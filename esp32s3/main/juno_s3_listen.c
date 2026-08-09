/* juno_s3_listen.c — THE LISTEN FIRMWARE. Engine B rendering audible audio
 * on the ESP32-S3, out of I2S.
 *
 * WHAT IT PROVES AND WHAT IT DOES NOT, stated before anything else.
 *
 *   IT PROVES: the per-sample DSP chain -- eb_engine_render_voices() plus
 *   eb_master_render(), the code the standalone gate certifies EXACTLY 0
 *   against the port and 11/11 bit-exact against the PLUGIN -- runs on real
 *   silicon, in real time or not, and what comes out is the instrument.
 *
 *   IT DOES NOT PROVE RECALL. Engine B has no device-side recall path; that
 *   is a recorded open item. The coefficients here were built ON THE HOST by
 *   eb_render_coefs_build()/eb_master_coefs_build() and frozen into
 *   s3_listen.bin (tools/engineb/gen_listen_coefs.py). Calling this "the
 *   synth running on the S3" would be the over-claim; it is the ENGINE
 *   running on the S3, fed by host-built coefficients.
 *
 * THE VOICE COUNT IS A RUNTIME NUMBER, not a rebuild. S3L_VOICES below caps
 * how many voices are allowed to sound; the rest are held at rest and cost
 * only their state advance. Start at 2, raise it until the underrun counter
 * moves, and the last value that stays at zero is this board's honest
 * polyphony -- MEASURED on the thing itself instead of divided out of a
 * cycle budget.
 *
 * UNDERRUNS ARE COUNTED AND PRINTED. A synth that is 20 % over budget still
 * makes sound; it makes sound with holes in it. The counter is the difference
 * between "it works" and "it sounds like it works", and it is printed every
 * second whether or not it is zero.
 */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "driver/i2s_std.h"
#include "esp_heap_caps.h"
#include "esp_timer.h"
#include "esp_task_wdt.h"
#include "eb_engine.h"
#include "eb_render.h"
#include "eb_coefs.h"
#include "eb_master.h"
#include "eb_master_coefs.h"
#include "s3_listen_meta.h"

/* ---- board wiring. Change these three to match your DAC/codec. ---------- */
#ifndef S3L_BCLK
#define S3L_BCLK  GPIO_NUM_5
#endif
#ifndef S3L_LRCK
#define S3L_LRCK  GPIO_NUM_6
#endif
#ifndef S3L_DOUT
#define S3L_DOUT  GPIO_NUM_7
#endif

/* S3L_VOICES -- how many voices this build is allowed to sound. The blob
 * carries one snapshot per chord size 1..8, so this selects a CHORD, and the
 * voices it wakes are the ones the probe MEASURED as sounding for that chord.
 * That matters: the port's allocator fills from voice 7 downward, so waking
 * voices 0..N-1 wakes exactly the silent ones. */
/* S3L_NOFX -- STEP 1: the VOICE CHAIN ONLY, no master/FX stage.
 *
 * WHY IT EXISTS. The first board run measured 20,465 cycles/sample at TWO
 * voices against a 22.68 us budget -- 3.7x over -- while the same engine
 * prices at ~20,860 INSTRUCTIONS for SIX voices. The difference is memory:
 * this build puts 6.2 MB of FX rings and 1.4 MB of state in PSRAM at 80 MHz
 * and touches them every sample. F4's own firmware header warned that its
 * cycles-per-sample was an INTERNAL-SRAM figure and must not be quoted as the
 * product's until a PSRAM-resident run existed. This is that run, and it says
 * the placement costs about 4x.
 *
 * With S3L_NOFX the master chain is not called and NO ring is allocated at
 * all, so nothing in the per-sample path reaches PSRAM except the voice
 * state. It is the smallest build that makes sound, and it isolates the
 * question: if this fits, the overrun is placement and not arithmetic. */
#ifndef S3L_TONE
#define S3L_TONE 0
#endif

#ifndef S3L_OFFLINE
#define S3L_OFFLINE 0
#endif

#ifndef S3L_NOFX
#define S3L_NOFX 0
#endif

/* S3_OFFLINE and S3_NOFX ARE MUTUALLY EXCLUSIVE, and this #error exists
 * because they were combined once by accident and the board died. The offline
 * renderer calls eb_master_render(); under S3L_NOFX the master state and its
 * rings are never allocated, so that is a null dereference on the first
 * sample -- LoadProhibited, EXCVADDR 0.
 *
 * HOW IT HAPPENED, recorded so it is not repeated: S3_OFFLINE is a CMake
 * CACHE variable. A build that does not pass it INHERITS the previous
 * build's value unless the build directory is wiped. The project already has
 * this exact trap recorded for S3_EXTRA_DEFS. ALWAYS rm -rf build when the
 * flag set changes. */
#if S3L_NOFX && S3L_OFFLINE
#error "S3_NOFX and S3_OFFLINE cannot be combined: offline renders the master chain, NOFX does not allocate it. Wipe the build dir (rm -rf build) -- these are CMake CACHE vars and persist."
#endif

#ifndef S3L_VOICES
#define S3L_VOICES 2
#endif

#define SR        44100
#define CHUNK     128            /* frames per render/write */

/* __asm__, not `asm`: -std=c99 is strict ISO and does not spell it the short
 * way. The project's flags are uniform across host and target on purpose, so
 * the firmware conforms to them rather than the other way round. */
extern const uint8_t listen_bin_start[] __asm__("_binary_s3_listen_bin_start");
extern const uint8_t listen_bin_end[]   __asm__("_binary_s3_listen_bin_end");

static eb_engine        EBE;
static eb_render_coefs  RC;
static eb_master_coef   MC;
static eb_master_rings  RG;
static eb_render_state *RS;      /* 735 KB -- PSRAM */
static eb_master_state *MS;      /* 730 KB -- PSRAM */

static const uint8_t *B_RSTATE, *B_MSTATE, *B_COEF;


/* THE MASTER STATE IS COPIED MEMBER BY MEMBER, and this is not tidiness.
 * Five of its FX sub-states end in `float *ring` -- 8 bytes on the host that
 * generated the blob, 4 bytes here -- so sizeof(eb_master_state) is 729,824
 * there and 729,768 here. The first firmware copied the blob whole: every
 * field past the first pointer landed at the wrong offset, the reverb read a
 * garbage ring depth, and the board died with a LoadStoreError at an
 * unmapped address on its first rendered sample.
 *
 * min(host, target) bytes of each member is EXACT, because every pointer is
 * the LAST member of its struct and eb_master_render re-assigns all of them
 * from eb_master_rings before use. */
static const uint8_t *ms_load(const uint8_t *p)
{
    void *dst[S3L_NMSEC];
    unsigned tgt[S3L_NMSEC];
    int i;
    dst[0]=&MS->in;   tgt[0]=sizeof MS->in;
    dst[1]=&MS->d1;   tgt[1]=sizeof MS->d1;
    dst[2]=&MS->d4;   tgt[2]=sizeof MS->d4;
    dst[3]=&MS->e0;   tgt[3]=sizeof MS->e0;
    dst[4]=&MS->d23;  tgt[4]=sizeof MS->d23;
    dst[5]=&MS->d5;   tgt[5]=sizeof MS->d5;
    dst[6]=&MS->e1;   tgt[6]=sizeof MS->e1;
    dst[7]=&MS->e5;   tgt[7]=sizeof MS->e5;
    dst[8]=&MS->rev;  tgt[8]=sizeof MS->rev;
    dst[9]=&MS->cho;  tgt[9]=sizeof MS->cho;
    dst[10]=&MS->dcore; tgt[10]=sizeof MS->dcore;
    dst[11]=&MS->fb84672; tgt[11]=2u*sizeof(float);
    dst[12]=&MS->route_change; tgt[12]=sizeof MS->route_change;
    dst[13]=MS->rev_pending;   tgt[13]=sizeof MS->rev_pending;
    dst[14]=&MS->rev_wipe;     tgt[14]=sizeof MS->rev_wipe;
    for (i = 0; i < S3L_NMSEC; ++i) {
        unsigned n = S3L_MSEC[i] < tgt[i] ? S3L_MSEC[i] : tgt[i];
        memcpy(dst[i], p, n);
        p += S3L_MSEC[i];          /* the blob stride is the HOST size */
    }
    return p;
}

/* THE LAYOUT CHECK THAT CAN ACTUALLY FIRE.
 *
 * blob_open() below compares the blob's header words against the S3L_*
 * constants -- and the SAME generator run writes both, so it compares the
 * header with itself and cannot detect a firmware built at a different
 * layout. That blind check let two real faults through.
 *
 * FAULT 1, the MMU entry error: -DEB_DCO_WT=1 inserts 1,412 bytes at offset
 * 3,016, inside the 6,904-byte voice prefix load_coefs() memcpy's in. The
 * wavetable state received trunk bytes, rpos became a wild index, and the
 * board died on its first sounding sample.
 *
 * FAULT 2, the one that made a booting board sound like a steam engine: the
 * blob was simply STALE. eb_render_state had grown 96 bytes since it was
 * generated, and chorus, delay and reverb all live AFTER the growth -- so
 * every FX state read shifted bytes. The voices were fine, which is why an
 * envelope was audible underneath the noise.
 *
 * AN EARLIER VERSION OF THIS CHECK ALLOWED 256 BYTES OF "POINTER SLACK", on
 * the reasoning that the host has 8-byte pointers and the S3 has 4. That
 * reasoning was wrong and the slack would have passed fault 2 silently:
 * eb_render_state contains NO pointer, so its size is identical on both, and
 * the 96 bytes were new members rather than pointer width. It is an equality.
 * (eb_master_state DOES carry pointers, which is exactly why ms_load copies
 * it member by member instead of whole.)
 *
 * C99 has no _Static_assert, so this is the negative-array form. */
typedef char s3l_rstate_layout_check
    [(sizeof(eb_render_state) == S3L_RSTATE_SZ) ? 1 : -1];
typedef char s3l_voice_prefix_check
    [(S3L_VOICE_SZ <= S3L_RSTATE_SZ) ? 1 : -1];

/* EB_DCO_WT no longer needs a blanket refusal: the generator now builds its
 * mask probe from null_b.CFLAGS, so a blob made under -DEB_DCO_WT=1 is read
 * by a probe at the SAME layout, and the size equality above catches any
 * disagreement between blob and firmware directly. The refusal was correct
 * while the blob could only be trunk-layout; it is not correct now, and
 * leaving it would block the lever it was written to protect.
 *
 * MEASURED on the way here: with the probe built at the wrong layout the
 * masks came back 0x00 for all eight chords -- "no voice sounds" -- and a
 * firmware built on them would have rendered SILENCE. gen_listen_coefs.py
 * now refuses an all-zero mask instead of writing it. */

static int blob_open(void)
{
    const uint32_t *h = (const uint32_t *)listen_bin_start;
    size_t have = (size_t)(listen_bin_end - listen_bin_start);
    size_t want = 32u + S3L_RSTATE_SZ + S3L_MSTATE_SZ
                + (size_t)S3L_NNOTE * 2u
                  * (S3L_COEF_SZ + S3L_MCOEF_SZ + S3L_VOICE_SZ);
    if (h[0] != S3L_MAGIC) { printf("BLOB: bad magic\n"); return 0; }
    /* THE SIZE CHECK IS NOT CEREMONY. The blob's layout is generated by a
     * host script against THIS build's struct sizes; if either side changes
     * and the other does not, every coefficient after the drift is garbage
     * and the firmware would happily render noise and call it a JUNO. */
    if (h[2] != S3L_COEF_SZ || h[3] != S3L_MCOEF_SZ ||
        h[4] != S3L_RSTATE_SZ || h[5] != S3L_MSTATE_SZ ||
        h[6] != S3L_VOICE_SZ || have != want) {
        printf("BLOB: LAYOUT MISMATCH -- regenerate s3_listen.bin\n"
               "  blob coef/mcoef/rstate/mstate = %u/%u/%u/%u\n"
               "  build                         = %u/%u/%u/%u\n"
               "  bytes have %u want %u\n",
               (unsigned)h[2], (unsigned)h[3], (unsigned)h[4], (unsigned)h[5],
               (unsigned)S3L_COEF_SZ, (unsigned)S3L_MCOEF_SZ,
               (unsigned)S3L_RSTATE_SZ, (unsigned)S3L_MSTATE_SZ,
               (unsigned)have, (unsigned)want);
        return 0;
    }
    B_RSTATE = listen_bin_start + 32;
    B_MSTATE = B_RSTATE + S3L_RSTATE_SZ;
    B_COEF   = B_MSTATE + S3L_MSTATE_SZ;
    return 1;
}

/* coefficient set for note index n, gate g (0 = on, 1 = off) */
static void load_coefs(int n, int g)
{
    const uint8_t *p = B_COEF + ((size_t)n * 2u + (size_t)g)
                       * (S3L_COEF_SZ + S3L_MCOEF_SZ + S3L_VOICE_SZ);
    memcpy(&RC, p, S3L_COEF_SZ);
    memcpy(&MC, p + S3L_COEF_SZ, S3L_MCOEF_SZ);
    /* THE VOICE STATE TOO, and without it there is no note. Envelopes,
     * phases, glide and the gate cells live in state, not in coefficients:
     * swapping only the coefficients leaves the envelope wherever it decayed
     * to and the engine renders a whisper. MEASURED in exactly that state --
     * the first firmware simulation peaked at 16 of 30000.
     *
     * Only the per-voice PREFIX is copied. The FX that follow it in this
     * struct are the master's business and must keep running across a note,
     * or every note-on would restart the reverb. */
    memcpy(RS, p + S3L_COEF_SZ + S3L_MCOEF_SZ, S3L_VOICE_SZ);
}

/* The master's nine delay rings. CALLER-OWNED by design (eb_master.h), and
 * they are the memory plan's whole story: about 6.4 MB for this patch, three
 * rings of 512 K floats each. They go to PSRAM; if PSRAM is absent this fails
 * loudly here rather than by rendering silence.
 *
 * THE LENGTHS COME FROM THE PORT'S OWN CELLS, through the generated
 * S3L_RING_LEN. The first draft of this file wrote down nine plausible powers
 * of two from memory and got four of them wrong (8192 written as 32768,
 * 524288 as 2097152). A ring that does not match the length its coefficients
 * were built against is a wrong delay time at best and a read past the end at
 * worst -- eb_master.h states that requirement, and guessing at it in the one
 * file that finally makes sound would have been a poor way to honour it. */
static int rings_alloc(void)
{
    float **dst[9] = { &RG.t1, &RG.t23, &RG.t5_0, &RG.t5_1, &RG.t5_2,
                       &RG.t5_3, &RG.e5, &RG.t4_0, &RG.t4_1 };
    int32_t *len[9] = { &RG.t1_len, &RG.t23_len, &RG.t5_0_len, &RG.t5_1_len,
                        &RG.t5_2_len, &RG.t5_3_len, &RG.e5_len,
                        &RG.t4_0_len, &RG.t4_1_len };
    /* the port's own ring lengths, the same nine the standalone shim copies */
    int i;
    for (i = 0; i < 9; ++i) {
        *dst[i] = heap_caps_calloc((size_t)S3L_RING_LEN[i], sizeof(float),
                                   MALLOC_CAP_SPIRAM);
        if (!*dst[i]) { printf("RINGS: PSRAM alloc failed at %d\n", i); return 0; }
        *len[i] = S3L_RING_LEN[i];
    }
    return 1;
}


/* ---- THE SECOND CORE -------------------------------------------------------
 *
 * S3_CORES=2 renders voices [0,S3L_SPLIT) on core 0 and [S3L_SPLIT,N) on core
 * 1. Until this existed the S3's second core had never rendered a sample,
 * while every cycle figure was compared against a two-core budget.
 *
 * THE HANDSHAKE IS A SPIN, NOT A SEMAPHORE, and that is deliberate: a
 * FreeRTOS semaphore round trip is hundreds of cycles and this happens every
 * sample. Both cores are dedicated to audio here, so a spin wastes nothing
 * that had another use. The flags are volatile and each is written by exactly
 * one core, which is what makes them safe without a lock.
 *
 * The worker must NOT be starved by the idle task or the watchdog, so it runs
 * at the highest priority on core 1 and the loop feeds the watchdog itself. */
#if S3_CORES >= 2
#ifndef S3L_SPLIT
#ifndef EB_PROLOGUE_PIPE
#define EB_PROLOGUE_PIPE 0
#endif
#define S3L_SPLIT (EB_NUM_VOICES / 2)
#endif

/* ---- BLOCK-LEVEL PARALLELISM ------------------------------------------------
 *
 * The first two-core build synchronised EVERY SAMPLE: signal core 1, render,
 * spin at a barrier. At 44,100 Hz that is 88,200 cross-core handshakes a
 * second, and the barrier sits on the critical path each time -- MEASURED at
 * roughly 1,436 cycles per sample, which is 26 % of the entire 5,442-cycle
 * real-time budget spent on handshaking rather than DSP.
 *
 * A whole CHUNK is now handed over at once, so there is ONE barrier per 128
 * samples instead of 128. The order is what makes it legal:
 *
 *   1. core 0 runs the prologue for all CHUNK samples, into an array. The
 *      prologue advances the shared noise, voice 0's cvgate/glide and the
 *      LFO, and NOTHING in a voice range writes back into any of them -- so
 *      the whole block can be computed ahead of any voice.
 *   2. core 1 renders its voice range for all CHUNK samples.
 *   3. core 0 renders its range for the same CHUNK, concurrently.
 *   4. one barrier.
 *
 * The per-sample loop afterwards only reads finished voice buffers. */
static volatile int      w_go = 0, w_done = 0, w_quit = 0;
static eb_shared_tick    w_shb[CHUNK];
static float             w_vbb[CHUNK][EB_NUM_VOICES];
static int               w_n = 0;

/* ROLLING READY INDEX, not a barrier. The first block design computed ALL
 * 128 prologues before releasing core 1, so the whole prologue pass (notecv +
 * voice-0 cvgate/glide + the shared LFO) sat on the critical path with core 1
 * idle. w_ready is published by core 0 as each sample's prologue completes and
 * consumed by core 1, so the two overlap. One writer per flag; volatile. */
static volatile int w_ready = 0;

static void worker(void *arg)
{
    int i;
    (void)arg;
    for (;;) {
        while (!w_go) { if (w_quit) vTaskDelete(NULL); }
        for (i = 0; i < w_n; ++i) {
            while (w_ready <= i) { }        /* wait for this sample's prologue */
            eb_engine_render_range(&EBE, RS, &RC, (const eb_render_needs *)0,
                                   S3L_SPLIT, EB_NUM_VOICES, &w_shb[i],
                                   w_vbb[i]);
        }
        w_go = 0;
        w_done = 1;
    }
}

static void render_block(int n)
{
    int i, k;
    /* Release core 1 FIRST; it blocks on w_ready until sample 0's prologue is
     * published, then runs one sample behind core 0's prologue rather than a
     * whole block behind it. */
    /* THE AT-REST VOICES, ONCE FOR THE WHOLE BLOCK (EB_ATREST_BLOCK).
     * A no-op unless that flag is set. Both ranges are advanced here on core
     * 0: an at-rest voice's free-run state is touched by nothing else in the
     * block, so there is no race with core 1, which skips those voices. */
    eb_engine_advance_atrest(&EBE, RS, &RC, 0, EB_NUM_VOICES, n);
    w_n    = n;
    w_ready = 0;
    w_done = 0;
    w_go   = 1;
#if EB_PROLOGUE_PIPE
    /* THE PROLOGUE IS A SERIAL HEAD, AND IT DOES NOT HAVE TO BE.
     *
     * MEASURED from the sweep's own slope (which predicts the 3-voice point
     * to the cycle in two independent builds): a sounding voice costs ~3,280
     * cycles and the prologue ~1,300. Core 1 waits for that prologue EVERY
     * SAMPLE before it may start, so the loop is prologue + max(core0, core1)
     * -- the prologue is charged to the critical path in full while a whole
     * core sits idle through it.
     *
     * Compute sample i+1's prologue AFTER core 0's own voices for sample i,
     * and publish sample i's at the TOP of the iteration. Core 1 is then
     * never blocked and the loop becomes
     *     max(core0_voices + prologue, core1_voices)
     * which lets an asymmetric split hide the prologue behind the other
     * core's voices entirely.
     *
     * BIT-EXACT BY CONSTRUCTION: the ORDER OF STATE UPDATES IS UNCHANGED --
     * prologue[i], voices[i], prologue[i+1], voices[i+1] is exactly the
     * sequence the serial version runs. Only the release point of core 1
     * moves, and core 1 touches none of the state the prologue advances
     * (notecv, glide[0], lfo[0]); voice 0's render consumes the published
     * eb_shared_tick rather than recomputing any of it. */
    w_shb[0].ready = 0;
    eb_engine_render_shared(&EBE, RS, &RC, &w_shb[0]);
    for (i = 0; i < n; ++i) {
        for (k = 0; k < EB_NUM_VOICES; ++k) w_vbb[i][k] = 0.0f;
        w_ready = i + 1;                    /* prologue[i] is already done */
        eb_engine_render_range(&EBE, RS, &RC, (const eb_render_needs *)0,
                               0, S3L_SPLIT, &w_shb[i], w_vbb[i]);
        if (i + 1 < n) {
            w_shb[i + 1].ready = 0;
            eb_engine_render_shared(&EBE, RS, &RC, &w_shb[i + 1]);
        }
    }
#else
    for (i = 0; i < n; ++i) {
        for (k = 0; k < EB_NUM_VOICES; ++k) w_vbb[i][k] = 0.0f;
        w_shb[i].ready = 0;
        eb_engine_render_shared(&EBE, RS, &RC, &w_shb[i]);
        w_ready = i + 1;                          /* publish; core 1 may go */
        eb_engine_render_range(&EBE, RS, &RC, (const eb_render_needs *)0,
                               0, S3L_SPLIT, &w_shb[i], w_vbb[i]);
    }
#endif
    while (!w_done) { }                           /* ONE barrier per block */
}
#else
static float w_vbb[CHUNK][EB_NUM_VOICES];
static void render_block(int n)
{
    int i, k;
    eb_engine_advance_atrest(&EBE, RS, &RC, 0, EB_NUM_VOICES, n);
    for (i = 0; i < n; ++i) {
        for (k = 0; k < EB_NUM_VOICES; ++k) w_vbb[i][k] = 0.0f;
        eb_engine_render_voices(&EBE, RS, &RC, (const eb_render_needs *)0,
                                w_vbb[i]);
    }
}
#endif

static i2s_chan_handle_t TX;

static int i2s_start(void)
{
    i2s_chan_config_t cc = I2S_CHANNEL_DEFAULT_CONFIG(I2S_NUM_AUTO,
                                                      I2S_ROLE_MASTER);
    i2s_std_config_t sc = {
        .clk_cfg  = I2S_STD_CLK_DEFAULT_CONFIG(SR),
        .slot_cfg = I2S_STD_PHILIPS_SLOT_DEFAULT_CONFIG(
                        I2S_DATA_BIT_WIDTH_16BIT, I2S_SLOT_MODE_STEREO),
        .gpio_cfg = { .mclk = I2S_GPIO_UNUSED, .bclk = S3L_BCLK,
                      .ws = S3L_LRCK, .dout = S3L_DOUT,
                      .din = I2S_GPIO_UNUSED,
                      .invert_flags = {0, 0, 0} },
    };
    cc.dma_desc_num = 6;
    cc.dma_frame_num = CHUNK;
    if (i2s_new_channel(&cc, &TX, NULL) != ESP_OK) return 0;
    if (i2s_channel_init_std_mode(TX, &sc) != ESP_OK) return 0;
    return i2s_channel_enable(TX) == ESP_OK;
}

void app_main(void)
{
    static int16_t pcm[CHUNK * 2];
    unsigned long frame = 0, underrun = 0, chunks = 0;
    unsigned long busy_us = 0;
    int64_t t_start;
    int behind = 0;
    int step = 0, gate = 0;
    /* the chord index for this build's voice count, clamped to what exists */
    const int CH = (S3L_VOICES < 1 ? 1 :
                    S3L_VOICES > S3L_NNOTE ? S3L_NNOTE : S3L_VOICES) - 1;
    /* OFFLINE RENDERS EVERY VOICE. The cap exists for the REAL-TIME build,
     * where cycles are the constraint; rendering into memory has no such
     * constraint, and capping there deletes real sound. MEASURED against the
     * plugin on patch 0, C3, full master chain:
     *
     *     1 voice awake   best-fit gain 0.955   residual -10.8 dB
     *     all 8 awake     best-fit gain 1.0002  residual -72.5 dB
     *
     * -72.5 dB is the 16-bit floor. The 29 % of signal the cap was throwing
     * away is the free-running output of the seven voices the JUNO renders
     * whether or not they are sounding -- the instrument's own character,
     * not noise, and the thing that made the capped build sound dead. */
#if S3L_OFFLINE
    unsigned WAKE = 0xffu;
#else
    unsigned WAKE = S3L_MASK[CH];
#endif
    /* THE SLOPE, MEASURED INSTEAD OF EXTRAPOLATED.
     *
     * The 1-voice cost was never measured -- it was the priced slope times a
     * c/i that had itself been DEFINED as measured-cycles / priced-
     * instructions at 2 voices, so predicting the 2-voice point back agreed
     * to 0.2 % by construction and validated nothing.
     *
     * This sweep measures three points on the real board: NO voices awake
     * (the shared base -- notecv, the shared LFO, the idle advances -- plus
     * every non-engine cost in the loop), ONE voice, and TWO. The slope and
     * the intercept then come from silicon, and the engine time is timed
     * SEPARATELY from the chunk so the PCM conversion and I2S call cannot be
     * charged to the DSP. */
#ifndef S3L_SWEEP
#define S3L_SWEEP 0
#endif
    /* THE SWEEP REACHES 6 NOW. Two points give a slope and an intercept, but
     * they cannot show CURVATURE -- and curvature is the whole question once
     * the FX move to a second board and the voice state fits internal SRAM.
     * The masks fill from voice 7 downward, which is the allocator's own
     * order (S3L_MASK in the generated header, measured not assumed). */
    /* 0xd0 IS THE PROLOGUE-PIPELINING PROBE, and it is here because the
     * lever is INVISIBLE at every other point in this sweep. The gain only
     * appears when the prologue-bearing core carries FEWER voices than the
     * other: 0xd0 wakes voice 4 (core 0) and voices 6,7 (core 1), a 1-vs-2
     * split. Serial, the loop is prologue + 2*voice ~= 7,860; pipelined it is
     * max(prologue + voice, 2*voice) ~= 6,560. Any symmetric mask hides the
     * difference completely, which is why adding this point comes BEFORE
     * trusting a pipelining measurement. */
    static const unsigned SWEEP[7] = { 0x00u, 0x80u, 0xc0u, 0xe0u,
                                       0xf0u, 0xfcu, 0xd0u };
    (void)SWEEP;
    int phase = 0;
    unsigned long eng_us = 0, ph_chunks = 0;

    printf("\n=== JUNO ENGINE B — S3 LISTEN FIRMWARE ===\n");
    printf("voices allowed: %d   sample rate: %d\n", S3L_VOICES, SR);
    printf("free internal %u  free PSRAM %u\n",
           (unsigned)heap_caps_get_free_size(MALLOC_CAP_INTERNAL),
           (unsigned)heap_caps_get_free_size(MALLOC_CAP_SPIRAM));

    if (!blob_open()) { printf("HALT: no usable coefficient blob.\n"); return; }

    /* THE VOICE STATE GOES TO INTERNAL RAM, and the reason is measured.
     * With the FX chain removed the board still ran at 12,720 cycles/sample
     * for two voices against a ~6,000-instruction model -- the only PSRAM
     * left in the per-sample path was this struct.
     *
     * It is 735 KB and internal RAM has 218 KB, but the VOICE CHAIN ONLY
     * TOUCHES THE FIRST 6,808 BYTES: everything after offsetof(chorus) is a
     * legacy copy of the FX state that eb_engine_render_voices never reads --
     * verified by grepping eb_render.c for st->chorus / st->delay /
     * st->reverb / st->rev_*, which returns nothing.
     *
     * So the full struct is allocated in PSRAM (the master chain still wants
     * it when FX are on) and, when FX are OFF, a 6,808-byte INTERNAL copy is
     * used instead. Under S3L_NOFX nothing can reach past the prefix. */
#if S3L_NOFX
    RS = heap_caps_malloc(S3L_VOICE_SZ + 64u, MALLOC_CAP_INTERNAL);
#else
    RS = heap_caps_malloc(sizeof *RS, MALLOC_CAP_SPIRAM);
#endif
#if S3L_NOFX
    MS = 0;
#else
    MS = heap_caps_malloc(sizeof *MS, MALLOC_CAP_SPIRAM);
#endif
#if S3L_NOFX
    if (!RS) { printf("HALT: internal alloc for voice state failed.\n"); return; }
    printf("voice state in INTERNAL RAM (%u bytes)\n", (unsigned)S3L_VOICE_SZ);
#else
    if (!RS || !MS) { printf("HALT: PSRAM alloc for states failed.\n"); return; }
#endif
#if S3L_NOFX
    memcpy(RS, B_RSTATE, S3L_VOICE_SZ);      /* the prefix is all that exists */
#else
    memcpy(RS, B_RSTATE, S3L_RSTATE_SZ);
#endif
#if !S3L_NOFX
    ms_load(B_MSTATE);
    if (!rings_alloc()) { printf("HALT: rings.\n"); return; }
#else
    printf("BUILD: VOICES ONLY -- master/FX chain not called, no rings.\n");
#endif

    eb_engine_init(&EBE, (float)SR);
    /* render_ok is the standalone engine's own guard. Setting it here is
     * legitimate for exactly the reason eb_render.h gives: the three gates it
     * names (null_b standalone, plugin_check, the teeth bracket) have all run
     * and all passed. It is not being switched on to make this build work. */
    EBE.render_ok = 1;
    load_coefs(CH, 0);

#if S3_CORES >= 2
    /* HIGHEST priority on core 1 so nothing preempts a spin the audio loop is
     * waiting on. Started AFTER the engine state is seeded, or it would
     * render from an uninitialised eb_render_state on its first spin. */
    xTaskCreatePinnedToCore(worker, "eb_core1", 4096, NULL,
                            configMAX_PRIORITIES - 1, NULL, 1);
    /* THE WORKER SPINS AND NEVER YIELDS, so core 1's idle task never runs and
     * the task watchdog reports IDLE1 every five seconds. Nothing crashes and
     * no sample is lost -- but a log full of backtraces hides real faults, and
     * this one is by design. Unsubscribe core 1's idle task rather than make
     * the audio path yield. */
    {   TaskHandle_t idle1 = xTaskGetIdleTaskHandleForCore(1);
        if (idle1) esp_task_wdt_delete(idle1);
    }
    printf("TWO CORES: voices 0..%d on core 0, %d..%d on core 1\n",
           S3L_SPLIT - 1, S3L_SPLIT, EB_NUM_VOICES - 1);
#else
    printf("ONE CORE: all %d voices on core 0\n", EB_NUM_VOICES);
#endif
    if (!i2s_start()) { printf("HALT: I2S would not start.\n"); return; }
#if S3L_TONE
    /* A LOUD SQUARE WAVE, NO ENGINE AT ALL.
     *
     * This exists to split one question into two. The firmware is provably
     * clocking data out of GPIO 5/6/7 -- it prints that it is playing -- yet
     * nothing is audible. Either the DAC/wiring is not carrying it, or the
     * engine's own samples are the problem. A full-scale 440 Hz square is
     * unmistakable through any working chain: if this is silent the fault is
     * hardware, and if it is audible the fault is upstream of the codec and
     * I stop blaming the wiring. */
    {
        static int16_t t[CHUNK * 2];
        int n = 0, hi = 1;
        printf("TEST TONE: 440 Hz square, FULL SCALE. No engine in the path.\n");
        for (;;) {
            size_t wrote = 0; int i;
            for (i = 0; i < CHUNK; ++i) {
                if (++n >= 50) { n = 0; hi = !hi; }   /* 44100/50/2 = 441 Hz */
                t[2*i] = t[2*i+1] = hi ? 22000 : -22000;
            }
            i2s_channel_write(TX, t, sizeof t, &wrote, portMAX_DELAY);
        }
    }
#endif
    t_start = esp_timer_get_time();
    printf("chord of %d voice(s), wake mask 0x%02x, "
           "%.2f s held / %.2f s released, looping\n\n",
           S3L_NVOICE[CH], WAKE,
           (double)S3L_HOLD_FRAMES / SR, (double)S3L_REL_FRAMES / SR);

    /* ================= OFFLINE RENDER, THEN REAL-TIME PLAYBACK =========
     * The engine is 1.4x too slow to feed the codec live at one voice. That
     * is a scheduling problem, not a sound problem: rendered into memory
     * first, every sample is correct and the DAC gets a perfectly-timed
     * stream. This is how you HEAR the port today while the real-time work
     * continues -- and it is honest about what it is, because the render is
     * timed and printed, so the shortfall stays visible instead of hidden.
     *
     * 10 seconds of stereo int16 = 1.76 MB in PSRAM. The DMA reads from
     * PSRAM at playback, which is trivially fast enough: 176 KB/s. */
#if S3L_OFFLINE
    {
        /* THE FULL INSTRUMENT, OFFLINE. The FX were cut for the REAL-TIME
         * build and then carried forward out of momentum; offline there is
         * no reason for it. MEASURED: the dry voice bus differs from the
         * port's own output by -10.8 dB, and patch 0's stereo width (L-R
         * 0.054 rms against a 0.066 signal) is entirely chorus. Without the
         * master chain this patch is a dry mono voice, which is what "the
         * VCF melts away" was describing -- the filter envelope itself
         * matches the port to within 10 % on spectral centroid.
         *
         * PSRAM: rings 6.46 MB + states 1.46 MB leaves room for ONE note
         * cycle. So the peak is found by rendering TWICE rather than by
         * keeping a float buffer -- offline, time is the cheap resource. */
        const unsigned long NFR = (unsigned long)S3L_HOLD_FRAMES
                                + (unsigned long)S3L_REL_FRAMES;
        int16_t *buf = heap_caps_malloc(NFR * 2u * sizeof(int16_t),
                                        MALLOC_CAP_SPIRAM);
        unsigned long f;
        float pk = 0.0f, g = 1.0f;
        uint32_t rnd = 22222u;
        int pass;
        int64_t t0;
        if (!buf) { printf("HALT: no PSRAM for the audio buffer.\n"); return; }
        printf("rendering %lu frames (%.2f s, ONE note cycle) with the FULL "
               "master chain: chorus, delay, reverb, stereo.\n",
               NFR, (double)NFR / SR);
        t0 = esp_timer_get_time();
        for (pass = 0; pass < 2; ++pass) {
            /* RE-SEED EVERY PASS. The FX carry state across the whole render
             * -- a second pass on a warm reverb is a different signal, and
             * the peak from pass 1 would then be the wrong number for
             * pass 2's audio. */
            memcpy(RS, B_RSTATE, S3L_RSTATE_SZ);
            ms_load(B_MSTATE);
            frame = 0; gate = 0;
            load_coefs(CH, 0);
            for (f = 0; f < NFR; ++f) {
                float vb[EB_NUM_VOICES], L = 0.0f, R = 0.0f;
                int k;
                for (k = 0; k < EB_NUM_VOICES; ++k)
                    EBE.v[k].atrest = !((WAKE >> k) & 1u);
                for (k = 0; k < EB_NUM_VOICES; ++k) vb[k] = 0.0f;
                /* the OFFLINE path renders one sample at a time on purpose:
                 * it is not real-time constrained, and a block buffer here
                 * would only duplicate render_block's storage. */
                render_block(1);
                { int q; for (q = 0; q < EB_NUM_VOICES; ++q) vb[q] = w_vbb[0][q]; }
                eb_master_render(MS, &MC, &RG, vb, &L, &R);
                if (pass == 0) {
                    float a1 = L < 0.0f ? -L : L, a2 = R < 0.0f ? -R : R;
                    if (a1 > pk) pk = a1;
                    if (a2 > pk) pk = a2;
                } else {
                    float d, v;
                    rnd = rnd * 1664525u + 1013904223u;
                    d  = (float)(int32_t)(rnd >> 16) / 32768.0f;
                    rnd = rnd * 1664525u + 1013904223u;
                    d += (float)(int32_t)(rnd >> 16) / 32768.0f;
                    v = L * g * 32767.0f + d * 0.5f;
                    if (v > 32767.0f) v = 32767.0f;
                    else if (v < -32768.0f) v = -32768.0f;
                    buf[2 * f] = (int16_t)v;
                    v = R * g * 32767.0f + d * 0.5f;
                    if (v > 32767.0f) v = 32767.0f;
                    else if (v < -32768.0f) v = -32768.0f;
                    buf[2 * f + 1] = (int16_t)v;
                }
                if (++frame >= (unsigned long)(gate ? S3L_REL_FRAMES
                                                    : S3L_HOLD_FRAMES)) {
                    frame = 0; gate = !gate; load_coefs(CH, gate);
                }
                if ((f % (SR / 2)) == 0)
                    printf("  pass %d  %lu%%\n", pass + 1, 100u * f / NFR);
            }
            if (pass == 0) {
                g = (pk > 1e-9f) ? (0.891f / pk) : 1.0f;
                printf("peak %.4f -> gain x%.3f (-1 dBFS)\n",
                       (double)pk, (double)g);
            }
        }
        printf("rendered in %.1f s (%.2fx real time)\n",
               (double)(esp_timer_get_time() - t0) / 1e6,
               (double)(esp_timer_get_time() - t0) / 1e6
                   / (2.0 * (double)NFR / SR));
        printf("PLAYING C3 on patch 0, FULL CHAIN, stereo, looping.\n");
        for (;;) {
            size_t wrote = 0;
            i2s_channel_write(TX, buf, NFR * 2u * sizeof(int16_t), &wrote,
                              portMAX_DELAY);
        }
    }
#endif
    for (;;) {
        int64_t t0 = esp_timer_get_time();
        int64_t te = 0;
        int i;
#if S3L_SWEEP
        /* THE COST SWEEP overrides the chord with 0, 1 and 2 voices to get a
         * slope and an intercept from silicon. It renders SILENCE for its
         * first eight seconds by design, so it is not the build to listen to
         * -- and it was the default, which is why the first listening attempt
         * heard nothing. */
        WAKE = SWEEP[phase];
#endif
        /* THE VOICE CAP. A capped voice is `atrest`, which is NOT "skipped":
         * eb_render.c still advances its free-run state. WAKE is constant
         * across a chunk, so this leaves the per-sample path. */
        {   int k;
            for (k = 0; k < EB_NUM_VOICES; ++k)
                EBE.v[k].atrest = !((WAKE >> k) & 1u);
        }
        /* THE WHOLE CHUNK, then ONE barrier. The timer is read TWICE per
         * BLOCK rather than twice per sample: esp_timer_get_time() reads a
         * hardware timer and is not free, and at two calls a sample it was
         * billing its own cost to the engine it was measuring. */
        {   int64_t e0 = esp_timer_get_time();
            render_block(CHUNK);
            te += esp_timer_get_time() - e0;
        }
        for (i = 0; i < CHUNK; ++i) {
            float *vb = w_vbb[i];
            float L = 0.0f, R = 0.0f;
            int k; (void)k;
#if S3L_NOFX
            /* The port's master sums the voices; everything after that is
             * FX. Summing here is NOT a claim to be the master stage -- it
             * is the dry voice bus, which is what this build measures. */
            for (k = 0; k < EB_NUM_VOICES; ++k) L += vb[k];
            R = L;
#else
            eb_master_render(MS, &MC, &RG, vb, &L, &R);
#endif
            if (L > 1.0f) L = 1.0f; else if (L < -1.0f) L = -1.0f;
            if (R > 1.0f) R = 1.0f; else if (R < -1.0f) R = -1.0f;
            pcm[2 * i]     = (int16_t)(L * 30000.0f);
            pcm[2 * i + 1] = (int16_t)(R * 30000.0f);

            /* One chord, held then released, repeating. `gate` 0 = held.
             *
             * THE TIMES ARE THE BLOB'S, NOT THIS FILE'S. Releasing copies the
             * OFF snapshot's voice state in (the gate lives in state -- with
             * coefficients alone the note does not release at all, measured),
             * so the hold length here MUST equal the one the snapshot was
             * captured at or the copy is a jump. It was: 1024 frames captured
             * against 1.5 s held, a 4,716-count step, audible as a pluck at
             * the end of every note. */
            if (++frame >= (unsigned long)(gate ? S3L_REL_FRAMES : S3L_HOLD_FRAMES)) {
                frame = 0;
                gate = !gate;
                load_coefs(CH, gate);
            }
            (void)step;
        }
        busy_us += (unsigned long)(esp_timer_get_time() - t0);
        eng_us  += (unsigned long)te;
        ++ph_chunks;

        {   /* A FULL DMA QUEUE MEANS WE ARE AHEAD; a timeout means we are
             * behind and the codec ran dry. That is the underrun. */
            size_t wrote = 0;
            /* A TIMEOUT IS NOT THE ONLY UNDERRUN, and the first board run
             * proved it: the engine ran at 27 % of real time and this
             * counter stayed at 0 for eight seconds, because when you are
             * permanently behind there is ALWAYS free DMA space and the
             * write never blocks. The real test is the wall clock. */
            if (i2s_channel_write(TX, pcm, sizeof pcm, &wrote,
                                  pdMS_TO_TICKS(50)) != ESP_OK
                || wrote != sizeof pcm)
                ++underrun;
        }

        vTaskDelay(1);          /* feed the watchdog; the loop had starved IDLE0 */
        if (++chunks % (SR / CHUNK) == 0) {
            /* cycles/sample, from the real render loop rather than a model */
            double us_per_sample = (double)busy_us / (double)(chunks * CHUNK);
            /* THE WALL-CLOCK TEST, which is the one that decides. */
            {   double real_us = (double)esp_timer_get_time() - (double)t_start;
                double audio_us = (double)(chunks * CHUNK) * 1e6 / (double)SR;
                if (real_us > audio_us * 1.02) behind = 1;
            }
            {   double n = (double)(ph_chunks * CHUNK);
                double e = (double)eng_us / n, w = (double)busy_us / n;
                /* PRINT THE MASK THAT IS ACTUALLY IN FORCE. This printed
                 * SWEEP[phase] even when the sweep was not driving WAKE, so
                 * it read "wake=0x00" while six voices were rendering -- a
                 * diagnostic that says the opposite of the truth. */
                printf("wake=0x%02x  engine %.2f us (%.0f cyc)  "
                       "whole loop %.2f us (%.0f cyc)  overhead %.0f cyc\n",
                       WAKE, e, e * 240.0, w, w * 240.0,
                       (w - e) * 240.0);
                if (chunks / (SR / CHUNK) % 8 == 0) {
                    phase = (phase + 1) % 7;
                    eng_us = busy_us = ph_chunks = 0;
                }
            }
            printf("t=%lus  %s  underruns=%lu  render %.2f us/sample "
                   "(~%.0f cycles at 240 MHz)  budget %.2f us  %s\n",
                   chunks / (SR / CHUNK),
                   behind ? "BEHIND REAL TIME" : "realtime OK",
                   underrun, us_per_sample,
                   us_per_sample * 240.0, 1e6 / (double)SR,
                   us_per_sample < 1e6 / (double)SR ? "FITS" : "OVER");
        }
    }
}

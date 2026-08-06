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
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "driver/i2s_std.h"
#include "esp_heap_caps.h"
#include "esp_timer.h"
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
#ifndef S3L_OFFLINE
#define S3L_OFFLINE 0
#endif

#ifndef S3L_NOFX
#define S3L_NOFX 0
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
    unsigned WAKE = S3L_MASK[CH];
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
    static const unsigned SWEEP[3] = { 0x00u, 0x80u, 0xc0u };
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

    if (!i2s_start()) { printf("HALT: I2S would not start.\n"); return; }
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
        const unsigned long NFR = (unsigned long)SR * 10u;
        int16_t *buf = heap_caps_malloc(NFR * 2u * sizeof(int16_t),
                                        MALLOC_CAP_SPIRAM);
        unsigned long f;
        int64_t t0;
        if (!buf) { printf("HALT: no PSRAM for the render buffer.\n"); return; }
        printf("rendering %lu s offline... (slower than real time; that is "
               "the point)\n", NFR / SR);
        t0 = esp_timer_get_time();
        frame = 0; gate = 0;
        load_coefs(CH, 0);
        for (f = 0; f < NFR; ++f) {
            float vb[EB_NUM_VOICES], L = 0.0f, R;
            int k;
            for (k = 0; k < EB_NUM_VOICES; ++k)
                EBE.v[k].atrest = !((WAKE >> k) & 1u);
            for (k = 0; k < EB_NUM_VOICES; ++k) vb[k] = 0.0f;
            eb_engine_render_voices(&EBE, RS, &RC,
                                    (const eb_render_needs *)0, vb);
            for (k = 0; k < EB_NUM_VOICES; ++k) L += vb[k];
            R = L;
            if (L > 1.0f) L = 1.0f; else if (L < -1.0f) L = -1.0f;
            if (R > 1.0f) R = 1.0f; else if (R < -1.0f) R = -1.0f;
            buf[2 * f]     = (int16_t)(L * 30000.0f);
            buf[2 * f + 1] = (int16_t)(R * 30000.0f);
            if (++frame >= (unsigned long)(gate ? S3L_REL_FRAMES
                                                : S3L_HOLD_FRAMES)) {
                frame = 0; gate = !gate; load_coefs(CH, gate);
            }
            if ((f % (SR / 2)) == 0)
                printf("  %lu%%\n", 100u * f / NFR);
        }
        printf("rendered %lu frames in %.1f s (%.2fx real time)\n", NFR,
               (double)(esp_timer_get_time() - t0) / 1e6,
               (double)(esp_timer_get_time() - t0) / 1e6
                   / ((double)NFR / SR));
        printf("PLAYING, looping. This is engine B on your board.\n");
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
        WAKE = SWEEP[phase];
        for (i = 0; i < CHUNK; ++i) {
            float vb[EB_NUM_VOICES], L = 0.0f, R = 0.0f;
            int k;
            /* THE VOICE CAP, applied per sample. A capped voice is `atrest`,
             * which is NOT "skipped": eb_render.c still advances its free-run
             * state, because a phase that stops while the engine runs is the
             * bug null_b plants in its teeth battery. */
            for (k = 0; k < EB_NUM_VOICES; ++k)
                EBE.v[k].atrest = !((WAKE >> k) & 1u);
            for (k = 0; k < EB_NUM_VOICES; ++k) vb[k] = 0.0f;
            {   int64_t e0 = esp_timer_get_time();
                eb_engine_render_voices(&EBE, RS, &RC,
                                        (const eb_render_needs *)0, vb);
                te += esp_timer_get_time() - e0;
            }
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
                printf("SWEEP wake=0x%02x  engine %.2f us (%.0f cyc)  "
                       "whole loop %.2f us (%.0f cyc)  overhead %.0f cyc\n",
                       SWEEP[phase], e, e * 240.0, w, w * 240.0,
                       (w - e) * 240.0);
                if (chunks / (SR / CHUNK) % 8 == 0) {
                    phase = (phase + 1) % 3;
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

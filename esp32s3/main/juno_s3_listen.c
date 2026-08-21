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
#include "driver/uart.h"
#include "esp_heap_caps.h"
#include "esp_timer.h"
#include "esp_task_wdt.h"
#include "eb_engine.h"
#include "eb_render.h"
#include "eb_coefs.h"
#include "eb_master.h"
#include "eb_master_coefs.h"
#include "s3_listen_meta.h"

/* ================= S3L_RECALL: THE COEFFICIENTS COME FROM THE CHIP =========
 *
 * -DS3_RECALL=1 replaces the frozen coefficient blob with REAL RECALL: a baked
 * ~30 KB device cell array, 134 compact patch bytes out of flash,
 * juno_bank_apply() run ON THE CHIP, and engine_b/dev/eb_recall.c's publish
 * contract putting the result in front of the audio loop.
 *
 * WHAT CHANGES, in one line each. Every figure MEASURED from idf.py size on
 * the two images, not estimated:
 *   the blob         not embedded at all. Whole image 3,078,336 -> 1,426,880
 *                    bytes, i.e. -1,651,456. (The blob itself is 1,930,444;
 *                    recall gives 278,988 of that back as juno_curve's tables,
 *                    the boot image, the bank, the template and 41,572 B of
 *                    recall code.)
 *   load_coefs()     GONE from the per-sample loop. It was a 29 KB memcpy out
 *                    of memory-mapped flash, executed inside the note gate's
 *                    per-sample test. That is requirement 1 of this task and
 *                    it is the half that is measurable immediately.
 *   coefficients     read through EB_RC / EB_MC, published by a pointer swap
 *                    inside the quiescent window
 *   the patch        STEPS through the 64-patch bank on a timer, so a program
 *                    change is exercised in the field and not only at boot
 *   the answer       every build is CRC32'd against gen/devcrc.h, which the
 *                    host computed with THE SAME SOURCE
 *
 * WHAT DOES NOT CHANGE: with S3L_RECALL=0 this file is the M1 firmware and
 * still builds, and that is requirement 4 -- the two must be A/B-able by ear,
 * which is the only way anybody will find out whether device recall SOUNDS
 * like the host build.
 *
 * NOT byte-identical, and the difference is stated rather than glossed: M1
 * grew 512 bytes (0x2ef710 -> 0x2ef8c0) because the decoded I2S counters below
 * are in the SHARED tail. That is deliberate. The old single `underrun`
 * counter could not tell an ESP_ERR_TIMEOUT from a short write, and both
 * builds need it decoded before either can say anything about the 105
 * underruns.
 *
 * ⚠ THIS FIRMWARE HAS NEVER RUN. Not one instruction of recall has executed on
 * an ESP32-S3. Every check below is written so that its FIRST run is
 * informative if it is wrong: each failure path prints a named line and MUTES,
 * and no cycle figure may be quoted from a run whose CRC line says MISMATCH. */
#ifndef S3L_RECALL
#define S3L_RECALL 0
#endif

#if S3L_RECALL
#include "ebdev.h"
#include "eb_recall.h"
#include "eb_sched.h"
#include "eb_notestep.h"
#include "eb_burststep.h"
/* ⚠ THE PROFILER'S CLOCK IS **NOT** SUPPLIED FROM HERE, AND MUST NEVER BE.
 * A `#define EB_MSPROF_TICK() xthal_get_ccount()` stood on these lines and did
 * NOTHING: eb_master.c is a different translation unit and a macro does not
 * cross one. It fell back to its host stub and every stage read exactly 1
 * cyc/sample for a 52-minute board run. eb_master.c now selects the clock from
 * __XTENSA__, where the choice belongs. See playbook 72. */
#include "eb_paramstep.h"
#include "eb_param_class.h"
#include "eb_devseq.h"
#include "eb_alloc.h"
/* O6: the two-chip link. S3L_LINK defaults ON and is HARMLESS when off the
 * bench: an unstrapped board with no wires reads chip A, finds no peer, and
 * runs single-board exactly as before. See s3_link_uart.h. */
#ifndef S3L_LINK
#define S3L_LINK 1
#endif
#if S3L_LINK
#include "s3_link_uart.h"
#endif
/* O1: THE ONE BOUNDARY. Every input reaches the engine through this and
 * nothing else -- FINAL_GUIDE O1, USER-BINDING. */
#include "juno_event.h"
#include "eb_patch.h"
#include "devchord.h"
#include "esp_cpu.h"
#include "gen/ebdev_boot.h"
#include "gen/eb_bank64.h"
#include "gen/eb_template.h"
#include "gen/devcrc.h"

/* THE COMPILE-TIME NET FOR A FLAG-SET DRIFT. devcrc.h is generated by a HOST
 * build of the same sources at the flag set tools/engineb/devboot/make_boot.py
 * calls M1_DEFS. If the firmware is built at different engine flags,
 * sizeof(eb_render_coefs) moves (10,564 at trunk defaults, 18,788 with
 * EB_DCO_WT + EB_VCF_RES_LUT) and every CRC would mismatch for a reason that
 * has nothing to do with the chip. C99 has no _Static_assert, so: negative
 * array. */
typedef char s3l_devcrc_rc_check[(DEVCRC_RC_SZ == sizeof(eb_render_coefs)) ? 1 : -1];
typedef char s3l_devcrc_mc_check[(DEVCRC_MC_SZ == sizeof(eb_master_coef)) ? 1 : -1];
typedef char s3l_devcrc_nv_check[(DEVCRC_NV == EBDEV_NV) ? 1 : -1];
typedef char s3l_devcrc_pb_check[(DEVCRC_PATCH_B == EB_PATCH_BYTES) ? 1 : -1];
typedef char s3l_devcrc_ch_check[(DEVCRC_CHORD_N == DEVCHORD_N) ? 1 : -1];
typedef char s3l_boot_nv_check[(EBDEV_BOOT_NV == EBDEV_NV) ? 1 : -1];
/* one rate is carried; carrying three and picking the wrong one is a quiet
 * detune, which is worse than a build error */
typedef char s3l_boot_rate_check[(EBDEV_BOOT_NRATE == 1) ? 1 : -1];

#define S3L_RC()  ((const eb_render_coefs *)EB_RC)
#define S3L_MC()  ((const eb_master_coef  *)EB_MC)

/* S3L_RECALL is exclusive with the two blob-driven harnesses, and it is an
 * #error rather than a silent no-op because CMake CACHE variables PERSIST: a
 * build that does not pass S3_OFFLINE inherits the previous build's value
 * unless the build directory is wiped. This project has that trap on the
 * record twice (S3_NOFX + S3_OFFLINE killed a board; S3_RING_SRAM sat in the
 * cache unread for a whole flash). ALWAYS rm -rf build when the flags change. */
#if S3L_OFFLINE
#error "S3_RECALL and S3_OFFLINE cannot be combined: the offline renderer re-seeds from the frozen blob, which a recall build does not embed. rm -rf build (these are CMake CACHE vars)."
#endif
#if S3L_LAYOUT
#error "S3_RECALL and S3_LAYOUT cannot be combined: the layout sweep swaps coefficient snapshots out of the blob. rm -rf build (these are CMake CACHE vars)."
#endif
/* THE FX-PIPE DEFERRAL MUST MATCH THE FX PIPELINE. See CMakeLists.txt. */
#if S3L_FX_PIPE && !defined(EB_RECALL_FX_PIPE)
#error "S3L_FX_PIPE is on and EB_RECALL_FX_PIPE is not: eb_recall_publish would put the new patch's master coefficients on the PREVIOUS chunk's voices -- 5.8 ms of the wrong effect on every program change. The CMake string(FIND) that derives it did not see S3L_FX_PIPE=1 in S3_EXTRA_DEFS."
#endif
#if !S3L_FX_PIPE && defined(EB_RECALL_FX_PIPE)
#error "EB_RECALL_FX_PIPE is set without S3L_FX_PIPE: the master coefficients would be deferred a block for no reason."
#endif
#if S3L_NOFX
#error "S3_RECALL and S3_NOFX cannot be combined: recall builds MASTER coefficients and seeds the master state, and NOFX allocates neither. rm -rf build (these are CMake CACHE vars)."
#endif
#else
#define S3L_RC()  ((const eb_render_coefs *)&RC)
#define S3L_MC()  ((const eb_master_coef  *)&MC)
#endif

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

/* S3L_B4_TOOTH -- provoke B4's overrun counter on purpose. N means "stall
 * one block in every N past two periods". 0 (the default) compiles the tooth
 * out entirely, so a shipping build carries none of it. Build the tooth,
 * SEE ovr_miss climb and HEALTH go red, then build with it off: that order is
 * the whole point. */
#ifndef S3L_B4_TOOTH
#define S3L_B4_TOOTH 0
#endif

#ifndef S3L_VOICES
#define S3L_VOICES 2
#endif

#define SR        44100
#ifndef CHUNK
/* frames per render/write.
 *
 * 128 -> 256 MEASURED-MOTIVATED (2026-08-11): after the console throttle the
 * wall clock still ran 0.54 % behind while the timed loop was only 0.07 %
 * over, so about 25 cycles/sample sit OUTSIDE the timed region. The per-block
 * work -- the I2S write and the one barrier -- is the only thing there, and it
 * is amortised over CHUNK samples. Doubling CHUNK halves its per-sample share.
 *
 * THE COST IS LATENCY, and it is the user-facing kind: 128 frames is 2.9 ms,
 * 256 is 5.8 ms, and the FX pipeline adds one more chunk on top. That is a
 * playability trade, not a free win, so it is a knob and not a new default
 * baked into the file. */
#define CHUNK     256
#endif

#if !S3L_RECALL
/* __asm__, not `asm`: -std=c99 is strict ISO and does not spell it the short
 * way. The project's flags are uniform across host and target on purpose, so
 * the firmware conforms to them rather than the other way round. */
extern const uint8_t listen_bin_start[] __asm__("_binary_s3_listen_bin_start");
extern const uint8_t listen_bin_end[]   __asm__("_binary_s3_listen_bin_end");
#endif

static eb_engine        EBE;
static eb_master_rings  RG;
static eb_render_state *RS;      /* 735 KB -- PSRAM */
static eb_master_state *MS;      /* 730 KB -- PSRAM */

#if S3L_RECALL
/* THE TWO BANKS. Both must be INTERNAL SRAM and the boot banner asserts it
 * with esp_ptr_internal(): the swap argument below rests on the ESP32-S3 not
 * serving internal SRAM through the L1 cache, and a bank that quietly landed
 * in PSRAM would need cache maintenance nobody wrote. 2 x 18,788 + 2 x 1,704
 * = 40,984 B. (eb_recall.h says "2 x 10,564"; that is the TRUNK size and is
 * wrong for this fork. Corrected here rather than believed.) */
static eb_render_coefs  RCB[2];
static eb_master_coef   MCB[2];
static eb_recall        REC;
/* the 20,246-byte one-record bank the port's recall reads. PSRAM: it is
 * touched once per patch change and never in the audio path. */
static unsigned char   *DEVBANK;
#else
static eb_render_coefs  RC;
static eb_master_coef   MC;
static const uint8_t *B_RSTATE, *B_MSTATE, *B_COEF;
#endif


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
#if !S3L_RECALL
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
#endif /* !S3L_RECALL */

#if S3L_RECALL
/* ======================================================================
 *                      DEVICE RECALL -- THE BURST
 * ======================================================================
 *
 * THE SHAPE, and why each piece is where it is.
 *
 *   dev_burst()    the ~30 KB cell reload + juno_bank_apply + the note writes
 *                  + eb_render_coefs_build + eb_master_coefs_build, into the
 *                  SHADOW bank. It runs on core 0, OUTSIDE the quiescent
 *                  window, in render_block() just before the barrier spin --
 *                  the one place core 0 is neither rendering nor holding the
 *                  window open. It must not run in place: the builder memsets
 *                  its output first (eb_coefs.c:17), so an in-place build
 *                  hands the audio loop an all-zero coefficient set for the
 *                  whole burst -- silence, then a click.
 *   eb_recall_publish()  a few hundred cycles, INSIDE the window.
 *
 * IT RECALLS COLD, ON PURPOSE, and this is a decision rather than a shortcut.
 * DEVICE_RECALL.md defect (1): warm recall != cold recall -- 24 of 64
 * coefficients move when patch A precedes patch B -- while the host oracle
 * that produced gen/devcrc.h recalls cold. Re-seeding the cell array from the
 * baked boot image before every juno_bank_apply makes the two comparable, and
 * it costs one 30 KB memcpy inside the burst, which is outside the audio
 * window and therefore free where it matters. THE PRICE: the port's own
 * order-dependence is not reproduced. That is right for a program change and
 * wrong for a DAW's live parameter edits, so C6 must revisit it rather than
 * inherit it.
 *
 * WHAT IS NOT HERE, and it is C4's: an ALLOCATOR. The chord's voices are
 * chosen in devchord.h. This proves recall builds the right coefficients on
 * the chip; it does not prove note allocation runs on the chip, and calling it
 * a note path would be the over-claim this file's own header warns about. */

static eb_alloc      ALLOC;
static eb_alloc_ev   ALLOC_EV[EB_ALLOC_MAX_EV];
static volatile int  note_pending = 0;   /* events are queued, a burst is owed */
/* set by the console `t` key, consumed once in the block loop: stall one block
 * on purpose so this build's overrun detector is SEEN TO FIRE. */
static volatile int  tooth_once = 0;

/* ================= O2: THE BUDGET, MEASURED RATHER THAN ASSUMED =========
 *
 * ⚠ WHY THIS EXISTS. The first split-publish run (b10) PROVED the key sounds
 * in 2 blocks -- 519 of 521 presses -- and still failed its acceptance,
 * because `miss note=` reached 23. THE INVARIANT rule 2 says the work gets "a
 * FIXED budget of work per block", and O2 had read that as ONE VOICE PER
 * BLOCK. A voice is not a budget. It is a fixed lump of about 148,000 cycles,
 * and whether it fits depends entirely on what the block was already doing:
 * on a DELAY TYPE 0 patch there is room, on patches 5/16/21/49 the block is
 * over budget before any burst work starts (6,526-6,821 against 5,442, O4).
 *
 * MEASURED consequence: 23 misses in about 4,160 note-build blocks, 0.55 %.
 * The step nearly always fits. It missed when it landed on a block that had
 * no slack left -- which no amount of finer chunking fixes, because the
 * problem is WHEN the step runs, not how big it is.
 *
 * SO THE BUDGET IS NOW READ FROM THE INSTRUMENT ITSELF -- AND FROM CCOUNT,
 * NOT FROM esp_timer. That choice is load-bearing. The obvious budget is
 * "period minus how long the last block took", but the block gap reads
 * 9,000-11,000 us against a 5,804 us period in every run on this board, and
 * WHY IS AN OPEN ITEM (b4_first_run.md §5, ovr_late on ~60 % of blocks). A
 * scheduler built on that number would conclude there is never any slack,
 * defer for ever, and force every step -- worse than no scheduler. Building
 * on an unexplained measurement is how the ring attribution went wrong.
 *
 * CORE 0'S BARRIER SPIN IS THE HONEST NUMBER, and it is already measured:
 * `while (!w_done) { }` is core 0 with nothing to do while core 1 finishes.
 * That spin IS the slack, in cycles, on the core the burst actually runs on.
 *   g_quiet_spin   the spin on the last block that ran NO burst work -- the
 *                  full slack this patch leaves, before the burst eats it
 *   g_step_cyc_max the worst any single burst step has cost, measured
 * A step runs only when the measured slack covers the worst measured step.
 * Otherwise it waits a block and is COUNTED (rule 4). Latency degrades,
 * continuity does not -- rule 3, applied to the burst instead of the queue.
 *
 * ⚠ IT MUST NOT STARVE. "The change arrives later" is the invariant; "the
 * change never arrives" is not. On a patch whose steady-state cost already
 * exceeds the period, slack never appears and a pure budget rule would defer
 * for ever. So after SCHED_STARVE deferrals the step is FORCED and counted
 * separately: that block may miss, and it is better to miss one block than to
 * leave a key silent. A forced step is a report of O4's problem, not O2's --
 * which is why the two counters are printed apart. */
#define SCHED_STARVE 64            /* ~370 ms, then force and count it */
/* ⚠ THE DECISION ITSELF LIVES IN engine_b/dev/eb_sched.h, NOT HERE. It is
 * gated with teeth by tools/engineb/sched_gate.py, and a gate that proves a
 * copy the firmware does not run proves nothing (playbook 28). This file
 * supplies the two MEASUREMENTS and nothing else. */
static eb_sched SCHED;
/* ⚠ ONE WORST-CASE PER MACHINE. The patch reseed is ~440,000 cycles and a
 * note's voice step ~148,000; a shared maximum would let the reseed's figure
 * gate every note step for ever -- the budget starving the exact work it was
 * added to protect. */
static unsigned long g_step_cyc_note = 0, g_step_cyc_burst = 0;
static unsigned long g_quiet_spin = 0;   /* core 0's idle, burst-free block */

/* Fold one step's measured cost into its machine's worst case, in cycles. */
static void sched_note_cost(unsigned long *slot, unsigned long cyc)
{
    if (cyc > *slot) *slot = cyc;
}
static int           note_nev = 0;
static unsigned long notes_seen = 0, notes_dropped = 0, note_bursts = 0;
static unsigned long ev_applied_blocks = 0;   /* blocks that applied events */
/* The producers' mutex. Declared in main/juno_event_port.h, defined ONCE
 * here, and taken only by submitters -- never by the drain. */
portMUX_TYPE juno_evq_mux = portMUX_INITIALIZER_UNLOCKED;
static unsigned long nb_min = 0xFFFFFFFFul, nb_max = 0, nb_last = 0;
static volatile int  dev_pending = 0;   /* a FINISHED shadow awaits publish */
/* ---- O2: the chunked patch change ---------------------------------------
 * The burst is ~2.1 M cycles against a 5.8 ms block and MEASURED 1-4 missed
 * deadlines per program change. THE INVARIANT rule 2 says that work is
 * INCREMENTAL AND CAPPED; rule 3 says the change may ARRIVE LATER. So it runs
 * ONE bounded step per block and the audio keeps playing the current bank
 * until one atomic publish swaps it. */
static volatile int  dev_want = 0;      /* a patch change has been asked for */
static int           burst_state = 0;   /* 0 idle, else the NEXT step to run */
static int           burst_patch = 0, burst_gate = 0;
static unsigned long burst_cyc = 0;     /* cycles across the whole build     */
static unsigned long burst_blocks = 0;  /* blocks the last change took       */
static unsigned long burst_blocks_max = 0;
static unsigned long burst_restarts = 0;/* a new request arrived mid-build   */
/* Set by dev_burst_step(), read and cleared at the deadline check, so a miss
 * can be attributed to the burst or to the steady state. Written and read by
 * core 0 only, in the same block. */
static volatile int  burst_ran_this_block = 0;
static volatile int  note_ran_this_block = 0;   /* 0 none, else the STEP ID
                                  * -- so a miss can name WHICH step overran
                                  * (b7: burst=17 and no attribution). */
static int           dev_patch = 0;     /* which patch the bank is on       */
static int           dev_gate = 0;      /* 0 = held, 1 = released           */
static unsigned long dev_builds = 0, dev_pubs = 0, dev_pub_refused = 0;
static unsigned long b_min = 0xFFFFFFFFul, b_max = 0, b_last = 0;
static unsigned long p_min = 0xFFFFFFFFul, p_max = 0, p_last = 0;
static unsigned long crc_checked = 0, crc_bad = 0;
static unsigned long dev_last_bad_patch = 0;
static int           dev_muted = 0;     /* a named failure fired -- see below */
static const char   *dev_mute_why = "";
static int           dev_ringlen_bad = 0;

/* THE QUIESCENCE PREDICATE, WITH EXACTLY ONE WRITER.
 *
 * eb_recall.h proposes (w_done && !w_go). Do NOT use that here: it is an
 * inference about the ORDER of core 1's two separate volatile stores
 * (w_go = 0 then w_done = 1). This flag describes CORE 0's own control flow
 * and core 0 is its only writer, so the assertion inside eb_recall_publish()
 * can actually fail -- which is the point of it being an assertion.
 *
 * (While here: this file's own comment at the top of the two-core section
 * claims "each is written by exactly one core". That is FALSE for w_go --
 * core 0 writes 1 and core 1 writes 0. The handshake is still safe because it
 * strictly alternates, but the stated invariant is wrong and C3's quiescence
 * must not be built on it.) */
static volatile int w_parked = 0;
static int listen_quiescent(void) { return w_parked; }
/* core 0's barrier spin, in cycles, per chunk. THE BURST'S ONLY HONEST BUDGET. */
static unsigned long spin_min = 0xFFFFFFFFul, spin_max = 0;
/* chunks since the last recall burst -- the underrun correlation test */
static unsigned long chunks_since_burst = 0;

/* The nine ring-length cells the port's recall writes (src/delay_recall.c
 * :397-408), in eb_master_rings order. eb_recall.c argues the rings are ONE
 * set over the whole bank and therefore never reallocated. That argument is
 * CHECKED here every patch instead of trusted: a ring whose length changed
 * under its coefficients is a read past the end. */
static const unsigned long DEV_RINGCELL[9] = {
    6395252ul, 6429412ul, 8594772ul, 10691940ul, 10726260ul,
    10759044ul, 101028ul, 6463716ul, 6496500ul
};

static int dev_check_rings(void)
{
    int i, bad = 0;
    for (i = 0; i < 9; ++i) {
        int32_t got = *(const int32_t *)ebdev_at(DEV_RINGCELL[i]);
        if (got != S3L_RING_LEN[i]) {
            printf("RECALL: *** RING %d LENGTH MOVED: patch %d wants %ld, the "
                   "allocation is %ld. eb_recall.c's 'one set over the bank' "
                   "argument is FALSE for this bank and the realloc it names "
                   "is now owed. ***\n",
                   i, dev_patch, (long)got, (long)S3L_RING_LEN[i]);
            bad = 1;
        }
    }
    return bad;
}


/* ================= THE MEMORY PROBE, 2026-08-12 ==========================
 * WHY THIS EXISTS. The reseed measured 426,945 cycles to copy 30,252 bytes =
 * 14.1 CYCLES PER BYTE. An internal-SRAM copy is well under one. That is not
 * a memcpy, it is waiting on memory -- and the whole project has been
 * optimising ARITHMETIC. If the engine is memory-bound anywhere, every cycle
 * hunt aimed at the DSP was aimed at the wrong thing.
 *
 * Three questions, one boot-time probe, no config change and no risk:
 *   1. how fast is a copy OUT OF FLASH (the reseed's own pattern)?
 *   2. how fast is the same copy internal -> internal (the floor)?
 *   3. what does a SCATTERED read cost in PSRAM vs internal?  Question 3 is
 *      the delay rings: 6.1 MB in PSRAM, and the patches that cost DOUBLE are
 *      exactly the pitch-shifting delays, which read several MOVING taps. If
 *      PSRAM scattered reads are dear, the FX cost is latency, not maths.
 *
 * The scattered pattern strides 64 bytes -- one D-cache line -- so every read
 * misses, which is what a moving delay tap does. A sequential loop would
 * measure the prefetcher instead and flatter PSRAM.
 *
 * NOTHING IS CONCLUDED HERE. It prints numbers. */
static void mem_probe(void)
{
    /* 8 KB, NOT 30 KB, and STATIC rather than malloc'd. The first attempt
     * asked for two 30 KB internal buffers when the largest free internal
     * block is about 31 KB, so it silently skipped itself and measured
     * nothing. Cycles-per-byte does not care about the length. */
    /* 2 KB, and 64 internal reads. The 8 KB version overflowed dram0_0_seg
     * by 10,704 bytes -- this firmware has ~60 KB of internal RAM left and a
     * probe may not take a fifth of it. Cycles-per-byte is scale-free. */
    enum { NB = 2048, NSTRIDE = 2048, STRIDE = 64, NISC = 64 };
    static unsigned char PB_DST[NB], PB_SRC[NB];
    unsigned long t0, c_flash = 0, c_int = 0, c_ps = 0, c_isc = 0, c_seq = 0;
    unsigned long c_seq4 = 0;
    volatile float *ps = (volatile float *)heap_caps_malloc(
        (size_t)NSTRIDE * STRIDE, MALLOC_CAP_SPIRAM);
    static float ISR[NISC * (STRIDE / 4)];
    volatile float sink = 0.0f;
    int i;

    /* 1. OUT OF FLASH. ebdev_boot[0] is memory-mapped flash -- the reseed's
     *    own source, so this is the reseed's read cost with nothing else in
     *    it. */
    t0 = (unsigned long)esp_cpu_get_cycle_count();
    memcpy(PB_DST, ebdev_boot[0], NB);
    c_flash = (unsigned long)esp_cpu_get_cycle_count() - t0;

    /* 2. THE FLOOR: internal -> internal, same size. */
    t0 = (unsigned long)esp_cpu_get_cycle_count();
    memcpy(PB_DST, PB_SRC, NB);
    c_int = (unsigned long)esp_cpu_get_cycle_count() - t0;

    /* 3. SCATTERED reads, PSRAM vs internal, one per cache line. */
    if (ps) {
        t0 = (unsigned long)esp_cpu_get_cycle_count();
        for (i = 0; i < NSTRIDE; ++i) sink += ps[(size_t)i * (STRIDE / 4)];
        c_ps = (unsigned long)esp_cpu_get_cycle_count() - t0;
    }
    t0 = (unsigned long)esp_cpu_get_cycle_count();
    for (i = 0; i < NISC; ++i) sink += ISR[(size_t)i * (STRIDE / 4)];
    c_isc = (unsigned long)esp_cpu_get_cycle_count() - t0;

    /* 4. THE PATTERN THE DELAY ACTUALLY USES, which rows 1-3 do not measure.
     *
     * Row 3 strides one cache line so EVERY read misses. A delay tap does not
     * do that: consecutive samples read consecutive ring positions, so one
     * 32-byte PSRAM burst serves eight samples. Concluding "the rings are
     * latency" from row 3 is reading a worst case as if it were the case --
     * and this file's own FX-ordering note records a ring-placement test that
     * made the engine 94 cycles WORSE, which row 3 cannot explain.
     *
     * So: a MOVING TAP. The read position advances one float per iteration
     * with a small wobble, and two adjacent floats are interpolated -- which
     * is what a pitch-modulated delay does. If this row is near the internal
     * row, the delay's cost is ARITHMETIC and the rings are innocent. */
    if (ps) {
        const size_t mask = (size_t)NSTRIDE * (STRIDE / 4) - 1u;
        size_t w = 0;
        t0 = (unsigned long)esp_cpu_get_cycle_count();
        for (i = 0; i < NSTRIDE; ++i) {
            size_t p = (w - (size_t)(1000 + (i & 7))) & mask;
            sink += ps[p] * 0.5f + ps[(p + 1u) & mask] * 0.5f;
            ++w;
        }
        c_seq = (unsigned long)esp_cpu_get_cycle_count() - t0;
    }

    /* 5. ⚠ FOUR MOVING TAPS AT ONCE -- THE PATTERN **DELAY TYPE 5** RUNS, AND
     *    THE ONE ROW 4 DOES NOT MEASURE.
     *
     * b19 proved O4's whole deficit is the delay stage on the four DELAY
     * TYPE 5 patches: 2.45x the delay cost of the other sixty, 97 % of the
     * excess. Type 5 is the only delay arm with FOUR rings; t1 and t23 have
     * one each. It performs 12 ring reads per sample against their ~4.
     *
     * Row 4 measures ONE moving tap and reads 30 cyc/tap, and that number has
     * been quoted ever since -- including in b6's WITHDRAWAL of the PSRAM
     * attribution. But one stream is the case where a 32-byte burst serves
     * eight consecutive samples. FOUR streams, far apart, interleaved, may
     * evict each other between reads and never amortise a burst at all.
     * Nobody has measured that, and it is exactly the untested assumption
     * this project keeps paying for (playbook 46).
     *
     * THE ARITHMETIC THAT MAKES THIS DECISIVE, written before the run:
     *   12 reads/sample at row 4's 30 cyc/tap  =   360 cyc  -- 29 % of the
     *      1,231 cyc/sample excess. Ring placement is then a PARTIAL lever
     *      and the rest must come from the arithmetic.
     *   12 reads/sample at about 100 cyc/tap   = 1,200 cyc  -- essentially
     *      ALL of it. Ring placement is then THE lever, and it is available
     *      at no sonic cost, because the rings only need to be as long as
     *      the measured maximum read lag.
     *
     * The four taps are spread across the buffer so they cannot share a
     * cache line or a burst, and each advances independently, as four
     * separate rings do. */
    if (ps) {
        const size_t nfl  = (size_t)NSTRIDE * (STRIDE / 4);
        const size_t mask = nfl - 1u;
        const size_t sep  = nfl / 4u;      /* the four rings, far apart */
        size_t w = 0;
        t0 = (unsigned long)esp_cpu_get_cycle_count();
        for (i = 0; i < NSTRIDE / 4; ++i) {
            size_t d = (size_t)(1000 + (i & 7));
            size_t p0 = (w - d) & mask;
            size_t p1 = (w + sep - d) & mask;
            size_t p2 = (w + 2u * sep - d) & mask;
            size_t p3 = (w + 3u * sep - d) & mask;
            sink += ps[p0] * 0.5f + ps[(p0 + 1u) & mask] * 0.5f;
            sink += ps[p1] * 0.5f + ps[(p1 + 1u) & mask] * 0.5f;
            sink += ps[p2] * 0.5f + ps[(p2 + 1u) & mask] * 0.5f;
            sink += ps[p3] * 0.5f + ps[(p3 + 1u) & mask] * 0.5f;
            ++w;
        }
        c_seq4 = (unsigned long)esp_cpu_get_cycle_count() - t0;
    }

    printf("\n=== MEMORY PROBE (is this engine memory-bound?) ===\n");
    printf("MEM: copy %d B out of FLASH   %lu cyc  = %.2f cyc/byte\n",
           NB, c_flash, (double)c_flash / (double)NB);
    printf("MEM: copy %d B internal->int  %lu cyc  = %.2f cyc/byte  <- the floor\n",
           NB, c_int, (double)c_int / (double)NB);
    if (ps)
        printf("MEM: %d scattered reads PSRAM    %lu cyc = %.1f cyc/read\n",
               NSTRIDE, c_ps, (double)c_ps / (double)NSTRIDE);
    else
        printf("MEM: PSRAM buffer refused -- the row that matters is MISSING\n");
    printf("MEM: %d scattered reads INTERNAL %lu cyc = %.1f cyc/read\n",
           NISC, c_isc, (double)c_isc / (double)NISC);
    if (ps)
        printf("MEM: %d MOVING-TAP reads PSRAM  %lu cyc = %.1f cyc/tap  "
               "<- the delay's own pattern\n",
               NSTRIDE, c_seq, (double)c_seq / (double)NSTRIDE);
    if (ps) {
        /* 8 reads per iteration over NSTRIDE/4 iterations = 2*NSTRIDE reads */
        printf("MEM: %d FOUR-TAP reads PSRAM    %lu cyc = %.1f cyc/tap  "
               "<- DELAY TYPE 5's own pattern\n",
               NSTRIDE * 2, c_seq4, (double)c_seq4 / (double)(NSTRIDE * 2));
        printf("MEM:   ONE tap %.1f -> FOUR taps %.1f cyc/tap.  At 12 reads a\n"
               "MEM:   sample that is %.0f cyc/sample, against the %d cyc/sample\n"
               "MEM:   excess b19 measured for DELAY TYPE 5.  >=70%% -> ring\n"
               "MEM:   PLACEMENT is O4's lever; <40%% -> the arithmetic is.\n",
               (double)c_seq / (double)NSTRIDE,
               (double)c_seq4 / (double)(NSTRIDE * 2),
               12.0 * (double)c_seq4 / (double)(NSTRIDE * 2), 1231);
    }
    printf("MEM: flash is configured DIO @ 80 MHz. QIO @ 120 MHz is available\n"
           "     and is worth its reflash ONLY if the flash row above is dear.\n");
    printf("MEM: rings are 6.1 MB in PSRAM. Read the MOVING-TAP row, NOT the\n"
           "     scattered row: scattered is a worst case the delay never runs.\n");
    (void)sink;
    if (ps) heap_caps_free((void *)ps);
}


/* ================= THE HEALTH LINE =======================================
 *
 * ONE verdict, and it LATCHES. The firmware already had several detectors and
 * printed twelve numbers beside them, which left a human to notice -- and a
 * person reading a scrolling log is not a detector.
 *
 * `HEALTH: OK` or the name of the FIRST fault, and once a fault is named this
 * never reads OK again. A latch rather than a level, because an instrument that
 * broke for one block an hour ago and recovered is still an instrument that
 * broke, and a self-healing report hides exactly the intermittent fault that is
 * hardest to find.
 *
 * ⚠ A HEALTH LINE THAT HAS NEVER GONE RED IS NOT EVIDENCE OF HEALTH. It is an
 * untested detector, which is playbook defect 1 and the oldest rule here. Each
 * fault below owes a tooth that provokes it on purpose; the ones marked OWED in
 * FINAL_GUIDE do not have one yet and must not be quoted as proof. */
static const char *health_fault = 0;      /* the FIRST fault, latched */
static unsigned long health_n = 0;        /* how many times anything fired */

static void health_fail(const char *why)
{
    ++health_n;
    if (!health_fault) health_fault = why;   /* FIRST, not last */
}

/* ---- THE OTHER 40 % OF THE BURST, attributed the same way ----------------
 * MEASURED on silicon 2026-08-12: the whole burst is 1,992,935 cycles and the
 * two coefficient builds account for 1,204,025 of them. That leaves 788,910
 * cycles -- 40 % -- in the four steps below, and NOTHING is known about how
 * they divide. The voice build was cut by measuring it first; this is the same
 * move on what is left, and it is one flash rather than four guesses.
 *
 * These run once per patch change, never per sample. */
static unsigned long devp_reseed = 0, devp_install = 0;
static unsigned long devp_recall = 0, devp_notes = 0;
static unsigned long devp_t0 = 0;
#define DEVP_T0()      devp_t0 = (unsigned long)esp_cpu_get_cycle_count()
#define DEVP_T1(dst)   (dst) = (unsigned long)esp_cpu_get_cycle_count() - devp_t0

/* THE BURST. Returns 0 on success. On any failure it says which one and the
 * caller mutes -- a board that plays wrong coefficients teaches nothing. */
static int dev_burst_verify(int patch, int gate);

static int dev_burst(int patch, int gate)
{
    unsigned long t0 = (unsigned long)esp_cpu_get_cycle_count(), dt;
    unsigned long miss0;

    chunks_since_burst = 0;
    ebdev_reset_counters();
    DEVP_T0();
    if (eb_devseq_boot_cells(ebdev_boot[0], (unsigned)EBDEV_NV)) {
        dev_mute_why = "the baked boot image does not match EBDEV_NV";
        return 1;
    }
    DEVP_T1(devp_reseed);
    DEVP_T0();
    if (eb_devseq_install(DEVBANK, eb_template, sizeof eb_template,
                          eb_bank64 + (size_t)patch * EB_PATCH_BYTES)) {
        dev_mute_why = "eb_patch_install refused the record";
        return 1;
    }
    DEVP_T1(devp_install);
    DEVP_T0();
    eb_devseq_recall(DEVBANK, 128.0f);
    DEVP_T1(devp_recall);
    /* C4: the allocator must learn THIS patch's ASSIGN MODE. Skipping it is
     * docs/ASSIGNER_MODE_FINDING.md verbatim -- 16 of 64 factory patches
     * played POLY when they are MONO or UNISON, for months, behind green
     * gates, because the port and its oracle were wrong together. */
    eb_alloc_init(&ALLOC);
    eb_devseq_alloc_config(&ALLOC, DEVBANK);
    DEVP_T0();
#if S3L_MIDI
    /* MIDI OWNS THE NOTES. The built-in chord is what makes the CRC comparable
     * to the host oracle, so it still runs at boot; with MIDI on, the keyboard
     * takes over from the first key. */
    (void)gate;
    eb_devseq_notes_on(DEVCHORD_VOICE, DEVCHORD_NOTE, DEVCHORD_VEL, DEVCHORD_N);
#else
    eb_devseq_notes_on(DEVCHORD_VOICE, DEVCHORD_NOTE, DEVCHORD_VEL, DEVCHORD_N);
    if (gate) eb_devseq_notes_off(DEVCHORD_VOICE, DEVCHORD_N);
#endif

    miss0 = EBDEV_S.miss;
    (void)miss0;
    DEVP_T1(devp_notes);
    eb_recall_build(&REC);              /* into the SHADOW bank */
    dt = (unsigned long)esp_cpu_get_cycle_count() - t0;
    b_last = dt;
    if (dt < b_min) b_min = dt;
    if (dt > b_max) b_max = dt;
    ++dev_builds;
    return dev_burst_verify(patch, gate);
}

/* THE CHECKS, IN ONE PLACE. Both the monolithic boot burst and O2's stepped
 * path end here, because two copies of a mute condition is how one of them
 * stops being updated. Returns non-zero on failure with dev_mute_why set. */
static int dev_burst_verify(int patch, int gate)
{
    if (EBDEV_S.miss) {
        printf("RECALL: *** %lu UNMAPPED CELL ACCESSES on patch %d (last "
               "offset %lu). The address map is INCOMPLETE for this patch "
               "and every cell that missed read or wrote an 8-byte SINK. ***\n",
               EBDEV_S.miss, patch, EBDEV_S.lastmiss);
        dev_mute_why = "unmapped cells -- the address map is incomplete";
        health_fail("a recall access fell off the address map");
        dev_last_bad_patch = (unsigned long)patch;
        return 1;
    }
    if (dev_check_rings()) { dev_ringlen_bad = 1;
        dev_mute_why = "a delay ring length changed under its coefficients";
        health_fail("a delay ring length moved");
        return 1; }

    /* THE ANSWER KEY. gen/devcrc.h was computed by the SAME source
     * (engine_b/dev/eb_devseq.c) through the SAME rebased addressing on the
     * host, from the SAME boot image and the SAME 134 patch bytes. So this
     * compares HOST arithmetic against CHIP arithmetic and nothing else --
     * which is the one question no host gate can answer.
     *
     * Only the gate-ON build is comparable: the oracle sounds the chord and
     * stops there. The gate-OFF build additionally issues note-offs, so it is
     * checked for unmapped cells and not for its CRC. */
    if (!gate) {
        const int shadow = 1 - REC.cur;
        unsigned long rc = eb_devseq_crc32(REC.rc[shadow], sizeof(eb_render_coefs));
        unsigned long mc = eb_devseq_crc32(REC.mc[shadow], sizeof(eb_master_coef));
        ++crc_checked;
        /* O6/D3: the key is PER VOICE BASE. Chip B's recall correctly
         * differs from chip A's on the scatter cells, so checking it against
         * the base-0 key would mute a RIGHT recall. devcrc.c generates both
         * and refuses if base 3 fails to move the key (seen to fail). */
        const unsigned long *krc = EB_DEVSEQ_VOICE_BASE ? devcrc_rc_b3 : devcrc_rc;
        const unsigned long *kmc = EB_DEVSEQ_VOICE_BASE ? devcrc_mc_b3 : devcrc_mc;
        if (rc != krc[patch] || mc != kmc[patch]) {
            ++crc_bad;
            dev_last_bad_patch = (unsigned long)patch;
            printf("RECALL: *** CRC MISMATCH patch %d: chip rc=%08lx mc=%08lx | "
                   "host rc=%08lx mc=%08lx. THE CHIP'S RECALL DISAGREES WITH "
                   "THE HOST'S. No cycle figure from this run may be quoted. ***\n",
                   patch, rc, mc, krc[patch], kmc[patch]);
            dev_mute_why = "the chip's coefficients disagree with the host's";
            return 1;
        }
    }
    return 0;
}

/* ================= O2: THE SAME BURST, ONE STEP PER BLOCK ================
 *
 * dev_burst() above is the monolith and is KEPT: it is what boot uses, where
 * there is no audio to protect and no reason to spend fourteen blocks. The
 * stepped path below runs the SAME calls in the SAME order for a program
 * change while the instrument is playing.
 *
 * THE STEP BUDGET IS ONE PER BLOCK, and that is a measurement rather than a
 * preference. MEASURED (b6_split_sweep.md): at the shipping split core 0
 * renders one voice (~2,590 cyc/sample) inside a ~5,250 block, so it spins at
 * the barrier for roughly half of every block -- about 650,000 cycles. The
 * largest single step here is the reseed at ~440,000 (BURST: line, silicon),
 * so even the worst step fits inside the slack that already exists. Fourteen
 * steps is ~81 ms for a program change: LATENCY DEGRADES, CONTINUITY DOES NOT,
 * which is rule 3 stated rather than accidental.
 *
 * ⚠ IF A STEP EVER GROWS PAST THE SLACK this stops working silently -- the
 * block simply runs long and B4's miss counter catches it. That counter is
 * the acceptance test for this whole step and it must read 0 across a program
 * change on all 64 patches.
 *
 * WHY IT IS SAFE: every step writes only the cell array and the SHADOW bank.
 * ebdev.c records that ebdev_at appears in no delay arm, eb_render.c or
 * eb_master.c -- so no cell is read per sample -- and the render loop reads
 * rc[cur], never rc[shadow]. A half-built patch is therefore inaudible.
 *
 * Returns  1 more work remains
 *          0 the shadow is COMPLETE and checked -- publish it
 *         -1 failed; dev_mute_why says which, and the caller mutes. */
enum { BST_IDLE = 0, BST_RESEED, BST_INSTALL, BST_RECALL, BST_NOTES,
       BST_COEFS, BST_CHECK, BST_PUB };
/* rule 4: a publish refused mid-build, counted. Must read 0 -- the publish
 * happens inside the quiescent window and there is no known way to refuse it,
 * so non-zero means the precondition is not what this file believes. */
static unsigned long burst_pub_retry = 0;

/* ======================= O3: THE PARAMETER PATH =========================
 *
 * A knob move is NOT a program change. It writes the parameter's two record
 * bytes, recalls WARM over the live cells -- no reseed, no install -- and
 * rebuilds only the sub-builders that parameter can reach, from the GENERATED
 * eb_param_class table. MEASURED (docs/engineb/data/b13_param_map.md): the
 * median parameter moves 32 of 12,276 coefficient bytes, so the full rebuild a
 * program change earns is ~380x the work a knob needs.
 *
 * ⚠ NO PER-PARAMETER STASH IS NEEDED, and that is a consequence of the design
 * rather than luck. eb_devseq.c names six values the GUI bridge must keep for
 * its live-edit path (lfo_rate_byte, dly time/sync/type, hpf_type,
 * last_condition) because the bridge drives per-parameter SETTERS that cannot
 * read them back. This path re-runs the WHOLE recall from the record every
 * edit, so every one of those is re-read from the bytes that hold it. The
 * stash list stays owed only for a design that narrows the APPLY, which is the
 * scope decision b13 §5 records and does not take.
 *
 * THE WARM RECALL IS THE DECISION eb_devseq.h RESERVED FOR THIS MOMENT, and it
 * is settled by measurement: 2,036 of 2,040 parameters land byte for byte
 * where a cold recall would, and the four that do not are transition latches
 * where WARM is the CORRECT answer for a live edit. paramwarm.c names those
 * four and fails in both directions.
 *
 * EDITS COALESCE. Several knobs moving at once, or one knob moving fast, cost
 * ONE build: the record bytes are written as they arrive and the class mask is
 * OR-ed, so the rebuild covers all of them. That is what makes "as many
 * parameters as you please, at the same time" (C9, user-binding) affordable
 * rather than N times the price. */
static eb_pm         PM;
/* ⚠ TWO SETS, AND THE SECOND ONE IS NOT OPTIONAL. `pend` accumulates the class
 * of every edit that has arrived; `run` is the snapshot the build in flight is
 * actually rebuilding. Taking the snapshot and CLEARING `pend` at begin() is
 * what makes the next batch start empty.
 *
 * With one set the masks would only ever grow: the first knob to touch all
 * eight voices would leave every later build rebuilding all eight forever, so
 * the map would be derived, gated, shipped -- and then quietly not used. The
 * saving would vanish with no symptom, because the coefficients would still be
 * RIGHT. Wrong-but-correct-looking is the failure mode this project has spent
 * the most time on.
 *
 * It is also what makes an edit arriving MID-BUILD safe: it lands in `pend`,
 * raises pm_want, and is rebuilt by the next build. Late, never lost. */
static unsigned      pm_vmask   = 0u;    /* pending class, voices */
static int           pm_tail    = 0;
static int           pm_master  = 0;
static unsigned      pm_v_run   = 0u;    /* the build in flight */
static int           pm_t_run   = 0;
static int           pm_m_run   = 0;
static int           pm_want    = 0;     /* edits are queued for a build */
static unsigned long pm_edits   = 0;     /* parameters accepted */
static unsigned long pm_builds  = 0;     /* rebuilds run */
static unsigned long pm_defer   = 0;     /* blocks the interlock held it off */
static unsigned long pm_unknown = 0;     /* param_id not in the class table */
static unsigned long pm_cyc_apply = 0, pm_cyc_max = 0;

/* Queue one edit. Called from the event drain, so it must be cheap and must
 * NOT touch the shadow -- a build may be in flight. */
static void dev_param_edit(int param_id, int value)
{
    const eb_param_class *c = eb_param_class_of(param_id);
    unsigned char *blob;
    if (!c) {
        /* ⚠ REFUSE AND COUNT, never "rebuild nothing". A parameter the map
         * does not know is a knob whose effect would silently not happen
         * (playbook 32), and the count is what makes the gap visible. */
        ++pm_unknown;
        health_fail("a parameter id outside the class table");
        return;
    }
    /* DEVBANK is a BANK, not a bare record: juno_bank_apply indexes
     * bank + 23 + idx*20223 and the device holds one record at index 0, whose
     * nibble-packed blob starts 16 bytes in past the name. Writing at the
     * wrong base would edit a neighbouring parameter and still look plausible,
     * so the two constants come from eb_patch.h rather than from arithmetic
     * spelled out here. */
    blob = DEVBANK + EB_BANK_HEADER + EB_BANK_BLOB_OFF;
    blob[c->rec - EB_BANK_BLOB_OFF]     = (unsigned char)((value >> 4) & 0xF);
    blob[c->rec - EB_BANK_BLOB_OFF + 1] = (unsigned char)(value & 0xF);
    pm_vmask  |= c->vmask8;
    pm_tail   |= c->tail;
    pm_master |= c->master;
    pm_want    = 1;
    ++pm_edits;
}

static int pm_apply(void *u)
{
    unsigned long t0 = (unsigned long)esp_cpu_get_cycle_count(), d;
    (void)u;
    ebdev_reset_counters();
    /* WARM: the live cells stay, the edited record is re-applied over them. */
    eb_devseq_recall(DEVBANK, 128.0f);
    d = (unsigned long)esp_cpu_get_cycle_count() - t0;
    pm_cyc_apply = d;
    if (d > pm_cyc_max) pm_cyc_max = d;
    return 1;
}
static void pm_begin(void *u)
{ (void)u; eb_recall_chunk_begin_subset(&REC, pm_v_run, pm_t_run, pm_m_run); }
static int  pm_step(void *u)  { (void)u; return eb_recall_chunk_step(&REC); }
static int  pm_busy(void *u)  { (void)u; return eb_recall_chunk_busy(&REC); }
static int  pm_verify(void *u)
{
    (void)u;
    if (EBDEV_S.miss) {
        printf("PARAM: *** %lu UNMAPPED CELL ACCESSES during a parameter "
               "refresh (last offset %lu) ***\n",
               EBDEV_S.miss, EBDEV_S.lastmiss);
        dev_mute_why = "unmapped cells during a parameter refresh";
        health_fail("a parameter refresh fell off the address map");
        return 0;
    }
    return 1;
}
static const eb_pm_ops PM_OPS = { pm_apply, pm_begin, pm_step, pm_busy,
                                  pm_verify };

static void dev_burst_begin(int patch, int gate)
{
    if (burst_state != BST_IDLE) ++burst_restarts;  /* latest wins, counted */
    burst_patch  = patch;
    burst_gate   = gate;
    burst_state  = BST_RESEED;
    burst_cyc    = 0;
    burst_blocks = 0;
}

static int dev_burst_step(void)
{
    unsigned long t0 = (unsigned long)esp_cpu_get_cycle_count();
    int rc_step = 1;

    if (burst_state != BST_IDLE)
        burst_ran_this_block = burst_state;  /* the STEP ID, for attribution */

    switch (burst_state) {
    case BST_IDLE:
        return 1;

    case BST_RESEED:
        chunks_since_burst = 0;
        ebdev_reset_counters();
        if (eb_devseq_boot_cells(ebdev_boot[0], (unsigned)EBDEV_NV)) {
            dev_mute_why = "the baked boot image does not match EBDEV_NV";
            burst_state = BST_IDLE; rc_step = -1; break;
        }
        devp_reseed = (unsigned long)esp_cpu_get_cycle_count() - t0;
        burst_state = BST_INSTALL;
        break;

    case BST_INSTALL:
        if (eb_devseq_install(DEVBANK, eb_template, sizeof eb_template,
                              eb_bank64 + (size_t)burst_patch * EB_PATCH_BYTES)) {
            dev_mute_why = "eb_patch_install refused the record";
            burst_state = BST_IDLE; rc_step = -1; break;
        }
        devp_install = (unsigned long)esp_cpu_get_cycle_count() - t0;
        burst_state = BST_RECALL;
        break;

    case BST_RECALL:
        eb_devseq_recall(DEVBANK, 128.0f);
        devp_recall = (unsigned long)esp_cpu_get_cycle_count() - t0;
        burst_state = BST_NOTES;
        break;

    case BST_NOTES:
        /* The allocator must learn THIS patch's ASSIGN MODE. Skipping it is
         * docs/ASSIGNER_MODE_FINDING.md verbatim. */
        eb_alloc_init(&ALLOC);
        eb_devseq_alloc_config(&ALLOC, DEVBANK);
#if S3L_MIDI
        eb_devseq_notes_on(DEVCHORD_VOICE, DEVCHORD_NOTE, DEVCHORD_VEL,
                           DEVCHORD_N);
#else
        eb_devseq_notes_on(DEVCHORD_VOICE, DEVCHORD_NOTE, DEVCHORD_VEL,
                           DEVCHORD_N);
        if (burst_gate) eb_devseq_notes_off(DEVCHORD_VOICE, DEVCHORD_N);
#endif
        devp_notes = (unsigned long)esp_cpu_get_cycle_count() - t0;
        eb_recall_chunk_begin(&REC);
        burst_state = BST_COEFS;
        break;

    case BST_COEFS:
        /* ONE piece of the coefficient build: a voice, the shared tail, or
         * the master set. Held bit-identical to the monolith over all 64
         * patches by tools/engineb/chunk_gate.py, with five teeth. */
        if (!eb_recall_chunk_step(&REC)) burst_state = BST_CHECK;
        break;

    case BST_CHECK:
        /* ⚑ IT MUST NOT GO IDLE HERE. This read `burst_state = BST_IDLE`
         * before asking for the publish, which is the SAME hand-over defect
         * the note machine had -- found by reading THIS machine after the note
         * machine was gated, and now tooth 1 of burst_teeth.sh.
         *
         * With a refused publish the whole ~2.1 M-cycle build was stranded in
         * the shadow: the instrument kept playing the OLD patch, so the
         * program change silently did nothing, and the next key press copied
         * the live bank over the shadow and destroyed the built patch.
         * The contract is eb_burststep.h's: ask, and advance only when the
         * caller says the publish HAPPENED. */
        if (dev_burst_verify(burst_patch, burst_gate)) {
            burst_state = BST_IDLE; rc_step = -1;
        } else {
            burst_state = BST_PUB; rc_step = 0;
        }
        break;

    case BST_PUB:
        /* Reachable only when the publish was REFUSED. Ask again and touch
         * nothing -- the shadow still holds the patch that was not handed
         * over, and opening anything over it loses the build. */
        ++burst_pub_retry;
        rc_step = 0;
        break;
    }

    burst_cyc += (unsigned long)esp_cpu_get_cycle_count() - t0;
    ++burst_blocks;
    if (rc_step == 0) {
        b_last = burst_cyc;
        if (burst_cyc < b_min) b_min = burst_cyc;
        if (burst_cyc > b_max) b_max = burst_cyc;
        ++dev_builds;
        if (burst_blocks > burst_blocks_max) burst_blocks_max = burst_blocks;
    }
    return rc_step;
}

/* ================= S3L_STRESS: THE ROBOT KEYBED ==========================
 *
 * b7's stimulus was a HUMAN mashing a terminal, and the user asked the right
 * question: a person is a poor stimulus generator. Unrepeatable, unlogged,
 * and unable to hit a patch boundary on purpose. This driver is the person,
 * scripted. It submits through THE SAME BOUNDARY as every real input
 * (juno_event_*, source KEYBED) -- a driver that reached the engine any other
 * way would stress a path nobody ships.
 *
 * SEVEN PHASES, ~2 s each, repeating (172 blocks/s, 344 blocks/phase):
 *   0 BASELINE   silence, so every counter has an uncontaminated control
 *   1 SINGLES    a note toggles ~4x/s -- the ordinary case
 *   2 PAIRS      TWO keys in ONE block -- the exact case the old path
 *                dropped and counted (notes_dropped)
 *   3 STORM      one event EVERY block, ~172/s -- far beyond human rate
 *   4 COLLIDE    a note submitted into every block where a patch build is
 *                LIVE (burst_state != IDLE) -- the O1xO2 composition rule,
 *                exercised deliberately instead of by luck
 *   5 PATCHSTORM a program change every ~0.5 s UNDER A HELD CHORD -- B4's
 *                acceptance case, and the worst case for key latency because
 *                a key must now wait for a patch build to hand back the
 *                shadow. keymax is read from THIS phase, not from phase 1.
 *   6 KNOBSTORM  O3. A parameter sweep -- one edit EVERY block, cycling the
 *                whole class table -- UNDER A HELD CHORD, with a program
 *                change every ~1 s on top. This is the only phase that makes
 *                the parameter path run at all.
 *
 * ⚠ PHASE 6 EXISTS BECAUSE THE FIRST O3 BUILD HAD NO KNOB. The parameter path
 * was written, gated by 57 teeth and compiled, and NOTHING ON THE DEVICE COULD
 * SEND IT AN EVENT -- no panel yet, and no stimulus here. That build would have
 * reported PARAM: edits=0 and been read as "O3 is quiet, so O3 is fine". It is
 * the SAME defect the note-collide phase already carries a warning about, one
 * paragraph below, committed again on the next subsystem: a stimulus whose
 * precondition never occurs measures nothing while reporting normally.
 *
 * ⚠ PHASES 4 AND 5 DRIVE THE PATCH THEMSELVES. Phase 4 was written to submit
 * notes into a LIVE patch build and then nothing in this file ever started
 * one -- the console `b`/`n` keys were the only source, so the phase ran its
 * condition against burst_state == IDLE forever and measured NOTHING while
 * reporting normally. A stimulus whose precondition never occurs is the same
 * blind-gate defect as playbook 60, wearing a stimulus instead of a gate.
 *
 * All held notes are released at each phase boundary, so a phase cannot leak
 * ringing voices into the next phase's measurements.
 *
 * ACCEPTANCE, same as the human run: sub == del + dep, ref = 0, torn = 0 --
 * and now HEALTH latches red on either, so nobody has to read the numbers.
 * Default OFF: this is a test stimulus, not an instrument feature. */
#ifndef S3L_STRESS
#define S3L_STRESS 0
#endif
#if S3L_STRESS
/* defined below -- the robot drives the patch as well as the keys, and this is
 * the only forward reference in the file. */
static void dev_request(int patch, int gate);
static void stress_step(void)
{
    static unsigned long blk = 0;
    static int held[8];
    static const unsigned char NOTE[8] = {48, 52, 55, 60, 64, 67, 72, 76};
    unsigned long t = blk++;
    unsigned long ph = (t / 344u) % 7u;
    int i;

    /* THE PATCH DRIVER, phases 4 and 5. dev_request is O(1) and only sets
     * dev_want; the build starts at the next block boundary that the note
     * machine is not holding, which is precisely the contention this is here
     * to create. */
    if (ph == 4u && (t % 43u) == 7u)
        dev_request((int)((t / 43u) % (unsigned long)DEVCRC_NPATCH), 0);
    if (ph == 5u && (t % 86u) == 0u)
        dev_request((int)((t / 86u) % (unsigned long)DEVCRC_NPATCH), 0);

    /* O3's driver. Every block, a different parameter, a sweeping value --
     * the worst case for the parameter machine and the one that shows the
     * coalescing: 344 edits per phase against far fewer builds. */
    if (ph == 6u) {
        int pid = (int)(t % (unsigned long)EB_PARAM_CLASS_N);
        int val = (int)((t * 7u) & 0xFFu);
        juno_event_param(JUNO_SRC_PANEL, pid, val);
        if ((t % 172u) == 3u)
            dev_request((int)((t / 172u) % (unsigned long)DEVCRC_NPATCH), 0);
    }

    if (t % 344u == 343u) {              /* phase boundary: release all */
        for (i = 0; i < 8; ++i)
            if (held[i]) { juno_event_note_off(JUNO_SRC_KEYBED, NOTE[i]);
                           held[i] = 0; }
        return;
    }
    switch (ph) {
    case 0: break;
    case 1:
        if (t % 43u == 0) {
            i = (int)((t / 43u) & 7u);
            if (held[i]) { juno_event_note_off(JUNO_SRC_KEYBED, NOTE[i]);
                           held[i] = 0; }
            else         { juno_event_note_on(JUNO_SRC_KEYBED, NOTE[i], 100);
                           held[i] = 1; }
        }
        break;
    case 2:
        if (t % 86u == 0) {
            juno_event_note_on(JUNO_SRC_KEYBED, 60, 100);
            juno_event_note_on(JUNO_SRC_KEYBED, 64, 100);
        } else if (t % 86u == 43u) {
            juno_event_note_off(JUNO_SRC_KEYBED, 60);
            juno_event_note_off(JUNO_SRC_KEYBED, 64);
        }
        break;
    case 3:
        i = (int)(t & 7u);
        if (held[i]) { juno_event_note_off(JUNO_SRC_KEYBED, NOTE[i]);
                       held[i] = 0; }
        else         { juno_event_note_on(JUNO_SRC_KEYBED, NOTE[i], 100);
                       held[i] = 1; }
        break;
    case 4:
        if (burst_state != BST_IDLE) {
            i = (int)(t & 3u);
            if (!held[i]) { juno_event_note_on(JUNO_SRC_KEYBED, NOTE[i], 100);
                            held[i] = 1; }
        } else if (t % 43u == 1u) {
            for (i = 0; i < 8; ++i)
                if (held[i]) { juno_event_note_off(JUNO_SRC_KEYBED, NOTE[i]);
                               held[i] = 0; }
        }
        break;
    case 6:
        /* A HELD CHORD under the knob sweep, for the same reason phase 5 holds
         * one: a parameter refresh that lands on silence proves nothing about
         * what the player hears. Keys are NOT retriggered here -- the knob is
         * the variable under test and note traffic would confound it. */
        if (t % 344u == 5u)
            for (i = 0; i < 4; ++i) {
                juno_event_note_on(JUNO_SRC_KEYBED, NOTE[i], 100);
                held[i] = 1;
            }
        break;
    case 5:
        /* A HELD CHORD, and keys moving under the program changes above. The
         * chord is what makes this B4's worst case rather than a patch sweep
         * on silence: voices are sounding when the shadow changes hands. */
        if (t % 86u == 3u) {
            for (i = 0; i < 4; ++i)
                if (!held[i]) { juno_event_note_on(JUNO_SRC_KEYBED,
                                                   NOTE[i], 100);
                                held[i] = 1; }
        } else if (t % 86u == 60u) {
            i = (int)((t / 86u) & 3u);
            if (held[i]) { juno_event_note_off(JUNO_SRC_KEYBED, NOTE[i]);
                           held[i] = 0; }
        }
        break;
    }
}
#endif

/* Ask for a patch/gate change. Called from the per-sample tail -- it must be
 * O(1) there, which is the whole point of C3: the 29 KB memcpy that used to
 * live at that call site is now the burst above, on the other side of a flag. */
static void dev_request(int patch, int gate)
{
#if EB_MSPROF
    /* ⚠ O4: THE MSP WINDOW IS THE PATCH, AND THE RESET BELONGS **HERE**.
     *
     * b18 reset the counters once a SECOND while the patch stepped every four,
     * so no line described one patch. The first repair moved the reset to the
     * periodic patch stepper -- and was STILL WRONG, because the stepper is not
     * the only source of a program change: S3L_STRESS drives its own, and so do
     * the console's b/n keys. A window labelled with a DELAY TYPE 0 patch could
     * therefore contain a stretch of a TYPE 5 one, and b19's first run produced
     * exactly that -- two hot windows labelled 48 (type 2) and 32 (type 0),
     * which is incoherent, since one delay type cannot cost 2,090 and 660.
     *
     * Every program change in this firmware passes through THIS function. So
     * the window closes here, for the patch that is ENDING, before dev_patch is
     * overwritten -- and it closes no matter who asked.
     *
     * Guarded on an ACTUAL change: line 3932 re-requests the SAME patch on a
     * gate change, and closing the window there would cut a patch into pieces
     * and label every piece the same, which reads like agreement and is not. */
    if (patch != dev_patch && eb_msprof_n) {
        unsigned long n = eb_msprof_n;
        unsigned long dl = (unsigned long)(eb_msprof[1] / n);
        unsigned long rv = (unsigned long)(eb_msprof[2] / n);
        printf("MSPP: pat=%d in=%lu delay=%lu reverb=%lu out=%lu effect=%lu"
               "  sum=%lu  (n=%lu)\n",
               dev_patch, (unsigned long)(eb_msprof[0] / n), dl, rv,
               (unsigned long)(eb_msprof[3] / n),
               (unsigned long)(eb_msprof[4] / n),
               (unsigned long)((eb_msprof[0] + eb_msprof[1] + eb_msprof[2] +
                                eb_msprof[3] + eb_msprof[4]) / n), n);
        if (dl <= 1ul && rv <= 1ul)
            printf("MSPP: *** BROKEN -- stub tick, IGNORE.\n");
        eb_msprof[0] = eb_msprof[1] = eb_msprof[2] = 0;
        eb_msprof[3] = eb_msprof[4] = 0;
        eb_msprof_n  = 0;
    }
#endif
    dev_patch = patch;
    dev_gate = gate;
    dev_want  = 1;      /* O2: a REQUEST. The build starts at the next block
                         * boundary and takes several; dev_pending now means
                         * "a finished shadow awaits publish" and nothing else.
                         * Conflating the two is what made the burst one
                         * indivisible lump. */
}

/* ======================================================================
 *            C4 + C5 -- THE NOTE PATH AND MIDI IN
 * ======================================================================
 *
 * C3 above proves the chip can turn 134 patch bytes into the host's own
 * coefficients. It still plays a HARD-CODED chord: DEVCHORD_VOICE picks the
 * voice by hand, on purpose, so "is recall right" and "which voice does a key
 * land on" stayed separate questions. C4 joins them and C5 lets you press the
 * key.
 *
 * THE ALLOCATOR IS NOT NEW CODE. engine_b/eb_alloc.c is CAssignJu60's own law,
 * PROVEN 270/270 against the plugin's allocator over all nine assign
 * configurations with four teeth. It emits the port's cell-writing ACTIONS;
 * engine_b/dev/eb_devseq.c applies them through the port's own note functions.
 * Nothing here reimplements either.
 *
 * ⚠ A NOTE-ON IS A COEFFICIENT CHANGE, and that is the fact that shapes this.
 * juno_note.c writes cell 304 (pitch), 320 (the ADSR gate), 6864/9680
 * (velocity) and more, and eb_coefs.c reads every one of them back per voice.
 * So a key press needs the same build+publish a patch change does -- it is a
 * BURST, not a poke. The only differences are that it must NOT reload the cell
 * array from the boot image (that would discard the patch) and must NOT re-run
 * juno_bank_apply.
 *
 * THE LATENCY THIS COSTS, stated rather than discovered: MIDI is polled once
 * per CHUNK and the publish lands at the following block boundary, so a key
 * press is heard between one and two chunks later -- 5.8 to 11.6 ms at
 * CHUNK=256. That is playable but it is not tight, and the fix when it matters
 * is a smaller CHUNK or a per-voice rebuild rather than a whole one. Neither is
 * done here and neither is guessed at: the burst cost is PRINTED.
 */
#ifndef S3L_MIDI
#define S3L_MIDI 0
#endif

/* S3L_USBMIDI -- be a class-compliant USB MIDI device on the NATIVE USB
 * socket, so a DAW can play the instrument with no parts and no driver. Read
 * main/s3_usbmidi.c: the console socket CANNOT do this, and the USB interrupt
 * is a real-time risk that `un=` and `gap=` will report. */
#ifndef S3L_USBMIDI
#define S3L_USBMIDI 0
#endif

/* S3L_PLAY -- THE INSTRUMENT, NOT THE DEMONSTRATION.
 *
 * Everything this firmware does by itself is a TEST FEATURE: it steps through
 * all 64 patches every S3L_PATCH_SECS seconds, and it plays a chord on a
 * 1.5 s / 0.7 s loop. Both were correct while nothing could play it.
 *
 * They are also why the board looks worse than it is. Each patch step and
 * each gate change asks for a 2-million-cycle burst, which is 8 ms against a
 * 5.8 ms block. That makes the 16 ms gaps and most of the underruns. A player
 * does none of this: a player selects ONE patch and presses keys.
 *
 * With S3L_PLAY=1 the firmware does nothing until a key arrives. A key press
 * rebuilds only the voices it touched (about 135,000 cycles, not 2 million).
 *
 * MEASURED, and the reason to expect this to hold: DELAY TYPE 0 patches run
 * 5,150-5,400 cycles against the 5,442 budget. 46 of the 64 factory patches
 * are TYPE 0. The other 18 use DELAY TYPE 2, 3 or 5, measure 6,600-6,900, and
 * will NOT hold real time. That is the PSRAM work and it is not done. */
#ifndef S3L_PLAY
#define S3L_PLAY 0
#endif


/* THE NOTE BURST. Same shape as dev_burst() minus the cold reseed and the bank
 * apply: the cell array is already this patch's and must stay that way. */
/* ================= O2: THE NOTE BURST, ALSO ONE STEP PER BLOCK ==========
 *
 * MEASURED (b8_robot_attribution.md): this was 1.06-1.27 M cycles in ONE
 * block -- 4.4-5.3 ms of a 5.8 ms period, 1.6x core 0's entire slack, and
 * 7.9x the ~135,000 FINAL_GUIDE C4 planned for it. O2 chunked the PATCH burst
 * and left this whole, which made a key press the largest single-block cost
 * in the firmware. THE INVARIANT rule 2 names note bursts explicitly, so O2
 * was half done.
 *
 * THE STATES, one block each, and the voice ones are popcount(mask) blocks
 * rather than one:
 *   NB_EVENTS      apply the allocator's events through the port's note path,
 *                  then open the PRIORITY voice build
 *   NB_PRI         the voices the allocator NAMED, one per block. The publish
 *                  after the last of these is where the key becomes audible.
 *   NB_REST_BEGIN  open the catch-up build, over the bank that publish made
 *                  live
 *   NB_REST        every other voice the broadcast touched, one per block
 *   NB_CHECK       the unmapped-cell check, which must see the WHOLE build
 *
 * `nb` IS NOW SPLIT the way BURST: already is -- ev= for the event apply,
 * vb= for the voice build, nv= for how many voices the allocator named. The
 * 135,000 figure was a PLAN NUMBER that nobody had measured; splitting it is
 * how the next session learns why it is 7.9x rather than guessing. If nv reads
 * 8 when a two-note chord is playing, that is a DEFECT to fix and not work to
 * spread -- which is exactly why the count is printed. */
/* ⚑ AND THE SPLIT PUBLISH, WHICH IS WHAT MAKES IT A KEYBOARD.
 *
 * The chunking above fixed the missed deadlines and created a new fault:
 * eb_alloc emits EB_EV_HELD on every note, eb_devseq widens the mask to all
 * eight voices (correct -- held_gate.py proves narrowing it WRONG on patch 5),
 * so a chunked note is 1 + 8 + 1 = TEN BLOCKS = 58 ms between key and sound.
 * That is not an instrument. Full evidence: data/b9_held_broadcast.md §4.
 *
 * THE FIX is b9 §6 option (c): build the voices the ALLOCATOR NAMED first,
 * publish, then build the other seven into a SECOND publish.
 *
 *   block 1   apply the events
 *   block 2   build the voice the key landed on   --> PUBLISH, IT SOUNDS
 *   block 3-9 the other seven, catching up        --> PUBLISH, complete
 *
 * TWO BLOCKS TO SOUND (~12 ms) instead of ten (58 ms). THE INVARIANT rule 3
 * exactly: the change arrives later, the audio never breaks, and nothing is
 * dropped. What lands late is the broadcast's effect on voices the player did
 * NOT just press -- cell 1856 into their LFO -- for at most eight blocks.
 *
 * IT ADDS NO NEW PUBLISH PATH. A second chunked build after a publish is the
 * same machine on the other bank: begin_voices copies the now-live bank into
 * the new shadow, so the voice just published is carried forward, not lost.
 *
 * ⚠ PUBLISHING TWICE FOR ONE KEY PRESS IS ONLY SAFE BECAUSE PUBLISH IS
 * IDEMPOTENT, and that was CHECKED, not assumed: step 7b consumes the aux
 * retrigger one-shot out of the cell array, so a second publish could destroy
 * what the first armed. tools/engineb/chunk_gate.py compares the RENDER STATE
 * after the split against the monolith over all 6,305 (mask, priority) pairs,
 * and chunk_teeth.sh tooth 11 plants exactly that defect and requires it to be
 * caught. Anything added to eb_recall_publish must keep that tooth red. */
/* ⚠ AND THE PUBLISH MAY BE REFUSED, WHICH IS WHY THERE ARE WAIT STATES.
 * eb_recall_publish returns non-zero when its quiescence precondition fails
 * and then NOTHING moves -- the build stays in the shadow. The firmware
 * already counts that (`dev_pub_refused`) so it is a case that exists.
 *
 * WITHOUT A WAIT STATE THE SPLIT LOSES A VOICE, SILENTLY: if the priority
 * publish is refused and the machine walks on to open the catch-up build,
 * begin_voices copies the LIVE bank over the shadow that still held the
 * priority voice -- and that voice is not in the catch-up mask, so nothing
 * ever rebuilds it. The key sounds with the previous patch's coefficients
 * until the next note happens to name it. A stale voice and no error is this
 * project's most expensive defect shape, and the split publish is the first
 * thing here that could produce one.
 *
 * So the machine does not advance past a publish until the publish HAPPENED.
 * NB_PUB1/NB_PUB2 ask again next block and touch nothing meanwhile; the
 * publish site advances them on success only. */
static eb_nb         NB;
static unsigned long nb_ev = 0, nb_vb = 0, nb_nvoice = 0, nb_steps = 0;
static unsigned long nb_miss0 = 0;
static unsigned long nb_keyblk = 0, nb_keyblk_max = 0;
#define NB_KEYH 12
static unsigned long nb_key_hist[NB_KEYH];
static unsigned long nb_defer = 0;

/* ---- the work eb_notestep.h drives. THIS FILE SUPPLIES THE WORK; THE HEADER
 * SUPPLIES THE ORDER, and the order is what tools/engineb/note_gate.py proves
 * with nine teeth. Two defects in that order were once found by reading this
 * file; they are now teeth 1 and 2. */
static int nb_apply(void *u)
{
    (void)u;
    if (eb_devseq_events(ALLOC_EV, note_nev) != note_nev) {
        dev_mute_why = "the allocator emitted an event the device cannot apply";
        return 0;
    }
    return 1;
}
static unsigned nb_touched(void *u)
{
    (void)u;
    return (unsigned)EB_DEVSEQ_TOUCHED & ((1u << EB_NUM_VOICES) - 1u);
}
static unsigned nb_voiced(void *u)
{
    (void)u;
    return (unsigned)EB_DEVSEQ_VOICED & ((1u << EB_NUM_VOICES) - 1u);
}
static void nb_begin(void *u, unsigned m) { (void)u; eb_recall_chunk_begin_voices(&REC, m); }
static int  nb_chunk(void *u)  { (void)u; return eb_recall_chunk_step(&REC); }
static int  nb_busy(void *u)   { (void)u; return eb_recall_chunk_busy(&REC); }
static int  nb_check(void *u)
{
    (void)u;
    if (EBDEV_S.miss != nb_miss0) {
        printf("NOTE: *** %lu UNMAPPED CELL ACCESSES applying note events "
               "(last offset %lu). A note wrote into a SINK -- that is "
               "DEVICE_RECALL.md defect 2 and the voice is silent. ***\n",
               EBDEV_S.miss - nb_miss0, EBDEV_S.lastmiss);
        dev_mute_why = "a note event hit an unmapped cell";
        health_fail("a note wrote into an unmapped cell");
        return 0;
    }
    return 1;
}
static const eb_nb_ops NB_OPS = { nb_apply, nb_touched, nb_voiced,
                                  nb_begin, nb_chunk, nb_busy, nb_check };

static int dev_note_step(void)
{
    unsigned long t0 = (unsigned long)esp_cpu_get_cycle_count();
    int was_idle = eb_nb_idle(&NB);
    int r;

    /* A NOTE STEP IS BURST WORK TOO. Without this, a miss caused by a note
     * build was attributed to `quiet` -- i.e. to O4. */
    note_ran_this_block = 1;
    if (was_idle) nb_miss0 = EBDEV_S.miss;

    r = eb_nb_step(&NB, &NB_OPS, (void *)0);

    if (was_idle) {
        nb_ev = (unsigned long)esp_cpu_get_cycle_count() - t0;
        nb_nvoice = 0; nb_vb = 0;
        {   unsigned m = nb_touched((void *)0);
            while (m) { nb_nvoice += m & 1u; m >>= 1; }
        }
        nb_steps = (unsigned long)eb_recall_chunk_steps(&REC);
    } else {
        nb_vb += (unsigned long)esp_cpu_get_cycle_count() - t0;
    }

    nb_keyblk = NB.key_blocks;
    if (r == 0 && NB.st == NB_PUB1) {
        if (nb_keyblk > nb_keyblk_max) nb_keyblk_max = nb_keyblk;
        nb_key_hist[nb_keyblk < NB_KEYH ? nb_keyblk : NB_KEYH - 1]++;
    }
    if (r == 0 && NB.st == NB_PUB2) {
        ++note_bursts;
        nb_last = nb_ev + nb_vb;
        if (nb_last < nb_min) nb_min = nb_last;
        if (nb_last > nb_max) nb_max = nb_last;
    }
    return r;
}

#if S3L_MIDI
/* ---- MIDI IN, UART1 at 31,250 baud --------------------------------------
 *
 * Standard 5-pin MIDI or a USB-MIDI adapter that speaks serial. One wire plus
 * ground into S3L_MIDI_RX. An opto-isolator is the correct front end for a
 * real DIN socket; a direct connection works on a bench and is what this
 * assumes.
 *
 * RUNNING STATUS IS HANDLED because keyboards use it: after one 0x9n a
 * controller may send bare note/velocity pairs forever, and a parser that
 * ignores that drops most of what you play. NOTE-ON WITH VELOCITY 0 IS A
 * NOTE-OFF -- also not optional, it is how most keyboards release.
 *
 * THE VELOCITY POLICY IS THE PLUGIN'S OWN and it is not a detail: the JU-06A's
 * wrapper forces every note to velocity 100 unless "Keyboard Velocity SW" is
 * on, and its default is OFF (CLAUDE.md, the host-lifecycle arc). A port that
 * passes played velocity raw sounds wrong on every velocity-sensitive patch.
 * S3L_MIDI_VELSW=1 turns the switch on. */
#ifndef S3L_MIDI_RX
#define S3L_MIDI_RX 18
#endif
#ifndef S3L_MIDI_VELSW
#define S3L_MIDI_VELSW 0
#endif
#define MIDI_UART   UART_NUM_1

static uint8_t m_status = 0, m_d1 = 0;
static int     m_have = 0;

/* NON-STATIC on purpose: main/s3_usbmidi.c calls this so that USB MIDI and
 * UART MIDI share ONE velocity policy and ONE allocator path. Two entry points
 * that decide separately is how the assigner-mode defect survived for months. */
/* ================= O1: THE CONSUMER SIDE =================================
 *
 * The queue is synth-agnostic by rule (END_GOAL item 7). EVERYTHING THAT IS
 * TRUE ONLY OF A JUNO LIVES HERE, on this side of the boundary, and there is
 * exactly one of each.
 *
 * THE VELOCITY POLICY MOVED HERE, and that is a correction rather than a
 * relocation. It used to sit in the submit path, which meant the QUEUE carried
 * an already-cooked velocity. But the JU-06A wrapper forcing every note to 100
 * unless "Keyboard Velocity SW" is on is a property of THIS INSTRUMENT, not of
 * a keybed. The boundary now carries what was PLAYED and the instrument
 * decides what to do with it -- which is also what lets the same header serve
 * the JX-3P, whose wrapper has different manners.
 *
 * It is still decided in ONE place, which was the original reason it was
 * hoisted out of the two parsers (docs/ASSIGNER_MODE_FINDING.md).
 *
 * THE CAP. eb_alloc emits up to EB_ALLOC_MAX_EV (40) events per note into one
 * shared buffer, and the burst applies the buffer as a unit. So this drains
 * notes only while the buffer provably has room for another worst case. That
 * is rule 2 -- a fixed budget of work per block, more blocks when there is
 * more to do -- and the surplus stays queued IN ORDER for the next block.
 *
 * WHY NOT ONE NOTE PER BLOCK, which would also be safe: a chord is several
 * note-ons in the same millisecond, and one per 5.8 ms block would spread a
 * six-note chord over 35 ms. That is audible as an arpeggio. */
#define EV_DRAIN_MAX 8          /* events examined per block; see the cap note */

/* Kept, and it must now read 0: O3 handles every parameter event, so a
 * non-zero count means an event reached the drain that the parameter path
 * declined -- the gap this counter was added to make visible has moved from
 * "not implemented yet" to "a real refusal". */
static unsigned long ev_param_unhandled = 0;

static int ev_apply(void)
{
    juno_event ev[EV_DRAIN_MAX];
    int got, i, nev = 0;

    /* Room for ONE worst-case note must exist before the first is taken, or
     * the drain would have to put an event back -- and a queue you can push
     * back into is not a queue with one consumer. */
    if (note_pending) return 0;      /* a burst is still in flight */
    got = juno_event_drain(ev, EV_DRAIN_MAX);
    if (got <= 0) return 0;

    for (i = 0; i < got; ++i) {
        int n, vel;
        if (ev[i].kind == JUNO_EV_PARAM) {
            /* O3. The edit is written into the record and its class OR-ed into
             * the pending mask; the REBUILD happens later, in the parameter
             * machine, under the budget. Several knobs in one drain therefore
             * cost ONE build, which is what makes C9's "as many parameters as
             * you please, at the same time" affordable.
             *
             * ⚠ THIS WRITES THE RECORD, NOT THE SHADOW. It is safe with a
             * build in flight because the record is not the coefficient bank;
             * the next apply reads whatever the record then holds. An edit
             * arriving mid-build is therefore picked up by the build after it,
             * which is rule 3 -- late, never lost. */
            dev_param_edit((int)ev[i].a, (int)ev[i].b);
            continue;
        }
        /* STOP BEFORE THE BUFFER CAN OVERFLOW, not after. eb_alloc may write
         * up to EB_ALLOC_MAX_EV for the next note alone. */
        if (nev + EB_ALLOC_MAX_EV > (int)(sizeof ALLOC_EV / sizeof ALLOC_EV[0]))
            break;

        ++notes_seen;
        vel = ev[i].b;
#if !S3L_MIDI_VELSW
        vel = (ev[i].kind == JUNO_EV_NOTE_ON) ? 100 : 64;
#endif
        n = (ev[i].kind == JUNO_EV_NOTE_ON)
              ? eb_alloc_note_on(&ALLOC, ev[i].a, vel, ALLOC_EV + nev)
              : eb_alloc_note_off(&ALLOC, ev[i].a, ALLOC_EV + nev);
        if (n > 0) nev += n;
    }
    if (nev <= 0) return 0;
    note_nev = nev;
    note_pending = 1;
    ++ev_applied_blocks;
    return 1;
}

/* O1: `s3_midi_event()` IS GONE, and its removal is the point of this step.
 *
 * It was the single note entry -- the half of the boundary that already
 * existed -- and it did two things it should not have. It ALLOCATED VOICES
 * INLINE from whatever task happened to be parsing, and when a burst was
 * already pending it DROPPED the note:
 *
 *     if (note_pending) { ++notes_dropped;
 *         health_fail("a note was DROPPED rather than delayed"); return; }
 *
 * THE INVARIANT rule 3 says the change ARRIVES LATER. It does not permit
 * discarding it. Playing two keys inside one 5.8 ms block lost one, on an
 * instrument whose entire premise is that it never breaks.
 *
 * Every parser now calls juno_event_note_on/off directly WITH ITS OWN SOURCE
 * TAG, so USB and DIN are distinguishable in every counter -- through the shim
 * they were not. Nothing reaches eb_alloc except ev_apply(), and
 * tools/engineb/boundary_check.py fails the build if that stops being true. */

static void midi_poll(void)
{
    uint8_t b[64];
    int n, i;
    n = uart_read_bytes(MIDI_UART, b, sizeof b, 0);
    for (i = 0; i < n; ++i) {
        uint8_t c = b[i];
        if (c >= 0xF8) continue;                 /* real-time, ignore */
        if (c & 0x80) {                          /* status */
            m_status = c; m_have = 0;
            continue;
        }
        if ((m_status & 0xF0) != 0x90 && (m_status & 0xF0) != 0x80) continue;
        if (!m_have) { m_d1 = c; m_have = 1; continue; }
        /* O1: the DIN parser SUBMITS. It no longer decides anything about
         * velocity -- that is the instrument's business, applied once in
         * ev_apply -- and it can no longer lose a note to a busy block. */
        if ((m_status & 0xF0) == 0x90) juno_event_note_on (JUNO_SRC_DIN, m_d1, c);
        else                           juno_event_note_off(JUNO_SRC_DIN, m_d1);
        m_have = 0;                              /* running status stays armed */
    }
}


/* ================= THE KEYBOARD YOU ALREADY HAVE =========================
 *
 * WHY THIS EXISTS. Every part of the note path is built and PROVEN on the host
 * -- eb_alloc is CAssignJu60's own law, 270/270 against the plugin -- and none
 * of it had ever executed on the board, because nothing had ever sent a byte to
 * GPIO 18. USB MIDI was meant to be that byte source and does not enumerate.
 *
 * The console cable is already connected to UART0. So the terminal becomes the
 * keyboard: no optocoupler, no DIN socket, no USB stack, no parts at all. It is
 * not a musical instrument interface and is not pretending to be one. It exists
 * to make the allocator, the note path and the incremental burst RUN, and to
 * make the board make a sound you asked it for.
 *
 * THE LAYOUT is the usual tracker/DAW one, so the middle row is the white keys:
 *
 *     w e   t y u          C# D#   F# G# A#
 *    a s d f g h j k      C  D  E  F  G  A  B  C
 *
 * z and x transpose down and up one octave. SPACE releases everything.
 *
 * KEYS TOGGLE, and that is a deliberate limitation rather than an oversight: a
 * terminal reports a key going DOWN and never reports it coming UP. So the
 * first press sounds a note and the second releases it. You can therefore hold
 * a chord -- press a, d, g -- which is what makes this useful for two voices.
 *
 * ⚠ IT MUST NOT PRINT. This is called from the audio loop, and printf in the
 * audio loop is playbook defect 30, four recurrences, most recently today. The
 * counters say what happened; the reporter prints them. */
#define CON_UART UART_NUM_0

static const signed char CON_KEY[128] = {
    ['a'] =  0, ['w'] =  1, ['s'] =  2, ['e'] =  3, ['d'] =  4,
    ['f'] =  5, ['t'] =  6, ['g'] =  7, ['y'] =  8, ['h'] =  9,
    ['u'] = 10, ['j'] = 11, ['k'] = 12,
};
static unsigned char con_held[128];
static int  con_base = 60;              /* middle C */
/* The console-settable split. Declared here because the console reader below
 * writes it and is defined before the block that explains it; the reasoning
 * lives at the SPLIT_ macro. Latched into w_split at a block boundary. */
#if !S3L_LAYOUT
volatile int g_split_rt = S3L_SPLIT;
#endif
unsigned long con_keys = 0;

/* O3 console state: which parameter the `;`/`'` keys select and the
 * value the `[`/`]` keys sweep. */
static int k_param = 0;
static int k_pval  = 128;

static void con_poll(void)
{
    unsigned char b[16];
    int n, i;
    n = uart_read_bytes(CON_UART, b, sizeof b, 0);
    for (i = 0; i < n; ++i) {
        unsigned char c = b[i];
        int note;
        if (c == ' ') {                 /* panic: release everything */
            int k;
            for (k = 0; k < 128; ++k)
                if (con_held[k]) { con_held[k] = 0;
                                   juno_event_note_off(JUNO_SRC_CONSOLE, k); }
            continue;
        }
        /* t -- fire the overrun detector ONCE, deliberately. See the block at
         * its use site: this is how a measurement build proves its own
         * detectors are live without contaminating the measurement. */
        if (c == 't') { tooth_once = 1; continue; }
        /* O3 BY HAND. `[` and `]` sweep the SELECTED parameter down and up;
         * `;` and `'` choose which parameter. Without these the only knob
         * source is the robot phase, and a path you cannot drive by hand is a
         * path you cannot investigate when the robot finds something. */
        if (c == ';' || c == '\'') {
            k_param = (c == '\'') ? (k_param + 1) % EB_PARAM_CLASS_N
                                   : (k_param + EB_PARAM_CLASS_N - 1)
                                     % EB_PARAM_CLASS_N;
            printf("PARAM: selected id=%d (record %d, vmask=%02x tail=%d "
                   "master=%d)\n", k_param, EB_PARAM_CLASS[k_param].rec,
                   EB_PARAM_CLASS[k_param].vmask8,
                   EB_PARAM_CLASS[k_param].tail,
                   EB_PARAM_CLASS[k_param].master);
            continue;
        }
        if (c == '[' || c == ']') {
            k_pval = (c == ']') ? (k_pval + 8 > 255 ? 255 : k_pval + 8)
                                : (k_pval < 8 ? 0 : k_pval - 8);
            juno_event_param(JUNO_SRC_PANEL, k_param, k_pval);
            printf("PARAM: id=%d value=%d\n", k_param, k_pval);
            continue;
        }
        if (c == 'z') { if (con_base >= 24) con_base -= 12; continue; }
        if (c == 'x') { if (con_base <= 96) con_base += 12; continue; }
        /* b / n -- PROGRAM CHANGE, backward and forward through the 64 factory
         * patches. This costs the FULL burst (about 2,000,000 cycles), not the
         * note path's ~135,000: a patch change really does move every voice
         * coefficient and the whole master chain. It is requested here and
         * performed in render_block, off the per-sample path, so it lands at a
         * block boundary rather than inside one.
         *
         * ⚠ EXPECT A CLICK. 2 M cycles is 8 ms against a 5.8 ms block, so a
         * program change is currently audible as a gap. That is the known open
         * item, it is measured (data/c3_silicon.md), and hearing it here is the
         * instrument telling the truth rather than a new fault. */
        if (c == 'b') {
            dev_request((dev_patch + DEVCRC_NPATCH - 1) % DEVCRC_NPATCH, 0);
            continue;
        }
        if (c == 'n') {
            dev_request((dev_patch + 1) % DEVCRC_NPATCH, 0);
            continue;
        }
#if !S3L_LAYOUT
        /* , / . -- MOVE THE SPLIT. Core 0 renders [lo, split), core 1 renders
         * [split, 8) plus the whole master chain. split = 8 leaves core 1 with
         * the FX ALONE, which is the cheap test of the load-balance finding:
         * no new pipeline stage and no added latency. The value is latched at
         * a block boundary in render_block, so pressing this mid-block cannot
         * make the two cores disagree about a voice. */
        if (c == ',' || c == '.') {
            g_split_rt += (c == '.') ? 1 : -1;
            if (g_split_rt < S3L_VOICE_LO)  g_split_rt = S3L_VOICE_LO;
            if (g_split_rt > EB_NUM_VOICES) g_split_rt = EB_NUM_VOICES;
            printf("SPLIT: core 0 renders voices %d..%d, core 1 renders %d..%d "
                   "%s the master chain\n",
                   S3L_VOICE_LO, g_split_rt - 1, g_split_rt, EB_NUM_VOICES - 1,
                   "plus");
            if (g_split_rt >= EB_NUM_VOICES)
                printf("SPLIT: core 1 now runs the FX ALONE (no voices)\n");
            continue;
        }
#endif
        if (c >= 128 || (CON_KEY[c] == 0 && c != 'a')) continue;
        note = con_base + CON_KEY[c];
        if (note < 0 || note > 127) continue;
        ++con_keys;
        if (con_held[note]) { con_held[note] = 0;
                              juno_event_note_off(JUNO_SRC_CONSOLE, note); }
        else                { con_held[note] = 1;
                              juno_event_note_on(JUNO_SRC_CONSOLE, note, 100); }
    }
}

static int con_start(void)
{
    /* The console's own UART. The driver is installed for READING; printf keeps
     * writing the way it always has, and the two directions do not share a
     * FIFO. */
    if (uart_driver_install(CON_UART, 256, 0, 0, NULL, 0) != ESP_OK) return 0;
    return 1;
}

static int midi_start(void)
{
    uart_config_t cfg = {
        .baud_rate = 31250,
        .data_bits = UART_DATA_8_BITS,
        .parity    = UART_PARITY_DISABLE,
        .stop_bits = UART_STOP_BITS_1,
        .flow_ctrl = UART_HW_FLOWCTRL_DISABLE,
        .source_clk = UART_SCLK_DEFAULT,
    };
    if (uart_driver_install(MIDI_UART, 512, 0, 0, NULL, 0) != ESP_OK) return 0;
    if (uart_param_config(MIDI_UART, &cfg) != ESP_OK) return 0;
    if (uart_set_pin(MIDI_UART, UART_PIN_NO_CHANGE, S3L_MIDI_RX,
                     UART_PIN_NO_CHANGE, UART_PIN_NO_CHANGE) != ESP_OK) return 0;
    return 1;
}
#endif /* S3L_MIDI */
#endif /* S3L_RECALL */

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
/* S3L_RING_SRAM -- put the SHORTENED rings in INTERNAL SRAM.
 *
 * WHY, MEASURED. docs/engineb/data/o8_halfos_result.md section 10 prices the
 * FX chain at 3,276 instructions and 7,745 cycles -- c/i 2.36 against the
 * voice chain's 1.56 -- and names the cause itself: the rings are 6.2 MB in
 * PSRAM. tools/engineb (JUNO_EB_RING_PROBE=1) then measured the DEEPEST READ
 * behind each write pointer over all 36 scenarios: 31,007 samples on the
 * largest ring, and since exactly ONE DELAY ARM runs per patch the worst
 * ACTIVE set is 137 KB against the 163 KB of free internal SRAM this file
 * prints at boot.
 *
 * WHY IT IS NOT JUST A SMALLER calloc, AND THIS IS THE WHOLE DIFFICULTY. The
 * length is the MODULUS of the circular buffer: a read is (w - lag) mod len.
 * Shortening the ring is only equivalent while lag < len AT EVERY SAMPLE. It
 * is therefore NOT a free change -- it is a change with a PRECONDITION, and
 * the precondition is a property of the DELAY TIME parameter, not of the 36
 * scenarios that happened to be measured.
 *
 * SO THE SHORT RING CARRIES A RUNTIME GUARD rather than a hope. Every read
 * lag is checked against the allocated length and the deepest one seen is
 * reported at each sweep phase. If any lag reaches the length the firmware
 * SAYS SO instead of quietly folding a 2-second delay into a 0.74-second one,
 * which would be heard as a wrong delay time and diagnosed as a DSP defect.
 *
 * DEFAULT 0: the full PSRAM allocation, exactly as before. */
#ifndef S3L_RING_SRAM
#define S3L_RING_SRAM 0
#endif
#if S3L_RING_SRAM
/* the deepest read lag observed per ring, published for the report */
volatile uint32_t s3l_ring_lag[9];
volatile uint32_t s3l_ring_over;          /* times a lag reached the length */
#endif

static int rings_alloc(void)
{
    float **dst[9] = { &RG.t1, &RG.t23, &RG.t5_0, &RG.t5_1, &RG.t5_2,
                       &RG.t5_3, &RG.e5, &RG.t4_0, &RG.t4_1 };
    int32_t *len[9] = { &RG.t1_len, &RG.t23_len, &RG.t5_0_len, &RG.t5_1_len,
                        &RG.t5_2_len, &RG.t5_3_len, &RG.e5_len,
                        &RG.t4_0_len, &RG.t4_1_len };
    /* the port's own ring lengths, the same nine the standalone shim copies */
    int i, n_int = 0, n_psram = 0;
    for (i = 0; i < 9; ++i) {
        int32_t want = S3L_RING_LEN[i];
#if S3L_RING_SRAM
        /* cap at the measured working set rounded to a power of two -- the
         * modulus must stay a power of two or the wrap arithmetic changes */
        if (want > S3L_RING_SRAM) want = S3L_RING_SRAM;
        *dst[i] = heap_caps_calloc((size_t)want, sizeof(float),
                                   MALLOC_CAP_INTERNAL);
        if (!*dst[i]) {
            printf("RINGS: internal alloc failed at %d (%d samples) -- "
                   "falling back to PSRAM at FULL length\n", i, (int)want);
            want = S3L_RING_LEN[i];
            *dst[i] = heap_caps_calloc((size_t)want, sizeof(float),
                                       MALLOC_CAP_SPIRAM);
            ++n_psram;
        } else {
            ++n_int;
        }
#else
        *dst[i] = heap_caps_calloc((size_t)want, sizeof(float),
                                   MALLOC_CAP_SPIRAM);
#endif
        if (!*dst[i]) { printf("RINGS: alloc failed at %d\n", i); return 0; }
        *len[i] = want;
    }
#if S3L_RING_SRAM
    /* Report the OUTCOME, not the request. The earlier form printed
     * "INTERNAL SRAM" unconditionally, so a run in which five of the nine
     * rings had fallen back to PSRAM still announced itself as an internal
     * build -- and the FX cycle figure was then read as an internal figure.
     * A summary line that cannot say it failed is not a summary line. */
    printf("RINGS: cap %d samples. %d of 9 INTERNAL, %d in PSRAM -- "
           "PLACEMENT IS %s. free internal now %u\n",
           (int)S3L_RING_SRAM, n_int, n_psram,
           (n_psram == 0) ? "ALL-INTERNAL"
                          : (n_int == 0 ? "ALL-PSRAM" : "MIXED"),
           (unsigned)heap_caps_get_free_size(MALLOC_CAP_INTERNAL));
    printf("RINGS: THE CAP IS ONLY VALID WHILE EVERY READ LAG IS BELOW IT --\n"
           "       a longer DELAY TIME than this bank uses would fold.\n");
#endif
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
static int               w_n = 0;

#ifndef S3L_FX_PIPE
#define S3L_FX_PIPE 0
#endif
#if S3L_FX_PIPE && S3L_NOFX
#error "S3L_FX_PIPE pipelines the FX chain; it is meaningless with S3L_NOFX."
#endif

#if S3L_FX_PIPE
/* ---- THE FX PIPELINE STAGE -------------------------------------------------
 *
 * WHY. FXRT measured 8,014 cycles against a 5,442 budget, and the parts added
 * EXACTLY: voice phase 5,294 + FX 2,622 + output 91. The FX was serial,
 * because `eb_master_render` ran in the per-sample loop AFTER the barrier, on
 * core 0, with core 1 already finished and idle. Nothing was overlapped.
 *
 * WHY IT CANNOT SIMPLY MOVE. The FX consumes the SUMMED VOICE OUTPUT, so it
 * cannot run beside the voices of the same sample -- the thing it needs does
 * not exist yet. It can only run beside the voices of the NEXT chunk. So this
 * is a pipeline stage, not a reassignment, and it costs one chunk of latency
 * (2.9 ms at CHUNK=128) and a second set of buffers. Both are stated here
 * because both are real.
 *
 * THE SHAPE. Two banks. Each chunk, both cores render voices into bank `cur`;
 * core 1 then runs the FX over bank `1-cur`, which is complete, and writes
 * finished PCM for it. Core 0's per-sample tail keeps only the note gate.
 *
 *   core 0 : prologue + its voice range                    (bank cur)
 *   core 1 : its voice range (bank cur), THEN FX (bank 1-cur)
 *
 * so the loop becomes max(core0_voices, core1_voices + FX) instead of a sum.
 * With the wake mask putting 2 voices on core 0 and 1 on core 1 that is
 * max(4,724 , 2,362 + 2,622) = 4,984, which is the point of the exercise.
 *
 * THE FIRST CHUNK HAS NO PREDECESSOR and therefore emits one chunk of
 * SILENCE, 2.9 ms, once at start. That is the pipeline filling, not a defect,
 * and it is why `w_have_prev` exists rather than being assumed.
 *
 * RACE ANALYSIS, stated rather than hoped: core 0 writes bank `cur` at voice
 * indices [0,SPLIT) while core 1 writes bank `cur` at [SPLIT,NUM) -- disjoint.
 * Core 1 READS bank `1-cur`, which no one writes this chunk. `w_cur` is
 * flipped by core 0 only, before `w_go` releases the worker, so the worker
 * reads a stable value for the whole pass. */
static float             w_vbb[2][CHUNK][EB_NUM_VOICES];
static int16_t           w_pcm[2][CHUNK * 2];
static volatile int      w_cur = 0;
static volatile int      w_have_prev = 0;
#else
static float             w_vbb[CHUNK][EB_NUM_VOICES];
#endif

/* ROLLING READY INDEX, not a barrier. The first block design computed ALL
 * 128 prologues before releasing core 1, so the whole prologue pass (notecv +
 * voice-0 cvgate/glide + the shared LFO) sat on the critical path with core 1
 * idle. w_ready is published by core 0 as each sample's prologue completes and
 * consumed by core 1, so the two overlap. One writer per flag; volatile. */
static volatile int w_ready = 0;

/* S3L_VOICE_LO -- the LOWEST voice index this firmware owns.
 *
 * WHY IT EXISTS, and it is not an optimisation. MEASURED 2026-08-11: the
 * shared prologue costs 117 cycles, not the 1,414 a subtraction had implied.
 * The other 1,297 is the per-sample cost of the FIVE voices this chord never
 * sounds -- about 259 cycles each for a zero-write, an at-rest test, two
 * control-rate state writes and a block advance.
 *
 * On a TWO-CHIP build those voices do not exist. Chip B owns three voices;
 * voices 0..4 are chip A's. Iterating them is not work to be made faster, it
 * is work the shipping design never does at all. This constant makes the
 * firmware own only what it owns.
 *
 * SAFETY, stated: w_vbb is static and therefore zero, nothing writes the
 * unowned slots, and the master sums all EB_NUM_VOICES entries -- so the
 * unowned slots contribute exactly 0.0 forever without being re-zeroed. That
 * is why the per-sample zeroing may be skipped rather than merely hoisted.
 *
 * DEFAULT 0 = own everything, which is the behaviour every previous build
 * had. */
/* How often the per-second report is PRINTED. The measurement is unaffected;
 * see the console note in the loop for why this matters at all. */
#ifndef S3L_REPORT_EVERY
#define S3L_REPORT_EVERY 5
#endif

#ifndef S3L_VOICE_LO
#define S3L_VOICE_LO 0
#endif
#if S3L_VOICE_LO >= EB_NUM_VOICES
#error "S3L_VOICE_LO must leave at least one voice."
#endif

/* ---- S3L_LAYOUT: EVERY CHIP LAYOUT IN ONE FLASH ----------------------------
 *
 * WHY THIS IS RUNTIME AND NOT SIX BUILDS. `S3L_VOICE_LO`, `S3L_SPLIT` and the
 * FX stage are compile-time today, so answering "which two-chip layout fits"
 * costs one flash per layout, and the user has already flashed this board
 * fifteen times tonight. None of the three has to be compile-time:
 * `eb_engine_render_range` TAKES the range as arguments, and the FX stage is
 * one `if`. So this build sweeps them.
 *
 * WHAT IS DIFFERENT FROM A DEDICATED BUILD, stated because it bounds what the
 * numbers mean:
 *
 *   - a real `S3_NOFX=1` build puts the voice state in INTERNAL RAM and skips
 *     the ring allocation. Here the FX must exist for the FX rows, so the
 *     placement is a per-ROW field instead (`rsint`) and both are measured.
 *   - the dry-bus sum for the no-FX rows runs on core 1 in the pipeline slot
 *     the FX would have used, not in core 0's tail. It is eight adds.
 *
 * Everything else -- the same chunk, the same barrier, the same timer, the
 * same engine -- is shared, so rows are comparable with each other and row 1
 * is comparable with the builds already measured. THAT IS WHY ROW 1 EXISTS:
 * it reproduces the shipping configuration, and if it does not read about
 * 6,040 then this harness is measuring something else and no other row on the
 * page may be quoted. */
#ifndef S3L_LAYOUT
#define S3L_LAYOUT 0
#endif
#if S3L_LAYOUT && !S3L_FX_PIPE
#error "S3L_LAYOUT needs S3L_FX_PIPE=1: the FX rows are measured in the pipeline slot, which is the only place the FX has ever been free."
#endif
#if S3L_LAYOUT && S3L_NOFX
#error "S3L_LAYOUT builds WITH the master chain and switches it per row; S3L_NOFX removes it from the link."
#endif
#if S3L_LAYOUT
static int g_lo = S3L_VOICE_LO, g_split = 4, g_fx = 1;
#define LO_     g_lo
#define SPLIT_  g_split

/* THE LAYOUT TABLE.
 *
 *   k      how many voices this row sounds. The wake masks fill from voice 7
 *          DOWNWARD (the allocator's own order), so k voices are [8-k, 8) and
 *          the row owns exactly those: lo = 8-k.
 *   split  the first voice index core 1 renders. core 0 gets [lo, split),
 *          core 1 gets [split, 8).
 *   fx     run the master chain (chorus, delay, reverb) on core 1's pipeline
 *          slot, or emit the dry voice bus.
 *   rsint  voice state in INTERNAL RAM rather than PSRAM. A real S3_NOFX
 *          build always does this and every FX build so far never has, so the
 *          two have never been compared at the same FX setting.
 *
 * PREDICTIONS ARE IN THE `pred` COLUMN so they cannot be written after the
 * fact. They come from the measured constants -- prologue+LFO ~717, voice
 * 2,362, FX 2,622, output 91 -- as max(core0, core1) + 91, and the additive
 * model is already known to read about 370 cycles LOW against this loop. */
typedef struct { int k, split, fx, rsint, pred; const char *what; } s3l_row;
static const s3l_row S3L_ROW[] = {
 { 3, 7, 1, 0, 5532, "CONTROL: chip B as shipped (3v+FX, 2/1) -- must read ~6040" },
 { 3, 7, 1, 1, 5532, "  same, voice state INTERNAL RAM" },
 { 2, 7, 1, 1, 5075, "LAYOUT B chip B: 2 voices + FX, 1/1" },
 { 2, 7, 1, 0, 5075, "  same, voice state PSRAM" },
 { 3, 6, 0, 1, 4815, "LAYOUT A chip A: 3 voices no FX, 1/2" },
 { 4, 6, 0, 1, 6051, "LAYOUT B chip A: 4 voices no FX, 2/2" },
 { 4, 5, 0, 1, 7177, "  4 voices no FX, 1/3 -- the other partition" },
 { 3, 6, 1, 1, 7437, "  3 voices + FX, 1/2 -- the other partition" },
 { 6, 5, 0, 1, 7177, "ONE CHIP, 6 voices, no FX" },
 { 6, 5, 1, 1, 9799, "ONE CHIP, everything: 6 voices + FX" },
};
#define S3L_NROW ((int)(sizeof S3L_ROW / sizeof S3L_ROW[0]))
static eb_render_state *RS_INT, *RS_PSR;

/* Applying a row touches four of app_main's locals, so it is a macro rather
 * than a function -- passing four pointers to say `CH = k-1` would be worse.
 * It is expanded in exactly one place. Every row starts from the SAME seeded
 * state, or a row would inherit the previous row's warm FX and its number
 * would not be comparable. */
#define S3L_APPLY_ROW(ROW) do {                                               \
    const s3l_row *r_ = &S3L_ROW[ROW];                                        \
    int q_;                                                                   \
    g_lo = EB_NUM_VOICES - r_->k;                                             \
    g_split = r_->split;                                                      \
    g_fx = r_->fx;                                                            \
    CH = r_->k - 1;                                                           \
    WAKE = S3L_MASK[CH];                                                      \
    RS = r_->rsint ? RS_INT : RS_PSR;                                         \
    memcpy(RS, B_RSTATE, S3L_VOICE_SZ);                                       \
    ms_load(B_MSTATE);                                                        \
    memset(w_vbb, 0, sizeof w_vbb);                                           \
    memset(w_pcm, 0, sizeof w_pcm);                                           \
    w_have_prev = 0;                                                          \
    frame = 0; gate = 0;                                                      \
    load_coefs(CH, 0);                                                        \
    for (q_ = 0; q_ < EB_NUM_VOICES; ++q_)                                    \
        EBE.v[q_].atrest = !((WAKE >> q_) & 1u);                              \
    printf("\n--- ROW %d/%d  %s\n"                                            \
           "    voices %d (%d..%d)  core0 [%d,%d)  core1 [%d,%d)  FX %s  "    \
           "state %s  predicted %d\n",                                        \
           (ROW) + 1, S3L_NROW, r_->what,                                     \
           r_->k, EB_NUM_VOICES - r_->k, EB_NUM_VOICES - 1,                   \
           g_lo, g_split, g_split, EB_NUM_VOICES,                             \
           r_->fx ? "on" : "off", r_->rsint ? "INTERNAL" : "PSRAM",           \
           r_->pred);                                                         \
} while (0)
#else
#define LO_     S3L_VOICE_LO
/* THE SPLIT IS RUNTIME IN THIS BUILD, AND THAT IS THE WHOLE POINT.
 *
 * b5_fx_attribution.md located the delay overrun in the load balance: core 0
 * carries [LO_, split) and core 1 carries [split, 8) PLUS the entire master
 * chain, and cyc = fx + v1 says core 1's two halves are the whole block.
 * The cheapest possible test of that -- no new pipeline stage, no added
 * latency -- is to give core 0 BOTH voices and leave core 1 with only the FX:
 * split = EB_NUM_VOICES makes core 1's voice range [8,8), which is empty.
 *
 * Compile-time it would cost a flash per value, and this board has been
 * reflashed enough. `eb_engine_render_range` already TAKES the range, so the
 * only requirement is that BOTH CORES SEE ONE VALUE FOR A WHOLE BLOCK --
 * which is why it is latched into w_split in render_block before core 1 is
 * released, and never read from the console variable inside the loops. */
static int          w_split    = S3L_SPLIT;   /* latched, per block */
#define SPLIT_  w_split
#endif

#ifndef S3L_TIME_PROLOGUE
#define S3L_TIME_PROLOGUE 0
#endif
#if S3L_TIME_PROLOGUE
/* prologue cost, accumulated per block. Write-only from core 0. */
static unsigned long prologue_us = 0, prologue_n = 0;
#endif

/* S3L_FXPROF -- SPLIT CORE 1'S PASS INTO ITS TWO HALVES.
 *
 * WHY THIS EXISTS AND WHY IT IS NOT OPTIONAL. The second silicon run measured
 * DELAY TYPE 2/3/5 patches at 6,526-6,772 cyc against 5,069-5,682 for every
 * other patch, and the delta was ATTRIBUTED to PSRAM ring latency on the
 * strength of the boot probe's scattered-read row. That attribution is not
 * measured, and the boot probe cannot support it: it strides one cache line so
 * every read misses, while a delay tap walks the ring ~sequentially. The probe
 * measures a pattern the delay does not use.
 *
 * There is also standing evidence AGAINST the latency story, in this very
 * file: moving four of nine rings into internal SRAM made the engine 94 cycles
 * WORSE. That test asked a different question and predates the FX-first
 * reordering, so it does not settle this -- but it is the reason the ring work
 * must not begin until the cost is located.
 *
 * WHAT THIS MEASURES. Core 1 does two things per block: the FX pass over the
 * PREVIOUS chunk (never blocked) and its own voice pass (throttled by core 0's
 * w_ready). Timing them separately answers the only question that matters
 * before any ring is touched: does the delay patches' extra cost land in the
 * FX pass at all, and how much of the FX pass is FREE -- i.e. inside the
 * window where core 1 would otherwise be waiting on core 0?
 *
 * COST: four CCOUNT reads per BLOCK, never per sample. Default ON; it is a
 * measurement, not a knob the audio path reads. */
#ifndef S3L_FXPROF
#define S3L_FXPROF 1
#endif
#if S3L_FXPROF
/* per-sample averages over the last reported second, published for rpt_task */
static volatile unsigned long rpt_fx_cyc = 0, rpt_v1_cyc = 0, rpt_wait_cyc = 0;
/* accumulators, written only by core 1 */
static unsigned long fxp_fx = 0, fxp_v1 = 0, fxp_wait = 0, fxp_n = 0;
static unsigned long fxp_wn = 0;   /* samples, for the per-sample wait mean */
#endif

static void worker(void *arg)
{
    int i;
    (void)arg;
    for (;;) {
        while (!w_go) { if (w_quit) vTaskDelete(NULL); }
        /* HOIST THE PUBLISHED POINTERS ONCE PER PASS. EB_RC/EB_MC are
         * `volatile`, and MEASURED on xtensa-esp-elf-gcc -O2 every volatile
         * access emits a MEMW before it -- one per sample per call site, and
         * MEMW drains the store buffer. Reading them once into plain locals is
         * CORRECT because they can only change inside the quiescent window and
         * a pass never overlaps the window: core 1 is parked at the spin
         * above for the whole of it. Write the reason down, or the hoist reads
         * as an unsafe optimisation. */
        const eb_render_coefs *rc = S3L_RC();
        const eb_master_coef  *mc = S3L_MC();
        (void)mc;
#if S3L_FX_PIPE
        {
        const int cur = w_cur, prev = 1 - w_cur, have = w_have_prev;
        /* ⚠ THE FX RUNS FIRST, AND THE ORDER IS THE WHOLE POINT.
         *
         * The first version of this worker did its voices and THEN the FX, and
         * the board measured 8,746 against a predicted 4,984. The reason is
         * not the FX's cost -- it is that core 1's VOICE pass cannot run any
         * faster than core 0 publishes prologues. `w_ready` is advanced once
         * per sample by core 0, which also carries two voices per sample, so
         * core 1's single voice waits at the top of every iteration and its
         * pass ENDS WHEN CORE 0'S ENDS. Only then did the FX start -- with
         * core 0 already spinning at the barrier. So the FX overlapped
         * nothing, and the loop was core0_pass + FX, which is a sum again.
         *
         * The FX depends ONLY on the previous chunk, which is complete before
         * this one begins. It is therefore the one piece of work on this core
         * that is never blocked. Running it FIRST fills exactly the window
         * where core 0 is busy and core 1 would otherwise be waiting on
         * w_ready; the voices then follow, still throttled by core 0, but now
         * throttled during time that was already going to be spent.
         *
         * MEASURED CAUSE, not a guess: the ring-placement test moved four of
         * nine rings into internal SRAM and the engine got 94 cycles WORSE,
         * which kills the memory-contention explanation and leaves this one. */
#if S3L_FXPROF
        {   unsigned long p0 = (unsigned long)esp_cpu_get_cycle_count(), pd;
#endif
        if (have) {
            for (i = 0; i < w_n; ++i) {
                float L = 0.0f, R = 0.0f;
#if S3L_LAYOUT
                /* A no-FX row still has to produce PCM, or the row measures a
                 * silent engine and sounds like a fault. The dry voice bus is
                 * what a real S3_NOFX build emits, and it is eight adds. */
                if (!g_fx) {
                    int k;
                    for (k = 0; k < EB_NUM_VOICES; ++k) L += w_vbb[prev][i][k];
                    R = L;
                } else
#endif
                eb_master_render(MS, mc, &RG, w_vbb[prev][i], &L, &R);
#if S3L_FXPROF && defined(S3L_FXPROF_TOOTH)
                /* THE RESPONSE TEST. A measurement nobody has seen move is a
                 * number, not a measurement. This burns S3L_FXPROF_TOOTH
                 * cycles per sample INSIDE the timed FX region and nowhere
                 * else, so `fx` must rise by exactly that and `v1` must not
                 * move. Default: not defined at all. */
                {   unsigned long tt = (unsigned long)esp_cpu_get_cycle_count();
                    while ((unsigned long)esp_cpu_get_cycle_count() - tt
                           < (unsigned long)S3L_FXPROF_TOOTH) { }
                }
#endif
                if (L > 1.0f) L = 1.0f; else if (L < -1.0f) L = -1.0f;
                if (R > 1.0f) R = 1.0f; else if (R < -1.0f) R = -1.0f;
                w_pcm[prev][2 * i]     = (int16_t)(L * 30000.0f);
                w_pcm[prev][2 * i + 1] = (int16_t)(R * 30000.0f);
            }
        }
#if S3L_FXPROF
        pd = (unsigned long)esp_cpu_get_cycle_count() - p0;
        if (have && w_n > 0) fxp_fx += pd / (unsigned long)w_n;
        p0 = (unsigned long)esp_cpu_get_cycle_count();
#endif
        for (i = 0; i < w_n; ++i) {
#if S3L_FXPROF
            /* ⚑ THE WAIT, MEASURED RATHER THAN ASSUMED. b5_fx_attribution.md
             * concluded "core 1 never waits" from cyc = fx + v1. That does not
             * follow: v1 INCLUDES this spin, so a v1 that is mostly waiting
             * looks identical in the sum. If part of v1 is wait, the load
             * balance pool is smaller than that document claims -- so the
             * claim must not be spent until this number exists.
             * COST: two CCOUNT reads per SAMPLE, not per block. That is the
             * one place in this file that pays per sample, and it is why
             * S3L_FXPROF is a measurement build rather than the default
             * shipping state. The reads land INSIDE v1, so v1 is inflated by
             * them and wait is not; neither is corrected, because a corrected
             * number nobody can re-derive is worse than a stated bias. */
            {   unsigned long ww = (unsigned long)esp_cpu_get_cycle_count();
                while (w_ready <= i) { }
                fxp_wait += (unsigned long)esp_cpu_get_cycle_count() - ww;
            }
#else
            while (w_ready <= i) { }        /* wait for this sample's prologue */
#endif
            eb_engine_render_range(&EBE, RS, rc, (const eb_render_needs *)0,
                                   SPLIT_, EB_NUM_VOICES, &w_shb[i],
                                   w_vbb[cur][i]);
        }
#if S3L_FXPROF
        pd = (unsigned long)esp_cpu_get_cycle_count() - p0;
        if (w_n > 0) { fxp_v1 += pd / (unsigned long)w_n;
                       fxp_wn += (unsigned long)w_n; ++fxp_n; }
        if (fxp_n >= 64) {          /* publish an average, then start afresh */
            rpt_fx_cyc   = fxp_fx / fxp_n;
            rpt_v1_cyc   = fxp_v1 / fxp_n;
            rpt_wait_cyc = fxp_wn ? fxp_wait / fxp_wn : 0ul;
            fxp_fx = fxp_v1 = fxp_wait = fxp_wn = 0; fxp_n = 0;
        }
        }
#endif
        }
#else
        for (i = 0; i < w_n; ++i) {
            while (w_ready <= i) { }        /* wait for this sample's prologue */
            eb_engine_render_range(&EBE, RS, rc, (const eb_render_needs *)0,
                                   SPLIT_, EB_NUM_VOICES, &w_shb[i],
                                   w_vbb[i]);
        }
#endif
        w_go = 0;
        w_done = 1;
    }
}

static void render_block(int n)
{
    int i, k;
    /* One volatile read per BLOCK, for the reason spelled out in worker().
     * It is taken here, before the window closes, so the whole block renders
     * from ONE coefficient bank -- a swap halfway through a block would put
     * two patches in one chunk. */
    const eb_render_coefs *rc = S3L_RC();
#if S3L_FX_PIPE
    /* Flip banks BEFORE releasing the worker, so the worker reads one stable
     * value of w_cur for its whole pass. Core 0 is the only writer. */
    float (*vb)[EB_NUM_VOICES];
    w_cur = 1 - w_cur;
    vb = w_vbb[w_cur];
#else
    float (*vb)[EB_NUM_VOICES] = w_vbb;
#endif
    /* Release core 1 FIRST; it blocks on w_ready until sample 0's prologue is
     * published, then runs one sample behind core 0's prologue rather than a
     * whole block behind it. */
    /* THE AT-REST VOICES, ONCE FOR THE WHOLE BLOCK (EB_ATREST_BLOCK).
     * A no-op unless that flag is set. Both ranges are advanced here on core
     * 0: an at-rest voice's free-run state is touched by nothing else in the
     * block, so there is no race with core 1, which skips those voices. */
#if !S3L_LAYOUT
    /* LATCH THE SPLIT FOR THIS BLOCK. Before this line core 1 is parked, so
     * this is the one instant at which the value can change without the two
     * cores disagreeing about who renders which voice -- which would render a
     * voice twice or not at all. Clamped, because the console writes it. */
    {   int s_ = g_split_rt;
        if (s_ < LO_)            s_ = LO_;
        if (s_ > EB_NUM_VOICES)  s_ = EB_NUM_VOICES;
        w_split = s_;
    }
#endif
    eb_engine_advance_atrest(&EBE, RS, rc, LO_, EB_NUM_VOICES, n);
    w_n    = n;
    w_ready = 0;
#if S3L_RECALL
    /* THE WINDOW CLOSES HERE, before the worker is released. One writer. */
    w_parked = 0;
#endif
    w_done = 0;
    w_go   = 1;
    /* THE RELEASE BARRIER IS THIS STORE, and it is already here.
     * MEASURED on xtensa-esp-elf-gcc -O2: `volatile` on the published POINTER
     * does NOT order the plain stores that filled the bank -- the compiler
     * sinks them PAST the pointer store. What does order them is `w_go`: it is
     * volatile, so GCC emits a MEMW immediately before this store, and a MEMW
     * orders every preceding store, plain or volatile. Core 1's `while (!w_go)`
     * emits the matching MEMW before each load. So the handshake this firmware
     * already had carries the release and the acquire, one MEMW on each side.
     * eb_recall.c's own __sync_synchronize() is then redundant here and is
     * kept because it makes that file correct in a single-core caller too.
     * THIS IS A PROPERTY OF THE COMPILER, NOT OF THE SOURCE: check it with
     *   xtensa-esp32s3-elf-objdump -d build/juno_s3.elf | grep -c memw */
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
    eb_engine_render_shared(&EBE, RS, rc, &w_shb[0]);
    for (i = 0; i < n; ++i) {
        for (k = LO_; k < EB_NUM_VOICES; ++k) vb[i][k] = 0.0f;
        w_ready = i + 1;                    /* prologue[i] is already done */
        eb_engine_render_range(&EBE, RS, rc, (const eb_render_needs *)0,
                               LO_, SPLIT_, &w_shb[i], vb[i]);
        if (i + 1 < n) {
            w_shb[i + 1].ready = 0;
            eb_engine_render_shared(&EBE, RS, rc, &w_shb[i + 1]);
        }
    }
#elif S3L_TIME_PROLOGUE
    /* MEASUREMENT BUILD ONLY. Core 0's 6,138 cycles are prologue + 2 voices,
     * and backing the voices out puts the prologue at 1,414 -- but that number
     * is a SUBTRACTION of two other numbers, and it silently contains the
     * at-rest advance and every per-voice loop cost for the five voices this
     * chord does not sound. Before anyone tries to move the prologue onto the
     * other core, its real size has to be its own measurement.
     *
     * So: run all n prologues in ONE timed batch, then the voices. This
     * DELIBERATELY SERIALISES the two -- core 1 is blocked until the batch
     * ends -- so the loop total this build prints is WORSE by construction and
     * must not be quoted. The only number it exists to produce is `prologue`.
     * The timer is read twice per BLOCK, not per sample, for the reason the
     * main loop already records: at two calls a sample it bills its own cost
     * to the thing it measures. */
    {   int64_t t0 = esp_timer_get_time();
        for (i = 0; i < n; ++i) {
            w_shb[i].ready = 0;
            eb_engine_render_shared(&EBE, RS, rc, &w_shb[i]);
        }
        prologue_us += (unsigned long)(esp_timer_get_time() - t0);
        prologue_n  += (unsigned long)n;
    }
    w_ready = n;                                  /* release core 1 in full */
    for (i = 0; i < n; ++i) {
        for (k = LO_; k < EB_NUM_VOICES; ++k) vb[i][k] = 0.0f;
        eb_engine_render_range(&EBE, RS, rc, (const eb_render_needs *)0,
                               LO_, SPLIT_, &w_shb[i], vb[i]);
    }
#else
    for (i = 0; i < n; ++i) {
        for (k = LO_; k < EB_NUM_VOICES; ++k) vb[i][k] = 0.0f;
        w_shb[i].ready = 0;
        eb_engine_render_shared(&EBE, RS, rc, &w_shb[i]);
        w_ready = i + 1;                          /* publish; core 1 may go */
        eb_engine_render_range(&EBE, RS, rc, (const eb_render_needs *)0,
                               LO_, SPLIT_, &w_shb[i], vb[i]);
    }
#endif
#if S3L_RECALL
    /* THE BURST GOES HERE, BEFORE THE SPIN, and the reason is scheduling and
     * not taste: this is the only point at which core 0 is neither rendering
     * nor holding the quiescent window open. If core 1 is the critical core
     * (M1 splits 1 voice on core 0 against 1 voice + the whole FX chain on
     * core 1) then core 0 WAITS at the barrier below and this time is free.
     * If core 0 is critical there is no free time here at all and the burst
     * lengthens the chunk it runs in.
     *
     * ⚠ NOBODY HAS MEASURED WHICH. The SLACK: line in the report prints the
     * spin, per chunk, from CCOUNT -- that is the burst's real budget, and it
     * is a measurement rather than the subtraction 5,410 - predicted_core0
     * that this project has already been told is not one. */
    /* O2: A PATCH CHANGE IS NOW A SEQUENCE OF BLOCKS, NOT ONE LUMP.
     *
     * A new request while a build is in flight RESTARTS it with the newer
     * patch -- latest wins, which is what a user spinning the patch knob
     * means -- and the restart is COUNTED (rule 4), because a knob turned
     * faster than 81 ms would otherwise silently never settle. */
    /* ⚠ AND IT WAITS FOR A NOTE BUILD TO FINISH. THE SHADOW HAS ONE OWNER.
     * The note branch below already refuses to start while a patch build is in
     * flight; the reverse was NOT true, so a program change arriving mid-note
     * opened a patch build over the note's half-finished shadow. It is worse
     * now that a note publishes twice: the burst's publish would also advance
     * the note machine past a hand-over that never happened.
     *
     * dev_want is NOT cleared here, so nothing is lost -- the patch change
     * lands a few blocks later, which is rule 3 and the same answer the note
     * path already gives a patch change. */
    if (dev_want && !dev_muted) {
        if (note_pending || !eb_nb_idle(&NB)) {
            ++nb_defer;     /* rule 4: counted, and dev_want is NOT cleared */
        } else {
            dev_burst_begin(dev_patch, dev_gate);
            dev_want = 0;
        }
    }
    /* ⚠ THE PATCH BURST IS NOT BUDGET-GATED, AND THE BOARD IS WHY.
     *
     * It was, for one build, on the reasoning that both machines are
     * incremental work and rule 2 covers both. MEASURED consequence
     * (b11): NOT ONE NOTE WAS EVER BUILT in a 280-second run, and 9,019
     * events were refused.
     *
     * The arithmetic: the burst's worst step measured 591,526 cycles against
     * 460,000 of slack, so it can NEVER fit -- the reseed and the bank apply
     * are single indivisible operations larger than any block's spare time.
     * Every step therefore deferred to the 64-block starve limit, so one
     * program change took ~384 blocks instead of 15. The robot requests
     * patches faster than that, so the build restarted 588 times and
     * `burst_state` was never IDLE -- and the note branch below only runs
     * when it is. The budget starved the exact path it was added to protect,
     * through an interlock rather than through its own deferrals.
     *
     * THE RULE THIS ENCODES: A BUDGET IS ONLY MEANINGFUL FOR WORK THAT CAN
     * BE MADE TO FIT. Deferring work that can never fit does not protect the
     * deadline -- the work still runs, later, in one lump -- it only delays
     * everything waiting behind it. The burst's own misses were 7 against the
     * note path's 23; it was never the problem. */
    if (burst_state != BST_IDLE && !dev_muted) {
        unsigned long sc0 = (unsigned long)esp_cpu_get_cycle_count();
        int st = dev_burst_step();
        /* still MEASURED, so the report can show why it is not gated */
        sched_note_cost(&g_step_cyc_burst,
                        (unsigned long)esp_cpu_get_cycle_count() - sc0);
        if (st < 0) {
            dev_muted = 1;
            printf("MUTE: %s. The audio is silenced deliberately -- a board "
                   "playing coefficients it cannot vouch for teaches nothing. "
                   "Rebuild with -DS3_RECALL_NOMUTE=1 to hear it anyway.\n",
                   dev_mute_why);
        } else if (st == 0) {
            dev_pending = 1;        /* the shadow is complete and checked */
        }
    }
    /* C4: a key press is a coefficient change and therefore the same burst,
     * in the same place, minus the reseed and the bank apply. `else if`
     * because a patch change already re-issues the chord -- running both in
     * one block would apply note events to coefficients that are about to be
     * replaced. */
    /* O1: TAKE EVENTS OFF THE QUEUE, HERE AND NOWHERE ELSE.
     *
     * Off the per-sample path and inside the same block-boundary section that
     * already owns the burst, so the events this drains are applied by the
     * burst below in the very same block. `else if` on the patch change for
     * the reason stated there: a program change re-issues the chord, and
     * applying note events to coefficients about to be replaced is wasted work
     * at best. Those events stay QUEUED and land next block -- late, not
     * lost, which is now true of the whole input path and not just this one
     * branch. */
    /* A NOTE MAY NOT LAND ON A HALF-BUILT SHADOW. The shadow has one owner at
     * a time, so notes wait while a patch build is in flight -- and because O1
     * queued them they wait rather than vanish. That composition is why O1 had
     * to come first. */
    else if (!dev_muted && burst_state == BST_IDLE) {
        /* O2: A NOTE IS NOW A SEQUENCE OF BLOCKS TOO. ev_apply only draws
         * from the queue when no note build is in flight, so the shadow keeps
         * exactly one owner; the events it does not take stay QUEUED and
         * arrive next block -- late, not lost. */
        if (!note_pending) ev_apply();
        /* THE PUBLISH STATES ARE NEVER BUDGETED. NB_PUB1/NB_PUB2 only ask for
         * a pointer swap and NB_CHECK only reads a counter; deferring those
         * would hold the key silent to save work that does not exist. Only the
         * states that BUILD are gated. */
        if (note_pending
            && (!eb_nb_heavy(&NB) || eb_sched_may(&SCHED, g_step_cyc_note))) {
            unsigned long sc0 = (unsigned long)esp_cpu_get_cycle_count();
            int st = dev_note_step();
            sched_note_cost(&g_step_cyc_note,
                            (unsigned long)esp_cpu_get_cycle_count() - sc0);
            if (st < 0) {
                dev_muted = 1;
                printf("MUTE: %s.\n", dev_mute_why);
            } else if (st == 0) {
                dev_pending = 1;   /* the publish below moves it into the audio */
            }
        }

        /* ================= O3: THE PARAMETER MACHINE =================
         *
         * ⚠ THE INTERLOCK IS NOW THREE-WAY. The shadow bank has ONE owner.
         * This branch already sits inside `burst_state == BST_IDLE`, so the
         * patch machine is excluded; the note machine must be excluded here.
         * A two-way check that grew a third machine is exactly how a build
         * gets opened over a shadow somebody else still owns.
         *
         * ⚠ AND THIS ONE IS BUDGET-GATED, where the patch burst is not. The
         * burst's worst step is 591,526 cycles against ~460,000 of slack and
         * can NEVER fit, so gating it starved the whole instrument (playbook
         * 63). This machine's worst step is the warm recall at ~0.24 M, which
         * FITS. Same rule, opposite answer, and the numbers are why. */
        if (eb_pm_idle(&PM)) {
            if (pm_want && !note_pending && eb_nb_idle(&NB)) {
                /* snapshot, then clear -- see the two-set note above */
                pm_v_run = pm_vmask; pm_t_run = pm_tail; pm_m_run = pm_master;
                pm_vmask = 0u;       pm_tail  = 0;       pm_master = 0;
                eb_pm_begin(&PM);
                pm_want = 0;
                ++pm_builds;
            } else if (pm_want) {
                ++pm_defer;   /* counted, and pm_want is NOT cleared */
            }
        }
        if (!eb_pm_idle(&PM)
            && (!eb_pm_heavy(&PM) || eb_sched_may(&SCHED, pm_cyc_max))) {
            int st = eb_pm_step(&PM, &PM_OPS, (void *)0);
            if (st < 0) {
                dev_muted = 1;
                printf("MUTE: %s.\n", dev_mute_why);
            } else if (st == 0) {
                dev_pending = 1;
            }
        }
    }
#endif
    {   /* CORE 0'S BARRIER SPIN, TIMED. Two CCOUNT reads per BLOCK, never per
         * sample -- at two a sample the clock bills its own cost to the thing
         * it measures (playbook 12). */
#if S3L_RECALL
        unsigned long s0 = (unsigned long)esp_cpu_get_cycle_count(), sd;
#endif
        while (!w_done) { }                       /* ONE barrier per block */
#if S3L_RECALL
        sd = (unsigned long)esp_cpu_get_cycle_count() - s0;
        if (sd < spin_min) spin_min = sd;
        if (sd > spin_max) spin_max = sd;
        /* ⚑ THE BUDGET'S MEASUREMENT. On a block that ran NO burst work this
         * spin is core 0's whole slack: the cycles it had spare while core 1
         * finished. That is exactly what a burst step must fit inside, on the
         * core it runs on, in the units it is measured in. Taking it from a
         * block that DID run a step would measure the slack after the step ate
         * it, and the scheduler would then starve itself. */
        if (!burst_ran_this_block && !note_ran_this_block) {
            g_quiet_spin = sd; eb_sched_slack(&SCHED, sd);
        }
#endif
    }
#if S3L_RECALL
    /* ================= THE QUIESCENT WINDOW =================
     * From here to `w_parked = 0` above (next block) core 1 is provably parked
     * at `while (!w_go)` in worker(): its last two acts were w_go = 0 and
     * w_done = 1, and the only code it runs afterwards is that spin. Nothing
     * it can observe changes until core 0 sets w_go. */
    w_parked = 1;
    /* the FX-pipe deferral, applied ONE BLOCK after the publish that set it:
     * the worker's next pass runs the master over the PREVIOUS chunk's voices,
     * so publishing MC immediately would put the new patch's delay/reverb/
     * chorus on voices rendered under the old one. */
    eb_recall_block_boundary(&REC);
    if (dev_pending && !dev_muted) {
        unsigned long q0 = (unsigned long)esp_cpu_get_cycle_count(), qd;
        if (eb_recall_publish(&REC) != 0) {
            ++dev_pub_refused;      /* the precondition refused: NOTHING moved */
        } else {
            ++dev_pubs;
            qd = (unsigned long)esp_cpu_get_cycle_count() - q0;
            p_last = qd;
            if (qd < p_min) p_min = qd;
            if (qd > p_max) p_max = qd;
            /* ⚑ THE NOTE MACHINE ADVANCES PAST A PUBLISH ONLY HERE, on the
             * success path. A refused publish leaves it in NB_PUB1/NB_PUB2,
             * where it asks again next block and opens no new build over the
             * shadow it has not yet handed over. See the enum's comment for
             * the stale voice this prevents. */
        }
        dev_pending = 0;
        /* ⚠ RELEASED ONLY WHEN THE NOTE MACHINE IS ACTUALLY IDLE. A note now
         * publishes TWICE -- once so the key sounds, once when the other
         * voices catch up -- and clearing this on the first would let the next
         * key's events be drawn on top of a half-owed build, which is the one
         * thing the shadow's single-owner rule forbids. The mid-note publish
         * leaves nbst non-idle, so the flag survives it. */
        /* ⚑ BOTH MACHINES ARE TOLD THE PUBLISH HAPPENED, AND ONLY HERE, ON
         * THE SUCCESS PATH. A refused publish leaves each of them asking
         * again next block while still owning its shadow. */
        eb_nb_published(&NB);
        if (burst_state == BST_PUB) burst_state = BST_IDLE;
        /* ⚑ AND THE PARAMETER MACHINE. eb_pm_published() is guarded on its own
         * PM_PUB state, so telling all three unconditionally cannot advance
         * one that did not ask -- which matters now that three machines share
         * one shadow and one publish per block. The guard is gated: param_gate
         * test 8 calls published() mid-build and requires nothing to move. */
        eb_pm_published(&PM);
        if (eb_nb_idle(&NB))
            note_pending = 0;   /* released here, so MIDI may queue the next */
    }
#endif
#if S3L_FX_PIPE
    /* From here on there IS a previous chunk, so the worker may run its FX
     * stage. Set only after the first barrier, never cleared. */
    w_have_prev = 1;
#endif
}
#else
/* The one-core build never had S3L_VOICE_LO defined -- its #ifndef lives in
 * the two-core section above -- so this branch referenced an undeclared
 * identifier and only ever compiled because nothing builds it. Give it the
 * default explicitly rather than leave the trap in place. */
#ifndef LO_
#define LO_ 0
#endif
static float w_vbb[CHUNK][EB_NUM_VOICES];
static void render_block(int n)
{
    int i, k;
    const eb_render_coefs *rc = S3L_RC();
    eb_engine_advance_atrest(&EBE, RS, rc, LO_, EB_NUM_VOICES, n);
    for (i = 0; i < n; ++i) {
        for (k = 0; k < EB_NUM_VOICES; ++k) w_vbb[i][k] = 0.0f;
        eb_engine_render_voices(&EBE, RS, rc, (const eb_render_needs *)0,
                                w_vbb[i]);
    }
}
#endif

/* ---- THE REPORTER, AND WHY IT IS A TASK -------------------------------------
 *
 * See the comment at the snapshot site: printf from the audio loop stalled the
 * loop for 66-117 ms, measured, twelve windows out of twelve. The loop now
 * writes these and nothing else; this task prints them. It runs at priority 1
 * on core 0, so the audio loop (which never yields except inside
 * i2s_channel_write) preempts it always and it can never hold the loop up.
 *
 * `volatile` and single-writer per field, the same discipline every other
 * cross-context datum in this file uses. A torn read costs one wrong digit in
 * a diagnostic; a lock would cost the thing this exists to avoid. */
#if S3L_USBMIDI
#include "tusb.h"
extern unsigned long usbmidi_pkts;
#endif

static volatile int           rpt_pending = 0;
static volatile unsigned long rpt_sec = 0, rpt_cyc = 0, rpt_under = 0;
static volatile unsigned long rpt_gap = 0, rpt_build = 0, rpt_nb = 0;
static volatile unsigned long rpt_midi = 0, rpt_drop = 0;
static volatile long          rpt_drift = 0;
/* ⚑ B4'S COUNTER. THE INVARIANT'S OWN VERDICT, AND IT DID NOT EXIST.
 *
 * FINAL_GUIDE requires "a hard block-overrun counter that must read 0".
 * `underrun` is NOT that counter and cannot be: it counts an I2S write
 * failure, which esp-idf returns only on ESP_ERR_TIMEOUT -- an EMPTY DMA
 * queue for 50 ms. A LATE block produces the OPPOSITE state (the queue
 * fills and the write returns ESP_OK), so the one counter this firmware
 * published was structurally blind to the thing B4 asks about.
 *
 * The DEADLINE PREDICATE already existed and was already correct; it just
 * had nowhere to put its answer. It called health_fail(), which latches
 * only the FIRST fault string and increments health_n -- a variable that
 * was never printed anywhere. So a missed deadline after the first one was
 * invisible, and the first one was only visible as a string.
 *
 * These two are CUMULATIVE and are never reset. A per-second maximum
 * (gap_max) answers "how bad was the worst block lately"; B4 asks "did a
 * block EVER miss", and only a counter that cannot be cleared answers it.
 *   ovr_late -- blocks that took more than ONE period. Expected to be
 *               non-zero: the writer blocks on a full queue by design, so
 *               a single period of jitter is normal. It is the early
 *               warning, not the verdict.
 *   ovr_miss -- blocks that took more than TWO periods. THIS IS THE B4
 *               NUMBER. The comment at the predicate explains why two:
 *               past two periods the DMA had to be carrying us, which is
 *               the invariant broken whatever it sounded like. */
static volatile unsigned long rpt_ovr_late = 0, rpt_ovr_miss = 0;
static volatile unsigned long rpt_blk_burst = 0, rpt_blk_quiet = 0,
                              rpt_blk_note = 0;
static volatile unsigned long rpt_dur_burst = 0, rpt_dur_quiet = 0,
                              rpt_dur_note = 0;
static volatile unsigned long rpt_miss_burst = 0, rpt_miss_quiet = 0;
static volatile unsigned long rpt_miss_note = 0;
static volatile unsigned long rpt_miss_step[BST_CHECK + 1];
static volatile unsigned long rpt_health_n = 0;

#if S3L_LINK
static void s3_la_report(void);
#endif

static void rpt_task(void *arg)
{
    (void)arg;
    for (;;) {
        if (!rpt_pending) { vTaskDelay(1); continue; }
        rpt_pending = 0;
        /* SHORT ON PURPOSE. The console is 115200 baud (the kconfig symbol
         * refused to hold 921600 and was left alone rather than fought). At
         * 8N1 that is 8.7 us per character, so a 130-character line needs
         * 11.3 ms of UART time and cannot leave inside ONE donated 10 ms
         * tick. Under 100 characters does. The budget constant and the words
         * are what got cut; every number is still here. */
        printf("HEALTH: %s%s\n",
               health_fault ? "*** " : "OK",
               health_fault ? health_fault : "");
        /* ovr=<late>/<miss> is B4's verdict and is CUMULATIVE. miss MUST read
         * 0; late is expected non-zero (one period of jitter is by design).
         * hn is health_n, which nothing printed before. */
        printf("B4: ovr=%lu/%lu hn=%lu\n",
               rpt_ovr_late, rpt_ovr_miss, rpt_health_n);
        /* burst= is O2's ACCEPTANCE NUMBER and must read 0: a block that ran a
         * burst step overran. quiet= belongs to O4 (delay patches over budget)
         * and to the open timer anomaly, and is printed beside it so the two
         * can never be confused for one another. */
        printf("B4: miss burst=%lu note=%lu quiet=%lu\n",
               rpt_miss_burst, rpt_miss_note, rpt_miss_quiet);
        /* ⚑ THE RATE, WHICH IS THE ACTUAL TEST. Misses per 10,000 blocks of
         * each class. O2's claim is that a note step fits the slack, so the
         * NOTE rate must not exceed the QUIET rate -- a note block missing as
         * often as an idle one means the note did not cause it, and what did
         * is the steady-state overrun on the delay patches (O4).
         * A bare count cannot say this: a note build spans ~10 blocks and
         * overlaps most misses by coincidence. */
        {   unsigned long bb = rpt_blk_burst ? rpt_blk_burst : 1;
            unsigned long bq = rpt_blk_quiet ? rpt_blk_quiet : 1;
            unsigned long bn = rpt_blk_note  ? rpt_blk_note  : 1;
            printf("B4rate: burst=%lu/10k note=%lu/10k quiet=%lu/10k  "
                   "(blocks %lu/%lu/%lu)  NOTE MUST NOT EXCEED QUIET\n",
                   10000ul * rpt_miss_burst / bb,
                   10000ul * rpt_miss_note  / bn,
                   10000ul * rpt_miss_quiet / bq,
                   rpt_blk_burst, rpt_blk_note, rpt_blk_quiet);
        }
        /* ⚑ THE MEASUREMENT THAT ACTUALLY DECIDES O2. Mean block duration by
         * class, in microseconds, over EVERY block rather than the ~20 that
         * missed. A note step is ~222,000 cycles and core 0's spin is
         * 420,000-880,000, so it should run inside time core 0 spends waiting
         * for core 1 and add NOTHING to the block. note ~ quiet proves that
         * from data; note > quiet by a visible margin refutes it. */
        printf("B4dur: note=%luus quiet=%luus burst=%luus  period=%luus  "
               "NOTE MINUS QUIET IS WHAT A NOTE STEP COSTS THE BLOCK\n",
               rpt_dur_note, rpt_dur_quiet, rpt_dur_burst,
               (unsigned long)(1000000ul * CHUNK / SR));
        /* WHICH STEP overran: reseed/install/recall/notes/coefs/check. b7
         * measured burst=17 with no attribution; this is the attribution. */
        printf("O2m: rs=%lu in=%lu rc=%lu nt=%lu cf=%lu ck=%lu\n",
               rpt_miss_step[BST_RESEED], rpt_miss_step[BST_INSTALL],
               rpt_miss_step[BST_RECALL], rpt_miss_step[BST_NOTES],
               rpt_miss_step[BST_COEFS],  rpt_miss_step[BST_CHECK]);
        /* O1: the boundary's own numbers. Rule 4 -- every refusal and every
         * deferral is COUNTED and reported; a system that copes quietly cannot
         * be proven to cope. `ref` MUST read 0: it is the only one of these
         * that is a fault. `dep`/`hi` are the queue's depth now and ever, and
         * a rising high-water mark is the early warning that the consumer is
         * falling behind. `par` counts parameter events accepted by the
         * boundary that O3 does not yet apply. */
        /* O2: the patch change's own numbers. `blk` is how many blocks the
         * last change took and `mx` the worst ever -- that IS the latency
         * rule 3 trades for continuity, so it is reported rather than
         * assumed. `rst` counts a request that arrived mid-build; non-zero
         * only means the knob moved faster than a change settles. */
        printf("O2: blk=%lu mx=%lu rst=%lu cyc=%lu pubretry=%lu\n",
               burst_blocks, burst_blocks_max, burst_restarts, b_last,
               burst_pub_retry);
        /* O2: the note burst, SPLIT. ev= the event apply, vb= the chunked
         * voice build, nv= how many voices the allocator named, st= steps
         * committed. The 1.06 M lump b8 measured is now these parts, so the
         * next question ("why 7.9x the plan?") is answered by reading rather
         * than by guessing. nv=8 on a two-note chord would be a DEFECT. */
        /* key= IS THE HEADLINE NUMBER OF THE SPLIT PUBLISH: blocks from the
         * event apply to the publish that makes the key audible. It read TEN
         * before the split (58 ms) and must read TWO (~12 ms). keymax= is the
         * worst any key press saw, because an average latency is not what a
         * player feels. nv= is still the WHOLE obligation, so key= being small
         * while nv= reads 8 is the design working, not a mask that shrank. */
        printf("NB: ev=%lu vb=%lu nv=%lu st=%lu tot=%lu key=%lu keymax=%lu "
               "defer=%lu pubretry=%lu\n",
               nb_ev, nb_vb, nb_nvoice, nb_steps, nb_last,
               nb_keyblk, nb_keyblk_max, nb_defer, (unsigned long)NB.pub_retry);
        /* THE DISTRIBUTION, because a max is one event and a player feels the
         * common case. Buckets 0 and 1 MUST be empty -- a key cannot sound
         * before the block that builds it. */
        {   int h; printf("KEYH:");
            for (h = 0; h < NB_KEYH; ++h) printf(" %d=%lu", h, nb_key_hist[h]);
            printf("   (blocks from key to sound; 2 is the design)\n");
        }
        /* THE BUDGET, SHOWN, so the rule can be read rather than inferred.
         * slack= is core 0's spare cycles on a burst-free block; step= is the
         * worst burst step measured. step <= slack is the whole rule.
         * forced= MUST stay 0: a forced step is the budget admitting it never
         * found room, which is O4's steady-state overrun and not O2's. */
        printf("SCHED: slack=%lu note=%lu burst=%lu cyc  defer=%lu forced=%lu\n",
               g_quiet_spin, g_step_cyc_note, g_step_cyc_burst,
               SCHED.n_defer, SCHED.n_forced);
        {   juno_event_stats es;
            juno_event_get_stats(&es);
            /* torn= is the only runtime witness to the publish barrier being
             * right (juno_event.h, JUNO_EVQ_BARRIER). Like ref=, it MUST
             * read 0; unlike ref= it can only be a concurrency fault. */
            printf("EVQ: sub=%lu ref=%lu del=%lu dep=%d hi=%lu par=%lu torn=%lu\n",
                   es.submitted, es.refused, es.delivered,
                   juno_event_depth(), es.depth_max, ev_param_unhandled,
                   es.torn);
        }
        /* O3. `edits` is knobs accepted, `builds` is rebuilds run -- the gap
         * between them IS the coalescing, and it is the number that says C9's
         * "as many parameters as you please, at the same time" is affordable.
         * `apply` is the warm recall's cost, the biggest single step this
         * machine takes and the one the budget is sized against.
         * `unknown` and `pubretry` MUST read 0: the first is a knob the class
         * table does not know, the second a build handed over twice. */
#if EB_MSPROF
        /* ================= O4: WHERE THE MASTER PASS SPENDS ITS TIME =======
         *
         * b16 predicts, BEFORE this ran: stage 1 (the DELAY dispatch) carries
         * ~1,500 cyc/sample more on patches 5, 16, 21 and 49 -- the bank's
         * only DELAY TYPE 5 patches -- than on the other sixty. If the excess
         * lands in stage 2 (reverb), or is spread across stages, b16 is WRONG
         * and the master-chain split across cores comes back onto the table.
         *
         * Printed beside `pat=` so each line is self-attributing. The counters
         * RESET every report, so a line describes ITS second and not the run.
         *
         * ⚠ DO NOT QUOTE THIS BUILD'S BLOCK TIMINGS. Six cycle-counter reads
         * per sample are inside the region being measured. The RATIO between
         * stages is what this build is for; `B4dur`, `cyc=` and `FXP:` from it
         * mean nothing. */
        {   unsigned long n = eb_msprof_n ? eb_msprof_n : 1ul;
            printf("MSP: in=%lu delay=%lu reverb=%lu out=%lu effect=%lu "
                   "cyc/sample  (n=%lu samples)\n",
                   (unsigned long)(eb_msprof[0] / n),
                   (unsigned long)(eb_msprof[1] / n),
                   (unsigned long)(eb_msprof[2] / n),
                   (unsigned long)(eb_msprof[3] / n),
                   (unsigned long)(eb_msprof[4] / n),
                   eb_msprof_n);
            /* ⚠ THE TOOTH. A stub clock steps by one per read, so a broken
             * profiler prints 1 for every stage -- which is what a 52-minute
             * run printed. A report that cannot tell that from a measurement
             * is worthless. This line SAYS SO, on the board, in the log. */
            {   int k, real = 0;
                for (k = 0; k < 5; k++) if (eb_msprof[k] / n > 1ul) real = 1;
                if (!real)
                    printf("MSP: *** BROKEN -- every stage reads <=1. The tick "
                           "is the stub counter, not the cycle counter. "
                           "IGNORE THIS RUN.\n");
            }
            /* ⚠ NO RESET HERE. The counters belong to the MSPP: window at the
             * patch boundary. Clearing them on the one-second report would
             * take samples out of the patch's own average and put the
             * misalignment back. This line is a PARTIAL running average of the
             * patch so far; MSPP: is the number to read. */
        }
#endif
#if S3L_LINK
        s3_link_report();
        s3_la_report();
#endif
        printf("PARAM: edits=%lu builds=%lu defer=%lu unknown=%lu "
               "pubretry=%u apply=%lu applymax=%lu blocks=%u\n",
               pm_edits, pm_builds, pm_defer, pm_unknown, PM.pub_retry,
               pm_cyc_apply, pm_cyc_max, PM.blocks);
#if S3L_FXPROF
        /* fx = core 1's master/FX pass, v1 = core 1's own voice pass
         * (INCLUDING the time it waits on core 0). Per sample, averaged over
         * 64 blocks. Compare fx across patch classes: if the delay patches'
         * extra cycles are not here, the rings are not the cause. */
        printf("FXP: fx=%lu v1=%lu wait=%lu per sample\n",
               rpt_fx_cyc, rpt_v1_cyc, rpt_wait_cyc);
#endif
        printf("t=%lu cyc=%lu drift=%+ld un=%lu gap=%lu bst=%lu nb=%lu "
               "midi=%lu/%lu usb=%lu/%d keys=%lu pat=%d\n",
               rpt_sec, rpt_cyc, rpt_drift, rpt_under, rpt_gap,
               rpt_build, rpt_nb, rpt_midi, rpt_drop,
#if S3L_USBMIDI
               /* usb=<packets>/<mounted>. MOUNTED means the host completed
                * enumeration. 0 packets with mounted 1 is a DAW routing
                * problem; mounted 0 is mine. */
               usbmidi_pkts, (int)tud_mounted()
#else
               0ul, 0
#endif
               , con_keys, dev_patch);
    }
}

#if S3L_LINK
/* O6 step 2: the audio link. Included HERE, after SR/CHUNK/EB_NUM_VOICES
 * exist -- it is plumbing over s3_link.h's host-gated decisions. */
#include "s3_link_audio.h"
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
    /* THE PREVIOUS SECOND'S wall clock and audio clock. The verdict below used
     * to compare TOTALS since t_start and LATCH `behind` forever on the first
     * comparison that failed. Two things were wrong with that. A latch cannot
     * recover, so one slow start-up second condemned a run that then held real
     * time for two minutes -- which is exactly what happened. And a total
     * hides the rate: a run 3 ms behind and holding reads the same as a run
     * losing 3 ms every second, and only the second one is a failure. These
     * two carry the previous second so the verdict can be PER SECOND, and the
     * drift is printed in ms so the direction is visible instead of inferred. */
    int64_t prev_real_us = 0, prev_audio_us = 0;
    double  drift_ms = 0.0;
    /* how long the last I2S write BLOCKED. A blocking write means the engine
     * is ahead of the codec, which is both the result we want and a yield the
     * scheduler already got. See the watchdog note in the loop. */
    unsigned long wrote_blocked_us = 0;
    int step = 0, gate = 0;
    unsigned long patch_frames = 0;
    /* ---- THE STALL BISECT AND THE GAP METER (2026-08-12) -----------------
     *
     * MEASURED and unexplained: underruns climb about 5/s while the engine's
     * own timed region sits UNDER budget, `nearest burst` reads 245 chunks on
     * most of them, and twice the drift jumped 3.5 s inside ONE five-second
     * window. No 5 % overrun produces that. SOMETHING BLOCKS FOR SECONDS and
     * four hypotheses in one session were wrong, so this build stops guessing.
     *
     * TWO INSTRUMENTS, and between them they leave nowhere for the cause to
     * hide:
     *
     * 1. THE GAP METER. The timed region measures render_block. It cannot see
     *    time spent ANYWHERE ELSE in the loop -- the PCM tail, the I2S write,
     *    printf, the burst, an interrupt. So this measures BLOCK START TO
     *    BLOCK START, which is the whole period by construction, and records
     *    the worst one with a TAG for what the loop had just done. Whatever
     *    the missing time is, it is inside this number and outside the other.
     *
     * 2. THE BISECT. Patch stepping alternates 30 s ON, 30 s OFF, and the
     *    underrun count is reported PER WINDOW. If the OFF windows are clean
     *    the burst is the cause and `nearest burst` is lying about it; if both
     *    windows leak the cause is in the steady state and the burst is
     *    exonerated. One flash answers a question four hypotheses could not. */
    unsigned long gap_max = 0, gap_tag = 0, gap_at = 0;
    /* CUMULATIVE by design -- never cleared in the per-second snapshot. */
    unsigned long ovr_late = 0, ovr_miss = 0;
    unsigned long ovr_miss_burst = 0, ovr_miss_quiet = 0, ovr_miss_note = 0;
    /* ⚠ A COUNT OF MISSES IS NOT AN ATTRIBUTION. A note build spans ~10
     * blocks, so it OVERLAPS most misses by coincidence -- and this board
     * misses in STEADY STATE on the delay patches (cyc 5,4xx-6,7xx against a
     * 5,442 budget, which is O4). `miss note=16` therefore cannot distinguish
     * "the note caused it" from "a miss happened while a note was in flight".
     *
     * THE RATE CAN. Count the BLOCKS in each class as well as the misses. If
     * note blocks miss at the same rate as quiet ones, the note path is not
     * the cause and O2's acceptance is met; if they miss at a higher rate, it
     * is, and the step is still too big for the block it landed on.
     *
     * The same trap was already written down for `burst` in this file and the
     * note counter was added without it. */
    unsigned long blk_burst = 0, blk_quiet = 0, blk_note = 0;
    /* ⚑ AND THE MEAN BLOCK DURATION PER CLASS -- THE SHARP INSTRUMENT.
     *
     * Counting rare misses cannot settle this. Two runs gave note=21 and
     * quiet=20 misses; at ~20 events the Poisson error is +-4.5 on each, so
     * 34/10k and 30/10k are indistinguishable NO MATTER HOW LONG THE RUN.
     *
     * Worse, the comparison is BIASED: note blocks cluster in the robot's
     * busy phases, where patches are being stepped and the delay arms are
     * live; quiet blocks include the silent baseline phase. The note class is
     * therefore drawn from a more expensive population for reasons that have
     * nothing to do with the note build.
     *
     * THE DIRECT QUESTION HAS THOUSANDS OF SAMPLES: does a block that ran a
     * note step take LONGER than one that did not? The note step is ~222,000
     * cycles and core 0's measured spin is 420,000-880,000, so the step
     * should fit inside time core 0 spends WAITING FOR CORE 1 and cost the
     * block nothing. If mean(note) ~ mean(quiet), that is confirmed directly,
     * from every block rather than from the tail. */
    unsigned long long dur_burst = 0, dur_quiet = 0, dur_note = 0;
    unsigned long miss_step[BST_CHECK + 1];
    memset((void *)miss_step, 0, sizeof miss_step);
    int64_t       t_prev_ok = 0;
    unsigned long w_underrun0 = 0, w_chunks0 = 0;
    int           w_step_on = !S3L_PLAY;   /* S3L_PLAY: no patch stepping */
    int64_t       t_prev_block = 0;
    unsigned long phase_tag = 0;   /* 1 write 2 report 3 burst 4 publish 5 tail */
    /* the DECODED underrun counters. The old single `underrun`
     * conflated an ESP_ERR_TIMEOUT with a short write, and a
     * counter nobody has decoded is the same class of defect as a
     * gate nobody has seen fail. */
    unsigned long i2s_timeout = 0, i2s_short = 0;
    unsigned long wb_min = 0xFFFFFFFFul, wb_max = 0, wb_zero = 0, wb_n = 0;
    long ur_gap_chunks = -1;

    /* the chord index for this build's voice count, clamped to what exists */
#if S3L_LAYOUT
    int CH = (S3L_VOICES < 1 ? 1 :
              S3L_VOICES > S3L_NNOTE ? S3L_NNOTE : S3L_VOICES) - 1;
    int lrow = 0;
#else
    const int CH = (S3L_VOICES < 1 ? 1 :
                    S3L_VOICES > S3L_NNOTE ? S3L_NNOTE : S3L_VOICES) - 1;
#endif
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
#elif S3L_RECALL
    /* the recall build sounds devchord.h's chord, on devchord.h's voices, and
     * the wake mask must be THAT and not the blob probe's -- they agree today
     * (both fill from voice 7 downward) and a silent disagreement would be a
     * chord of at-rest voices, i.e. an instrument that plays nothing. */
    unsigned WAKE = (unsigned)DEVCHORD_WAKE;
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
    /* HOW OFTEN THE PATCH STEPS. A program change every S3L_PATCH_SECS
     * seconds, wrapping over all 64. It is on a TIMER rather than at boot for
     * one reason: the transitions the publish contract exists for -- the delay
     * route latch, the reverb wipe, the DCO live copy -- have NEVER executed
     * anywhere in this project, and a boot-only recall would still never
     * execute them. */
#ifndef S3L_PATCH_SECS
#define S3L_PATCH_SECS 4
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

    /* ⚑ THE AUDIO LOOP MUST OUTRANK EVERY TASK IT SHARES A CORE WITH.
     *
     * MEASURED 2026-08-12: with printf moved to rpt_task the worst
     * block-to-block gap fell from 66-117 ms to a stubborn 16 ms, ONCE A
     * SECOND -- exactly the reporter's period. IDF starts app_main as
     * `main_task` at CONFIG_ESP_MAIN_TASK_PRIORITY, which is 1, and rpt_task
     * was created at 1 as well. FreeRTOS ROUND-ROBINS EQUAL PRIORITIES, so the
     * reporter's ~69 ms of UART could preempt the audio loop after all.
     *
     * Taking printf off the loop was necessary and not sufficient: it also has
     * to be unable to preempt. This is the same defect as the console one
     * wearing a different hat, and it is why the fix is a PRIORITY and not
     * another throttle. */
    vTaskPrioritySet(NULL, 5);

    printf("\n=== JUNO ENGINE B — S3 LISTEN FIRMWARE ===\n");
    printf("voices allowed: %d   sample rate: %d\n", S3L_VOICES, SR);
    printf("free internal %u  free PSRAM %u\n",
           (unsigned)heap_caps_get_free_size(MALLOC_CAP_INTERNAL),
           (unsigned)heap_caps_get_free_size(MALLOC_CAP_SPIRAM));

#if S3L_RECALL
    printf("BUILD: DEVICE RECALL. The coefficients are built ON THIS CHIP from\n"
           "       %d compact patch bytes and a %u B baked cell array. There is\n"
           "       no frozen blob in this image.\n",
           EB_PATCH_BYTES, (unsigned)sizeof(ebdev_state));
#else
    if (!blob_open()) { printf("HALT: no usable coefficient blob.\n"); return; }
#endif

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
#if S3L_LAYOUT
    /* BOTH placements, so `rsint` is a row field and not a rebuild. The voice
     * chain reads only the first S3L_VOICE_SZ bytes -- eb_render.c contains no
     * reference to st->chorus / st->delay / st->reverb, checked again rather
     * than inherited -- and the master keeps its own state in MS. So an
     * 8,488-byte internal buffer is a complete voice state. */
    RS_PSR = heap_caps_malloc(sizeof *RS, MALLOC_CAP_SPIRAM);
    RS_INT = heap_caps_malloc(S3L_VOICE_SZ + 64u, MALLOC_CAP_INTERNAL);
    RS = RS_PSR;
    if (!RS_PSR || !RS_INT) { printf("HALT: layout allocs failed.\n"); return; }
#elif S3L_NOFX
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
#if S3L_RECALL
    /* nothing to copy: the state is SEEDED from the recalled cells below */
#elif S3L_NOFX
    memcpy(RS, B_RSTATE, S3L_VOICE_SZ);      /* the prefix is all that exists */
#else
    memcpy(RS, B_RSTATE, S3L_RSTATE_SZ);
#endif
#if !S3L_NOFX && !S3L_RECALL
    ms_load(B_MSTATE);
    if (!rings_alloc()) { printf("HALT: rings.\n"); return; }
#elif S3L_NOFX
    printf("BUILD: VOICES ONLY -- master/FX chain not called, no rings.\n");
#endif

    eb_engine_init(&EBE, (float)SR);
    /* render_ok is the standalone engine's own guard. Setting it here is
     * legitimate for exactly the reason eb_render.h gives: the three gates it
     * names (null_b standalone, plugin_check, the teeth bracket) have all run
     * and all passed. It is not being switched on to make this build work. */
    EBE.render_ok = 1;
#if S3L_RECALL
    /* ============ THE FIRST RECALL, ON THE CHIP ==========================
     * Order matters and each step names why:
     *   the wake mask FIRST  -- eb_recall_publish's step 7c takes a different
     *                           path for an at-rest voice, and it reads it
     *                           from EBE
     *   the burst            -- fills the SHADOW bank
     *   rings                -- after the burst, so dev_check_rings() has run
     *                           against a real recalled patch
     *   the state seeds      -- CONTEXT START. This is the only place they run;
     *                           a patch change is not a context start, which is
     *                           exactly what the publish contract exists for
     *   publish              -- still on the default always-quiescent
     *                           predicate: core 1 does not exist yet */
    {   int k;
        for (k = 0; k < EB_NUM_VOICES; ++k)
            EBE.v[k].atrest = !((DEVCHORD_WAKE >> k) & 1u);
    }
    DEVBANK = heap_caps_malloc(EB_DEVSEQ_BANK_BYTES, MALLOC_CAP_SPIRAM);
    if (!DEVBANK) DEVBANK = heap_caps_malloc(EB_DEVSEQ_BANK_BYTES,
                                             MALLOC_CAP_INTERNAL);
    if (!DEVBANK) { printf("HALT: no room for the 20,246 B record buffer.\n"); return; }
    eb_recall_init(&REC, &RCB[0], &RCB[1], &MCB[0], &MCB[1], RS, MS, &EBE);
    eb_sched_init(&SCHED, SCHED_STARVE);
    eb_nb_init(&NB);
    /* ⚠ EXPLICIT, NOT BY STATIC ZERO-INIT. PM_IDLE happens to be 0, so a
     * static eb_pm would start idle by luck. This project does not ship state
     * that is correct by luck: an enum reordered later would silently boot the
     * machine mid-build, owning a shadow nobody built. */
    eb_pm_init(&PM);
#if S3L_LINK
    /* O6/D3: the strap decides the GLOBAL voice base BEFORE the first recall
     * deals the scatter. An unstrapped board reads chip A, base 0 -- today's
     * behaviour, byte-identical. */
    {   int r = s3_link_early();
        EB_DEVSEQ_VOICE_BASE = s3_role_config(r).voice_base;
        printf("LINK: strap read EARLY -> chip %c, GLOBAL voice base %d "
               "(before the boot recall, so the scatter is dealt right the "
               "first time)\n", 'A' + r, EB_DEVSEQ_VOICE_BASE);
    }
#endif
    if (dev_burst(dev_patch, 0)) {
        dev_muted = 1;
        printf("MUTE AT BOOT: %s. The engine is started anyway so the counters "
               "below still report, but the output is silenced.\n", dev_mute_why);
    }
    if (!rings_alloc()) { printf("HALT: rings.\n"); return; }
    eb_render_state_seed((const unsigned char *)0, RS);
    eb_master_state_seed((const unsigned char *)0, MS);
    eb_render_events_mirror((unsigned char *)0, RS);
    if (eb_recall_publish(&REC) != 0) {
        printf("MUTE AT BOOT: the publish precondition refused before core 1 "
               "exists, which should be impossible -- eb_recall_quiescent is "
               "still the default.\n");
        dev_muted = 1;
    }
    printf("RECALL: boot recall done, patch %d, gen %lu\n", dev_patch, REC.gen);
#if S3L_PLAY
    /* SILENCE AT POWER-ON. dev_burst() sounds the built-in chord so the CRC
     * can be compared against the host answer key, and that check is worth
     * keeping. An instrument must not then drone. So the chord is released
     * here, after the check, and the coefficients are rebuilt once. */
    eb_devseq_notes_off(DEVCHORD_VOICE, DEVCHORD_N);
    eb_recall_build(&REC);
    if (eb_recall_publish(&REC) != 0)
        printf("PLAY: the release publish refused -- the boot chord is held.\n");
    else
        printf("PLAY: boot chord released. The board is SILENT until you play "
               "a key. Patch stepping is OFF.\n");
#endif
#else
    load_coefs(CH, 0);
#endif

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
#if S3L_RECALL
    /* ONLY NOW. Until the worker exists there is nothing to be quiescent with
     * respect to, and pointing the predicate at w_parked (which is 0) before
     * the boot publish would have refused it. */
    eb_recall_quiescent = listen_quiescent;
#endif
    printf("TWO CORES: voices 0..%d on core 0, %d..%d on core 1\n",
           S3L_SPLIT - 1, S3L_SPLIT, EB_NUM_VOICES - 1);
#else
    printf("ONE CORE: all %d voices on core 0\n", EB_NUM_VOICES);
#endif
#if S3L_RECALL && S3L_MIDI
    if (!midi_start()) {
        printf("HALT: MIDI UART would not start on GPIO %d.\n", S3L_MIDI_RX);
        return;
    }
#if S3L_LINK
    if (!s3_link_start())
        printf("LINK: control UART would NOT start -- running single-board.\n");
    else
        s3_link_banner();
    if (!s3_la_start(LINK.role))
        printf("LINK: audio channel would NOT start -- control link only.\n");
    else
        printf("LINK: audio %s ready on BCLK %d LRCK %d DATA %d "
               "(mix stays CLOSED until the wire is CRC-proven)\n",
               LINK.role == S3_ROLE_A ? "master RX" : "slave TX",
               S3_LINK_BCLK, S3_LINK_LRCK, S3_LINK_DATA);
#endif
    printf("MIDI IN: UART1, 31250 baud, RX on GPIO %d.  velocity switch %s "
           "(%s)\n", S3L_MIDI_RX,
           S3L_MIDI_VELSW ? "ON" : "OFF",
           S3L_MIDI_VELSW ? "played velocity passes through"
                          : "every note forced to 100 -- the plugin's own default");
#if S3L_USBMIDI
    {   extern int s3_usbmidi_start(void);
        if (s3_usbmidi_start())
            printf("USB MIDI: started. Plug a USB-C cable into the board's OTHER\n"
                   "          socket -- the NATIVE one, not the console/flash one --\n"
                   "          and select \"JUNO-60 Engine B\" in your DAW.\n");
        else
            printf("USB MIDI: FAILED TO START. UART MIDI on GPIO 18 still works.\n");
    }
#endif
    if (con_start())
        printf("TYPE TO PLAY -- no parts needed, this console IS the keyboard:\n"
               "          a s d f g h j k  = C D E F G A B C   (white keys)\n"
               "            w e   t y u    = the black keys\n"
               "          z / x = octave down / up     SPACE = release all\n"
               "          b / n = previous / next patch  (all 64 factory patches;\n"
               "                  a program change costs the full burst, so a\n"
               "                  click there is expected and is measured)\n"
               "          , / . = move the CORE SPLIT.  '.' until core 1 has\n"
               "                  the FX alone is the load-balance test; watch\n"
               "                  FXP wait= and cyc on patches 5/16/21/49.\n"
               "          KEYS TOGGLE: a terminal never reports a key going UP,\n"
               "          so press once to sound a note and again to release it.\n"
               "          Hold a chord with a, d, g -- two voices are allowed.\n");
    else
        printf("TYPE TO PLAY: the console UART driver refused; typing does "
               "nothing.\n");
    printf("PLAY IT. Notes are allocated by eb_alloc (CAssignJu60's law, "
           "270/270 vs the plugin), applied through the port's own note path, "
           "and published at the next block boundary.\n");
#endif
    /* Priority 1 on core 0: the audio loop always wins. Started before I2S so
     * the very first second is reported. */
    /* Priority 2: above the idle task, BELOW the audio loop's 5, so it can
     * still never preempt audio -- it runs only in the donated tick. */
    xTaskCreatePinnedToCore(rpt_task, "eb_report", 3072, NULL, 2, NULL, 0);
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
#if S3L_LAYOUT
    printf("\n=== CHIP-LAYOUT SWEEP: %d rows, 8 s each, %d s per pass ===\n"
           "Row 1 is the CONTROL. It reproduces the shipping configuration\n"
           "(juno_s3_LFO.bin, whole loop 6,040). If it does not land near\n"
           "6,040 this harness is measuring something else and NO row on the\n"
           "page may be quoted.\n", S3L_NROW, S3L_NROW * 8);
    S3L_APPLY_ROW(0);
#endif
#if S3L_RECALL
    /* ============ WHAT IS IN FORCE, NOT WHAT WAS CONFIGURED ==============
     * Playbook 12: two separate defects on this project were diagnostics that
     * printed the opposite of the truth. Every number below is read from the
     * thing itself. */
    mem_probe();
    printf("\n=== DEVICE RECALL ===\n");
    printf("RECALL: cell array %u B  (tile %u + segments %u + scatter %dx%d)\n"
           "        NV=%d  segments=%d  scatter cells=%d\n",
           (unsigned)sizeof(ebdev_state), (unsigned)EBDEV_VTILE,
           (unsigned)EBDEV_SEGBYTES, EBDEV_NV, EBDEV_NSCAT,
           EBDEV_NV, (int)EBDEV_NSEG, (int)EBDEV_NSCAT);
    printf("RECALL: boot image %u B, baked at %d Hz  (THE IMAGE'S rate, not the "
           "rate this build configured, which is %d)\n",
           (unsigned)EBDEV_BOOT_BYTES, ebdev_boot_rate[0], SR);
    if (ebdev_boot_rate[0] != SR)
        printf("RECALL: *** THE BOOT IMAGE IS FOR A DIFFERENT SAMPLE RATE. "
               "516 of 30,156 bytes move between 44.1k and 48k -- this is a "
               "quiet detune across every FX block, not a crash. ***\n");
    printf("RECALL: banks 2 x %u rc + 2 x %u mc = %u B   patch %d B x %d = %u B "
           "in flash   template %u B\n",
           (unsigned)sizeof(eb_render_coefs), (unsigned)sizeof(eb_master_coef),
           (unsigned)(2 * sizeof(eb_render_coefs) + 2 * sizeof(eb_master_coef)),
           EB_PATCH_BYTES, DEVCRC_NPATCH,
           (unsigned)sizeof eb_bank64, (unsigned)sizeof eb_template);
    printf("RECALL: map chain-vs-table selftest: %ld disagreements (0 REQUIRED)\n",
           ebdev_selftest());
    printf("RECALL: placement rc0=%d rc1=%d mc0=%d mc1=%d cells=%d   "
           "(1 = INTERNAL. A 0 INVALIDATES THE SWAP ARGUMENT: it assumes the "
           "S3 does not serve internal SRAM through L1, so no cache "
           "maintenance is done anywhere.)\n",
           esp_ptr_internal(&RCB[0]), esp_ptr_internal(&RCB[1]),
           esp_ptr_internal(&MCB[0]), esp_ptr_internal(&MCB[1]),
           esp_ptr_internal(&EBDEV_S));
    printf("RECALL: free internal %u  largest internal block %u  free PSRAM %u\n",
           (unsigned)heap_caps_get_free_size(MALLOC_CAP_INTERNAL),
           (unsigned)heap_caps_get_largest_free_block(MALLOC_CAP_INTERNAL),
           (unsigned)heap_caps_get_free_size(MALLOC_CAP_SPIRAM));
    printf("RECALL: chord %d voice(s), wake 0x%02x, notes", DEVCHORD_N,
           (unsigned)DEVCHORD_WAKE);
    {   int k; for (k = 0; k < DEVCHORD_N; ++k)
            printf(" %d->v%d", DEVCHORD_NOTE[k], DEVCHORD_VOICE[k]); }
    printf("  (CHOSEN voices, NOT an allocator -- that is C4)\n");
    printf("RECALL: boot build %lu cycles, publish %lu cycles  "
           "(the FIRST Xtensa numbers for recall that exist)\n", b_last, p_last);
    printf("RECALL: burst rest: reseed %lu, install %lu, port recall %lu, "
           "notes %lu cyc  (these four are the 40 %% that is NOT coefficients)\n",
           devp_reseed, devp_install, devp_recall, devp_notes);
    printf("RECALL: burst split: voice coefs %lu cyc, master coefs %lu cyc "
           "(0/0 = profiling off).  MEASURED, not attributed -- the ~90,000 in "
           "eb_recall.h and the res-LUT attribution were both wrong.\n",
           eb_recall_t_rc, eb_recall_t_mc);
    printf("RECALL: CRC vs host answer key: %lu checked, %lu bad -- %s\n",
           crc_checked, crc_bad,
           crc_bad ? "*** THE CHIP DISAGREES WITH THE HOST. NO CYCLE FIGURE "
                     "FROM THIS RUN MAY BE QUOTED. ***"
                   : (crc_checked ? "MATCH -- device recall reproduces the "
                                    "host build bit for bit"
                                  : "NOT CHECKED (the boot build failed first)"));
    printf("RECALL: patch STEPS every %d s through all %d patches, so a program "
           "change is exercised in the field and not only at boot\n",
           S3L_PATCH_SECS, DEVCRC_NPATCH);
    if (dev_muted)
        printf("RECALL: *** MUTED: %s ***\n", dev_mute_why);
    printf("\n");
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
        if (t_prev_block) {
            unsigned long g = (unsigned long)(t0 - t_prev_block);
            if (g > gap_max) {
                gap_max = g; gap_tag = phase_tag;
                gap_at  = (unsigned long)(t0 - t_start) / 1000ul;
            }
        }
        t_prev_block = t0;
        phase_tag = 5;
        /* THE DEADLINE. One block must be produced every CHUNK/SR seconds. A
         * gap longer than TWO block periods means a block was late enough that
         * the DMA had to be carrying us, which is the definition of the
         * invariant being broken -- whatever it sounded like. Two rather than
         * one because the writer blocks on a full queue by design, which makes
         * a single period of jitter normal and expected. */
#if S3L_B4_TOOTH
        /* ⚑ THE TOOTH. A counter that has never fired is not evidence of
         * health; it is an untested detector (FINAL_GUIDE: "EVERY DETECTOR
         * MUST HAVE BEEN SEEN TO FIRE", and END_GOAL: "the gate must be able
         * to fail"). This burns past two block periods on one block in every
         * S3L_B4_TOOTH, so ovr_miss MUST become non-zero and HEALTH MUST go
         * red. A B4 run whose tooth build reads ovr=.../0 has proved nothing
         * about the build that follows it.
         *
         * It BUSY-WAITS rather than vTaskDelay: the point is to occupy the
         * core the way a real overrun does, not to yield it. */
        {
            static unsigned long tooth_n = 0;
            if (++tooth_n % (unsigned long)S3L_B4_TOOTH == 0) {
                int64_t until = t0 + (int64_t)(3ul * (1000000ul * CHUNK / SR));
                while (esp_timer_get_time() < until) { }
            }
        }
#endif
        /* ⚑ THE SAME TOOTH, ON DEMAND, ALWAYS COMPILED IN.
         *
         * S3L_B4_TOOTH above fires every N blocks, which proves the detector
         * works and RUINS the measurement it is compiled into -- miss can no
         * longer be read as "the instrument missed a deadline". So a
         * MEASUREMENT build has to leave it off, and then that build's own
         * overrun detector has never been seen to fire.
         *
         * That is a false choice. `t` on the console stalls ONE block, once,
         * when the operator asks. Press it at the END of a run: the numbers
         * up to that point are uncontaminated, and the red that follows proves
         * the detector was live the whole time. Every detector seen to fire,
         * without paying for it in the data. */
        if (tooth_once) {
            int64_t until = t0 + (int64_t)(3ul * (1000000ul * CHUNK / SR));
            tooth_once = 0;
            printf("TOOTH: stalling ONE block on purpose. B4 ovr= and miss= "
                   "MUST move and HEALTH MUST go red. If they do not, every "
                   "zero this run printed was an untested detector.\n");
            while (esp_timer_get_time() < until) { }
        }
        if (t_prev_ok) {
            unsigned long d      = (unsigned long)(t0 - t_prev_ok);
            if (burst_ran_this_block)     { ++blk_burst; dur_burst += d; }
            else if (note_ran_this_block) { ++blk_note;  dur_note  += d; }
            else                          { ++blk_quiet; dur_quiet += d; }
            unsigned long period = 1000000ul * CHUNK / SR;
            /* COUNT, do not merely latch. See rpt_ovr_* for why the counter
             * had to be added: health_fail keeps the FIRST string only, so
             * every later miss was invisible, and B4 needs the COUNT. */
            if (d > period)      ++ovr_late;
            if (d > 2ul * period) {
                ++ovr_miss;
                /* ⚑ O2's ACCEPTANCE TEST NEEDS THE CAUSE, NOT THE TOTAL.
                 *
                 * `miss` climbs for reasons O2 does not own and cannot fix:
                 * delay patches 5/16/21/49 overrun in STEADY STATE (6,526-6,821
                 * against 5,442 -- that is O4), and b4_first_run.md §5 records
                 * miss incrementing about once a second with the gap under
                 * threshold, an esp_timer-vs-I2S anomaly that is still open.
                 *
                 * So "miss must not increment across a program change" is not a
                 * test of O2. It would fail for O4's reasons and send the next
                 * session hunting the wrong cause -- which is exactly what the
                 * ring attribution cost this project once already today.
                 *
                 * THE TEST THAT IS O2's: did a block that RAN A BURST STEP miss
                 * its deadline? That is the claim -- a step fits in the slack --
                 * and it is isolated from both other causes. miss_burst MUST
                 * read 0. miss_quiet is O4's and the anomaly's, reported beside
                 * it so neither can be mistaken for the other. */
                if (burst_ran_this_block) {
                    ++ovr_miss_burst;
                    ++miss_step[burst_ran_this_block <= BST_CHECK
                                ? burst_ran_this_block : 0];
                } else if (note_ran_this_block) {
                    ++ovr_miss_note;
                } else ++ovr_miss_quiet;
                health_fail("a block missed its deadline");
            }
        }
        burst_ran_this_block = 0;
        note_ran_this_block = 0;
        t_prev_ok = t0;
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
#if S3L_RECALL && S3L_MIDI
            /* ONCE PER BLOCK, OUTSIDE the timed render. A UART read is a
             * memcpy out of the driver's ring; polling it per sample would
             * bill its cost to the engine, which is playbook 12's rule and
             * this project has broken it three times. */
            midi_poll();
            con_poll();
#if S3L_STRESS
            stress_step();          /* the robot keybed, same boundary */
#endif
#endif
            render_block(CHUNK);
            te += esp_timer_get_time() - e0;
        }
#if !S3L_FX_PIPE
        float (*vb_out)[EB_NUM_VOICES] = w_vbb;
#endif
        for (i = 0; i < CHUNK; ++i) {
#if S3L_FX_PIPE
            /* THE PCM IS ALREADY MADE. Core 1 produced it this chunk, from the
             * PREVIOUS chunk's voices. Core 0's tail keeps only the note gate,
             * which must stay per-sample because the hold and release lengths
             * are counted in frames. */
            (void)0;
#else
            float *vb = vb_out[i];
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
            /* NaN and Inf survive the clamps below -- a NaN compares false
             * against everything, so `if (L > 1.0f)` does NOT catch it and it
             * reaches the DAC as full-scale noise. It is checked BEFORE the
             * clamp and only against itself, which is the one test that catches
             * NaN without a library call. */
            if (!(L == L) || !(R == R)) {
                health_fail("a sample was NaN -- the DSP diverged");
                L = 0.0f; R = 0.0f;
            }
            if (L > 1.0f) L = 1.0f; else if (L < -1.0f) L = -1.0f;
            if (R > 1.0f) R = 1.0f; else if (R < -1.0f) R = -1.0f;
            pcm[2 * i]     = (int16_t)(L * 30000.0f);
            pcm[2 * i + 1] = (int16_t)(R * 30000.0f);
#endif

            /* One chord, held then released, repeating. `gate` 0 = held.
             *
             * THE TIMES ARE THE BLOB'S, NOT THIS FILE'S. Releasing copies the
             * OFF snapshot's voice state in (the gate lives in state -- with
             * coefficients alone the note does not release at all, measured),
             * so the hold length here MUST equal the one the snapshot was
             * captured at or the copy is a jump. It was: 1024 frames captured
             * against 1.5 s held, a 4,716-count step, audible as a pluck at
             * the end of every note. */
            /* S3L_PLAY: the keyboard owns the notes. The built-in chord loop
             * is a test feature and its gate change costs a full burst. */
            if (!S3L_PLAY &&
                ++frame >= (unsigned long)(gate ? S3L_REL_FRAMES : S3L_HOLD_FRAMES)) {
                frame = 0;
                gate = !gate;
#if S3L_RECALL
                /* *** THIS IS REQUIREMENT 1, IN ONE LINE. ***
                 * It used to be load_coefs(CH, gate): three memcpys totalling
                 * 28,980 bytes out of memory-mapped flash, executed HERE, in
                 * the per-sample tail, against 32 cycles of per-sample margin.
                 * Now it sets a flag and the burst happens on the other side
                 * of it, in render_block(), at most one CHUNK (5.8 ms) later.
                 *
                 * ⚠ AND IT IS NOT SOLD AS THE FIX FOR THE 105 UNDERRUNS. Read
                 * the I2S: line below: that counter conflates a 50 ms TIMEOUT
                 * with a short write, and esp-idf's i2s_common.c:1630 returns
                 * short ONLY on timeout -- which needs an EMPTY DMA queue for
                 * 50 ms, the opposite of what a LATE writer causes. The
                 * decoded counters below settle it in one run; until then this
                 * is a burst moved off the audio path, which is worth doing on
                 * its own terms. */
                dev_request(dev_patch, gate);
#else
                load_coefs(CH, gate);
#endif
            }
#if S3L_RECALL
            /* THE PROGRAM CHANGE. On a timer, aligned to a note boundary so
             * the patch changes while the chord is held -- which is where the
             * publish contract's transitions actually bite (a bisected
             * instrument is only audible if something is sounding). */
#if S3L_LINK
            /* O6/D2: CHIP A IS THE SOURCE OF TRUTH FOR THE PATCH. With a
             * valid peer, chip B never self-steps -- two free-running 4 s
             * steppers agree only by luck and the handshake would read
             * PATCH_DIFFERS nearly always, making the bench criterion
             * unreachable. The decision is a pure function, gated on the
             * host (d1_link_gate teeth 5-7) before this line existed. */
            if (w_step_on) {
                int fp = s3_follow_patch(LINK.role, LINK.peer.present,
                                         LINK.peer.role, dev_patch,
                                         LINK.peer.patch);
                if (fp >= 0) { patch_frames = 0; dev_request(fp, gate); }
            }
            if (w_step_on &&
                !s3_follow_holds_stepper(LINK.role, LINK.peer.present,
                                         LINK.peer.role) &&
                ++patch_frames >= (unsigned long)(S3L_PATCH_SECS * SR)) {
#else
            if (w_step_on &&
                ++patch_frames >= (unsigned long)(S3L_PATCH_SECS * SR)) {
#endif
                patch_frames = 0;
                dev_request((dev_patch + 1) % DEVCRC_NPATCH, gate);
            }
#endif
            (void)step;
        }
#if S3L_LINK
        /* O6/D2: one frame every ~100 ms and a drain of whatever arrived.
         * O(1), no allocation, and it runs on the BLOCK tail rather than the
         * sample tail -- the same rule the burst obeys (C3).
         *
         * ⚑ THE CRC SENT IS THE COMPILED-IN ANSWER KEY, NOT A LIVE CHECKSUM,
         * and that is the useful choice rather than the lazy one. A live CRC
         * over 18,788 bytes every block is unaffordable; and the chip ALREADY
         * verifies its live bank against this table on every recall (the
         * `CRC MISMATCH` path above mutes if they disagree). So sending the
         * table value transmits a number already proven equal to the
         * coefficients this chip is actually playing.
         *
         * What it then catches across the link is the failure that
         * one-image-flashed-twice invites and nothing else would see: THE TWO
         * BOARDS RUNNING DIFFERENT BUILDS. devcrc_rc/mc are generated per
         * build, so a stale image on one board changes this number and the
         * handshake says SAME PATCH, DIFFERENT COEFFICIENTS. */
        /* ⚠ THE WIRE FINGERPRINT IS THE BASE-0 KEY ON BOTH CHIPS -- see
         * s3_link.h. The per-base keys differ BY DESIGN, so advertising each
         * chip's own key (the previous revision did) reads CRC_DIFFERS on
         * every correct pair, forever. Each chip's PLAYING bank is proven
         * locally by the per-base RECALL CRC check; the wire only proves
         * same build + same patch. */
        s3_link_poll(dev_patch, devcrc_rc[dev_patch] ^ devcrc_mc[dev_patch],
                     LA.tx_crc, LA.tx_crc_blk);
        /* O6 step 2, on the same block tail. The chunk in w_vbb[w_cur] is
         * complete on both cores and untouched until the next flip, so this
         * is the one window where B may tap it and A may inject into it.
         * hs_ok gates everything; a lone board does nothing here. */
        {   int hs_ok = LINK.peer.present && LINK.hs == S3_HS_OK;
            if (LINK.role == S3_ROLE_A) {
                s3_la_rx_inject(w_vbb[w_cur], CHUNK, hs_ok,
                                LINK.peer_acrc, LINK.acrc_fresh);
                LINK.acrc_fresh = 0;
            } else {
                s3_la_tx(w_vbb[w_cur], CHUNK, hs_ok);
            }
        }
#endif
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
            int64_t tw = esp_timer_get_time();
            phase_tag = 1;
#if S3L_FX_PIPE
            /* Bank 1-w_cur is the chunk core 1 just finished the FX for.
             * Before the first flip it is all zeros -- one chunk of silence
             * while the pipeline fills, 2.9 ms, once. */
            const int16_t *out = w_pcm[1 - w_cur];
            const size_t   nby = sizeof w_pcm[0];
#else
            const int16_t *out = pcm;
            const size_t   nby = sizeof pcm;
#endif
            esp_err_t we;
#if S3L_RECALL
            /* THE MUTE. A named failure fired, so the board says what and
             * plays silence rather than coefficients it cannot vouch for.
             * -DS3_RECALL_NOMUTE=1 plays it anyway, on purpose: hearing a
             * wrong recall is sometimes the fastest diagnosis there is. */
#ifndef S3L_RECALL_NOMUTE
            if (dev_muted) memset((void *)out, 0, nby);
#endif
            ++chunks_since_burst;
#endif
            /* ⚠ A SHORT WRITE USED TO DROP THE REST OF THE BLOCK.
             *
             * MEASURED 2026-08-12, with the test loop finally out of the way:
             * every `cyc` is under the 5,442 budget and the block-to-block gap
             * is a clean 5,700 us, yet underruns climbed about 7 per second and
             * the drift went NEGATIVE and grew. Negative drift means the loop
             * counted MORE audio than wall-clock time -- which cannot happen by
             * computing faster. It happens by counting a block as delivered
             * when part of it was thrown away.
             *
             * The writer produces a block every 5,700 us; the DAC consumes one
             * every 5,804 us. The writer is ahead, so the DMA queue fills, the
             * 50 ms write returns SHORT, and the remainder was silently
             * discarded -- a hole in the audio and a click, once per full
             * queue.
             *
             * The remainder is now WRITTEN, not dropped, and the wait is
             * unbounded. A blocking write is the correct way to be ahead: it
             * parks the loop until the DAC has room, which locks the engine to
             * the DAC's own clock instead of free-running against it. An
             * underrun is now only a real timeout. */
            {   const unsigned char *wp = (const unsigned char *)out;
                size_t left = nby, n = 0;
                we = ESP_OK;
                wrote = 0;
                while (left) {
                    /* O6 step 2: when chip B is LINKED, A's clock paces the
                     * loop through the slave-TX write, and this DAC write (to
                     * unconnected pins on B) must NOT also block -- two
                     * pacemakers on two crystals is the drift D1 forbids. */
                    we = i2s_channel_write(TX, wp, left, &n,
#if S3L_LINK
                                           (LA.up && LA.role == S3_ROLE_B &&
                                            LA.pace == S3_BPACE_LINKED)
                                               ? 0 :
#endif
                                           portMAX_DELAY);
                    if (we != ESP_OK) break;
                    if (n == 0) break;      /* no progress: do not spin */
                    wp += n; left -= n; wrote += n;
                }
            }
            /* DECODE THE COUNTER BEFORE TRYING TO FIX WHAT IT COUNTS.
             * esp-idf components/esp_driver_i2s/i2s_common.c:1630-1633 returns
             * a SHORT write only on ESP_ERR_TIMEOUT -- i.e. the TX message
             * queue stayed empty for the full 50 ms, which means the DMA
             * posted no end-of-frame for ~8.6 buffer periods. A LATE writer
             * causes the OPPOSITE state (the queue fills, the write still
             * returns ESP_OK with wrote == nby). So the two are different
             * faults and were being added together. */
            if (we != ESP_OK) { ++i2s_timeout; health_fail("I2S write timed out -- the DAC ran dry"); }
            if (wrote != nby)  ++i2s_short;
            if (we != ESP_OK || wrote != nby) {
                ++underrun;
#if S3L_RECALL
                /* THE CORRELATION TEST, in one field: how many chunks since
                 * the last recall burst. If the burst is the cause this
                 * clusters at 0-2; if it is scattered, it is not. */
                ur_gap_chunks = (long)chunks_since_burst;
#endif
            }
            wrote_blocked_us = (unsigned long)(esp_timer_get_time() - tw);
            /* THE CUSHION METER, and it costs nothing -- this number was
             * already being computed and thrown away. A BLOCKING write means
             * the writer still holds its ~29 ms lead over the DMA; a
             * ZERO-length block means the queue had a spare entry, i.e. the
             * lead has been lost. */
            ++wb_n;
            if (wrote_blocked_us < wb_min) wb_min = wrote_blocked_us;
            if (wrote_blocked_us > wb_max) wb_max = wrote_blocked_us;
            if (wrote_blocked_us == 0) ++wb_zero;
        }

        /* THE WATCHDOG FEED WAS THE MEASUREMENT (found 2026-08-11).
         *
         * This used to be an unconditional `vTaskDelay(1)` every CHUNK. One
         * FreeRTOS tick is 10 ms at the default 100 Hz, and a CHUNK of 128
         * frames is 2.90 ms of audio. So the loop spent 10 ms of wall clock
         * sleeping for every 2.90 ms of audio it produced, and the wall-clock
         * verdict measured THAT -- the board reported a drift climbing about
         * 2,450 ms per second while the engine's own counter said 22.40 us
         * against a 22.68 us budget. The delay, not the engine, was the
         * deficit. A harness that sleeps 3x the sample period cannot answer
         * whether the sample period is met.
         *
         * The delay exists because when the engine runs BEHIND, i2s_channel_
         * write never blocks -- there is always free DMA space -- so the loop
         * spins and starves IDLE0. But when the engine runs AHEAD, which is
         * the case we are trying to prove, that write DOES block, and a
         * blocking queue wait yields to IDLE by itself. So the delay is only
         * needed in the failing case, and it is exactly the failing case that
         * it was corrupting.
         *
         * ⚠ THE CONDITIONAL FORM OF THAT FIX DID NOT WORK, and the board said
         * so immediately: the drift stayed at +2,451.5 ms/s, identical to the
         * decimal. The behind-state SUSTAINS ITSELF, so the condition can
         * never fire:
         *
         *     behind ---> DMA always empty ---> the write never blocks
         *        ^                                        |
         *        +--------- so we sleep 10 ms <-----------+
         *
         * The sleep is the only reason we are behind, and being behind is the
         * only reason the sleep keeps firing. There is no path out from inside
         * the loop, so NO CONDITION ON THE LOOP CAN BE THE FIX.
         *
         * THE FIX IS TO STOP SLEEPING AT ALL. A real-time audio loop is
         * SUPPOSED to saturate its core; it is not misbehaving when it starves
         * IDLE. The idle-task watchdog is therefore off for this firmware
         * (sdkconfig.defaults), and the loop now blocks only where it should
         * -- inside i2s_channel_write, waiting for DMA space. That is a proper
         * blocking wait and yields by itself the moment the engine is ahead,
         * which is exactly the state we are trying to detect. */
        (void)wrote_blocked_us;
        if (++chunks % (SR / CHUNK) == 0) {
            /* ⚑⚑ THE AUDIO LOOP MAY NOT CALL printf. NOT THROTTLED -- AT ALL.
             *
             * MEASURED 2026-08-12 by this build's own gap meter: the worst
             * block-to-block gap was 66,000-117,000 us and the tag was
             * `printf` on TWELVE windows out of twelve, against a 5,804 us
             * block period. Seven report lines is about 800 characters; at
             * 115,200 baud that is 69 ms of blocking, and it matches the
             * measured gap exactly.
             *
             * That is playbook defect 30 FOR THE FOURTH TIME. The catalogue
             * already named the console, and S3L_REPORT_EVERY was already
             * added to throttle it -- then four more lines were added while
             * hunting a stall, and re-created the defect at three times the
             * size. Every hypothesis chased afterwards was chasing this.
             *
             * A throttle makes it rarer. Rare is what let it survive. So the
             * loop now only SNAPSHOTS, and rpt_task() -- a separate task, low
             * priority, on core 0 -- does the printing. It cannot block the
             * audio path because it is not on it. */
            {   unsigned long sec = chunks / (SR / CHUNK);
                static unsigned long p_busy = 0, p_ch = 0;
                unsigned long d_busy = busy_us - p_busy;
                unsigned long d_ch   = (chunks - p_ch) * CHUNK;
                int64_t real_us  = esp_timer_get_time() - t_start;
                int64_t audio_us = (int64_t)((double)(chunks * CHUNK)
                                             * 1e6 / (double)SR);
                p_busy = busy_us; p_ch = chunks;
                rpt_sec   = sec;
                rpt_cyc   = d_ch ? (unsigned long)((double)d_busy
                                                   / (double)d_ch * 240.0) : 0;
                rpt_under = underrun;
                rpt_gap   = gap_max;
                rpt_drift = (long)((real_us - audio_us) / 1000);
                /* NOT reset below with gap_max: B4's question is "did a block
                 * EVER miss", so these accumulate for the life of the run. */
                rpt_ovr_late  = ovr_late;
                rpt_miss_burst = ovr_miss_burst;
                rpt_miss_quiet = ovr_miss_quiet;
                rpt_miss_note  = ovr_miss_note;
                rpt_blk_burst = blk_burst; rpt_blk_quiet = blk_quiet;
                rpt_blk_note  = blk_note;
                rpt_dur_burst = blk_burst ? (unsigned long)(dur_burst / blk_burst) : 0;
                rpt_dur_quiet = blk_quiet ? (unsigned long)(dur_quiet / blk_quiet) : 0;
                rpt_dur_note  = blk_note  ? (unsigned long)(dur_note  / blk_note)  : 0;
                memcpy((void *)rpt_miss_step, (const void *)miss_step,
                       sizeof miss_step);
                /* rule 4 latches that should always have existed: a refused
                 * submit and a torn publish are FAULTS, not statistics. */
                {   juno_event_stats hs;
                    juno_event_get_stats(&hs);
                    if (hs.refused) health_fail("the event queue REFUSED a submit");
                    if (hs.torn)    health_fail("a TORN publish reached the drain");
                }
                rpt_ovr_miss  = ovr_miss;
                rpt_health_n  = health_n;
#if S3L_RECALL
                rpt_build = b_last;
                rpt_nb    = nb_last;
                rpt_midi  = notes_seen;
                rpt_drop  = notes_dropped;
#endif
                gap_max = 0;
            }
            rpt_pending = 1;
            /* ⚠ A LOWER-PRIORITY TASK ON A SATURATED CORE NEVER RUNS.
             * MEASURED (PRIO build): with the audio loop raised to priority 5,
             * rpt_task at priority 1 printed NOTHING -- not one line after the
             * banner. Moving the printf off the audio path is necessary and is
             * not sufficient: the loop is over budget, so it never blocks long
             * enough in i2s_channel_write for a priority-1 task to be picked.
             *
             * So the loop DONATES one tick, once per second, at the exact
             * moment the reporter has something to say. The DMA holds
             * dma_desc_num(6) x CHUNK(256) = 34.8 ms of audio, so a 10 ms
             * donation cannot empty it. This is the ONLY place the audio loop
             * yields on purpose, and it is once per second. */
            vTaskDelay(1);
            /* The donation is not a stall. Re-anchor the gap meter so it does
             * not report its own yield as a 10 ms worst gap once a second. */
            t_prev_block = esp_timer_get_time();
        }
        if (0) {
            /* ⚠ THE CONSOLE IS PART OF THE MEASUREMENT, and at 115200 baud it
             * is not a small part. The two lines below run about 235
             * characters; at 8N1 that is 2,350 bits, or 20.4 ms of UART time
             * EVERY SECOND -- 2.0 % of the wall clock, against a measured
             * remaining deficit of 1.16 %. printf blocks once the driver's
             * buffer fills, and it sits INSIDE the wall-clock test that
             * decides pass or fail.
             *
             * So the report is throttled to one second in S3L_REPORT_EVERY.
             * The measurement still accumulates every second; only the
             * printing is rarer, which divides the UART cost by the same
             * factor without touching what is measured.
             *
             * This is the third time tonight the instrument turned out to be
             * the thing being measured -- after the latched verdict and the
             * watchdog sleep. Whenever the last few percent will not close,
             * price the harness before pricing the engine. */
            /* cycles/sample, from the real render loop rather than a model */
            double us_per_sample = (double)busy_us / (double)(chunks * CHUNK);
            /* THE WALL-CLOCK TEST, which is the one that decides. Measured
             * over the LAST SECOND only, so the verdict tracks the engine
             * instead of remembering the start-up. */
            {   int64_t real_us  = esp_timer_get_time() - t_start;
                int64_t audio_us = (int64_t)((double)(chunks * CHUNK)
                                             * 1e6 / (double)SR);
                int64_t d_real  = real_us  - prev_real_us;
                int64_t d_audio = audio_us - prev_audio_us;
                behind = (d_real > (int64_t)((double)d_audio * 1.02));
                /* CUMULATIVE drift, signed: positive means the wall clock has
                 * run ahead of the audio, i.e. the engine owes time. A healthy
                 * run holds this flat; a failing one climbs without limit. */
                drift_ms = (double)(real_us - audio_us) / 1000.0;
                prev_real_us = real_us; prev_audio_us = audio_us;
            }
            {   double n = (double)(ph_chunks * CHUNK);
                double e = (double)eng_us / n, w = (double)busy_us / n;
                /* PRINT THE MASK THAT IS ACTUALLY IN FORCE. This printed
                 * SWEEP[phase] even when the sweep was not driving WAKE, so
                 * it read "wake=0x00" while six voices were rendering -- a
                 * diagnostic that says the opposite of the truth. */
                if ((chunks / (SR / CHUNK)) % S3L_REPORT_EVERY == 0)
            printf("wake=0x%02x  engine %.2f us (%.0f cyc)  "
                       "whole loop %.2f us (%.0f cyc)  overhead %.0f cyc\n",
                       WAKE, e, e * 240.0, w, w * 240.0,
                       (w - e) * 240.0);
                if (chunks / (SR / CHUNK) % 8 == 0) {
#if S3L_LAYOUT
                    /* THE ROW'S RESULT, printed from the window that just
                     * ended, THEN the next row. The whole-loop figure is the
                     * one that decides: it contains the barrier, the PCM
                     * conversion and the I2S call, and the codec charges for
                     * all three. */
                    {   double cyc = w * 240.0, d = cyc - 5442.0;
                        printf("    RESULT  engine %.0f   WHOLE LOOP %.0f   "
                               "budget 5442   %s by %.0f   (predicted %d, "
                               "err %+.0f)\n",
                               e * 240.0, cyc,
                               d <= 0.0 ? "FITS, under" : "OVER",
                               d <= 0.0 ? -d : d, S3L_ROW[lrow].pred,
                               cyc - (double)S3L_ROW[lrow].pred);
                    }
                    lrow = (lrow + 1) % S3L_NROW;
                    S3L_APPLY_ROW(lrow);
#endif
                    phase = (phase + 1) % 7;
                    eng_us = busy_us = ph_chunks = 0;
                }
            }
#if S3L_TIME_PROLOGUE
            if (prologue_n)
                printf("PROLOGUE %.2f us/sample (~%.0f cycles) "
                       "-- loop total in THIS build is serialised and must not "
                       "be quoted\n",
                       (double)prologue_us / (double)prologue_n,
                       (double)prologue_us / (double)prologue_n * 240.0);
#endif
#if S3L_RECALL
            if ((chunks / (SR / CHUNK)) % S3L_REPORT_EVERY == 0)
                printf("NOTES: midi=%lu dropped=%lu bursts=%lu  "
                       "note-burst cyc %lu/%lu/%lu (min/max/last)\n",
                       notes_seen, notes_dropped, note_bursts,
                       nb_min == 0xFFFFFFFFul ? 0ul : nb_min, nb_max, nb_last);
#endif
            {   /* THE BISECT WINDOW. 30 s of patch stepping, then 30 s of
                 * none, forever. The underrun count is per window, so the two
                 * are directly comparable and neither is a subtraction. */
                unsigned long sec = chunks / (SR / CHUNK);
                if (sec && sec % 30 == 0 && chunks % (SR / CHUNK) == 0) {
                    static const char *TAG[6] = { "?", "i2s write", "printf",
                                                  "burst", "publish", "tail" };
                    unsigned long uw = underrun - w_underrun0;
                    unsigned long cw = chunks - w_chunks0;
                    printf("\n*** BISECT WINDOW %s: %lu underruns in %lu "
                           "chunks (%.2f %%)   worst block-to-block gap "
                           "%lu us at t=%lu ms, right after: %s   "
                           "[budget %lu us]\n",
                           w_step_on ? "PATCH STEPPING ON " : "PATCH STEPPING OFF",
                           uw, cw, cw ? 100.0 * (double)uw / (double)cw : 0.0,
                           gap_max, gap_at, TAG[gap_tag > 5 ? 0 : gap_tag],
                           (unsigned long)(1000000ull * CHUNK / SR));
                    printf("*** next window: PATCH STEPPING %s\n\n",
                           w_step_on ? "OFF" : "ON");
                    w_step_on = !w_step_on;
                    w_underrun0 = underrun; w_chunks0 = chunks;
                    gap_max = 0; gap_tag = 0; gap_at = 0;
                }
            }
            phase_tag = 2;
            if ((chunks / (SR / CHUNK)) % S3L_REPORT_EVERY == 0)
            printf("t=%lus  %s  drift %+.1f ms  underruns=%lu  "
                   "render %.2f us/sample "
                   "(~%.0f cycles at 240 MHz)  budget %.2f us  %s\n",
                   chunks / (SR / CHUNK),
                   behind ? "BEHIND REAL TIME" : "realtime OK",
                   drift_ms,
                   underrun, us_per_sample,
                   us_per_sample * 240.0, 1e6 / (double)SR,
                   us_per_sample < 1e6 / (double)SR ? "FITS" : "OVER");
            if ((chunks / (SR / CHUNK)) % S3L_REPORT_EVERY == 0) {
                /* THE DECODED UNDERRUN, and the cushion behind it. `underrun`
                 * on its own could not tell a 50 ms timeout from a short
                 * write, and it turns out esp-idf only ever produces the
                 * second AS the first -- so the counter had one meaning and
                 * was being read as two. */
                printf("I2S: blocked %lu/%lu us (min/max)  zero-block %lu of "
                       "%lu  timeouts %lu  short %lu  nearest burst %ld chunks"
                       "   [a zero-block write means the ~29 ms DMA lead is "
                       "GONE; a blocking one means it is held]\n",
                       wb_min == 0xFFFFFFFFul ? 0ul : wb_min, wb_max,
                       wb_zero, wb_n, i2s_timeout, i2s_short, ur_gap_chunks);
                wb_min = 0xFFFFFFFFul; wb_max = 0; wb_zero = 0; wb_n = 0;
#if S3L_RECALL
                printf("BURST: patch %d  gate %d  builds %lu  publishes %lu "
                       "(refused %lu)  build %lu/%lu/%lu cyc (min/max/last)  "
                       "publish %lu/%lu/%lu cyc  gen %lu\n",
                       dev_patch, dev_gate, dev_builds, dev_pubs,
                       dev_pub_refused,
                       b_min == 0xFFFFFFFFul ? 0ul : b_min, b_max, b_last,
                       p_min == 0xFFFFFFFFul ? 0ul : p_min, p_max, p_last,
                       REC.gen);
                printf("BURST: unmapped total %lu (last offset %lu)  CRC "
                       "%lu checked / %lu BAD (first bad patch %lu)  %s\n",
                       EBDEV_S.miss, EBDEV_S.lastmiss, crc_checked, crc_bad,
                       dev_last_bad_patch,
                       (EBDEV_S.miss || crc_bad || dev_ringlen_bad)
                         ? "*** SEE THE NAMED LINE ABOVE -- NO CYCLE FIGURE "
                           "FROM THIS RUN MAY BE QUOTED ***"
                         : "map complete, chip agrees with host");
                printf("SLACK: core 0 barrier spin %lu/%lu cyc per chunk "
                       "(min/max) = %lu cyc/sample of FREE core-0 time. THIS "
                       "IS THE BURST'S BUDGET, MEASURED -- not 5,410 minus a "
                       "predicted core 0.\n",
                       spin_min == 0xFFFFFFFFul ? 0ul : spin_min, spin_max,
                       (spin_min == 0xFFFFFFFFul ? 0ul : spin_min)
                           / (unsigned long)CHUNK);
                spin_min = 0xFFFFFFFFul; spin_max = 0;
                if (dev_muted)
                    printf("MUTED: %s\n", dev_mute_why);
#endif
            }
        }
    }
}

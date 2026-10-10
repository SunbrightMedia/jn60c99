/* engine_b/shim/skeleton/juno_driver.c — VERBATIM FORK of src/juno_driver.c
 * plus the engine B skeleton hook. Diff it against src/juno_driver.c: the only
 * changes are the two marked ENGINE B blocks.
 *
 * WHAT IT PROVES, AND WHAT IT DOES NOT.
 *
 * PROVES: the engine B skeleton is compiled into the real audio path, is
 * initialised, runs on EVERY rendered sample of every scenario the null harness
 * drives, and perturbs the output by EXACTLY 0. Its structures are therefore
 * real, its per-sample cost is real and measurable by tools/engineb/cost.py, and
 * its free-run advance is exercised by the idle-prefix scenarios.
 *
 * DOES NOT PROVE: anything about engine B's DSP. eb_engine_process() returns
 * EB_INCOMPLETE (eb_modules.h: eleven of twelve modules do not exist), so the
 * PORT's sample is the one returned. This is the BASELINE the first real module
 * is measured against, and calling it anything more would be dishonest.
 *
 * The fork exists because engine_b/shim/README.md requires a shim file to be
 * named after the ONE src/ translation unit it replaces. juno_driver.c is the
 * right one to fork: the per-sample loop is exactly what engine B eventually
 * replaces wholesale.
 */
#include "juno_engine.h"
#include "recall_ramp.h"
#include "juno_driver.h"
#include "delay_recall.h"
#include "effect_modes.h"
#include <string.h>

/* ---- ENGINE B (1/2): the skeleton, alongside the port ------------------- */
#include "eb_engine.h"      /* -I engine_b/ is supplied by the harness */
#include "eb_modules.h"

/* One engine, in BSS, exactly as firmware would hold it -- no allocation, no
 * handle, no init order to get wrong. The null harness renders one context at a
 * time, so a single instance is sufficient here and this file is not the place
 * that decides engine B's ownership model. */
static eb_engine EB;
static int EB_READY;
/* ------------------------------------------------------------------------- */

/* Install the host-params shim into the state block. Call once after init.
 * `shim` must outlive all render calls (the state holds a pointer into it). */
void juno_driver_attach_host(unsigned char *st, struct juno_host_shim *shim,
                             int32_t chorus_mode)
{
    int32_t *p39, *p551;
    void *base;

    shim->mode_v39  = chorus_mode;   /* legacy field; no longer read by the master */
    shim->mode_v551 = chorus_mode;   /* legacy field; slot 2 now follows JUNO_PROG_EFX */
    /* The master reads slot 1 (v39) through params+136 and slot 2 (v551) through
     * params+112 (see src/master_render.c). Point BOTH at the ENGINE cells the
     * per-patch recall writes so each slot follows the loaded patch's own routing:
     *   slot 1 -> state[JUNO_PROG_DLY] = DELAY TYPE  (juno_apply_delay)
     *   slot 2 -> state[JUNO_PROG_EFX] = EFFECT TYPE (juno_apply_effect_modes)
     * Pointer wiring ONLY — the cells' power-on values (DELAY 0, EFFECT 2) are
     * part of the prepared baseline written by juno_engine_prepare, exactly as
     * the plugin's constructor leaves them (poweron_routing proof). Do NOT seed
     * from chorus_mode here: an earlier revision did, and every caller passing 0
     * silently parked slot 2 in the Pan arm instead of the plugin's power-on
     * chorus, so the warm (host-idled) state diverged on every chorus patch. */
    p39  = (int32_t *)JCELL(st, JUNO_PROG_DLY);
    p551 = (int32_t *)JCELL(st, JUNO_PROG_EFX);
    memcpy(shim->params + 136, &p39,  sizeof(void *));
    memcpy(shim->params + 112, &p551, sizeof(void *));
    /* base = &shim->params, stored at state+136 (the chase's first hop) */
    base = shim->params;
    memcpy(JCELL(st, 136), &base, sizeof(void *));
}

/* Replicate voice 0's per-voice state block [176,84272) to voices 1..7 so every
 * voice carries the same patch coefficients. Call once after juno_bank_apply (and
 * after juno_engine_init). The 8 blocks tile [176,84272) exactly at stride 10512;
 * the shared/global region (>=84272) and the header (<176) are left untouched. */
void juno_driver_seed_voices(unsigned char *st)
{
#ifdef EB_DEVCELLS
    /* THE DEVICE HAS NO CONTIGUOUS VOICE BLOCK, so this memcpy would copy
     * nothing (the tile IS voice 0 and voices 1..7 exist only as the twelve
     * scatter cells). The rewrite lives here rather than at the call site so a
     * future caller cannot get a silent no-op. Omitting the broadcast was
     * MEASURED to fail 24 of 192 gate cases, first at glide[1].k592. */
    (void)st;
    ebdev_broadcast_scatter();
#else
    const unsigned block = 176;                 /* per-voice block start          */
    int v;
    for (v = 1; v < JUNO_NUM_VOICES; ++v)
        memcpy(st + block + (unsigned)v * JUNO_VOICE_MAIN_STRIDE,
               st + block, JUNO_VOICE_MAIN_STRIDE);
#endif
}

/* Shared analog-noise/LFSR block: a self-contained noise generator + one-pole
 * filter at [84272, 84436) whose evolution reads only its own cells (no per-voice
 * input — voice_render.c:573-631). The plugin BUILDs 9 isolated engine units
 * (sub_7FF91E0268D0: nine operator new(0xA83010)); each of the 8 voice units owns
 * its own copy and steps it exactly ONCE per sample (all units lockstep, so every
 * voice reads the same value). Our single shared state would step it 8x/sample
 * (once per chained voice) and hand each voice a different noise value. */
#define JUNO_NOISE_BLOCK_OFF 84272u
#define JUNO_NOISE_BLOCK_LEN 164u        /* [84272, 84436): 11 cells x 16 - 12 */

/* INDIRECTION FOR PLACEMENT A/B ONLY — NOT AN ARITHMETIC CHANGE.
 * juno_voice_render has exactly one call site (below). Calling it through a
 * function pointer lets an embedded harness swap in a SECOND COMPILATION OF THE
 * SAME SOURCE that the linker placed in a different memory (e.g. ITCM instead of
 * XIP QSPI flash), so ONE boot can measure both placements. The default value is
 * juno_voice_render itself, so every host build behaves exactly as before; the
 * only cost is one indirect branch per voice, paid identically in both arms of
 * the A/B, so it cannot bias the comparison. No operand, no rounding, no order
 * of operations changes — the golden corpus must stay 8/8 (verified with
 * `make test`). */
uint32_t (*juno_voice_render_fn)(unsigned char *, int, float *, float *)
    = juno_voice_render;

/* Same purpose, same guarantee, for the master stage's single call site. */
float *(*juno_master_render_fn)(unsigned char *, float **, float **)
    = juno_master_render;

#ifndef EB_DEVCELLS
#define UNIT_MAGIC 0x54494E55              /* "UNIT": per-voice noise copies live */
typedef char unit_fits[(JUNO_UNIT_END <= JUNO_STATE_BYTES && JUNO_NOISE_BLOCK_LEN <= 176u) ? 1 : -1];
static int unit_split(const unsigned char *st)
{
    int32_t m;
    memcpy(&m, st + JUNO_UNIT_BASE, 4);
    return m == UNIT_MAGIC;
}
static unsigned char *unit_noise(unsigned char *st, int v)
{
    return st + JUNO_UNIT_BASE + 16u + 176u * (unsigned)v;
}
/* unit u's start-up mute (JUNO_LATCH_BASE): 1 = this sample is muted (and the
 * counter taken), 0 = render */
static unsigned char *latch_cell(unsigned char *st, int u)
{
    return u < 8 ? st + JUNO_LATCH_BASE + 4u * (unsigned)u : st + JUNO_LATCH_MASTER;
}
static int latch_take(unsigned char *st, int u)
{
    int32_t n;
    memcpy(&n, latch_cell(st, u), 4);
    if (n <= 0) return 0;
    --n;
    memcpy(latch_cell(st, u), &n, 4);
    return 1;
}
#endif

/* Arm every unit's start-up mute (the engine's construction: 960 samples). */
void juno_driver_arm_latch(unsigned char *st)
{
#ifndef EB_DEVCELLS
    int32_t n = JUNO_LATCH_N;
    int u;
    for (u = 0; u < 9; ++u) memcpy(latch_cell(st, u), &n, 4);
#else
    (void)st;
#endif
}

/* Voice v's own copy of the noise block (for gates): the per-voice copy once
 * a count below 8 has been rendered, else the one shared block. */
const unsigned char *juno_driver_unit_noise(const unsigned char *st, int v)
{
#ifndef EB_DEVCELLS
    if (unit_split(st) && v >= 0 && v < JUNO_NUM_VOICES) return unit_noise((unsigned char *)st, v);
#endif
    (void)v;
    return st + JUNO_NOISE_BLOCK_OFF;
}

/* The noise-block cells the plugin's setSampleRate re-initializes in every unit's
 * own copy (sub_1803A1300: eight, sub_1803990C0: two; EXECUTED: probes/b13b/
 * setsr_writers.py, the same ten on every unit; CLAIMS B13b). With per-voice
 * copies live, each copy takes them from the shared block the two constructors
 * have just written; its other cells stay its own. */
void juno_driver_unit_noise_reinit(unsigned char *st)
{
#ifndef EB_DEVCELLS
    static const unsigned W[10] = { 84272u, 84288u, 84320u, 84336u, 84352u, 84368u, 84384u,
                                    84400u, 84416u, 84432u };
    int v, k;
    if (!unit_split(st)) return;
    for (v = 0; v < JUNO_NUM_VOICES; ++v)
        for (k = 0; k < 10; ++k)
            memcpy(unit_noise(st, v) + (W[k] - JUNO_NOISE_BLOCK_OFF), JCELL(st, W[k]), 4);
#else
    (void)st;
#endif
}

void juno_driver_render_voices(unsigned char *st, float *vbuf)
{
    unsigned char nblk[JUNO_NOISE_BLOCK_LEN];
    int v, nv = juno_voice_count(st);
#ifndef EB_DEVCELLS
    /* A VOICE COUNT BELOW 8 (CLAIMS B10): each voice steps ITS OWN noise copy,
     * as each plugin unit does, so a stopped unit's copy freezes and stays its
     * own when the unit runs again. Entered the first time a count below 8 is
     * rendered (every copy = the shared block: the units ran in lockstep until
     * then) and kept from then on. With all eight voices in lockstep the result
     * is the path below, bit for bit. */
    if (nv < JUNO_NUM_VOICES || unit_split(st)) {
        if (!unit_split(st)) {
            int32_t m = UNIT_MAGIC;
            for (v = 0; v < JUNO_NUM_VOICES; ++v)
                memcpy(unit_noise(st, v), JCELL(st, JUNO_NOISE_BLOCK_OFF), JUNO_NOISE_BLOCK_LEN);
            memcpy(st + JUNO_UNIT_BASE, &m, 4);
        }
        for (v = 0; v < JUNO_NUM_VOICES; ++v) {
            float vr = 0.0f;
            vbuf[v] = 0.0f;
            if (v >= nv || latch_take(st, v)) continue;
            memcpy(JCELL(st, JUNO_NOISE_BLOCK_OFF), unit_noise(st, v), JUNO_NOISE_BLOCK_LEN);
            juno_voice_render_fn(st, v, &vbuf[v], &vr);
            memcpy(unit_noise(st, v), JCELL(st, JUNO_NOISE_BLOCK_OFF), JUNO_NOISE_BLOCK_LEN);
        }
        return;
    }
#endif
    /* snapshot the block, then restore before EACH voice so all 8 step from the
     * same state (nblk) and read the identical one-step advance; after the loop the
     * block is left advanced exactly once (by the last voice) — matching the plugin.
     * A voice at or above the engine's voice count is not rendered at all: its
     * output is zero and its state does not move (rva 0x3C7400, CLAIMS B10). */
    (void)nv;                              /* here every voice runs (count >= 8) */
    memcpy(nblk, JCELL(st, JUNO_NOISE_BLOCK_OFF), JUNO_NOISE_BLOCK_LEN);
    for (v = 0; v < JUNO_NUM_VOICES; ++v) {
        float vr = 0.0f;
        vbuf[v] = 0.0f;
#ifndef EB_DEVCELLS
        /* a muted unit runs no DSP; all eight carry the same counter here (they
         * were armed together and have all rendered every sample since) */
        if (latch_take(st, v)) continue;
#endif
        memcpy(JCELL(st, JUNO_NOISE_BLOCK_OFF), nblk, JUNO_NOISE_BLOCK_LEN);
        juno_voice_render_fn(st, v, &vbuf[v], &vr);
    }
}

/* Render one stereo output sample: 8 voices -> 8 buffers -> master process.
 * Writes the final stereo pair to *outL / *outR. Returns 1 if the full master/
 * chorus path ran, 0 if the dry fallback was used (chorus coeffs not yet loaded). */
int juno_driver_render_sample(unsigned char *st, float *outL, float *outR)
{
    float vbuf[JUNO_NUM_VOICES];     /* one mono sample per voice */
    float scratch = 0.0f;
    float *a2[16];
    int i;
    int eb_ok = 0; float eb_l = 0.0f, eb_r = 0.0f;   /* ENGINE B */

    for (i = 0; i < 16; ++i) a2[i] = &scratch;        /* default: harmless */

    /* ---- ENGINE B (2/2): advance the skeleton on EVERY sample ----------
     * Called before the port renders, so engine B sees the same sample count
     * the oracle does -- including the idle samples of the idle-prefix
     * scenarios, which is the whole point of running it here rather than only
     * while a note sounds. Its output is DISCARDED while eb_engine_process()
     * returns EB_INCOMPLETE; the port's sample is what leaves this function, so
     * the null against the oracle is EXACTLY 0 by construction. */
    {
        float ebL = 0.0f, ebR = 0.0f;
        if (!EB_READY) { eb_engine_init(&EB, 44100.0f); EB_READY = 1; }
        eb_ok = (eb_engine_process(&EB, &ebL, &ebR) == EB_OK);
#ifdef EB_SKELETON_FORCE_HANDOVER
        /* TEETH ONLY. Forces the hand-over branch that EB_INCOMPLETE otherwise
         * makes unreachable, so that "the null is EXACTLY 0" is demonstrated to
         * be a property of engine B not yet claiming the output, and NOT of a
         * dead branch the harness could never reach. Engine B currently computes
         * silence, so with this defined the null must FAIL loudly. */
        eb_ok = 1;
#endif
        eb_l = ebL; eb_r = ebR;
    }

    juno_driver_render_voices(st, vbuf);              /* 8 voices; noise block stepped once */
    for (i = 0; i < JUNO_NUM_VOICES; ++i)
        a2[2 * i] = &vbuf[i];                          /* even slots = voices */

    /* Run the full master/chorus/output stage. Every coefficient it reads is now
     * supplied bit-exactly from the binary (juno_engine_init + juno_engine_prepare
     * for the invariant/prepare state, the per-patch recall for the rest) — no
     * captured baseline — so the master always produces the faithful signal. */
    {
        float *a3[2] = { outL, outR };
        float keep[JUNO_NUM_VOICES];
        int nv = juno_voice_count(st), v0 = nv < 0 ? 0 : nv;
        *outL = 0.0f; *outR = 0.0f;
        /* the master writes every voice's input sample into the voice output
         * cell (10672 + v*10512) of ITS OWN unit; a voice the count stops keeps
         * the last output its unit rendered (CLAIMS B10) */
        for (i = v0; i < JUNO_NUM_VOICES; ++i)
            keep[i] = JF(st, 10672u + (unsigned)i * JUNO_VOICE_MAIN_STRIDE);
#ifndef EB_DEVCELLS
        if (!latch_take(st, 8))            /* the master's start-up mute: no DSP, zero out */
#endif
        juno_master_render_fn(st, a2, a3);
        for (i = v0; i < JUNO_NUM_VOICES; ++i)
            JF(st, 10672u + (unsigned)i * JUNO_VOICE_MAIN_STRIDE) = keep[i];
#ifndef EB_DEVCELLS
        /* The plugin steps every unit's ramp records AFTER that unit's DSP of the
         * sample (its render wrappers tail-jump to the pump, rva 0x3C24A0), so
         * the recall ramps step here (CLAIMS B1, src/recall_ramp.c). */
        juno_rr_pump(st);
#endif
        /* Reproduce the x86 plugin's FTZ/DAZ: flush decayed recursive state out
         * of the denormal range so the next sample reads zeros (as it would on
         * the real CPU). Removes the denormal-op load behind the crackle. */
        juno_flush_denormals(st);
        /* ENGINE B hand-over point. Unreachable until eb_modules.h says every
         * module exists; when it is reachable THIS line is what makes the null
         * harness start measuring engine B instead of the port. */
        if (eb_ok) { *outL = eb_l; *outR = eb_r; }
        return 1;
    }
}

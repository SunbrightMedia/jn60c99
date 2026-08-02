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
#include "juno_driver.h"
#include "delay_recall.h"
#include "effect_modes.h"
#include <string.h>

/* ---- ENGINE B (1/2): the skeleton, alongside the port ------------------- */
#include "../../eb_engine.h"
#include "../../eb_modules.h"

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
    p39  = (int32_t *)(st + JUNO_PROG_DLY);
    p551 = (int32_t *)(st + JUNO_PROG_EFX);
    memcpy(shim->params + 136, &p39,  sizeof(void *));
    memcpy(shim->params + 112, &p551, sizeof(void *));
    /* base = &shim->params, stored at state+136 (the chase's first hop) */
    base = shim->params;
    memcpy(st + 136, &base, sizeof(void *));
}

/* Replicate voice 0's per-voice state block [176,84272) to voices 1..7 so every
 * voice carries the same patch coefficients. Call once after juno_bank_apply (and
 * after juno_engine_init). The 8 blocks tile [176,84272) exactly at stride 10512;
 * the shared/global region (>=84272) and the header (<176) are left untouched. */
void juno_driver_seed_voices(unsigned char *st)
{
    const unsigned block = 176;                 /* per-voice block start          */
    int v;
    for (v = 1; v < JUNO_NUM_VOICES; ++v)
        memcpy(st + block + (unsigned)v * JUNO_VOICE_MAIN_STRIDE,
               st + block, JUNO_VOICE_MAIN_STRIDE);
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

void juno_driver_render_voices(unsigned char *st, float *vbuf)
{
    unsigned char nblk[JUNO_NOISE_BLOCK_LEN];
    int v;
    /* snapshot the block, then restore before EACH voice so all 8 step from the
     * same state (nblk) and read the identical one-step advance; after the loop the
     * block is left advanced exactly once (by the last voice) — matching the plugin. */
    memcpy(nblk, st + JUNO_NOISE_BLOCK_OFF, JUNO_NOISE_BLOCK_LEN);
    for (v = 0; v < JUNO_NUM_VOICES; ++v) {
        float vr = 0.0f;
        vbuf[v] = 0.0f;
        memcpy(st + JUNO_NOISE_BLOCK_OFF, nblk, JUNO_NOISE_BLOCK_LEN);
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
        *outL = 0.0f; *outR = 0.0f;
        juno_master_render_fn(st, a2, a3);
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

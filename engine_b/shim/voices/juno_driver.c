/* engine_b/shim/voices/juno_driver.c — VERBATIM FORK of src/juno_driver.c with
 * ONE function replaced: juno_driver_render_voices. Engine B's own voice chain
 * (eb_engine_render_voices) produces all eight voice samples; the PORT's master
 * stage then consumes them exactly as before.
 *
 * WHAT THIS GATES, AND WHAT IT DOES NOT. Read this before quoting any number
 * from it.
 *
 * GATES: the whole engine B voice chain, end to end, as ONE piece of code
 * driving its OWN state from its OWN coefficients -- sixteen modules that had
 * only ever been gated one at a time inside the port's surrounding code, plus
 * the wiring between them, which had never been executed at all. Eight wrong
 * module inputs were already found in that wiring by reading it; this is the
 * gate that can find the ninth.
 *
 * DOES NOT GATE, and is therefore NOT the certification the orders ask for:
 *   - the MASTER chain. It is still the port's: voice summing, the EFFECT-TYPE
 *     routing, gain staging, the boost/output path and the stereo assembly are
 *     78 % untranscribed (the scope finding, docs/engineb/PHASE1_ORDERS.md).
 *     The FX inside eb_engine_render are not reached by this file.
 *   - engine B's own RECALL. Coefficients are built from the PORT's recalled
 *     cells by eb_render_coefs_build. eb_patch is a later, separate job.
 *   - the at-rest voice shortcut. This file holds every voice awake (see
 *     below), so eb_render.c's atrest branch is not exercised here and stays
 *     an unproven claim.
 * It is the WEAKER gate that PHASE1_ORDERS.md's ruling calls 1b-0, and calling
 * it anything else would be the kind of over-claim this project's own harness
 * audit exists to catch.
 *
 * ORIGINAL HEADER FOLLOWS.
 *
 * juno_driver.c — offline per-sample driver around the exact DSP transcription.
 *
 * This is the clean host glue (NO plugin threading): it renders the voices into
 * the 8 voice buffers the master expects, supplies the chorus-mode selectors
 * the master reads through a host-params pointer, and calls the master process
 * (juno_master_render = sub_180363380) to produce the final stereo sample.
 *
 * POLYPHONY: the master's input is 8 voice samples. voice_render is now
 * parameterised by voice index using the VERIFIED offset classification (diffing
 * the 8 specialised copies sub_180369070..sub_180383F20 proves every state
 * reference is main +v*10512, shared +0, or aux +v*32 — see docs/POLYPHONY.md).
 * All 8 voices are rendered by the one exact transcription each sample. NOTE: the
 * shared analog-noise block (84272..84436) must NOT chain across the 8 voices — the
 * plugin runs 8 ISOLATED engine units (BUILD sub_7FF91E0268D0 = 9x operator
 * new(0xA83010)), each stepping its OWN copy once/sample in lockstep, so every voice
 * reads the same one-step advance. juno_driver_render_voices snapshots the block and
 * restores it before each voice to reproduce that (chaining it, as an earlier version
 * did, stepped the noise 8x too fast). Each voice needs its own copy of the per-voice
 * patch coefficients: juno_bank_apply writes voice 0's block, and
 * juno_driver_seed_voices replicates it to voices 1..7 (call after apply). Global
 * coeffs (e.g. VCA level at 101072) stay single.
 */
#include "juno_engine.h"
#include "juno_driver.h"
#include "delay_recall.h"
#include "effect_modes.h"
#include <string.h>

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
    /* ---- ENGINE B: DETECT A NEW CONTEXT AND RE-SEED ---------------------
     *
     * THE DEFECT THIS FIXES, because it cost most of a session to find and it
     * is a trap for the standalone shim too. Engine B's state lives in file
     * statics, and the render WORKER creates one context per scenario and
     * renders all 29 in ONE process. Without this, scenario 1 seeded engine B
     * and scenarios 2..29 silently reused scenario 1's ENDING state -- so the
     * first scenario nulled EXACTLY 0 and every later one failed from its
     * very first frame. The failure looks exactly like a broken DSP chain and
     * is nothing of the kind. MEASURED: the first differing sample was 42000,
     * which is precisely the length of scenario 1.
     *
     * Re-seeding is keyed on a MARKER in the unused tail of the 12 MB state
     * block, not on the pointer: juno_gui_create() callocs a fresh block (so
     * the marker reads 0) but a freed block's address is readily reused, and a
     * pointer test would then miss the new context. juno_driver_attach_host is
     * also called on RE-INIT and on a chorus-mode change; those must NOT
     * re-seed, because re-seeding free-run state mid-scenario is exactly what
     * would mask a lockstep defect, and the marker leaves them alone.
     *
     * The offset is past everything the engine uses (the highest live cell is
     * 11,022,348 of 12,582,912) and is read and written by nothing else. */
    {
        extern void ebsh_new_context(void);
        uint32_t *mark = (uint32_t *)(st + 11500000u);
        if (*mark != 0xEB0BEEF1u) { *mark = 0xEB0BEEF1u; ebsh_new_context(); }
    }

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

/* ---- ENGINE B: the voice chain, in place of the port's eight calls -------- */
#include "eb_engine.h"
#include "eb_render.h"
#include "eb_coefs.h"

static eb_engine       EBE;
static eb_render_state EBS;
static eb_render_coefs EBC;
static int             EB_STARTED;
static unsigned long   EB_GEN_SEEN;

/* Called by juno_driver_attach_host when a genuinely NEW context appears.
 * ONE engine B instance serves one context at a time, which is what the null
 * harness drives; two live contexts would need two instances and this file is
 * not the place that decides engine B's ownership model. */
void ebsh_new_context(void) { EB_STARTED = 0; }
extern unsigned long   eb_coef_gen;    /* gui/juno_bridge.c bumps it */

#ifdef EB_VOICES_DEBUG
#include <stdio.h>
static unsigned long DBGN;
static int DBGSHOWN;
/* Live differential: the PORT's own voice render on the REAL state (so the
 * oracle trajectory is the true one), engine B alongside it, and the port's
 * samples are what leave the function -- so the null must be EXACTLY 0 and any
 * report below is a genuine engine B difference, not a harness artefact. */
static void ebdbg_cmp(const float *pv, const float *ebv)
{
    int v;
    for (v = 0; v < JUNO_NUM_VOICES; ++v)
        if (memcmp(&pv[v], &ebv[v], 4) != 0) {
            if (DBGSHOWN < 12) {
                fprintf(stderr, "DIFF n=%lu voice=%d port=%.9g eb=%.9g\n",
                        DBGN, v, (double)pv[v], (double)ebv[v]);
                ++DBGSHOWN;
            }
            break;
        }
    ++DBGN;
}
#endif

void juno_driver_render_voices(unsigned char *st, float *vbuf)
{
    float ebv[JUNO_NUM_VOICES];
    int v;

    if (!EB_STARTED) {
        /* SEEDED ONCE, THEN OWNED. Everything free-running -- DCO phases, the
         * noise LFSR, every smoother -- is copied from the port here and never
         * again. Re-seeding it per sample would make a lockstep defect
         * impossible to see, which is the whole reason the idle-prefix
         * scenarios exist. */
        eb_engine_init(&EBE, 44100.0f);
        eb_render_state_seed(st, &EBS);
        /* the sample rate above is not read by the voice chain: every
         * rate-dependent quantity arrives as a coefficient from the port's
         * recalled cells, so this gate is correct at both rates. `EBE` supplies
         * render_ok and the per-voice atrest flags and nothing else. */
        EBE.render_ok = 1;
        EB_STARTED = 1;
        EB_GEN_SEEN = 0;               /* force the first coefficient build */
    }
    if (EB_GEN_SEEN != eb_coef_gen) {
        eb_render_coefs_build(st, &EBC);
#ifdef EB_VOICES_DEBUG
        { float sv[8]; int q; for (q=0;q<8;++q) sv[q]=*(float*)(st+101504+q*32);
          eb_render_events_mirror(st, &EBS);
          for (q=0;q<8;++q) *(float*)(st+101504+q*32)=sv[q]; }
#else
        eb_render_events_mirror(st, &EBS);
#endif
        EB_GEN_SEEN = eb_coef_gen;
    }
    /* EVERY VOICE STAYS AWAKE. Notes are driven into the PORT by juno_bridge.c,
     * so engine B's own note path never runs and its atrest flags never clear.
     * Holding them clear here is not a workaround for that: it also keeps the
     * at-rest shortcut -- an UNGATED claim that a resting voice's output is
     * exactly 0 -- out of the measurement, so this gate reports the arithmetic
     * chain and not a shortcut around it. */
    for (v = 0; v < JUNO_NUM_VOICES; ++v) EBE.v[v].atrest = 0;

#ifdef EB_VOICES_DEBUG
    {
        unsigned char nblk[JUNO_NOISE_BLOCK_LEN];
        float pv[JUNO_NUM_VOICES];
        int i;
        for (i = 0; i < JUNO_NUM_VOICES; ++i) ebv[i] = 0.0f;
        eb_engine_render_voices(&EBE, &EBS, &EBC, (const eb_render_needs *)0, ebv);
        memcpy(nblk, st + JUNO_NOISE_BLOCK_OFF, JUNO_NOISE_BLOCK_LEN);
        for (i = 0; i < JUNO_NUM_VOICES; ++i) {
            float vr = 0.0f; pv[i] = 0.0f;
            memcpy(st + JUNO_NOISE_BLOCK_OFF, nblk, JUNO_NOISE_BLOCK_LEN);
            juno_voice_render(st, i, &pv[i], &vr);
        }
        ebdbg_cmp(pv, ebv);
        /* ENGINE B'S SAMPLES ARE WHAT LEAVE, ALWAYS. The port's are computed
         * only to be compared against. An earlier revision had this behind a
         * second define, so building with EB_VOICES_DEBUG alone emitted the
         * PORT's audio and the null passed trivially -- a green lie waiting to
         * be quoted. There is now no build of this file that can pass without
         * engine B producing the samples. */
    }
#else
    for (v = 0; v < JUNO_NUM_VOICES; ++v) ebv[v] = 0.0f;
    if (eb_engine_render_voices(&EBE, &EBS, &EBC, (const eb_render_needs *)0,
                                ebv) != EB_RENDER_OK) {
        /* Unreachable while render_ok is set above; if it ever fires the null
         * fails loudly rather than quietly returning the port's samples. */
        for (v = 0; v < JUNO_NUM_VOICES; ++v) ebv[v] = 0.0f;
    }
#endif
    /* THE CROSSING: engine B's samples enter the port's master stage here, and
     * this is where --teeth perturbs them. One statement, one loop, so the
     * teeth anchor is unambiguous and a shim edit that moves it breaks the
     * battery loudly instead of planting nothing. */
    for (v = 0; v < JUNO_NUM_VOICES; ++v) {
        /* THE BRACES ARE LOAD-BEARING. --teeth inserts its perturbation on the
         * line after the assignment; without them it would land outside the
         * loop with v == JUNO_NUM_VOICES, writing one past the end of vbuf and
         * perturbing nothing. MEASURED in that state: both bracket factors gave
         * a residual of EXACTLY 0, i.e. a teeth case that could not reach its
         * own mutation -- the failure this harness has now hit three times. */
        vbuf[v] = ebv[v];
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

    for (i = 0; i < 16; ++i) a2[i] = &scratch;        /* default: harmless */

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
        return 1;
    }
}

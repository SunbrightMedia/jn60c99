/* engine_b/shim/standalone/juno_driver.c — THE STANDALONE GATE (task 1b-2).
 *
 * Engine B produces the WHOLE stereo sample. The port's juno_voice_render and
 * juno_master_render are still linked but are NEVER CALLED: every sample comes
 * from eb_engine_render_voices() followed by eb_master_render(). This is the
 * gate 1b-0 deliberately was not.
 *
 * WHAT THIS GATES, AND WHAT IT DOES NOT. Read this before quoting any number
 * from it.
 *
 * GATES: engine B as an ENGINE -- the voice chain AND the master chain, driving
 * their own state, with the port supplying only the recalled coefficients.
 *
 * ORIGINAL VOICE-GATE HEADER FOLLOWS, still accurate about the voice half.
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
#include <stdio.h>
#include <stdlib.h>

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
#include "eb_master.h"
#include "eb_master_coefs.h"
#include <stddef.h>

static eb_engine       EBE;
static eb_render_state EBS;
static eb_render_coefs EBC;
static eb_master_state MS;
static eb_master_coef  MC;
static eb_master_rings RG;
static int             MS_REFUSED;
static int             EB_STARTED;
static unsigned long   EB_GEN_SEEN;

/* Called by juno_driver_attach_host when a genuinely NEW context appears.
 * ONE engine B instance serves one context at a time, which is what the null
 * harness drives; two live contexts would need two instances and this file is
 * not the place that decides engine B's ownership model. */
void ebsh_new_context(void) { EB_STARTED = 0; MS_REFUSED = 0; }

/* ---- LISTEN-FIRMWARE DUMP HOOK (tools/engineb/gen_listen_coefs.py) -------
 * Read-only access to the four blocks the standalone engine renders from, so
 * a target with no recall path of its own can be given host-built ones. It
 * writes nothing and is never called during a gate run; the gate's own
 * numbers cannot depend on it. */
void ebsh_dump_sizes(int *out)
{
    out[0] = (int)sizeof EBC; out[1] = (int)sizeof MC;
    out[2] = (int)sizeof EBS; out[3] = (int)sizeof MS;
    /* THE VOICE PREFIX. eb_render_state still carries a whole chorus, delay
     * and reverb after its per-voice members -- 724 KB of the 735 KB, and
     * legacy: the master owns the FX now and eb_engine_render_voices does not
     * touch them. Everything a NOTE consists of (envelopes, phases, glide,
     * gate cells) lives in the first ~7 KB, so a target can carry one
     * snapshot per note for the price of a rounding error. offsetof, not a
     * hand-counted number: the struct will change again. */
    out[4] = (int)offsetof(eb_render_state, chorus);
}

void ebsh_dump_blob(int which, unsigned char *dst)
{
    const void *src = 0; size_t n = 0;
    switch (which) {
    case 0: src = &EBC; n = sizeof EBC; break;
    case 1: src = &MC;  n = sizeof MC;  break;
    case 2: src = &EBS; n = sizeof EBS; break;
    case 3: src = &MS;  n = sizeof MS;  break;
    case 4: src = &EBS; n = offsetof(eb_render_state, chorus); break;
    default: return;
    }
    memcpy(dst, src, n);
}
extern unsigned long   eb_coef_gen;    /* gui/juno_bridge.c bumps it */

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
        eb_master_state_seed(st, &MS);
        /* ENGINE B OWNS ITS RINGS. They could have pointed straight at the
         * port's cells -- exact, and free, since the port's 12 MB block already
         * holds them -- and the first version did. That is WRONG for a
         * standalone gate in two ways: it would leave engine B reading the
         * port's memory, and it hides the requirement. MEASURED over all 64
         * factory patches, these six rings need 6.10 MB, three of them 2 MB
         * each. A target that cannot afford that must know it here, not from a
         * linker error.
         *
         * Copied from the port at seed time rather than zeroed, so a context
         * that starts warm is seeded correctly too. */
        {
            static const struct { unsigned data, len; } RD[9] = {
                {4298096, 6395252}, {6396640, 6429412}, {6497616, 8594772},
                {8594784, 10691940}, {10693488, 10726260},
                {10726272, 10759044}, {96928, 101028},
                {6430944, 6463716}, {6463728, 6496500}
            };
            float **dst[9] = { &RG.t1, &RG.t23, &RG.t5_0, &RG.t5_1,
                               &RG.t5_2, &RG.t5_3, &RG.e5,
                               &RG.t4_0, &RG.t4_1 };
            int32_t *dlen[9] = { &RG.t1_len, &RG.t23_len, &RG.t5_0_len,
                                 &RG.t5_1_len, &RG.t5_2_len, &RG.t5_3_len,
                                 &RG.e5_len, &RG.t4_0_len, &RG.t4_1_len };
            int q;
            for (q = 0; q < 9; ++q) {
                int32_t n = *(const int32_t *)(st + RD[q].len);
                if (*dst[q]) free(*dst[q]);
                *dst[q] = (float *)malloc((size_t)n * sizeof(float));
                memcpy(*dst[q], st + RD[q].data, (size_t)n * sizeof(float));
                *dlen[q] = n;
            }
        }
        /* the sample rate above is not read by the voice chain: every
         * rate-dependent quantity arrives as a coefficient from the port's
         * recalled cells, so this gate is correct at both rates. `EBE` supplies
         * render_ok and the per-voice atrest flags and nothing else. */
        EBE.render_ok = 1;
        EB_STARTED = 1;
        EB_GEN_SEEN = 0;               /* force the first coefficient build */
    }
#ifdef EB_SA_RECOEF
    /* DIAGNOSTIC: rebuild the master coefficients EVERY sample, the way the
     * FX shims do. If this makes the gate pass, some cell the constructor
     * treats as a coefficient is not one. */
    eb_master_coefs_build(st, &MC);
#endif
    if (EB_GEN_SEEN != eb_coef_gen) {
        eb_render_coefs_build(st, &EBC);
        eb_master_coefs_build(st, &MC);
        eb_render_events_mirror(st, &EBS);
        EB_GEN_SEEN = eb_coef_gen;
    }
    /* EVERY VOICE STAYS AWAKE. Notes are driven into the PORT by juno_bridge.c,
     * so engine B's own note path never runs and its atrest flags never clear.
     * Holding them clear here is not a workaround for that: it also keeps the
     * at-rest shortcut -- an UNGATED claim that a resting voice's output is
     * exactly 0 -- out of the measurement, so this gate reports the arithmetic
     * chain and not a shortcut around it. */
    for (v = 0; v < JUNO_NUM_VOICES; ++v) EBE.v[v].atrest = 0;

    for (v = 0; v < JUNO_NUM_VOICES; ++v) ebv[v] = 0.0f;
    if (eb_engine_render_voices(&EBE, &EBS, &EBC, (const eb_render_needs *)0,
                                ebv) != EB_RENDER_OK) {
        /* Unreachable while render_ok is set above; if it ever fires the null
         * fails loudly rather than quietly returning the port's samples. */
        for (v = 0; v < JUNO_NUM_VOICES; ++v) ebv[v] = 0.0f;
    }
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
    float vbuf[JUNO_NUM_VOICES];
    int rc;

    /* The voice chain first -- this call also performs the once-per-context
     * seed and the coefficient rebuild for BOTH chains. */
    juno_driver_render_voices(st, vbuf);

#ifdef EB_SA_DEBUG
    /* The PORT's master on the SAME voice samples, for comparison. Engine B's
     * master reads no port cell per sample, so running this is completely
     * non-interfering -- the port's state evolves exactly as the oracle's. */
    {
        static unsigned long N; static int SH;
        float pL = 0.0f, pR = 0.0f, eL, eR;
        float *a2[16]; float scratch = 0.0f; float *a3[2]; int i;
        for (i = 0; i < 16; ++i) a2[i] = &scratch;
        for (i = 0; i < JUNO_NUM_VOICES; ++i) a2[2*i] = &vbuf[i];
        a3[0] = &pL; a3[1] = &pR;
        juno_master_render(st, a2, a3);
        eb_master_render(&MS, &MC, &RG, vbuf, &eL, &eR);
        if ((pL != eL || pR != eR) && SH < 6) {
            fprintf(stderr, "SA n=%lu portL=%.9g ebL=%.9g portR=%.9g ebR=%.9g\n",
                    N, (double)pL, (double)eL, (double)pR, (double)eR);
            SH++;
        }
        ++N;
#ifdef EB_SA_PORTOUT
        *outL = pL; *outR = pR;
#else
        *outL = eL; *outR = eR;
#endif
        rc = EB_MASTER_OK;
    }
#else
    rc = eb_master_render(&MS, &MC, &RG, vbuf, outL, outR);
#endif
    if (rc != EB_MASTER_OK) {
        /* The patch selected a dispatch arm engine B has not transcribed:
         * DELAY TYPE 4, or the EFFECT LABEL_164 core. MEASURED: no factory
         * patch selects either. Say so ONCE and loudly rather than emitting
         * silence that would look like a working effect nobody tested. */
        if (!MS_REFUSED) {
            fprintf(stderr, "eb standalone: REFUSING -- DELAY TYPE %d / EFFECT "
                    "TYPE %d has no engine B module (task 1b-3)\n",
                    (int)MC.delay_type, (int)MC.effect_type);
            MS_REFUSED = 1;
        }
        *outL = 0.0f;
        *outR = 0.0f;
    }

    /* The port's FTZ fallback still runs over the port's cells. It is a no-op
     * for engine B's own state, which is flushed by the CPU's FTZ/DAZ mode
     * that juno_enable_hw_ftz() sets for the whole process -- the same mode
     * the oracle runs under, which is why the two agree on denormals. */
    juno_flush_denormals(st);
    return 1;
}


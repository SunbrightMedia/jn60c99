/* eb_engine.c — the skeleton: lifecycle, the free-run contract, the voice
 * allocator's bookkeeping, and one stub per module.
 *
 * WHAT THIS FILE COMPUTES TODAY: no audio at all. Every module flag in
 * eb_modules.h except NOISE is 0, so eb_engine_process() advances all
 * free-running state, calls each module stub, and returns EB_INCOMPLETE. The
 * caller (today: engine_b/shim/skeleton/juno_driver.c) therefore uses the
 * oracle's sample, and tools/engineb/null_b.py reads EXACTLY 0.
 *
 * BE CLEAR ABOUT WHAT THAT ZERO IS WORTH. It proves the skeleton compiles into
 * the audio path, is initialised from the 118-byte patch, runs on every sample,
 * and PERTURBS NOTHING. It says nothing whatever about engine B's DSP, because
 * engine B has no DSP. It is a baseline to measure the first module against, and
 * that is all it is.
 *
 * WHY THE STUBS ARE STRUCTURED AS THEY ARE. Each module stub has the signature
 * the real module will have, and is called from the place the real module will
 * be called from. Promoting a module is then a change of one function body plus
 * its flag in eb_modules.h -- not a re-plumbing that invalidates every earlier
 * measurement.
 */
#include "eb_engine.h"
#include "eb_modules.h"
#include <string.h>

/* ------------------------------------------------------------------ stubs
 * Each returns the value the real module will return. While its EB_HAVE_ flag
 * is 0 the value is not used for anything -- eb_engine_process() refuses the
 * output -- and each stub is deliberately free of a plausible-looking
 * placeholder law. A stub that "approximately" filtered would be the worst of
 * both worlds: it would make the engine look alive and it would be wrong.
 */
static float eb_mod_dco(eb_engine *e, eb_voice *v)   { (void)e; (void)v; return 0.0f; }
static float eb_mod_vcf(eb_engine *e, eb_voice *v, float x) { (void)e; (void)v; return x; }
static float eb_mod_hpf(eb_engine *e, eb_voice *v, float x) { (void)e; (void)v; return x; }
static void  eb_mod_env(eb_engine *e, eb_voice *v)   { (void)e; (void)v; }
static float eb_mod_vca(eb_engine *e, eb_voice *v, float x) { (void)e; (void)v; return x; }
static void  eb_mod_lfo(eb_engine *e)                { (void)e; }
static void  eb_mod_fx (eb_engine *e, float *l, float *r) { (void)e; (void)l; (void)r; }

/* ------------------------------------------------------------------ init */
void eb_engine_init(eb_engine *e, float sample_rate)
{
    int i;
    memset(e, 0, sizeof(*e));
    e->sr = sample_rate;
    eb_noise_init(&e->noise);
    eb_phase_init(&e->lfo, 0, 0);
    eb_phase_init(&e->fx.cho_lfo, 0, 0);
    for (i = 0; i < EB_NUM_VOICES; ++i) {
        eb_voice *v = &e->v[i];
        eb_phase_init(&v->dco, 0, 0);
        eb_phase_init(&v->sub, 0, 0);
        v->note = 0xFF;
        v->atrest = 1;
        v->env[EB_ENV1].atrest = 1;
        v->env[EB_ENV2].atrest = 1;
    }
}

int eb_engine_set_patch(eb_engine *e, const eb_patch *p)
{
    /* The ONE parameter entry point. Coefficient derivation belongs to the
     * PARAM module and is not attempted here -- eb_params holds the instrument's
     * own bytes, and each module converts them under its own gate. */
    return eb_patch_decode(p, &e->p, 0, 0);
}

/* ------------------------------------------------------------------ notes */
void eb_engine_note_on(eb_engine *e, int note, int vel)
{
    int i, pick = -1;
    uint32_t oldest = 0xFFFFFFFFu;
    if (note < 0 || note > 127) return;
    e->held[note >> 5] |= 1u << (note & 31);
    /* Skeleton allocator: free voice first, else oldest. The real law is
     * CAssignJu60 (POLY / MONO / UNISON, LEGATO, last-note priority on press and
     * LOWEST-held fallback on release) and belongs to EB_HAVE_ALLOC. Getting
     * this wrong is not a subtlety -- the port shipped a POLY-only allocator for
     * months and 16 of 64 factory patches played in the wrong mode. */
    for (i = 0; i < EB_NUM_VOICES; ++i)
        if (!e->v[i].active) { pick = i; break; }
    if (pick < 0)
        for (i = 0; i < EB_NUM_VOICES; ++i)
            if (e->v[i].age < oldest) { oldest = e->v[i].age; pick = i; }
    e->v[pick].note   = (uint8_t)note;
    e->v[pick].vel    = (uint8_t)(vel < 0 ? 0 : vel > 127 ? 127 : vel);
    e->v[pick].gate   = 1;
    e->v[pick].active = 1;
    e->v[pick].atrest = 0;
    e->v[pick].age    = ++e->age_counter;
}

void eb_engine_note_off(eb_engine *e, int note)
{
    int i;
    if (note < 0 || note > 127) return;
    e->held[note >> 5] &= ~(1u << (note & 31));
    for (i = 0; i < EB_NUM_VOICES; ++i)
        if (e->v[i].active && e->v[i].note == (uint8_t)note) e->v[i].gate = 0;
}

/* ------------------------------------------------------------- free run */
int eb_engine_all_atrest(const eb_engine *e)
{
    int i;
    for (i = 0; i < EB_NUM_VOICES; ++i) if (!e->v[i].atrest) return 0;
    return 1;
}

void eb_engine_advance(eb_engine *e, uint32_t n)
{
    int i;
    /* O(1) in n for every phase; O(n) for the LFSR, which is stated as such in
     * eb_freerun.h and is 6 integer ops per sample. */
    eb_noise_advance(&e->noise, n);
    eb_phase_advance(&e->lfo, n);
    eb_phase_advance(&e->fx.cho_lfo, n);
    for (i = 0; i < EB_NUM_VOICES; ++i) {
        eb_phase_advance(&e->v[i].dco, n);
        eb_phase_advance(&e->v[i].sub, n);
    }
}

/* Exactly what eb_engine_advance does for ONE sample, so that the equivalence
 * test compares two code paths rather than one code path with itself. */
static void eb_engine_step_freerun(eb_engine *e)
{
    int i;
    (void)eb_noise_step(&e->noise);
    (void)eb_phase_step(&e->lfo);
    (void)eb_phase_step(&e->fx.cho_lfo);
    for (i = 0; i < EB_NUM_VOICES; ++i) {
        (void)eb_phase_step(&e->v[i].dco);
        (void)eb_phase_step(&e->v[i].sub);
    }
}

/* ------------------------------------------------------------------ render */
int eb_engine_process(eb_engine *e, float *outL, float *outR)
{
    float mix = 0.0f, l, r;
    int i;

    /* 1. Shared free-running state, ALWAYS, whatever the polyphony. The noise
     *    LFSR steps ONCE per sample for the whole engine -- never once per voice.
     *    (The port had to fix exactly this: chaining it across the 8 voices ran
     *    it 8x too fast.) */
    (void)eb_noise_step(&e->noise);
    (void)eb_phase_step(&e->lfo);
    eb_mod_lfo(e);

    /* 2. Voices. THE DESIGN RULE: a voice that is at rest skips its AUDIO work
     *    and NEVER its STATE ADVANCE. MEASURED: one single sample of idling
     *    changes every sample of the note that follows, because the phases
     *    free-run. Skipping the advance here is the one mistake that would sound
     *    right in every cold-start test and wrong in a DAW, which is why
     *    tools/engineb/null_b.py plants precisely that bug in its teeth run. */
    for (i = 0; i < EB_NUM_VOICES; ++i) {
        eb_voice *v = &e->v[i];
        if (v->atrest) {
            eb_phase_step(&v->dco);          /* state advance: NOT skipped */
            eb_phase_step(&v->sub);
            continue;                        /* audio work: skipped        */
        }
        {
            float s = eb_mod_dco(e, v);
            eb_mod_env(e, v);
            s = eb_mod_vcf(e, v, s);
            s = eb_mod_hpf(e, v, s);
            mix += eb_mod_vca(e, v, s);
        }
    }

    /* 3. FX. The chorus LFO free-runs whether or not anything is sounding. */
    eb_phase_step(&e->fx.cho_lfo);
    l = r = mix;
    eb_mod_fx(e, &l, &r);
    *outL = l; *outR = r;

#if EB_MODULES_COMPLETE
    return EB_OK;
#else
    /* Structural refusal, not a guess: engine B has no output until every module
     * in eb_modules.h exists. The caller must use the oracle. */
    return EB_INCOMPLETE;
#endif
}

/* Exposed for the equivalence test only. */
void eb_engine_step_freerun_public(eb_engine *e) { eb_engine_step_freerun(e); }

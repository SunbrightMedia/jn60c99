/* eb_envgen.h — ENGINE B MODULE M7: the two ADSR envelope generators.
 *
 * WHY THIS MODULE FIRST. Two things were crossed to choose it
 * (docs/trackb/MODULE_ORDER.md, docs/trackb/COST_ATTRIBUTION.md):
 *   * GATE QUALITY. The canary survey ranks the envelope block 2nd of 9 at
 *     11/14 observable assignments. The DCOs rank 7th/8th and the charter
 *     forbids rewriting behind a blind gate, so they are not eligible however
 *     tempting. M1b (rank 1) is 1.5% of the budget and COST_ATTRIBUTION still
 *     lists it as blocked; the envelopes are rank 2 AND are the named target of
 *     COST_ATTRIBUTION #3.
 *   * COST. The block is 111 source lines of the port's voice_render.c and it
 *     is pure state-machine arithmetic: no table, no expf, no branchy filter.
 *     That makes it the module where the port's flat-array penalty is the
 *     LARGEST FRACTION of its own cost, which is exactly what engine B claims
 *     to remove. If the thesis fails here it fails everywhere.
 *
 * WHAT THIS IS NOT. It is not the JUNO's ADSR "as a synth textbook would write
 * it", and eb_types.h's placeholder eb_env (level/coef/target/stage) is NOT the
 * topology the plugin uses. The plugin's generator is a peak-detector + phase
 * flag + slewed sustain target + smoothed rate. Writing a textbook ADSR here
 * would have been a chosen approximation with an unbounded error, and the
 * ACCURACY STANDARD requires a measured budget for any of those. So the STATE
 * SET below is the plugin's own.
 *
 * PROVENANCE of the equations: READ from src/voice_render.c:965-1075 and
 * cross-checked line by line against docs/trackb/ENV.md §2.4, which was itself
 * adversarially re-derived. Every parenthesis is load-bearing: the code is
 * compiled -ffp-contract=off and the reference is x86 SSE2 single precision, so
 * an algebraically equal regrouping is a different number. Two of them are
 * documented traps and are NOT taken here (see eb_envgen.c).
 *
 * WHAT ENGINE B CHANGES, and why each change is EXACT rather than approximate:
 *   1. 5 floats of state in a struct instead of 15 cells in a 12 MB array.
 *      The port carries the previous sample through SHADOW cells (2608/2656/
 *      2640/2688/2736) that are copied from the state cells at the top of every
 *      sample -- 5 loads + 5 stores whose only job is to be read 20 lines
 *      later. In a struct the previous value is the value in the register.
 *   2. Loop-invariant hoisting into eb_env_coef, rebuilt only when a parameter
 *      changes. A*0.00390625, S*8.75 and the slew constant are recomputed by
 *      the port on EVERY SAMPLE from cells that change only on recall. Hoisting
 *      a product is bit-exact: the same two operands, the same one rounding.
 *   3. The two write-only outputs (2768/3248) and the two LFO taps (2528/2544)
 *      are dropped. GREPPED: they have no reader in src/ or gui/ outside the
 *      block that writes them. Dropping a store nothing reads cannot change
 *      audio -- but it DOES break state-cell parity, so it is a sonic-identity
 *      claim and not a bit-exact-state one, and it is recorded as such.
 * There is no approximation in this module. The null is expected to be EXACTLY
 * 0, and if it is not, the difference is a defect and not a budget.
 */
#ifndef ENGINEB_EB_ENVGEN_H
#define ENGINEB_EB_ENVGEN_H

/* ---------------------------------------------------------------- state
 * 20 bytes. The port spends 15 cells x 16-byte spacing = 240 bytes of address
 * space per envelope on the same information, 10 of those cells existing only
 * to hold last sample's copy of another cell.
 *
 * NOT free-running (eb_freerun.h): an envelope is driven by its gate, so it has
 * no advance(n). It may only be SKIPPED once it is exactly at rest, and
 * eb_env_atrest() is that predicate.                                        */
typedef struct {
    float y;    /* output integrator            (port cell 2592 / 3072)      */
    float h;    /* peak detector                (port cell 2624 / 3104)      */
    float p;    /* phase flag, 0 = attack       (port cell 2640 / 3120)      */
    float t;    /* slewed sustain target        (port cell 2672 / 3152)      */
    float r;    /* smoothed rate coefficient    (port cell 2720 / 3200)      */
} eb_env_state;

/* ---------------------------------------------------------------- coefficients
 * Rebuilt on a parameter change only. Split from the state so the inner loop
 * touches one read-only cache line shared by all voices playing the same patch.
 *
 * The `k_*` fields are the engine's rate-dependent init constants. They are
 * IDENTICAL for ENV1 and ENV2 in the port (cells 2864..3024 mirror 3344..3504)
 * but are kept per-coef so that a future rate law cannot silently couple them.
 */
typedef struct {
    /* per-patch, from A/S/D/R */
    float a_q;        /* A * (1/256)                                        */
    float d_q;        /* D * (1/256)                                        */
    float r_q;        /* R * (1/256)                                        */
    float sus_scaled; /* S * k_peak                                         */
    /* per-rate init constants (port cells 2864,2880,2896,2912,2928,2944,
     * 2976,2992,3008 and the derived 2704) */
    float k_relthr;   /* -0.5      release threshold on the gated input     */
    float k_peakthr;  /* -8.75     attack-peak threshold                    */
    float k_hold;     /* 11.75     peak-detector hold drive                 */
    float k_atktgt;   /* 14.75     attack target (overshoot)                */
    float k_peak;     /* 8.75      envelope peak / sustain scale            */
    float k_susbase;  /* 8.1499996 sustain base                             */
    float k_slew;     /* the DERIVED sustain slew step -- see eb_envgen.c   */
    float k_ratesm;   /* rate-coefficient smoother                          */
    /* The output stage is TWO multiplies, `(y*k_norm)*k_gain`, exactly as the
     * port writes it. Folding them into one product would be bit-exact only
     * because k_gain happens to be 1.0 today; that is a property of one
     * constant, not of the code, so it is not relied on. One multiply per
     * envelope per sample is not worth an unguarded assumption. */
    float k_norm;     /* 1/8.75, output normaliser                          */
    float k_gain;     /* output gain (1.0 in every rate branch READ so far) */
} eb_env_coef;

/* Build the per-patch half. `a,s,d,r` are the recalled coefficient VALUES (the
 * port's cells 2784/2800/2816/2832), not patch bytes: the byte->value law is
 * the PARAM module's, gated separately, and guessing it here would smuggle an
 * ungated law into a gated module. */
void eb_env_set_adsr(eb_env_coef *c, float a, float s, float d, float r);

/* Build the per-rate half from the engine's initialised constants. Taking them
 * as arguments rather than hard-coding a table is deliberate: the port's own
 * init has two rate branches whose exact bit patterns are PROVEN, and
 * re-deriving them here would be a second, ungated copy of a solved problem.
 * `k_lerpsel` is the port's cell 2848 (1.0) and is an argument because it is
 * the operand of the cancellation the slew constant depends on. */
void eb_env_set_rate_consts(eb_env_coef *c,
                            float k_relthr, float k_peakthr, float k_hold,
                            float k_atktgt, float k_peak, float k_susbase,
                            float k_slewin, float k_lerpsel, float k_ratesm,
                            float k_norm, float k_gain);

/* One sample. `gin` is the gated input: gate x LFO-trigger polarity, computed
 * by the caller because both operands belong to other modules. Returns the
 * NORMALISED envelope output (the port's cells 2752 / 3232). */
float eb_env_tick(eb_env_state *s, const eb_env_coef *c, float gin);

/* Reset to the power-on state. All five cells are zeroed by the port's own
 * chorus_init.c:118-127, so zero is the plugin's power-on value and not a
 * convenient default. */
void eb_env_reset(eb_env_state *s);

/* The skip predicate of the free-run contract. TRUE only when there is nothing
 * left in the generator to advance -- output exactly 0 AND the detector,
 * target and smoothed rate exactly 0. Deliberately conservative: a decaying
 * tail that has merely become inaudible is NOT at rest. */
int eb_env_atrest(const eb_env_state *s);

#endif /* ENGINEB_EB_ENVGEN_H */

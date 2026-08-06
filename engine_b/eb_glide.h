/* eb_glide.h — portamento/glide, the pitch-CV output, and the LFO's rate and
 * delay-envelope chain.
 *
 * SCOPE. src/voice_render.c:682-796 exactly. As with eb_lfo, the boundary was
 * computed rather than chosen: four live-in scalars, and the live-outs are the
 * two values this module returns plus three that are PLAIN COEFFICIENT READS
 * the port happened to hoist into this range (cells 944/976/1008, the external
 * LFO inputs) and one constant (v42 = 1.0). The shim keeps that constant and
 * reads those three cells where they are used, so nothing is threaded back.
 *
 * WHAT IT PRODUCES. Two things the rest of the voice needs:
 *   cell 752  the FINAL PITCH CV -- the glide output, and the value the pitch
 *             polynomial and the VCF cutoff CV both read
 *   the clamped LFO delay-envelope level (the port's v73), which is
 *             eb_lfo_tick()'s `dly_env` argument
 * Plus cell 880, which is state here and an input to the VCF cutoff CV.
 *
 * STATE, classified by read-before-write exactly as eb_lfo's was -- SEVEN
 * floats, and here all seven really are state:
 *   560   the +1 counter / gate ramp
 *   656   glide integrator A
 *   672   glide integrator B
 *   688   the legato/portamento enable ramp
 *   704   the previous pitch CV (the glide's target memory)
 *   880   the key-follow + velocity sum
 *   1104  the LFO rate smoother
 *
 * TEN DEAD STORES are not reproduced: 528, 576, 720, 736, 896, 928, 960, 992,
 * 1024, 1120. Each was grepped across src/ and gui/ including
 * master_render.c's pointer-arithmetic forms; none has a reader anywhere.
 *
 * THE TWO EXP TABLES. The LFO rate uses the port's juno_exp_ad3c /
 * juno_exp_acc0 lookup ladder with its integer index games, transcribed branch
 * for branch. They are constant data from juno_tables.h, which engine B
 * already depends on for the pitch polynomial; no port CODE is called.
 *
 * ONE DIVISION is on this path (the glide's `s672 / (...)`). It is left as a
 * division: x/y and x*(1/y) are different floats, and this module must null at
 * EXACTLY 0. It is a once-per-voice-per-sample cost, not a per-sub-sample one.
 */
#ifndef ENGINEB_EB_GLIDE_H
#define ENGINEB_EB_GLIDE_H

typedef struct {
    float s560, s656, s672, s688, s704, s880, s1104;
} eb_glide_state;

typedef struct {
    float k592, k608, k624, k768, k784, k800, k816, k832;
    float k848, k864, k912, k1040, k1088, k1152, k1168;
    /* DERIVED, by eb_glide_prepare. The port's two exponent-table ladders
     * (:757-796) are indexed by (int)k1168 and (int)-k1168 and scale k912 --
     * every operand is RECALL-CONSTANT, so the whole ladder produces the same
     * float on every sample of a patch. It was being walked once per voice per
     * sample. Not an approximation: the value is identical, so the null is
     * EXACTLY 0. */
    float d_exp;
} eb_glide_coef;

/* Fills the derived member. MUST be called after the k members are set and
 * before the first tick. Both coefficient builders call it -- the engine's
 * eb_render_coefs_build and the null harness's glide shim -- because a
 * derived value computed in only one of them is the defect class this project
 * has hit three times (the DCO edge thresholds, twice). */
void eb_glide_prepare(eb_glide_coef *c);

/* One sample.
 *   gate_sign  the port's v34, the three-way gate sign (+1/-1)
 *   kbd        cell 368 (v14), key-follow amount
 *   vel        cell 384 (v16), velocity contribution
 *   pitch_in   the port's v28, the pre-glide pitch CV
 *
 * Returns the clamped LFO delay-envelope level (the port's v73, which is
 * eb_lfo_tick's `dly_env`). `out752` returns the FINAL PITCH CV. */
float eb_glide_tick(eb_glide_state *s, const eb_glide_coef *c,
                    float gate_sign, float kbd, float vel, float pitch_in,
                    float *out752);

#endif /* ENGINEB_EB_GLIDE_H */

/* eb_pwm_cv.c — ENGINE B MODULE M-MODCV. See eb_pwm_cv.h for scope and rules.
 *
 * TRANSCRIPTION RULE, which is the whole of the risk here: the reference is
 * x86 SSE2 single precision compiled -ffp-contract=off, so an algebraically
 * equal regrouping is a DIFFERENT float. Every parenthesis below is the port's
 * own, in the port's own order, and no sum is reassociated. The only things
 * moved are products of operands that a render cannot change (the bend term),
 * and moving those is exact because the operands and the rounding are the same.
 *
 * WHERE THE BLUEPRINT IS WRONG. docs/trackb/MOD.md §3.9 labels [3744] the
 * "mod-wheel term". It is not: [3744] = ([3984] * ([4016] * [1808])) * [4000],
 * i.e. the UNDELAYED LFO through the common LFO gain and two more constants —
 * the same [3712] the PWM sum uses. There is no wheel anywhere in the range.
 * The FORMULAS in §3.9/§3.10 are correct as written and were used; only that
 * label is wrong, and the oracle (the code at :1100-1101) decides.
 *
 * WHAT IS DEAD, MEASURED BY GREP over src/ and gui/ rather than assumed:
 *   [3568]  written at :1077, no reader anywhere.
 *   [3616]  written at :1082, its only reader is :1080 which writes [3632];
 *   [3632]  no reader anywhere. So the keyboard-CV STORE is dead — but the
 *           VALUE v169 is live, it enters the pitch sum at :1112.
 *   [3696]  written at :1088, read only at :1116 by v188;
 *   [3824]  written at :1124 from v188, no reader anywhere. So v188 is a dead
 *           chain and neither it nor [3696] is computed here.
 * Nothing else in the range is dropped.
 */
#include "eb_pwm_cv.h"

void eb_modcv_set(eb_modcv_coef *c,
                  float c3584, float c3600, float c3856, float c3872,
                  float c3888, float c3904, float c3920, float c3936,
                  float c3952, float c3968, float c3984, float c4000,
                  float c4016, float c4032, float c4048, float c4064,
                  float c4080, float c4096, float c4112, float c4128,
                  float c4144, float c4160, float c4176, float modsrc)
{
    c->k_pcv         = c3584;
    c->k_kbd         = c3600;
    c->lfo_gain      = c4016;
    c->pitch_lfo     = c4032;
    c->pitch_lfo_out = c4048;
    c->pwmarm_a      = c3984;
    c->pwmarm_b      = c4000;
    c->env1_pitch    = c4064;
    c->env2_pitch    = c4080;
    c->envmix_pitch  = c4096;
    c->pitch_off1    = c3952;
    c->pitch_off2    = c3968;
    c->pwm_lfo       = c4160;
    c->pwm_manual    = c4176;
    c->pwm_scale     = c3888;
    c->env1_pwm      = c3904;
    c->env2_pwm      = c3920;
    c->pwm_off       = c3936;
    c->out_gain      = c4144;

    /* :1103 verbatim, with [3680] == [3552] (:1087, a same-sample copy). */
    c->bend       = (((c3856 * modsrc) - (c4112 * c3856)) + c4112) * c4128;
    /* the shape in which :1105 consumes it */
    c->bend_pitch = c3872 * c->bend;
}

void eb_modcv_tick(const eb_modcv_coef *c,
                   float pitch_cv, float kbd, float lfo_del, float lfo_undel,
                   float env1, float env2,
                   float *pitch_out, float *pwm_out)
{
    /* :1081 — keyboard / pitch CV mix (the [3616] store is dead, the value is
     * not) */
    float v169 = (kbd * c->k_kbd) + (pitch_cv * c->k_pcv);

    /* :1093-1095 — the two LFO arms. v177 is the port's [3712]. */
    float v176 = lfo_del * c->lfo_gain;
    float v177 = c->lfo_gain * lfo_undel;

    /* :1098-1101 */
    float v180 = v176 * c->pitch_lfo;
    float v182 = (c->pwmarm_a * v177) * c->pwmarm_b;      /* [3744] */

    /* :1105 — the bend contribution is folded (see eb_modcv_set) */
    float v185 = (c->pitch_lfo_out * v180) + (v182 + c->bend_pitch); /*PLANT*/

    /* :1108-1114 — THE PITCH SUM, [3776] */
    float ps = (((((c->env2_pitch * env2) + (c->env1_pitch * env1))
                   * c->envmix_pitch)
                 + v185)
                + v169)
               + c->pitch_off1;
    *pitch_out = ps + c->pitch_off2;

    /* :1117-1123 — THE PWM SUM, [3808] */
    *pwm_out = ((((((v177 * c->pwm_lfo) + c->pwm_manual) * c->pwm_scale)
                  + (c->env1_pwm * env1))
                 + (c->env2_pwm * env2))
                + c->pwm_off)
               * c->out_gain;
}

float eb_modcv_tap(eb_modcv_state *s)      { return s->z_pitch; }
void  eb_modcv_latch(eb_modcv_state *s, float v) { s->z_pitch = v; }
void  eb_modcv_reset(eb_modcv_state *s)    { s->z_pitch = 0.0f; }

/* ------------------------------------------------------------------ block
 * THE AFFORDABLE SHAPE. eb_modcv_tick() is called eight times per sample and,
 * being out of line, reloads all 21 coefficients through the pointer on every
 * one of those calls: MEASURED-STATIC, 68 memory accesses per invocation, and
 * the cost rig puts that at 438 of the module's 474 S3 cyc/sample. The
 * coefficient set is not per-voice, so the loads are loop-invariant across the
 * eight voices. This entry hoists them: same arithmetic, same order, same
 * roundings, EXACTLY the same floats -- eb_modcv_tick is defined in terms of it
 * so the two cannot drift.
 */
void eb_modcv_block(const eb_modcv_coef *c, int nvoices,
                    const float *pitch_cv, const float *kbd,
                    float lfo_del, float lfo_undel,
                    const float *env1, const float *env2,
                    float *pitch_out, float *pwm_out)
{
    const float k_pcv = c->k_pcv, k_kbd = c->k_kbd;
    const float lfo_gain = c->lfo_gain, pitch_lfo = c->pitch_lfo;
    const float pitch_lfo_out = c->pitch_lfo_out;
    const float pwmarm_a = c->pwmarm_a, pwmarm_b = c->pwmarm_b;
    const float env1_pitch = c->env1_pitch, env2_pitch = c->env2_pitch;
    const float envmix_pitch = c->envmix_pitch;
    const float off1 = c->pitch_off1, off2 = c->pitch_off2;
    const float pwm_lfo = c->pwm_lfo, pwm_manual = c->pwm_manual;
    const float pwm_scale = c->pwm_scale, e1p = c->env1_pwm, e2p = c->env2_pwm;
    const float pwm_off = c->pwm_off, out_gain = c->out_gain;
    const float bend_pitch = c->bend_pitch;
    /* the LFO is global, so its two arms are computed ONCE for all voices */
    const float v176 = lfo_del * lfo_gain;
    const float v177 = lfo_gain * lfo_undel;
    const float v180 = v176 * pitch_lfo;
    const float v182 = (pwmarm_a * v177) * pwmarm_b;
    const float v185 = ((pitch_lfo_out * v180) + v182) + bend_pitch;
    const float pwm_lfo_term = ((v177 * pwm_lfo) + pwm_manual) * pwm_scale;
    int v;
    for ( v = 0; v < nvoices; ++v )
    {
        float e1 = env1[v], e2 = env2[v];
        float v169 = (kbd[v] * k_kbd) + (pitch_cv[v] * k_pcv);
        float ps = (((((env2_pitch * e2) + (env1_pitch * e1)) * envmix_pitch)
                     + v185) + v169) + off1;
        pitch_out[v] = ps + off2;
        pwm_out[v] = (((pwm_lfo_term + (e1p * e1)) + (e2p * e2)) + pwm_off)
                     * out_gain;
    }
}


/* eb_envgen.c — ENGINE B MODULE M7. See eb_envgen.h for why this module and
 * what is and is not claimed.
 *
 * The reference is src/voice_render.c:965-1075 (ENV1 at 971-1021, ENV2 at
 * 1026-1075, an exact structural clone at cell offset +480). Locals below carry
 * the port's own v-numbers in comments so the two can be diffed by eye.
 *
 * THE TWO TRAPS, both documented in docs/trackb/ENV.md §2.4 and both PROVEN
 * there, neither taken here:
 *
 *  1. The slew constant is `((sel*step) - (peak*sel)) + peak` with sel == 1.0
 *     and peak == 8.75. ALGEBRAICALLY that is `step`. NUMERICALLY it is not:
 *     ulp(8.75) is 2^-20 and the step is ~3.9e-4, so the round trip through
 *     exponent 2^3 destroys the step's low mantissa bits -- 0x39ce11c1 becomes
 *     0x39ce0000, a relative error of 3.4e-4 on every slewing sustain sample.
 *     The expression is therefore evaluated verbatim; it is merely evaluated
 *     ONCE, at parameter time, instead of on every sample of every voice.
 *
 *  2. The release rate is `((R*(1/256))*rel - rel*r) + r`, not `R*(1/256)`.
 *     With rel == 1 those differ whenever the smoothed rate r is non-zero --
 *     the same cancellation shape. The rel/r terms are kept.
 *
 * A third would-be simplification is also refused: the port's shift chain makes
 * cell 2640 hold the PREVIOUS peak-detector value during the sample and the
 * NEW phase flag after it. Reading that as "compare h against the phase flag"
 * is the natural misreading and is wrong. Here they are two named fields.
 */
#include "eb_envgen.h"
#include "eb_fork_config.h"

/* fminf without <math.h>: the port's fminf(a,b) on two non-NaN operands, which
 * these always are (both are finite by construction -- k_peak is a constant and
 * the target is a bounded slew). Avoiding the libm call matters on the target:
 * the S3 census in docs/engineb/S3_TOOLCHAIN.md counts 128 call8 instructions
 * per sample in the port's voice_render, and every one of them is a windowed
 * ABI call the engine B budget cannot afford. */
static float eb_fminf(float a, float b) { return (a < b) ? a : b; }

void eb_env_reset(eb_env_state *s)
{
    s->y = 0.0f; s->h = 0.0f; s->p = 0.0f; s->t = 0.0f; s->r = 0.0f;
}

int eb_env_atrest(const eb_env_state *s)
{
    return s->y == 0.0f && s->h == 0.0f && s->t == 0.0f && s->r == 0.0f;
}

void eb_env_set_adsr(eb_env_coef *c, float a, float s, float d, float r)
{
    /* 0.00390625 is 1/256 exactly, so these are single roundings identical to
     * the port's per-sample products at :1004 and :1015. */
    c->a_q = a * 0.00390625f;
    c->d_q = d * 0.00390625f;
    c->r_q = r * 0.00390625f;
    c->sus_scaled = s * c->k_peak;      /* port :999, JF(2800)*JF(2928) */
}

void eb_env_set_rate_consts(eb_env_coef *c,
                            float k_relthr, float k_peakthr, float k_hold,
                            float k_atktgt, float k_peak, float k_susbase,
                            float k_slewin, float k_lerpsel, float k_ratesm,
                            float k_norm, float k_gain)
{
    c->k_relthr  = k_relthr;
    c->k_peakthr = k_peakthr;
    c->k_hold    = k_hold;
    c->k_atktgt  = k_atktgt;
    c->k_peak    = k_peak;
    c->k_susbase = k_susbase;
    c->k_ratesm  = k_ratesm;
    c->k_norm    = k_norm;
    c->k_gain    = k_gain;
    /* TRAP 1 -- verbatim, once. Port :989-991. */
    c->k_slew = ((k_lerpsel * k_slewin) - (k_peak * k_lerpsel)) + k_peak;
}

float eb_env_tick(eb_env_state *s, const eb_env_coef *c, float gin)
{
    /* The five carried values. In the port these are five loads from shadow
     * cells that five stores put there earlier in the same sample. */
    const float y_prev = s->y;          /* [2608] */
    const float p_prev = s->p;          /* [2656] */
    const float h_prev = s->h;          /* [2640] after the shift chain */
    const float t_prev = s->t;          /* [2688] */
    const float r_prev = s->r;          /* [2736] */

    float rel, gh, h, det, dh, p, sus, atk, rsel, t, err, r, y;

    /* release flag; port :980-984. rel == 1 means the gate is low. */
    rel = ((gin + c->k_relthr) >= 0.0f) ? 0.0f : 1.0f;
    gh  = 1.0f - rel;

    /* peak detector; port :986-988 */
    h   = gh * ((c->k_hold * p_prev) + y_prev);
    det = h + c->k_peakthr;
    dh  = h - h_prev;

    /* phase flag; port :992-1000 */
    p = (det < 0.0f) ? 0.0f : 1.0f;
    if (dh < 0.0f) p = gh;

    /* sustain target, attack flag, rate select; port :998-1004 */
    sus  = ((gh * c->sus_scaled) - (c->k_susbase * gh)) + c->k_susbase;
    atk  = gh * (1.0f - p);
    rsel = (c->d_q * p) + (c->a_q * atk);

    /* upward slew of the sustain target, then the peak clamp; port :1005-1009 */
#if EB_ENV_CR == 2
    if ((sus - t_prev) > 0.0f) sus = t_prev + (c->k_slew + c->k_slew);
#else
    if ((sus - t_prev) > 0.0f) sus = t_prev + c->k_slew;
#endif
    t = eb_fminf(c->k_peak, sus);

    /* error toward the stage target, smoothed rate, integrate; :1011-1017.
     * TRAP 2 is the `(c->r_q*rel - rel*r) + r` factor. */
    err = ((atk * c->k_atktgt) + (p * t)) - y_prev;
#if EB_ENV_CR == 2
    {   /* THE TWO-STEP POLE SQUARE. See eb_fork_config.h: this call now
         * stands for two samples, so each first-order coefficient a becomes
         * 1-(1-a)^2 = a(2-a), which lands the state exactly where two
         * uncompensated steps would have -- for as long as the inputs hold,
         * which between two adjacent samples they nearly do. */
        float ks = c->k_ratesm * (2.0f - c->k_ratesm);
        float a;
        r = ((ks * rsel) - (ks * r_prev)) + r_prev;
        a = ((c->r_q * rel) - (rel * r)) + r;
        a = a * (2.0f - a);
        y = (a * err) + y_prev;
    }
#else
    r   = ((c->k_ratesm * rsel) - (c->k_ratesm * r_prev)) + r_prev;
    y   = ((((c->r_q * rel) - (rel * r)) + r) * err) + y_prev;
#endif

    s->y = y; s->h = h; s->p = p; s->t = t; s->r = r;

    /* port :1018-1019. The port also stores y*gain*1.0 into a second cell that
     * GREPPING finds no reader for anywhere in src/ or gui/; it is not written
     * here (eb_envgen.h, change 3). */
    return (y * c->k_norm) * c->k_gain;
}


/* A BLOCK ENTRY POINT WAS TRIED AND REJECTED, and the negative result is worth
 * more than the code was. The idea: one call per sample for all 8 voices x 2
 * envelopes, so the thirteen coefficients -- identical for every voice playing
 * the patch -- are loaded once into registers instead of once per call.
 * MEASURED with tools/engineb/cost.py on the real ESP32-S3 compiler:
 *
 *   two standalone eb_env_tick calls   162 instructions,  50 memory accesses
 *   the same two ticks force-inlined    240 instructions, 105 memory accesses
 *
 * Inlining made it WORSE, not better, in both terms. The S3 has 16 float
 * registers and one coefficient set is 13 floats, so two live sets spill; and
 * the strided addressing of the voice arrays costs more integer loads than the
 * hoist saves. Splitting into two passes (all voices' ENV1, then all voices'
 * ENV2) to keep only one set live did not recover it either: 240 instructions,
 * 105 accesses. The shape is therefore NOT shipped. If a future layout change
 * (structure-of-arrays state, fewer coefficients) makes it win, it must win in
 * a measurement before it comes back.
 */

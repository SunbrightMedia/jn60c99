/* eb_vcf_cv.c — the VCF cutoff CV summing network. See eb_vcf_cv.h.
 *
 * EVALUATION ORDER IS THE SPECIFICATION. -ffp-contract=off, x86 SSE2 single
 * precision reference: an algebraically equal regrouping is a different float.
 * Every parenthesis below is src/voice_render.c's own. Four regroupings that
 * look free and are NOT taken:
 *     (a*x - b*a) + b            is not   b + a*(x - b)
 *     ((v*v)*v)*v * k4 + ...     is not   Horner
 *     (m - k*(t*d)) + (t*d)      is not   m + (t*d)*(1 - k)
 *     (in - s)*rate + s          is not   in*rate + s*(1-rate)
 *
 * THE DEAD STORES. The port writes 21 cells here; only [6704] and [6848] have
 * a reader outside the block (:1230, :1231, :1570 — GREPPED over all of src/
 * and gui/). Three more ([6896], [7088], [7168]) are read by the NEXT sample of
 * this same block and are engine B's three state floats. The remaining 16 —
 * [6592] [6624] [6656] [6688] [6880] [6912] [6976] [6992] [7040] [7056] [7072]
 * [7104] [7184] [7248] [7264] [7280] — are stores nothing ever loads (several
 * are the z-1 shadows of a value the port then reads from the SOURCE cell
 * anyway) and are simply not performed. Deleting a store that has no load
 * cannot change a number; it does change per-cell state parity, so this is a
 * sonic-identity claim, the same standing as module M-VCF's item 3.
 *
 * ONE ORDERING TRAP, worth naming because it is easy to get backwards:
 *   * [7040] is loaded AFTER it is stored from [7008], so the lerp uses
 *     [7008], not [7040]'s previous value. It is combinational, not state.
 *   * [7248] is loaded AFTER [6896] is updated, so the final sum sees the NEW
 *     smoother value, not the one the same sample started with.
 *   * [7088]/[7168] are the opposite: loaded BEFORE the update. They are state.
 */
#include "eb_vcf_cv.h"

void eb_vcf_cv_reset(eb_vcf_cv_state *st)
{
    st->s_env = 0.0f;
    st->s_a   = 0.0f;
    st->s_b   = 0.0f;
}

/* ---------------------------------------------------------------- prepare
 * RECALL TIME, not sample time. Every expression here is lifted VERBATIM out
 * of the tick below; its operands are recall-constant, so the lift cannot
 * change a float. In engine B this runs when the patch changes; the null shim
 * calls it every sample (harness cost, excluded from every cycle figure) so
 * that a coefficient edit mid-render cannot make the gate lie.
 */
void eb_vcf_cv_prepare(eb_vcf_cv_derived *d, const eb_vcf_cv_coef *c)
{
    float v200, v201, v203, v204;

    /* the quartic spline leg -> [6704]  (src :1154-1169) */
    v200 = ((c->k6720 * c->x6576) - (c->k6736 * c->k6720)) + c->k6736;
    v201 = ((((v200 * v200) * v200) * v200) * c->k6816)
         + (((((v200 * v200) * v200) * c->k6800)
            + (((v200 * c->k6768) + c->k6752)
               + ((v200 * v200) * c->k6784))));
    v203 = (v201 <= 0.0f) ? 0.0f : v201;
    v204 = 1.0f;
    if (v203 < 1.0f) v204 = v203;
    d->f6704 = v204;

    d->f6848 = c->x6832;                                  /* src :1170 */
    d->termA = ((((c->x6608 * c->k7328) - (c->k7456 * c->k7328)) + c->k7456)
                * c->k7472);                              /* src :1213-1216 */
    d->v226  = c->k7312 * c->x6672;                       /* src :1212 */
    d->c7024x6640 = c->k7024 * c->x6640;                  /* src :1187 */

    d->k6864 = c->k6864; d->k6928 = c->k6928;
    d->k6944 = c->k6944; d->k6960 = c->k6960;
    d->k7008 = c->k7008; d->k7024 = c->k7024;
    d->k7120 = c->k7120; d->k7136 = c->k7136; d->k7152 = c->k7152;
    d->k7200 = c->k7200; d->k7216 = c->k7216; d->k7232 = c->k7232;
    d->k7296 = c->k7296; d->k7312 = c->k7312; d->k7344 = c->k7344;
    d->k7360 = c->k7360; d->k7376 = c->k7376; d->k7392 = c->k7392;
    d->k7408 = c->k7408; d->k7424 = c->k7424; d->k7440 = c->k7440;
    d->k7488 = c->k7488; d->k7504 = c->k7504;
}

float eb_vcf_cv_tick(eb_vcf_cv_state *st, const eb_vcf_cv_derived *c,
                     float in752, float in880, float in1792, float in1808,
                     float in2752, float in3232,
                     float *out6704, float *out6848)
{
    float s_env_new, mix6976, lerp7072, tap7104, tap7184;
    float d_a, d_b, s_a_new, s_b_new, v210;
    float v225, v226, cv;

    /* ---- the two recall-constant outputs, folded (see eb_vcf_cv_prepare) ---- */
    *out6704 = c->f6704;
    *out6848 = c->f6848;

    /* ---- smoother [6896]  (src :1171-1175) ---- */
    s_env_new = ((c->k6864 - st->s_env) * c->k6928) + st->s_env;
    st->s_env = s_env_new;

    /* ---- the two-term mixer [6976]  (src :1176-1179) ---- */
    mix6976 = (in880 * c->k6960) + (in752 * c->k6944);

    /* ---- the lerp pair [7040]/[7072]  (src :1180-1187) ---- */
    v210     = in2752 + ((c->k7008 * in3232) - (c->k7008 * in2752));
    lerp7072 = (c->c7024x6640 - (c->k7024 * v210)) + v210;

    /* ---- smoother [7088] + its tap [7104]  (src :1188-1195) ---- */
    d_a     = in1792 - st->s_a;
    s_a_new = (d_a * c->k7120) + st->s_a;
    tap7104 = (d_a * c->k7136) + (c->k7152 * s_a_new);
    st->s_a = s_a_new;

    /* ---- smoother [7168] + its tap [7184]  (src :1196-1203) ---- */
    d_b     = in1808 - st->s_b;
    s_b_new = (d_b * c->k7200) + st->s_b;
    tap7184 = (d_b * c->k7216) + (c->k7232 * s_b_new);
    st->s_b = s_b_new;

    /* ---- the final eight-term sum -> v227  (src :1204-1229) ---- */
    v225  = c->k7296;
    v226  = c->v226;
    cv = ((c->termA
           + (((c->k7440 + s_env_new) * c->k7504) * c->k7424))
        + (((((((v226 - (c->k7312 * (tap7184 * v225))) + (tap7184 * v225))
                 * c->k7360) * c->k7376)
              + (((v226 - (c->k7312 * (tap7104 * v225))) + (tap7104 * v225))
                 * c->k7344))
            + ((((mix6976 + c->k7488) * c->k7408) + (lerp7072 * c->k7392))))));
    return cv;
}

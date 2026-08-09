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

#ifndef EB_ZC_PROBE
#define EB_ZC_PROBE 0
#endif
#if EB_ZC_PROBE
#include <stdio.h>
static float zc_hi[7];
static const char *zc_nm[7] = {"k6864","k7008","k7024","k7136","k7216","k7312","k7376"};
static void zc_rep(void) __attribute__((destructor));
static void zc_rep(void){ int i; FILE*f=fopen("/tmp/zc_probe.log","a"); if(!f)return;
  for(i=0;i<7;++i) fprintf(f,"%s max|v| %.9g\n",zc_nm[i],(double)zc_hi[i]); fclose(f); }
#define ZC(i,v) do{ float _a=(v)<0?-(v):(v); if(_a>zc_hi[i]) zc_hi[i]=_a; }while(0)
#endif


/* ---------------------------------------------------- EB_ZEROCOEF (step 3)
 * DELETING COEFFICIENTS THAT ARE ZERO FOR EVERY PRESET, NOT MERELY EVERY
 * FACTORY PATCH. GOAL.md forbids the second and this is evidenced for the
 * first: tools/engineb/zero_proof.c holds each of these at 0.0 through 64
 * factory patches, 31,744 single-parameter sweeps over the BINDINGS table,
 * 49,632 sweeps of every host RECORD parameter over its whole semantic range,
 * and 7,000 randomised presets -- 188,668 slot-values moved in total, and not
 * one of these ever left zero.
 *
 * AND THE METHOD HAS A NON-VACUITY CONTROL, which is what makes the above
 * mean anything: the identical sweep run against the VCA's c9584 FOUND
 * negatives (72 of 512 factory sets, reaching +/-1.0 across the preset
 * space) and thereby killed the tone-filter skip. The sweep bites when there
 * is something to bite.
 *
 * ON 0 * inf AND 0 * NaN, which this project keeps for c9536 deliberately:
 * every operand deleted below is a bounded control-rate CV -- envelope
 * outputs, smoother taps and recall constants -- not the ladder's feedback
 * state, so neither an infinity nor a NaN can arrive at these multiplies.
 * That is the argument c9536 could not make and these can.
 *
 * STILL A FLAG, DEFAULT OFF. The evidence is empirical and wide, not a proof
 * read out of the port's own writer; the user decides adoption. */
#ifndef EB_ZEROCOEF
#define EB_ZEROCOEF 0
#endif


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
    /* k6864 IS NOT DELETABLE, and it is the reason this file carries a
     * warning. zero_proof.c held it at 0.0 through 64 patches, 81,376
     * parameter sweeps and 7,000 random presets -- and it reaches 0.787 the
     * moment a NOTE IS PLAYED. That sweep varied PRESETS and never played a
     * note, so every note/gate-dependent cell read zero for a reason that had
     * nothing to do with the preset space. The -100 dB gate caught it at
     * 2.4 dB on 9 scenarios.
     *
     * THE LESSON FOR THE REST OF THE CANDIDATE LIST: preset coverage and
     * note/gate coverage are DIFFERENT AXES, and the earlier firmware-blob
     * scan (one patch, 128 note/gate/voice sets) was strong exactly where
     * zero_proof is blind. Neither alone licenses a deletion. */
    s_env_new = ((c->k6864 - st->s_env) * c->k6928) + st->s_env;
    st->s_env = s_env_new;

    /* ---- the two-term mixer [6976]  (src :1176-1179) ---- */
    mix6976 = (in880 * c->k6960) + (in752 * c->k6944);

    /* ---- the lerp pair [7040]/[7072]  (src :1180-1187) ---- */
#if EB_ZEROCOEF
    /* k7008 and k7024 are both structurally zero, so v210 collapses to
     * in2752 and the lerp collapses to v210 (c7024x6640 is k7024 * x6640,
     * zero with it). Five multiplies and three adds. */
    v210     = in2752;
    lerp7072 = v210;
#else
    v210     = in2752 + ((c->k7008 * in3232) - (c->k7008 * in2752));
    lerp7072 = (c->c7024x6640 - (c->k7024 * v210)) + v210;
#endif

    /* ---- smoother [7088] + its tap [7104]  (src :1188-1195) ---- */
    d_a     = in1792 - st->s_a;
    s_a_new = (d_a * c->k7120) + st->s_a;
#if EB_ZEROCOEF
    tap7104 = c->k7152 * s_a_new;                  /* k7136 == 0 */
#else
    tap7104 = (d_a * c->k7136) + (c->k7152 * s_a_new);
#endif
    st->s_a = s_a_new;

    /* ---- smoother [7168] + its tap [7184]  (src :1196-1203) ---- */
    d_b     = in1808 - st->s_b;
    s_b_new = (d_b * c->k7200) + st->s_b;
#if EB_ZEROCOEF
    tap7184 = c->k7232 * s_b_new;                  /* k7216 == 0 */
#else
    tap7184 = (d_b * c->k7216) + (c->k7232 * s_b_new);
#endif
    st->s_b = s_b_new;

    /* ---- the final eight-term sum -> v227  (src :1204-1229) ---- */
#if EB_ZC_PROBE
    ZC(0,c->k6864); ZC(1,c->k7008); ZC(2,c->k7024); ZC(3,c->k7136);
    ZC(4,c->k7216); ZC(5,c->k7312); ZC(6,c->k7376);
#endif
    v225  = c->k7296;
    v226  = c->v226;
#if EB_ZEROCOEF
    /* k7312 == 0 makes v226 zero and both (v226 - k7312*T) + T collapse to T.
     * k7376 == 0 then kills the whole tap7184 leg, which is what makes this
     * the largest of the deletions. */
    (void)v226; (void)tap7184;
    cv = ((c->termA
           + (((c->k7440 + s_env_new) * c->k7504) * c->k7424))
        + ((((tap7104 * v225) * c->k7344))
            + (((mix6976 + c->k7488) * c->k7408) + (lerp7072 * c->k7392))));
#else
    cv = ((c->termA
           + (((c->k7440 + s_env_new) * c->k7504) * c->k7424))
        + (((((((v226 - (c->k7312 * (tap7184 * v225))) + (tap7184 * v225))
                 * c->k7360) * c->k7376)
              + (((v226 - (c->k7312 * (tap7104 * v225))) + (tap7104 * v225))
                 * c->k7344))
            + ((((mix6976 + c->k7488) * c->k7408) + (lerp7072 * c->k7392))))));
#endif
    return cv;
}

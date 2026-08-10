/* eb_vcf_res.c — see eb_vcf_res.h. A transcription of
 * src/voice_render.c:1230-1297, with the port's variable numbers kept.
 */
#include "eb_vcf_res.h"
#include "eb_costprobe.h"
#include "eb_fpdiv.h"
#include "eb_minmax.h"
#ifndef EB_ZEROCOEF
#define EB_ZEROCOEF 0
#endif
#include "eb_fork_config.h"
/* EB_VCF_RES_CR -- C2, control-rate resonance. CLOSED NEGATIVE 2026-08-05:
 * N=2, the gentlest decimation that exists, FAILS at -39.3 dB on all 36
 * scenarios (the gate is -100). N=1 is EXACTLY 0, which is what makes that
 * failure attributable to the decimation alone. The cause is measured, not
 * guessed: this module's output moves 107 % per sample because it carries a
 * wrap24 DITHER -- a stochastic term no causal approximation can reproduce.
 * Read docs/engineb/data/c2_result.md before reviving this idea.
 * The flag stays so the negative is reproducible in one command. */
#ifndef EB_VCF_RES_CR
#define EB_VCF_RES_CR 1
#endif

/* EB_VCF_RES_RANGE -- write-only instrumentation. The tail below (v234..v241)
 * is a PURE FUNCTION OF ONE SCALAR, v227, and 150 of this module's 222 Xtensa
 * instructions are in it. That makes it the tabulation case, and a table
 * needs the argument's real range. Reported to /tmp/eb_res_range.log, for the
 * reason eb_vcf_ladder.c records: the null harness discards worker stderr. */
#ifndef EB_VCF_RES_RANGE
#define EB_VCF_RES_RANGE 0
#endif
#if EB_VCF_RES_RANGE
#include <stdio.h>
static float ebr_lo = 1e30f, ebr_hi = -1e30f;
static unsigned long ebr_n = 0;
static void ebr_report(void) __attribute__((destructor));
static void ebr_report(void)
{
    FILE *f;
    if (!ebr_n) return;
    f = fopen("/tmp/eb_res_range.log", "a");
    if (!f) return;
    fprintf(f, "calls=%lu v227 in [%.9g, %.9g]\n", ebr_n,
            (double)ebr_lo, (double)ebr_hi);
    fclose(f);
}
#endif
#include <math.h>
#include <string.h>

/* FORK EXP SWITCH: a VCF coefficient path: memorylessly consumed, so the bias law's ~1e-5
 * tolerance applies and the exponential's own 0.119 ppm is three orders
 * inside it.
 */
#include "eb_fork_config.h"

#ifndef EB_EXPF
#if EB_EXP_FORK
#include "eb_exp_fork.h"
#define EB_EXPF eb_exp_fork
#else
#define EB_EXPF expf
#endif
#endif


static unsigned ebr_bits(float f) { unsigned b; memcpy(&b, &f, 4); return b; }

/* juno_wrap24, transcribed from src/juno_dsp.c so this module calls no port
 * code. The bit fiddling is the algorithm and is reproduced verbatim. */
static float ebr_wrap24(float x)
{
    int v1 = (int)(x * 16777216.0f);
    int v2, v5, v6;
    if (v1 == 0) {
        v2 = 1;
    } else {
        int v3 = v1 & 0x200000;
        if ((v1 & 0x800000) != 0) {
            if (v3 == 0) v2 = 2 * v1; else v2 = 2 * v1 + 1;
        } else {
            if (v3 != 0) v2 = 2 * v1; else v2 = 2 * v1 + 1;
        }
    }
    v5 = v2 & 0xFFFFFF;
    v6 = v2 | 0xFF000000;
    if ((v2 & 0x1000000) == 0) v6 = v5;
    return (float)v6 * 5.960464477539063e-08f;
}

/* ------------------------------------------------------------- the TAIL
 * A PURE FUNCTION OF ONE SCALAR. Every statement below is lifted VERBATIM out
 * of the tick -- same expressions, same parentheses, same order -- and its
 * only inputs are v227 and recall constants. There is no state in it.
 *
 * WHY IT IS LIFTED. It is 150 of this module's 222 Xtensa instructions, it is
 * FEED-FORWARD (C4's post-mortem: a span that does not recycle its error is
 * the case where approximation survives), and it is MEMORYLESSLY CONSUMED
 * (the bias law's ~1e-5 tolerance). One scalar in, one bounded scalar out --
 * v241 is v240/(v240+1), so it lies in [0,1). That is the tabulation case.
 *
 * The lift itself is gated on its own, EXACTLY 0, BEFORE any table is built
 * on it. C2's N=1 row is the precedent: a transformation whose identity case
 * is unproven cannot attribute a later failure to the approximation.
 */
/* EB_VCF_RES_LUT -- tabulate the tail. The value is the table size and must
 * be a power of two; 0 disables the lever and is the default.
 *
 * THE DOMAIN IS MEASURED, not chosen. Over all 36 scenarios at both rates,
 * 17,199,360 calls, v227 lands in [-4.185, 3.500]. The table spans [-6, 4],
 * which is that span with about 1.8 of headroom on each side, and ANY
 * argument outside it falls back
 * to the exact tail rather than being clamped -- clamping would silently
 * change the answer for a user preset the scenario set never reached, which
 * is the "this byte is 0 in every factory patch" mistake GOAL.md forbids.
 *
 * THE TABLE IS PER VOICE. CONDITION scatter makes the ~20 coefficients below
 * voice-distinct, so one shared table would be wrong on seven voices out of
 * eight. At 4,096 entries that is 16 KB per voice, 98 KB at six voices.
 *
 * SIZE, MEASURED rather than reasoned. Linear interpolation error falls as
 * the square of the step, so each doubling should buy 12 dB, and it does
 * until it meets the arithmetic's own floor:
 *
 *     span [-8,8]:  1,024 -> -79.9 dB   2,048 -> -93.3    4,096 -> -105.4
 *                   8,192 -> -111.2 (the floor: 6 dB for a doubling, not 12)
 *     span [-6,4]:  2,048 -> -101.1     4,096 -> -108.8
 *
 * 4,096 over [-6,4] is the shipping choice. 2,048 also passes, at -101.1 dB
 * against a -100 dB gate -- 1.1 dB of margin is a probe ON the threshold, and
 * this project has twice been caught by exactly that.
 */
#ifndef EB_VCF_RES_LUT
#define EB_VCF_RES_LUT 0
#endif
#if EB_VCF_RES_LUT
#define EBR_LUT_LO   (-6.0f)
#define EBR_LUT_HI    (4.0f)
#define EBR_LUT_STEP  ((float)EB_VCF_RES_LUT / (EBR_LUT_HI - EBR_LUT_LO))
static float ebr_tail(const eb_vcf_res_coef *c, float v227);
void eb_vcf_res_prepare(eb_vcf_res_coef *c)
{
    int i;
    for (i = 0; i <= EB_VCF_RES_LUT; ++i)
        c->lut[i] = ebr_tail(c, EBR_LUT_LO
                             + (float)i * (1.0f / EBR_LUT_STEP));
}
#endif

static float ebr_tail(const eb_vcf_res_coef *c, float v227)
{
    float v234, v236, v237, v238, v239, v240, v241;
    int v235;
    v234 = v227;
    v235 = (int)v227;
    if ( v235 != (int)0x80000000 && (float)v235 != v227 )
      v234 = (float)(v235 - (int)((ebr_bits(v227) >> 31) & 1u));
    v236 = v227 - v234;
    v237 = (float)(v236 * v236) * 0.25;
    v238 = (float)(EB_EXPF(v234)
                 * (float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)((float)(v236 * c->k8032) + c->k8016) * v237) + (float)(v236 * c->k8000)) + c->k7984) * v237) + (float)(v236 * c->k7968))
                                                                                                 + c->k7952)
                                                                                         * v237)
                                                                                 + (float)(v236 * c->k7936))
                                                                         + c->k7920)
                                                                 * v237)
                                                         + (float)(v236 * c->k7904))
                                                 + c->k7888)
                                         * v237)
                                 + (float)(v236 * c->k7872))
                         + 1.0))
         * c->k7856;
    v239 = v238 * v238;
    v240 = (float)((float)((float)((float)((float)((float)((float)((float)(v238 * v238) * c->k8192)
                                                         + c->k8160)
                                                 * (float)(v239 * v239))
                                         + (float)((float)((float)(v238 * v238) * c->k8128)
                                                 + c->k8096))
                                 * (float)((float)((float)(v238 * v238) * v238) * (float)(v238 * v238)))
                         + (float)((float)((float)(v238 * v238) * v238) * c->k8064))
                 + v238)
         / (float)((float)((float)((float)((float)((float)((float)((float)((float)(v238 * v238) * c->k8176)
                                                                 + c->k8144)
                                                         * (float)(v239 * v239))
                                                 + (float)((float)(v238 * v238) * c->k8112))
                                         + c->k8080)
                                 * (float)(v239 * v239))
                         + (float)((float)(v238 * v238) * c->k8048))
                 + 1.0);
    v241 = EB_DIV(v240, (float)(v240 + 1.0));
    return v241;
}

float eb_vcf_res_tick(eb_vcf_res_state *s, const eb_vcf_res_coef *c,
                      float cv, float in6704, float in6848, float *out7536)
{
    float v227 = cv;
    float v228, v229, v230, v231, v232, v233;
    float v241, L7584;

  v228 = in6704;
  v229 = in6848;
  L7584 = s->s7568;
  v230 = s->s7552;
  s->s7568 = v230;
  if ( c->k7632 == 1.0 )
  {
    v231 = L7584
         + (float)((float)(c->k7712 * v230) - (float)(c->k7712 * L7584));
    s->s7568 = v231;
    v232 = (float)(v231 * c->k7696) + c->k7600;
    s->s7552 = ebr_wrap24(-v230);
    v233 = (float)(1.0 - v229) * c->k7728;
#if EB_ZEROCOEF
    s->s7536 = v229 * c->k7792;                     /* k7616 == 0 */
#else
    s->s7536 = (float)(v229 * c->k7792) + c->k7616;
#endif
    /* k7760/k7776 are RECALL coefficients in the second operand -- non-NaN
     * by construction (they are decoded patch bytes) and never a signed
     * zero paired with an opposite zero. The INNER fminf's second operand
     * v233 is COMPUTED, so that one takes the exact form. */
    v227 = (float)(eb_fmaxf_c(
                                 eb_fminf_c(
                                   (float)((float)((float)((float)(v227 * c->k7680)
                                                         + (float)(v228 * c->k7648))
                                                 + v232)
                                         + eb_fminf(c->k7744, v233))
                                 + c->k7664,
                                   c->k7760),
                                 c->k7776)
                             * c->k7824)
                     + c->k7840;
#if EB_VCF_RES_CR > 1
    /* C2, CONTROL-RATE RESONANCE (fork lever; docs/engineb/data/c2_result.md).
     * Everything from here to the division is a PURE FUNCTION of v227 -- no
     * state -- so it is the natural control-rate candidate: evaluate it on
     * every Nth sample and reuse the cached s7520 between. The per-sample
     * state ABOVE this point (the wrap24 dither and its smoother) keeps
     * running every sample, because a free-running oscillator that is
     * stepped at 1/N is a different oscillator, not an approximated one.
     *
     * The port's own k7632 != 1.0 arm has exactly this shape, which is what
     * makes the transformation expressible at all. */
    if (s->cr_phase == 0)
#endif
    {
#if EB_VCF_RES_RANGE
    if (v227 < ebr_lo) ebr_lo = v227;
    if (v227 > ebr_hi) ebr_hi = v227;
    ++ebr_n;
#endif
#if EB_VCF_RES_LUT
    if (v227 >= EBR_LUT_LO && v227 < EBR_LUT_HI) {
        float u = (v227 - EBR_LUT_LO) * EBR_LUT_STEP;
        int   i = (int)u;
        float f = u - (float)i;
        v241 = c->lut[i] + (c->lut[i + 1] - c->lut[i]) * f;
        EBCP(lut_hit);
    } else {
        v241 = ebr_tail(c, v227);   /* outside the measured span: exact */
        EBCP(lut_miss);
    }
#else
    v241 = ebr_tail(c, v227);
#endif
    s->s7520 = v241;
    }
#if EB_VCF_RES_CR > 1
    if (++s->cr_phase >= EB_VCF_RES_CR) s->cr_phase = 0;
    v241 = s->s7520;
#endif
  }
  else
  {
    v241 = s->s7520;
  }
  *out7536 = s->s7536;
  return v241;
}

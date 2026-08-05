/* eb_vcf_res.c — see eb_vcf_res.h. A transcription of
 * src/voice_render.c:1230-1297, with the port's variable numbers kept.
 */
#include "eb_vcf_res.h"
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

float eb_vcf_res_tick(eb_vcf_res_state *s, const eb_vcf_res_coef *c,
                      float cv, float in6704, float in6848, float *out7536)
{
    float v227 = cv;
    float v228, v229, v230, v231, v232, v233, v234, v236, v237, v238, v239;
    float v240, v241, L7584;
    int v235;

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
    s->s7536 = (float)(v229 * c->k7792) + c->k7616;
    v227 = (float)(fmaxf(
                                 fminf(
                                   (float)((float)((float)((float)(v227 * c->k7680)
                                                         + (float)(v228 * c->k7648))
                                                 + v232)
                                         + fminf(c->k7744, v233))
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
    v241 = v240 / (float)(v240 + 1.0);
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

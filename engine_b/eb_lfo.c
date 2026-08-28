/* eb_lfo.c — see eb_lfo.h for scope, for how the state was classified, and for
 * what is deliberately not reproduced.
 *
 * This is a TRANSCRIPTION, not a rewrite. Every expression, every
 * parenthesisation and every branch below is src/voice_render.c:797-963 with
 * the cell accesses renamed. The port's own variable numbers (v74, v98, v121)
 * are kept so the two files can be read side by side; that is worth more here
 * than pretty names, because the only question this file must answer is
 * "is it the same arithmetic", and a reviewer has to be able to check it.
 *
 * The `(float)` casts are the port's and are load-bearing under
 * -ffp-contract=off: they force a rounding at that point.
 */
#include "eb_lfo.h"
#include "eb_minmax.h"
#include "triangle.h"
#include <math.h>

/* FORK EXP SWITCH: the LFO delay envelope; its result reaches the LFO RATE, which INTEGRATES
 * into LFO phase -- so this site is gated by the end-to-end LFO-RATE ppm
 * gate (tools/engineb/lfo_rate_gate.py), not by the exponential's own ppm
 * figure. An exp error that is small can still matter after a cancelling
 * expression amplifies it; that is measured there, not assumed here.
 */
#include "eb_fork_config.h"

/* EB_ZEROCOEF here deletes 13 of the 14 candidate coefficients. The 14th,
 * k1856, IS NOT DELETED: the in-render probe reads it at 1.0 with notes
 * sounding while all five preset stages held it at zero -- the THIRD member
 * of the note-path smoother-target species (k6864, c9680, k1856). Every
 * deletion below was confirmed zero IN-RENDER over the full battery, and the
 * operands are bounded CVs, so no 0*inf can arrive. */
#ifndef EB_ZEROCOEF
#define EB_ZEROCOEF 0
#endif
#ifndef EB_EXP_MEMO
#define EB_EXP_MEMO 0
#endif

/* #ifndef so a diagnostic build can define EB_EXPF first and tap this site.
 * That tap produced the finding recorded in F3_S3_FORK_DESIGN: the engine
 * presents only FOUR distinct arguments here across 2,016,000 calls, so the
 * audio null's EXACTLY 0 for the exp substitution is nearly vacuous and the
 * correctness claim rests on the exhaustive ppm gate, not on it. */
#ifndef EB_EXPF
#if EB_EXP_FORK
#include "eb_exp_fork.h"
#define EB_EXPF eb_exp_fork
#else
#define EB_EXPF expf
#endif
#endif


/* The port's phase wrap, verbatim, including the fmodf. eb_dco_wrap() is a
 * PROVEN bit-identical replacement for exactly this shape (all 2^32 inputs,
 * engine_b/test_dco_wrap.c) and would remove four fmodf calls per sample from
 * the S3 path -- but it is not used here YET, on purpose. This module's first
 * gate must attribute any divergence to the transcription and to nothing else.
 * Swapping the wrap is a separate change with its own null run. */
/* EB_LFO_COUNT (P3's method): write-only branch counters, compiled out unless
 * -DEB_LFO_COUNT. ctr[0] = wrap calls, ctr[1] = slow (fmodf) arms taken. The
 * cost tool charges every fmodf CALL SITE its full body; these rates say how
 * often one actually runs on the real gated scenario set. */
#ifdef EB_LFO_COUNT
unsigned long long eb_lfo_ctr[2];
#define EBLC(i) (++eb_lfo_ctr[i])
#else
#define EBLC(i) ((void)0)
#endif

static float eb_lfo_wrap(float p)
{
    /* wrap-dco (b38): the fmodf-free form of eb_dco_wrap (eb_dco.h:299-313),
     * PROVEN bit-identical to this function's fmodf reference over ALL 2^32
     * float32 inputs incl. NaN payloads (engine_b/test_dco_wrap.c, 0 mismatch).
     * fmodf survives only on the rare |p|>=~3 tail. EBLC hooks unchanged. */
    EBLC(0);
    if (p <= 1.0f) {
        if (p < -1.0f) {
            float t = p - 1.0f;
            EBLC(1);
            return (t > -4.0f) ? (t + 2.0f) + 1.0f : fmodf(t, 2.0f) + 1.0f;
        }
        return p;
    }
    {   float t = p + 1.0f;
        EBLC(1);
        return (t < 4.0f) ? (t - 2.0f) - 1.0f : fmodf(t, 2.0f) - 1.0f;
    }
}

/* L-B (b24 §4.1): ONE body, TWO specialisations. The five state stores
 * (s1488/s1504/s1568/s1536/s1600) all land before the cut; the return value
 * and both out-pointers are computed after it. want_out is a compile-time
 * constant at both call sites, so GCC dead-code-eliminates the whole output
 * tail (including the interleaved output-only locals v96..v100, L1408,
 * L1680..L1760) from the advance-only specialisation. One source of truth:
 * the state law cannot drift between the two paths because there is only
 * one copy of it. */
static __inline__ __attribute__((always_inline))
float eb_lfo_tick_impl(eb_lfo_state *s, const eb_lfo_coef *c,
                       float dly_env, float ext_gate,
                       float ext0, float ext1, float noise,
                       float *out1808, float *out1824, int want_out)
{
    float v74, v75, v76, v77, v78, v79, v80, v81, v83, v84, v85, v86, v87;
    float v88, v89, v90, v91, v92, v93, v94, v95, v96, v97, v98, v99;
    float v100, v101, v102, v103, v104, v105, v106, v107, v108, v109;
    float v110, v111, v112, v113, v114, v115, v116, v117, v118, v119;
    float v120, v121, v529;
    float L1408, L1424, L1440, L1456, L1472, L1552, L1584, L1616;
    float L1680, L1696, L1712, L1728, L1760;

    v74 = c->k1056;
#if EB_EXP_MEMO
    /* THE MEMO, cashing a measurement O6 left on the table: across 2,016,000
     * calls over the whole battery this site saw FOUR distinct arguments (the
     * delay envelope is a ramp between recall constants and parks at its
     * ends). A pure function with four live inputs is a cache, not a
     * computation: one float compare on a hit against ~300 cycles of
     * exponential. BIT-EXACT BY CONSTRUCTION -- same argument, same result,
     * the cached value IS the function's own output. A stale entry cannot
     * exist: the key is compared before every use. The cache is file-static
     * (NOT engine state) precisely because a value cache needs no re-seed:
     * unlike the lockstep statics this project was bitten by, a memo entry
     * is correct for its key in every context or it does not match at all. */
    {   static float memo_a = -1.0f/0.0f, memo_r;
        float a75 = (float)dly_env * c->k1200;
        if (a75 != memo_a) { memo_a = a75; memo_r = EB_EXPF(a75); }
        v75 = memo_r * c->k1184;
    }
#else
    v75 = EB_EXPF((float)dly_env * c->k1200) * c->k1184;
#endif
    v76 = v74 * c->k1072;
    L1584 = s->s1568;
    v77 = v75 + c->k1216;
    v78 = s->s1504;
#if EB_ZEROCOEF
    v79 = 0.0f;                                   /* k1904 == 0 */
#else
    v79 = ext_gate * c->k1904;
#endif
    L1616 = s->s1600;
    v80 = s->s1488;
    v81 = s->s1536;
    /* the port stores old-1488 into 1504 here and overwrites it at :840
     * before anything reads it -- a dead first write, kept out */
    L1552 = v81;
    L1440 = ext0;
    L1456 = ext1;
    L1424 = noise;
    v83 = (float)(v76 - (float)(v74 * v77)) + v77;
    v84 = c->k1856;
    v85 = v79 + v84;
    if (v85 >= -1.0f)
        v86 = eb_fminf_c(v85, 1.0f);      /* non-zero constant second */
    else
        v86 = -1.0f;
    v87 = c->k2128;
    s->s1488 = v86;
    /* SECOND OPERAND IS COMPUTED -- no bound, so the exact form. */
    v88 = eb_fminf(v87, v83 * 0.000015258789f);
    v89 = (float)((float)(1.0f - v78) * c->k1920) + v78;
    if (v89 >= -1.0f)
        v90 = eb_fminf_c(v89, 1.0f);      /* non-zero constant second */
    else
        v90 = -1.0f;
    v91 = v88 * c->k2144;
    v92 = v80 - v86;
    v93 = v91 + v81;
    if (v92 < 0.0f)
        v90 = 0.0f;
    v94 = c->k1872;
    v95 = L1424;
    s->s1504 = v90;
    v96 = v90 + c->k2272;
    if (v92 >= 0.0f)
        v94 = 1.0f;
    v97 = v96 * c->k2256;
    v98 = (float)(v93 * v94) * c->k1888;
    if (v97 <= 0.0f)
        v99 = 0.0f;
    else
        v99 = v97;
    v100 = v99;
    v101 = (float)((float)(v95 - L1584) * c->k2464) + L1584;
    s->s1568 = v101;
    L1472 = v100;
    v529 = L1552;
    v102 = (float)((float)((float)(v101 * c->k2448) * c->k2064)
                 - (float)(v95 * c->k2064))
         + v95;
    v98 = eb_lfo_wrap(v98);
    v103 = L1616;
    s->s1536 = v98;
    v104 = v98 + c->k2288;
    L1408 = v102 * c->k2432;
    if (v529 < 0.0f && v98 > 0.0f)
        v103 = v95;
    v104 = eb_lfo_wrap(v104);
    s->s1600 = v103;
    /* THE CUT (L-B). Every persistent field is written above this line; the
     * out-pointers are untouched below on the advance path, so a consumer of
     * the published fields sees the PREVIOUS computed value, never zero. */
    if (!want_out) return 0.0f;
    v105 = v103 * c->k2416;
    v106 = (float)(v104 * c->k2352) + c->k2480;
    L1680 = v106;
    L1760 = v105;
    v107 = v98 + c->k2320;
    L1696 = -v106;
    /* the port wraps v107 with fmodf and DISCARDS the result; fmodf has no
     * side effects, and eb_triangle wraps its own argument (PROVEN over all
     * 2^32 inputs), so the discarded call is simply absent. v107 and v108 are
     * DIFFERENT phases -- see src/voice_render.c:899. */
#if EB_ZEROCOEF
    v108 = v98;                                   /* k2304 == 0 */
#else
    v108 = v98 + c->k2304;
#endif
    v108 = eb_lfo_wrap(v108);
    v109 = eb_triangle(v107);
#if EB_ZEROCOEF
    v110 = v108;                                  /* k2496 == 0 */
#else
    v110 = v108 + c->k2496;
#endif
    v111 = v109 * c->k2384;
    if (v110 >= 0.0f) {
        if (v110 > 0.0f)
            v110 = 1.0f;
    } else {
        v110 = -1.0f;
    }
#if EB_ZEROCOEF
    v112 = v98;                                   /* k2336 == 0 */
#else
    v112 = v98 + c->k2336;
#endif
    L1728 = v111;
    *out1824 = v110;
#if EB_ZEROCOEF
    v113 = v110 * c->k2368;                       /* k2512 == 0 */
#else
    v113 = (float)(v110 * c->k2368) + c->k2512;
#endif
    v112 = eb_lfo_wrap(v112);
    v114 = fabsf(v112);
    L1712 = v113;
#if EB_ZEROCOEF
    /* k1968, k2032, k2000, k2016 all zero: the whole v116 sum and the
     * v115*L1728 product below vanish. */
    v115 = 0.0f;
    v116 = 0.0f;
#else
    v115 = c->k1968;
    v116 = (float)((float)(c->k2032 * L1760)
                 + (float)(c->k2000 * L1680))
         + (float)(c->k2016 * L1696);
#endif
    v117 = (float)((float)((float)((float)(v114 * (float)((float)(v114 * v114) * v114)) * c->k2224)
                         + (float)((float)((float)((float)(v114 * v114) * v114) * c->k2208)
                                 + (float)((float)((float)(v114 * c->k2176) + c->k2160)
                                         + (float)((float)(v114 * v114) * c->k2192))))
                 + c->k2240)
         * c->k2400;
#if EB_ZEROCOEF
    v118 = 0.0f;                        /* v115 == v116 == 0 above */
    (void)v115; (void)v116;
#else
    v118 = (float)(v115 * L1728) + v116;
#endif
    v119 = c->k2080;
    v120 = (float)((float)(c->k1936 * L1472) - c->k1936) + 1.0f;
#if EB_ZEROCOEF
    /* k1984 == 0 and k2048 == 0; with v118 == 0 the sum is one product. */
    v121 = v117 * c->k1952;
#else
    v121 = (float)((float)(v118 + (float)(c->k1984 * L1712))
                 + (float)(v117 * c->k1952))
         + (float)(c->k2048 * L1408);
#endif
    *out1808 = v121;
#if EB_ZEROCOEF
    return (v119 * v120) * v121;        /* k2096 == 0, k2112 == 0 */
#else
    return (float)((float)(c->k2096 * L1440) + (float)(c->k2112 * L1456))
         + (float)((float)(v119 * v120) * v121);
#endif
}

float eb_lfo_tick(eb_lfo_state *s, const eb_lfo_coef *c,
                  float dly_env, float ext_gate,
                  float ext0, float ext1, float noise,
                  float *out1808, float *out1824)
{
    return eb_lfo_tick_impl(s, c, dly_env, ext_gate, ext0, ext1, noise,
                            out1808, out1824, 1);
}

#if EB_LFO_TAIL_CR
/* advance the LFO state without computing the outputs -- callable only on
 * samples the b24 §4.1 alignment argument proves nothing reads them. */
void eb_lfo_advance(eb_lfo_state *s, const eb_lfo_coef *c,
                    float dly_env, float ext_gate,
                    float ext0, float ext1, float noise)
{
    float d0, d1;
    (void)eb_lfo_tick_impl(s, c, dly_env, ext_gate, ext0, ext1, noise,
                           &d0, &d1, 0);
}
#endif

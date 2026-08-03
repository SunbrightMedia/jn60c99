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
#include "triangle.h"
#include <math.h>

/* The port's phase wrap, verbatim, including the fmodf. eb_dco_wrap() is a
 * PROVEN bit-identical replacement for exactly this shape (all 2^32 inputs,
 * engine_b/test_dco_wrap.c) and would remove four fmodf calls per sample from
 * the S3 path -- but it is not used here YET, on purpose. This module's first
 * gate must attribute any divergence to the transcription and to nothing else.
 * Swapping the wrap is a separate change with its own null run. */
static float eb_lfo_wrap(float p)
{
    if (p <= 1.0f) {
        if (p < -1.0f) return fmodf(p - 1.0f, 2.0f) + 1.0f;
        return p;
    }
    return fmodf(p + 1.0f, 2.0f) - 1.0f;
}

float eb_lfo_tick(eb_lfo_state *s, const eb_lfo_coef *c,
                  float dly_env, float ext_gate,
                  float ext0, float ext1, float noise,
                  float *out1808, float *out1824)
{
    float v74, v75, v76, v77, v78, v79, v80, v81, v83, v84, v85, v86, v87;
    float v88, v89, v90, v91, v92, v93, v94, v95, v96, v97, v98, v99;
    float v100, v101, v102, v103, v104, v105, v106, v107, v108, v109;
    float v110, v111, v112, v113, v114, v115, v116, v117, v118, v119;
    float v120, v121, v529;
    float L1408, L1424, L1440, L1456, L1472, L1552, L1584, L1616;
    float L1680, L1696, L1712, L1728, L1760;

    v74 = c->k1056;
    v75 = expf((float)dly_env * c->k1200) * c->k1184;
    v76 = v74 * c->k1072;
    L1584 = s->s1568;
    v77 = v75 + c->k1216;
    v78 = s->s1504;
    v79 = ext_gate * c->k1904;
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
        v86 = fminf(v85, 1.0f);
    else
        v86 = -1.0f;
    v87 = c->k2128;
    s->s1488 = v86;
    v88 = fminf(v87, v83 * 0.000015258789f);
    v89 = (float)((float)(1.0f - v78) * c->k1920) + v78;
    if (v89 >= -1.0f)
        v90 = fminf(v89, 1.0f);
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
    v108 = v98 + c->k2304;
    v108 = eb_lfo_wrap(v108);
    v109 = eb_triangle(v107);
    v110 = v108 + c->k2496;
    v111 = v109 * c->k2384;
    if (v110 >= 0.0f) {
        if (v110 > 0.0f)
            v110 = 1.0f;
    } else {
        v110 = -1.0f;
    }
    v112 = v98 + c->k2336;
    L1728 = v111;
    *out1824 = v110;
    v113 = (float)(v110 * c->k2368) + c->k2512;
    v112 = eb_lfo_wrap(v112);
    v114 = fabsf(v112);
    L1712 = v113;
    v115 = c->k1968;
    v116 = (float)((float)(c->k2032 * L1760)
                 + (float)(c->k2000 * L1680))
         + (float)(c->k2016 * L1696);
    v117 = (float)((float)((float)((float)(v114 * (float)((float)(v114 * v114) * v114)) * c->k2224)
                         + (float)((float)((float)((float)(v114 * v114) * v114) * c->k2208)
                                 + (float)((float)((float)(v114 * c->k2176) + c->k2160)
                                         + (float)((float)(v114 * v114) * c->k2192))))
                 + c->k2240)
         * c->k2400;
    v118 = (float)(v115 * L1728) + v116;
    v119 = c->k2080;
    v120 = (float)((float)(c->k1936 * L1472) - c->k1936) + 1.0f;
    v121 = (float)((float)(v118 + (float)(c->k1984 * L1712))
                 + (float)(v117 * c->k1952))
         + (float)(c->k2048 * L1408);
    *out1808 = v121;
    return (float)((float)(c->k2096 * L1440) + (float)(c->k2112 * L1456))
         + (float)((float)(v119 * v120) * v121);
}

/* test_modcv_block.c — eb_modcv_block() must equal eb_modcv_tick() BIT FOR BIT.
 *
 * WHY THIS TEST EXISTS (docs/engineb/HARNESS_AUDIT.md F4). A coverage run over
 * the full 30-scenario set measured eb_pwm_cv.c at 61.1 % of lines executed,
 * the lowest of any engine B module. The uncovered lines were not a scenario
 * gap: they are the whole of eb_modcv_block(), a block-rate entry point that
 * NOTHING CALLS. No scenario can reach it, so no null gate can say anything
 * about it, and it was sitting in the tree waiting to be switched on during
 * optimisation with zero evidence behind it.
 *
 * That is the more dangerous half of an unexecuted line: not dead code, but
 * code that will become live later, after everyone has stopped looking.
 *
 * WHAT IS CHECKED. The block form hoists the LFO arms and the PWM LFO term out
 * of the per-voice loop. Those terms do not depend on the voice index, so the
 * hoist should be exact -- but "should be exact" is what this project has been
 * wrong about repeatedly (eb_triangle's fmodf replacement was mathematically
 * identical and disagreed on 8,388,608 inputs; eb_triangle_saw's first form was
 * algebraically identical and disagreed on 104,857,600). So it is compared as
 * BIT PATTERNS, not with a tolerance, over pseudo-random coefficient sets and
 * inputs, including the awkward ones: zeros, signed zeros, denormals, huge and
 * tiny magnitudes.
 *
 * A tolerance would defeat the purpose. Two float expressions that differ by
 * one ULP are not the same function, and this engine's standard is EXACTLY 0.
 */
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include "eb_pwm_cv.h"

#define NV 8

static uint32_t rs = 12345u;
static uint32_t r32(void) { rs ^= rs << 13; rs ^= rs >> 17; rs ^= rs << 5; return rs; }

/* A float drawn to land on the awkward cases as well as the ordinary ones. */
static float rf(void)
{
    switch (r32() % 16u) {
    case 0:  return 0.0f;
    case 1:  return -0.0f;
    case 2:  return 1.0f;
    case 3:  return -1.0f;
    case 4:  return 1e-38f;               /* near the denormal boundary */
    case 5:  return -1e-38f;
    case 6:  return 1e30f;
    case 7:  return -1e30f;
    default: {
        /* ordinary audio-scale values, both signs */
        float v = (float)(int32_t)(r32() & 0xFFFFFF) / 8388608.0f - 1.0f;
        return v * (float)(1 << (r32() % 8u));
    }
    }
}

static int bits_differ(float a, float b)
{
    uint32_t x, y;
    memcpy(&x, &a, 4); memcpy(&y, &b, 4);
    return x != y;                        /* signed zeros differ; NaNs compare
                                             by pattern. Both are intended. */
}

int main(void)
{
    eb_modcv_coef c;
    float pcv[NV], kbd[NV], e1[NV], e2[NV];
    float bp[NV], bw[NV];                 /* block outputs */
    float tp, tw;                         /* tick outputs */
    long trials = 200000, i, v, bad = 0, checked = 0;

    for (i = 0; i < trials; ++i) {
        float *f = (float *)&c;
        size_t nf = sizeof(c) / sizeof(float), k;
        float lfo_del, lfo_undel;

        for (k = 0; k < nf; ++k) f[k] = rf();
        lfo_del = rf(); lfo_undel = rf();
        for (v = 0; v < NV; ++v) {
            pcv[v] = rf(); kbd[v] = rf(); e1[v] = rf(); e2[v] = rf();
        }

        eb_modcv_block(&c, NV, pcv, kbd, lfo_del, lfo_undel, e1, e2, bp, bw);

        for (v = 0; v < NV; ++v) {
            eb_modcv_tick(&c, pcv[v], kbd[v], lfo_del, lfo_undel,
                          e1[v], e2[v], &tp, &tw);
            checked += 2;
            if (bits_differ(bp[v], tp) || bits_differ(bw[v], tw)) {
                if (bad < 5)
                    fprintf(stderr,
                            "  MISMATCH trial %ld voice %ld: pitch block %.9g "
                            "tick %.9g | pwm block %.9g tick %.9g\n",
                            i, v, (double)bp[v], (double)tp,
                            (double)bw[v], (double)tw);
                ++bad;
            }
        }
    }

    printf("eb_modcv_block == eb_modcv_tick: %ld comparisons, %ld differing\n",
           checked, bad);
    printf("MODCV BLOCK/TICK EQUIVALENCE: %s\n", bad ? "FAIL" : "PASS");
    return bad ? 1 : 0;
}

/* libm_expf_ab.c — is `expf` bit-identical between the libm the ARM proof used
 * (glibc) and the libm the Teensy actually ships (newlib)?
 *
 * Why this matters: src/voice_render.c calls expf() twice inside the per-sample
 * audio path. fmodf (the engine's other libm call, 24 sites) is safe by
 * construction -- IEEE-754 defines fmod as an EXACT operation, so every
 * conforming implementation returns identical bits. expf is NOT exactly
 * specified: implementations are allowed to differ by fractions of a ULP, and a
 * single differing bit propagates through the filter state and breaks
 * bit-exactness. tools/embed/arm_golden.sh proves the engine on ARM/glibc; it
 * says nothing about ARM/newlib.
 *
 * Method: newlib's own expf object is lifted out of the toolchain's
 * v7e-m+dp/hard libm.a (the exact Cortex-M7 hard-float multilib the Teensy
 * builds against), its symbol renamed, and linked beside glibc's expf in one
 * armhf binary. Both are then called on identical inputs and compared as raw
 * bit patterns. Same machine, same registers, same ABI -- the only variable is
 * the implementation.
 *
 * Driven by tools/embed/libm_expf_ab.sh. Reports the worst ULP delta found.
 */
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <math.h>

float newlib_expf(float);        /* renamed out of newlib's libm.a */

/* newlib's math_errf.c sets errno through __errno(); glibc spells the same thing
 * __errno_location(). Supply the newlib name so the object links. errno plays no
 * part in the returned bit pattern, which is all this test compares. */
int *__errno(void);
int *__errno(void) { static int e; return &e; }

static uint32_t bits(float f) { uint32_t u; memcpy(&u, &f, 4); return u; }

static long long ulps(float a, float b)
{
    int32_t x, y;
    uint32_t ua = bits(a), ub = bits(b);
    /* map to a monotone signed ordering so the subtraction counts ULP steps */
    x = (ua & 0x80000000u) ? (int32_t)(0x80000000u - (ua & 0x7fffffffu)) : (int32_t)ua;
    y = (ub & 0x80000000u) ? (int32_t)(0x80000000u - (ub & 0x7fffffffu)) : (int32_t)ub;
    return (long long)x - (long long)y;
}

static long long worst;
static float    worst_at;
static long     diffs, total;

static void probe(float x)
{
    float g = expf(x), n = newlib_expf(x);
    long long d;
    total++;
    if (bits(g) == bits(n)) return;
    /* NaN payloads are not required to match and never reach the audio path */
    if (isnan(g) && isnan(n)) return;
    diffs++;
    d = ulps(g, n);
    if (d < 0) d = -d;
    if (d > worst) { worst = d; worst_at = x; }
}

int main(void)
{
    long i;

    /* 1. The engine's real domain. voice_render.c:776 feeds expf a smoothed
     *    envelope/LFO product; :1239 feeds it an integer-valued float from a
     *    frexp-style split. Both live in a modest range around zero, so sweep
     *    it densely rather than sampling a huge span thinly. */
    for (i = -12000000; i <= 12000000; ++i) probe((float)i * 1e-5f);   /* [-120,120] step 1e-5 */

    /* 2. Exact integers, which is what site :1239 actually passes. */
    for (i = -200; i <= 200; ++i) probe((float)i);

    /* 3. Every representable float in [2^-30, 2^7] by exponent-stepped bit
     *    patterns, to catch a table-boundary discrepancy the linear sweep
     *    above would step straight over. */
    for (i = 0; i < 4000000; ++i) {
        uint32_t u = 0x30000000u + (uint32_t)i * 0x40u;   /* ascending magnitudes */
        float f; memcpy(&f, &u, 4);
        if (f > 128.0f) break;
        probe(f);
        probe(-f);
    }

    /* 4. Edges: zero, subnormals, infinities, the overflow/underflow knees. */
    {
        static const float edge[] = {
            0.0f, -0.0f, 1e-45f, -1e-45f, 1.1754944e-38f, -1.1754944e-38f,
            88.7228f, 88.7229f, 88.8f, -87.3f, -103.9f, -104.0f, -150.0f,
            1.0f, -1.0f, 0.6931472f, -0.6931472f, 709.0f, -709.0f
        };
        size_t k;
        for (k = 0; k < sizeof edge / sizeof *edge; ++k) probe(edge[k]);
        probe(INFINITY); probe(-INFINITY);
    }

    printf("compared %ld inputs\n", total);
    if (diffs == 0) {
        printf("RESULT: glibc expf == newlib expf, BIT-IDENTICAL on all %ld\n", total);
        printf("        -> the engine's expf use is safe on Teensy/newlib.\n");
        return 0;
    }
    printf("RESULT: %ld / %ld inputs DIFFER  (worst %lld ULP at x = %.9g)\n",
           diffs, total, worst, (double)worst_at);
    printf("        -> expf must be pinned before trusting bit-exactness on\n");
    printf("           hardware; the golden corpus will fail on device.\n");
    return 1;
}

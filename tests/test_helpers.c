/* test_helpers.c — sanity checks for the transcribed leaf helpers.
 *
 * These are transcription self-checks, not the project's per-stage validation
 * (that compares against the decompile's intermediate signals). They guard
 * against typos by re-deriving each helper's semantics independently and by
 * asserting structural properties the decompile guarantees.
 */
#include "../src/juno_dsp.h"
#include <math.h>
#include <stdio.h>

static int failures = 0;

static void check(int cond, const char *what, float in, float got, float ref)
{
    if (!cond) {
        printf("FAIL %-22s in=%.9g got=%.9g ref=%.9g\n", what, in, got, ref);
        ++failures;
    }
}

/* Independent reference for juno_triangle: wrap to [-1,1), piecewise triangle. */
static float ref_triangle(float p)
{
    if (p > 1.0f)       p = fmodf(p + 1.0f, 2.0f) - 1.0f;
    else if (p < -1.0f) p = fmodf(p - 1.0f, 2.0f) + 1.0f;
    if (p >= -0.5f && p <= 0.5f) return 2.0f * p;
    if (p > 0.5f)                return 2.0f - 2.0f * p;
    return -2.0f - 2.0f * p;
}

int main(void)
{
    /* triangle: matches the independent reference across several periods */
    for (float p = -3.0f; p <= 3.0f; p += 0.013f) {
        float got = juno_triangle(p), ref = ref_triangle(p);
        check(fabsf(got - ref) < 1e-6f, "triangle==ref", p, got, ref);
    }
    /* triangle: known anchor points */
    check(fabsf(juno_triangle(0.0f) - 0.0f)  < 1e-6f, "triangle(0)",   0.0f,  juno_triangle(0.0f),  0.0f);
    check(fabsf(juno_triangle(0.5f) - 1.0f)  < 1e-6f, "triangle(.5)",  0.5f,  juno_triangle(0.5f),  1.0f);
    check(fabsf(juno_triangle(-0.5f) + 1.0f) < 1e-6f, "triangle(-.5)", -0.5f, juno_triangle(-0.5f), -1.0f);
    /* triangle: output stays within [-1,1] over a wide sweep */
    for (float p = -10.0f; p <= 10.0f; p += 0.001f) {
        float y = juno_triangle(p);
        check(y >= -1.0001f && y <= 1.0001f, "triangle range", p, y, 0.0f);
    }

    /* wrap24 computes wrapToSigned(2*x) on a 24-bit grid: the decompile doubles
     * the fixed-point value (v2 = 2*v1) before masking to 24 bits. Reference:
     * double, then wrap into [-1,1). Compare within a few 2^-24 quanta and avoid
     * exact half-integer boundaries where the tie rule applies. */
    const float q = 5.960464477539063e-08f; /* 2^-24 */
    for (float x = -2.0f; x <= 2.0f; x += 0.0007f) {
        float r = 2.0f * x;
        while (r >= 1.0f)  r -= 2.0f;
        while (r < -1.0f)  r += 2.0f;
        float y = juno_wrap24(x);
        /* skip points landing on a wrap boundary (|r| within a quantum of 1) */
        if (fabsf(fabsf(r) - 1.0f) < 8.0f * q) continue;
        check(fabsf(y - r) <= 8.0f * q, "wrap24 double-wrap", x, y, r);
    }
    /* small inputs: no wrap, output is exactly ~2x */
    for (float x = -0.49f; x <= 0.49f; x += 0.0007f) {
        float y = juno_wrap24(x);
        check(fabsf(y - 2.0f * x) <= 8.0f * q, "wrap24 2x", x, y, 2.0f * x);
    }
    /* wrap24: output always within (-1,1) */
    for (float x = -5.0f; x <= 5.0f; x += 0.01f) {
        float y = juno_wrap24(x);
        check(y > -1.0001f && y < 1.0001f, "wrap24 range", x, y, 0.0f);
    }

    if (failures == 0)
        printf("OK: all helper self-checks passed\n");
    else
        printf("%d failures\n", failures);
    return failures ? 1 : 0;
}

/* triangle.h — juno_triangle without the fmodf call.
 *
 * The reference (src/juno_dsp.c:54) wraps phase into [-1,1) with fmodf, then
 * maps piecewise to a triangle. The arithmetic is trivial; the cost is the
 * libm call. DENSITY.json measures juno_triangle at 87 static instructions but
 * 1,969 DYNAMIC instructions per sample (rho 22.6) -- it is called several times
 * per sample by the master and the cost is almost entirely fmodf.
 *
 * A phase accumulator moves by a small increment each sample, so it never needs
 * a general remainder: one conditional add or subtract covers it. Subtracting
 * 2.0f from a float is EXACT while the result stays in range, so the cheap path
 * is not an approximation -- it is the same value. Out-of-range inputs fall back
 * to fmodf so behaviour is preserved everywhere, not just where we expect.
 *
 * Verified EXHAUSTIVELY: all 2^32 float32 bit patterns, bit-identical to the
 * reference. See test_triangle.c.
 */
#ifndef ENGINEB_TRIANGLE_H
#define ENGINEB_TRIANGLE_H

#include <math.h>

static inline float eb_triangle(float phase)
{
    /* The reference computes fmodf(phase +/- 1, 2) -/+ 1. That leading add ROUNDS,
     * so replacing the whole thing with a plain subtract is NOT bit-identical --
     * it disagrees on 8,388,608 of the 2^32 inputs, starting immediately above
     * 1.0. The rounding has to be reproduced, not avoided. For |t| < 4 the
     * remainder itself is a single exact add or subtract, so only the libm CALL
     * is removed, never the arithmetic. */
    if (phase > 1.0f) {
        float t = phase + 1.0f;                          /* rounds -- keep it */
        phase = (t < 4.0f) ? (t - 2.0f) - 1.0f
                           : fmodf(t, 2.0f) - 1.0f;
    } else if (phase < -1.0f) {
        float t = phase - 1.0f;                          /* rounds -- keep it */
        phase = (t > -4.0f) ? (t + 2.0f) + 1.0f
                            : fmodf(t, 2.0f) + 1.0f;
    }

    float v2 = phase + phase;
    if (phase >= -0.5f)
        return (phase <= 0.5f) ? v2 : 2.0f - v2;
    return -2.0f - v2;
}

#endif

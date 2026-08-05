/* test_eb_dsp.c — engine B's own copies of the four shared DSP primitives must
 * be BIT-IDENTICAL to the port's.
 *
 * WHY THIS TEST EXISTS. eb_dsp.c is a hand copy of four functions out of
 * src/juno_dsp.c, made so the trunk links without the port (see eb_dsp.h). A
 * hand copy is exactly the kind of thing that is right on the day it is written
 * and wrong two edits later, and no null gate would notice: every null build
 * links the whole port anyway, which is how the original dependency stayed
 * invisible for as long as it did.
 *
 * So this compares the two implementations directly, over domains chosen to hit
 * every branch of each function rather than a comfortable middle:
 *   - the wraps: below -1, inside, above +1, and exactly on the boundaries;
 *   - the triangle: all three output arms plus both wrap arms;
 *   - the pitch polynomial: across the whole clamped domain AND outside it on
 *     both sides, since the clamp is part of the function.
 *
 * Equality is on the BITS, not on a tolerance. These are transcriptions; a
 * tolerance would let a genuinely different function through.
 */
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "eb_dsp.h"
#include "juno_dsp.h"

static int bad;

static void cf(float a, float b, const char *what, double at)
{
    unsigned x, y;
    memcpy(&x, &a, 4); memcpy(&y, &b, 4);
    if (x != y) {
        if (++bad < 10)
            fprintf(stderr, "  FAIL %s(%.9g): eb=%.9g (0x%08x) port=%.9g (0x%08x)\n",
                    what, at, (double)a, x, (double)b, y);
    }
}

static void cd(double a, double b, const char *what, double at)
{
    unsigned long long x, y;
    memcpy(&x, &a, 8); memcpy(&y, &b, 8);
    if (x != y) {
        if (++bad < 10)
            fprintf(stderr, "  FAIL %s(%.17g): eb=%.17g port=%.17g\n",
                    what, at, a, b);
    }
}

int main(void)
{
    int i;
    long n = 0;

    /* The wraps and the triangle, over [-8, 8] finely plus the exact
     * boundaries the branches test against. */
    static const float EDGE[] = { -1.0f, 1.0f, -0.5f, 0.5f, 0.0f,
                                  -1.0000001f, 1.0000001f,
                                  -0.9999999f, 0.9999999f,
                                  -3.0f, 3.0f, -2.0f, 2.0f };
    for (i = 0; i < (int)(sizeof EDGE / sizeof EDGE[0]); ++i) {
        float x = EDGE[i];
        cf(eb_triangle_wrap(x), juno_triangle(x), "triangle", x);
        cf(eb_wrap_unit(x), juno_wrap_unit(x), "wrap_unit", x);
        cf(eb_wrap_hi(x), juno_wrap_hi(x), "wrap_hi", x);
        n += 3;
    }
    for (i = -80000; i <= 80000; ++i) {
        float x = (float)i * 1e-4f;
        cf(eb_triangle_wrap(x), juno_triangle(x), "triangle", x);
        cf(eb_wrap_unit(x), juno_wrap_unit(x), "wrap_unit", x);
        cf(eb_wrap_hi(x), juno_wrap_hi(x), "wrap_hi", x);
        n += 3;
    }

    /* The pitch polynomial across the clamped domain [-20, 8.9] and OUTSIDE it
     * on both sides -- the clamp is part of the function and a copy that
     * dropped it would agree everywhere in the middle. */
    for (i = -25000; i <= 15000; ++i) {
        double x = (double)i * 1e-3;
        cd(eb_pitch_poly(x), juno_pitch_poly(x), "pitch_poly", x);
        ++n;
    }

    printf("EB_DSP vs the port: %s  (%ld comparisons)\n",
           bad ? "FAIL" : "BIT-IDENTICAL", n);
    if (bad)
        fprintf(stderr, "  %d differing value(s)\n", bad);
    return bad ? 1 : 0;
}

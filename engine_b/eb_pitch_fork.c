/* eb_pitch_fork.c — see eb_pitch_fork.h. FORK code; the trunk is eb_pitch.c. */
#include "eb_pitch_fork.h"
#include "eb_pitch_fork_tab.h"
#include <math.h>

float eb_pitch_fork_eval(float x)
{
    /* The clamp mirrors the port's fmin(fmax(x,-20),8.9). (float)8.9 is
     * 8.8999996..., BELOW the double 8.9, so the float clamp can only land
     * inside the port's domain, never outside it. The sliver of inputs in
     * ((float)8.9, 8.9) does not exist in float, so nothing is lost. */
    /* THE NaN TEST IS EXPLICIT, and the reason is a measured failure, not
     * style. The first version used fminf(fmaxf(x,-20),8.9): for a QUIET
     * NaN that lands at -20 like the port, but for a SIGNALING NaN IEEE
     * maxNum returns a quieted NaN instead of the number, so fminf then
     * chose 8.9 -- and the exhaustive gate caught fork(sNaN)=P(8.9) where
     * the port gives P(-20) (its float->double conversion quiets every
     * NaN before its clamp). x != x is true for BOTH payload classes, so
     * every NaN follows the port to -20; after it, plain comparisons are
     * safe. Only an EXHAUSTIVE gate could have found this: the failing
     * inputs are a payload class of NaN, which no sweep ever visits. */
    if (x != x) x = -20.0f;
    if (x < -20.0f) x = -20.0f;
    if (x > 8.9f)   x = 8.9f;

    /* ROW SELECTION MUST MATCH THE PORT'S EXACTLY, and it does, by this
     * argument and not by luck: the port computes (int)(v1 + 20.0) in
     * double, where v1 is the clamped value. A float widens to double
     * exactly, and adding 20 to a double of magnitude <= 20 with a 24-bit
     * significand is exact, so the port's row is floor(v1) + 20 with no
     * rounding anywhere. floorf here is the same function. An earlier shape
     * of this line was (int)(x + 20.0f) -- WRONG, because the FLOAT add can
     * round up across an integer boundary and select the next row. */
    int r = (int)floorf(x) + 20;
    if (r > 28) r = 28;             /* x == +8.x -> row 28 */
    if (r < 0)  r = 0;              /* unreachable after the clamp; belt */

    /* t is EXACT: x and the center c share binade neighbourhoods and
     * |x - c| <= 0.5 with both operands multiples of ulp(20) at worst, so
     * the subtraction is representable (Sterbenz for the near cases; for
     * tiny x against c = +/-0.5 the rounding is <= ulp(0.5) = 6e-8, worth
     * < 1e-4 cents through the spline's slope -- measured, not assumed:
     * the exhaustive gate covers every such input). */
    {
        const float *b = eb_pitch_fork_tab[r];
        float t = x - ((float)r - 19.5f);
        float p = b[12];
        int j;
        for (j = 11; j >= 0; --j)
            p = p * t + b[j];
        return p;
    }
}

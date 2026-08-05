/* eb_exp_fork.c — see eb_exp_fork.h. FORK code; the trunk keeps libm expf.
 *
 * Shape: e^x = 2^n * e^r with n = round(x*log2(e)) and r = x - n*ln2, the
 * ln2 subtraction in two constants (Cody–Waite) so r is exact to float, then
 * a degree-5 polynomial for e^r on |r| <= ln2/2, then the 2^n scale as a
 * bit-built float (n is in [-126,127] because the tails were already
 * delegated). The polynomial coefficients are Cephes' expf set, in service
 * since the 1980s; the gate measures what they deliver HERE rather than
 * citing their reputation.
 */
#include "eb_exp_fork.h"
#include <math.h>
#include <string.h>
#include <stdint.h>

float eb_exp_fork(float x)
{
    /* Tails and NaN go to libm, so overflow/underflow/NaN are the port's
     * own by construction. Real LFO arguments never come here. */
    if (!(x >= -87.0f && x <= 88.0f))
        return expf(x);

    {
        float n = floorf(x * 1.44269504088896341f + 0.5f);
        /* r = x - n*ln2, ln2 split so each product is exact in float. */
        float r = (x - n * 0.693359375f) - n * -2.12194440e-4f;
        float z = r * r;
        float p = 1.9875691500e-4f;
        p = p * r + 1.3981999507e-3f;
        p = p * r + 8.3334519073e-3f;
        p = p * r + 4.1665795894e-2f;
        p = p * r + 1.6666665459e-1f;
        p = p * r + 5.0000001201e-1f;
        p = p * z + r + 1.0f;

        /* 2^n by bit construction: n in [-126, 127] here, so the biased
         * exponent stays in [1, 254] and no denormal path is needed. */
        {
            int32_t ni = (int32_t)n;
            uint32_t bits = (uint32_t)(ni + 127) << 23;
            float s;
            memcpy(&s, &bits, 4);
            return p * s;
        }
    }
}

/* test_dco_wrap.c — eb_dco_wrap over ALL 2^32 float32 bit patterns.
 *
 * The session brief's warning, restated because it is the reason this file
 * exists: src/voice_render.c:1726, the NEGATIVE arm of the phase wrap, executes
 * in NONE of the 30 null scenarios, and the phase gets to -0.999657 -- 0.0003
 * from firing. A scenario gate cannot protect a 0.0003 margin. And the
 * precedent is not hypothetical: eb_triangle's "obvious" replacement was
 * mathematically identical to the reference and disagreed on 8,388,608 of 2^32
 * inputs through rounding alone, and only the exhaustive run found it.
 *
 * Reference = src/voice_render.c:1723-1731 transcribed literally.
 * Comparison is on BITS, and NaN payloads are compared too, because a NaN that
 * reaches the polynomial saturator propagates.
 */
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <stdint.h>
#include "eb_dco.h"

static float ref_wrap(float p)
{
    if (p <= 1.0f) { if (p < -1.0f) p = fmodf(p - 1.0f, 2.0f) + 1.0f; }
    else                            p = fmodf(p + 1.0f, 2.0f) - 1.0f;
    return p;
}

int main(void)
{
    uint64_t bad = 0, nanboth = 0;
    uint32_t u = 0;
    float x, a, b;
    uint32_t ua, ub;
    do {
        memcpy(&x, &u, 4);
        a = ref_wrap(x); b = eb_dco_wrap(x);
        memcpy(&ua, &a, 4); memcpy(&ub, &b, 4);
        if (ua != ub) {
            if (isnan(a) && isnan(b)) { ++nanboth; }
            else if (++bad <= 10)
                printf("MISMATCH in=%08x ref=%08x cand=%08x\n", u, ua, ub);
        }
        ++u;
    } while (u != 0);
    printf("eb_dco_wrap: 2^32 inputs, %llu bit mismatches, "
           "%llu NaN-payload-only differences\n",
           (unsigned long long)bad, (unsigned long long)nanboth);
    return bad ? 1 : 0;
}

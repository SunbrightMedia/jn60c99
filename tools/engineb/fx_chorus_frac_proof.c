/* fx_chorus_frac_proof.c -- EXHAUSTIVE proof that the DOUBLE in the chorus tap
 * fraction can be removed.
 *
 * src/master_render.c:2878 computes the interpolation fraction as
 *      v638 = (float)(v636 * 16384.0) - (double)(int)(float)(v636 * 16384.0);
 * i.e. the subtraction happens in DOUBLE and the result is rounded to float.
 * On the ESP32-S3 that is 8 soft-float helper calls per sample
 * (__extendsfdf2 / __floatsidf / __subdf3 / __truncdfsf2), MEASURED-STATIC by
 * tools/engineb/cost.py. Doing it in float instead is the obvious replacement
 * and this project has already been burned once by an "obvious" float
 * replacement (fmodf, wrong on 8,388,608 of 2^32 inputs). So it is not argued,
 * it is ENUMERATED: every float bit pattern whose value lies in [-1024, 1024)
 * -- which strictly contains the reachable range (the delay in samples is
 * 72..456 at 48 kHz, MEASURED) -- is checked for
 *      (float)((double)t - (double)(int)t)  ==  t - (float)(int)t
 * bit for bit, including the sign of zero.
 *
 * Build: cc -O2 -ffp-contract=off -o /tmp/fracproof fx_chorus_frac_proof.c -lm
 */
#include <stdio.h>
#include <stdint.h>
#include <string.h>

int main(void)
{
    uint64_t n = 0, bad = 0;
    uint32_t u;
    uint32_t firstbad = 0;
    /* |t| < 1024  <=>  biased exponent <= 136  <=>  bits < 0x44800000 */
    for (u = 0; u < 0x44800000u; ++u) {
        float t; double d; float a, b; uint32_t ua, ub;
        memcpy(&t, &u, 4);
        d = (double)t - (double)(int)t;
        a = (float)d;
        b = t - (float)(int)t;
        memcpy(&ua, &a, 4); memcpy(&ub, &b, 4);
        ++n;
        if (ua != ub) { if (!bad) firstbad = u; ++bad; }
        /* negative counterpart */
        { uint32_t un = u | 0x80000000u;
          memcpy(&t, &un, 4);
          d = (double)t - (double)(int)t;
          a = (float)d;
          b = t - (float)(int)t;
          memcpy(&ua, &a, 4); memcpy(&ub, &b, 4);
          ++n;
          if (ua != ub) { if (!bad) firstbad = un; ++bad; } }
    }
    printf("checked %llu float inputs in (-1024,1024), mismatches %llu",
           (unsigned long long)n, (unsigned long long)bad);
    if (bad) printf(" first at bits 0x%08x", firstbad);
    printf("\n");
    return bad != 0;
}

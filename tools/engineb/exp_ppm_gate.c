/* exp_ppm_gate.c — the EXHAUSTIVE ppm gate for the fork exponential (F3).
 *
 * Every float32 bit pattern through eb_exp_fork and through the port's expf.
 * In the delegated tails the two must be BIT-IDENTICAL (the fork calls expf
 * there; the gate verifies rather than trusts). In the polynomial region the
 * relative error is bounded in ppm. Where expf underflows toward zero the
 * relative measure blows up on quantization; below a floor the gate bounds
 * ULP distance instead — stated, not hidden.
 *
 * usage: exp_ppm_gate <lo_u32> <hi_u32>
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <stdint.h>
#include "eb_exp_fork.h"

int main(int argc, char **argv)
{
    if (argc != 3) { fprintf(stderr, "usage: lo hi\n"); return 2; }
    uint64_t lo = strtoull(argv[1], 0, 0), hi = strtoull(argv[2], 0, 0);
    double wppm = 0; float wat = 0;
    int32_t wulp = 0; float wulp_at = 0;
    uint64_t n = 0, tailmis = 0;

    for (uint64_t u = lo; u < hi; ++u) {
        float x; uint32_t b = (uint32_t)u;
        memcpy(&x, &b, 4);
        float f = eb_exp_fork(x);
        float r = expf(x);
        ++n;
        if (!(x >= -87.0f && x <= 88.0f)) {
            uint32_t bf, br;
            memcpy(&bf, &f, 4); memcpy(&br, &r, 4);
            /* NaN payloads may differ between two calls' quieting; equal
             * NaN-ness is the contract, not payload bits. */
            if (bf != br && !(f != f && r != r)) ++tailmis;
            continue;
        }
        if (r >= 1e-30f) {
            double ppm = fabs((double)f / (double)r - 1.0) * 1e6;
            if (ppm > wppm) { wppm = ppm; wat = x; }
        } else {
            int32_t bf, br;
            memcpy(&bf, &f, 4); memcpy(&br, &r, 4);
            int32_t d = bf - br; if (d < 0) d = -d;
            if (d > wulp) { wulp = d; wulp_at = x; }
        }
    }
    printf("RANGE %08x..%08x n=%llu tailmis=%llu\n", (unsigned)lo,
           (unsigned)hi, (unsigned long long)n, (unsigned long long)tailmis);
    printf("WPPM %.9g at %a\n", wppm, (double)wat);
    printf("WULP %d at %a\n", (int)wulp, (double)wulp_at);
    return 0;
}

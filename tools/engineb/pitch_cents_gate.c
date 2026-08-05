/* pitch_cents_gate.c — THE EXHAUSTIVE CENTS GATE for the fork pitch (F3).
 *
 * EXHAUSTIVE MEANS EXHAUSTIVE: every one of the 2^32 float32 bit patterns is
 * driven through BOTH evaluators — eb_pitch_fork_eval (the candidate) and the
 * PORT's own juno_pitch_poly in double (the reference, itself bit-exact to
 * the plugin under the null harness). No sampling, no "dense sweep": a sweep
 * at 1e-5 steps is 3 million points; this is 4.3 billion, and the difference
 * is precisely the inputs a sweep never lands on.
 *
 * THE MEASURE is 1200*log2(Pf/Pd) — cents — wherever that is meaningful, and
 * absolute error where it is not. It is NOT meaningful near the spline's own
 * zeros: there the PLUGIN's value is dominated by its own 2^37-amplified
 * rounding (pitch_p2_study.md, measured in exact rationals), so a relative
 * comparison there grades the plugin's noise, not the candidate. The gate
 * therefore reports by |Pd| band and applies the 0.05-cent bound where
 * |Pd| >= 1e-3; below that it bounds the ABSOLUTE gap against the plugin's
 * own noise scale. Both bounds print; neither is silent.
 *
 * Run via pitch_cents_gate.py, which compiles this file fresh (no stale
 * binary can be trusted -- this project has been bitten by that twice) and
 * fans the bit-space across cores.
 *
 * usage: pitch_cents_gate <lo_u32> <hi_u32>   (inclusive, exclusive)
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <stdint.h>
#include "eb_pitch_fork.h"

double juno_pitch_poly(double x);      /* the PORT's own, src/juno_dsp.c */

int main(int argc, char **argv)
{
    if (argc != 3) { fprintf(stderr, "usage: lo hi\n"); return 2; }
    uint64_t lo = strtoull(argv[1], 0, 0), hi = strtoull(argv[2], 0, 0);

    /* bands of |Pd|: [1,inf) [0.3,1) [0.1,0.3) [1e-2,0.1) [1e-3,1e-2) ;
     * below 1e-3 absolute-error accounting. */
    static const double EDGE[5] = { 1.0, 0.3, 0.1, 1e-2, 1e-3 };
    double wcents[5] = {0}; float wat[5] = {0};
    double wabs = 0; float wabs_at = 0; double wabs_ref = 0;
    uint64_t n = 0, nsub = 0;

    for (uint64_t u = lo; u < hi; ++u) {
        float x; uint32_t b = (uint32_t)u;
        memcpy(&x, &b, 4);
        float  pf = eb_pitch_fork_eval(x);
        double pd = juno_pitch_poly((double)x);
        ++n;
        double apd = fabs(pd);
        if (apd >= 1e-3) {
            /* sign must agree where the value is this large, or the ratio
             * is meaningless and the candidate is simply wrong. */
            if (!(pf * pd > 0.0)) {
                printf("SIGNFAIL at bits %08x x=%a pf=%a pd=%a\n",
                       (unsigned)b, (double)x, (double)pf, pd);
                return 1;
            }
            double cents = fabs(1200.0 * log2((double)pf / pd));
            int k = apd >= EDGE[0] ? 0 : apd >= EDGE[1] ? 1 :
                    apd >= EDGE[2] ? 2 : apd >= EDGE[3] ? 3 : 4;
            if (cents > wcents[k]) { wcents[k] = cents; wat[k] = x; }
        } else {
            double d = fabs((double)pf - pd);
            ++nsub;
            if (d > wabs) { wabs = d; wabs_at = x; wabs_ref = pd; }
        }
    }
    printf("RANGE %08x..%08x  n=%llu  sub1e-3=%llu\n",
           (unsigned)lo, (unsigned)hi, (unsigned long long)n,
           (unsigned long long)nsub);
    for (int k = 0; k < 5; ++k)
        printf("BAND %d worst_cents %.9g at %a\n", k, wcents[k], (double)wat[k]);
    printf("SUB worst_abs %.9g at %a ref %a\n", wabs, (double)wabs_at, wabs_ref);
    return 0;
}

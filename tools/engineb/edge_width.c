/* Is the DCO's edge width in SAMPLES independent of pitch?
 *
 * Derived: the edge half-width in the triangle argument is inc4/(2*amp);
 * x = t/(pw-1) puts it at |pw-1|*inc4/(2*amp) in phase; the phase advances
 * 4*inc4 per output sample; so the half-width in SAMPLES is |pw-1|/(8*amp)
 * and inc4 CANCELS.
 *
 * If that holds, a step residual indexed by TIME is pitch-independent, the
 * mip dimension collapses, and the table goes from 7.5 MB to tens of KB.
 * The project's standard is that a derivation is a hypothesis until it is
 * executed, so this measures it: run the real eb_dco_step at several pitches
 * and count how far the pulse edge travels, in OUTPUT SAMPLES, between
 * saturation and saturation.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "eb_fork_config.h"
#include "eb_dco.h"
#include "c6_realcoefs.h"

int main(void)
{
    float incs[5] = { 0.0025f, 0.005f, 0.02f, 0.08f, 0.12f };
    int q;
    printf("%10s %14s %14s\n", "~f0 Hz", "edge width", "in OUTPUT samples");
    for (q = 0; q < 5; ++q) {
        float inc4 = incs[q];
        eb_dco_state s; eb_dco_coef c;
        /* sub-sample the oscillator finely so the edge is resolved, then
         * express the width in units of the OUTPUT sample it would have. */
        const int OS = 4096;
        long nsteps;
        double sub = (double)inc4 * 4.0 / OS;   /* phase per fine step */
        long i; int inedge = 0; long cnt = 0, best = 0;
        memset(&s, 0, sizeof s); memset(&c, 0, sizeof c);
        c.inc = (float)sub;
        c.g = 0.00390625f / inc4;
        c.pw = RC_pw; c.pwm1 = c.pw - 1.0f; c.pwp1 = c.pw + 1.0f;
#if EB_DCO_RECIP
        c.rm1 = 1.0f / c.pwm1; c.rp1 = 1.0f / c.pwp1;
#endif
        c.lvl_pulse = RC_lvl_pulse;      /* PULSE ARM ONLY */
        c.gn_pulse = RC_gn_pulse; c.amp_pulse = RC_amp_pulse;
        c.sat_in = RC_sat_in;   c.subthr = RC_subthr;
        c.k3=RC_k3; c.k5=RC_k5; c.k7=RC_k7; c.k9=RC_k9; c.k11=RC_k11;
        { float x=c.sat_in,x2=x*x,x3=x*x2,x5=x3*x2,x7=x5*x2,x9=x7*x2,x11=x9*x2;
          c.sat_hi = x + x3*c.k3 + x5*c.k5 + x7*c.k7 + x9*c.k9 + x11*c.k11; }
        { float x=-c.sat_in,x2=x*x,x3=x*x2,x5=x3*x2,x7=x5*x2,x9=x7*x2,x11=x9*x2;
          c.sat_lo = x + x3*c.k3 + x5*c.k5 + x7*c.k7 + x9*c.k9 + x11*c.k11; }
        {   float hi = fabsf(c.sat_hi * c.gn_pulse * c.lvl_pulse);
            nsteps = (long)(2.5 / sub);   /* a FULL period, plus a margin.
                                           * The first version ran OS*3 fine
                                           * steps, which at the lowest pitch
                                           * covers 1.5 %% of a period -- it met
                                           * no edge at all and reported 0. */
            for (i = 0; i < nsteps; ++i) {
                float v = fabsf(eb_dco_step(&s, &c));
                int flat = v > hi * 0.999f;
                if (!flat) { ++cnt; inedge = 1; }
                else if (inedge) { if (cnt > best) best = cnt; cnt = 0; inedge = 0; }
            }
        }
        printf("%10.0f %14ld %14.4f\n", inc4 / 2 * 4 * 44100.0, best,
               (double)best / OS);
    }
    return 0;
}

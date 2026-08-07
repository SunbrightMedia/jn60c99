/* The band-limited DCO against the 4x path it replaces, at MODULE level.
 * Isolating it from the engine is the point: a whole-engine null cannot say
 * whether a disagreement is the oscillator, its delay, or something the
 * decimator does downstream. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "eb_fork_config.h"
#include "eb_dco.h"
#include "eb_dco_wt.h"
#include "eb_decim.h"
#include "c6_realcoefs.h"
#define N 40000
static float A[N], B[N];
int main(int argc, char **argv)
{
    float inc4 = argc > 1 ? (float)atof(argv[1]) : 0.005f;
    eb_dco_coef dc; eb_dco_state ds;
    eb_dco_wt_coef wc; eb_dco_wt_state ws;
    int i, best = 0; double bc = -1e30, ra = 0, rb = 0;
    memset(&ds,0,sizeof ds); memset(&ws,0,sizeof ws); memset(&dc,0,sizeof dc);
    memset(&wc,0,sizeof wc);
    dc.inc = inc4; dc.g = 0.00390625f/inc4;
    dc.pw = RC_pw; dc.pwm1 = dc.pw-1.0f; dc.pwp1 = dc.pw+1.0f;
    dc.rm1 = 1.0f/dc.pwm1; dc.rp1 = 1.0f/dc.pwp1;
    dc.lvl_saw=RC_lvl_saw; dc.lvl_pulse=RC_lvl_pulse; dc.lvl_sub=RC_lvl_sub;
    dc.gn_saw=RC_gn_saw; dc.gn_pulse=RC_gn_pulse; dc.gn_sub=RC_gn_sub;
    dc.amp_saw=RC_amp_saw; dc.amp_pulse=RC_amp_pulse; dc.amp_sub=RC_amp_sub;
    dc.sat_in=RC_sat_in; dc.subthr=RC_subthr;
    dc.k3=RC_k3;dc.k5=RC_k5;dc.k7=RC_k7;dc.k9=RC_k9;dc.k11=RC_k11;
    {float x=dc.sat_in,x2=x*x,x3=x*x2,x5=x3*x2,x7=x5*x2,x9=x7*x2,x11=x9*x2;
     dc.sat_hi=x+x3*dc.k3+x5*dc.k5+x7*dc.k7+x9*dc.k9+x11*dc.k11;}
    {float x=-dc.sat_in,x2=x*x,x3=x*x2,x5=x3*x2,x7=x5*x2,x9=x7*x2,x11=x9*x2;
     dc.sat_lo=x+x3*dc.k3+x5*dc.k5+x7*dc.k7+x9*dc.k9+x11*dc.k11;}
    eb_dco_set_edge_thresholds(&dc);
    /* the 4x reference: eb_dco_step4 (4 sub-steps) with no decimator, so this
     * compares the OSCILLATORS and nothing else */
    /* FOUR CALLS TO eb_dco_step, NOT eb_dco_step4. EB_DCO_WT implies
     * EB_QUARTER_OS, which makes eb_dco_step4 emit ONE sub-sample and three
     * zeros -- so averaging its output gave a quarter of the amplitude and the
     * probe blamed the module for its own reference being wrong. eb_dco_step
     * is one sub-step whatever the flag says. */
    for (i = 0; i < N; ++i) {
        float a0 = eb_dco_step(&ds,&dc), a1 = eb_dco_step(&ds,&dc);
        float a2 = eb_dco_step(&ds,&dc), a3 = eb_dco_step(&ds,&dc);
        A[i] = (a0+a1+a2+a3) * 0.25f;
    }
    eb_dco_wt_bind_tables(&wc);
    wc.sat_hi=dc.sat_hi; wc.sat_lo=dc.sat_lo;
    wc.lvl_saw=dc.lvl_saw; wc.lvl_pulse=dc.lvl_pulse; wc.lvl_sub=dc.lvl_sub;
    wc.gn_saw=dc.gn_saw; wc.gn_pulse=dc.gn_pulse; wc.gn_sub=dc.gn_sub;
    wc.subthr=dc.subthr;
    eb_dco_wt_set_pitch(&wc, inc4*4.0f, dc.pw);
    for (i = 0; i < N; ++i) B[i] = eb_dco_wt_tick(&ws,&wc);
    for (i = 2000; i < N; ++i) { ra += A[i]*A[i]; rb += B[i]*B[i]; }
    printf("f0 %.0f Hz   ref rms %.4f   wt rms %.4f\n",
           inc4/2*4*44100.0, sqrt(ra/(N-2000)), sqrt(rb/(N-2000)));
    for (i = -128; i <= 128; ++i) {
        double c = 0; int k;
        for (k = 4000; k < N-200; ++k) {
            int j = k + i; if (j < 0 || j >= N) continue;
            c += (double)A[k] * B[j];
        }
        if (c > bc) { bc = c; best = i; }
    }
    printf("best lag %+d samples (B leads A by this)\n", best);
    {   double e = 0, s2 = 0; int k;
        for (k = 4000; k < N-200; ++k) {
            int j = k + best; if (j < 0 || j >= N) continue;
            e += ((double)A[k]-B[j])*((double)A[k]-B[j]); s2 += (double)A[k]*A[k];
        }
        printf("aligned residual %.1f dB\n", 10*log10(e/s2));
    }
    return 0;
}

/* The band-limited DCO against the 4x path it replaces, at MODULE level.
 * Isolating it from the engine is the point: a whole-engine null cannot say
 * whether a disagreement is the oscillator, its delay, or something the
 * decimator does downstream. */
#include <stdio.h>
#include <stdlib.h>
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
    float pw0;
    float pwmod = getenv("EB_AB_PWMOD") ? (float)atof(getenv("EB_AB_PWMOD")) : 0.0f;
    float pmod  = getenv("EB_AB_PMOD")  ? (float)atof(getenv("EB_AB_PMOD"))  : 0.0f;
    memset(&ds,0,sizeof ds); memset(&ws,0,sizeof ws); memset(&dc,0,sizeof dc);
    memset(&wc,0,sizeof wc);
    dc.inc = inc4; dc.g = 0.00390625f/inc4;
    /* pw0 IS THE BASE, HELD SEPARATELY. Reading dc.pw as the base inside the
     * candidate loop reads whatever the REFERENCE loop left modulated there,
     * so the two sides ran different pulse widths and the probe reported
     * +1.8 dB at a modulation depth of 0.001. */
    pw0 = getenv("EB_AB_PW") ? (float)atof(getenv("EB_AB_PW")) : RC_pw;
    dc.pw = pw0; dc.pwm1 = dc.pw-1.0f; dc.pwp1 = dc.pw+1.0f;
    dc.rm1 = 1.0f/dc.pwm1; dc.rp1 = 1.0f/dc.pwp1;
    /* ARM SELECTOR via argv[2]: 0 = the patch's own mix, 1 = saw, 2 = pulse,
     * 3 = sub. A whole-mix residual cannot say WHICH arm is wrong, and with
     * three arms and three residual tables that is the first thing to know. */
    dc.lvl_saw=RC_lvl_saw; dc.lvl_pulse=RC_lvl_pulse; dc.lvl_sub=RC_lvl_sub;
    if (argc > 2) {
        int arm = atoi(argv[2]);
        if (arm == 1) { dc.lvl_pulse = 0.0f; dc.lvl_sub = 0.0f;
                        if (dc.lvl_saw == 0.0f) dc.lvl_saw = 1.0f; }
        if (arm == 2) { dc.lvl_saw = 0.0f;   dc.lvl_sub = 0.0f;
                        if (dc.lvl_pulse == 0.0f) dc.lvl_pulse = 1.0f; }
        if (arm == 3) { dc.lvl_saw = 0.0f;   dc.lvl_pulse = 0.0f;
                        if (dc.lvl_sub == 0.0f) dc.lvl_sub = 1.0f; }
    }
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
    /* THE REFERENCE IS THE PORT'S OWN 4x PATH: four sub-steps through the
     * REAL 16-coefficient decimator. A box average of four sub-samples is NOT
     * that filter -- its response rolls off completely differently -- and
     * using one made this probe measure the box against the FIR and call the
     * difference a defect in the module.
     *
     * Build with -DEB_QUARTER_OS_SET=1 -DEB_QUARTER_OS=0 so that EB_DCO_WT can
     * be on (for the candidate) while eb_decim_tick still compiles its 4x arm
     * (for the reference). One binary, both paths, no chance of the two sides
     * differing in anything but the oscillator. */
    {   eb_decim_state xs; eb_decim_coef xc; int j;
        memset(&xs,0,sizeof xs); memset(&xc,0,sizeof xc);
        for (j = 0; j < 16; ++j) xc.c[j] = RC_fir[j];
        xc.k6256 = RC_k6256; xc.k6272 = RC_k6272; xc.k6336 = RC_k6336;
        for (i = 0; i < N; ++i) {
            float q[4];
            /* MODULATED pw AND PITCH, because the engine modulates both every
             * sample and this probe held them fixed. A module gate that runs
             * only static coefficients cannot answer why the same module is
             * 25 dB worse inside the engine. Both sides get the SAME
             * modulation, so any difference is still the oscillator's. */
            if (pwmod != 0.0f || pmod != 0.0f) {
                float ph = (float)i * (2.0f * 3.14159265f * 3.0f / (float)N);
                float pwv = pw0 + pwmod * (float)sin(ph);
                float inv = inc4 * (1.0f + pmod * (float)sin(ph * 1.7f));
                dc.pw = pwv; dc.pwm1 = pwv-1.0f; dc.pwp1 = pwv+1.0f;
                dc.rm1 = 1.0f/dc.pwm1; dc.rp1 = 1.0f/dc.pwp1;
                dc.inc = inv; dc.g = 0.00390625f/inv;
                eb_dco_set_edge_thresholds(&dc);
            }
            q[0] = eb_dco_step(&ds,&dc); q[1] = eb_dco_step(&ds,&dc);
            q[2] = eb_dco_step(&ds,&dc); q[3] = eb_dco_step(&ds,&dc);
            A[i] = eb_decim_tick(&xs,&xc,0.0f,q[0],q[1],q[2],q[3]);
        }
    }
    eb_dco_wt_bind_tables(&wc);
    wc.sat_hi=dc.sat_hi; wc.sat_lo=dc.sat_lo;
    wc.lvl_saw=dc.lvl_saw; wc.lvl_pulse=dc.lvl_pulse; wc.lvl_sub=dc.lvl_sub;
    wc.gn_saw=dc.gn_saw; wc.gn_pulse=dc.gn_pulse; wc.gn_sub=dc.gn_sub;
    wc.subthr=dc.subthr;
    eb_dco_wt_set_pitch(&wc, inc4, dc.pw);
    /* THE BIQUAD RUNS ON THIS SIDE TOO, exactly as eb_render.c does it: the
     * wavetable replaces the decimator's FIR, and the biquad tail stays
     * because it is rate-dependent recall data. Comparing an un-biquadded
     * candidate against a biquadded reference measures the biquad. */
    {   eb_decim_state ys; eb_decim_coef yc; int j;
        memset(&ys,0,sizeof ys); memset(&yc,0,sizeof yc);
        for (j = 0; j < 16; ++j) yc.c[j] = RC_fir[j];
        yc.k6256 = RC_k6256; yc.k6272 = RC_k6272; yc.k6336 = RC_k6336;
        for (i = 0; i < N; ++i) {
            float w;
            if (pwmod != 0.0f || pmod != 0.0f) {
                float ph = (float)i * (2.0f * 3.14159265f * 3.0f / (float)N);
                float pwv = pw0 + pwmod * (float)sin(ph);
                float inv = inc4 * (1.0f + pmod * (float)sin(ph * 1.7f));
                eb_dco_wt_set_pitch(&wc, inv, pwv);
            }
            w = eb_dco_wt_tick(&ws,&wc);
            /* the biquad alone: feed the sample in and zero the other three,
             * which is what the EB_QUARTER_OS arm does */
            ys.b3 = ys.b1; ys.b1 = ys.b2;
            {   float v524 = w, v520 = ys.b1;
                float v521 = v520 * yc.k6256 + ys.b3;
                float v525;
                ys.b1 = v521;
                v525 = v524 - (v520 * yc.k6272 + v521);
                ys.b2 = v525 * yc.k6256 + v520;
                B[i] = ((v521 - v525 * 0.0f) * yc.k6336 - yc.k6336 * v524)
                     + v524;
            }
        }
    }
    for (i = 2000; i < N; ++i) { ra += A[i]*A[i]; rb += B[i]*B[i]; }
    printf("f0 %.0f Hz   ref rms %.4f   wt rms %.4f\n",
           inc4/2*4*44100.0, sqrt(ra/(N-2000)), sqrt(rb/(N-2000)));
    /* THE SEARCH SPAN MUST BE SHORTER THAN A PERIOD, and this probe was
     * caught not being. A saw is nearly periodic, so its correlation has a
     * peak at EVERY period; over +/-128 samples the search picked whole-period
     * offsets and the "aligned" residual it then reported was the module
     * compared against itself one cycle over. That read as a sharp band of
     * failure at inc 0.010 to 0.014 -- -19.5 dB at 0.012 between -53.3 and
     * -44.7 either side -- which is the shape of a broken measurement, not of
     * a broken oscillator.
     *
     * The true lag is not a free parameter: it is EB_WT_RES_LEN/2, the half
     * ring the tick delays its flat path by. So the span defaults to +/-16 and
     * EB_AB_LAG pins it outright. */
    {   int span = getenv("EB_AB_SPAN") ? atoi(getenv("EB_AB_SPAN")) : 16;
        if (getenv("EB_AB_LAG")) { best = atoi(getenv("EB_AB_LAG")); bc = 1; }
        else
    for (i = -span; i <= span; ++i) {
        double c = 0; int k;
        for (k = 4000; k < N-200; ++k) {
            int j = k + i; if (j < 0 || j >= N) continue;
            c += (double)A[k] * B[j];
        }
        if (c > bc) { bc = c; best = i; }
    }
    }
    printf("best lag %+d samples (B leads A by this)\n", best);
    /* WHERE the error is, not just how big. A single dB figure cannot say
     * whether a residual is wrong at the edge or everywhere. */
    if (getenv("EB_AB_DUMP")) {
        int k, e0 = -1;
        /* EB_AB_WORST centres the dump on the LARGEST error instead of the
         * first edge. The first edge is not the worst one when the fault is
         * fraction-dependent: at inc 0.014 the first edge's error is 0.002,
         * which alone would read -55 dB, while the arm measures -19.2. A dump
         * anchored on the first edge cannot see a fault like that at all. */
        if (getenv("EB_AB_WORST")) {
            double bw = -1;
            for (k = 4000; k < N-200; ++k) {
                int j = k + best; double d;
                if (j < 0 || j >= N) continue;
                d = fabs((double)A[k] - B[j]);
                if (d > bw) { bw = d; e0 = k; }
            }
            printf("  worst error %.5f at sample %d\n", bw, e0);
        } else
        for (k = 6000; k < 6400; ++k) {
            int j = k + best;
            if (fabs((double)A[k] - A[k-1]) > 0.25) { e0 = k; break; }   /* the port's edge spans several samples, so no single step is large */
        }
        if (e0 > 0) {
            printf("  around an edge at sample %d:\n", e0);
            /* THE WINDOW IS SETTABLE. A fixed 16-sample dump cannot say
             * whether an error is a misplacement or a TAIL that runs past the
             * residual's own length, and the sub arm needed exactly that
             * question answered. */
            int lo = getenv("EB_AB_LO") ? atoi(getenv("EB_AB_LO")) : -4;
            int hi = getenv("EB_AB_HI") ? atoi(getenv("EB_AB_HI")) : 12;
            for (k = e0 + lo; k < e0 + hi; ++k) {
                int j = k + best;
                printf("    %+3d  port %+9.5f  wt %+9.5f  err %+9.5f\n",
                       k - e0, A[k], B[j], B[j] - A[k]);
            }
        }
    }
    {   double e = 0, s2 = 0; int k;
        for (k = 4000; k < N-200; ++k) {
            int j = k + best; if (j < 0 || j >= N) continue;
            e += ((double)A[k]-B[j])*((double)A[k]-B[j]); s2 += (double)A[k]*A[k];
        }
        printf("aligned residual %.1f dB\n", 10*log10(e/s2));
    }
    return 0;
}

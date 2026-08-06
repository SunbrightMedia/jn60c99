/* o8_alias_probe.c — F5 GATE 2 AGAINST THE REAL IMPLEMENTATION.
 *
 * WHY THIS EXISTS AND WHY THE F5 PROBE DOES NOT REPLACE IT. F5's
 * c6_halfos_probe.c measured an AD-HOC 2x path: a Kaiser half-band it
 * generated itself, driven by hand from the outside. It answered "is the
 * alias LEVEL preservable in principle" and the answer was yes. It cannot
 * answer "does the code that will actually ship preserve it", because none
 * of the code that will ship was in it.
 *
 * This probe builds the SHIPPING modules -- eb_dco.c and eb_decim.c, no
 * copies -- twice from one source file: once with EB_HALF_OS=0 (the port's
 * 4x path, the reference and the plugin's own alias floor) and once with
 * EB_HALF_OS=1 (EB_DCO_SUBSTEPS==2 plus the designed 24-tap FIR). The drive
 * is patch 32's real recalled coefficients, the same ones F5 used, so the
 * two tables are comparable.
 *
 * THE INCREMENT WIRING IS COPIED FROM eb_render.c ON PURPOSE: inc is DOUBLED
 * for the 2x build and `g` is NOT rescaled. That pairing is not obvious --
 * reasoning said halve g, and measurement said the opposite (up to 4.95 dB of
 * in-band tilt at 10.6 kHz when g was halved). Getting it wrong here would
 * make the probe measure a mis-wired engine and blame the lever.
 *
 * Output: raw float32 to stdout. The python driver (tools/engineb/o8_gate2.py)
 * does the FFTs and prints the per-band alias table.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "eb_fork_config.h"
#include "eb_dco.h"
#include "eb_decim.h"
#include "c6_realcoefs.h"

static void fill_coef(eb_dco_coef *c, float inc4)
{
    memset(c, 0, sizeof *c);
    c->inc = eb_dco_inc_scale(inc4);   /* the engine's own scaler, not a copy:
                                        * a second copy of this rule is how
                                        * the octave bug survived twice */
    /* THE EDGE WIDTH. g sets the ramp's DURATION: the pulse edge spans
     * inc4/amp in phase, and g*256 = 1/inc4, so dividing g by W widens the
     * ramp by W in time. At 4x the ramp is about a quarter of an output
     * sample wide and is sampled four times. At 1x it is sampled ONCE, and
     * where that sample lands is the aliasing. Widening the ramp toward one
     * output sample is the first-order band-limited step.
     *
     * Swept from the environment rather than fixed, because at 2x the SAME
     * reasoning said "halve g" and MEASUREMENT said the opposite (4.95 dB of
     * in-band tilt). A knob whose sign has already been wrong once is swept,
     * not chosen. */
    {   const char *w = getenv("EB_PROBE_GW");
        float W = w ? (float)atof(w) : 1.0f;
        c->g = (0.00390625f / inc4) / W;
    }
    c->pw = RC_pw; c->pwm1 = c->pw - 1.0f; c->pwp1 = c->pw + 1.0f;
#if EB_DCO_RECIP
    c->rm1 = 1.0f / c->pwm1; c->rp1 = 1.0f / c->pwp1;
#endif
    c->lvl_saw = RC_lvl_saw; c->lvl_pulse = RC_lvl_pulse; c->lvl_sub = RC_lvl_sub;
    c->gn_saw = RC_gn_saw;   c->gn_pulse = RC_gn_pulse;   c->gn_sub = RC_gn_sub;
    c->amp_saw = RC_amp_saw; c->amp_pulse = RC_amp_pulse; c->amp_sub = RC_amp_sub;
    c->sat_in = RC_sat_in;   c->subthr = RC_subthr;
    c->k3 = RC_k3; c->k5 = RC_k5; c->k7 = RC_k7; c->k9 = RC_k9; c->k11 = RC_k11;
    { float x = c->sat_in, x2 = x*x, x3=x*x2, x5=x3*x2, x7=x5*x2, x9=x7*x2, x11=x9*x2;
      c->sat_hi = x + x3*c->k3 + x5*c->k5 + x7*c->k7 + x9*c->k9 + x11*c->k11; }
    { float x = -c->sat_in, x2 = x*x, x3=x*x2, x5=x3*x2, x7=x5*x2, x9=x7*x2, x11=x9*x2;
      c->sat_lo = x + x3*c->k3 + x5*c->k5 + x7*c->k7 + x9*c->k9 + x11*c->k11; }
}

int main(int argc, char **argv)
{
    float inc = argc > 1 ? (float)atof(argv[1]) : 0.02f;
    int nsamp = argc > 2 ? atoi(argv[2]) : 131072;
    eb_dco_state ds; eb_dco_coef dc; eb_decim_state xs; eb_decim_coef xc;
    int i, j;

    memset(&ds, 0, sizeof ds); memset(&xs, 0, sizeof xs);
    memset(&xc, 0, sizeof xc);
    for (j = 0; j < 16; ++j) xc.c[j] = RC_fir[j];
    xc.k6256 = RC_k6256; xc.k6272 = RC_k6272; xc.k6336 = RC_k6336;
    fill_coef(&dc, inc);

    for (i = 0; i < nsamp; ++i) {
        float sub[4], out;
        eb_dco_step4(&ds, &dc, sub);
        out = eb_decim_tick(&xs, &xc, 0.0f, sub[0], sub[1], sub[2], sub[3]);
        fwrite(&out, 4, 1, stdout);
    }
    return 0;
}

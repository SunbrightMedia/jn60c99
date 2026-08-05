/* c6_halfos_probe.c — THE HALF-OVERSAMPLING MEASUREMENT (F5).
 *
 * THE QUESTION. The DCO is naive and its band-limiting is entirely the 4x
 * decimator; eb_dco.h's own header says reproducing the plugin's ALIASING is
 * part of the sound. Running the same naive shaping at 2x changes the alias
 * pattern BY CONSTRUCTION. This probe measures BY HOW MUCH, so the design
 * decision rests on a table instead of an adjective.
 *
 * WHAT IT RENDERS. The real modules — eb_dco_step4 + eb_decim_tick, the
 * shipping code, no copies — as the 4x REFERENCE; and a 2x variant that calls
 * the same eb_dco_step4 with the phase increment doubled (the same waveform
 * sampled at 88.2 kHz: two of its four sub-samples per output sample are
 * used) into a generated half-band FIR (c6_halfband.h, made by
 * gen_c6_halfband.py to match the port cascade's in-band response).
 *
 * Coefficients: the harness's plausible-drive fill for the recall-time set
 * (levels/gains/amps all live), increment swept over the musical range. Raw
 * float output of both paths is written to stdout as binary; the python
 * driver (gen_c6_halfband.py --measure) does the FFTs and prints the table:
 * in-band (0-18 kHz) spectral difference and the alias floor of each path.
 *
 * WHY THE 2x PATH MAY USE eb_dco_step4 UNCHANGED: the block is memoryless
 * shaping around a phase accumulator; stepping the SAME code with 2x the
 * increment IS the 2x oscillator. Only two of its four outputs are consumed
 * (the other two are the same waveform at points we no longer sample); the
 * probe advances phase by calling with the doubled increment and taking
 * outputs 0 and 1, which after the doubling correspond to the two half-rate
 * sub-instants. O8's real implementation would run a 2-step loop instead and
 * halve the cost; the SPECTRUM is identical either way, which is what this
 * probe measures.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "eb_dco.h"
#include "eb_decim.h"
#include "c6_halfband.h"
#include "c6_realcoefs.h"

static void fill_coef(eb_dco_coef *c, float inc)
{
    memset(c, 0, sizeof *c);
    c->inc = inc; c->g = 0.00390625f / inc;
    c->pw = RC_pw; c->pwm1 = c->pw - 1.0f; c->pwp1 = c->pw + 1.0f;
#if EB_DCO_RECIP
    c->rm1 = 1.0f / c->pwm1; c->rp1 = 1.0f / c->pwp1;
#endif
    c->lvl_saw = RC_lvl_saw; c->lvl_pulse = RC_lvl_pulse; c->lvl_sub = RC_lvl_sub;
    c->gn_saw = RC_gn_saw;   c->gn_pulse = RC_gn_pulse;   c->gn_sub = RC_gn_sub;
    c->amp_saw = RC_amp_saw; c->amp_pulse = RC_amp_pulse; c->amp_sub = RC_amp_sub;
    c->sat_in = RC_sat_in;   c->subthr = RC_subthr;
    c->k3 = RC_k3; c->k5 = RC_k5; c->k7 = RC_k7; c->k9 = RC_k9; c->k11 = RC_k11;
    /* sat_hi/sat_lo are eb_sat(+/-sat_in); the shipping recall builds them
     * via eb_dco_set_shape -- reproduce the polynomial inline: */
    { float x = c->sat_in, x2 = x*x, x3=x*x2, x5=x3*x2, x7=x5*x2, x9=x7*x2, x11=x9*x2;
      c->sat_hi = x + x3*c->k3 + x5*c->k5 + x7*c->k7 + x9*c->k9 + x11*c->k11; }
    { float x = -c->sat_in, x2 = x*x, x3=x*x2, x5=x3*x2, x7=x5*x2, x9=x7*x2, x11=x9*x2;
      c->sat_lo = x + x3*c->k3 + x5*c->k5 + x7*c->k7 + x9*c->k9 + x11*c->k11; }
}

static void fill_decim(eb_decim_coef *x)
{
    /* the port's decimator coefficients are recall-derived; the harness's
     * plausible fill is reused so both paths see the same drive class. The
     * REFERENCE path's absolute response is not the point -- the DIFFERENCE
     * between paths under identical drive is. */
    int j;
    memset(x, 0, sizeof *x);
    for (j = 0; j < 16; ++j) x->c[j] = RC_fir[j];
    x->k6256 = RC_k6256; x->k6272 = RC_k6272; x->k6336 = RC_k6336;
}

int main(int argc, char **argv)
{
    /* argv: mode(4|2) inc nsamp */
    int mode = argc > 1 ? atoi(argv[1]) : 4;
    float inc = argc > 2 ? (float)atof(argv[2]) : 0.02f;
    int nsamp = argc > 3 ? atoi(argv[3]) : 65536;
    eb_dco_state ds; eb_dco_coef dc; eb_decim_state xs; eb_decim_coef xc;
    static float hb_hist[C6_HB_TAPS]; int hb_i = 0;
    int i, k;

    memset(&ds, 0, sizeof ds); memset(&xs, 0, sizeof xs);
    fill_decim(&xc);

    for (i = 0; i < nsamp; ++i) {
        float out;
        if (mode == 4) {
            float sub[4];
            fill_coef(&dc, inc);
            eb_dco_step4(&ds, &dc, sub);
            out = eb_decim_tick(&xs, &xc, 0.0f, sub[0], sub[1], sub[2], sub[3]);
        } else {
            /* 2x: doubled increment, two sub-instants per output sample,
             * generated half-band decimates 88.2k -> 44.1k. */
            float sub[4], acc = 0.0f;
            fill_coef(&dc, inc * 2.0f);
            eb_dco_step4(&ds, &dc, sub);
            /* two half-rate sub-samples: sub[0], sub[1] */
            for (k = 0; k < 2; ++k) {
                hb_hist[hb_i] = sub[k];
                hb_i = (hb_i + 1) % C6_HB_TAPS;
            }
            for (k = 0; k < C6_HB_TAPS; ++k)
                acc += hb_hist[(hb_i - 1 - k + 2 * C6_HB_TAPS) % C6_HB_TAPS]
                     * c6_halfband[k];
            out = acc;
            /* burn the two unused sub-instants' phase NOT needed: the doubled
             * increment already advanced a full output sample in two of the
             * four steps -- rewind the extra two. eb_dco_step4 stepped four
             * times at 2*inc = two output samples; take both pairs. */
            for (k = 0; k < 2; ++k) {
                hb_hist[hb_i] = sub[2 + k];
                hb_i = (hb_i + 1) % C6_HB_TAPS;
            }
            /* second output sample from the same call */
            {
                float acc2 = 0.0f;
                for (k = 0; k < C6_HB_TAPS; ++k)
                    acc2 += hb_hist[(hb_i - 1 - k + 2 * C6_HB_TAPS) % C6_HB_TAPS]
                          * c6_halfband[k];
                fwrite(&out, 4, 1, stdout);
                out = acc2; ++i;
            }
        }
        fwrite(&out, 4, 1, stdout);
    }
    return 0;
}

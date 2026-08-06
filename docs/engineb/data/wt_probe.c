/* wt_probe.c — ROW 6: does a band-limited WAVETABLE reproduce this DCO?
 *
 * THE QUESTION, and why it is not the question quarter_os_result.md answered.
 * That build ran the port's shaping nonlinearity at the OUTPUT rate and the
 * harmonics came out 7 to 13.6 dB wrong, because the nonlinearity generates
 * the harmonics and a coarsely-sampled input generates different ones. A
 * wavetable does not run the nonlinearity at the output rate at all: it runs
 * it ONCE, at high resolution, at recall time, stores the result, band-limits
 * it exactly, and reads it back. Same distinction that made the vcf_res table
 * work where C2's decimation of the identical span failed at -39.3 dB.
 *
 * WHAT THIS PROBE BUILDS
 *   reference  the shipping path: eb_dco_step4 at 4x + eb_decim_tick.
 *   candidate  ONE period of the same oscillator evaluated at WT_OS times the
 *              output rate, Fourier-truncated to the harmonics that fit below
 *              Nyquist AT THIS PITCH, then read back with a phase accumulator
 *              running at the output rate and linear interpolation.
 *
 * THE PERIOD IS 4, NOT 2. The phase wraps over [-1,1), but the SUB arm is
 * clocked by a divide-by-two counter, so the oscillator only repeats after
 * TWO phase wraps. Tabulating over 2 would alias the sub-octave into the
 * fundamental and would look like a broken sub oscillator, not a broken
 * table.
 *
 * THE PULSE WIDTH IS FIXED IN THIS PROBE, on purpose. pw moves on 52 % of
 * samples (measured), and the answer to that is the band-limited-step
 * identity, which is a SECOND question. Mixing the two would leave a failure
 * unattributable to either. This probe answers "is a band-limited table of
 * this oscillator indistinguishable from the 4x path" and nothing else.
 *
 * Output: raw float32 to stdout, same contract as o8_alias_probe.c, so the
 * same driver measures it.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "eb_fork_config.h"
#include "eb_dco.h"
#include "eb_decim.h"
#include "c6_realcoefs.h"

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

#define WT_OS    64            /* sub-samples per output sample when building */
#ifndef WT_LEN
#define WT_LEN   4096          /* table entries over the FULL period of 4      */
#endif

static void fill_coef(eb_dco_coef *c, float inc4, int substeps)
{
    memset(c, 0, sizeof *c);
    c->inc = inc4 * (float)(4 / substeps);
    c->g = 0.00390625f / inc4;          /* edge width in TIME -- never rescaled */
    c->pw = RC_pw; c->pwm1 = c->pw - 1.0f; c->pwp1 = c->pw + 1.0f;
#if EB_DCO_RECIP
    c->rm1 = 1.0f / c->pwm1; c->rp1 = 1.0f / c->pwp1;
#endif
    c->lvl_saw = RC_lvl_saw; c->lvl_pulse = RC_lvl_pulse; c->lvl_sub = RC_lvl_sub;
    c->gn_saw = RC_gn_saw;   c->gn_pulse = RC_gn_pulse;   c->gn_sub = RC_gn_sub;
    c->amp_saw = RC_amp_saw; c->amp_pulse = RC_amp_pulse; c->amp_sub = RC_amp_sub;
    c->sat_in = RC_sat_in;   c->subthr = RC_subthr;
    c->k3 = RC_k3; c->k5 = RC_k5; c->k7 = RC_k7; c->k9 = RC_k9; c->k11 = RC_k11;
    { float x = c->sat_in, x2=x*x, x3=x*x2, x5=x3*x2, x7=x5*x2, x9=x7*x2, x11=x9*x2;
      c->sat_hi = x + x3*c->k3 + x5*c->k5 + x7*c->k7 + x9*c->k9 + x11*c->k11; }
    { float x = -c->sat_in, x2=x*x, x3=x*x2, x5=x3*x2, x7=x5*x2, x9=x7*x2, x11=x9*x2;
      c->sat_lo = x + x3*c->k3 + x5*c->k5 + x7*c->k7 + x9*c->k9 + x11*c->k11; }
#if EB_DCO_PULSEFAST
    eb_dco_set_edge_thresholds(c);
#endif
}

/* ---- build the table -------------------------------------------------------
 * Run the oscillator at WT_OS x the output rate until the phase has advanced
 * exactly one FULL period (4 in phase units), resampling onto WT_LEN evenly
 * spaced phase points. Done by RUNNING the real eb_dco_step with a tiny
 * increment and recording (phase, output) pairs, rather than by calling the
 * shaping maths directly -- so the table is built from the shipping code and
 * cannot drift from it.
 */
static void wt_build(float *tab, float inc4)
{
    eb_dco_state s; eb_dco_coef c;
    double acc = 0.0;                    /* phase travelled, in units of 4     */
    int i, n = WT_LEN;
    float *raw = (float *)malloc(sizeof(float) * (size_t)n);
    double step = 4.0 / (double)n;       /* phase per table entry              */

    memset(&s, 0, sizeof s);
    fill_coef(&c, inc4, 4);
    /* THE INCREMENT IS SET TO ONE TABLE STEP, not to the note's own. The table
     * is a function of PHASE; how fast the note walks it is the runtime's
     * business. Building it at the note's increment would sample the waveform
     * at the note's own resolution, which is exactly the 1x failure. */
    c.inc = (float)step;
    for (i = 0; i < n; ++i) {
        raw[i] = eb_dco_step(&s, &c);
        acc += step;
    }
    memcpy(tab, raw, sizeof(float) * (size_t)n);
    free(raw);
}

/* ---- the port's own decimator response -------------------------------------
 * THE TABLE MUST CARRY IT. The first run of this probe compared a table
 * against the 4x path and the harmonics grew steadily wrong with frequency --
 * +0.0 dB at 441 Hz, +1.0 at 6.2 kHz, +12.4 at 15.9 kHz -- with the TABLE
 * always the louder. That is not the table: it is the port's 16-coefficient
 * decimator, whose passband is NOT flat, and which the table path skips. A
 * wavetable stands in for the whole 4x-DCO-plus-decimator chain, so it has to
 * carry that chain's response.
 *
 * THE IMPULSE RESPONSE IS DERIVED, not guessed. eb_decim.c writes the filter
 * as sixteen (a+b)*k pairs indexed by (stream, age); stream p at age a is
 * delayed 4a + (3-p) sub-samples, because s3 is the newest of the four. That
 * mapping produces the 32-tap sequence below, and it comes out SYMMETRIC
 * about d=15.5 without being made to -- which is the check that the mapping
 * is right rather than merely plausible.
 *
 * The 15.5-sub-sample group delay is 3.875 output samples, and the diagnostic
 * that found this needed a 3-sample alignment shift. The two agree.
 */
static const int EB_DECIM_TAP[32] = {
    3, 2, 0, 1, 7, 6, 5, 4, 11, 10, 9, 8, 15, 14, 13, 12,
    12, 13, 14, 15, 8, 9, 10, 11, 4, 5, 6, 7, 1, 0, 2, 3
};

/* |H(f)| of that filter, at a frequency expressed as CYCLES PER SUB-SAMPLE. */
static double decim_mag(double cyc_per_sub)
{
    double re = 0.0, im = 0.0;
    int d;
    for (d = 0; d < 32; ++d) {
        double th = 2.0 * M_PI * cyc_per_sub * d;
        double h = RC_fir[EB_DECIM_TAP[d]];
        re += h * cos(th); im -= h * sin(th);
    }
    return sqrt(re * re + im * im);
}

/* ---- band-limit it ---------------------------------------------------------
 * Naive DFT, truncated to the harmonics that fit below Nyquist at this pitch.
 * O(N * H) and slow, and that is fine: this runs once in a probe. A shipping
 * build would do this per mip level at recall time with an FFT.
 *
 * THE FUNDAMENTAL IS harmonic 2 of this table, not 1: the table spans TWO DCO
 * cycles so that the sub-octave is periodic in it. Harmonic 1 IS the sub.
 */
static void wt_bandlimit(float *tab, int n, int hmax, double inc4)
{
    double *re = (double *)calloc((size_t)hmax + 1, sizeof(double));
    double *im = (double *)calloc((size_t)hmax + 1, sizeof(double));
    double dc = 0.0;
    int k, i;
    for (i = 0; i < n; ++i) dc += tab[i];
    dc /= n;
    for (k = 1; k <= hmax; ++k) {
        double a = 0.0, b = 0.0;
        for (i = 0; i < n; ++i) {
            double th = 2.0 * M_PI * k * i / (double)n;
            a += tab[i] * cos(th);
            b += tab[i] * sin(th);
        }
        /* THE DECIMATOR'S GAIN AT THIS HARMONIC. The table period is two
         * DCO cycles and the phase advances 4*inc4 per output sample, so the
         * table completes inc4 periods per output sample: harmonic k sits at
         * k*inc4 cycles per OUTPUT sample, and at four sub-samples to the
         * output sample that is k*inc4/4 per SUB-sample.
         *
         * The first version wrote /8. It was found by checking one number
         * against the diagnostic rather than by re-reading the algebra:
         * harmonic 72 of the table is 15,876 Hz, and 72*0.005/4 * 176,400 is
         * 15,876 while /8 gives half that. A frequency mapping is worth
         * checking against a known frequency every time. */
        {   double g = decim_mag(k * inc4 / 4.0);
            re[k] = 2.0 * a / n * g; im[k] = 2.0 * b / n * g; }
    }
    for (i = 0; i < n; ++i) {
        double v = dc, th0 = 2.0 * M_PI * i / (double)n;
        for (k = 1; k <= hmax; ++k)
            v += re[k] * cos(k * th0) + im[k] * sin(k * th0);
        tab[i] = (float)v;
    }
    free(re); free(im);
}

int main(int argc, char **argv)
{
    float inc = argc > 1 ? (float)atof(argv[1]) : 0.02f;
    int nsamp = argc > 2 ? atoi(argv[2]) : 131072;
    const char *mode = argc > 3 ? argv[3] : "ref";
    eb_dco_state ds; eb_dco_coef dc; eb_decim_state xs; eb_decim_coef xc;
    int i, j;

    memset(&ds, 0, sizeof ds); memset(&xs, 0, sizeof xs);
    memset(&xc, 0, sizeof xc);
    for (j = 0; j < 16; ++j) xc.c[j] = RC_fir[j];
    xc.k6256 = RC_k6256; xc.k6272 = RC_k6272; xc.k6336 = RC_k6336;

    if (!strcmp(mode, "ref")) {
        fill_coef(&dc, inc, 4);
        for (i = 0; i < nsamp; ++i) {
            float sub[4], out;
            eb_dco_step4(&ds, &dc, sub);
            out = eb_decim_tick(&xs, &xc, 0.0f, sub[0], sub[1], sub[2], sub[3]);
            fwrite(&out, 4, 1, stdout);
        }
    } else {
        /* THE TABLE PATH. Phase advances 4*inc per OUTPUT sample -- four
         * sub-sample increments' worth, since one output sample is what four
         * sub-samples used to make. */
        static float tab[WT_LEN];
        double ph = 0.0, dph;
        int hmax;
        wt_build(tab, inc);
        /* Harmonics below Nyquist. One table period is 2 DCO cycles, so the
         * DCO's fundamental is harmonic 2 and the sub is harmonic 1. The
         * output rate is 4/(4*inc) table periods per sample... expressed
         * directly: the table period lasts 4/(4*inc) = 1/inc output samples,
         * so its fundamental is inc cycles/sample and Nyquist admits
         * floor(0.5/inc) harmonics. */
        hmax = (int)floor(0.5 / inc);
        if (hmax > WT_LEN / 2 - 1) hmax = WT_LEN / 2 - 1;
        if (hmax < 1) hmax = 1;
        wt_bandlimit(tab, WT_LEN, hmax, (double)inc);
        dph = (double)inc * 4.0 / 4.0;   /* table periods per output sample */
        for (i = 0; i < nsamp; ++i) {
            double u = ph * WT_LEN;
            int    k = (int)u;
            float  f = (float)(u - k), out;
            out = tab[k & (WT_LEN - 1)]
                + (tab[(k + 1) & (WT_LEN - 1)] - tab[k & (WT_LEN - 1)]) * f;
            /* THE BIQUAD TAIL STILL RUNS. It is rate-dependent recall data,
             * not anti-aliasing, and leaving it out would compare a filtered
             * reference against an unfiltered candidate. */
            out = eb_decim_tick(&xs, &xc, 0.0f, out, 0.0f, 0.0f, 0.0f);
            fwrite(&out, 4, 1, stdout);
            ph += dph;
            if (ph >= 1.0) ph -= 1.0;
        }
    }
    return 0;
}

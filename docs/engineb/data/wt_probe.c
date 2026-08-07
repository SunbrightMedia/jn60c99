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

/* THE PULSE WIDTH, overridable. EB_WT_PW sets the width the OSCILLATOR runs
 * at; EB_WT_PWREF sets the width the TABLE is built at. Equal is the honest
 * case; different measures how far one pulse-width slice stretches, which is
 * what decides whether PWM needs a table rebuild, a set of slices, or the
 * band-limited-step identity. */
static float wt_pulse_ref(void)
{
    const char *e = getenv("EB_WT_PWREF");
    return e ? (float)atof(e) : RC_pw;
}

static float wt_pw(int building)
{
    const char *e = getenv(building ? "EB_WT_PWREF" : "EB_WT_PW");
    if (!e) e = getenv("EB_WT_PW");
    return e ? (float)atof(e) : RC_pw;
}

/* ARM SELECTOR. 0 = all three, 1 = saw only, 2 = pulse only, 3 = sub only.
 * The three arms are summed AFTER their own saturators, so isolating one by
 * zeroing the other two levels is exact -- eb_dco.c skips a term whose level
 * is 0.0f and says why (finite*0.0f is +/-0.0f and adding it changes nothing).
 */
static int WT_ARM = 0;

static void fill_coef_pw(eb_dco_coef *c, float inc4, int substeps, float pw)
{
    memset(c, 0, sizeof *c);
    c->inc = inc4 * (float)(4 / substeps);
    c->g = 0.00390625f / inc4;          /* edge width in TIME -- never rescaled */
    c->pw = pw; c->pwm1 = c->pw - 1.0f; c->pwp1 = c->pw + 1.0f;
#if EB_DCO_RECIP
    c->rm1 = 1.0f / c->pwm1; c->rp1 = 1.0f / c->pwp1;
#endif
    c->lvl_saw = RC_lvl_saw; c->lvl_pulse = RC_lvl_pulse; c->lvl_sub = RC_lvl_sub;
    if (WT_ARM == 1) { c->lvl_pulse = 0.0f; c->lvl_sub = 0.0f; }
    if (WT_ARM == 2) { c->lvl_saw = 0.0f;   c->lvl_sub = 0.0f; }
    if (WT_ARM == 3) { c->lvl_saw = 0.0f;   c->lvl_pulse = 0.0f; }
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

static void fill_coef(eb_dco_coef *c, float inc4, int substeps)
{
    fill_coef_pw(c, inc4, substeps, wt_pw(0));
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
    fill_coef_pw(&c, inc4, 4, wt_pw(1));
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

/* ---- THE PULSE IDENTITY -----------------------------------------------------
 * WHY IT IS REQUIRED and not merely tidier. A pulse-width SLICE was measured
 * and it does not stretch: at 441 Hz a table built 0.02 away in pw is 29.3 dB
 * wrong. Slicing pw would need hundreds of tables. And pw moves on 52 % of
 * samples, so rebuilding is not an option either.
 *
 * THE STRUCTURE. The pulse arm is a square with TWO edges: one at p = -pw,
 * which moves with the pulse width, and one at the phase wrap p = +/-1, which
 * does not. Both are the SAME edge shape with opposite signs. So
 *
 *     pulse(p; pw) = Rb(p + pw) - Rb(p + 1)
 *
 * where Rb is ONE band-limited, edge-shaped step. The pulse width becomes a
 * PHASE OFFSET on one of two reads of a single table, and nothing is rebuilt.
 *
 * RECOVERING Rb from the shipping code, rather than modelling it. Build the
 * pulse arm's own table at any reference width pw0 and take its Fourier
 * coefficients C_n. The identity in the frequency domain is
 *
 *     C_n = Rb_n * (e^{j n pi pw0} - e^{j n pi})
 *
 * over the table's period of 4 -- so the phase factors use n*pi/2 per unit of
 * phase, and pw0 and 1 are in the same phase units. Dividing gives Rb_n, and
 * an inverse transform gives the table. Rb therefore inherits the port's own
 * edge shape and its saturator; nothing here models the oscillator.
 *
 * The divisor VANISHES whenever the two edges land on the same phase for a
 * harmonic, and those harmonics carry no information about Rb at this pw0.
 * They are left at zero and a second reference width would be needed to fill
 * them -- reported by the probe rather than silently interpolated.
 */
static int wt_pulse_step(float *rb, const float *ptab, int n, int hmax,
                         double pw0, double inc4, double *dc0)
{
    double *rr = (double *)calloc((size_t)hmax + 1, sizeof(double));
    double *ri = (double *)calloc((size_t)hmax + 1, sizeof(double));
    int k, i, dead = 0;
    /* THE PULSE ARM'S DC, which the identity CANNOT carry. Rb(a) - Rb(b) is a
     * difference of two shifted copies of one function, so its mean is
     * structurally zero -- while a square of duty != 50 % has a real offset.
     * Found by looking at the waveform rather than the spectrum: the identity
     * matched in RMS (0.765 against 0.768) and was 0.25 too high at every
     * sample. A spectrum with a Hann window barely shows DC, so the gate
     * reported 140 dB of "harmonic error" for what was one missing constant.
     *
     * For a square of amplitude A and duty (1+pw)/2 the mean is A*pw, so the
     * offset scales linearly with the pulse width and one measurement at pw0
     * gives every other width. */
    { double m = 0.0; for (i = 0; i < n; ++i) m += ptab[i]; *dc0 = m / n; }
    for (k = 1; k <= hmax; ++k) {
        double a = 0.0, b = 0.0, th, dr, di, den;
        for (i = 0; i < n; ++i) {
            th = 2.0 * M_PI * k * i / (double)n;
            a += ptab[i] * cos(th); b += ptab[i] * sin(th);
        }
        a = 2.0 * a / n * decim_mag(k * inc4 / 4.0);
        b = 2.0 * b / n * decim_mag(k * inc4 / 4.0);
        /* e^{j k pi/2 * pw0} - e^{j k pi/2 * 1}, phase measured in the table's
         * own units where the period is 4. */
        dr = cos(M_PI * k * pw0 / 2.0) - cos(M_PI * k / 2.0);
        di = sin(M_PI * k * pw0 / 2.0) - sin(M_PI * k / 2.0);
        den = dr * dr + di * di;
        if (den < 1e-9) { ++dead; rr[k] = ri[k] = 0.0; continue; }
        /* (a + jb) / (dr + j di) */
        rr[k] = (a * dr + b * di) / den;
        ri[k] = (b * dr - a * di) / den;
    }
    for (i = 0; i < n; ++i) {
        double v = 0.0, t0 = 2.0 * M_PI * i / (double)n;
        for (k = 1; k <= hmax; ++k)
            v += rr[k] * cos(k * t0) + ri[k] * sin(k * t0);
        rb[i] = (float)v;
    }
    free(rr); free(ri);
    return dead;
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
        static float tab[WT_LEN], sawt[WT_LEN], subt[WT_LEN], rb[WT_LEN];
        static double pdc0 = 0.0, pwref0 = 1.0;
        double ph = 0.0, dph;
        int hmax, ident = !strcmp(mode, "id");
        hmax = (int)floor(0.5 / inc);
        if (hmax > WT_LEN / 2 - 1) hmax = WT_LEN / 2 - 1;
        if (hmax < 1) hmax = 1;
        dph = (double)inc;               /* table periods per output sample */

        if (!ident) {
            {   const char *r = getenv("EB_WT_REF");
                wt_build(tab, r ? (float)atof(r) : inc);
            }
            wt_bandlimit(tab, WT_LEN, hmax, (double)inc);
        } else {
            /* THREE TABLES: saw and sub are pulse-width independent and are
             * tabulated directly; the pulse arm becomes two reads of the
             * recovered step Rb. Built at the REFERENCE width and played at
             * the target width, which is the whole point. */
            double pw0 = (double)wt_pulse_ref();
            int dead;
            WT_ARM = 1; wt_build(sawt, inc); wt_bandlimit(sawt, WT_LEN, hmax, inc);
            WT_ARM = 3; wt_build(subt, inc); wt_bandlimit(subt, WT_LEN, hmax, inc);
            WT_ARM = 2; wt_build(tab, inc);
            dead = wt_pulse_step(rb, tab, WT_LEN, hmax, pw0,
                                 (double)inc, &pdc0);
            WT_ARM = 0; pwref0 = pw0;
            {   /* MEANS, printed rather than reasoned about. The DC bug was
                 * argued three ways from the structure and each argument gave
                 * a different sign; the arithmetic settles it in one run. */
                double ms = 0, mu = 0, mp = 0, mr = 0;
                int q;
                for (q = 0; q < WT_LEN; ++q) {
                    ms += sawt[q]; mu += subt[q]; mp += tab[q]; mr += rb[q];
                }
                fprintf(stderr, "wt: dead=%d/%d pw0=%.4f | mean saw=%.5f "
                        "sub=%.5f pulse=%.5f rb=%.5f dc0=%.5f\n",
                        dead, hmax, pw0, ms / WT_LEN, mu / WT_LEN,
                        mp / WT_LEN, mr / WT_LEN, pdc0);
            }
        }

        for (i = 0; i < nsamp; ++i) {
            double u = ph * WT_LEN;
            int    k = (int)u;
            float  f = (float)(u - k), out;
#define RD(T, PH) ({ double _u = (PH) * WT_LEN; \
                     int _k = (int)_u; float _f = (float)(_u - _k); \
                     (T)[_k & (WT_LEN-1)] \
                       + ((T)[(_k+1) & (WT_LEN-1)] - (T)[_k & (WT_LEN-1)]) * _f; })
            if (!ident) {
                out = tab[k & (WT_LEN - 1)]
                    + (tab[(k + 1) & (WT_LEN - 1)] - tab[k & (WT_LEN - 1)]) * f;
            } else {
                /* pw and 1 are offsets in PHASE, and the table spans 4 phase
                 * units, so an offset of x phase is x/4 of a table period. */
                double pw = (double)wt_pw(0);
                double o1 = ph + pw / 4.0, o2 = ph + 1.0 / 4.0;
                o1 -= floor(o1); o2 -= floor(o2);
                out = (float)(RD(sawt, ph) + RD(subt, ph)
                              + (RD(rb, o1) - RD(rb, o2))
                              + pdc0 * (pw / pwref0));
            }
#undef RD
            out = eb_decim_tick(&xs, &xc, 0.0f, out, 0.0f, 0.0f, 0.0f);
            fwrite(&out, 4, 1, stdout);
            ph += dph;
            if (ph >= 1.0) ph -= 1.0;
        }
    }
    return 0;
}

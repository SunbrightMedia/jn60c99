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
static float pwref_override = -1e30f;

static float wt_pulse_ref(void)
{
    const char *e = getenv("EB_WT_PWREF");
    if (pwref_override > -1e29f) return pwref_override;
    return e ? (float)atof(e) : RC_pw;
}

static float wt_pw(int building)
{
    const char *e;
    if (building && pwref_override > -1e29f) return pwref_override;
    e = getenv(building ? "EB_WT_PWREF" : "EB_WT_PW");
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
/* TWO REFERENCE WIDTHS, and the reason is measured. With one, the divisor
 * VANISHES at every harmonic where the two edges land on the same phase --
 * for pw0 = 0.30 that is k = 40 and k = 80, and harmonic 40 of the table is
 * 8,820 Hz carrying real energy at -43 dB. Zeroing it left a -240 dB bin
 * against the reference's -43 and the gate read 131 dB of harmonic error at
 * 441 Hz while the SAME build was correct at 1,764 Hz, where hmax is 25 and
 * k = 40 does not exist.
 *
 * The vanishing set depends on pw0, so a second width covers the first's
 * holes. Per harmonic, the reference with the LARGER divisor wins. */
static int wt_pulse_step2(float *ra_t, float *rb_t, const float *pa,
                          const float *pb, int n, int hmax, double pwa,
                          double pwb, double inc4, double *dc0);

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
        /* THE DIVISION, written out. This DFT produces f = SUM a_k cos +
         * b_k sin, which is the complex coefficient C_k = a_k - j b_k -- the
         * minus sign is the whole trap. So
         *
         *     (a - jb)/(dr + j di) = [(a*dr - b*di) - j(a*di + b*dr)] / den
         *
         * and the coefficient that multiplies sin is +(a*di + b*dr)/den.
         * The first version had a PLUS in the cos term and a MINUS in the sin
         * term -- both cross terms sign-flipped -- which left the DC and the
         * RMS right and the swing 60 % too large. */
        rr[k] = (a * dr - b * di) / den;
        ri[k] = (b * dr + a * di) / den;
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

/* The two-reference recovery. Identical arithmetic to wt_pulse_step, run for
 * both widths, choosing per harmonic. */
static void wt_pulse_one(const float *tab, int n, int k, double inc4,
                         double *a, double *b)
{
    double sa = 0.0, sb = 0.0, th;
    int i;
    for (i = 0; i < n; ++i) {
        th = 2.0 * M_PI * k * i / (double)n;
        sa += tab[i] * cos(th); sb += tab[i] * sin(th);
    }
    *a = 2.0 * sa / n * decim_mag(k * inc4 / 4.0);
    *b = 2.0 * sb / n * decim_mag(k * inc4 / 4.0);
}

/* TWO EDGES, not one -- and this is the finding that made the identity work.
 *
 * The first version assumed pulse(p;pw) = Rb(p+pw) - Rb(p+1): one edge shape
 * used twice with opposite signs. MEASURED, it fails in a way that points
 * straight at the cause. At pw = 0.30 the identity's own factor for table
 * harmonic 40 is e^{j40*pi*0.15} - e^{j20*pi} = 1 - 1 = EXACTLY ZERO, so the
 * model says that harmonic cannot exist -- while the reference has it at
 * -53.6 dB. The model was missing something real, not merely imprecise.
 *
 * eb_dco.c says what: the pulse phase is divided by pwm1 when t < 0 and by
 * pwp1 when t > 0, so "the two halves of the pulse get different edge slopes
 * -- that asymmetry IS the pulse width". Two slopes means TWO edge shapes.
 *
 *     pulse(p; pw) = Ra(p + pw) - Rb(p + 1)
 *
 * Two unknowns per harmonic, so two reference widths give two equations:
 *
 *     Ca = Ra e^{j k pi pwa/2} - Rb e^{j k pi/2}
 *     Cb = Ra e^{j k pi pwb/2} - Rb e^{j k pi/2}
 *
 * Subtracting eliminates Rb; back-substitution gives it. The second reference
 * is offset far enough that the two exponentials cannot coincide.
 */
static int wt_pulse_step2(float *ra_t, float *rb_t, const float *pa,
                          const float *pb, int n, int hmax, double pwa,
                          double pwb, double inc4, double *dc0)
{
    double *ar = (double *)calloc((size_t)hmax + 1, sizeof(double));
    double *ai = (double *)calloc((size_t)hmax + 1, sizeof(double));
    double *br = (double *)calloc((size_t)hmax + 1, sizeof(double));
    double *bi = (double *)calloc((size_t)hmax + 1, sizeof(double));
    int k, i, dead = 0;
    { double m = 0.0; for (i = 0; i < n; ++i) m += pa[i]; *dc0 = m / n; }
    for (k = 1; k <= hmax; ++k) {
        double car, cai, cbr, cbi;
        double ea_r = cos(M_PI * k * pwa / 2.0), ea_i = sin(M_PI * k * pwa / 2.0);
        double eb_r = cos(M_PI * k * pwb / 2.0), eb_i = sin(M_PI * k * pwb / 2.0);
        double e1_r = cos(M_PI * k / 2.0),       e1_i = sin(M_PI * k / 2.0);
        double dr = ea_r - eb_r, di = ea_i - eb_i, den = dr * dr + di * di;
        double nr, ni, rar, rai, tr, ti;
        {   double x, y;
            wt_pulse_one(pa, n, k, inc4, &x, &y); car = x; cai = -y;
            wt_pulse_one(pb, n, k, inc4, &x, &y); cbr = x; cbi = -y; }
        if (den < 1e-9) { ++dead; continue; }
        /* Ra = (Ca - Cb) / (ea - eb) */
        nr = car - cbr; ni = cai - cbi;
        rar = (nr * dr + ni * di) / den;
        rai = (ni * dr - nr * di) / den;
        /* Rb = (Ra*ea - Ca) / e1 ; |e1| == 1 so dividing is multiplying by
         * its conjugate. */
        tr = rar * ea_r - rai * ea_i - car;
        ti = rar * ea_i + rai * ea_r - cai;
        br[k] =  tr * e1_r + ti * e1_i;
        bi[k] =  ti * e1_r - tr * e1_i;
        ar[k] = rar; ai[k] = rai;
    }
    /* back to the a*cos + b*sin form this file's DFT uses: C = a - j b */
    for (i = 0; i < n; ++i) {
        double va = 0.0, vb = 0.0, t0 = 2.0 * M_PI * i / (double)n;
        for (k = 1; k <= hmax; ++k) {
            va += ar[k] * cos(k * t0) - ai[k] * sin(k * t0);
            vb += br[k] * cos(k * t0) - bi[k] * sin(k * t0);
        }
        ra_t[i] = (float)va; rb_t[i] = (float)vb;
    }
    free(ar); free(ai); free(br); free(bi);
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
        static float tab[WT_LEN], sawt[WT_LEN], subt[WT_LEN];
        static float ra[WT_LEN], rb[WT_LEN];
        static float ra2[WT_LEN], rb2[WT_LEN];
        static double pwL = 0.0, pwH = 1.0;
        static double pdc0 = 0.0, pwref0 = 1.0;
        double ph = 0.0, dph;
        static float pa_t[WT_LEN], pb_t[WT_LEN];
        int hmax, ident = !strcmp(mode, "id"), slice = !strcmp(mode, "sl");
        int ident2 = !strcmp(mode, "id2");
        if (ident2) ident = 1;
        double pwlo = 0.0, pwhi = 0.0;
        hmax = (int)floor(0.5 / inc);
        if (hmax > WT_LEN / 2 - 1) hmax = WT_LEN / 2 - 1;
        if (hmax < 1) hmax = 1;
        dph = (double)inc;               /* table periods per output sample */

        if (slice) {
            /* PULSE-WIDTH SLICES WITH INTERPOLATION -- the test the earlier
             * slice measurement did NOT run. That one built at one width and
             * played at another with no interpolation, which is what a table
             * with ONE slice does. A 2-D table interpolates between two, and
             * interpolation error falls as the SQUARE of the spacing, so the
             * two questions have different answers and only one of them was
             * asked.
             *
             * EB_WT_SLICE sets the half-spacing; the two slices bracket the
             * target width. */
            double h = getenv("EB_WT_SLICE") ? atof(getenv("EB_WT_SLICE")) : 0.05;
            double pw = (double)wt_pw(0);
            float save = pwref_override;
            pwlo = pw - h; pwhi = pw + h;
            WT_ARM = 1; wt_build(sawt, inc); wt_bandlimit(sawt, WT_LEN, hmax, inc);
            WT_ARM = 3; wt_build(subt, inc); wt_bandlimit(subt, WT_LEN, hmax, inc);
            WT_ARM = 2;
            pwref_override = (float)pwlo; wt_build(pa_t, inc);
            wt_bandlimit(pa_t, WT_LEN, hmax, inc);
            pwref_override = (float)pwhi; wt_build(pb_t, inc);
            wt_bandlimit(pb_t, WT_LEN, hmax, inc);
            pwref_override = save; WT_ARM = 0;
        } else if (!ident) {
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
            if (ident2) {
                /* THE TWO IDEAS COMBINED, and each fixes what the other
                 * cannot.
                 *
                 * MEASURED: interpolating two pulse WAVEFORMS converges
                 * badly at low pitch -- 15.6 dB even at a half-spacing of
                 * 0.0125 -- because the edges sit in DIFFERENT PLACES and
                 * blending them gives TWO edges, not one moved edge. You
                 * cannot cross-fade a moving edge.
                 *
                 * The identity moves the edge exactly (it is a phase offset)
                 * but assumes ONE shape, and the shape moves with pw because
                 * the slopes are 1/(pw-1) and 1/(pw+1).
                 *
                 * So: recover the step PAIR at two pw slices and interpolate
                 * THE STEPS. Their edges are both at argument 0 by
                 * construction, so interpolating them blends shape without
                 * moving anything -- and the identity then places the blended
                 * edge at the exact width. */
                double h = getenv("EB_WT_SLICE") ? atof(getenv("EB_WT_SLICE")) : 0.05;
                double pw = (double)wt_pw(0);
                static float t2[WT_LEN];
                float save = pwref_override;
                pwL = pw - h; pwH = pw + h;
                pwref_override = (float)pwL;        wt_build(tab, inc);
                pwref_override = (float)(pwL + 0.37); wt_build(t2, inc);
                wt_pulse_step2(ra, rb, tab, t2, WT_LEN, hmax,
                               pwL, pwL + 0.37, (double)inc, &pdc0);
                pwref_override = (float)pwH;        wt_build(tab, inc);
                pwref_override = (float)(pwH + 0.37); wt_build(t2, inc);
                dead = wt_pulse_step2(ra2, rb2, tab, t2, WT_LEN, hmax,
                                      pwH, pwH + 0.37, (double)inc, &pdc0);
                pwref_override = save;
                pwref0 = pw;
            } else
            {   /* the second reference width, offset far enough that its
                 * vanishing set cannot coincide with the first's */
                static float tab2[WT_LEN];
                float save = pwref_override;
                pwref_override = (float)(pw0 + 0.37);
                wt_build(tab2, inc);
                pwref_override = save;
                dead = wt_pulse_step2(ra, rb, tab, tab2, WT_LEN, hmax,
                                      pw0, pw0 + 0.37, (double)inc, &pdc0);
            }
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
            if (slice) {
                double pw = (double)wt_pw(0);
                double w = (pw - pwlo) / (pwhi - pwlo);
                float lo = RD(pa_t, ph), hi = RD(pb_t, ph);
                out = (float)(RD(sawt, ph) + RD(subt, ph)
                              + lo + (hi - lo) * (float)w);
            } else if (!ident) {
                out = tab[k & (WT_LEN - 1)]
                    + (tab[(k + 1) & (WT_LEN - 1)] - tab[k & (WT_LEN - 1)]) * f;
            } else {
                /* pw and 1 are offsets in PHASE, and the table spans 4 phase
                 * units, so an offset of x phase is x/4 of a table period. */
                /* THE EDGE WIDTH SCALES WITH pw, and a STEP IS FLAT EXCEPT
                 * NEAR ITS EDGE -- so the width change is a PHASE SCALING of
                 * one shape, not a new shape.
                 *
                 * The pulse phase is t/(pw-1) below zero and t/(pw+1) above,
                 * and the edge spans a fixed range in that argument, so its
                 * width in PHASE is proportional to |pw-1| and |pw+1|. Reading
                 * the recovered step at a distance-from-edge scaled by
                 * |pwref-1|/|pw-1| gives the right width while leaving the
                 * flat parts flat.
                 *
                 * MEASURED FIRST, which is why this exists: with fixed steps
                 * the error away from the reference width is BROAD -- 13 of 36
                 * harmonics over the bound at dpw = 0.05 -- so it is the shape
                 * moving, not one harmonic nulling. */
                double pw = (double)wt_pw(0);
                double sa = ident2 ? 1.0
                                   : fabs(pwref0 - 1.0) / fabs(pw - 1.0);
                double sb = ident2 ? 1.0
                                   : fabs(pwref0 + 1.0) / fabs(pw + 1.0);
                double d1 = ph + pw / 4.0, d2 = ph + 1.0 / 4.0;
                double o1, o2;
                /* distance from the edge, in table periods, folded to
                 * (-0.5, 0.5] so the scaling is about the NEAREST edge */
                d1 -= floor(d1 + 0.5); d2 -= floor(d2 + 0.5);
                o1 = d1 * sa; o2 = d2 * sb;
                o1 -= floor(o1); o2 -= floor(o2);
                if (ident2) {
                    double wgt = (pw - pwL) / (pwH - pwL);
                    float a1 = RD(ra, o1), a2v = RD(ra2, o1);
                    float b1 = RD(rb, o2), b2v = RD(rb2, o2);
                    out = (float)(RD(sawt, ph) + RD(subt, ph)
                                  + (a1 + (a2v - a1) * (float)wgt)
                                  - (b1 + (b2v - b1) * (float)wgt)
                                  + pdc0);
                } else
                out = (float)(RD(sawt, ph) + RD(subt, ph)
                              + (RD(ra, o1) - RD(rb, o2))
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

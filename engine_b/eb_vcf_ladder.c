/* eb_vcf_ladder.c — the 4-pole ladder core. See eb_vcf_ladder.h for the
 * topology, the provenance and the list of what is changed.
 *
 * EVALUATION ORDER IS THE SPECIFICATION. The build is -ffp-contract=off and the
 * reference is x86 SSE2 single precision, so an algebraically equal regrouping
 * is a DIFFERENT NUMBER. Every parenthesis below is the source's own. Three
 * regroupings that look free and are not, and are therefore NOT taken here:
 *     1 - (G+G)                 is not      1 - 2*G
 *     x + ((((x*x)*x)*x)*(x*K)) is not      x*(1 + K*(x*x)*(x*x))
 *     1/(((G*G)*(G*G))*k + 1)   is not      a reciprocal approximation
 * The third is called out by docs/trackb/VCF.md §3.8 and is the one that would
 * be tempting on a divider-less FPU. CORRECTED 2026-08-10, because the
 * sentence that stood here was wrong on both halves: it said the ESP32-S3 has
 * no FP divide and that this division is therefore a soft-float call. MEASURED,
 * __XCHAL_HAVE_FP_DIV is 1, every instruction of the divide sequence assembles
 * for this target, and libgcc's own __divsf3 for esp32s3 IS that sequence --
 * 30 instructions of which 14 are div0.s / nexp01.s / maddn.s / divn.s. The
 * FPU was doing the work all along; what the call costs is TRANSPORT (entry,
 * retw, a wfr pair in and an rfr out, because the windowed ABI passes floats
 * in INTEGER registers). engine_b/eb_fpdiv.h removes that transport by
 * inlining the same sequence verbatim. The refusal above still stands: a
 * reciprocal APPROXIMATION is not admissible here, and none is used.
 */
#include "eb_vcf_ladder.h"
#include "eb_fork_config.h"
#include "eb_fpdiv.h"
#if EB_HALF_OS_VCF
#include "eb_halfos_fir.h"
#include "eb_vcf_halfos_fir.h"
#ifndef EB_VCF_CLAMP_COUNT
#define EB_VCF_CLAMP_COUNT 0
#endif
#if EB_VCF_CLAMP_COUNT
unsigned long eb_vcf_clamp_hits = 0;
#endif
#endif

/* EB_VCF_GRANGE -- write-only instrumentation for the half-OS guard. G's
 * range decides whether the G' = 2G/(1-G^2) clamp is a real limitation or a
 * line that never executes, and this project's rule is that a branch rate is
 * MEASURED over the real scenario set rather than reasoned about. Off in
 * every shipping build; the counters are never read by the DSP. */
#ifndef EB_VCF_GRANGE
#define EB_VCF_GRANGE 0
#endif
#if EB_VCF_GRANGE
#include <stdio.h>
static float eb_g_lo = 1e30f, eb_g_hi = -1e30f;
/* AND k, THE RESONANCE. The ZDF refit's fitted saturation is judged almost
 * entirely by behaviour near self-oscillation, so its reachable range is a
 * precondition of the fit rather than a curiosity. Tracked here so both
 * numbers come from ONE run over the real battery. */
static float eb_k_lo = 1e30f, eb_k_hi = -1e30f;
static unsigned long eb_g_n = 0, eb_g_over = 0;
static void eb_g_report(void) __attribute__((destructor));
static void eb_g_report(void)
{
    /* A FILE, not stderr: the null harness runs its scenarios in worker
     * subprocesses whose stderr is captured and discarded, so the first
     * version of this reported nothing at all and looked like "G never moved"
     * -- a measurement that silently measures nothing is the trap this
     * project keeps a catalogue of. */
    FILE *f;
    if (!eb_g_n) return;
    f = fopen("/tmp/eb_grange.log", "a");
    if (!f) return;
    fprintf(f, "calls=%lu G in [%.6f, %.6f] over-0.41421=%lu (%.4f%%) "
               "k in [%.6f, %.6f]\n",
            eb_g_n, (double)eb_g_lo, (double)eb_g_hi, eb_g_over,
            100.0 * eb_g_over / eb_g_n, (double)eb_k_lo, (double)eb_k_hi);
    fclose(f);
}
#endif

/* ------------------------------------------------------------- wrap24
 * Verbatim from src/juno_dsp.c:20-45 (0x180368D60). Copied rather than called
 * so the module is self-contained on a target that does not link the port.
 * The bit fiddling IS the algorithm and is not re-expressed as a formula; the
 * copy is byte-for-byte, and engine_b/tests/test_vcf_wrap24.c compares the two
 * over ALL 2^32 float bit patterns because this project has already been bitten
 * once by an "obviously identical" wrap replacement (eb_triangle, 8,388,608
 * disagreements out of 2^32, rounding alone).
 */
static float eb_wrap24(float x)
{
    int v1 = (int)(x * 16777216.0f);
    int v2, v5, v6;
    if (v1 == 0) {
        v2 = 1;
    } else {
        int v3 = v1 & 0x200000;
        if ((v1 & 0x800000) != 0)
            v2 = (v3 == 0) ? 2 * v1 : 2 * v1 + 1;
        else
            v2 = (v3 != 0) ? 2 * v1 : 2 * v1 + 1;
    }
    v5 = v2 & 0xFFFFFF;
    v6 = v2 | (int)0xFF000000;
    if ((v2 & 0x1000000) == 0)
        v6 = v5;
    return (float)v6 * 5.960464477539063e-08f;
}

void eb_vcf_reset(eb_vcf_state *st)
{
    int i;
    st->nl = st->y1 = st->y2 = st->y3 = st->y4 = 0.0f;
    st->s1 = st->s2 = 0.0f;
    st->drive_prev = 0.0f;
    st->dith = 0.0f;
    for (i = 0; i < 32; ++i) st->h[i] = 0.0f;
    st->hi = 31;
}

float eb_vcf_hist_get(const eb_vcf_state *st, int i)
{
    return st->h[(st->hi - i) & 31];
}

void eb_vcf_hist_set(eb_vcf_state *st, int i, float v)
{
    st->h[(st->hi - i) & 31] = v;
}

/* ---------------------------------------------------------- one sub-step
 * READ src/voice_render.c:1355-1384 (sub-step 1); :1388-1419, :1424-1454 and
 * :1458-1488 are the same shape, and the only textual differences are the
 * commutations listed in eb_vcf_ladder.h item 2.
 *
 * `ins` is the interpolated input ALREADY multiplied by R = 1/(1+k*G^4).
 * Returns the 24 dB tap; leaves the pipeline advanced.
 */

#if EB_VCF_ADAA
/* the clamped quintic and its first two antiderivatives, in one place so the
 * ADAA orders cannot disagree about the curve they are integrating */
static float eb_vcf_sat(float x, float k)
{
    float ax = x < 0.0f ? -x : x, x2;
    if (!(ax <= 1.0f)) return x < 0.0f ? -(1.0f + k) : (1.0f + k);
    x2 = x * x;
    return x + k * x2 * x2 * x;
}
static float eb_vcf_F1(float x, float k)          /* even */
{
    float ax = x < 0.0f ? -x : x, x2;
    if (!(ax <= 1.0f))
        return (0.5f + k * (1.0f / 6.0f)) + (1.0f + k) * (ax - 1.0f);
    x2 = x * x;
    return 0.5f * x2 + k * (1.0f / 6.0f) * x2 * x2 * x2;
}
static float eb_vcf_F2(float x, float k)          /* odd */
{
    float ax = x < 0.0f ? -x : x, a2, v;
    if (!(ax <= 1.0f)) {
        float e = ax - 1.0f;
        v = (1.0f / 6.0f + k * (1.0f / 42.0f))
            + (0.5f + k * (1.0f / 6.0f)) * e
            + 0.5f * (1.0f + k) * e * e;
    } else {
        a2 = ax * ax;
        v = a2 * ax * (1.0f / 6.0f) + k * (1.0f / 42.0f) * a2 * a2 * a2 * ax;
    }
    return x < 0.0f ? -v : v;
}
#endif

static float eb_vcf_substep(eb_vcf_state *st, const eb_vcf_coef *c,
                            float ins, float G, float A, float Rk)
{
    float x, nl, y1, y2, y3, y4, t, p2, S;
    float xz = st->nl, y1z = st->y1, y2z = st->y2, y3z = st->y3, y4z = st->y4;

    /* ZDF resolution of the resonance feedback. [9536] is 0.0, so the second
     * term contributes nothing -- and it is still MULTIPLIED, because 0*inf and
     * 0*NaN are not nothing. :1355-1357 */
#if EB_VCF_DEADCOEF
    /* c9536 IS ZERO IN EVERY COEFFICIENT SET MEASURED (128 of 128 across the
     * bank's note/gate/voice sets), so the second product and its add are
     * dead, and st->s2 with them. The original keeps the multiply because
     * 0*inf and 0*NaN are not nothing -- st->s1 is hard-bounded by the
     * saturation ahead of it, so neither can arrive here, and the null gate
     * holds that claim to EXACTLY 0. */
    x = ins - ((st->s1 * c->c9520) * Rk);
#else
    x = ins - (((st->s1 * c->c9520) + (st->s2 * c->c9536)) * Rk);
#endif

#if EB_VCF_ADAA == 3
    /* CENTRED ADAA -- antialiasing WITHOUT the delay that killed the others.
     *
     * Ordinary ADAA averages f over the segment the input just travelled,
     * [x1, x0], so its result belongs to the MIDPOINT: a half-sample delay at
     * first order, a full sample at second. This saturation sits inside a
     * zero-delay resonant loop, and a phase shift there is precisely what the
     * ZDF solve exists to remove -- which is why first order measured 2.22 dB
     * and second order 33.94 dB while the linear cascade at the same rate
     * measured 0.03 dB. The delay was the fault, not the averaging.
     *
     * So average over a segment of the SAME WIDTH centred on x instead:
     *
     *     y = ( F1(x + d/2) - F1(x - d/2) ) / d ,   d = x - x1
     *
     * It is still causal -- d uses only the current and previous input -- it
     * still suppresses the fold, and its centre of mass is x, so it adds no
     * delay to the loop. The limit as d -> 0 is f(x) exactly. */
    {   float k = c->c9184, d = x - st->xprev, hd;
        st->xprev = x;
        hd = 0.5f * d;
        if (d > 1e-5f || d < -1e-5f)
            nl = (eb_vcf_F1(x + hd, k) - eb_vcf_F1(x - hd, k)) / d;
        else
            nl = eb_vcf_sat(x, k);
    }
#elif EB_VCF_ADAA >= 2

    /* SECOND-ORDER ANTIDERIVATIVE ANTIALIASING.
     *
     * First order is measured HARMFUL on this filter -- 2.22 dB at 4x and
     * 5.77 dB at 2x -- because it replaces the instantaneous nonlinearity
     * with its average over the input's last step, and that average is a
     * low-pass whose corner moves with slew. Second order takes the average
     * of THAT average over two steps, so its own artefact falls with the
     * SQUARE of the step instead of linearly, while suppressing the fold
     * harder.
     *
     * With f(x) = x + k x^5 on |x| <= 1 and constant +/-(1+k) outside,
     *     F1(x) = x^2/2  + k x^6/6            (even, since f is odd)
     *     F2(x) = x^3/6  + k x^7/42           (odd)
     * and outside the clamp both continue as polynomials in (|x| - 1) with
     * the value and slope matched at the boundary.
     *
     * y = 2/(x0-x2) * ( (F2(x0)-F2(x1))/(x0-x1) - (F2(x1)-F2(x2))/(x1-x2) )
     *
     * TWO denominators can vanish, not one, and they vanish independently.
     * Each is guarded separately and falls back to the lower-order form,
     * which is that quotient's own limit. */
    {   float k = c->c9184, x1 = st->xprev, x2 = st->xprev2;
        float d0 = x - x1, d1 = x1 - x2, d2 = x - x2;
        float F2x = eb_vcf_F2(x, k), F2a = st->F2p, F2b = st->F2pp;
        float q0, q1;
        st->xprev2 = x1;  st->xprev  = x;
        st->F2pp   = F2a; st->F2p    = F2x;
        q0 = (d0 > 1e-5f || d0 < -1e-5f) ? (F2x - F2a) / d0
                                         : eb_vcf_F1(0.5f * (x + x1), k);
        q1 = (d1 > 1e-5f || d1 < -1e-5f) ? (F2a - F2b) / d1
                                         : eb_vcf_F1(0.5f * (x1 + x2), k);
        if (d2 > 1e-5f || d2 < -1e-5f) nl = 2.0f * (q0 - q1) / d2;
        else                           nl = eb_vcf_sat(0.5f * (x + x2), k);
    }
#elif EB_VCF_ADAA
    /* ANTIDERIVATIVE ANTIALIASING on the clamped quintic.
     *
     * The 4x oversampling in this filter is NOT there for frequency warping:
     * the loop is already zero-delay (see the solve above). It is there
     * because this saturation sits INSIDE the resonant feedback path, so its
     * harmonics fold AND are then re-circulated by the resonance. Halving the
     * oversampling instead of fixing that measured 24.8 dB on the sonic gate.
     *
     * ADAA attacks the fold at its source. With
     *     f(x) = x + k*x^5   on |x| <= 1, and constant +/-(1+k) outside,
     * the antiderivative is elementary:
     *     F(x) = x^2/2 + k*x^6/6            on |x| <= 1
     *     F(x) = F(1) + (1+k)*(|x| - 1)     outside   (F is even, f is odd)
     * and one sample of it is  y = (F(x) - F(xprev)) / (x - xprev), which is
     * the average of f over the segment the input travelled rather than its
     * value at one instant. The fold is suppressed instead of moved.
     *
     * THE DIVISION IS ILL-CONDITIONED when the input barely moves, which is
     * most of the time on a slow-moving control signal. Below the threshold
     * the midpoint value is used, which is the limit of the quotient. */
    {   float k = c->c9184, xp = st->xprev, ax, axp, Fx, Fxp, d;
        st->xprev = x;
        ax  = x  < 0.0f ? -x  : x;
        axp = xp < 0.0f ? -xp : xp;
        if (!(ax  <= 1.0f)) Fx  = (0.5f + k * (1.0f / 6.0f))
                                  + (1.0f + k) * (ax  - 1.0f);
        else { float x2 = x * x;  Fx  = 0.5f * x2
                                        + k * (1.0f / 6.0f) * x2 * x2 * x2; }
        if (!(axp <= 1.0f)) Fxp = (0.5f + k * (1.0f / 6.0f))
                                  + (1.0f + k) * (axp - 1.0f);
        else { float p2 = xp * xp; Fxp = 0.5f * p2
                                        + k * (1.0f / 6.0f) * p2 * p2 * p2; }
        d = x - xp;
        if (d > 1e-5f || d < -1e-5f) {
            nl = (Fx - Fxp) / d;
        } else {
            float m = 0.5f * (x + xp), am = m < 0.0f ? -m : m;
            if (!(am <= 1.0f)) nl = m < 0.0f ? -(1.0f + k) : (1.0f + k);
            else { float m2 = m * m; nl = m + k * m2 * m2 * m; }
        }
    }
#else
    /* EB_VCF_SATFIT -- FITTED SATURATION DRIVE, for the 2x path.
     *
     * WHY THIS AND NOT MORE ADAA. EB_HALF_OS_VCF measures 3.17 dB on the
     * sonic gate, and the record says the residual is IN-BAND HARMONICS from
     * half-rate waveshaping. All three ADAA orders (2.22 / 5.77 / 33.94 dB,
     * centred 3.25) attacked ALIASING. Aliasing and level are different
     * defects: at 2x the saturator is evaluated TWICE per output sample
     * instead of four times, so the same input traverses the curve half as
     * often and the harmonic LEVEL it generates is simply different. That is
     * a gain question, and a gain question is fitted, not antialiased.
     *
     * The form keeps small-signal gain EXACTLY 1 at a = m = 1, so the flag is
     * the identity when unset and the trunk is untouched:
     *     nl = sat(x * a) * (m / a)
     * `a` sets how hard the curve is driven (the harmonic level), `m` is the
     * overall makeup. Two constants, fitted against the TRUNK ORACLE's own
     * renders -- never against a bounce (diagnostic covenant).
     */
#ifndef EB_VCF_SATFIT_A
#define EB_VCF_SATFIT_A 1.0f
#endif
#ifndef EB_VCF_SATFIT_M
#define EB_VCF_SATFIT_M 1.0f
#endif
#if EB_VCF_SATFIT
    x = x * (EB_VCF_SATFIT_A);
#endif
    /* hard clip, NaN -> -1.0 (the >= test fails on NaN). :1358-1361 */
    if (x >= -1.0f) { if (x > 1.0f) x = 1.0f; }
    else            { x = -1.0f; }

    /* the saturation curve. :1362 */
#if EB_VCF_NOSAT
    /* DIAGNOSTIC ONLY. Makes the ladder LINEAR so that halving the
     * oversampling can be judged with the nonlinearity removed: if 2x and 4x
     * then differ by the same amount as they do with it, the residual is the
     * cascade's own HF response; if the difference collapses, it is the
     * saturation's fold. Never a shipping build. */
    nl = x;
#else
    nl = x + ((((x * x) * x) * x) * (x * c->c9184));
#if EB_VCF_SATFIT
    nl = nl * ((EB_VCF_SATFIT_M) / (EB_VCF_SATFIT_A));
#endif
#endif
#endif

    /* four cascaded bilinear one-poles. :1365-1375 */
    y1 = (G * (nl + xz)) + (y1z * A);
    t  = G * (y1 + y1z);
    p2 = G * (((G * nl) + (A * y1)) + y1);      /* stage-2, one step ahead */
    y2 = t + (y2z * A);
    y3 = (G * (y2 + y2z)) + (y3z * A);
    y4 = ((y3z + y3) * G) + (A * y4z);

    /* zero-input response of the whole chain one sub-step ahead. :1377-1381 */
    S  = (G * (((G * ((p2 + (A * y2)) + y2)) + (A * y3)) + y3)) + (A * y4);

    st->nl = nl; st->y1 = y1; st->y2 = y2; st->y3 = y3; st->y4 = y4;
#if EB_VCF_DEADCOEF
    st->s1 = S;                      /* s2 is read only through c9536 */
#else
    st->s2 = st->s1; st->s1 = S;
#endif

    /* :1382-1384 */
#if EB_VCF_DEADCOEF
    /* c9088 (18 dB tap) and c9072 (12 dB tap) are ZERO in all 128 measured
     * sets -- the header always said the 18 dB taps are computed and
     * multiplied by zero every sub-step. Only the 24 dB tap survives. */
    return y4 * c->c9104;
#else
    return ((y3 * c->c9088) + (y4 * c->c9104)) + (c->c9072 * y2);
#endif
}

/* ===================================================== EB_VCF_ZDF1X (S3/S4)
 * THE 1x REFIT. A TEMPORARY, FLAGGED EXPERIMENT -- default OFF, adopted only
 * by the user's decision. Read docs/engineb/VCF_ZDF1X_PLAN.md.
 *
 * THE SEAM, established by reading the port rather than assuming: the port's
 * ladder is ALREADY zero-delay. `ins` arrives pre-multiplied by
 * R = 1/(1+k*G^4) and the feedback is `ins - s1*R*k`, which IS the TPT solve
 * u = (x - k*S)/(1 + k*G^4). So the 4x oversampling buys NOTHING for the
 * linear filter -- eb_vcf_ladder.c has always said it is there because the
 * saturator sits inside the resonant loop. Drop the oversampling, keep the
 * solve, and the linear response should be reproducible EXACTLY by algebra;
 * only the nonlinearity needs fitting. That is what gate G-A tests, and it is
 * why the linear skeleton is built and gated BEFORE anything is fitted.
 *
 * THE CUTOFF MAP, derived from the port's own one-pole, not assumed.
 *     H(z) = G(1 + z^-1)/(1 - A z^-1),  A = 1 - 2G
 * matched against the bilinear lowpass (pole (1-g)/(1+g), gain g/(1+g)) gives
 *     G = g/(1+g)   i.e.   g = G/(1-G)
 * -- G is the bilinear GAIN, NOT the prewarped tangent. Assuming G = tan cost
 * 29 dB once in the half-OS work; it is not repeated here. The port's g is at
 * 4x, so the same corner at 1x is tan(4*atan(g4)), reached by the tangent
 * double-angle identity applied TWICE, with no frequency ever appearing:
 *     t  = 2g4/(1 - g4^2)          tan(2th)
 *     g1 = 2t /(1 - t^2)           tan(4th)
 *     G1 = g1/(1 + g1)
 *
 * THE GUARD IS REAL, not decoration. g1 runs to infinity as t -> 1, i.e.
 * g4 -> 0.41421, i.e. G -> 0.29289. MEASURED over the whole battery G lands
 * in [0.000119, 0.209771], so the clamp never fires on any factory patch --
 * and "no factory patch reaches it" is not a proof about any preset, which is
 * exactly why it is kept.
 */
#if EB_VCF_ZDF1X
float eb_vcf_tick(eb_vcf_state *st, const eb_vcf_coef *c,
                  float in, float G, float k)
{
    float d, drive, prev;
    float g4, t, g1, G1, A1, R1, Rk1;
    float x, nl, y1, y2, y3, y4, tt, p2, S;
    float xz, y1z, y2z, y3z, y4z;

    /* the input node, unchanged and at 1x already -- the dither is a
     * free-running wrap24 oscillator and C2 proved a stochastic carrier
     * cannot be approximated, so it is stepped every sample exactly as before */
    d     = st->dith;
    drive = (((k * c->c9168) + 1.0f) * (in * c->c9136)) + ((-d) * c->c9120);
    st->dith = eb_wrap24(-d);
    prev  = st->drive_prev;
    st->drive_prev = drive;
    (void)prev;                 /* the 4x upsampler's other tap; see S4 */

#if EB_VCF_ZDF1X == 2
    /* VARIANT 2 -- POLE-MAPPED, NO NYQUIST ZERO. Gate G-A on variant 1
     * (bilinear corner match) measured 0.2-1.8 dB at low cutoff and 20 dB
     * near Nyquist at G >= 0.05, and the cause is structural rather than a
     * tuning error: the port's one-pole is G(1+z^-1)/(1-Az^-1), so it carries
     * a ZERO AT NYQUIST. At 4x those four zeros sit at 88.2 kHz and do
     * nothing in band; at 1x they sit at 22.05 kHz and gut the top octave.
     * No choice of corner frequency can move them.
     *
     * So map what CAN be mapped exactly -- the pole. Four steps of a pole A
     * at 4x is A^4 at 1x, exactly. Drop the numerator and normalise for unity
     * DC. The cascade is then a plain 4-pole with the port's own decay per
     * output sample and no spurious notch.
     */
    A1 = 1.0f - (G + G);
    A1 = (A1 * A1) * (A1 * A1);                 /* A^4, exact 4x -> 1x */
    G1 = 1.0f - A1;                             /* unity DC             */
    (void)g4; (void)t; (void)g1;
#else
    g4 = G / (1.0f - G);
    if (!(g4 < 0.40f)) g4 = 0.40f;              /* the documented clamp */
    t  = (g4 + g4) / (1.0f - (g4 * g4));
    g1 = (t + t) / (1.0f - (t * t));
    G1 = g1 / (1.0f + g1);
    A1 = 1.0f - (G1 + G1);
#endif
    R1 = 1.0f / ((((G1 * G1) * (G1 * G1)) * k) + 1.0f);
    Rk1 = R1 * k;

    xz = st->nl; y1z = st->y1; y2z = st->y2; y3z = st->y3; y4z = st->y4;

    x = (drive * R1) - ((st->s1 * c->c9520) * Rk1);
#if EB_VCF_NOSAT
    nl = x;                                     /* the linear skeleton, G-A */
#else
    if (x >= -1.0f) { if (x > 1.0f) x = 1.0f; } else { x = -1.0f; }
    nl = x + ((((x * x) * x) * x) * (x * c->c9184));
#endif

#if EB_VCF_ZDF1X == 2
    /* plain one-poles: y = G1*x + A1*y_prev, no numerator, no Nyquist zero.
     * S is the same object as the port's -- the cascade's output ONE STEP
     * AHEAD with zero input -- rebuilt for this recurrence rather than
     * copied, because the port's expression assumes its own numerator. */
    y1 = (G1 * nl) + (y1z * A1);
    y2 = (G1 * y1) + (y2z * A1);
    y3 = (G1 * y2) + (y3z * A1);
    y4 = (G1 * y3) + (y4z * A1);
    {   float z1 = A1 * y1, z2, z3;
        z2 = (G1 * z1) + (A1 * y2);
        z3 = (G1 * z2) + (A1 * y3);
        S  = (G1 * z3) + (A1 * y4);
    }
    (void)tt; (void)p2; (void)xz;
#else
    y1 = (G1 * (nl + xz)) + (y1z * A1);
    tt = G1 * (y1 + y1z);
    p2 = G1 * (((G1 * nl) + (A1 * y1)) + y1);
    y2 = tt + (y2z * A1);
    y3 = (G1 * (y2 + y2z)) + (y3z * A1);
    y4 = ((y3z + y3) * G1) + (A1 * y4z);
    S  = (G1 * (((G1 * ((p2 + (A1 * y2)) + y2)) + (A1 * y3)) + y3)) + (A1 * y4);
#endif

    st->nl = nl; st->y1 = y1; st->y2 = y2; st->y3 = y3; st->y4 = y4;
    st->s1 = S;

    /* c9152 IS KEPT, AND GATE G-A IS WHY. The first draft dropped it with the
     * decimator, reasoning that a 4x output gain belongs to a 4x path. The
     * gate's DC column then read port 0.97022 against 0.24254 -- a ratio of
     * EXACTLY 4.0000, which is not a response error at all: c9136 scales the
     * INPUT by 0.25 and c9152 restores it at the output. The decimator has
     * unity DC gain and never carried this factor. Measured, not reasoned:
     * the assumption in the deleted comment was wrong in the direction that
     * would have been absorbed silently by a fitted makeup gain in S4, and
     * the fit would then have been hiding a factor of four. */
    return (y4 * c->c9104) * c->c9152;
}
#else
float eb_vcf_tick(eb_vcf_state *st, const eb_vcf_coef *c,
                  float in, float G, float k)
{
    float A, R, Rk, d, drive, prev, acc;
    float *h = st->h;
    int hi = st->hi;
    int j;

    /* --------------------------------------------------- the input node
     * :1340-1349. The dither is a free-running 24-bit wrap oscillator that
     * never reads the audio; the port's [8992] shadow of it is dropped.      */
    d     = st->dith;
    drive = (((k * c->c9168) + 1.0f) * (in * c->c9136)) + ((-d) * c->c9120);
    st->dith = eb_wrap24(-d);
    prev  = st->drive_prev;
    st->drive_prev = drive;

#if EB_VCF_GRANGE
    ++eb_g_n;
    if (G < eb_g_lo) eb_g_lo = G;
    if (G > eb_g_hi) eb_g_hi = G;
    if (G > 0.41421354f) ++eb_g_over;
    if (k < eb_k_lo) eb_k_lo = k;
    if (k > eb_k_hi) eb_k_hi = k;
#endif
    A  = 1.0f - (G + G);                                        /* :1344 */
    R  = 1.0f / ((((G * G) * (G * G)) * k) + 1.0f);             /* :1345 */
    Rk = R * k;                                                 /* :1349 */

#if EB_HALF_OS_VCF
    /* ================================================ HALF-OVERSAMPLED PATH
     * TWO sub-steps at 88.2 kHz instead of four at 176.4 kHz.
     *
     * THE CUTOFF TRANSFORM IS EXACT ALGEBRA AND NEEDS NO FREQUENCY --
     * BUT NOT THE ALGEBRA F5 WROTE. F5 §3 says G = tan(pi f / fs) and hence
     * G' = 2G/(1-G^2). That is wrong about this filter, and the gate caught
     * it: up to 29 dB of error at high cutoff and high resonance.
     *
     * Read the one-pole above instead of assuming its parameterisation:
     *
     *     H(z) = G (1 + z^-1) / (1 - A z^-1),   A = 1 - 2G
     *
     * Matching that against the bilinear lowpass gives pole (1-g)/(1+g) and
     * gain g/(1+g) with g = tan(pi f / fs). Both identities hold at once
     * only if
     *
     *     G = g / (1 + g),   i.e.   g = G / (1 - G)
     *
     * -- G is the bilinear gain, NOT the prewarped tangent. So the correct
     * half-rate map goes through g and back:
     *
     *     g4 = G / (1 - G)                      (recover the tangent)
     *     g2 = tan(2 atan g4) = 2 g4/(1 - g4^2) (same cutoff, half the rate)
     *     G' = g2 / (1 + g2)                    (back to the port's variable)
     *
     * Still exact, still needs no frequency, and it is what the response
     * gate passes on.
     *
     * THE GUARD IS REAL, not defensive decoration: g2 runs to infinity as
     * g4 -> 1 (f -> fs4/4 = 44.1 kHz). MEASURED over the whole gated battery
     * (17,199,360 calls, JUNO_EB_VCF_GRANGE=1), G lands in
     * [0.000119, 0.209771], so g4 <= 0.2655 and the clamp NEVER FIRES on any
     * factory patch. It is kept because "no factory patch reaches it" has
     * been an excuse in this project before, and because an unstable filter
     * is a worse failure than a wrong cutoff.
     *
     * THE INPUT WEIGHTS ARE READ, NOT DESIGNED. Dumped from a recalled engine
     * the port's four cells are c9216=0.75, c9232=0.25, c9248=0.5, c9200=1.0
     * -- exactly linear interpolation of the drive ramp at 1/4, 1/2, 3/4, 1.
     * The two half-rate sub-instants are therefore 1/2 and 1, which are the
     * port's OWN second and fourth inputs, used verbatim. */
    {
        float g4, g2, Gp, Ap, Rp, Rkp;
#if EB_VCF_MAPFAST
        /* THE SAME MAP IN ONE DIVISION INSTEAD OF THREE.
         *
         * Substituting the three steps into each other:
         *     g4 = G/(1-G)
         *     g2 = 2*g4/(1-g4^2) = 2G(1-G)/(1-2G)
         *     Gp = g2/(1+g2)     = 2G(1-G)/(1-2G^2)
         * VERIFIED EXACT over 289 rationals G = 0.001..0.289 in exact
         * arithmetic -- this is an identity, not a fit. What is NOT exact is
         * the float32 evaluation, because the same real number reached by a
         * different sequence of roundings is a different float: MEASURED
         * worst 5 ULP over the whole measured domain G in [0.000119,
         * 0.209771]. So this is FORK-ONLY and its gate is the sonic gate,
         * never the null.
         *
         * THE CLAMP IS THE SAME CLAMP, MOVED. g4 <= sqrt(2)-1 is exactly
         * G <= 1 - 1/sqrt(2) = 0.29289322, and at that point both forms give
         * Gp = 0.5 -- checked, not assumed. It also guards the closed form's
         * OWN pole at 1-2G^2 = 0, i.e. G = 1/sqrt(2) = 0.7071, which sits far
         * above it. MEASURED over the whole battery G never exceeds 0.209771,
         * so the clamp does not fire on any factory patch; it is kept for the
         * same reason the original is -- an unstable filter is a worse failure
         * than a wrong cutoff.
         *
         * Two divisions and one operation come out. The remaining Rp division
         * stays: 1/(G^4 k + 1) is not part of this identity, and the file's
         * own header refuses a reciprocal APPROXIMATION by name. */
        {   float Gc = G;
            if (Gc > 0.29289322f) {
                Gc = 0.29289322f;
#if EB_VCF_CLAMP_COUNT
                ++eb_vcf_clamp_hits;
#endif
            }
            Gp = ((Gc + Gc) * (1.0f - Gc)) / (1.0f - ((Gc * Gc) + (Gc * Gc)));
        }
        (void)g4; (void)g2;
#else
        g4 = G / (1.0f - G);
        if (g4 > 0.41421354f) {
            g4 = 0.41421354f;
#if EB_VCF_CLAMP_COUNT
            ++eb_vcf_clamp_hits;
#endif
        }
        g2  = (g4 + g4) / (1.0f - (g4 * g4));
        Gp  = g2 / (1.0f + g2);
#endif
        Ap  = 1.0f - (Gp + Gp);
        Rp  = EB_DIV(1.0f, ((((Gp * Gp) * (Gp * Gp)) * k) + 1.0f));
        Rkp = Rp * k;

        hi = (hi + 1) & 31;
        h[hi] = eb_vcf_substep(st, c, ((prev + drive) * c->c9248) * Rp,
                               Gp, Ap, Rkp);
        hi = (hi + 1) & 31;
        h[hi] = eb_vcf_substep(st, c, (drive * c->c9200) * Rp,
                               Gp, Ap, Rkp);
        st->hi = hi;
        (void)A; (void)R; (void)Rk;
    }

    /* THE 2x DECIMATOR. The same designed 24-tap FIR the DCO path uses, and
     * that is not a convenience: dumped from a recalled engine, the VCF's
     * sixteen cells (9504 - 16i) and the DCO decimator's (5696 + 16i) hold
     * the SAME MULTISET of values -- one filter, written in two orders. So
     * gate 1's 0.0783 dB response match covers this decimator as well, and
     * a second design would have been a second chance to be wrong.
     *
     * Folded and unrolled for the same measured reason as eb_decim.c: the
     * rolled form was more expensive than the 4x code it replaces. */
    {
        int base = hi + 32;
        float a0, b0;
        acc = 0.0f;
#if EB_DECIM_AVG
        /* LEVER A3. The two newest sub-samples, averaged, carrying the 16-tap
         * filter's OWN DC gain (1.0001332) so the output LEVEL cannot move --
         * only the stopband does. j and the fir table stay referenced so the
         * flag cannot silently drop a symbol it was meant to replace. */
        (void)b0;
        a0 = h[base & 31] + h[(base - 1) & 31];
        acc = a0 * 0.50006661f;
        (void)j; (void)eb_vcf_halfos_fir;
#else
#if defined(__GNUC__)
#pragma GCC unroll 12
#endif
        /* THE LADDER'S OWN 2x DECIMATOR, not the DCO's. See
         * eb_vcf_halfos_fir.h: reusing eb_halfos_fir here measured 24.80 dB
         * on the sonic gate, because it is a different filter. */
        for (j = 0; j < EB_VCF_HALFOS_TAPS / 2; ++j) {
            a0 = h[(base - j) & 31];
            b0 = h[(base - (EB_VCF_HALFOS_TAPS - 1) + j) & 31];
            acc += (a0 + b0) * eb_vcf_halfos_fir[j];
        }
#endif
    }
#else
    hi = (hi + 1) & 31;
    h[hi] = eb_vcf_substep(st, c, ((prev * c->c9216) + (drive * c->c9232)) * R,
                           G, A, Rk);
    hi = (hi + 1) & 31;
    h[hi] = eb_vcf_substep(st, c, ((prev + drive) * c->c9248) * R,
                           G, A, Rk);
    hi = (hi + 1) & 31;
    h[hi] = eb_vcf_substep(st, c, ((prev * c->c9232) + (drive * c->c9216)) * R,
                           G, A, Rk);
    hi = (hi + 1) & 31;
    h[hi] = eb_vcf_substep(st, c, (drive * c->c9200) * R,
                           G, A, Rk);
    st->hi = hi;

    /* ------------------------------------------------------- decimator
     * :1489-1513. A symmetric 32-tap FIR folded into 16 coefficients,
     * accumulated CENTRE PAIR FIRST and outward -- which is the port's own
     * association order, not a choice made here. The port's spelling of the
     * same sum interleaves four 8-cell lines; the mapping (line, slot) ->
     * 4x delay is  A/B/C/D = delay 0/1/2/3 mod 4, slot = delay/4, which is why
     * this is one ring and not four.                                        */
#if defined(EB_ABLATE) && EB_ABLATE == 9      /* EB_ABL_DECIM, cost only */
    /* Splits the ladder's measured 1,083 cycles/voice into FOUR SUB-STEPS and
     * DECIMATOR. Deliberately wrong audio: it takes the newest 4x sample
     * instead of filtering the last 32. Never gated, never shipped. */
    acc = h[hi & 31];
    (void)j;
#else
    acc = (h[(hi - 15) & 31] + h[(hi - 16) & 31]) * c->fir[0];
    for (j = 1; j < 16; ++j)
        acc += (h[(hi - (15 - j)) & 31] + h[(hi - (16 + j)) & 31]) * c->fir[j];
#endif
#endif  /* EB_HALF_OS_VCF */

    return acc * c->c9152;                                      /* :1513 */
}
#endif  /* EB_VCF_ZDF1X */

#if EB_VCF_ILV
#if !EB_VCF_DEADCOEF || EB_VCF_ADAA || EB_VCF_NOSAT || EB_VCF_ZDF1X \
    || EB_VCF_SATFIT || (EB_HALF_OS_VCF && EB_DECIM_AVG)
#error "EB_VCF_ILV supports the shipping 4x ladder and the HALF-OS ladder (DEADCOEF on, no ADAA/NOSAT/ZDF1X/SATFIT, and no DECIM_AVG under half-OS). tick2 falls back to two tick() calls otherwise -- do not combine."
#endif

#if EB_HALF_OS_VCF
/* eb_vcf_tick2 -- TWO voices' HALF-OVERSAMPLED ladders, statements interleaved.
 *
 * SAME HYPOTHESIS AS THE 4x TICK2, CHEAPER TO TEST: the LX7 is in-order and
 * its FPU results are not available to the next instruction, so a single
 * voice's ladder is a chain of stalls. Two voices are independent, so their
 * statements are woven together and each fills the other's bubbles.
 *
 * WHY IT MAY WORK HERE WHERE THE 4x VERSION IS BOUNDED BY REGISTERS: the
 * half-OS ladder runs TWO sub-steps, not four, and the per-sub-step live set
 * is the same size either way -- but the DECIMATOR is 16 taps folded into 8
 * instead of 32 folded into 16, and the loop trip count halves. The register
 * question is settled by objdump (stack stores inside the sub-steps), not by
 * this comment.
 *
 * BIT-IDENTICAL to eb_vcf_tick(a) then eb_vcf_tick(b) under the same flags:
 * within each voice every operation and every association is the one
 * eb_vcf_tick + eb_vcf_substep already perform, in the same order. Only
 * INDEPENDENT statements of the two voices are interleaved. Nothing is
 * simplified, no expression is regrouped, and the two dead values A and R
 * (computed before the #if in eb_vcf_tick and immediately (void)-cast in its
 * half-OS arm) are simply not computed, which no float can observe.
 */
void eb_vcf_tick2(eb_vcf_state *sta, const eb_vcf_coef *ca, float ina, float Ga, float ka, float *outa,
                  eb_vcf_state *stb, const eb_vcf_coef *cb, float inb, float Gb, float kb, float *outb)
{
    float da, drivea, preva, acca; float *ha = sta->h; int hia = sta->hi;
    float db, driveb, prevb, accb; float *hb = stb->h; int hib = stb->hi;
    float g4a, g2a, Gpa, Apa, Rpa, Rkpa;
    float g4b, g2b, Gpb, Rpb, Apb, Rkpb;
    float xa, nla, y1a, y2a, y3a, y4a, tta, p2a, Sa, xza, y1za, y2za, y3za, y4za;
    float xb, nlb, y1b, y2b, y3b, y4b, ttb, p2b, Sb, xzb, y1zb, y2zb, y3zb, y4zb;
    float insa, insb, a0a, b0a, a0b, b0b;
    int basea, baseb, j;

    /* ------------------------------------------------- the input node */
    da = sta->dith;
    drivea = (((ka * ca->c9168) + 1.0f) * (ina * ca->c9136)) + ((-da) * ca->c9120);
    sta->dith = eb_wrap24(-da);
    preva = sta->drive_prev; sta->drive_prev = drivea;
    db = stb->dith;
    driveb = (((kb * cb->c9168) + 1.0f) * (inb * cb->c9136)) + ((-db) * cb->c9120);
    stb->dith = eb_wrap24(-db);
    prevb = stb->drive_prev; stb->drive_prev = driveb;

    /* ------------------------------------ the half-rate cutoff transform */
    g4a = Ga / (1.0f - Ga);
    if (g4a > 0.41421354f) {
        g4a = 0.41421354f;
#if EB_VCF_CLAMP_COUNT
        ++eb_vcf_clamp_hits;
#endif
    }
    g2a = (g4a + g4a) / (1.0f - (g4a * g4a));
    Gpa = g2a / (1.0f + g2a);
    Apa = 1.0f - (Gpa + Gpa);
    Rpa = 1.0f / ((((Gpa * Gpa) * (Gpa * Gpa)) * ka) + 1.0f);
    Rkpa = Rpa * ka;
    g4b = Gb / (1.0f - Gb);
    if (g4b > 0.41421354f) {
        g4b = 0.41421354f;
#if EB_VCF_CLAMP_COUNT
        ++eb_vcf_clamp_hits;
#endif
    }
    g2b = (g4b + g4b) / (1.0f - (g4b * g4b));
    Gpb = g2b / (1.0f + g2b);
    Apb = 1.0f - (Gpb + Gpb);
    Rpb = 1.0f / ((((Gpb * Gpb) * (Gpb * Gpb)) * kb) + 1.0f);
    Rkpb = Rpb * kb;

    /* ------------------------------------------------------ sub-step 1
     * input weight c9248 -- the port's own 1/2 instant. */
    insa = ((preva + drivea) * ca->c9248) * Rpa;
    insb = ((prevb + driveb) * cb->c9248) * Rpb;
    xza = sta->nl; y1za = sta->y1; y2za = sta->y2; y3za = sta->y3; y4za = sta->y4;
    xzb = stb->nl; y1zb = stb->y1; y2zb = stb->y2; y3zb = stb->y3; y4zb = stb->y4;
    xa = insa - ((sta->s1 * ca->c9520) * Rkpa);
    xb = insb - ((stb->s1 * cb->c9520) * Rkpb);
    if (xa >= -1.0f) { if (xa > 1.0f) xa = 1.0f; } else xa = -1.0f;
    if (xb >= -1.0f) { if (xb > 1.0f) xb = 1.0f; } else xb = -1.0f;
    nla = xa + ((((xa * xa) * xa) * xa) * (xa * ca->c9184));
    nlb = xb + ((((xb * xb) * xb) * xb) * (xb * cb->c9184));
    y1a = (Gpa * (nla + xza)) + (y1za * Apa);
    y1b = (Gpb * (nlb + xzb)) + (y1zb * Apb);
    tta = Gpa * (y1a + y1za);
    ttb = Gpb * (y1b + y1zb);
    p2a = Gpa * (((Gpa * nla) + (Apa * y1a)) + y1a);
    p2b = Gpb * (((Gpb * nlb) + (Apb * y1b)) + y1b);
    y2a = tta + (y2za * Apa);
    y2b = ttb + (y2zb * Apb);
    y3a = (Gpa * (y2a + y2za)) + (y3za * Apa);
    y3b = (Gpb * (y2b + y2zb)) + (y3zb * Apb);
    y4a = ((y3za + y3a) * Gpa) + (Apa * y4za);
    y4b = ((y3zb + y3b) * Gpb) + (Apb * y4zb);
    Sa = (Gpa * (((Gpa * ((p2a + (Apa * y2a)) + y2a)) + (Apa * y3a)) + y3a)) + (Apa * y4a);
    Sb = (Gpb * (((Gpb * ((p2b + (Apb * y2b)) + y2b)) + (Apb * y3b)) + y3b)) + (Apb * y4b);
    sta->nl = nla; sta->y1 = y1a; sta->y2 = y2a; sta->y3 = y3a; sta->y4 = y4a; sta->s1 = Sa;
    stb->nl = nlb; stb->y1 = y1b; stb->y2 = y2b; stb->y3 = y3b; stb->y4 = y4b; stb->s1 = Sb;
    hia = (hia + 1) & 31; ha[hia] = y4a * ca->c9104;
    hib = (hib + 1) & 31; hb[hib] = y4b * cb->c9104;

    /* ------------------------------------------------------ sub-step 2
     * input weight c9200 -- the port's own instant 1. */
    insa = (drivea * ca->c9200) * Rpa;
    insb = (driveb * cb->c9200) * Rpb;
    xza = nla; y1za = y1a; y2za = y2a; y3za = y3a; y4za = y4a;
    xzb = nlb; y1zb = y1b; y2zb = y2b; y3zb = y3b; y4zb = y4b;
    xa = insa - ((Sa * ca->c9520) * Rkpa);
    xb = insb - ((Sb * cb->c9520) * Rkpb);
    if (xa >= -1.0f) { if (xa > 1.0f) xa = 1.0f; } else xa = -1.0f;
    if (xb >= -1.0f) { if (xb > 1.0f) xb = 1.0f; } else xb = -1.0f;
    nla = xa + ((((xa * xa) * xa) * xa) * (xa * ca->c9184));
    nlb = xb + ((((xb * xb) * xb) * xb) * (xb * cb->c9184));
    y1a = (Gpa * (nla + xza)) + (y1za * Apa);
    y1b = (Gpb * (nlb + xzb)) + (y1zb * Apb);
    tta = Gpa * (y1a + y1za);
    ttb = Gpb * (y1b + y1zb);
    p2a = Gpa * (((Gpa * nla) + (Apa * y1a)) + y1a);
    p2b = Gpb * (((Gpb * nlb) + (Apb * y1b)) + y1b);
    y2a = tta + (y2za * Apa);
    y2b = ttb + (y2zb * Apb);
    y3a = (Gpa * (y2a + y2za)) + (y3za * Apa);
    y3b = (Gpb * (y2b + y2zb)) + (y3zb * Apb);
    y4a = ((y3za + y3a) * Gpa) + (Apa * y4za);
    y4b = ((y3zb + y3b) * Gpb) + (Apb * y4zb);
    Sa = (Gpa * (((Gpa * ((p2a + (Apa * y2a)) + y2a)) + (Apa * y3a)) + y3a)) + (Apa * y4a);
    Sb = (Gpb * (((Gpb * ((p2b + (Apb * y2b)) + y2b)) + (Apb * y3b)) + y3b)) + (Apb * y4b);
    sta->nl = nla; sta->y1 = y1a; sta->y2 = y2a; sta->y3 = y3a; sta->y4 = y4a; sta->s1 = Sa;
    stb->nl = nlb; stb->y1 = y1b; stb->y2 = y2b; stb->y3 = y3b; stb->y4 = y4b; stb->s1 = Sb;
    hia = (hia + 1) & 31; ha[hia] = y4a * ca->c9104;
    hib = (hib + 1) & 31; hb[hib] = y4b * cb->c9104;

    sta->hi = hia; stb->hi = hib;

    /* --------------------------------------------- the 2x decimator, folded
     * The accumulator starts at 0.0f and the first tap is ADDED to it, which
     * is what eb_vcf_tick does; 0.0f + x is not x when x is -0.0f, so the
     * initialisation is copied rather than folded away. */
    basea = hia + 32;
    baseb = hib + 32;
    acca = 0.0f;
    accb = 0.0f;
#if defined(__GNUC__)
#pragma GCC unroll 12
#endif
    for (j = 0; j < EB_VCF_HALFOS_TAPS / 2; ++j) {
        a0a = ha[(basea - j) & 31];
        a0b = hb[(baseb - j) & 31];
        b0a = ha[(basea - (EB_VCF_HALFOS_TAPS - 1) + j) & 31];
        b0b = hb[(baseb - (EB_VCF_HALFOS_TAPS - 1) + j) & 31];
        acca += (a0a + b0a) * eb_vcf_halfos_fir[j];
        accb += (a0b + b0b) * eb_vcf_halfos_fir[j];
    }

    *outa = acca * ca->c9152;
    *outb = accb * cb->c9152;
}
#else
/* eb_vcf_tick2 -- TWO voices' 4x ladders, statements interleaved.
 *
 * The four sub-steps of ONE voice are a serial chain: each reads the
 * previous sub-step's feedback S and cascade state. They cannot overlap. Two
 * DIFFERENT voices are independent, so their sub-steps are interleaved here,
 * giving the in-order LX7 FPU two dependency chains to fill each other's
 * latency bubbles -- the measured c/i 1.56 with a flat slope is exactly that
 * stall.
 *
 * BIT-IDENTICAL to eb_vcf_tick(a) then eb_vcf_tick(b): no operation inside
 * either voice is reordered, only independent operations of the two voices
 * are woven together. The null gate holds it to EXACTLY 0.
 */
void eb_vcf_tick2(eb_vcf_state *sta, const eb_vcf_coef *ca, float ina, float Ga, float ka, float *outa,
                  eb_vcf_state *stb, const eb_vcf_coef *cb, float inb, float Gb, float kb, float *outb)
{
    float Aa,Ra,Rka,da,drivea,preva,acca; float *ha=sta->h; int hia=sta->hi;
    float Ab,Rb,Rkb,db,driveb,prevb,accb; float *hb=stb->h; int hib=stb->hi;
    float xa,nla,y1a,y2a,y3a,y4a,ta,p2a,Sa, xza,y1za,y2za,y3za,y4za;
    float xb,nlb,y1b,y2b,y3b,y4b,tb,p2b,Sb, xzb,y1zb,y2zb,y3zb,y4zb;
    float insa, insb; int j, ss;

    da=sta->dith; drivea=(((ka*ca->c9168)+1.0f)*(ina*ca->c9136))+((-da)*ca->c9120); sta->dith=eb_wrap24(-da); preva=sta->drive_prev; sta->drive_prev=drivea;
    db=stb->dith; driveb=(((kb*cb->c9168)+1.0f)*(inb*cb->c9136))+((-db)*cb->c9120); stb->dith=eb_wrap24(-db); prevb=stb->drive_prev; stb->drive_prev=driveb;
    Aa=1.0f-(Ga+Ga); Ra=1.0f/((((Ga*Ga)*(Ga*Ga))*ka)+1.0f); Rka=Ra*ka;
    Ab=1.0f-(Gb+Gb); Rb=1.0f/((((Gb*Gb)*(Gb*Gb))*kb)+1.0f); Rkb=Rb*kb;

    /* the four input weights of the 4x path, both voices */
    for (ss = 0; ss < 4; ++ss) {
        switch (ss) {
        case 0: insa=((preva*ca->c9216)+(drivea*ca->c9232))*Ra; insb=((prevb*cb->c9216)+(driveb*cb->c9232))*Rb; break;
        case 1: insa=((preva+drivea)*ca->c9248)*Ra;             insb=((prevb+driveb)*cb->c9248)*Rb;             break;
        case 2: insa=((preva*ca->c9232)+(drivea*ca->c9216))*Ra; insb=((prevb*cb->c9232)+(driveb*cb->c9216))*Rb; break;
        default:insa=(drivea*ca->c9200)*Ra;                     insb=(driveb*cb->c9200)*Rb;                     break;
        }
        xza=sta->nl; y1za=sta->y1; y2za=sta->y2; y3za=sta->y3; y4za=sta->y4;
        xzb=stb->nl; y1zb=stb->y1; y2zb=stb->y2; y3zb=stb->y3; y4zb=stb->y4;
        xa = insa - ((sta->s1 * ca->c9520) * Rka);
        xb = insb - ((stb->s1 * cb->c9520) * Rkb);
        if (xa >= -1.0f) { if (xa > 1.0f) xa = 1.0f; } else xa = -1.0f;
        if (xb >= -1.0f) { if (xb > 1.0f) xb = 1.0f; } else xb = -1.0f;
        nla = xa + ((((xa * xa) * xa) * xa) * (xa * ca->c9184));
        nlb = xb + ((((xb * xb) * xb) * xb) * (xb * cb->c9184));
        y1a = (Ga * (nla + xza)) + (y1za * Aa);
        y1b = (Gb * (nlb + xzb)) + (y1zb * Ab);
        ta = Ga * (y1a + y1za);
        tb = Gb * (y1b + y1zb);
        p2a = Ga * (((Ga * nla) + (Aa * y1a)) + y1a);
        p2b = Gb * (((Gb * nlb) + (Ab * y1b)) + y1b);
        y2a = ta + (y2za * Aa);
        y2b = tb + (y2zb * Ab);
        y3a = (Ga * (y2a + y2za)) + (y3za * Aa);
        y3b = (Gb * (y2b + y2zb)) + (y3zb * Ab);
        y4a = ((y3za + y3a) * Ga) + (Aa * y4za);
        y4b = ((y3zb + y3b) * Gb) + (Ab * y4zb);
        Sa = (Ga * (((Ga * ((p2a + (Aa * y2a)) + y2a)) + (Aa * y3a)) + y3a)) + (Aa * y4a);
        Sb = (Gb * (((Gb * ((p2b + (Ab * y2b)) + y2b)) + (Ab * y3b)) + y3b)) + (Ab * y4b);
        sta->nl=nla; sta->y1=y1a; sta->y2=y2a; sta->y3=y3a; sta->y4=y4a; sta->s1=Sa;
        stb->nl=nlb; stb->y1=y1b; stb->y2=y2b; stb->y3=y3b; stb->y4=y4b; stb->s1=Sb;
        hia=(hia+1)&31; ha[hia]=y4a*ca->c9104;
        hib=(hib+1)&31; hb[hib]=y4b*cb->c9104;
    }
    sta->hi=hia; stb->hi=hib;

    {   int basea=hia+32, baseb=hib+32; float a0,b0,a0b,b0b;
        acca=(ha[(hia-15)&31]+ha[(hia-16)&31])*ca->fir[0];
        accb=(hb[(hib-15)&31]+hb[(hib-16)&31])*cb->fir[0];
        for (j=1;j<16;++j){
            acca+=(ha[(hia-(15-j))&31]+ha[(hia-(16+j))&31])*ca->fir[j];
            accb+=(hb[(hib-(15-j))&31]+hb[(hib-(16+j))&31])*cb->fir[j];
        }
        (void)basea;(void)baseb;(void)a0;(void)b0;(void)a0b;(void)b0b;
    }
    *outa=acca*ca->c9152; *outb=accb*cb->c9152;
}
#endif  /* EB_HALF_OS_VCF */
#endif  /* EB_VCF_ILV */

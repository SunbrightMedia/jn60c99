/* eb_pitch.c — VARIANT v3 "Horner in slimmed triple-float" (PROBE BUILD;
 * this file is the INTEGRATION SHAPE — the same code that goes behind
 * EB_PITCH_FAST in engine_b/eb_pitch.c, including the lazy split-table).
 *
 * WHY TRIPLE-FLOAT. MEASURED (scratchpad pitch_sweep.c, 1.45M evals over all
 * 29 table rows): the ~49-bit Dekker variants' distance from the port's
 * double result has a tail of 25k+ float-ulp, dominated by u^2-level term-
 * formation error amplified by the polynomial's cancellation, while the
 * double reference's OWN rounding wander (double vs long-double, the floor
 * no forward-accuracy candidate can beat) is 533 ulp worst. Neumaier or
 * accurate-df sums do not move that tail (v3a worst 66500, v3b-class worst
 * 22-32k): the gap is term formation, not summation order. A triple-float
 * (h+m+l, coefficients split EXACTLY — 3x24 bits >= 53) evaluation whose only
 * inexactness is u^3-level roundings lands EXACTLY on the floor: 222,597
 * flips / worst 533 ulp vs the floor's 222,592 / 534 over the same sweep.
 *
 * STRUCTURE CHANGES vs the port (all legal because the evaluation tracks the
 * EXACT value far below the reference's own error, so grouping no longer
 * matters — unlike every df variant, which had to mimic the port's order):
 *   - Horner instead of explicit powers (12 mul-by-x + 13 coefficient adds);
 *   - the x >= 8.9 clamp arm returns a CONSTANT: the port evaluates the whole
 *     arm at exactly (double)8.9, so its float result is one number per
 *     table; it is computed ONCE by the port's own double arithmetic (cold
 *     path) and is therefore BIT-EXACT for the entire arm;
 *   - clamp and row are float-only, PROVEN equal to the port's double
 *     fmin/fmax clamp + (int)(x+20.0) over ALL 2^32 float bit patterns
 *     (scratchpad clamp_exhaust.c: row 0 mismatches; clamp 0 mismatches
 *     outside the 8.9 arm, which the constant above makes exact anyway).
 *
 * The ONLY remaining double arithmetic is on COLD paths that run once per
 * row: the 3-way coefficient split cache and the 8.9-arm constant. The
 * per-sample path is pure single-float FPU.
 *
 * FMA WOULD BREAK THIS FILE: TwoSum/TwoProd algebra requires every listed
 * rounding to happen. Build with -ffp-contract=off (repo standard). */
#include "eb_pitch.h"
#include <math.h>

typedef struct { float hi, lo; } df;

/* Knuth TwoSum: a + b = s + e exactly. */
static df two_sum(float a, float b)
{
    df r;
    r.hi = a + b;
    {
        float bb = r.hi - a;
        r.lo = (a - (r.hi - bb)) + (b - bb);
    }
    return r;
}

/* Fast TwoSum: exact when |a| >= |b| or a == 0 (holds at its one use site:
 * |t1.hi| is a few ulp of |p0.hi|, and p0.hi == 0 forces t1.hi == 0). */
static df fast_two_sum(float a, float b)
{
    df r;
    r.hi = a + b;
    r.lo = b - (r.hi - a);
    return r;
}

/* Veltkamp split of x, cached once per call: every Horner step multiplies by
 * the same x. */
typedef struct { float shi, slo, v; } xsplit;

static xsplit xs_make(float x)
{
    xsplit s;
    float c = 4097.0f * x;
    s.shi = c - (c - x);
    s.slo = x - s.shi;
    s.v = x;
    return s;
}

/* Dekker TwoProd a*x, x pre-split: exact product as hi + lo. */
static df two_prod_xs(float a, xsplit x)
{
    df sa, r;
    {
        float c = 4097.0f * a;
        sa.hi = c - (c - a);
        sa.lo = a - sa.hi;
    }
    r.hi = a * x.v;
    r.lo = ((sa.hi * x.shi - r.hi) + sa.hi * x.slo + sa.lo * x.shi)
           + sa.lo * x.slo;
    return r;
}

/* value = h + m + l, |m| ~ ulp(h), |l| ~ ulp(m) after renormalization */
typedef struct { float h, m, l; } tf;

/* s*x: only u^3-LEVEL ROUNDINGS are inexact (both u-level products are exact
 * TwoProds; their error limbs join the residue stream). */
static tf tf_mulx(tf a, xsplit x)
{
    df p0 = two_prod_xs(a.h, x);
    df p1 = two_prod_xs(a.m, x);
    float q = a.l * x.v;                    /* u^2-level piece, rounds u^3 */
    df s1 = two_sum(p0.lo, p1.hi);
    float r2 = (s1.lo + q) + p1.lo;
    df t1 = two_sum(s1.hi, r2);
    df t0 = fast_two_sum(p0.hi, t1.hi);
    df ml = two_sum(t0.lo, t1.lo);
    {
        tf r;
        r.h = t0.hi; r.m = ml.hi; r.l = ml.lo;
        return r;
    }
}

/* s + coefficient (a constant tf). Full TwoSum at the head of the
 * renormalization because s0.hi may have CANCELLED below t2.hi — the exact
 * case the -100 dB gate exists for. */
static tf tf_addc(tf a, const float *c)     /* c = {h, m, l} */
{
    df s0 = two_sum(a.h, c[0]);
    df s1 = two_sum(a.m, c[1]);
    df t1 = two_sum(s0.lo, s1.hi);
    float r2 = (a.l + c[2]) + (s1.lo + t1.lo);
    df t2 = two_sum(t1.hi, r2);
    df t0 = two_sum(s0.hi, t2.hi);
    df ml = two_sum(t0.lo, t2.lo);
    {
        tf r;
        r.h = t0.hi; r.m = ml.hi; r.l = ml.lo;
        return r;
    }
}

/* ---- clamp + row, float-only, PROVEN == port over all 2^32 inputs ------- */
/* 0x410E6667 = 8.9000006f = the smallest float > (double)8.9: floats at or
 * above it are exactly the set the port's fmin clamps to 8.9. */
#define EB_P_HI89 8.9000006f
/* |y| < 2^-27: the one corner where (int)((double)y + 20.0) may round across
 * the integer boundary; delegate to the port's own double there (cold). */
#define EB_P_TINY (-7.450581e-9f)

static float eb_clampf(float cv)
{
    float y = cv;
    if (!(y >= -20.0f))                     /* catches NaN like fmax does */
        y = -20.0f;
    return y;
}

int eb_pitch_row(float cv)
{
    float y = eb_clampf(cv);
    if (y >= EB_P_HI89) return 28;
    if (y >= 0.0f) return 20 + (int)y;
    if (y > EB_P_TINY) return (int)((double)y + 20.0);   /* cold corner */
    return 20 + (int)y - ((float)(int)y != y);           /* floor, y < 0 */
}

/* Lazy per-row coefficient cache: tab[2k] split EXACTLY into three floats
 * (24+24+24 bits >= a double's 53). Filled once per row ever seen, from the
 * caller's own table row; the double arithmetic below is COLD-PATH ONLY.
 * The 8.9-arm constant c89 is the port's own double evaluation at exactly
 * 8.9, so that arm is BIT-EXACT, not approximated. */
static float eb_p_sp[29][13][3];
static unsigned char eb_p_init[29];
static float eb_p_c89;
static unsigned char eb_p_c89i;

static void eb_p_split_row(int row, const double *tab)
{
    int k;
    for (k = 0; k < 13; k++) {
        double v = tab[2 * k];
        float h = (float)v;
        float m = (float)(v - (double)h);
        float l = (float)(v - (double)h - (double)m);
        eb_p_sp[row][k][0] = h;
        eb_p_sp[row][k][1] = m;
        eb_p_sp[row][k][2] = l;
    }
    eb_p_init[row] = 1;
}

float eb_pitch_eval(float cv, const double *tab, float gain)
{
    float y = eb_clampf(cv);
    if (y >= EB_P_HI89) {
        if (!eb_p_c89i) {                   /* cold: port's own double math */
            double x = 8.9;
            double x3 = x * x * x, x5 = x3 * x * x;
            double x8 = x5 * x * x * x, x10 = x8 * x * x;
            double s = x * tab[2] + tab[0] + x * x * tab[4] + x3 * tab[6]
                     + x3 * x * tab[8] + x5 * tab[10] + x5 * x * tab[12]
                     + x5 * x * x * tab[14] + x8 * tab[16] + x8 * x * tab[18]
                     + x10 * tab[20] + x10 * x * tab[22]
                     + x10 * x * x * tab[24];
            eb_p_c89 = fmaxf(fminf((float)s, 512.0f), -512.0f);
            eb_p_c89i = 1;
        }
        return eb_p_c89 * gain;
    }
    {
        int row = eb_pitch_row(cv);
        const float (*C)[3];
        if (!eb_p_init[row])
            eb_p_split_row(row, tab);       /* cold: once per row ever */
        C = eb_p_sp[row];
        {
            xsplit xs = xs_make(y);
            tf s;
            s.h = C[12][0]; s.m = C[12][1]; s.l = C[12][2];
            s = tf_addc(tf_mulx(s, xs), C[11]);
            s = tf_addc(tf_mulx(s, xs), C[10]);
            s = tf_addc(tf_mulx(s, xs), C[9]);
            s = tf_addc(tf_mulx(s, xs), C[8]);
            s = tf_addc(tf_mulx(s, xs), C[7]);
            s = tf_addc(tf_mulx(s, xs), C[6]);
            s = tf_addc(tf_mulx(s, xs), C[5]);
            s = tf_addc(tf_mulx(s, xs), C[4]);
            s = tf_addc(tf_mulx(s, xs), C[3]);
            s = tf_addc(tf_mulx(s, xs), C[2]);
            s = tf_addc(tf_mulx(s, xs), C[1]);
            s = tf_addc(tf_mulx(s, xs), C[0]);
            {
                float out = s.h + (s.m + s.l);
                return fmaxf(fminf(out, 512.0f), -512.0f) * gain;
            }
        }
    }
}

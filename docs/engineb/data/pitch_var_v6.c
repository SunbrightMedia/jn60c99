/* eb_pitch.c — VARIANT V6 "compensated dekker + exact-double fallback below x=-6" (PROBE).
 *
 * Double-float (Dekker) arithmetic: every value is an unevaluated sum of two
 * floats (hi + lo), ~49 effective mantissa bits. Products via Dekker TwoProd
 * with the FMA-free 4097 split; sums via Knuth TwoSum. No double arithmetic
 * anywhere on the evaluation path. Term order matches the port's.
 *
 * Coefficients: tab[i] (double) is split ONCE at use into
 * hi = (float)tab[i], lo = (float)(tab[i] - hi) -- the same two floats a
 * pre-split float table would hold on the S3 (the only double ops are these
 * conversions, which a real S3 build does at table-generation time, not at
 * runtime). */
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

/* Dekker split, FMA-free: a = hi + lo with hi carrying the top 12 bits. */
static df d_split(float a)
{
    df r;
    float c = 4097.0f * a;
    r.hi = c - (c - a);
    r.lo = a - r.hi;
    return r;
}

/* Dekker TwoProd: a * b = p + e exactly (barring overflow of the split). */
static df two_prod(float a, float b)
{
    df sa = d_split(a), sb = d_split(b);
    df r;
    r.hi = a * b;
    r.lo = ((sa.hi * sb.hi - r.hi) + sa.hi * sb.lo + sa.lo * sb.hi)
           + sa.lo * sb.lo;
    return r;
}

/* df + df (Dekker add, branchless-simple form). */
static df df_add(df a, df b)
{
    df s = two_sum(a.hi, b.hi);
    float lo = s.lo + a.lo + b.lo;
    return two_sum(s.hi, lo);
}

/* df * df. v3: the a.lo*b.lo term is KEPT (dekker dropped it). One extra
 * multiply buys the last ~2^-48 of the product. */
static df df_mul(df a, df b)
{
    df p = two_prod(a.hi, b.hi);
    float lo = ((p.lo + a.lo * b.lo) + a.hi * b.lo) + a.lo * b.hi;
    return two_sum(p.hi, lo);
}

/* df * float. */
static df df_mulf(df a, float b)
{
    df p = two_prod(a.hi, b);
    float lo = p.lo + a.lo * b;
    return two_sum(p.hi, lo);
}

static df df_from(float x) { df r; r.hi = x; r.lo = 0.0f; return r; }

/* Split a double coefficient into a df pair (see the header comment). */
static df df_coef(double v)
{
    df r;
    r.hi = (float)v;
    r.lo = (float)(v - (double)r.hi);
    return r;
}

static float eb_pitch_clamp(float cv)
{
    return fminf(fmaxf(cv, -20.0f), 8.9f);
}

int eb_pitch_row(float cv)
{
    return (int)(eb_pitch_clamp(cv) + 20.0f);
}

/* v3 ACCUMULATOR: a df plus a separate compensation float. df_add loses bits
 * in its plain-float lo sum exactly where the 13 terms cancel -- and the two
 * scenarios that failed variant B are cancellation cases. Here every rounding
 * of the lo path is captured by a further two_sum and banked in c, giving the
 * SUM ~70+ effective bits while the terms stay ~49-bit dfs. */
typedef struct { df s; float c; } acc3;

static acc3 acc_add(acc3 A, df t)
{
    df s1 = two_sum(A.s.hi, t.hi);          /* exact */
    df s2 = two_sum(A.s.lo, t.lo);          /* exact */
    df s3 = two_sum(s1.lo, s2.hi);          /* exact */
    df r  = two_sum(s1.hi, s3.hi);          /* exact renormalize */
    acc3 out;
    out.s = r;
    out.c = (A.c + s2.lo) + s3.lo;
    return out;
}

/* THE HYBRID SPLIT. v3 passes 29/30; the one failure is 'DCO neg pitch
 * sweep' at -99.1 dB, and its cause is arithmetic, not chance: at large
 * negative x the 13 terms reach ~x^12 = 4e15 and cancel to <= 512, eating
 * ~52 bits -- double survives with margin, ~49-bit df does not. Below the
 * threshold this function therefore runs the PORT'S OWN double evaluation,
 * bit for bit; above it, the compensated float path. The choice is per call
 * from the input alone: no state, no seam, and the threshold sits in a region
 * (pitch CV < -9, deep sub-audio) that music rarely enters, so the S3 pays
 * the soft-double price only on rare samples. */
static float eb_pitch_eval_double(float x, const double *tab, float gain)
{
    double v385 = (double)x;
    double v386 = v385 * v385 * v385;
    double v388 = v386 * v385 * v385;
    double v389 = v388 * v385 * v385 * v385;
    double v390 = v389 * v385 * v385;
    double s = v385 * tab[2]
             + tab[0]
             + v385 * v385 * tab[4]
             + v386 * tab[6]
             + v386 * v385 * tab[8]
             + v388 * tab[10]
             + v388 * v385 * tab[12]
             + v388 * v385 * v385 * tab[14]
             + v389 * tab[16]
             + v389 * v385 * tab[18]
             + v390 * tab[20]
             + v390 * v385 * tab[22]
             + v390 * v385 * v385 * tab[24];
    return fmaxf(fminf((float)s, 512.0f), -512.0f) * gain;
}

float eb_pitch_eval(float cv, const double *tab, float gain)
{
    float x = eb_pitch_clamp(cv);
    df dx   = df_from(x);
    /* THE SPLIT, placed by MEASUREMENT (ULP sweep, 15.2M points, /tmp/psweep):
     * v3-vs-double disagreement peaks at 27,571 ULP in row 6 (x near -14) and
     * decays to <= 1-2 ULP above row 12; from x >= -6 the worst row is 8 ULP
     * and every scenario that exercises that range passes at -135 dB or
     * better. Below -6 the 13 terms cancel so hard that even double keeps only
     * ~14-20 good bits; ~49-bit double-float cannot follow it, and matching
     * the port there means using the port's own arithmetic. x < -6 is the
     * deep pitch-down region, rare in music, so the S3 pays the soft-double
     * price only on the voices and samples that actually go there. */
    if (x < -6.0f)
        return eb_pitch_eval_double(x, tab, gain);
    df x3   = df_mulf(df_mulf(dx, x), x);         /* v386 */
    df x5   = df_mulf(df_mulf(x3, x), x);         /* v388 */
    df x8   = df_mulf(df_mulf(df_mulf(x5, x), x), x); /* v389 */
    df x10  = df_mulf(df_mulf(x8, x), x);         /* v390 */

    acc3 A;
    A.s = df_mulf(df_coef(tab[2]), x);
    A.c = 0.0f;
    A = acc_add(A, df_coef(tab[0]));
    A = acc_add(A, df_mulf(df_mulf(df_coef(tab[4]), x), x));
    A = acc_add(A, df_mul(x3, df_coef(tab[6])));
    A = acc_add(A, df_mul(df_mulf(x3, x), df_coef(tab[8])));
    A = acc_add(A, df_mul(x5, df_coef(tab[10])));
    A = acc_add(A, df_mul(df_mulf(x5, x), df_coef(tab[12])));
    A = acc_add(A, df_mul(df_mulf(df_mulf(x5, x), x), df_coef(tab[14])));
    A = acc_add(A, df_mul(x8, df_coef(tab[16])));
    A = acc_add(A, df_mul(df_mulf(x8, x), df_coef(tab[18])));
    A = acc_add(A, df_mul(x10, df_coef(tab[20])));
    A = acc_add(A, df_mul(df_mulf(x10, x), df_coef(tab[22])));
    A = acc_add(A, df_mul(df_mulf(df_mulf(x10, x), x), df_coef(tab[24])));

    {
        float out = A.s.hi + (A.s.lo + A.c);
        return fmaxf(fminf(out, 512.0f), -512.0f) * gain;
    }
}

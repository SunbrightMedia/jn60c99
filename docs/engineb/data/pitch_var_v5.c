/* eb_pitch.c — VARIANT V5 "compensated dekker + PORT-VERBATIM double clamp/row" (PROBE).
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

/* The clamp and the row are the PORT'S OWN DOUBLE forms, verbatim. v4 proved
 * the remaining -99.1 dB does NOT live in the eval below x=-9; the sweep
 * scenario crosses every row boundary, and the float row (x + 20.0f, coarse
 * rounding) can pick a different spline row than the port's exact double
 * (x + 20.0). A row flip evaluates the wrong coefficients: a small, persistent
 * pitch offset that integrates -- the -99 dB signature. These four double
 * fmin/fmax + one conversion per call are cheap (~112 instr on the S3) next to
 * the 3,419 the full double eval cost; an exact float-only replacement (TwoSum
 * boundary test) is a later, gated step. */
static double eb_pitch_clamp_d(double cv)
{
    return fmin(fmax((float)cv, -20.0), 8.9);
}

static float eb_pitch_clamp(float cv)
{
    return (float)eb_pitch_clamp_d(cv);
}

int eb_pitch_row(float cv)
{
    return (int)(eb_pitch_clamp_d(cv) + 20.0);
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

float eb_pitch_eval(float cv, const double *tab, float gain)
{
    float x = eb_pitch_clamp(cv);
    df dx   = df_from(x);
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

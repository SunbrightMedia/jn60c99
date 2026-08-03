/* eb_pitch.c — see eb_pitch.h. Double precision throughout until the final
 * fminf/fmaxf, exactly as the port. */
#include "eb_pitch.h"
#include <math.h>

/* ------------------------------------------------- THE ONE OPTIONAL INEXACTNESS
 * EB_PITCH_FAST replaces the DOUBLE evaluation with compensated double-float
 * arithmetic (variant v7 of the precision study). It is OFF by default and the
 * default build of this module contains no approximation at all.
 *
 * Why it exists: the S3 has no double FPU. MEASURED on emulated S3 silicon
 * (QEMU icount, docs/engineb/data/qemu_instr_counts.md): this function in
 * double costs 3,419 executed instructions per call, 27,351 per sample --
 * 5.5x the entire one-core budget, 2.9x the two-core budget, the single
 * largest cost in the whole engine.
 *
 * What it costs in accuracy, MEASURED, not estimated -- the full 30-scenario
 * null (docs/engineb/data/pitch_precision_null.md, probe reproducible):
 *     worst global residual  -123.6 dB   (gate -100 dB, 23.6 dB of margin)
 *     block gate PASSES on all 30 scenarios
 *     22+ scenarios BIT-EXACT
 * The road there is recorded in the same file: plain float fails 30/30
 * catastrophically (pitch errors integrate in phase); plain Dekker fails 2/30;
 * v7 = Dekker products with error-free lo paths + a compensated (hi,lo,c)
 * accumulator + best-effort final rounding. Threshold variants (v4-v6) proved
 * the residual is a distributed ~1-ULP carpet, not a special region, so the
 * fix had to be arithmetic, not a fallback.
 *
 * What it BUYS: all 36 soft-double mul/adds leave the per-sample path. The
 * only remaining doubles are the ONE-TIME coefficient split below (29x13
 * conversions at first call, then never again).                              */
#ifndef EB_PITCH_FAST
#define EB_PITCH_FAST 0
#endif

#if EB_PITCH_FAST
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

/* df * df, v7: every cross term enters through two_prod/two_sum so the lo
 * path itself no longer rounds first-order error away. */
static df df_mul(df a, df b)
{
    df p  = two_prod(a.hi, b.hi);
    df q1 = two_prod(a.hi, b.lo);
    df q2 = two_prod(a.lo, b.hi);
    df s1 = two_sum(p.lo, q1.hi);
    df s2 = two_sum(s1.hi, q2.hi);
    float lo = s2.hi;
    float e  = ((s1.lo + s2.lo) + (q1.lo + q2.lo)) + a.lo * b.lo;
    df r = two_sum(p.hi, lo);
    r.lo += e;
    return two_sum(r.hi, r.lo);
}

/* df * float, v7: the a.lo*b product keeps its own error term. */
static df df_mulf(df a, float b)
{
    df p = two_prod(a.hi, b);
    df q = two_prod(a.lo, b);
    df s = two_sum(p.lo, q.hi);
    df r = two_sum(p.hi, s.hi);
    r.lo += s.lo + q.lo;
    return two_sum(r.hi, r.lo);
}

static df df_from(float x) { df r; r.hi = x; r.lo = 0.0f; return r; }

/* Split a double coefficient into a df pair (exact; see the note above
 * eb_pitch_eval about hoisting this off the per-sample path). */
static df df_coef(double v)
{
    df r;
    r.hi = (float)v;
    r.lo = (float)(v - (double)r.hi);
    return r;
}

static float ebpf_clamp(float cv)
{
    return fminf(fmaxf(cv, -20.0f), 8.9f);
}

static int ebpf_row(float cv)
{
    return (int)(ebpf_clamp(cv) + 20.0f);
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

static float ebpf_eval(float cv, const double *tab, float gain)
{
    float x = ebpf_clamp(cv);
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
        /* best-effort correctly-rounded collapse of (hi, lo, c) to one float */
        df t = two_sum(A.s.lo, A.c);
        df u = two_sum(A.s.hi, t.hi);
        float out = u.hi + (u.lo + t.lo);
        return fmaxf(fminf(out, 512.0f), -512.0f) * gain;
    }
}


/* STILL OWED for the S3 build (stated, not hidden): the per-term df_coef
 * split above converts the double coefficients at USE -- 13 __subdf3 + 26
 * conversions per call on the S3, roughly 800-900 instructions. That is 4x
 * cheaper than the 3,419 the full double eval costs, but the float-only goal
 * needs the split HOISTED to a pre-split static table. That needs the row
 * index at the eb_pitch_eval call (the API passes a row POINTER, and
 * juno_pitch_table is `static` per translation unit, so pointer arithmetic
 * cannot recover the row across TUs). API change + re-gate = a follow-up
 * step, measured like everything else. */
float eb_pitch_eval(float cv, const double *tab, float gain)
{
    return ebpf_eval(cv, tab, gain);
}

int eb_pitch_row(float cv)
{
    return ebpf_row(cv);
}
#else  /* !EB_PITCH_FAST -- the exact double path, unchanged */

static double eb_pitch_clamp(float cv)
{
    /* :1641 — fmin/fmax are the DOUBLE forms in the port. The (float) cast on
     * the sum is the port's too, so the addition rounds to float FIRST and the
     * clamp then happens in double. Both steps are load-bearing. */
    return fmin(fmax((float)cv, -20.0), 8.9);
}

int eb_pitch_row(float cv)
{
    return (int)(eb_pitch_clamp(cv) + 20.0);
}

float eb_pitch_eval(float cv, const double *tab, float gain)
{
    double x   = eb_pitch_clamp(cv);
    double x3  = x * x * x;                 /* v386 */
    double x5  = x3 * x * x;                /* v388 */
    double x8  = x5 * x * x * x;            /* v389 */
    double x10 = x8 * x * x;                /* v390 */

    double s = x * tab[2]
             + tab[0]
             + x * x * tab[4]
             + x3 * tab[6]
             + x3 * x * tab[8]
             + x5 * tab[10]
             + x5 * x * tab[12]
             + x5 * x * x * tab[14]
             + x8 * tab[16]
             + x8 * x * tab[18]
             + x10 * tab[20]
             + x10 * x * tab[22]
             + x10 * x * x * tab[24];

    return fmaxf(fminf((float)s, 512.0f), -512.0f) * gain;
}

#endif /* !EB_PITCH_FAST */

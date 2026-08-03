/* eb_pitch.c — VARIANT V9 (PROBE): the shipping v7 fast path with ONE change,
 * the complement of v8: the error-free product lo-paths (v7 df_mul/df_mulf)
 * are replaced by the simple Dekker forms, while the compensated (hi,lo,c)
 * accumulator is KEPT. Plain Dekker (simple products + simple add) failed
 * 2/30; v8 (error-free products + simple add) passed at -110.2 dB. This
 * variant isolates which upgrade carries the margin.  */
#define EB_PITCH_FAST 1
/* eb_pitch.c — see eb_pitch.h. Double precision throughout until the final
 * fminf/fmaxf, exactly as the port. */
#include "eb_pitch.h"
#include "juno_tables.h"
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
#include "eb_pitch_tab.h"

/* NOT INLINED, AND THAT IS MEASURED, NOT AN OVERSIGHT. Forcing
 * always_inline on the df helpers makes this function WORSE on the S3:
 * 3,452 static instructions inlined against 3,126 as calls. The reason is in
 * the mnemonic mix of the inlined build -- 1,254 `lsi` plus 423 `ssi`, i.e.
 * 1,677 of 3,452 instructions are float loads and stores. The LX7 has 16
 * float registers; the compensated double-float arithmetic keeps far more
 * values live than that, so inlining converts call overhead into spill
 * traffic and loses. Left as calls deliberately. */
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
    df p = two_prod(a.hi, b.hi);
    p.lo += a.hi * b.lo + a.lo * b.hi;
    return two_sum(p.hi, p.lo);
}

/* df * float, v7: the a.lo*b product keeps its own error term. */
static df df_mulf(df a, float b)
{
    df p = two_prod(a.hi, b);
    p.lo += a.lo * b;
    return two_sum(p.hi, p.lo);
}

/* the pre-split coefficient for term k of the selected row */
static df ebpf_c(const float *ch, const float *cl, int k)
{
    df r; r.hi = ch[k]; r.lo = cl[k]; return r;
}

static df df_from(float x) { df r; r.hi = x; r.lo = 0.0f; return r; }

/* Split a double coefficient into a df pair. NO LONGER ON THE PER-SAMPLE PATH:
 * eb_pitch_tab.h carries the same split as build-time constants. It is kept
 * because engine_b/tests/test_pitch_tab.c re-derives every generated pair with
 * THIS function and requires bit equality -- the generated table is checked
 * against the arithmetic it claims to replace, not trusted. */
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

static float ebpf_eval_row(float cv, int row, float gain)
{
    const float *ch = eb_pitch_hi[row];
    const float *cl = eb_pitch_lo[row];
    float x = ebpf_clamp(cv);
    df dx   = df_from(x);
    df x3   = df_mulf(df_mulf(dx, x), x);         /* v386 */
    df x5   = df_mulf(df_mulf(x3, x), x);         /* v388 */
    df x8   = df_mulf(df_mulf(df_mulf(x5, x), x), x); /* v389 */
    df x10  = df_mulf(df_mulf(x8, x), x);         /* v390 */

    acc3 A;
    A.s = df_mulf(ebpf_c(ch, cl, 1), x);
    A.c = 0.0f;
    A = acc_add(A, ebpf_c(ch, cl, 0));
    A = acc_add(A, df_mulf(df_mulf(ebpf_c(ch, cl, 2), x), x));
    A = acc_add(A, df_mul(x3, ebpf_c(ch, cl, 3)));
    A = acc_add(A, df_mul(df_mulf(x3, x), ebpf_c(ch, cl, 4)));
    A = acc_add(A, df_mul(x5, ebpf_c(ch, cl, 5)));
    A = acc_add(A, df_mul(df_mulf(x5, x), ebpf_c(ch, cl, 6)));
    A = acc_add(A, df_mul(df_mulf(df_mulf(x5, x), x), ebpf_c(ch, cl, 7)));
    A = acc_add(A, df_mul(x8, ebpf_c(ch, cl, 8)));
    A = acc_add(A, df_mul(df_mulf(x8, x), ebpf_c(ch, cl, 9)));
    A = acc_add(A, df_mul(x10, ebpf_c(ch, cl, 10)));
    A = acc_add(A, df_mul(df_mulf(x10, x), ebpf_c(ch, cl, 11)));
    A = acc_add(A, df_mul(df_mulf(df_mulf(x10, x), x), ebpf_c(ch, cl, 12)));

    {
        /* best-effort correctly-rounded collapse of (hi, lo, c) to one float */
        df t = two_sum(A.s.lo, A.c);
        df u = two_sum(A.s.hi, t.hi);
        float out = u.hi + (u.lo + t.lo);
        return fmaxf(fminf(out, 512.0f), -512.0f) * gain;
    }
}


/* THE SPLIT IS HOISTED (2026-08-03). It used to happen at USE: 13 __subdf3
 * plus 26 conversions per call on the S3, on the per-sample path, 8 times a
 * sample. eb_pitch_tab.h now carries the same two floats as build-time
 * constants, so this path executes NO double arithmetic at all. The API change
 * that made it possible: eb_pitch_eval takes the CV and reads its own row,
 * instead of being handed a row pointer it could not turn back into an index
 * (juno_pitch_table is `static` per translation unit). */
/* THE GENERATED TABLE IS CHECKED, NOT TRUSTED. Re-derives every one of the
 * 29x13 pre-split pairs with df_coef -- the arithmetic eb_pitch_tab.h claims to
 * replace -- and returns the number of pairs that do not match BIT FOR BIT.
 * Must be 0. engine_b/tests/test_pitch_tab.c calls it; if the table is ever
 * regenerated from a changed juno_pitch_table and drifts, that test goes red
 * instead of the engine going quietly wrong. */
int eb_pitch_tab_selfcheck(void)
{
    int r, k, bad = 0;
    for (r = 0; r < EB_PITCH_ROWS; ++r)
        for (k = 0; k < EB_PITCH_TERMS; ++k) {
            df want = df_coef(juno_pitch_table[r][2 * k]);
            if (want.hi != eb_pitch_hi[r][k] || want.lo != eb_pitch_lo[r][k])
                ++bad;
        }
    return bad;
}

float eb_pitch_eval(float cv, float gain)
{
    return ebpf_eval_row(cv, ebpf_row(cv), gain);
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

float eb_pitch_eval(float cv, float gain)
{
    /* The module reads its own row -- see the header. juno_pitch_table is
     * header-static, so this is the same constant data the caller used to pass
     * in, indexed by the same clamp. Bit-identical, one parameter fewer. */
    const double *tab = juno_pitch_table[eb_pitch_row(cv)];
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

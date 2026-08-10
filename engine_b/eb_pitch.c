/* eb_pitch.c — see eb_pitch.h. Double precision throughout until the final
 * fminf/fmaxf, exactly as the port. */
#include "eb_pitch.h"
#include "eb_minmax.h"
#include "eb_fork_config.h"
#include "juno_tables.h"
#include <math.h>

/* ------------------------------------------------------------------ FORK
 * THE S3 FORK'S PITCH, switched in at ONE point. EB_PITCH_FORK is defined
 * only by eb_fork_config.h under EB_FORK_S3, so no trunk build and no trunk
 * gate compiles a single line of it -- `--module all`, plugin_check and the
 * whole teeth battery still exercise the double path below, unchanged.
 *
 * The clamp-and-gain TAIL is kept identical to the trunk's on purpose. The
 * fork replaces the polynomial EVALUATION, which is what the exhaustive
 * cents gate measured (tools/engineb/pitch_cents_gate.py, 2^32 inputs,
 * worst 0.00074 cents); it does not get to change the +/-512 saturation or
 * the gain multiply, because those were never the cost and a second
 * difference would make the gate's result an incomplete answer about the
 * function the engine actually calls.
 */
#if EB_PITCH_FORK
#include "eb_pitch_fork.h"

float eb_pitch_eval(float cv, float gain)
{
    /* both bounds are non-zero constants in the SECOND operand: no NaN
     * and no signed-zero case (eb_minmax.h). */
    return eb_fmaxf_c(eb_fminf_c(eb_pitch_fork_eval(cv), 512.0f), -512.0f) * gain;
}

int eb_pitch_row(float cv)
{
    /* Same row law as the trunk (floor of the clamped value + 20); kept so
     * anything that asks for a row agrees with the evaluator that uses it. */
    float x = cv;
    if (x != x) x = -20.0f;
    if (x < -20.0f) x = -20.0f;
    if (x > 8.9f)   x = 8.9f;
    {   int r = (int)floorf(x) + 20;
        return r > 28 ? 28 : (r < 0 ? 0 : r); }
}

#else

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

/* CHEAPER VARIANTS WERE BUILT, MEASURED, AND REJECTED — do not rebuild them.
 * (P2 study, docs/engineb/data/pitch_p2_study.md, 2026-08-03.) v7 contains two
 * independent upgrades over plain Dekker, and single-change probes measured
 * each alone over the full 30-scenario null at BOTH rates:
 *
 *              products     accumulator   44,100 Hz    48,000 Hz    instr/call
 *   v8         error-free   simple add    -110.2 dB    FAIL -95.4   2,224
 *   v9         simple       compensated   -106.0 dB    FAIL -95.4   1,792
 *   v7 (this)  error-free   compensated   -123.6 dB    -148.4 dB    2,640
 *
 * BOTH cheaper variants pass 44.1 kHz and FAIL the SHIPPING rate — the exact
 * trap DOUBT_AUDIT.md H1 was about, caught because P1 gave the null a --rate.
 * The guard below makes requesting them a compile error instead of a silently
 * better-than-asked-for v7. Also killed in the same study, by measurement, not
 * by taste: moving precision into the DCO phase accumulator (the port's own
 * increment is a float; a value difference cannot be repaired downstream), and
 * recentered/higher-precision evaluation (the port's sum structure amplifies
 * its OWN double rounding by up to 2^37 near the polynomial's zeros, so a more
 * accurate result diverges from the port exactly there — only structural
 * mimicry can match it). */
#if EB_PITCH_FAST > 1
#error "EB_PITCH_FAST levels above 1 (v8/v9) FAILED the 48 kHz null at -95.4 dB. See docs/engineb/data/pitch_p2_study.md."
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
    return eb_fminf_c(eb_fmaxf_c(cv, -20.0f), 8.9f);   /* constants, non-zero */
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
        return eb_fmaxf_c(eb_fminf_c(out, 512.0f), -512.0f) * gain;
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

#if EB_PITCH_CR > 0
/* Control-rate evaluation, SECOND design. The first (linear extrapolation of
 * the OUTPUT from past anchors) was built and FAILED the gate hard -- N=2
 * -54.8 dB in 9 scenarios, N=4 -26.6, N=8 -12.9, worse than any curvature
 * model predicts -- because the pitch CV is not smooth at the sample scale:
 * envelope attacks, the LFO's S&H and NOISE modes put sample-rate content in
 * it, and no scheme that ignores the per-sample input can track that.
 * Recorded in docs/engineb/data/pitch_p2_study.md as the measured death of
 * output-side decimation.
 *
 * THIS form anchors the polynomial AND its first derivative every N samples,
 * then per sample applies A + D*(cv - cv0) with the TRUE per-sample cv --
 * which the caller has already computed; it was never the expensive part.
 * Sample-rate content in cv passes through the linear term. The residual is
 * second order, (P''/2)*(cv-cv0)^2, and the RADIUS GUARD re-anchors whenever
 * |cv - cv0| exceeds EB_PITCH_CR_RADIUS, so a patch whose modulation is too
 * hot for the linearisation degenerates toward anchoring every sample --
 * slower, never wrong. Cost failure, not correctness failure, by design.
 *
 * The derivative is evaluated in PLAIN FLOAT from the hi halves of the split
 * coefficients: its error multiplies (cv - cv0), which the radius bounds, so
 * a float derivative moves the output by < 2^-24 * radius * |P'| -- far below
 * the gate. The anchor value itself is the full v7 evaluation, unchanged.
 *
 * THE CLAMP: the port clamps the polynomial to +/-512 BEFORE the gain. The
 * anchor is taken through eb_pitch_eval (clamped, gained); if the anchor sits
 * on the clamp, the local derivative is meaningless and D is zeroed -- the
 * output holds the clamped value, which is exactly what the port does in
 * saturation. */
/* THE DERIVATIVES CANNOT BE FLOAT, and this was measured, not assumed: at
 * cv = -4.963 the float Horner returns -0.104 where the true P' is +0.022 --
 * wrong SIGN -- because the derivative terms reach ~1e6 and cancel to 0.02, a
 * 5e7 cancellation ratio that eats every float bit. This is P2's §2 finding
 * (the port's own sum structure amplifies rounding by up to 2^37) applied to
 * the derivative, where it bites even harder because d_k = k*c_k grows the
 * high terms. So P' and P'' are evaluated with the same double-float
 * machinery as the polynomial itself, over derivative coefficients pre-split
 * ONCE at first use (double arithmetic at init only -- the same license the
 * original split-at-first-call used). Anchors are 1-in-N, so the df cost sits
 * off the per-sample path.
 *
 * The second-order term is carried because the first-order form failed every
 * sustained-slew scenario: (P''/2)*delta^2 error is one-signed for any
 * modulation direction (exp-like P'' > 0), a bias, and a bias in the
 * increment integrates in phase. With it carried the leading error is odd in
 * delta and alternates under vibrato. */
static float eb_d1_hi[EB_PITCH_ROWS][12], eb_d1_lo[EB_PITCH_ROWS][12];
static float eb_d2_hi[EB_PITCH_ROWS][11], eb_d2_lo[EB_PITCH_ROWS][11];
static int   eb_deriv_ready = 0;

static void ebpf_deriv_init(void)
{
    int r, k;
    for (r = 0; r < EB_PITCH_ROWS; ++r) {
        for (k = 1; k <= 12; ++k) {
            double c = (double)eb_pitch_hi[r][k] + (double)eb_pitch_lo[r][k];
            double d = c * (double)k;
            eb_d1_hi[r][k-1] = (float)d;
            eb_d1_lo[r][k-1] = (float)(d - (double)eb_d1_hi[r][k-1]);
        }
        for (k = 2; k <= 12; ++k) {
            double c = (double)eb_pitch_hi[r][k] + (double)eb_pitch_lo[r][k];
            double d = c * (double)(k * (k - 1));
            eb_d2_hi[r][k-2] = (float)d;
            eb_d2_lo[r][k-2] = (float)(d - (double)eb_d2_hi[r][k-2]);
        }
    }
    eb_deriv_ready = 1;
}

/* simple Dekker add: enough here -- the requirement on P' is ~5e-6 relative
 * and df carries ~1e-14 per op against the 5e7 cancellation = ~5e-7. */
static df df_add_s(df a, df b)
{
    df s = two_sum(a.hi, b.hi);
    float lo = s.lo + a.lo + b.lo;
    return two_sum(s.hi, lo);
}

static float ebpf_horner_df(const float *dh, const float *dl, int n, float x)
{
    df acc; int k;
    acc.hi = dh[n-1]; acc.lo = dl[n-1];
    for (k = n - 2; k >= 0; --k) {
        df c; c.hi = dh[k]; c.lo = dl[k];
        acc = df_add_s(df_mulf(acc, x), c);
    }
    return acc.hi + acc.lo;
}

#ifndef EB_PITCH_CR_DFDERIV
/* DOUBLE Horner for the anchor derivatives. On the S3 this is soft-double at
 * ANCHOR rate only (1-in-N samples, ~24 df3 calls per anchor). The df variant
 * below (EB_PITCH_CR_DFDERIV) is cheaper; whether its ~1e-6-relative error
 * survives the gate is a measured question, not an assumed one. */
static float ebpf_deriv(float x, int row)
{
    double d = 0.0; int k;
    for (k = 11; k >= 0; --k)
        d = d * (double)x + ((double)eb_d1_hi[row][k] + (double)eb_d1_lo[row][k]);
    return (float)d;
}
static float ebpf_deriv2(float x, int row)
{
    double d = 0.0; int k;
    for (k = 10; k >= 0; --k)
        d = d * (double)x + ((double)eb_d2_hi[row][k] + (double)eb_d2_lo[row][k]);
    return (float)d;
}
#else
static float ebpf_deriv(float x, int row)
{
    return ebpf_horner_df(eb_d1_hi[row], eb_d1_lo[row], 12, x);
}
static float ebpf_deriv2(float x, int row)
{
    return ebpf_horner_df(eb_d2_hi[row], eb_d2_lo[row], 11, x);
}
#endif

float eb_pitch_eval_cr(eb_pitch_cr_state *s, float cv, float gain)
{
    /* THE DELTA LIVES IN THE CLAMPED DOMAIN, and the first Taylor build got
     * this wrong in a way the radius could not fix: the negative-sweep
     * scenarios pin the input clamp at x = -20, where the true output is
     * CONSTANT -- but the raw cv keeps moving, so D*(cv - cv0) charged a
     * biased error against a pinned truth, and a bias integrates. MEASURED:
     * shrinking the radius tenfold moved the worst residual only -51.6 ->
     * -60.1 dB, the signature of an error the radius does not govern. With
     * delta = clamp(cv) - clamp(cv0), a pinned input gives delta = 0 and the
     * held anchor is exact. The clamp here is compare-based, not fminf --
     * this is the approximation path, and 16 libm calls per sample would be
     * the cost problem this candidate exists to remove. */
    float xs = cv;
    if (xs < -20.0f) xs = -20.0f;
    else if (xs > 8.9f) xs = 8.9f;

    if (!eb_deriv_ready)
        ebpf_deriv_init();
    /* THE KNOT CHECK: the polynomial is a spline, and a Taylor step taken in
     * row R is wrong the moment xs crosses into row R+1 -- the synthetic
     * probe's worst error sat exactly on a knot. Crossing re-anchors. */
    /* THE ANCHOR IS PRE-GAIN. The gain is NOT a constant: the port writes
     * its cell (3792) EVERY SAMPLE at :1115 -- it is envelope-driven. The
     * earlier builds baked gain into A and D, and the pluck scenario sat at
     * exactly -89.5 dB through five unrelated fixes because the error was
     * (gain_now - gain_anchor) * A the whole time -- insensitive to radius,
     * knots, Taylor order and derivative precision alike. Found by asking
     * what stayed frozen that the port moves. The per-sample multiply is one
     * instruction, and the anchor-sample value is bit-identical either way:
     * ebpf_eval_row's final step with gain = 1.0f rounds to clamp(s) exactly,
     * and clamp(s) * gain is then the same single rounding the plain path
     * performs. */
    if (!s->primed || s->k == 0
        || fabsf(xs - s->x0) > (float)EB_PITCH_CR_RADIUS
        || (int)(xs + 20.0f) != s->row0) {
        float x   = ebpf_clamp(cv);
        int   row = ebpf_row(cv);
        float A   = ebpf_eval_row(cv, row, 1.0f);
        s->x0 = x;
        s->row0 = row;
        s->a_cur = A;
        if (fabsf(A) >= 512.0f) {
            s->slope = 0.0f;                    /* pinned on the clamp */
            s->half2 = 0.0f;
        } else {
            s->slope = ebpf_deriv(x, row);
            s->half2 = 0.5f * ebpf_deriv2(x, row);
        }
        s->primed = 1;
        s->k = (EB_PITCH_CR > 1) ? 1 : 0;
        return A * gain;
    }
    {
        float d   = xs - s->x0;
        float out = (s->a_cur + d * (s->slope + d * s->half2)) * gain;
        if (++s->k >= EB_PITCH_CR) s->k = 0;
        return out;
    }
}
#endif /* EB_PITCH_CR */

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

    return eb_fmaxf_c(eb_fminf_c((float)s, 512.0f), -512.0f) * gain;
}

#endif /* !EB_PITCH_FAST */

#endif /* EB_PITCH_FORK */

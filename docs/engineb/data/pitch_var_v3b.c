/* eb_pitch.c — VARIANT v3b "full double-float, accurate renormalization"
 * (PROBE BUILD, decision measurement only). Ladder rung 2 of the v3 series.
 *
 * Full double-float (hi,lo) arithmetic through the powers AND the sum, with
 * renormalization after every operation. The sum uses the ACCURATE
 * double-word add (Briggs/Bailey / AccurateDWPlusDW: TwoSum on both limbs,
 * two renormalization passes), whose relative error is bounded ~3u^2 even
 * under full cancellation — unlike the sloppy add in pitch_var_dekker.c,
 * which has no relative bound there.
 *
 * Clamp and row are the PORT'S OWN double forms (proved not the gap). */
#include "eb_pitch.h"
#include <math.h>

typedef struct { float hi, lo; } df;

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

/* Fast TwoSum: exact when |a| >= |b| or a == 0. */
static df fast_two_sum(float a, float b)
{
    df r;
    r.hi = a + b;
    r.lo = b - (r.hi - a);
    return r;
}

static df d_split(float a)
{
    df r;
    float c = 4097.0f * a;
    r.hi = c - (c - a);
    r.lo = a - r.hi;
    return r;
}

static df two_prod(float a, float b)
{
    df sa = d_split(a), sb = d_split(b);
    df r;
    r.hi = a * b;
    r.lo = ((sa.hi * sb.hi - r.hi) + sa.hi * sb.lo + sa.lo * sb.hi)
           + sa.lo * sb.lo;
    return r;
}

static df df_mul(df a, df b)
{
    df p = two_prod(a.hi, b.hi);
    float lo = p.lo + (a.hi * b.lo + a.lo * b.hi);
    return two_sum(p.hi, lo);
}

/* AccurateDWPlusDW (Briggs/Bailey class): ~3u^2 relative even under
 * cancellation. */
static df df_add_acc(df a, df b)
{
    df s = two_sum(a.hi, b.hi);
    df t = two_sum(a.lo, b.lo);
    {
        float c = s.lo + t.hi;
        df v = fast_two_sum(s.hi, c);
        float w = t.lo + v.lo;
        return fast_two_sum(v.hi, w);
    }
}

static df df_coef(double v)
{
    df r;
    r.hi = (float)v;
    r.lo = (float)(v - (double)r.hi);
    return r;
}

/* ---- the port's own clamp and row selection, verbatim (double) ---------- */
static double eb_pitch_clamp(float cv)
{
    return fmin(fmax((float)cv, -20.0), 8.9);
}

int eb_pitch_row(float cv)
{
    return (int)(eb_pitch_clamp(cv) + 20.0);
}

float eb_pitch_eval(float cv, const double *tab, float gain)
{
    double xd = eb_pitch_clamp(cv);
    df dx;
    dx.hi = (float)xd;
    dx.lo = (float)(xd - (double)dx.hi);
    {
        df x2 = df_mul(dx, dx);
        df x3 = df_mul(x2, dx);
        df x4 = df_mul(x3, dx);
        df x5 = df_mul(x4, dx);
        df x6 = df_mul(x5, dx);
        df x7 = df_mul(x6, dx);
        df x8 = df_mul(x7, dx);
        df x9 = df_mul(x8, dx);
        df x10 = df_mul(x9, dx);
        df x11 = df_mul(x10, dx);
        df x12 = df_mul(x11, dx);

        df s = df_mul(dx, df_coef(tab[2]));       /* port term order */
        s = df_add_acc(s, df_coef(tab[0]));
        s = df_add_acc(s, df_mul(x2, df_coef(tab[4])));
        s = df_add_acc(s, df_mul(x3, df_coef(tab[6])));
        s = df_add_acc(s, df_mul(x4, df_coef(tab[8])));
        s = df_add_acc(s, df_mul(x5, df_coef(tab[10])));
        s = df_add_acc(s, df_mul(x6, df_coef(tab[12])));
        s = df_add_acc(s, df_mul(x7, df_coef(tab[14])));
        s = df_add_acc(s, df_mul(x8, df_coef(tab[16])));
        s = df_add_acc(s, df_mul(x9, df_coef(tab[18])));
        s = df_add_acc(s, df_mul(x10, df_coef(tab[20])));
        s = df_add_acc(s, df_mul(x11, df_coef(tab[22])));
        s = df_add_acc(s, df_mul(x12, df_coef(tab[24])));
        {
            float out = s.hi + s.lo;
            return fmaxf(fminf(out, 512.0f), -512.0f) * gain;
        }
    }
}

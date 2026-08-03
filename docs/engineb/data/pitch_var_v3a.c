/* eb_pitch.c — VARIANT v3a "dekker + Neumaier sum" (PROBE BUILD, decision
 * measurement only). Ladder rung 1 of the v3 series.
 *
 * Same Dekker double-float products as pitch_var_dekker.c (Veltkamp 4097
 * split, FMA-free), powers as renormalized df in the port's grouping, but the
 * 13-term sum is a Neumaier/Kahan-Babuska COMPENSATED SUM: TwoSum on the term
 * HI parts, and every TwoSum error plus every term LO part accumulated into
 * one float compensation term. This removes the sloppy df_add's unbounded
 * relative error under cancellation, which is the failure signature of the
 * two dekker FAIL scenarios.
 *
 * Clamp and row are the PORT'S OWN double forms (variant B2 proved they are
 * not the gap; keeping them isolates the evaluation change). */
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

/* Veltkamp split, FMA-free: a = hi + lo with hi carrying the top 12 bits. */
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

/* df * df with renormalization (DWTimesDW). */
static df df_mul(df a, df b)
{
    df p = two_prod(a.hi, b.hi);
    float lo = p.lo + (a.hi * b.lo + a.lo * b.hi);
    return two_sum(p.hi, lo);
}

/* Split a double coefficient into a df pair (~48 coefficient bits). */
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

        df t[13];
        t[0]  = df_mul(dx, df_coef(tab[2]));      /* port term order */
        t[1]  = df_coef(tab[0]);
        t[2]  = df_mul(x2, df_coef(tab[4]));
        t[3]  = df_mul(x3, df_coef(tab[6]));
        t[4]  = df_mul(x4, df_coef(tab[8]));
        t[5]  = df_mul(x5, df_coef(tab[10]));
        t[6]  = df_mul(x6, df_coef(tab[12]));
        t[7]  = df_mul(x7, df_coef(tab[14]));
        t[8]  = df_mul(x8, df_coef(tab[16]));
        t[9]  = df_mul(x9, df_coef(tab[18]));
        t[10] = df_mul(x10, df_coef(tab[20]));
        t[11] = df_mul(x11, df_coef(tab[22]));
        t[12] = df_mul(x12, df_coef(tab[24]));

        {
            /* Neumaier: s + comp; every TwoSum error and every term LO part
             * goes into comp. */
            float s = 0.0f, comp = 0.0f;
            int i;
            for (i = 0; i < 13; i++) {
                df u = two_sum(s, t[i].hi);
                s = u.hi;
                comp += u.lo + t[i].lo;
            }
            {
                float out = s + comp;
                return fmaxf(fminf(out, 512.0f), -512.0f) * gain;
            }
        }
    }
}

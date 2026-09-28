/* es_math.c -- libm replacements for the no-libc wasm32 build, and the RNG.
 * Accuracy target: ~1e-12 relative (tests/test_math.c compares with libm). */
#include "es_math.h"
#include <stdint.h>

static uint32_t es_rng = 12345u;
void es_srand(unsigned seed) { es_rng = seed ? seed : 1u; }
double es_rand01(void)
{
    es_rng = es_rng * 1664525u + 1013904223u;
    return (double)(es_rng >> 8) * (1.0 / 16777215.0);
}

#ifdef ES_NO_LIBM
typedef union { double d; uint64_t u; } du;

double es_fabs(double x) { du v; v.d = x; v.u &= 0x7fffffffffffffffull; return v.d; }
double es_sqrt(double x) { return __builtin_sqrt(x); }   /* wasm f64.sqrt */
double es_floor(double x) { return __builtin_floor(x); } /* wasm f64.floor */
double es_ceil(double x) { return __builtin_ceil(x); }
static double es_trunc(double x) { return __builtin_trunc(x); }
double es_round(double x) { return x >= 0 ? es_floor(x + 0.5) : -es_floor(-x + 0.5); }

double es_fmod(double x, double y)
{
    double q;
    if (y == 0.0 || x != x || y != y) return (x * y) / (x * y);
    q = es_trunc(x / y);
    return x - q * y;
}

/* exp: range-reduce by ln2, degree-13 Taylor on |r| <= ln2/2 */
double es_exp(double x)
{
    const double ln2 = 0.6931471805599453094;
    double k, r, p, t;
    int i, ki;
    du v;
    if (x != x) return x;
    if (x > 709.0) return 1.0 / 0.0;
    if (x < -745.0) return 0.0;
    k = es_floor(x / ln2 + 0.5);
    r = x - k * ln2;
    p = 1.0; t = 1.0;
    for (i = 1; i <= 12; i++) { t *= r / i; p += t; }   /* |r|<=0.347: r^13/13! < 2e-16 */
    ki = (int)k;
    if (ki < -1022) { p *= 1.0 / 4503599627370496.0; ki += 52; }  /* 2^-52 */
    v.u = (uint64_t)(ki + 1023) << 52;
    return p * v.d;
}

/* ln: frexp by bits, atanh series on z = (m-1)/(m+1), |z| <= 0.1716 */
static double es_log(double x)
{
    const double ln2 = 0.6931471805599453094;
    du v;
    int e;
    double m, z, z2, s, t;
    int i;
    if (!(x > 0.0)) return x == 0.0 ? -1.0 / 0.0 : (x - x) / (x - x);
    v.d = x;
    e = (int)((v.u >> 52) & 0x7ff);
    if (e == 0) { v.d = x * 4503599627370496.0; e = (int)((v.u >> 52) & 0x7ff) - 52; }
    e -= 1023;
    v.u = (v.u & 0x000fffffffffffffull) | 0x3ff0000000000000ull;
    m = v.d;
    if (m > 1.41421356237309505) { m *= 0.5; e += 1; }
    z = (m - 1.0) / (m + 1.0);
    z2 = z * z;
    s = 0.0; t = z;
    for (i = 1; i <= 21; i += 2) { s += t / i; t *= z2; }  /* z<=0.1716: z^23/23 < 1e-19 */
    return 2.0 * s + e * ln2;
}

double es_pow(double x, double y)
{
    double yi;
    if (y == 0.0) return 1.0;
    if (x == 0.0) return y > 0 ? 0.0 : 1.0 / 0.0;
    if (x < 0.0) {
        yi = es_trunc(y);
        if (yi != y) return (x - x) / (x - x);
        {
            double r = es_exp(y * es_log(-x));
            return (es_fmod(yi, 2.0) != 0.0) ? -r : r;
        }
    }
    return es_exp(y * es_log(x));
}

/* sin/cos: reduce to [-pi/4, pi/4] by quadrant, Taylor to degree 17 */
static double k_sin(double r) {
    double r2 = r * r, t = r, s = r; int i;
    for (i = 3; i <= 17; i += 2) { t *= -r2 / ((i - 1) * i); s += t; }
    return s;
}
static double k_cos(double r) {
    double r2 = r * r, t = 1.0, s = 1.0; int i;
    for (i = 2; i <= 18; i += 2) { t *= -r2 / ((i - 1) * i); s += t; }
    return s;
}
static void sincos_q(double x, double *s, double *c)
{
    const double pio2 = 1.57079632679489661923;
    double q = es_floor(x / pio2 + 0.5);
    double r = (x - q * 1.57079632673412561417) - q * 6.07710050650619224932e-11;
    long qi = (long)es_fmod(q, 4.0);
    double ss = k_sin(r), cc = k_cos(r);
    if (qi < 0) qi += 4;
    switch (qi) {
    case 0: *s = ss;  *c = cc;  break;
    case 1: *s = cc;  *c = -ss; break;
    case 2: *s = -ss; *c = -cc; break;
    default:*s = -cc; *c = ss;  break;
    }
}
double es_sin(double x) { double s, c; sincos_q(x, &s, &c); return s; }
double es_cos(double x) { double s, c; sincos_q(x, &s, &c); return c; }
double es_tan(double x) { double s, c; sincos_q(x, &s, &c); return s / c; }

/* atan on [0,1] via argument halving + series; acos(x) = atan2(sqrt(1-x^2), x) */
static double es_atan01(double x)
{
    double s, t, x2; int i, h = 0;
    while (x > 0.2) { x = x / (1.0 + es_sqrt(1.0 + x * x)); h++; }
    x2 = x * x; s = 0.0; t = x;
    for (i = 1; i <= 41; i += 2) { s += t / i; t *= -x2; }
    return s * (double)(1 << h);
}
static double es_atan(double x)
{
    const double pio2 = 1.57079632679489661923;
    if (x < 0) return -es_atan(-x);
    if (x > 1.0) return pio2 - es_atan01(1.0 / x);
    return es_atan01(x);
}
double es_acos(double x)
{
    const double pi = 3.14159265358979323846;
    double y;
    if (x > 1.0 || x < -1.0) return (x - x) / (x - x);
    if (x == 0.0) return pi / 2;
    y = es_sqrt((1.0 - x) * (1.0 + x));
    if (x > 0) return es_atan(y / x);
    return pi + es_atan(y / x);
}
double es_tanh(double x)
{
    double e;
    if (x > 20.0) return 1.0;
    if (x < -20.0) return -1.0;
    e = es_exp(2.0 * x);
    return (e - 1.0) / (e + 1.0);
}
#endif

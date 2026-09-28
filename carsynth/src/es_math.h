/* es_math.h -- double-precision math for the engine-sim port.
 *
 * Native builds use libm. The wasm32 build (no libc) uses the self-contained
 * versions below; tests/test_math.c holds them to libm (relative error). The
 * physics is engine-sim's, in double, as upstream; a float build for the
 * ESP32-S3 (no double FPU) is a later, separately gated step. */
#ifndef ES_MATH_H
#define ES_MATH_H

#define ES_PI 3.14159265359            /* engine-sim constants::pi, verbatim */
#define ES_R  8.31446261815324         /* constants::R */

#ifndef ES_NO_LIBM
#include <math.h>
#define es_sqrt  sqrt
#define es_pow   pow
#define es_cos   cos
#define es_sin   sin
#define es_tan   tan
#define es_acos  acos
#define es_fmod  fmod
#define es_floor floor
#define es_ceil  ceil
#define es_round round
#define es_exp   exp
#define es_tanh  tanh
#define es_fabs  fabs
#else
double es_sqrt(double x);
double es_pow(double x, double y);
double es_cos(double x);
double es_sin(double x);
double es_tan(double x);
double es_acos(double x);
double es_fmod(double x, double y);
double es_floor(double x);
double es_ceil(double x);
double es_round(double x);
double es_exp(double x);
double es_tanh(double x);
double es_fabs(double x);
#endif

static inline double es_fmin(double a, double b) { return a < b ? a : b; }
static inline double es_fmax(double a, double b) { return a > b ? a : b; }
/* utilities.h clamp(x, x0 = 0, x1 = 1) */
static inline double es_clamp(double x, double x0, double x1)
{
    if (x <= x0) return x0;
    else if (x >= x1) return x1;
    else return x;
}
/* utilities.cpp positiveMod */
static inline double es_positive_mod(double x, double mod)
{
    if (x < 0) x = es_ceil(-x / mod) * mod + x;
    return es_fmod(x, mod);
}

/* rand() / RAND_MAX replacement: a 32-bit LCG, [0, 1] */
double es_rand01(void);
void   es_srand(unsigned seed);

#endif

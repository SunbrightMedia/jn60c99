/* eb_pitch.c — VARIANT A "float32" (PROBE BUILD, decision measurement only).
 *
 * Identical structure to engine_b/eb_pitch.c, but every intermediate is FLOAT:
 * double->float, fmin/fmax->fminf/fmaxf, double literals->float literals.
 * The table stays double (the header's ABI); each coefficient is truncated to
 * float at its single point of use, which is exactly what a pre-converted
 * float table would feed the arithmetic on the S3.
 * Term order is IDENTICAL to the port's. */
#include "eb_pitch.h"
#include <math.h>

static float eb_pitch_clamp(float cv)
{
    return fminf(fmaxf(cv, -20.0f), 8.9f);
}

int eb_pitch_row(float cv)
{
    return (int)(eb_pitch_clamp(cv) + 20.0f);
}

float eb_pitch_eval(float cv, const double *tab, float gain)
{
    float x   = eb_pitch_clamp(cv);
    float x3  = x * x * x;                  /* v386 */
    float x5  = x3 * x * x;                 /* v388 */
    float x8  = x5 * x * x * x;             /* v389 */
    float x10 = x8 * x * x;                 /* v390 */

    float s = x * (float)tab[2]
            + (float)tab[0]
            + x * x * (float)tab[4]
            + x3 * (float)tab[6]
            + x3 * x * (float)tab[8]
            + x5 * (float)tab[10]
            + x5 * x * (float)tab[12]
            + x5 * x * x * (float)tab[14]
            + x8 * (float)tab[16]
            + x8 * x * (float)tab[18]
            + x10 * (float)tab[20]
            + x10 * x * (float)tab[22]
            + x10 * x * x * (float)tab[24];

    return fmaxf(fminf(s, 512.0f), -512.0f) * gain;
}

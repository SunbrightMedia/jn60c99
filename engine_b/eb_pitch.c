/* eb_pitch.c — see eb_pitch.h. Double precision throughout until the final
 * fminf/fmaxf, exactly as the port. */
#include "eb_pitch.h"
#include <math.h>

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

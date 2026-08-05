/* lfo_rate_gate.c — THE LFO-RATE PPM GATE (F3's named gate, executed in O6).
 *
 * WHY THIS EXISTS AND WHY expf's OWN PPM FIGURE IS NOT THE ANSWER.
 * The fork exponential measures 0.119 ppm over all 2^32 inputs. That is the
 * error of expf. It is NOT the error of the thing the engine integrates.
 * Between the exponential and the LFO phase accumulator the port computes
 *
 *     v75 = expf(dly_env * k1200) * k1184
 *     v77 = v75 + k1216
 *     v83 = (v76 - v74*v77) + v77            <-- v76 = v74 * k1072
 *     inc = fminf(k2128, v83 * 2^-16) * k2144
 *     phase += inc                            <-- INTEGRATES
 *
 * `v83` SUBTRACTS two quantities that can be close, and a subtraction of
 * near-equal values amplifies relative error without bound. This project has
 * already been caught once by exactly that mechanism at a much larger scale
 * (the pitch polynomial's 2^37 cancellation), and the lesson recorded from it
 * is that an input error bound tells you nothing until you carry it through
 * the expression the engine actually evaluates.
 *
 * So this gate measures the RATE, end to end: same expression, port expf on
 * one side and the fork exp on the other, swept over the coefficient ranges
 * the recalled bank actually produces, and reports the worst RELATIVE error
 * of `inc` in ppm plus the accumulated PHASE error after 60 seconds of
 * integration at 48 kHz -- which is the quantity a listener could ever
 * perceive, and the reason a rate bias is worth bounding at all.
 *
 * The coefficient ranges are read from the real factory bank by
 * lfo_rate_gate.py and passed in; nothing here invents a range.
 */
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "eb_exp_fork.h"

/* the port's expression, parameterised by which exponential to use */
static double rate_of(float (*E)(float), float dly, float k1200, float k1184,
                      float k1216, float k1072, float v74, float k2128,
                      float k2144)
{
    float v75 = E(dly * k1200) * k1184;
    float v76 = v74 * k1072;
    float v77 = v75 + k1216;
    float v83 = (float)(v76 - (float)(v74 * v77)) + v77;
    float v88 = fminf(k2128, v83 * 0.000015258789f);
    return (double)(v88 * k2144);
}

static float portexp(float x) { return expf(x); }

int main(int argc, char **argv)
{
    if (argc != 9) {
        fprintf(stderr, "usage: k1200 k1184 k1216 k1072 v74 k2128 k2144 label\n");
        return 2;
    }
    float k1200 = atof(argv[1]), k1184 = atof(argv[2]), k1216 = atof(argv[3]);
    float k1072 = atof(argv[4]), v74 = atof(argv[5]);
    float k2128 = atof(argv[6]), k2144 = atof(argv[7]);
    const char *label = argv[8];

    double wppm = 0, wat = 0, wref = 0;
    /* dly_env is an envelope in [0,1]; sweep it finely, both directions. */
    for (int i = 0; i <= 2000000; ++i) {
        float dly = (float)i / 2000000.0f;
        double a = rate_of(portexp,     dly, k1200, k1184, k1216, k1072, v74, k2128, k2144);
        double b = rate_of(eb_exp_fork, dly, k1200, k1184, k1216, k1072, v74, k2128, k2144);
        if (fabs(a) < 1e-30) continue;
        double ppm = fabs(b / a - 1.0) * 1e6;
        if (ppm > wppm) { wppm = ppm; wat = dly; wref = a; }
    }
    /* what that worst rate error becomes after 60 s of integration at 48 kHz,
     * expressed as a fraction of one LFO cycle. */
    double cycles60 = fabs(wref) * 48000.0 * 60.0;
    printf("%-22s worst %.6f ppm at dly=%.6f  rate=%.9g  "
           "phase drift in 60 s = %.3g cycles\n",
           label, wppm, wat, wref, cycles60 * wppm * 1e-6);
    return 0;
}

/* pi_log10_check.c -- the Pi build's log10 (pi/kernel/bare_log10.c) against the C library's, on the
 * host, where it matters: the GUI meter's dB step (gui/juno_bridge.c juno_gui_meter_tick,
 * (int)(log10(d) * 333 + 999) for d the float peak clamped to [0.001, 1]). EVERY float in that range is
 * tried; each must give the same step (task #62). Also reported: the largest difference in ULPs over
 * the range and over 10^7 seeded doubles in (0, 1e6] (both libraries round within 1 ULP of the
 * truth, so they may differ by 2; the bound is 4 -- 1e-15 relative, far inside the meter's 1e-12).
 * A tooth (-DTOOTH) scales the Pi's log10 by 1 + 2^-25: the check must then FAIL.
 * cc -O2 -std=c99 -ffp-contract=off tools/repro/pi_log10_check.c -lm && ./a.out */
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#define log10 bare_log10
#include "../../pi/kernel/bare_log10.c"
#undef log10
#include <math.h>

#ifdef TOOTH
#define PI_LOG10(x) (bare_log10(x) * (1.0 + 1.0 / 33554432.0))      /* TOOTH: 3e-8 relative */
#else
#define PI_LOG10(x) bare_log10(x)
#endif

static int step(double y) { double x = y * 333.0 + 999.0; return (x > -2147483649.0 && x < 2147483648.0) ? (int)x : INT32_MIN; }
static int64_t ulps(double a, double b)
{
    int64_t ia, ib;
    memcpy(&ia, &a, 8); memcpy(&ib, &b, 8);
    if (ia < 0) ia = INT64_MIN - ia;
    if (ib < 0) ib = INT64_MIN - ib;
    return ia > ib ? ia - ib : ib - ia;
}

int main(void)
{
    float f = 0.001f;
    long n = 0, bad = 0;
    int64_t worst = 0, w2 = 0;
    uint64_t s = 0x9E3779B97F4A7C15ull;
    long i;
    for (;;) {
        double d = (double)f, a = PI_LOG10(d), b = log10(d);
        int64_t u = ulps(a, b);
        if (u > worst) worst = u;
        if (step(a) != step(b)) { if (bad < 5) printf("step differs at %.9g: %d vs %d\n", d, step(a), step(b)); ++bad; }
        ++n;
        if (f >= 1.0f) break;
        f = nextafterf(f, 2.0f);
    }
    for (i = 0; i < 10000000; ++i) {                 /* seeded doubles in (0, 1e6] */
        double d, a, b;
        int64_t u;
        s ^= s << 13; s ^= s >> 7; s ^= s << 17;
        d = (double)(s >> 11) * (1e6 / 9007199254740992.0) + 1e-300;
        a = PI_LOG10(d); b = log10(d);
        u = ulps(a, b);
        if (u > w2) w2 = u;
    }
    printf("pi_log10_check: %ld floats in [0.001, 1]: %ld meter steps differ; largest difference %lld ULP there, "
           "%lld ULP over 10^7 seeded doubles\n", n, bad, (long long)worst, (long long)w2);
#ifdef TOOTH
    printf("pi_log10_check --tooth: %s\n", (bad || worst > 4) ? "BITES" : "DID NOT BITE");
    return (bad || worst > 4) ? 0 : 1;
#else
    printf("pi_log10_check: %s\n", (!bad && worst <= 4 && w2 <= 4) ? "GREEN" : "RED");
    return (!bad && worst <= 4 && w2 <= 4) ? 0 : 1;
#endif
}

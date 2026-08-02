/* Exhaustive: every one of the 2^32 float32 bit patterns. */
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <math.h>
#include "triangle.h"

static float ref_triangle(float phase)          /* verbatim src/juno_dsp.c:54 */
{
    if (phase <= 1.0f) { if (phase < -1.0f) phase = fmodf(phase - 1.0f, 2.0f) + 1.0f; }
    else               { phase = fmodf(phase + 1.0f, 2.0f) - 1.0f; }
    float v2 = phase + phase;
    if (phase >= -0.5f) { if (phase <= 0.5f) return v2; else return 2.0f - v2; }
    return -2.0f - v2;
}

int main(void)
{
    uint64_t bad = 0, nan_skipped = 0; uint32_t firstbad = 0;
    for (uint64_t i = 0; i <= 0xFFFFFFFFull; ++i) {
        uint32_t b = (uint32_t)i; float x; memcpy(&x, &b, 4);
        if (isnan(x)) { nan_skipped++; continue; }
        float a = ref_triangle(x), c = eb_triangle(x);
        uint32_t ab, cb; memcpy(&ab,&a,4); memcpy(&cb,&c,4);
        if (ab != cb) { if (!bad) firstbad = b; bad++; }
    }
    printf("exhaustive: 2^32 patterns, %llu NaN skipped, %llu mismatches\n",
           (unsigned long long)nan_skipped, (unsigned long long)bad);
    if (bad) { float x; memcpy(&x,&firstbad,4); printf("  first at 0x%08x = %g\n", firstbad, x); return 1; }
    printf("OK: eb_triangle is bit-identical to juno_triangle over the whole domain\n");
    return 0;
}

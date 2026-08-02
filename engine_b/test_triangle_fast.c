#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <math.h>
#include "triangle.h"

/* SAW site: eb_triangle((p+1)*0.5f), p in [-1,1).
 * (p+1)*0.5 is exact (a power-of-two scale) and v2 = u+u recovers p+1 exactly,
 * so the whole function collapses to two arms with no wrap and no compare
 * against +/-1. */
/* The second arm must keep the reference's own rounding: it computes
 * 2.0f - v2 where v2 == fl(p+1), and fl(2 - fl(p+1)) != fl(1 - p) whenever
 * p+1 rounds. Writing the "simpler" 1.0f - p disagrees on 104,857,600 of the
 * 2,130,706,433 in-domain floats -- about 5%. Measured, not reasoned. */
static inline float tri_saw(float p) { float v = p + 1.0f;
                                       return (p <= 0.0f) ? v : (2.0f - v); }

/* SUB site: eb_triangle(-fabsf(t)), argument in [-1,0]. */
static inline float tri_sub(float x) { return (x >= -0.5f) ? (x + x) : (-2.0f - (x + x)); }

int main(void)
{
    uint64_t bad_saw = 0, bad_sub = 0, n = 0;
    /* Exhaustive over every float32 bit pattern, filtered to each site's
     * PROVEN input domain. */
    for (uint64_t i = 0; i <= 0xFFFFFFFFull; ++i) {
        uint32_t b = (uint32_t)i; float x; memcpy(&x, &b, 4);
        if (isnan(x)) continue;

        if (x >= -1.0f && x < 1.0f) {                    /* p domain */
            float a = eb_triangle((x + 1.0f) * 0.5f), c = tri_saw(x);
            uint32_t ab, cb; memcpy(&ab,&a,4); memcpy(&cb,&c,4);
            if (ab != cb) bad_saw++;
            n++;
        }
        if (x >= -1.0f && x <= 0.0f) {                   /* -|t| domain */
            float a = eb_triangle(x), c = tri_sub(x);
            uint32_t ab, cb; memcpy(&ab,&a,4); memcpy(&cb,&c,4);
            if (ab != cb) bad_sub++;
        }
    }
    printf("SAW  : %llu mismatches over %llu in-domain floats\n",
           (unsigned long long)bad_saw, (unsigned long long)n);
    printf("SUB  : %llu mismatches\n", (unsigned long long)bad_sub);
    return (bad_saw || bad_sub) ? 1 : 0;
}

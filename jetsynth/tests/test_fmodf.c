/* test_fmodf.c -- jet_fmodf (the wasm build's fmodf) vs host libm, bit for bit.
 * Covers the chorus's actual use (x+-1 mod 2 near the wrap) densely, plus a
 * random sweep over all exponents. A tooth: a naive x - trunc(x/y)*y must FAIL. */
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <stdint.h>
float jet_fmodf(float, float);
static float naive(float x, float y) { return x - (float)(long long)(x / y) * y; }
static int run(float (*f)(float, float), long *n)
{
    uint32_t s = 12345u, bad = 0; long i; float y2 = 2.0f;
    *n = 0;
    for (i = 0; i < 4000000; i++) {
        float x, y, a, b; uint32_t ua, ub;
        s = s * 1664525u + 1013904223u;
        if (i & 1) { x = ((float)(s >> 8) / 16777216.0f - 0.5f) * 8.0f; y = y2; }
        else { uint32_t u = s & 0x7f7fffffu; memcpy(&x, &u, 4);
               s = s * 1664525u + 1013904223u; u = (s & 0x3fffffffu) | 0x30000000u; memcpy(&y, &u, 4); }
        a = f(x, y); b = fmodf(x, y);
        memcpy(&ua, &a, 4); memcpy(&ub, &b, 4);
        if (ua != ub) bad++;
        (*n)++;
    }
    return (int)bad;
}
int main(void)
{
    long n; int bad = run(jet_fmodf, &n), badn = run(naive, &n);
    printf("jet_fmodf: %d / %ld mismatches vs libm; tooth (naive): %d mismatches\n", bad, n, badn);
    if (bad) { printf("FAIL\n"); return 1; }
    if (!badn) { printf("TOOTH DID NOT BITE\n"); return 1; }
    printf("PASS\n");
    return 0;
}

/* test_fma_canary.c — fail loudly if the compiler contracts a*b+c into a fused
 * multiply-add (single rounding). The JUNO-60 port is bit-exact against the
 * plugin's x86 SSE2 output, which has NO FMA. On a target with hardware FMA
 * (Teensy 4.1 / ARM Cortex-M7 VFPv5) an accidental contraction would change the
 * rounding of the DCO/VCF/VCA/FX math and silently break bit-exactness. The
 * Makefile passes -ffp-contract=off; this canary proves it took effect.
 *
 * Construction: a = 1 + 2^-23, b = 1 - 2^-23, c = -1.
 *   a*b (real)     = 1 - 2^-46
 *   fl(a*b)        = 1.0f              (2^-46 is far below 1 ULP at 1.0)
 *   separate: fl(a*b) + c = 1.0 - 1.0 = 0.0f          <- IEEE, no contraction
 *   fused:    fl(a*b + c) = fl(-2^-46) = -2^-46 != 0  <- contraction happened
 * volatile inputs stop the compiler from constant-folding the whole thing.
 */
#include <stdio.h>
#include <stdint.h>
#include <string.h>

int main(void)
{
    volatile float a = 1.0f + 1.19209290e-07f;   /* 1 + 2^-23 */
    volatile float b = 1.0f - 1.19209290e-07f;   /* 1 - 2^-23 */
    volatile float c = -1.0f;
    float r = a * b + c;                          /* natural expression */

    uint32_t bits;
    memcpy(&bits, &r, 4);
    printf("a*b+c = %.10g (bits %08x)\n", (double)r, bits);

    if (r != 0.0f) {
        printf("FAIL: a*b+c = %.10g, expected 0 — the compiler CONTRACTED a*b+c "
               "into a fused multiply-add. Bit-exactness against the plugin's "
               "non-FMA reference is BROKEN. Build with -ffp-contract=off.\n",
               (double)r);
        return 1;
    }
    printf("OK: no FMA contraction (a*b+c separately rounded to 0)\n");
    return 0;
}

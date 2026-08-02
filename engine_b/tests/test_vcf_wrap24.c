/* test_vcf_wrap24.c — engine B's copy of juno_wrap24, checked over the WHOLE
 * float domain.
 *
 * WHY EXHAUSTIVE AND NOT A SPOT CHECK. Two facts from this project:
 *   * eb_triangle's replacement of fmodf was mathematically identical to the
 *     reference and disagreed on 8,388,608 of 2^32 inputs through rounding
 *     alone. It was caught only by an exhaustive test.
 *   * MEASURED 2026-08-02 on the DCO: the negative phase wrap gets within
 *     0.0003 of firing in the scenario set, so a scenario gate protects a wrap
 *     with a margin far too thin to trust.
 * The ladder's dither phase runs through this wrap every sample and free-runs,
 * so a single disagreeing input would drift the filter's dither for the rest of
 * the session. All 2^32 bit patterns are compared, NaNs included.
 *
 * The comparison is of BITS, not of value: -0.0 and +0.0 are different answers
 * here, because the next sample's wrap sees the sign.
 *
 * Build:  cc -O2 -ffp-contract=off -I src -I engine_b \
 *            engine_b/tests/test_vcf_wrap24.c src/juno_dsp.c -lm
 */
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include "juno_dsp.h"

/* pull in the module's own static copy */
#include "../eb_vcf_ladder.c"

int main(void)
{
    uint64_t i, bad = 0, nan_in = 0;
    uint32_t first_bad = 0;
    for (i = 0; i <= 0xFFFFFFFFull; ++i) {
        uint32_t b = (uint32_t)i;
        float x, a, e;
        uint32_t ab, eb_;
        memcpy(&x, &b, 4);
        if (x != x) { ++nan_in; }
        a = eb_wrap24(x);
        e = juno_wrap24(x);
        memcpy(&ab, &a, 4);
        memcpy(&eb_, &e, 4);
        if (ab != eb_) {
            if (!bad) first_bad = b;
            ++bad;
        }
    }
    printf("eb_wrap24 vs juno_wrap24 over all 2^32 float bit patterns\n");
    printf("  NaN inputs exercised : %llu\n", (unsigned long long)nan_in);
    printf("  DISAGREEMENTS        : %llu\n", (unsigned long long)bad);
    if (bad) printf("  first at bits 0x%08X\n", first_bad);
    printf("%s\n", bad ? "FAIL" : "PASS");
    return bad ? 1 : 0;
}

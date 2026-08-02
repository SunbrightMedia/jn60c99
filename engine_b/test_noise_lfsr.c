/* test_noise_lfsr.c — prove the noise generator against captured oracle output.
 *
 *   cc -O2 -ffp-contract=off -I.. -o t test_noise_lfsr.c && ./t
 *
 * Reads docs/engineb/data/noise_core_200k.npy directly (parsing the .npy header
 * rather than assuming its length -- assuming 128 bytes was wrong and produced a
 * 200,000-of-200,000 mismatch that looked like a broken generator).
 */
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include "noise_lfsr.h"

#define REF "docs/engineb/data/noise_core_200k.npy"

int main(void)
{
    FILE *f = fopen(REF, "rb");
    if (!f) { f = fopen("../" REF, "rb"); }
    if (!f) { printf("FAIL: cannot open %s\n", REF); return 2; }

    unsigned char hdr[10];
    if (fread(hdr, 1, 10, f) != 10) { printf("FAIL: short header\n"); return 2; }
    if (memcmp(hdr + 1, "NUMPY", 5)) { printf("FAIL: not a .npy file\n"); return 2; }
    unsigned hlen = (unsigned)hdr[8] | ((unsigned)hdr[9] << 8);   /* v1.0 */
    fseek(f, 10 + (long)hlen, SEEK_SET);

    static uint32_t ref[200000];
    size_t n = fread(ref, 4, 200000, f);
    fclose(f);
    if (n < 1000) { printf("FAIL: only %zu samples read\n", n); return 2; }

    eb_noise s; eb_noise_init(&s);
    size_t bad = 0, first = 0;
    for (size_t i = 0; i < n; ++i) {
        float v = eb_noise_step(&s);
        uint32_t bits; memcpy(&bits, &v, 4);
        if (bits != ref[i]) { if (!bad) first = i; bad++; }
    }
    if (bad) {
        printf("FAIL: %zu/%zu mismatches, first at %zu\n", bad, n, first);
        return 1;
    }
    printf("OK: noise LFSR bit-identical to the oracle over %zu samples\n", n);
    return 0;
}

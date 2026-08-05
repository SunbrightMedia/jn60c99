/* o8_vcf_probe.c -- the half-OS VCF's response, measured on the SHIPPING
 * ladder built twice from one source (EB_HALF_OS 0 and 1).
 *
 * WHY A NOISE DRIVE AND NOT AN IMPULSE. The ladder is nonlinear: it clips at
 * +/-1 and runs a quintic saturation, so an impulse measures the response at
 * a level no patch ever uses. The drive is a fixed pseudo-random sequence at
 * a musical level, IDENTICAL in both builds, and the comparison is of the two
 * outputs' spectra -- which is the transfer function including whatever the
 * nonlinearity does, rather than instead of it.
 *
 * G is swept over the range MEASURED on the real scenario set: 17,199,360
 * calls of the gated battery put G in [0.000119, 0.209771].
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "eb_fork_config.h"
#include "eb_vcf_ladder.h"
#include "c6_realvcf.h"

int main(int argc, char **argv)
{
    float G = argc > 1 ? (float)atof(argv[1]) : 0.1f;
    float k = argc > 2 ? (float)atof(argv[2]) : 1.0f;
    int n   = argc > 3 ? atoi(argv[3]) : 131072;
    eb_vcf_state st; eb_vcf_coef c;
    unsigned seed = 12345u;
    int i;

    memset(&c, 0, sizeof c);
    RV_FILL(c);
    eb_vcf_reset(&st);
    for (i = 0; i < n; ++i) {
        float x, y;
        seed = seed * 1103515245u + 12345u;
        x = 0.25f * ((float)(int)(seed >> 8 & 0xFFFFu) - 32768.0f) / 32768.0f;
        y = eb_vcf_tick(&st, &c, x, G, k);
        fwrite(&y, 4, 1, stdout);
    }
    return 0;
}

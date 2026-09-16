/* fuzz.c — THE INVARIANT gate, run wide on the host.
 *
 * END_GOAL's INVARIANT: "audio never breaks, for any input." This throws a
 * seed swarm across the ENTIRE control surface (notes, all 79 host params,
 * patch changes, tempo — with OUT-OF-RANGE values too) at the engine and
 * asserts every rendered sample is finite (no NaN/inf) and bounded. Any
 * failure names the seed so it can be replayed.
 *
 * The engine is bit-exact across x86/ARM, so a clean x86 run means a clean ARM
 * run (identical bits); the metal probe spot-checks a few seeds anyway.
 *
 * usage: fuzz <bank.bin> [nseeds] [frames] [bound]   (default 400 12000 16.0) */
#include <stdio.h>
#include <stdlib.h>
#include "juno_probe_core.h"

#define SR 48000.0f

int main(int argc, char **argv)
{
    if (argc < 2) { fprintf(stderr, "need bank path\n"); return 2; }
    FILE *f = fopen(argv[1], "rb");
    if (!f) { fprintf(stderr, "open %s failed\n", argv[1]); return 2; }
    fseek(f, 0, SEEK_END); long len = ftell(f); fseek(f, 0, SEEK_SET);
    unsigned char *bank = (unsigned char *)malloc((size_t)len);
    if (fread(bank, 1, (size_t)len, f) != (size_t)len) return 2;
    fclose(f);

    int  nseeds = argc > 2 ? atoi(argv[2]) : 400;
    int  frames = argc > 3 ? atoi(argv[3]) : 12000;
    float bound = argc > 4 ? (float)atof(argv[4]) : 16.0f;
    float *buf = (float *)malloc(sizeof(float) * 2 * (size_t)frames);

    long tot_bad_finite = 0, tot_bad_bound = 0, samples = 0;
    float worst = 0.0f; int worst_seed = 0, fails = 0;

    for (int i = 0; i < nseeds; ++i) {
        unsigned seed = 0x9E3779B1u * (unsigned)(i + 1);   /* spread the seeds */
        float pk = 0.0f; long bf = 0, bb = 0;
        int r = juno_probe_fuzz(bank, (int)len, SR, seed, frames, bound,
                                buf, &pk, &bf, &bb);
        samples += 2L * frames;
        tot_bad_finite += bf; tot_bad_bound += bb;
        if (pk > worst) { worst = pk; worst_seed = (int)seed; }
        if (r != 0) {
            ++fails;
            if (fails <= 10)
                printf("seed %08x  FAIL  nonfinite=%ld  overbound=%ld  peak=%.4f\n",
                       seed, bf, bb, pk);
        }
    }

    printf("----\n");
    printf("seeds %d  frames/seed %d  samples scanned %ld\n", nseeds, frames, samples);
    printf("non-finite (NaN/inf) samples: %ld\n", tot_bad_finite);
    printf("over-bound (|s|>%.1f) samples: %ld\n", bound, tot_bad_bound);
    printf("worst |peak| %.5f (seed %08x)\n", worst, (unsigned)worst_seed);
    if (tot_bad_finite == 0 && tot_bad_bound == 0) {
        printf("INVARIANT HELD: audio never broke across the whole surface\n");
        return 0;
    }
    printf("INVARIANT VIOLATED (%d failing seeds)\n", fails);
    return 1;
}

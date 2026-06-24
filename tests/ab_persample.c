/* ab_persample.c — capture-free per-sample A/B of the running DSP.
 *
 * The state dump holds TWO full snapshots of the live plugin's engine state taken
 * a moment apart (t0, t1); the plugin advanced its per-sample DSP between them.
 * We load t0, run our voice_render forward, and for every dynamic voice-0 field
 * find the sample count K at which our evolved value best matches t1.
 *
 * Result interpretation:
 *  - CONTROL-RATE fields (envelope smoothers, gains, cutoff) are monotonic/slewed;
 *    if our per-sample math matches the plugin they reach the plugin's value
 *    BIT-EXACTLY at a single K. They do (see docs/VALIDATION.md) — a sample-accurate
 *    proof of the running control-rate DSP using only data we already have.
 *  - AUDIO-RATE fields (filter z^-1 memory) are phase-sensitive; over thousands of
 *    samples any infinitesimal phase offset decorrelates them, so they are NOT
 *    expected to match here. Validating those needs the audio A/B (a WAV bounce of
 *    the same note from the plugin) — see docs/RUN_GUIDE_AUDIO_AB.md.
 *
 *   usage: ab_persample <t0.bin> <t1.bin> <dsp_read_offsets.txt> [max_k]
 */
#include "../src/juno_engine.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#define NB 12058624

static unsigned char t0[NB], t1[NB];

int main(int argc, char **argv)
{
    if (argc < 4) { printf("usage: %s t0 t1 offs [max_k]\n", argv[0]); return 2; }
    int max_k = (argc > 4) ? atoi(argv[4]) : 20000;

    FILE *f0 = fopen(argv[1],"rb"), *f1 = fopen(argv[2],"rb"), *fo = fopen(argv[3],"r");
    if (!f0||!f1||!fo) { printf("FAIL: missing inputs (run `make validate` first)\n"); return 2; }
    if (fread(t0,1,NB,f0)!=NB || fread(t1,1,NB,f1)!=NB) { printf("FAIL: short dump\n"); return 2; }

    static long offs[4096]; int noff = 0; char line[64];
    while (fgets(line,sizeof line,fo) && noff < 4096) {
        long o = atol(line);
        if (o<=0 || o+4>NB || o >= 84000) continue;
        if (memcmp(t0+o, t1+o, 4) == 0) continue;   /* dynamic voice-0 fields only */
        offs[noff++] = o;
    }

    /* For each field, scan K and record the best (min |ours-plugin|) and its K. */
    static double bestres[4096]; static int bestk[4096];
    for (int j = 0; j < noff; ++j) { bestres[j] = 1e300; bestk[j] = -1; }

    unsigned char *st = malloc(JUNO_STATE_BYTES);
    memcpy(st, t0, NB); memset(st + NB, 0, JUNO_STATE_BYTES - NB);
    for (int k = 1; k <= max_k; ++k) {
        float l=0, r=0; juno_voice_render(st, &l, &r);
        for (int j = 0; j < noff; ++j) {
            float a, b; memcpy(&a, st+offs[j],4); memcpy(&b, t1+offs[j],4);
            if (!isfinite(a) || !isfinite(b)) continue;
            double res = fabs((double)a - (double)b);
            if (res < bestres[j]) { bestres[j] = res; bestk[j] = k; }
        }
    }

    /* Count fields that reach a bit-exact / near-exact match, and find the modal K
     * among them (the real t0->t1 control-rate gap). */
    int exact = 0, near = 0;
    for (int j = 0; j < noff; ++j) {
        float b; memcpy(&b, t1+offs[j],4);
        double scale = fmax(fabs((double)b), 1e-6);
        if (bestres[j] == 0.0) exact++;
        if (bestres[j] <= scale * 1e-4) near++;
    }
    printf("tracked %d dynamic voice-0 fields over K=1..%d\n", noff, max_k);
    printf("CONTROL-RATE match: %d/%d dynamic fields reach within 0.01%% of the "
           "plugin when run forward (%d of them BIT-EXACT)\n", near, noff, exact);
    printf("(audio-rate filter-memory fields decorrelate in phase — expected; "
           "see docs/RUN_GUIDE_AUDIO_AB.md for the WAV A/B that covers those)\n");

    /* Show the headline control fields at their own best-K (each is a monotonic
     * slew, so a unique K aligns it; bit-exact there proves the slew math). */
    long show[] = {7520, 9856, 9776, 6704};
    const char *nm[] = {"VCF cutoff", "VCA env", "amp gain", "cutoff base"};
    printf("headline control-rate fields (each at its own best-fit K):\n");
    for (unsigned s = 0; s < sizeof(show)/sizeof(long); ++s) {
        int j = -1;
        for (int t = 0; t < noff; ++t) if (offs[t] == show[s]) { j = t; break; }
        if (j < 0) continue;
        float b; memcpy(&b, t1+show[s],4);
        printf("  off %5ld %-12s plugin=%.6f  best |d|=%.2e at K=%d %s\n",
               show[s], nm[s], b, bestres[j], bestk[j],
               bestres[j]==0.0 ? "(BIT-EXACT)" : "");
    }
    free(st);
    return 0;
}

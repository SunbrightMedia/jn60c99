/* host_ref.c — x86 reference: print the bit-exact hash of each patch at the
 * platform rate (48000). These hashes ARE the plugin's output (the x86 engine
 * nulls EXACTLY 0 vs the plugin, make verify). The bare-metal kernel bakes
 * them in and must reproduce every one.
 *
 * usage: host_ref <bank.bin> [nframes]   (default 4000)  */
#include <stdio.h>
#include <stdlib.h>
#include "juno_probe_core.h"

#define SR   48000.0f
#define NOTE 60
#define VEL  105

int main(int argc, char **argv)
{
    if (argc < 2) { fprintf(stderr, "need bank path\n"); return 2; }
    FILE *f = fopen(argv[1], "rb");
    if (!f) { fprintf(stderr, "open %s failed\n", argv[1]); return 2; }
    fseek(f, 0, SEEK_END); long len = ftell(f); fseek(f, 0, SEEK_SET);
    unsigned char *bank = (unsigned char *)malloc((size_t)len);
    if (fread(bank, 1, (size_t)len, f) != (size_t)len) return 2;
    fclose(f);

    int nfr = (argc > 2) ? atoi(argv[2]) : 4000;
    int def[] = { 0, 5, 11, 21, 27, 36, 42, 48, 55, 60, 63, 7 };
    int npat = (int)(sizeof def / sizeof def[0]);
    float *buf = (float *)malloc(sizeof(float) * 2 * (size_t)nfr);

    printf("# JUNO bit-exact reference @ %.0f Hz, note %d vel %d, %d frames\n",
           SR, NOTE, VEL, nfr);
    for (int i = 0; i < npat; ++i) {
        float pk;
        uint64_t h = juno_probe_render_hash(bank, (int)len, def[i],
                                            SR, NOTE, VEL, nfr, buf, &pk);
        printf("patch %2d  hash %016llx  pk %.6f\n",
               def[i], (unsigned long long)h, pk);
    }
    return 0;
}

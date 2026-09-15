/* arm_bitexact.c -- prove the JUNO engine is BIT-EXACT when built for ARM.
 *
 * The whole Raspberry Pi plan rests on one claim: the same C source, compiled
 * for AArch64 with -ffp-contract=off, produces the SAME float samples as the
 * x86 host build that is already proven bit-exact against the plugin. This
 * harness renders a set of factory patches through the engine's own gui API
 * and prints a hash of the raw float output per patch. Build it twice (native
 * x86 and cross aarch64, run under qemu) and diff the hashes. Identical = ARM
 * carries the seal; the platform port can proceed. Any mismatch names the
 * exact patch, and the cause is one of the three known traps (FMA, denormals,
 * a libm call) -- a bug to fix before a single board is bought.
 *
 * usage: arm_bitexact <bank.bin> [patch ...]   (default: a 12-patch spread) */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

/* the engine's own host API (gui/juno_bridge.c) -- same calls libjuno exports */
void *juno_gui_create(float sr, int flags);
void  juno_gui_destroy(void *ctx);
int   juno_gui_apply_bank(void *ctx, const char *bank, int len, int idx);
void  juno_gui_note_on(void *ctx, int note, int vel);
int   juno_gui_render(void *ctx, float *buf, int nframes);

#define SR    44100.0f
#define NOTE  60
#define VEL   105
#define NFR   16000            /* ~0.36 s, well into the sustain */

/* FNV-1a over the raw sample BYTES: any single-bit float difference changes it. */
static uint64_t fnv1a(const unsigned char *p, size_t n)
{
    uint64_t h = 1469598103934665603ULL;
    for (size_t i = 0; i < n; ++i) { h ^= p[i]; h *= 1099511628211ULL; }
    return h;
}

int main(int argc, char **argv)
{
    if (argc < 2) { fprintf(stderr, "need bank path\n"); return 2; }
    FILE *f = fopen(argv[1], "rb");
    if (!f) { fprintf(stderr, "open %s failed\n", argv[1]); return 2; }
    fseek(f, 0, SEEK_END); long len = ftell(f); fseek(f, 0, SEEK_SET);
    char *bank = (char *)malloc((size_t)len);
    if (fread(bank, 1, (size_t)len, f) != (size_t)len) { return 2; }
    fclose(f);

    int def[] = { 0, 5, 11, 21, 27, 36, 42, 48, 55, 60, 63, 7 };
    int npat, *pats;
    if (argc > 2) { npat = argc - 2; pats = (int *)malloc(sizeof(int) * npat);
                    for (int i = 0; i < npat; ++i) pats[i] = atoi(argv[2 + i]); }
    else          { npat = (int)(sizeof def / sizeof def[0]); pats = def; }

    float *buf = (float *)malloc(sizeof(float) * 2 * NFR);
    for (int i = 0; i < npat; ++i) {
        void *c = juno_gui_create(SR, 0);
        juno_gui_apply_bank(c, bank, (int)len, pats[i]);
        juno_gui_note_on(c, NOTE, VEL);
        juno_gui_render(c, buf, NFR);
        uint64_t h = fnv1a((const unsigned char *)buf,
                           sizeof(float) * 2 * (size_t)NFR);
        printf("patch %2d  hash %016llx\n", pats[i], (unsigned long long)h);
        juno_gui_destroy(c);
    }
    return 0;
}

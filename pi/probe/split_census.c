/* split_census.c — enumerate EVERY cell juno_voice_render writes, to find any
 * shared state (besides the noise block) that a multi-core voice split would
 * corrupt. Rigidity by census, not by argument.
 *
 * The engine's memory map (src/juno_engine.h):
 *   own main : [176 + v*10512, 176 + (v+1)*10512)  — private to voice v
 *   own aux  : 101504 + v*32 (+ a few bytes)        — private to voice v
 *   shared   : [84272, 84436) noise/LFSR block      — SHARED by all voices
 * A concurrency-safe split needs each core to write ONLY its own voice's private
 * cells, plus a PRIVATE copy of the shared noise block. So: render each voice
 * from a clean state, diff the whole 12 MB, and flag any written byte that is
 * NOT in that voice's own main/aux block and NOT in the noise block. Any such
 * "HAZARD" range is shared state the split must give each core privately.
 *
 * usage: split_census <bank.bin> [npatch]   (default 64) */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include "juno_engine.h"
#include "juno_driver.h"

void *juno_gui_create(float, int);
void  juno_gui_reinit(void *, float, int);
int   juno_gui_apply_bank(void *, const char *, int, int);
void  juno_gui_note_on(void *, int, int);
int   juno_gui_render(void *, float *, int);
unsigned char *juno_gui_state(void *);
unsigned juno_gui_state_bytes(void);

#define SR 48000.0f
#define NOISE_LO 84272u
#define NOISE_HI 84436u
#define AUX_BASE 101504u
#define AUX_STRIDE 32u
#define MAIN_BASE 176u

static int classify(unsigned off, int v)   /* 0 own-main, 1 own-aux, 2 noise, 3 HAZARD */
{
    unsigned mlo = MAIN_BASE + (unsigned)v * JUNO_VOICE_MAIN_STRIDE;
    unsigned mhi = mlo + JUNO_VOICE_MAIN_STRIDE;
    if (off >= mlo && off < mhi) return 0;
    if (off >= AUX_BASE + (unsigned)v * AUX_STRIDE &&
        off <  AUX_BASE + (unsigned)v * AUX_STRIDE + AUX_STRIDE) return 1;
    if (off >= NOISE_LO && off < NOISE_HI) return 2;
    return 3;
}

/* track distinct HAZARD ranges (coalesced) seen across the whole census */
#define MAXH 256
static unsigned hlo[MAXH], hhi[MAXH]; static int nh = 0;
static void note_hazard(unsigned off)
{
    for (int i = 0; i < nh; ++i) {
        if (off >= hlo[i] && off < hhi[i]) return;
        if (off == hhi[i]) { hhi[i] = off + 1; return; }
        if (off + 1 == hlo[i]) { hlo[i] = off; return; }
    }
    if (nh < MAXH) { hlo[nh] = off; hhi[nh] = off + 1; ++nh; }
}

int main(int argc, char **argv)
{
    if (argc < 2) { fprintf(stderr, "need bank\n"); return 2; }
    FILE *f = fopen(argv[1], "rb");
    fseek(f, 0, SEEK_END); long len = ftell(f); fseek(f, 0, SEEK_SET);
    unsigned char *bank = malloc(len);
    if (fread(bank, 1, len, f) != (size_t)len) return 2;
    fclose(f);
    int npatch = argc > 2 ? atoi(argv[2]) : 64; if (npatch > 64) npatch = 64;
    int points[] = { 1, 40, 200, 900, 3000 };
    int chord[] = { 45, 48, 52, 55, 60, 64, 67, 72 };

    void *c = juno_gui_create(SR, 0);
    unsigned SB = juno_gui_state_bytes();
    unsigned char *S = malloc(SB); float *rb = malloc(sizeof(float) * 2 * 3100);

    long own_main = 0, own_aux = 0, noise = 0, hazard = 0;
    for (int p = 0; p < npatch; ++p)
      for (int q = 0; q < (int)(sizeof points/sizeof points[0]); ++q) {
        juno_gui_reinit(c, SR, 0);
        juno_gui_apply_bank(c, (const char *)bank, (int)len, p);
        for (int k = 0; k < 8; ++k) juno_gui_note_on(c, chord[k], 100);
        juno_gui_render(c, rb, points[q]);
        unsigned char *st = juno_gui_state(c);
        memcpy(S, st, SB);                       /* clean pre-state */

        for (int v = 0; v < 8; ++v) {
            memcpy(st, S, SB);                    /* every voice from the SAME state */
            float l = 0, r = 0;
            juno_voice_render(st, v, &l, &r);
            for (unsigned o = 0; o < SB; ++o)
                if (st[o] != S[o]) {
                    switch (classify(o, v)) {
                    case 0: ++own_main; break;
                    case 1: ++own_aux;  break;
                    case 2: ++noise;    break;
                    default: ++hazard; note_hazard(o); break;
                    }
                }
        }
      }

    printf("scanned %d patches x %d points x 8 voices, full 12 MB diff each\n",
           npatch, (int)(sizeof points/sizeof points[0]));
    printf("written bytes: own-main %ld  own-aux %ld  noise(shared) %ld  HAZARD %ld\n",
           own_main, own_aux, noise, hazard);
    if (hazard == 0) {
        printf("NO OTHER SHARED WRITES: a voice writes ONLY its own block + the noise "
               "block. Split is rigid with per-core private noise.\n");
        return 0;
    }
    printf("HAZARD ranges (shared/foreign cells a voice writes — each needs a "
           "private per-core copy):\n");
    for (int i = 0; i < nh; ++i)
        printf("  [%u, %u)  (%u bytes)\n", hlo[i], hhi[i], hhi[i] - hlo[i]);
    return 1;
}

/* block_split_gate.c — prove the SHARED-NOTHING block fork-join is bit-exact.
 *
 * The firmware plan (MiniDexed-style): each core owns a PRIVATE copy of the
 * engine state and a FIXED set of voices; it renders its voices for a whole
 * block into a shared per-voice buffer; then ONE audio core sums the voices per
 * sample in canonical order and runs the master/FX. Voices never migrate; cores
 * touch only their own copy during render. ZERO DSP change.
 *
 * Why shared-nothing: juno_voice_render does a read-modify-write of the shared
 * noise block [84272,84436), NOT race-safe on one shared state. A private copy
 * per core removes the hazard; the noise step is voice-independent and
 * deterministic, so every copy's noise evolves identically with NO comms.
 *
 * This models that execution EXACTLY and runs MANY CONSECUTIVE BLOCKS, comparing
 * every output sample to the single-core reference. Continuity over many blocks
 * is the real proof: any state drift (a voice, the FX, the noise) would surface
 * as a later-block divergence. usage: block_split_gate <bank> [npatch] */
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
#define NOISE_OFF 84272u
#define NOISE_LEN 164u
#define NF 256                       /* block size (frames) */
#define NBLK 40                      /* consecutive blocks per state (~0.2 s) */

/* Render voices [vlo,vhi) for one block on private state `st`, into vbuf rows —
 * the exact per-sample sequence the single core uses for those voices. */
static void render_core(unsigned char *st, int vlo, int vhi, float vbuf[8][NF])
{
    unsigned char nblk[NOISE_LEN];
    for (int s = 0; s < NF; ++s) {
        memcpy(nblk, st + NOISE_OFF, NOISE_LEN);
        for (int v = vlo; v < vhi; ++v) {
            float l = 0.0f, r = 0.0f;
            memcpy(st + NOISE_OFF, nblk, NOISE_LEN);
            juno_voice_render(st, v, &l, &r);
            vbuf[v][s] = l;
        }
        juno_flush_denormals(st);                 /* per-sample flush */
    }
}

static const int PARTS[][5] = {
    {2, 0, 4, 8, 8},          /* 2 cores: 0-3 | 4-7            */
    {4, 0, 2, 4, 6},          /* 4 cores: 0-1|2-3|4-5|6-7      */
    {3, 0, 3, 5, 8},          /* 3 cores: 0-2|3-4|5-7          */
};
#define NPART ((int)(sizeof PARTS / sizeof PARTS[0]))

int main(int argc, char **argv)
{
    if (argc < 2) { fprintf(stderr, "need bank\n"); return 2; }
    FILE *f = fopen(argv[1], "rb");
    fseek(f, 0, SEEK_END); long len = ftell(f); fseek(f, 0, SEEK_SET);
    unsigned char *bank = malloc(len);
    if (fread(bank, 1, len, f) != (size_t)len) return 2;
    fclose(f);
    int npatch = argc > 2 ? atoi(argv[2]) : 64; if (npatch > 64) npatch = 64;
    int points[] = { 1, 300, 1500 };
    int chord[] = { 45, 48, 52, 55, 60, 64, 67, 72 };

    void *cref = juno_gui_create(SR, 0);
    void *ccore[4]; for (int i = 0; i < 4; ++i) ccore[i] = juno_gui_create(SR, 0);
    unsigned SB = juno_gui_state_bytes();
    unsigned char *snap = malloc(SB);
    float *rb = malloc(sizeof(float) * 2 * 1600);
    static float vbuf[8][NF]; static float refblk[2 * NF];

    long checks = 0, fails = 0, worstblk = -1;
    for (int p = 0; p < npatch; ++p)
      for (int q = 0; q < (int)(sizeof points/sizeof points[0]); ++q)
        for (int pt = 0; pt < NPART; ++pt) {
            int ncore = PARTS[pt][0];
            int bound[5]; for (int i = 0; i <= ncore; ++i) bound[i] = PARTS[pt][1+i];
            bound[ncore] = 8;

            /* build the state, snapshot it, clone to reference + every core */
            juno_gui_reinit(cref, SR, 0);
            juno_gui_apply_bank(cref, (const char *)bank, (int)len, p);
            for (int k = 0; k < 8; ++k) juno_gui_note_on(cref, chord[k], 100);
            juno_gui_render(cref, rb, points[q]);
            memcpy(snap, juno_gui_state(cref), SB);
            for (int cc = 0; cc < ncore; ++cc)
                memcpy(juno_gui_state(ccore[cc]), snap, SB);

            unsigned char *sref = juno_gui_state(cref);
            unsigned char *sa   = juno_gui_state(ccore[0]);   /* audio core */
            int diverged = 0;

            for (int blk = 0; blk < NBLK && !diverged; ++blk) {
                /* single-core reference block */
                for (int s = 0; s < NF; ++s)
                    juno_driver_render_sample(sref, &refblk[2*s], &refblk[2*s+1]);

                /* split: every core renders its voices (private copies) */
                for (int cc = 0; cc < ncore; ++cc)
                    render_core(juno_gui_state(ccore[cc]), bound[cc], bound[cc+1], vbuf);

                /* audio core sums canonically + masters, per sample */
                for (int s = 0; s < NF; ++s) {
                    float scratch = 0.0f, *a2[16];
                    for (int i = 0; i < 16; ++i) a2[i] = &scratch;
                    for (int v = 0; v < 8; ++v) a2[2*v] = &vbuf[v][s];
                    float L = 0, R = 0, *a3[2] = { &L, &R };
                    juno_master_render(sa, a2, a3);
                    if (L != refblk[2*s] || R != refblk[2*s+1]) {
                        diverged = 1;
                        if (fails < 12)
                            printf("patch %2d point %4d %dcore block %d sample %d  "
                                   "L %.9g/%.9g R %.9g/%.9g\n",
                                   p, points[q], ncore, blk, s,
                                   refblk[2*s], L, refblk[2*s+1], R);
                        break;
                    }
                }
                if (diverged && (worstblk < 0 || blk < worstblk)) worstblk = blk;
            }
            ++checks;
            if (diverged) ++fails;
        }

    printf("----\n");
    printf("checked %ld runs (patches %d x points %d x partitions %d), "
           "%d blocks x %d frames each\n",
           checks, npatch, (int)(sizeof points/sizeof points[0]), NPART, NBLK, NF);
    if (fails == 0) {
        printf("BLOCK SHARED-NOTHING SPLIT IS BIT-EXACT over %d consecutive blocks: "
               "every partition (2/3/4 cores) == single-core, every sample\n", NBLK);
        return 0;
    }
    printf("BLOCK SPLIT DIVERGES in %ld runs (earliest at block %ld)\n", fails, worstblk);
    return 1;
}

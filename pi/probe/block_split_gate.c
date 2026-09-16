/* block_split_gate.c — prove the SHARED-NOTHING block fork-join is bit-exact,
 * INCLUDING the per-sample control tick and LIVE note events.
 *
 * Firmware plan (MiniDexed-style): each core owns a PRIVATE state copy and a
 * FIXED voice set. Every core runs the per-sample CONTROL tick (arp + note) on
 * its own copy — so every copy advances its arp/note/gate state identically from
 * the same replicated control — then renders ONLY its own voices into a shared
 * per-voice buffer. One audio core sums canonically and runs the master/FX.
 * ZERO DSP change; shared-nothing removes the noise-block race.
 *
 * Reference = juno_gui_render (the true single-core audio path: tick + all voices
 * + master + flush, per sample). The split must match it, block for block, with
 * live note-on/off injected between blocks and the arp running. Continuity over
 * many blocks is the proof — any drift in a voice, the FX, the noise, the arp or
 * the gates would surface as a later-block divergence.
 * usage: block_split_gate <bank> [npatch] */
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
void  juno_gui_note_off(void *, int);
void  juno_gui_arp_config(void *, int, int, int, float, float);
void  juno_gui_tick(void *);                 /* one sample of arp+note control    */
int   juno_gui_render(void *, float *, int); /* single-core reference path        */
unsigned char *juno_gui_state(void *);
unsigned juno_gui_state_bytes(void);

#define SR 48000.0f
#define NOISE_OFF 84272u
#define NOISE_LEN 164u
#define NF 128                       /* block size (frames) */
#define NBLK 60                      /* consecutive blocks (~0.16 s), events between */

static uint32_t xs(uint32_t *s){uint32_t x=*s;x^=x<<13;x^=x>>17;x^=x<<5;return *s=x;}

/* One core's block: tick control on its OWN copy each sample, render its voices. */
static void render_core(void *ctx, int vlo, int vhi, float vbuf[8][NF])
{
    unsigned char *st = juno_gui_state(ctx);
    unsigned char nblk[NOISE_LEN];
    for (int s = 0; s < NF; ++s) {
        juno_gui_tick(ctx);                       /* arp + note tick (replicated) */
        memcpy(nblk, st + NOISE_OFF, NOISE_LEN);
        for (int v = vlo; v < vhi; ++v) {
            float l = 0.0f, r = 0.0f;
            memcpy(st + NOISE_OFF, nblk, NOISE_LEN);
            juno_voice_render(st, v, &l, &r);
            vbuf[v][s] = l;
        }
        juno_flush_denormals(st);
    }
}

static const int PARTS[][5] = {
    {1, 0, 8, 8, 8},          /* 1 core (isolation: my loop vs juno_gui_render) */
    {2, 0, 4, 8, 8}, {4, 0, 2, 4, 6}, {3, 0, 3, 5, 8},
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

    void *cref = juno_gui_create(SR, 0);
    void *ccore[4]; for (int i = 0; i < 4; ++i) ccore[i] = juno_gui_create(SR, 0);
    unsigned SB = juno_gui_state_bytes();
    unsigned char *snap = malloc(SB);
    static float vbuf[8][NF]; static float refblk[2 * NF];
    int held[16], nheld;

    long checks = 0, fails = 0, worst = -1;
    for (int p = 0; p < npatch; ++p)
      for (int pt = 0; pt < NPART; ++pt)
        for (int arp = 0; arp < 2; ++arp) {         /* test with arp off and on */
            int ncore = PARTS[pt][0];
            int bound[5]; for (int i = 0; i <= ncore; ++i) bound[i] = PARTS[pt][1+i];
            bound[ncore] = 8;
            uint32_t s = 0x1234u ^ (uint32_t)(p*131 + pt*7 + arp);

            /* Set up the reference AND every core's copy with the IDENTICAL call
             * sequence from a fresh engine — NOT an st clone. The voice allocator
             * state lives in the juno_ctx, not in the 12 MB st, so a copy must be
             * driven by the same events from boot to keep allocation in lockstep.
             * This is the firmware rule: broadcast every event to every copy. */
            void *all[5]; int nall = 0; all[nall++] = cref;
            for (int cc = 0; cc < ncore; ++cc) all[nall++] = ccore[cc];
            for (int a = 0; a < nall; ++a) {
                juno_gui_reinit(all[a], SR, 0);
                juno_gui_apply_bank(all[a], (const char *)bank, (int)len, p);
                if (arp) juno_gui_arp_config(all[a], 1, 0, 1, 120.0f, 0.75f);
                juno_gui_note_on(all[a], 60, 100);
            }
            (void)snap;
            nheld = 1; held[0] = 60;

            int diverged = 0;
            for (int blk = 0; blk < NBLK && !diverged; ++blk) {
                /* live control between blocks: same event to reference AND all copies */
                uint32_t r = xs(&s) % 100u;
                if (r < 30) { int nt = 36 + (int)(xs(&s)%48u), vv = 40+(int)(xs(&s)%88u);
                    juno_gui_note_on(cref, nt, vv);
                    for (int cc=0;cc<ncore;++cc) juno_gui_note_on(ccore[cc], nt, vv);
                    if (nheld<16) held[nheld++]=nt; }
                else if (r < 55 && nheld>0) { int idx=(int)(xs(&s)%(uint32_t)nheld), nt=held[idx];
                    juno_gui_note_off(cref, nt);
                    for (int cc=0;cc<ncore;++cc) juno_gui_note_off(ccore[cc], nt); }

                /* single-core reference block */
                juno_gui_render(cref, refblk, NF);

                /* split: WORKER cores render their voices for the whole block */
                for (int cc = 1; cc < ncore; ++cc)
                    render_core(ccore[cc], bound[cc], bound[cc+1], vbuf);

                /* AUDIO core (copy 0) interleaves per sample — tick, render its own
                 * voices, THEN master (so the master reads the control smoothers at
                 * THIS sample, exactly like single-core), then flush. */
                void *ca = ccore[0]; unsigned char *sa = juno_gui_state(ca);
                unsigned char nblk[NOISE_LEN];
                for (int i = 0; i < NF; ++i) {
                    juno_gui_tick(ca);
                    memcpy(nblk, sa + NOISE_OFF, NOISE_LEN);
                    for (int v = bound[0]; v < bound[1]; ++v) {
                        float l = 0.0f, rr = 0.0f;
                        memcpy(sa + NOISE_OFF, nblk, NOISE_LEN);
                        juno_voice_render(sa, v, &l, &rr);
                        vbuf[v][i] = l;
                    }
                    float scratch = 0.0f, *a2[16];
                    for (int j = 0; j < 16; ++j) a2[j] = &scratch;
                    for (int v = 0; v < 8; ++v) a2[2*v] = &vbuf[v][i];
                    float L = 0, R = 0, *a3[2] = { &L, &R };
                    juno_master_render(sa, a2, a3);
                    juno_flush_denormals(sa);
                    if (L != refblk[2*i] || R != refblk[2*i+1]) {
                        diverged = 1;
                        if (fails < 12)
                            printf("patch %2d %dcore arp%d block %d smp %d  L %.9g/%.9g R %.9g/%.9g\n",
                                   p, ncore, arp, blk, i, refblk[2*i], L, refblk[2*i+1], R);
                        break;
                    }
                }
                if (diverged && (worst < 0 || blk < worst)) worst = blk;
            }
            ++checks; if (diverged) ++fails;
        }

    printf("----\n");
    printf("checked %ld runs (patches %d x partitions %d x arp{off,on}), "
           "%d blocks x %d frames, live note events + tick replicated\n",
           checks, npatch, NPART, NBLK, NF);
    if (fails == 0) {
        printf("BLOCK SHARED-NOTHING SPLIT IS BIT-EXACT vs juno_gui_render: every "
               "partition (2/3/4 cores), arp on/off, with live notes, every sample\n");
        return 0;
    }
    printf("BLOCK SPLIT DIVERGES in %ld runs (earliest block %ld)\n", fails, worst);
    return 1;
}

/* listen_mask_probe.c — WHICH VOICES SOUND, measured.
 *
 * The firmware must hold non-sounding voices at rest, or a "2-voice" run
 * costs eight voices. Which voices the port's allocator chose for a given
 * chord is NOT guessable: it fills from voice 7 DOWNWARD, and assuming 0..k-1
 * made the first firmware simulation render silence (peak 16 of 30000) while
 * looking like a broken engine.
 *
 * So it is measured: for each chord snapshot, render a short burst with
 * exactly one voice awake and see whether anything comes out. Prints one
 * hex mask per chord for the generator to embed.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "eb_engine.h"
#include "eb_render.h"
#include "eb_master.h"
#include "eb_master_coefs.h"
#include "s3_listen_meta.h"


static eb_engine EBE; static eb_render_coefs RC; static eb_master_coef MC;
static eb_master_rings RG; static eb_render_state *RS; static eb_master_state *MS;
/* THE MASTER STATE IS COPIED MEMBER BY MEMBER, and this is not tidiness.
 * Five of its FX sub-states end in `float *ring` -- 8 bytes on the host that
 * generated the blob, 4 bytes here -- so sizeof(eb_master_state) is 729,824
 * there and 729,768 here. The first firmware copied the blob whole: every
 * field past the first pointer landed at the wrong offset, the reverb read a
 * garbage ring depth, and the board died with a LoadStoreError at an
 * unmapped address on its first rendered sample.
 *
 * min(host, target) bytes of each member is EXACT, because every pointer is
 * the LAST member of its struct and eb_master_render re-assigns all of them
 * from eb_master_rings before use. */
static const unsigned char *ms_load(const unsigned char *p)
{
    void *dst[S3L_NMSEC];
    unsigned tgt[S3L_NMSEC];
    int i;
    dst[0]=&MS->in;   tgt[0]=sizeof MS->in;
    dst[1]=&MS->d1;   tgt[1]=sizeof MS->d1;
    dst[2]=&MS->d4;   tgt[2]=sizeof MS->d4;
    dst[3]=&MS->e0;   tgt[3]=sizeof MS->e0;
    dst[4]=&MS->d23;  tgt[4]=sizeof MS->d23;
    dst[5]=&MS->d5;   tgt[5]=sizeof MS->d5;
    dst[6]=&MS->e1;   tgt[6]=sizeof MS->e1;
    dst[7]=&MS->e5;   tgt[7]=sizeof MS->e5;
    dst[8]=&MS->rev;  tgt[8]=sizeof MS->rev;
    dst[9]=&MS->cho;  tgt[9]=sizeof MS->cho;
    dst[10]=&MS->dcore; tgt[10]=sizeof MS->dcore;
    dst[11]=&MS->fb84672; tgt[11]=2u*sizeof(float);
    dst[12]=&MS->route_change; tgt[12]=sizeof MS->route_change;
    dst[13]=MS->rev_pending;   tgt[13]=sizeof MS->rev_pending;
    dst[14]=&MS->rev_wipe;     tgt[14]=sizeof MS->rev_wipe;
    for (i = 0; i < S3L_NMSEC; ++i) {
        unsigned n = S3L_MSEC[i] < tgt[i] ? S3L_MSEC[i] : tgt[i];
        memcpy(dst[i], p, n);
        p += S3L_MSEC[i];          /* the blob stride is the HOST size */
    }
    return p;
}


int main(int argc, char **argv)
{
    FILE *f = fopen(argv[1], "rb");
    long n; unsigned char *blob;
    const unsigned char *B_RS, *B_MS, *B_C;
    int c, v;
    fseek(f, 0, SEEK_END); n = ftell(f); rewind(f);
    blob = malloc((size_t)n);
    if (fread(blob, 1, (size_t)n, f) != (size_t)n) return 2;
    fclose(f);
    B_RS = blob + 32; B_MS = B_RS + S3L_RSTATE_SZ; B_C = B_MS + S3L_MSTATE_SZ;
    RS = malloc(sizeof *RS); MS = malloc(sizeof *MS);
    {   float **d[9] = {&RG.t1,&RG.t23,&RG.t5_0,&RG.t5_1,&RG.t5_2,&RG.t5_3,
                        &RG.e5,&RG.t4_0,&RG.t4_1};
        int32_t *L[9] = {&RG.t1_len,&RG.t23_len,&RG.t5_0_len,&RG.t5_1_len,
                         &RG.t5_2_len,&RG.t5_3_len,&RG.e5_len,&RG.t4_0_len,
                         &RG.t4_1_len};
        int i;
        for (i = 0; i < 9; ++i) {
            *d[i] = calloc((size_t)S3L_RING_LEN[i], sizeof(float));
            *L[i] = S3L_RING_LEN[i];
        }
    }
    for (c = 0; c < S3L_NNOTE; ++c) {
        unsigned mask = 0;
        const unsigned char *p = B_C + (size_t)(c * 2)
            * (S3L_COEF_SZ + S3L_MCOEF_SZ + S3L_VOICE_SZ);
        for (v = 0; v < EB_NUM_VOICES; ++v) {
            double pk = 0.0; int i, k;
            memcpy(RS, B_RS, S3L_RSTATE_SZ);
            ms_load(B_MS);
            memcpy(&RC, p, S3L_COEF_SZ);
            memcpy(&MC, p + S3L_COEF_SZ, S3L_MCOEF_SZ);
            memcpy(RS, p + S3L_COEF_SZ + S3L_MCOEF_SZ, S3L_VOICE_SZ);
            eb_engine_init(&EBE, 44100.0f); EBE.render_ok = 1;
            for (i = 0; i < 4096; ++i) {
                float vb[EB_NUM_VOICES], L = 0.0f, R = 0.0f;
                for (k = 0; k < EB_NUM_VOICES; ++k)
                    EBE.v[k].atrest = (k != v);
                for (k = 0; k < EB_NUM_VOICES; ++k) vb[k] = 0.0f;
                eb_engine_render_voices(&EBE, RS, &RC,
                                        (const eb_render_needs *)0, vb);
                (void)eb_master_render(MS, &MC, &RG, vb, &L, &R);
                if (fabs((double)vb[v]) > pk) pk = fabs((double)vb[v]);
            }
            /* the VOICE's own sample, not the master's: the FX tail of a
             * previous chord would otherwise mark a silent voice as sounding */
            if (c==0) fprintf(stderr,"  chord0 voice%d pk=%.6g\n",v,pk);
            if (pk > 1e-4) mask |= 1u << v;
        }
        printf("%d 0x%02x\n", c, mask);
    }
    return 0;
}

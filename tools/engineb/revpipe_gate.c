/* revpipe_gate.c -- THE REV-PIPE COMPOSITION GATE.
 *
 * CLAIM UNDER TEST. eb_master_render_front (in + delay + effect: the
 * per-sample feedback loop) and eb_master_render_back (reverb + out: the
 * feed-forward tail) may be scheduled CHUNK-BATCHED -- all of a chunk's
 * fronts, then all of its backs on the buffered v176/v177 -- and the output
 * stream is BIT-IDENTICAL to the serial eb_master_render. That is the whole
 * safety case for running back() on the other core one chunk late: the same
 * call sequence, spread over wall time. If any state is secretly shared
 * between the halves (a reverb field the effect reads, a feedback the reverb
 * writes), the batched order diverges and this gate goes RED.
 *
 * Two full instances over the same voice stream:
 *   A: serial   eb_master_render per sample
 *   B: batched  chunk of front(), then chunk of back()
 * Compare every output sample BIT FOR BIT. 0 differing, or the split lies.
 *
 * THE TOOTH (argv tooth=1): perturb ONE buffered v176 by one ULP in one
 * chunk. The gate MUST then report differences; a run where it does not is
 * a blind gate and every green from it is worthless.
 *
 * usage: revpipe_gate <blob> <chord 1-8> <chunk> <nchunks> <tooth 0|1>
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

static eb_engine        EBE;
static eb_render_coefs  RC;
static eb_master_coef   MC;
static eb_master_rings  RGa, RGb;
static eb_render_state *RS;
static eb_master_state *MSa, *MSb;

/* THE MASTER STATE IS COPIED MEMBER BY MEMBER -- the blob stride is the sum
 * of member sizes (S3L_MSEC), not sizeof(struct). A flat memcpy lands every
 * field past the first padding at the wrong offset. Copied verbatim from
 * listen_mask_probe.c, which paid for this lesson with a LoadStoreError. */
static const unsigned char *ms_load(eb_master_state *MS, const unsigned char *p)
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
        p += S3L_MSEC[i];          /* the blob stride is the generator's size */
    }
    return p;
}

static void rings_alloc(eb_master_rings *RG)
{
    float **dst[9] = { &RG->t1, &RG->t23, &RG->t5_0, &RG->t5_1, &RG->t5_2,
                       &RG->t5_3, &RG->e5, &RG->t4_0, &RG->t4_1 };
    int32_t *len[9] = { &RG->t1_len, &RG->t23_len, &RG->t5_0_len,
                        &RG->t5_1_len, &RG->t5_2_len, &RG->t5_3_len,
                        &RG->e5_len, &RG->t4_0_len, &RG->t4_1_len };
    int i;
    for (i = 0; i < 9; ++i) {
        *dst[i] = calloc((size_t)S3L_RING_LEN[i], sizeof(float));
        if (!*dst[i]) { fprintf(stderr, "ring %d\n", i); exit(2); }
        *len[i] = S3L_RING_LEN[i];
    }
}

int main(int argc, char **argv)
{
    const char *blobp = argc > 1 ? argv[1] : "esp32s3/main/s3_listen.bin";
    int nv     = argc > 2 ? atoi(argv[2]) : 3;
    int chunk  = argc > 3 ? atoi(argv[3]) : 256;
    int nchk   = argc > 4 ? atoi(argv[4]) : 172;
    int tooth  = argc > 5 ? atoi(argv[5]) : 0;
    long have; const uint32_t *h; int i, k, c;
    unsigned char *BLOB; const unsigned char *B_RSTATE, *B_MSTATE, *B_COEF;
    int n = chunk * nchk;
    float *VB   = malloc((size_t)n * EB_NUM_VOICES * sizeof(float));
    float *outA = malloc((size_t)n * 2 * sizeof(float));
    float *outB = malloc((size_t)n * 2 * sizeof(float));
    float *f176 = malloc((size_t)chunk * sizeof(float));
    float *f177 = malloc((size_t)chunk * sizeof(float));
    FILE *f = fopen(blobp, "rb");
    if (!f) { perror("blob"); return 2; }
    fseek(f, 0, SEEK_END); have = ftell(f); fseek(f, 0, SEEK_SET);
    BLOB = malloc((size_t)have);
    if (fread(BLOB, 1, (size_t)have, f) != (size_t)have) return 2;
    fclose(f);
    h = (const uint32_t *)BLOB;
    if (h[0] != S3L_MAGIC) { fprintf(stderr, "bad magic\n"); return 2; }
    /* LAYOUT GUARD. A blob generated under other flags shifts every copy
     * below; both paths would read the same garbage and agree -- a green
     * that means nothing. Refuse loudly instead (the mask-probe defect
     * class, gen_listen_coefs.py:199). */
    if (sizeof(*RS) != S3L_RSTATE_SZ ||
        sizeof(RC) != S3L_COEF_SZ || sizeof(MC) != S3L_MCOEF_SZ) {
        fprintf(stderr, "LAYOUT MISMATCH: RS %zu/%u RC %zu/%u "
                "MC %zu/%u -- rebuild blob and gate with the SAME flags\n",
                sizeof(*RS), S3L_RSTATE_SZ,
                sizeof(RC), S3L_COEF_SZ, sizeof(MC), S3L_MCOEF_SZ);
        return 3;
    }   /* MS is loaded member-by-member below; its stride check is ms_load */
    B_RSTATE = BLOB + 32;
    B_MSTATE = B_RSTATE + S3L_RSTATE_SZ;
    B_COEF   = B_MSTATE + S3L_MSTATE_SZ;

    RS  = calloc(1, sizeof *RS);
    MSa = calloc(1, sizeof *MSa);
    MSb = calloc(1, sizeof *MSb);
    memcpy(RS, B_RSTATE, S3L_RSTATE_SZ < sizeof *RS ? S3L_RSTATE_SZ : sizeof *RS);
    ms_load(MSa, B_MSTATE);
    {   /* chord nv, gate ON -- the fork_cost.c recipe, verbatim */
        const unsigned char *p = B_COEF + ((size_t)(nv - 1) * 2u + 0u)
                    * (S3L_COEF_SZ + S3L_MCOEF_SZ + S3L_VOICE_SZ);
        memcpy(&RC, p, S3L_COEF_SZ);
        memcpy(&MC, p + S3L_COEF_SZ, S3L_MCOEF_SZ);
        memcpy(RS, p + S3L_COEF_SZ + S3L_MCOEF_SZ, S3L_VOICE_SZ);
    }
    memcpy(MSb, MSa, sizeof *MSa);          /* identical master start state */
    rings_alloc(&RGa);
    rings_alloc(&RGb);

    eb_engine_init(&EBE, 44100.0f);
    EBE.render_ok = 1;

    /* ---- the ONE voice stream both paths consume ------------------------ */
    for (i = 0; i < n; ++i) {
        float *vb = VB + (size_t)i * EB_NUM_VOICES;
        for (k = 0; k < EB_NUM_VOICES; ++k) EBE.v[k].atrest = (k >= nv);
        for (k = 0; k < EB_NUM_VOICES; ++k) vb[k] = 0.0f;
        eb_engine_render_voices(&EBE, RS, &RC, (const eb_render_needs *)0, vb);
    }

    /* ---- path A: the serial monolith ------------------------------------ */
    for (i = 0; i < n; ++i)
        eb_master_render(MSa, &MC, &RGa, VB + (size_t)i * EB_NUM_VOICES,
                         &outA[2 * i], &outA[2 * i + 1]);

    /* ---- path B: chunk-batched front, then back ------------------------- */
    for (c = 0; c < nchk; ++c) {
        for (i = 0; i < chunk; ++i)
            eb_master_render_front(MSb, &MC, &RGb,
                                   VB + (size_t)(c * chunk + i) * EB_NUM_VOICES,
                                   &f176[i], &f177[i]);
        if (tooth && c == 3)
            f176[10] = nextafterf(f176[10], 1e30f);  /* ONE ulp, ONE sample */
        for (i = 0; i < chunk; ++i)
            eb_master_render_back(MSb, &MC, f176[i], f177[i],
                                  &outB[2 * (c * chunk + i)],
                                  &outB[2 * (c * chunk + i) + 1]);
    }

    /* ---- bit compare ---------------------------------------------------- */
    {
        long diff = 0;
        for (i = 0; i < 2 * n; ++i)
            if (memcmp(&outA[i], &outB[i], sizeof(float)) != 0) ++diff;
        printf("REVPIPE: %ld differing of %d values  chord=%d chunk=%d "
               "tooth=%d\n", diff, 2 * n, nv, chunk, tooth);
        if (tooth) return diff > 0 ? 0 : 1;   /* tooth MUST bite */
        return diff == 0 ? 0 : 1;
    }
}

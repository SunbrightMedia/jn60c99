/* fork_cost.c -- what does the FORK cost per sample, on the host, in
 * instructions? Same question tools/engineb/cost_harness.c asked of the trunk,
 * asked of the code a target would actually run.
 *
 * It drives the two calls the S3 firmware drives -- eb_engine_render_voices()
 * and eb_master_render() -- on the frozen coefficient blob, at a chosen voice
 * count. argv[1] = samples, argv[2] = chord size. Render zero samples for the
 * baseline and difference the two callgrind counts, so setup is not billed.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "eb_engine.h"
#include "eb_render.h"
#include "eb_coefs.h"
#include "eb_master.h"
#include "eb_master_coefs.h"
#include "s3_listen_meta.h"

static eb_engine        EBE;
static eb_render_coefs  RC;
static eb_master_coef   MC;
static eb_master_rings  RG;
static eb_render_state *RS;
static eb_master_state *MS;
static unsigned char   *BLOB;
static const unsigned char *B_RSTATE, *B_MSTATE, *B_COEF;

int main(int argc, char **argv)
{
    int n  = argc > 1 ? atoi(argv[1]) : 1000;
    int nv = argc > 2 ? atoi(argv[2]) : 6;
    long have; const uint32_t *h; float vb[EB_NUM_VOICES]; float L, R; int i;
    FILE *f = fopen("esp32s3/main/s3_listen.bin", "rb");
    if (!f) { perror("blob"); return 1; }
    fseek(f, 0, SEEK_END); have = ftell(f); fseek(f, 0, SEEK_SET);
    BLOB = malloc((size_t)have);
    if (fread(BLOB, 1, (size_t)have, f) != (size_t)have) return 1;
    fclose(f);
    h = (const uint32_t *)BLOB;
    if (h[0] != S3L_MAGIC) { printf("bad magic\n"); return 1; }
    B_RSTATE = BLOB + 32;
    B_MSTATE = B_RSTATE + S3L_RSTATE_SZ;
    B_COEF   = B_MSTATE + S3L_MSTATE_SZ;

    RS = calloc(1, sizeof *RS);
    MS = calloc(1, sizeof *MS);
    memcpy(RS, B_RSTATE, S3L_RSTATE_SZ < sizeof *RS ? S3L_RSTATE_SZ : sizeof *RS);
    memcpy(MS, B_MSTATE, S3L_MSTATE_SZ < sizeof *MS ? S3L_MSTATE_SZ : sizeof *MS);
    {   /* chord nv, gate ON */
        const unsigned char *p = B_COEF + ((size_t)(nv - 1) * 2u + 0u)
                    * (S3L_COEF_SZ + S3L_MCOEF_SZ + S3L_VOICE_SZ);
        memcpy(&RC, p, S3L_COEF_SZ);
        memcpy(&MC, p + S3L_COEF_SZ, S3L_MCOEF_SZ);
        memcpy(RS, p + S3L_COEF_SZ + S3L_MCOEF_SZ, S3L_VOICE_SZ);
#if EB_DCO_WT
        /* THE BLOB IS A TRUNK-LAYOUT SNAPSHOT and this build is not trunk
         * layout: offsetof(wt) is 3016, inside the 6808-byte voice prefix, so
         * the copy above lands trunk bytes on the wavetable state and rpos
         * becomes a wild index. Clearing it here is a HARNESS repair for a
         * cost measurement -- it does NOT fix the firmware, which needs a
         * blob regenerated under the same flags. */
        memset(RS->wt, 0, sizeof RS->wt);
        memset(RS->wt_live, 0, sizeof RS->wt_live);
#endif
    }
    {   float **dst[9] = { &RG.t1, &RG.t23, &RG.t5_0, &RG.t5_1, &RG.t5_2,
                           &RG.t5_3, &RG.e5, &RG.t4_0, &RG.t4_1 };
        int32_t *len[9] = { &RG.t1_len, &RG.t23_len, &RG.t5_0_len,
                            &RG.t5_1_len, &RG.t5_2_len, &RG.t5_3_len,
                            &RG.e5_len, &RG.t4_0_len, &RG.t4_1_len };
        for (i = 0; i < 9; ++i) {
            *dst[i] = calloc((size_t)S3L_RING_LEN[i], sizeof(float));
            if (!*dst[i]) { printf("ring %d\n", i); return 1; }
            *len[i] = S3L_RING_LEN[i];
        }
    }
    eb_engine_init(&EBE, 44100.0f);
    /* render_ok is the standalone engine's own guard; the three gates
     * eb_render.h names have all passed. THE AT-REST FLAGS ARE THE WHOLE
     * MEASUREMENT: without them every voice takes the shortcut and the engine
     * costs 1,500 instructions a sample instead of tens of thousands. */
    EBE.render_ok = 1;
    for (i = 0; i < EB_NUM_VOICES; ++i) EBE.v[i].atrest = (i >= nv);

    for (i = 0; i < n; ++i) {
        int k;
        for (k = 0; k < EB_NUM_VOICES; ++k) EBE.v[k].atrest = (k >= nv);
        eb_engine_render_voices(&EBE, RS, &RC, (const eb_render_needs *)0, vb);
        eb_master_render(MS, &MC, &RG, vb, &L, &R);
    }
    printf("rendered %d samples, %d voices, last %g %g\n", n, nv, L, R);
    return 0;
}

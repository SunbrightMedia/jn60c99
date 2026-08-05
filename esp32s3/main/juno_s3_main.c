/* juno_s3_main.c — the S3 FORK firmware (F4 preparation).
 *
 * WHAT THIS MEASURES AND WHAT IT DOES NOT. This firmware answers ONE
 * question: cycles per sample for the fork engine's chain on real silicon.
 * It reuses tools/engineb/qemu/harness.c AS A SOURCE FILE — the same
 * workload, the same non-silence contract, the same regions — so the QEMU
 * instruction count and the silicon cycle count come from an IDENTICAL
 * program and c/i is their ratio with nothing else varied. The Daisy arc's
 * lesson stands behind that choice: its model was 1.7–4× and its silicon
 * measured 11×, and the difference was never attributable because the
 * workloads differed.
 *
 * It does NOT play patches. Engine B's own recall is the recorded OPEN item
 * (coefficients still come from the PORT's recalled cells on the host);
 * until eb_patch grows a device-side recall, a full-engine bit-exactness
 * test on silicon (the Daisy's E1) has no honest input to run on. What CAN
 * be checked bit-level without recall is checked: the fork evaluators
 * against embedded expected values, below.
 *
 * MEMORY, and the honest label on the number. This build runs the harness
 * with EB_DELAY_LEN=32768 in internal SRAM (see main/CMakeLists.txt for
 * why), so the printed cycles/sample is an INTERNAL-SRAM figure. The
 * shipping engine's 6.10 MB of rings live in PSRAM, and PSRAM latency on
 * the delay path is exactly the cost the Daisy arc warns about. The
 * PSRAM-resident re-measurement is a named F4 task; do not quote this
 * build's number as the product's.
 */
#include <stdio.h>
#include "esp_heap_caps.h"
#include "esp_timer.h"
#include "eb_pitch_fork.h"
#include "eb_exp_fork.h"

int harness_main(void);

/* Spot bit-exactness for the two fork evaluators: eight inputs each, the
 * expected floats computed on the HOST by the same functions the exhaustive
 * gates certified. A mismatch here means the target's arithmetic differs
 * (FPU mode, contraction, libm) and every host proof needs re-examination —
 * loudly, before any cycle number is quoted. */
static const struct { float in, want; } PITCH_VEC[] = {
    /* filled by tools/engineb/gen_s3_vectors.py -- DO NOT EDIT BY HAND */
#include "s3_pitch_vectors.h"
};
static const struct { float in, want; } EXP_VEC[] = {
#include "s3_exp_vectors.h"
};

static int vec_check(void)
{
    int bad = 0;
    unsigned i;
    for (i = 0; i < sizeof PITCH_VEC / sizeof PITCH_VEC[0]; ++i) {
        float g = eb_pitch_fork_eval(PITCH_VEC[i].in);
        if (g != PITCH_VEC[i].want) {
            printf("PITCH VEC MISMATCH [%u] in=%a got=%a want=%a\n",
                   i, (double)PITCH_VEC[i].in, (double)g,
                   (double)PITCH_VEC[i].want);
            ++bad;
        }
    }
    for (i = 0; i < sizeof EXP_VEC / sizeof EXP_VEC[0]; ++i) {
        float g = eb_exp_fork(EXP_VEC[i].in);
        if (g != EXP_VEC[i].want) {
            printf("EXP VEC MISMATCH [%u] in=%a got=%a want=%a\n",
                   i, (double)EXP_VEC[i].in, (double)g,
                   (double)EXP_VEC[i].want);
            ++bad;
        }
    }
    printf("FORK EVALUATOR VECTORS: %s\n", bad ? "FAIL" : "BIT-EXACT");
    return bad;
}

void app_main(void)
{
    printf("\n=== JUNO S3 FORK FIRMWARE (F4) ===\n");
    printf("free internal: %u  free PSRAM: %u\n",
           (unsigned)heap_caps_get_free_size(MALLOC_CAP_INTERNAL),
           (unsigned)heap_caps_get_free_size(MALLOC_CAP_SPIRAM));
    if (vec_check()) {
        printf("HALT: evaluator vectors failed; cycle numbers would be "
               "numbers about a different function.\n");
        return;
    }
    /* CCOUNT on silicon counts CYCLES at the CPU clock; the harness prints
     * raw CCOUNT deltas, so sample_total here IS cycles/sample. Divide by
     * the QEMU run's sample_total for c/i. */
    harness_main();
    printf("=== done; sample_total above is CYCLES/sample on silicon ===\n");
}

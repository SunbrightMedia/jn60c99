/* t5_coef_audit.c -- WHICH OF DELAY TYPE 5's COEFFICIENTS ARE ZERO, AND ON
 * WHICH PATCHES.
 *
 * WHY. b19 proved O4's deficit is the DELAY stage on the four DELAY TYPE 5
 * patches: delay ratio 2.45x, 97 % of the excess, no overlap between the hot
 * five reports and the other seventy-nine.
 *
 * The engine already has a proven, gated technique for cutting arithmetic at
 * EXACTLY ZERO sonic cost: EB_ZEROCOEF. Where a coefficient is zero on every
 * patch, the multiply that consumes it is replaced by a literal 0.0f under
 * #if EB_ZEROCOEF, and the trunk null gate proves the output did not move.
 *
 * IT IS APPLIED TO SEVEN VOICE MODULES AND TO NO DELAY MODULE:
 *
 *     eb_dcoprep eb_glide eb_lfo eb_noise_svf eb_vca_hpf eb_vcf_cv eb_vcf_res
 *     eb_delay_t1  0        eb_delay_t23  0        eb_delay_t5  0
 *
 * The voice chain got the treatment. The master chain never did -- and the
 * master chain is now the whole deficit.
 *
 * WHAT THIS DECIDES, BEFORE ANY CODE IS WRITTEN. If few of t5's coefficients
 * are zero, EB_ZEROCOEF is the WRONG lever for it and this tool has saved the
 * work. Playbook 11b: measure first, and state the decision rule before
 * measuring.
 *
 *   DECISION RULE, WRITTEN FIRST:
 *     >= 20 always-zero float coefficients  -> EB_ZEROCOEF is worth applying
 *     <  20                                 -> look elsewhere (tap count,
 *                                              ring placement, CSE)
 *
 * HOW. The coefficient struct is scanned WORD-WISE rather than field by field.
 * A field list would have to be kept in step with a GENERATED header by hand,
 * and would rot silently. The two int32 ring-length words per pair are skipped
 * by name so a length of 0 is never read as a zero coefficient.
 *
 * usage: t5_coef_audit <bank>
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#include "juno_engine.h"
#include "juno_apply.h"
#include "juno_driver.h"
#include "eb_master_coefs.h"

#define NPATCH 64

static unsigned char *ST;
static eb_master_coef MC;

/* the four int32 ring-length words inside eb_dly5_coef, by VALUE-INDEPENDENT
 * identity: their offsets are taken from the struct itself, never guessed. */
static size_t LENOFF[4];

static int is_len_word(size_t off)
{
    int i;
    for (i = 0; i < 4; ++i) if (off == LENOFF[i]) return 1;
    return 0;
}

int main(int argc, char **argv)
{
    FILE *f;
    long bl;
    unsigned char *bank;
    int p, i, nw, always0 = 0, always1 = 0, t5only0 = 0;
    size_t base;
    /* per-word: how many patches read it as exactly 0.0f / 1.0f */
    static int z[sizeof(eb_dly5_coef) / 4];
    static int o[sizeof(eb_dly5_coef) / 4];
    static int zt5[sizeof(eb_dly5_coef) / 4];
    /* the bank's only DELAY TYPE 5 patches (b16 §2, read from record 650) */
    static const int T5[4] = { 5, 16, 21, 49 };

    if (argc < 2) { fprintf(stderr, "usage: %s <bank>\n", argv[0]); return 2; }

    LENOFF[0] = offsetof(eb_dly5_coef, k8594772);
    LENOFF[1] = offsetof(eb_dly5_coef, k10691940);
    LENOFF[2] = offsetof(eb_dly5_coef, k10726260);
    LENOFF[3] = offsetof(eb_dly5_coef, k10759044);

    f = fopen(argv[1], "rb");
    if (!f) { fprintf(stderr, "cannot open %s\n", argv[1]); return 2; }
    fseek(f, 0, SEEK_END); bl = ftell(f); fseek(f, 0, SEEK_SET);
    bank = (unsigned char *)malloc((size_t)bl);
    if (fread(bank, 1, (size_t)bl, f) != (size_t)bl) return 2;
    fclose(f);

    ST = (unsigned char *)malloc(JUNO_STATE_BYTES);
    nw = (int)(sizeof(eb_dly5_coef) / 4);
    base = offsetof(eb_master_coef, d5);

    for (p = 0; p < NPATCH; ++p) {
        int t5 = (p == T5[0] || p == T5[1] || p == T5[2] || p == T5[3]);
        const unsigned char *d5;
        memset(ST, 0, JUNO_STATE_BYTES);
        juno_chorus_init(ST);
        *(float *)(ST + 16) = 44100.0f;
        juno_engine_init(ST);
        juno_engine_prepare(ST);
        juno_bank_apply(ST, bank, p);
        juno_driver_seed_voices(ST);
        juno_apply_unison_spread(ST, juno_bank_assign(bank, p));
        juno_apply_condition(ST, juno_bank_condition(bank, p));
        juno_apply_lfo_tempo(ST, juno_bank_lfo_rate_byte(bank, p), 128.0f);
        memset(&MC, 0, sizeof MC);
        eb_master_coefs_build(ST, &MC);

        d5 = (const unsigned char *)&MC + base;
        for (i = 0; i < nw; ++i) {
            float v;
            if (is_len_word((size_t)i * 4)) continue;
            memcpy(&v, d5 + (size_t)i * 4, 4);
            /* EXACT bit test on the value, not a tolerance. A coefficient that
             * is 1e-30 is not zero and the multiply may not be deleted. */
            if (v == 0.0f) { ++z[i]; if (t5) ++zt5[i]; }
            if (v == 1.0f) ++o[i];
        }
    }

    for (i = 0; i < nw; ++i) {
        if (is_len_word((size_t)i * 4)) continue;
        if (z[i] == NPATCH) ++always0;
        if (o[i] == NPATCH) ++always1;
        if (zt5[i] == 4 && z[i] != NPATCH) ++t5only0;
    }

    printf("=== DELAY TYPE 5 COEFFICIENT AUDIT (all 64 factory patches) ===\n");
    printf("eb_dly5_coef: %d words, %d of them ring lengths (skipped)\n",
           nw, 4);
    printf("\n");
    printf("  ZERO on ALL 64 patches         : %d\n", always0);
    printf("  ONE  on ALL 64 patches         : %d\n", always1);
    printf("  zero on the four TYPE 5 patches\n");
    printf("     but NOT on all 64           : %d\n", t5only0);
    printf("\n");
    printf("DECISION RULE (written before the run): >=20 always-zero -> apply\n");
    printf("EB_ZEROCOEF to eb_delay_t5.c.  <20 -> the lever is elsewhere.\n");
    printf("\nVERDICT: %s\n",
           always0 >= 20 ? "APPLY EB_ZEROCOEF" : "LEVER IS ELSEWHERE");

    printf("\n--- the always-zero word offsets (byte offset within d5) ---\n");
    for (i = 0; i < nw; ++i) {
        if (is_len_word((size_t)i * 4)) continue;
        if (z[i] == NPATCH) printf("  +%zu\n", (size_t)i * 4);
    }
    return 0;
}

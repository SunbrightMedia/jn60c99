/* mc_zero_proof.c -- WHICH DELAY TYPE-5 COEFFICIENT SLOTS ARE STRUCTURALLY
 * ZERO?  The master-chain sibling of zero_proof.c, scoped to eb_dly5_coef.
 *
 * WHY IT EXISTS (2026-08-30): b20 counted "4 of 65 t5 coefficients always
 * zero" from a FACTORY-BANK-ONLY scan and killed EB_ZEROCOEF-on-t5 against a
 * >=20 rule -- correct for b20's 1,231-cycle deficit.  The deficit is now
 * 50-150 cycles/sample (T5PROBE/T5PROBE-128), so the lever revives, and the
 * factory scan is NOT sufficient evidence to delete anything: zero_proof.c's
 * preamble records why (one bank cannot separate "zero by construction" from
 * "zero in these presets").  This runs the same three widening stages over
 * the MASTER coefficients.
 *
 * Same blind spot as zero_proof.c, inherited deliberately: IT NEVER PLAYS A
 * NOTE.  The master chain takes no note/gate input, so the note-path axis is
 * far weaker here -- but the delay TIME SMOOTHER and mute fade are runtime
 * state, and a survivor here is a CANDIDATE whose port writer must still be
 * read before deletion.
 *
 * Stage counts print with the MOVED witness, same rule: a stage that moves
 * nothing is a broken stage, not a clean one.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "juno_engine.h"
#include "eb_master.h"
#include "eb_master_coefs.h"

static eb_master_coef MC;

/* d5's floats: everything up to the two trailing int32 ring lengths. */
/* 2026-08-30: widened from d5-only to the WHOLE master coef struct.
 * Int fields self-eliminate when nonzero; any int-typed "survivor" is
 * filtered at the naming step, never deleted. */
#define D5_NF ((int)(sizeof(eb_master_coef) / 4))

static unsigned char alive[4096];
static float lastv[4096];
static long  moved;

static void observe(void)
{
    const float *f = (const float *)&MC;
    int s;
    for (s = 0; s < D5_NF; ++s) {
        if (alive[s] && f[s] != 0.0f) alive[s] = 0;
        if (f[s] != lastv[s]) { lastv[s] = f[s]; ++moved; }
    }
}

static unsigned long rs = 12345u;
static unsigned rnd(void) { rs = rs * 1103515245u + 12345u; return (unsigned)((rs >> 16) & 0xFFFFu); }

static void settle(unsigned char *st, const unsigned char *bank, int p)
{
    juno_driver_seed_voices(st);
    juno_apply_condition(st, juno_bank_condition(bank, p));
    juno_apply_unison_spread(st, juno_bank_assign(bank, p));
    eb_master_coefs_build(st, &MC);
    observe();
}

int main(int argc, char **argv)
{
    static unsigned char bank[1 << 21];
    unsigned char *st;
    FILE *f;
    size_t n;
    int p, np, s, i, b, trial, rate = 44100, NPARAM;
    long stage2 = 0;

    if (argc < 2) { fprintf(stderr, "usage: mc_zero_proof <bank>\n"); return 2; }
    f = fopen(argv[1], "rb");
    if (!f) { perror(argv[1]); return 2; }
    n = fread(bank, 1, sizeof bank, f);
    fclose(f);
    st = malloc(JUNO_STATE_BYTES);
    np = juno_bank_num_patches(bank, (unsigned long)n);
    for (s = 0; s < D5_NF; ++s) alive[s] = 1;
    setvbuf(stdout, (char *)0, _IOLBF, 0);
    NPARAM = juno_param_count();
    printf("master coef 4-byte slots: %d   params: %d\n", D5_NF, NPARAM);

    for (p = 0; p < np; ++p) {
        memset(st, 0, JUNO_STATE_BYTES);
        juno_engine_init(st); juno_engine_prepare(st);
        juno_bank_apply(st, bank, p);
        settle(st, bank, p);
    }
    { int a = 0; for (s = 0; s < D5_NF; ++s) a += alive[s];
      printf("STAGE 1  %d patches -> %d of %d zero (moved %ld)\n", np, a, D5_NF, moved); moved = 0; }

    for (p = 0; p < np; p += (np / 4 > 0 ? np / 4 : 1)) {
        memset(st, 0, JUNO_STATE_BYTES);
        juno_engine_init(st); juno_engine_prepare(st);
        for (i = 0; i < NPARAM; ++i) {
            juno_bank_apply(st, bank, p);
            for (b = 0; b < 256; ++b) {
                juno_apply_param(st, i, b, rate);
                settle(st, bank, p);
                ++stage2;
            }
        }
    }
    { int a = 0; for (s = 0; s < D5_NF; ++s) a += alive[s];
      printf("STAGE 2  %ld sweeps -> %d of %d zero (moved %ld)\n", stage2, a, D5_NF, moved); moved = 0; }

    memset(st, 0, JUNO_STATE_BYTES);
    juno_engine_init(st); juno_engine_prepare(st);
    for (trial = 0; trial < 4000; ++trial) {
        juno_bank_apply(st, bank, (int)(rnd() % (unsigned)np));
        for (i = 0; i < NPARAM; ++i)
            juno_apply_param(st, i, (int)(rnd() & 0xFF), rate);
        juno_driver_seed_voices(st);
        juno_apply_condition(st, (int)(rnd() & 0xFF));
        juno_apply_unison_spread(st, (int)(rnd() % 3u));
        eb_master_coefs_build(st, &MC);
        observe();
    }
    { int a = 0; for (s = 0; s < D5_NF; ++s) a += alive[s];
      printf("STAGE 3  4000 random presets -> %d of %d zero (moved %ld)\n", a, D5_NF, moved);
      printf("SURVIVORS (4-byte slot index into eb_master_coef):");
      for (s = 0; s < D5_NF; ++s) if (alive[s]) printf(" %d", s);
      printf("\n"); }
    return 0;
}

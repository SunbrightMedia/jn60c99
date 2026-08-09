/* zero_proof.c — WHICH ENGINE B COEFFICIENT SLOTS ARE STRUCTURALLY ZERO?
 *
 * A coefficient that is always 0.0 costs a load and a multiply-add on every
 * sample of every voice, and deleting it is free. The catch is the standard
 * GOAL.md forbids taking the easy road on: "this byte is 0 in every factory
 * patch is not an excuse to skip it" -- recall must be correct for ANY
 * preset. So a bank measurement is a NECESSARY condition and nothing more.
 *
 * WHY THE EARLIER SCAN WAS NOT ENOUGH. /tmp/zeroscan.c read the FIRMWARE's
 * coefficient blob: ONE patch, across notes, gates and voices. It reported
 * "60+ always-zero slots". One patch cannot distinguish a slot that is zero
 * by construction from a slot that is zero because that patch happens not to
 * use it, and the difference is the whole question.
 *
 * WHAT THIS DOES INSTEAD, in three widening stages:
 *
 *   STAGE 1  all 64 factory patches x 8 voices. The necessary condition.
 *   STAGE 2  EVERY parameter in the BINDINGS table x EVERY byte 0..255,
 *            applied on top of each of several base patches. This is the
 *            single-parameter any-preset sweep: if a slot can be made
 *            nonzero by any one parameter at any value, it is not
 *            structurally zero and it dies here.
 *   STAGE 3  RANDOM PRESETS -- every parameter set to an independent random
 *            byte, many trials, plus a random CONDITION. Stage 2 cannot see a
 *            slot that is only nonzero when TWO parameters are both off their
 *            defaults; this can.
 *
 * A slot that survives all three is a CANDIDATE, not a proof. The remaining
 * step is to read the port's own writer for that cell and say why it can
 * never be nonzero. This program's job is to shrink the reading list from
 * "every coefficient" to "these", and -- more usefully -- to KILL the ones
 * that look zero and are not.
 *
 *   cc -O2 -std=c99 -ffp-contract=off -Isrc -Iengine_b -o zero_proof \
 *      tools/engineb/zero_proof.c <the port and engine_b objects>
 *   ./zero_proof truth/presetbankog1.bin
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "juno_apply.h"
#include "juno_engine.h"
#include "juno_driver.h"
#include "eb_render.h"
#include "eb_coefs.h"

#define MAXSLOT 512

typedef struct {
    const char *name;
    int         off;        /* byte offset of the sub-struct inside a voice   */
    int         nfloat;
} group;

/* The per-voice coefficient sub-structs, by name, with their float counts.
 * Offsets are taken with offsetof at run time below rather than written out,
 * so this cannot drift from the struct. */
static eb_render_coefs RC;

typedef struct { const char *name; int nf; const float *(*get)(int v); } grp;

static const float *g_env0(int v) { return (const float *)&RC.env[v][0]; }
static const float *g_env1(int v) { return (const float *)&RC.env[v][1]; }
static const float *g_modcv(int v){ return (const float *)&RC.mod[v]; }
static const float *g_vcfcv(int v){ return (const float *)&RC.cv[v]; }
static const float *g_vcf(int v)  { return (const float *)&RC.vcf[v]; }
static const float *g_vca(int v)  { return (const float *)&RC.vca[v]; }
static const float *g_dco(int v)  { return (const float *)&RC.dco[v]; }
static const float *g_decim(int v){ return (const float *)&RC.dec[v]; }
static const float *g_nsvf(int v) { return (const float *)&RC.nsv[v]; }
static const float *g_lfo(int v)  { return (const float *)&RC.lfo[v]; }
static const float *g_glide(int v){ return (const float *)&RC.glide[v]; }
static const float *g_nmix(int v) { return (const float *)&RC.nmix[v]; }
static const float *g_res(int v)  { return (const float *)&RC.res[v]; }
static const float *g_dprep(int v){ return (const float *)&RC.dprep[v]; }

static grp G[] = {
    { "env0",     sizeof(eb_env_coef)/4,        g_env0 },
    { "env1",     sizeof(eb_env_coef)/4,        g_env1 },
    { "modcv",    sizeof(eb_modcv_coef)/4,      g_modcv },
    { "vcf_cv",   sizeof(eb_vcf_cv_derived)/4,  g_vcfcv },
    { "vcf",      sizeof(eb_vcf_coef)/4,        g_vcf },
    { "vca",      sizeof(eb_vca_coef)/4,        g_vca },
    { "dco",      sizeof(eb_dco_coef)/4,        g_dco },
    { "decim",    sizeof(eb_decim_coef)/4,      g_decim },
    { "nsvf",     sizeof(eb_nsvf_coef)/4,       g_nsvf },
    { "lfo",      sizeof(eb_lfo_coef)/4,        g_lfo },
    { "glide",    sizeof(eb_glide_coef)/4,      g_glide },
    { "noisemix", sizeof(eb_noisemix_coef)/4,   g_nmix },
    { "vcf_res",  sizeof(eb_vcf_res_coef)/4,    g_res },
    { "dcoprep",  sizeof(eb_dcoprep_coef)/4,    g_dprep },
};
#define NG ((int)(sizeof G / sizeof G[0]))

static unsigned char alive[NG][MAXSLOT];    /* 1 = still believed always-zero */

/* A cheap deterministic generator. Math.random-style reproducibility matters
 * here: a survivor list nobody can regenerate is not evidence. */
static unsigned long rs = 12345u;
static unsigned rnd(void) { rs = rs * 1103515245u + 12345u; return (unsigned)((rs >> 16) & 0xFFFFu); }

static void observe(void)
{
    int g, v, s;
    for (g = 0; g < NG; ++g) {
        int nf = G[g].nf;
        if (nf > MAXSLOT) nf = MAXSLOT;
        for (v = 0; v < EB_NUM_VOICES; ++v) {
            const float *f = G[g].get(v);
            for (s = 0; s < nf; ++s)
                if (alive[g][s] && f[s] != 0.0f) alive[g][s] = 0;
        }
    }
}

static void settle(unsigned char *st, const unsigned char *bank, int p)
{
    /* The three calls that make the voices differ; dco_scatter.c records what
     * happens when they are omitted (eight copies of the power-on value, and
     * a probe that reports no spread at all). */
    juno_driver_seed_voices(st);
    juno_apply_condition(st, juno_bank_condition(bank, p));
    juno_apply_unison_spread(st, juno_bank_assign(bank, p));
    eb_render_coefs_build(st, &RC);
    observe();
}

int main(int argc, char **argv)
{
    static unsigned char bank[1 << 21];
    unsigned char *st;
    FILE *f;
    size_t n;
    int p, np, g, s, i, b, trial, total = 0, rate = 44100;
    int NPARAM = 0;
    long stage1 = 0, stage2 = 0, stage3 = 0;

    if (argc < 2) { fprintf(stderr, "usage: zero_proof <bank>\n"); return 2; }
    f = fopen(argv[1], "rb");
    if (!f) { perror(argv[1]); return 2; }
    n = fread(bank, 1, sizeof bank, f);
    fclose(f);
    st = malloc(JUNO_STATE_BYTES);
    np = juno_bank_num_patches(bank, (unsigned long)n);

    for (g = 0; g < NG; ++g)
        for (s = 0; s < MAXSLOT; ++s) alive[g][s] = 1;
    for (g = 0; g < NG; ++g) total += G[g].nf;

    /* how many parameters the BINDINGS table exposes: probe upward until the
     * setter refuses. juno_apply_param returns a negative value for an index
     * it does not own. */
    memset(st, 0, JUNO_STATE_BYTES);
    juno_engine_init(st); juno_engine_prepare(st);
    while (NPARAM < 4096 && juno_apply_param(st, NPARAM, 0, rate) >= -1e29f) ++NPARAM;

    /* ---- STAGE 1: the 64 factory patches ------------------------------- */
    for (p = 0; p < np; ++p) {
        memset(st, 0, JUNO_STATE_BYTES);
        juno_engine_init(st); juno_engine_prepare(st);
        juno_bank_apply(st, bank, p);
        settle(st, bank, p);
        ++stage1;
    }
    { int a = 0; for (g = 0; g < NG; ++g) for (s = 0; s < G[g].nf; ++s) a += alive[g][s];
      printf("STAGE 1  %d factory patches x %d voices          -> %d of %d slots still zero\n",
             np, EB_NUM_VOICES, a, total); }

    /* ---- STAGE 2: every parameter x every byte, on 4 base patches ------ */
    for (p = 0; p < np; p += (np / 4 > 0 ? np / 4 : 1)) {
        for (i = 0; i < NPARAM; ++i) {
            for (b = 0; b < 256; ++b) {
                memset(st, 0, JUNO_STATE_BYTES);
                juno_engine_init(st); juno_engine_prepare(st);
                juno_bank_apply(st, bank, p);
                juno_apply_param(st, i, b, rate);
                settle(st, bank, p);
                ++stage2;
            }
        }
    }
    { int a = 0; for (g = 0; g < NG; ++g) for (s = 0; s < G[g].nf; ++s) a += alive[g][s];
      printf("STAGE 2  %ld single-parameter sweeps               -> %d of %d slots still zero\n",
             stage2, a, total); }

    /* ---- STAGE 3: random presets, every parameter at once --------------- */
    for (trial = 0; trial < 4000; ++trial) {
        memset(st, 0, JUNO_STATE_BYTES);
        juno_engine_init(st); juno_engine_prepare(st);
        juno_bank_apply(st, bank, (int)(rnd() % (unsigned)np));
        for (i = 0; i < NPARAM; ++i)
            juno_apply_param(st, i, (int)(rnd() & 0xFF), rate);
        juno_driver_seed_voices(st);
        juno_apply_condition(st, (int)(rnd() & 0xFF));
        juno_apply_unison_spread(st, (int)(rnd() % 3u));
        eb_render_coefs_build(st, &RC);
        observe();
        ++stage3;
    }
    { int a = 0; for (g = 0; g < NG; ++g) for (s = 0; s < G[g].nf; ++s) a += alive[g][s];
      printf("STAGE 3  %ld random presets (all parameters)       -> %d of %d slots still zero\n",
             stage3, a, total); }

    printf("\nSURVIVORS -- candidates for a structural proof, NOT proofs:\n");
    for (g = 0; g < NG; ++g) {
        int any = 0;
        for (s = 0; s < G[g].nf; ++s) if (alive[g][s]) {
            if (!any) { printf("  %-10s (%2d floats):", G[g].name, G[g].nf); any = 1; }
            printf(" %d", s);
        }
        if (any) printf("\n");
    }
    return 0;
}

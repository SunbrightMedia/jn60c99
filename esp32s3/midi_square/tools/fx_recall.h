/* fx_recall.h -- the proven recall driver shared by fxgen.c and fx_gate.c
 * (patchbank.c order: juno_bank_apply -> seed voices -> unison spread ->
 * condition -> lfo tempo -> eb_render_coefs_build -> eb_master_coefs_build). */
#include "juno_engine.h"
#include "juno_apply.h"
#include "juno_driver.h"
#include "eb_coefs.h"
#include "eb_master_coefs.h"
#define BANK_HEADER 23
#define BANK_STRIDE 20223
#ifndef TYPE_CHO
#define TYPE_CHO 3              /* 2 = JUNO CHORUS 1, 3 = JUNO CHORUS 2 (truth/Script.xml) */
#endif
#define R_EFX_DEPTH 116
#define R_REV_LEVEL 118
#define R_EFX_TYPE  634
#define R_EFX_TONE  642
#define R_DLY_TYPE  650
#define R_REV_TYPE  658

static unsigned char *ST, *BANK;
static eb_render_coefs RC;

static void boot(int rate)
{
    memset(ST, 0, JUNO_STATE_BYTES);
    juno_chorus_init(ST);
    JF(ST, 16) = (float)rate;
    juno_engine_init(ST);
    juno_engine_prepare(ST);
}

static void recall(int idx, eb_master_coef *mc, eb_master_state *ms)
{
    juno_bank_apply(ST, BANK, idx);
    juno_driver_seed_voices(ST);
    juno_apply_unison_spread(ST, juno_bank_assign(BANK, idx));
    juno_apply_condition(ST, juno_bank_condition(BANK, idx));
    juno_apply_lfo_tempo(ST, juno_bank_lfo_rate_byte(BANK, idx), 128.0f);
    eb_render_coefs_build(ST, &RC);
    eb_master_coefs_build(ST, mc);
    if (ms) eb_master_state_seed(ST, ms);
}

static unsigned char *rec(int idx) { return BANK + BANK_HEADER + (size_t)idx * BANK_STRIDE; }
static int  getp(int idx, int roff) { unsigned char *r = rec(idx); return ((r[roff] & 0xF) << 4) | (r[roff + 1] & 0xF); }
static void setp(int idx, int roff, int v) { unsigned char *r = rec(idx); r[roff] = (unsigned char)((r[roff] & 0xF0) | (v >> 4)); r[roff + 1] = (unsigned char)((r[roff + 1] & 0xF0) | (v & 0xF)); }


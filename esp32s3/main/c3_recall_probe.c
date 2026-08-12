/* c3_recall_probe.c -- TEMPORARY, SCOUT 1 MEASUREMENT ONLY. Delete after.
 *
 * Its only job is to REFERENCE every recall entry point so --gc-sections
 * cannot strip the closure, and so `idf.py size` prices the real thing
 * instead of an empty set.
 *
 * It allocates ONLY what recall genuinely adds: the SHADOW coefficient bank.
 * RS/MS/RC/MC already exist in juno_s3_listen.c (RC/MC internal .bss, RS/MS
 * heap_caps_malloc'd into PSRAM), so declaring fresh ones here would have
 * charged recall 1,466,740 bytes it does not need -- which is exactly what
 * the first version of this file did, and the link said
 * `dram0_0_seg overflowed by 1602368 bytes`.
 */
#include <stdint.h>
#include "juno_engine.h"
#include "juno_apply.h"
#include "juno_note.h"
#include "eb_coefs.h"
#include "eb_master_coefs.h"
#include "ebdev.h"
#include "eb_recall.h"

static eb_render_coefs SHADOW_RC;      /* the double buffer recall needs */
static eb_master_coef  SHADOW_MC;
static eb_recall       REC;

int c3_recall_probe(const unsigned char *bank, int p,
                    eb_render_coefs *rc, eb_master_coef *mc,
                    eb_render_state *rs, eb_master_state *ms,
                    const eb_engine *eng);
int c3_recall_probe(const unsigned char *bank, int p,
                    eb_render_coefs *rc, eb_master_coef *mc,
                    eb_render_state *rs, eb_master_state *ms,
                    const eb_engine *eng)
{
    juno_bank_apply((unsigned char *)0, bank, p);
    ebdev_broadcast_scatter();
    juno_apply_unison_spread((unsigned char *)0, juno_bank_assign(bank, p));
    juno_apply_condition((unsigned char *)0, juno_bank_condition(bank, p));
    juno_apply_lfo_tempo((unsigned char *)0, juno_bank_lfo_rate_byte(bank, p),
                         128.0f);
    juno_note_on((unsigned char *)0, 0, 60, 100);
    juno_note_off((unsigned char *)0, 0);
    eb_recall_init(&REC, rc, &SHADOW_RC, mc, &SHADOW_MC, rs, ms, eng);
    eb_recall_build(&REC);
    (void)eb_recall_publish(&REC);
    eb_recall_block_boundary(&REC);
    eb_render_state_seed((const unsigned char *)0, rs);
    eb_master_state_seed((const unsigned char *)0, ms);
    eb_render_events_mirror((unsigned char *)0, rs);
    return (int)REC.gen;
}

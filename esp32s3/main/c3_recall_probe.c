/* c3_recall_probe.c -- TEMPORARY, SCOUT 1 MEASUREMENT ONLY. Delete after.
 *
 * Its only job is to REFERENCE every recall entry point so --gc-sections
 * cannot strip the closure, and so `idf.py size` prices the real thing
 * instead of an empty set. It is kept out of the shipping build by not
 * being listed in CMakeLists.txt.
 */
#include <stdint.h>
#include "juno_engine.h"
#include "juno_apply.h"
#include "juno_note.h"
#include "eb_coefs.h"
#include "eb_master_coefs.h"
#include "ebdev.h"
#include "eb_recall.h"

static eb_render_coefs RC0, RC1;
static eb_master_coef  MC0, MC1;
static eb_render_state RS;
static eb_master_state MS;
static eb_engine       ENG;
static eb_recall       REC;

int c3_recall_probe(const unsigned char *bank, int p);
int c3_recall_probe(const unsigned char *bank, int p)
{
    juno_bank_apply((unsigned char *)0, bank, p);
    ebdev_broadcast_scatter();
    juno_apply_unison_spread((unsigned char *)0, juno_bank_assign(bank, p));
    juno_apply_condition((unsigned char *)0, juno_bank_condition(bank, p));
    juno_apply_lfo_tempo((unsigned char *)0, juno_bank_lfo_rate_byte(bank, p),
                         128.0f);
    juno_note_on((unsigned char *)0, 0, 60, 100);
    juno_note_off((unsigned char *)0, 0);
    eb_recall_init(&REC, &RC0, &RC1, &MC0, &MC1, &RS, &MS, &ENG);
    eb_recall_build(&REC);
    (void)eb_recall_publish(&REC);
    eb_recall_block_boundary(&REC);
    eb_render_state_seed((const unsigned char *)0, &RS);
    eb_master_state_seed((const unsigned char *)0, &MS);
    eb_render_events_mirror((unsigned char *)0, &RS);
    return (int)REC.gen;
}

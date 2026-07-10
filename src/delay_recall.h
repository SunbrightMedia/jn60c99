/* delay_recall.h — per-patch DELAY effect recall for the slot-1 (v39) effect.
 *
 * The Cloud 60 master runs two effect slots in series (see src/master_render.c):
 *   v39  = *(int*)(state + JUNO_PROG_DLY)  selects slot-1 algorithm (DELAY TYPE)
 *   v551 = *(int*)(state + JUNO_PROG_EFX)  selects slot-2 algorithm (EFFECT TYPE)
 * When v39 == 0 the slot routes the DELAY block at engine offset 102xxx. This
 * module recalls that block per-patch from the bank record, using coefficient
 * mappings taken bit-for-bit from the plugin's own value-tree dispatch (the
 * Unicorn oracle, tools/gen_delay_overlay.py). See src/delay_recall.c.
 */
#ifndef JUNO_DELAY_RECALL_H
#define JUNO_DELAY_RECALL_H

/* Engine cells holding the two effect-slot program selectors (int32). The master
 * reads them through the host-params pointer chase off state+136. */
#define JUNO_PROG_DLY  11022056   /* v39  — DELAY TYPE (slot 1) */
#define JUNO_PROG_EFX  11022060   /* v551 — EFFECT TYPE (slot 2) */

/* Apply the per-patch delay recall for one bank record (`rec` points at the start
 * of the 20223-byte patch record, i.e. bank + header + idx*stride). Writes the
 * DELAY TYPE selector to state[JUNO_PROG_DLY] and, when DELAY TYPE == 0, fills the
 * slot-1 delay coefficient block (102xxx). Leaves the block untouched otherwise. */
void juno_apply_delay(unsigned char *state, const unsigned char *rec);

#endif /* JUNO_DELAY_RECALL_H */

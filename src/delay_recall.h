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

/* Engine cells holding the two effect-slot program selectors (int32) — the
 * plugin's OWN cells (setter-proven: the DELAY/EFFECT TYPE setters write
 * clamp(v,<=5) to exactly these offsets for all 256 values; ext_sweeps.py).
 * The master reads them through the host-params pointer chase off state+136. */
#define JUNO_PROG_DLY  11022056   /* v39  — DELAY TYPE (slot 1), power-on 0  */
#define JUNO_PROG_EFX  11022052   /* v551 — EFFECT TYPE (slot 2), power-on 2 */

/* Apply the per-patch delay recall for one bank record (`rec` points at the start
 * of the 20223-byte patch record, i.e. bank + header + idx*stride). Writes the
 * DELAY TYPE selector to state[JUNO_PROG_DLY] and, when DELAY TYPE == 0, fills the
 * slot-1 delay coefficient block (102xxx). Leaves the block untouched otherwise. */
void juno_apply_delay(unsigned char *state, const unsigned char *rec);

/* The tempo entry's delay half (leaf 375, EXECUTED census): the active delay
 * TYPE's time cell (0: 102352, 1: 4297584, 5: 6497168) at the engine's stored
 * tempo (juno_rr_tempo); the float-BPM form rounds, stores and applies. */
void juno_apply_delay_tempo_t10(unsigned char *state, int time_byte, int sync, int dtype);
void juno_apply_delay_tempo(unsigned char *state, int time_byte, int sync,
                            int dtype, float bpm);
void juno_live_delay_sync(unsigned char *state, int time_byte, int sync,
                          int dtype); /* live blob-59 flip: instance cell only, stored tempo */

/* The slot-1 block switch value at host rate Hr: on = the ARM_LFX1 class, off =
 * ARM_LFX1_OFF (src/delay_recall.c). Used by the recall ramps (src/recall_ramp.c). */
float juno_lfx1_value(int Hr, int on);

#endif /* JUNO_DELAY_RECALL_H */

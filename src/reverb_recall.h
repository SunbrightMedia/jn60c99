/* reverb_recall.h — per-patch global REVERB recall.
 *
 * The Cloud 60 reverb is a GLOBAL send in the master output stage (master_render.c),
 * always active. Three per-patch quantities are recalled from the plugin's own
 * value-tree dispatch (setter-hooked under Unicorn):
 *   REVERB LEVEL (front-panel blob 51) -> engine 10759408  (send/wet level, idx 795)
 *   REVERB TYPE  (record byte 658, 0..5) -> 4 DPF cutoffs (10759648/696/744/792),
 *       the type-5-only stage (10759488), and jointly with TIME the 8 Hp/Lp coeffs (idx 876)
 *   REVERB TIME  (record byte 666) -> the 8 Hp/Lp DPF decay coeffs, JOINT with TYPE (idx 877)
 * See src/reverb_recall.c and scratchpad/oracle/reverb_validation_findings.md.
 */
#ifndef JUNO_REVERB_RECALL_H
#define JUNO_REVERB_RECALL_H
void juno_apply_reverb(unsigned char *state, const unsigned char *rec);

/* Write the 34-int reverb tap-index table (11022208..11022340) for REVERB TYPE
 * `type` (0, 1, or default 2..5) at host rate Hr. The plugin's own REVERB TYPE
 * dispatch output, verbatim (see reverb_recall.c). Used by juno_apply_reverb per
 * patch and by juno_engine_prepare to seed the build default (type 2). This is the
 * PRE-DELAY-default (byte 20) form; equivalent to juno_write_reverb_taps_pd(...,20). */
void juno_write_reverb_taps(unsigned char *state, int type, int Hr);

/* REVERB PRE DELAY (idx 1323, record byte 3947, int1x7, range 0..100). The plugin's
 * PRE DELAY setter shifts the whole reverb tap array uniformly by the pre-delay in
 * samples. Closed form (executed, W1: tools/verify/reverb_predelay_derive.py, exact
 * over every byte x 4 rates x 3 TYPE classes): predelay = max((pd_byte*Hr)/1000-2, 0).
 * juno_write_reverb_taps_pd writes the taps with the pre-delay shift (identity at
 * byte 20 == juno_write_reverb_taps); the master reverb predelay cell 10759360 is
 * (float)predelay, written by juno_apply_reverb. */
int  juno_reverb_predelay(int pd_byte, int Hr);
void juno_write_reverb_taps_pd(unsigned char *state, int type, int Hr, int pd_byte);
#endif

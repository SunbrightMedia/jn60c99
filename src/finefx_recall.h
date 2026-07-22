/* finefx_recall.h — per-patch "fine-FX" filter recall (the leaves the plugin's
 * value-tree recall ENUMERATOR (0x3B48A0) does NOT fire, but a real host's
 * preset-load DOES apply via the controller path). See finefx_recall.c. */
#ifndef JUNO_FINEFX_RECALL_H
#define JUNO_FINEFX_RECALL_H

/* Apply the DELAY fine-FX filter params (HIGH CUT / LF+HF DAMP / LF+HF DAMP FREQ)
 * for a DELAY TYPE-0 patch: overwrites the delay slot-1 high-cut/damp coefficient
 * cells (102368..102672) with the per-byte law the plugin's own setter produces.
 * `rec` = patch record start; `Hr` = host sample rate (for the two rate-armed
 * cells). Reduces to delay_recall.c's frozen FILT[]/put_rate defaults at the
 * default byte, so it is a no-op for default-fine-FX patches. */
void juno_apply_delay_finefx(unsigned char *state, const unsigned char *rec, int Hr);

#endif

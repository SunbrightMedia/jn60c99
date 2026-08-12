/* chorus_recall.h — per-patch JUNO-60 chorus level recall. */
#ifndef CHORUS_RECALL_H
#define CHORUS_RECALL_H

/* Apply the per-patch chorus levels for one bank record (`rec` = record start).
 * Writes the master's slot-2 chorus block from EFFECT DEPTH / EFFECT TONE /
 * EFFECT TYPE. Bit-exact vs the plugin's value-tree dispatch (see
 * docs/CHORUS_RECALL.md). Call after juno_apply_delay / juno_apply_reverb. */
void juno_apply_chorus(unsigned char *state, const unsigned char *rec);

#endif /* CHORUS_RECALL_H */

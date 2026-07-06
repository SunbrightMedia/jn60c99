/* reverb_recall.h — per-patch global REVERB recall.
 *
 * The Cloud 60 reverb is a GLOBAL send in the master output stage (LABEL_105 of
 * src/master_render.c), always active, scaled per-patch by REVERB LEVEL. The
 * value-tree oracle (a second harness that constructs the real CJu60Sim effect
 * engine and reads the .rdata-bound param descriptors) resolved the reverb param
 * -> engine coefficient bindings:
 *   REVERB LEVEL (front-panel blob 51) -> engine offset 10759408  (send/wet level)
 *   REVERB TIME  (record 666)          -> engine offset 10759680  (decay feedback)
 * Each recall value is the plugin's own value-tree curve output (captured by
 * hooking the effect param setter). See src/reverb_recall.c.
 */
#ifndef JUNO_REVERB_RECALL_H
#define JUNO_REVERB_RECALL_H
void juno_apply_reverb(unsigned char *state, const unsigned char *rec);
#endif

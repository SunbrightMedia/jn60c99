/* eb_param_class.h -- GENERATED. DO NOT EDIT BY HAND.
 *
 * WHICH SUB-BUILDERS A PARAMETER EDIT MUST RE-RUN.
 *
 * O3's whole saving. A knob move rebuilds only the pieces its parameter can
 * actually reach -- the voices in `vmask8`, the shared FX/noise tail if
 * `tail`, the master set if `master` -- and the shadow copy carries the rest.
 * MEASURED (docs/engineb/data/b13_param_map.md): the median parameter moves
 * 32 of 12,276 coefficient bytes, so a full rebuild is ~380x the work the edit
 * needs.
 *
 * DERIVED, NOT WRITTEN. tools/engineb/devboot/paramclass_gate.c perturbs every
 * parameter over 13 base patches, sees which regions of the coefficient
 * structs move -- per-voice regions from what eb_coefs_voice(v) itself writes
 * under two fills, the tail from what is left, the master from its own struct
 * -- and emits this file. It then HOLDS the result: pre-edit coefficients plus
 * only these builders == a full rebuild, byte for byte, over all 59
 * parameters. Three teeth, all caught, including C9's own ("a parameter whose
 * map is short by one field must produce a coefficient set that differs").
 *
 * ⚠ REGENERATE, NEVER PATCH. tools/engineb/paramclass_gate.py re-derives this
 * file every run and FAILS if the checked-in copy differs. A hand-edited row
 * is a stale coefficient waiting to ship, and it is exactly the failure mode
 * this project has paid for most: wrong sound, no error.
 *
 * ⚠ ITEM-7. `rec` is a RECORD OFFSET, which is this synth's business; the
 * INDEX into this table is the portable `param_id` the event API carries
 * (event/juno_event.h: "param_id is an INDEX INTO A PER-SYNTH TABLE, never a
 * JUNO constant"). A port swaps this file and keeps everything else.
 */
#ifndef EB_PARAM_CLASS_H
#define EB_PARAM_CLASS_H

typedef struct {
    short         rec;      /* record offset of the parameter's HIGH nibble */
    unsigned char vmask8;   /* voices to rebuild, bit v = voice v (8-voice) */
    unsigned char tail;     /* re-run eb_render_coefs_build_shared */
    unsigned char master;   /* re-run eb_master_coefs_build */
} eb_param_class;

static const eb_param_class EB_PARAM_CLASS[] = {
    { 30, 0xffu, 0, 0 },
    { 32, 0xffu, 0, 0 },
    { 34, 0xffu, 0, 0 },
    { 36, 0xffu, 0, 0 },
    { 40, 0xffu, 0, 0 },
    { 44, 0xffu, 0, 0 },
    { 46, 0xffu, 0, 0 },
    { 48, 0xffu, 0, 0 },
    { 68, 0xffu, 0, 0 },
    { 70, 0xffu, 0, 0 },
    { 72, 0xffu, 0, 0 },
    { 74, 0xffu, 0, 0 },
    { 86, 0xffu, 0, 0 },
    { 90, 0xffu, 0, 0 },
    { 92, 0xffu, 0, 0 },
    { 94, 0xffu, 0, 0 },
    { 96, 0xffu, 0, 0 },
    { 98, 0xffu, 0, 0 },
    { 100, 0xffu, 0, 0 },
    { 102, 0xffu, 0, 0 },
    { 104, 0xffu, 0, 0 },
    { 106, 0xffu, 0, 0 },
    { 108, 0xffu, 0, 0 },
    { 110, 0xffu, 0, 0 },
    { 112, 0xffu, 0, 0 },
    { 114, 0xffu, 0, 0 },
    { 116, 0x00u, 1, 1 },
    { 118, 0x00u, 1, 1 },
    { 120, 0x00u, 1, 1 },
    { 122, 0x00u, 1, 1 },
    { 124, 0xffu, 0, 0 },
    { 128, 0xfeu, 0, 0 },
    { 134, 0xffu, 1, 1 },
    { 148, 0x00u, 0, 1 },
    { 490, 0xffu, 0, 0 },
    { 498, 0xffu, 0, 0 },
    { 530, 0xffu, 0, 0 },
    { 538, 0xffu, 0, 0 },
    { 554, 0xffu, 0, 0 },
    { 618, 0xffu, 0, 0 },
    { 634, 0x00u, 1, 1 },
    { 642, 0x00u, 1, 1 },
    { 650, 0x00u, 1, 1 },
    { 658, 0x00u, 1, 1 },
    { 666, 0x00u, 1, 1 },
    { 1868, 0xffu, 0, 0 },
    { 2102, 0xffu, 0, 0 },
    { 3056, 0x00u, 1, 1 },
    { 3058, 0x00u, 1, 1 },
    { 3060, 0x00u, 1, 1 },
    { 3068, 0x00u, 1, 1 },
    { 3076, 0x00u, 1, 1 },
    { 3084, 0x00u, 1, 1 },
    { 3092, 0x00u, 1, 1 },
    { 3286, 0x00u, 0, 1 },
    { 3288, 0x00u, 0, 1 },
    { 3948, 0x00u, 1, 1 },
    { 3950, 0x00u, 1, 1 },
    { 3952, 0x00u, 1, 1 },
};

#define EB_PARAM_CLASS_N 59

/* param_id -> class. Returns 0 for an id the table does not carry, which the
 * caller MUST treat as "refuse and count", never as "rebuild nothing": a
 * parameter the map does not know is a knob whose effect would silently not
 * happen (playbook 32). */
static const eb_param_class *eb_param_class_of(int param_id)
{
    if (param_id < 0 || param_id >= EB_PARAM_CLASS_N) return 0;
    return &EB_PARAM_CLASS[param_id];
}

#endif /* EB_PARAM_CLASS_H */

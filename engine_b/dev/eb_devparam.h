/* eb_devparam.h -- THE WARM PARAMETER EDIT, THE PLUGIN'S OWN WAY.
 *
 * WHY THIS FILE EXISTS. A live knob move is NOT a patch recall. The plugin
 * proves this: gui/juno_bridge.c's juno_gui_set_param calls
 * juno_apply_param_leaf (src/juno_apply.c) -- it writes the edited leaf's
 * cell(s) and broadcasts ONLY that leaf's scatter cell; it never re-seeds
 * voices and never touches per-voice NOTE state (gate/pitch/velocity). The
 * device used to answer every knob move with eb_devseq_recall -- a FULL patch
 * recall whose juno_driver_seed_voices broadcasts voice 0's note-carrying
 * scatter cells onto every voice. With voice 0 released, that gated every
 * voice: the storm's stuck note (b45; PROVEN on host, scratchpad probe: a warm
 * seed_voices moves 22 note cells, a leaf edit moves 0).
 *
 * THE RULE, in ONE place so the firmware and the gate cannot drift:
 *   1. A parameter that HAS a value-tree leaf (a BINDINGS row) is applied by
 *      juno_apply_param_leaf -- the plugin's exact live edit. 26 of the 59
 *      device parameters are leaves: every continuous tonal knob a keybed or
 *      panel drives (VCF, ENV1/2, DCO levels, LFO, PORTAMENTO, TONE, LEVEL).
 *   2. A parameter with NO leaf (a discrete switch, or an FX/master byte) has
 *      no per-cell plugin setter; it is re-derived from the record by
 *      juno_bank_apply's own laws. That path DOES re-seed, so its note state
 *      is preserved across it -- which is exactly the plugin's invariant for a
 *      knob move (note state unchanged), reached a different way.
 *
 * eb_devparam_leaf_index maps the portable param_id (index into
 * EB_PARAM_CLASS) to the BINDINGS row juno_apply_param_leaf wants, or -1 for a
 * non-leaf. The record offset -> front-panel blob_pos relation is
 * blob_pos = (rec - EB_BANK_BLOB_OFF) / 2 (the record packs each panel byte as
 * two nibbles; PROVEN: all 59 recs are even and every leaf name resolves).
 *
 * EB_DEVPARAM_NOTE_CELLS are the five per-voice scatter cells juno_note_*
 * writes (pitch 304, gate 320, VCF vel 6864, VCA vel 9680, 9824). They are the
 * note state a warm edit must never disturb.
 */
#ifndef EB_DEVPARAM_H
#define EB_DEVPARAM_H

#include "eb_param_class.h"
#include "eb_patch.h"       /* EB_BANK_BLOB_OFF */
#include "juno_apply.h"     /* juno_param_count / juno_param_blob / _leaf */

/* the five note-state scatter cells (see header comment) */
#define EB_DEVPARAM_NNOTE 5
static const unsigned EB_DEVPARAM_NOTE_CELLS[EB_DEVPARAM_NNOTE] = {
    304u, 320u, 6864u, 9680u, 9824u
};

/* param_id -> BINDINGS row for juno_apply_param_leaf, or -1 for a non-leaf. */
static int eb_devparam_leaf_index(int param_id)
{
    const eb_param_class *cl = eb_param_class_of(param_id);
    int blob, i, n;
    if (!cl) return -1;
    blob = ((int)cl->rec - EB_BANK_BLOB_OFF) / 2;
    n = juno_param_count();
    for (i = 0; i < n; ++i)
        if (juno_param_blob(i) == blob) return i;
    return -1;
}

#endif /* EB_DEVPARAM_H */

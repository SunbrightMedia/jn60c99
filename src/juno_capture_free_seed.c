/* juno_capture_free_seed.c — the single binary-sourced replacement for the
 * "PD The Juno Pad" memory capture (juno_runtime_coeffs_apply, src/runtime_coeffs_data.c).
 *
 * It assembles the engine's parameter-applied coefficient state from transcribed
 * code + .rdata constants ONLY — no captured numbers:
 *
 *   1. juno_construction_defaults  — sub_3A66B0: zero every param value-slot,
 *                                    set the 16 "PlugIn Sw" to 1.0.
 *   2. juno_registration_defaults  — sub_388170 registrar: 4 .rdata value-defaults
 *                                    (incl. the AMP FIX level that keeps the amp
 *                                    chain non-silent) + 17 switch "on" defaults.
 *   3. juno_voice_constants        — the Mod/Vel/Bend Sens framework defaults +
 *                                    master M.CV slot (LUT outputs = .rdata literals).
 *   4. juno_fx_filter_coeffs_apply — 98 shared FX filter templates from .rdata.
 *   5. juno_reverb_coeffs_apply    — 48 HALL2 reverb coeffs from .rdata.
 *
 * Call in place of juno_runtime_coeffs_apply, after juno_chorus_init +
 * juno_engine_init and BEFORE juno_preset_load (which then overlays the per-preset
 * panel params). The per-note velocity/CV targets are produced by the note-on path
 * (juno_note_on); the JUNO-60 is not velocity-sensitive, so those targets feed an
 * inert multiply and do not colour the sound.
 *
 * This reproduces the engine's coefficient state for ANY factory preset (the
 * capture only ever reproduced the one pad it was taken from). It is general and
 * capture-free; it is not bit-identical to that single pad's capture (~1% RMS on a
 * full render) because a handful of slots that ride the framework default cannot
 * yet round-trip a non-default decode position — see juno_voice_constants.c.
 */
#include "juno_engine.h"

void juno_master_gate_set(int ready);

void juno_capture_free_seed(unsigned char *st)
{
    juno_construction_defaults(st);
    juno_registration_defaults(st);
    juno_voice_constants(st);
    juno_fx_filter_coeffs_apply(st);
    juno_reverb_coeffs_apply(st);
    juno_master_gate_set(1);   /* master/chorus coefficients are now present */
}

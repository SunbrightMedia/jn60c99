/* juno_note.h — faithful offline note driver for the JUNO-60 C99 port.
 *
 * Reproduces the plugin's note-on / gate / pitch / DCO-retrigger control surface on
 * top of the ported per-sample DSP (juno_voice_render). A note event writes three
 * per-voice parameters, all flagged en=0 (IMMEDIATE) in the binary's descriptor
 * table (docs/param_routing.json): M.CV (pitch, off 304), M.Gate (gate, off 320),
 * and the aux DCO-retrigger latch (off 101504 + voice*32). See src/juno_note.c for
 * the full binary-derived derivation and docs/CONTROL_LAYER_PORT.md.
 *
 * PITCH: state[voiceBase+304] = midi_note/12.0 (octave units). The DCO sums it with
 * the FIXED tune state[voiceBase+4448] = -4.75 that init writes, giving
 * 220*2^((note-57)/12) = concert pitch. The note path must NOT write state[4448].
 *
 * GATE: the shared binary gate state[560] is 1 iff state[320] > 0 (the twin glide
 * conditioner is frozen, state[240]*state[272]==0, so v29==state[320]). M.Gate is
 * an IMMEDIATE parameter, so note-on writes state[320] = 1.0 directly (gate opens,
 * both ADSRs attack) and note-off writes 0.0 (both ADSRs release) — no host-side
 * ramp. The gate is binary; state[320]'s positive magnitude is audio-irrelevant.
 */
#ifndef JUNO_NOTE_H
#define JUNO_NOTE_H

#ifdef __cplusplus
extern "C" {
#endif

/* Trigger a note on `voice` (0..7). `midi_note` is a standard MIDI note number
 * (60 = middle C); `velocity` 1..127 (0 == note-off). Writes M.CV (pitch), M.Gate
 * (opens the gate, immediate), and the one-shot DCO retrigger latch. */
void juno_note_on(unsigned char *st, int voice, int midi_note, int velocity);

/* Release `voice`: writes M.Gate = 0 (immediate) so both ADSRs enter release. */
void juno_note_off(unsigned char *st, int voice);

/* Glide `voice` to `midi_note`: writes M.CV (pitch) ONLY — no gate edge, no DCO
 * retrigger latch, no velocity. This is the assigner's legato / portamento move
 * (CAssignJu60 sets NOTE CV param 433+v without touching the gate, so the ADSRs
 * keep running — see docs, mono/unison legato + poly-portamento-glide). */
void juno_note_glide(unsigned char *st, int voice, int midi_note);

/* Per-voice PORTAMENTO GATE (note-bus leaf 467+v): off!=0 zeroes voice v's glide
 * gate 592 (bypassing the DCO glide conditioner) and its twin 9824; off==0 puts
 * 592 back to `porta_base` (the recalled PORTAMENTO on/off) and still zeroes 9824.
 * Written by the POLY allocator's LEGATO arm. See the comment in juno_note.c. */
void juno_note_porta_gate(unsigned char *st, int voice, int off, float porta_base);

/* Refresh velocity coeffs (VCF/VCA) without a gate edge — MONO legato / UNISON glide
 * overlaps with a changed velocity. Verified vs CAssignJu60 under emulation. */
void juno_note_velocity(unsigned char *st, int voice, int velocity);

/* Broadcast the global "any key held" flag (cell 1856) to ALL voices; the plugin
 * maintains it on every assigner-level note-on/note-off transition. */
void juno_note_broadcast_held(unsigned char *st, int any_held);

/* No-op: the gate is now an immediate write with no host-side ramp to advance.
 * Retained for API/source compatibility (callers tick it once per sample). */
void juno_note_tick(unsigned char *st);

/* Map a MIDI note to the per-voice DCO pitch value written to state[304] (octave
 * units, one unit == one octave; = midi_note/12). Exposed for tests/diagnostics. */
float juno_note_pitch(int midi_note);

#ifdef __cplusplus
}
#endif
#endif /* JUNO_NOTE_H */

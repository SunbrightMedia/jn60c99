/* juno_note.h — faithful offline note driver for the JUNO-60 C99 port.
 *
 * Reproduces the plugin's note-on / gate / pitch / ADSR-trigger control layer on
 * top of the ported per-sample DSP (juno_voice_render) and the ported ramp engine
 * (juno_ramp.c). Drives one (or more) of the 8 voices: sets the per-voice DCO
 * note pitch, opens the shared envelope gate, and fires the one-shot DCO
 * retrigger edge; note-off closes the gate so both ADSRs enter release.
 *
 * PITCH: the per-voice note pitch is state[voiceBase+304] = midi_note/12.0 (octave
 * units). The DCO sums it with the FIXED tune state[voiceBase+4448] = -4.75 that
 * init writes, giving 220*2^((note-57)/12) = concert pitch. (state[304] is the
 * frozen portamento conditioner input; state[240]*state[272]==0 so it passes to
 * the DCO instantly.) The note path must NOT write state[4448].
 *
 * GATE: the shared binary gate state[560] is 1 iff the twin conditioner output
 * v29 = state[272]*state[240]*(state[208]-state[320])+state[320] is nonzero and
 * >= -state[544]. Since state[240]*state[272]==0 (never set), v29==state[320], so
 * we ramp state[320] 0->positive on note-on (gate opens, both ADSRs attack) and
 * ->0 on note-off (both ADSRs release) — the plugin's own gate write. The gate is
 * binary; state[320]'s magnitude is audio-irrelevant (state[480]=v29 is dead).
 *
 * See src/juno_note.c for the full derivation (live-plugin state + decompile) and
 * docs/CONTROL_LAYER.md. Offline/host-side: the per-voice ramp objects are kept
 * in module-static storage here.
 */
#ifndef JUNO_NOTE_H
#define JUNO_NOTE_H

#ifdef __cplusplus
extern "C" {
#endif

/* Trigger a note on `voice` (0..7). `midi_note` is a standard MIDI note number
 * (60 = middle C); `velocity` 1..127 (0 == note-off). Writes the DCO pitch, the
 * one-shot attack edge, and starts the gate ramp. Call juno_note_tick() once per
 * rendered sample thereafter. */
void juno_note_on(unsigned char *st, int voice, int midi_note, int velocity);

/* Release `voice`: starts the gate ramp back to 0 so both ADSRs enter release. */
void juno_note_off(unsigned char *st, int voice);

/* Advance every active voice's gate ramp by one control tick. Call once per
 * sample, immediately BEFORE juno_voice_render for that voice/sample. */
void juno_note_tick(unsigned char *st);

/* Map a MIDI note to the per-voice DCO pitch value written to state[304] (octave
 * units, one unit == one octave; = midi_note/12). Exposed for tests/diagnostics. */
float juno_note_pitch(int midi_note);

#ifdef __cplusplus
}
#endif
#endif /* JUNO_NOTE_H */

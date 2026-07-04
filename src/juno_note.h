/* juno_note.h — minimal offline note driver for the JUNO-60 C99 port.
 *
 * Reconstructs the plugin's note-on / gate / ADSR-trigger control layer on top
 * of the ported per-sample DSP (juno_voice_render) and the ported ramp engine
 * (juno_ramp.c). It drives one (or more) of the 8 voices: sets the DCO pitch,
 * opens the shared envelope gate, and fires the one-shot attack edge; note-off
 * closes the gate so both ADSRs enter release.
 *
 * The envelope gate: voice_render computes a per-voice binary gate at state[560]
 * (= JF(base+240)) from the DCO gate-conditioner (state base+0 / +... ). Both the
 * filter ADSR (state[2592]) and amp ADSR (state[3072]) run iff that gate is 1
 * (their v125/v147 flags are (gate*v123 + (-0.5) >= 0) ? run : idle, and in the
 * captured PD-Juno-Pad patch v123==v145==1). The gate latches to 1 when the
 * conditioner output v29 is nonzero and >= -state[544](~0.0104). We open it by
 * ramping the DCO phase-reset base slot (base+0, = state[320] for voice 0) from 0
 * to a small positive level: this makes v29>0 without perturbing the DCO pitch
 * (the oscillator frequency depends only on state[4448]+state[3776], not on this
 * slot), so the note sounds in-tune. Note-off ramps the same slot back to 0.
 *
 * See docs/CONTROL_LAYER.md and the firstnote traces. Offline/host-side: the
 * per-voice ramp objects are kept in module-static storage here.
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

/* Map a MIDI note to the DCO pitch value written to state[4448] (octave units,
 * one unit == one octave). Exposed for tests/diagnostics. */
float juno_note_pitch(int midi_note);

#ifdef __cplusplus
}
#endif
#endif /* JUNO_NOTE_H */

/* juno_driver.h — offline per-sample driver around the exact DSP transcription.
 * Renders the voices into the master's 8 voice buffers, supplies the chorus-mode
 * selectors, and calls juno_master_render to produce the final stereo sample.
 * This is clean host glue (no plugin threading) — see src/juno_driver.c.
 */
#ifndef JUNO_DRIVER_H
#define JUNO_DRIVER_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Shim that satisfies the master's host-params pointer chase off state+136.
 * The master reads two chorus-mode selectors:
 *   base = *(void**)(state+136);
 *   v39  = *(int*)*(void**)((char*)base + 136);   // first chorus engine
 *   v551 = *(int*)*(void**)((char*)base + 112);   // second chorus engine
 * Mode 0 selects the dry/bypass path in both engines. */
struct juno_host_shim {
    int32_t mode_v39;
    int32_t mode_v551;
    unsigned char params[160];   /* +112 and +136 hold pointers to the modes */
};

/* Wire the shim into the state block. Call once after juno_engine_init.
 * `shim` must outlive all subsequent render calls. */
void juno_driver_attach_host(unsigned char *st, struct juno_host_shim *shim,
                             int32_t chorus_mode);

/* Render one stereo output sample (voices -> 8 buffers -> master process).
 * Returns 1 if the full master/chorus path ran, 0 if the dry fallback was used
 * (chorus coefficients from sub_180388170 not yet captured — see juno_driver.c). */
int juno_driver_render_sample(unsigned char *st, float *outL, float *outR);

/* --- note gate + pitch --------------------------------------------------------
 * A note is played by holding the per-voice master gate ("M.Gate", flat-state
 * offset 320 + voice*10512) at 1.0 and pulsing the note-on edge (offset 101504 +
 * voice*32) for one sample. voice_render then generates the LFO, both ADSR
 * envelopes and the filter sweep internally from that gate.
 *
 * Pitch: voice_render reads the pitch from offset 4448 (+voice*10512) in OCTAVES
 * (Hz = JUNO_DCO_REF_HZ * 2^pitch). juno_note_on sets it for a MIDI note under
 * standard A440 equal temperament — the plugin's default tuning (its 12-entry
 * fine-tune table sub_135D180 defaults to equal temperament). The octave->Hz
 * reference is the transcribed DCO's own calibration, so the produced frequency
 * is exactly 440*2^((note-69)/12). Patch transpose/master-tune params are separate
 * (368/384) and left at the patch's values. */
#define JUNO_DCO_REF_HZ  22380.1   /* Hz at pitch-offset 0, from the transcribed DCO */

void juno_note_on (unsigned char *st, int voice, int midi_note);  /* gate + pitch + edge */
void juno_note_off(unsigned char *st, int voice);                 /* gate=0.0 (release)  */

#ifdef __cplusplus
}
#endif

#endif /* JUNO_DRIVER_H */

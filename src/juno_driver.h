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
 * The master runs TWO DIFFERENT effects IN SERIES, each with its own selector:
 *   base = *(void**)(state+136);
 *   v39  = *(int*)*(void**)((char*)base + 136);   // "Prog_ID_DLY" slot
 *   v551 = *(int*)*(void**)((char*)base + 112);   // "Prog_ID_EFX" slot
 *
 * These are NOT two halves of one chorus. The decompile's program-slot vector
 * (decomp_380000.c:4512-4618) names them: slot 5 (params+136) = the Delay/Chorus
 * block that holds the authentic JUNO BBD chorus (state 6395xxx), driven by the
 * patch's "JUNO Chorus mode" (DB873 — off/CH1/CH2); slot 4 (params+112) = the
 * System-8 "FX-A" effect slot (state 84672..96xxx), driven by "FX-A type" (DB875).
 * Signal flow per sample: voices -> FX-A (v551) -> JUNO chorus (v39) -> output.
 *
 * `mode_v39` is the JUNO chorus mode (2 = CH1 for SQ Dynamic ARPG).
 * `mode_v551` is the FX-A type. FX-A's "off/delay" paths (v551 0/1) read
 * coefficients that only the live host writes (the EFX output-mix gains at
 * 85152/85168/85184 — runtime-only, absent from our static state), so they
 * collapse to silence offline. To render FX-A faithfully we'd need that patch's
 * FX-A coefficients (a small capture). Until then, `fxa_bypass` routes the FX-A
 * input straight to its output (a clean thru), so the JUNO chorus processes the
 * dry voice and no spurious second modulation is added. See docs/CHORUS_VIBRATO_DIAG.md. */
struct juno_host_shim {
    int32_t mode_v39;
    int32_t mode_v551;
    unsigned char params[160];   /* +112 and +136 hold pointers to the modes */
};

/* Wire the shim into the state block. Call once after juno_engine_init.
 * Sets mode_v39 = chorus_mode (the JUNO chorus); sets the FX-A slot to off and
 * enables the FX-A thru-bypass by default (see the struct note above).
 * `shim` must outlive all subsequent render calls. */
void juno_driver_attach_host(unsigned char *st, struct juno_host_shim *shim,
                             int32_t chorus_mode);

/* Enable (1) / disable (0) the FX-A thru-bypass. Default: enabled. Disable only
 * when the live FX-A coefficients have been loaded into the state. */
void juno_driver_set_fxa_bypass(int on);

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

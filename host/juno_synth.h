/* juno_synth.h — real-time-style polyphonic instrument API around the bit-exact
 * JUNO-60 engine. This is the host-facing layer a VST3/CLAP/AU/standalone wrapper
 * calls: create → load preset → note on/off + set params → process blocks.
 * Voice allocation (note→one of 8 voices) is handled here; the DSP underneath is
 * the verified per-voice render + master/chorus/reverb. */
#ifndef JUNO_SYNTH_H
#define JUNO_SYNTH_H
#include "../src/juno_preset.h"

typedef struct juno_synth juno_synth;

juno_synth *juno_synth_create(void);         /* allocate + init the engine     */
void        juno_synth_destroy(juno_synth*);

/* Load a factory bank patch (capture-free). Sets up chorus + reverb from the
 * patch. Returns 0 on success; fills *info if non-NULL. */
int  juno_synth_load_preset(juno_synth*, const char *bank_path, int record,
                            juno_preset_info *info);

void juno_synth_note_on (juno_synth*, int midi_note, int velocity); /* allocates a voice */
void juno_synth_note_off(juno_synth*, int midi_note);               /* releases its voice */
void juno_synth_all_notes_off(juno_synth*);

/* Render `nframes` stereo samples into outL/outR (deinterleaved). */
void juno_synth_process(juno_synth*, float *outL, float *outR, int nframes);

#endif

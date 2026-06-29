/* juno_synth.h — real-time-style polyphonic instrument API around the bit-exact
 * JUNO-60 engine. This is the host-facing layer a VST3/CLAP/AU/standalone wrapper
 * calls: create → load preset → note on/off + set params → process blocks.
 * Voice allocation (note→one of 8 voices) is handled here; the DSP underneath is
 * the verified per-voice render + master/chorus/reverb. */
#ifndef JUNO_SYNTH_H
#define JUNO_SYNTH_H
#include "../src/juno_preset.h"

typedef struct juno_synth juno_synth;

juno_synth *juno_synth_create(void);          /* allocate + init at 48 kHz       */
juno_synth *juno_synth_create_sr(double sr);  /* allocate + init at host SR      */
void        juno_synth_destroy(juno_synth*);

/* Re-initialise the engine at a new sample rate (host setupProcessing). Clears
 * voices; the caller should re-load the preset afterwards. */
void        juno_synth_set_sample_rate(juno_synth*, double sr);

/* Load a factory bank patch (capture-free). Sets up chorus + reverb from the
 * patch. Returns 0 on success; fills *info if non-NULL. */
int  juno_synth_load_preset(juno_synth*, const char *bank_path, int record,
                            juno_preset_info *info);

void juno_synth_note_on (juno_synth*, int midi_note, int velocity); /* allocates a voice */
void juno_synth_note_off(juno_synth*, int midi_note);               /* releases its voice */
void juno_synth_all_notes_off(juno_synth*);

/* Render `nframes` stereo samples into outL/outR (deinterleaved). */
void juno_synth_process(juno_synth*, float *outL, float *outR, int nframes);

/* ---- Panel-parameter interface (for the VST3/CLAP/AU wrapper) ----
 * The exposed automatable params are the JUNO-60 panel knobs/switches
 * (refs/juno_param_map.h: db->engine offset+tableId). Each takes a normalized
 * 0..1 value; the engine step is round(norm*255) applied through the verified
 * LUT path (juno_param_apply_lut), broadcast to all 8 voices. */
int          juno_synth_num_params(void);
const char  *juno_synth_param_name(int index);
void         juno_synth_set_param(juno_synth*, int index, float norm);

#endif

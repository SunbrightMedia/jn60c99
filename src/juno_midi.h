/* juno_midi.h -- the plugin's MIDI controller intake below its render driver
 * (CLAIMS B16, docs/HOST_RENDER_LAYER.md): the engine's pitch bend, mod wheel
 * and expression entries, and the value laws of the wrapper's parameter
 * records. The tables are the booted plugin's own (src/midi_tables.h,
 * tools/verify/gen_midi_tables.py).
 *
 * READ (rva 0x3C7390 / 0x3C7E70 / 0x3C7DD0 -> dispatch 493 / 495 / 498 on the
 * 9 units with flag 0 -> processor rva 0x3AFD40 / 0x3AF810 / 0x3AEBD0) and
 * EXECUTED through the plugin's own process() (probes/host_midi/
 * ctl_path_probe.py): every set is a ramped set (rva 0x3C10D0 -> 0x3C2920) on
 * a ramped cell -- the bend and the mod wheel on two cells of every voice at
 * time index 0, the expression on the master's cell at time index 1. */
#ifndef JUNO_MIDI_H
#define JUNO_MIDI_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* CWaveGen vt+152 (rva 0x3C7390): the 16-bit bend, clamped to -8192..8191 as
 * an int16 (rva 0x3C4FD0); curve 26 at bend + 8192 (rva 0x35BBD0 / 0x359440)
 * on cells 4112 and 7456 of every voice. */
void  juno_midi_bend(unsigned char *state, int v16);
/* CWaveGen vt+256 (rva 0x3C7E70): 0..127 only; curve 22 (rva 0x35C090 /
 * 0x359A60) on cells 4000 and 7376 of every voice. */
void  juno_midi_mod(unsigned char *state, int v);
/* CWaveGen vt+280 (rva 0x3C7DD0): 0..127 only; curve 18 (rva 0x35AEF0) on the
 * master's cell 101136. */
void  juno_midi_expression(unsigned char *state, int v);

/* The value a mapped CC gives its parameter record (rva 0x31A850): the CC byte
 * over the range of JUNO_MIDI_PARAM[entry]. */
float juno_midi_cc_value(int entry, int cc);
/* The engine value of a parameter record (rva 0x31A940): min + (max - min) x v
 * of JUNO_MIDI_PARAM[entry], rounded half away from zero, clamped to an int. */
int32_t juno_midi_record_value(int entry, float v);
/* The id map the render driver searches for a parameter record (rva 0x319AB0):
 * the JUNO_MIDI_PARAM entry of `id`, -1 when it has none. */
int   juno_midi_entry(uint32_t id);
/* The default CC assignment (rva 0x319A60): the entry CC `cc` drives, -1 none. */
int   juno_midi_cc_entry(int cc);
/* The port's host index of entry `entry` (JUNO_STATE_ENT: >= 0, or one of
 * JUNO_SE_NONE / _VOICES / _SRATE) and its id. */
int   juno_midi_entry_host(int entry);
uint32_t juno_midi_entry_id(int entry);

/* The VST3 MIDI-mapping parameter base (core +48): ids base + 0..129. */
uint32_t juno_midi_base(void);

#ifdef __cplusplus
}
#endif
#endif /* JUNO_MIDI_H */

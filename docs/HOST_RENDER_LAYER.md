# The plugin's HOST RENDER LAYER (opened 2026-10-07)

LIVING. Answers: what happens between a host's `process()` call and the engine
render, and where the port differs. Status words: PROVEN (executed in the booted
plugin), READ (machine code / decompile), INFERRED.

Found 2026-10-07 while building the oracle for the running arpeggiator. The
census of the JUNO started at the engine (CWaveGen vtable) and never executed the
plugin's own `IAudioProcessor::process`; this whole layer sat between the host
and every gate (playbook 143).

## The call chain of one host block

```
IAudioProcessor::process        rva 0x34A380   events -> MIDI push 0x31F4E0; parameter queues: id < base -> kind-1
                                                record, id - base = 0..127 CC / 128 channel AT / 129 bend -> push;
                                                ProcessContext -> transport struct; then:
render driver (queue consumer)  rva 0x320B20   engine rate check, tempo, arp tick clock, queued events at their
                                                sample offsets, sub-block renders through the core's render object
core render object (core+96)    set by rva 0x3442E0 for (engine rate, host rate):
    identity                    rva 0x344270   engine render directly (engine rate == host rate)
    rate converter              rva 0x343E30   engine render into its own buffers, then converted to the host rate
engine render (CWaveGen vt+56)  rva 0x3C7400   voice workers + master (e2e_emu replaces only the thread transport)
```

## PROVEN (probes/host_render/render_path.py; Unicorn, the plugin's own process())

| fact | evidence |
|---|---|
| The engine rate is the plugin setting **vm.vs.sampleRate** (id 0x0FFFC015, in the DAW state, Script.xml range 0..3, **default 0**), table rva 0x94AB80 = {96000, 88200, 48000, 44100, 32000} | getState carries 0x0FFFC015=0; after boot core+588 = 96000; setState with 2 -> 48000, with 3 -> 44100 |
| With the default, the engine runs at **96000 at every host rate** | host 48000: core+104 = 96000, no setSampleRate call; render object {96000, 48000, 4, 8} = converter |
| At a host rate other than the engine rate, every block goes through the **rate converter** (rva 0x343E30) | host 48000: a 512-sample block renders 1024 engine samples; host 44100: 1115, 751 + 364, 1114 (object {96000, 44100, 588, 1280}) |
| Host rate == engine rate -> **identity** (rva 0x344270): the engine renders the host block itself | host 96000 default; host 48000 with setting 2; host 44100 with setting 3 |
| A changed setting takes effect at the next process(): engine setSampleRate(new rate), then the identity / converter object for the pair | setting 2 at host 48000: block 0 logs setSampleRate(48000.0), path IDENTITY |
| The host tempo reaches the engine as round(tempo x 10) | ProcessContext tempo 128.5, kTempoValid: tempo entry once, core+580 = 1285 |
| The arp clock ticks on its own grid in HOST samples, splitting the render | host 48000, tempo 128.5: tick at 0, next tick in block 1 at offset 421 (933.85 host samples per tick); the render splits 421 + 91 (engine 842 + 182 through the converter) |

## READ (rva 0x320B20, 0x34A380, 0x3C7F10, 0x3C6750)

- Transport struct built by process(): +0 playing (state & kPlaying), +4/+8 project
  time in quarters (kProjectTimeMusicValid), +16/+24 tempo (kTempoValid; **120.0 when
  the host gives none**), +32/+40/+48 cycle (kCycleValid). CWaveGen vt+200 / +208 /
  +240 (playing, position, cycle) are empty functions: only the tempo reaches the engine.
- Tempo: T = round-half-away(tempo x 10.0) (rva 0x3F2050), clamped to int. The engine
  tempo entry (vt+176, rva 0x3C7F10) is called only when T differs from the last one
  (core+580, -1 at boot) AND the tempo is valid; it dispatches leaf 375 (flag 0, value
  T) to all 9 units when 400 <= T <= 3000 (40..300 BPM), else nothing.
- Arp tick clock: period P = (60000000000 x hostRate_int / T) / 24 (64-bit, truncating)
  in 1e-8 host samples; phase core+560. Before each event offset and up to the block
  end: render up to floor(phase / 1e8), call the tick (vt+184, rva 0x3C6750: all 9 arp
  instances, every tick, whether the arp is on or not), phase += P. Block end: phase
  -= 1e8 x n. The tick period uses T even when the tempo is not valid (then 1200).
- Note count core+568: +1 per note-on record, -1 per note-off record (every note, arp
  on or off). When it was 0 before the records at one offset and is > 0 after them:
  phase = 1e8 x offset + P and a tick runs at once -- **the grid restarts at the first
  key**.
- An engine-rate change (core+104 != core+588) at the start of a block: engine
  setSampleRate, new render object, and, when the pair changed, phase = 0, count = 0.

## The port today

| plugin | port |
|---|---|
| engine at vm.vs.sampleRate's rate (default 96000) + the converter to the host rate | the same on the product path (juno_gui_plugin_init, src/juno_conv.c) -- **bit-exact, A25**; juno_gui_create stays the engine model (the engine at the given rate, no table) the engine gates grade |
| silence at a host rate outside its table (11025, 22050, 32000, 47999, ...) and at wild settings | the same -- **bit-exact, A25** |
| a setting change after the engine has run: setSampleRate in place | the same (setsr_inplace, src/recall_ramp.c juno_rr_setsr_*) -- **bit-exact, A30** |
| a host-rate change on a running instance (setActive / setupProcessing): the engine kept, the render object looked up again | the same (juno_gui_setup_processing, juno_gui_set_active) -- **bit-exact, A28** |
| the render driver: events at offsets, the tick clock in 1e-8 host samples from round(tempo x 10), the grid restarted by the first key, ticks always, the tempo only when valid / changed / 40..300 | the same (gui/juno_bridge.c drv_block) -- **bit-exact, A24** |
| the arp controller (SW / TYPE / STEP, the apply, the pattern reload at the next step) | the same (arp_sw / arp_type_set / arp_step_set, src/carp.c carp_ctl_config) -- **bit-exact, A24** |
| the start-up: 274 ramps per unit in flight after the boot (the build at 96000), the stopped units' kept | the same (src/boot_ramps.h, juno_rr_boot in juno_gui_plugin_init) -- **bit-exact from the first sample, A29** (the default setting) |
| MIDI controllers through process(): bend, mod wheel, expression, the 51 default CC assignments, parameter records (every host id below the MIDI base), aftertouch / program change (empty) | the same (juno_gui_process_ex, src/juno_midi.c, src/midi_tables.h) -- **bit-exact, A26** |
| sustain (CC 64, a HOLD in the keyboard object) and all-notes-off (CC 123, the assigner's) | the same (gui/juno_bridge.c, the keyboard block) -- **bit-exact, A27** |

## The arp controller (READ + EXECUTED, 2026-10-07)

The host entry (rva 0x3C7AE0) sends dispatch 831..835 straight to the controller of each of the 9
units (engine +136 + 64u), nothing else: 831 the switch with (v != 0) (rva 0x3C49F0), 832 TYPE
(0x3C4E50), 833 STEP (0x3C49B0), 834 SCATTER TYPE (0x3C4F10), 835 SCATTER DEPTH (0x3C4EE0), the
last two with force 0. The plugin's state list and patch load never send 834 / 835: SCATTER stays
at the build's (0, 7) on every product path.

- TYPE / STEP (0..5): a new value re-runs the switch with force; while the arp is on, the config
  runs once more. While the arp is off the value only waits: the switch-on's config applies it.
- The switch, on: the config twice (TYPE, STEP) before anything moves, then the keyboard's route,
  the arp's flag (+10), the keys from the voice map to the arp. Off: the arp idle (its sounding
  notes off) and reset, then the keys back as notes (B11).
- The config (rva 0x3C4F40): TYPE and STEP clamped to 2; the apply for a new TYPE, the apply for
  STEP (+4076), and -- the first time ever -- the rate mode 2 with the beat re-latch armed.
- The apply (rva 0x3C0EC0, apply object built with -1, -1, -1, -8): the pattern request (rva
  0x3C3010: +40 = 1, the step index taken modulo the old length, the selector, the octave offset
  0, the range from +4076, the block's gate and sensitivity), the rate ({0,2,4,1,3,5}[mode] + the
  table's delta), the range delta, seven values to dispatch 312..318 (the engine's side, census
  A20), the keyboard's beat (+5). Table rva 0x9D86D0, [150 x slab + 15 x k + sub].
- The reload (rva 0x3C07E0) at the next step tick, before the step: while running, every slot's
  note off (velocity 64), the expand (rva 0x3BF9F0) and the gate fill (rva 0x3BFED0).
- PROVEN (probes/host_render/arp_cfg_probe.py): a TYPE edit while the arp runs with keys held
  changes +40, the selector, the config bytes, the apply's type, nothing else -- not the selector
  index, "started", the UP&DOWN direction; no unit's engine state moves.

## Ported details (A25)

- The setting acts at once (the core's listener); the switch happens at the start of the next
  block, before that block's records. initialize's defaults and the DAW's events follow it. The
  port switches exactly on a fresh start (its state byte-equal to a fresh create + plugin_init: a
  build at the new rate, the mute, the defaults again) and refuses a switch after the engine ran.
- The plugin's default engine is built at 96000 and never given setSampleRate: the two mode-5
  cells only setSampleRate writes (96336, 96368) stay 0 (juno_engine_no_setsr).
- The converter's engine render runs its preamble (the voice-count sync) once per call; a call
  that needs no engine sample runs none. The count can be -1; the next call then copies the
  history upward from index -1, the word in front of the plugin's vector (+0 under DAZ), and the
  history becomes zeros; the backward taps read index -1 the same way.
- Harnesses set the oracle FP mode after juno_gui_create (which sets the production FTZ).

## The converter table (PROVEN, read from the booted plugin, 2026-10-07)

rva 0xC43C30, 45 entries + a terminator, 32 bytes each {engine rate, host rate, L, M, coefficient
vector, render function}; the lookup is rva 0x343A80 (on a new engine or host rate).

| engine \ host | 11025, 22050 | 44100 | 48000 | 88200 | 96000 | 176400 | 192000 | 384000 |
|---|---|---|---|---|---|---|---|---|
| 96000 | silence | L588 M1280 | L4 M8 | L588 M640 | identity | L147 M80 | L4 M2 | L4 M1 |
| 88200 | silence | L640 M1280 | L80 M147 | identity | L640 M588 | L640 M320 | L640 M294 | L640 M147 |
| 48000 | silence | L1176 M1280 | identity | L147 M80 | L8 M4 | L147 M40 | L8 M2 | L8 M1 |
| 44100 | silence | identity | L1280 M1176 | L1280 M640 | L1280 M588 | L1280 M320 | L1280 M294 | L1280 M147 |
| 32000 | silence | L441 M320 | L441 M294 | L441 M160 | L12 M4 | L441 M80 | L12 M2 | L12 M1 |

Coefficients per vector: 84 (L4/L8 at 2:1), 43 (L4 at 1:2, 1:4), 13257 (44.1k <-> 48k family),
6631, 1524, 126, 4568. No entry for the pair -> the terminator's render function, silence:
EXECUTED at host 32000 (default and setting 32000), 22050 and 47999 -- no engine render, zero
output with a key held; 48000 (default) and 44100 (setting 3) play.

The converter (rva 0x343E30): per block, ceil((acc43 + delay + n x M - acc42) / L) engine samples
rendered after the kept history (2 x delay / L samples per channel); each output sample sums the
taps forward then backward in float and is scaled by (float)L; the counters wrap at 0x40000000 -
(0x40000000 mod (M x L)) + 2 x delay.

## Work (CLAIMS B13b, B15)

1. DONE (A24): the oracle through process() with its isolation control; the driver and the arp
   controller ported and gated on the identity path at 44100 / 48000 / 96000.
2. DONE (A25): the engine-rate setting, the table, the converter, the silence object, the
   product start at 96000, the switch on a fresh start. DONE (A30): the switch on a running
   engine (setSampleRate in place, rva 0x3C7A20); the fresh start now switches the boot state
   in place too.
3. DONE (A29): the start-up as the plugin boots (its build at 96000, its ramps in flight), gated
   from the first sample (boot_gate.py). Not graded from the first sample: a setting that
   switches the engine at the first block.
4. DONE (A26): MIDI CC / channel aftertouch / pitch bend intake (process() re-encoding, the
   push's CC map, the parameter records, the engine's vt+136 / +152 / +160 / +168). DONE (A27): the
   keyboard object's sustain (CC 64) and the assigner's all-notes-off (CC 123).

## The MIDI controller intake (READ + EXECUTED, 2026-10-07; CLAIMS A26 / B16b)

- process() (rva 0x34A380): host events first (notes), then one record per parameter queue (its
  last point), in queue order. An id below the base (core +48 = 0x0FFFC100) -> a parameter record
  (kind 1, rva 0x31F2C0, the value as a float). base + n: n 0..127 CC n with data round(v x 127)
  (half away from zero, rva 0x3F2050; below 0 or NaN 0, above 255 255), 128 channel aftertouch
  (data1 the same), 129 bend round(v x 16383) (below 0 or NaN 0, above 65535 65535) as two 7-bit
  bytes, any other n a message of three zero bytes. All through the push (rva 0x31F4E0).
- The push: a CC its map assigns (rva 0x319A60; the boot's map: 51 CCs, no learn slot open)
  first queues a parameter record (the parameter's id, the CC byte over its range: rva 0x31A850,
  rounded or -- entry byte +16 -- truncated); then the message's own record, for every message.
- The driver (rva 0x3211D6): kind 1 -> the id map (rva 0x319AB0) -> the engine's host entry
  (vt+112) with round(min + (max - min) x v) (rva 0x31A940); an id the map lacks, nothing. Kind
  0: 0xB0 vt+136 (rva 0x34AE90: 1 mod, 10 empty, 11 expression, 64 sustain, 123 all notes off),
  0xE0 vt+152 with (lsb + ((msb - 64) << 7)) as 16 bits, 0xA0 / 0xC0 / 0xD0 empty functions.
- The engine's host entry with the engine-rate setting's id does nothing: only the model's
  listener switches the rate, and process() does not touch the model.
- Bend (rva 0x3C7390): clamped as an int16 to -8192..8191 (rva 0x3C4FD0), dispatch 493 flag 0
  -> every voice's sub-objects +25 / +33 (rva 0x35BBD0 / 0x359440): curve 26 at bend + 8192,
  ramped (time index 0) on cells 4112 / 7456. Mod (rva 0x3C7E70, 0..127 only): curve 22 on 4000 /
  7376, time index 0. Expression (rva 0x3C7DD0, 0..127 only): curve 18 on the master's 101136,
  time index 1. The processor keeps each value (+1160 / +1164 / +1168); nothing on the gated
  paths re-sends them (a patch load and a voice-count change after a bend: bit-exact).
- The product's units: the voice units' assigners follow the engine's voice count (6), the
  master's stays at 8 (EXECUTED, sus_probe.py): its allocation differs and is never rendered.

## The keyboard object and the sustain (READ + EXECUTED, 2026-10-07; CLAIMS A27)

One per unit (engine +120 + 64u), all alike; the engine's note entries (vt+120 / +128) call it.
Fields: +4 the route (1: the arp), +7 a transpose no path writes (0), +8 the key-trig flag, +9 /
+10 the arp / note sustain, +11 / +12 the pending key-trig mode, +16 the keys in the arp and +532
the arp keys the sustain holds (count + list), +1048 the keys down on the voices (key -> its
note) and +1176 the notes the sustain holds (0xFF none) -- adjacent, and the press-order walk
reads +1176 at index -1, which is +1048's key 127 --, +1320 the velocities, +1448 the press order
(newest first, -1 empty), +1312 the note sink (the assigner), +1304 the arp.

- Key-on (rva 0x3C42D0): the pending key-trig mode first. Arp route: with the arp sustain on and
  no key in the arp, the held arp keys leave first; a key not yet in the arp goes in (unless the
  sustain holds it: then it only leaves the hold). Voices: with the note sustain on and NO key
  down, every held note leaves first (press order, oldest first); the key goes down; a held note
  pressed again leaves the hold and plays again. Then the velocity and the press order.
- Key-off (rva 0x3C4230): arp route out of the arp (held instead under the arp sustain); voices:
  the key's note, held under the note sustain, else off.
- CC 64 (rva 0x3C7E20 -> the arp controller's 0x3C4E90): only a change acts; the note sustain,
  then the arp sustain, follow it; a release frees what each holds (notes: by the key-trig flag,
  1 from key 127 down, else the press list -- its empty slots included, so with key 127 down the
  walk sends note 255 and forgets that key: EXECUTED, probes/host_midi/sus_probe.py key127).
- The arp switch (rva 0x3C49F0) moves held notes into the arp (and its hold) when it turns on,
  held arp keys onto the voices (and their hold) when it turns off.
- CC 123 (rva 0x3C7DA0 -> 0x3C3A00 -> the assigner's 0x354A90 -> 0x3530B0): gate-off for every
  gated voice, every slot "no note", the held-note mask and +68 cleared; the keyboard's maps and
  the arp stay. Each gate leaf rewrites the held flag 1856 as "a voice still gated" (rva
  0x3B1C58), so the last gate-off leaves 0.

## A host-rate change on a running instance (READ + EXECUTED, 2026-10-07; CLAIMS A28)

setupProcessing (rva 0x3CB150) stores the setup and nothing else. setActive, true or false (rva
0x34AA50): the core's setup (rva 0x321AC0) at the stored rate -- with the automatic engine-rate
setting the requested engine rate becomes the engine's current one; the render object takes the
host rate (rva 0x3442D0, also a global its constructor reads) and is looked up again (rva
0x343A80); found, its buffers start from zeros and the tick phase and the note count go to 0 (a
held key's later note-off takes the count below 0) -- then the all-sound-off record (rva 0x3208E0:
CC 120 at offset 0, written past the CC map; the engine's CC entry takes no 120). The engine is not
touched: a DAW's rate change keeps every voice, ramp and FX state and swaps only the converter.
The driver's tick period reads the host rate from the render object (core +108).

## The start-up (READ + EXECUTED, 2026-10-07; CLAIMS A29)

The constructor sets 96000 before the engine's build; the build arms its cells' ramps from their
value before it (0 for most; CONDITION's scatter cells from their C = 0 values) toward the built
value. No block renders before the host's first process(), so the product start runs 274 ramp
records per unit from the first sample: unmoved, rate 96000, subdivision 10, time index 0 for 264
cells, 5 for cell 6736 + 10512 v, 1 for the expression 101136, 8 for 10759376 -- the same on every
unit and at host 44100 / 48000 / 96000 (probes/boot/boot_ramp_census.py). The units the voice
count stops do not pump theirs; a later count resumes the ramps and the 960-sample mute together.
A note in the block of a voice-count change is lost: the render's preamble that applies the count
resets every assigner after the block's events. Port: src/boot_ramps.h (tools/verify/gen_boot_ramps.py),
juno_rr_boot (src/recall_ramp.c) in juno_gui_plugin_init. Gate: tools/verify/boot_gate.py (7 chains
from the first sample); mutants: probes/boot/boot_teeth.py.

## setSampleRate on a running engine (READ + EXECUTED, 2026-10-07; CLAIMS A30)

CWaveGen::setSampleRate (rva 0x3C7A20) does nothing when the rate equals the engine's (ucomiss /
je: also on NaN); else, for each of the 9 units: the processor's suspend (vt3, rva 0x3B86C0) ramps
the mute cells toward 0 at the OLD rate (every voice's 2848 / 3328 / 6448; 84560 and the effect
type's own pair -- 91248 / 91280 for types 2..4, 96384 / 96416 for 5; 101744 and the delay block in
force's switch / enable pairs; the reverb's 10759376 at 36 ms); the effect container's setSampleRate
(rva 0x3BC980) re-applies by IMMEDIATE set (the cell, no record) every voice's 624, 1920, 1936,
2784 .. 3312, 10240 .. 10288, the chorus' 91120 .. 91184, 96336, 96368 and the delay block in force's
cells, with the values a recall at the new rate gives; the reverb arms its filter and cut cells
(twice, mute / unmute around them) at the old rate and stores its 34 taps and its lazy-wipe
countdown directly; the state's setSampleRate (rva 0x3C2770) sets every record's rate and runs the
constructor's constants (sub_1803990C0, not the BUILD wrapper's latches and seeds) and the runtime
reset (sub_1803A1300: voice and effect memories, the effect buffers, the delay ring positions, the
noise block -- in every unit's own copy); the resume (vt5, rva 0x3B8560) ramps the mute cells back
at the NEW rate (84560 and 85184 / 85168 at 24 ms for effect type 0, 86320 for 1). Records keep
their increments unless re-armed: a ramp armed at an engine rate of 0 has a 0/0 increment and
steps its cell to NaN, which the master render's tank test reads as "off" (rva 0x36680E, jbe on
unordered). The port: setsr_inplace (gui/juno_bridge.c) composes juno_rr_setsr_suspend /
_reapply / _resume (src/recall_ramp.c), juno_engine_init_core, juno_chorus_init and
juno_driver_unit_noise_reinit; the re-applied values come from a recall of the current record on
a reference engine built at the new rate (its own shim). Gate: tools/verify/rate_switch_gate.py;
mutants: probes/b13b/switch_teeth.py; census probes: probes/b13b/.


## The CC map in the DAW state (READ + EXECUTED, 2026-10-07; CLAIMS A31)

The core keeps a map CC -> parameter record (core+24+48), each record's own CC (+12) and the record
a MIDI learn waits for (+64, -1 none). The boot fills the 51 default assignments. IComponent::setState
(rva 0x34AAA0) reads the byte count; a count <= 0 returns kResultFalse before the deserializer. The
deserializer (rva 0x321F20) first EMPTIES the map (rva 0x31A4F0 with -1: every record's CC -1), then
reads the entries in payload order: an id 0x10000000 + n (n 0..127) is a map entry (rva 0x31A6A0):
a value >= 0 found in the id map (rva 0xCB04F8) sets map[n] = its record and the record's CC = n (a
later entry for n wins; two CCs may drive one record; the old owner's CC field is not cleared); a
negative or unknown value leaves n free. Every other id is a parameter entry. So a payload without
the 128 map entries leaves every CC free. A patch load (rva 0x335850) leaves the map alone
(probes/host_api/conductor_probe.py). The push's lookup (rva 0x319A60) answers -1 while a learn
waits; getState writes map[n]'s record id or -1 (rva 0x319B90). The port: juno_ccmap_* (src/juno_midi.c)
and the context's map (gui/juno_bridge.c). Gate: tools/verify/ccmap_state_gate.py; mutants:
probes/host_api/ccmap_teeth.py.

The core's second queue (core+512) and its drain (the conductor's slot 1, rva 0x320120) are NOT on
the audio path: the drain runs on the plugin's UI timer (CUiThreadTimer, 50 ms; the core registers
at initialize, rva 0x320420; the edit controller starts the timer) and, EXECUTED with the drain
called directly (scratchpad drain probe, task #36): it adds no engine record; it applies the
store records a mapped CC queues (kind 1: id, the CC's float value) to the parameter store getState
reads, with the record value law (rva 0x31A940); it completes a waiting MIDI learn with the FIRST CC
message it reads (rva 0x319C90: CC < 120; the record's old CC leaves the map, the CC's old record
loses its CC). Host parameter records (process(), ids below the MIDI base) never reach that queue:
the store does not follow host automation.

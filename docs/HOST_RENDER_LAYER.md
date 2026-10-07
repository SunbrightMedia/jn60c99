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
| a setting change after the engine has run: setSampleRate in place | refused, the port keeps its rate -- **open, B13b** |
| the render driver: events at offsets, the tick clock in 1e-8 host samples from round(tempo x 10), the grid restarted by the first key, ticks always, the tempo only when valid / changed / 40..300 | the same (gui/juno_bridge.c drv_block) -- **bit-exact, A24** |
| the arp controller (SW / TYPE / STEP, the apply, the pattern reload at the next step) | the same (arp_sw / arp_type_set / arp_step_set, src/carp.c carp_ctl_config) -- **bit-exact, A24** |
| the start-up: ~274 ramps per unit in flight after the boot | starts settled -- **open, B15** |

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
   product start at 96000, the switch on a fresh start. B13b: the switch on a running engine
   (setSampleRate in place, rva 0x3C7A20).
3. B15: the start-up as the plugin boots (its build at 96000, its ramps in flight); gate from
   the first sample.
4. MIDI CC / channel aftertouch / pitch bend intake (process() re-encoding + the engine's
   vt+136 / +152 / +160 / +168).

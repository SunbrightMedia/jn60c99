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

## The port today (INFERRED until the new gates run)

| plugin | port |
|---|---|
| engine at vm.vs.sampleRate's rate (default 96000) + the converter to the host rate | engine at the host rate, no converter: equal to the plugin only where the two rates are equal (a 96 kHz host with the default, or the setting matched to the host rate) |
| tick period from round(tempo x 10), 1e-8 host samples | src/carp.c: from round(BPM) (whole BPM), 1e-9 samples |
| grid restarts at the first key; ticks always run | free-running grid, ticks only while the arp is on |
| tempo forwarded only when valid and changed, 40..300 BPM | juno_gui_set_tempo: every value > 0, as a float |

## Work (CLAIMS B13, B14)

1. Oracle: execute the plugin's own process() in the booted plugin, the engine render's
   thread transport replaced as in e2e_emu (the only replacement), with an isolation
   control that equals the proven e2e path (identity path, notes at block starts).
2. Port the driver (events at offsets, tick clock, tempo, note count) and gate it on the
   identity path at 44100 / 48000 / 96000, arp running, tempos incl. non-integer and out
   of range, keys at every offset, several block sizes.
3. Port the engine-rate setting and the converter (rva 0x3442E0 tables, 0x343E30); gate
   the default (96000 engine) at host 44100 / 48000 / 88200 and odd rates.
4. MIDI CC / channel aftertouch / pitch bend intake (process() re-encoding + the engine's
   vt+136 / +152 / +160 / +168).

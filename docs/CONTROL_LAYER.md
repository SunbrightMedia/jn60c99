# Control layer — parameter system, note handling, voice allocation

Synthesis of the full-dump research (note handler #1, parameter appliers #2). RVAs
are imagebase-relative (0x180000000 + RVA). This is the map for transcribing the
host/control layer that sits above the audio closure.

## The descriptor/parameter system (the spine of both #1 and #2)
The engine object holds a `std::vector` of **40-byte parameter descriptors** at
`engine+0x38` (read as `engine[7]`/off 56). Each descriptor:

| off | field |
|----|----|
| +0  | parameter name string ptr |
| +12 | type/enabled flag (dword; `==1` = active numeric slot) |
| +16..31 | 16-byte "default" block (the shared flag constant for most params) |
| +20 | env/voice index (into the ramp-engine array) |
| +32 | **pointer to the coefficient slot** = `&engine_state[offset]` |

The descriptor `+32` pointer is bound to a flat-state field during init (the
registry `sub_180388170` does `lea &engine_state[offset]` per parameter, in
registration order = parameter ID). So **parameter ID → flat-state offset** is the
sequence of `lea` targets in `sub_180388170` (we already parsed ~1117 of these;
see docs/COEFF_PARAM_MAP.md).

## #2 — parameter → coefficient is a RAW STORE (no curves)
- Setter: `sub_1803C1090` / `sub_1803C10F0`: `*(float*)(descriptor[id].ptr+0) = value`.
  Getter: `sub_1803C10B0`. **No denormalize, no skew, no curve** — the value goes
  straight into the slot in native units.
- **Therefore the coefficient stored in a slot *is* the parameter value.** Our
  captured 279 coefficients ARE the parameter values for PD The Juno Pad, and
  `juno_runtime_coeffs_apply` (writing them into slots) *is* the original raw-store
  mechanism. The capture approach is faithful, not a shortcut.
- Per-parameter ranges/defaults/display live in a flat **4966×16-byte metadata
  table** `unk_…EC040` (indexed by `sub_1803ABAF0`), used only for clamp + display
  — **not needed for audio**.
- **Factory-default patch:** `sub_1803A66B0` — zeros every slot then issues a long
  run of raw `descriptor[id].ptr = <const>` writes (the engine's init patch).
  Transcribing this + the ID→offset map yields the default patch entirely from
  ORIGINAL code (no capture).
- Preset/bank loaders: `sub_18032F2B0` (load patch bank), `sub_18033CF30` (format
  detect: .s8p/.PRM/PLUGOUT_PATCH/.bin), `sub_18033C330` (deserialize) — all feed
  the same generic raw store in a loop.

**Surface for #2 = data, not framework:** the raw store (~5 lines) + the ID→offset
map (from sub_180388170) + the factory-default constants (from sub_1803A66B0).
No bespoke per-parameter setters or curve math to reimplement.

## #1 — note handling (descriptor-based, + a ramp engine)
- **Keyboard/arp scanner** `sub_1803C0260` resolves the integer note (octave
  transpose + wrap into 0..127) and fires note-on via `vtable[0]` with (note, vel).
- **Velocity→gate** `sub_1803C1720`: sets param **1090** (gate level/time) through
  the descriptor, then fires the gate trigger.
- **Voice trigger** `sub_1803C2920`: starts the gate envelope **ramp toward 1.0**
  (`sub_1803C2E80`, target const `unk_…EB50`) and **pushes the env index onto the
  active-voice list** (the `std::vector<int>` at engine off 112/120/128 — the exact
  inverse of the pruner `sub_1803C24A0`).
- **Note-off** `sub_1803C17A0`: sets param 1090 → 0.0 (gate release ramp).
- **Ramp/envelope engine** `sub_1803C2E80` (+ per-step/"done" `sub_1803C2E00`):
  ramps a value toward a target over N ms in subdivisions; drives the gate and any
  ramped parameter. Essential to transcribe.
- **Gate edge** at `state[voiceBase+101504]`: a one-shot retrigger flag (`==1.0`
  means "a note just started"); the renderer consumes it then zeroes it.
- **Pitch:** the renderer reads `clamp(state[+4448] + state[+3776], -20, 8.9)` in
  **octave units**; the live pitch is written through the pitch parameter's
  descriptor pointer (bound to `&state[+4448]`).

### RESOLVED — note → pitch
voice_render reads the pitch from offset 4448 in OCTAVES and turns it into a DCO
frequency via `juno_pitch_table` (Hz = C·2^pitch). Measuring the transcribed DCO
gives C = 22380.1 Hz at pitch 0, a clean 2^oct law (each +1.0 doubles the
frequency). The fine-tune table `sub_135D180` defaults to equal temperament, so a
MIDI note maps with standard A440: `pitch = log2(440/C) + (note-69)/12`. Rendered
notes match standard tuning to **<0.1 cents across two octaves** (A4 = 440.01 Hz).
Implemented in `juno_note_on(st, voice, midi_note)` (src/juno_driver.c). The
absolute reference C is the DCO's own calibration (from code); only the A440 +
equal-temperament convention is assumed, which is the plugin's default tuning.
`make play NOTE` / `tests/play_scale` demonstrate it.

### Known gap (do NOT fabricate)
The exact **integer-MIDI-note → octave-pitch float** conversion is not a visible
inline formula — the note stays an integer and is converted in the DCO/parameter-
binding layer via tuning tables (e.g. `sub_135D180` writes a 12-entry `cents/1200`
table). The descriptor binding for the pitch parameter (which param ID points at
`&state[4448]`, and the int→float it stores) must be traced from the original code
before the port can pitch notes correctly. The plausible `(note-60)/12` is an
inference, not read — treat as UNCONFIRMED until the binding is traced.

## Helpers to transcribe for the control layer
`sub_1803C2E80`/`2E00` (ramp engine), `sub_1803C24A0` (pruner) + its vector
helpers, `sub_1803C1090/B0/D0/F0` (descriptor get/set/trigger), `sub_1803C1720`/
`17A0` (gate on/off), `sub_1803C0260` (key/arp scanner), `sub_135D180` (tuning
table), and the descriptor `+32` binding code in the `sub_180363380` init region.

## Port implications
- Our engine + captured coefficients already reproduce the *processing* faithfully
  (raw store confirmed; init validated 0 gaps).
- To **play notes from original code**: transcribe the ramp engine + voice
  trigger/pruner + the note→pitch binding (the one gap to pin).
- To **honour any patch from original code**: transcribe the raw store + ID→offset
  map + factory-default constants (all mechanical/data).

## RESOLVED — the voice plays from the gate at offset 320
The full parameter map (registry `sub_180388170`, parsed clean) gives the per-voice
control slots by name. The note gate is **"M.Gate" at offset 320** (param idx 2),
NOT 1856 ("Gate", which is a different/secondary flag) and NOT a control-layer ramp.
Holding `state[320] = 1.0` (+ the one-shot edge at `state[101504]`) makes
voice_render generate the LFO (`+560`), both ADSRs (params at `+2784`/`+3264`) and
the filter-envelope sweep (`+3232`) **internally**, per sample. So the "ramp
engine / envelope generator" is NOT needed for a basic note — voice_render is
self-contained once gated. The ramp engine (src/ramp_engine.c) remains the exact
mechanism for parameter smoothing and the keyboard-object gate, but the audible
path does not depend on it.

Key per-voice param offsets (voice 0; add v·10512): 272 UseExtJack, 304 M.CV,
**320 M.Gate (note gate)**, 368 Master Tune, 384 Part Tune, 1088 LFO Rate,
2784–2832 ENV1 A/S/D/R, 3264–3312 ENV2 A/S/D/R, 4448 pitch (octaves),
6736 LPF Cutoff, 6832 LPF Resonance, 6864 Velocity, 9824 Mute (amp enable),
10176 Gate SW, 10208 ENV2 SW, 10304 ENV LEVEL, 10320 AMP LEVEL. Full list of 1121
params in the parser output (tools, registry asm).

## Sound-test diagnostic (empirical, earlier this session — superseded above)
Loaded the captured PD-Juno-Pad coefficients, set the note-on edge `state[101504]=1.0`,
and rendered. Findings:
- **Oscillator core works:** DCO phase advances; saw mix `state[1792] = -0.99`
  (full scale); wave-mix `state[4928] = -1.07`; VCA env `state[9856]` opens to ~1.0.
- **Signal dies in the filter:** VCF output `state[10544] ≈ 0` and decays — the
  filter envelope stays closed, so the (correct) ladder filters the voice to silence.
- **No single-field shortcut:** holding any one offset (300..10800) at 1.0 every
  sample produces no voice output. The note-on is a SEQUENCED gate (the ramped
  gate that opens BOTH the amp and filter ADSRs), not a single flag.
- **Conclusion:** an audible test requires the real note-on gate path — the ramp
  engine `sub_1803C2E80` driving the held-gate that triggers the filter/amp
  envelopes. That is unit #1; the engine itself is proven to synthesize.

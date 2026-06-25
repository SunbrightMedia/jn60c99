# JUNO-60 DSP → C99 (exact port)

A C99 port of the Roland Cloud **Cloud 60** (JUNO-60 emulation) **DSP audio
engine**, reverse-engineered entirely from the decompiled VST3. The goal is an
**exact, structural transcription** of the plugin's actual algorithm — same
operations, same signal flow, same coefficients — not a sound-alike approximation.

**THE RULE:** the decompiled plugin is the spec. We transcribe it. We do **not**
fit curves, tune constants to match audio, or substitute an easier stand-in for a
hard-to-read DSP block. If a number isn't in the decompile, it does not go in the
port (`docs/DATA_PROVENANCE.md`).

## Target facts (binary-derived)

- Plugin: Roland Cloud **Cloud 60**, x86-64 PE. **ImageBase `0x180000000`.**
- **Per-voice render @ `0x180369070`** (RVA `0x369070`).
- 8-voice poly engine; DCO (saw + variable-pulse + square sub + noise),
  non-resonant HPF, 24 dB/oct resonant LPF (IR3109-style 4-pole), two ADSRs
  (filter + amp), one delayed triangle LFO, stereo BBD chorus (modes I / II / I+II).
- Voice-state strides: main +10512 / shared +0 / aux +32 per voice.

## Source of truth

The **entire decompiled plugin** is in the repo — no IDA session or live capture
is needed to continue:

| Path | Purpose |
|------|---------|
| `refs/allcode_decomp.tgz` | Full Hex-Rays decompile of the plugin (every function). |
| `refs/manifest.tsv` | Index into the decompile. |
| `refs/*.json`, `refs/data/` | Recovered coefficient tables, FX/arp data, vtables. |
| `asm_dump/`, `everything_static/`, `master_deps/`, `param_setter/`, `host_layer/` | Disassembly for functions Hex-Rays dropped args on / couldn't lift. |
| `src/` | The C99 port. |
| `tools/` | Static-analysis / transcription helpers. |
| `docs/` | Subsystem maps and the project record (start at `docs/PORT_STATUS.md`). |

## Progress tracker

The single goal: a **production-ready, bit-exact, extremely accurate** C99 port of
the plugin's DSP. Percentages are honest engineering estimates toward *bit-exact*,
not "sounds close." Two bars are tracked per area: **code** (transcribed from the
decompile) and **verified** (proven against the binary's bytes or asm). Updated as
work lands — keep this current.

| Area | % | State |
|------|--:|-------|
| Init / coefficient layer (`engine_init`) | 100% | Bit-exact: 2289/2289 stores match the binary. |
| Voice DSP — DCO/HPF/VCF/2×ADSR/VCA/LFO/unison | 100% | **Bit-exact verified** vs decompile+asm (full line-by-line diff, zero discrepancies). |
| Polyphony (8 voices, M.CV fix) | 98% | All 8 voices render; voice 0 bit-identical; M.CV pitch-base bug fixed; all 622 per-voice offsets verified. |
| Master mix + BBD chorus (×2 instances) | 100% | Both chorus instances **bit-exact verified** vs asm; Chorus I/II CV **recovered capture-free** (step·11/255−8, steps 62/50, bit-exact). |
| Delay FX (+ DL2) | 100% | **Bit-exact verified** (both modes, interpolation, damping, feedback). |
| Reverb (CJu60Sim) | 98% | DSP **bit-exact verified**; HALL2 **activated** (tap-builder `sub_7FF91E021AC0` transcribed, renders a decaying tail). Per-patch decay-knob damping is the small remainder. |
| System-8 FX-A slot (Flanger, all 6 modes) | 100% | DSP **bit-exact verified**; routed separately from chorus; thru-bypassed when type=DELAY. |
| `chorus_init` + `ramp_engine` | 100% | **Bit-exact verified** (chorus_init: 3148 stmts, zero diffs). |
| Arpeggiator (`CArpeggio` + CKbdArp) | 100% | Core + 6 selectors + scanner + clock **bit-exact verified**; the CKbdArp preset-pattern expander is now transcribed + wired (`juno_arp_load_pattern`). |
| Preset / bank decode | 98% | Deserializer-proven; **validated against real ground truth**: loading all 64 records and matching voice-0 vs the live capture identifies it as record 0 "SY Poly Synth" and reproduces it **23/24** (only BEND RANGE off). FX selectors stride-4 verified; byte→step = identity; noise gate verified. |
| Panel→engine param coverage | 72% | **Apply order proven STATIC** (positional descriptor walk `sub_33BFC0`; DB=750+position; offset+tableId in `juno_param_table.h`) — overturned the "not statically recoverable" claim. Bound + capture-validated: pulse-osc level (DB770→4208), VCA tone (DB793→9584), **LFO KEY TRIG (DB756→1872, fixes per-note vibrato reset)**, **PWM SOURCE demux (DB759→3888/3904/3920/3936)**. FX-send transforms proven static (= curve-22 = step/255); **DELAY LEVEL→102528 confirmed**, REVERB LEVEL node binding still unconfirmed. Remaining: FX-A delay activation (host-side output gains), ASSIGN MODE (voice-manager), a few switches, BEND transform. |
| Param registry (name→engine slot) | 100% | All 1121 bindings extracted from the asm (`refs/param_registry.json`). |
| Param-apply engine (step→coefficient) | 98% | LUT mechanism bit-exact (88/88); identity byte→step + noise byte-0 gate verified. |
| Host layer — preset loader + RT synth API | 70% | Capture-free preset loader + CLI host (`host/juno_render.c`) + **real-time polyphonic synth API** (`host/juno_synth.c`: create/load/note-on-off/process-block with 8-voice allocation). Only the thin **VST3 SDK binding** (IAudioProcessor/IEditController glue + state chunk) remains. |
| **Overall (weighted)** | **~90%** | **Every audio DSP block is bit-exact-verified, and any factory patch renders fully capture-free (incl. the chorus CV, now recovered).** Remaining: the per-patch reverb-decay damping rows and the VST3 SDK wrapper. |

See `docs/PORT_STATUS.md` for the detailed accounting and `docs/` for per-subsystem maps.

## Status (short)

- **Audio DSP: bit-exact verified.** Every block (voice, ×2 chorus, delay+DL2,
  reverb, FX-A/flanger, `chorus_init`, `ramp_engine`, arp core+selectors, helpers,
  param-apply LUT) has been diffed line-by-line against the decompile+asm with zero
  discrepancies. The init layer is 2289/2289 bit-identical.
- **Capture-free preset path works.** The bank decode (deserializer-proven, incl.
  the stride-4 FX selectors) + the identity byte→step + the verified noise gate let
  the C loader (`src/juno_preset.c`) apply any factory patch; `host/juno_render.c`
  renders it to WAV with its chorus + HALL2 reverb derived from the patch.
- **Fully capture-free.** The last believed-capture-only value — the JUNO chorus CV
  — was recovered from the binary (`(step·11)/255−8`, steps 62/50, bit-exact;
  `src/juno_fx.c`). Every coefficient on the SQ-ARPG path now derives from the
  decompile/data.
- **Remaining:** the per-patch reverb decay-knob damping rows (a small data
  extraction) and the VST3 SDK wrapper (standard plugin boilerplate around the
  finished engine). See `docs/PORT_STATUS.md`, `docs/FX_MODE_COEFFICIENTS.md`.

## Method

Transcribe function-by-function from the decompile, top of the call tree down,
naming struct fields as we go; resolve any args Hex-Rays dropped from the matching
disassembly; validate each piece's data layer bit-exact against the binary's own
constants. Coefficients come from the decompile only.

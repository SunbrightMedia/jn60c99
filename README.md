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
| Panel→engine param coverage | 100% | **Every JUNO-60 panel parameter is bound + capture-validated bit-exact.** Complete DB→engine map (`refs/db_engine_map_full.json`) from the static positional descriptor walk (`sub_33BFC0`; DB=750+position) + the corrected stride-4 block-2 decode (`241+(db-854)*4`). Applied: 24-param LUT map + pulse/VCA-tone + LFO KEY TRIG + PWM-source demux + portamento (tid7) + tempo-sync + BEND RANGE (`LUT21(step+160)`) + arp + 5 FX selectors + FX-A DELAY + REVERB LEVEL (10759440) + REVERB TIME (10759360) + VCF LFO MOD (7344, tid47) + VCA LEVEL (101072 dB curve) + EFFECT DEPTH (102576) + **VCA ENV-SELECT** (DB855 demux — fixed 19/64 presets that use ENV1/GATE not the ENV2 default). Every "host-side"-flagged param was ultimately found statically. The one unbound knob, EFFECT TONE (DB874), is *genuinely* host-side and inert for JUNO chorus modes (it only colours the non-JUNO overdrive/crusher effects). Master tune & block-2 mod-matrix are 0/center across all 64 factory banks, so the engine default is already bit-exact. |
| Param registry (name→engine slot) | 100% | All 1121 bindings extracted from the asm (`refs/param_registry.json`). |
| Param-apply engine (step→coefficient) | 98% | LUT mechanism bit-exact (88/88); identity byte→step + noise byte-0 gate verified. |
| Host layer — preset loader + RT synth API | 70% | Preset loader + CLI host (`host/juno_render.c`) + **real-time polyphonic synth API** (`host/juno_synth.c`: create/load/note-on-off/process-block with 8-voice allocation). Remaining: the VST3 SDK binding **and** the capture-seed dependency below. |
| **Capture-seed elimination (in progress)** | ~75% | Originally 279 captured coeffs. **Eliminated capture-free, verified against the binary:** 98 shared FX filter templates (`juno_fx_filter_coeffs.c`), 48 HALL2 reverb coeffs (`juno_reverb_coeffs.c`), and the parameter construction layer — `sub_3A66B0` construction-default writer (`juno_construction_defaults.c`) + the `sub_388170` registration defaults (`juno_registration_defaults.c`, the one function Hex-Rays couldn't lift; recovered via `.rdata` + the Juno-106 cross-reference). The capture-free param pipeline reproduces **102/110** of the record-0 verification oracle. Remaining: ~3 preset params needing the deserializer position-map, the note-on runtime state (velocity/LFO-tempo targets), then SR-parameterization to render at 44.1 kHz. |
| **Sound accuracy (SQ ARPG)** | — | After exhaustively perturbing every capture offset and tracing each audible one: **no confident remaining static-coefficient bug.** DCO mix / VCF / 2×ADSR / FX / LFO-rate (a clean 1/8-note sync @120 BPM) are all correct; the note-on velocity handler is a **dead end** (JUNO-60 isn't velocity-sensitive). Any residual perceived difference most plausibly lives in **arp performance** (the host harness's single-voice retrigger vs the plugin's polyphonic arp voicing/pattern) and/or **genuine analog-domain modeling** — not transcription error. No SQ-ARPG capture exists to verify bit-exactness for this specific preset. |
| **Overall (weighted)** | **~90%** | Every audio DSP *block* is bit-exact-verified; the loader is validated vs the record-0 capture; 146/279 capture coefficients eliminated (FX + reverb, `.rdata`-verified). Remaining: the 133-coeff voice-region capture residue (mostly sonically inert / global constants), per-patch reverb-decay rows, and the VST3 wrapper. |

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
- **NOT fully capture-free (corrected).** The render still seeds engine state from
  `src/runtime_coeffs_data.c` — 279 coefficients **memory-captured from the
  "PD The Juno Pad" preset**, of which 249 survive unmodified into every render
  (the loader overwrites ~40). The earlier "fully capture-free" claim, and the
  claim that `state_dump/state_t0.bin` is an SQ-ARPG capture, were both wrong; see
  `docs/PROVENANCE_CORRECTION.md`. The only genuine captures held are record 0
  ("SY Poly Synth", `src/captured_patch.c`) and "PD The Juno Pad" — **neither is
  SQ Dynamic ARPG.**
- **Remaining:** the per-patch reverb decay-knob damping rows (a small data
  extraction) and the VST3 SDK wrapper (standard plugin boilerplate around the
  finished engine). See `docs/PORT_STATUS.md`, `docs/FX_MODE_COEFFICIENTS.md`.

## Method

Transcribe function-by-function from the decompile, top of the call tree down,
naming struct fields as we go; resolve any args Hex-Rays dropped from the matching
disassembly; validate each piece's data layer bit-exact against the binary's own
constants. Coefficients come from the decompile only.

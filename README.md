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
| Init / coefficient layer (`engine_init`) | 95% | Bit-exact: 2289/2289 stores match the binary. |
| Voice DSP — DCO/HPF/VCF/2×ADSR/VCA/LFO/unison | 85% | Transcribed line-by-line; audibly validated; not yet per-sample A/B'd. |
| Polyphony (8 voices, M.CV fix) | 90% | All 8 voices render; voice 0 bit-identical; M.CV pitch-base bug fixed. |
| Master mix + BBD chorus | 80% | Chorus DSP **bit-exact vs asm** (every depth constant matches rdata). Rate/depth *inputs* still PD-captured, not SQ-ARPG's. |
| System-8 FX-A slot (the `v551`/EFX effect) | 15% | Identified + routed (separate from chorus); faithful render needs its runtime coeffs. Currently thru-bypassed. |
| Reverb (CJu60Sim HALL2) | 10% | Tables recovered; solver graph not transcribed. Biggest audible gap. |
| Delay FX | 30% | Coeff tables recovered; multimode DSP partially transcribed. |
| Arpeggiator (`CArpeggio`) | 80% | Faithful scan/clock core; UP/range/STEP decoded from the deserializer. |
| Preset / bank decode | 85% | Format proven from the deserializer (not guessed). |
| Param-apply engine (LUT + switch) | 70% | Mechanism bit-exact (88/88 LUT, 69/69 FX); not every param family routed. |
| DB→engine runtime bridge (preset → coeffs) | 30% | Red-black-tree binding is runtime-only; partially reconstructed. |
| VST3 host wrapper (MIDI / automation / state save) | 0% | Not started. |
| **Overall (weighted)** | **~50%** | Validated voice + polyphony + arp core are the de-risked core; FX, full param-apply, and host wrapper are the bulk remaining. |

See `docs/PORT_STATUS.md` for the detailed accounting and `docs/` for per-subsystem maps.

## Status (short)

- **Data layer:** bit-exact and proven (init 2289/2289; param-apply LUT 88/88; FX
  coeffs 69/69 — identical uint32 bit patterns vs the binary).
- **Audio DSP:** transcribed line-by-line from the decompile, **not yet**
  numerically A/B-verified against the plugin. Renders are in the ballpark, not
  proven identical.
- **Next:** runtime translation of the DB→engine parameter bridge (the
  runtime-built mapping from preset values to engine coefficients), which also
  carries the open pitch-drift investigation. See `docs/PORT_STATUS.md`,
  `docs/DB_ENGINE_BRIDGE.md`, `docs/CHORUS_VIBRATO_DIAG.md`.

## Method

Transcribe function-by-function from the decompile, top of the call tree down,
naming struct fields as we go; resolve any args Hex-Rays dropped from the matching
disassembly; validate each piece's data layer bit-exact against the binary's own
constants. Coefficients come from the decompile only.

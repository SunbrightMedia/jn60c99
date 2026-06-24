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

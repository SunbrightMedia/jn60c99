# JUNO-60 DSP → C99 (exact-port restart)

> ## ⭐ THE GOAL (see [GOAL.md](GOAL.md) — read it first)
> A **bit-exact C99 port of the DSP engine**, plus **whatever it takes to sound
> EXACTLY the same as the original plugin, in the browser** — kept portable C99
> so it can **eventually run on a microcontroller (Teensy)**. Ground truth is
> ONLY the decompiled/compiled binary. "Sounds exactly the same" is the
> acceptance test, not "N params bound." Full goal + rules in **[GOAL.md](GOAL.md)**.

A C99 port of the Roland Cloud **Cloud 60** (JUNO-60 emulation) **DSP audio
engine**. The goal is an **exact, structural transcription** of the plugin's
actual algorithm — same operations, same signal flow, same coefficients — not a
sound-alike approximation.

**THE RULE:** the decompiled plugin is the spec. We transcribe it. We do **not**
fit curves, tune constants to match audio, or substitute an easier stand-in for
a hard-to-read DSP block. Read `docs/HANDOFF_IDA.md` in full before touching code.

## Target facts (binary-derived)

- Plugin: Roland Cloud **Cloud 60**, x86-64 PE.
- **ImageBase `0x180000000`.**
- **Per-voice render @ `0x180369070`** (RVA `0x369070`) — primary extraction seed.
- 6-voice poly; DCO (saw + variable-pulse + square sub + noise), non-resonant
  HPF, 24 dB/oct resonant LPF (IR3109-style 4-pole), two ADSRs (filter + amp),
  one delayed triangle LFO, stereo BBD chorus (modes I / II / I+II).

## Workflow

1. **Extract** (Windows, IDA Pro 9.3, x86-64 decompiler): run
   `tools/extract_dsp.py` on the auto-analyzed database. Output → `dsp_dump/`
   (`MANIFEST.md`, `callgraph.txt`, `constants.txt`, per-function `.c`).
2. **Transcribe** function-by-function from the dump, top of the call tree down,
   naming struct fields as we go. Coefficients come from `constants.txt` only.
3. **Validate per-stage** against the decompile's intermediate signals — never
   end-to-end RMS. RMS/NaN checks are crash smoke-tests only.
4. Assemble the full engine only once each stage matches.

## Runtime constants (chorus)

A few chorus coefficient *values* are heap-allocated at runtime and don't appear
in the static `.rdata` dump. Reuse **only** the real Frida golden-dump value
files from the old project when reaching the chorus — nothing else from the old
project (no C source, no fitted curves, no RMS fingerprint).

## Layout

| Path | Purpose |
|------|---------|
| `docs/HANDOFF_IDA.md` | Authoritative project brief — read first. |
| `tools/extract_dsp.py` | One-time IDA 9.3 DSP call-tree extractor. |
| `dsp_dump/` | Decompiled extraction output (populated by the script). |
| `src/` | The C99 port. |

# JUNO-60 (JU-06A) → C99, bit-exact

> ## ⭐ THE GOAL (see [GOAL.md](GOAL.md) — read it first, it is binding)
> A **bit-exact C99 port of the DSP engine**, plus **whatever it takes to sound
> EXACTLY the same as the original plugin, in the browser** — kept portable C99
> so it can **eventually run on a microcontroller (Teensy 4.1)**. "Sounds exactly
> the same" is the acceptance test, not "N params bound."

Ground truth is ONLY the original plugin binary, pinned in [`truth/`](truth/)
(checksum-verified) and *executed* under emulation to produce every proof. The
port is **self-proving**: no captures, no ear A/B, no fitted curves — if a value
isn't derivable from the binary's own code, that is stated, not guessed. Agent
rules live in [`CLAUDE.md`](CLAUDE.md).

**Live status: [`PROVENANCE.tsv`](PROVENANCE.tsv)** — the per-subsystem ledger of
what is PROVEN vs RECONSTRUCTED vs CAPTURED vs UNVERIFIED. The project is done when
`make verify` is green (zero non-PROVEN rows).

## Quick start

```
make libjuno.so     # build the engine (shared lib for the GUI + gates)
make test           # functional test suite
make verify         # test + provenance ledger — the honest finish line
python3 tools/verify/truth.py     # verify ground-truth checksums
bash gui/web/build.sh             # rebuild the WASM app (needs emscripten)
node tools/verify/wasm_golden.mjs # prove WASM == native, bit-exact
```

## Layout

| Path | Purpose |
|------|---------|
| `GOAL.md` / `CLAUDE.md` | The goal (user's words) / agent project memory. |
| `PROVENANCE.tsv` | Per-subsystem proof ledger — the status authority. |
| `truth/` | Ground truth: the `.vst3`, `Script.xml`, factory bank + SHA256SUMS. |
| `src/` | The C99 port (engine, recall, render, arp, FX). |
| `gui/` | ctypes bridge + the in-browser WASM app (`gui/web/`). |
| `tests/` | Functional suite incl. golden corpora (Teensy 44.1 kHz). |
| `tools/verify/` | The gates: the Unicorn oracle + the executable proofs. |
| `refs/` | Full IDA decompile archive (provenance for transcriptions). |
| `docs/` | CLAIMS.md (claims ledger) + subsystem notes. |

## Engine facts (proven from the binary)

- x86-64 PE, preferred ImageBase `0x180000000`; per-voice render RVA `0x369070`;
  engine state block `0xA83010` bytes = 8 voice blocks (10512 B stride) +
  master/FX; recall setter RVA `0x3B9A30`; recall enumerator RVA `0x3B48A0`.
- Signal path: DCO (saw + variable-pulse + square sub + noise), HPF, 4-pole
  resonant LPF, two ADSRs (filter + amp), delayed-triangle LFO, stereo BBD
  chorus (I/II), per-patch delay + reverb + effect modes, arpeggiator.
- Bit-exact at 44100 / 48000 / 96000 Hz (SR-variant curve arms).
  `-ffp-contract=off` is load-bearing: the reference is x86 SSE2 with no FMA.

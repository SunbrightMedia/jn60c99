# JUNO-60 (JU-06A) → C99, bit-exact — and onto real hardware

A **bit-exact C99 port** of the Roland Cloud JUNO-60 VST3 DSP engine, proven
against the plugin's own machine code, playable in the browser, and being
carried onto ESP32-S3 hardware as a real instrument. The method is designed to
be REPEATED for the next synth (the JX-3P port is underway in `jx3p/`).

**The one rule:** the original plugin binary (pinned + checksummed in
[`truth/`](truth/)) is the ONLY ground truth. Every constant is proven by
EXECUTING the binary under emulation — no captures, no ear A/B, no fitted
curves. The port is self-proving: `make verify` green = zero non-PROVEN rows
in [`PROVENANCE.tsv`](PROVENANCE.tsv) (status: 20/20 PROVEN).

## Read these, in this order

1. [`END_GOAL.md`](END_GOAL.md) — WHAT we build (user's words, binding)
2. [`CLAUDE.md`](CLAUDE.md) — rules + live state (the constitution)
3. [`FINAL_GUIDE.md`](FINAL_GUIDE.md) — the only status page (tracks A–E)
4. [`docs/INDEX.md`](docs/INDEX.md) — every doc classified, with the question
   it answers
5. [`docs/HISTORY.md`](docs/HISTORY.md) — the full dated log

## The arcs

| Arc | Where | State |
|---|---|---|
| Desktop bit-exact port | `src/` + `tools/verify/` | SEALED — `make verify` green |
| Browser (WASM) | `gui/web/` | Shipped; `wasm_golden` proves WASM == native |
| Engine B (fast fork for hardware) | `engine_b/` | Trunk bit-exact; S3 fork under budget work |
| ESP32-S3 firmware | `esp32s3/` | Playable; honest 3-voice budget pending (JUNO-3V staged) |
| CLASSIC port (1982 panel only) | `EB_CLASSIC` flag + [`docs/CLASSIC_PANEL.md`](docs/CLASSIC_PANEL.md) | 6 voices + chorus on ONE chip — image staged, unflashed |
| Carrier board (4 × DevKitC-1) | [`docs/hardware/`](docs/hardware/) | Schematic in progress (user's hands) |
| JX-3P (the repeat) | `jx3p/` | Recall proven; render A/B seed fix open |

## Quick start (desktop)

```
make libjuno.so     # build the engine (shared lib for the GUI + gates)
make test           # functional test suite
make verify         # + the LIVE plugin comparisons — the honest finish line
python3 tools/verify/truth.py     # verify ground-truth checksums
bash gui/web/build.sh             # rebuild the WASM app (needs emscripten)
node tools/verify/wasm_golden.mjs # prove WASM == native, bit-exact
```

ESP32-S3: see `esp32s3/LISTEN.md` (build + the canonical flag line) and
`esp32s3/flash/README.md` (prebuilt images, flash commands, no toolchain
needed). Engine-B gates: `tools/engineb/` (`o2_gates.sh`, `o3_gates.sh`, …).

## Layout

| Path | What |
|---|---|
| `truth/` | The plugin + Script.xml + factory bank, checksummed. Paths ONLY via `tools/verify/truth.py` |
| `src/` | The FROZEN bit-exact port (C99). Do not touch except through a gate |
| `tools/verify/` | The canonical gates + the Unicorn oracle (`e2e_emu.py`) |
| `engine_b/` | The restructured fast engine (trunk = bit-exact; fork = S3 flags) |
| `esp32s3/`, `daisy/`, `teensy/` | Device firmware (S3 is the live target) |
| `gui/` | Web app (WASM) + Tk test GUI |
| `docs/` | All findings — start at `docs/INDEX.md` |
| `probes/` | Executed evidence per investigation (each dir has a README) |
| `jx3p/` | The second port — proof the method repeats |
| `refs/` | The decompile archive (provenance for READ claims) |

Agent rules, hard covenants (captures are forbidden), and the live state all
live in [`CLAUDE.md`](CLAUDE.md).

# Phase 7 — final gate

The bit-exact ground truth for this port is the plugin's own machine code (run under
Unicorn) and the states it produces. Every gate below compares OUR C99 engine against
that ground truth. Reproduce with `scratchpad/oracle/run_final_gate.sh`.

| Gate | Result | What it proves |
|------|--------|----------------|
| Native test suite (17 tests) | **17/17 pass** | Recall, note path, prepare, arp, voice alloc, bend/mod, condition scatter, per-parameter setter — all locked bit-exact at 44.1/48/96 kHz |
| Voice cold-load A/B (64 patches) | **64/64 bit-exact** | Every factory patch's voice stream (osc+VCF+VCA+both ADSRs) is sample-identical to the plugin from a cold load |
| Master/FX cold-load A/B (64 patches) | **64/64 bit-exact** | The FULL pipeline (voices → chorus/delay/reverb → stereo out) is sample-identical over the entire 8000-sample captured window — every patch, zero residuals |
| Random-patch recall A/B (100 novel patches) | **100/100 bit-identical** | The applier reproduces the plugin's value-tree recall on arbitrary patches, not just the factory bank — no overfitting |
| Per-parameter setter (25 params × 3 rates) | **bit-exact** | The "0..255 byte → parameter" interface IS the recall dispatch, one parameter at a time |
| WASM render (10 patches × 3 rates × 3 chorus) | **90/90 audible + finite** | The shipped browser engine renders correctly through the full master path |

## 64/64: no known divergence remains

Every factory patch renders **sample-identical** to the plugin through the complete
pipeline from a cold load. The last three items to land (see `docs/FX_COLDLOAD_TODO.md`
for the derivations):

1. **REVERB-TYPE-dependent tap tables** — types 0/1 run their own reverb stage sets;
   our recall now rewrites the 34-int tap table per type (the plugin's own dispatch
   output, all 3 rates).
2. **Tempo-synced DELAY TIME** — 34/64 patches sync the delay to tempo: the TIME byte
   quantizes to one of 16 note divisions at the baked 128-BPM recall default
   (`ms = beats × 60000/BPM`), bit-exact 48/48 divisions × rates, with the live-tempo
   law verified at 60/88/176 BPM and wired to the bridge's BPM path.
3. **DELAY TYPE 1 (dual delay) wired** — both instances populated exactly as the
   captured states (graft-proven render-exact before wiring).

## What "correct" means here

Bit-exactness is the *verification method*, not the goal — the goal is that the port
**sounds like the plugin**. With 64/64 sample-identical cold-load renders, 100/100
random-patch recall, and a bit-exact per-parameter dispatch, the two are now the same
statement over everything the harness can observe. The port is playable in the browser
(`gui/web/`, WASM) at the host sample rate with no resampler, carrying every fix.

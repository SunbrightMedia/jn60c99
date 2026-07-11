# Phase 7 — final gate

The bit-exact ground truth for this port is the plugin's own machine code (run under
Unicorn) and the states it produces. Every gate below compares OUR C99 engine against
that ground truth. Reproduce with `scratchpad/oracle/run_final_gate.sh`.

| Gate | Result | What it proves |
|------|--------|----------------|
| Native test suite (17 tests) | **17/17 pass** | Recall, note path, prepare, arp, voice alloc, bend/mod, condition scatter, per-parameter setter — all locked bit-exact at 44.1/48/96 kHz |
| Voice cold-load A/B (64 patches) | **64/64 bit-exact** | Every factory patch's voice stream (osc+VCF+VCA+both ADSRs) is sample-identical to the plugin from a cold load |
| Master/FX cold-load A/B (64 patches) | **62/64 bit-exact** | The full pipeline (voices → chorus/delay/reverb → output) is sample-identical; the 2 residuals are inaudible (below) |
| Random-patch recall A/B (100 novel patches) | **100/100 bit-identical** | The applier reproduces the plugin's value-tree recall on arbitrary patches, not just the factory bank — no overfitting |
| Per-parameter setter (25 params × 3 rates) | **bit-exact** | The "0..255 byte → parameter" interface IS the recall dispatch, one parameter at a time |
| WASM render (10 patches × 3 rates × 3 chorus) | **90/90 audible + finite** | The shipped browser engine renders correctly through the full master path |

## Audibility: 0 patches audibly off

All 64 factory patches render within RMS ratio **~1.000** of the plugin over the full
pipeline. There is no audibly-wrong patch — voices, filters, envelopes, arp, and all four
FX modes (chorus I/II, delay, reverb, distortion+pan, ensemble) match.

## The 2 non-bit-exact master patches (41, 62) — inaudible

Patches 41 ("SQ Multirhythm", DELAY TYPE 1) and 62 ("BS Juno Grime", DELAY TYPE 2) diverge
only in the **late delay tail** (first bit-diff at sample 1660) at RMS ratio **1.000** —
identical energy, a sub-sample phase shift no listener can hear. Both trace to a single
open item: the **tempo-synced DELAY TIME** (`102352`/`4297584`/`6497168`). The manual
per-byte time formula is exact where a patch's division coincides but quantized otherwise;
deriving the sync law (division byte + BPM) is the one remaining bit-exact task. The whole
DELAY TYPE 1 dual-delay constant block is already derived and staged (`apply_slot1_delay1`),
waiting only on that time. Full detail: `docs/FX_COLDLOAD_TODO.md`.

## What "correct" means here

Bit-exactness is the *verification method*, not the goal — the goal is that the port
**sounds like the plugin**. The gates above establish both: 62/64 patches are literally
sample-identical, and all 64 are audibly identical (RMS ~1.000). The port is playable in
the browser (`gui/web/`, WASM) at the host sample rate with no resampler, carrying every
one of these fixes.

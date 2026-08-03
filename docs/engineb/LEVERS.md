# The levers, measured — can engine B fit the ESP32-S3?

Date 2026-08-03. Executed instructions per sample, MEASURED on the host with
callgrind: 8 voices sounding, patch 20 (chorus + delay + reverb), 48 kHz, the
whole engine built through the real gate path. Each lever is a real build, not
an estimate.

Engine B exists for one reason: to run on the ESP32-S3 with 8 voices and all FX
at 48 kHz. The budget is **3,500 cycles per sample**. This page asks whether
that is reachable, and it asks it before any more of the engine is written.

## The oversampling levers

The DCO runs at 4× the host rate into a polyphase decimator, and the ladder
filter runs 4 sub-steps. That oversampled path is **6,588 of engine B's 15,450
instructions per sample — 43 %**. It is also what makes the JUNO's aliasing
sound the way it does, so removing it is not a free win; it is a different
instrument.

| build | engine B DSP | saving |
|---|---|---|
| **as built (exact)** | **15,450** | — |
| DCO at 1× | 13,258 | 2,192 |
| decimator removed | 14,522 | 928 |
| ladder at 1× | 13,122 | 2,328 |
| **all three removed** | **10,002** | **5,448** |

## The finding

**Removing every oversampling stage — which changes the sound and is therefore
not something we would ship — leaves 10,002 instructions per sample against a
3,500 cycle budget. That is 2.9× over.**

So the gap is not an oversampling problem. Nothing in the 4× path can close it.

What remains at that floor, per sample:

| | instr/sample |
|---|---|
| ladder filter | 2,722 |
| VCA / HPF | 1,448 |
| envelopes | 1,264 |
| DCO at 1× | 819 |
| FX (chorus + delay + reverb) | 1,289 |
| filter CV | 576 |
| pitch polynomial | 536 |
| mod CV, CV/gate, rest | ~1,350 |

There is no single item to attack. It is the whole synthesiser.

## The other levers, and why they do not rescue it

* **6 voices instead of 8** — the only compromise `docs/trackb/CONSTRAINTS.md`
  permits, and only as a last resort. Per-voice cost at the floor is about
  1,089, so two fewer voices saves ~2,178: **7,824, still 2.2× over**.
* **Both S3 cores** — roughly halves the per-voice work, though the FX do not
  split cleanly. Optimistically ~5,000: **still 1.4× over**.
* **All three together** — no oversampling, 6 voices, two cores — lands near
  **3,900, still above 3,500**, and by then the engine is neither exact nor the
  instrument that was asked for.

## Honest statement of the uncertainty

These are **host x86-64 instruction counts**, not S3 cycles. The comparison to
3,500 assumes roughly one instruction per cycle on an in-order core running from
internal RAM. That assumption is **MODELED**. No engine B code has ever run on
an ESP32. Xtensa may do better on some sequences and worse on others; the
software float divide is a known worse case.

What is MEASURED is the **ratio** between builds, and the ratio is what this page
rests on: the exact engine is 4.4× the budget, and the floor of a sound-changing
rewrite is still 2.9×.

## What this means

**On these numbers, the ESP32-S3 at 8 voices with all FX at 48 kHz is not
reachable by rearranging this engine.** That is a conclusion about the target,
not about engine B's correctness — engine B is bit-exact against the plugin
binary at both sample rates, and that result stands.

The choice now belongs to the user, and it is between:

1. **A faster part.** The gap is roughly 3× at the floor and 4.4× exact. A part
   with several times the throughput removes the problem instead of negotiating
   with it.
2. **Fewer voices plus both cores plus a sound-changing rewrite.** Measured
   above at ~3,900 — still short, and it gives up exactness, which was the
   point.
3. **Change the target.** A lower sample rate is currently forbidden by the
   constraints document; so is degrading the FX.

**The next measurement that would change any of this** is engine B running on
real S3 silicon, because every figure here is a host count. That measurement
needs the board, and it should happen before anyone acts on option 1.

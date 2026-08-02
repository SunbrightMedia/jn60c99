# engine_b/wip — modules that are written but NOT gated

A file here is NOT part of any build and NOT part of any gate. It sits outside
`engine_b/shim/` on purpose: `null_b.py` picks up a module the moment its shim
directory exists, so leaving a failing shim in place would turn `make engineb`
red and, worse, would let someone assume it works because it is present.

## decim_voice_render.c — the 4x polyphase decimator. FAILING.

The module itself is `engine_b/eb_decim.{h,c}`. It compiles and it is wired,
and it DIVERGES.

MEASURED, `null_b.py --module decim`, full 30-scenario set:
**17 of 30 FAIL, worst global residual −36.6 dB.** Thirteen scenarios are
EXACTLY 0, so the transcription is close but is wrong somewhere specific.

### What has been checked and is NOT the cause

* **The tap map.** All 32 taps were derived from the cell addresses and then
  checked back one at a time: cell = phase_base + 16·age, phase bases 4944 /
  5072 / 5200 / 5328. Every one of the 16 pairs matches.
* **The accumulation order.** Reproduced term for term, left-nested, from
  `src/voice_render.c:2137-2173`.
* **The removed shift.** Exactly the 30 `JI` moves were removed — the four
  8-deep lines plus the biquad's 5504←5488 and 5488←5472 — printed and checked
  against the source.
* **Conditionality.** The shift is not inside any branch, so removing it
  unconditionally is not the error.
* **State lifetime.** The first hypothesis was that engine B's per-voice state
  is a `static` in the shim while the harness builds a NEW context per
  scenario, so scenario N+1 would inherit scenario N's filter history. Tested
  by resetting on a context change: it fixed exactly ONE scenario, 18 → 17.
  So it is real but it is not the main cause.

### RESOLVED: the MODULE is correct. The defect is in the SHIM.

`engine_b/tests/test_decim.c` was written and run. It drives `eb_decim_tick`
and a verbatim transcription of the port's own arithmetic — the 30-move shift
from `:1697-1702` and the FIR and biquad from `:2134-2173`, in a plain cell
array — from the same inputs, and compares bit patterns.

MEASURED: **300,000 samples, 0 differing. PASS.**

So the tap map, the accumulation order, the biquad's state rotation and the
rotating-index replacement for the shift are all correct. **The remaining defect
is in how the shim is wired, not in `eb_decim.c`.**

The unit test is a DIFFERENTIAL, not a proof: its reference side is a hand
transcription and could share a misreading with the module. What it does prove
is that the module matches that reading exactly, which moves the search from
sixty lines of arithmetic to the shim.

### What to try next, in order

1. **State lifetime.** The strongest remaining suspect and the one the
   standalone engine removes. The shim's `static eb_decim_state EBD[8]`
   outlives the engine context; the harness builds a new context per scenario.
   Resetting on a base-pointer change fixed one scenario of thirty, but that
   test is unreliable — `malloc` reuses addresses, so a new context can land on
   the old pointer and skip the reset. A trustworthy test needs one scenario per
   process.
2. ~~**Cell readers.**~~ CHECKED and clear. Outside the FIR, the only code that
   touches cells 4944..5440 / 5472 / 5488 / 5504 is the DCO writing the four
   fresh sub-samples (`src/voice_render.c` :1807, :1911, :2015, :2117, all
   after the shift and before the FIR) and `src/chorus_init.c` zeroing them at
   power-on — which is exactly what engine B's zero-initialised state matches.
   No reader is left unserved by dropping the shift.
3. Then finish the module in `eb_voice`, where the state belongs — the fields
   are already declared (`decim_h`, `decim_w`, `decim_b1..b3`).

### The design finding, which outlives this bug

**A shim cannot host engine B's per-voice state.** Every module gated so far
keeps its state in the port's cells and reloads it each sample, which is why
`eb_vcf_hist_set`/`get` alone cost 9,088 instructions per sample of pure
marshalling. This is the first module that tried to own its state, and the
harness has no place to put it: a `static` array outlives the context.

That is not a reason to keep marshalling. It is the concrete argument for the
standalone engine, where engine B owns an `eb_voice` and the port's cells are
gone. This module should be finished there rather than forced into a shim.

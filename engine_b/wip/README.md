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

### What to try next

1. Unit-level A/B: drive `eb_decim_tick` and the port's own FIR with the same
   32 taps and the same biquad state, and find the first differing sample. That
   localises it in minutes; the scenario gate only says "somewhere".
2. Suspect the biquad's state rotation ordering before anything else. The
   port rotates 5504/5488 at line 1701, several hundred lines before the biquad
   runs at 2159, which is exactly the kind of split this transcription had to
   reassemble by hand.

### The design finding, which outlives this bug

**A shim cannot host engine B's per-voice state.** Every module gated so far
keeps its state in the port's cells and reloads it each sample, which is why
`eb_vcf_hist_set`/`get` alone cost 9,088 instructions per sample of pure
marshalling. This is the first module that tried to own its state, and the
harness has no place to put it: a `static` array outlives the context.

That is not a reason to keep marshalling. It is the concrete argument for the
standalone engine, where engine B owns an `eb_voice` and the port's cells are
gone. This module should be finished there rather than forced into a shim.

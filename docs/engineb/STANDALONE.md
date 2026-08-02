# The standalone engine — scope, and why the measurements force it

Date 2026-08-02. Every number here is MEASURED. Where a figure is an estimate it
says so.

## Why this step exists

Engine B today is ten modules living inside the port's own `voice_render.c`.
Each module keeps its state in the **port's memory cells** and reloads it every
sample, because that is the only way `null_b.py` can substitute one module at a
time and attribute a divergence to it.

That arrangement has done its job — every module is BIT-EXACT against the plugin
binary at 44.1 kHz and 48 kHz, as a whole engine — and it has now hit two hard
limits, both measured, not predicted.

### Limit 1 — the marshalling dominates the cost

Whole-engine profile, host, callgrind, 8 voices sounding, patch 20 (chorus +
delay + reverb), 48 kHz, executed instructions per sample:

| | per sample | share |
|---|---|---|
| `juno_voice_render` self — almost all shim marshalling | 27,585 | 56.6 % |
| all engine B DSP modules together | ~17,000 | ~35 % |
| **total** | **48,748** | |

Inside that 27,585, the split by region:

| region | per sample |
|---|---|
| marshalling — VCF ladder state in and out | 15,760 |
| marshalling — pitch/PWM CV | 2,936 |
| marshalling — VCF cutoff CV | 2,720 |
| marshalling — VCA/HPF and the envelopes | 2,344 |
| **genuinely unwritten blocks** | **3,825** |

Two lines alone — copying the ladder's filter history in and out of the port's
cells — cost **9,088 instructions per sample**.

So roughly **24,000 of the 48,748 is harness glue**, not engine. **Engine B's
true cost has never been measured**, and every cost figure quoted in this repo
before today is inflated by that glue. An estimate of the standalone engine, by
subtraction, is near **20,000 instructions per sample** — labelled an ESTIMATE,
and the whole point of this step is to replace it with a measurement.

### Limit 2 — a shim cannot own state

PROVEN by trying it. `engine_b/eb_decim.c` is the first module that keeps its
own per-voice state instead of the port's cells. It cannot be gated as a shim:
the state is a `static`, and the harness builds a NEW engine context for every
scenario, so scenario N+1 inherits scenario N's filter history. Resetting on a
context change fixed exactly one scenario of thirty, so that is real but minor —
the module also has a transcription defect, recorded in `engine_b/wip/README.md`
with everything already ruled out.

The lesson is structural, not incidental: **every module that owns its state
needs the standalone engine to live in.** Continuing to write blocks as shims
would mean writing each one twice.

## What the standalone engine is

`eb_engine_render(eb_engine *e, float *outL, float *outR)` — one function that
produces one stereo sample from engine B state only, with no `juno_*` code and
no port memory cells anywhere in the path. `eb_engine`, `eb_voice` and `eb_fx`
already exist in `engine_b/eb_types.h`; today they are only partly used, and
`eb_engine.c`'s own allocator and note handling are UNPROVEN and un-gated (audit
finding F4).

## How it gets gated — this is the part that must not be weakened

The standalone engine is compared exactly as the shims are, and by the same
tools. It replaces `juno_driver.c` (the `skeleton` module's slot) rather than a
region inside `voice_render.c`, so:

* `null_b.py --module standalone` — engine B's whole output against the port's,
  all 30 scenarios, 17 with idle prefixes. Must be **EXACTLY 0**.
* `plugin_check.py --module standalone` — against the PLUGIN binary, the
  authority, at 44,100 and 48,000 Hz. Must be **BIT-EXACT**.
* A teeth bracket in `null_b.py --teeth`, measured like the other nine, so
  "green" means something.

It does **not** get a relaxed threshold for being new. The accuracy standard is
unchanged: sample-domain null, EXACTLY 0 against the port, with no spectral or
statistical fallback.

## Order of work

1. **`eb_voice` owns the per-voice state the modules currently keep in port
   cells** — the ladder history first, since it is the largest single cost.
2. **Finish `eb_decim`** in that home, and find its defect with a unit-level A/B
   against the port's own FIR rather than with a scenario gate.
3. **Write the remaining blocks** — noise SVF, CV/gate conditioning, the voice
   sum — which the shim measurement puts at only 3,825 instructions per sample
   combined, so they are a correctness job, not a cost one.
4. **Gate the standalone engine** by the three gates above.
5. **Measure it.** This is the first cost number for engine B with no harness in
   it, and it is the number that decides whether the ESP32-S3 target is met.

Step 5 is the point. Everything before it exists so that the number is real.

## What is deliberately NOT in this step

* No optimisation. The standalone engine must first be BIT-EXACT; the profile
  that follows it is what chooses the next lever. Optimising before that
  measurement would repeat the mistake the DCO work already exposed, where a
  model overcharged 12,000 cyc/sample of calls that never execute.
* No change to `src/`. It stays frozen and remains the proxy oracle; the plugin
  stays the authority.

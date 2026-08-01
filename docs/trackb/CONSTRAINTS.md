# TRACK B — BINDING CONSTRAINTS (user-set, 2026-08-01)

These are the user's own words and they override every default, plan, or
convenience elsewhere in the Track B documents.

## The target is not negotiable

> "you MUST achieve this goal, but if you cannot, drop to 6 voices first. that is
> the ONLY scenario you may compromise on, and it MUST BE THE LAST RESORT. keep
> trying for as much as possible"

Ranked, and binding:

1. **8 voices, all FX, 48 kHz, on the Daisy Seed, sonically accurate.** This is
   the goal. Pursue it to exhaustion.
2. **6 voices is the ONLY permitted compromise, and only as a LAST RESORT.**
3. **Nothing else may be given up.** Not the FX — not one of them, not their
   quality. Not the sample rate. Not the sonic character of the DCO/VCF/ENV.

An earlier default of mine ("FX quality first, then voice count") is REVOKED.
FX are not a sacrifice candidate.

## Sample rate: 48000 Hz. Settled.

The codec offers no 44.1 kHz, and 48 kHz is inside the port's proven rate
contract (44100/48000/88200/96000/192000).

## The measured fact that makes the permitted compromise nearly worthless

SILICON, 2026-08-01:

| voices | cyc/sample | vs 8,333 budget |
|---|---|---|
| 0 (idle floor) | 85,137 | 10.22x |
| 4 | 84,560 | 10.15x |
| 8 | 93,288 | 11.19x |

The idle floor is **91%** of the 8-voice cost, because the engine free-runs all
eight voices every sample by design. Interpolating, 6 voices is ~88,900
cyc/sample -- about **10.7x over**, against 11.19x for eight.

**So the one compromise the user allows buys roughly 5%.** It cannot be the
plan; it can only ever be a rounding-off at the very end. The required factor is
~10.7x either way, and it must come from somewhere else.

## Correction to the P1 write-up (2026-08-01, same day)

The first summary of the silicon run concluded "memory placement is not a
lever, E3 measures the D-cache at 1.05x". **That inference was wrong and is
withdrawn.**

E3 measures that the *cache* does not help. It does not measure that memory is
not the bottleneck. With a ~416 KB per-sample working set against a 16 KB L1
D-cache -- a >25x oversubscription -- cache-on and cache-off both miss nearly
everything, and 1.05x is the signature of "the cache is irrelevant", not of
"we are compute-bound".

E4 measures the thing that actually matters:

| access pattern | AXI SRAM | SDRAM | penalty |
|---|---|---|---|
| sequential | 4.98 cyc | 8.79 cyc | 1.76x |
| scattered | 12.02 cyc | **75.34 cyc** | **6.26x** |

And the memory map says the hot part is small enough to move:

* per-voice state 10,512 B x 8 voices = **86 KB**
* AXI SRAM 512 KB, DTCM 128 KB, RAM_D2 256 KB -- 86 KB fits many times over
* the 12 MB total is dominated by delay/reverb buffers, which stream
  SEQUENTIALLY (1.76x penalty) and can stay in SDRAM

**Therefore relocating per-voice state into internal RAM is a live lever with a
measured ceiling of 6.26x on the scattered portion of the cost, and it is
orthogonal to arithmetic reduction.** It is now the first thing to quantify.

Label discipline still applies: the 6.26x is SILICON for a synthetic 256 KB
walk, NOT for the engine's own access pattern. What fraction of the engine's
93,288 cyc/sample is scattered SDRAM stall is UNMEASURED, and measuring it is
the highest-value next experiment.

## Standing rules that Track B does not get to relax

* Never validate by ear; never ask the user to A/B. Gates decide.
* `src/` stays frozen and bit-exact. Track B lives in `native/`. The two claims
  are never conflated.
* No module may be rewritten behind a blind gate (charter gate #4).
* Label every number SILICON / MEASURED / MODELED / STATIC / INFERRED.

# The whole-engine cost, MEASURED × STATIC — the honest number

Date 2026-08-03 (Opus 5). Answers the question plan step P6 exists for, by the
method P3 established. Tool: `tools/engineb/engine_price.py`.

## What was measured

Every engine B module cross-compiled for the ESP32-S3 at the shipping flags and
priced over its **call graph** — each function's own body plus, for every call
site it contains, the callee's cost — including libgcc helper bodies. The DCO
is not priced this way: it is the branchiest module in the engine, so it uses
`dco_price.py`'s figure, which comes from branch rates **counted over the real
gated scenario set on real recalled patches**.

Invocation counts are the port's own structure: voice modules once per voice
(eight), envelopes twice per voice, the DCO's inner step four times per voice,
the noise LFSR and the three FX once for the whole engine.

**No QEMU in either half.** Its per-call spans are untrustworthy, and a
`sample_total` of the complete engine needs `eb_engine_render` gated and
running, which it is not yet.

## THE RESULT

| build | instr/sample | vs the 6,300–9,500 two-core instruction budget |
|---|---|---|
| default (bit-exact double pitch, division) | **63,484** | 6.7× – 10.1× over |
| **S3 shipping (fast pitch v7 + DCO reciprocal)** | **48,564** | **5.1× – 7.7× over** |

Per module, shipping build, per audio sample:

| module | per sample | | module | per sample |
|---|---|---|---|---|
| **dco** | **10,202** | | vca_hpf | 1,664 |
| **pitch (v7)** | **20,736** | | glide | 1,584 |
| lfo | 3,768 | | decim | 1,216 |
| vcf_res | 2,232 | | envgen | 1,296 |
| vcf_ladder | 1,840 | | all three FX | 1,583 |

## Cross-checks — this is why the number is credible

* The **default** build totals 63,484 against `DOUBT_AUDIT.md`'s independently
  MODELED **~69,000**. Two methods, 8 % apart.
* `eb_pitch_eval` prices at **4,281** instructions per call in the default build
  and **2,592** in the fast build, against **~4,450** and **~3,126** recorded
  independently in `pitch_hoist_result.md`. 4 % and 17 % apart.
* `eb_dcoprep` prices at 67 = its 37 static instructions plus `__divsf3`'s 30,
  which is the whole module by inspection.

## THE TRIPWIRE IS TRIPPED

The plan's P6 tripwire was: **above 19,000 instructions per sample, start P8
immediately.** The shipping build is **48,564** — two and a half times the
tripwire. P8, the restructure track, is not a contingency any more; it is the
only remaining lever class with the right magnitude.

**The two targets are now unambiguous, and they are the same two the plan
already named.** Pitch (20,736, 43 % of the engine) and the DCO (10,202, 21 %)
are 64 % of the total between them. P2 closed the cheaper-arithmetic exits for
pitch by measurement, so what is left for both is structural: loop fusion,
control-rate evaluation, reduced oversampling with a matched decimator, and
fixed-point with the S3's PIE SIMD. Every candidate still has to null at
−100/−80 dB.

## Three errors made and caught while building this tool, recorded because each one flattered the result

1. **Summing every symbol in a translation unit.** That counts each static
   helper body ONCE, but `eb_pitch`'s fast path calls `df_mul` eleven times and
   `df_mulf` fifteen times per evaluation. It reported 921 instructions where
   the executed cost is ~2,600. Caught because 921 was absurd against a figure
   already on record. Fixed by pricing over the call graph.
2. **Skipping section-relative relocation targets.** A call to a STATIC function
   in the same unit does not relocate against the symbol — it relocates against
   `.text+0xNNN`. Dropping those dropped every intra-module call and priced
   `eb_pitch_eval` at **18** instructions. Fixed by resolving the offset to its
   containing symbol.
3. **Finding libgcc helper sizes with `grep -l`.** That locates objects which
   REFERENCE the symbol, not the one that DEFINES it: `_divdc3.o` mentions
   `__muldf3` and is 903 instructions. Fixed with `nm --defined-only`;
   `__muldf3` = 105 and `__adddf3` = 116 then agreed with this project's own
   earlier figures, which is what confirmed the fix.

All three made the engine look cheaper than it is. A measurement that flatters
the thing being measured deserves the same suspicion as a gate that has never
failed.

## What this number excludes, stated rather than buried

Voice allocation and note handling (`eb_alloc` — gated by `alloc_ab.py`, not
priced here), the once-per-recall coefficient derivation, and whatever plumbing
the finished `eb_engine_render` adds. **Instructions are not cycles**: on an
in-order LX7 the cycles-per-instruction factor is ≥ 1 and unknown until
silicon (hole H5).

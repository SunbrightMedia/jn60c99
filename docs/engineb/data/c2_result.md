# C2 — CONTROL-RATE CV: CLOSED NEGATIVE, and the premise was wrong

Date 2026-08-05 (Opus 5), executing O7. Verdict first: **C2 is dead, the fit
ladder loses its 1.4× rung, and 6 voices at 44.1 kHz is NOT reachable with
the levers now known.** What that leaves is in §4.

## 1. The premise, and why it was false

P8_PLAN §C2 and the bias law say: phase-integrated quantities need exact
evaluation, but *memorylessly-consumed* quantities — "VCF coefficients,
gains" — tolerate ~1e-5, so they can be evaluated at control rate and
interpolated. Worth ~5,500 instr/sample.

Three things were wrong with that, each found by measuring:

**The target list was too big.** `glide` (1,188) and `pwm_cv` (366) both carry
the **pitch** CV into the DCO phase. The bias law forbids them — the wall C1
died on. Real candidates: `vcf_res` (3,174) and `vcf_cv` (570) at 6 voices,
so at most ~2,800, not 5,500.

**The signals are not smooth.** MEASURED over 4,752,000 calls on eight real
scenarios, per-sample motion of each module's output:

| module output | mean abs delta | mean RELATIVE delta |
|---|---|---|
| `vcf_res` (resonance term) | 0.0032 | **107 %** |
| `vcf_cv` (cutoff CV) | 0.502 | **104 %** |

A quantity that changes by ~100 % every sample is not a control signal being
sampled too finely. It is **noise the instrument deliberately generates** —
`vcf_res` carries a wrap24 dither, the same analog-scatter machinery as
CONDITION. No causal approximation reproduces a stochastic term, because
there is nothing to approximate: holding and interpolating both REMOVE it.

**And `vcf_cv`'s state update IS its computation.** It is three one-pole
smoothers; evaluating them every Nth sample does not approximate the filter,
it builds a filter with a different time constant.

## 2. The gate, at the gentlest setting that exists

`EB_VCF_RES_CR=N`: evaluate `eb_vcf_res`'s pure tail (everything after
`v234 = v227` — no state, a clean function of one scalar) every Nth sample,
reusing the cache between, with the dither still stepping EVERY sample.

| build | result |
|---|---|
| **N=1 (identity check)** | **EXACTLY 0**, all 36 scenarios |
| **N=2** | **FAIL −39.3 dB, all 36 scenarios** |

The N=1 row is what makes the N=2 row mean something: the transformation
itself changes nothing, so the failure is the decimation alone and not a
transcription error riding along with it. **−39.3 dB is 60 dB above the
gate** — not a near miss to be tuned, a different sound.

Two things checked rather than assumed on the way: cell 7632 is 1.0 in all 64
factory patches (so the expensive body genuinely runs every sample — the
prize was real), and the port's own `k7632 != 1.0` arm has exactly the
control-rate shape, which is what made the transform expressible at all.

The flag stays in the tree, defaulted to 1 and proven identity there, so this
negative result is reproducible in one command instead of re-derived.

## 3. The fourth candidate killed by measurement

C1 (integration), C4 (resolution, both recursive and feed-forward), C5
(register pressure), now C2 (stochastic content). Each was modelled as worth
thousands of instructions; each died to a property of the actual instrument
that the model did not contain. **Every remaining "modelled" saving in this
project should be read with that record in mind.**

## 4. What this costs, stated plainly

MODELLED ladder without C2 (instructions × 0.95 = cycles, from F4's measured
c/i; the two half-oversampling figures are MODELLED, not gated):

| step | cycles/sample | vs 44.1 kHz two-core (~10,900) |
|---|---|---|
| fork + shared LFO (measured) | ~23,450 | 2.15× |
| + half-oversampling DCO/decim | ~19,600 | 1.80× |
| + half-oversampling VCF path | ~16,900 | **1.55×** |

**6 voices at 44.1 kHz is ~1.55× over after every lever now known**, and both
remaining rungs are unbuilt and ungated. Honest options from here:

1. **4 voices** with both half-oversampling levers: ~11,900 cycles ≈ **1.1×** —
   within reach of ordinary tuning.
2. **New structural work on the DCO** (~8,700 at 6 voices, never attacked
   because pitch always dwarfed it) — the only untouched large line.
3. **The Teensy fork**, which needs none of this.

The plan's F5/O8 (half-oversampling) remain worth doing — they are the
difference between 2.15× and 1.55×, and they are prerequisites for option 1
as well. But O9's "6 voices at 44.1 kHz running properly" cannot be promised
on today's evidence, and this document is the reason.

# TABULATING eb_vcf_res's TAIL — −1,980 instructions at −108.8 dB

Date 2026-08-06 (Opus 5), executing `S3_PLAN_THAT_FITS.md`. This is the
largest single instruction saving found since the S3 fork began, and it
clears the **trunk** gate, not merely the fork's.

## What was tabulated

`eb_vcf_res.c`'s tail — the port's `v234` to `v241` — is a **pure function of
one scalar**. Its only inputs are `v227` and recall constants. It contains an
exponential, a 17-term polynomial and two divisions.

Three properties make it the tabulation case, and all three are recorded
findings of earlier failed levers:

* **FEED-FORWARD.** C4's post-mortem said a span that does not recycle its
  error is where approximation survives. This span has no state at all.
* **MEMORYLESSLY CONSUMED.** The bias law's ~1e-5 tolerance applies. It is not
  phase-integrated.
* **BOUNDED OUTPUT.** `v241 = v240/(v240+1)` lies in `[0,1)`.

## Why C2's failure does not apply

C2 decimated this same tail and failed at −39.3 dB. C2's own document is
clear about the cause: the module carries a **wrap24 dither**, and the tail's
argument moves about 107 % per sample.

**A table is not a decimation.** It is evaluated on every sample, on the
actual argument. The dither passes through the table exactly as it passes
through the function. C2's objection is to computing LESS OFTEN; this
computes the same thing FASTER, which is the category the DCO edge
short-circuits already proved out.

## The lift was gated before the table was built on it

The tail was first moved into its own function `ebr_tail`, with the same
expressions, the same parentheses and the same order. That build nulls
**EXACTLY 0** on all 36 scenarios.

This is C2's own discipline and it is the reason the numbers below mean
something: the transformation itself changes nothing, so any residual is the
table alone and not a transcription error riding along with it.

## The domain is measured

`-DEB_VCF_RES_RANGE=1`, write-only instrumentation, all 36 scenarios at both
rates: **17,199,360 calls, `v227` in [−4.185, 3.500]**.

The table spans **[−6, 4]** — that span with about 1.8 of headroom each side.
Any argument outside it **falls back to the exact tail**. It is not clamped.
Clamping would silently change the answer for a user preset the scenario set
never reached, which is the "this byte is 0 in every factory patch" mistake
`GOAL.md` forbids.

## The size is measured

Linear interpolation error falls as the square of the step, so each doubling
should buy 12 dB. It does, until it meets the arithmetic's own floor.

| entries | span [−8, 8] | span [−6, 4] |
|---|---|---|
| 1,024 | −79.9 dB FAIL | |
| 2,048 | −93.3 dB FAIL | −101.1 dB PASS |
| 4,096 | −105.4 dB PASS | **−108.8 dB PASS** |
| 8,192 | −111.2 dB PASS | |

The 8,192 row buys 6 dB for a doubling instead of 12. That is the float
arithmetic's own noise, not the interpolation, and it is why there is no
point going further.

**Shipping choice: 4,096 entries over [−6, 4].** 2,048 also passes, at
−101.1 dB against a −100 dB gate. **1.1 dB of margin is a probe ON the
threshold**, and this project has twice been caught by exactly that.

## The result

| | |
|---|---|
| full gate, 36 scenarios, both rates | **PASS, −108.8 dB** |
| composite `--module standalone` | **PASS, −108.8 dB** |
| default build (flag off) | **EXACTLY 0** |
| `eb_vcf_res` per call, Xtensa | **530 → 200** |
| at 6 voices | **−1,980 instructions/sample** |
| fork total | 24,320 → **22,340** |
| share of the engine removed | **8.1 %** |

## Memory

4,097 floats per voice = 16 KB, **98 KB at six voices**. The table is per
voice because CONDITION scatter makes the ~20 coefficients voice-distinct; one
shared table would be wrong on five voices out of six.

It is built at recall time, not per sample. `eb_vcf_res_prepare` is called by
both coefficient builders — the engine's `eb_render_coefs_build` and the null
harness's shim — because a derived value computed in only one builder is the
defect class this project has hit three times, twice on the DCO edge
thresholds alone.

**98 KB is a real cost against the S3's 512 KB of internal SRAM**, and it
competes with the 266 KB the FX rings want (`ring_depth.md`). That trade is
not decided here.

## What this says about the remaining levers

Every lever that tried to compute LESS OFTEN has died: C1 (integration), C2
(stochastic content), C3, C5 (register pressure). Every lever that computed
the SAME THING FASTER has worked: the DCO edge short-circuits (EXACTLY 0),
the glide exponent hoist (EXACTLY 0), and now this (−108.8 dB).

**The remaining per-voice modules should be read for that pattern**, not for
decimation opportunities. `vca_hpf` (230 instructions per call) and `pwm_cv`
have not been examined for it.

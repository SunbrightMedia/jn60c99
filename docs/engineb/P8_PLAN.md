# P8 — the restructure track. The plan, from the corrected numbers.

Date 2026-08-03 (Fable 5). The P6 tripwire is tripped: the S3 shipping build is
**55,167 instr/sample** against a 6,300–9,500 two-core instruction budget
(`data/engine_cost.md`, corrected). Per-module tuning is exhausted — P2 proved
the cheaper-pitch exits dead by measurement, P3/P4 cashed the DCO levers. What
remains is structural. Every candidate below must null at −100 dB global /
−80 dB block against the port, at BOTH rates, like everything else in this
project. A candidate that cannot is dead, whatever it saves.

## Where the instructions are (shipping build)

| block | /sample | share | | block | /sample |
|---|---|---|---|---|---|
| pitch (v7) | 21,792 | 40 % | | vca_hpf | 1,840 |
| DCO | 10,202 | 18 % | | vcf_ladder | 1,840 |
| LFO | 6,305 | 11 % | | glide | 1,584 |
| vcf_res | 4,232 | 8 % | | envgen | 1,296 |
| FX (all three) | 2,241 | 4 % | | decim | 1,216 |

## ⚠ REVISED THE SAME NIGHT — C1 and C3 are DEAD, by measurement

C1 was built and executed to its end (`data/pitch_p2_study.md` §6). Its final
form was accurate to 1e-7 on the real trajectory and STILL failed at
−89.5 dB, because a smooth deterministic error is a bias and the DCO phase
integrates it. **The law: phase-integrated quantities (pitch increment, LFO
rate) need bias < ~1e-9 — only exact evaluation passes. Memorylessly-consumed
quantities (filter coefficients, gains) tolerate ~1e-5.** C3 dies with C1
(the LFO rate feeds the LFO phase integrator). C2 survives ONLY for the
non-integrating targets: vcf_res's expf and shaper (consumed as filter
coefficients), the vcf_cv smoother outputs. The honest ceiling of this plan
drops accordingly: pitch's 21,792 is irreducible by approximation, and the
remaining levers are C2-narrowed (~3,500), C5 fusion (~2,000), C4
fixed-point/SIMD on the audio path (the big one left), and C6 behind it.
Six voices stays last, per the user's order.

## The candidates, ranked by expected saving per unit of risk (original text)

**C1 — CONTROL-RATE PITCH WITH INCREMENT INTERPOLATION. The big one.**
Evaluate the v7 polynomial every N samples per voice; between evaluations,
step the DCO increment by a precomputed per-sample delta (linear in the
increment). MODELED saving at N=4: pitch 21,792 → ~6,000, minus ~500 of
interpolation. Why it can pass where plain float could not: the failure mode
was a VALUE error integrating in phase; interpolation between two CORRECT
values is a bounded, zero-mean path error that does not accumulate — but that
is an argument, not a measurement, and vibrato (the LFO moves pitch every
sample) is the case that will decide it. Build as a ladder N = 2, 4, 8;
measure the residual at each; adopt the largest N that clears the gate with
margin at both rates. If even N=2 fails, the fallback is v7 unchanged.

**C2 — CONTROL-RATE CV: the same mechanism for vcf_res, glide, pwm_cv,
vcf_cv.** vcf_res carries a per-voice `expf` per sample whose input is a
smoothed CV; glide's divide and the mod-CV products move at control rate too.
MODELED saving at N=4: ~5,500. The envelopes are NOT candidates — their
attack transients are audible-rate by definition. Same ladder, same gates.

**C3 — THE LFO's expf, incrementally.** `expf(v73·k1200)` where v73 is the
delay-envelope ramp — a value that moves by a constant per sample for long
stretches. exp(x+d) = exp(x)·exp(d): one multiply per sample with a
re-anchor every N samples to stop drift. MODELED saving: ~1,300. Must be
gated for the re-anchor discontinuity.

**C4 — FIXED-POINT + PIE SIMD for the oversampled audio path** (DCO,
decimator, ladder, VCA/HPF ≈ 15,100/sample). The S3's PIE is 128-bit integer
SIMD; esp-dsp is the precedent. This is the only ×2–3-class lever on the
part and the largest single piece of work: a fixed-point ladder that nulls at
−100 dB needs ~30+ fraction bits and saturation semantics matched to the
float original. Start it ONLY after C1/C2 land, with a one-filter prototype
gated before any wider adoption.

**C5 — CALL-STRUCTURE FUSION. CLOSED NEGATIVE 2026-08-05 — read
`docs/engineb/data/c5_fusion.md`. The prize is ~640 instr/sample, not
~2,000 (the register-window `entry` makes a call nearly free), and one
translation unit removes 2 of 118 call sites while forced inlining costs
2.6x across code size and float traffic. The text below is the ORIGINAL
proposal, kept for the record.** One loop per voice instead of thirteen calls;
EXACTLY-0-able since it reorders nothing arithmetic. MODELED saving ~1,500–
3,000 (call overhead + window traffic + re-loads). Do it LAST of the cheap
ones: it makes the code harder to attribute, and the null must be re-run per
module boundary removed.

**C6 — REDUCED OVERSAMPLING (4× → 2×) with a redesigned decimator.** Halves
the DCO+decim mass (~5,700). It changes the aliasing structure, so it is the
most audible-risk candidate; it stays BEHIND C1–C5, per the binding order.

**LAST — 6 VOICES.** The user's constraint: last resort only. ~−12,000 on
today's numbers. Not part of this plan unless everything above lands and the
silicon number still says over.

## The honest arithmetic, end to end

55,167 − C1 (~15,300) − C2 (~5,500) − C3 (~1,300) − C5 (~2,000) ≈ **31,000**
→ still 3.3–4.9× over. With C4 at ×2.5 on the audio path ≈ **21,000** →
2.2–3.3×. With C6 ≈ **15,000** → 1.6–2.4×. **Even the full ladder lands near
the budget only at c/i ≈ 1.0, which silicon has not yet blessed.** This plan
does not promise the goal is reached; it is the ordered list of every lever
that exists, each with its measurement, and the honest statement that the
last resort may still be needed. That decision belongs to the user and to the
silicon number (P10), not to this document.

## Order of work and who does it

1. **C1 ladder** — numerically subtle (the interpolation interacts with the
   phase integration): Fable.
2. **C2 + C3** — mechanical application of C1's proven mechanism: Opus, after
   C1's gate shape exists.
3. **Re-price** (engine_price.py) after each landing; re-rank.
4. **C5** — Opus, gated EXACTLY 0.
5. **C4 prototype** (one ladder filter, fixed-point, gated): Fable; wider
   adoption: Opus.
6. **Step 2 of the previous list** (the eb_render_coefs constructor + the
   eb_engine_render gate) remains OWED before any silicon run and is
   unaffected by this plan: Opus.

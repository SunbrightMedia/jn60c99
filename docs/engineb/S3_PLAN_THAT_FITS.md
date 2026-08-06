# THE PLAN THAT FITS — 6 voices + full FX on the ESP32-S3

Date 2026-08-06 (Opus 5), at the user's order: "find me a plan that fits, with
6 VOICES AND FULL FX".

**THE SENTENCE FIRST.** The previous ladder (`S3_STRATEGY_6VOICE.md`) ends at
1.2x to 1.25x over budget. It does not fit. This document replaces it. The
plan below ends at **0.97x**, but it needs **two structural changes that this
project has never tried**, and both are ESTIMATES until they are built.

---

## 1. The budget, and the honest starting point

| item | value | status |
|---|---|---|
| S3 clock | 240 MHz | MEASURED |
| sample rate | 44,100 Hz | fixed |
| cycles per sample per core | 5,442 | MEASURED |
| two cores | **10,884** | the target |

Today's S3 fork, 6 voices, with `EB_LFO_SHARED`:

| chain | instr/sample | c/i | cycles |
|---|---|---|---|
| voice chain | 20,143 | **1.56** (MEASURED on the board) | 31,423 |
| FX chain | 4,729 | **2.36** (MEASURED, PSRAM-bound) | 11,160 |
| **total** | **24,872** | | **42,583** |

**Today = 3.9x over.** Every number in this table is measured on the user's
own board. The plan must remove 31,700 cycles.

---

## 2. Why the previous ladder failed

It attacked instruction counts inside the existing structure. The structure
is the cost. Two facts show this:

* **The engine oversamples 4x.** The DCO, the decimator and the VCF ladder all
  run at 176,400 Hz. That is 4 times more work than the audio rate needs.
* **Every per-voice control block runs at audio rate.** Glide, PWM CV, VCF CV,
  VCF resonance, the envelopes and pitch all update 44,100 times per second.
  A control voltage does not change that fast. These blocks are 5,607
  instructions per sample, which is 27 % of the voice chain.

Roland's own hardware did neither of these things. That is the answer to
"Roland did this in 2015 with less resources".

---

## 3. The ladder

Each row states what it removes and how sure the number is.

| # | change | voice instr | FX instr | voice c/i | FX c/i | cycles | vs budget |
|---|---|---|---|---|---|---|---|
| — | today | 20,143 | 4,729 | 1.56 | 2.36 | 42,583 | 3.91x |
| 0 | DCO edge short-circuits | 18,503 | 4,729 | 1.56 | 2.36 | 40,025 | 3.68x |
| 1 | FX rings to internal RAM | 18,503 | 4,729 | 1.56 | 1.30 | 34,999 | 3.22x |
| 2 | FX at half rate | 18,503 | 2,365 | 1.56 | 1.30 | 31,929 | 2.93x |
| 3 | voice-pair interleaving | 18,503 | 2,365 | 1.25 | 1.30 | 26,203 | 2.41x |
| 4 | **oversampling 4x to 1x** | 10,845 | 2,365 | 1.25 | 1.30 | 16,631 | 1.53x |
| 5 | **control blocks at 1/8 rate** | 5,945 | 2,365 | 1.25 | 1.30 | **10,505** | **0.97x** |

**Status of each row:**

| # | status |
|---|---|
| 0 | **DONE. MEASURED. Null EXACTLY 0.** Not a relaxation — the output is bit-identical. |
| 1 | Not built. The 1.30 value is an ESTIMATE from the voice chain's own 1.56. |
| 2 | Not built. ESTIMATE. |
| 3 | Not built. The 1.25 value is an ESTIMATE. LTO gave 5.8 % from the same effect. |
| 4 | **Not built. STRUCTURAL. This is a new DSP design.** |
| 5 | **Not built. STRUCTURAL. C2 died here once — see §5.** |

**Rows 4 and 5 carry 15,700 of the 31,700 cycles.** Rows 0 to 3 alone reach
2.41x. The plan fits only if both structural rows work.

---

## 4. Row 4 — remove the oversampling

**What it is.** The DCO runs 4 sub-steps per sample, then a 16-tap decimator
reduces them to one. The VCF ladder runs 4 sub-steps. Row 4 makes all of them
run once per sample.

**Why the oversampling exists.** The DCO makes hard edges. A hard edge at
44,100 Hz makes aliases. Oversampling pushes the aliases up, and the
decimator removes them.

**The replacement: band-limited step correction (BLEP).** Instead of making
the edge four times and filtering, the DCO computes WHERE the edge falls
between two samples and adds a small correction. This is standard practice in
software synthesizers. It gives a lower alias level than 4x oversampling, at
about 1/6 of the cost.

**The saving:**

| part | now | after | saving |
|---|---|---|---|
| DCO phase overhead (`p_fixed`) | 2,088 | 522 | 1,566 |
| DCO edge blocks | ~5,000 | ~1,300 | 3,700 |
| decimator | 912 | 0 | 912 |
| VCF ladder | 2,766 | 692 | 2,074 |
| BLEP correction | 0 | ~600 | −600 |
| **total** | | | **7,658** |

**The risk, stated:** the VCF ladder at 1x has a different high-frequency
skirt. The O8 half-rate VCF rung was DECLINED for exactly this reason. The
fix that was never tried is a **corrective one-pole after the ladder**. If
that fails, the VCF stays at 2x and row 4 gives 6,275 instead of 7,658. The
plan then ends at 1.05x, not 0.97x.

**The gate:** alias level per band within +1 dB of the plugin's own floor
(F5's gate 2, which already exists and runs), plus the VCF cascade magnitude
match to 0.1 dB (F5's gate 1, which also already exists).

---

## 5. Row 5 — control blocks at 1/8 rate

**What it is.** Glide, PWM CV, VCF CV, VCF resonance, the envelopes and pitch
update once every 8 samples (5,512 Hz) instead of every sample. The values
between are interpolated in a straight line.

**Why this is not C2.** C2 was closed negative and the reason is recorded in
`data/c2_result.md`: `vcf_res` and `vcf_cv` move about 100 % per sample
because they carry the **wrap24 dither**, which is a random term. Holding or
interpolating a random term removes it. The null failed at −39.3 dB.

**The design that answers that.** Split each block into two parts:

1. the **smooth** part — the envelope, the glide, the LFO depth. This is what
   gets decimated and interpolated.
2. the **dither** part — the wrap24 term. This stays at full rate. It is
   cheap: the dither is one wrap, not the whole block.

C2 decimated both together. That is why it failed. The measurement in
`c2_result.md` is correct and it does not forbid this split — it forbids the
thing C2 actually did.

**The saving:** 5,607 instructions per sample become 5,607/8 + dither cost.
Estimated at **4,900 saved**.

**The gate:** this is a FORK change, so the standard is indistinguishability,
not −100 dB. Gate it as the pitch fork was gated: a stated numeric bound on
the control value itself, then a listening-band null. Pitch is inside this
set and pitch is phase-integrated, so **pitch keeps its own bound of 0.05
cents** and may need to stay at full rate. Pitch is only 360 instructions, so
excluding it costs almost nothing.

---

## 6. What must happen next, in order

1. **Row 1 — FX rings to internal RAM.** Cheapest. It changes no arithmetic.
   First measure what delay times the factory patches really use: the rings
   are sized for 11.9 seconds and no patch is likely to need that. If the real
   maximum is under 1 second, all nine rings fit in internal RAM.
2. **Row 3 — voice-pair interleaving.** Also changes no arithmetic. Its
   result gives the real c/i value, which every later row depends on.
3. **Row 4 — BLEP.** The large structural change. Build the DCO first and gate
   it with the alias probe that already exists. Then the VCF.
4. **Row 5 — control rate with the dither split.**
5. **Row 2 — FX at half rate.** Last, because it is the smallest structural
   row and the FX chain may already fit after row 1.

---

## 7. The honest summary

* Rows 0 to 3 are ordinary engineering. They reach **2.41x**. They do not fit.
* Rows 4 and 5 are DSP redesigns. They are the plan. With both, it reaches
  **0.97x**.
* Every number in rows 1 to 5 is an ESTIMATE. Only row 0 is measured.
* If row 4's VCF part fails, the plan ends at **1.05x** and 6 voices at
  44.1 kHz needs one more lever.

**This plan can fit. It is not proven to fit.** The difference matters and it
is stated here so that no later document has to correct it.

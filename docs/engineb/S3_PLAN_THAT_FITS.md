# THE PLAN THAT FITS — 6 voices + full FX on the ESP32-S3

Date 2026-08-06 (Opus 5), at the user's order: "find me a plan that fits, with
6 VOICES AND FULL FX", then "please complete plan that fits".

**REVISED TWICE THE SAME DAY, by measurement, and the second revision is
fatal.** Row 5's premise was wrong, row 6 measured nearly empty, and **row 4's
DCO half is now CLOSED NEGATIVE** (`data/quarter_os_result.md`). Row 4 carried
6,178 of the plan's remaining instructions.

**THE HONEST ENDPOINT IS 1.48×, NOT 1.02×. 6 voices with full FX at 44.1 kHz
does not fit on today's evidence.** The same ladder reaches 1.27× at 5 voices
and **1.07× at 4 voices**. Every wrong number below is named rather than
deleted, because the plan was wrong three times in one day and the pattern in
how it was wrong is worth more than the numbers were.

---

## 1. The budget

| item | value | status |
|---|---|---|
| S3 clock | 240 MHz | MEASURED |
| sample rate | 44,100 Hz | fixed |
| cycles per sample per core | 5,442 | MEASURED |
| **two cores** | **10,884** | the target |

Cycles per instruction, measured on the user's own board: **1.56 for the voice
chain, 2.36 for the FX chain**. The FX chain is slower because it waits for
PSRAM.

---

## 2. Where the engine stands today

Three levers are **built, gated and priced**. All three are in the same
category, and that category is the finding of this whole exercise.

| lever | saving | gate | status |
|---|---|---|---|
| DCO edge short-circuits | −1,640 | **EXACTLY 0** | DONE |
| glide exponent hoist | −216 | **EXACTLY 0** | DONE |
| vcf_res tail tabulated | **−1,980** | **−108.8 dB** | DONE |

A fourth correction came out of pricing them — **the sixth pricing error in
this project, in the same flattering direction as the other five.** The fork
exponential line charged `2 x voices` sites unconditionally. Both of its
assumptions had since been broken by levers the same tool prices: the shared
LFO runs ONCE, not once per voice, and the `vcf_res` table moved that site to
recall time while the module's own cost had ALREADY dropped to reflect it. The
saving was being counted twice. Sites are counted now, and printed.

Fork total: 24,536 → **19,908 instructions per sample**.

| chain | instr | c/i | cycles |
|---|---|---|---|
| voice | 15,867 | 1.56 | 24,752 |
| FX | 4,041 | 2.36 | 9,537 |
| **total** | **19,908** | | **34,289 = 3.15×** |

Down from 3.91× this morning.

---

## 3. THE PATTERN — read this before proposing any lever

| lever | idea | result |
|---|---|---|
| C1 control-rate pitch | compute less often | **DEAD**, −89.5 dB |
| C2 control-rate CV | compute less often | **DEAD**, −39.3 dB |
| C3 incremental LFO exp | compute less often | **DEAD** by the bias law |
| C4 fixed point + SIMD | compute at less precision | **DEAD**, +3.9 dB |
| C5 call fusion | remove call overhead | **DEAD**, 2.6× worse |
| DCO edge short-circuits | compute the same thing faster | **WORKS**, EXACTLY 0 |
| glide exponent hoist | compute the same thing faster | **WORKS**, EXACTLY 0 |
| vcf_res tabulation | compute the same thing faster | **WORKS**, −108.8 dB |

**Every lever that tried to compute LESS OFTEN has died. Every lever that
computed the SAME THING FASTER has worked.** Levers below are ordered by
that finding, not by modelled size.

---

## 4. The ladder

Today's row now includes half-oversampling, which is gated and was not
counted before.

| # | change | voice | FX | v c/i | f c/i | cycles | vs budget |
|---|---|---|---|---|---|---|---|
| — | **today, all gated levers** | 12,861 | 4,041 | 1.56 | 2.36 | **29,600** | **2.72×** |
| 1 | FX rings to internal RAM | 12,861 | 4,041 | 1.56 | 1.30 | 25,316 | 2.33× |
| 2 | FX at half rate | 12,861 | 2,021 | 1.56 | 1.30 | 22,690 | 2.08× |
| 3 | voice-pair interleaving | 12,861 | 2,021 | 1.25 | 1.30 | 18,703 | 1.72× |
| 4 | VCF ladder 4× to 2× | 12,171 | 2,021 | 1.25 | 1.30 | 17,841 | 1.64× |
| 5 | envelopes at 1/8 rate | 11,321 | 2,021 | 1.25 | 1.30 | 16,778 | 1.54× |
| 6 | three divisions | 10,781 | 2,021 | 1.25 | 1.30 | **16,103** | **1.48×** |

Rows 1 to 6 are **all estimates**. Only the "today" row is measured.

**The same ladder at other voice counts**, since the voice chain scales and
the FX chain does not:

| voices | cycles | vs budget |
|---|---|---|
| 6 | 16,103 | 1.48× |
| 5 | 13,857 | 1.27× |
| **4** | **11,611** | **1.07×** |

---

## 5. Row 1 — FX rings to internal RAM

**MEASURED and possible.** `data/ring_depth.md`.

The nine rings allocate 6.16 MB and use **0.26 MB**. The deepest read in the
whole engine is 31,007 samples = 0.70 seconds. The rings were sized for 11.9
seconds.

266 KB fits the S3's 512 KB of internal SRAM. This removes the PSRAM wait that
makes the FX chain's c/i 2.36.

**The competition for that RAM is real:** the vcf_res table wants 98 KB of the
same 512 KB. 266 + 98 = 364 KB. That trade is not yet decided.

**Not yet measured:** the actual cycle gain, and the shipping ring lengths,
which must come from the parameter maximum and not from these 36 scenarios.

---

## 6. Row 4 — the DCO half is CLOSED NEGATIVE

**Read `data/quarter_os_result.md`.** Built as `EB_QUARTER_OS=1` and measured
with the alias gate that already existed.

The DCO's edge is a FIXED DURATION in time, so oversampling does not change
its spectrum — it changes how accurately the edge is sampled. At 1× the alias
floor rises up to +5.6 dB against F5's +1.0 dB bound. Widening the edge (the
first-order band-limited step) fixes that at ×6 — **and destroys the
instrument**, because widening an edge is a low-pass that removes the alias
floor and the harmonics together. Worst harmonic error at ×6: **73 dB**.

**The finding is not about edges.** Even at ×1, with the port's own edge, the
harmonics are 7.1 to 13.6 dB wrong. The DCO's harmonics come from its
**shaping nonlinearity**, which runs per sub-sample. No filter placed after a
nonlinearity recovers harmonics the nonlinearity never generated.

**What survives:** half-oversampling (2×) stands, gated, worth 3,826
instructions, worst harmonic error 3.27 dB. And the **VCF half of row 4 is
untouched** — a ladder is a linear filter with no nonlinearity, so its rate
reduction is F5's algebra problem (`G' = 2G/(1−G²)`), not a
harmonic-generation problem. It is worth 690 and still needs the corrective
one-pole that was never tried.

---

## 7. Row 5 — CORRECTED, and it is much smaller than claimed

**The first version of this document was wrong.** It said C2 failed because it
"decimated the dither together with the smooth part", and proposed splitting
them.

**C2 already did that split.** `data/c2_result.md` states it plainly: the
decimation ran "with the dither still stepping EVERY sample", and it still
failed at −39.3 dB. There is no split left to make.

So row 5's target list collapses:

| module | instr | verdict |
|---|---|---|
| glide | 816 | forbidden — carries pitch into the DCO phase |
| pwm_cv | 852 | forbidden — carries pitch |
| pitch | 360 | forbidden — phase-integrated |
| lfo | 489 | forbidden — LFO rate is phase-integrated |
| vcf_res | 1,200 | **dead** — C2, −39.3 dB |
| vcf_cv | 570 | **dead** — C2, its state update IS its computation |
| envgen | 972 | the only survivor |

Row 5 is **−850, not −4,900**. The plan absorbs that loss through row 6.

---

## 8. Row 6 — CORRECTED: the well is nearly dry

`data/res_lut.md` removed 1,980 instructions from one module at −108.8 dB by
tabulating a pure function of one scalar. The obvious next step was to apply
the same method to `vca_hpf` (1,380) and `pwm_cv` (366).

**MEASURED: there is nothing there.** Every per-voice module was disassembled
for the S3 and scanned for expensive helper calls — divisions, exponentials,
double conversions:

| module | expensive calls |
|---|---|
| vca_hpf | **0** |
| pwm_cv | **0** |
| vcf_cv | **0** |
| envgen | **0** |
| notecv | **0** |
| noisemix | **0** |
| glide | 1 × `__divsf3` |
| dcoprep | 1 × `__divsf3` |
| vcf_ladder | 1 × `__divsf3` |

`pwm_cv` is already fully block-hoisted and is straight multiply-add.
`vca_hpf` is 230 instructions of one-poles and clamps. Neither contains a
transcendental, a division or a span worth tabulating.

**Three divisions remain in the entire per-voice chain.** At 30 instructions
each over six voices that is 540, and removing them needs the reciprocal
trick, which is a fork relaxation (the `EB_DCO_RECIP` precedent), not a free
saving.

**Row 6 is −540, not −1,500.** The `vcf_res` table was the one large fish in
this pond and it is caught.

## 9. Order of work

1. **Row 1** — FX rings to internal RAM. Cheapest, changes no arithmetic, and
   its memory precondition is already measured.
2. **Row 3** — voice-pair interleaving. Changes no arithmetic. Its result
   gives the real c/i, which every later row depends on.
3. **Row 4** — BLEP. The large structural change, and now the only large one
   left. Host-gateable: F5's two gates already exist.
4. **Row 5** — envelopes at 1/8 rate.
5. **Row 6** — the three divisions.
6. **Row 2** — FX at half rate. Last; the FX chain may already fit after row 1.

Rows 1, 2 and 3 need the user's board. Rows 4, 5 and 6 can be gated here.

---

## 10. The honest summary

* Today is **3.15×**, down from 3.91× this morning, by three measured levers
  and one pricing correction.
* The ladder ends at **1.02×**. It fits, with no margin at all.
* Rows 1 to 6 are all estimates. Only today's row is measured.
* **Row 4 now carries the plan.** It is 7,658 of the 9,048 instructions the
  ladder still has to remove. If its VCF part fails, the endpoint is 1.09×;
  if the whole row fails, nothing else on the list reaches the budget.
* Rows 5 and 6 together are 1,390 instructions. They are trim, not levers.

**This plan can fit. It is not proven to fit.** Two of its six rows were
already corrected downward by measurement on the day they were written, and
both corrections came from re-reading a result this project had already
recorded. Read `data/c2_result.md` and `data/res_lut.md` before proposing a
seventh row.

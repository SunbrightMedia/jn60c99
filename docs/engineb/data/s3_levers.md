# The S3 ladder, measured on the user's own board

All cycle figures are from the LISTEN firmware's own sweep, single core,
44,100 Hz, voices only (no FX). Slope and intercept from a linear fit whose
increments agree to within 31 cycles.

## Where it started, and lever 1

| voices | trunk  | + wavetable DCO |
|--------|--------|-----------------|
| 0      |  2,557 |  2,815          |
| 1      |  7,573 |  6,587          |
| 2      | 12,587 | 10,361          |
| 3      | 17,609 | 14,139          |
| 4      | 22,654 | 17,919          |
| 6      |   --   | **25,499**      |

Slope 5,017 -> **3,775 cycles/voice, a 24.8 % cut** (22 % was predicted).
Intercept 2,557 -> 2,815: the at-rest wavetable advance costs more than
eb_dco_advance, and is worth it many times over.

The 6-voice point was PREDICTED at 25,465 from the 0..4 fit and MEASURED at
25,499 -- 0.1 %. The model is linear and it holds at the point that matters.

## Lever 2: the second core had never run a sample

There is no xTaskCreatePinnedToCore anywhere in the firmware. Every number
this project has ever quoted is single core, while the 10,884-cycle budget
they were compared against assumes two. That is a factor of two sitting
untouched.

eb_engine_render_range(v0, v1) renders a voice range; voice v touches only
slot v of every array, so ranges are independent. eb_engine_render_shared()
computes what both cores need first: the shared noise LFSR, voice 0's cvgate
and glide, and (under EB_LFO_SHARED) the one LFO whose input is voice 0's
glide output.

WHY THE PROLOGUE EXISTS. Without it the range holding voice 0 must finish a
whole voice before the other core can start, which serialises one voice in
six and caps the split near 1.5x. The prologue is three cheap calls, so both
cores then run three voices fully in parallel.

GATED: JUNO_EB_SPLIT_TEST=N runs both calls in order on one core so the whole
battery gates them. 36 of 36 EXACTLY 0, at every split boundary 1..5.

TEETH, after two invalid attempts that are worth recording:
  - DELETING the shared-noise publication measured EXACTLY 0. An
    uninitialised local's value is not controlled, so that case measured the
    COMPILER. Already in this repo's catalogue; walked into anyway.
  - PERTURBING it, on the firmware's own blob, still passed -- that patch's
    noise level is 0, so the path was covered by scenario luck.
  - Under the full battery: shared noise perturbed -> FAILS on DCO noise at
    -19.4 dB rel. Prologue pitch_cv perturbed -> 14 scenarios FAIL. Prologue
    LFO perturbed -> 22 scenarios FAIL.

MEASURED INERT, not assumed: voice 0's dly_env is dead inside the range under
EB_LFO_SHARED. Its only two consumers are LFO calls, and the prologue already
supplies the LFO. Perturbing it changes nothing on all 36, and that is a
property of the code rather than a weakness of the gate. It is carried for
the non-shared build, where the per-voice LFO consumes it.

## The ladder from here

Measured: 6 voices, one core, wavetable = 25,499 cyc = 2.34x over 10,884.

| step                                   | cycles | over  |
|----------------------------------------|--------|-------|
| wavetable, one core (MEASURED)         | 25,499 | 2.34x |
| + both cores with the prologue         | ~12,900| 1.19x |
| + ladder at 1x (zero-delay feedback)   | ~9,400 | 0.86x |
| + chorus (~660)                        | ~10,060| 0.92x |

The two-core row is arithmetic on a measured single-core number, not a
measurement. It is the next thing to put on silicon.

## The 2x ladder is CLOSED NEGATIVE (2026-08-08)

EB_HALF_OS_VCF was already written, with its own 2x decimator. Enabling it and
running the sonic gate:

  VERDICT: FAIL (27 of 36)   worst band overall 24.80 dB, bound 1.0 dB
  realloc chorus 24.06 dB · DCO neg warm chorus 10.96 dB · DCO neg pitch
  sweep 5.88 dB · realloc unison 3.58 dB

That is not a marginal miss. It is 24 dB over a 1 dB bound.

WHY, and it corrects the plan this lever was priced under: the ladder is
ALREADY zero-delay feedback -- its own source says so and solves
u*(1 + k*G^4) = in - k*S. The 4x oversampling is NOT there to fix frequency
warping or a delay-free loop. It is there because a SATURATION sits inside
the feedback loop:

    nl = x + k * x^5

A nonlinearity inside a resonant loop generates harmonics that fold, and the
folded products are then RE-CIRCULATED by the resonance. Halving the
oversampling doubles them and the loop compounds them, which is why the worst
scenarios are the resonant ones.

CONSEQUENCE, stated plainly: "the ladder at 2x" is worth 0 %, not 13 %, and
"the ladder at 1x via zero-delay feedback" was never a real lever -- the
zero-delay part was already there. The only remaining route to a cheaper
ladder is ANTIDERIVATIVE ANTIALIASING on the quintic saturation, which
attacks the aliasing at its source rather than pushing it out of band. Its
antiderivative is trivial (x^2/2 + k*x^6/6), so it is tractable, but it is
unbuilt and ungated and no cycle figure may be quoted for it.

## ADAA: measured, and it does not open the ladder (2026-08-08)

Antiderivative antialiasing on the clamped quintic, EB_VCF_ADAA, sonic gate:

  at FULL 4x   FAIL  8 of 36, worst band  2.22 dB   (bound 1.0)
  at 2x        FAIL 27 of 36, worst band 30.45 dB

Both numbers matter and they say different things.

At 4x, ADAA changes the sound by up to 2.22 dB ON ITS OWN, with the
oversampling untouched. First-order ADAA replaces the instantaneous
nonlinearity with its average over the segment the input travelled, and that
average is a mild low-pass whose corner moves with input slew. Inside a
resonant loop the filter hears that as a changed saturation curve, not merely
as less aliasing. So ADAA is not free even where it is not asked to save
anything.

At 2x it is WORSE than the plain 2x ladder (30.45 vs 24.80 dB), which settles
the question the 4x run raised: the failure at 2x is not aliasing that ADAA
could have removed. If it were, ADAA would have improved it.

CONSEQUENCE: the ladder's 4x oversampling is not reducible by half-rate, by
zero-delay reformulation (already present), or by first-order ADAA. All three
are closed by measurement. The VCF's ~26 % stands, and the remaining levers
for the S3 are the ones that do not touch it: EB_NUM_VOICES=6 (exact),
control-rate CV and envelopes, and core-balance tuning. Those reach ~1.09x,
not 1.0x.

## Control-rate CV is closed under the SONIC standard too (2026-08-08)

The hypothesis was that C2 died against the trunk's -100 dB gate and might
live under the fork's, since the wavetable DCO nulls at -36.5 dB and still
passes the sonic gate at 0.40 dB. MEASURED, EB_VCF_RES_CR:

  N=2  FAIL 13 of 36, worst band  7.32 dB
  N=4  FAIL 14 of 36, worst band 11.27 dB

The hypothesis was wrong, and the original C2 finding already said why:
vcf_res carries the wrap24 DITHER, and holding a value between updates does
not approximate a stochastic term, it REMOVES it. A missing dither is not a
small error in any band -- it changes what the resonance does. A -39 dB null
whose residual is BROADBAND NOISE is not the same object as a -36 dB null
whose residual is repositioned aliases, and the sonic gate is right to
separate them.

## Where the measured ladder actually ends

                                        cyc     over   +chorus
  ONE board, 6 voices, today          15,036   1.38x    1.45x
  ONE board, + EB_NUM_VOICES=6        13,661   1.26x    1.32x
  TWO boards, 3 voices each            11,343  1.04x    1.10x
  TWO boards, 3 each + NUM_VOICES=6     9,886  0.91x    0.97x  FITS

Only the last row fits, and it needs NO new deviation and NO unbuilt DSP --
just the six-voice harness rebuild, which is bit-exact by construction.

One board at six voices does not reach real time on measured levers. Two
boards at three each does, with 3 % of margin, and the split is the one the
user proposed before any of this was measured.

# The path to 6 voices + full FX, real time, on ONE ESP32-S3

## The distance, from measurement

Budget 5,442 cycles per sample (240 MHz / 44,100 Hz, WALL CLOCK -- the second
core's help is already inside this number, it does not double the budget).

  MEASURED, 6 voices, no FX, two cores, per-sample barrier   15,036   2.76x
  + block barrier + 6-voice build (BUILT, unmeasured)        12,275   2.26x
  + full FX                                                  13,475   2.48x

A voice costs 3,775 cycles. To fit with FX it must cost 1,097. **3.44x.**

## THE STANDARD IS FIXED AND IS NOT A LEVER

6 voices, full FX, ONE ESP32-S3, real time, 1.0 dB per third-octave band.
The bound is not negotiable and must not be raised to let a lever pass; a
second board and a different chip are equally out. Only changes that gate at
EXACTLY 0, or that pass the 1.0 dB bound as it stands, count.

CONSEQUENCE: the 2x ladder is OUT at 3.17 dB. Its remaining error is in-band
harmonic content from waveshaping at half rate -- not aliasing, so no
antialiasing method reaches it (three ADAA orders measured). The lever is
dead under the standard, and the standard wins.

## The levers that remain, and nothing else does

  1. Voice interleaving              ~1.35x  EXACTLY 0   designed, unbuilt
  2. Per-module block processing     ~1.15x  EXACTLY 0   unbuilt
  3. Chorus ring into internal SRAM  ~1.03x  EXACTLY 0   unbuilt (102 KB fits
                                                          the 202 KB free)
  OUT under the standard:
     2x ladder (3.17 dB) · envelopes at control rate (an approximation) ·
     ADAA of any order (measured 3.25 / 5.77 / 33.94 dB)

  product of what remains: ~1.60x against a 1.93x gap.

  STATED PLAINLY so no session mistakes it: the EXACTLY-0 levers known today
  do NOT close the gap. The shortfall is ~1.21x and there is no candidate for
  it yet. Finding one is the work -- not relaxing the bound, which is
  forbidden, and not adding hardware, which is forbidden.

## Lever 2: the diagnosis, because it is the one that decides it

The half-rate ladder fails the sonic gate at 24.80 dB. That is far too large
for aliasing: halving the rate of a filter whose own alias floor is -43 dB
should cost a few decibels. 25 dB in a resonant band is a MISTUNED FILTER.

RULED OUT -- the cutoff transform is already correct. eb_vcf_ladder.c carries
a note that F5's G' = 2G/(1-G^2) was wrong for this filter (G is the bilinear
GAIN, not the prewarped tangent) and that the corrected map, g4 = G/(1-G) ->
g2 = 2g4/(1-g4^2) -> G' = g2/(1+g2), is what the response gate passes on.

RULED OUT -- the input interpolation. The half path takes sub-steps 2 and 4 of
the 4x sequence, which are the midpoint and endpoint weights. Correct for 2x.

THE REMAINING SUSPECT, and it is structural: THE FEEDBACK DELAY.

    x = ins - ((st->s1 * c->c9520) * Rk)

st->s1 is S from the PREVIOUS SUB-STEP. The ZDF solve removes the delay
around the cascade, but this term is still one sub-step old. At 4x that delay
is 1/176,400 s; at 2x it is 1/88,200 s -- DOUBLED. A doubled delay inside a
resonant loop moves the resonant peak and rotates the loop phase, and no
scaling of G can compensate it, because G parameterises the cascade and not
the loop delay.

RULED OUT TOO -- CHECKED, and the diagnosis above is WRONG. The half-rate
sub-steps DO receive Gp/Ap/Rkp, so S is computed at half-rate parameters
throughout. And S is not a delayed term at all: it is the zero-input response
ONE SUB-STEP AHEAD, computed at step n and consumed at step n+1, which is
exactly on time. That is the whole point of the ZDF solve. There is no delay
error to compensate.

THE SUSPECT THAT SURVIVES: THE DECIMATOR IS A DIFFERENT FILTER.

At 4x the VCF decimates with the PORT'S OWN coefficients, c->fir[j], 32 taps
folded into 16 -- and those coefficients are part of the instrument's sound,
not a convenience. The half-rate path instead uses eb_halfos_fir, 24 taps,
which was DESIGNED FOR THE DCO PATH. Substituting one anti-imaging filter for
another changes the transfer function of the whole ladder output, and it does
so most where the two designs differ most -- which would explain a 24.8 dB
band error far better than aliasing does.

WHAT TO DO ABOUT IT: derive a 2x->1x decimator whose CASCADE with the
half-rate ladder matches the port's 4x ladder + 32-tap chain, and gate it on
response before touching the sonic gate. Do NOT reuse the DCO's filter: the
note in the 4x path says the VCF's sixteen cells and the DCO decimator's hold
the same MULTISET at 4x, which is a statement about the 4x filters and says
nothing about a 2x substitute.

SUPERSEDED PLAN (kept so it is not re-tried): re-derive the feedback term
rather than transporting c9520 unchanged. The cascade's zero-input response
one sub-step ahead is a function of (G, A) and the four stage states; S is
already computed from them, so the half-rate S must be computed with the
half-rate (Gp, Ap) -- CHECK THAT IT IS. If eb_vcf_substep receives Gp/Ap for
the cascade but the S expression was tuned to the 4x relationship, that is
the bug and it is a small fix. If S is already consistent, the delay is
genuinely structural and lever 2 is dead -- in which case the goal is not
reachable on one S3 and that must be said plainly.

## Order of work

  1. Diagnose lever 2 FIRST. It decides whether the goal is reachable at all,
     and it is a read of ~40 lines rather than a build.
  2. Voice interleaving (docs/engineb/VOICE_INTERLEAVE_PLAN.md).
  3. Per-module block processing.
  4. Envelopes at control rate -- and note these are NOT vcf_res: C2 died
     because vcf_res carries the wrap24 dither and holding a stochastic term
     deletes it. Envelopes carry no dither and are memorylessly consumed.

## Closed by measurement -- do not re-try

  ladder ADAA (2.22 dB at 4x, worse at 2x) · zero-delay reformulation (already
  present) · control-rate vcf_res (7.32 dB) · Q15 fixed point (+3.9 dB) ·
  LTO (2.2 %, already in the build) · call fusion (register window) ·
  C1 control-rate pitch (bias integrates in the phase accumulator)

# The path to 6 voices + full FX, real time, on ONE ESP32-S3

## The distance, from measurement

Budget 5,442 cycles per sample (240 MHz / 44,100 Hz, WALL CLOCK -- the second
core's help is already inside this number, it does not double the budget).

  MEASURED, 6 voices, no FX, two cores, per-sample barrier   15,036   2.76x
  + block barrier + 6-voice build (BUILT, unmeasured)        12,275   2.26x
  + full FX                                                  13,475   2.48x

A voice costs 3,775 cycles. To fit with FX it must cost 1,097. **3.44x.**

## The four levers that remain, and nothing else does

  1. Voice interleaving                    ~1.35x   designed, unbuilt
  2. 2x ladder                             ~1.20x   FAILS -- diagnosis below
  3. Per-module block processing           ~1.15x   unbuilt
  4. Envelopes at control rate             ~1.07x   unbuilt

  product 1.99x against a 1.93x gap. Every one must land near its optimistic
  value. Without lever 2 the product is 1.66x and the goal is NOT reachable.

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

WHAT TO DO ABOUT IT: re-derive the feedback term for the new sub-step period
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

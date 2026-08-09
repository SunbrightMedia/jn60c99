# THE ONE CHANGE — sonically accurate -> audibly accurate (USER-ORDERED)
2026-08-10. The user's decision, in their words: the fork's standard steps
down from the 1.0 dB third-octave bound to AUDIBLY ACCURATE -- "it should
still sound the same to me" -- via ONE change, proven from existing evidence,
reversible later.

## The change
EB_HALF_OS_VCF=1 joins the shipping fork define set. The ladder runs two
sub-steps per sample instead of four, through the ALREADY-FITTED 16-tap
decimator (eb_vcf_halfos_fir.h, 0.003 dB match to the port's own response).

## The evidence, all pre-existing
- Sonic cost MEASURED: 3.17 dB worst third-octave band, confined to ~10 kHz
  in high-resonance/warm-chorus scenarios; typical scenarios far lower.
- F5: the fork lands within +/-0.7 dB of the plugin's OWN alias floor
  (-43..-54 dB, audible BY DESIGN) in five of six bands.
- Cost: ~500 cycles/voice (F4's ladder-down step, measured).
- Closed alternatives that do NOT come back with this change: ADAA x3,
  drive fit (a=1.0 is a minimum), map retune (k-dependent residual),
  1x direct (23.77 dB), exact-1x ARMA (no FP divider).

## The two-chip landing (measured inputs)
  0xd0 today 7,785 = head ~1,450 + 2 x ~3,170
  + O1 (gated, silicon pending)   -> ~6,500
  + HALF_OS (-500/voice)          -> ~5,560 vs 5,442 = within 2 %
  Last 2 %: bit-exact kernel pass (60 of a measured 735/voice stall pool).
  NO FURTHER STANDARD CHANGE IS AUTHORIZED OR NEEDED.

## Verification order
1. sonic gate, full stack + HALF_OS (running) -- pins today's number.
2. worst-scenario A/B WAVs, trunk vs fork -- the USER's ears are the judge
   of "indiscernible", per the fork charter ("the judgement stays with the
   user"). This is the fork's relaxed standard, not the trunk's proof.
3. one firmware (full stack + HALF_OS), 0xd0 is the verdict.

## Reversal
Delete -DEB_HALF_OS_VCF from the define set. Nothing else moves; the 1.0 dB
standard and all its gates remain in the tree untouched.

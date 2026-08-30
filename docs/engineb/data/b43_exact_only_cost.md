# b43 -- THE BIT-EXACT ENGINE'S SILICON COST (measured 2026-08-30)

Build: trunk + EXACTLY-0 levers ONLY (EB_ZEROCOEF, EB_ATREST_BLOCK/O1,
EB_VCF_DEADCOEF, EB_EXP_MEMO, EB_FUSE_VCA; NO wavetable, NO half-OS VCF,
NO res LUT, NO fast math, NO control-rate). Answer key regenerated with
EBOOT_DEFS; the DEVCRC size tooth REFUSED the first mismatched build
(seen to fail). CRC MATCH on device. CHUNK=256, 3 voices, stepper 4 s.

## MEASURED
- v1 (one bit-exact voice, core 1): 5,191-5,670 cyc/sample.
  Fork voice: ~2,600. RATIO 2.0-2.2x.
- Whole loop at 3 voices: cyc 7,438-8,550 vs 5,442 budget; quiet blocks
  8,265-8,390 us vs the 5,804 us period = ~143 % of real time.
- fx (front, core 1): 1,741-3,237 across the stepped patches;
  back (reverb+out, core 0): ~1,140-1,200 -- close to the fork's.
- rc bank shrinks 18,788 -> 10,564 B (the CR levers' fields gone).

## WHAT IT SETTLES
- TWO CHIPS CANNOT RUN THE BIT-EXACT ENGINE: 6 voices = ~32,400
  cyc/sample vs 4 cores x 5,442 = 21,768 -- 1.5x over with ZERO FX.
  The sonic levers are NECESSARY on the target, by measurement.
- Four S3s (hypothetical only; END_GOAL forbids): 8 cores = 43,536;
  6 exact voices + full master ~= 36,500 -> fits on paper at ~85 %
  load, no margin, needs per-core voice distribution + 2-hop link.

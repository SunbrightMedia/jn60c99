# The no-nonsense plan to real time (2026-08-08)

GOAL (fixed): 6 voices + full FX, ONE ESP32-S3, real time, 1.0 dB/band.
BUDGET: 5,442 wall-clock cycles/sample (240 MHz / 44,100 Hz; both cores'
parallelism is INSIDE wall clock -- it does not double this number).

## What is MEASURED on the board
  6v, 2 cores, per-sample barrier, 8-slot build, no FX:  15,036 cyc = 2.76x
  decomposition: floor 2,357 + 3 critical-path voices x ~4,226 + barrier.

## What is BUILT, PROVEN, and in juno_s3_BEST.bin -- unmeasured on silicon
  - block barrier: 1 handshake/128 samples instead of 128 (was ~1,436 cyc/smp)
  - timer fix: the measured region no longer bills its own timer reads
  - VCF dead-coefficient deletion (EXACTLY 0, structural)
  - dead at-rest DCO advance under the wavetable (bit-identical, 0/36 differ)
  - interleave is OFF: MEASURED on Xtensa, tick2 = 432 insns + 27 FP spills
    vs 320 + 0 for two ticks. The 16-register file defeats it.

## STEP 0 -- the one flash that decides everything
  Flash juno_s3_BEST.bin, read wake=0xfc at t=41s. Projection ~12,300 (2.26x).
  Everything below keys off the REAL number, not the projection.

## STEP 1 -- six-voice harness rebuild (exact, no deviation)
  Regenerate blob + masks at EB_NUM_VOICES=6. Removes the two 8-slot idle
  voices from the floor and shrinks state. Est. -1,400 cyc. -> ~10,900 no FX.

## STEP 2 -- FX on board (the goal includes them)
  +~1,200 cyc (chorus+delay+reverb, measured host, FX c/i is the risk).
  Chorus ring already fits internal SRAM; delay/reverb rings are PSRAM.
  -> ~12,100 = 2.2x. THAT IS THE HONEST MEASURED-ARITHMETIC END-STATE.

## The wall, stated once
  To fit, a critical-path voice must cost <= (5,442-900-50-1,200)/3 = 1,097
  cycles. It costs ~3,775. Every lever large enough has been closed BY
  MEASUREMENT, not opinion:
    2x ladder 3.17 dB (in-band harmonics) · ADAA x3 (2.22/5.77/33.94 dB) ·
    control-rate CV 7.32 dB · interleave (register-spill wall) · Q15 (+3.9 dB)
    · C1/C2/C4/C5 (project record) · LTO 2.2% (already in).
  No known EXACTLY-0 or 1.0 dB-passing lever provides the missing ~2.2x.

## What could still change the answer (unproven, in order of credibility)
  1. STEP-0 surprise: if the built stack measures well under projection,
     re-derive this table from the real number.
  2. Structurally-zero coefficient proofs (audit found 39 candidates; the
     verify pass was cut off by usage limits; each needs a structural --
     any-preset -- proof before deletion, per GOAL.md).
  3. A second 8 MB-PSRAM S3 at 240 MHz is the known-good fallback the user
     has ruled out; it stays ruled out unless the user says otherwise.

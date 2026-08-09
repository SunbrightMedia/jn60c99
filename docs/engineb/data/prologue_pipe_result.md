# EB_PROLOGUE_PIPE — CLOSED NEGATIVE, and it exposed a wrong model
2026-08-10, Opus 5. Flag kept, default OFF.

## The measurement
  mask   NOPIPE    PIPE   delta        (CHUNK = 128, so a full block to
  0x00     1851    1850      -1         pipeline across; not a plumbing
  0x80     4736    4684     -52         limitation)
  0xc0     8015    7908    -107
  0xe0    11304   11143    -161
  0xf0    11074   10958    -116
  0xfc    10970   10965      -5   <- CONTROL, must be ~0: HELD
  0xd0     7785    7731     -54   <- PROBE, predicted -1300

The control held, so the experiment was sound. The probe delivered 4 % of its
prediction. **The lever is dead as built: ~1 %, not 20 %.**

## THE PART THAT MATTERS MORE: the timing model is WRONG
Two measured facts that cannot both be true under the model used to project
the two-chip fit:

1. **Core 0's voices are FREE.** 0xd0 (1 voice on core 0 + 2 on core 1) costs
   7,731 against 0xc0 (0 + 2) at 7,908 -- adding a whole sounding voice to the
   otherwise-idle core cost -177 cycles, i.e. nothing. Cross-core parallelism
   for VOICES works.
2. **Core 0's prologue is NOT free.** The PIPE slope is voice 3,230 with an
   intercept of 1,454, and that intercept is present even at 0xc0 where core 0
   has NO sounding voices at all. 7,908 = 1,454 + 2 x 3,230, exactly.

Under the model (loop = max(core0_work, core1_work) once the prologue is
pipelined), 0xc0 should cost max(1,454, 6,460) = 6,460. It costs 7,908 -- the
prologue is serialised with core 1's work one-for-one, even though core 0
publishes each prologue at the TOP of its iteration and then races ahead.

**I do not know why, and that is the honest state.** What follows from it:
the ~1,454 head is REAL and additive per sample, so the two-chip projection
built on this decomposition (2-voice core ~7,850 = 1.44x) rests on a model
that just failed its own prediction by 25x. That projection should not be
quoted again until the head is explained.

## What still stands, measured and independent of any model
  best 6-voice number: 10,965 (STEP13 and PIPE tie)
  same-mask deltas from the baseline 11,353: -388, bit-exact
  ATREST + the 14 coefficient deletions: kept, gated EXACTLY 0
  EB_FUSE_VCA: +168, rejected
  EB_PROLOGUE_PIPE: -54 at the probe, rejected

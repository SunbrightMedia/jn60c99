# IS THE 47-CYCLE MARGIN A LUCKY PATCH? (2026-08-10, measured)

The 0xd0 verdict (5,395 against 5,442) was measured on ONE patch and ONE
fixed chord. Two branches in the voice path are patch- and pitch-dependent
and could have swallowed a 0.9 % margin. Both are now measured over the whole
gated battery -- 36 scenarios on real recalled factory patches,
`EB_COSTPROBE=1`:

    sounding voice-samples          17,199,360
    eb_vcf_res LUT MISS rate        **0.0000 %  (0 of 17,199,360)**
    eb_dco_wt residual per sample   **0.0138**  (a 16-iteration loop each)

**THE LUT NEVER MISSES.** The expensive exact tail behind
`EB_VCF_RES_LUT` is not reached once in seventeen million voice-samples on
this bank. That branch cannot move the margin.

**THE RESIDUAL COSTS ~3 INSTRUCTIONS PER VOICE-SAMPLE** (0.0138 x ~235).
It scales with pitch -- higher notes cross more often -- so a chord an octave
above the battery's would roughly double it, to ~6. Against a 47-cycle margin
that is not a risk.

So the margin is NOT an artefact of patch choice. What it IS still exposed to
is stated in the next section, because that is the honest remaining doubt.

## ★ WHAT THE SWEEP DOES NOT TEST, AND WHY THE NEXT FIRMWARE EXISTS
`BEHIND REAL TIME` on every sweep line is NOT a failure signal: `behind` is a
LATCH set by a wall-clock check, and the sweep deliberately drives six-voice
masks that cannot fit, so it latches in phase one and never clears. The
per-mask `wake=` cycle figures are unaffected and remain the measurement.

But it means **the sweep has never tested REAL TIME at the per-chip
workload.** Its `engine` figure is 5,395 (under budget by 47) while its
`whole loop` figure is 5,486 (over by 44), and the difference is the sweep
harness's own bookkeeping -- whose real-firmware equivalent, the I2S DMA
write, has never been measured at this workload.

`juno_s3_REALTIME3.bin` closes that: **S3L_SWEEP=0, three voices, S3L_SPLIT=6
so the chord's voices 5/6/7 divide 1 on core 0 and 2 on core 1** -- exactly
the 2/1 split 0xd0 emulated, and exactly one chip's share of six voices. It
plays real audio through I2S and prints `realtime OK` or `BEHIND REAL TIME`
plus an underrun count.

That is the end-to-end test: FreeRTOS, DMA, codec and all. A cycle figure
under budget is a necessary condition; this is the sufficient one.

## THE SPLIT IS THE SHIPPING DECISION, RESTATED WITH THE RIGHT NUMBER
With `S3L_SPLIT=5` a three-note chord lands on voices 5,6,7 -- ALL on core 1
-- which is 7,780 cycles and fails by 43 %. With `S3L_SPLIT=6` the same chord
splits 1/2 and is the 5,395 that fits. **The voice-to-core map is not a
detail; it is the difference between fitting and failing by half.**

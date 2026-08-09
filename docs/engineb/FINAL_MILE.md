# FINAL MILE — from 1.42x to real time, for Opus 5, TIME-BOXED
2026-08-10, Fable 5. HARD LIMIT: a few hours. Do the steps IN ORDER; each has
a deliverable and an abort rule. No new theories are authorized. The goal is
unchanged: 6 voices + FX, TWO chips, 44.1 kHz, 8 slots, 1.0 dB gate.

## The distance, measured
  today (0xd0 = a 2-chip board's exact workload: 1v core0 + 2v core1)
                                        7,731 / 5,442 = 1.42x   gap 2,289
  after E1+E2 (kill coordination tax)  ~6,460 = 1.19x           gap ~1,018
  after kernel (~510/voice of a ~735   ~5,440 = FITS
  measured stall pool)
  FX ride the 1-voice core's ~2,200 of slack; measured later, not assumed.

## E1 — BLOCK-LAGGED HANDOFF (build first, ~1 hour)
WHY: the 1,454/sample head is NOT prologue arithmetic (core 0 finishes all
128 prologues in ~90k cycles while core 1 needs ~830k; core 1 never waits).
It is PER-SAMPLE CROSS-CORE OVERHEAD: the w_ready spin, SRAM/cache
arbitration between cores, and both cores writing the same 32-byte w_vbb
line. NOPIPE was ALREADY pipelined (publish happens before core 0's voices)
-- which is why EB_PROLOGUE_PIPE measured -54: it re-fixed a solved problem.
WHAT: EB_BLOCK_LAG flag. Double-buffer w_shb and w_vbb (two CHUNK-sized
banks). Core 0 fills bank A's prologues for block N while core 1 renders
bank B (block N-1). ONE handshake per 128 samples. Outputs consumed one
block late for core 1's voices -- mix alignment: delay core 0's voice
outputs by CHUNK samples so all voices stay sample-aligned (a CHUNK-deep
float ring per core-0 voice, trivial). LATENCY +2.9 ms total: state this in
the result doc; it is a USER-visible property.
BIT-EXACT: same operations, same per-voice sample order; only WHEN each core
computes moves. Gate: the on-board vector/state self-test pattern is not
needed here -- the null harness can run this (it is C, host-executable) --
JUNO null gate must read EXACTLY 0.
E2 -- CACHE-LINE SEPARATION (same build): give each core its OWN output
array, 32-byte aligned, no shared line. Two flags, ONE firmware each plus
the control, so the sweep separates E1 from E2.
MEASURE: the 0xd0 probe. SUCCESS = 0xd0 under ~6,700. ABORT RULE: if E1+E2
together recover < 400 of the 1,454, STOP -- the head is something else
(likely shared flash-cache thrash between cores; note it, do not chase it
past the time box) and report.

## K — THE ASM KERNEL, skeleton only inside this time box
Follow docs/engineb/ASM_KERNEL_WORKORDER.md steps A1-A2 ONLY:
  A1 asm_diff.py + the -S reference (shipping flags: EB_VCF_DEADCOEF,
     EB_VCF_RES_LUT=256, EB_ZEROCOEF, EB_ATREST_BLOCK).
  A2 verbatim-order .S behind EB_VCF_ASM + the on-board 100k-vector
     bit-exact self-test WITH its planted negative. Expect ~= C cost.
A3+ (the actual rescheduling, the only part that yields cycles) is NEXT
session's work -- starting it with under an hour left produces an ungated
half-kernel, which is worse than nothing. Deliver A2 proven instead.

## The report the user gets at the end of the box
One table: 0xd0/0xfc for control, E1, E1+E2; the E-verdict sentence; A2's
self-test verdict; and the honest remaining ladder with the measured numbers
filled in. No projections without a measured slope behind them.

## Standing rules (unchanged, non-negotiable)
Bit-exact changes get the EXACTLY-0 gate; sonic changes are not authorized
here at all. No madd.s. Flags default OFF. Every negative gets a data/ doc.
Sub-300-cycle deltas are noise. The DAW bounces are diagnostic-covenant
material and touch nothing.

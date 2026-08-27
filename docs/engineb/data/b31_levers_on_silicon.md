# b31 — the three levers on silicon: real but not enough (2026-08-27)

The three-lever build (L-B, L-A, both dead-store guards) ran on the board. The
levers are PROVEN correct (b30, forkbit EXACTLY 0) and they help, MEASURABLY --
but they do NOT close the steady-state deficit on their own.

## What the board showed

Idle `quiet` block, before the stress phase, DOUBLE-PROFILED build (VPROF+MSPROF
both on, ~11 CCOUNT reads/sample inside the loop, so absolute is inflated):

| build | idle quiet | period |
|---|---|---|
| b27 (no levers) | 6753 us | 5804 us |
| b31 (three levers) | **6635 us** | 5804 us |

**~118 us saved at idle**, profiler-constant, so it is the real lever delta.

## Why it is far less than the ~235 cyc/voice the hunt estimated
1. L-B and L-A fire only on SKIPPED cr_ph samples (1 of 2, 1 of 4), so their
   PER-SAMPLE AVERAGE saving is a fraction of the module's full cost. The b29
   estimates were per-invocation, not per-average-sample. This is the main gap.
2. VPROF's five measured modules (nsvf/noisemix/vcf/vca/decim) are UNCHANGED
   (vcf 611, vca 329) -- correct: none of the three levers touches those
   modules. L-B is in the prologue, L-A in the wt_live rebuild, A/R/Rk removes
   a compute VPROF never counted. So VPROF cannot see the saving; only the
   whole-block `quiet` can, and it dropped 118 us.

## The honest conclusion
The un-profiled shipping `quiet` was 6001 us (b12). Minus ~118 us ~= 5883 us,
still ~79 us OVER the 5804 us period. So:

* **The steady-state deficit is NARROWED, not closed.** The VCA move (b26/b27)
  is STILL NEEDED, but it now has ~79 us less to carry than before.
* The four DELAY TYPE 5 patches still spike (pat 49 delay=2140, pat 21=2085,
  pat 5=2099, pat 16=1503). The worst-case lever is untouched, as expected --
  these levers are voice-side, the t5 cost is master-side.

## What the profiled build CANNOT answer, and the clean flash that can
This build has both profilers on, so its absolute `quiet` is inflated and
"does it fit 5804" cannot be read directly -- only the 118 us DELTA is honest.
A build with NO profilers would print the true shipping `quiet`. That is the
next measurement: same three levers, `EB_MSPROF` and `S3_VPROF` OFF, read
`B4dur quiet` clean. Predicted ~5883 us -> still just over, confirming the VCA
move is required.

## The levers still earned their place
~118 us of the ~197 us steady-state deficit is real, proven-bit-exact relief
that costs no latency and no sound change -- unlike the VCA move, which costs
2.9 ms. Every one of those microseconds is one the VCA move no longer has to
find, so the VCA cut can be smaller.

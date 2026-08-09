# THE CLOSING WORK ORDER — the fused ladder+VCA kernel (2026-08-09, Fable 5)

GOAL, fixed by the user: 6 voices + FX, TWO ESP32-S3s, 44.1 kHz, 8 slots,
1.0 dB sonic gate. NO alternatives are to be proposed.

## The arithmetic that says this closes it
Two-voice core today: 2 x 3,394 = 6,788 vs 5,442. GAP = 673/voice.
MEASURED on the S3 toolchain's own output:
    ladder  ~516 insns for 1,083 cycles  -> c/i 2.1  (stalls ~567)
    VCA      211 insns for   379 cycles  -> c/i 1.8  (stalls ~168)
STALL POOL in these two modules alone: ~735/voice. GAP 673. Same size.

## Why the compiler cannot do it and a hand can
- The ladder's 4 sub-steps are ONE serial dependency chain; within a voice
  the compiler has nothing legal to reorder into the bubbles across the
  5 call boundaries (substep x4 + wrap24).
- The VCA's five strands (velocity smoother, mute smoother, gate ramp, tone
  filter A, tone filter B) are INDEPENDENT of the ladder until the final
  (mix*g1)*g2 -- perfect bubble filler, but they live in another TU.
- -ffp-contract=off is LOAD-BEARING (no madd.s: single rounding differs).
  The kernel reorders INSTRUCTIONS, never operations: same ops, same
  parentheses, same rounding -> BIT-EXACT by construction, gated EXACTLY 0.

## The steps
1. Extract the exact op sequence: ladder tick + 4 substeps + VCA tick,
   inlined, as a single .S file generated FROM the compiler's own -S output
   (start from what is correct, reschedule, never retype).
2. Software-pipeline: hoist the 4 substep input weights; weave VCA strands
   into ladder latency slots; keep <= 16 live FP regs (the wall that killed
   interleave ACROSS voices does not apply: one voice's ladder+VCA peaks at
   ~12 live).
3. Gate: null_b EXACTLY 0 (bit-exact claim, so the -100 dB gate applies,
   not the sonic one) + test battery + one firmware, wake sweep.
4. Then the small stack: tone-filter skip (~40-60), zero-coef deletions
   (60-130 pending the reading pass), ATREST (already gated, on the desk).

## Expected landing
voice 3,394 - ~600 (kernel) - ~100 (stack) ~= 2,700 => two-voice core
~5,400 vs 5,442 budget: FITS at 44.1 kHz on TWO chips, exact, 8 slots.
Margin is thin; the FX number (unmeasured on silicon) rides the 1-voice
core which has ~1,300 free. If the kernel lands short, the remainder comes
from extending the kernel over dcoprep+noisemix (same method, ~150 more).

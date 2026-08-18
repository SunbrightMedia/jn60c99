# The wait is 5 cycles, the split is a real lever, and neither setting is enough
2026-08-18, MEASURE build 03eb5f7-dirty, board e8:f6:0a:a7:d7:0c, 656 s.
PROVEN (executed) throughout. The user moved the split with '.' several times;
every press past 8 is clamped, so the run is two configurations, not several.

## 1. THE WAIT IS 5 CYCLES. THE POOL IS REAL.
At the shipping split, over t=1..14, `wait` reads **5 per sample, every second,
without variation**. Core 1 does not wait on core 0 -- it is the bottleneck,
and core 0 is the core that spins. b5_fx_attribution.md inferred this from
cyc = fx + v1 and could not prove it, because v1 contains the spin. It is
proven now, and the inference was right.

THE RESPONSE TEST FOR `wait` FIRED IN THE SAME RUN: moving the split sent it
from 5 to 1,399-3,307. A counter seen at both ends of its range, on a known
stimulus, is a measurement. No tooth build was needed.

## 2. THE TWO CONFIGURATIONS, MEASURED
                          SPLIT 7 (shipping)      SPLIT 8
                          core0: 1 voice          core0: 2 voices
                          core1: 1 voice + FX     core1: FX alone
    fx      non-delay     2,434-2,661             2,369-2,896
            DELAY         3,916-4,144             3,930-4,276
    wait                  5                       1,399-3,307
    cyc     non-delay     5,112-5,389   UNDER     5,735-5,881   OVER
            DELAY         6,526-6,821   OVER      5,801-5,910   OVER
    budget 5,442

SPLIT 8 BUYS ~900 ON THE DELAY PATCHES AND COSTS ~600 ON EVERY OTHER PATCH.
It flattens the profile -- every patch lands in one narrow band -- because
core 0's two-voice pass becomes the critical path and does not care which
delay arm is selected.

## 3. THE NUMBER THAT NOW BOUNDS EVERYTHING
    fx + wait = CORE 0's TWO-VOICE PASS = 5,522-5,706, at every patch class.
That is measured directly, not attributed: at split 8 core 1 runs the FX and
then waits for core 0, so fx + wait IS core 0's block. It is flat across delay
and non-delay, which is the control -- core 0 renders no FX, so it must be.

Per voice that is ~2,805 on core 0 (which also carries the prologue) against
~2,590 for a voice on core 1 (split 7, v1 with wait=5). TWO VOICES ON ONE CORE
ALREADY SPEND 5,610 OF THE 5,442 BUDGET BEFORE ANY FX EXISTS.

## 4. THE VERDICT: KEEP SPLIT 7, AND THE FX MUST BE DIVIDED
Moving voices cannot fix this, and the arithmetic says why. With the FX chain
INDIVISIBLE the achievable block time is
    split 7:  fx + 2,590        split 8:  5,610
which cross at fx = 3,020. Below it split 7 wins, above it split 8. But
split 8's floor is 5,610 -- already over budget -- so it never delivers a
compliant patch. Split 7 keeps 60 of 64 patches under budget; split 8 keeps
none. THE SHIPPING SPLIT STAYS AT 7.

The balanced ideal, if the chain could be divided, is (5,610 + fx) / 2:
    non-delay  ~4,105          DELAY  ~4,830        both UNDER 5,442
So the ~1,350/~2,020 pool b5_fx_attribution.md named is REAL but is NOT
reachable by moving whole voices. Reaching it requires splitting the master
chain itself across the cores, which costs one more block of pipeline latency
(5.8 ms). The invariant permits late changes. That is the design step, and it
is now the only route to the delay patches that the measurements support.

## 5. WHAT THIS DOES NOT SETTLE
- WHY the delay arm costs 1,450 more than the rest of the chain. Located, not
  explained. The ring is not the leading suspect (b5 §3, moving-tap 30.0
  cyc/tap this run) but arithmetic-vs-access is still not separated.
- Only 4 of 64 patches (5, 16, 21, 49) show the high fx band while
  b4_stress.py classifies 18 as DELAY TYPE 2/3/5. Still open.
- un=0 in both configurations; the burst and the ovr_late/drift timer anomaly
  are unchanged (b4_first_run.md §5).

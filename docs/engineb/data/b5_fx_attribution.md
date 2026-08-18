# The delay cost is located, the rings are innocent, and core 0 is half idle
2026-08-18, MEASURE build 3f48785-dirty, board e8:f6:0a:a7:d7:0c, 385 s,
all 64 patches stepped six times. PROVEN (executed) unless marked.

## 1. THE RESPONSE TEST PASSED, ON 64 LIVE STIMULI
`fx` tracks the patch class and `v1` does not move. Non-delay patches read
fx 2,376-2,998; patches 5, 16, 21 and 49 read fx 3,916-4,144 and return to
the low band on the very next patch. v1 stays 2,559-2,637 through all of it.
A number that steps on exactly the four patches that cost extra, and on
nothing else, is a measurement. The tooth (S3L_FXPROF_TOOTH) was not needed.

## 2. THE EXTRA CYCLES ARE ALL IN THE FX. AND cyc = fx + v1.
        t     fx     v1   fx+v1    cyc   diff
        1   2606   2590    5196   5248    +52
       22   4068   2586    6654   6756   +102
       85   4057   2565    6622   6526    -96
      140   2535   2570    5105   5071    -34
      280   4098   2584    6682   6821   +139
      342   4107   2565    6672   6741    +69
    diff range -96 .. +139 over delay and non-delay alike

THE BLOCK TIME IS CORE 1'S TWO HALVES ADDED TOGETHER. There is no overlap at
all. The FX-first reordering in juno_s3_listen.c was justified by "the FX
fills the window where core 1 waits on core 0" -- and at TWO voices core 1
never waits, because core 0 carries ONE voice (~2,500 cyc) while core 1
carries one voice PLUS the whole master chain. Core 0 finishes and spins at
the barrier for roughly half of every block.

## 3. THE RINGS ARE NOT THE LEVER (this corrects b4_second_run.md §2)
The boot probe's new MOVING-TAP row -- the delay's own pattern, one float
forward per sample with a wobble, two adjacent floats interpolated -- reads
29.9 cyc/tap against the scattered row's 229.5 and internal scattered's 18.8.
The scattered row was 7.7x pessimistic and measured a pattern the delay never
runs. b4_second_run.md attributed the delay delta to PSRAM ring latency on
the strength of that row. THAT ATTRIBUTION IS WITHDRAWN.
A type-5 arm would have to take ~43 moving taps per sample for latency alone
to explain the +1,300, which it does not. NOT SEPARATED YET: how much of the
FX delta inside the arm is ring access and how much is arithmetic -- but the
ring is no longer the leading suspect, and no ring may be moved on this
evidence.

## 4. THE HEADROOM IS IN THE LOAD BALANCE, AND IT IS BIGGER THAN THE OVERRUN
Per sample at 2 voices, total work = 2 voices + FX:
    non-delay  2 x ~2,575 + ~2,700 = ~7,850   perfectly split ~3,925
               measured today                  5,270   -> ~1,350 recoverable
    delay      2 x ~2,575 + ~4,050 = ~9,200   perfectly split ~4,600
               measured today                  6,620   -> ~2,020 recoverable
A balanced split puts the DELAY patches at ~4,600 against the 5,442 budget --
under it, with room. The recoverable amount EXCEEDS the overrun it must pay.

WHY IT IS NOT A ONE-LINE CHANGE, stated rather than hidden: the master chain
is one serial, stateful, per-sample chain. It cannot be split by sample (the
ring state is sequential) and it cannot be split mid-chain without another
pipeline stage, which costs one more block of latency (5.8 ms). The invariant
permits late changes, so that cost is affordable -- but it is a design step,
not a knob.

## 5. WHAT DOES NOT CHANGE
Only FOUR of 64 patches show the high band, while b4_stress.py classifies 18
as DELAY TYPE 2/3/5. So the cost is narrower than the type classification --
OPEN, and it should be settled before any arm is optimised.
The burst (2.02-2.22 M) and the ovr_late/drift timer anomaly are unchanged
and still owed (b4_first_run.md §5).

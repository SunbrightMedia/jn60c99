# b11 — the budget starved the path it was added to protect
(2026-08-19. Board run of the budgeted-burst build. A REGRESSION, found on
silicon, caused by b10 §3.)

## 1. THE SYMPTOM: NOT ONE NOTE IN 280 SECONDS
    NB:   ev=0 vb=0 nv=0 st=0 tot=0 key=0 keymax=0
    KEYH: 0=0 1=0 2=0 ... all zero
    EVQ:  sub=255 del=0 dep=255 ref=9019 hi=255
    SCHED: slack~460000 note=0 burst=591526  defer=46995 forced=745

`note=0` is the tell: the note machine's worst step was never measured because
IT NEVER RAN ONCE. 9,019 events refused. The instrument was not playable at
all, on a build whose host gates were entirely green.

## 2. THE ARITHMETIC, WHICH IS THE WHOLE EXPLANATION
The patch burst's worst step measured **591,526 cycles against ~460,000 of
slack**. It CANNOT FIT, ever: the reseed (437,834) and the bank apply are
single indivisible operations larger than any block's spare time.

So every burst step deferred to the 64-block starve limit and was then forced.
One program change went from ~15 blocks to ~384. The robot requests patches
every 43-86 blocks, so the build RESTARTED before finishing -- `rst=588` --
and `burst_state` was therefore never IDLE.

⚠ AND THE NOTE BRANCH ONLY RUNS WHEN IT IS. The interlock is correct and
necessary (the shadow has one owner). The defect is that budgeting the burst
made the interlock permanent. **The budget starved the exact path it was added
to protect, and not through its own deferrals -- through something else it
made slow.**

## 3. THE ERROR IN THE DESIGN, NAMED
b10 measured `miss note=23` and `miss burst=7`. The budget was for the NOTE
path. It was applied to BOTH because "rule 2 covers all incremental work",
which is true of the rule and false of the implementation: the note build is
divisible into ~148,000-cycle pieces that fit; the patch burst is not.

**A BUDGET IS ONLY MEANINGFUL FOR WORK THAT CAN BE MADE TO FIT.** Deferring
work that can never fit does not protect the deadline -- the work still runs,
later, in one lump -- it only delays everything queued behind it. The right
treatment for a step bigger than the slack is to MAKE IT SMALLER or to accept
its overrun, never to postpone it.

## 4. THE FIX
The patch burst is no longer budget-gated; it runs one step per block as it
did before b10. Its cost is still MEASURED and still printed, so the report
shows why it is not gated. The note path keeps the budget: its step is
~148,000 cycles against ~460,000 of slack, so it fits and the gate is real.

## 5. WHY NO HOST GATE CAUGHT IT
sched_gate.py checks the budget's arithmetic and note_gate.py checks the
sequence. Both are correct and both passed. The defect lives in NEITHER: it is
an interaction between the budget, the interlock and the ARRIVAL RATE of patch
requests -- three components that are individually right.

⚠ THE LESSON: unit-correct components compose into a system that starves. The
missing gate is a WHOLE-INSTRUMENT one -- the stress gate FINAL_GUIDE already
calls for (F1) -- and no amount of per-component teeth substitutes for it. The
robot keybed IS that harness; it found this in one run. It should run on every
candidate build before the build is called a candidate.

## 6. WHAT THE RUN DID CONFIRM
  * `pubretry=0` on both machines -- the hand-over contract holds on silicon.
  * `torn=0`, `sub = del + dep` exact -- O1's queue is sound under refusal.
  * The `t` key works: `TOOTH: stalling ONE block on purpose`, then ovr and
    miss both moved and HEALTH stayed red. The detectors are live.
  * `un=0` throughout. Even completely starved of note builds, THE AUDIO NEVER
    BROKE -- which is the invariant holding under a defect that made the
    instrument useless. Latency degraded to infinity; continuity did not.

## 7. THE FIX WORKED, AND THE LAST CRITERION IS THE WRONG TEST (run 3)
Six of seven criteria pass, and both regressions are closed:

| criterion | result |
|---|---|
| KEYH 0,1 zero; 2 dominant | **PASS — 2=337 of 337, exclusively** |
| keymax bounded | **PASS — 2** (run 1 had two 9s; none now) |
| pubretry=0, both machines | **PASS — 0** |
| SCHED forced=0 | **PASS — forced=0, defer=0** |
| ref=0 | **PASS — 0** (9,019 -> 542 -> 0) |
| detectors seen to fire | PASS — HEALTH red, `t` tooth fired |
| miss note=0 | **FAIL — note=16** |

The 256-slot queue took refusals to ZERO, the un-gated burst restored the note
path, and the key now sounds in exactly 2 blocks EVERY TIME -- bucket 2 holds
every single one of 337 presses, with 0, 1 and every higher bucket empty.

### ⚠ BUT `miss note=16` CANNOT MEAN WHAT THE RULE ASSUMED
SCHED says the worst note step is **219,493 cycles against 418,050-851,999 of
slack**. It always fits; `defer=0` confirms no step was ever refused. So the
note step is NOT overrunning its budget -- yet 16 misses are attributed to
blocks that ran one.

Look at `cyc`: **5,412-6,734 against a 5,442 budget.** Those blocks were
ALREADY over before any note work happened. That is the delay-patch
steady-state overrun, which is O4 and has been measured since b6.

`note_ran_this_block` cannot distinguish "the note caused this miss" from "a
miss happened while a note was in flight". A note build spans ~10 blocks, so
it overlaps most misses by coincidence.

⚠ THIS EXACT TRAP IS ALREADY WRITTEN DOWN IN THIS FILE, for `burst`:
"`miss` climbs for reasons O2 does not own and cannot fix... it would fail for
O4's reasons and send the next session hunting the wrong cause". The `note`
counter was added later WITHOUT that reasoning applied to it. A warning is not
a guard: it protected the counter it was written next to and nothing else.

### The measurement that settles it: a RATE, not a count
The firmware now counts BLOCKS per class as well as misses, and prints
`B4rate: burst=/10k note=/10k quiet=/10k`. The claim under test is that a note
step fits its slack, so:

  **THE NOTE MISS RATE MUST NOT EXCEED THE QUIET MISS RATE.**

Equal rates mean the note path is not the cause and O2's acceptance is met.
A higher note rate means it IS the cause, and the step is genuinely too big
for the blocks it lands on. Either way the answer is a number, not a
judgement -- which a bare count could never give.

## 8. THE RATE WAS THE WRONG INSTRUMENT TOO — USE THE MEAN
Two runs of the rate build gave IDENTICAL counters: note=21, quiet=20 misses
on 6,105 and 6,618 blocks -> 34/10k and 30/10k. (Identical because the robot
is deterministic, which is a useful fact in itself: the harness is exactly
repeatable.)

⚠ THAT COMPARISON CANNOT BE SETTLED BY RUNNING LONGER, for two reasons:

  a. **Poisson.** At ~20 events the error is +-4.5 on each count, so 34 and 30
     overlap. Reaching a 10 % separation needs ~400 events per class, i.e.
     roughly 30 minutes of stimulus, for a question that does not need it.
  b. **THE CLASSES ARE NOT EXCHANGEABLE, which is the real defect in the
     test.** Note blocks cluster in the robot's BUSY phases, where patches are
     stepping and the delay arms are live. Quiet blocks include the SILENT
     baseline phase. The note class is drawn from a more expensive population
     for reasons that have nothing to do with the note build, so a higher note
     rate is expected even if the note step is free.

### The direct question, with thousands of samples instead of twenty
**DOES A BLOCK THAT RAN A NOTE STEP TAKE LONGER THAN ONE THAT DID NOT?**

`B4dur: note= quiet= burst= period=` -- mean block duration per class, over
EVERY block. The prediction is specific: a note step is ~222,000 cycles and
core 0's measured spin is 420,000-880,000, so the step runs inside time core 0
already spends WAITING FOR CORE 1 and should add nothing measurable.

  * note ~ quiet  -> the note step is free, O2's claim is confirmed DIRECTLY,
                     and the residual misses are the background rate (O4).
  * note >> quiet -> the step really does extend its block, and O2 is not done.

A mean over thousands of samples answers in 90 seconds what a tail count could
not answer in half an hour. Reaching for a longer run was the wrong instinct:
the fix was a better instrument, not more data through a blunt one.

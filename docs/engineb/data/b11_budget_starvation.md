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

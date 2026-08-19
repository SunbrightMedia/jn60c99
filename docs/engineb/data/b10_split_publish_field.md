# b10 — the split publish on silicon, and the budget it forced
(2026-08-19. Board run of the O2 split-publish build, then the fix it demanded.
Supersedes b9 §9's "not measured on silicon" caveat.)

## 1. THE SPLIT PUBLISH IS CONFIRMED
Robot keybed, six phases, ~113 s, 521 key presses through the real boundary.

| criterion (stated BEFORE the run, b9 §10) | result |
|---|---|
| KEYH buckets 0,1 zero; 2 dominant | **PASS** 0=0 1=0 **2=519 of 521 (99.6 %)** |
| keymax bounded and explainable | **PASS** 9, twice |
| pubretry = 0 | **PASS** 0 |
| sub = del + dep, torn = 0 | **PASS** exact, torn=0 |
| miss does not increment | **FAIL** note=23 burst=7 quiet=21 |
| ref = 0 | **FAIL** ref=542 |
| detectors seen to fire | **PASS** HEALTH latched red from REAL misses |

**58 ms -> ~12 ms, measured.** Buckets 0 and 1 empty is the load-bearing one:
no key ever sounded before the block that built it, so the early publish is
publishing real work and not an empty swap.

keymax=9 twice is NOT a fault and was predicted by the rule: an 8-key chord
names all eight voices, so the priority set IS all eight and the build is
1 + 8 blocks. The design is "the voices the player is waiting for go first";
when the player is waiting for all of them there is nothing to defer.

## 2. WHY IT STILL FAILED — A VOICE IS NOT A BUDGET
23 misses in ~4,160 note-build blocks: **0.55 %**. The step nearly always fits.
It missed when it LANDED ON A BLOCK THAT HAD NO SLACK LEFT.

THE INVARIANT rule 2 says the work gets "a FIXED budget of work per block".
O2 had read that as ONE VOICE PER BLOCK. A voice is not a budget -- it is a
fixed lump of ~148,000 cycles, and whether it fits depends entirely on what
the block was already doing. On DELAY TYPE 0 there is room; on patches
5/16/21/49 the block is over budget before any burst work starts (6,526-6,821
against 5,442 -- that is O4, not O2).

⚠ FINER CHUNKING WOULD NOT HAVE FIXED THIS. The fault is WHEN the step runs,
not how big it is. Sub-voice granularity was the obvious next move and it was
the wrong one; the log said so and the log was read before the code was
written.

## 3. THE FIX: THE BUDGET IS MEASURED, FROM CCOUNT
A step runs only when core 0's measured slack covers the worst measured step
of that kind. Otherwise it waits one block, COUNTED (rule 4).

⚠ **NOT FROM esp_timer, AND THAT CHOICE IS LOAD-BEARING.** The obvious budget
is "period minus how long the last block took". The block gap reads
9,000-11,000 us against a 5,804 us period in EVERY run on this board, and why
is an OPEN item (b4_first_run.md §5, ovr_late on ~60 % of blocks). A scheduler
built on it would conclude there is never slack, defer for ever, and force
every step -- worse than no scheduler. Building on an unexplained measurement
is exactly how the ring attribution went wrong (playbook 55).

**CORE 0'S BARRIER SPIN IS THE HONEST NUMBER**, already measured in CCOUNT:
`while (!w_done) { }` is core 0 with nothing to do while core 1 finishes. That
spin IS the slack, in cycles, on the core the burst actually runs on.
  * `g_quiet_spin`   the spin on the last block that ran NO burst work
  * `g_step_cyc_note` / `g_step_cyc_burst` worst measured step, PER MACHINE

⚠ ONE WORST-CASE PER MACHINE, not one shared. The patch reseed is ~440,000
cycles and a note's voice step ~148,000. A shared maximum would let the
reseed's figure gate every note step for ever -- the note refused room it
actually had, and the budget starving the very thing it was added to protect.

⚠ IT MUST NOT STARVE. "The change arrives later" is the invariant; "the change
never arrives" is not. On a patch whose steady-state cost already exceeds the
period, slack never appears. After SCHED_STARVE (64 blocks, ~370 ms) the step
is FORCED and counted SEPARATELY. A forced step is a report of O4's problem,
not O2's, which is why `forced=` is printed apart from `defer=`.

The scheduler is self-correcting by construction: a deferred block runs no
burst work, so it counts as quiet and refreshes the slack measurement. It
cannot deadlock on its own input.

## 4. ALSO FIXED
`nv=32` counted all 32 bits of `~0u`. The BUILD was always right (the cursor
masks to EB_NUM_VOICES internally); the PRINT was not. A figure that cannot be
true on an eight-voice engine is worse than no figure.

## 5. WHAT ref=542 IS, AND WHAT IT IS NOT
The queue refused 542 events, `hi=63` of 64. A note occupies ~11 blocks and
`ev_apply` only draws when no note build is in flight, so during the STORM
phase (172 events/s, far beyond any human) the queue fills. Refusal is
bounded, counted, and latches HEALTH -- the queue doing what it was built to
do. It is still recorded as a FAIL because the rule said ref=0 and the rule
was set before the run. Moving a threshold after seeing the data is how a
gate stops meaning anything.

## 6. THE NEXT RUN'S RULE (unchanged where it passed)
CONFIRMED if: `SCHED forced=0`, `miss note=0`, `KEYH` buckets 0,1 zero and 2
dominant, `pubretry=0`, `torn=0`. `defer=` may be any value -- that is the
budget working. `ref=` is expected non-zero in the storm phase only.
REFUTED if forced>0 on DELAY TYPE 0 patches, or if KEYH 2 stops dominating --
either means the budget is refusing room that exists.

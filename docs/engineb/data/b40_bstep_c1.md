# b40 — Step 3: note-build steps move to core 1's park time (S3L_BSTEP_C1)

## The problem b39 created
Step 3's plan drew the burst slice from CORE-0 slack. REV-PIPE spent it:
the b39 flash reads SLACK slack=7 cyc. Note blocks now run 6,221-6,669 us
against the 5,804 us period (B4 miss note= ticks), because the ~140-200k-cyc
voice-build step extends a core-0 block that has no room left.

## Where the slack went
Core 1: fx 1,316-1,800 + v1 ~2,600 cyc/sample against the per-sample budget
-> core 1 parks ~260-390k cycles per block. A note step FITS there and
nowhere else.

## The mechanism (machine code unchanged; the call moves cores)
In NB_PRI/NB_REST the machine's one expensive call is purely
eb_recall_chunk_step (a voice build into the SHADOW bank -- state no
renderer reads). Core 0 posts bs_req BEFORE w_go (its MEMW orders the
store); the worker executes the step at its pass tail, before w_done (its
MEMW publishes bs_ret); core 0 advances the machine AFTER the barrier, in
the quiescent window, nb_chunk() consuming the stored result exactly once.
The prediction is exact: in those states the machine always calls
chunk_step; note_pending, the burst interlock and the budget cannot move
mid-block. bs_mispredict counts violations and MUST read 0.

## Not delegated, and why
- NB_EVENTS: allocator + event queue = policy, and cheap (~17k + bank copy).
- The patch burst: reseed 437k cyc fits NO slack; stays under C10
  (bounded 1-4 block miss per program change, absorbed by the DMA cushion).
- The knob machine: worst apply 302k > the ~260k floor of core 1's park;
  measured before any move.

## Verdict criteria (next flash, counters baked in)
- `BSTEP: c1=` grows while playing; `mispredict=0`; `cycmax` <= core 1 park.
- `B4: miss note=` stays 0 over a key+patch soak. That is Step 3's counter
  for notes.
- OPEN, not claimed: quiet misses ~2/1,000 blocks remain UNATTRIBUTED
  (suspects: LKA link thrash in BAD-PAIR bench state, reporter prints).
  Attribution owed before Step 4 shrinks the cushion.

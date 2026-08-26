# OPEN FINDING — JX fuzz seed 2 diverges (2026-08-26)

Status: **OPEN, UNATTRIBUTED.** Recorded the moment it was seen, before any
attempt to explain it, so the finding cannot quietly disappear.

## What was seen
The new seeded fuzz gate (`jx3p/tools/fuzz_gate.sh`) failed on its third seed:

    seed 2: sr=96000 patch=7 warm=2 notes=[(70, 107)] n=75

Seeds 0, 1 and 3 passed, including seed 3 at the non-standard 88200 Hz with
five simultaneous notes. Replay, forever, with:

    sh jx3p/tools/fuzz_gate.sh 2 3

## What is NOT yet known
- Whether the divergence is in the voice arm, the master, or the seam.
- How many samples in it starts, and in which cell.
- Whether it is rate-dependent (96000), patch-dependent (7), warm-dependent
  (only 2 warm blocks, the shortest so far), or note-dependent.
- Whether the factory-bank A/B would have caught it at a different N. The bank
  A/B uses warm=6 and n=64 for EVERY patch; this seed uses warm=2 and n=75.

No hypothesis is recorded here because none has been measured. Playbook 46: a
number quoted is not a number measured.

## Why this matters beyond the bug
This is the second defect in one day found by the value/shape spread that the
factory bank holds constant, and the first one (FTZ/DAZ) was a whole-port
floating-point MODE mismatch. Both were invisible to a gate that was green on
64 patches at 3 rates. The gate suite was measuring one point and reporting a
space.

## Owed next
1. Bisect the divergence: first differing sample, first differing cell.
2. Decide whether it is a PORT defect or a HARNESS defect (charter rule 7 —
   run the control: the same seed with nothing changed must already agree).
3. Only then, fix — and add the shape that found it to the gate's grammar.

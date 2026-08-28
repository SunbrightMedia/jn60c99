# b32 — clean-build silicon: headroom NOT closed, gap larger than predicted

The no-profiler three-lever build ran on the board. The honest shipping number:

    B4dur: quiet=6460 us   period=5804 us    (pure idle, blocks 0/0/171)

Under the robot stress load quiet climbs to ~6870-6935 us. The board MISSES
DEADLINES throughout (HEALTH red, note/quiet miss rates 40-90/10k). `un=0`
(the blind counter) but `B5 deficit` climbs monotonically -- true starvation.

## The correction I owe: my ~79 us prediction was wrong
I predicted clean quiet ~= 5883 us (b12's 6001 minus the 118 us lever saving).
It came in at 6460. The error: b12's 6001 us was a DIFFERENT configuration and
was not a valid baseline for this build. Comparing incomparable numbers is
exactly the trap this project keeps a catalogue of; I fell into it.

## What IS solid
The lever saving is config-matched and real: b27 (no levers, profiled)
quiet=6753 vs b31 (levers, profiled) quiet=6635 = **118 us**, same everything
except the levers. So a no-lever clean build would be ~6578 us; the levers buy
~118 us of that. They are proven bit-exact (forkbit) and worth keeping.

## The sobering implication for O4
Idle is ~656 us over period; loaded is ~1070 us over. The VCA move moves at
most ~400-600 us (380-580 cyc/sample). So **the VCA move ALONE will not close
this.** The plan needs more than the voice-side levers + VCA move:

* the VCA move (subset) -- still worth doing, ~400-600 us
* the delay-t5 worst case (b20/b21) -- still open, the four hot patches
* possibly the master-chain split (b22, costs latency + a feedback question)
  or a measured sonic trade, both of which the invariant/END_GOAL constrain.

This is an O4 re-plan, not a tweak. The honest position: with 3 voices on one
chip at this config, the engine is ~11% over budget at idle and the known
voice-side levers recover ~2% of it. The two-chip split (3+3) is what the
END_GOAL relies on to make the budget -- and O6 (the link) is where the other
three voices move off this chip. So the real question the next session must
settle is whether O4's target is "3 voices fit one chip" (hard, maybe
impossible without latency) or "the SHIPPING 3-per-chip split fits", which is
a different and easier measurement that O6 sets up.

## Next
1. Re-read the O4 target against END_GOAL: is the budget per-chip-3-voices
   (shipping) or per-chip-more? The stress build renders 3 here but the split
   test (`,`/`.` keys) and O6 change the picture.
2. Build + host-prove the subset VCA move regardless -- it helps under any
   target.
3. Re-measure, then decide on the delay-t5 / split levers with real numbers.

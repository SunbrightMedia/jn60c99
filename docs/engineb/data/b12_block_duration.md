# b12 — What a chunked step really costs a block (47-minute silicon run)

Board run, 2026-08-19, split 7, robot keybed phases 1-5 incl. PATCHSTORM.
All numbers PROVEN(executed) on silicon and quoted verbatim from the console.

## 1. The headline

```
B4rate: burst=21/10k note=31/10k quiet=28/10k  (blocks 83670/200827/203294)
B4dur:  note=6190us quiet=6001us burst=6192us  period=5804us
```

Health on the same run: `pubretry=0` (both machines), `torn=0`, `ref=0`,
`un=0`, `defer=0`, `forced=0`, CRC MATCH all patches.
Key latency: bucket 2 = 15,356 of 15,462 presses; bucket 9 = 106, all
8-key chords, where every voice is in the priority set (b10 §11).

## 2. Read `B4dur`, not `B4rate`

A raw miss count cannot attribute (playbook 46 class). A miss RATE per class
still cannot: note blocks cluster in the busy phases, quiet blocks include the
silent baseline, and at ~600 events each class the Poisson error is ~4 %.

The MEAN BLOCK DURATION per class has neither problem. It is a per-block
measurement of the thing the deadline is about.

| class | mean block | over period |
|---|---|---|
| quiet (no chunk step at all) | 6,001 µs | **+197 µs** |
| note step in the block | 6,190 µs | +386 µs |
| burst step in the block | 6,192 µs | +388 µs |

**NOTE MINUS QUIET = 189 µs.** That is what one chunked note step costs the
block it runs in. The note path's own average is ~496 µs/block, so ~62 % of it
is absorbed by core 0's spin — which is exactly what split 7 was chosen to buy
(b6: core 1 is the bottleneck, core 0 spins).

## 3. THE FINDING THAT REDRAWS THE TRACK BOUNDARY

`quiet = 6,001 µs against a period of 5,804 µs`.

A block with **no chunk step, no note, no program change, nothing but audio**
is 197 µs over period — 3.4 %. drift reached +150,106 µs across the run.

Therefore:

> **`miss = 0` IS UNREACHABLE FOR ANY SUBSYSTEM ON THIS BUILD.**

O2's old acceptance rule — "miss MUST NOT increment across a program change or
a played note" — asked O2 to remove a miss it does not cause. No amount of
chunking can make a block that already overruns empty stop overrunning. The
rule was written before the background was measurable, and it is now known to
be unpassable by construction.

The correct rule, and the one O2 is measured against here:

> **A chunked step must cost the block a BOUNDED, MEASURED amount, and must
> not make the note path or the patch path own the shadow indefinitely.**

Against that: 189 µs bounded and measured, `defer=0`, `forced=0`, `ref=0`,
`pubretry=0`, key audible in 2 blocks. O2 passes.

The residual 197 µs belongs to **O4** — the steady-state overrun, whose real
number is now quotable without any note or patch work in the frame:

> **O4's number: an idle block runs 6,001 µs against a 5,804 µs period.**

That supersedes every earlier attempt to state O4's deficit from patch cycle
counts alone, and it means the `ovr_late` / esp_timer-vs-I2S anomaly
(b4_first_run.md §5) is not a reporting artefact — it is the deficit itself.

## 4. What the miss rates say once the background is known

note 31/10k vs quiet 28/10k: an ~11 % relative increase on a background that
dominates. Consistent with 189 µs of extra work on a block that was already
197 µs late. Burst 21/10k is BELOW quiet, which is not a paradox — burst
blocks cluster in PATCHSTORM, where no note is being built.

## 5. Method carried forward (item 7)

1. Measure a per-class MEAN of the quantity the deadline is about. Do not
   measure a count, and do not measure a rate of a rare event, when a mean of
   a per-block duration is available.
2. Always carry the class that does NOTHING. `quiet` is what turned an
   unattributable miss count into a two-line verdict and moved the remaining
   work to the correct track.
3. An acceptance rule written before the background was measurable must be
   re-derived, not argued around, once it is.

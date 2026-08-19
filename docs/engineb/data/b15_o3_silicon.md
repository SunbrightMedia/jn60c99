# b15 — O3 on silicon, and a retraction of b14's O4 target

Board run, 2026-08-19, 425 s, robot phases 0-6 including KNOBSTORM.

## 1. O3 PASSES ON SILICON

    PARAM: edits=10146 builds=665 defer=718 unknown=0 pubretry=0
           apply=247067 applymax=291393 blocks=10

| reading | value | meaning |
|---|---|---|
| `unknown=0` | 0 | every parameter id the robot sent is in the class table |
| `pubretry=0` | 0 | no build was ever stranded by a refused publish |
| `edits/builds` | 10,146 / 665 | **15.3x coalescing** |
| `apply` | 164k-247k cyc | the warm recall, as designed |
| `applymax` | 291,393 cyc | worst case, ~1.21 ms |
| `blocks` | 10-12 | blocks per knob build |

`applymax = 291,393` against `SCHED slack` of 420k-1.3M: the warm recall FITS,
which is what permitted budgeting this machine at all (b11's rule). `forced=0`
throughout — the budget never had to force a step through.

**The coalescing is the headline.** 10,146 edits cost 665 rebuilds. C9's "as
many parameters as you please, at the same time, without overloading the CPU"
is met by construction, not by luck.

### The cost O3 charges, stated

`KEYH` shows bucket 9 = 78 presses against bucket 2 = ~1,900. So a key
occasionally waits 9 blocks instead of 2 — the note machine queuing behind a
parameter build. That is the priority policy b13 §8 predicted (it modelled up
to 48 blocks under a heavier storm) now visible on hardware at 78 of ~2,000
presses. It is a POLICY, and it is the user's to overturn.

## 2. ⚠ RETRACTION: b14's O4 TARGET WAS BUILT ON A UNIT ERROR

b14 claimed b12's block durations were confirmed by the drift counter —
"implied drift 149.5 s vs the board's own 150.1 s, agreement 0.4 %". 

**That is wrong. 150,106 µs is 0.15 SECONDS, not 150 seconds.** The two numbers
disagree by a factor of 1000, and b14 read a µs field as seconds and called it
corroboration.

### What the board actually says

    blocks counted        73,443   (12,499 + 26,721 + 34,223)
    elapsed                  425 s
    implied mean interval  5,787 µs
    period                 5,805 µs
    B4dur weighted mean    6,081 µs  -> would imply 447 s elapsed
    drift at t=425        +20,114 µs = 0.02 s  ->  0.274 µs per block
    B4dur excess per block   276 µs      ->  1,008x the measured drift

**The block COUNT settles it.** 73,443 blocks in 425 s is 5,787 µs per block,
which is the period. The instrument is keeping up. Drift accumulates at 0.27 µs
per block — 0.005 % — not 276 µs.

### So `B4dur` is the broken instrument, not the engine

Three independent quantities — block count, elapsed time, and the drift counter
— agree that blocks arrive at the period. Only `B4dur` disagrees, by ~3.5 %
consistently across all three of its classes. A mean that contradicts the count
and the clock it was derived from is a bug in the mean.

**O4's target is therefore NOT 306 µs/block, and not 287 cyc/sample.** Both
numbers are withdrawn. What remains real and unexplained:

* `ovr=39,301` of 73,443 blocks exceed the period — but if the mean interval IS
  the period, that is jitter crossing a threshold, not a deficit. Roughly half
  the blocks being over a mean-centred threshold is what jitter looks like.
* `gap=9,000-12,000 µs` worst block-to-block, tagged to `printf` in earlier
  work. Those are real stalls and they are the only large excursions here.
* `miss` totals 23/84/101 over the run — rare, and now unattributed again.

### What O4's first step must be

Not a cycle hunt, and not the master-chain split. **Fix or retire `B4dur`
first.** Every O4 lever would be chosen against a number that is 1,000x wrong.
The block count and the drift counter are cheap, already printed, and agree
with each other; `B4dur` must be reconciled against them or removed.

## 3. Why this got as far as it did

b12 quoted `B4dur` and it looked plausible. b14 "reconciled" it against the
drift counter and got agreement — but only by misreading µs as s. A check that
CONFIRMS a suspect number is exactly where a unit error does the most damage,
because it converts doubt into false confidence and closes the question.

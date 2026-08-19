# b15 — O3 on silicon; and two unit errors in a row, corrected

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

## 2. ⚠ THIS SECTION WAS WRONG, TWICE OVER — the corrected account

**What §2 originally said (2026-08-19, WITHDRAWN): that b14's O4 target was a
unit error, that `B4dur` was inflated by 3.5 %, and that the engine keeps up.
All three statements are false.** They are left named here rather than deleted,
because the sequence is the lesson.

### The field definitions, read from the source instead of assumed

    juno_s3_listen.c:4010   rpt_drift = (long)((real_us - audio_us) / 1000);
    juno_s3_listen.c:3997   sec       = chunks / (SR / CHUNK);

* `drift` is **MILLISECONDS**, not microseconds. `+150,106` in b12 is 150.1 s
  and `+20,114` here is 20.1 s.
* `t=` is **audio time produced**, derived from the BLOCK COUNT — not wall
  clock. So "73,443 blocks in 425 s" was circular: it assumed the very thing it
  was used to prove.

### What the board actually says

    blocks                 73,443
    audio produced          426.3 s   (this is the t= field)
    drift                   +20.1 s   (20,114 ms)
    REAL elapsed            446.4 s   (audio + drift)

    B4dur weighted mean     6,081 µs -> 446.6 s over 73,443 blocks
    agreement with REAL      100.03 %

**`B4dur` is correct to 0.03 %.** The engine produces 426 s of audio in 446 s
of real time. It is **4.8 % behind**, and the drift counter is the accumulated
proof: 20.1 s lost in one run.

### So O4's target STANDS, restated

    mean block          6,081 µs against a 5,805 µs period
    over per block        276 µs
    over per sample       259 cycles
    actual              ~5,701 cyc/sample against the 5,442 budget

b12 was right. b14's reconciliation was right. **Only this section was wrong.**

### The sequence, because it is worth more than the number

1. b12 measured a mean and it looked alarming.
2. b14 checked it against `drift` and reported agreement — reading ms as s by
   luck, and getting the right answer for the wrong reason.
3. b15 §2 "caught" b14's unit error, read ms as µs, and used a block-derived
   `t=` as if it were wall clock. Two errors, both in the direction of the
   conclusion being drawn, in the act of writing a playbook entry about unit
   errors.
4. The only thing that settled it was OPENING THE SOURCE and reading what the
   two fields are computed from.

**Neither an agreement nor a disagreement is evidence about a field whose
definition has not been read.** Both times the interpretation came from
context, and context supplied whichever answer was being looked for.
## 3. What O4's first step actually is

Not "fix B4dur" — it is correct. The engine is 259 cyc/sample over budget and
loses 20 s per 7 minutes. The b6 lever list applies: measure the prologue
(`S3L_TIME_PROLOGUE`, still 0), explain the delay arm, then choose between the
master-chain split across cores and an arm hunt.

One number from THIS run narrows it already: `FXP: fx=2,4xx-4,3xx v1=2,57x-2,65x
wait=5`. Core 1's FX pass swings by ~1,900 cyc/sample across patches while its
voice pass is flat, and `wait=5` says core 0 is not the constraint. That is the
same picture b6 recorded, on a build with three machines running.

# ★ THE PROLOGUE IS 117 CYCLES, NOT 1,414 (2026-08-11)

`juno_s3_PROBE_PROLOGUE.bin`, the user's board, stable on every line:

    PROLOGUE 0.49 us/sample (~117 cycles)

I had been using **1,414**, and that figure was a subtraction --
`core0 (6,138) - 2 voices (4,724)` -- not a measurement. It was wrong by 12x,
and it had been steering the whole search.

## What the other 1,297 cycles actually are

Core 0 runs with `S3L_SPLIT=7` and wake mask `0xe0`, so its range is voices
0..6: **two sounding (5 and 6) and FIVE AT REST (0..4)**. It also zeroes eight
`vout` slots per sample and advances at-rest state for all eight.

    1,297 / 5 at-rest voices = about 259 cycles each

for a zero-write, an at-rest test, two control-rate state writes, `continue`,
and a share of the block advance.

## Why this is not an optimisation problem

**On a two-chip build those voices do not exist.** Chip B owns three voices;
voices 0..4 belong to chip A. Iterating them is not work to be made faster --
**it is work the shipping design never does at all.** The firmware was
measuring a cost that the product does not have.

## What chip B costs once it owns only its own voices

    core 0 = prologue 117 + 2 voices = 4,841
    core 1 = 1 voice + FX            = 4,984
    loop   = max + output stage      = 5,075
    budget                           = 5,442
    -> UNDER BY 367

**That closes the 696.** It is arithmetic on measured constants, and the board
has not yet run it, so it is a prediction and nothing more -- the fifth
prediction in this project, and the previous four have a mixed record.

## The build

`S3L_VOICE_LO` is the lowest voice index a firmware owns; default 0 keeps
every previous build's behaviour exactly. It bounds the at-rest advance, the
`vout` zeroing and core 0's render range.

**SAFETY, stated rather than assumed:** `w_vbb` is static and therefore zero,
nothing writes the unowned slots, and the master sums all `EB_NUM_VOICES`
entries -- so the unowned slots contribute exactly 0.0 forever without being
re-zeroed. That is why the per-sample zeroing may be SKIPPED and not merely
hoisted.

`juno_s3_OWN3.bin` is `S3L_VOICE_LO=5`: this firmware owns voices 5, 6 and 7,
which is exactly the three the chord sounds.

## The lesson, and it is the same one twice tonight

**A subtraction is not a measurement.** 1,414 sent me looking for a way to
move or shrink a shared prologue that was never big enough to matter, and it
hid a 1,297-cycle cost that the product does not even incur. The FX price was
settled by measuring it three ways; the prologue should have been measured
once before anything was designed around it.

# ★★ OWN3 ON SILICON: 6,138 -> 5,446. THE 696 IS RECOVERED. (2026-08-11)

`juno_s3_OWN3.bin`, `S3L_VOICE_LO=5`, 136 s on the user's board.

    FXPIPE2 (owns all 8)   engine 6,138   whole loop 6,164
    OWN3    (owns 3)       engine 5,420   whole loop 5,446
    saved                          718                 718

**718 recovered against a 696 target.** Not owning the other chip's voices was
the whole gap.

    whole loop 5,446   vs budget 5,442   -> over by 4 cycles, 0.07 %

## It is ON the line, and the wall clock is slightly the harsher judge

The verdict FLICKERS between `realtime OK` and `BEHIND REAL TIME` second by
second, which is exactly what a loop sitting on its budget looks like. The
drift accumulates **+11.6 ms per second, about 1.16 % behind**, which is more
than the 0.07 % the loop metric implies.

That difference is real and it is not a contradiction: `busy_us` measures the
render, while the wall clock also carries the I2S write, the per-sample note
gate and the once-a-second printf. **The wall clock is the deciding test and
it says marginally behind.** So: NOT a pass. About 60 cycles of wall-clock
work sit outside the timed region and are now the whole remaining deficit.

## The prediction was optimistic AGAIN, by 371

I predicted 5,075 and the board returned 5,446 -- the fifth prediction in this
project and the fifth to flatter itself. The residual is the per-sample loop
and at-rest advance still running over voices 5..7 plus the three-slot zeroing,
none of which the estimate charged. **The direction of the error is now a
pattern rather than a coincidence, and future estimates should be quoted with
it stated.**

## Where the last ~60 cycles could come from, none measured

- `CHUNK` is 128. A larger chunk amortises the per-block I2S call and barrier
  over more samples. It also raises latency, which is a user-facing trade.
- The per-sample note gate runs a counter and a branch for every sample on
  core 0; it only needs to act at a gate change.
- The once-a-second printf is inside the timed wall clock.

None of these is engine arithmetic. **The DSP is no longer the problem** --
which is the first time that has been true in this project.

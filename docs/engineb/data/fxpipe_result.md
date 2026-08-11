# FXPIPE: the pipeline WORKS and the result is WORSE (2026-08-11)

`juno_s3_FXPIPE.bin`, the user's board, 330 s, rings in PSRAM,
`S3L_SPLIT=7` (core 0 = 2 sounding voices, core 1 = 1 voice + FX).

    SERIAL (FXRT)   engine 5,294   overhead 2,713   loop 8,014
    PIPELINED       engine 8,746   overhead    27   loop 8,773

## The pipeline itself did exactly what it was built to do

**The overhead collapsed 2,713 -> 27.** The FX is off the serial tail; that
part is not in question. The mechanism works.

## And the engine rose by 3,452, which is more than the FX ever cost

The barrier should have waited for the slower core:

    core 0 = 2 voices     = 4,724
    core 1 = 1 voice + FX = 2,362 + 2,622 = 4,984
    max                                    = 4,984
    MEASURED                                 8,746

Backing the voice out of core 1's share leaves **6,384 cycles for the FX
against 2,622 measured on core 0 alone -- 2.43x.**

## THE LEADING HYPOTHESIS, and it is not yet proven

**Memory contention.** Every previous FX measurement was taken with the FX
running ALONE on its core while the other core had already finished and was
spinning at the barrier. The FX is ring-heavy and those rings are in PSRAM at
80 MHz; the voice state is in PSRAM too. Concurrency puts both cores on that
one bus at the same time, and a bus does not double when the cores do.

This is a hypothesis from an arithmetic gap, not a measurement. It predicts
something specific and cheap to test, which is the only reason to believe it
at all.

## ⚠ AND IT CORRECTS SOMETHING I TOLD YOU NOT TO REOPEN

`fx_measured.md` closed ring placement NEGATIVE -- PSRAM measured 24 cycles
FASTER than internal -- and said "do not reopen this". **That measurement was
taken with the other core idle.** It is sound for the serial firmware and it
may be worthless for the concurrent one, because contention is precisely the
term that does not exist when only one core is running.

The instruction stands corrected: **ring placement is reopened for the
concurrent case, and only for the concurrent case.** A result measured under
one structure does not transfer to another structure that changes the thing
being measured. I generalised a measurement past its own conditions.

## The discriminator

`juno_s3_FXPIPE_SRAM.bin` is the identical build with the rings capped into
internal SRAM. If contention is the cause, the engine figure must fall
sharply. If it does not move, the hypothesis is dead and the cause is
something else -- and either answer is worth one flash.

# ⚠ THE DISCRIMINATOR DID NOT RUN: THE KNOB WAS NOT WIRED (2026-08-11)

`juno_s3_FXPIPE_SRAM.bin` returned engine 8,746 / whole loop 8,773 / drift
+636.8 ms at t=1s -- **identical to FXPIPE to the decimal.** It is NOT a
result. The build never carried the change.

**`S3_RING_SRAM` was not read by `main/CMakeLists.txt` at all.** It was passed
on the idf.py command line, CMake stored it as
`S3_RING_SRAM:UNINITIALIZED=32768`, and nothing ever consumed it. CMake does
not warn about a `-D` it never uses. The firmware compiled clean and was the
PSRAM build with a different version string.

Two tells, and both were in the log before I sent the binary:

1. **No `RINGS:` lines.** `rings_alloc`'s report is inside `#if
   S3L_RING_SRAM`. The earlier FX_SRAM build printed them; this one printed
   nothing, so that code was not compiled.
2. **Numbers identical to the decimal.** That is the same signature the
   watchdog fixed point left three hours earlier. An identical number across
   two binaries means the thing you changed is not in the path.

Proved mechanically rather than argued -- the ring report string is absent
from the old image and present in the new one:

    strings juno_s3_FXPIPE_SRAM.bin  | grep -c "PLACEMENT IS"   -> 0
    strings juno_s3_FXPIPE_SRAM2.bin | grep -c "PLACEMENT IS"   -> 1

## The rule this earns

**A knob is not a knob until something reads it, and the check is the
firmware's own printed banner, not the command line you typed.** The
CMakeLists now defines `S3L_RING_SRAM` from `S3_RING_SRAM` and carries this
history in a comment so the next person does not spend a flash on it.

The contention hypothesis is still OPEN. It has not been tested.
`juno_s3_FXPIPE_SRAM2.bin` is the build that actually tests it.

# CONTENTION IS DEAD, AND THE REAL CAUSE IS AN ORDERING DEFECT (2026-08-11)

`juno_s3_FXPIPE_SRAM2.bin`, with the knob actually wired -- the banner now
reads `RINGS: cap 32768 samples. 4 of 9 INTERNAL, 5 in PSRAM -- PLACEMENT IS
MIXED`, which is the check working:

    PSRAM rings   engine 8,746
    MIXED rings   engine 8,840      -> +94 cycles WORSE

**Moving four of nine rings into internal SRAM made it slightly worse.** The
memory-contention hypothesis is not supported and is closed. (The earlier
serial finding stands: PSRAM is the better placement. It was reopened
correctly and it has now closed the same way.)

## The real cause, from the code rather than a guess

Core 1's VOICE pass cannot run faster than core 0 publishes prologues.
`w_ready` advances once per sample from core 0, which in this split also
carries TWO voices per sample. Core 1's single voice therefore waits at the
top of every iteration and **its pass ends when core 0's pass ends.** Only
then did the FX start -- with core 0 already spinning at the barrier.

**So the FX overlapped nothing.** The loop was `core0_pass + FX`, which is a
sum again, in a build written to stop summing. The pipeline moved the FX off
the SERIAL TAIL and onto a core that was itself serialised behind core 0.

## The fix, and why it is the right shape

The FX depends only on the PREVIOUS chunk, which is complete before this one
starts. It is the one piece of work on core 1 that is never blocked. Running
it FIRST fills exactly the window in which core 0 is busy and core 1 would
otherwise be waiting on `w_ready`. The voices then follow, still throttled by
core 0, but throttled during time that was already going to be spent.

`juno_s3_FXPIPE2.bin` carries the reorder. It is a MOVE of one loop above
another; no arithmetic changed.

## THE BOUND THAT MATTERS MORE THAN EITHER

From measured parts, per sample: 3 voices = 7,086, FX = 2,622, total 9,708.
Spread over two cores PERFECTLY, that is **4,854 against a 5,442 budget**.

So 3 voices + FX on ONE chip is not impossible -- but it needs a near-perfect
split, and the prologue is on core 0 and is not divisible. The measured 8,746
is 1.8x the ideal, so the arrangement, not the arithmetic, is what is being
paid for. That is the thing to keep working on, and it is also why the
two-chip plan was never contingent on this build fitting.

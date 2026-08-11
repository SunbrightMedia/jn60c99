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

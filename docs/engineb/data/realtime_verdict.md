# The real-time verdict line was broken (2026-08-11)

`juno_s3_REALTIME3.bin` ran 121 seconds on the user's board and printed
`BEHIND REAL TIME` on every line, with `underruns=0` on every line. Those two
statements cannot both be interesting, and the fault is in the verdict.

## What the line actually tested

    if (real_us > audio_us * 1.02) behind = 1;

Two defects, and each alone is enough to void the verdict.

**It was a LATCH.** `behind` is set and never cleared. One slow second at any
point condemns every line after it. The first accounting period contains the
first DMA fill and the opening printf, so it is the most likely second in the
whole run to exceed the threshold -- and once it does, the run can hold real
time perfectly for two minutes and still print BEHIND on all of them. That is
what happened.

**It compared TOTALS, so it could not show a rate.** A run 3 ms behind and
holding steady reads identically to a run losing 3 ms every second. Only the
second is a failure. A test that cannot tell a fixed offset from a leak is
not a real-time test.

## The fix

The comparison is now made over the LAST SECOND only, so the verdict tracks
the engine instead of remembering the start-up, and it can recover. And the
line prints the SIGNED CUMULATIVE DRIFT in ms, so the direction and the rate
are both visible rather than inferred: a healthy run holds the drift flat, a
failing one climbs without limit.

`juno_s3_REALTIME4.bin` carries the fix. Same engine, same flags, same 3
voices, `S3L_SPLIT=6`.

## ⚠ AND THE BINARY IS NOT WHAT I CALLED IT

I described REALTIME3 as the "end-to-end real-time test". Its own banner
says otherwise:

    BUILD: VOICES ONLY -- master/FX chain not called, no rings.

It is built `S3_NOFX=1`. It plays three voices out of I2S with NO master and
NO FX. So it is a real-time test of the VOICE CHAIN, which is worth having,
but it is not the whole instrument and I should not have said it was.

## What the run does establish, taking only the cycle counters

`S3L_SPLIT=6` with wake mask `0xe0` puts voice 5 on core 0 and voices 6 and 7
on core 1 -- a 1/2 split, the same shape as `0xd0`.

    engine       5,274 cycles      (0xd0 on FAST3_CR: 5,395)
    whole loop   5,367 cycles      (0xd0 on FAST3_CR: 5,486)
    budget       5,442
    underruns    0 over 121 s

**The whole loop is under budget by 75 cycles, and it held for two minutes
with the I2S clock running.** That is the strongest voice-chain evidence in
the project so far, and it is stronger than the offline sweep because a real
clock was present. It is still NOT a system result: no master, no FX, no
second chip.

# THE WATCHDOG FEED WAS THE DEFICIT (2026-08-11, REALTIME4)

REALTIME4's per-second verdict works, and it immediately found something the
latched version had hidden: the drift climbs **+2,451 ms every second**, on a
run whose own render counter reads 22.40 us against a 22.68 us budget.

Both cannot be true of the engine. They are not. The deficit is the harness.

## The line

    vTaskDelay(1);   /* feed the watchdog; the loop had starved IDLE0 */

once per CHUNK. `CHUNK` is 128 frames. At 44,100 Hz that is **2.902 ms of
audio**. One FreeRTOS tick at the default 100 Hz is **10 ms**. The chunk's own
render is 2.87 ms, which fits inside a single tick, so `vTaskDelay(1)` aligns
the loop to the next tick boundary and the loop advances **exactly one tick
per chunk**:

    wall per chunk  = 10.000 ms   (tick-aligned)
    audio per chunk =  2.902 ms
    ratio           =  3.445x
    predicted drift = +2,445 ms per second
    MEASURED drift  = +2,451 ms per second

**The model and the board agree to 0.2 %.** The whole deficit is the sleep.
The harness spent 10 ms of wall clock producing 2.9 ms of audio, and the
wall-clock verdict measured that.

## Why the line existed, and why it was self-defeating

When the engine runs BEHIND, `i2s_channel_write` never blocks -- there is
always free DMA space -- so the loop spins and starves IDLE0. That is real,
and it is why the delay was added.

But when the engine runs AHEAD, which is the case the test exists to prove,
that write DOES block, and a blocking queue wait yields to IDLE by itself. So
the delay is only needed in the FAILING case, and the failing case is the only
one it was not corrupting. It made every passing run look like a failure.

## The fix

Feed the watchdog only when the write did NOT block:

    if (wrote_blocked_us < 1000) vTaskDelay(1);

In a passing run this never fires, and the wall clock is the engine's alone.
In a failing run it fires every chunk, exactly as before, and IDLE0 still
lives.

`juno_s3_REALTIME5.bin` carries it.

## What this does NOT change

Nothing in the cycle columns. `busy_us` was always measured around the render
only, so every engine and whole-loop figure in every log stands unaltered. The
sleep was outside the timed region -- which is precisely why the two halves of
the log disagreed, and why the disagreement was the clue.

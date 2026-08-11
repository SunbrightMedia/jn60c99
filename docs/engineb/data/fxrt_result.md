# FXRT: the FX and the voices in one build — FAILS, and the cause is STRUCTURAL
(2026-08-11)

`juno_s3_FXRT.bin`, the user's board, 136 s.

    engine (voice phase, both cores)   5,294
    overhead                           2,713
    whole loop                         8,014
    budget                             5,442      -> 1.47x OVER
    drift                             +483 ms/s   -> 1.48x, agrees
    underruns                          0

## The parts add EXACTLY, and that is the whole finding

    5,294 + 2,713 = 8,007, against a measured loop of 8,014.

Nothing is anomalous. The voice phase costs what REALTIME6 measured (5,285),
and the FX costs what the FX builds measured:

    FX proper = 2,713 - 91 = 2,622   vs 2,593 and 2,616 previously

**Three independent measurements of the FX chain now agree within 1 %.** The
price of the FX is settled. What is wrong is not the price.

## ⚠ THE FX IS NOT PARALLEL. I PREDICTED WITHOUT READING THE LOOP.

I predicted 5,046 cycles from `max(1 voice + FX, 2 voices)`, on the assumption
that the FX would run on core 0 CONCURRENTLY with core 1's voices. The
firmware does not do that, and its own comment says so:

    1. core 0 runs the prologue for all CHUNK samples
    2. core 1 renders its voice range
    3. core 0 renders its range, concurrently
    4. one barrier
    * The per-sample loop afterwards only reads finished voice buffers.

`eb_master_render` is called in that per-sample loop -- **after the barrier,
on core 0, alone**. So the FX is serial with the entire voice phase, and the
costs add instead of overlapping. The board's exact additivity is the proof.

This is my error, and it is the same class as two earlier ones tonight: I
described the timed region without reading it, and I predicted a structure
instead of checking it. The rule earned twice already applies again -- READ
THE LOOP BEFORE PRICING THE LOOP.

## What this does and does not change

**Does NOT change:** the FX price (2,622, now triple-measured), the voice
slope (2,362), the output stage (91), or REALTIME6's voice-chain pass. Every
measured constant stands.

**Does change:** the two-chip layout arithmetic in `chip_layout.md` and
`fx_measured.md` is not a projection of THIS firmware. Both layouts assume the
FX runs on a core of its own, concurrently. **That firmware does not exist
yet.** The arithmetic remains valid as a target; it is not a description.

## The head pointer, and it is now engineering rather than measurement

Move `eb_master_render` off the serial tail and onto the second core, so it
overlaps the voice phase instead of following it. Then:

    Layout B, chip B: core 0 = 2 voices = 4,724 ; core 1 = FX = 2,622
                      loop = 4,724 + 91 = 4,815 against 5,442

The obstacle is real and must be named before anyone tries: the FX consumes
the summed voice output, so it cannot run concurrently with the SAME sample's
voices. It must run one sample (or one chunk) BEHIND them -- a pipeline stage,
which costs one chunk of latency (2.9 ms at CHUNK=128) and needs a second
buffer. That is the design question, and it has not been answered.

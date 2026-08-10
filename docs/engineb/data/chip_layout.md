# The voice-to-CHIP map is a free lever (2026-08-10)

All numbers below are MEASURED on the user's board, except the FX row, which
is stale and says so.

## The measured inputs

| Quantity | Value | Source |
|---|---|---|
| Budget, 240 MHz / 44,100 Hz | 5,442 cycles/sample | arithmetic |
| Voice slope, FAST3_CR | 2,362 cycles | board, wake sweep |
| Output stage (sum, clamp, int16) | 91 cycles | board, 0xd0 loop minus engine |
| FX chain | 7,745 cycles | STALE — see below |

The FX figure is stale in TWO ways. It was measured before the 72 libm calls
came off the master path, and it was measured with the delay rings in PSRAM.
Do not quote it as a result. It is used here only to show WHICH layout the
FX must fit into.

## The two layouts

A chip has two cores. The sample period is the MAX of the two cores, not the
sum. So the question is only: what does the second core of the FX chip carry?

**LAYOUT A — 3 voices per chip** (this is what wake mask `0xd0` tested):

    chip A: core 0 = 2 voices = 4,724 ; core 1 = 1 voice = 2,362
    chip B: core 0 = 2 voices = 4,724 ; core 1 = 1 voice + FX

Chip B is free only while `2,362 + FX <= 4,724`, that is **FX <= 2,362**.

**LAYOUT B — 4 voices on chip A, 2 voices + FX on chip B:**

    chip A: core 0 = 2 voices ; core 1 = 2 voices  -> 4,724 + 91 = 4,815
    chip B: core 0 = 2 voices = 4,724 ; core 1 = FX ALONE

Chip B is free while **FX <= 4,724**.

## What that changes

Layout B DOUBLES the FX budget, from 2,362 to 4,724, and costs nothing. It is
a change to the voice-to-chip map only. No DSP moves.

Against the stale FX figure, corrected to the voice chain's own c/i (2.36 ->
1.56, giving 5,120):

| Layout | FX threshold | Over by |
|---|---|---|
| A | 2,362 | 2.2x |
| B | 4,724 | **1.08x** |

Layout B puts the FX chain within about 8 % of fitting, on a figure that has
two known-pessimistic terms still in it. Layout A does not come close.

## The rule this gives the split constant

`S3L_SPLIT=5` is still forbidden — it puts a three-note chord entirely on one
core (measured 9,204 cycles, 70 % over). The map must force the 2/2 split on
chip A and the 2/0 split on chip B. Neither chip may put three voices on one
core.

## What is NOT proven here

The two-chip link does not exist. No FX figure exists for the current tree.
This document proves only that the LAYOUT choice is worth about 2x on the FX
budget, and that the choice is free.

# The FX chain, MEASURED on silicon (2026-08-10)

`juno_s3_FX_SRAM.bin`, the user's board, full 60 s sweep.

## The number

The FX overhead is **~2,707 cycles/sample**, and it is CONSTANT across every
wake mask:

| wake | engine | whole loop | overhead |
|---|---|---|---|
| 0x00 | 1,059 | 3,763 | 2,704 |
| 0x80 | 3,440 | 6,145 | 2,705 |
| 0xc0 | 6,185 | 8,874 | 2,689 |
| 0xe0 | 8,939 | 11,635 | 2,696 |
| 0xf0 | 8,876 | 11,578 | 2,702 |
| 0xfc | 9,215 | 11,919 | 2,705 |
| 0xd0 | 6,113 | 8,820 | 2,707 |

The overhead does not move with the voice count, which is the correct shape
for a master chain that runs once per sample whatever the voices do. That
flatness is what makes the number believable.

The overhead includes the output stage, measured at 91 cycles in the NOFX
builds. So the **FX chain proper is about 2,616 cycles/sample**.

## Against the stale estimate

The last figure was **7,745**. The measured figure is **2,616**. The estimate
was **3.0x HIGH**. It was stale in the two ways already recorded — it predated
the 72 libm calls coming off the master path, and it predated the ring work.
This is the sixth pricing estimate in this project to be wrong, and the fifth
to be wrong in the flattering direction for the pessimist rather than the
optimist. **Do not price this chain again. Measure it.**

## ⚠ THE FIRMWARE LIED IN ITS OWN RING REPORT

The log reads:

    RINGS: internal alloc failed at 0 (32768 samples) -- falling back to PSRAM
    RINGS: internal alloc failed at 2 ...
    RINGS: internal alloc failed at 3 ...
    RINGS: internal alloc failed at 7 (8192 samples) ...
    RINGS: internal alloc failed at 8 (8192 samples) ...
    RINGS: capped at 32768 samples, INTERNAL SRAM. free internal now 64515

The last line says INTERNAL SRAM. **Five of the rings are in PSRAM.** The
summary line prints the REQUEST, not the outcome, and the five failures above
it are the outcome. Free internal fell 166,931 -> 64,515, so about 102 KB did
land internal; the rest did not.

So `juno_s3_FX_SRAM.bin` is NOT an all-internal build. It is a MIXED build.
The 2,616 figure is therefore a mixed-placement figure, and the all-internal
number is still unknown and could only be better.

The summary line is fixed: it now names the placement ALL-INTERNAL / MIXED /
ALL-PSRAM and counts both sides.

## ★ RING PLACEMENT IS NOT A LEVER — CLOSED BY MEASUREMENT

`juno_s3_FX_PSRAM.bin`, all nine rings in PSRAM, ran next:

| wake | mixed-SRAM | all-PSRAM | delta |
|---|---|---|---|
| 0x00 | 2,704 | 2,680 | **-24** |
| 0xfc | 2,705 | 2,679 | **-26** |
| 0xd0 | 2,707 | 2,684 | **-23** |

**PSRAM is FASTER, by about 24 cycles, on every mask.** Not slower. The whole
`S3L_RING_SRAM` idea was built on the belief that PSRAM ring access would cost
the FX chain real time. It costs nothing measurable, and putting the rings
internal costs a little -- most likely because the 102 KB it takes out of
internal RAM displaces something the voice chain wanted (the engine column
also moves, 6,082 -> 6,113).

So the delay rings STAY IN PSRAM. That releases about 102 KB of internal SRAM
for whatever the two-chip link turns out to need, and it removes the standing
precondition that the earlier build had to print -- the cap was only valid
while every read lag stayed below it, so a longer DELAY TIME than this bank
uses would have folded. **That risk is now gone, and it was bought for -24
cycles.** Do not reopen this.

The FX figure to quote is therefore the all-PSRAM one: overhead 2,684, and
**FX proper 2,593 cycles/sample**.

## A benign artefact worth naming

The all-PSRAM run prints `underruns=1` from t=1s and it never grows. It is a
single start-up event, not a running deficit. A real overrun would climb.

## The voice numbers in this build are OLD

This build is `dd7b329-dirty`, compiled 07:48. `FAST3_CR` was compiled at
17:06. So the voice chain here is the FAST3-era one -- 0xd0 engine 6,113,
against FAST3's 6,062 and FAST3_CR's 5,395. **Do not read a voice slope out of
this log.** Only the overhead column is new information.

## What it does to the two-chip fit

Using the FAST3_CR voice slope of 2,362, the output stage of 91, the measured
FX proper of 2,616, and the 5,442-cycle budget:

**LAYOUT A — 3 voices per chip**

    chip A: core0 2v = 4,724 ; core1 1v = 2,362   -> 4,815   margin 627
    chip B: core0 2v = 4,724 ; core1 1v+FX = 4,955 -> 5,046  margin 396

**LAYOUT B — 4 voices on chip A; 2 voices + FX ALONE on chip B**

    chip A: core0 2v ; core1 2v                    -> 4,815  margin 627
    chip B: core0 2v = 4,724 ; core1 FX = 2,593    -> 4,815  margin 627

**BOTH LAYOUTS FIT ON PAPER.** Layout B is the better one — it balances at
4,815 on both chips and holds 627 cycles of margin on each, against layout A's
worst core at 5,046 and 396. Layout B is also the safer one, because the FX
core has no voice on it at all, so a voice-count change cannot push it over.

**ONE CHIP STILL CANNOT DO IT:** 3 voices plus the FX on one core is 9,793
against 5,442. The two-chip decision stands.

## What is still NOT proven

The two-chip link does not exist — no code, no measurement, no cost for the
inter-chip audio transport, and that transport lands on one of these cores.
The 627-cycle margin is where it has to fit. Nothing above is an end-to-end
real-time result; it is an arithmetic on four measured constants.

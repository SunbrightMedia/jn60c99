# THE FX COST DEPENDS ON THE PATCH, AND 18 OF 64 PATCHES COST DOUBLE
(2026-08-12, `juno_s3_QUIET.bin`, the user's board -- the first run with the
console off the audio loop)

## What the board did

With `printf` gone from the audio loop the loop settles at **5,129-5,392
against a 5,442 budget** and the drift goes NEGATIVE. Then, every twenty
seconds or so, it spends exactly FOUR SECONDS at **9,000-10,774** and the drift
climbs by about one second.

Four seconds is exactly `S3L_PATCH_SECS`. So it is not a stall, a burst or a
scheduler artefact: **certain PATCHES cost twice as much to render.**

## Which ones, and it is not a coincidence

The excursions land at t=21-24, 45-48, 65-68, 77-80, 85-88, i.e. patches
5, 11, 16, 19 and 21. Their DELAY TYPE, read from the bank at record byte 650:

    patch    5   11   16   19   21
    DELAY    5    2    5    3    5

**Every expensive patch is DELAY TYPE 2, 3 or 5. Every cheap one is 0 or 1.**
No exception in the 24 patches the run covered.

    DELAY TYPE   patches   cost
       0            29     cheap   (~5,200)
       1            17     cheap
       2            10     EXPENSIVE (~10,000)
       3             4     EXPENSIVE
       5             4     EXPENSIVE
                   ----
       2/3/5        18 of 64 = 28 %

The mechanism is in the code and is not surprising once seen: TYPE 2/3 run
`eb_delay_t23`, which calls `juno_pitch_poly` and `juno_triangle` -- a
PITCH-SHIFTING delay -- and TYPE 5 runs `eb_delay_t5`, the largest FX module in
the engine at 20,949 bytes of Xtensa. TYPE 0/1 are plain delays.

The FX chain was MEASURED at 2,622 cycles. That figure is DELAY TYPE 0. On
types 2/3/5 the same chain costs roughly **8,100**.

## ⚠ WHAT THIS DOES TO EVERY NUMBER IN TRACK B

**The listen firmware's blob was built from patch 0, and patch 0 is DELAY
TYPE 0.** So the layout sweep, the M1 result, the 691-cycle gap, the 425-cycle
gap -- every cycle figure this project has ever taken -- is the CHEAPEST of
three FX classes.

    what was measured        2 voices + FX, DELAY TYPE 0    5,159   FITS
    what 28 % of the bank    2 voices + FX, DELAY TYPE 5   ~10,700  2x OVER

**A real-time budget must be met by the WORST patch, not by patch 0.** END_GOAL
item 4 says "no stuttering whatsoever"; a synth that stutters on 18 of its 64
factory sounds does not meet it, and every previous measurement was blind to
that by construction.

## What this does NOT change

The steady-state engine is fine and the console fix was real: at DELAY TYPE
0/1 the loop is inside budget with the drift negative, and the underruns that
remain do not climb during the expensive phases (when the engine is behind the
DMA never fills, so the write never blocks -- the counter's own known blind
spot).

## The next measurement, and it is a sweep rather than a guess

Price the delay arms SEPARATELY on the board: hold one patch of each DELAY TYPE
for a fixed window and report the loop for each. Five rows, one flash, and it
replaces "the FX costs 2,622" with a per-arm table. Until that exists, quote
2,622 as **DELAY TYPE 0 only**.

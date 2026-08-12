# ★★★ THE CHIP-LAYOUT SWEEP: ten layouts, ONE flash, on the user's board
(2026-08-12)

`juno_s3_LAYOUT.bin`. Voice range, core split, FX stage and voice-state
placement are RUNTIME row fields, so every candidate two-chip layout is
measured in one flash instead of six. Three complete passes, repeatable to
within 1 cycle on every row.

Blob = patch 50, so **the LFO is live in every row**. Budget 5,442.

## The table

| row | config | split | FX | state | WHOLE LOOP | vs budget | predicted | err |
|---|---|---|---|---|---|---|---|---|
| 1 | 3 voices | 2/1 | on | PSRAM | **6,133** | +691 | 5,532 | +601 |
| 2 | 3 voices | 2/1 | on | INT | 6,096 | +654 | 5,532 | +564 |
| 3 | **2 voices** | **1/1** | **on** | **INT** | **5,472** | **+30** | 5,075 | +397 |
| 4 | 2 voices | 1/1 | on | PSRAM | 5,489 | +47 | 5,075 | +414 |
| 5 | **3 voices** | **1/2** | **off** | **INT** | **5,388** | **FITS −54** | 4,815 | +573 |
| 6 | 4 voices | 2/2 | off | INT | 6,262 | +820 | 5,532* | +730 |
| 7 | 4 voices | 1/3 | off | INT | 7,906 | +2,464 | 7,894 | +12 |
| 8 | 3 voices | 1/2 | on | INT | 7,996 | +2,554 | 7,437 | +559 |
| 9 | 6 voices | 3/3 | off | INT | 8,827 | +3,385 | 7,894* | +933 |
| 10 | 6 voices | 3/3 | on | INT | 10,479 | +5,037 | 9,799 | +680 |

\* rows 6 and 9 carry a prediction ERROR OF MINE, not of the model: row 6's
printed prediction used the superseded 1,236 prologue and row 9's was copied
from row 7 without being recomputed. The `predicted` column above is corrected;
the firmware printed 6,051 and 7,177 for those two. Recording it because a
prediction that is quietly repaired after the fact is worthless.

## ⚠ THE HARNESS IS ~150 CYCLES HEAVY, AND ROW 1 SAYS SO

Row 1 reproduces the shipping configuration exactly. The shipping build
(`juno_s3_LFO_P50.bin`) measured **5,981**; row 1 reads **6,133**.

    +152 cycles, 2.5 %

That is the price of making `S3L_VOICE_LO`, `S3L_SPLIT` and the FX stage
RUNTIME values: the render range is no longer a compile-time constant, so the
inner loops lose some folding, and the worker gains a branch.

**So every row is about 150 cycles PESSIMISTIC against a dedicated build**, and
the control is what makes that quantity known rather than assumed. A sweep
harness that could not reproduce a known point would have been unusable.

## WHAT IT SETTLES

### 1. Two voices with FX is ON THE LINE, and probably under

Row 3 is 30 cycles over in a harness that is 150 heavy. A dedicated build is
expected near 5,320. **That is an INFERENCE from the row-1 offset and it must
be measured, not quoted** -- this project's inferences have a bad record.

### 2. THE FX COSTS 2,608, confirmed a second way

Row 8 minus row 5: identical voices, identical split, FX the only difference.

    7,996 - 5,388 = 2,608

The independent figure from `fxpipe2_result.md` is 2,622. **Two methods, 14
cycles apart.**

### 3. A VOICE COSTS 2,518, NOT 2,362

Row 7 minus row 5: one voice added to core 1, nothing else changed.

    7,906 - 5,388 = 2,518

The 2,362 in every earlier document predates the LFO. **Every voice-count
arithmetic in this repo is about 7 % light.** Use 2,518.

### 4. VOICE-STATE PLACEMENT IS CLOSED NEGATIVE

    2 voices   PSRAM 5,489   INTERNAL 5,472   -> 17 cycles
    3 voices   PSRAM 6,133   INTERNAL 6,096   -> 37 cycles

It was a live hypothesis for the ~370 cycles the additive model was missing. It
is not that. It is 0.3 %. Do not spend a flash on it again.

### 5. THE SPLIT IS WORTH MORE THAN ANY OPTIMISATION ON THE TABLE

Same three voices, same FX, same everything but which core holds what:

    2/1 split   6,133
    1/2 split   7,996      -> 1,863 cycles

The core carrying the prologue must carry FEWER voices. A layout mistake costs
more than every closed lever in this project put together.

### 6. ONE BOARD CANNOT DO IT

    6 voices + FX, one chip, best split   10,479   = 1.93x over

**Two boards is a measured necessity, not a preference.** END_GOAL item 2 is
confirmed by the numbers rather than assumed by them.

### 7. THE TWO-BOARD GAP IS 691 CYCLES, ON ONE CHIP

    chip A   3 voices, no FX, 1/2 split   5,388   FITS by 54
    chip B   3 voices + FX,   2/1 split   6,133   OVER by 691

Six voices with full FX on two boards is short by **691 cycles on chip B and
nothing else.** That is 27 % of one voice, or 26 % of the FX chain.

## THE MODEL, CORRECTED

The additive model under-read every row by 400-600 cycles. The missing term is
the per-sample loop overhead that no model contained: the barrier, the
`w_ready` spin, the PCM conversion and the note-gate tail. Fitted on rows 5 and
7, which differ by exactly one voice on the same core:

    voice        2,518   (measured, rows 7-5)
    FX           2,608   (measured, rows 8-5)
    overhead       352   (measured, row 5 minus 2 voices)
    prologue+LFO  ~921   (from row 9; less certain, core0 is the max there)

Use `loop = max(prologue + n0*voice, n1*voice + fx) + 352`.

## THE ESTIMATE RECORD, UPDATED

Nine estimates, eight wrong, **seven of them flattering**. The two causes here
were both mine and both avoidable: an overhead term that was never in the model
because nobody had measured the loop's own cost, and one row's prediction
copied from another without being recomputed.

**The rule this earns: a prediction column must be generated by the same code
that generates the rows, not typed beside them.**

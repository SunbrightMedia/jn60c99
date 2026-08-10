# TRIM closed NEGATIVE on silicon (2026-08-10)

`juno_s3_TRIM.bin` removed two things from the firmware that looked like pure
waste:

1. `render_block`'s pre-zero loop, which zeroed all eight `w_vbb[i]` slots on
   core 0 before publishing `w_ready`. `eb_engine_render_range` already writes
   `vout[v] = 0.0f` as the first statement of its own voice loop.
2. Under `S3L_NOFX`, the second clamp / multiply / float-to-int for the R
   channel, when R had just been assigned from L.

Neither touches engine arithmetic. Both looked free. **The board says they are
not.**

## Measured, wake sweep, engine cycles

| wake | voices | FAST3_CR | TRIM | delta |
|---|---|---|---|---|
| 0x00 | 0 | 1,132 | 1,099 | **-33** |
| 0x80 | 1 | 3,056 | 3,093 | +37 |
| 0xc0 | 2 | 5,415 | 5,488 | +73 |
| 0xe0 | 3 | 7,780 | 7,886 | +106 |
| 0xfc | 6 | 8,145 | 8,110 | -35 |
| **0xd0** | **3, split 2/1** | **5,395** | **5,430** | **+35** |

Whole loop on 0xd0: 5,486 -> 5,526, **+40**. Output-stage overhead: 91 -> 95,
**+4** -- the R-channel removal made the output stage SLOWER, not faster.

## The slope

Per-voice slope, from the 1 -> 2 -> 3 voice steps:

    FAST3_CR: 2,359 and 2,365   -> 2,362
    TRIM:     2,395 and 2,398   -> 2,396

**+34 cycles per voice.**

## The reading

The floor gain is REAL and is exactly what the pre-zero removal was supposed to
buy: -33 cycles at 0 voices. But the same edit costs +34 cycles per voice, and
the binding case carries three voices. The gain is paid back once and the cost
is paid three times, so 0xd0 goes backwards.

The cause is not the deleted work. It is the codegen around it. Removing the
loop changed how the compiler arranges the voice loop's entry, and the voice
loop is where the register pressure already lives. This is the SAME wall that
killed voice interleave twice, the pitch hoist's inlining, `EB_FUSE_VCA` (+168)
and `EB_VCF_ILV` (+131). It is now five times.

`0xfc` improved by 35, and that is real, but `0xfc` is not the binding case --
it saturates on the 4-voice core.

## Disposition

**Reverted.** `esp32s3/main/juno_s3_listen.c` is back to the FAST3_CR form.
`juno_s3_REALTIME3.bin` is restored to its pre-TRIM build for the same reason.
`juno_s3_TRIM.bin` is kept so the measurement can be repeated.

**The standing 0xd0 numbers are unchanged: engine 5,395 against a 5,442 budget;
whole loop 5,486.**

## The rule this earns

A firmware edit that deletes work near the voice loop must be MEASURED on the
board before it is believed, even when the deleted work is provably redundant.
Redundant work and free work are not the same thing.

# ★★★ M1 ON SILICON: 2 VOICES + FX FITS, AND IT STILL CLICKS
(2026-08-12)

`juno_s3_M1.bin` — the dedicated build of layout row 3. `S3_VOICES=2`,
`S3L_VOICE_LO=6`, `S3L_SPLIT=7`, `S3L_FX_PIPE=1`, compile-time constants, no
sweep. 315 seconds on the user's board, 63 reports.

    whole loop   5,410 average   (5,385 - 5,435)
    engine       5,388 average
    overhead        25
    budget       5,442
    MARGIN          32 cycles = 0.6 %
    verdict      "realtime OK" on 63 of 63 lines
    drift        -1.94 ms/s, NEGATIVE throughout
    underruns    105

**This is the first configuration in this project that holds real time on
silicon with the LFO running and the full FX chain — chorus, delay, reverb —
in the loop.**

## The drift is negative, and that is the good direction

`drift_ms = real_us - audio_us`, so negative means the engine produced more
audio than wall-clock time elapsed: it runs AHEAD of the codec. It never turns
positive in 315 seconds.

The rate, -1.94 ms/s, is 0.19 %. That is the I2S clock divider landing near
44,186 Hz rather than exactly 44,100, which is a property of the chip's
fractional divider and not of the engine. It is recorded so nobody later reads
it as an engine result.

## ⚠ 105 UNDERRUNS, AND THEY ARE THE POINT OF THIS PAGE

One incomplete `i2s_channel_write` every three seconds, steady, from the first
report to the last. 0.19 % of writes.

**LEADING HYPOTHESIS, not yet proven: the note gate's coefficient reload.**
Every 2.2 seconds (`S3L_HOLD_FRAMES` + `S3L_REL_FRAMES` = 97,022 frames) the
per-sample tail calls `load_coefs()`, which memcpy's

    18,788 (coefs) + 1,704 (master) + 8,488 (voice state) = 28,980 bytes

out of memory-mapped flash, INSIDE the audio loop. Gate changes happen 0.909
times a second; underruns arrive 0.336 times a second, which is one per three
gate changes. With 32 cycles of margin, whether a burst lands inside its
block's deadline is close to a coin flip, so a fractional ratio is what the
hypothesis predicts.

**It is a hypothesis.** Falsify it by changing `S3L_HOLD_FRAMES` and watching
whether the underrun rate tracks the gate rate. That has not been done.

## WHAT THIS SETTLES ABOUT THE GOAL

| question | answer |
|---|---|
| does 2 voices + FX fit the cycle budget? | **YES, measured, 32 cycles spare** |
| does it meet END_GOAL item 4, "no stuttering whatsoever"? | **NO** |

END_GOAL.md said this would happen, in these words:

> "No stuttering whatsoever" means headroom, not parity. A build that meets the
> budget exactly drops audio the first time a patch changes, because recall is
> a burst. Parity is not the finish line; margin is.

A 29 KB memcpy already breaks it. **Device recall is a larger burst than that**,
and MIDI, the allocator and the note path all land on the same core.

## THE FIX IS SCHEDULING, NOT ARITHMETIC

The burst does not have to be in the audio loop. The publish contract being
written for device recall is exactly the mechanism: build into an inactive
buffer across blocks, swap a pointer at a block boundary. `load_coefs()` should
be the first user of it.

**So the next move for the underruns is NOT a cycle hunt.** It is to take the
burst off the per-sample path. That is worth doing before any arithmetic is
touched, because a cycle hunt cannot fix a burst — it can only make the coin
flip land favourably more often.

## THE ESTIMATE RECORD

Ten estimates, eight wrong, seven flattering.

    sweep row 3 (runtime split)   5,472
    M1 (compile-time split)       5,410
    the harness cost                 62

I had claimed the sweep harness cost ~150 cycles, from the row-1 control
against the shipping build (6,133 vs 5,981 = 152), and inferred M1 would land
near **5,320**. It landed at **5,410** — optimistic by 90, and the harness cost
is 62 in this configuration rather than 152.

The lesson is narrow and worth keeping: **a harness overhead measured at one
workload does not transfer to another.** Row 1 carries three voices and the FX;
M1 carries two voices and the FX. The runtime-constant penalty scales with the
work inside the loop it de-optimises, so quoting one figure for both was the
same class of error as quoting a c/i measured on different code.

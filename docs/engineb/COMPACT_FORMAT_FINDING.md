# THE 118-BYTE COMPACT PRESET FORMAT IS INSUFFICIENT — MEASURED 2026-08-02

`docs/preset/COMPACT_FORMAT.md` states that a JUNO-60 patch is **118 bytes**, and
that reconstructing each patch from those bytes reproduces the engine state
**exactly for 64/64** factory patches.

Engine B's parameter path was wired to that format, and the format was then gated
at the **output** instead of at a state hash. It fails.

## The measurement

Method (`tools/engineb/patch_roundtrip.py`): take patch 0's whole 20,223-byte
record as the template — the same template firmware would bake in — copy in only
the compact bytes of patch *p*, and RENDER both banks through the oracle
(`libjuno.so`, 48 kHz, note 60 velocity 100, 8,000 frames, one note-on). Require
the samples to be identical.

| byte set | patches BIT-EXACT |
|---|---|
| documented, 118 bytes | **57 / 64** |
| engine B, 127 bytes | **64 / 64** |

The seven failures are patches **1, 9, 17, 25, 33, 41, 49**, at residuals of
**−5.3, −1.8, −0.3, −2.2, +2.7, −0.6 and −3.3 dB relative**. Those are not
rounding differences; they are a different sound.

## The cause

Those seven are the **arpeggiator patches**, and the 118-byte set carries **none**
of ARPEGGIO SW, ARPEGGIO TYPE or ARPEGGIO STEP (blob 282/283, 290/291, 298/299 —
records 298, 306, 314; leaves 89, 90, 91).

The reason is visible in the format's own stated method. The live-byte scan
flipped record bytes and hashed a probe set of **audio cells**. With no transport
clock the arpeggiator writes no audio cell, so its three parameters were
invisible to the probe and were classified dead.

This is the same structural blindness that hid KEY ASSIGN, the fine-FX leaf table
and the MONO retrigger latch from the port's gates: **a byte set derived by
probing is only as complete as the probe.** A format derived that way must be
gated at the output, which is what `patch_roundtrip.py` now does — and it carries
the 118-byte set as a permanent negative control, so the gate is demonstrated to
be sensitive to a dropped parameter rather than trusted to be.

## Three further bytes, added because they are unstored parameters

These cost nothing (they are constant across the factory bank) and that is
precisely why the scan could not see them.

* **blob 112** — the high-nibble byte of **ASSIGN MODE**. Without it, KEY ASSIGN
  survives only because the template happens to supply a zero nibble (assign mode
  is 0..2, so the high nibble is 0 in all 64 patches). KEY ASSIGN is the single
  parameter this project has been bitten hardest by. It must not be carried by
  luck.
* **blob 466/467** — **F ENV VARIATION**, the VCF envelope SOURCE, the port's own
  "pluck has a slow attack" bug. It **varies** across the bank (value 1 in
  patches 1, 5, 10, 35, 36, 47, 61) and the 118-byte set carries **neither** of
  its bytes. MEASURED: dropping it is audio-inert under this driving, so this one
  is a **latent hole**, not a demonstrated audible defect — but a parameter that
  varies and is not stored is not a state a format may ship in.

## Result

**127 bytes**, in `engine_b/eb_patch.c` (`eb_patch_offsets`). Storage: 8,128 bytes
for the 64 factory patches; **159 patches** fit a 24LC256, against the 277 the
118-byte figure promises.

## What is still owed

Unchanged from the debt `COMPACT_FORMAT.md` already lists, and this session did
not pay it: **all of the above was derived by driving the PORT**. Per
`docs/trackb/THREE_WAY_GATE.md` only a scan against the **plugin** can retire the
claim. And the factory bank cannot exercise a parameter no factory patch moves —
EFFECT TYPE 4 (FLANGER) remains the named example. 127 bytes is a floor that has
been measured, not a ceiling that has been proven.

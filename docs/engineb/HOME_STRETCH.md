# THE HOME STRETCH — real time on TWO chips, 44.1 kHz, 6 voices + FX
(2026-08-09, Fable 5. Short on purpose. Every number is measured.)

TARGET: the busiest core (2 voices) <= 5,442 cycles. Today it is 6,788.
NEEDED: 673 cycles per voice.

## The four steps

1. **ATREST** — already built and gated, on the desk.        ~150/voice eq.
   You flash it, send the wake lines. Zero risk.

2. **The kernel** — fuse ladder+VCA into one hand-scheduled  ~450–600/voice
   block. The stalls are measured at ~735/voice in exactly
   those two modules; the kernel reorders instructions, never
   operations, so it is BIT-EXACT and gated EXACTLY 0.
   My work, host-side, no board needed until the final measure.

3. **The small stack** — tone-filter skip (~50) + zero-       ~100–180/voice
   coefficient deletions (60–130, proofs in hand).
   My work, each gated before it ships.

4. **Wire the second chip** — 3 wires I2S + 1 wire UART,
   chip B owns the clock and your DAC/amp. Firmware pair
   built and flashed like every binary so far.

## The arithmetic
3,394 − (150 + 500 + 130) ≈ 2,600/voice → 2-voice core ≈ 5,200 vs 5,442.
FITS, with the FX riding the 1-voice core (~1,300 cycles free there).

## The two honest risks, named once
- The kernel lands short (say 350, not 500): the same method extends over
  dcoprep+noisemix for the remainder. Same gate, more of the same work.
- FX measure worse than ~1,200 on silicon: they live on the emptiest core,
  which has room for triple that.

## What is NOT in this plan
No sample-rate change. No third chip. No new theories. No more discovery —
every dead end is measured and closed. This is carpentry with a finish line.

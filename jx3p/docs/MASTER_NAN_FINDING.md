# JX master "NaN defect" — the A/B seeds an INVALID state (not yet a port defect)

Traced 2026-08-25, while killing the mutation survivors.

## What was seen
With all 57 recall pools exercised (the corrected census), the integration A/B
reported the C master emitting NaN (0xffc00000) for L/R on patches 5/49/54,
while the voice seam and every voice-state word stayed EXACTLY 0. Eleven master
cells go NaN after ONE sample -- a count that matches the "11 argless helper
sites" the file header names, which is what made it look like the placeholders
had finally been reached.

## What it actually is
The NaN is NOT created by the C. It is INHERITED from the oracle snapshot the
A/B feeds both sides:

  * `mstate_in.bin` already holds NaN at st+269904 / 269920 / 269936 / 269952;
  * the chorus delay line at st+10928592 contains **3497 NaN entries of 65536**
    in the ORACLE's own state, before the port runs at all.

So the harness's warm-up (`jx.render(256)` x6, after poking st8+11191048=0 and
st8+20=1) leaves the plugin's chorus buffer partly filled with NaN. The plugin's
own render then reads an index that happens to be clean (idx 1787 -> 0.0) and
produces finite audio; the C reaches a contaminated value somewhere in the same
region and propagates it. Both sides start from a state no real host would ever
present.

Also visible in the same snapshot: st+10928080 = 0.9637203, mid-flight on a
parameter RAMP heading to 1.0 -- the same ramp subsystem found missing on both
ports today.

## Why this is NOT yet a port defect
A differential result is only meaningful from a VALID starting state. This one
is invalid on the oracle side. Calling it a port defect would repeat the
2026-08-25 cell-102560 retraction: an incomplete/incorrect oracle INVENTS
defects.

## Localised 2026-08-25 (second pass)
The state is CLEAN through BUILD, SETSR, RECALL (57 pools) and NOTE-ON. NaN
first appears in the FIRST RENDERED BLOCK and then grows by ~768 cells per
block = 3 cells per sample: the master writes NaN into a delay line every
sample, from the very first one it renders.

The two harness pokes are NOT the cause. Measured both ways on patch 5:
  * with pokes (latch forced to 0):    master NaN = 6569
  * without pokes (latch runs down):   master NaN = 1488
The latch (st8+11191048) is 960 at note-on and the master stub decrements it
once per SAMPLE, so without the poke the first ~960 samples are skipped and
only the remainder render -- fewer rendered samples, proportionally fewer NaN.
Rendering itself is what produces them, either way.

So the choice is now narrow and testable:
  (a) the harness drives the master incorrectly (wrong a2 layout, wrong block
      handling, or a buffer it never initialises), or
  (b) the plugin genuinely writes NaN into a buffer it does not read while
      that effect is disabled, and the NaN is inert.
THE DECIDING EXPERIMENT: hook reads of the NaN cells during a master render.
If they are only ever written and never read, (b) holds and the seed tooth
must ignore inert scratch instead of failing. If they ARE read, (a) holds and
the driving must be fixed before any master verdict is meaningful.

## The fix, in order
1. Make the A/B seed a clean state: warm the plugin through its own documented
   entry path rather than by poking two cells, long enough for the chorus line
   to be fully written, and ASSERT the snapshot contains no NaN before use.
   A snapshot containing NaN must fail the harness loudly, not be handed out.
2. Only then re-run the 57-pool A/B and judge the master.
3. The ramp subsystem (sub_1803F4A40 + its walker in the per-voice tail 0x3F40E0)
   is unported on JX and under-gated on JUNO; it is tracked separately.

## Status
OPEN as a HARNESS defect. The master's correctness under full FX is UNKNOWN --
neither proven nor disproven. It must not be reported as either.

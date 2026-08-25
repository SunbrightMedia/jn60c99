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

## Deciding experiment RUN 2026-08-25 -- and its first reading was too crude
Hooked reads of all 6569 NaN cells across 4 master samples: **4 reads, all from
ONE site, 0x18039D0E8**. Disassembled, that site is:

    39d0e8: mov  eax, dword ptr [rsi + 0x4424b0]
    39d0f1: mov  dword ptr [rsi + rcx*4 + 0x42490], eax

an INTEGER 32-bit copy shuffling a word into a ring buffer -- not arithmetic.
No FP instruction (movss/mulss/addss) read a NaN cell at all.

So the crude "is it read?" test answers the wrong question. The NaN bit
patterns are DATA being moved around a ring, and the plugin never computes with
them. That is alternative (b), not (a): the seed's NaN is inert as far as these
4 samples show, and a tooth that fails on ANY NaN anywhere in 11 MB of state is
too strict -- it would block a state the plugin itself is content to carry.

REVISED TOOTH CONTRACT (to implement): fail only when a NaN is read INTO FP
ARITHMETIC, not when one merely exists or is copied. Until that is in place the
existing tooth stays, but it must be understood as conservative, and
JX_ALLOW_NAN_SEED=1 is the documented escape for diagnosis.

STILL UNEXPLAINED: with the same seed and the same inputs, the C master emitted
NaN where the plugin emitted finite audio. Since the plugin does not compute
with these cells, the C must be reading a DIFFERENT cell or taking a DIFFERENT
branch. That divergence -- not the seed -- is the real remaining question, and
it is a genuine candidate port defect that must not be closed until explained.

## LOCALISED 2026-08-25 (third pass) -- 6 cells, one expression
Ran ONE master sample on both sides from the identical snapshot and diffed the
whole 11 MB master state:

| cell | C | plugin |
|---|---|---|
| 32 / 36 | NaN | 0.9902894 |
| 269968 / 269984 | NaN | 0.9902894 |
| 136 / 140 | object pointer | object pointer (harness relocation, expected) |

Only SIX cells differ and four of them are the same output value. Everything
else the master writes -- including the ring index at st+10928560 and the
chorus-path cells -- matches BIT-EXACTLY. So the divergence is not a branch
taken differently earlier and not an index computed differently; it is confined
to the final output expression.

0.9902894 is exactly st+270176, the CLAMP constant, so the plugin took
`if ((st+270160) - v479 <= 0.0) v482 = st+270176;` -- meaning its v479 >= 0.3032.
In the C, v479 is NaN, every comparison is therefore false, no clamp fires, and
the unclamped polynomial yields NaN. All of that expression's state inputs
(270016/270032/270048/270064/270080/270096/270112/270128/270144/270160/270176)
were verified FINITE in the seed.

NEXT STEP (bounded): bisect inside jx_master_render.c around lines 2535-2570 by
printing v466/v472..v482 for this one sample, and compare against the same
values under the oracle. The defect is in one line of that expression's
transcription, and it is now cheap to find.

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

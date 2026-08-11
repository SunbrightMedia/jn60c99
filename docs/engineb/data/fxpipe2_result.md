# ★ FXPIPE2: the FX is now FREE. 8,746 -> 6,138. (2026-08-11)

`juno_s3_FXPIPE2.bin`, the user's board. The only change from FXPIPE is that
core 1's FX loop moved ABOVE its voice loop.

    FXPIPE  (voices then FX)   engine 8,746
    FXPIPE2 (FX then voices)   engine 6,138
    saved                             2,608
    the FX costs                      2,622

**The saving equals the FX's entire cost to within 14 cycles. The FX chain is
now approximately 100 % hidden -- it is free.** The ordering diagnosis was
right, and moving one loop above another was the whole fix.

    vs budget 5,442 : OVER by 696 = 1.13x
    drift           : +143 ms/s = 1.14x, which agrees

## The bottleneck has moved, and it is no longer the FX

    core 0 = prologue + 2 voices = 6,138   <- the critical core
    core 1 = 1 voice + FX        = 4,984   <- idle for 1,154 cycles

Backing the voices out gives the **prologue = 1,414 cycles**, measured rather
than assumed, and it sits on core 0 where it cannot be split.

## What each chip can now hold, on measured constants

prologue 1,414 · voice 2,362 · FX 2,622 · budget 5,442

    2 voices + FX, split 1/1 : core0 3,776  core1 4,984  -> 4,984  FITS
    3 voices + FX, split 2/1 : core0 6,138  core1 4,984  -> 6,138  OVER 696
    3 voices,  no FX, split 1/2 : core0 3,776  core1 4,724 -> 4,724  FITS
    4 voices,  no FX, split 2/2 : core0 6,138  core1 4,724 -> 6,138  OVER 696

## THE CONSEQUENCE FOR THE 6-VOICE GOAL, stated plainly

Two chips at 3 voices each needs the FX chip to carry **3 voices + FX = 6,138**,
which is over by 696. The best honest reading of these numbers is:

    chip A : 3 voices, no FX      = 4,724   FITS
    chip B : 3 voices + FX        = 6,138   OVER by 696

**So 6 voices with FX is 696 cycles short on one core, and nothing else.** Not
a factor, not a redesign -- 12.8 % of one core.

Two candidate levers, neither measured in this configuration:

1. **`EB_PROLOGUE_PIPE`.** It exists to compute sample i+1's prologue after
   core 0's own voices so core 1 is never blocked, turning the loop into
   `max(core0_voices + prologue, core1_voices)`. It was closed NEGATIVE (-7
   cycles) in a build where core 0 was NOT prologue-bound. It is now, and the
   prologue is 1,414 on the critical core. That closure was measured under
   different conditions and does not transfer -- the same mistake this
   document made about ring placement, so it is named here before it is
   repeated.
2. **The voice slope.** 696 is 29 % of one voice. Nothing currently on the
   table removes that much.

Neither is a promise. The measured position is: **the FX is free, and the
remaining gap is 696 cycles on one core.**

# EB_PROLOGUE_PIPE CLOSED NEGATIVE AGAIN, and now for a stated reason

    FXPIPE2            engine 6,138
    FXPIPE3 (+PIPE)    engine 6,136      -> -2 cycles

The retest was justified -- the first closure was measured when core 0 was not
prologue-bound -- and the answer is the same. This time the reason is known
rather than assumed:

**`EB_PROLOGUE_PIPE` changes WHEN CORE 1 IS RELEASED. Core 1 is no longer
waiting.** The FX-first reorder already fills that window. And core 0 is
WORK-bound, not dependency-bound: its total (prologue + 2 voices) is the same
whichever order it runs them in. **A lever aimed at a dependency cannot move a
work bound.**

That is a general rule worth keeping: before adopting a scheduling lever,
identify whether the critical core is waiting or working. Only the first kind
is reachable by scheduling.

## THE REMAINING BOUND, and it is much smaller than 696

Chip B's TOTAL work per sample:

    prologue 1,414 + 3 voices 7,086 + FX 2,622 = 11,122
    perfectly balanced over two cores          =  5,561
    budget                                     =  5,442
    -> EVEN PERFECT BALANCE IS 119 OVER

So the position is:

    measured today             6,138   over by 696
    best conceivable rebalance 5,561   over by 119

**577 of the 696 is bad balance and is reachable by scheduling. The last 119
is real work and is not.** The obstacle to the balance half is that the
prologue is 1,414 cycles, indivisible, and must precede the voices -- so any
core holding it plus two voices lands at 6,138 regardless of order.

Two honest routes for the last 119, neither attempted:
- Remove ~119 cycles of arithmetic anywhere on the chip. That is 5 % of one
  voice, or 4.5 % of the FX chain.
- Pipeline the PROLOGUE itself onto core 1 a chunk ahead, the way the FX now
  is. Core 1 idles 1,154 and the prologue costs 1,414, so it does not fit in
  the gap today -- but it would change the shape of the bound rather than
  chip away at it.

Nothing above is a promise. It is where the measurements leave the problem.

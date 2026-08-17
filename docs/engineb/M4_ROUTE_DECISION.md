# M4 — the B3 route, decided at the worst patch instead of patch 0
2026-08-17. ARITHMETIC on measured figures, each sourced below. No board run;
none is needed to choose between two layouts, and the choice does not depend on
the L1 number that M3 removed.

## THE BASIS M4 WAS SUPPOSED TO USE IS GONE
The plan said: "decide the B3 route with M3's number in hand: ~700 on chip B vs
~850 on chip A stops being a guess once the FX's real post-L1 cost is known."
M3 established there is no post-L1 cost, because L1 as scoped cannot be done
(1,030 KB of rings against 163 KB of internal SRAM). So the route is decided on
what is measured today, and it turns out not to have needed L1 at all.

## THE INPUTS
| quantity | value | source |
|---|---|---|
| budget, 240 MHz / 44,100 | 5,442 | data/chip_layout.md |
| one voice | 3,068 | data/fx_chain_price.md:48 |
| FX chain, DELAY TYPE 0 | 2,622 | data/patch_dependent_fx.md |
| FX chain, DELAY TYPE 2/3/5 | ~8,100 | data/patch_dependent_fx.md |

Two honest caveats. The voice figure is 3,394 in the ASM_KERNEL_PLAN era
(6,788 for a two-voice core rather than 6,136); the conclusion below holds
either way and the difference is noted where it matters. And
fx_chain_price.md:5 records the FX chain at 7,745 cycles, consistent with the
~8,100 expensive-patch figure rather than the 2,622 TYPE 0 one -- they are the
same chain on different patch classes, which is precisely the trap
patch_dependent_fx.md was written to expose.

## THE TWO LAYOUTS, AT BOTH PATCH CLASSES
Six voices, two chips, four cores. The FX must live on one chip because it sums
every voice.

**LAYOUT A** — 3 voices per chip; chip B's second core carries 1 voice + FX.
**LAYOUT B** — 4 voices on chip A; chip B is 2 voices on one core and the FX
ALONE on the other.

| patch class | layout | chip A | chip B |
|---|---|---|---|
| TYPE 0 (46 of 64) | A | 6,136 (+694) | 6,136 (+694) |
| TYPE 0 | B | 6,136 (+694) | 6,136 (+694) |
| **TYPE 2/3/5 (18 of 64)** | A | 6,136 (+694) | **11,168 (+5,726)** |
| **TYPE 2/3/5** | B | 6,136 (+694) | **8,100 (+2,658)** |

## THE DECISION: LAYOUT B
On the cheap patches the two layouts are identical. On the worst patch class
Layout B is better by **3,068 cycles — exactly one voice**, because it is the
only arrangement in which the expensive FX does not stack on top of a voice on
the same core. That is the whole decision, and every previous comparison missed
it by being taken on patch 0, where the two layouts tie.

This also settles the "~700 on chip B vs ~850 on chip A" question the plan
posed: neither figure is the binding one. Both layouts are over budget on
EVERY patch because of the voice chain alone, and the layouts differ only on
the 18 expensive patches, where B wins.

## WHAT LAYOUT B COSTS US, AND IT IS NOT FREE
**Layout B uses all four cores: A0 = 2v, A1 = 2v, B0 = 2v, B1 = FX.** There is
no spare core left.

That spends L2. The headroom plan listed L2 as "FX arms on the spare core,
using the one-sample delay the port's own topology already has" and M2 called
it required rather than a fallback. In Layout B there is no spare core for it:
the FX is already alone on B1, and the only other core on that chip is carrying
two voices. **L2 is not an additional lever on top of Layout B; Layout B IS the
structural move, and it is now spent.**

## THE TWO GAPS THAT REMAIN, AND ONLY ONE HAS A LEVER
| gap | size | where | lever |
|---|---|---|---|
| the two-voice core | **+694** | both chips, every patch | L3 — the ASM stall pool, 735/voice (LAST_MILE Phase B) |
| the worst-patch FX | **+2,658** | chip B only, 18 of 64 patches | **NONE IDENTIFIED** |

The first is covered, and robustly: L3's pool is 735 cycles per voice against a
694-cycle gap, and even on the ASM_KERNEL_PLAN's heavier voice (6,788, +1,346)
two voices' worth of pool is 1,470 and still covers it.

The second is not covered by anything now on the list:
- **L1 is dead** (M3): the rings do not fit internal SRAM at the size the
  DELAY TIME parameter requires.
- **L2 is spent** (above): Layout B already puts the FX alone on a core.
- **L3 is a voice-chain lever**, and this gap is the FX chain.
- **L4 is the TYPE 4 arm**, and this gap is TYPE 2/3/5.

And M2 already said where it would have to come from: only 34 % of the
expensive arm is memory. **The remaining 2,658 is mostly arithmetic in
eb_delay_t23 and eb_delay_t5**, which means the work is making those two
modules genuinely cheaper — the ASM kernel pointed at the FX arms rather than
the voice, or an algorithmic change to the arms, gated at the fork's sonic
standard rather than EXACTLY 0.

## WHAT TO DO NEXT, and what NOT to do
1. **Adopt Layout B** as the target arrangement. It is decidable now and it is
   strictly better on the patches that break the invariant.
2. **L3 against the two-voice core.** It is sized for its gap and its gate
   discipline is already written (ASM_KERNEL_WORKORDER).
3. **Open a NEW lever for the delay arms' arithmetic.** It does not exist on
   the plan and nothing else covers its gap. Size it against 2,658 on chip B.
4. **Do not spend effort on ring placement** expecting the FX to come free.
   M3 removed that, and M2's ceiling said it was short even when it looked
   alive.

The one number that would change this page is the board's: every figure here is
2 voices + FX, and the B4 counter added in M1 has never run under the stress
b4_stress.py builds. If the worst case at 3 voices differs from the arithmetic
above, this decision should be re-taken against it -- but the ORDERING of the
two layouts comes from the FX not sharing a core with a voice, and that does
not depend on the exact figures.

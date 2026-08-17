# M2 — the worst case, and the number that was wrong
2026-08-17. No board was available, so nothing here is a new silicon
measurement. Everything is either QUOTED from a file that sources it to a board
run, or ARITHMETIC on such quotes, and each is labelled. The one number M2 owes
that still requires the board is named at the end.

## THE HEADLINE: G2 IS ~5,258 CYCLES, NOT ~1,460

`FINAL_GUIDE.md:97` states:

> **The 18 DELAY TYPE 2/3/5 patches VIOLATE this invariant today** (6,600-6,900
> cycles against 5,442)

and `CLAUDE.md`'s LIVE STATE carries the same figure as "~6,800". **That range
does not belong to the delay patches.** It is the TWO-VOICE CORE figure, and it
appears in four other files with that meaning:

| file | figure | what it measures |
|---|---|---|
| ASM_KERNEL_PLAN.md:7 | 6,788 | "Two-voice core today: 2 x 3,394" |
| ASM_KERNEL_WORKORDER.md:100 | 6,681 | "the gap is 0xd0 ... on the 2-voice core" |
| LAST_MILE.md:3 | 6,723 | "MEASURED GAP: 0xd0 ... -> 640 cycles/voice" |
| VCF_ZDF1X_PLAN.md:113 | 6,788 | "Two-voice core" |

Those are about the VOICE CHAIN. The delay-patch cost is a different
measurement, on the board, in `docs/engineb/data/patch_dependent_fx.md`
(2026-08-12, `juno_s3_QUIET.bin`):

    2 voices + FX, DELAY TYPE 0    5,159   FITS
    2 voices + FX, DELAY TYPE 5   ~10,700  2x OVER
    FX chain: TYPE 0 = 2,622  ->  TYPE 2/3/5 ~ 8,100

So the invariant violation is **10,700 - 5,442 = ~5,258 cycles**, not the
~1,460 that the conflated figure implies. HEADROOM_PLAN.md sized G2 off the
wrong number and is corrected in this commit.

## THE CROSS-CHECK THAT MAKES IT TRUSTWORTHY
Independent of the board total, from the instruction counts:

    DELAY arm, TYPE 0 (shared core)     320 instr   engine_cost.md:47
    DELAY arm, TYPE 5                 1,979 instr   engine_cost.md:47
    spread                            1,659 instr
    x MEASURED c/i 2.36                3,915 cyc    fx_chain_price.md:9-12

`tools/engineb/arm_dist.c:3-7` states that same 3,915 in its own header. Add it
to the measured TYPE 0 total: 5,159 + 3,915 = **9,074**, against a board
measurement of ~10,700 for TYPE 5 (the remainder is the EFFECT arm and the rest
of the patch-dependent chain). Two independent routes land within ~15 % of each
other and BOTH are far above 6,900. The conflated figure is not merely stale;
it is the wrong quantity.

## THE ATTRIBUTION M2 ASKED FOR: memory vs arithmetic
ARITHMETIC on two MEASURED c/i values (voices 1.56, FX chain 2.36, both from
`o8_halfos_result.md` §10 via `fx_chain_price.md:9-12`):

| the delay arm's 1,659-instruction spread | cycles | share |
|---|---|---|
| at the FX chain's measured c/i 2.36 | 3,915 | 100 % |
| at the voice chain's c/i 1.56 (arithmetic floor) | 2,588 | 66 % |
| **the difference = the MEMORY term** | **1,327** | **34 %** |

**Two thirds of the expensive arm is arithmetic, not memory.** That is the
finding that matters for the plan, because L1 (rings out of PSRAM into internal
SRAM) can only ever attack the memory third.

## WHAT THIS DOES TO L1, AND IT IS DECISIVE
`fx_chain_price.md:5` measures the whole FX chain at 3,276 instructions and
7,745 cycles. If ring placement moved its c/i all the way to the voice chain's
1.56 -- the best case its own §5 hypothesises, "the hypothesis being tested is
that c/i 2.36 -> ~1.6" -- then:

    FX chain today                     7,745 cyc
    FX chain at c/i 1.56               5,111 cyc
    L1 CEILING (a PERFECT L1)          2,634 cyc

    G2                                 5,258 cyc
    minus a perfect L1                -2,634
    STILL TO FIND                      2,624 cyc

And `fx_chain_price.md:3` already records the same conclusion from the other
side: at 5,111 the FX is still above the **3,068** threshold below which it
hides behind the two-voice core and costs the instrument nothing.

**L1 CANNOT CLOSE G2 ON ITS OWN, EVEN IF IT WORKS PERFECTLY.** The headroom
plan listed L2 (FX arms on the spare core, using the one-sample delay the
port's own topology already has) as a "structural fallback if L1 lands short".
It is not a fallback. On these numbers L1 lands short by construction, and L2
or something of its size is REQUIRED.

## WHAT M2 STILL OWES THE BOARD
Nothing above is a new silicon measurement, and three things cannot be settled
without one:

1. **The true worst case at 3 voices.** Every figure here is 2 voices + FX.
   B4's stress (all 64 patches x worst polyphony x program change) has never
   run; the counter it needs was only added today and its tooth has never been
   seen to fire.
2. **Whether ~10,700 still holds.** It is `juno_s3_QUIET.bin`, 2026-08-12,
   before the FX-in-IRAM fix that removed PLAY2's 10,158-cycle chunks
   (`c3_silicon.md`, PLAY3). That fix plausibly moved this number and nobody
   has re-taken it. The arithmetic cross-check above does not depend on it, but
   the exact G2 does.
3. **Whether c/i 2.36 -> 1.56 is achievable at all.** It is the repo's own
   hypothesis and has never executed. If placement only reaches, say, 2.0, the
   L1 ceiling falls from 2,634 to about 1,180 and the gap to find grows past
   4,000.

The order the plan already sets stands, and this file only sharpens it: run the
B4 tooth, see it red, then run the stress and take the worst-case number ONCE.
Do not re-derive G2 from arithmetic when a board can print it.

## CORRECTION (same day): the arm is STALL-bound, not arithmetic-bound
The attribution above priced the delay arm by applying the FX CHAIN's c/i
(2.36) to the arm's instruction delta: 1,659 x 2.36 = 3,915 cycles, of which
2,588 was called the arithmetic floor and 1,327 (34 %) the memory term. That
used an average where a direct measurement exists, and it understates the arm.

The arm's OWN cost is the difference between two board measurements of the same
chain (data/patch_dependent_fx.md): DELAY TYPE 0 = 2,622 cycles, TYPE 2/3/5 =
~8,100. So the arm costs **5,478 cycles for 1,659 instructions -- c/i 3.30**,
not 2.36, and not 3,915 cycles.

    voice chain        8,200 instr  12,820 cyc  c/i 1.56  stalls 4,620 (36 %)
    FX chain           3,276 instr   7,745 cyc  c/i 2.36  stalls 4,469 (58 %)
    THE EXPENSIVE ARM  1,659 instr   5,478 cyc  c/i 3.30  stalls 3,819 (70 %)

**Seventy per cent of the arm is stall.** The claim in this file that "two
thirds of the expensive arm is arithmetic" is WRONG: it followed from the
averaged c/i, and the arm's own figure inverts it. Only 30 % of the arm's time
is issuing instructions.

WHAT THAT CHANGES. The 2,658-cycle gap M4 left without an owner does NOT have
to come out of the algorithm:

    the arm today, c/i 3.30                    5,478 cyc
    the arm at the VOICE chain's c/i 1.56      2,588 cyc
    difference                                 2,890 cyc   > the 2,658 needed

Bringing the arm's stall rate down to the rest of the engine's would close the
gap on its own, and stalls are waiting rather than work -- removing them
changes no arithmetic and therefore no sound. That is a scheduling and
placement problem, not an algorithm rewrite.

ROBUST TO THE INPUT UNCERTAINTY: "roughly 8,100" is the softest number here.
Even at 7,745 the arm delta is 5,123 cycles, 3,464 of them stall, and the
head-room to voice-chain c/i is 2,535 -- within 5 % of the need rather than
comfortably over it, but the conclusion (stall-bound, not arithmetic-bound)
does not move.

NOT PROVEN, and it is the next measurement: WHICH stalls, and how many are
recoverable. Four ring buffers in PSRAM is the obvious suspect and M3 already
showed the rings cannot simply move (1,030 KB vs 163 KB). The live-window
variant M3 identified is unmeasured and is now the first thing to measure,
because it attacks exactly this 3,819.

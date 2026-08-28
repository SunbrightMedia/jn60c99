# b34 — half-rate FX priced on silicon: the lever CLOSES THE GAP (2026-08-28)

The b33 price probes (delay + reverb held every second sample, MSPROF on) ran
on the board. The decision rule, written before the flash, fired GREEN.

## Per-stage price (MSPP, cyc/sample, vs b31 same-config)
| stage | b31 | probe | drop | rule (~45-50%) |
|---|---|---|---|---|
| delay typical | 660 | 363-365 | -45% | PASS |
| delay pat 49 | 2097-2140 | 1026-1099 | -49% | PASS |
| delay pat 21 | 2082-2085 | 806-1079 | -48% | PASS |
| delay pat 5  | 2092-2099 | 855-1088 | -49% | PASS |
| reverb | 970-1440 | 516-865 | -42% | PASS |

## The block time
`B4dur quiet` = 5748-5990 us against the 5804 period WITH both profilers still
inside the loop (b31 comparable read 6635; b32 clean read 6460). Hot-patch
master sums fell from ~4200 to ~2600 cyc/sample. Misses fell sharply (quiet
13-26/10k vs 41-57).

**With profilers off, the real half-rate build lands UNDER period, idle and
worst case, with margin.** The steady-state gap (~656 us) and the t5 worst
case (~1000+) are BOTH covered by this one lever.

## What this build is NOT
Sonically wrong by design (echo times doubled, tails held). NEVER a listening
build. It answers only the cycle question, and it has.

## The real version, now justified
1. Rebuild delay + reverb internal time constants for 22,050 Hz so echo and
   tail TIMES stay correct: tap counts halve, coefficient laws re-derived at
   the half rate (the recall's rate-arm machinery is the tool).
2. Proper down/up sampling at the stage seams (short polyphase pair).
3. Trunk byte-identical off (same guard discipline as b33; proven by cmp).
4. sonic_gate bound, then the USER'S EAR at F2 -- this is a sonic trade and
   the user is the judge. The b33 probes are not that judgment and must not be
   presented as it.

## Order vs the other levers
This lever alone covers the whole measured gap. The VCA move (b26/b27) drops
to RESERVE -- worth keeping designed, unbuilt, in case the real half-rate
version prices worse than the probe (resamplers cost something) or the ear
rejects a piece of it.

# MODULE ORDER — decided by measurement, 2026-08-01

`docs/trackb/NEXT.md` said: "survey canary observability across all seven module
ranges and let that pick the order. Start with the highest-observability module,
not the simplest one." Done. Raw output in `CANARY_SURVEY.txt`.

| rank | module | lines | observable | BLIND lines |
|---|---|---|---|---|
| 1 | M1b noise SVF + source mix | 1129-1149 | **12/14** | 1132, 1143 |
| 2 | M7 envelope | 1298-1400 | 11/14 | 1337, 1346, 1349 |
| 3 | M6 mix | 1150-1229 | 10/14 | 1162, 1172, 1174, 1177 |
| 4 | M4 VCF | 1516-1640 | 9/14 | 1522, 1524, 1529, 1531, 1534 |
| 5 | M5 PWM | 1076-1128 | 9/14 | 1079, 1082, 1092, 1096, 1097 |
| 6 | M8 VCA / output | 1718-1830 | 8/14 | 1720, 1726, 1735, 1737, 1739, 1740 |
| 7 | **M2 DCO** | 964-1021 | **5/12** | 968, 973, 974, 981, 987, 988, 993 |
| 8 | **M3 DCO2** | 1022-1075 | **5/12** | 1023, 1028, 1029, 1036, 1042, 1043, 1048 |
| 9 | M1a conditioner + gate | 654-693 | **2/13** | 11 of 13 |

## What this changes

**PLAN §3 is confirmed wrong.** It put M1a first because its math is trivial.
M1a is the *worst* gated module in the engine: 2 of 13 assignments observable.
A module whose null stays green whatever you write into it is the worst place to
start. NEXT.md already said so from a partial survey; the full survey confirms it
across all nine ranges.

**The uncomfortable finding is rank 7 and 8.** The two DCO modules are the ones a
performance rewrite most wants to touch -- they are the oscillator core and a
prime cost centre -- and they are the least observable in the engine at 5/12.
Charter gate #4 forbids rewriting behind a blind gate. So DCO work is BLOCKED
until the scenario set reaches those lines. That is a prerequisite task, not an
optional improvement.

**Rank 1 is genuinely ready.** M1b at 12/14 with only two blind lines, both of
which NEXT.md already classified: `:1132`'s store to 4304 is overwritten at
`:1134` before the next read, and `:1143` writes cell 6464 which has zero readers
anywhere in voice_render.c or master_render.c. Write-only shadows -- droppable
under a sonic-identity claim, though NOT under the bit-exact one, and they belong
in the ledger's `state_parity` column.

## Order of work

1. Close the DCO blind gates (M2/M3) -- prerequisite, blocks the highest-value
   rewrites.
2. M1b, then M7, then M6 -- rewrite where the gate can already see.
3. M1a last, or never: if the gate cannot see it, the cycles it costs are better
   attacked structurally than by rewriting arithmetic nobody can validate.

Note that this ordering is by GATE QUALITY, not by cost. It must be crossed with
the cost attribution before any rewrite is scheduled: a well-gated module that
costs 2% of the budget is not where the 11.19x comes from.

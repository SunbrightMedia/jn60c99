# MODULE ORDER — rebuilt 2026-08-02, additive probe, labels verified against cells

Supersedes the multiplicative survey entirely. Raw output:
`CANARY_SURVEY_ADDITIVE.txt` (this one) and `CANARY_SURVEY.txt` (the old one,
kept only as the record of what an under-reporting probe looks like).

## Two things were wrong with the first survey

**1. The probe could not see half of what it measured.** The default canary
scales an assignment by 1.001. That cannot move a literal zero
(`0.0f * 1.001f == 0.0f`), cannot flip a sign test or a threshold because scaling
preserves sign, and cannot move a value whose consumer saturates. Re-run with
`--add 1.0`:

| range | multiplicative | **additive** | genuinely blind |
|---|---|---|---|
| 654-693 | 2/13 | **4/13** | 9 lines |
| 964-1021 | 5/12 | **10/12** | 974, 988 |
| 1022-1075 | 5/12 | **10/12** | 1029, 1043 |
| 1076-1128 | 9/14 | **11/14** | 1082, 1092, 1097 |
| 1129-1149 | 12/14 | **12/14** | 1132, 1143 |
| 1150-1229 | 10/14 | **11/14** | 1162, 1172, 1174 |
| 1298-1400 | 11/14 | **11/14** | 1337, 1346, 1349 |
| 1516-1640 | 9/14 | **9/14** | 1522, 1524, 1529, 1531, 1534 |
| 1718-1830 | 8/14 | most lines 17/27 or 27/27 | 1739 (summary line lost; re-run) |

**2. The LABELS were wrong, and in the worst possible way.** Verified by checking
which cells each range actually touches against the blueprint documents:

| range | old label | **what it actually is** | evidence |
|---|---|---|---|
| 964-1021 | "M2 DCO" | **ENV1 ADSR** | touches 2560, 2576, 2608, 2624, 2640, 2656, 2688, 2736, 2864, 2880 — every one documented in `ENV.md` |
| 1022-1075 | "M3 DCO2" | **ENV2 ADSR** | structural copy of the above |
| **1718-1830** | "M8 VCA/output" | **THE DCO** | touches 4640, 4656, 5552, 5648, 5952 — all in `DCO.md`; contains the phase wraps at :1726/:1730 and the phase store `JF(a1,4640) = v403` at :1732 |

So for two days I have been repeating that "the DCOs are blocked at 5/12 and may
not be rewritten". **Both halves were false.** Those ranges are the envelope
generators and they read 10/12 additively; the real DCO is elsewhere and is among
the better-gated ranges. A rewrite scheduled from the old table would have been
driven by `DCO.md` while editing envelope code.

## The order, corrected

Gate quality only. It must still be crossed with cost before scheduling.

| rank | range | what it is | observable |
|---|---|---|---|
| 1 | 1129-1149 | noise SVF + source mix | 12/14 |
| 2 | 1076-1128 | PWM | 11/14 |
| 2 | 1150-1229 | mix | 11/14 |
| 2 | 1298-1400 | envelope (per `MODULE_ORDER` legacy name) | 11/14 |
| 5 | 964-1021 | **ENV1 ADSR** | 10/12 |
| 5 | 1022-1075 | **ENV2 ADSR** | 10/12 |
| 7 | 1516-1640 | VCF | 9/14 |
| — | 1718-1830 | **DCO** | re-run needed for the summary |
| last | 654-693 | conditioner + gate | **4/13** |

654-693 remains the worst by a wide margin and is still the module PLAN §3 wanted
first.

## Genuinely blind lines, classified with proof rather than suspicion

* **974** — stores to cell 2576, which has **no reader** in `voice_render.c` or
  `master_render.c`. A mutant writing 12345.0 there is bit-identical over 384
  full-bank comparisons and 24 fuzz seeds. Dead store.
* **988** — feeds a branch that DOES fire (planting a marker in the override body
  is caught 25/26 at 57.7 dB) but is **outcome-neutral**: deleting the override
  entirely is bit-identical over the same 384 + 24. Where `h` falls, the value
  the override writes already equals what the preceding lines wrote.
* **1132, 1143** — write-only shadows, classified previously.

## Standing lesson

The multiplicative-probe defect was found in `observability.py`, fixed there, and
left in `canary.py`'s default — where it silently produced the survey that set
the work order. **Fixing a probe defect in one tool is not fixing it.** When a
measurement instrument is found to under-report, every tool sharing that
technique must be re-run before its output is trusted.

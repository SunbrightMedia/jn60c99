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

## The labels, CORRECTED from CELLMAP.md's own cell names

Six of the nine were wrong. Three were swapped between entirely different
subsystems. Identified by taking every cell each range touches and reading the
name `CELLMAP.md` gives it — the plugin's own registry where available — rather
than trusting `PLAN.md`.

| range | old label | **what it actually is** | decisive evidence |
|---|---|---|---|
| 654-693 | conditioner+gate | **CV/gate conditioning** ✔ | 304 "M.CV — note pitch CV", 448 smoother-enable |
| 964-1021 | M2 DCO | **ENV1 ADSR** | 32 of 35 cells named ENV |
| 1022-1075 | M3 DCO2 | **ENV2 ADSR** | 33 ENV cells; 3040 "LFO trigger env sw" |
| 1076-1128 | M5 PWM | **pitch/PWM modulation CV** | 752 "FINAL PITCH CV", 1792 "LFO OUT" |
| 1129-1149 | M1b noise SVF | **noise SVF** ✔ | 4288/4304 "noise SVF state 1/2" |
| 1150-1229 | M6 mix | **VCF cutoff CV summing** | 18 VCF + 16 LFO cells |
| 1298-1400 | M7 envelope | **VCF LADDER CORE** | 6544 "VCF AUDIO INPUT", 7536 "resonance drive", 8208 "ladder stage-1 nl out" |
| 1516-1640 | M4 VCF | **VCA + HPF output** | 12 VCA + 7 HPF cells; 2752/3232 "ENV OUT raw" |
| 1718-1830 | M8 VCA/output | **DCO OSCILLATOR** | 4640 "DCO master phase (wrap [-1,1))", 4672 sub-osc counter, saw/pulse |

Only three of nine were right. The three most consequential — the DCO, the VCF
ladder and the envelopes — were each pointing at a different subsystem's code.

`tools/trackb/verify_labels.py` now carries the corrected table and exits 0.

## The order, corrected

Gate quality only. It must still be crossed with cost before scheduling.

| rank | range | module | observable |
|---|---|---|---|
| 1 | 1129-1149 | noise SVF | 12/14 |
| 2 | 1076-1128 | pitch/PWM modulation CV | 11/14 |
| 2 | 1150-1229 | VCF cutoff CV | 11/14 |
| 2 | 1298-1400 | **VCF ladder core** | 11/14 |
| 5 | 964-1021 | ENV1 ADSR | 10/12 |
| 5 | 1022-1075 | ENV2 ADSR | 10/12 |
| 7 | 1516-1640 | VCA + HPF output | 9/14 |
| — | 1718-1830 | **DCO oscillator** | re-run for the summary |
| last | 654-693 | CV/gate conditioning | **4/13** |

## Genuinely blind lines, classified with proof rather than suspicion

* **974** — stores to cell 2576. **DEAD, PROVEN by execution**
  (`tools/trackb/deadstore.py 974`, 2026-08-02): the line is instrumented and
  shown to execute (438/438 comparisons change when its execution is made
  audible), and three different absurd stored values — 12345.0, -7.7e18 and 0.0 —
  are each bit-identical across 30 scenarios + 384 full-bank + 24 fuzz = 438
  comparisons, scored EXACTLY rather than against a threshold.
* **988** — feeds a branch that DOES fire (planting a marker in the override body
  is caught 25/26 at 57.7 dB) but is **outcome-neutral**: deleting the override
  entirely is bit-identical over the same 384 + 24. Where `h` falls, the value
  the override writes already equals what the preceding lines wrote.
* **1132, 1143, 1146, 1147** — **DEAD, PROVEN by execution** as of 2026-08-02
  (`deadstore.py 1132 1143 1146 1147`): each executes, and each is bit-identical
  under all three absurd stored values over the same 438 comparisons.
  **They were previously classified by READING** — ":1132 is overwritten at
  :1134", ":1143 has no readers" — which was not evidence. A grep for a numeric
  offset in this engine finds textual matches, not readers: the state is a flat
  byte block addressed by number, aliased by JF/JI over the same memory, and
  several cells have register-promoted shadow locals. The reading happened to be
  right; that is luck, not method.

## Standing lesson

The multiplicative-probe defect was found in `observability.py`, fixed there, and
left in `canary.py`'s default — where it silently produced the survey that set
the work order. **Fixing a probe defect in one tool is not fixing it.** When a
measurement instrument is found to under-report, every tool sharing that
technique must be re-run before its output is trusted.

## DCO (1718-1830) — survey completed, and its three blind lines classified

Dual-probe run, 2026-08-02: **11/14 observable**, not the 8/14 the multiplicative
probe reported. BLIND: 1720, 1726, 1739. Three lines, three different causes,
and two of them are the dangerous kind.

| line | code | cause |
|---|---|---|
| `:1720` | `JF(a1,4656) = _s4656 = v401;` | **DEAD STORE, PROVEN by execution 2026-08-02** (`deadstore.py 1720`). The line executes; corrupting only the MEMORY STORE with 12345.0, -7.7e18 and 0.0 — while the shadow local `_s4656` still receives the real value — is bit-identical over all 438 comparisons. Cell 4656 has no reader. **Read the caveat below: the STORE is dead, the VALUE is not.** |
| `:1726` | `v403 = fmodf(v403 - 1.0, 2.0) + 1.0;` | **UNREACHED — the NEGATIVE phase-wrap arm.** Taken only when the accumulated phase falls below −1. No scenario drives it. |
| `:1739` | `v407 = -1.0;` | **UNREACHED — the negative clamp arm** of the pulse shaper, taken only when its input falls below −1. |

**Why the two unreached arms matter more than a dead store.** They are the
*negative-going* halves of a wrap and a clamp. A rewritten DCO that handles only
the positive side would null perfectly on all 27 scenarios and then break the
first time a patch drives pitch downward. That is exactly the shape of the
`fmodf` rounding defect found in `eb_triangle`, where the obvious replacement
disagreed on 8,388,608 inputs — except here the gate would not even complain.

**To open them**, drive the phase negative with the parameters that reach it:
`DCO LFO MOD` (blob 9) at depth with a slow `LFO RATE` (blob 8) so the modulation
sweeps a full cycle, and `DCO PWM DEPTH` (blob 14) for the pulse-shaper clamp.
Both are front-panel bytes, so `('param', 9, N)` and `('param', 14, N)` scenarios
reach them without inventing engine state.

**Standing rule for this module:** the DCO may not be rewritten until :1726 and
:1739 are either opened by a scenario or proven unreachable. A dead store is a
safe residual; an unreached branch is not.

### The DCO blind lines, resolved by execution counting and margin measurement

Guessing at parameters did not open them: three scenarios built specifically to
drive pitch negative (`DCO neg pitch sweep`, `DCO neg wrap + PWM clamp`,
`DCO neg warm chorus`, using DCO LFO MOD at depth with a slow LFO RATE) left the
count at 11/14. So the lines were **instrumented and counted** instead.

**Execution counts across all 30 scenarios:**

| line | executions | conclusion |
|---|---|---|
| `:1720` prev-phase store | **240,000-737,000 per scenario** | executes constantly. NOT unreached — **UNOBSERVABLE**, and now **PROVEN a dead store** by `deadstore.py`, no longer inferred from the shape of `:974`. |
| `:1726` negative phase wrap | **0** | never executes |
| `:1739` negative pulse clamp | **0** | never executes |

**Then the margin**, because "the branch did not fire" says nothing about how
close it came, and a rewrite changes exactly that:

| test | minimum value seen | threshold | margin |
|---|---|---|---|
| `:1725` `v403 < -1.0` | **−0.999657** | −1.0 | **0.000343** |
| `:1738` `v406 < -1.0` | **0.000000** | −1.0 | 1.0 |

**These two are NOT the same finding, and treating them alike would be the bug.**

* **`:1739` is safely dead.** Its input never goes negative at all, let alone
  below −1. The clamp cannot fire, and engine B may omit it. Margin 1.0.
* **`:1726` is a hair from firing.** The phase reaches −0.999657, i.e. within
  **0.0003** of the threshold, because the positive wrap at `:1730` lands it just
  above −1 and it climbs from there. It is not dead code — it is a boundary the
  engine rides against every wrap cycle. **A rewritten DCO whose wrap arithmetic
  rounds a fraction differently WILL cross it**, and the branch must be
  implemented. Omitting it because "no scenario reached it" would be exactly the
  `eb_triangle` mistake again: there, replacing `fmodf(p+1,2)-1` with `p-2` was
  mathematically identical and disagreed on 8,388,608 inputs because of rounding.

**Revised rule for this module.** The DCO may be rewritten, provided:
1. `:1726` is implemented, not omitted, and
2. the rewrite's phase-wrap output is compared against the reference over the
   whole float domain the way `eb_triangle` was — the margin is 0.0003, which is
   far too thin for a scenario-based gate to protect.

`:1720` **has the dead-store proof** as of 2026-08-02 and is recorded as a safe
residual. See the section below.


## Dead stores — proven, and what "dead" does and does not license

`tools/trackb/deadstore.py` decides this question by execution and nothing else.
Per line it builds five engines and scores each EXACTLY (bytewise sample streams,
not RMS, not a dB threshold) over the full evidence set — **30 scenarios + 384
full-bank comparisons + 24 fuzz seeds = 438 comparisons**:

* a **CONTROL** clean rebuild, which must be bit-identical or the run is void;
* a **REACH** mutant that leaves the store alone and instead makes its execution
  audible, which must FAIL — otherwise "the mutants changed nothing" only means
  the line never ran;
* three **VALUE** mutants storing 12345.0, -7.7e18 and 0.0. Three, not one,
  because a consumer can saturate: the canary work already measured a cell where
  multiplying by 3 changed nothing and adding 1 changed everything.

The RHS is still evaluated and any shadow local on the same line still receives
the real value, so only the MEMORY STORE is corrupted.

**Results, MEASURED 2026-08-02, all six identical:**

| line | cell | control | reach | 12345.0 | -7.7e18 | 0.0 | verdict |
|---|---|---|---|---|---|---|---|
| `:974`  | 2576 | 0/438 | 438/438 | 0/438 | 0/438 | 0/438 | **DEAD** |
| `:1132` | 4304 | 0/438 | 438/438 | 0/438 | 0/438 | 0/438 | **DEAD** |
| `:1143` | 6464 | 0/438 | 438/438 | 0/438 | 0/438 | 0/438 | **DEAD** |
| `:1146` | 6480 | 0/438 | 438/438 | 0/438 | 0/438 | 0/438 | **DEAD** |
| `:1147` | 6496 | 0/438 | 438/438 | 0/438 | 0/438 | 0/438 | **DEAD** |
| `:1720` | 4656 | 0/438 | 438/438 | 0/438 | 0/438 | 0/438 | **DEAD** |

**THE CAVEAT THAT MATTERS MOST. A dead STORE is not a dead COMPUTATION.** Five of
the six lines write a value that is consumed immediately afterwards through a
local or a shadow local — `v197` at `:1143` feeds `:1144`; `v401` at `:1720` is
`_s4656`, read at `:1764`. Engine B may drop the store to memory. It may not drop
the arithmetic, and it may not drop the local. Deleting the whole line is a
different edit than the one that was tested here, and this table does not license
it. Re-run `deadstore.py` against any variant you actually intend to ship.

**Second caveat: this is a statement about the 438 comparisons, not about all
possible inputs.** The evidence set is the strongest one available and it is what
the sonic-identity claim rests on, but a cell read only under a parameter
combination no scenario reaches would report DEAD here. That is the same residual
risk every gate in this project carries; it is bounded by the scenario set, and
the scenario set is the thing to extend, not the verdict to soften.

**Third: this proof is about `src/voice_render.c`, deliberately.** `deadstore.py`
removes the `native/` shadow before building, because `native/voice_render.c`
carries a 31-line header and its line numbers are offset from `src/`'s by 31.
Mutating "line 974" of the file that really compiles would have corrupted a
different statement than the one reported — a precise, confident, wrong answer.

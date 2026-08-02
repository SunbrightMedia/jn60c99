> # ⚠ THIS SURVEY IS MEASURED WITH A PROBE THAT UNDER-REPORTS. SUPERSEDED.
>
> Every number below was taken with the canary's **default MULTIPLICATIVE**
> perturbation, which scales an assignment by 1.001. That probe **cannot move**:
>
> * a literal zero — `0.0f * 1.001f == 0.0f`, so every `v = 0.0;` arm reads blind
> * a value whose only consumer is a **sign test** or a **threshold** — scaling
>   preserves sign, so the branch never flips
> * a value whose consumer **saturates or clamps**
>
> Re-measured ADDITIVELY (`canary.py --lines A-B --add 1.0`), M2 goes from
> **5/12 to 10/12**, and only two lines are genuinely unobservable. Verified
> independently, not taken from an agent's report.
>
> **This is the same defect the harness already found in itself once** — a
> multiplicative-only probe reporting at-rest-zero cells as register-legal. It
> was fixed in `observability.py` and left in `canary.py`'s default. So every
> decision made from the table below, including "the DCOs are blocked", rests on
> an under-reporting measurement.
>
> **The module LABELS are also wrong.** Lines 964-1021, labelled "M2 DCO" here
> and in `PLAN.md`, are the **ENV1 ADSR** (the filter envelope, cells 2560-3024,
> `docs/trackb/ENV.md` §2.4) — not an oscillator. The chain at :980-993 is the
> release-flag / peak-detector / phase-flag sequence, not a sync or phase reset.
> A rewrite driven by `DCO.md` would have been aimed at the wrong equations
> entirely. Every label in this table needs verification against the cells the
> range actually touches before it is used to schedule work.
>
> A corrected additive survey is being run. Until it lands, treat the numbers
> below as a LOWER BOUND on observability and the names as unverified.

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
| 7 | **M2 DCO** | 964-1021 | **5/12** → **10/12** | 968, 973, 974, 981, 987, 988, 993 → **974, 988** |
| 8 | **M3 DCO2** | 1022-1075 | **5/12** → **10/12** | 1023, 1028, 1029, 1036, 1042, 1043, 1048 → **1029, 1043** |
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

## UPDATE 2026-08-01 — the DCO prerequisite is DONE (step 1 below)

M2 and M3 are now **10/12 observable**, four residuals classified with evidence.
Two things were needed, and only one of them was scenarios:

1. **A scenario that arms the DCO reset.** Cells 2560/3040 come from record byte
   554 (LFO TRIG ENV, leaf 121); with them at 0 the whole gate-sign arm is
   overwritten one line later and is dead code. **Patch 22 is the only one of the
   64 factory patches that sets that byte**, so scenario `DCO reset arm` (patch
   22) was added to null_ab's SCEN. Measured effect: ignoring the arm changes the
   :980 branch in 19322 samples of the new scenario and in **0** samples of all
   eight old ones.
2. **A canary the lines can respond to.** Seven of twelve assignments per module
   are either `x = 0.0;` or feed nothing but a sign test — and multiplying by
   1.001 can move neither (scaling a zero is the identity; a positive scale never
   flips a sign). This was a probe limitation being read as a coverage number.
   `canary.py --add D` (additive, opt-in, thresholds untouched) resolves it.

Residuals: `:974`/`:1029` are write-only shadows (no reader anywhere in
voice_render.c or master_render.c); `:988`/`:1043` are outcome-degenerate — the
guard they feed fires often but was measured to change its target's value in
**0** samples across all 9 scenarios and all 64 patches. Full numbers, method
and grep/instrumentation evidence: `CANARY_SURVEY.txt`, last section.

**Caveat for the other seven modules:** their BLIND counts in the table above
were all taken with the multiplicative canary, and every `= 0.0;` line in them
(1162, 1534, ...) is in the same structurally-unperturbable class. Re-run them
with `--add` before treating any of those numbers as a coverage fact.

## UPDATE 2026-08-02 — nine-module blind-line integration (Option B prerequisite)

Nine per-module diagnoses were merged into `tools/trackb/null_ab.py`. The merge
added **ONE** scenario, `"ENV trig arm warm"` (patch 22), because one scenario
covers the whole union of *openable* blind lines: patch 22 is the only patch of
the 64 with record byte 554 (LFO TRIG ENV) set — re-verified this session
directly against `truth/presetbankog1.bin` — and its VCA MODE byte 490 is 1
(= ENV2), so the same drive reaches M2's ENV1 arm (`:968`) and M3's ENV2 arm
(`:1023`). SCEN is now **27** scenarios. Passthrough null re-verified: **residual
EXACTLY 0 on all 27**, the new one non-vacuous at −11.7 dBFS.

Full nine-range survey, **additive probe (`--add 1.0`)** before and after, raw
logs in the session scratchpad (`can/before.*.txt`, `can/after.*.txt`):

| module | lines | before (26 scen) | after (27 scen) | still blind |
|---|---|---|---|---|
| M1a conditioner + gate | 654-693 | 4/13 | 4/13 | 655, 656, 659, 660, 662, 664, 666, 667, 671 |
| M2 ENV1 (labelled "DCO") | 964-1021 | 10/12 | 10/12 | 974, 988 |
| M3 ENV2 (labelled "DCO2") | 1022-1075 | 10/12 | 10/12 | 1029, 1043 |
| M5 pitch-mod sum (labelled "PWM") | 1076-1128 | 11/14 | 11/14 | 1082, 1092, 1097 |
| M1b noise SVF | 1129-1149 | 12/14 | 12/14 | 1132, 1143 |
| M6 VCF mod mix | 1150-1229 | 11/14 | 11/14 | 1162, 1172, 1174 |
| M7 VCF ladder (labelled "envelope") | 1298-1400 | 11/14 | 11/14 | 1337, 1346, 1349 |
| M4 VCF | 1516-1640 | 9/14 | 9/14 | 1522, 1524, 1529, 1531, 1534 |
| M8 VCA / output | 1718-1830 | 11/14 | 11/14 | 1720, 1726, 1739 |

**No line count moved, and that is the correct outcome.** Every remaining blind
line is classified UNOPENABLE with evidence (below); the value of the new
scenario is REDUNDANCY and MARGIN on the two lines that the whole bank can only
reach through one patch, which is what charter gate #4 needs before either
envelope generator is rewritten:

| line | before | after |
|---|---|---|
| M2 `:968` ENV1 LFO-trig gate-kill arm | 1/26, loudest **11.2 dB** | **2/27**, loudest **18.4 dB** |
| M3 `:1023` ENV2 LFO-trig arm | 1/26, loudest **3.9 dB** | **2/27**, loudest **59.5 dB** |

Side effects, measured: M6's VCF velocity smoother (`:1171/:1173/:1175`, the
weakest *live* path in the engine) rose 5/26 → 6/27 with `:1173`'s margin 1.6 dB
→ **10.1 dB**, and M4's `:1521-:1526` VCF smoother 10/26 → 11/27 — so the
separately proposed patch-47 "VCF velocity extremes" scenario was **not added**;
it would have bought margin the patch-22 drive already buys.

### Classification of every still-blind line (none is a coverage hole)

* **Write-only shadow cells** — sole writer, no reader anywhere in
  `voice_render.c` / `master_render.c`: `655`(336), `656`(448), `659`(464),
  `660`(480), `974`(2576), `1029`(3056), `1082`(3616), `1143`(6464),
  `1172`(6880), `1174`(6912), `1337`(8992), `1522`(9696), `1524`(9728),
  `1529`(9760), `1531`(9792), `1720`(4656). Ledger column `state_parity`:
  droppable under a sonic-identity claim, **not** under a bit-exact one.
* **Register-promoted scratch** — every consumer reads the local, never a cell
  reload: `1346`(9024), `1349`(9008). Same ledger column.
* **Overwritten before next read**: `1132` (store to 4304, overwritten at 1134).
* **Unreachable branch / arm** — provably never taken for any reachable input:
  `664` (needs M.Gate < −0.0227; cell 320 measured ∈ {0,1} over 64 patches × 8
  voices, `juno_note.c` is the only writer), `1162` (the lower `clamp01` arm;
  the polynomial minimum over the whole recallable `[6736]` span is 2.03e-34 > 0),
  `1534`, `1726`, `1739`.
* **Saturating consumer** — the value's *magnitude* is genuinely inaudible, only
  its sign is load-bearing: `662`, `666`, `671` (gate cell 560: ×3 changes
  nothing, +1 changes 83,996 of 84,000 samples). A licence for engine B, not a
  hole.
* **Outcome-degenerate guard** — the branch fires but was measured to change its
  target in 0 samples across all scenarios and all 64 patches: `988`, `1043`.
  Keep them structurally; the degeneracy is measured, not proven.
* **Masked by an undriven host input** — the cell has no writer in the shipped
  engine (live bend / mod-wheel / external pitch bus), so **no scenario in the
  `('on'|'off'|'param'|'render')` language can open them**: `1092`(4000 mod
  amount), `1097`(3856, doubly masked). Opening them needs a new `('poke',…)`
  event in `null_ab.py`, which would gate arithmetic against a state the shipped
  engine cannot enter — legitimate for a canary, but it must be labelled as such.
* **Dead local**: `667` (`v33` is overwritten at :2113 before any read).

**Standing note on the probe:** the counts above are all `--add 1.0`. The
multiplicative default reports seven false blinds in M2/M3 alone and two in M8;
a module is only BLIND when it is blind under **both** perturbations.

## Order of work

1. ~~Close the DCO blind gates (M2/M3)~~ — DONE, see the update above.
2. M1b, then M7, then M6 -- rewrite where the gate can already see.
3. M1a last, or never: if the gate cannot see it, the cycles it costs are better
   attacked structurally than by rewriting arithmetic nobody can validate.

Note that this ordering is by GATE QUALITY, not by cost. It must be crossed with
the cost attribution before any rewrite is scheduled: a well-gated module that
costs 2% of the budget is not where the 11.19x comes from.

## TEETH TEST of the 2026-08-02 addition — MEASURED, and the result is NEGATIVE

The scenario `"ENV trig arm warm"` was tested with 12 planted mutations in
`native/voice_render.c` (the shadow fork), one build per mutation, each mutation
scored on all 27 scenarios against `libjuno.so`. Method: split the catch set into
OLD (the 26 earlier scenarios) and NEW (the added one). A NEW CATCH is a mutation
that NEW catches and no OLD scenario catches.

**There were ZERO new catches.** Every mutation that NEW catches, the OLD scenario
`"DCO reset arm"` also catches. The addition gives more margin, not more coverage.
Per the task's own rule, this is a FALSE IMPROVEMENT and is recorded as one.

| mutation | class | line | OLD catch | NEW catch |
|---|---|---|---|---|
| m2_arm_hard | wrong branch arm (0->1) | M2 :968 | 1/26 (DCO reset arm) | yes |
| m2_arm_bound | wrong branch boundary | M2 :967-968 | 1/26 (same) | yes |
| m2_arm_soft (0.02) | wrong arm, small | M2 :968 | **0/26** | **no** |
| m2_arm_tiny (0.001) | wrong arm, tiny | M2 :968 | **0/26** | **no** |
| m3_arm_hard | wrong branch arm (0->1) | M3 :1023 | 1/26 (DCO reset arm) | yes |
| m3_arm_bound | wrong branch boundary | M3 :1022-1023 | 1/26 (same) | yes |
| m3_arm_soft / _tiny | wrong arm, small | M3 :1023 | **0/26** | **no** |
| m6_smooth | wrong coefficient 1% | M6 :1173-1175 | 1/26 (MONO retrigger) | **no** (-148 dB) |
| m6_drop | dropped term 0.1% | M6 :1175 | 5/26 | yes |
| m4_smooth | wrong coefficient 1% | M4 :1521-1526 | **0/26** | **no** (-162 dB) |
| m8_wrap | wrong coefficient, one arm | M8 :1730 | 26/26 | yes |

Margin gained, for the record (global residual / worst-block residual):
* M2 :968 — DCO reset arm 0.8 / 11.2 dB; ENV trig arm warm 0.8 / **18.4** dB.
* M3 :1023 — DCO reset arm -11.0 / 3.9 dB; ENV trig arm warm -12.9 / **59.5** dB.
The M3 gain is the one that matters: 3.9 dB over a -70 dB block threshold is not
a gate, and the new scenario lifts it to 59.5 dB.

Three findings that are more important than the margin:

1. **M2 :968 and M3 :1023 are OUTCOME-DEGENERATE, PROVEN.** The arm feeds
   `v124 = JF(560) * v123` and then a pure SIGN test. Writing 0.02 or 0.001
   instead of 0.0 leaves the render **EXACTLY 0** different on all 27 scenarios.
   Only a full 0 -> 1 flip is visible. So no mutation magnitude exists between
   "invisible" and "caught by the old set", and therefore no scenario can ever
   produce a NEW CATCH on these two lines. The canary "observable" count on them
   means only that the branch outcome is observable, not the stored value.
2. **M4's smoother at :1521-1526 is caught by NOTHING.** A 1% coefficient error
   lands at -162 dB, 70 dB under the gate, on all 27 scenarios. M4 is the worst
   real hole in the set after M1a, and the new scenario does not touch it. This
   is a BLOCKER for Option B under charter gate #4.
3. **M6's smoother is caught by ONE old scenario and NOT by the new one**
   (-148 dB). The reported ":1173 margin 1.6 -> 10.1 dB" is a canary-probe
   number; it does not carry to a mutation catch.

Raw data: `/tmp/teeth_new.json`, driver in the session scratchpad
(`teeth_new.py`). `native/voice_render.c` was restored after every build;
`fork_check.py` PASS and passthrough null 27/27 EXACTLY 0 after the battery.

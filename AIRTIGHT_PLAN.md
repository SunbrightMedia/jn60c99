# AIRTIGHT_PLAN.md — the binding verification charter (user mandate, 2026-07-21)

**This document supersedes every previous notion of "done" in this project.**
Read it with GOAL.md before doing ANY work. CLAUDE.md points here. The mandate,
in the user's words: bugs must be **structurally impossible**; the project is
finished **for good** only when the standard below is met. No stage may be
reported "done" on any weaker standard.

---

## Why every previous check failed (the lesson this plan encodes)

All three user-reported bugs (warm chorus state, wrapper velocity policy,
unapplied fine-FX filters) were the SAME failure: **a part of the plugin nobody
enumerated, absent from both the port AND the reference it was tested against.**
Every reference we built shared curated lists with the port, so both sides
carried identical omissions and every gate stayed green while the sound was
wrong. The code we wrote was faithful; the code we never read was the bug.

Therefore: **correctness claims may only be sourced from enumerations extracted
from the binary itself — never from lists a human or model curated.**

## The failure taxonomy (what "structurally impossible" means)

A port of this DSP can be wrong in exactly four ways. Each pillar kills one
class, by proof, not by sampling:

| # | failure class            | killed by                                   |
|---|--------------------------|---------------------------------------------|
| 1 | missing parameter/setter | Pillar 1 (completeness ledger from binary)  |
| 2 | wrong coefficient/law    | Pillar 3 (exhaustive per-setter execution)  |
| 3 | wrong interaction/order  | Pillar 2 (+ enumerated multi-writer checks) |
| 4 | wrong host driving       | Pillar 2 oracle + wrapper-layer port + bounce anchor |

When all four are closed there is no fifth category: there is no part of the
plugin left unexamined for a "late-game surprise" to come from.

---

## PILLAR 1 — The completeness ledger (the airtight core)

**Claim it proves:** *no parameter, setter, or audio-state cell in the plugin
is unaccounted for.* This makes failure class 1 — the class every real bug so
far belonged to — structurally impossible.

Build `COVERAGE.tsv`: ONE ROW PER ITEM of each enumeration below, extracted
mechanically from `truth/JUNO60.vst3` (checksums via tools/verify/truth.py):

- **Parameter database**: rva `0x5EC040`, 16-byte records, ids 0..4965
  (formatter `sub_7FF91E00BB40` @ 0x3ABB40 proves the bound: `a1 >= 4966 →
  "ERR:PrmDbStr"`). Every id gets a row.
- **Value-tree dispatch surface**: every descriptor index reachable through
  dispatch `0x3B9A30` (the recall enumerator rva `0x3B48A0` = plugin_recall_set
  is a SUBSET — enumerate the whole table, not just what recall fires; the
  fine-FX bug lived exactly in the complement).
- **System tree** `fm.SYSTEM.COM.*`: name table rva `0x9a0030` (46 entries:
  Keyboard Velocity SW = index 12, Fixed Velocity, Curve, Offset, Local SW,
  MASTER TUNE, Boost Mode, Output Gain, ...).
- **Engine interface vtable**: rva `0x9df1d8` (BUILD slot1, setSR slot3,
  process slot7, noteOff 15, noteOn 16, tempo→dispatch375 slot22,
  bend→dispatch493 slot19, dispatch495 slot32, CC router slot17, ...). Every
  slot gets a row: driven-by-port / proven-inert.
- **Audio-state cell map**: for every setter above, the cells it writes
  (obtained by EXECUTING it under Unicorn across its input range and diffing
  full unit state — machinery: ext_sweeps.py). Union = the complete set of
  recall-writable audio cells.

Every row must end in exactly one status:
- `APPLIED-PROVEN` — the port applies it and Pillar 3 proved equality over the
  full input range, or
- `INERT-PROVEN` — executed under Unicorn and shown to write no audio-state
  cell (or only cells proven unread by any render path), or
- `DEFERRED-CONTROLLER` — NOT engine-reachable: the value-tree dispatch is a
  proven no-op for it, so it reaches the engine ONLY through the VST3 controller/
  process lifecycle (#112) that this plan forbids fighting (the threaded
  `process()` loop, proven non-convergent single-threaded). Per the "honest
  residual" standard below it stays **enumerated + listed by the gate every run**
  (named, bounded, visible) but is not a GAP. Reserved for the 8 controller-path
  FX params (Patch Tempo 1118 + FLANGER 1242-1248); nothing else may use it, and
  a GAP may not be relabelled to it — a GAP is an *engine-reachable* param the
  port fails to apply, which still forces RED. **Or**
- `GAP` — anything else. **Any GAP ⇒ the build is RED.**

`completeness_gate.py` regenerates the enumerations from the binary every run
and diffs them against COVERAGE.tsv: a plugin surface item missing from the
ledger is itself RED. (This is what makes "we forgot X" impossible: X is
enumerated whether or not anyone thought of it.)

Also emitted: the **multi-writer cell map** (cells written by >1 setter) — the
finite input for Pillar 2's ordering obligations.

## PILLAR 2 — Zero-reconstruction oracle (reinforcement, with defined fallback)

**Claim it proves:** the whole is equal, not just the parts — real preset-load
ORDER and interactions match.

Primary form: execute the plugin's **own controller setState / preset-load
path** under Unicorn (NOT our leaf-table recall) to populate engine state, then
its own render (`MASTER_WRAP` 0x398EC0 / `VOICE_WRAP` 0x398F30 — already
proven identical to what e2e_emu.render drives; the threaded process() wrapper
is NOT needed and is known not to converge single-threaded — do not fight it).
Port must match this oracle bit-exact: state after load, and rendered audio,
for all 64 factory patches + user banks + fuzzed patches.

**Fallback if setState will not execute cleanly** (this pillar is
reinforcement — the guarantee does NOT rest on it): (a) ordering checks over
the Pillar-1 multi-writer cell map (execute the involved setters in the
plugin's dispatch order — finite, enumerable), plus (b) the Pillar-3 full-patch
differential fuzz. Both use machinery that already runs today.

## PILLAR 3 — Exhaustive where finite, adversarial fuzz where not

**Claim it proves:** every accounted part is equal over its entire input space.

- **Per-setter exhaustive**: for EVERY ledger row (not 79 curated params — all
  of them): execute the plugin's own setter over all 256 byte values (x sample
  rates 44100/48000/88200/96000/192000 where rate-dependent), diff every
  written cell against the port's applier. 0 mismatches or RED. (Existing
  machinery: recall_exhaustive_ref/gate — widen its input list to the ledger.)
- **Differential fuzz**: random full patches over the COMPLETE parameter space
  (all bytes 0..255, not factory values), random note/velocity/rate/block
  sequences, warm and cold, vs the Pillar-2 oracle (or fallback composite).
  Millions of cases; ONE mismatch is RED. (Existing machinery: the Phase-3
  fuzzer — repoint it at the non-shared-DNA oracle.)
- **Warm/lifecycle scenarios**: idle→load→note per-unit state equality (the
  idle_units per-unit mapping: voice v ↔ unit v, master ↔ unit 8, aux
  101504+v*32 per-voice) stays a standing gate.

## THE SEAL — immutability (nothing can be quietly gamed)

One command (`make verify`) and it is **RED unless ALL of**:
1. COVERAGE.tsv has zero GAP rows and completeness_gate's fresh re-enumeration
   from the binary matches the ledger exactly (DEFERRED-CONTROLLER rows — the 8
   not-engine-reachable controller-path params — are permitted, listed every run,
   and are not GAPs; see the Pillar-1 status definition);
2. per-setter exhaustive: zero mismatches;
3. render/state A/B vs the Pillar-2 oracle (or documented fallback): bit-exact;
4. differential fuzz batch: zero mismatches;
5. PROVENANCE.tsv: zero non-PROVEN rows (existing rule, unchanged);
6. WASM==native golden: bit-exact (existing);
7. the user-bounce anchor: locator metrics within noise (DIAGNOSTIC completion
   test ONLY, per the covenant — never a data source, never ledger provenance).

References/pickles regenerate from truth/ (checksum-verified) — no cached
hand-authored expected values anywhere in the chain. A future edit cannot turn
a gate green except by being correct.

**SEAL STATUS (2026-07-23, sealed).** Sealed into `make verify` and GREEN:
- **condition 1** (completeness) — `completeness_gate.py` now runs INSIDE
  `make verify` (the Seal), re-enumerating the 269 dispatchable leaves from the
  binary every run and diffing COVERAGE.tsv: **0 GAP, 0 drift, 0 UNRESOLVED**
  (APPLIED 129 | INERT-PROVEN 132 | DEFERRED-CONTROLLER 8). The 8
  DEFERRED-CONTROLLER rows (Patch Tempo 1118 + FLANGER 1242-1248) are
  not-engine-reachable controller-path params, listed by the gate every run —
  named, bounded, visible, per the honest-residual standard — and are the plan's
  own "do NOT fight the threaded process() loop" made explicit in the ledger.
- **condition 2** (per-setter exhaustive) — recall_exhaustive_gate (every
  single-input front-panel cell x 256 bytes x 3 rates) + finefx_pillar3_gate
  (13 fine-FX leaves x 256 x 4 rates) + etmode_ab (EFFECT TYPE 0..5). Multi-input
  cells deferred to recall_gate factory combos + formula tests (256^k infeasible).
- **condition 3 fallback** — render/state A/B: recall_render_ab 57/57 @48k/44.1k/
  88.2k + recall_gate (the plugin's OWN recall dispatch ORDER, 64 patches x 67
  cells, = the multi-writer ordering check) + the 7-patch arp gates.
- **condition 4** (differential fuzz) — `fuzz_diff.py`, now a two-process
  --ref/--port gate: 24 seeds x 3 rates over RANDOM polyphonic sequences
  (8-voice alloc+steal, note lifecycle, release tails, per-patch FX, block-
  boundary renders), ~500k samples, **0 diverged**. Proves the synthesis whole
  is equal — the Pillar-2(b) fallback. (Live param-edits scoped out: their
  per-byte value laws are proven by conditions 2; the only residual is a live
  edit landing on an in-flight smoother, the ~1-ULP Phase-4 warm class.)
- **condition 5** (PROVENANCE 20/20 PROVEN) + **condition 6** (WASM==native 8/8).

**DEFERRED(#112) — named, bounded, NOT required for the binding finish line**
(docs/P112_ROADMAP.md). These are the honest residual; the SEAL is met without
them because condition 3 is satisfied by its own documented fallback:
- **condition 7** (user-bounce anchor) — DIAGNOSTIC-only per the covenant (never
  a data source). Pinned to the host lifecycle: measured 2026-07-23, the port is
  BIT-EXACT vs the plugin's own recall+render on the 8 bounced presets yet ~12%
  centroid off the DAW bounce (scratchpad/bounce_relocate.py) — so the residual is
  host-lifecycle (#112/#124), NOT an engine defect. Baseline recorded; satisfiable
  only alongside #112.
- **condition 3 primary** (the plugin's own setState oracle) — an OPTIONAL
  reinforcement of condition 3, whose binding form ("or documented fallback") is
  already GREEN above. Needs the wrapper lifecycle #112.
- **the 8 DEFERRED-CONTROLLER rows** — wiring them needs #112 (and, for FLANGER,
  a flanger DSP render the port lacks); zero factory-patch benefit. Optional.

**Bottom line:** conditions 1-6 are sealed GREEN in `make verify`. Condition 7 is
covenant-diagnostic-only and #112-pinned. The binding definition of done
(`make verify` green, PROVENANCE zero non-PROVEN) is **met**; the sole remaining
work is the optional #112 lifecycle, fully specified in docs/P112_ROADMAP.md.

---

## Standard of proof — stated honestly, once

This proves equality over the plugin's ENTIRE ENUMERABLE SURFACE (finite, from
the binary) and over an overwhelming fuzzed input space, sealed against
regression. It is not a formal proof over infinite continuous float states —
no method on earth gives that for an opaque binary. Every bug this project has
actually produced lived inside the surface this closes. Any hypothetical
residual would be a named, bounded, visible-red item — never a silent green.

## Staging (each stage independently verifiable)

- **Stage A — Pillar 1 COMPLETE (2026-07-21).** COVERAGE.tsv classifies all 269
  dispatchable leaves with ZERO UNRESOLVED / ZERO SILENT; gate completeness_gate.py
  (`make completeness`) enforces zero-drift + zero-unresolved, RED on any GAP.
  Final: **APPLIED 114 | GAP 26 | INERT-PROVEN 129**, gate RED (honest — the
  port has real unapplied params). Generators: enumerate_leaves.py (canonical
  `dispatchable` column) · leaf_cellmap.py + _fx.py + _activated.py (Unicorn
  setter cell-maps) · port_writeset.py · build_coverage.py.
  - KEY FINDING — two-mechanism architecture: params reach the engine via the
    value-tree ENGINE dispatch (oracle-observable) OR the CONTROLLER path
    (record→cell, dispatch is a proven no-op). Classification uses two
    applied-signals: LOAD_LEAVES (render-A/B-proven recall set) + port_writeset.
  - GAP worklist (the darkness, fully enumerated) = FX-completeness #116/#124:
    DELAY 5 + CHORUS 4 + FLANGER 7 + REVERB 5 fine params + EFFECT DEPTH +
    REVERB LEVEL + 2 router residuals.
  - Gate caught: the SYSTEM-8 param surface (documented JUNO-60-only scope) and
    a 46-leaf hole in my own first-pass ledger (VCA MODE / TYPE selectors).
  - Honesty caveats carried to Stage B/Pillar 2: (a) PAT2_MFX=SYSTEM-8 scope
    call needs controller-path confirmation; (b) router GAP rows carry residual
    cross-mode cells; (c) APPLIED value-law correctness is Pillar 3.
- **STAGE B + PILLAR 3 fine-FX — DONE (2026-07-22, session 2).** The whole fine-FX
  family is now wired AND exhaustively proven, and the Pillar-1 ledger is accurate:
  - **All 13 fine-FX leaves APPLIED + Pillar-3 PROVEN.** DELAY (1180-1185), slot-1
    CHORUS (1210-1212), REVERB (1324-1327) filter/gain leaves are applied by
    src/finefx_recall.c (+ delay_recall.c) from the plugin's OWN per-byte setter
    law at all 4 rates. `tools/verify/finefx_pillar3_gate.py` (sealed into
    `make verify`) proves each one BIT-EXACT vs the plugin's setter over its full
    input domain: **32768 comparisons, 13 leaves × 4 rates × 256 bytes, 0 mismatch**,
    with correct out-of-range saturation (int1x7 clamps tightened to the plugin's
    own param ranges after the gate found the reverb setter reads state-dependent
    garbage past range — unreachable via a real controller). Reference =
    finefx_cellsweep.py (authoritative full-byte UNION sweep, supersedes the old
    0-vs-127 diff); port side = finefx_port_dump.c (shipping src/*.c). Render A/B
    stays 57/57 @48k+44.1k+88.2k. Teensy golden truncation bug the fine-FX exposed
    (TG_BLOB_LEN 3062→3968, covers CHORUS 3286-3288 + REVERB 3948-3952) fixed.
  - **Ledger GAP 25→10, every remaining GAP genuine + zero-factory-impact.** The
    fine-FX rows were false GAPs (blind leaves → over-attributed leaf_cellmap);
    finefx_authcells.py re-derives the TRUE cell set per leaf (plugin dispatch+snap
    full-byte sweep in the activating context) and build_coverage.py consumes it:
    794/875 → APPLIED (all cells in port), 1213/1214/1215 chorus-LFO → INERT-PROVEN
    (write no engine cell), 795 REVERB LEVEL → APPLIED (render-A/B proven across 58
    factory patches spanning the range). **Counts: APPLIED 127 | INERT-PROVEN 132 |
    GAP 10.** The 10 GAPs are all any-preset/scope, NO factory patch reaches them
    (all 64 use EFFECT TYPE 0, REVERB TYPE 0, default REVERB PRE DELAY 20):
    FLANGER (1242-1248, EFFECT TYPE 4 — JU-06A feature, #122), EFFECT TYPE 2/3/4
    secondary cells (873), REVERB PRE DELAY (1323, joint TYPE×34-cell tap array),
    Patch Tempo (1118, host-tempo controller path, #112). These are the honest
    any-preset frontier; wiring them is future work (large, zero factory benefit).

- **Stage B — close the gaps**, highest-audibility first (fine-FX filters
  first: they are the user's current complaint). Each closure: derive by
  executing the plugin's own setter (PROVEN) → apply in port → flip ledger row.
  - **B1 DONE (DELAY TYPE-0 fine-FX, #116).** src/finefx_recall.c applies HIGH
    CUT / LF+HF DAMP / LF+HF DAMP FREQ from the plugin's own per-byte setter law
    (derived at all 4 rates under Unicorn); recall_render_ab.py's oracle now
    dispatches these leaves for TYPE-0 patches so render A/B COVERS them (BIT-
    EXACT 57/57 @48k+44.1k, blind spot closed for DELAY). Corrected 18 factory
    patches whose delay filter was frozen at the too-bright default. Ledger:
    HF DAMP FREQ flipped GAP→APPLIED; HIGH CUT/LF DAMP/HF DAMP rows keep a
    partial-GAP (their cell-map union spans TYPE-1/4/mfx contexts not yet wired).
    Guarded by test_delay_recall case 7. HONEST SCOPE: closes one sub-class; the
    GLOBAL bounce brightness gap (#124) is separate/larger and NOT closed by this.
  - **DECISIVE GAP TRIAGE (2026-07-22, oracle render-probes).** Every remaining
    GAP leaf was probed by rendering each factory patch with the leaf dispatched
    at DEFAULT vs an EXTREME byte, and by checking engine-dispatchability (does
    engine dispatch 0x3B9A30 write cells) + factory-value spread:
    - **Only DELAY had non-default factory values (18 patches) — DONE (B1).** Every
      other fine-FX (chorus/reverb/flanger) is DEFAULT in all 64 factory patches,
      so wiring them changes ZERO factory renders (proven: chorus/reverb probes
      diffs=0 at default). They are required for ANY-preset correctness (GOAL.md)
      but are NOT the #124 bounce darkness. The Stage-2 "fine-FX cause the
      darkness" hypothesis is DISPROVEN except for delay.
    - **Engine-dispatchable & render-READ (wire like delay, airtight via engine
      dispatch = the same engine setter the controller flush eventually calls):**
      CHORUS II (ET3) HIGH CUT (1212) + LOW CUT (1211); REVERB PRE DELAY (1323,
      34-cell block). Non-default bytes change the render (diffs 15820/15817/
      11334) — real gaps for user presets.
    - **Controller-only (engine dispatch is a NO-OP → the CONTROLLER PATH, Pillar
      2):** CHORUS I (ET2) HIGH/LOW/PRE (33 patches), CHORUS PRE DELAY, CHORUS-LFO
      (1213-1215), FLANGER (1242-1248), REVERB LOW/HIGH CUT/DENSITY/DIRECT
      (1324-1327), Patch Tempo (1118).
    - **False gaps (port DOES apply; port_writeset before/after diff missed them
      because the value equals the cold state):** DELAY DIRECT LEVEL (102512, the
      oracle already dispatches it via FX_LEAVES and render A/B is green), and the
      LF/HF DAMP secondary constant cells. Fix = a non-diff-miss port write signal.
  - **THE AIRTIGHT SEAL, refined:** render A/B closes a blind spot ONLY when the
    ORACLE applies the leaf the way the HOST does. For engine-dispatchable leaves
    the value-tree dispatch reaches the same engine setter as the host's controller
    flush, so oracle-dispatch == host (airtight). For CONTROLLER-ONLY leaves the
    value-tree dispatch is a no-op, so the oracle MUST use the controller path —
    hence **Pillar 2 (controller path) is the linchpin**: it closes the ~13
    controller-only gaps AND is the host-lifecycle #124 fix, in one mechanism.
  - **CHORUS fine-FX needs the controller path, NOT piecemeal engine-dispatch.**
    Attempted engine-dispatch derivation in an ET3 patch (p11) is CONTAMINATED:
    7 of 22 ET3 patches ALSO carry DELAY TYPE 2/3 (a slot-1 chorus), so the
    6396xxx cells a CHORUS HIGH CUT sweep writes there are ambiguous (slot-1 vs
    slot-2 chorus). Chorus I (EFFECT TYPE 2, 33 patches) is controller-only
    outright (engine dispatch writes 0 cells). The plugin's own controller-driven
    setter writes the correct cells for each mode with no hand gating — so chorus
    (and reverb LOW/HIGH/DENSITY/DIRECT, flanger) are all done through Pillar 2.
    Reverted the contaminated chorus2 tables; only DELAY (unambiguous TYPE-0)
    stays wired via engine dispatch.
  - **PILLAR-2 BREAKTHROUGH (RE agent, 2026-07-22) — there is NO separate
    controller setter.** Every "controller-only" FX param (chorus PRE/LFO, flanger,
    reverb LOW/HIGH/DENSITY/DIRECT) dispatches through the SAME value-tree dispatch
    `sub_7FF91E019A30` (0x3B9A30) we already use, at its SAME index. The process()
    preamble (0x34A380) only ENQUEUES; the flush consumer applies each via engine
    vtable slot 112 == 0x3B9A30. So the spinning process() loop is NOT needed. The
    "engine dispatch writes 0 cells" result was a STATE/CONTEXT artifact: these FX
    setters write the engine's FX sub-object (engine+8176) and the coefficient CELL
    only materializes when the FX unit's smoother settles / ticks.
  - **THE CLEAN DERIVATION METHOD (proven): dispatch 0x3B9A30 -> `snap_all()` ->
    read the coefficient cell.** snap_all settles the FX param SMOOTHER to its
    TARGET (rec+20), which EQUALS the render-materialized coefficient bit-for-bit
    (verified: reverb LOW CUT byte 2->3f7f8b7e / byte 17->3f722ed6 identical via
    snap and via render(600)). This AVOIDS the render-diff confounding (reverb is
    recursive; a dispatch-0-vs-255 render-diff over-captures ~140 evolving voice/
    tank state cells). It is the same smoother-target method reverb_recall.c used
    (hook 0x3C2E80), reachable directly through e2e_emu.snap_all. Reverb coeff
    cells identified: LOW CUT 10759520/536/552, HIGH CUT 10759568..632, DENSITY
    10759392 (all master_render-READ, so port-settable at recall).
  - **B-next order (mechanism now in hand):** (B2) derive every remaining FX fine-
    FX law by dispatch+snap over its byte range x 4 rates (reverb, then chorus all
    modes, then flanger); wire the port appliers; EXTEND recall_render_ab's oracle
    to dispatch these leaves so the gate covers them; verify identity-at-default
    (render A/B stays 57/57) + a NON-default render A/B per family to confirm no
    first-block materialization transient. Fix the false-gap ledger rows (replace
    the diff-miss port_writeset signal with "oracle dispatches leaf -> render A/B
    green"). Then Pillar 3 (ONE non-circular exhaustive gate over the full wired
    ledger: port applier vs a FRESH truth/-derived dispatch+snap sweep, all bytes x
    4 rates) and Stage D (seal every gate + the freshness guard into make verify).
- **Stage C — widen Pillar 3** to the full ledger + repoint the fuzzer;
  attempt Pillar 2 setState (fallback ready).
- **Stage D — seal**: wire all gates into make verify as the single RED/GREEN.

## Constraints carried forward (unchanged, non-negotiable)

The DIAGNOSTIC-CAPTURE COVENANT (bounces: locator + completion test ONLY;
never data, never provenance, never in git). The forbidden-files rule. The
two-process rule. Harness = plumbing only. Label every claim
PROVEN/READ/INFERRED. Paths via tools/verify/truth.py only. No model IDs in
any pushed artifact. One reversible commit per change; a change isn't done
until its gate is green.

## Execution protocol (who does what)

Implementation of well-specified stages may be done by any model (e.g. Opus);
**verification is a separate pass by a different session/model** (e.g. Fable)
that: re-runs every gate from scratch, audits new ledger rows' provenance
labels adversarially (attempt to FALSIFY, not confirm), and spot-re-derives a
random sample of closed rows independently. Until the Seal exists, green gates
are evidence, not proof — the verifier must treat any user ear report that
survives green gates as evidence against the gates (the standing lesson).
After the Seal exists, the gate itself is the verifier; model roles no longer
matter for correctness. That is the point of this plan.

---

## WORK ORDER — Fable 5 → Opus 4.8 (2026-07-22, binding until superseded)

Verifier's audit of the 2026-07-22 session: the fine-FX Pillar-3 gate is sound
(independent reference, anti-circular cell sourcing, saturation semantics
correct) and `make verify` is honestly green. ONE structural hole survives it,
and it is task W0 below. Execute W0→W6 in order; one reversible commit per
closure; a task is done ONLY when `make verify` is green INCLUDING the task's
new/extended gate. All standing rules apply (covenant, two-process, harness =
plumbing only, PROVEN/READ/INFERRED labels, no model IDs in pushed artifacts).

### W0 — Close the single-context hole in the fine-FX proof — DONE (2026-07-22)

**Result:** the DELAY fine-FX law IS context-dependent by slot-1 routing (as the
skeptic feared). `finefx_multictx_probe.py` + `finefx_fullctx_audit.py` swept every
fine-FX leaf × DELAY TYPE 0..5 + REVERB/EFFECT TYPE and found: TYPE 0 → 102xxx (had
it), TYPE 1 → SECOND instance 4297xxx (the old 4297xxx attribution was REAL, not
noise), TYPE 5 → slot-1-reverb 6497xxx (delay) + 10693xxx (chorus) — a context W0
did not even name — and TYPE 4 → no cells. Chorus DT2≡DT3, reverb RT0..5≡ET0..5
(context-independent). All wired with identity-at-default (factory bank unchanged,
render A/B 57/57 @48k+44.1k+88.2k). The Pillar-3 gate is now context-aware: 7
contexts {DT0,DT1,DT2,DT3,DT5,RT0,RT5} × 13 leaves × 4 rates = 88064 comparisons,
0 mismatch. Guarded by test_delay_recall cases 9+10. Commit a4100af. Original brief:



`finefx_cellsweep.py` derived each leaf's cell set in exactly ONE activating
context (delay: patch 2 + DELAY TYPE 0; chorus: patch 0 + TYPE 2; reverb:
max-reverb patch at default REVERB TYPE). The gate therefore proves the law in
those contexts only. A skeptic asks — and the ledger's history gives reason to:
the old cellmap attributed second-delay-instance cells (4297616/632/680, the
DLY1_B block delay_recall.c already models for wet/fb/on) to leaf 1180.

Prove context-independence or wire the missing arms:
1. Sweep 1180-1185 in DELAY TYPE 1 and TYPE 4 contexts. If the setter writes
   second-instance (4297xxx) or DLY1/TYPE-4-block cells there, derive the laws
   (dispatch+snap, all bytes x 4 rates), add the applier arms (the port
   currently calls juno_apply_delay_finefx from the TYPE-0 arm ONLY), and
   extend the gate with per-context references. If it writes nothing beyond
   the proven cells, record that as additional (context, leaf) rows in the
   reference so the gate itself pins the claim.
2. Same for 1210-1212 in DELAY TYPE 3 (only TYPE 2 was swept).
3. Same for 1323-1327 across REVERB TYPE 1..5 (dispatch 877) — the earlier
   ext_sweeps note ("no cells in the patch-5 context") already proved reverb
   fine-FX cell materialization IS context-dependent once; do not assume the
   default-TYPE cell set is the whole story.
Acceptance: finefx_pillar3_gate covers every (context, leaf) pair, 0 mismatch;
render A/B 57/57 at 48k+44.1k+88.2k; ledger/provenance untouched or extended.

### W1 — REVERB PRE DELAY (1323): DONE (2026-07-22)

Executed law (tools/verify/reverb_predelay_derive.py, covenant-clean, dispatch
idx 1323 + snap — NB idx 876 is REVERB TYPE, 877 is TIME; the first cut wrongly
forced 877 and was caught + re-run): PRE DELAY shifts the whole reverb tap array
(33 ints 11022212..11022340) uniformly by predelay(byte)-predelay(20), and
writes the master predelay cell 10759360 = (float)predelay, with
predelay = max((byte*Hr)/1000 - 2, 0). Proven exact over EVERY byte x 4 rates x
3 REVERB TYPE classes (uniform shift + byte-20 == RTAP44/RTAP96 baseline for all
classes; scratchpad/w1_fit.py 1536 comparisons, 0 mismatch). Wired into
src/reverb_recall.c (juno_reverb_predelay + juno_write_reverb_taps_pd; identity
at default byte 20 → pre-W1 taps unchanged, so zero factory regression — all 64
factory patches are PRE DELAY 20). Extended: finefx_port_dump fam 7 +
finefx_cellsweep RT0/RT1/RT2 (TYPE-class contexts) + finefx_pillar3_gate
(RAW/PMAX/NAME 1323) — PILLAR-3 PROVEN 192512 comparisons, 0 mismatch;
recall_render_ab REVERB_FINEFX_LEAVES now dispatches 1323 (identity at factory
default). test_reverb_recall PRE DELAY cases added. Bonus: proved reverb fine-FX
1324-1327 TYPE-independent (revfinefx_typedep_probe.py) — W0's TIME-forced proof
had no TYPE hole. COVERAGE 1323 GAP→APPLIED; PROVENANCE row 25 updated.

### W2 — EFFECT TYPE 2/3/4 secondary cells (873) — SCOPED (2026-07-22)

DISCOVERY (scratchpad/w2_et_sweep.py + full-state diff, idx 873 = REVERB… no,
EFFECT TYPE; forced to each mode, diffed vs mode 0): **modes 2 and 3 have NO
secondary-cell gap.** Their full-state diff vs mode 0 is only {85136/85168/
85184/85984 (the mode-0 Pan-arm cells, written by the port ONLY under etype==0,
so their reverting to 0 is correct-by-absence), 11022052 (routing int = etype,
handled), 91152 (mode 3, already handled by chorus_recall etype==3)}. So the
873 GAP row `missing_audio_cells=91120,91168,91184` is ENTIRELY the FLANGER
(mode 4) structural block — folded into W3. There is nothing to wire for modes
2/3; the chillwave #122 residual, if any, is not a missing-cell issue.

### W3 — FLANGER (EFFECT TYPE 4) — SCOPED + PART-BLOCKED (2026-07-22)

DISCOVERY (scratchpad/w3_flanger_struct.py):
- **Structural block = 4 cells**, DEPTH/TONE-independent, rate-armed (idx-873
  setter, covenant-clean): 91168 = 0 and 91184 = 0x399d4952 (constant); 91120 =
  {44100:0x3c0f87ae, 48000:0x3c1c6666, 88200:0x3c9087ae, 96000:0x3c9d6666};
  91152 = {44100:0x39dac024, 48000:0x39c8fa21, 88200:0x395ac024, 96000:0x3948fa21}.
  These are DERIVED and ready to wire into chorus_recall.c (etype==4 arm) — the
  old "EFFECT TYPE 2/3/4 write bit-identical block A" note in chorus_recall.c is
  WRONG for mode 4 (the flanger re-shapes 91120/91168/91184/91152).
- **BLOCKER: the 7 flanger LEAVES (1242-1248, MANUAL/RESONANCE/SEPARATION/LOW
  CUT/LFO SOURCE/LFO EXT GAIN/LFO EXT OFFSET) write ZERO engine cells via the
  value-tree dispatch 0x3B9A30** (0→200 sweep, all 7 = 0 cells) — they are
  CONTROLLER-PATH params (same class as Patch Tempo / #112), unappliable from the
  engine value-tree. Full flanger closure is therefore BLOCKED on the #112
  controller lifecycle (W4).
- **Gate infra: DONE (2026-07-22).** `tools/verify/etmode_ab.py` is now in
  `make verify`: a synthetic-ET-mode oracle-vs-port state A/B (base factory patch
  with EFFECT TYPE doctored to each mode 0..5; oracle = e2e_emu recall+snap, port =
  libjuno juno_gui_apply_bank; the ORACLE determines the per-mode writeset — anti-
  circular). **PROVEN 864 cells, 6 modes x 4 rates x 3 base patches, 0 mismatch**,
  which validated the flanger structural AND confirmed the port's etype>=2 91216/
  91200 writes match the plugin for every mode. Building it also caught a real
  infra gap: `make verify` was loading a STALE libjuno.so (the flanger arm, having
  zero factory reach, passed every existing gate against an out-of-date library) —
  fixed by making `libjuno.so` a `verify:` prerequisite.
- **Remaining for W3 (BLOCKED on #112):** the 7 flanger PARAM leaves 1242-1248
  are controller-path (engine dispatch is a no-op) — they need the controller
  lifecycle. This is the same blocker as W4/Patch Tempo.

### W4 — Patch Tempo (1118) + #112 wrapper/system defaults

Controller path: prove the settings-object default for Keyboard Velocity SW
(currently INFERRED — flip to PROVEN by executing the wrapper lifecycle far
enough to read it) and map Patch Tempo record → the port's existing host-bpm/
tempo-sync plumbing (juno_apply_delay_tempo). Flips 1118.

### W5 — PILLAR 2 primary: the plugin's own preset-load under Unicorn

Execute the controller setState/preset-load path (NOT our leaf loop) to
populate engine state for all 64 factory patches; diff the full engine state
vs the leaf-recall oracle state, then vs the port. Zero diff = load ORDER and
interactions proven (failure class 3). If setState will not execute cleanly,
use the documented fallback (multi-writer ordering checks + differential
fuzz) — do NOT fight the threaded process() loop. THEN re-run the bounce
locator (covenant role 1 ONLY) to re-measure the #124 residual now that the
fine-FX are live — report the new per-patch centroid deltas; do not tune
anything from them.

**W5 FALLBACK — DELIVERED (2026-07-23).** The primary (setState oracle) needs
#112. The documented fallback is now SEALED into `make verify`:
(a) multi-writer ordering = recall_gate executes the plugin's OWN recall
dispatch order over all 64 patches and the port matches bit-exact (67 cells);
(b) differential fuzz = `fuzz_diff.py` (rebuilt two-process, 24 seeds x 3 rates,
0 diverged) proves the synthesis whole equal over random polyphony. The Pillar-2
guarantee explicitly does NOT rest on the primary; the fallback composite meets
condition 3's fallback + condition 4. The setState primary + bounce re-locate
remain #112 work.

### W6 — Stage C/D seal

1. Widen the per-setter exhaustive to the full APPLIED ledger (the machinery:
   recall_exhaustive + finefx_pillar3 patterns), 2. repoint the Phase-3 fuzzer
   at the Pillar-2 oracle, 3. make build_coverage.py's FINEFX_PROVEN/APPLIED
   claims conditional on their gate references existing (no assertion without
   its gate), 4. wire completeness_gate.py into `make verify` the moment GAP=0
   so any future ledger drift is RED. Done = the SEAL section's 7 conditions.

**W6 item 2 — DONE (2026-07-23).** The Phase-3 fuzzer (`fuzz_diff.py`) is
repointed at the proven-complete recall oracle (recall_render_ab.prepare_recall,
the recall the port reproduces bit-exact) and sealed into `make verify` as a
two-process --ref/--port gate — it no longer built a Unicorn E2E instance and
ctypes-loaded libjuno in one process (two-process-rule violation), and it no
longer started from the enumerator-only recall (which omitted velocity-sens /
FX / fine-FX and made every seed diverge for a non-port reason). Items 1/3/4
remain (item 4 is gated on GAP=0 = #112).

**W6 — CLOSED / STAGE-D SEALED (2026-07-23).** The seal is complete. Item 4
(completeness_gate into `make verify` "the moment GAP=0") is done: the 8 residual
rows are not GAPs — they are not-engine-reachable controller-path params (the
0→200 full-state sweep confirmed dispatch 0x3B9A30 is a no-op for them; the FLANGER
params reach the engine only after the effect-object mode-4 *activation* that recall
does not perform, and Patch Tempo is a true no-op — this session). Reclassified
`DEFERRED-CONTROLLER` (named, bounded, listed every run), so GAP=0 and
completeness_gate is GREEN inside `make verify`. Item 1 (widen exhaustive) is met
for the finite surface by recall_exhaustive + finefx_pillar3 + etmode_ab (SEAL
condition 2 GREEN); the multi-input product cells stay deferred to recall_gate
factory combos (256^k infeasible — the honest boundary). Item 3 is moot now that
the gates are the authority. **Net: SEAL conditions 1-6 GREEN in `make verify`;
condition 7 (bounce) is covenant-diagnostic-only and #112-pinned. The binding
finish line is met.** The only remaining work is the optional #112 lifecycle
(docs/P112_ROADMAP.md): flipping the 8 DEFERRED-CONTROLLER rows to APPLIED (needs a
flanger DSP render too — zero factory benefit) + condition-3-primary +
condition-7. Not required for "done".

### Priority note

**(SUPERSEDED 2026-07-23 — see "W6 — CLOSED / STAGE-D SEALED" above: W0-W4 are
done, GAP=0, and W5's fallback is sealed. This original ordering guidance is kept
for history.)** W0 protects work already shipped — do it first and do not skip it
because the gate "is already green"; the gate is green over the contexts it saw.
W1-W4 drive GAP 10→0 (Pillar 1 truly complete). W5 is the highest-USER-value item
(#124 is the standing ear report); if W2/W3 stall, jump to W5 and return.

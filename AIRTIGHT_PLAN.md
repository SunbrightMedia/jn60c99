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
   from the binary matches the ledger exactly;
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
  - **B-next order**: (B2 = Pillar 2) crack the controller path (RE of the
    controller setState / per-param apply), derive every controller-only + mode-
    ambiguous FX law through it, build the controller-path oracle (the #124 ground
    truth), wire the port, render A/B green; fix the false-gap ledger rows along
    the way (DIRECT LEVEL etc. — replace the diff-miss port_writeset signal with
    the definitive "oracle dispatches leaf -> render A/B green" test). Then Pillar
    3 (build ONE exhaustive gate over the full wired ledger: port applier vs a
    FRESH truth/-derived setter sweep, all 256 bytes x 4 rates, non-circular) and
    Stage D (seal every gate into make verify as the single RED/GREEN).
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

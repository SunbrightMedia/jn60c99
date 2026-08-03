# PHASE 1 ORDERS — finish and certify engine B, the splitting point
(Fable 5 → Opus 5, 2026-08-04. USER-BINDING. Supersedes the "order of work"
in P8_PLAN.md for sequencing.)

## The decision this executes

The user has decided the target strategy:
* **The TRUNK is the full engine B, EXACT** — every module gated EXACTLY 0
  against the port and bit-exact against the plugin, standalone, small-memory.
  It is the splitting point for every microcontroller this project and
  project-ssx will ever target. NOTHING approximate ships in the trunk.
* **Targets are FORKS by build flags** (S3: 6 voices @48 kHz + cents-gated
  pitch + ppm-gated LFO rate + C4; Teensy: full standard). Fork work starts
  ONLY after the trunk is certified. Fable owns the fork's numeric work.

Consequence for sequencing: **C2 (control-rate CV) is NOT trunk work.** It is
a −100 dB approximation candidate, so it belongs to the S3 fork. An earlier
phase assignment (mine) put it in Phase 1; that was wrong and is corrected
here. Trunk work is exact work only.

## Standing rules (unchanged, and they bind every task below)

* Accuracy: EXACTLY 0 vs the port for every trunk change; 11/11 BIT-EXACT vs
  the PLUGIN at 44,100 AND 48,000 Hz. No relaxations in the trunk, none.
* Every gate you add must have TEETH, with measured brackets, run at 48 kHz.
* Regenerate the composite after ANY shim edit (`merge_shims.py --check` is
  the arbiter). Fresh-build before trusting any run.
* `src/` stays frozen. No model IDs in anything pushed. Commit per task with
  the standard trailer; push after each.
* The four ways the boundary script lies (CLAUDE.md P5 block) apply to any
  new cell work. Check all four.
* If a task's gate will not go green, STOP that task and record the failure
  honestly. Do not weaken a gate to pass it. A failed-honest task is a
  deliverable; a green lie is not.

## TASK 1 — step 2: the coefficient constructor, then the engine gate

GOAL: `eb_engine_render` runs as THE engine and is gated. The guard
(`render_ok`) comes off exactly when the three gates below are green.

1a. **`eb_render_coefs_build(const unsigned char *st, eb_render_coefs *c)`**
    (new `engine_b/eb_coefs.c`). It fills every field from the port's
    recalled state cells. The cell→field mapping ALREADY EXISTS, written and
    proven: it is the gather blocks of the fifteen shims
    (`engine_b/shim/*/voice_render.c`, `master_render.c` for the FX). Derive
    the constructor from those gathers — mechanically where possible — do not
    re-derive cells from the port source. Two traps, both already on record:
    * Per-sample cells must NOT enter the constructor (noisemix's 3536 is the
      proven example; the generation guard cannot catch this class).
    * The FX cfg structs gather from MASTER cells; the reverb needs its
      pending-tap array and wipe arm as real storage.
    Reading the PORT's state to build coefs is legitimate harness plumbing
    for gating. The instrument's own recall path (eb_patch) is a LATER trunk
    task, gated separately; do not conflate the two.

1b. **The standalone shim.** Follow docs/engineb/STANDALONE.md: the module
    replaces `juno_driver.c` (the `skeleton` slot). Per sample it calls
    `eb_engine_render` instead of the port's voice+master chain, with:
    * engine B state SEEDED ONCE from the port's cells at context start
      (power-on equivalence), then OWNED — never reloaded per sample. That is
      the entire point of the standalone engine.
    * note/recall events mirrored into engine B state. The generation counter
      is the signal (it bumps on every note event and recall); on a bump,
      re-read the CONTROL cells that events write (gate, cell 320, velocity,
      kbd) and rebuild coefs. Free-run state (phases, LFSR, smoothers) is
      NEVER re-seeded after start — reloading it would mask lockstep bugs.
    * the two delayed copies of port range :1665-1671 and the dco_live
      coefficient-copy equivalence resolved INSIDE eb_engine_render. Both are
      currently believed-not-gated; the null decides them.

1c. **The three gates, none weakened for being new:**
    * `null_b.py --module standalone`, all 30 scenarios, EXACTLY 0, at BOTH
      rates (`--rate 48000` and 44100).
    * `plugin_check.py --module standalone --rate` both rates, 11/11
      BIT-EXACT.
    * a teeth bracket for the standalone module, measured, plus one planted
      LOCKSTEP error (skip an idle voice's state advance) that the
      idle-prefix scenarios must catch — the catch-matrix pattern.
    Expect the seeding/event-mirroring to be where it fights you; the
    idle-prefix scenarios exist precisely to catch what cold runs cannot.

1d. When 1c is green: set `render_ok` in the engine init, delete the
    EB_RENDER_INCOMPLETE guard note, update eb_render.h's honesty block, and
    record the certification in CLAUDE.md.

## TASK 2 — C5 fusion (trunk: EXACT only)

One loop per voice instead of the call chain, batching only — identical
arithmetic, identical order, so the gate is EXACTLY 0, not −100 dB. Re-run
the full gate set after each boundary removed. Measure the saving with
`engine_price.py` before/after and record it. If any fusion step cannot hold
EXACTLY 0, back it out — fusion is cost work, not correctness work, and the
trunk does not trade correctness for cost.

## TASK 3 — the method playbook (the user's portability requirement)

The user requires engine B's MAKING to be portable to other project-ssx
synths. Today it is scattered: SSX_FRAMEWORK.md is a design that predates the
real work and was never implemented; the method that actually worked lives in
CLAUDE.md blocks, STANDALONE.md, HARNESS_AUDIT.md and commit messages.
Write **`docs/engineb/METHOD_PLAYBOOK.md`**, synth-agnostic, distilled from
what was DONE, not what was planned:
1. the hybrid-shim null harness (oracle = the port, substitute one TU,
   EXACTLY-0 self-test, two-process rendering);
2. boundary selection by live-variable analysis + read-before-write cell
   classification + THE FOUR WAYS THE SCRIPT LIES;
3. teeth: measured brackets, fail-only classes, catch matrices, the
   probe-on-threshold trap, "a gate never seen to fail is not a gate";
4. the coefficient generation counter and its self-disproving build;
5. MEASURED×STATIC costing (call-graph pricing, helper bodies by
   nm --defined-only, measured branch rates, the four flattering errors);
6. the bias law (phase-integrated targets need exact evaluation;
   memoryless targets tolerate measured bounds) and the cents-gate pattern;
7. the harness-defect catalogue: every defect this project found in its own
   verification, one line each, as a pre-flight checklist.
Mark SSX_FRAMEWORK.md's header as superseded-by-practice with a pointer.

## TASK 4 — certification sweep and record

Full `null_b --teeth` at 48 kHz; composite both rates; plugin_check both
rates; `alloc_ab.py` + `--teeth`; the port-side `make verify` untouched and
green; `engine_price.py` re-run and `engine_cost.md` refreshed if numbers
moved. Then update CLAUDE.md's top block: TRUNK CERTIFIED, with the numbers,
and hand back for the S3 fork.

## What Opus must NOT do in Phase 1

No C2, no C4, no oversampling changes, no voice-count changes, no pitch or
LFO relaxations, no EB_PITCH_CR>1 (compile-refused anyway), no new
approximations of any kind. Those are fork work, Fable's numeric design, and
they start only from a certified trunk.

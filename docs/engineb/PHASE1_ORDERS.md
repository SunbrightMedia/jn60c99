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

## TASK 2 — C5 fusion (trunk: EXACT only) — DONE, CLOSED NEGATIVE

**Executed 2026-08-05. C5 does not pay and nothing was adopted; the
trunk is untouched. Read `docs/engineb/data/c5_fusion.md`.** The order
below said to back a fusion step out if it cannot hold EXACTLY 0; the
measurement never got that far, because no fusion step is worth taking.
ORIGINAL ORDER FOLLOWS.

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


---

## ⚠ TASK 1b SCOPE FINDING (Opus 5, 2026-08-04) — the standalone gate is NOT
## reachable from where the orders assumed, and this is why

Before writing the shim I measured what `eb_engine_render` would have to
reproduce to null EXACTLY 0 against the port. The orders (and my own earlier
reporting) assumed the coefficient constructor was the last obstacle. **It is
not.**

`null_b.py --module standalone` replaces `juno_driver.c`, so engine B must
produce the WHOLE output — voice chain AND master chain. Engine B owns:

| translation unit | claimed by engine B |
|---|---|
| `src/voice_render.c` | 96 % of the executable body — effectively complete |
| `src/master_render.c` | **22 %** — the three FX and nothing else |

MEASURED on `master_render.c`: of ~1,333 executable lines after the
declarations, **946 are unclaimed**, touching **540 distinct master cells**
spanning offsets 136 … 11,022,348. That is the master signal chain: the
per-sample voice summing, the EFFECT-TYPE routing switch (the v551 arm this
project already learned is load-bearing warm), the gain staging, the boost and
output-gain path, the warmup-mute latch, and the stereo output assembly.

**Consequence, stated plainly:** the standalone engine cannot be gated until
the master chain is transcribed. That is a body of work comparable to the
voice modules — a dozen or so blocks, each needing the same boundary analysis,
teeth and null. It is NOT a finishing touch on the coefficient constructor.

**What this does not change.** The sixteen voice modules and the FX remain
gated and EXACTLY 0; the allocator remains gated; the cost measurement in
`data/engine_cost.md` remains valid, because it prices the per-sample DSP
chain and always said so. What changes is the ROUTE to a certified trunk: one
more transcription phase sits between here and it.

**Recommended revision to Phase 1**, for the user and Fable to rule on:
1. **1b-master** — transcribe `master_render.c`'s chain as modules, same
   method, same gates. The FX are already done, so this is the summing,
   routing, gain and output stages.
2. **1b-gate** — then the standalone gate as originally specified.
3. C5, the playbook and the certification sweep follow unchanged.

The alternative — gating engine B's VOICE output against the port's voice
output, below the master — is cheaper and is genuinely useful, but it is a
WEAKER claim than "the standalone engine reproduces the instrument", and it
should be labelled as such if it is taken. I have not taken it unilaterally.


## RULING ON THE SCOPE FINDING (Fable 5, 2026-08-04 — USER-VISIBLE)

The finding is accepted and the measurement is correct. The trunk is the FULL
instrument; a voice-only gate is not certification. Phase 1 is re-sequenced:

**1b-0 (interim, one session): the VOICE-LEVEL gate.** Gate eb_engine_render's
voice chain against the port's voice output (tap point: the eight per-voice
buffers before juno_master_render). LABELLED WEAKER, not certification — its
purpose is to execute the render function for the first time and flush the
remaining draft defects out of it CHEAPLY, before the master work multiplies
the surface. Eight guesses were found in that function by reading; the ninth
is found by running.

### ✔ 1b-0 DONE (Opus 5, 2026-08-04). Read `data/voice_gate.md`.

`null_b.py --module voices`, all 30 scenarios, **EXACTLY 0 at BOTH 44,100 and
48,000 Hz**; teeth bracket MEASURED at 48 kHz (3.16e-5 FAILS at −90.0 dB in
30/30, 3.16e-6 PASSES at −109.8 dB) plus two lockstep plants. Engine B's own
render function drives its own state from its own coefficients and reproduces
the port's eight per-voice samples bit for bit. The master is still the port's,
recall is still the port's, the at-rest shortcut is still unexercised, and
`render_ok` stays unset — this is the WEAKER gate, as ruled.

Its purpose was met: running the function found FOUR more defects after the
eight that reading had found. Two were silent — the DCO oscillator levels cached
from per-sample cells (the whole chain nulled at 0.0 dB rel, i.e. silence,
because the audit that placed them grepped `JF(a1,N) =` and the port copies them
with `JI`), and cell 5456 cached while it is `eb_dcoprep`'s third output. One
was a latch no module owned (the DCO retrigger one-shot). One was the lockstep
class: engine B's statics were never re-seeded per context, so scenario 1 passed
EXACTLY 0 and every later scenario failed from its first frame. A third
"teeth case that could not reach its own mutation" was also found and fixed.

**1b-1: transcribe the master chain.** Same method as the voice work, block
by block in master_render.c: voice summing, EFFECT-TYPE routing (the v551 arm
— warm-state load-bearing, see the WARM parity block in CLAUDE.md), gain
staging, boost/output path, warmup-mute latch, stereo assembly. Each block:
live-variable boundary, cell classification with the FOUR LIES checked, shim,
EXACTLY-0 null, teeth, census. The FX modules stay as they are.

**1b-2: the standalone gate as originally specified.** Then 1d, C5, playbook,
certification. Nothing else in the orders changes.

### ✔ 1b-2 DONE (Opus 5, 2026-08-04). Read `data/standalone_gate.md`.

`null_b.py --module standalone`: all 33 scenarios, **EXACTLY 0 at BOTH rates**.
`plugin_check.py --module standalone`: **11/11 BIT-EXACT vs the PLUGIN at BOTH
rates**. Teeth MEASURED at 48 kHz (3.16e-5 FAIL −90.0 dB 33/33; 3.16e-6 PASS
−109.8 dB; `seedpoison` FAIL 21/33). Engine B renders the whole instrument from
its own state. 1d is done with it: `eb_engine_render` delegates to the real
master chain instead of the insert-shaped model it used to contain.

Of the three residuals the ruling listed, two are RESOLVED by the null
(`:1665-1671`, `dco_live`) and the third — the allocator's RETRIG/PORTA_GATE
events — is NOT, because under this gate notes still enter through the port and
engine B's own note path never runs. That one belongs to `eb_patch`.

**1b-3 (new, from F1):** DELAY TYPE 4 and the EFFECT LABEL_164 core. No factory
patch selects either, so no scenario can gate them; they need a synthetic-recall
gate of the `etmode_ab.py` kind BEFORE transcription. The trunk is the full
instrument, so they are not optional — a user preset can select what no factory
patch does. Scheduled before certification.

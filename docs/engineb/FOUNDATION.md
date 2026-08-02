# ENGINE B — THE FOUNDATION

**One command: `make engineb`.** Full tier, MEASURED **10 m 02 s** GREEN on this
container with 4 shim modules present (steps 0–4 and 6–8 are a fixed ~8 min;
each additional shim adds ~35 s to step 5).

`make engineb-quick` is the short tier and covers strictly less — see §4, which
states exactly what it drops. **Timing honesty:** the quick tier reached step 5
in **1 m 31 s** MEASURED, and no complete quick run has finished green, because
a concurrent session was writing new shims into `engine_b/shim/` throughout
(step 5 correctly went red on a half-written `chorus`). Take **~1.5 min + ~35 s
per shim** as the estimate, not as a measurement of a full pass.

The driver is `tools/engineb/foundation.sh`. It runs eight steps in dependency
order and stops at the first red, with a message that says what to DO. It stops
rather than continuing because the order is load-bearing: a module null run
through a harness whose teeth were never checked is not a weaker result, it is a
meaningless one.

    0  libjuno.so          the oracle side, built fresh from FROZEN src/
    1  labels              verify_labels.py
    2  unit tests          make -C engine_b/tests
    3  null self-test      null_b --module none  MUST be EXACTLY 0
    4  teeth (module gate) null_b --teeth
    5  modules             null_b --module <every shim that exists>
    6  teeth (src/ gate)   null_ab.py --teeth
    7  cost                cost.py calibrate + the ledger's budget accounting
    8  ledger integrity    ledger.py check  (STALE / FORGED)

---

## 1. What the foundation now GUARANTEES

Every item below is MEASURED by a run of `make engineb`, not asserted.

1. **The comparator is honest about zero.** `null_b --module none` substitutes
   nothing and returns residual **EXACTLY 0** on all 30 scenarios — bitwise, not
   "below threshold". Any module number is therefore attributable to the module.
2. **Both gates can go red.** Both teeth batteries run and pass:
   * `null_b --teeth` — CLEAN 0 / `onelsb` −130.5 dB PASS / `justover` −90.4 dB
     FAIL / `tailquiet` 30 caught / `dcopitch` 30 caught / `idleskip` 19 caught,
     matching a catch matrix **derived from the event scripts**, not from tag
     names. This battery had **never executed before 2026-08-02**: it raised
     `NameError` on its first line while the tool's own docstring and two
     documents said "teeth proven". Fixed and now run every time.
   * `null_ab.py --teeth` — 30/30 clean control, and every planted mutation
     caught by its recorded scenario set.
3. **The bands are calibrated from both sides.** −100 dB global / −80 dB block:
   1 LSB/sample passes at −130 dB, a deliberate just-over error fails at
   −90.4 dB. The floor is bracketed, not chosen.
4. **Engine B's own contracts hold**: hot state 204 B/voice against a 1024 B
   limit (51.5× smaller than the port's 10,512 B), the free-run advance is O(1)
   in n, and 64/64 factory patches round-trip through the 118-byte compact
   format on the 127 live bytes it decodes.
5. **Module labels match the cells the code touches** (6 of 9 ranges are truly
   checked — see §2).
6. **The equivalence ledger matches the tree.** Every current row re-hashes
   against its module source, proof source, gate harness, cost rig and scenario
   set; a hand-edited number reports FORGED. Ledger teeth: 6 damage cases
   caught, clean control not caught.
7. **The cost model states its own error bars**: M7 arm 1.09× against the one
   SILICON anchor, host arm 0.81× against callgrind, ESP32-S3 **calibrated by
   nothing**.
8. **Two stale-artifact holes are closed** as part of this work: `engine_b/tests`
   now depends on `engine_b/*.h` (breaking a header used to leave the binaries
   untouched and printing PASS on the OLD constants), and `null_b` builds both
   sides from source into a temp tree on every run.

---

## 2. What the foundation does NOT guarantee

Read this section before quoting a green.

**G1 — Green means "matches `src/`", not "matches the plugin."** Every null in
this target compares engine B against the FROZEN transcription. `src/` is a
proxy. The authority is the plugin binary, reached by
`tools/engineb/plugin_check.py` / `docs/trackb/THREE_WAY_GATE.md`, and no step
of `make engineb` runs it. Every ledger row says so in its `authority` column.

**G2 — `plugin_check.py` has an OPEN, UNTRIAGED finding.** Against the plugin
itself, `src/` is bit-exact on POLY and MONO with idle prefixes, but on **UNISON
(patch 61) one single free-running idle sample before note-on is enough to
diverge**: 0 idle frames bit-exact, 1 frame −58.1 dB, 441 frames −33.4 dB. Cause
NOT established; a harness defect is not fully excluded. **Any engine B UNISON
result is measured against a reference that may itself be wrong.** Triage this
before believing one.

**G3 — a green null does not bound a coefficient.** PROVEN by planting the
error: multiplying `eb_envgen.c`'s `k_hold` by 1.001, 1.01, 1.1 and **2.0** each
leaves `null_b --module env` at residual **EXACTLY 0, PASS**. The value is
consumed only by sign comparisons, so any perturbation that does not flip a test
is invisible. `k_hold = 0.0f` does fail, 11/30. The row `env … EXACTLY 0 …
GREEN` is true and does not bound `k_hold` at all.

**G4 — no teeth case plants an error in ENGINE B code.** Every mutation in both
batteries is planted in `src/`, i.e. the batteries test the comparator, not the
substitution path. G3 is what that gap looks like when it bites.

**G5 — the scenario set is thinner than 30 suggests.** Over the 8-mutation
battery the 30 scenarios collapse to **7 distinct catch signatures**; the
largest identical class is 13. No mutation in the battery distinguishes a 1-frame
idle prefix from a 44,100-frame one, and those 15 ladder scenarios are 31.3 % of
every gate run's samples. The ladder is cheap insurance against lockstep drift —
`idleskip`'s *magnitudes* do differ across it — but it is not 30 independent
tests.

**G6 — `verify_labels.py` checks 6 of its 9 ranges.** `654-693`, `1129-1149` and
`1516-1640` carry `expect=None` and always print `ok`. All three were
deliberately mislabelled during the audit and the tool still printed ALL LABELS
CONSISTENT, exit 0.

**G7 — no ESP32-S3 number is measured. No engine B code has ever run on an
ESP32-S3.** Every `cyc_s3` in the ledger is MODELED from a real
`xtensa-esp32s3-elf` compile's static instruction counts, with `rho`
MEASURED on x86 and TRANSFERRED. The rig's own calibration section says to treat
S3 nominals as **± 2×**. The 3,500 cyc/sample budget has never been tested
against silicon.

**G8 — the budget sum is not an engine total, and it is not gated.** `ledger.py
show` currently sums the three ledgered modules to 5,270..20,962 (nom **8,393**)
cyc/sample = **240 % of budget**, dominated by triangle at 205 %. That figure is
charged at **104 invocations/sample, which is the ORACLE's measured call rate**;
engine B's DCO is not written, so it is the number to beat, not a debt engine B
owes. `make engineb` prints it loudly and fails on nothing, because failing a
build on knowingly incomplete arithmetic teaches everyone to bypass the build.

**G9 — most of engine B does not exist, and the unwritten part is the larger
part.** The FX are **0 % written** — chorus, delay and reverb are by code volume
larger than the whole voice path, and their entire cost, memory placement and
accuracy story is unstarted. `eb_fx` today is 137,012 B of *placeholder* delay
lines (`EB_CHORUS_LEN`/`EB_DELAY_LEN`/`EB_REVERB_LEN` are compile-time guesses,
stated as such in `eb_types.h`).

**G10 — the 118-byte patch format decodes 59 bytes and leaves 18 parameters
UNRESOLVED**, including EFFECT TYPE, EFFECT DEPTH, DELAY FEEDBACK, REVERB
TYPE/TIME, LEGATO, TRANSPOSE and all 12 fine-FX filter bytes. "64/64 round-trip
proven" is true of what it decodes. Every unresolved parameter is an FX
parameter or a mode — i.e. the format is unproven exactly where the FX work will
need it.

**G11 — a shim with no ledger row has no recorded cost and no recorded
accuracy.** Step 5 nulls every shim directory that exists; only three modules
have ledger rows. The run prints an ADVISORY naming the unledgered ones. It does
not fail on them.

**G12 — the tree is not locked while the target runs.** A full run takes ten
minutes and shim directories have been created and deleted under it during this
session. Step 5 re-checks each directory and reports SKIPPED rather than blaming
the code, and a half-written shim shows up as a *build/load* failure whose
message says so — but a green from a run that raced a concurrent edit is worth
what any race is worth. Prefer a quiet tree.

---

## 3. Failure messages

Every step's `die` block names the failure, says why the step exists, and gives
the action. Two are worth quoting because they are the ones people get wrong:

* **step 5** distinguishes "did not build/load" from "built and diverged".
  They exit identically and mean completely different things — the first
  compared no DSP at all.
* **step 8** says to close a STALE row with `ledger.py emit`, and notes that
  there is no `--accuracy` and no `--cycles` argument, by design. A row is never
  typed; it is emitted by the proof that earned it.

---

## 4. `--quick`, and what it does NOT cover

`make engineb-quick` runs steps 0, 1, 2, 3, 5, 7, 8. It **omits**:

* **step 4, `null_b --teeth`** — the module gate is not shown to be able to fail.
* **step 6, `null_ab.py --teeth`** — same for the `src/`-level harness.
* the `long LFO+tail` scenario, dropped from every null it does run.

So: **a quick green says the gates are green. It does not say the gates have
teeth.** The run prints this list itself at the end, so an omission cannot go
unstated. Run the full tier before believing a module result, and always before
emitting a ledger row.

---

## 5. THE SINGLE NEXT TASK

**Give `null_b` teeth in ENGINE B's own code, then re-emit the ledger.**

That is G3/G4, and it is the one gap that makes current green rows mean less
than they read. Concretely:

1. Add a mutation mode to `null_b.py` that plants an error in the **shim /
   engine_b** side rather than in `src/` — the natural form is a per-module
   coefficient perturbation ladder (×1.001, ×1.01, ×1.1, ×2.0) applied to each
   named constant of the module under test.
2. Run it against `env` first, where the answer is already known: `k_hold`
   survives ×2.0 at residual exactly 0. The battery must report that as a
   **BLIND COEFFICIENT**, by name, not as a pass.
3. Emit the blind list into the ledger as a column beside `accuracy_evidence`,
   so a row states not only "EXACTLY 0" but "and these N constants are not
   bounded by that zero". Then `ledger.py emit --all`.

Do this before writing an FX module. The FX are the larger half of the engine
(G9) and they will be written against these gates; teeth that only test the
comparator will let a wrong FX coefficient through the same way they let ×2.0
through `k_hold`.

Second in line, and not far behind: **triage G2**, the UNISON idle-prefix
divergence between `src/` and the plugin. Until it is explained, engine B's
UNISON reference is suspect.

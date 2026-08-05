# THE METHOD PLAYBOOK — how to lift a synth engine out of a binary, and how to
# know you did

Synth-agnostic. Distilled from what was **done** to produce engine B, not from
what was planned. Every rule here was paid for by a defect; where a rule has a
number attached, that number was measured on this project and is quoted so the
next one can recognise the same shape.

The task this describes: you have a bit-exact port of a plugin's DSP that runs
on a host, and you want a portable engine that runs on a microcontroller and
sounds *identical*. Not similar. Identical, until you deliberately and
measurably relax it.

---

## 0. The one idea

**A green gate is a hypothesis, not a result, until something has been made to
turn it red.**

Everything below is machinery for that sentence. On this project, four separate
defects were shipped behind green gates, and each was found only when someone
asked what the gate could *not* see. The gates were not weak — they were
answering a narrower question than their name implied.

---

## 1. The hybrid-shim null harness

**The setup.** The oracle is the PORT, built fresh from source in the same run.
The candidate is the same tree with exactly ONE translation unit replaced by a
"shim" — a verbatim fork of that file in which one block is replaced by a call
into your new engine. Render the same scenarios through both, subtract in the
sample domain, gate the residual.

Consequences, and they are the whole reason for the shape:

* **Everything you have not written yet is not stubbed, mocked or faked — it is
  literally the port's own code, in the same process, carrying the same state.**
  "The rest of the engine calls the oracle" is true by construction rather than
  by a bridge somebody has to maintain.
* **A divergence is attributable**: exactly one translation unit differs.
* **The state layout does not have to change for a module to be gated.** A shim
  may read and write the port's memory cells; your engine's own compact layout
  arrives later, when a module owns enough of the chain to carry its own state.

**The self-test that makes it non-vacuous.** `--module none` substitutes nothing,
so the candidate IS the oracle and the residual must be **EXACTLY 0**. Run it at
the head of every run. A harness that cannot demonstrate a zero cannot be
trusted to report a small number.

**The two-process rule.** The comparing process never loads a library. Each side
is rendered by a separate subprocess that loads exactly one library and writes
its samples to a file. Oracle and candidate never share an address space —
because a shared process is how an oracle and a candidate end up sharing a
mistake.

**Build both sides in the run.** No prebuilt artifacts. This project produced two
false greens in one day from a stale library and stale test binaries.

**The accuracy standard.** Sample-domain null, two thresholds, both gating:
global RMS residual ≤ −100 dB, and worst 1024-sample block ≤ −80 dB, each
normalised to its own level. The block metric exists because the global RMS is
dominated by the loud part of a render: MEASURED here, a tail-only 0.1 % error
was caught by the global metric in 5 of 7 scenarios and by the block metric in
**7 of 7**. Calibrate once and record it: on this engine a 2-ULP/sample error
lands at −129 dB, so a −90 dB gate would ignore errors up to ~200 ULP/sample.

**Scenarios are part of the harness, not decoration.** See §3.

---

## 2. Choosing a module boundary

Do not carve by eye. Two measurements decide it.

**(a) Live-variable analysis.** For a candidate line range, compute how many
local values cross each edge: assigned before and read inside (live-in), assigned
inside and read after (live-out). A range with a narrow cut lifts into a function
cleanly; a wide one is a marshalling exercise wearing a module's name. On this
project the best voice module had **four live-in and zero live-out**, and the
whole master chain turned out to cut into ~14 blocks with only **2 to 6** locals
crossing.

**⚠ A live-out set computed by "assigned inside and mentioned later" is an
OVER-APPROXIMATION.** It does not check whether the successor block *assigns*
the local before reading it. On this project that error nearly led to a block
being declared a no-op. Do the assignment-before-use check for any block whose
control flow falls through into another.

**(b) Read-before-write cell classification.** For every memory cell the block
touches, decide: coefficient (read, never written anywhere), state (read and
written), or dead store (written, never read). Do it **by script** — and then
know that the script lies in five distinct ways.

### THE SIX WAYS THE CLASSIFIER LIES

Each of these shipped a defect here.

1. **Branch-split cells.** Written in an `if` arm, read in the `else` arm. They
   carry across samples, and a read-before-write scan calls them locals.
   Treating them as locals zeroed a filter on every else path.
2. **Raw-pointer cells.** `*(float *)(base + 0x2000)` is invisible to a grep for
   the accessor macro. Sweep the whole function for raw forms once, and record
   that you did — that is what makes every other block's inventory trustworthy.
3. **Self-assigned live-ins.** `v = f(v, ...)` looks "assigned" to a naive
   live-in check and is a genuine live-in. Split statements before matching.
4. **Per-sample cells masquerading as coefficients.** A cell the function writes
   every sample, cached once as a coefficient, freezes a moving value — and a
   generation counter can never catch it, because the cell does not change at
   recall time. **Grep for writers across the WHOLE function before calling any
   cell a coefficient**, and grep for **both accessors**: on this project the
   three DCO oscillator levels were copied as ints, the audit greped only the
   float accessor, and the engine emitted silence.
5. **Cross-block feedback.** A cell read at the top of block A and written at
   the bottom of block Z, in the same sample. A scan of block A *alone* calls it
   a coefficient. Only a whole-function scan sees it. These must be ARGUMENTS to
   the module, not state, because they belong to the block that writes them.
6. **Constant scratch a block leaves behind.** A block's last statements may
   assign plain constants to locals it never uses again — decompiled register
   reuse, and easy to drop as noise. They are not noise if a LATER block reads
   the local on a branch where it does not assign it first. Here every DELAY arm
   ended with `v56 = 0.0; v58 = -1.0;`; all four delay modules dropped the pair,
   and the omission was unreachable until an EFFECT arm that assigns `v56` on
   only one branch was transcribed. **A module's contract is the state it LEAVES
   as well as the value it RETURNS** — and no per-module gate can test that,
   because each module is exact inside the other's port code. It took a
   two-member composite bisect to find.

**Make the check mechanical and put it in the battery.** A check that runs by
hand goes stale. Give it teeth of its own: a planted tree in which the bad cell
is read again, on which the check MUST fail.

---

## 3. Scenarios, and the arms your gate cannot see

**Coverage is a prerequisite, not a nicety.** If a synth dispatches between
several algorithms — delay types, effect types, filter modes — a module written
for an arm no scenario selects **cannot be gated at all**: the null compares two
code paths, neither of which runs, and reports EXACTLY 0.

MEASURED here: the inherited scenario set drove one dispatch through 3 of 6 arms
and another through 3 of 6. Half the master chain was ungateable and nothing
said so.

**Do this before writing a module, not after:**
1. Instrument the dispatch and COUNT executions per arm over the whole scenario
   set.
2. Add scenarios — from REAL factory patches where possible, so they are the
   instrument's own configurations rather than synthetic edits — until every
   reachable arm is exercised.
3. Make that a standing gate that runs every time.
4. For arms NO patch can select, say so explicitly and **refuse to write the
   module** until a synthetic-recall gate exists. Silence is indistinguishable
   from a working effect nobody tested.

**THE SYNTHETIC-RECALL GATE, concretely: DOCTOR THE PRESET, not the engine.**
Overwrite the parameter's own bytes in a copy of the factory preset record and
let the instrument's OWN recall path run. That is a preset a user could save,
so the arm is reached the way it will really be reached — unlike poking the
engine's dispatch cell, which reaches the arm while skipping everything recall
does on the way. Three arms here were closed exactly this way, and one of them
was an arm a shipped module had always handled and no gate had ever executed.

**And then make the coverage tool use the SAME driving.** Ours rendered the
doctored scenarios against the PRISTINE preset bank, so it reported two arms
NOT REACHABLE while the null gate was covering them. **A coverage tool that
does not reproduce the gate's own driving is describing a different run.**

**Coverage added for one reason finds defects of another.** The scenario added
here to reach one effect type happened to use an arpeggiated patch — and
immediately exposed that the arpeggiator never bumped the coefficient generation
counter, so the engine would have played **silence on every arpeggiated patch**.
That defect had survived every gate because no scenario used an arp patch.

**Idle-prefix scenarios.** Same patch, same note, varying ONLY the number of idle
samples before the note-on (1, 48, 441, 4410, 44100). MEASURED: five different
outputs, because oscillator phases, noise generators and effect LFOs free-run and
where they stand at note-on is part of the sound. An engine that skips the STATE
ADVANCE of a silent voice sounds right in every cold-start test and wrong in a
DAW.

**`--quick` is for iteration, never for a result.** MEASURED here: the quick set
drops the long scenario, which was the ONLY scenario exercising one module. That
module's quick PASS was vacuous and it was genuinely broken. **No module result
may be quoted from a shortened run.** The teeth catch-counts tell you when you
are near this cliff: a module caught by ONE scenario is one `--quick` away from
being ungated.

---

## 4. Teeth: proving the gate can go red

For every module, plant a known error and require the gate to CATCH it. A gate
that has never been seen to fail is not a gate.

**Brackets, measured.** Find the smallest relative error on the module's own
output that the gate catches, and the next one down that it lets through. Record
both, with the scenario counts. A battery of catchable errors alone says nothing
about where the floor is — the PASS half is what fixes it.

**Perturb at the crossing.** Plant where the module's result ENTERS the signal
path, and make it a RELATIVE scale so the factor means the same thing in a loud
module and a quiet one.

**Fail-only classes are legitimate.** Some modules carry a CONTROL value (a
pitch, a cutoff) whose relative error is amplified enormously; they are gated
finer than one ULP of 1.0f, so no pass case can exist. MEASURED: at 1e-8 the
factor rounds to 1.0f and the build perturbs NOTHING — that would be a vacuous
pass case. Record the impossibility instead of faking the case.

**The probe-on-threshold trap.** If your chosen factor lands within a decibel of
the threshold, you are measuring the threshold, not the module. Move it.

**★ MATCHING IS NOT REACHING.** An anchor that matches its marker exactly once
can still plant a statement that never executes. On this project a perturbation
was inserted after an assignment inside a brace-less loop, landed outside the
loop with the index one past the end, wrote past an array and perturbed nothing
— and the uniqueness assert PASSED. **Both bracket factors measured EXACTLY 0.**
If a teeth case reports no effect, that is a finding about the case before it is
a finding about the module.

**Assert anchor uniqueness and hard-stop.** Three times here a refactor moved a
call and left an anchor naming the old form. Each time the battery stopped
instead of silently planting nothing. The guard is worth more than the cases it
protects.

**Catch matrices.** For a bug only certain scenarios can see, derive the expected
catch set FROM THE SCENARIO SCRIPTS and require equality — not "some scenarios
caught it". Naming is not structure: two scenarios tagged "idle" here could not
catch an idle-only bug because they opened with a note-on.

**Plant your own history.** Every defect the harness once let through becomes a
permanent teeth case.

---

## 5. State, seeding and the lockstep class

**Seed once, then own.** The engine copies free-running state from the oracle at
context start and NEVER again. Re-seeding per sample would make a lockstep defect
impossible to see, which is the entire point of the exercise.

**★ A shim may cache COEFFICIENTS in file statics. It may never hold STATE
there.** Statics are seeded once per PROCESS, and a harness that renders every
scenario in one process will silently carry scenario 1's ending state into
scenario 2. MEASURED here, twice, by two different routes: scenario 1 nulled
EXACTLY 0 and every later scenario failed from its FIRST FRAME, with the first
differing sample equal to scenario 1's length. **It looks exactly like a broken
DSP chain and is nothing of the kind.** Keep shim state in the host's cells and
copy in and out per sample, or hook context creation.

**Detect a new context by a MARKER, not by a pointer.** A freed block's address
is reused. Write a magic value into unused space; a fresh allocation reads zero.

**Re-init and mode changes must NOT re-seed.** Only genuine context creation.

**Seeds are only ever exercised near-cold, so gate them deliberately.** A state
field missing from the seed whose post-recall value happens to be zero will hide
forever. Plant a perturbation in ONE seeded field and require failure.

**★ And check that your seed-poison case can actually fire.** The first one here
perturbed a field whose coefficient is 0.0 in ALL 64 factory patches — the field
is inert, the case measured EXACTLY 0, and it would have been recorded as proof
that the seed is read. Ask why a case did not fire before concluding anything
from it.

---

## 6. Transcribing by machine, not by hand

For blocks of decompiled DSP beyond ~100 lines, **do not hand-type**. Write a
transformer that rewrites the source block mechanically: each memory access
becomes a coefficient field, a state field, an argument, or a ring access.

**The guard that makes it safe: refuse to emit while ANY unresolved reference
remains.** Count the residual raw accesses and unknown cells and abort if either
is non-zero. With that guard, a 409-line block with four ring buffers is a
tractable job; without it, it is a guess.

**Things the transformer will get wrong, all found here:**

* **Multi-line expressions.** A line-by-line pass silently leaves them behind.
  Operate on the joined text. The residual-reference count is what caught it.
* **Non-uniform sub-expressions.** One ring read spelled its offset inline
  rather than as a local, and a "capture a local" pattern skipped it silently.
* **Phantom cells** from matching a constant inside an address expression
  (`4LL * v + BASE` yielding a "cell 4").

**★ THE INT/FLOAT REINTERPRETATION TRAP, in three distinct forms.** All three
shipped here; all three produced a green gate before they produced a red one.

1. **A cell copied with the integer accessor** but read as a float elsewhere —
   invisible to a single-accessor audit.
2. **An `int`-declared local carrying float BITS.** The decompiler types it
   `int`; every use is a bare cell load or store. Transcribed literally against a
   float field, BOTH assignments become numeric conversions and the value is
   destroyed twice. MEASURED: one module output was **exactly 0** on every sample
   while its sibling tracked perfectly. Detect mechanically: a local is a bit
   carrier when *every* use is a bare cell load or store with no arithmetic
   anywhere — which correctly excludes ring indices.
3. **A `LODWORD`-style store into a float field.** `carriers()` cannot catch this
   one, because the local IS used in arithmetic elsewhere; only that single store
   is a bit operation. MEASURED: a cell read back **947597056** where the port had
   **5.99e-05** — the integer value of the float's own bit pattern. Rewrite such
   stores to a byte copy.

**Reproduce, do not reason.** Where the source computes a value you believe is
dead, compute and return it anyway. On this project a control-flow reading was
wrong — a block believed to fall through actually did not — and the module was
correct throughout *only* because it reproduced what the source did instead of
acting on the liveness conclusion. That choice was made before the conclusion
turned out to be wrong, and it cost a comment instead of a debugging session.

**Verify the transform by reversing it.** Reverse-substitute the emitted body
back to source form and diff against the original. Anything but ring-shape
differences is a transformer bug.

---

## 7. Finding a divergence: measure, do not deduce

When a null fails, the temptation is to reason about the chain. Reasoning is slow
and, on a long chain, usually wrong. The techniques that actually worked here, in
the order to reach for them:

1. **Split by magnitude.** Two failure magnitudes in one gate mean two distinct
   causes. Here, ~0 dB on one patch class and last-bit drift on another located a
   missing state seed immediately.
2. **First differing sample.** Cheap and highly diagnostic. A difference that
   starts at sample ~7,430 rather than sample 0 is a *delay tap depth* — a seed
   defect can wait a sixth of a second before it shows.
3. **Run both implementations side by side in ONE build** and report the first
   disagreement. If your engine reads no host state per sample, the original can
   run alongside it, completely non-interfering. This is the single most
   productive tool in this document.
4. **Export the ORIGINAL's intermediates** and compare stage by stage. When five
   stages are candidates, this says which one moved first. Nothing else will.
5. **Compare whole structs byte for byte, then map the offset with `offsetof`.**
   This is what found an array declared one element short: the reverb's A channel
   stayed exact while B drifted in its last bits, and the first differing byte
   fell inside the last tap. No amount of staring finds that.
6. **Poison a value and see if anything changes.** Answers "is this live?"
   directly. A result of "nothing changed" is a measurement, not a failure — but
   then go and find out *why*.

**Beware the diagnostic that lies.** Two here did: a shadow copy of state whose
event mirroring ran in the wrong order, and a differential that rendered only the
first two events of a script (one sample) and reported "no differences" for a
20,000-sample scenario. Sanity-check the diagnostic against a case you already
understand.

---

## 8. Costing, when you must know if it fits

**Do not trust an emulator's per-function counts.** MEASURED here: a cycle
counter advanced 25 at a time at translation-block boundaries, so short spans
sampled the quantisation systematically and a code-layout change moved it. Two
runs differing only in a compile flag disagreed by exactly 500,000 units on
UNCHANGED functions.

**Use MEASURED × STATIC.** Static instruction counts per function from
`objdump`, multiplied by dynamic call and branch counts measured on the host over
the real scenario set. No emulator in either half.

**Four ways a cost model flatters its subject** — every one of these happened
here, and every one made the engine look cheaper:

1. **Summing whole-TU symbols** counts a static helper once when it is called
   eleven times.
2. **Skipping relocation entries** drops every intra-module call — one function
   was priced at **18** instructions.
3. **Finding library helpers by grepping for references** rather than
   definitions prices the wrong object (903 instructions instead of 105).
4. **Charging the standard library at zero.** `expf` was 184 instructions on the
   target toolchain, `fmodf` 137, and one of them ran per voice per sample.

**Measure branch rates; do not charge worst case.** A saturating shortcut fired
99.2–99.7 % of the time here and one wrap branch was taken **0 times in 61
million steps**. Charging both sides of every branch made a synthetic estimate
**51 % high**.

**A measurement that flatters its subject deserves the suspicion a
never-failing gate does.**

---

## 9. Approximation: the bias law

Once the exact engine exists and does not fit, you will be tempted to approximate.
Classify every candidate **by its consumer** before spending a day on it:

* **Phase-integrated quantities** — an oscillator pitch increment feeding a phase
  accumulator, an LFO rate feeding an LFO phase — require bias below ~1e-9. **No
  causal approximation delivers that.** Interpolation, Taylor expansion,
  incremental exponentials, control-rate evaluation: all dead. Only
  exact-to-dither evaluation passes.
* **Memorylessly-consumed quantities** — filter coefficients, gains, mix levels —
  tolerate ~1e-5. Control-rate evaluation is live THERE and only there.

The proof this cost: a control-rate pitch evaluator accurate to **1e-7 worst,
4.2e-8 RMS** on the real logged trajectory — pointwise −134 dB — still failed the
audio null at **−89.5 dB**. A smooth deterministic error is a BIAS, and a phase
accumulator integrates a bias. The exact path passes not because it is more
accurate but because its ±1-ULP errors DITHER around zero.

**The cents-gate pattern**, for when a relaxation is genuinely wanted: express
the error in the instrument's own perceptual units, and set the bound from the
instrument's own measured behaviour. Here: the plugin's UNISON detune spans
**18.2 cents peak-to-peak**, so a pitch relaxation gated at **0.05 cents** — a
thousand times below the instrument's own scatter — is defensible in a way that
"sounds fine" never is. Gate it by exhaustive sweep, not by ear.

---

## 10. The harness-defect catalogue

Every defect this project found in its own verification. Use as a pre-flight
checklist.

| # | defect | how it presented |
|---|---|---|
| 1 | Prebuilt binaries / stale library used by a gate | two false greens in one day |
| 2 | No build rule depended on headers, where the constants live | a coefficient edit rebuilt nothing; every gate green on old constants |
| 3 | Composite generated by shadowing linked only the last module | an execution counter measured **0** calls in the composite |
| 4 | Overlap guard keyed per module kept only the LAST region | a merged module nulled at 0.0 dB on all scenarios |
| 5 | Two shims chose the same file-scope static name | compiled alone, collided only in the composite, error named neither |
| 6 | A diagnostic shim became a composite member | duplicated code closed the function early; looked like a merge bug |
| 7 | Teeth mutation planted into a rate-specific arm | measured NOTHING at the other rate |
| 8 | Teeth anchor stale after a refactor (×3) | cases silently planted nothing until a uniqueness assert was added |
| 9 | Teeth statement landed outside a brace-less loop | anchor matched; mutation unreachable; residual EXACTLY 0 |
| 10 | Bracket factor chosen 0.2 dB from the threshold | measured the threshold, not the module |
| 11 | Scenario set never selected half the dispatch arms | modules ungateable, gates reported EXACTLY 0 |
| 12 | `--quick` dropped the only scenario exercising a module | vacuous PASS on a broken module |
| 13 | Shim held STATE in a file static (×2) | scenario 1 exact, all others wrong from frame 1 |
| 14 | Seed-poison case pointed at an inert field | could not fail; would have "proved" the seed is read |
| 15 | Cell-writer audit named only one accessor | per-sample cells cached as coefficients; engine emitted silence |
| 16 | Differential rendered a truncated script | reported "no differences" over one sample |
| 17 | Shadow-state diagnostic mirrored events in the wrong order | showed a divergence that did not exist |
| 18 | Gate validated a component against an oracle in which the component it replaced was never reachable | oracle and port were wrong together; every comparison green |
| 19 | Two modules each EXACTLY 0 alone, wrong together (dropped scratch constants) | composite failed at −11.7 dB; neither per-module gate could see it |
| 20 | Module wrote a `float` result through a pointer to a `double` local | compiler warned, nobody read it; the local was garbage on the branch that used it |
| 21 | Teeth case DELETED a statement instead of substituting a wrong value | the uninitialised local happened to hold the right value; case measured the compiler |
| 22 | Teeth case perturbed the inert half of a two-constant defect | passed while the defect it was written for was real |
| 23 | Unit test stopped LINKING when a dependency was added, and was not in `make test` | a test that does not build is not failing, it is absent — for two days |
| 24 | Cost model omitted code the engine always executes (the whole master chain) | understated the engine; fifth flattering error of the same shape |
| 25 | Gate run with the tool's DEFAULT module set (the port), reported as an engine result | "11/11 vs the plugin" measured the port, not engine B |
| 26 | Coverage tool drove the doctored scenarios against the PRISTINE data | called two arms unreachable while the gate was covering them |
| 27 | Teeth battery run across a tree that changed under it mid-run | not a certification of any one tree; had to be restarted |

**#18 is the one to internalise.** Before concluding "the original does X", check
that the original's code for *not*-X could have run in your harness at all.

---

## 11. Order of work

1. Build the null harness and its EXACTLY-0 self-test. Nothing before this.
2. Measure dispatch-arm coverage; add scenarios until every reachable arm runs.
3. Carve modules by live-variable analysis; classify cells with all five lies
   checked, both accessors.
4. One module at a time: shim, null EXACTLY 0 at every supported rate, measured
   teeth, then move on.
5. Assemble the chain and gate it standalone. Expect the assembly to have its own
   defects — the ones here were all in seeding, ordering and interface, not in
   arithmetic.
6. Gate the parameter format at the OUTPUT, through your engine, not through the
   original.
7. Only now: cost, and only then approximate, under §9.

**Do not defer verification to make room for the next module.** Twice here a
battery was left unfinished in favour of the next piece of work, and both times
the state of the project was quietly less proven than it was described as being.
Each task's own battery runs to completion inside that task.

# THE METHOD PLAYBOOK — how to lift a synth engine out of a binary, and how to
# know you did

Synth-agnostic. Distilled from what was **done** to produce engine B, not from
what was planned. Every rule here was paid for by a defect; where a rule has a
number attached, that number was measured on this project and is quoted so the
next one can recognise the same shape.

**⚑ THIS FILE IS END_GOAL ITEM 7.** The user made the repeatability of the whole
process — `.vst3` in, two playing boards out — a binding goal on 2026-08-12, so
that the next synth takes days and not a month. The transcribed arithmetic
transfers to nothing; THIS transfers to everything. Keep it current: a lesson
that lives only in a session's memory, or only in a dated result document, has
not been made repeatable. The companion artifacts are `.claude/workflows/`
(every multi-agent run, kept whole and re-runnable) and the gate shapes below.

**Read §10's catalogue before writing a gate, and §12-14 before touching a
target.** Sections 0-11 were learned on the host; 12-14 were learned on
silicon, and they are a different family of trap.

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

### The silicon-phase additions (2026-08-05 to 08-12)

Everything above was learned while the engine ran on a host. These were paid for
on the microcontroller, and they are a different family: on a host the harness is
free, and on a target the harness is part of the thing you are timing.

| # | defect | how it presented |
|---|---|---|
| 28 | **A gate that cannot be configured like the device.** The shim forced every voice awake; the device sets that flag from a wake mask. | The shared LFO was DEAD at every polyphony below full, on the firmware being flashed all night. The gate could not see it BY CONSTRUCTION, and re-running the gate after the fix moved nothing — which CONFIRMS the blind spot rather than clearing it. |
| 29 | **A subtraction quoted as a measurement.** A shared prologue was priced as `core0_total − 2 voices`. | Wrong by 12× (1,414 against a measured 117). It steered a whole search toward moving a component that was never big enough to matter. |
| 30 | **The harness was the thing being measured** (×3). A `vTaskDelay(1)` in the audio loop; a latched pass/fail verdict; 235 characters of console per second at 115,200 baud. | The delay slept 10 ms per 2.9 ms of audio and the board reported the SLEEP as the deficit. The latch condemned a run that then held real time for two minutes. The console was 2.0 % of the wall clock against a 1.16 % deficit. **Rule: when the last few percent will not close, price the harness before pricing the engine.** |
| 31 | **A conditional fix for a self-sustaining failure.** "Only sleep when we are behind" — but the sleep was the only reason we were behind. | The board returned drift IDENTICAL TO THE DECIMAL across two binaries. A fixed point and a dead knob leave the same signature. |
| 32 | **A build knob nothing read.** `-DS3_RING_SRAM=32768` sat in the CMake cache as UNINITIALIZED; no rule consumed it. | The firmware was byte-for-byte the old one. CMake does not warn. **A knob is not a knob until something reads it, and the way to check is the firmware's own printed banner, not the command line you typed.** |
| 33 | **A structure described without being read** (×3). | Predicted the FX would overlap; it was serial. Predicted a split's cost from a diagram. Each time the code said otherwise in a comment already in the file. |
| 34 | **A probe watching one of three outputs.** The modulation detector read only the delayed LFO output, which that patch leaves at zero by construction. | Reported "the LFO is dead" for a working fix. Same shape as the bug being hunted: a measurement that cannot see its subject. |
| 35 | **A demonstration patch that could not demonstrate.** The coefficient blob carried one patch, and that patch routed no LFO to audio. | A PROVEN fix produced EXACTLY 0 audio difference. Scanning all 64 patches found 32 that route it; the blob had been built from one of the other 32. |
| 36 | **A scheduling lever aimed at a work bound.** Prologue pipelining moves WHEN the other core is released. | −2 cycles. **Before adopting a scheduling lever, establish whether the critical core is WAITING or WORKING. Only the first kind is reachable by scheduling.** |
| 37 | **Ordering, not cost, was the whole defect.** Two loops on the second core, in the wrong order. | The FX cost 2,622 cycles and hid 2,608 of them when its loop moved ABOVE the voice loop. Nothing else changed. The first ordering had been justified by a memory-contention theory that a placement test had already killed. |
| 38 | **Every gate recalls COLD, one patch per scenario.** | Warm ≠ cold was invisible for the life of the project. Measured at last: the plugin's state is order-dependent in 50 of 64 pairs but never reaches its audio; the port's reaches the audio in 19 % of random pairs, from ONE missing recall write. **A shipping, audible defect that no cold gate could ever see.** |
| 39 | **A count asserted three times without a trace.** A per-voice cell set was called 5, then 13. | Measured: 364 addressed, 12 needing storage. The 5-cell version fails 192/192 the moment a note is issued. Trace it; do not count it by reading. |
| 41 | **printf in the audio loop, for the FOURTH time.** Entry 30 already named the console and a throttle was already added for it. Four more report lines went in while hunting a stall. | The loop blocked 66-117 ms against a 5,804 us period -- twelve windows out of twelve, tagged `printf` by its own gap meter. Two flashes were then spent chasing hypotheses about the engine. **A throttle makes it rarer, and rare is what lets it survive: the audio loop may not call printf AT ALL. It snapshots; a separate task prints.** |
| 40 | **A gate that never issues a note.** The device-recall gate called recall and the builders, and stopped. | It could not see the per-voice hole (#39) or the event mirror. It had already caught one per-voice hazard, which made it look strong — and it stopped one step short of where that same hazard recurs. |
| 41 | **A perturbation scan whose PROBE VALUES cannot reach the value being tested for.** The record-position scan used `{0x00,0x03,0x0C,0x7F}`, i.e. low nibbles `{0,3,12,15}`, against a parameter whose only live value is **1** (`lg == 1 && as == 1`, src/juno_apply.c:652). | LEGATO's record positions 126/127 were absent from the "112 measured recall-affecting positions", so the compact patch format does not carry blob 110. MEASURED both ways: the four probe values move nothing, `0x01` moves the coefficients. **A scan is blind to 11 of the 16 nibble values, and equality-gated discrete parameters live in exactly that blind spot.** Sweeping VALUES is not the same as sweeping POSITIONS, and this scan swept positions only. |
| 42 | **A single-position scan used as a completeness proof for a COMBINATION.** The same scan also needs a base patch that satisfies the parameter's gate; none of its six did (only patches 5 and 47 have `LEGATO==1 && ASSIGN==1`). | The cheap refutation is a WHOLE-record random template: perturb every non-carried position at once, then bisect. It named the byte in one run. Do that before believing any "these N positions are the ones that matter" list. |
| 43 | **A LINKER PLACEMENT DIRECTIVE THAT NOTHING APPLIED, for the life of the firmware.** `esp32s3/main/linker.lf` maps all of `libmain.a` to `noflash_text` and its own comment explains the board's 2x-over-model cycles as instruction-cache thrash that the mapping removes. | MEASURED 2026-08-12 on the shipping ELF: `nm juno_s3.elf \| awk '$1 ~ /^403/' \| grep -cE "eb_\|juno_"` returns **0**. `app_main` is at 0x4200a69c and `eb_engine_render_range` at 0x42011a48 -- XIP FLASH, both. Reverting the fragment entirely changes NOTHING: identical addresses, identical section sizes. INFERRED cause: `-flto` destroys the archive-member identity ldgen matches on. So every cycle figure this project has ever quoted for the S3 was measured with the engine running from FLASH, and the recorded explanation for the shortfall was never tested. **Playbook 32 again, one layer down: a knob is not a knob until something reads it, and the artefact -- not the file you wrote -- is what says so.** |
| 44 | **A concurrent session editing the same tree during a battery** (third occurrence: `eeda697`, `cdabfe9`, and this one). While this task was measuring, another agent modified `src/juno_apply.c`, `src/juno_apply.h`, `gui/juno_bridge.c`, `tools/engineb/gen_devcells.py`, `tools/engineb/devrecall_gate.py` and `engine_b/dev/ebdev.h`. | The gate refused to start -- `ebdev_seg.h` had gone STALE under it because the generator had grown a new `#define` in another session. That refusal is the ONLY reason the collision was noticed at all; the earlier `make test` and the two firmware links had already run across a tree that was moving. **No battery result may be quoted as a certification of a tree unless the tree was frozen for its whole run, and the cheap way to know is `git status` before AND after.** |
| 45 | **A lower-priority task on a saturated core never runs at all.** The console defect (41) was fixed by moving `printf` into a separate task at priority 1, which is correct and was not sufficient. | The board printed NOTHING after its banner. The audio loop had been raised to priority 5 and, being over budget, never blocked long enough for the reporter to be scheduled. **Moving work off a hot path only helps if the destination is ever scheduled.** The fix is that the hot path DONATES one tick at the moment the other task has something to say -- once per second, against 34.8 ms of DMA slack. |
| 46 | **Three statements about one cost, none of them measured.** `eb_recall.h` said the recall burst was ~90,000 cycles; `DEVICE_RECALL.md` said it fits in one audio block; a res-LUT attribution predicted a third of it. | Silicon: 1,992,935 cycles, 21x the stated figure, and the res-LUT was 1 %. **The rule from §13 was already written and was not applied because the number had been repeated often enough to feel measured.** A number that has been quoted three times is not thereby a measurement. Splitting the burst in two and counting each half took one flash and immediately named a 54 % item that was building eight voices for a two-voice chord. |
| 47 | **A gate index outside the smallest configuration the gate compiles.** A new tooth poked voice 6 to prove that an under-stated voice mask must differ. | The gate builds twice: trunk defaults at 8 voices, and the shipping fork at `-DEB_NUM_VOICES=6`. On the fork half voice 6 does not exist, nothing differed, and the tooth failed -- correctly reporting itself as vacuous. **Every index in a gate must sit inside the SMALLEST configuration it compiles, not the largest.** The tooth working as designed is the only reason this was not shipped as a passing check. |
| 48 | **A gate that perturbed a byte nothing reads, while its own comment claimed it had closed that blind spot.** `leaf_ranges.py` took DELAY FEEDBACK / DIRECT from a grep of `src/` `rec_byte(rec, 3057)` calls -- RECORD offsets -- and wrote them BLOB-relative. Blob = record - 16, so it moved 3073/3076. | The plugin said so and was not heard: the derived range for blob 3057 came back **`flat`**, meaning 256 values that never move the plugin's state. That was read as "a boring parameter" instead of "a wrong address". `recall_render_ab.py:196` had converted correctly all along. **A `flat` result on a byte you believe is live is evidence of a WRONG ADDRESS, not of a dull parameter.** Correcting it exposed a captured constant on the first run. |
| 49 | **Every gate in the tree recalled COLD, so none could fail on a warm defect.** All comparisons went through `prepare_recall`, which did `E.E2E(); e.build(sr)` -- a fresh plugin engine per patch. The port is stateful: `juno_bank_apply` writes into an existing state and never re-prepares. | 64 factory patches, 768 user patches and 57/57 render A/B were all measured in the ONE condition where the port's statefulness cannot show: the first patch after power-on. The defects were in **which cells get written**, not in the values, and cold an unwritten cell holds a default identical on both sides. Two warm defects were live in the shipping factory bank (p39->p40 adjacent). **A stateful port compared only from cold is untested in the dimension it is most likely to be wrong.** |
| 50 | **A wait loop that matched itself, and six hours lost twice in one day.** `until ! pgrep -f "make verify"; do sleep 15; done` ran inside a shell whose OWN command line contained the string `make verify`, so `pgrep` always found a match and the loop could never exit. `make verify` had finished 5 hours earlier; its log had not changed since. | The gate was GREEN and the work was blocked on nothing. The same day, a workflow was retried three times against a harness whose permission layer strips the required parameter from every subagent tool call -- also a wait on something already known to be dead. **Never wait on a name pattern that your own waiter's command line contains; wait on a PID or a completion sentinel.** And before waiting at all, CHECK WHETHER IT IS ALREADY DONE: one `stat` of the log's mtime answers in a second what a bad loop hides for hours. `tools/verify/waitfor.sh` now does both and refuses an unbounded wait. |
| 51 | **A per-patch cell sat in a table labelled "constants" because its law SATURATES.** `6396432` (slot-1 chorus) was captured as `1.0` from 18 master states, and every factory patch plus the first 30 random seeds agreed. It is `min(DELAY LEVEL * 32, 255) / 255`, which clamps to exactly 1.0 for any level >= 8. | A uniform random level clears 8 in 97% of draws, so 30 seeds saw only the saturated side and the cell looked like a constant with 30/30 agreement. It took 100 seeds to find ONE that did not (seed 315, level 4). **Agreement across N captures is not evidence of constancy when the law saturates -- it is evidence that N samples landed in the flat region.** A cell is constant only when a SWEEP of its candidate drivers moves nothing; a clamp must be measured on BOTH sides of its edge (here: level 7 unclamped, level 8 clamped). |
| 50 | **A capture frozen inside an honestly-labelled constant table.** `S1REVERB[]` in `src/delay_recall.c` says "captured bit-for-bit from the v39==5 master states", and 41 of its 42 entries really are constants. `6497376` was not: it held `0x3ed8d8d9`, which is `f32(fb/255)*f32(0.9)` evaluated at DELAY FEEDBACK **120**. | All four factory DELAY TYPE 5 patches carry feedback 120, so every gate agreed with the capture by construction. The same word had already been caught and fixed at the OTHER delay instance (`4297808`) months earlier, and the sibling site was not audited then. **When one capture is found, sweep every instance of the same block for the same signature -- a value that equals some law evaluated at a factory byte.** |
| 51 | **"Clamps out of range" derived from a cold sweep, where it is unfalsifiable.** `src/effect_modes.c` clamped EFFECT TYPE > 5 to 5 and stored it, citing a cold spot sweep. | Cold, the power-on routing value and a clamped store are the same number, so the sweep could not tell them apart. Warm, two-sided, the plugin plainly performs **no store**: with type 3 in force it leaves 3, with type 5 it leaves 5. **A claim of the form "out of range behaves like value X" cannot be established from a cold engine whose default IS X.** The same shape recurred at `JUNO_PROG_DLY` and is still open. |
| 52 | **A three-way rule read as two-way, from a chain with one blind point.** The DELAY LEVEL gate at `102576` was derived as `(level >= 2)` and reported 128/128. | Its only level-1 sample followed a level-0 step, where "write 0" and "no write" are the same observation. The true rule is level 0 -> write 0, level 1 -> **NO WRITE**, level >= 2 -> write 1, proven two-sided by arming the carried cell to 1 and to 0 and seeing the result equal the input both ways. The proposed fix was a REGRESSION that would have muted a live path. **To prove a no-write you must arm the cell to two different values; one arming proves nothing.** |
| 53 | **A hoisted derived field that only ONE of three builders fills.** `7936d3b` moved a per-sample 13-term double pitch call out of the TYPE 2/3 and TYPE 5 delay ticks into a coef field, `pitchmod_pre`. `eb_master_coefs_build()` computes it; the module shims build the same structs cell by cell and never assigned it, and the structs are function-level `static`, so it stayed `0.0f`. | Delay pitch modulation was frozen at zero in EVERY shim build -- DELAY type 2 at -4.6 dB rel against a -100 dB gate. The hoist's proof line was "null --module standalone EXACTLY 0", and `standalone` is the one path that DOES call the builder: **it was proven on the only configuration that could not see the defect.** Ask, of every optimisation: which builds execute the changed code, and did the proof run on one that does NOT? The structural fix is a shared helper -- a value written as a bare inline expression must be re-typed by each builder, and one of them will forget. |
| 54 | **A failing tooth does not fail one case; it silences every gate downstream of it.** The `voiceidleskip` anchor stopped matching when `eb_render.c`'s guard grew `|| v >= EB_SLOTS` (73a7657), so `_plant()` asserted. `foundation.sh` step 4 calls `die`, which exits. | Steps 4b-8 -- composite regeneration, EVERY per-module null, `--module all`, and the rest -- had not executed for **eight days**, and the delay null above broke inside that window and was not seen. `make engineb-quick` skips step 4 and would have reached step 5, so the quick path was greener than the full one. **A gate that aborts is not a gate that failed one check: measure what it stopped running, and treat every downstream verdict as UNKNOWN, not as previously-green.** Anchors matched verbatim against generated files are fragile by construction -- ~35 in `_OUT_ANCHOR` plus ~12 named mutations, any one of which can do this again. |

---

## 11b. THE FLASH BUDGET — someone else's hands are in this loop

On a target you cannot flash yourself, every build costs a HUMAN two minutes
and their patience. That makes a flash a scarce resource and it should be
spent like one. MEASURED on 2026-08-12: eight flashes in one session, of which
**two were hypothesis-driven guesses chasing a stall that turned out to be the
session's own `printf`** -- and the measurement that settled it was available
the whole time and was sent fourth instead of second.

Three rules, in order of how much they save:

1. **MEASURE BEFORE YOU FIX.** If you cannot name the cause, the next build
   INSTRUMENTS; it does not repair. A repair sent without a cause is a guess
   with a flash attached, and this project's estimate record says four in five
   of those are wrong.
2. **A BUILD MAY CARRY MANY EXPERIMENTS AND NEVER MANY GUESSES.** Make the
   variable a RUNTIME switch and sweep it: the layout sweep tested ten chip
   configurations in one flash, and the bisect answered a question four
   separate builds had failed to. Two fixes in one binary is not that -- it is
   two guesses that cannot be told apart afterwards.
3. **STATE THE DECISION RULE BEFORE SENDING.** Which number, which threshold,
   and what each outcome means. If no result would change what you do next,
   the build is not worth their two minutes.

---

## 12. Taking it to silicon

**No optimisation before a silicon number.** Host cycle counts are not target
costs in either direction, and modelled target costs are worse: on this project
an llvm-mca model calibrated on the host case was still 2.2× off the real board,
and a QEMU per-call harness was 51 % high on one module because its synthetic
inputs defeated a saturator shortcut the real signal takes 99.2 % of the time.

**Measure rates on the host, prices on the target.** Branch-taken rates come from
host counters on the real scenario set; instruction prices come from static
target disassembly INCLUDING the compiler-support library bodies. Multiply. This
agreed with an independent method to 8 % where a pure-target harness had been out
by 51 %.

**Instruction counts are not cycles until the chip says so.** On the M7 they were
not. On this LX7 they were, within 5 % — and that was worth one measurement to
learn, because the whole cost model rested on it.

**Timer calls are not free.** Read the clock twice per BLOCK, not twice per
sample, or the measurement bills its own cost to the thing it measures.

**Print what is in force, not what you configured.** Two separate defects here
were diagnostics that printed the opposite of the truth: a wake mask the sweep
was not driving, and a memory placement the build had not applied.

**The per-core budget is `rate ÷ sample rate`, and the loop is the MAX of the
cores, never the sum — but only the cores that overlap.** Establish which work is
serial with which before designing a split. On this project the shared prologue
must precede every voice, so the core carrying it holds strictly fewer voices,
and no amount of rebalancing changes that.

---

## 13. Writing an estimate

**This project's record: eight estimates, seven wrong. Six flattered
themselves.** Record yours the same way, because the direction of the error is
not a property of the estimator's temperament — it is a property of not
measuring.

Every one of the six optimistic errors was **pricing code that had not been
read**: a whole master chain omitted; a static helper counted once where it is
called eleven times; intra-module calls dropped by a regex; a library object
credited with a symbol it only references. The single PESSIMISTIC one (2.5× high)
had exactly the same cause — it charged four transcendental calls where the
source has two, one of them memoised, and charged a slow branch at 100 % that the
repo already recorded as measured at 9.75 %.

So: **an estimate is a reading exercise, not an arithmetic one.** State what
would falsify it, and say which of its terms you have not read.

---

## 14. Recall and parameters on the device

Learned from designing this for the S3; every number is this project's, but the
shape is general.

**The huge state array is an illusion of size.** The original's block was 11 MB;
recall touches 343 cells. A voice tile plus about thirty segments is ~29 KB, and
on a register-window machine a literal binary-search address map compiles to the
SAME four instructions as a flat array at any constant offset. An array loop does
not fold and costs 27. **Generate the literal chain.**

**Find the map with a randomised bank, never the factory bank.** 321 of the 343
cells appear under the factory patches; 22 appear only when every record nibble
is randomised. The same blindness hides parameters from a byte-scan format: five
of this synth's parameters are constant in all 64 factory patches, so a scan
built from that bank cannot see them, and a format built from that scan is short
by five.

**Price the per-parameter table before you put it in the burst.** One resonance
table here is ~460,000 instructions for six voices and would have dominated
everything. It is a function of SAMPLE RATE ONLY — identical in every voice, and
moved by none of the parameters — so it belongs at boot. Check that class of
thing first; it is the difference between a burst that fits in one audio block
and one that cannot fit at all.

**Publishing a patch is not a pointer swap.** State that lives in neither
coefficient struct — a live oscillator copy, an envelope gate mirror, a
one-shot retrigger latch — must be invalidated in the original's own order, or
the instrument bisects: filter and envelopes on the new patch, oscillator on the
old.

**Do not double-buffer an array the engine writes back into.** If an event
mirror CONSUMES a latch by writing zero into the array, two buffers either lose
the event or replay one nobody triggered — wrong even single-threaded.

**A render engine is not an instrument.** Recall, note events, MIDI, controls and
storage are bursts on a budget, and a per-sample average that fits does not
survive a burst. Build headroom, not parity.

---

## 15. Order of work

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


8. **Only now the target.** Re-read §12 first. Nothing measured on a host
   survives the crossing unexamined, and the harness you carry over becomes
   part of what you are timing.
9. **Build the instrument, not just the engine.** Recall, notes, MIDI, controls
   and storage are the product. On this project they were left until after the
   engine was fast, and that was the wrong order — a render engine cannot be
   judged by ear, and "audibly identical" is the standard.
10. **Update THIS FILE as you go.** Every defect you pay for goes in §10 the day
    it is found, not at the end. That is item 7, and a lesson recorded only in a
    dated result document has already failed it.

## 55. A worst-case probe read as if it were the case
MEASURED 2026-08-18 (b5_fx_attribution.md). The boot memory probe strided one
cache line so EVERY PSRAM read missed, and printed 229.5 cyc/read beside a
closing line inviting the reader to conclude "DELAY TYPE 2/3/5 is LATENCY, not
maths". The delay does not read that way: a tap walks the ring roughly in
order, so one 32-byte burst serves eight samples. The delay's own pattern
measures 29.9 cyc/tap -- 7.7x cheaper. A whole session's headroom plan was
aimed at the rings on the strength of a row that measured a pattern the code
never runs.

THE SHAPE. A probe is honest about what it did and silent about what it did
NOT do, and then its conclusion line does the arguing. The worst case is the
right thing to measure for a BOUND and the wrong thing to attribute a COST to.

THE CURE, both halves:
  * measure the pattern the code actually runs, beside the worst case, never
    instead of it -- the two rows together are the finding;
  * a probe may print numbers and MUST NOT print a verdict. The line that said
    "if the PSRAM row is many times the internal row, this is LATENCY" is the
    defect, not the number above it.

RELATED: 46 (a number quoted N times is not thereby measured). The difference
is that 46 is about repetition and this is about a measurement that was taken
once, correctly, of the wrong thing.

## 56. The load balance nobody measured because both halves were on one line
Same run. `cyc` was the only per-sample number the firmware printed, so three
sessions of headroom work attributed its movement to whatever had changed in
the DSP. Splitting core 1's block into its two halves -- four CCOUNT reads per
BLOCK -- showed cyc = fx + v1 within +-140 across every patch class: the two
halves are strictly serial and are the ENTIRE block time. Core 0 carries one
voice and then spins for half of every block.

The reordering that put the FX first was justified in a comment by "the FX
fills the window where core 1 waits on core 0". At two voices core 1 never
waits. The argument was sound when it was written and silently stopped being
true when the voice count changed; nothing measured it again.

THE CURE: when a total is the only thing printed, the split is not "extra
detail" -- it is the measurement. Print the parts, not the sum. And a comment
that justifies a design by a runtime relationship (who waits for whom) names a
condition that can expire: re-measure it whenever the configuration it assumed
changes.

## 57. The accumulator that was declared and never written
MEASURED 2026-08-18 (b6_split_sweep.md). `fxp_wait` was declared beside two
accumulators that WERE written, was zeroed in the same statement as them, and
was never incremented anywhere. It compiled clean: it is written (to 0) and
read (into the reset), so no unused-variable warning fires. Had it reached a
print it would have shown a confident, stable 0 -- and 0 is exactly the value
the hypothesis wanted, so it would have been believed.

THE SHAPE is 55's cousin and the project's recurring one: a thing that looks
like a measurement, reports success, and selects nothing. Here the giveaway
was not the compiler but a REVIEWER ASKING WHAT WROTE IT.

THE CURE: a counter must be read at BOTH ENDS OF ITS RANGE before it is
quoted. `wait` read 5 at the shipping split and 1,399-3,307 after the split
moved -- one run, one stimulus, both ends seen. Prefer a live stimulus already
in the run (patch stepping, a config knob) over a tooth build: it costs no
flash and it exercises the real path.

## 58. The pool that is real and not reachable
Same run. The load-balance finding priced the recoverable idle time at
~1,350/~2,020 cycles by comparing the measured block against a PERFECT split
of the total work. Both halves of that were true. The conclusion still did not
follow, because the FX chain is INDIVISIBLE at block granularity: the only
moves available were whole voices, and the two reachable configurations are
    split 7: fx + 2,590        split 8: 5,610
neither of which is the balanced ideal. Split 8 bought 900 cycles on the four
patches that needed it and lost 600 on the other sixty -- measured, and the
opposite of the headline.

THE CURE: when costing a rebalance, price the MOVES YOU CAN ACTUALLY MAKE, not
the partition function's optimum. State the granularity of the smallest movable
unit in the same sentence as the pool. An unreachable optimum is a useful
bound and a misleading plan.

## 59. \b does not bound a C identifier, and the check reports PASS
MEASURED 2026-08-18, TWICE IN ONE AFTERNOON, both times in a gate this session
had just written. `_` is a word character, so:
  * `r"\btud_midi\b"` does NOT match `tud_midi_available()` -- so the USB file
    was silently exempt from the boundary check's "does every input submit?"
    pass, and the gate printed PASS while USB still reached the engine through
    a shim;
  * `r"\bVCF\b"` does NOT match `JUNO_VCF_CUTOFF_PARAM` -- so a planted JUNO
    constant walked straight through the "is the header synth-agnostic?" pass.

Both were found ONLY because a tooth was planted and NOT CAUGHT. Neither would
have been found by reading the regex, and both gates were green.

THE CURE, two halves:
  * matching a C identifier or any part of one: no `\b`, match the substring,
    or anchor on something that is genuinely not a word character;
  * and the half that actually saved it: EVERY GATE GETS TEETH, INCLUDING THE
    ONES THAT CHECK OTHER GATES. A tooth that is not caught is the only signal
    that would have arrived here.

RELATED: 55 (a probe that measures a pattern the code never runs). Same family
-- a selector that selects nothing and reports success -- now seen in a
measurement, a linker script, a coefficient audit, a ledger fingerprint, a
teeth anchor, and twice in one regex.

## 60. The gate that never set up the precondition its tooth needed
PAID 2026-08-19, chunk_gate.py's split-publish section, TWICE in one hour.

The split publish makes eb_recall_publish run twice per key press, and publish
is not a pure function -- step 7b CONSUMES the aux retrigger one-shot out of
the cell array. So the gate compares RENDER STATE as well as coefficients, and
tooth 11 plants the matching defect: a publish whose second run clears the
retrigger its first run armed. A lost retrigger moves no coefficient byte, so
nothing else in that gate could see it.

TOOTH 11 WAS NOT CAUGHT. Twice.
  1. The setup applied the notes BEFORE its two priming publishes, which
     consumed the one-shot. No trial had a retrigger pending, so the plant had
     nothing to destroy.
  2. Moving the notes after the publishes was still not enough, because
     src/juno_note.c:166 says note-ON does NOT arm the latch and :255 says
     note-OFF does. The gate had to RELEASE the chord too.

THE DEFECT CLASS: a detector that is correct, wired in, and pointed at a state
the harness never enters. It reads PASS, and the PASS is worth nothing. This is
defect 1 -- an untested detector -- reached from the other direction: not "the
tooth was never planted" but "the tooth was planted, the gate stayed green, and
that was nearly read as the gate being right about the code".

THE RULE, and it is cheap: WHEN A TOOTH IS NOT CAUGHT, SUSPECT THE GATE'S SETUP
BEFORE THE TOOTH. Ask what state the plant needs to be observable in, then
check the harness actually reaches that state -- from the SOURCE that owns the
state, not from what the state is called. The answer here was two lines of the
port's own note file, and it was written down years before the gate existed.

Corollary: a gate that exercises a side-effecting function must set up the side
effect it is testing. Priming a context with the same call being measured is
how the precondition gets spent before the measurement starts.

## 61. "A fixed budget per block" read as "one fixed lump per block"
PAID 2026-08-19, O2's note chunking, found on silicon after the design passed
every host gate it had.

THE INVARIANT rule 2 says incremental work gets "a FIXED budget of work per
block". O2 implemented that as ONE VOICE PER BLOCK and called it done. A voice
is not a budget. It is ~148,000 cycles, fixed, and whether it fits depends
entirely on what the block was already doing -- which varies by PATCH, by a
factor this project had already measured (delay patches run 6,526-6,821
against a 5,442 budget before any burst work starts).

The board said so precisely: 23 misses in ~4,160 note-build blocks, 0.55 %.
The step nearly always fitted. It missed when it LANDED ON A BLOCK WITH NO
SLACK. The obvious next move -- chunk finer, sub-voice -- would have been
wasted work, because the fault was WHEN the step ran, not how big it was. The
0.55 % is what said so; a bare "23 misses" would have sent the next session
subdividing eb_coefs_voice.

THE RULE: A BUDGET IS A MEASUREMENT, NOT A CONSTANT. If work is "capped per
block", the cap must be read from the instrument at run time and compared
against the measured cost of the specific work about to run. A constant chosen
at design time is a guess that happens to be right on the patches you tested.

TWO COROLLARIES, both paid for in the same hour:
  a. BUDGET AGAINST THE RIGHT CLOCK. The obvious slack is "period minus the
     last block's duration" -- but that used esp_timer, whose gap reads
     9,000-11,000 us against a 5,804 us period for reasons still OPEN
     (b4_first_run §5). A scheduler on that number concludes there is never
     slack and forces every step: worse than none. The honest number was
     already being measured in CCOUNT -- core 0's barrier spin IS its idle
     time, on the core the work runs on, in the units it is measured in.
     Never build control logic on a measurement whose value you cannot yet
     explain (playbook 55, one step further).
  b. ONE WORST-CASE PER MACHINE. A shared "worst step" let the patch reseed
     (~440,000 cyc) gate note steps (~148,000 cyc) for ever -- the budget
     starving the exact work it was added to protect.

And the shape to recognise: a scheduler must not deadlock on its own input. A
deferred block must still refresh the measurement the deferral was based on,
or the first deferral is permanent.

## 62. A defect found in one state machine is a question to ask of every other
PAID 2026-08-19, twice in one hour, in the same file.

The note sequencer had a hand-over defect: it advanced past a publish without
waiting to hear the publish had happened, so a REFUSED publish let the next
build copy over the shadow and lose the work. It was found by reading, fixed,
extracted to a header, and gated with the defect planted as a tooth.

THE PATCH SEQUENCER, TWENTY LINES AWAY IN THE SAME FILE, HAD THE IDENTICAL
DEFECT AND KEPT IT. `BST_CHECK` set the state to IDLE and asked for the
publish in one step. Consequence if refused: a ~2.1 M-cycle patch build
stranded in the shadow, the instrument still playing the old patch -- a
program change that silently did nothing -- and the build then destroyed by
the next key press, which copies the live bank over the shadow.

WHY IT SURVIVED THE FIRST FIX: the fix was applied to THE CODE THAT HAD JUST
BEEN READ, not to the CLASS. Reading a machine, finding a fault, and repairing
that machine feels complete, and it is exactly half the job.

THE RULE: when a defect is found in one state machine, protocol, or handshake,
IMMEDIATELY ENUMERATE EVERY OTHER INSTANCE OF THAT SHAPE IN THE TREE and check
each one before moving on. Write the check as a gate over the shared contract,
not as a fix to the instance -- the gate is what makes the class stay closed.
"Are there others?" is one question and it costs a minute; here it was the
difference between one gated machine and two.

Corollary, and it is what made the second one findable: EXTRACTING THE FIRST
MACHINE'S CONTRACT INTO A HEADER MADE THE SECOND MACHINE'S BREACH OBVIOUS. A
written contract is a template to hold against every other candidate. Before
the extraction, both machines were "some states in a big switch" and the
similarity was invisible.

## 63. A budget for work that cannot fit starves everything behind it
PAID 2026-08-19 on silicon, one build after the budget was added (b11).

b10 measured `miss note=23` and `miss burst=7` and added a budget: a step runs
only when the measured slack covers it. Correct for the note path, whose steps
are ~148,000 cycles against ~460,000 of slack. It was applied to the PATCH
burst too, because "rule 2 covers all incremental work".

The patch burst's worst step is 591,526 cycles. It CANNOT FIT -- the reseed and
the bank apply are single indivisible operations larger than any block's spare
time. So every step deferred to the starve limit and was forced: a program
change went from 15 blocks to ~384. Requests arrived faster than that, the
build restarted 588 times, `burst_state` was never idle, and the note path --
which may only run when it is -- NEVER RAN ONCE. 9,019 events refused, not one
note built, on a build whose host gates were all green.

THE RULE: A BUDGET IS ONLY MEANINGFUL FOR WORK THAT CAN BE MADE TO FIT.
Deferring work that can never fit does not protect the deadline -- the work
still runs, later, in one lump -- it only delays everything behind it. Before
gating anything, compare its worst measured step against the available slack.
If the step is larger, the answer is to divide it or to accept its overrun,
never to postpone it.

THE SECOND, HARDER LESSON: the starvation was not caused by the deferrals. It
was caused by an INTERLOCK the deferrals made permanent. Three individually
correct components -- a budget, a single-owner rule, and a request rate --
composed into a system that could not play a note. Per-component gates cannot
see this by construction; each one passed. Only a WHOLE-INSTRUMENT stress run
found it, in one pass, in under a second of its own runtime.

So: a candidate build is not a candidate until the robot harness has played it.
Component gates say the parts are right. They never say the instrument works.

## 64. An acceptance rule can be unpassable, and only a baseline class shows it
PAID 2026-08-19 on silicon (b12), after two builds spent chasing it.

O2's acceptance rule said "miss MUST NOT increment across a program change or
a played note". Two builds were made to satisfy it. The first counted misses
per class; a bare count cannot attribute. The second counted a miss RATE per
class; a rate of a rare event is Poisson-limited and biased by when the classes
occur. Neither could say whether O2 had worked.

The third build measured the MEAN BLOCK DURATION per class, and added a class
that does NOTHING -- `quiet`, blocks with no chunk step at all. That class
answered the question in one line: **an idle block runs 6,001 us against a
5,804 us period**. The deadline was already missed with no O2 work in the
frame, so `miss = 0` was unreachable BY CONSTRUCTION, and the rule had been
asking O2 to remove a miss another track causes.

The same measurement then gave O2 the number it actually needed -- note minus
quiet = 189 us, what one chunked step costs -- and gave O4 its real deficit,
which no cycle count of a patch had produced in three attempts.

THE RULE: MEASURE A PER-BLOCK MEAN OF THE QUANTITY THE DEADLINE IS ABOUT, AND
ALWAYS CARRY A CLASS THAT DOES NOTHING. A count says something happened. A
rate says how often, badly, when the event is rare. A mean with a baseline
says HOW MUCH, and WHOSE.

THE SECOND LESSON: AN ACCEPTANCE RULE WRITTEN BEFORE ITS BACKGROUND WAS
MEASURABLE MUST BE RE-DERIVED ONCE IT IS -- not argued around, and not chased.
Work that cannot pass its own rule is not failing; the rule is.

## 65. Randomising a probe's bases can destroy the condition it is probing for
PAID 2026-08-19 (b13), while deriving O3's parameter map.

`--patch-scan` decides which record positions reach the coefficients, and the
compact patch format's coverage check asserts against its answer. It used six
bases: factory patches 0, 7, 14 and RANDOMISED copies of 21, 28, 35. It
reported EB_RECALL_POS[] stale by four entries, three of them CHORUS PRE DELAY
/ LOW CUT / HIGH CUT.

The scan was wrong. Those three move 4, 5 and 24 bytes of eb_master_coef when
perturbed on FACTORY patch 21 -- executed, all 256 values. They reach the
coefficients only when EFFECT TYPE selects their block, which is true on
patches 21, 28, 35, 49 and 56. **The scan randomised precisely 21, 28 and 35**,
so on those three bases the condition was destroyed; the factory bases that
survived do not select that effect.

THE RULE: RANDOMISED BASES MUST BE ADDITIONAL, NEVER SUBSTITUTES. Randomisation
is added to reach conditions the real data never sets, and it does -- but it
also DESTROYS the conditions the real data DID set, on exactly the samples it
replaces. A probe that randomises over its only examples of a condition cannot
see anything that depends on it, and it reports that blindness as a negative.

THE SECOND LESSON, which is why this cost so little: the disagreement was found
by CORROBORATING A NEW MEASUREMENT AGAINST A PROVEN ONE. A fresh harness and a
checked-in table disagreed by three entries. The reflex is to assume the new
tool is wrong -- and this time the new tool was right about the discrepancy and
WRONG ABOUT THE DIRECTION: its own first conclusion ("those records are dead")
came from copying the old scan's base selection, blind spot included. Both were
settled only by testing the case neither covered.

THE THIRD, AND THE DANGEROUS ONE: the gate was RED and its verdict was a FALSE
ALARM. Acting on it -- deleting four bytes from the patch format -- would have
silently dropped three real parameters. A red gate is a question, not an
instruction. Before deleting anything on a gate's say-so, reproduce the finding
by a second method that does not share the first one's construction.

## 66. A completion is a transition, not a state
PAID 2026-08-19 (b13 §8), in the gate written to guard against playbook 63.

The three-machine interlock gate counted a finished build as "the machine is
idle when a publish happens". Every machine that was NOT running is idle then,
so the counter really counted publishes. It reported 3,053 patch changes
completed out of 378 requested, and the identical 3,053 for parameter
refreshes -- two different subsystems reporting the same number, which was the
only reason it was questioned at all.

THE RULE: TO COUNT A COMPLETION, LATCH THE STATE BEFORE AND AFTER AND COUNT THE
EDGE. A predicate that reads "is finished" is almost always also true of
"never started", and the difference is the entire measurement.

THE TELL, which is worth more than the rule: two independent counters agreeing
exactly is not corroboration, it is a shared cause. When a number matches
another number it has no reason to match, suspect the instrument before the
result -- the same reflex that found the --patch-scan false negative (playbook
65) one measurement earlier.

AND THE DIRECTION: this defect inflated the completion counts. A gate that
over-reports success is worse than one that under-reports it, because nobody
investigates good news.

## 67. Gate the path; then ask what on the DEVICE can drive it
PAID 2026-08-19, on O3, one command before the user flashed it.

The parameter path was designed from two measurements, built, held by 57 teeth
across five gates, compiled for the target and staged for flashing. Nothing on
the device could send it a parameter event. The panel is a later step and no
test stimulus existed, so the build would have printed `PARAM: edits=0` and
been read as "the parameter path is quiet, so it is fine".

THE HOST GATES CANNOT SEE THIS BY CONSTRUCTION. Every one of them CALLS the
path under test directly -- that is what makes them gates. The question they
cannot ask is "what, on the real device, produces this input at all", and
nothing asks it automatically.

THE RULE: A SUBSYSTEM IS NOT READY TO FLASH UNTIL SOMETHING ON THE DEVICE CAN
DRIVE IT, BY ROBOT AND BY HAND. Robot, so it is exercised without a person.
By hand, so it can be investigated when the robot finds something. Add both
before the build is sent, not after the log comes back empty.

⚠ THE PART THAT MAKES THIS ENTRY WORTH ITS NUMBER: the same file already
carried a written warning about the identical defect. Phase 4 of the robot had
been written to submit notes into a live patch build when nothing in the file
ever started one, and its comment names it "the same blind-gate defect as
playbook 60, wearing a stimulus instead of a gate". That comment was READ
during this session, four paragraphs from where the new fix went, and the same
mistake was made on the next subsystem anyway.

So: reading a warning is not the same as applying it. When a file tells you a
defect class was paid for here, ask whether the thing you are adding RIGHT NOW
has it -- that is the only moment the warning is worth anything.

## 68. Read the field's DEFINITION before reading its value
PAID 2026-08-19 (b15), twice in one hour, in opposite directions, while writing
this entry.

The board prints `drift=+150106` and `t=425`. Two conclusions were drawn from
them, both confidently, both wrong:

  b14  read `drift` as MICROSECONDS, called it 150 s by luck, and reported that
       it "confirmed" the mean-block-duration meter to 0.4 %. Right answer,
       wrong reason -- the agreement was arithmetic coincidence.
  b15  "caught" that, read `drift` as MICROSECONDS the other way (0.15 s),
       declared the meter inflated by 3.5 % and the engine healthy, and
       RETRACTED a whole track's target. It also used `t=` as wall-clock
       elapsed to prove it.

The source settles both in two lines:

    rpt_drift = (long)((real_us - audio_us) / 1000);   /* MILLISECONDS */
    sec       = chunks / (SR / CHUNK);                 /* AUDIO time, from
                                                          the BLOCK COUNT */

`drift` is ms: 150,106 is 150 s and the engine really is behind. `t=` is audio
produced, not real time -- so using it to test whether blocks arrive on time is
CIRCULAR, assuming exactly what it was cited to prove. With the definitions in
hand the numbers close to 0.03 %: 73,443 blocks produce 426 s of audio in 446 s
of real time, and the 20 s difference IS the drift counter.

THE RULE: A FIELD'S UNITS AND BASIS ARE PROPERTIES OF THE CODE THAT WRITES IT,
NOT OF THE CONTEXT IT IS READ IN. Open the line that assigns it. This costs
thirty seconds and it is the only thing that worked here.

THE TRAP THAT MADE IT SURVIVE: context supplies whichever reading fits the
conclusion being drawn. b14 wanted confirmation and found it; b15 wanted a
retraction and found that. Neither an agreement NOR a disagreement is evidence
about a field whose definition has not been read -- and an agreement is worse,
because it closes the question.

THE TELL: a "time" field and a "count" field that must be consistent are the
cheapest cross-check on any board -- but only after both definitions are known.
Here the count field was derived FROM the thing under test, so the check had no
independent term in it at all.

## 69. "Probably harmless codegen noise" was the bug reporting itself
PAID 2026-08-19 (b16), while adding a disabled profiler to eb_master.c.

A five-stage profiler was added to the master chain, every macro expanding to
`do { } while (0)` unless EB_MSPROF is 1. The claim was that a disabled
profiler costs nothing, so the host assembly was diffed before and after.

IT DIFFERED BY 341 LINES -- register allocation shifted throughout. The
temptation, and the reasoning that was actually written down first, was:
"statement-neutral text CAN move GCC's allocator, x86 host codegen is not the
target, this is probably noise."

IT WAS NOT NOISE. The macro block had been inserted INSIDE an existing
`#if EB_RING_PROBE` region that is off by default. The definitions vanished;
the CALL SITES, further down the file and outside that region, did not. So
`MSP_T0()` compiled as a call to an undefined function -- which is exactly why
codegen moved, and the trunk gate then failed to LINK:

    undefined reference to `MSP_T0'
    undefined reference to `MSP_HIT'

After moving the block past the region's `#endif`, the assembly diff is ZERO
lines and the claim "free when off" is proven rather than asserted.

THE RULE: WHEN A CHEAP CHECK DISAGREES WITH A CLAIM YOU BELIEVE, THE CHECK IS
THE FINDING. The instinct to explain a small anomaly away is strongest exactly
when the anomaly is small, and "probably harmless" is a hypothesis with no
measurement behind it. Here the anomaly WAS the defect, in full, and reading it
would have found the bug before the gate did.

THE SECOND LESSON, about insertion by script: adding text at a position found
by searching backwards for a comment or a blank line takes NO ACCOUNT OF
PREPROCESSOR NESTING. A block landing inside a disabled `#if` is invisible in
the source diff -- it reads perfectly -- and shows up only as a link error or,
worse, as silently different behaviour in one build configuration. After any
scripted insertion into C, CHECK WHICH #if REGION THE NEW TEXT LANDED IN.

## 70. Gate the configuration that SHIPS, not the one that is convenient
PAID 2026-08-19 (b16), caught before the build was sent rather than after.

The master-chain stage profiler was written with `xthal_get_ccount()` called
directly. That is Xtensa-only, so `make engineb` -- which runs on the host --
could compile it ONLY with the profiler OFF. The OFF path was therefore proven
byte-identical and green, and the build actually flashed, with the profiler ON,
had no gate behind it at all.

That is exactly the wrong way round. The disabled configuration was the proven
one; the shipping configuration was the unproven one.

THE FIX was small: make the clock a PORT DETAIL. `EB_MSPROF_TICK()` defaults to
a plain counter, which is useless as a time but exercises every line of the
accumulation, and the device defines it to its cycle counter. Now the trunk
gate can run with EB_MSPROF=1 and assert the null is still EXACTLY 0 with the
profiler compiled in.

THE RULE: A PLATFORM CALL INSIDE OTHERWISE-PORTABLE CODE SILENTLY MOVES THAT
CODE OUT OF EVERY HOST GATE. One `xthal_`, one `esp_`, one `#include <driver/>`
is enough. Push it behind a macro the port supplies -- not for elegance, but
because the gate cannot see past it, and what the gate cannot compile it cannot
prove.

A SECOND ERROR IN THE SAME MINUTE, worth recording because it is so easy: the
first attempt to run the gate with the profiler on passed
`make engineb EXTRA_CFLAGS=-DEB_MSPROF=1`. This Makefile has no EXTRA_CFLAGS.
The run would have gone green having tested NOTHING, and been reported as
proof. Before trusting a flag-driven run, CONFIRM THE FLAG REACHED THE
COMPILER -- here, by compiling one file and checking the symbol exists.

## 71. A watcher that matches itself never returns
PAID 2026-08-20 (O4), ninety minutes of it.

Wait loops were written as `until ! pgrep -f "make engineb"; do sleep 20; done`.
The WAITER'S OWN command line contains the string "make engineb", so pgrep
matched the shell running the loop. It reported "[gate running]" for ninety
minutes after the gate had actually finished, and three separate wait tasks
spun until they were killed.

THE RULE: A PATTERN MATCHED AGAINST PROCESS COMMAND LINES WILL MATCH THE
PROCESS DOING THE MATCHING. Use `pgrep -x` on the executable, check the exit of
the job itself, or watch the artefact -- the log's own last line and mtime said
"finished at 22:42" the whole time and were never read.

⚠ IT IS THE SESSION'S RECURRING SHAPE, not a shell trivium. A profiler whose
cycle-counter reads sit inside the region it times. A `B4dur` mean argued
against a `t=` field derived from the thing under test. A stimulus phase whose
precondition never occurs. A staleness check that counted its own accessor's
brace. Every one is the instrument entangled with its subject, and every one
cost more than the bug it was hunting.

WHEN A MEASUREMENT DISAGREES WITH REALITY, SUSPECT THE MEASUREMENT'S
INDEPENDENCE FIRST -- before its arithmetic, and long before the system.

## 72. A macro cannot cross a translation unit — the profiler that measured nothing for 52 minutes

**Paid 2026-08-20.** `eb_master.c` carried a five-stage cycle profiler and left
its clock as a port detail:

    #ifndef EB_MSPROF_TICK
    static unsigned long eb_msprof_fake;
    #define EB_MSPROF_TICK() (++eb_msprof_fake)   /* host fallback */
    #endif

The firmware supplied the real clock — in `juno_s3_listen.c`:

    #if EB_MSPROF
    #define EB_MSPROF_TICK() xthal_get_ccount()
    #endif

`eb_master.c` is a **different translation unit**. It never saw that `#define`.
It compiled the stub. The user ran the board for 52 minutes and every report
line read:

    MSP: in=1 delay=1 reverb=1 out=1 effect=1 cyc/sample

Five stages, all exactly 1 — the signature of a counter that steps by one per
read. O4's prediction was left untested and 52 minutes of the user's time was
spent on an instrument that was not connected to its subject.

### Why it survived the gates

Playbook 70 was filed in this same session for the *opposite* error: the tick
was Xtensa-only, so the host gate could only prove the OFF path. The fix made
the tick a port hook — and put the hook in the caller. That made the host gate
runnable and made the DEVICE build silently wrong. **The repair introduced the
defect it was next door to.**

Every gate then passed honestly. The trunk gate proves the null is 0, which it
was. Nothing anywhere asserted that the number printed was a TIME.

### The rules

1. **Select a platform detail in the file that USES it**, from a predefined
   target macro (`__XTENSA__`), never from a `#define` in a caller. A caller's
   macro reaches its own TU and no other. If a hook genuinely must come from
   outside, it must arrive as a **compile definition** or through a **header
   both units include** — those cross; a `#define` in a `.c` does not.
2. **Prove the selection in the artefact that ships.** The check that would
   have caught this costs one command:

       target-gcc -DEB_MSPROF=1 -S eb_master.c  ->  6 rsr.ccount sites, 0 stub
       target-gcc              -S eb_master.c  ->  0 rsr.ccount sites

   Compiling for the host proves the host arm. Only target assembly proves the
   target arm.
3. **A measurement must be able to say it is broken.** The board now prints
   `MSP: *** BROKEN` when every stage reads <=1. A stub clock has a signature;
   detect the signature. Cf. playbook 46 (a number quoted N times is not
   thereby measured) and the standing rule that every tooth must be SEEN TO
   FAIL.
4. **Do not drag a platform's headers into the engine to get one register.**
   `<xtensa/hal.h>` lives in an ESP-IDF component; including it would have made
   `engine_b/` depend on the device tree. One `rsr.ccount` in inline asm has no
   such cost.

### The shape, which is now four deep in one session

67 (a knob with no source), 69 (a probe inside a disabled `#if`), 70 (a gate
that could only prove the unused path), 72 (a clock wired to the wrong TU).
Each is an **instrument that did not reach its subject**, and each passed every
gate aimed at the subject. The gates were pointed at the engine; nothing was
pointed at the instrument. **Gate the instrument as an artefact in its own
right, or it will read plausibly and mean nothing.**

## 73. `idf.py` returned EXIT 0 on a FAILED build, and a stale ELF passed the check

**Paid 2026-08-20, minutes after 72.** Two `idf.py build` runs were left going
in the SAME build directory at once. They clobbered each other's CMake state:

    CMake Error: Cannot find component list file
    ninja: error: rebuilding 'build.ninja': subcommand failed
    ERROR: ninja failed with exit code 1
    [exited with code 0]          <-- idf.py's own exit status

**The build failed and the command succeeded.** `build/juno_s3.elf` was left as
the PREVIOUS build's artefact, and it was newer than nothing that mattered.

### The check that passed, and why it was worthless

The playbook-72 check was run against that stale ELF:

    ccount reads in eb_master_render : 6      GREEN
    eb_msprof_fake symbol            : 0      GREEN

Both true — of the OLD image. 72's own lesson had just been filed and the check
it produced was aimed at a feature the old build ALREADY HAD. A verification
that the previous artefact also satisfies proves nothing about this one.

What caught it was a check for the string the NEW code adds:

    strings build/juno_s3.bin | grep 'MSPP: pat='   ->  0

### The rules

1. **Never run two builds in one build directory.** Serialize, or give each its
   own directory. A build system's incremental state is not concurrency-safe.
2. **Do not judge a build by its exit status.** `idf.py` returns 0 on a ninja
   failure. Grep the output for the success line AND inspect the artefact.
3. **A post-build check must test something the PREVIOUS artefact lacked.** Any
   assertion an older image also satisfies cannot detect a build that did not
   run. Pick a string, symbol or instruction the new code introduces.
4. **Check freshness explicitly**: `[ build/x.elf -nt src/changed.c ]`.

### The session's shape, restated

67, 69, 70, 72 were instruments that did not reach their subject. 73 is the
same failure applied to a VERIFICATION: the check did not reach the artefact it
was believed to describe. **Verifying the report instead of the thing is the
defect, whether the report is a log line, a gate, or an exit code.**

## 74. `git add -A` during a gate run committed the gate's own planted defect

**Paid 2026-08-20.** The worst defect of the session, and it reached the branch.

`chunk_teeth.sh` proves its detector by PLANTING faults into the checked-in
`engine_b/dev/eb_recall.c`, running the gate, and restoring the file. Tooth 2
replaces the shared FX/noise tail build with `(void)0;` — a full patch recall
that never builds its FX tail. It is correctly written: it snapshots the file,
and a `trap ... EXIT INT TERM` restores it.

While that suite was mid-flight, an unrelated documentation commit was made
with `git add -A`. It swept up the planted line. **`(void)0;` — a deliberate,
audio-breaking defect — was committed and pushed.**

### And then the recovery made it worse

After the suite finished it restored the real call, which now showed as a diff
against the poisoned commit. That diff was misread as "the tooth is still in
the tree", and `git checkout -- engine_b/dev/eb_recall.c` was run to "clean up"
— **destroying the correct code and reinstating the plant.**

Recovered by taking the file from the last commit that predates the poisoning
(`git show <good>:<path> > <path>`) and diffing to confirm it is identical.

### The rules

1. **NEVER `git add -A` while any gate is running.** The FREEZE rule already
   said do not edit the tree during a gate; it did not say the tree is being
   edited BY the gate. It is. Gates that plant teeth make the working tree
   theirs for the duration. Check `git status` is clean, or that no gate is
   running, before staging anything.
2. **Stage by path, not by sweep**, when any doubt exists. `git add <the files
   you edited>` cannot pick up a plant in a file you never touched.
3. **A diff appearing during or after a gate run is not evidence of which side
   is correct.** Determine the correct content from a commit known to predate
   the gate, never from the direction of the diff. `git checkout --` resolves
   toward HEAD, and HEAD is exactly what may be poisoned.
4. **A file a tooth plants into must be verified against a known-good commit**
   after any suite run, not merely observed to be clean.

### Why nothing downstream trusted it

The gate suite still read ALL GREEN, because the gates ran against the restored
file. Green did not mean the tree was sound. That is the session's shape once
more (67, 69, 70, 72, 73): the report was about something other than the
artefact in hand.

## 75. The checksum that covered itself — a detector wrong in the direction that rejects good input

**Caught in review, 2026-08-21, AFTER the build had been sent to the user.**
The two-chip link frame ended in its checksum:

    typedef struct { ...six bytes... ; uint16 patch; ulong crc; uint16 sum; }
    for (i = 0; i < sizeof(frame) - sizeof(sum); ++i)  /* <- the defect */

Struct tail padding made `sizeof - 2` LARGER than `offsetof(sum)`, so the
summed range included the `sum` field itself. The sender computes the checksum
while the field is still zero; the receiver computes it over the filled field.
**Every frame is rejected. Two perfectly wired boards report NO PEER forever**
— on the exact build whose purpose was to prove the wire. The bench diagnosis
would have read "bad wiring", and the wiring would have been fine.

A second defect in the same struct: `unsigned long` is 4 bytes on the S3 and 8
on the host, so a host gate would have gated a DIFFERENT LAYOUT than the wire
carries — a gate aimed beside its subject (the 70/72/73 species again).

### The rules

1. **A trailing checksum covers `offsetof(sum)` bytes, never `sizeof - N`.**
   Padding makes the two differ, and the difference puts the checksum inside
   its own coverage.
2. **Wire structs use fixed-width types only.** `long` across host and target
   is two layouts with one name.
3. **A codec's FIRST gate case is the clean round trip.** Corruption tests
   check rejection; the shipped defect was in ACCEPTANCE, and a suite of
   corruption tests alone would have stayed green while every good frame died.
   Both directions are toothed now (d1_link_gate tooth 4 re-computes the old
   sizeof-2 checksum and requires the round trip to fail).
4. Protocol code written for hardware that does not exist yet gets its codec
   executed on the host BEFORE the image ships, not after. The direction
   table and handshake were gated; the byte-level codec was not — the gap was
   exactly the ungated layer.

### Why review caught it and no gate did

The frame codec lived in the ESP-only header, out of reach of the host gates,
and nothing on a desk can run a UART. The fix moved the codec into the
portable header where d1_link_gate executes it. The lesson is 74's, restated
for protocols: gate every layer you CAN before touching the layer you cannot.

## 76. The one-run extractor that lost 132 of 185 methods — and the band that got them back

**Caught by the extractor's own completeness check, 2026-08-22, on the JX-3P
first IDA dump — before any transcription.** `ida_extract_all.py` discovered its
targets two ways: a call-graph closure DOWN from the DSP vtable methods, and a
blanket `.rdata` function-pointer sweep, unioned and capped at 6000 functions.
The dump came back with the entire FltVoice (24/24), LfoVoice (13/13), AmpVoice
(12/12), EnvVoice (11/11), EfxCh and EfxPh voices **absent** — 132 of 185
concrete DSP methods had no decompile, and 135 were not even in the disassembly.

Two failures compounded:

1. **The render leaves are reached by INDIRECT dispatch, not direct calls.**
   Measured on the JUNO: a direct-call closure from every DSP method reaches 154
   functions and NONE of the four hand-found leaves (voice render, master,
   parameter registry, chorus-coefficient gen). A call-graph walk was never
   going to find them; the fptr sweep was the patch for that, and it was the
   wrong patch.
2. **The fptr sweep + cap is a truncation machine.** The sweep harvested 275+
   JUCE/Gdiplus/CRT function pointers; the 6000 cap then evicted real DSP as the
   graph fanned out through the GUI. A cap on a graph walk cannot be trusted to
   keep the subset you care about — set membership was decided by traversal
   order, not by relevance.

### The fix — geometry, not graph-reachability

MSVC lays a class's methods and the non-virtual helpers they dispatch to into
ONE contiguous slab of `.text`. So the completeness guarantee is an ADDRESS
BAND, from the lowest DSP method to the highest parameter-class method,
±0x10000 — a bounded range that physically cannot lose a method. Proven before
re-running IDA: JUNO band = 1282 functions, all four leaves + BUILD +
NOTEON/NOTEOFF IN, 44,000 CRT/GUI OUT; JX band = 1291 functions, every method
plus the master process the bad dump missed IN. Call-graph closures stay only
as belt-and-suspenders for a straggler outside the slab.

### The rules

1. **A "get everything" extractor states its completeness invariant and checks
   it in the tool, in the window, before the artifact leaves the machine.** The
   self-check that printed `53/185` is the only reason this cost one re-run
   instead of surfacing as wrong coefficients three sessions later.
2. **Prove a discovery strategy against a binary whose answers you already know
   BEFORE spending the user's one expensive run on the binary you don't.** The
   band was validated on the JUNO's four known leaves first; the JX run was
   never speculative.
3. **A cap on a graph walk is a silent truncation. Bound coverage by an address
   range you can measure, not a count you hope is large enough.**
4. **When the thing you need is reached by indirect dispatch, stop trying to
   follow the call and enclose the region instead.** Reachability failed;
   geometry held.

## 77. The link CRC that could never match — a stream compared by chunk

Paid 2026-08-23, on the FIRST real two-chip wire. The audio-link proof was
"B advertises the CRC of each chunk it sends; A CRCs the chunk it received;
match opens the mix." On the bench: handshake OK, rx counting cleanly,
short=0 — and EVERY CRC bad, forever. Nothing was wrong with the wire.

I2S is a CONTINUOUS stream. A's DMA chunk framing starts when A's channel
starts; B's when B's does. The two framings sit at a constant, arbitrary slot
offset — so the two CRCs are computed over SHIFTED windows and can never be
equal. The host gates fed both sides the same aligned buffer, so this defect
was structurally invisible to them; only the wire could show it.

The fix exploits the same fact that caused it: ONE bit clock drives both
framings, so the offset is CONSTANT. `s3_lock_search` (s3_link.h, pure,
host-gated) scans the received history for a window whose CRC matches an
advertised one; the hit offset is discarded from the stream ONCE and every
later chunk is aligned — the original design then works as written.
Gate: tools/engineb/lock_search_gate.c, all 512 offsets, tooth = off-by-one
re-frame goes red. In o6_gates.sh.

### The rules
1. **A chunk is a unit of YOUR bookkeeping, not of the transport.** Any
   equality check across two independently-framed views of a stream must
   first prove the framings coincide — or search for the offset.
2. **A host gate that hands both sides the same buffer has assumed away the
   transport.** Name the assumption in the gate header, and list what only
   the physical medium can falsify (framing, polarity, bit order, clocking).
3. When a wire-proof fails with clean counters everywhere (rx up, short=0,
   handshake OK), suspect the COMPARISON before the wire: re-seating cannot
   fix a windowing defect, and one reseat is enough to know.

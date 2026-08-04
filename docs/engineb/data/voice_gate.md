# 1b-0 — the VOICE-LEVEL gate: engine B's render function, executed at last

Date 2026-08-04 (Opus 5), executing the ruling in `PHASE1_ORDERS.md`.

## The result, first

**`null_b.py --module voices`, all 30 scenarios, EXACTLY 0 against the port, at
BOTH 44,100 and 48,000 Hz.**

`eb_engine_render_voices()` — the sixteen gated modules plus the wiring between
them, driving engine B's OWN state from an `eb_render_coefs` built by
`eb_render_coefs_build` — reproduces the port's eight per-voice samples bit for
bit, on every sample of every scenario, including the five idle-prefix lengths.

## What this is NOT

It is the WEAKER gate, and the ruling labelled it so before it was built:

* **The master chain is still the port's.** Engine B's voice samples are fed
  into `juno_master_render` exactly as the port's were. The voice summing, the
  EFFECT-TYPE routing, the gain staging, the boost/output path and the stereo
  assembly are untranscribed (the scope finding: 946 of ~1,333 executable lines
  of `master_render.c`, 540 cells). `eb_engine_render`'s own mix and FX calls
  are not reached by this gate at all.
* **Recall is still the port's.** Coefficients come from the port's recalled
  cells. `eb_patch` is a separate, later, separately gated job.
* **The at-rest shortcut is still unproven.** The shim holds every voice awake,
  so `eb_render.c`'s `atrest` branch is not exercised here.

`render_ok` therefore stays unset in the shipped engine. This gate is 1b-0; the
standalone gate is 1b-2, after the master transcription (1b-1).

## The defects it found, which is why it was ordered

Eight wrong module inputs had already been found in `eb_engine_render` by
READING it. Running it found four more, and two of them were silent.

**1. The DCO oscillator levels were cached from the wrong cells (SILENT).**
`eb_coefs.c` gathered cells 4736/4752/4768 because the dco SHIM gathers them —
correctly, for the shim, which runs inside the port at a point where they have
already been written this sample. `src/voice_render.c` WRITES all three every
sample, at :1702-1707. Cached from a power-on state they are 0, so the DCO
emitted exactly 0 on every sub-sample and the whole chain nulled at 0.0 dB rel —
silence. The real chain is same-sample and lag-free: recall cell 4192 → 4240
(:1126) → v393 (:1667) → 4736 (:1702), all before the DCO reads it. 4192/4208/
4224 have no writer in the voice function and are the coefficients.

**WHY THE EXISTING CHECK MISSED IT, and this is the transferable part.**
`eb_coefs.c`'s header claimed every cell had been checked for a writer. The
check was `grep 'JF(a1, N) ='`. All three of these cells are copied as INTS,
with `JI`. **A cell-writer audit that names only one accessor is not an audit.**
`tools/engineb/coef_audit.py` now performs it mechanically, both accessors,
scoped to the constructor.

**2. Cell 5456 was cached too (LATENT).** Found by that new audit, not by ear
and not by the null. It is `eb_dcoprep`'s third output — `fmaxf(0, (cell3776 +
k6304) * k6320 + k6288)`, derived from the modulated pitch sum — and the
decimator's per-sample feedback term. `eb_render.c` discarded it as
`(void)pwm_out` while the decimator read a cached copy. MEASURED: fixing it
changed no sample of any scenario, so it was latent, not active — cell 5456 does
not move in the thirty scenarios. **The decim SHIM caches it behind the
generation guard too, and its null is EXACTLY 0, so that gate is blind to this
cell by scenario coverage rather than by construction.** `k5456` is now a
per-sample ARGUMENT to `eb_decim_tick`, so the type system refuses the mistake.

**3. The retrigger one-shot belonged to nobody.** Port cell 101504+v*32 is read
at :589 and cleared at :2178 — both OUTSIDE every module boundary. When armed it
forces that sample's cell-320 read to 0.0. No module claimed it, so a standalone
engine would silently never retrigger: the MONO-retrigger defect (e611f7d) all
over again, and invisible to every cold scenario. It is now `aux_edge` in
`eb_render_state`, consumed in the voice loop.

**4. THE LOCKSTEP DEFECT, and it is the one worth remembering.** Engine B's
state lives in file statics; the render worker creates one context per scenario
and renders all thirty IN ONE PROCESS. Without a per-context re-seed, scenario 1
seeded engine B and scenarios 2..30 inherited scenario 1's ENDING state.
MEASURED while it was live: **scenario 1 nulled EXACTLY 0 and all 28 others
failed from their very first frame, the first differing sample being 42000 —
exactly scenario 1's length.** It looks precisely like a broken DSP chain and is
nothing of the kind. Re-seeding is keyed on a marker in the unused tail of the
12 MB state block, not on the state POINTER: a freed block's address is readily
reused. `juno_driver_attach_host` is also called on re-init and on a chorus-mode
change, and those must NOT re-seed — re-seeding free-run state mid-scenario is
exactly what would mask a lockstep defect.

## Teeth

MEASURED at 48 kHz over all 30 scenarios.

| case | result |
|---|---|
| `out:voices:(1+3.16e-5)` | FAIL, −90.0 dB, 30/30 scenarios |
| `out:voices:(1+3.16e-6)` | PASS, −109.8 dB |
| `voicereseed` (lockstep: never re-seed a new context) | must FAIL |
| `voiceidleskip` (a gate-closed voice skips its state advance) | must FAIL |

`voicereseed` plants defect 4 above. A defect this harness actually let through
once is now a case it must catch every run.

**A THIRD "teeth case that could not reach its own mutation."** The output
anchor's perturbation is inserted on the line after the assignment, and the
crossing loop had no braces — so the statement landed outside the loop with
`v == JUNO_NUM_VOICES`, wrote one past the end of `vbuf`, and perturbed nothing.
MEASURED in that state: both bracket factors gave a residual of EXACTLY 0. The
uniqueness assert passed, because the anchor DID match once. **Matching is not
reaching.** The braces are now load-bearing and commented as such.

## Files

* `engine_b/eb_render.{h,c}` — `eb_engine_render_voices()` split out; the aux
  one-shot; `eb_engine_render` is now that plus the mix and the FX.
* `engine_b/eb_coefs.{h,c}` — the two cell corrections and
  `eb_render_events_mirror()`.
* `engine_b/eb_decim.{h,c}` — `k5456` promoted to a per-sample argument.
* `engine_b/shim/voices/juno_driver.c` — the shim, with its own scope note and a
  live differential tap (`-DEB_VOICES_DEBUG`) that runs the port's voice
  function alongside engine B's and reports the first differing (sample, voice).
  That tap is what isolated defect 4; it always emits ENGINE B's samples, so no
  build of it can pass vacuously.
* `tools/engineb/coef_audit.py` — the constructor's cell-writer audit.
* `tools/engineb/merge_shims.py` — whole-chain shims are excluded from the
  composite by name, with the reason.

## Groundwork for 1b-1 (measured, not yet transcribed)

The first master block was chosen the way every voice module's boundary was
chosen — by a live-variable analysis, not by eye.

**`src/master_render.c:826-886` — the MASTER INPUT STAGE: ZERO live-in, three
live-out (`v36`, `v38`, `v5`), 40 cells touched, 26 written.**

That is the same shape that made `eb_lfo` lift (four live-in, zero live-out).
It is the voice summing, the per-pair gain staging and the two channel signals
(cells 101104 and 101120) that the DELAY routing switch at :887 consumes.
`juno_host_sel(a1, 136)` at :887 is the natural end of the block: it is the
EFFECT/DELAY-TYPE routing read, and the routing switch belongs to the next
block, not this one.

The 26 written cells still need the read-before-write classification and the
FOUR LIES check before any of them may be called a coefficient — and the DCO
oscillator-level defect above is the standing reason to run
`coef_audit.py`-style checking on BOTH accessors, since `master_render.c`
copies with `_DWORD` as freely as `voice_render.c` copies with `JI`.

### The measured cut map for the whole master chain

`tools/engineb/master_cuts.py` reports the CUT WIDTH at every line of
`juno_master_render` — the number of decompiler locals assigned before that line
and read after it. The voice modules were carved this way and the master must be
too; a range with a wide cut is not a module, it is a marshalling exercise.

MEASURED: 2,120 executable lines, 754 locals, and the function cuts into roughly
fourteen blocks with only **2 to 6 locals crossing** each boundary:

```
  :826     0 crossing   (function entry)
  :886     3            end of the master INPUT STAGE
  :942     4
  :1043    6
  :1548    6
  :1656    6
  :1747    6
  :1858    6
  :1959    4
  :2015    5
  :2066    4
  :2107    5
  :2278    6
  :2337    4
  :2378    2            v551 = juno_host_sel(a1, 112)  <- the EFFECT-TYPE routing read
  :2427    4
  :2497    3
  :2550    6
  :2632    3
  :2679    3
  :2744    3
  :2784    4
  :2827    4
  :2868    2
  :2941    0            the stereo output assembly
```

Two of these are worth naming now. **:2378 is the EFFECT-TYPE routing read** —
the `v551` arm this project already learned is load-bearing warm (the WARM
parity block in CLAUDE.md), and it has the narrowest interior cut in the whole
function at 2. **:2941 cuts at 0**, so the stereo output assembly lifts as
cleanly as a block can.

This map is the ROUTE for 1b-1, not the work. Every chosen range still needs its
cells classified read-before-write with all FOUR LIES checked, and
`master_render.c` copies with `_DWORD` exactly as freely as `voice_render.c`
copies with `JI` — which is how the DCO oscillator levels were missed above.

---

# 1b-1 — the master chain, first blocks (Opus 5, 2026-08-04)

## Done and gated

| module | port range | null | teeth bracket @48k |
|---|---|---|---|
| `master_in` | `:826-886` | **EXACTLY 0**, 30 scenarios, 44.1k AND 48k | 3.16e-5 FAIL −90.0 dB 30/30 · 3.16e-6 PASS −109.8 dB |
| `master_out` | `:2338-2377` + the `:2941-2943` tail | **EXACTLY 0**, 30 scenarios (both rates: see below) | 3.16e-5 FAIL −90.0 dB 30/30 · 3.16e-6 PASS −109.8 dB |

Both brackets are MEASURED, and measuring them is also what proved the two new
teeth anchors reachable — the residual moved, so the mutation was planted where
it claims to be. That check exists because this harness has now had three cases
that matched their anchor and reached nothing.

## Two rules the master chain has already taught

**1. A read-before-write scan of one block is not a classification.** Cells
84672 and 84704 are read at the top of `master_in` and WRITTEN at :2496, :2625,
:2747, :2936 and :2940 — by the chorus/output stage, at the far end of the same
sample. Scanned inside `:826-886` alone they look exactly like coefficients.
They are cross-sample feedback. The scan has to cover the whole function.

**2. A shim may cache COEFFICIENTS in file statics. It may never hold STATE
there.** `master_in`'s first version kept its one-pole history in a static; the
null worker renders all thirty scenarios in one process, so scenario 2 onward
inherited scenario 1's history. MEASURED: 7 scenarios failed at worst −63.5 dB,
every one of them a small-signal noise case. Same class as the voices shim's
missing per-context re-seed, reached by a different route, one day apart. State
lives in the port's cell and is copied in and out per sample, as the other
shims do.

Also worth keeping: two plausible causes were killed by measurement rather than
argued away. Restoring all 23 dropped dead stores changed nothing, and a
line-by-line differential of the module against the port's own code showed zero
difference on every sample. Neither was the fault, and guessing would have
"fixed" the wrong thing.

## The cut map needed one correction, and the routing region is bigger than it
## looks

The map's zero-width cut at :2941 suggested an "output assembly" module. It is
three lines — `out = cell + cell` on two cells — with no arithmetic worth a
call. It is folded into `master_out`, which writes those cells, exactly as
`eb_dcoprep` folded the port's arithmetic-free :1665-1671.

**The `v551` routing switch at :2378 is NOT a block.** MEASURED: it opens a
~562-line region running to :2939 with several `v551` arms, `goto LABEL_164`
and `goto LABEL_205` control flow, and the already-claimed M-CHORUS module
inside it. The narrow cut the map reports at :2378 is the cut at the switch
STATEMENT, not the extent of what the switch governs. It needs to be carved
into arms, and the warm-state hazard applies to all of them (the v551 arm is
load-bearing warm — see the WARM parity block in CLAUDE.md). It is the largest
single piece of 1b-1 and it is deliberately NOT started here.

## Remaining for 1b-1

* the `v551` routing region `:2378-2939`, in arms
* the middle blocks between `:887` and `:2337`, narrowest cut first
* a full `--teeth` battery run once the middle blocks land (the two new
  brackets are measured; the battery itself was last run green before them)

## ★ THE GATE WAS BLIND TO HALF THE MASTER CHAIN (measured before writing any
## arm module)

`src/master_render.c` is not one signal path. Two host-selector switches choose
between whole alternative algorithms:

```
v39  = juno_host_sel(a1, 136)   :887    DELAY TYPE  (slot 1)
v551 = juno_host_sel(a1, 112)   :2378   EFFECT TYPE (slot 2)
```

MEASURED with the thirty inherited scenarios, by counting samples per arm
through the port's own code (`tools/engineb/arm_coverage.py`):

| switch | reached | NEVER reached |
|---|---|---|
| DELAY TYPE | 0, 1, 5 | **2, 3, 4** |
| EFFECT TYPE | 2, 3, 5 | **0, 1, 4** |

**A module written for an unreached arm cannot be gated at all.** The null would
compare two code paths neither of which runs and report EXACTLY 0 — for the same
reason a disconnected meter reads zero. Half of 1b-1's remaining work sat behind
that.

Closed with REAL factory patches, measured by recalling all 64 and reading
`JUNO_PROG_DLY`/`JUNO_PROG_EFX` — not synthetic parameter edits:

* patch 11 → DELAY 2 · patch 19 → DELAY 3 · patch 9 → EFFECT 1

Patch 9 is the ONLY patch in the whole bank with EFFECT TYPE 1 and its
arpeggiator is on, so an arp scenario is the only route to that arm; both sides
run the port's own arpeggiator, so the comparison stays deterministic.

**HONESTLY STILL UNREACHABLE: DELAY 4, EFFECT 0, EFFECT 4.** No factory patch
selects any of them, and EFFECT 4 (FLANGER) is additionally documented as
engine-unreachable under recall. They need a synthetic-recall gate of the
`etmode_ab.py` kind, and **no module may be written for them until one exists.**
`arm_coverage.py` distinguishes the two cases and only fails on an arm a patch
could actually select.

## The DELAY dispatch is not five parallel arms

Reading the control flow rather than the line ranges:

```
if (v39 == 1)      { :889-1051   type-1 pre-stage }
if (v39 <= 1)      { LABEL_69: :1054-1267  THE SHARED CORE -> LABEL_105 }
else if (v39<=3)   { :1271-1452  type-2/3 algorithm }
else if (v39 != 4) { if (v39==5) { :1458-1866 type-5 -> LABEL_105 }
                     goto LABEL_69;  /* >=6 uses the shared core */ }
else               { :1870-2076  type-4 algorithm }
LABEL_105: :2077...
```

So types 0, 1 and >=6 SHARE a core, and that core is already the claimed
`eb_delay` module. The unclaimed delay work is four pieces, not five:

| piece | lines | gateable today |
|---|---|---|
| type-1 algorithm `:890-1048` | 159 | yes (see the correction below) |
| type-2/3 `:1271-1452` | 184 | **yes, newly** |
| type-5 `:1458-1866` | 409 | yes |
| type-4 `:1870-2076` | 207 | **no — needs a synthetic gate** |

The type-2/3 arm's live-in is `v36`/`v38` — exactly `eb_master_in`'s two
outputs, so the module chain already lines up.

## The DELAY arms share ONE interface

MEASURED for all three unclaimed reachable arms:

| arm | lines | cells touched / written | live-in | live-out |
|---|---|---|---|---|
| type-1 pre-stage `:889-1051` | 163 | 67 / 33 | `v36 v38 v5` | `v176 v177 v56 v58` |
| type-2/3 `:1271-1452` | 184 | 83 / 41 | `v36 v38 v5` | `v176 v177 v56 v58` |
| type-5 `:1458-1866` | 409 | 170 / 101 | `v36 v38 v5` | `v176 v177 v56 v58` |

Every arm is the same function shape: `(v36, v38, v5) -> (v176, v177, v56, v58)`,
where `v36`/`v38` are exactly `eb_master_in`'s two outputs and `v5` its
coefficient `k84496`. So the delay dispatch is POLYMORPHIC: one call signature,
several implementations, selected by `v39`. Engine B can mirror that directly —
one `eb_delay_arm_*` per type behind a single call — and the arms are mutually
exclusive at runtime, so they cost flash and not per-sample time.

### ⚠ A LIMITATION OF `master_cuts.py`, found while using it

Its live-out set is an OVER-APPROXIMATION. It reports a local as live-out if the
block assigns it and ANY later line mentions it — it does not check whether the
successor ASSIGNS the local before reading it. For the two arms that
`goto LABEL_105` (type-2/3 and type-5) that makes no difference: they jump past
everything between. **For the type-1 pre-stage it does**, because control falls
through into the shared core at LABEL_69, which assigns `v176`/`v177` itself.
So the pre-stage's true outputs are NOT yet known and must be derived by an
assignment-before-use analysis of the shared core before that arm is
transcribed. Recorded rather than discovered later by a null that will not
close: a boundary tool that flatters its block deserves the same suspicion as a
gate that never fails.


## ★ CORRECTION: the DELAY dispatch, read properly

An earlier note here said types 0, 1 and >=6 SHARE the core at LABEL_69, making
`:890-1048` a "type-1 pre-stage". **That is wrong.** Line 1049-1050 is `}`
followed by `else`: type 1 does NOT reach the core. The core serves type 0 and,
via `goto LABEL_69`, types >= 6. `:890-1048` is the COMPLETE type-1 algorithm.

How the error was caught is the useful part. Taking the fall-through reading at
face value, `v176`/`v177` assigned at :1046-1047 would be dead, because the core
assigns both unconditionally at :1266-1267 (and `v56`/`v58` at :1177/:1182). I
checked that much and it held. Then I asked which of the block's 33 written
cells anything later reads, and the answer was **none** — which would make the
whole block a no-op. That is the result that did not add up, and disbelieving it
is what sent me back to the control flow.

MEASURED confirmation, after the fact: perturbing this module's `v176`/`v177` by
3.16e-5 is caught by **10 of the 33 scenarios**. Dead values catch nothing.

**The module was correct the whole time**, because it reproduces what the port
does rather than acting on a liveness conclusion — a choice made before the
conclusion turned out to be wrong. Two tools pointed the wrong way here
(`master_cuts.py` over-approximates live-out, and a "nothing reads these cells"
scan invites a no-op conclusion); reproducing the port is what made that
survivable.

## 1b-1 status

| module | port range | null |
|---|---|---|
| `master_in` | `:826-886` | EXACTLY 0, both rates |
| `delay_t1` | `:890-1048` | EXACTLY 0 |
| `delay_t23` | `:1271-1452` | EXACTLY 0, both rates |
| `delay_t5` | `:1459-1866` | EXACTLY 0, both rates |
| `master_out` | `:2338-2377` + tail | EXACTLY 0, both rates |

All three REACHABLE delay arms are now modules.


## O2 COMPLETE — the master chain is 82 % claimed, and the rest is unreachable

Both reachable EFFECT arms are modules too: `eb_fx_e1` (`:2381-2497`) and
`eb_fx_e5` (`:2633-2748`), each EXACTLY 0. Both take cell 84624 — the master
input stage's one-pole output — as an ARGUMENT, because `arm_xform.py`
classified it EXT: written by another block earlier in the same sample. Caching
it would have been the eb_master_in mistake a third time; the tool refuses it by
construction now.

Both arms also carry `v593`, an int-declared local holding FLOAT BITS, so the
shim bit-copies it out instead of assigning. Assigning would convert and destroy
it — the same trap that made the type-5 arm's output exactly zero.

MEASURED claim of `juno_master_render` (2,119 executable lines):

| | lines | share |
|---|---|---|
| claimed by engine B modules | 1,737 | **82 %** |
| unclaimed, in arms NO factory patch can select | 331 | 16 % |
| dispatch glue | 51 | 2 % |

The scope finding that opened 1b-1 measured 22 %. **Everything still unclaimed is
unreachable**: the DELAY type-4 arm (`:1870-2076`) and the EFFECT `LABEL_164`
core (`:2503-2626`, serving EFFECT 0 and >= 6). Neither can be gated until a
synthetic-recall gate of the `etmode_ab.py` kind exists, and no module may be
written for them before then.

**The composite — all 16 voice modules AND all 10 master modules together —
nulls EXACTLY 0.**

Teeth brackets, all MEASURED at 48 kHz, all 3.16e-5 FAIL / 3.16e-6 PASS:
`master_in` −90.0, `master_out` −90.0, `delay_t23` −90.0 (2 scenarios),
`delay_t1` −90.0 (10 scenarios), `delay_t5` −90.0, `fx_e1` −93.2 (1 scenario),
`fx_e5` −93.6 (1 scenario). The small catch counts are not weak coverage — they
are the whole of it. EFFECT TYPE 1 has exactly one patch in the entire bank.


## ★★ A CORRECTION I HAVE TO MAKE, AND THE TRAP BEHIND IT

Earlier in this document and in two commit messages I wrote that the EFFECT arms
null "EXACTLY 0 on all 33 scenarios". **That was measured with `--quick`, which
renders 32.** The scenario `--quick` drops is `long LFO+tail` — and MEASURED
from the teeth, that is the ONLY scenario in the whole set that exercises
`fx_e5`. So the quick PASS for that module was **vacuous**: the arm never ran.

The full run failed it at −5.7 dB, and the module was genuinely wrong.

**THE RULE, and it is now the only safe one: a module result may never be quoted
from a `--quick` run.** `--quick` exists to shorten iteration, and for a module
whose only exercising scenario is the long one it measures nothing at all. The
`--teeth` catch counts are what reveal this: an arm caught by ONE scenario is
one `--quick` away from being ungated.

### The defect it was hiding: a third form of the int/float trap

```c
*(_DWORD *)(a1 + 96160) = LODWORD(v553);   /* the port: store a float's BITS */
s->s96160 = LODWORD(v553);                 /* the module: CONVERTS them      */
```

MEASURED: cell 96160 read back **947597056** where the port had **5.99e-05** —
the integer value of the float's own bit pattern.

`carriers()` cannot catch this one. `v553` is used in arithmetic elsewhere, so
it is not a pure bit carrier; only this one STORE is a bit operation.
`arm_xform.py` now rewrites `s->sN = LODWORD(vX);` into `memcpy(&s->sN, &vX, 4)`,
which is correct whatever the field's declared type.

That makes three distinct forms of the same underlying trap found in one
session — a cached per-sample cell, a pure bit-carrier local, and a `LODWORD`
store — each of which produced a green gate before it produced a red one.

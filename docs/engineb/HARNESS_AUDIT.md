# Harness audit — engine B gates

Date 2026-08-02. Every finding below is MEASURED by execution. Nothing here is
from reading the code.

The reason for the audit: almost every error this project has made came from the
harness, not from the engine. This audit looks for that class only.

---

## F1 — SHIM COLLISION. Composite builds linked 2 modules of 10. **FIXED, and the whole-engine test now exists.**

`null_b.build()` overlays each module's shim onto `src/` with `copyfile`. Six
modules ship their own `voice_render.c` (dco, env, pwm_cv, vca_hpf, vcf_cv,
vcf_ladder) and three ship their own `master_render.c` (chorus, delay, reverb).
The second write destroyed the first. An alphabetical `--module all` build
therefore linked **vcf_ladder's voice path and reverb's master path only**, and
still reported all ten modules by name.

PROVEN with a counter planted in `eb_dco_step`, over the 30-scenario set:

| build | `eb_dco_step` calls |
|---|---|
| `--module all` | **0** |
| `--module dco` | **60,989,440** |

Effect: every whole-engine claim is withdrawn. Per-module gates are unaffected —
one module shadows one file. `--check-port` is unaffected — it substitutes
nothing.

Fix, part 1: a collision is now a hard build failure that names both modules.

Fix, part 2 — **engine B has now been tested as a whole engine, for the first
time.** `tools/engineb/merge_shims.py` GENERATES one composite shim,
`engine_b/shim/engine_all/`, by applying each member's edit regions to one copy
of the port file. The regions are disjoint, and the generator CHECKS that rather
than assuming it: overlapping shims are a hard stop naming both, never an
automatic resolution. `make engineb` regenerates the composite before any null
runs, and `--check` fails on a stale one, so it cannot drift from its members.

RESULTS, and both were verified by coverage rather than by the label — which is
the mistake that started this audit:

| comparison | result |
|---|---|
| whole engine vs the **plugin** (authority), 11 scenarios, 5 with idle prefixes | **11/11 BIT-EXACT** |
| whole engine vs the port, 30 scenarios | **EXACTLY 0 everywhere** |

Coverage of the composite build over the full 30-scenario set: eb_delay 100 %,
eb_chorus_shim 96.5 %, eb_chorus 96.1 %, eb_reverb 93.6 %, eb_vca_hpf 91.7 %,
eb_vcf_cv 90.9 %, eb_envgen 89.4 %, eb_vcf_ladder 87.3 %, eb_dco 82.8 %,
eb_pwm_cv 61.1 %. **Every DSP module executes.**

---

## F2 — 9 of the 10 modules had NO teeth. **FIXED 2026-08-02.**

`null_b.teeth()` plants errors in the port and in **reverb**. There is no
planted-error case for chorus, dco, delay, env, pwm_cv, skeleton, vca_hpf,
vcf_cv or vcf_ladder. So for nine modules, "the gate is green" has never been
paired with "the gate can go red".

MEASURED for the DCO during this audit, by scaling its output:

| planted error | worst global residual | scenarios that caught it |
|---|---|---|
| ×1.00001 (1e-5) | **−99.8 dB** | **1 of 30** |
| ×1.0000001 (1e-7) | −119.8 dB | 0 of 30 (PASS) |

So the DCO is gated to about **1e-5 of its own output**, and it clears the
−100 dB threshold by 0.2 dB. Twenty-nine of the thirty scenarios do not react to
a 1e-5 DCO error at all. This is the module that dominates the cost budget and
the one most likely to be changed for speed.

**FIXED.** Every module now has a measured bracket in `null_b.py --teeth`: the
smallest relative error on its own output that the gate catches, and one that it
lets through. Battery result: **TEETH: PASS**, 28 cases.

### RETRACTED: "the DCO is the weakest module in the set"

That claim was made earlier on this page and it is **wrong**. It came from a
probe fault of my own, committed within the hour after F8 recorded the same
fault elsewhere.

A pure relative scale of 1e-5 on a module whose error reaches the output at
unity gain produces a residual of exactly 1e-5, which is exactly −100 dB, which
is exactly the threshold. Six of the eight modules sit at unity gain, so six
brackets landed **on** the line, read −100.0/−100.1 dB, and passed or failed
essentially at random — dco 1/30, delay 17/30, chorus 21/30. I read "dco 1/30"
as weakness. It was the probe.

MEASURED gain of each module's output error at the gate, G = residual dB minus
20·log10(factor):

| unity gain (G ≈ 0 dB) | amplifying |
|---|---|
| chorus, dco (+0.2), delay, reverb, vca_hpf, vcf_ladder | env +18.6, vcf_cv +16.3, **pwm_cv +104.5** |

The amplifying three carry control values — an envelope level, a cutoff, a pitch
— and a relative error on a control moves the audio by far more than itself.

### The brackets, re-measured, each about 10 dB clear of the line

| module | fail factor | measured | reacting | pass factor | measured |
|---|---|---|---|---|---|
| chorus | 3.16e-5 | −90.0 dB | 21/30 | 3.16e-6 | −109.8 dB |
| **dco** | 3.16e-5 | −89.8 dB | **30/30** | 3.16e-6 | −109.2 dB |
| delay | 3.16e-5 | −90.0 dB | 17/30 | 3.16e-6 | −109.8 dB |
| env | 3.7e-6 | −90.1 dB | 8/30 | 3.7e-7 | −109.8 dB |
| reverb | 3.16e-5 | −90.0 dB | 30/30 | 3.16e-6 | −109.8 dB |
| vca_hpf | 3.16e-5 | −90.0 dB | 30/30 | 3.16e-6 | −109.8 dB |
| vcf_cv | 4.8e-6 | −90.2 dB | 14/30 | 4.8e-7 | −109.3 dB |
| vcf_ladder | 3.16e-5 | −90.0 dB | 30/30 | 3.16e-6 | −109.7 dB |
| pwm_cv | 1e-7 (one ULP) | −35.5 dB | 22/30 | — | none possible |

**`pwm_cv` has no pass case and cannot have one.** 1e-8 gives EXACTLY 0 because
`1.0f + 1e-8f == 1.0f`, so that build perturbs nothing and would be a vacuous
pass. Since 1e-7 is one ULP, `pwm_cv` is gated at the finest error a float can
carry. A fail case placed at −90 dB would need a factor near 1.9e-10, far below
one ULP. It gets the fail half and this note instead of a fake pass.

**`skeleton` is un-gateable and is excluded on purpose.** Its shim discards
`eb_engine_process()`'s result, so no perturbation of it reaches the output.

---

## F3 — RETRACTED. `eb_patch.c` is tested, by a different gate.

**My finding was wrong and is withdrawn.** `eb_patch.c` is the compact-preset
decoder, not DSP, so its absence from the audio-path gate is correct rather than
a hole. It is covered by `engine_b/tests/test_patch118.c` (run by
`make -C engine_b/tests`, which `make engineb` runs) and by
`tools/engineb/patch_roundtrip.py`.

VERIFIED by running both during this audit: `PARAMETER PATH: PASS`, and
**64/64 factory patches BIT-EXACT** through a 127-byte round trip.

The lesson for the audit method: "0 % coverage under gate X" is not "untested".
It is "not tested by X". The two must not be conflated, and I conflated them.

---

## F4 — Two modules are only partly exercised. **FIXED / EXPLAINED.**

Line coverage of each module's own engine B file, full 30-scenario set:

| module | executed |
|---|---|
| delay | 100.0 % |
| chorus | 96.1 % |
| reverb | 93.6 % |
| vca_hpf | 91.7 % |
| vcf_cv | 90.9 % |
| env | 89.4 % |
| vcf_ladder | 87.3 % |
| dco | 82.8 % |
| **pwm_cv** | **61.1 %** |
| **eb_engine.c** (skeleton) | **31.9 %** |

**The cause is not a scenario gap.** The uncovered lines were located, not
guessed. In both cases they are entire functions that NOTHING CALLS, so no
scenario could ever reach them:

* `eb_pwm_cv.c` — the whole of `eb_modcv_block()`, a block-rate entry point kept
  for the optimisation work, plus `eb_modcv_reset()`.
* `eb_engine.c` — engine B's own voice allocator, note on/off, and free-run
  advance. The shims use the port's allocator, so engine B's is not yet in any
  path.

This is the more dangerous kind of unexecuted line: not dead code, but code that
becomes live later, after everyone has stopped looking.

**FIXED for `pwm_cv`:** `engine_b/tests/test_modcv_block.c` proves
`eb_modcv_block()` equals `eb_modcv_tick()` **bit for bit** — compared as bit
patterns, not with a tolerance — over pseudo-random coefficients and inputs
including signed zeros, denormals and huge magnitudes. MEASURED: **3,200,000
comparisons, 0 differing.** It is wired into `make -C engine_b/tests`.

**NOT fixed for `eb_engine.c`:** its allocator and note handling are still
unproven and un-gated. They must not be switched on until they are gated against
the port's allocator, which is the same class of surface that produced the KEY
ASSIGN failure. Stated here rather than left implicit.

---

## F5 — `cost.py` charged six `fmodf` sites that never execute. **FIXED.**

MEASURED in the same counting run: over 60,989,440 DCO steps, the `fmodf`
fallback arms in `eb_dco_wrap` and `eb_triangle` executed **0 times**. The cost
model charges all six statically at 80..300 cycles each, so the top of the DCO's
band is overstated. The divide is real: 60,989,440 executions, one per step.

**FIXED.** `cost.py` gains `--exec SYMBOL=N`, a MEASURED executions-per-
invocation count that replaces the static one for that symbol. A symbol not
listed keeps its static count, so nothing is ever quietly discounted, and the
tool prints the overrides in force at the head of the run.

**The correction is large.** DCO, ESP32-S3, `--calls eb_dco_step=32`:

| | nominal | band |
|---|---|---|
| static charge (before) | 31,611 | 16,384 .. 94,845 |
| **`--exec fmodf=0` (measured)** | **19,326** | **10,664 .. 55,845** |

The model had been charging roughly 12,000 cyc/sample of calls that never run.
Every DCO cost figure reported before this fix is too high.

---

## F6 — `plugin_check` named the candidate from the request. **FIXED.**

The report line was built from the module list the user asked for. While F1 was
live it printed all ten module names for a build that contained two.

**FIXED.** The label is now derived from `build()`'s own return value — the list
of port translation units it actually overwrote — and a duplicated shadow is a
hard error. VERIFIED: `--module dco` now reports
`engine B, modules: dco  [linked, shadowing voice_render.c]`.

---

## F7 — Historical: the teeth battery had never run.

Recorded in `null_b.py` itself: until 2026-08-02 `teeth()` raised `NameError`
before doing any work, while the docstring and two documents said "teeth
proven". Found by running it. Listed here because it is the same class and
because it shows the class is recurrent, not a one-off.

---

## What the audit did NOT cover

* The Unicorn oracle itself (`e2e_emu.py`) and the 13 port-side gates in
  `make verify`. This audit is engine B's harness only.
* Branch coverage. The numbers above are LINE coverage; a line can execute with
  one of its two branches never taken.
* 48 kHz. Every number here is 44,100 Hz.
* The cost model's CPI assumptions, beyond F5.

## Order of repair

1. ~~F2~~ DONE — every module has a measured bracket.
2. ~~F3~~ RETRACTED — the finding was wrong.
3. ~~F4~~ DONE for `pwm_cv`; `eb_engine.c`'s allocator remains unproven and is
   flagged, not fixed.
4. ~~F5~~ DONE — and every DCO cost figure before it was too high.
5. ~~F6~~ DONE.
6. ~~F8~~ DONE — and then committed again by me, and fixed again. See F2.
7. ~~F1 follow-up~~ DONE — the composite is generated and gated, and the whole
   engine is BIT-EXACT against the plugin.

**Every audit finding is now closed.** What remains open is not a harness fault
but a stated limit:

* `eb_engine.c`'s voice allocator and note handling are unproven and un-gated.
  They must not be switched on before they are gated against the port's
  allocator — the same surface that produced the KEY ASSIGN failure.
* `skeleton` is un-gateable: its shim discards `eb_engine_process()`'s result.
* ~~48 kHz has never been compared against the authority.~~ **CLOSED
  2026-08-02.** `plugin_check.py --rate` was added and both sides were run at
  **48,000 Hz**, engine B's delivery rate:

  | comparison at 48 kHz | result |
  |---|---|
  | whole engine (`--module all`) vs the plugin | **11/11 BIT-EXACT** |
  | the port (`--check-port`) vs the plugin | **11/11 BIT-EXACT** |

  NON-VACUITY, which matters because a rate that fails to propagate would give a
  full set of false greens: the signal levels differ from the 44.1 kHz run —
  `pluck POLY` reads −43.2 dBFS at 48 kHz against −35.7 dBFS at 44.1 kHz, and
  every other scenario also moved. The rate change reached the DSP. On top of
  that, `ref_main` asserts the reference's own `SR` equals the gate's before it
  renders a single frame, so a variable that did not propagate aborts the run
  instead of producing divergences with a non-engine cause.
* Coverage here is LINE coverage. A line can execute with one branch never
  taken.


## F8 — NEW, found by running the new battery: a calibration probe had drifted
## onto the threshold. **FIXED.**

The reverb's pass-side probe (`reverbwet`) was recorded at −100.5 dB against a
−100 dB threshold — 0.5 dB inside the line. Re-running the battery measured it
at **−99.2 dB**, so it had crossed, and the battery reported a TEETH FAILURE.

Nothing was wrong with the reverb. The probe was sitting on the line.

**The gate was not moved. The probe was.** It is now 16.0005f (3.1e-5 relative),
MEASURED at −105.2 dB. 16.00025f was also measured, at −111.2 dB, and was not
chosen: a bracket should sit near the line, only not on it.

The general lesson, and it applies to every calibration probe in this repo: a
probe within about 1 dB of its threshold will eventually report drift as a
defect. Give it margin, and record the measured margin next to it.

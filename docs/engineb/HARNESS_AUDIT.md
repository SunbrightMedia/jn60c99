# Harness audit — engine B gates

Date 2026-08-02. Every finding below is MEASURED by execution. Nothing here is
from reading the code.

The reason for the audit: almost every error this project has made came from the
harness, not from the engine. This audit looks for that class only.

---

## F1 — SHIM COLLISION. Composite builds linked 2 modules of 10. **FIXED.**

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

Fix: a collision is now a hard build failure that names both modules.

---

## F2 — 9 of the 10 modules have NO teeth. The gate has never been shown to
## catch an error inside them.

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

Required: a teeth case for every module, each with its measured leverage.

---

## F3 — `engine_b/eb_patch.c` is never executed by any gate.

56 lines. Coverage over the full 30-scenario set, every module in turn: 0.0 %
in all ten builds. It is untested code inside the engine.

---

## F4 — Two modules are only partly exercised.

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

`pwm_cv` reports "exact" on lines that never ran. 39 % of that module carries no
evidence at all.

---

## F5 — `cost.py` charges six `fmodf` sites that never execute.

MEASURED in the same counting run: over 60,989,440 DCO steps, the `fmodf`
fallback arms in `eb_dco_wrap` and `eb_triangle` executed **0 times**. The cost
model charges all six statically at 80..300 cycles each, so the top of the DCO's
band is overstated. The divide is real: 60,989,440 executions, one per step.

Effect: the DCO band I reported (16,384 .. 94,845 cyc/sample on the S3) has a
wrong top. The nominal is less affected but is not clean either.

---

## F6 — `plugin_check` names the candidate from the request, not from the build.

The report line is built from the module list the user asked for. When F1 was
live it printed all ten module names for a build that contained two. A gate must
report what it linked, not what it was asked for.

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

1. F2 — a teeth case per module. Without it a green gate means nothing.
2. F1 follow-up — merge the colliding shims so a whole-engine test can exist.
3. F4 — scenarios that reach the unexecuted parts of `pwm_cv`.
4. F3 — cover or delete `eb_patch.c`.
5. F5 — stop the cost model charging unreachable calls.
6. F6 — report the linked module list from the library, not the request.


---

## Gate #2 and #3 — added 2026-07-31, because gate #1 alone was not enough

The very first mutation planted in the native fork (a 0.1 % error in the noise
generator's `2^-24` output scale, `src/voice_render.c:640`) was caught by
**one of null_ab's five scenarios**. The other four did not report a small
residual — they reported **EXACTLY 0**. They were right to: their patches have
DCO NOISE at zero, so the mutated value is multiplied out downstream. The line
*ran* and the error was *unobservable*.

That is the project's defining failure mode wearing a new hat: five green
scenarios that look like five times the evidence and are, for that subsystem,
one. So a Track B PASS is only admissible when all three gates below are green
**for the subsystem being rewritten**.

### Gate #2 — `tools/trackb/coverage_probe.py` — was the code REACHED?
gcov line counts from a coverage build of the candidate, per scenario, in
separate processes so counters do not accumulate. First run: 1 161 of 1 188
instrumented lines of `voice_render.c` executed by at least one scenario, and
1 156–1 161 by each scenario individually. `--lines A-B` fails, by name, any
scenario that misses the range you rewrote, and reports any target line no
scenario reaches at all.

### Gate #3 — `tools/trackb/observability.py` — would a wrong answer be NOTICED?
Coverage is necessary and not sufficient, as the noise-gain mutation proves.
This tool multiplies chosen per-voice cells by 1.000 000 12 f (~2 ULP) *after*
the render, through an `#ifdef`-guarded hook in `native/voice_render.c` that
emits no code unless `-DTRACKB_PERTURB_CELLS` is passed, and reports which
scenarios see it. Both directions demonstrated on the first run: the voice
output (3520) is observed by 5/5 at −129 dB; cells 432/528/4928 by 0/5.

Two things fall out of it:

* **Gate calibration, MEASURED.** A 2-ULP-per-sample error on the voice output
  lands at −129 dB rel — **39 dB below the −90 dB threshold**. So gate #1
  ignores errors up to roughly 200 ULP (~2.4 × 10⁻⁵ relative) per sample and
  catches anything larger. Far under audibility, far over float noise. That is
  now a number, not a hope.
* **An executed carriage classifier** (`--each`). The hook fires after the
  sample, so a cell whose perturbation nobody can see does not survive the
  sample boundary. NOT-CARRIED is precisely the property that makes a cell legal
  to hold in a register instead of memory — the scratch lever the Cortex-M7
  needs — and this establishes it by running the engine rather than by static
  reasoning. Label it MEASURED over the scenario set: evidence, not proof for
  all inputs. It also cross-checks the blueprint docs' CARRIED/SCRATCH tables,
  which were produced by reading. It already found that `4928` is a dead
  duplicate store of the value written to `3520`.

### The rule
Before rewriting subsystem X: run gate #3 on X's output cells. If **0/5**
scenarios observe them, the scenario set cannot validate that rewrite — add a
scenario that uses X, or record X as out of scope in the EQUIVALENCE ledger.
Never rewrite behind a blind gate.

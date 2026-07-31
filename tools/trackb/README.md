# Track B harness — how to run it, and how to point it at another synth

Track B is the deliberate, bounded departure from bit-exactness: the voice inner
kernels get rewritten natively so the engine fits an in-order Cortex-M7, while
everything else stays the sealed transcription. The acceptance criterion is the
user's: **sonically identical in every way**, made operational as a null test
with a measured meaning.

Nothing here touches `src/`. `src/` remains a party to the bit-exact seal that
`make verify` proves against the plugin binary under Unicorn, and that proof must
stay intact — it is the reference this harness measures against.

---

## The loop

```
edit native/voice_render.c              # the fork; see "Substrate" below
make juno_cand.so                       # native/<x>.c replaces src/<x>.c by name
python3 tools/trackb/coverage_probe.py --lines A-B      # was it REACHED?
python3 tools/trackb/observability.py  --cells ...      # would it be NOTICED?
python3 tools/trackb/null_ab.py --cand ./juno_cand.so --all   # is it IDENTICAL?
```

Three questions, three tools, in that order. The first two exist because the
third cannot answer them, and answering only the third is how a test lies.

### 1. `null_ab.py` — is the output identical?

```
null_ab.py --cand X            7-scenario smoke gate           (~20 s)
null_ab.py --cand X --all      ACCEPTANCE gate                 (~3 min)
null_ab.py --teeth             test the gate itself            (~4 min)
```

`--all` adds 384 full-bank comparisons (64 factory patches × 3 scripts × 2 rates)
and 24 seeded random polyphonic sequences **with live parameter edits**. Pass
threshold: residual RMS ≤ −90 dB relative to the reference signal, with a
−50 dBFS non-vacuity floor so silence-vs-silence can never pass.

**What −90 dB means, MEASURED:** a 2-ULP-per-sample error on the voice output
lands at −129 dB — 39 dB below the threshold. So the gate ignores errors up to
roughly 200 ULP (≈2.4 × 10⁻⁵ relative) per sample and catches anything larger.
Under audibility by a wide margin, over float noise by a wide margin.

**Two metrics, both gating.** One RMS over a whole render is normalised by the
loud part, so an error confined to a release tail contributes almost nothing to
it. Every comparison therefore also reports the **worst 1024-sample block**
residual, measured against that block's *own* level (floored at 1e-3 of the
global RMS so silence cannot divide by zero), threshold −70 dB.

That second metric is not decoration, and the number that says so is measured:
the `tailquiet` mutation — a 0.1 % gain error that exists only while the gate is
released — is caught by the global metric in **5 of 7** scenarios and by the
block metric in **7 of 7**. Two scenarios sit at −93.0 and −94.7 dB globally,
i.e. they would have walked straight through the −90 dB gate, while the block
metric sees them at −66.8 and −66.3 dB.

Writing that mutation also exposed a coverage hole: the first five scenarios
never released a note at all, so five of seven reported EXACTLY 0 against a
release-path bug. Every scenario now ends with note-offs and a tail.

**`--teeth` is not optional after any change to the gate.** It builds four
known-broken engines and requires each to be caught *in a specified number of
scenarios*, plus a clean control that must be EXACTLY 0:

| mutation | what it really breaks | required |
|---|---|---|
| `noisegain` | noise LFSR 2⁻²⁴ output scale, 0.1 % | ≥1 of 7 |
| `dcopitch` | Hz→phase-increment scale, 100 ULP ≈ 0.01 cent | all 7 |
| `nochorus` | slot-2 routing forced to the Pan arm | all 7 |
| `envslow` | one envelope coefficient, 1 % | all 7 |
| `tailquiet` | 0.1 % gain error **only while the gate is released** | all 7 |

Mutations are planted in the file that is **actually compiled** — if
`native/<x>.c` shadows `src/<x>.c`, the mutation goes into the fork, so the
battery exercises the same substitution path a real candidate uses. A battery
that patched a file the candidate build never sees would report the gate as
blind when in truth the experiment never happened.

`noisegain` is required in only one because four scenario patches have DCO NOISE
at zero, so the value is multiplied out — the case that taught this harness that
"caught somewhere" is not a coverage statement. On the full bank the same
mutation is caught by **84 of 384** comparisons.

### 2. `coverage_probe.py` — was the code reached?

gcov line counts from a coverage build, per scenario, each scenario in its own
process so counters do not accumulate. `--lines A-B` names any scenario that
misses the range you rewrote, and any target line no scenario reaches at all.

### 3. `observability.py` — would a wrong answer be noticed?

Multiplies chosen per-voice cells by ~2 ULP **after** the sample, via an
`#ifdef`-guarded hook in `native/voice_render.c` that emits no code unless
`-DTRACKB_PERTURB_CELLS` is passed, and reports which scenarios see it.

```
observability.py --cells 3520,4928            per-scenario verdict
observability.py --cells 320,336 --each       classify one cell at a time
observability.py --sweep --out map.tsv        classify every written cell
```

**Rule: never rewrite behind a 0/N gate.** If no scenario observes the cells a
subsystem produces, the null is vacuous for that subsystem — add a scenario that
uses it, or record it as out of scope in the ledger.

Because the hook fires after the sample, `--sweep` also measures **carriage**:
which cells survive to influence a later sample (`docs/trackb/CARRIAGE.tsv`).
NOT-CARRIED is exactly the property that makes a cell legal to hold in a register
instead of memory — the scratch lever the M7 needs — established by running the
engine, not by static argument.

---

## Substrate

`native/<name>.c` replaces `src/<name>.c` by filename in `make juno_cand.so`.
`native/voice_render.c` began as a verbatim copy of the sealed transcription, so
with no rewrite applied the candidate is a byte-identical twin and the null is
EXACTLY 0 — the harness's own passthrough proof. Keep that proof honest: after
any change to the harness, re-run it before trusting a non-zero result.

---

## Three failure modes this harness has already caught in itself

Written down because they are the general lessons, not JUNO-specific ones.

1. **A probe that cannot perturb.** The perturbation was `v *= 1.00000012f`, and
   `0.0f * anything` is `0.0f`, so every cell resting at zero read NOT-CARRIED
   whether it was or not — the dangerous direction. Fixed with an additive term;
   cell 320 immediately flipped to CARRIED.
2. **A subsystem no scenario ran.** The glide integrator read NOT-CARRIED because
   no scenario ever changed pitch on a portamento patch. Adding one flipped cell
   656 to CARRIED. A subsystem that never runs is indistinguishable from a
   subsystem with no state.
3. **A leak that only bites at scale.** `render()` created an ~11 MB engine
   context per call and never destroyed it: invisible across ten renders, fatal
   across 1 415 (OOM at 11.6 GB). Gates that are cheap get run in loops; write
   them as if they will be.

---

## Redoing this for another synth (JX-3P, …)

Reusable as-is — the method and most of the code:

* the three-question structure, and the rule that the second and third exist
  because the first cannot answer them;
* `coverage_probe.py` entirely (it only needs `SCEN` and a candidate build);
* `observability.py` and `perturb_rt.c` entirely, given a render function with a
  flat state pointer and a place to put the hook;
* `null_ab.py`'s comparator, thresholds, non-vacuity floor, `--full`/`--fuzz`
  structure and the teeth discipline;
* the `native/<x>.c` shadowing rule in the Makefile;
* every lesson in the section above.

JUNO-specific, and what a new synth must supply:

* `SCEN` — scenario patches and scripts, chosen so every subsystem is *observed*
  (verify that with `observability.py`, do not assume it);
* the mutation set in `build()` — each needs a real anchor in that engine's
  source, and its own honest expected-scenario count;
* the cell-offset vocabulary (`JF(a1, N)`), the per-voice stride, and the
  `written_cells()` regex if the transcription uses different accessors;
* the bank/patch loader (`truth.BANK`, `juno_gui_apply_bank`) and the
  `juno_gui_*` API names in `load()`;
* a sealed bit-exact reference to null against. **This is the load-bearing one.**
  Track B is only trustworthy because there is a proven-exact engine on the other
  side of the subtraction; without that, a null test compares two guesses.

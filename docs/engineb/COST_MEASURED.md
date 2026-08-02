# Engine B's cost, with the harness subtracted

Date 2026-08-02. Executed instructions, MEASURED on the host with callgrind.
4,000 samples, 8 voices sounding, patch 20 (chorus + delay + reverb), 48 kHz,
all thirteen modules in the build.

## The measurement

| | instr/sample | share |
|---|---|---|
| `juno_voice_render` self — the shim marshalling | 27,225 | 54.0 % |
| **engine B's own functions** | **17,943** | 35.6 % |
| `juno_master_render` self | 1,701 | 3.4 % |
| `juno_flush_denormals` | 1,232 | 2.4 % |
| `juno_driver_render_voices` | 312 | 0.6 % |
| **total through the harness** | **50,413** | 100 % |

Inside engine B's 17,943, two functions are **not DSP**:

| | instr/sample |
|---|---|
| `eb_vcf_hist_set` | 1,536 |
| `eb_vcf_hist_get` | 1,536 |

They exist only so the ladder can keep its state in the port's memory cells and
inherit the port's lifecycle. The shipped engine has no such call.

**So engine B's DSP is 17,943 − 3,072 = 14,871 instructions per sample.**
MEASURED, on the host, with real signals and a real patch.

## What that means

The engine measured through the harness is **50,413** instructions per sample.
Engine B's actual DSP is **14,871**. The difference — about **35,500**, or 70 %
— is glue that exists so one module can be substituted at a time, and it will
not be in the shipped engine.

**Every cost figure this project has quoted for engine B before today was
inflated by that glue.**

The standalone engine will add some plumbing of its own — voice allocation, the
free-run advance, patch recall — so 14,871 is a FLOOR, not the finished number.
It is the first honest estimate of the right order.

## Against the target

The ESP32-S3 budget is 3,500 cycles per sample for the whole engine at 48 kHz,
8 voices, all FX.

On an in-order core running from internal RAM, one instruction is roughly one
cycle, so **14,871 instructions per sample is about 4.2× the budget**. That
comparison is **MODELED**, not measured: no engine B code has ever run on an
ESP32, and the host is a different machine in every way that matters.

What is MEASURED is the ratio between engine B and the harness, and that the
engine is far smaller than every previous figure implied.

## What is NOT yet done, and why the standalone gate is still open

`eb_engine_render()` does not exist as working code. `eb_engine.c` is a skeleton:
every DSP call inside it is a stub returning 0 or passing its input through.
Wiring all thirteen modules into it, with patch recall and voice allocation on
engine B's own state, is a substantial build and is the next piece of work.

Until it exists there is nothing to gate, so the standalone gate named in
`STANDALONE.md` is still open. The number above was obtained by subtraction from
the real engine rather than by waiting for it.

`tools/engineb/standalone_cost.c` is a direct-call benchmark written toward that
gate. It builds and runs, and it currently **REFUSES TO REPORT**: its placeholder
coefficients leave the chain silent, and several modules skip work on a zero
signal — the DCO's level gates and its saturator shortcut are the obvious ones —
so a silent run would report a cheaper engine than the one that ships. It needs
driving from a real recalled patch. The guard is deliberate: a benchmark that
quietly measures silence is exactly the class of fault this project keeps
finding.


---

## Step 1 of the standalone engine — the ladder's state moved. MEASURED.

Date 2026-08-02, after the measurement above.

`eb_engine_render()` is a large build, and this project's history says that
writing the whole thing and then debugging a whole-engine divergence is the
expensive way — the CV/gate block took most of its time to a defect whose values
were all bit-identical. So it is being built in gated steps, biggest cost first,
with the state moving to its final home as it goes.

**Step 1: the VCF ladder's state moved out of the port's cells into engine B.**
It was the largest single cost in the engine — the copy in and out was 17,008
instructions per sample, 62 % of the port function's self cost and 34 % of the
whole engine, and none of it is DSP.

Stopping the cell maintenance was CHECKED, not assumed: an exact search over
every `src/*.c` for each of the eleven scalar cells and the four history bases
finds **no reader outside the ladder block**. The only other code that touches
them is `chorus_init.c`, zeroing them at power-on — which is what supplies the
fresh-context marker (cell 8320, claimed by engine B on the same pattern the
decimator uses on 5440 and the noise SVF on 4288).

### The result

| | before | after | change |
|---|---|---|---|
| `juno_voice_render` self (marshalling) | 27,225 | **16,241** | **−40 %** |
| engine B's own functions | 17,943 | 15,431 | −2,512 (the two hist accessors are gone) |
| **whole engine through the harness** | **50,413** | **36,357** | **−27.9 %** |

And it is still exact:

| gate | result |
|---|---|
| `--module vcf_ladder`, 30 scenarios | EXACTLY 0 |
| `--module all`, 30 scenarios | EXACTLY 0 |
| vs the PLUGIN at 48 kHz | 11/11 BIT-EXACT |

**Engine B's DSP is now 15,431 instructions per sample**, and unlike the earlier
figure this one contains no marshalling functions at all — the 3,072 spent on
`eb_vcf_hist_set`/`get` are gone rather than subtracted on paper.

### What is left in the port's 16,241

That is the remaining marshalling: every other module still reloads its
coefficients from the port's cells each sample. Moving each one is the same
pattern, and each is independently gateable. That is steps 2 onward, and when
the last one lands there is nothing left for `eb_engine_render()` to do except
call the modules in order — which is the point of building it this way round.


---

## Step 2 — the coefficient reloads. MEASURED.

Every module was reloading its coefficients from the port's cells **every
sample, per voice**, from cells that only a patch recall ever changes. Two of
them also ran a float-by-float change check to avoid recomputing. All of it is
harness cost: the shipped engine computes these once at recall and never looks
again.

The four biggest, located by a line-level profile rather than chosen:

| what | was, instr/sample |
|---|---|
| envelope change check (15 floats × 2 × 8 voices) | 1,776 |
| mod-CV change check (24 floats × 8 voices) | 2,192 |
| ladder coefficient load (30 cells × 8) | 776 |
| decimator coefficient load (20 cells × 8) | 512 |

Each is now cached on a `memcmp` of the raw cells.

**Why `memcmp` is exact here.** It is *stricter* than the float comparison it
replaces: the two differ only where the bits differ but the floats compare
equal — `+0.0` against `-0.0` — and there `memcmp` says "changed" and
recomputes. A needless recompute produces identical coefficients, so the result
never changes; the only cost is doing the work occasionally when it was not
required. Being conservative in that direction is safe. The reverse would not
be, and that is the direction a cheaper check would have failed in.

### Running total

| | instr/sample |
|---|---|
| before step 1 | 50,413 |
| after step 1 (ladder state moved) | 36,357 |
| **after step 2 (coefficient caches)** | **34,549** |
| engine B's own DSP, unchanged throughout | 15,431 |

**−31.5 % from the starting figure, and still exact at every gate:** EXACTLY 0
on all 30 scenarios for each module and for the whole engine, and **11/11
BIT-EXACT against the plugin** at 48 kHz.

The port function is down from 27,225 to **14,433**. What remains there is the
same pattern in the modules not yet moved, plus the port code that engine B's
own recall will eventually replace.


---

## Step 3 — the coefficient generation counter, and how it was proven

After step 2 the remaining cost was the *check*, not the work. MEASURED over the
30-scenario set, how often each cached coefficient set actually changed:

| module | recomputes | of |
|---|---|---|
| envelopes | 272 | 30,494,720 |
| mod CV | 128 | 15,247,360 |
| ladder | 8 | 15,247,360 |
| decimator | 8 | 15,247,360 |

So the cells are recall-rate and the per-sample `memcmp` is almost always a
wasted read of 15 to 30 cells per voice.

`gui/juno_bridge.c` now carries `eb_coef_gen`, bumped by every entry point that
is not a plain render. A shim skips its check while the counter is unchanged.

### The counter is NOT trusted, it is PROVEN

A counter like this is exactly the kind of shortcut that is right until some
writer nobody thought of moves a cell. So it is not believed on argument.
Building with `-DEB_VERIFY_GEN` (`JUNO_EB_VERIFY_GEN=1`) makes every shim run
its full `memcmp` **anyway** and abort if the counter ever claimed "clean" while
the cells had in fact changed.

| run | result |
|---|---|
| `JUNO_EB_VERIFY_GEN=1 --module all`, 30 scenarios | **PASS** |
| same build with the counter FROZEN (teeth) | **ABORTS**, naming the module |

The teeth case matters more than the pass. The first two attempts at it did
**not** abort, and both were my error rather than the mechanism's:

1. The first froze only `set_param` and `apply_bank`, but `juno_gui_create` also
   bumps the counter and every scenario builds a new context — so the counter
   still advanced exactly when it needed to.
2. The second ran against a **stale composite shim**. The guard had been added
   to the individual shims and the composite had not been regenerated, so both
   runs tested a build with no guard in it at all. That is the stale-artifact
   class this project keeps meeting; `merge_shims.py --check` exists for it and
   `make engineb` runs the regeneration, but I invoked the gate directly and
   skipped it.

Only after both were fixed did freezing the counter produce the abort. **A
verification that has never been seen to fail is not a verification.**

### Running total

| | instr/sample |
|---|---|
| before step 1 | 50,413 |
| after step 1 (ladder state) | 36,357 |
| after step 2 (coefficient caches) | 34,549 |
| **after step 3 (generation counter)** | **33,750** |
| engine B's own DSP, unchanged throughout | 15,431 |

**−33.0 % from the start.** The port function is down from 27,225 to **13,634**.
Every gate is still green: EXACTLY 0 on all 30 scenarios per module and
whole-engine, and 11/11 BIT-EXACT against the plugin at 48 kHz.


---

## Step 4 — the gathers moved inside the generation check

Step 3 stopped the modules *comparing* their coefficients every sample, but they
were still **reading** them: each shim gathered its 15 to 30 cells into a local
array and only then asked whether anything could have changed. The read was the
remaining cost.

| module | gather, instr/sample |
|---|---|
| mod CV (24 cells × 8 voices) | 768 |
| decimator (20 × 8) | 536 |
| ladder (30 × 8) | 776 |
| envelopes (15 × 2 × 8) | 336 |

All four gathers now sit **inside** the generation check. Under
`-DEB_VERIFY_GEN` the branch is always taken, so the verification build still
gathers and still compares every sample — the proof is unweakened by the
optimisation it is proving.

### Running total

| | instr/sample | port function self |
|---|---|---|
| before step 1 | 50,413 | 27,225 |
| after step 1 (ladder state) | 36,357 | 16,241 |
| after step 2 (coefficient caches) | 34,549 | 14,433 |
| after step 3 (generation counter) | 33,750 | 13,634 |
| **after step 4 (gathers moved)** | **30,758** | **10,642** |
| engine B's own DSP, unchanged throughout | 15,431 | — |

**−39.0 % from the start**, and the port function is down by **61 %**.

Gates, all green after regenerating the composite:

| gate | result |
|---|---|
| each of the four modules, 30 scenarios | EXACTLY 0 |
| `--module all`, 30 scenarios | EXACTLY 0 |
| `JUNO_EB_VERIFY_GEN=1 --module all` | PASS |
| vs the PLUGIN at 48 kHz | 11/11 BIT-EXACT |

**Half of what is left is now engine B itself.** Of 30,758, engine B's DSP is
15,431 and the port function is 10,642. The marshalling has stopped being the
dominant term, which is the point at which `eb_engine_render()` becomes worth
writing: there is little left for it to delete, and what remains is real work.

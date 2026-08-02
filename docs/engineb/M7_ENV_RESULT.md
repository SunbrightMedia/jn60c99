# MODULE M7 — the two ADSR envelopes. Measured on both axes.

2026-08-02. The first real engine B DSP module. Code: `engine_b/eb_envgen.{h,c}`,
gate shim `engine_b/shim/env/voice_render.c`.

## Why this module and not another

Crossing the two things already measured, as the task requires:

| | rank | evidence |
|---|---|---|
| gate quality | **2 of 9**, 11/14 assignments observable | `docs/trackb/MODULE_ORDER.md` |
| cost | named target #3 of the attribution | `docs/trackb/COST_ATTRIBUTION.md` |

The DCOs are the tempting target and are **excluded by rule**: 5/12 observable
before the prerequisite work, and the charter forbids rewriting behind a blind
gate. M1b is rank 1 on gate quality but is 1.5% of the budget and
COST_ATTRIBUTION still lists it as blocked. M7 is the best available crossing of
"the gate can see it" with "it is worth cycles".

## Axis 1 — ACCURACY. `tools/engineb/null_b.py --module env`

**26 of 26 scenarios EXACTLY 0.** Not "below −100 dB": bit-identical, every
sample, including all 17 idle-prefix scenarios (idle chorus / unison / noise at
1, 48, 441, 4410, 44100 samples, and the two allocate→release→idle→reallocate
cases). The self-test (`--module none`) was EXACTLY 0 in the same run, so the
comparison is not vacuous at the harness level.

That is not luck. **There is no approximation in this module.** Everything
engine B changes is exact by construction:

1. Five floats of struct state replace fifteen cells, ten of which exist only to
   hold the previous sample's copy of another cell.
2. Six loop-invariant products are hoisted to parameter time. Hoisting a product
   is bit-exact — same two operands, same single rounding — it is only moved.
3. Four stores are dropped (2528/2544/2768/3248). GREPPED: no reader anywhere in
   `src/` or `gui/`. Audio cannot change; **per-cell state parity does**, so this
   is a sonic-identity claim, not a bit-exact-state one.

### Non-vacuity, measured, not asserted

A green null on a first module is exactly the shape a plumbing mistake takes, so
three errors were planted in `eb_envgen.c` and driven through the real build:

| planted error | result |
|---|---|
| **TRAP 1 taken**: slew constant simplified from `((sel*step)−(peak*sel))+peak` to `step` — algebraically identical | **FAIL, 10 of 25 scenarios**, worst global **−66.9 dB**, worst block −57.0 dB |
| output scaled by 1 ULP (1 + 2⁻²³) | PASS, **−118.5 dB** worst global. Calibrates where the −100 dB gate bites for this module: ~5.6 ULP. |
| **TRAP 2 taken**: release rate simplified from `((R/256)*rel − rel*r) + r` to `R/256` | **EXACTLY 0 in all 25 scenarios** |

Trap 1 is the documented cancellation in `docs/trackb/ENV.md` §2.4 and is worth
**33 dB above the gate** — the module is very much in the audio path, and the
doc's warning is confirmed by measurement rather than by reading.

Trap 2 is an **honest negative**: the scenario set cannot see it. The
cancellation is exact for every value these scenarios produce. The verbatim form
is kept anyway (it costs nothing), but *this gate does not prove it is needed*,
and any future claim about it needs a scenario that reaches it.

## Axis 2 — COST. `tools/engineb/cost.py`, real compiles, three toolchains

`eb_env_tick`, one envelope, one sample. Instruction counts are MEASURED-STATIC
from real objects; cycles are MODELED with the rig's stated bands.

| target | instructions | memory accesses | cyc/call (nom) | ×16 calls/sample | % of 3,500 |
|---|---|---|---|---|---|
| host x86-64 | 84 | 24 | 21 | 339 (222–998) | 9.7% |
| Cortex-M7 | 80 | 25 | 85 | 1,367 (686–4,528) | 39.1% |
| **ESP32-S3** | **81** | **25** | **74** | **1,188 (739–3,098)** | **34.0%** |

16 calls/sample = 8 voices × 2 envelopes, the worst case, with no at-rest skip.
Every S3 cycle figure is MODELED against **no S3 silicon**; the rig's own error
bar is ±2×. Quote the band.

### Against the port, same block, same job

`src/voice_render.c:964–1075`, MEASURED-STATIC by counting its own cell
references:

| | port | engine B | ratio |
|---|---|---|---|
| cell/memory accesses per voice per sample | **108** (78 loads, 30 stores) | **50** (2 × 25) | 2.16× fewer |
| distinct addresses touched | 84 | 2 structs (20 B state, 52 B shared coefficients) | — |
| float instructions, S3 | — | 162 for both envelopes | — |

On the Daisy those 108 accesses are the whole story: at the board's own MEASURED
68 cyc/access they are ~7,300 cyc/voice/sample for the envelopes alone, ~58,700
for eight voices. Engine B's 50 accesses are to two small structs in fast SRAM.

### A restructuring that was tried and REJECTED

The obvious next move — one `eb_env_block()` call per sample so the thirteen
coefficients, identical for every voice, are loaded once — was implemented and
measured on the real S3 compiler:

| shape | instructions | accesses |
|---|---|---|
| two standalone `eb_env_tick` calls | 162 | 50 |
| the same two force-inlined into a loop | 240 | 105 |
| two passes (all ENV1, then all ENV2) to halve live coefficients | 240 | 105 |

**Inlining made it worse in both terms.** The S3 has 16 float registers and one
coefficient set is 13 floats; two live sets spill, and the strided addressing of
the voice arrays costs more integer loads than the hoist saves. The shape is not
shipped. It may come back only with a measurement that shows it winning.

## The honest answer to the question the task asks

**Can −100 dB and 3,500 cyc/sample be met together? On this module: accuracy
yes, absolutely — cost, not yet, and the shortfall is arithmetic, not layout.**

* Accuracy is not a trade-off here. EXACTLY 0, with no approximation and
  therefore no error budget to spend.
* 1,188 cyc/sample nominal is **34% of the entire engine budget for the
  envelopes alone**, against `SCOPE.md`'s planned allocation of 200 cyc for all
  control-rate work and 2,000 for all eight voices. The plan is wrong, not the
  measurement.
* **The remaining cost is not memory.** 38 float-arithmetic instructions per
  envelope × 2 × 8 voices ≈ 608 float ops per sample; on a 240 MHz
  single-precision FPU that is a hard floor around 600 cycles no layout can
  remove. The plugin's generator — peak detector, phase flag, slewed target,
  smoothed rate — is intrinsically this expensive, and transcribing a cheaper
  ADSR is exactly the chosen approximation the ACCURACY STANDARD forbids without
  a measured budget.

### What is left, priced

| lever | exact? | expected | status |
|---|---|---|---|
| at-rest skip (`eb_env_atrest`, already written) | **yes** | ×(sounding voices / 8). 2 voices held → ~300 cyc/sample | implemented, not yet gated: needs a scenario set that measures polyphony, and the skip must never skip a free-running state advance |
| control-rate decimation, envelopes at 1/8 sample rate | **NO** | ~150 cyc/sample, 8× | **a chosen approximation. Its error is UNMEASURED. It must not be adopted until it is nulled, and this module is now the vehicle for measuring exactly that.** |
| fewer coefficients / SoA state so the block shape wins | yes | unknown | rejected on today's measurement, reopen only with a new one |

**The next measurement, and it is the decisive one for engine B as a whole:**
run this module at 1/8 control rate through the same null and report the dB. It
is now cheap to do — the module is written, the gate is proven to have 33 dB of
teeth on it, and the answer tells us whether "sounds the same" survives the one
lever that closes the budget.

## Standing caveats

* `src/` is the ORACLE here, a fast proxy, never the authority
  (`docs/trackb/THREE_WAY_GATE.md`). This module has **not** been compared
  against the plugin. Only B-vs-plugin retires the claim.
* The shim stores engine B's state in the port's own state cells so it inherits
  the port's lifecycle. Cycle figures are measured on `eb_envgen.c` alone and
  never on the shim; the shim's coefficient change-detection is harness cost.
* The rate constants are taken as arguments from the port's initialised state.
  The byte→coefficient law and the rate table belong to the PARAM module and are
  deliberately not duplicated or guessed here.

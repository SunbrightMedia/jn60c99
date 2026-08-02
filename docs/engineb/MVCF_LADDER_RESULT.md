# MODULE M-VCF — the 4-pole ladder CORE. Measured on both axes.

2026-08-02. Code: `engine_b/eb_vcf_ladder.{h,c}`; gate shim
`engine_b/shim/vcf_ladder/voice_render.c`; exhaustive wrap test
`engine_b/tests/test_vcf_wrap24.c`.

Scope: `src/voice_render.c:1298-1515` and nothing else — the input node, the
four 4x sub-steps, the four dispersion lines and the decimating FIR. The
cutoff -> coefficient mapper that makes `G` and `k` (:1230-1297) is a different
module and is consumed here as two arguments.

## THE HEADLINE, first, because it is the answer to the task's own question

**Accuracy: solved, with no approximation at all — 30/30 scenarios EXACTLY 0.
Cost: NOT affordable. The ladder alone is MODELED at 4,273 cyc/sample on the
ESP32-S3, which is 1.86x the ~2,300 cyc/sample that remains after the
envelopes, and 122% of the entire 3,500 engine budget.** Nothing is left for the
DCO, the mixers, the HPF/VCA or any FX.

And the shortfall is **arithmetic, not layout**, so no amount of struct-packing
reaches it. MEASURED-STATIC from the real xtensa-esp-elf compile:

| per voice per host sample | float-arithmetic instructions |
|---|---|
| 4 sub-steps x 49 | 196 |
| the input node + decimator (`eb_vcf_tick`) | 38 |
| **total** | **234** |

x 8 voices = **1,872 float arithmetic instructions per sample**. On a 240 MHz
single-precision FPU at one op per cycle that is a **floor of 1,872 cyc/sample
with zero memory cost assumed** — 81% of the remaining budget before a single
load, store or loop counter is charged. The measured 4,273 is that floor plus
memory and overhead.

## Topology, as EXTRACTED (the task asked for this explicitly)

* **4x oversampling.** FOUR sub-steps per host sample; the input drive is
  linearly interpolated between last sample's and this one's with weights
  0.25 / 0.5 / 0.75 / 1.0 (cells [9232]/[9248]/[9216]/[9200]).
* **Four one-pole stages**, each a bilinear integrator
  `y[n] = G*(x[n]+x[n-1]) + (1-2G)*y[n-1]`, `G = g/(1+g)`, `g = tan(pi*fc/4H)`.
  Output taps [9072]/[9088]/[9104] are **0 / 0 / 1.0**: the 24 dB tap only. The
  12 and 18 dB taps are computed every sub-step and multiplied by zero.
* **Feedback enters AHEAD of the saturation, at the input node, and is
  RESOLVED, not iterated.** `S` is the zero-input response of the whole 4-pole
  chain one sub-step ahead, and the node solves `u*(1 + k*G^4) = in - k*S` with
  one real division. This is why the module is straight-line code with no
  iteration: there is no implicit equation left at run time.
* **The saturation sits on the SOLVED node, outside the loop:**

      x  = clamp(x, -1, +1)            (NaN -> -1.0; the `>=` test fails on NaN)
      nl = x + ((((x*x)*x)*x) * (x * -0.2))

  A hard clip followed by a **quintic `x - 0.2*x^5`**. The task says the curve
  matters more than the pole count, so it is transcribed in the source's exact
  evaluation order and NOT re-expressed as `x*(1 - 0.2*x^4)` — see the trap
  table, that regrouping is a real, if small, error.
* **Decimator**: the four sub-step taps feed four 8-deep lines = 32 samples of
  4x history, decimated by a symmetric 32-tap FIR folded into 16 coefficients
  ([9264]..[9504]), accumulated **centre pair first**, x 4.0.

### Where the blueprint and the oracle disagree

**They do not, on this block.** `docs/trackb/VCF.md` §1.5 / §3.8 / §3.9 is
correct in every particular I checked by execution: the 4x claim (which VCF.md
itself flags as CELLMAP being wrong with "3x"), the pipeline cell-to-value
mapping, the interpolation weights, the feedback pair, and the identification of
`p2` as stage 2 one sub-step ahead. The only textual difference in the port —
sub-step 4 associating its tap as `((y4*c24) + (c18*y3)) + (y2*c12)` instead of
`((y3*c18) + (y4*c24)) + (c12*y2)` — is pure commutativity of `+` and `*` and is
exact in IEEE-754 for non-NaN, which is why one helper serves all four
sub-steps. That was **verified by execution, not by reading**: 30/30 EXACTLY 0.

## Axis 1 — ACCURACY. `tools/engineb/null_b.py --module vcf_ladder`

**30 of 30 scenarios EXACTLY 0**, bit-identical every sample. The `--module
none` self-test was EXACTLY 0 in the same run, so the comparison is not vacuous
at the harness level, and the build log shows `shadowed: voice_render.c`.

    pluck POLY EXACTLY 0        MONO retrigger EXACTLY 0     UNISON pile-up EXACTLY 0
    chorus pad EXACTLY 0        delay keys EXACTLY 0         MONO glide EXACTLY 0
    long LFO+tail EXACTLY 0     DCO noise EXACTLY 0          DCO reset arm EXACTLY 0
    ENV trig arm warm EXACTLY 0
    idle chorus 1/48/441/4410/44100      all EXACTLY 0
    idle unison 1/48/441/4410/44100      all EXACTLY 0
    idle noise  1/48/441/4410/44100      all EXACTLY 0
    realloc unison EXACTLY 0     realloc chorus EXACTLY 0
    DCO neg pitch sweep / neg wrap + PWM clamp / neg warm chorus   all EXACTLY 0

All 17 idle-prefix scenarios included. Nothing free-running is skipped: the
dither phase is stepped through `eb_wrap24` on every sample whatever the voice
is doing.

### Non-vacuity, MEASURED, and the calibration of this gate

A green null on a new module is the exact shape a plumbing mistake takes, so
seven errors were planted in `eb_vcf_ladder.c` and driven through the real build
(`--quick`, 29 scenarios):

| planted error | result |
|---|---|
| **E: saturation removed** (`nl = x`) | **FAIL, 29 of 29**, worst global **-13.9 dB**, worst block -8.1 dB |
| **F: output x 1.00003** (calibration, must fail) | **FAIL, 29 of 29**, -90.4 dB |
| **G: output x (1+2^-23), 1 ULP** (calibration, must pass) | PASS, -128.7 dB |
| **A: saturation regrouped** to `x*(1 + K*(x*x)*(x*x))` | PASS, **-130.5 dB worst** — a real error, ~1-2 ULP, **below this gate** |
| **D: FIR summed outward-to-centre from 0.0** | PASS, -120.9 dB — a real error, below this gate |
| **B: drop the `S-1` feedback term** (its coefficient is 0.0) | **EXACTLY 0**, 29/29 |
| **C: `A = 1-2G` instead of `1-(G+G)`** | **EXACTLY 0** — `2.0f*G` is exact, the doc's warning does not bite here |

Read together: the module is very much in the audio path (86 dB of headroom on
E), the gate bites between 1 ULP and 3e-5 as designed, and **two of the
"evaluation order is load-bearing" warnings are worth 120-130 dB, i.e. real but
below -100 dB.** The verbatim forms are shipped anyway — they cost nothing — but
this gate does **not** prove they are needed, and that is an honest negative,
not a pass.

Trap H (one Newton refinement on the reciprocal) also came back EXACTLY 0. That
measures nothing about replacing the divide: refining an already
correctly-rounded reciprocal is a no-op. A genuine reciprocal *approximation*
was not measured and remains forbidden by the header.

### The wrap, over the whole float domain

`eb_wrap24` is a byte-for-byte copy of `src/juno_dsp.c`'s, and
`engine_b/tests/test_vcf_wrap24.c` compares the two **over all 2^32 float bit
patterns**, comparing BITS (so -0.0 != +0.0), 16,777,214 NaN inputs included:
**0 disagreements, PASS.** This is done because the dither phase free-runs
through it and because this project has already been bitten by an "obviously
identical" wrap replacement (eb_triangle, 8,388,608 disagreements out of 2^32).

## Axis 2 — COST. `tools/engineb/cost.py`, real compiles, three toolchains

Instruction counts are MEASURED-STATIC from real objects; cycles are MODELED
with the rig's own bands. `eb_vcf_substep` is **not** inlined by any of the
three compilers, so it is charged separately at 32 calls/sample (4 sub-steps x
8 voices) and `eb_vcf_tick` at 8.

| target | substep instr | tick instr | cyc/sample (nom) | band | share of the ~2,300 left after ENV |
|---|---|---|---|---|---|
| host x86-64 | 89 | 150 | **1,020** | 673 – 3,044 | — |
| Cortex-M7 | 82 | 136 | **3,909** | 1,993 – 12,924 | — |
| **ESP32-S3** | **87** | **197** | **4,273** | 2,633 – 11,566 | **186%** |

(The rig also prints `eb_vcf_reset` / `eb_vcf_hist_*`; those are not per-sample
and are excluded from the totals above. `eb_vcf_hist_*` exist only for the gate
shim.)

Against the whole 3,500 budget the S3 nominal is **122%**. Every S3 figure is
MODELED against **no S3 silicon**; the rig's own error bar is +-2x, so quote the
band. Even the optimistic end, 2,633, is 114% of what remains after the
envelopes.

One `__divsf3` per voice per sample [MEASURED-STATIC]: the ZDF resolution's
`1/(1+k*G^4)`. It is modelled at 25-180 cyc and is **not** removed, because the
only removals available are reciprocal approximations, which the header forbids
without a measured budget.

### Against the port, same block, same job

| | port (:1298-1515) | engine B | ratio |
|---|---|---|---|
| cells shifted per voice per sample, purely to move a value | **39** (7 pipeline + 32 dispersion) | **0** (7 floats not overwritten; one ring, 2-bit phase) | — |
| memory accesses per invocation, S3 STATIC | — | 102 (tick) + 32 x 20 (substep) | — |
| state bytes per voice | 768 (48 cells x 16 B) | **172** | 4.5x smaller |

172 B for this module; the voice struct is 204 B today, so the < 1 KB per-voice
budget still holds with room, and 128 of the 172 is the 4x history the 32-tap
decimator cannot do without.

## Cheaper options, priced, with their measured error

| lever | exact? | measured saving (S3 nom) | measured error | status |
|---|---|---|---|---|
| **LEAN**: drop the `S-1` feedback term and the two zero-valued taps (their coefficients are 0/0/0 with only init writers) | **yes as measured** | 4,273 -> **3,962**, i.e. **311 cyc/sample, 7.3%** | **EXACTLY 0, 29/29** | measured, **NOT shipped**: exactness is conditional on three INPUT-CONST cells staying zero, and 7.3% does not change the verdict |
| drop the 4x oversampling to 2x or 1x | **no** | up to ~75% of the sub-step cost, ~1,900 cyc/sample | **UNMEASURED** | **the only lever big enough, and it is a design task, not a tweak**: `G` is derived for the 4x rate (`[7856] = pi*440/(4H)`), so a lower rate needs the cutoff law re-derived AND a new decimator. Not attempted here; must not be adopted before it is nulled. |
| at-rest / silent-voice skip | yes, but | x (sounding voices / 8) | — | the ladder's state is input-driven and must not be skipped until it is exactly at rest; the dither phase free-runs and must be advanced regardless. The predicate must be decided from the coefficients, not the state, per the eb_env_atrest lesson. |
| struct packing, SoA, inlining | yes | small | — | pointless here: 1,872 float ops/sample is a floor no layout touches |

## The honest answer

**This module cannot be made both accurate and affordable at 8 voices on one
240 MHz core.** Accuracy is free — there is no approximation, so there is no
error budget to spend. Cost is not: the ladder alone is 1.86x the remaining
budget nominal, and its 1,872 float ops/sample floor is 81% of that budget
before any memory access is charged. Crossed with the envelopes' already
MEASURED 1,188, the two modules together are ~5,460 cyc/sample nominal, **156%
of the whole 3,500 engine budget**, with the DCO, mixers, HPF/VCA and all FX
still unwritten.

The decision that follows is a scoping decision, not a coding one, and it should
be taken now rather than after another module:

1. fewer voices (the cost is linear in voices and this module is 100%
   per-voice), or
2. a lower oversampling rate with a re-derived cutoff law and decimator, and its
   error measured through this same gate before it is adopted, or
3. a faster or dual-core target.

## Standing caveats

* `src/` is the ORACLE here, a fast proxy, never the authority
  (`docs/trackb/THREE_WAY_GATE.md`). This module has **not** been compared
  against the plugin.
* The shim keeps the module's 41 floats in the port's own cells so it inherits
  the port's lifecycle; that copying is harness cost and is excluded from every
  cycle figure. Cycle figures are measured on `eb_vcf_ladder.c` alone.
* Dropped SHADOW stores ([8992] and the six scratch cells [8336..8416], no
  reader outside the block): audio is unaffected, **per-cell state parity is
  not**. This is a sonic-identity claim, the same standing module M7 has.
* The `[9056] != 1.0` arm of the shim is unreachable under today's recall and is
  reproduced verbatim rather than deleted.

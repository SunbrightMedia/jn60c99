# ENGINE B — M-CHORUS: implemented, nulled EXACTLY 0, and costed (2026-08-02)

The module is `engine_b/eb_chorus.{h,c}`. It replaces
`src/master_render.c:2753-2937`, the EFFECT TYPE 2/3/4 arm. `src/` is untouched.

Everything below was executed. Nothing is quoted from the specification without
having been re-run.

---

## 1. Accuracy — EXACTLY 0, on all 30 scenarios

    python3 tools/engineb/null_b.py --module chorus
    VERDICT: PASS   worst global EXACTLY 0 everywhere

30/30, residual **EXACTLY 0** (bit-identical streams, not "below -100 dB"), and
that includes every idle-prefix scenario — the ones that exist because the
chorus LFO free-runs from power-on:

| scenario | residual | scenario | residual |
|---|---|---|---|
| pluck POLY | EXACTLY 0 | idle chorus 1 | EXACTLY 0 |
| MONO retrigger | EXACTLY 0 | idle chorus 48 | EXACTLY 0 |
| UNISON pile-up | EXACTLY 0 | idle chorus 441 | EXACTLY 0 |
| chorus pad | EXACTLY 0 | idle chorus 4410 | EXACTLY 0 |
| delay keys | EXACTLY 0 | idle chorus 44100 | EXACTLY 0 |
| MONO glide | EXACTLY 0 | idle unison 1 / 48 / 441 / 4410 / 44100 | EXACTLY 0 |
| long LFO+tail | EXACTLY 0 | idle noise 1 / 48 / 441 / 4410 / 44100 | EXACTLY 0 |
| DCO noise | EXACTLY 0 | realloc unison | EXACTLY 0 |
| DCO reset arm | EXACTLY 0 | realloc chorus | EXACTLY 0 |
| ENV trig arm warm | EXACTLY 0 | DCO neg pitch sweep | EXACTLY 0 |
| | | DCO neg wrap + PWM clamp | EXACTLY 0 |
| | | DCO neg warm chorus | EXACTLY 0 |

Ledger row (emitted by the proof, not typed):
`docs/trackb/EQUIVALENCE.tsv`, `chorus@78c2784`, scenario fingerprint
`8fe377bd13ad0e8c`, `ledger.py check` = 16 rows, 0 problems.

**Non-vacuity, MEASURED rather than assumed.** 19 of the 30 scenarios diverged
loudly (worst 0.4 dB rel) on this module's FIRST run, before the defect in §4
was fixed. Those 19 are therefore witnessed to reach the chorus arm. The 11 that
were EXACTLY 0 even then are patches on other EFFECT TYPEs and prove nothing
about this module — a fact worth keeping, because "30/30 EXACTLY 0" on its own
would not have told anyone that only 19 of them can see the code.

---

## 2. Memory — a compile-time budget

| item | bytes |
|---|---|
| `eb_chorus_state.line[1024]` — the BBD delay line | **4,096** |
| rest of `eb_chorus_state` (39 floats + 1 int) | 160 |
| `eb_chorus_coef` (38 floats + 1 int) | 156 |
| **total, one chorus** | **4,412** |

`EB_CHORUS_RING` is the compile-time budget and the line is one contiguous
array, so moving it to PSRAM is a question of where the struct lives, not a DSP
edit. A `typedef char[...]` assertion refuses a ring smaller than
`EB_CHORUS_MAX_DELAY + 2` or one that is not a power of two. MEASURED, the
longest delay the chorus ever asks for at 48 kHz is 456 samples, so
`-DEB_CHORUS_RING=512` (2,208 B total) is provably sufficient there; 1,024 is
kept as the default because 2 KB is not worth the argument.

**17 cells that are in the port and not here.** The port's arm stores the chorus
input (90368/90384), the four modulation cells (90768..90816), the two wet cells
(91056/91072), the two block outputs (91088/91104), the line-write value (95840)
and the six tap scratch cells (95856..95880) into the flat block every sample.
Each is written and read inside the same sample and never read again, so here
they are locals. That is DECIDED BY EXECUTION, not by reading: with them removed
the null is still EXACTLY 0 on all 30 scenarios. It removed 17 stores per sample
(MEASURED: 489 -> 468 executed x86 instructions per sample) and 68 bytes.

---

## 3. Cost — MEASURED on the host, MODELED on the cross targets

**MEASURED (callgrind, delta of 20,000 and 220,000 samples,
`tools/engineb/eb_chorus_cost.c` driving the module with the sealed port's own
48 kHz factory-patch-0 coefficients):**

    total executed x86-64 instructions per sample : 474
    of which the test driver's own loop           :  29
    THE MODULE                                    : 445

For comparison, `docs/engineb/FX_CHORUS.md` MEASURED the port's arm inside
`master_render` at **417** instructions per sample by the two-point difference
method. **The compact module is not cheaper in instructions on x86-64** — it is
about 7% dearer. That is the honest result and it is not a surprise: on an
out-of-order x86 with a 32 KB L1 the port's flat-block loads are nearly free, so
there was never an instruction-count win to be had there. The win engine B is
after is the memory tier and the absence of an 11 MB working set, and neither
shows up in an x86 instruction count.

**Cycle estimates (`tools/engineb/cost.py measure`, rho forced to the MEASURED
0.726 where stated; the ledger row uses the rig's own band):**

| target | cyc/sample, band (nominal) | share of the 3,500 budget |
|---|---|---|
| host x86-64 | 100 .. 672 (**211**) | — |
| Cortex-M7 (Daisy) | 251 .. 1,622 (**521**) | — |
| **ESP32-S3 (THE TARGET)** | **329 .. 1,434 (537)** | **9.4% .. 41.0% (15.3%)** |

Every S3 number is MODELED. No ESP32-S3 silicon number exists anywhere in this
project.

**Two corrections the rig needed, both MEASURED:**

1. **fmodf is charged and never executes.** `eb_wrap_unit` calls `fmodf` only
   when the LFO phase crosses ±1 — once per LFO period, i.e. once in 100,000
   samples at 48 kHz. Callgrind over a 200,000-sample delta shows **zero** fmodf
   calls in the profile at all. The rig's static count charges 4 of them at
   80..300 cycles each, which is roughly half its S3 nominal. The ledger's
   `strip_libm` subtracts it and records why. An independent check by a
   control build with the two fmodf calls removed (not shipped) puts the S3
   nominal at 554 against 1,079 with the charge — the same conclusion by a
   different route.
2. **A double leaked into the tap fraction.** The port computes it as
   `(float)((double)t - (double)(int)t)`, which on the S3 is 8 soft-float helper
   calls per sample (`__extendsfdf2`, `__floatsidf`, `__subdf3`, `__truncdfsf2`,
   MEASURED-STATIC). See §5 — it is now done in float, PROVEN.

**Against the first-guess sub-budget of 400 cycles for the chorus, the module is
over at its nominal (537) and inside at the optimistic end (329).** Against the
whole-engine budget of 3,500 it is 15.3% nominal. No cheaper version is offered,
because the only one available fails the accuracy standard — see §6.

---

## 4. A defect this module had, found by running it

The first run of `--module chorus` failed 19 of 30 scenarios with residuals
around 0 dB. The module's arithmetic was correct the whole time; the SHIM was
wrong. It keys the module's state on the engine's base pointer, the null
harness's worker renders 30 scenarios in one process, and `malloc` hands back
the same address for a new engine — so scenario N inherited scenario N−1's LFO
phase and delay line. Fixed by `ebsh_forget()`, called from a one-line fork of
`chorus_init.c` (`engine_b/shim/chorus/chorus_init.c`), which is exactly where
the port re-initialises those cells.

Worth recording for the next module: **the idle-prefix scenarios are what made
this visible**, and a state-carrying module gated only from a cold engine would
have shipped it.

Two harness self-checks were also needed on the way and are kept:
`v56` / `v58`, the two clamp fall-backs the port's arm inherits from earlier in
`master_render` as an IDA artefact, are **passed into** the module by the shim
rather than assumed — so the null cannot be green because of an assumption. They
were then MEASURED separately at **0.0 and −1.0 at every one of 14,000 chorus-arm
entries across 7 patches**, which is what `eb_chorus_tick()` hard-codes for the
standalone engine.

---

## 5. The one departure from the port's arithmetic, and its proof

`tools/engineb/fx_chorus_frac_proof.c` enumerates **every float bit pattern in
(−1024, 1024) — 2,298,478,592 of them**, which strictly contains the MEASURED
reachable range of 72..456 samples, and requires

    (float)((double)t - (double)(int)t)   ==   t - (float)(int)t

bit for bit including the sign of zero. **0 mismatches.** Runs in 5 s; exit code
is the verdict.

Nothing else is re-expressed. In particular `fmodf` is **not** replaced by
`x - 2`: the reachable phase exceeds 1 by only ~2e-5 so the two look equivalent,
`x + 1` near 2.0 rounds at an ulp of 2.4e-7 while `x - 2` is exact, and this
project has already shipped exactly that mistake once (wrong on 8,388,608 of
2^32 inputs). It also costs nothing, MEASURED, so there is no reason to take the
risk.

---

## 6. The cheaper option, with its measured error, so the trade is a decision

The only lever of any size is the BBD noise generator. `FX_CHORUS.md` estimated
its level at −92 dB against the dry signal and concluded it may not be dropped.
That estimate is right in direction and much too kind in magnitude. MEASURED, by
removing only its two injection terms and re-running the null:

| | |
|---|---|
| worst global residual | **−54.3 dB rel** (best scenario −68.1 dB) |
| scenarios failed | **17 of 30** |
| worst 1024-block | **0.0 dB rel** in four scenarios (blocks where the tail *is* the noise) |
| saving | **21 executed x86 instructions per sample** (489 -> 468), ~22 S3 cycles MODELED |

That is **46 dB above** the −100 dB gate for a 4% saving. The trade is refused,
and it is refused with a number rather than with the specification's adjective.

---

## 7. Files

| file | what |
|---|---|
| `engine_b/eb_chorus.h` / `.c` | the module |
| `engine_b/eb_chorus_shim.{h,c}` | null-harness glue; NOT the engine (see its header comment) |
| `engine_b/shim/chorus/master_render.c` | verbatim fork of `src/master_render.c`, one block replaced |
| `engine_b/shim/chorus/chorus_init.c` | verbatim fork, one line added (§4) |
| `tools/engineb/fx_chorus_frac_proof.c` | the 2.3-billion-input exhaustive proof |
| `tools/engineb/eb_chorus_cost.c` | the callgrind driver for the MEASURED instruction count |
| `docs/trackb/EQUIVALENCE.tsv` | the emitted ledger row |

## 8. Still owed

* No comparison against the PLUGIN. `tools/engineb/plugin_check.py` is the
  authority; `src/` is not. This row is a fast proxy result and says so.
* The S3 cycle figure has no silicon anchor. It is MODELED and its band is
  4.4x wide.
* `fminf` is still two out-of-line calls per sample (12 executed instructions,
  MEASURED). `__builtin_fminf` would remove them; it is not done because the
  signed-zero case is not proven and the saving is 2.7%.
* EFFECT TYPE 4 (flanger) shares this arm with four overridden coefficients and
  is untested here — no factory patch reaches it. EFFECT TYPE 5 (ensemble) is a
  different block entirely and is not this module.
* The order-dependent LFO rate recall recorded in `FX_CHORUS.md` §6 is a
  RECALL-side finding and is untouched by this work; engine B's parameter module
  must write the LFO rate unconditionally.

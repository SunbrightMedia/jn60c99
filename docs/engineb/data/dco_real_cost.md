# P3 — the DCO's real cost, MEASURED x STATIC (no QEMU)

Date 2026-08-03 (Opus 5). Closes hole H4 of `docs/engineb/DOUBT_AUDIT.md`.

## The question

`qemu_instr_counts.md` put `eb_dco_step4` at **17,581 instructions per sample**
and flagged it as worst-case-ish, for two reasons. The harness drove the module
with SYNTHETIC coefficients — all three waveform levels non-zero, and a signal
that does not sit at the saturator's clamp — so both of the module's large
branch savings were switched off. And the harness's per-call spans are
untrustworthy in general (CCOUNT advances 25 instructions at a time at
translation-block boundaries; two builds differing only in `EB_PITCH_FAST`
disagreed by exactly 500,000 raw units on functions that did not change).

So the DCO was the single largest cost unknown in the plan.

## The method — neither half touches QEMU

**MEASURED** (`tools/engineb/dco_rates.py`): counters compiled into
`engine_b/eb_dco.c` under `-DEB_DCO_COUNT`, counting how often each branch is
TAKEN while rendering the **real gated 30-scenario set on real recalled factory
patches** through the real port render path. The counters are write-only; the
DSP never reads them, so an instrumented build computes the same samples.
**60,989,440 sub-sample steps** were counted at 48,000 Hz.

**STATIC** (`tools/engineb/dco_paths.c` + `dco_price.py`): each path's
arithmetic copied verbatim into an isolated `noinline` probe, cross-compiled
with `xtensa-esp32s3-elf-gcc -O2 -ffp-contract=off`, instructions counted by
`objdump`. libgcc helper BODIES are added at their executed rate — `objdump`
counts a call as one instruction, and `__divsf3` is **30 instructions**
(MEASURED from this toolchain's own `libgcc.a`).

## The measured branch rates

| branch | rate |
|---|---|
| saw arm on | **53.36 %** |
| pulse arm on | 100.00 % |
| sub arm on | **38.57 %** |
| saw saturator took the CLAMP SHORTCUT | **99.65 %** |
| pulse saturator took the CLAMP SHORTCUT | **99.17 %** |
| sub saturator took the CLAMP SHORTCUT | **99.64 %** |
| `eb_dco_wrap` slow (fmodf) arm | **0.000 %** (0 of 60,989,440) |
| sub counter bump | 0.041 % |

The clamp shortcut hypothesis in `eb_dco.h` is confirmed on real patches: it
fires on 99.2–99.7 % of saturator calls. The synthetic QEMU run defeated it.
The fmodf wrap arm was taken **zero** times — it is correctness insurance, not
a cost.

## Static path prices (Xtensa instructions)

| probe | default | EB_DCO_RECIP=1 |
|---|---|---|
| `p_fixed` (wrap + phase + sub counter) | 87 | 87 |
| `p_saw` | 31 | 31 |
| `p_pulse` | 165 | 121 |
| `p_sub` | 50 | 50 |
| `p_sat` (full polynomial) | 25 | 25 |
| `p_sat_short` (the shortcut) | 16 | 16 |
| `p_mix` | 14 | 14 |
| `__divsf3` body, 1 executed per pulse step | 30 | — |
| `eb_dco_step4` whole body, for scale | 475 | 431 |

## THE RESULT

| configuration | instr/sub-sample | **instr/sample, 8 voices** |
|---|---|---|
| **default, real patches** | 363 | **11,610** |
| **EB_DCO_RECIP=1, real patches** | 319 | **10,202** |
| default, worst case (all arms on, no shortcut) | 452 | 14,464 |

**The DCO's real cost is ~11,600 instructions per sample, not 17,581.** The
QEMU figure was **51 % high**, and the difference is entirely branch rates.

**Cross-check between the two methods.** Priced on the SAME configuration the
QEMU harness actually ran — all arms on, shortcut never taken — these static
prices give 14,464 against QEMU's 17,581: **18 % apart**, in the direction the
isolation caveat predicts (see below). Two independent methods agreeing to
within a fifth on the same configuration is what makes the real-patch number
credible; it is a rate effect, not a different cost model.

## EB_DCO_RECIP is now worth a firm number

Adopting the reciprocal saves **1,408 instructions per sample (12 % of the
module)** on real patches. Its sonic cost is now gated at both rates:
**−121.5 dB at 48 kHz, −121.1 dB at 44.1 kHz** (P1, this session), against a
−100 dB gate. It is the best-evidenced lever currently unadopted.

## Stated limitations

* **Isolation over-prices the arms.** Each probe pays its own prologue and
  reloads coefficients that the real `step4` keeps in registers across all four
  sub-samples. These figures are therefore an over-estimate of each arm's
  marginal cost, which is the safe direction and is part of why the worst-case
  cross-check lands below QEMU's.
* Static counts include instructions in untaken branches within a probe.
  Also the safe direction.
* **Instructions are not cycles.** On an in-order LX7 the cycles-per-instruction
  factor is ≥ 1 and unknown until silicon (hole H5). Nothing here is a cycle.
* The rates are those of the gated scenario set. It is the most patch-diverse
  driving the project has, but a patch with all three levels up and a very low
  pitch would sit nearer the worst case.

# QEMU ESP32-S3 — the first EXECUTED instruction counts for engine B

Date 2026-08-03. Recovered from `tools/engineb/qemu/run.log`: the harness agent
completed the build AND the run before it hit the session limit; only its
report was lost. The harness, its build scripts and the raw log are committed
in `tools/engineb/qemu/`.

## What was measured

Espressif QEMU 9.2.2, `-M esp32s3 -icount shift=0`, bare-metal ELF in internal
SRAM, no cache modeling. Real recalled FX coefficients from the sealed port
(factory patch 0, 48 kHz, `gen_fx_coefs.py` → `fx_coefs.h`); evolving non-silent
inputs; every region's float sink checked non-zero and finite; delay/reverb
overrun guards 0. 100,000 calls per voice function, 12,500 whole-sample
iterations.

**Units: QEMU-executed Xtensa instructions.** NOT cycles: no cache misses, no
FPU latency, no memory waits. A cycles-per-instruction factor ≥1 sits on top.

## The counter scale — INFERRED, cross-checked four ways

In this build CCOUNT advances once per **25** executed instructions (icount
virtual time at 1 ns/instruction × the machine's 40 MHz default CPU clock).
The harness's own comment says once per instruction; that is wrong, and the
CAL region proves it (an empty measured span averages 0.042 ticks — impossible
at 1 tick/instruction). The ×25 scale is confirmed by four independent
branch-light functions whose static counts are known:

| function | static instr | measured ×25 |
|---|---|---|
| eb_env_tick | 81 | 84 |
| eb_decim_tick | 152 | 161 |
| eb_cvgate | 37 | 40 |
| eb_nsvf_tick | 26 | 34 |

(The excess over static is the call/argument overhead the MEAS window includes.)
Verification for the next session: run a counted 3,000,000-instruction loop and
compare; one command, decisive.

## The numbers (MEASURED, ×25 scale applied)

| region | instr/call | calls/sample | instr/sample |
|---|---|---|---|
| **pitch, DOUBLE (as shipped)** | **3,419** | 8 | **27,351** |
| **dco_step4** | **2,198** | 8 | **17,581** |
| vcf ladder tick | 1,106 | 8 | 8,850 |
| vca/hpf | 492 | 8 | 3,936 |
| env (×2) | 84 | 16 | 1,341 |
| decim | 161 | 8 | 1,288 |
| vcf_cv | 113 | 8 | 904 |
| modcv | 93 | 8 | 744 |
| cvgate | 40 | 8 | 320 |
| nsvf | 34 | 8 | 272 |
| chorus + delay + reverb + noise | — | 1 each | 1,635 |
| sum of parts | | | 64,222 |
| **whole chain, measured directly** | | | **71,051** |

(The ~6,800 gap between the sum and the direct total is the harness's own loop
scaffolding, gate cycling and input dithering — stated, not hidden.)

## What this settles

1. **The pitch-double model is validated.** Modeled 2,277–2,786 instr/call
   common-path (exceptions excluded, "only push it higher"); MEASURED 3,419.
   The pitch block alone is **27,351 instr/sample = 5.5× the one-core budget,
   2.9× the two-core budget.** Its removal (pitch v3) stays the top item.
2. **The whole chain today is ~71,000 instr/sample vs 9,500 two-core cycles**
   — 7.5× over BEFORE any cycles-per-instruction factor. After the pitch fix:
   ~44,000, still ~4.6× over. The host-derived post-fix band (17,700–22,300)
   was **optimistic by roughly 2×** — the same direction and size as the M7
   precedent (2.2×).
3. **The next wall after pitch is measured, not guessed:** dco_step4 17,581
   and the ladder 8,850. CAVEAT on the DCO figure: the harness's synthetic
   levels likely keep the saturator's cheap shortcut (98.7 % of calls on real
   patches) from firing, so 17,581 is toward the worst case; replaying a real
   scenario through the harness bounds it properly. The ladder figure has no
   such caveat.
4. FX are cheap on the S3 (1,635/sample total) — the constraints' "all FX"
   demand costs little; the fight is the voice path.

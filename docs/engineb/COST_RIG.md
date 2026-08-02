# THE ENGINE B COST RIG — `tools/engineb/cost.py`

Built 2026-08-02. Every engine B design decision is now measured, not argued.

    python3 tools/engineb/cost.py calibrate
    python3 tools/engineb/cost.py measure <file.c> -I src --calls fn=8
    python3 tools/engineb/cost.py density --source <file.c> -- <exe> '{n}' 8 --save

## What it does

For a C file or function it compiles for three real toolchains, disassembles
the real objects, counts instructions by class, and models cycles for each
audio sample against the 3,500 cyc/sample engine B budget.

| target | toolchain | status |
|---|---|---|
| host | `gcc` x86-64 | present. The only target where DYNAMIC counts can be measured. |
| m7 | `arm-none-eabi-gcc`, `-mcpu=cortex-m7 -mfpu=fpv5-d16 -mfloat-abi=hard` | present. The calibration anchor — this project owns real Daisy SILICON. |
| s3 | `xtensa-esp32s3-elf-gcc` (esp-16.1.0, GCC 16.1.0) | present. **THE TARGET.** No silicon exists. |

A missing toolchain is reported as SKIPPED. It is never estimated and never
faked.

## The model

    cycles_per_invocation = issue + memory + libm + softfloat

    issue    = SUM over classes  n_class * cpi_class      (CPI table in the tool)
    memory   = ACCESSES * extra_latency(memory_tier)
    everything is then scaled by rho, the execution density

Three parts of this are worth stating because each one fixes a specific error
this project has already made.

**1. `rho`, the execution density.** Static instruction counts charge both
sides of every branch. That is exactly the flaw in the retired 2.15x llvm-mca
model. `rho` = dynamic instructions / static instructions, MEASURED on the host
with callgrind using a delta of two run lengths (which removes bank parse and
teardown from the render loop). MEASURED for `juno_voice_render`:

    22,288 dynamic x86 instr/sample / 8 voices / 3,467 static = rho 0.804

`rho` is measured on x86 and TRANSFERRED to the cross targets. Same source,
same `-O2`, same control flow, different branch layout — treat as +/- 15%. It
is the one genuinely MODELED step in the instruction count.

**2. Memory ACCESSES, not memory INSTRUCTIONS.** ARM `ldm/stm/push/pop/vldm`
move a whole register list in one instruction. Counting instructions
under-counted the port's accesses by 0.66x against the board's own figure;
weighting by register-list length brings it to 0.86x. This mattered because
accesses are the term that decides the whole budget.

**3. Per-access latency is a tier, not a multiplier.** MEASURED tiers:

| tier | extra cyc/access | label |
|---|---|---|
| `tcm` | 0 | M7 ITCM/DTCM |
| `axi` | 13 / 16 / 19 | MEASURED, Daisy AXI SRAM |
| `sdram4` | 78.74 | MEASURED, Daisy SDRAM 4-byte stride (E7) |
| `sdram16` | 138.10 | MEASURED, Daisy SDRAM 16-byte stride (E7) |
| `s3_iram` | 0 / 0.3 / 1.0 | MODELED, ESP32-S3 internal SRAM |
| `s3_psram` | 30 / 60 / 120 | MODELED-UNVALIDATED. A guess. Do not quote. |

## The blanket-multiplier correction (do not re-litigate)

The brief supplied `1.125 x 2.53 x 2.193 = 6.24x` from host to Daisy. Applied
to the MEASURED host figure:

    14,970 x 6.24 = 93,414 cyc/sample

That is the OLD E2 number (93,288) — the one `docs/trackb/SILICON_TRUTH.md`
proves was a 32-bit DWT counter wrap artefact and declares VOID.

    TRUE host -> Daisy ratio  = 669,682 / 14,970 = 44.7x
    the 6.24x decomposition accounts for            6.24x
    UNACCOUNTED residual                            7.16x

The residual is not a mystery: 9,850 accesses/sample x 68 cyc = 669,800, the
entire Daisy cost to within 0.02%. **The rig therefore uses no blanket
multiplier at all.** It models issue and memory separately, because that split
is also the entire thesis of engine B: shrinking 10,512 B/voice to <1 KB/voice
does not make the arithmetic faster, it removes the term that is ~95% of the
cost.

## Calibration — what the rig is allowed to claim

Two independent validation points, both run by `cost.py calibrate`:

**M7 arm, against the one real SILICON number.** Back-solving the per-access
latency that reproduces 669,682 cyc/sample, given this rig's issue term:

    IMPLIED per-access latency          69.7 cyc   [MODELED from the rig]
    board's own accesses/sample figure  68.0 cyc   [MEASURED, SILICON_TRUTH]
    agreement                           2.5%

Predicting forward instead: with every cell at the MEASURED `sdram4` latency
the rig says 746,455 against a SILICON 669,682 — **1.11x over**. It over-
predicts because not every access reaches SDRAM (stack, literals, the chorus
block are faster). The blended 69.7 landing between the MEASURED AXI (16) and
SDRAM-4B (78.7) tiers is what a mixed placement should give.

**Host arm, independent of the M7 arm.**

    MEASURED host instructions/sample   30,459
    MEASURED host cycles/sample         14,970  ->  IPC 2.03
    rig's host CPI table predicts       12,184  ->  error 0.81x

### Error bars — the binding statement

| arm | quality | what you may say |
|---|---|---|
| M7 + SDRAM | +/- 1.2x, one board, one workload | order of magnitude, never the third digit |
| M7 + TCM/AXI | latencies MEASURED, combination never measured end to end | MODELED |
| **ESP32-S3** | **nothing is calibrated** | instruction counts are MEASURED-STATIC from a real compile; **every cycle figure is MODELED, treat as +/- 2x** |
| rho | MEASURED on x86, transferred | +/- 15% |

The rig prints a BAND, never a point. The width of the band is the honest
answer. A rig that reports a confident wrong number is worse than one that
reports a range — so the tool refuses to report a point.

## What it already found, on its first run

Costing the sealed port for the S3 (`measure src/voice_render.c
src/master_render.c src/juno_dsp.c --calls juno_voice_render=8 ...`):

**MEASURED-STATIC, the port on the ESP32-S3:**

| finding | count |
|---|---|
| soft-float helper calls per sample | **168** — `__muldf3` 51, `__adddf3` 27, `__subdf3` 14, `__floatsidf` 13, `__extendsfdf2` 26, `__truncdfsf2` 25, `__divsf3` 9, `__fixdfsi` 2, `__ledf2` 1 |
| libm calls per sample | 26 — `fmodf` 24, `expf` 2 |
| memory accesses per invocation, voice_render | 2,154 static (1,155 of them float — this independently reproduces the repo's MEASURED 1,155 accesses/voice/sample) |

The `__*df*` family means **doubles leaked into the DSP**. The LX7 FPU is
single-precision only and has no divider, so each one is tens to hundreds of
cycles. This is a class of cost that is invisible on x86 and on the M7 (which
has `vdiv.f32`), and it is the first thing engine B must never do. The rig
prints it as its own loud line for that reason.

**MODELED cost of the sealed port on the S3, for reference only:**

    88,095 cyc/sample nominal (band 43,498 .. 280,178) = 25.2x the 3,500 budget

This is a MODELED figure with an uncalibrated +/- 2x. It is quoted to set the
scale of the rewrite, not as a result.

## Subcommands

    calibrate   run both validation points; print what is and is not calibrated
    measure     cost a file/function for every available target
                --func REGEX     select functions (repeatable)
                --calls FN=N     invocations per sample, per function
                --per-sample N   invocations per sample, global
                --tier TIER      memory tier override
                --rho R          force execution density
                --json OUT       machine-readable report
    density     MEASURE rho with callgrind, delta of two run lengths
                --divisor FN=N   normalise a function called N times per sample
                --save           write docs/engineb/DENSITY.json

`docs/engineb/DENSITY.json` holds the MEASURED densities and is read
automatically by `measure` and `calibrate`.

## Known limits

- Static counts are per compile unit and do not see cross-TU inlining. Cost a
  module the way it will actually be built.
- `rho` for a function called more than once per sample reads > 1 unless you
  pass `--divisor`; that is call multiplicity, not density.
- The libm and soft-float cycle costs are MODELED bands (80–300 and 25–180).
  No cycle count for newlib `expf` on either target exists in this project.
- Instruction cache and prefetch behaviour is not modelled at all. On the Daisy
  that term is MEASURED at 1.27x (ITCM) and 2.19x (I-cache off); on the S3 it
  is unknown.

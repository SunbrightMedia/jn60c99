# Engine B — honest per-function ESP32-S3 cost table

Date 2026-08-03. This table is MODELED. No engine B code has run on an ESP32.
The model multiplies MEASURED host executed counts by STATIC cross-compile
ratios, and then adds STATIC soft-float penalties. Precedent for caution: the
M7 model in this repo was 2.2x below the silicon number. Treat every total
here as a lower-bound-flavored estimate until a device measurement exists.

## Method and commands

1. STATIC S3 counts. Each `engine_b/eb_*.c` compiled with:

       xtensa-esp32s3-elf-gcc -std=c99 -O2 -ffp-contract=off \
         -fno-strict-aliasing -DEB_DELAY_LEN=65536 -Iengine_b -Isrc -c
       (toolchain: crosstool-NG esp-16.1.0_20260609, gcc 16.1.0)

   All 17 modules compiled clean for both targets, zero warnings.
   Instructions counted per function from `xtensa-esp32s3-elf-objdump -d`,
   lines that match `^\s+[0-9a-f]+:` inside each function symbol. Xtensa
   literal pools (`.literal`) are data, not code, and are excluded; the `l32r`
   loads that read them are counted.

2. STATIC host counts. Same flags with `cc` (x86-64), same objdump count.

3. MEASURED host executed instr/sample: callgrind, 8 voices, patch 20,
   48 kHz (measurement of 2026-08-02/03, reused, not re-run). The 14 rows sum
   to 14,927 instr/sample, which matches the 14,871 whole-DSP figure in
   `docs/engineb/COST_MEASURED.md` to 0.4 % — the row set is the complete
   engine B DSP.

4. S3 base estimate per function = host_executed x (s3_static / host_static).
   MODELED. Assumption: the executed instruction mix scales with the static
   mix. The call instructions to libgcc/libm helpers are inside the static
   counts on both sides; the helper BODIES are not, so they are added as
   explicit penalties (step 5).

5. Penalties = executed helper calls/sample x helper static body size.
   Helper body sizes counted from the toolchain's own esp32s3 multilib
   (`objdump -d` on libgcc.a / libm.a) — STATIC, and they CONFIRM the census
   in the tasking exactly:

   | helper | static instrs | source |
   |---|---|---|
   | `__muldf3` | 105 | libgcc.a |
   | `__adddf3` | 116 | libgcc.a |
   | `__extendsfdf2` | 37 | libgcc.a |
   | `__truncdfsf2` | 59 | libgcc.a |
   | `__fixdfsi` | 28 | libgcc.a |
   | `__divsf3` | 30 | libgcc.a |
   | `fmin` / `fmax` (double) | 21 each | libm.a, self-contained, no further calls |
   | `fminf` / `fmaxf` | 24 each | libm.a |
   | `fmodf` | 30 | libm.a — MEASURED 0 executions, no penalty |

   ASSUMPTION (stated, load-bearing): straight-line common path — one helper
   call executes the full static body. The special-case branches (NaN, inf,
   denormal) make the true common path somewhat shorter; the windowed-ABI
   entry/`retw` are included. This makes the penalty a per-call cost BAND
   with the static size as its top.

## Penalty derivation

- **eb_pitch (8 calls/sample, one per voice).** `eb_render.c:72` runs
  `eb_pitch_eval(pit, juno_pitch_table[eb_pitch_row(pit)], 1.0f)` per voice
  per sample, so the WHOLE-FILE relocation census executes once per call:
  23 `__muldf3` + 13 `__adddf3` + 2 `__extendsfdf2` + 1 `__fixdfsi` +
  1 `__truncdfsf2` + **4** double `fmin`/`fmax` (the tasking said 2; the
  relocation census is 2 `fmin` + 2 `fmax` sites — 2 in `eb_pitch_eval`'s
  inlined clamp, 2 in `eb_pitch_row`'s; both pairs are on the straight-line
  path, so 4 is used) + 2 `fminf`/`fmaxf`. `eb_pitch_eval` (eb_pitch.c:19-42)
  is branch-free straight-line code, so the census IS the executed path.
  Per call: 23x105 + 13x116 + 2x37 + 1x28 + 1x59 + 4x21 + 2x24 = **4,216**.
  Per sample: 8 x 4,216 = **33,728**. STATIC counts on MEASURED call rate.
- **eb_dco divides.** MEASURED 32 executed `__divsf3`/sample (relocation
  census + execution count from the tasking). 32 x 30 = **960**.
- **eb_vcf_ladder divide.** One `__divsf3` site, `eb_vcf_ladder.c:129`
  (`R = 1.0f / (...)`), unconditional inside `eb_vcf_tick` → 8
  executions/sample (INFERRED from structure: one per voice-tick, no branch
  around it). 8 x 30 = **240**.
- **Float clamp bodies elsewhere** (`fminf`/`fmaxf` are library calls on the
  S3): `eb_vca_hpf.c:58` common path 8/sample, `eb_delay.c:73/87/88` ~3/sample,
  `eb_chorus.c` ~2/sample → ~13 x 24 = **312**. INFERRED (site inspection,
  common-path execution assumed).

## The table

host exec/sample = MEASURED (callgrind, host). statics = STATIC. ratio,
base, total = MODELED.

| function | host exec/sample | s3 static | host static | ratio | S3 base | penalty | total |
|---|---|---|---|---|---|---|---|
| eb_pitch_eval (+row+soft-double) | 536 | 221 | 76 | 2.91 | 1,559 | 33,728 | **35,287** |
| eb_dco_step4 | 3,012 | 475 | 521 | 0.91 | 2,746 | 960 | 3,706 |
| eb_vcf_tick | 2,426 | 200 | 154 | 1.30 | 3,151 | 240 | 3,391 |
| eb_vcf_substep | 2,624 | 87 | 93 | 0.94 | 2,455 | 0 | 2,455 |
| eb_vca_tick | 1,448 | 208 | 223 | 0.93 | 1,351 | 0 | 1,351 |
| eb_env_tick | 1,264 | 81 | 86 | 0.94 | 1,191 | 0 | 1,191 |
| eb_decim_tick | 952 | 152 | 125 | 1.22 | 1,158 | 0 | 1,158 |
| eb_vcf_cv_tick | 576 | 95 | 72 | 1.32 | 760 | 0 | 760 |
| eb_reverb_process | 511 | 765 | 731 | 1.05 | 535 | 0 | 535 |
| eb_modcv_tick | 296 | 61 | 40 | 1.52 | 451 | 0 | 451 |
| eb_delay_process | 354 | 254 | 267 | 0.95 | 337 | 0 | 337 |
| eb_chorus_tick_x | 432 | 564 | 738 | 0.76 | 330 | 0 | 330 |
| eb_cvgate | 264 | 37 | 51 | 0.73 | 192 | 0 | 192 |
| eb_dco_set_shape | 232 | 27 | 31 | 0.87 | 202 | 0 | 202 |
| float clamp bodies (vca/delay/chorus) | — | — | — | — | — | 312 | 312 |
| **SUM** | **14,927** | | | | **16,415** | **35,240** | **51,655** |

## Instructions are not cycles

The LX7 is in-order and single-issue. Loads from internal SRAM, taken
branches (~2-3 cycles), and pipeline interlocks push cycles/instruction above
1.0. The soft-double helpers are branchy, so they sit at the high end. Band
used: **1.0x to 1.5x cycles per instruction**. From flash cache or PSRAM the
band does not hold at all — this table assumes hot code and hot state in
internal SRAM (which is its own open problem: `EB_DELAY_LEN=65536` floats is
256 KB of the S3's 512 KB SRAM before reverb, chorus, and voices).

## Against the budgets (MODELED)

| | nominal (1.0 c/i) | at 1.5 c/i |
|---|---|---|
| total cycles/sample | 51,655 | 77,483 |
| vs 5,000 one core (hard) | **10.3x over** | 15.5x over |
| vs 3,500 target | 14.8x over | 22.1x over |
| vs 9,500 two cores | **5.4x over** | 8.2x over |

## What the number is made of (the actionable structure)

1. **The pitch soft-double penalty is 33,728 of 51,655 — 65 % of the whole
   engine.** One function file, running a double-precision 13-term polynomial
   per voice per sample on a core with no double FPU. Every `__muldf3` that
   is one host `mulsd` becomes ~105 S3 instructions. This is the single
   dominant fact of the table.
2. Remove that penalty entirely (hypothetically: single-precision or
   per-note/blockwise evaluation — an accuracy question for the -100 dB gate,
   NOT decided here) and the engine is **17,927 nominal → 3.6x over one core,
   1.9x over two cores** at 1.0 c/i.
3. The remaining mass is the per-voice 4x-oversampled ladder + DCO:
   dco_step4 + vcf_tick + vcf_substep + decim + vcf_cv = 12,470 of 17,927
   (70 %). FX (reverb + chorus + delay) are small: 1,202 total.
4. The divide penalties (960 + 240) are real but minor; `__divsf3` is
   FPU-assisted and cheap.

## Caveats (all of them)

- MODELED end to end. The static-ratio method assumes the executed mix
  scales with the static mix per function. Unproven for this ISA pair.
- The libgcc penalty uses full static body size per call (straight-line
  assumption). True executed path is somewhat shorter; the M7 precedent says
  models can also err 2.2x the OTHER way.
- Functions not in the callgrind row set (`eb_nsvf_tick`, `eb_dco_advance`,
  `eb_pitch_row` in-function code ~15 instrs x 8, `eb_engine_render` glue
  ~315 static) are not in the base sum. On the host they were inlined or
  below the row set's floor; order ~500-1,000 instr/sample of standalone
  plumbing is not counted here.
- Host static counts include glibc stack-protector overhead (`__stack_chk_fail`
  in eb_delay); the xtensa build has none. Skews that ratio slightly low.
- `fmin`/`fmax`/`fminf`/`fmaxf` are out-of-line calls on BOTH targets at
  these flags, so the ratio treatment of the call sites is symmetric; only
  the S3 bodies are added as penalty.
- Host callgrind numbers are per-function SELF counts; host libm bodies were
  not inside them. The S3 penalties add the S3 bodies, so the accounting is
  consistent.

## Verdict this table supports

At 8 voices + all FX + 48 kHz, the honest S3 estimate is **51,655
instr/sample nominal (10.3x over one core, 5.4x over both cores)** — but 65 %
of that is one removable class of cost (double-precision pitch evaluation),
not the engine's structure. After that class, the gap to two cores is ~1.9x
nominal and ~2.9x at 1.5 c/i. The prior "host instructions vs S3 cycles"
comparison understated the gap (it missed 35k of soft-float); this table
replaces it. Next fact needed: any one function measured on real silicon to
pin the c/i band and validate the ratio method.

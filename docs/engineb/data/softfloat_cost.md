# Soft-float helper cost on ESP32-S3 — EXECUTED common path, not static size

Date: 2026-08-03. Toolchain: xtensa-esp-elf-gcc 16.1.0 (crosstool-NG
esp-16.1.0_20260609), libgcc for esp32s3.

## Method (commands, reproducible)

```
export PATH=/root/.espressif/tools/xtensa-esp-elf/esp-16.1.0_20260609/xtensa-esp-elf/bin:$PATH
LIBGCC=$(xtensa-esp32s3-elf-gcc -print-libgcc-file-name)
# = .../lib/gcc/xtensa-esp-elf/16.1.0/esp32s3/libgcc.a
ar x $LIBGCC _muldf3.o _addsubdf3.o _divsf3.o _truncdfsf2.o _extendsfdf2.o _fixdfsi.o _cmpdf2.o
xtensa-esp32s3-elf-objdump -d <obj>   # hand-trace of the common path

LIBM=/root/.espressif/tools/xtensa-esp-elf/esp-16.1.0_20260609/xtensa-esp-elf/xtensa-esp-elf/lib/esp32s3/libm.a
ar x $LIBM libm_a-s_fmax.o libm_a-s_fmin.o libm_a-s_fpclassify.o libm_a-sf_fmax.o libm_a-sf_fpclassify.o

# call-site census re-check (this session, MEASURED):
xtensa-esp32s3-elf-gcc -O2 -c engine_b/eb_pitch.c -o eb_pitch_s3.o -Iengine_b -Isrc
xtensa-esp32s3-elf-objdump -r eb_pitch_s3.o | grep 'SLOT0_OP\s\+\(__\|fm\)' | awk '{print $3}' | sort | uniq -c
```

Census result (MEASURED, this session): 23 `__muldf3`, 13 `__adddf3`,
2 `fmin`, 2 `fmax` (double), 2 `__extendsfdf2`, 1 `__truncdfsf2`,
1 `__fixdfsi`, 1 `fminf`, 1 `fmaxf`. This confirms the prior census and adds
the fminf/fmaxf pair it did not list. The compiled object has **zero branch
instructions** (grep over the disassembly = 0). Thus the static site count IS
the executed count for each call pair (`eb_pitch_row` + `eb_pitch_eval`).
Caller-side code: 236 instructions total in the object's .text
(245 disassembly lines minus 9 literal words), all straight-line.

Trace rule: for each helper I follow the path for NORMAL FINITE inputs with a
normal result. At each special-case test I take the no-special-case arm. I
count every instruction from `entry` to `retw.n`, both arms of data-dependent
branches give the band. Labels: instruction counts = STATIC (hand-traced
common path in the disassembly); cycle bands = MODELED (LX7 single-issue,
1 cycle/instr, +2 per taken branch, load-use stalls on `l32r`, mull result
latency ~2, no window-overflow exceptions).

## Per-helper results

| helper | common-path instr | loops? | hardware mul used | cycle band/call |
|---|---|---|---|---|
| `__muldf3` | 57–66 | **NO** | **YES: 4x `mull` + 4x `muluh`** | ~65–90 |
| `__adddf3` effective-add | 27–37 | NO | — | ~30–50 |
| `__adddf3`/`__subdf3` effective-sub | 33–46 (+~10 on cancellation) | NO | — | ~35–55 |
| `__divsf3` | 30, straight-line, ALL FPU (`div0.s`/`maddn.s`/`divn.s` Newton-Raphson) | NO | — | ~35–55 (serial FP dependency chain) |
| `__extendsfdf2` | 14 | NO | — | ~15–22 |
| `__truncdfsf2` | 17 (no round) / 20 (round) | NO | — | ~18–28 |
| `__fixdfsi` | 16 (result >= 1) / 10 (result 0) | NO | — | ~17–24 |
| `fmax`/`fmin` double (newlib) | ~60–70 TOTAL = own body 20 + 2x `__fpclassifyd` (17 each) + 1x `__gtdf2`/`__ltdf2` (~10–12); **3 nested callx8** | NO | — | ~80–120 |
| `fmaxf`/`fminf` (newlib) | ~41 = body 17 + 2x `__fpclassifyf` (12 each); compare is inline FPU `olt.s`; **2 nested callx8** | NO | — | ~50–75 |

Key decisions from the disassembly:

1. **`__muldf3` does NOT loop.** It computes the 53x53-bit product with 8
   hardware 32x32 multiplies (`mull` x4, `muluh` x4) plus carry propagation.
   The "~60 or ~300" question resolves to **~60**. The static count of 105
   includes the `__muldf3_aux` denormal/NaN/inf arms; normal data never
   executes them.
2. **`__adddf3` static 116 is 2 functions.** The object holds `__adddf3` AND
   `__subdf3` plus shared aux arms. The executed path is 27–46.
3. **`__divsf3` is FPU-assisted and cheap-ish** but its 13 `maddn.s` chain is
   serially dependent, so it does not pipeline; ~35–55 cycles, not 30.
4. **newlib double `fmin`/`fmax` are the trap.** Each makes THREE windowed
   calls (`__fpclassifyd` twice + one soft compare). One `fmax(double)` costs
   about the same as one `__muldf3`. Window depth grows +2 under the caller,
   which raises window-overflow exception risk (each ~20–40 cycles, NOT in the
   bands above).

## Per-sample pitch penalty (8 voices)

Mix per voice per sample (MEASURED census, straight-line object):
23 muldf3 + 13 adddf3 + 2 extendsfdf2 + 2 fmax + 2 fmin (double)
+ 1 fixdfsi + 1 truncdfsf2 + 1 fmaxf + 1 fminf + 236 caller instructions.

Instructions per voice per sample (STATIC common-path bands):

| term | low | high |
|---|---|---|
| 23 x `__muldf3` (57–66) | 1311 | 1518 |
| 13 x `__adddf3` (27–46) | 351 | 598 |
| 4 x double `fmin`/`fmax` (60–70) | 240 | 280 |
| 2 x `__extendsfdf2` (14) | 28 | 28 |
| 1 x `__fixdfsi` (16) | 16 | 16 |
| 1 x `__truncdfsf2` (17–20) | 17 | 20 |
| 2 x `fminf`/`fmaxf` (39–45) | 78 | 90 |
| caller (eb_pitch itself, MEASURED) | 236 | 236 |
| **total / voice / sample** | **2277** | **2786** |

x 8 voices = **18,200–22,300 instructions/sample** (STATIC common path).
At the physically impossible best case of 1.0 cycles/instruction that is
already **3.6x–4.5x the ENTIRE 5,000-cycle hard budget**. With the stated
pipeline model (CPI 1.15–1.35 from taken branches, l32r load-use, mull
latency, call/entry/retw traffic; window overflows excluded and only push it
higher): **~21,000–30,000 cycles/sample (MODELED) for the pitch path alone**,
i.e. **4x–6x the hard budget** before one DCO, filter, envelope, or FX cycle
is spent.

## DCO divides (for completeness)

`eb_dco`: 32 executed `__divsf3`/sample (MEASURED, prior census) x 35–55
cycles = **~1,120–1,760 cycles/sample** at 8 voices — significant against
5,000 but second-order next to the pitch doubles. `eb_vcf_ladder`: 1 site,
same per-call band.

## Conclusion (the number that matters)

The soft-double helpers are all loop-free and multiplier-assisted — the CHEAP
version of soft-float — and the pitch path still costs ~2.3k–2.8k
instructions per voice per sample. **Per-sample double-precision evaluation
of eb_pitch is disqualified on the S3 by arithmetic, not by tuning.** The
levers are known and already staged in this repo
(`docs/engineb/data/pitch_var_float32.c`, `pitch_var_dekker.c`,
`pitch_precision_null.md`): a float32 or float-float (Dekker) pitch
evaluation, and/or moving the polynomial off the audio rate (pitch CV is
control-rate). Replacing the four newlib double `fmin`/`fmax` with inline
sign-tested compares and the two `fminf`/`fmaxf` with inline `olt.s` is
nearly free and removes ~400–500 instructions/voice/sample on its own, but no
combination of clamping fixes survives the 23 `__muldf3` — the double
arithmetic itself has to go.

Labels: census + caller instruction count = MEASURED (commands above);
common-path instruction counts = STATIC (hand trace of the shipped libgcc /
libm disassembly); cycle bands and per-sample totals = MODELED (pipeline
assumptions stated); "8 pitch calls/sample" = MEASURED (prior session, task
statement).

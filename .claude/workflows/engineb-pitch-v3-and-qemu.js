export const meta = {
  name: 'engineb-pitch-v3-and-qemu',
  description: 'Build the compensated-sum pitch variant and the QEMU instruction-count harness',
  phases: [
    { title: 'Build', detail: 'pitch v3 gated at -100 dB; QEMU bare-metal CCOUNT harness' },
  ],
}

const CTX = `Repo /home/user/jn60c99. ENGINE B for the JUNO-60 port, ESP32-S3 target.

STATE. Engine B: 13 modules, bit-exact vs the plugin binary (the authority,
under Unicorn) at 44.1/48 kHz. Gates: tools/engineb/null_b.py (vs the sealed
port in src/, thresholds -100 dB global / -80 dB worst-1024-block, 30 scenarios,
17 idle-prefix) and tools/engineb/plugin_check.py (vs the plugin). The S3
assessment (docs/engineb/S3_ASSESSMENT.md, 2026-08-03) found the dominant S3
cost is engine_b/eb_pitch.c: a 13-term polynomial in DOUBLE, 8 calls/sample,
18,200-22,300 Xtensa instructions/sample via soft-double libgcc calls.

MEASURED ALREADY (docs/engineb/data/pitch_precision_null.md):
- float32 variant: FAIL 30/30, catastrophic (pitch error integrates in phase).
- Dekker double-float (~49 bits, FMA-free TwoProd/TwoSum): FAIL only 2/30 on
  the GLOBAL gate: 'DCO neg pitch sweep' -95.8 dB (needs -100) and
  'idle chorus 44100' -98.1 dB. Block gate PASSES 30/30. 22/30 BIT-EXACT.
  A control variant proved the gap is SUMMATION PRECISION in the 13-term sum
  only (large-negative-CV term cancellation), not the clamp/row selection.
- Staged files: docs/engineb/data/pitch_var_float32.c, pitch_var_dekker.c,
  pitch_var_dekker_drow.c, and the probe docs/engineb/data/
  pitch_precision_probe.py (it overrides null_b._plant to copy a variant over
  engine_b/eb_pitch.c in the CANDIDATE tree only, then runs
  null_b.run(["pitch"], False, mutate=..., ref=oracle_render(False))).

RULES (binding, from CLAUDE.md):
- NEVER edit src/. The plugin under Unicorn is the only ground truth.
- Two-process rule: null_b.py already obeys it; drive the existing harness.
- Never validate by ear. Label numbers PROVEN/MEASURED/STATIC/MODELED/INFERRED.
- Do NOT git commit or push. Write files and report; the main session commits.
- Toolchain: export PATH=/root/.espressif/tools/xtensa-esp-elf/esp-16.1.0_20260609/xtensa-esp-elf/bin:$PATH
- Scratchpad: /tmp/claude-0/-home-user-jn60c99/851980e2-931d-52da-bb74-16fb8562b242/scratchpad
- Report only numbers you measured, with the command that produced them.`

phase('Build')

const built = await parallel([
  () => agent(`${CTX}

TASK: build PITCH V3 -- a compensated-sum double-float evaluation that PASSES
the -100 dB global gate on all 30 scenarios -- and integrate it behind a
compile-time switch modeled on EB_DCO_RECIP.

NUMERICS DIRECTION (iterate until the gate passes; the gate decides, not
theory):
 v3a: keep the Dekker double-float products (Veltkamp split, FMA-free), but
      accumulate the 13 terms with a Neumaier/Kahan-Babuska compensated sum of
      the product HI parts, adding every product LO part and every TwoSum error
      into the compensation term. The two failing scenarios are cancellation
      cases; compensation targets exactly that.
 v3b (if v3a fails): full double-float (hi,lo) arithmetic through the powers
      and the sum with renormalization after every operation (Briggs/Bailey
      df_add/df_mul), which approaches 2^-48..-49 relative per op.
 v3c (if v3b fails): extend the accumulator only to triple-float.
 The input clamp and the row selection may stay in double (the control variant
 proved they are not the gap; they are 4 double fmin/fmax + 1 __fixdfsi per
 call -- cheap next to 36 mul/adds).

STEPS:
 1. Write the variant as docs/engineb/data/pitch_var_v3.c following the staged
    variants' interface (same functions as engine_b/eb_pitch.c: eb_pitch_row,
    eb_pitch_eval). It must compile with
    cc -std=c99 -O2 -ffp-contract=off -fno-strict-aliasing -c  AND with
    xtensa-esp32s3-elf-gcc (same flags). -ffp-contract=off matters: your
    TwoProd/TwoSum algebra DEPENDS on no FMA contraction.
 2. Measure with the existing probe (extend docs/engineb/data/
    pitch_precision_probe.py to accept the new variant), full 30 scenarios.
    Report per-scenario residual dB, worst global, worst block. The two
    previously-failing scenarios MUST flip to passing.
 3. When a variant passes: integrate into engine_b/eb_pitch.c behind
    '#if EB_PITCH_FAST' (default 0 = the current double path, bit-exact),
    with a header comment in the style of EB_DCO_RECIP in engine_b/eb_dco.h:
    what it changes, the MEASURED accuracy numbers, what it buys on the S3
    (cite docs/engineb/data/softfloat_cost.md). Verify default build stays
    bit-exact: python3 tools/engineb/null_b.py --module pitch --quick must
    print EXACTLY 0.
 4. Verify the fast build passes the gate through the REAL harness, not only
    the probe: set CFLAGS to add -DEB_PITCH_FAST=1 via the environment hook if
    null_b has one, else run the probe path with the integrated file. State
    exactly what you ran.
 5. STATIC census of the v3 object for the S3 (objdump -r): remaining soft-
    double relocs must be ~zero on the per-sample path (table splitting may be
    hoisted to a precomputed static table -- do that: precompute the split
    table at first use or as a build-time constant array).
 6. Write results into docs/engineb/data/pitch_precision_null.md (append a v3
    section) and report the numbers.
If NO variant passes after v3c, report the best result per scenario and stop --
that is a finding, not a failure to be papered over.`,
    { label: 'build:pitch-v3', phase: 'Build' }),

  () => agent(`${CTX}

TASK: build the QEMU ESP32-S3 instruction-count harness and produce the first
EXECUTED-XTENSA numbers for engine B's hot functions.

WHAT EXISTS (verified by a prior agent, PROVEN):
- Working QEMU: <scratchpad>/qemu/bin/qemu-system-xtensa
  (Espressif esp_develop_9.2.2_20260417; -M esp32s3 boots the real mask ROM;
  -icount shift=0,align=off,sleep=off accepted; NO TCG plugin interface, so
  count via the CCOUNT special register; under icount CCOUNT advances per
  executed INSTRUCTION -- label all results 'QEMU-executed instructions', not
  cycles).
- Design notes from the scout: link code+data entirely into internal SRAM
  (IRAM ~0x40370000 for code, DRAM ~0x3FC88000 for data), tiny crt0 (set PS,
  zero .bss, call main), load with -kernel harness.elf (Espressif QEMU loads
  ELF segments directly, bypassing flash boot). UART0 for output: on ESP32-S3
  the UART0 FIFO is memory-mapped (TX fifo at 0x60000000); a putc that writes
  the FIFO and a busy-wait on the status register is enough under QEMU. If
  UART proves fiddly, an alternative exit channel: write results to a known
  DRAM address and use QEMU's -d exec or a memory dump -- but try UART first,
  it is the simple path.

STEPS:
 1. Create tools/engineb/qemu/ with: crt0.S, link.ld, uart.c (putc/puts/
    print_u32 hex), harness.c, build.sh, run.sh. Keep it minimal C99/asm.
 2. harness.c: for each function under test, run a warmup, then read CCOUNT
    (rsr.ccount), run N iterations (N >= 100,000 for the small ticks), read
    CCOUNT again, print (end-start)/N. State N per function.
    FUNCTIONS, with per-sample call rates for the roll-up:
      eb_dco_step4 (8/sample), eb_vcf_tick (8), eb_env_tick (16),
      eb_vca_tick (8), eb_decim_tick (8), eb_vcf_cv_tick (8),
      eb_modcv_tick (8), eb_cvgate (8), eb_nsvf_tick (8),
      eb_pitch_eval CURRENT DOUBLE version (8),
      eb_chorus_tick_x (1), eb_delay_process (1), eb_reverb_process (1).
    DRIVE THEM WITH NON-ZERO, EVOLVING STATE: several modules skip work on
    silence (the DCO's level gates, the saturator shortcut), and a silent
    benchmark reports a cheaper engine than the real one -- this project was
    caught by exactly that once. Reuse the coefficient setup pattern from
    tools/engineb/standalone_cost.c (it documents the non-degenerate values),
    and feed inputs from a cheap integer LCG so branches see real variation.
    Feed the DCO real increments (audible pitch range) so its wrap branches
    exercise. Sum outputs into a volatile to defeat dead-code elimination.
 3. Memory: EB_DELAY_LEN=65536 floats will NOT fit internal SRAM. For the
    delay use -DEB_DELAY_LEN=16384 in the harness build ONLY, and SAY SO in
    the report (the count scales; what matters here is instructions, and note
    the ring size does not change the per-sample instruction count -- masking
    is the same). The reverb state ~200 KB: check sizeof; if it does not fit
    beside the rest, run the reverb in a SECOND harness build/run with other
    modules compiled out. Two runs are fine.
 4. build.sh: xtensa-esp32s3-elf-gcc -std=c99 -O2 -ffp-contract=off
    -fno-strict-aliasing -Iengine_b -Isrc, -nostartfiles -Wl,-T,link.ld;
    verify the ELF's segments land in the SRAM ranges (readelf -l).
 5. run.sh: <scratchpad>/qemu/bin/qemu-system-xtensa -M esp32s3 -nographic
    -icount shift=0,align=off,sleep=off -kernel harness.elf, with a timeout
    and output captured. Parse the printed table.
 6. Report the table: function | QEMU-executed instr/call | calls/sample |
    instr/sample, plus the roll-up sum, and set it beside the MODELED table in
    docs/engineb/data/s3_cost_table.md -- state where the model was wrong and
    by how much, per function. Write the whole result to
    docs/engineb/data/qemu_instr_counts.md.
 7. Also measure eb_pitch_eval's DOUBLE version per-call count -- this is the
    number that validates or refutes the 2,277-2,786/call common-path model.
Debugging tips: if the ELF does not run, first try -d guest_errors; confirm
entry point matches the ResetVector expectation when using -kernel (Espressif
QEMU jumps to the ELF entry); keep the vector table trivial (no interrupts;
poll everything). If CCOUNT reads zero, set CCOMPARE never to fire and ensure
PS.INTLEVEL masks all. Timebox bring-up struggles to ~45 minutes; if truly
stuck, deliver the harness + the exact failing command + observed output.`,
    { label: 'build:qemu-harness', phase: 'Build' }),
])

return { built: built.filter(Boolean) }
# WORK ORDER — the hand-written ladder kernel (EB_VCF_ASM), for Opus 5
2026-08-10, Fable 5. THE LAST PIECE. Everything else in HOME_STRETCH.md is
done, measured, and banked. This is the single remaining lever for real time
on two chips at 44.1 kHz. Execute exactly; do not substitute a compiler-level
shortcut -- that was tried (EB_FUSE_VCA) and silicon priced it at +130
cycles/voice. This order exists BECAUSE the shortcut failed.

## 0. The target, in numbers (all MEASURED on the user's S3)
  voice today (STEP13 config)        ~3,380 cycles
  needed for the two-chip fit        <= 2,721   (2 voices <= 5,442)
  ladder: 516 insns in 1,083 cyc     c/i 2.1 -> ~567 stall cycles
  VCA:    211 insns in   379 cyc     c/i 1.8 -> ~168 stall cycles
  REQUIRED YIELD: ~650/voice out of ~735 measured stalls.
  ABORT-TO-DECISION: if the kernel lands under 300, STOP and report; the
  user decides. Do not grind past a measured shortfall.

## 1. Why hand assembly can do what the compiler cannot (measured, not hoped)
- The ladder's four sub-steps are ONE serial FP dependency chain; every
  dependent add.s/mul.s stalls ~4 cycles on the LX7's in-order pipe.
- The compiler cannot fill the bubbles: within the C call graph every
  neighbouring computation either feeds the ladder or reads it, and moving
  the VCA's independent strands next to it REQUIRES values to live across a
  call boundary -- which spills. EB_FUSE_VCA measured that spill at +130.
- A single .S routine has no call boundary. Hand allocation keeps the
  ladder's live set (~12-13 regs: G, A, Rk, y1..y4, nl, s1, ins, 2-3 temps)
  and the VCA control values in the remaining 3 of the 16 FP registers.
  The filler instructions are FREE work already being done elsewhere:
    a) the VCA control strands (~40 insns, proven independent of vcf)
    b) wrap24 + the dither/drive input node (INTEGER ops -- they fill FP
       stall slots at zero FP-register cost)
    c) the next sub-step's input weight (prev/drive lerp)
    d) the VCA audio half's lp/boost setup once y4 exists

## 2. The iron rules
1. **BIT-EXACT.** Same operations, same operands, same order WITHIN every
   dependency chain. Only the interleaving of independent chains may differ.
   NO madd.s ANYWHERE -- fused multiply-add has one rounding, the reference
   has two. grep the final .S for madd; its presence is an automatic FAIL.
2. **Start from the compiler's own output.** xtensa-esp32s3-elf-gcc -S -O2
   -ffp-contract=off of the CURRENT eb_vcf_ladder.c + eb_vca_hpf.c. Reorder
   those instructions; never retype an expression by hand.
3. **Windowed ABI.** entry/retw.n, args in a2.., call8 from C. Do not touch
   a15. lsi/ssi offsets are 0..1020, multiples of 4 -- keep the coef struct
   pointer in one address register and index off it.
4. **Flag: EB_VCF_ASM, default 0.** The C path stays; the S3 CMake adds the
   .S only when the flag is set. Host/gate builds never see it.

## 3. The gate -- on the BOARD, because the host cannot run Xtensa
The null harness runs on x86 and cannot execute this kernel. The project
already solved this once: the listen firmware's "FORK EVALUATOR VECTORS:
BIT-EXACT" self-test. Extend that pattern:
  S2a  VECTOR TEST at boot: run the C tick and the asm kernel side by side
       over >= 100,000 vectors -- random (in, G, k) over the MEASURED domain
       (G in [0.000119, 0.20977], k in [0, 3.981]) AND evolving state (the
       same streams through both, comparing FULL STATE STRUCTS bytewise every
       sample, not just outputs). HALT on first mismatch, print both words.
  S2b  A PLANTED NEGATIVE: one build with a deliberately transposed
       instruction pair inside a dependency chain must be CAUGHT by S2a.
       A self-test never seen to fail is not a self-test.
  S2c  Only after S2a passes on silicon: the wake sweep. Baseline = the
       STEP13 numbers the user measures next.
Host-side, additionally: the .S is mechanically diffed against the -S
reference for OPERATION MULTISET equality (same opcodes, same immediates,
same symbolic operands, order aside) -- a script, tools/engineb/asm_diff.py,
written first. It cannot prove order-correctness (S2a does) but it refuses
retyped constants and dropped operations before a single flash is spent.

## 4. Execution order, one commit each
  A1  asm_diff.py + extract the -S reference for tick+substeps+vca.
  A2  the .S skeleton: verbatim compiler order, no rescheduling, behind
      EB_VCF_ASM. It must pass S2a AS-IS (this proves plumbing, ABI, CMake).
      Measure it: expect ~= C cost. Any surprise here is a plumbing bug.
  A3  reschedule PASS 1: interleave wrap24+input node (integer) into
      sub-step 1's stalls; VCA control into sub-steps 2-3; weight prep into
      4. Re-run S2a + sweep. RECORD the per-pass yield.
  A4  reschedule PASS 2: software-pipeline across the four sub-steps (the
      port's own S-predictor makes each sub-step's head independent of the
      previous tail for ~6 insns -- use it).
  A5  fold in the VCA audio half after y4.
  A6  verdict either way in docs/engineb/data/asm_kernel_result.md, with
      per-pass cycle numbers. Then the user decides adoption.

## 5. Known traps, each already paid for once in this repo
- FPU coprocessor context: FP in a task is fine (the C code already uses
  it); do NOT move the kernel into an ISR.
- The dither is per-sample state -- it is filler work, never elided.
- EB_VCF_DEADCOEF=1 and EB_VCF_RES_LUT=256 are the shipping config; the
  reference -S must be generated WITH them or the multiset diff lies.
- Sub-300-cycle sweep deltas are the board's noise floor.
- Cache/layout moves numbers +/-100: judge passes by the SWEEP, same wake
  masks, same 41 s procedure, never by a single line.

## 6. What success is
STEP13 voice ~3,380 -> ~2,720 or less. Two-voice core <= 5,442.
SIX VOICES, FULL FX (on the 1-voice core), 44.1 kHz, TWO CHIPS, 1.0 dB gate
untouched (the kernel is bit-exact; it spends NOTHING sonically).
That is real time. That is the finish line, and this is the whole distance.

## ADDENDUM (2026-08-10, silicon night) — READ THIS FIRST, IT RESIZES THE JOB
**The gap is 0xd0 = 6,681 vs 5,442 = ~620 cycles on the 2-voice core, and
Phase A just PROVED it is made of stalls.** The control-rate holds removed
hundreds of instructions of module arithmetic and the board moved ~60
cycles/voice (LASTMILE2 sweep, STEP1_ATTRIBUTION.md). Arithmetic removal is
exhausted as a category: the pipeline was waiting, not working. The measured
ladder+VCA stall pool is ~735/voice > the 620 gap. This kernel is now the
ONLY lever matched to the measured cause, and the FIRST one sized to cover
the remaining span.

EXECUTION NOTES THE BOARD ADDED TONIGHT:
- The SHIPPING flag set is the AUDIBLE build's (CMakeCache S3_EXTRA_DEFS of
  LASTMILE2 MINUS every EB_CR_* and EB_ENV_CR flag). Do not carry the CR
  levers into the kernel build: ~60 cycles for 2.6 dB is a closed trade.
- Verify bit-exactness under QEMU (tools/engineb/qemu/) against the C
  ladder BEFORE any firmware goes to the user. The user flashes VERDICTS,
  not experiments.
- The 16-register wall killed every COMPILER-side scheduling attempt
  (interleave, fusion, always_inline). The kernel exists precisely because
  hand allocation can hold two voices' four live values each where the
  compiler spills; if a draft spills to the stack inside the sub-step loop,
  it has already lost -- count stores before counting cycles.
- Iron rule unchanged: no landing number to the user before 0xd0 prints.

## RECON RESULT (2026-08-10, Opus 5) — READ docs/engineb/data/asm_kernel_recon.md
- **c/i is 1.35, not 1.9.** Pool ~790 cycles/voice against a ~620 gap: the
  kernel is still correctly sized, required capture ~78 %.
- **c/i = 0.95 was a DIFFERENT PROGRAM** (F4 harness: 4x ladder, no
  wavetable DCO, never calls eb_render.c's voice loop). Do not quote it here.
- **DO THE FREE MEASUREMENT FIRST:** esp32s3/flash/juno_s3_ILV.bin and
  juno_s3_BEST_noILV.bin already exist, gated EXACTLY 0, and were NEVER
  MEASURED. They decide the interleave hypothesis -- the kernel's own
  premise -- for the cost of two flashes.
- **QEMU TRAP:** tools/engineb/qemu/build.sh has none of the shipping fork
  flags. Without -DEB_HALF_OS_VCF the reference is a DIFFERENT ladder body.
- asm_diff.py exists and its teeth are proven (control passes; four
  mutations caught; the fused-multiply-add rule is absolute).

## ★ STOP — THE RECON SAYS THIS IS THE WRONG FIRST LEVER (2026-08-10)
- **Ladder+VCA stall pool is ~466 cycles/voice, and this order requires
  ~650** (abort line 300). A PERFECT kernel cannot close the gap alone.
- The 516-instruction ladder figure this order is sized on **charges the
  decimator's hardware `loop` body ONCE against a trip count of 15**;
  executed is ~682, so the 4x ladder's c/i was 1.59, not 2.1.
- **27 % of a voice is LIBRARY CALLS**: 7 fminf/fmaxf at 62 instructions
  each (30-instruction body + 2 __issignalingf + 2 __isnanf) plus 6
  __divsf3 = 620 of 2,275 instructions. eb_envgen.c:37 already defines a
  static eb_fminf for this exact reason; seven per-voice call sites never
  took it. A library call OCCUPIES issue slots rather than waiting in them,
  so Phase A's null result does not predict this one.
DO THAT FIRST. Then re-measure, then decide about this order.

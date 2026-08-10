/* eb_fpdiv.h — the ESP32-S3's hardware float divide, inline, BIT-EXACT.
 *
 * WHAT THIS CORRECTS. eb_vcf_ladder.c's header says "the ESP32-S3 has no FP
 * divide, so this division is a soft-float call". MEASURED, that is wrong on
 * both halves. `__XCHAL_HAVE_FP_DIV` is 1 for this target, every instruction
 * of the divide sequence assembles, and libgcc's own `__divsf3` for esp32s3
 * IS that sequence -- 30 instructions of which 14 are div0.s / nexp01.s /
 * maddn.s / divn.s. The FPU was doing the work all along.
 *
 * SO WHAT IS ACTUALLY BEING PAID IS THE CALL, and it is paid in the worst
 * possible currency. The caller holds its operands in FLOAT registers; the
 * windowed ABI passes them in INTEGER registers, so every division costs a
 * `wfr` pair on the way in and an `rfr` on the way out purely to satisfy the
 * calling convention, plus `entry`/`retw.n`, the literal load, the argument
 * moves and the `callx8` itself. None of that arithmetic exists; it is
 * transport.
 *
 * BIT-EXACT BY CONSTRUCTION, NOT BY ARGUMENT. The body below is libgcc's
 * `_divsf3.o` transcribed instruction for instruction, in the same order,
 * with only the register NAMES replaced by compiler-assigned operands. It is
 * therefore the same computation with the same roundings, and the check that
 * this is true is mechanical rather than rhetorical: disassemble a build with
 * EB_FPDIV=1 and diff the opcode sequence against libgcc's. A transcription
 * error shows up there, not in an ear.
 *
 * THE RISK, STATED BEFORE THE MEASUREMENT. The sequence needs NINE float
 * registers live at once and the LX7 has sixteen. A CALL confines that
 * pressure to the callee, because the register window rotates; INLINING
 * exposes it to the caller, which in the ladder already holds about a dozen
 * live values. This project has hit the 16-register wall three times --
 * voice interleave, the pitch hoist's inlining, and EB_FUSE_VCA, which
 * measured +168 cycles for exactly this reason. So the rule from
 * ASM_KERNEL_WORKORDER.md applies here too and is not negotiable: COUNT THE
 * STACK STORES BEFORE COUNTING THE CYCLES. If spills rise inside the ladder,
 * this has already lost and does not ship, however good the instruction
 * count looks.
 *
 * DEFAULT OFF. Nothing changes by omission.
 */
#ifndef ENGINEB_EB_FPDIV_H
#define ENGINEB_EB_FPDIV_H

#ifndef EB_FPDIV
#define EB_FPDIV 0
#endif

#if EB_FPDIV && defined(__XTENSA__)

static float eb_fpdiv(float a, float b)
{
    float f0, f2 = b, f3, f4, f5, f6, f7, f8;
    __asm__ (
        "div0.s    %[f3], %[f2]        \n\t"
        "nexp01.s  %[f4], %[f2]        \n\t"
        "const.s   %[f5], 1            \n\t"
        "maddn.s   %[f5], %[f4], %[f3] \n\t"
        "mov.s     %[f6], %[f3]        \n\t"
        "mov.s     %[f7], %[f2]        \n\t"
        "nexp01.s  %[f2], %[f1]        \n\t"
        "maddn.s   %[f6], %[f5], %[f6] \n\t"
        "const.s   %[f5], 1            \n\t"
        "const.s   %[f0], 0            \n\t"
        "neg.s     %[f8], %[f2]        \n\t"
        "maddn.s   %[f5], %[f4], %[f6] \n\t"
        "maddn.s   %[f0], %[f8], %[f3] \n\t"
        "mkdadj.s  %[f7], %[f1]        \n\t"
        "maddn.s   %[f6], %[f5], %[f6] \n\t"
        "maddn.s   %[f8], %[f4], %[f0] \n\t"
        "const.s   %[f3], 1            \n\t"
        "maddn.s   %[f3], %[f4], %[f6] \n\t"
        "maddn.s   %[f0], %[f8], %[f6] \n\t"
        "neg.s     %[f2], %[f2]        \n\t"
        "maddn.s   %[f6], %[f3], %[f6] \n\t"
        "maddn.s   %[f2], %[f4], %[f0] \n\t"
        "addexpm.s %[f0], %[f7]        \n\t"
        "addexp.s  %[f6], %[f7]        \n\t"
        "divn.s    %[f0], %[f2], %[f6] \n\t"
        : [f0] "=&f" (f0), [f2] "+&f" (f2), [f3] "=&f" (f3), [f4] "=&f" (f4),
          [f5] "=&f" (f5), [f6] "=&f" (f6), [f7] "=&f" (f7), [f8] "=&f" (f8)
        : [f1] "f" (a));
    return f0;
}

#define EB_DIV(a, b) eb_fpdiv((a), (b))

#else

/* The tree as it was: the compiler's own `/`, which becomes a call to
 * __divsf3. Kept as the default so a build that does not ask for the inline
 * form is byte-for-byte what it was. */
#define EB_DIV(a, b) ((a) / (b))

#endif

#endif /* ENGINEB_EB_FPDIV_H */

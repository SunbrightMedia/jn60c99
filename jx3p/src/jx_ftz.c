/* jx_ftz.c -- put the CPU into the plugin's floating-point MODE.
 *
 * WHY THIS EXISTS, and why a green gate did not ask for it:
 * the JX-3P plugin runs on x86 with the SSE FTZ (flush-to-zero) and DAZ
 * (denormals-are-zero) MXCSR bits set -- the mode every audio host runs in.
 * A denormal result is written as 0; a denormal operand is read as 0. The
 * oracle reproduces that (`jx_emu.set_ftz`). The C port did NOT, so the port
 * and the plugin computed in DIFFERENT floating-point modes.
 *
 * Nothing caught it, because the 64 factory patches do not drive a denormal
 * into any compared cell within the gate's 64-sample window. It was found on
 * 2026-08-26 by the RANDOM-SEEDED ramp-walker A/B, whose value spread includes
 * denormals on purpose: 90 of 200 cases diverged, every one of them on a
 * denormal `step` or `acc`. This is charter rule 1 paying out -- "the value
 * spread must NOT come from a preset bank".
 *
 * The JUNO-60 port has had this since src/juno_ftz.c; the JX never did. Call
 * jx_enable_hw_ftz() ONCE before any render, in every harness and every host.
 */

#if defined(__SSE__) && !defined(__EMSCRIPTEN__)
#include <xmmintrin.h>
#include <pmmintrin.h>                          /* DAZ */
void jx_enable_hw_ftz(void)
{
    _MM_SET_FLUSH_ZERO_MODE(_MM_FLUSH_ZERO_ON);
    _MM_SET_DENORMALS_ZERO_MODE(_MM_DENORMALS_ZERO_ON);
}
int jx_hw_ftz_available(void) { return 1; }

#elif defined(__ARM_FP) && !defined(__EMSCRIPTEN__)
/* ARM FZ (FPSCR bit 24) covers denormal inputs and outputs together. */
void jx_enable_hw_ftz(void)
{
    unsigned int fpscr;
    __asm__ __volatile__("vmrs %0, fpscr" : "=r"(fpscr));
    fpscr |= (1u << 24);
    __asm__ __volatile__("vmsr fpscr, %0" : : "r"(fpscr));
}
int jx_hw_ftz_available(void) { return 1; }

#else
/* WebAssembly and other targets with no hardware mode. Returning 0 is a
 * REFUSAL to claim bit-exactness, not a silent fallback: the caller must
 * flush explicitly, exactly as the JUNO's WASM build does. */
void jx_enable_hw_ftz(void) { }
int jx_hw_ftz_available(void) { return 0; }
#endif

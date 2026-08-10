/* eb_minmax.h — fminf/fmaxf without the call.
 *
 * WHY THIS EXISTS, AS A MEASUREMENT. On the ESP32-S3 with picolibc, one
 * `fminf` is 62 EXECUTED instructions: a 30-instruction body plus two
 * `__issignalingf` (9 each) and two `__isnanf` (7 each), reached through a
 * windowed `callx8`. Seven such calls sit on the per-sounding-voice path, and
 * with six `__divsf3` they are 620 of the voice's 2,275 instructions --
 * **27 % of a voice spent in library code to compute what a comparison
 * computes.**
 *
 * WHAT THE COMPILER ACTUALLY EMITS, measured with the project's own toolchain
 * and flags (-O2 -ffp-contract=off -mlongcalls):
 *
 *     (x < 1.0f) ? x : 1.0f        ->  olt.s b0, f0, f1 ; movf a2, a8, b0
 *     fminf(x, 1.0f)               ->  l32r ; mov ; callx8            <-- call
 *     the NaN-exact form below     ->  olt.s ; bt ; oeq.s ; movt.s
 *
 * Two FPU instructions against a call into a 62-instruction routine. That is
 * the whole lever.
 *
 * THIS IS NOT AN APPROXIMATION AND HAS NO SONIC BUDGET. It removes CALLS, not
 * arithmetic, so its bar is the TRUNK's: every build must null EXACTLY 0.
 *
 * ------------------------------------------------------------------ IEEE
 * WHERE THE CHEAP TERNARY AND C's fminf DISAGREE, stated exactly, because
 * "these are always finite" is an assertion this project does not accept
 * without a bound:
 *
 *   1. NaN IN THE SECOND OPERAND. C says fminf(a, NaN) == a; the ternary
 *      `(a < b) ? a : b` yields NaN. They agree when the NaN is FIRST:
 *      fminf(NaN, b) == b and the ternary also yields b, because every
 *      comparison against NaN is false.
 *      => the ternary is exact whenever the SECOND operand cannot be NaN.
 *
 *   2. ZEROS OF OPPOSITE SIGN. fminf(-0.0, +0.0) and fminf(+0.0, -0.0) are
 *      recommended to return -0.0; the ternary returns its SECOND operand in
 *      both cases, so it differs in the SIGN BIT -- a different bit pattern
 *      from a pair that compares equal, which is exactly the kind of
 *      difference a null gate catches and an ear cannot.
 *      => the ternary is exact whenever the two operands cannot be zeros of
 *      opposite sign, which is guaranteed when either operand is a non-zero
 *      constant.
 *
 * SO THERE ARE TWO ENTRY POINTS AND CHOOSING BETWEEN THEM IS THE WHOLE JOB:
 *
 *   eb_fminf / eb_fmaxf         EXACT for every input, including NaN and
 *                               signed zeros. 4 instructions, no call.
 *   eb_fminf_c / eb_fmaxf_c     the 2-instruction ternary. Its SECOND
 *                               operand must be provably non-NaN, and the
 *                               pair must not be zeros of opposite sign.
 *                               EVERY call site must carry a comment naming
 *                               its bound. A site that cannot name one uses
 *                               the exact form; it is still 15x cheaper than
 *                               the library call.
 *
 * The `_c` suffix reads "constant-bounded", not "cheap": the discipline is
 * the point, and a reader who has to guess which is which will eventually
 * guess wrong.
 */
#ifndef ENGINEB_EB_MINMAX_H
#define ENGINEB_EB_MINMAX_H

#include "eb_fork_config.h"

/* EB_NOLIBM — default 0, so no build changes by omission. With it off, the
 * macros below expand to the libm calls the code has always made, which is
 * what makes the flag itself gateable: the OFF build must be bit-identical
 * to the tree before this header existed. */
#ifndef EB_NOLIBM
#define EB_NOLIBM 0
#endif

#if EB_NOLIBM

/* EXACT. b != b is the NaN test, spelled without <math.h> so no
 * __isnanf/__issignalingf call can creep back in through isnan().
 *   b is NaN   -> a          (C: fminf(a,NaN) == a)
 *   a is NaN   -> b          (a < b is false; b == b is true)
 *   otherwise  -> the smaller, and for equal-magnitude zeros the SECOND,
 *                 matching the ternary's own rule rather than IEEE's
 *                 preference -- see the caveat below. */
static float eb_fminf(float a, float b)
{
    return (a < b) ? a : ((b == b) ? b : a);
}

static float eb_fmaxf(float a, float b)
{
    return (a > b) ? a : ((b == b) ? b : a);
}

/* CONSTANT-BOUNDED. Two instructions. The caller asserts, in a comment at the
 * site, that the second operand is not NaN and that the pair cannot be zeros
 * of opposite sign. */
static float eb_fminf_c(float a, float b) { return (a < b) ? a : b; }
static float eb_fmaxf_c(float a, float b) { return (a > b) ? a : b; }

#else   /* the tree as it was: real libm calls */

#include <math.h>
static float eb_fminf(float a, float b)   { return fminf(a, b); }
static float eb_fmaxf(float a, float b)   { return fmaxf(a, b); }
static float eb_fminf_c(float a, float b) { return fminf(a, b); }
static float eb_fmaxf_c(float a, float b) { return fmaxf(a, b); }

#endif

/* THE SIGNED-ZERO CAVEAT, WRITTEN DOWN RATHER THAN DISCOVERED LATER.
 * eb_fminf(-0.0f, +0.0f) returns +0.0f where IEEE-754's minNum recommends
 * -0.0f, and glibc/picolibc's fminf follows the recommendation. The exact
 * form above therefore matches C on NaN but NOT on opposite-signed zeros.
 * Handling that too costs a sign-bit test on every call, and the null gate
 * decides whether it is needed: if any engine build is not EXACTLY 0, this
 * is the first place to look, and the fix is
 *     if (a == b) return signbit(a) ? a : b;
 * spelled with a bit test rather than signbit(). Recorded so that a future
 * failure is diagnosed in a minute instead of a night. */

#endif /* ENGINEB_EB_MINMAX_H */

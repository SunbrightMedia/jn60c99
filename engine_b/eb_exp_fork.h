/* eb_exp_fork.h — the S3 FORK exponential (F3). FORK code; the trunk keeps
 * libm expf and is EXACTLY 0.
 *
 * WHY: expf is 184 instructions on the S3 toolchain (wrapper plus the
 * __ieee754_expf body) and the LFO calls it per voice per sample — 6,305
 * instr/sample of the engine's 71,535 hangs off this one function. The fork
 * body below is ~30.
 *
 * THE STANDARD, per the user's Phase-2 charter: a PPM gate, not the null.
 * tools/engineb/exp_ppm_gate.py drives EVERY float32 bit pattern through
 * this function and through the port's expf and bounds the relative error
 * at 2 ppm. For comparison, the fork pitch bound of 0.05 cents is 29 ppm.
 *
 * THE TAILS ARE DELEGATED, NOT APPROXIMATED. For x outside [-87, 88] this
 * function CALLS expf, so overflow, underflow-to-zero, denormal results and
 * NaN behave identically to the port by construction — the gate then proves
 * bit-equality there rather than trusting this comment. No real LFO
 * coefficient reaches the tails; the branch costs one compare.
 */
#ifndef ENGINEB_EB_EXP_FORK_H
#define ENGINEB_EB_EXP_FORK_H

float eb_exp_fork(float x);

#endif

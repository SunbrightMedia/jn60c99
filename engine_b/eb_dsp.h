/* eb_dsp.h — the four shared DSP primitives, engine B's OWN copies.
 *
 * WHY THIS FILE EXISTS. Engine B is meant to be a STANDALONE engine: the
 * splitting point for every microcontroller target. Until now four of its
 * modules called `juno_pitch_poly`, `juno_triangle`, `juno_wrap_unit` and
 * `juno_wrap_hi` out of `src/juno_dsp.c` — the PORT. Every null gate links the
 * whole port, so the dependency was invisible to all of them; it was found by
 * LINKING engine B outside the harness, and recorded as PORTABILITY DEBT in
 * eb_master.h and in the project memory.
 *
 * A gate that cannot see a dependency is not evidence the dependency is
 * absent. That is the general form, and it is why this file is not merely
 * tidiness: a target that tried to build the trunk alone would have failed at
 * the linker with four undefined symbols and no explanation.
 *
 * WHAT IS AND IS NOT COPIED. These are VERBATIM transcriptions of the port's
 * own functions, character for character in their arithmetic, `fmodf` and all.
 * Nothing is "improved" — an improved wrap is a different function and the
 * nulls would say so. The pitch TABLE is not copied: `juno_tables.h` is
 * constant DATA proven from the plugin, engine B already depends on it in nine
 * modules, and data is portable in a way that code linkage is not.
 *
 * eb_dco.c's `eb_triangle` (engine_b/triangle.h) is a DIFFERENT function — it
 * is the port's triangle with the wrap removed, valid only where the caller
 * has already bounded the phase, and proven over all 2^32 inputs on that
 * domain. The delay and effect arms need the WRAPPING form, which is
 * `eb_triangle_wrap` below. Do not substitute one for the other.
 */
#ifndef ENGINEB_EB_DSP_H
#define ENGINEB_EB_DSP_H

/* juno_pitch_poly — pitch -> ratio, the 13-term spline in juno_pitch_table. */
double eb_pitch_poly(double x);

/* juno_triangle — wrapping triangle over the whole real line. */
float eb_triangle_wrap(float phase);

/* juno_wrap_unit — wrap to [-1,1) in both directions. */
float eb_wrap_unit(float x);

/* juno_wrap_hi — wrap only when above 1. */
float eb_wrap_hi(float x);

#endif

/* eb_delay_pitchmod.h -- THE ONE definition of the hoisted delay pitch-mod
 * pre-value, so that every builder of an eb_dly23_coef or eb_dly5_coef fills
 * it, and fills it the same way.
 *
 * WHY THIS FILE EXISTS (measured 2026-08-17)
 *     7936d3b hoisted a per-sample 13-term DOUBLE-precision pitch call out of
 *     the TYPE 2/3 and TYPE 5 delay ticks into a coef field, `pitchmod_pre`.
 *     It filled that field in eb_master_coefs_build() -- the ONLY builder that
 *     fills it. The module shims and the GENERATED composite build their coef
 *     structs field by field from the port's cells, never assigned it, and the
 *     structs are function-level `static`, so the field stayed 0.0f for the
 *     life of the process. In every shim build the delay's pitch modulation
 *     was frozen at zero instead of the clamped polynomial.
 *
 *     Two things hid it. The hoist was proven on `null_b --module standalone`,
 *     which is the one path that DOES call eb_master_coefs_build -- proven on
 *     the only build that could not see the defect. And the null gate's teeth
 *     had asserted ("voiceidleskip anchor moved") since 73a7657, so
 *     `make engineb` died at step 4 and NO per-module null ran for eight days.
 *
 *     Cost when the teeth were repaired and the gate finally ran: DELAY type 2
 *     at -4.6 dB rel, type 3 at -0.9, and the TYPE 5 patches at about 0 dB rel
 *     -- a difference as loud as the signal -- against a -100 dB rel gate.
 *
 * WHY A SHARED FUNCTION AND NOT A LINE IN EACH BUILDER
 *     Both arms used the IDENTICAL expression on different operands. Copying
 *     it into each builder is what let one builder be forgotten; a third
 *     builder would be free to invent a fourth spelling. One function cannot
 *     drift, and a new coef builder that forgets to call it is a compile-time
 *     absence rather than a silent zero.
 *
 *     The expression is written here CHARACTER FOR CHARACTER as the render
 *     loop and eb_master_coefs.c had it. That is what keeps the null EXACTLY
 *     0; -ffp-contract=off is load-bearing here as everywhere.
 */
#ifndef ENGINEB_EB_DELAY_PITCHMOD_H
#define ENGINEB_EB_DELAY_PITCHMOD_H

#include "eb_dsp.h"
#include "eb_minmax.h"

/* ka, kb are the two cells the arm already holds: TYPE 2/3 uses
 * k6395312 + k6395408, TYPE 5 uses k10692016 + k10692112. The clamp's second
 * operand is a constant and cannot be NaN, which is what eb_fminf_c/eb_fmaxf_c
 * require of their caller. */
static float eb_delay_pitchmod_pre(float ka, float kb)
{
    return eb_fmaxf_c(eb_fminf_c(
        (float)eb_pitch_poly((double)(float)(ka + kb)),
        512.0f), -512.0f);
}

#endif

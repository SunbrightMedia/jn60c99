/* juno_dsp.h — C99 port of the Cloud 60 (JUNO-60) DSP engine.
 *
 * Exact structural transcription of the decompiled plugin (see docs/). The
 * decompile in dsp_dump/ is the spec: same operations, same coefficients.
 * Nothing here is fitted or approximated.
 */
#ifndef JUNO_DSP_H
#define JUNO_DSP_H

#ifdef __cplusplus
extern "C" {
#endif

/* ── Leaf DSP helpers (decompiled, exact) ───────────────────────────────────
 * juno_wrap24  — 0x180368D60: wrap to signed 24-bit fixed point, ·2^-24.
 *                The DCO phase-accumulator wrap.
 * juno_triangle — 0x180368FC0: phase (wrapped to [-1,1)) → triangle wave.
 */
float juno_wrap24(float x);
float juno_triangle(float phase);

#ifdef __cplusplus
}
#endif

#endif /* JUNO_DSP_H */

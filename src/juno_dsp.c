/* juno_dsp.c — C99 port of the Cloud 60 (JUNO-60) DSP engine.
 *
 * Each function carries the source address (RVA from ImageBase 0x180000000) of
 * the decompiled routine in dsp_dump/ that it transcribes. Transcription is
 * literal; constants come from the .rdata values in the dump, never invented.
 */
#include "juno_dsp.h"
#include <math.h>
#include "juno_tables.h"

/* ── 0x180368D60 — juno_wrap24 ──────────────────────────────────────────────
 * Wrap a value into signed 24-bit fixed point and scale back by 2^-24.
 *   v1 = (int)(x * 2^24)              ; truncate toward zero
 *   then a tie adjustment on bits 21/23 doubles v1 and conditionally +1
 *   mask to 24 bits, sign-extend via bit 24, multiply by 2^-24.
 * Constants from the dump: 16777216.0 (2^24), 5.960464477539063e-08 (2^-24).
 * This is transcribed bit-for-bit; the bit fiddling is the algorithm, so it is
 * reproduced verbatim rather than re-expressed as a "clean" formula.
 */
float juno_wrap24(float x)
{
    int v1 = (int)(x * 16777216.0f);
    int v2;
    if (v1 == 0) {
        v2 = 1;
    } else {
        int v3 = v1 & 0x200000;
        if ((v1 & 0x800000) != 0) {
            if (v3 == 0)
                v2 = 2 * v1;        /* bit23 set, bit21 clear */
            else
                v2 = 2 * v1 + 1;    /* bit23 set, bit21 set   */
        } else {
            if (v3 != 0)
                v2 = 2 * v1;        /* bit23 clear, bit21 set  */
            else
                v2 = 2 * v1 + 1;    /* bit23 clear, bit21 clear */
        }
    }
    int v5 = v2 & 0xFFFFFF;
    int v6 = v2 | 0xFF000000;       /* sign-extend candidate */
    if ((v2 & 0x1000000) == 0)
        v6 = v5;                    /* bit 24 clear → no sign extension */
    return (float)v6 * 5.960464477539063e-08f;
}

/* ── 0x180368FC0 — juno_triangle ────────────────────────────────────────────
 * Wrap phase into [-1,1) (via fmodf), then piecewise-map to a triangle:
 *   |p| <= 0.5 :  2*p
 *      p > 0.5 :  2 - 2*p
 *      p < -0.5: -2 - 2*p
 * Constants from the dump: 1.0, -1.0, 2.0, 0.5, -0.5, -2.0.
 */
float juno_triangle(float phase)
{
    if (phase <= 1.0f) {
        if (phase < -1.0f)
            phase = fmodf(phase - 1.0f, 2.0f) + 1.0f;
    } else {
        phase = fmodf(phase + 1.0f, 2.0f) - 1.0f;
    }
    float v2 = phase + phase;       /* 2*p */
    if (phase >= -0.5f) {
        if (phase <= 0.5f)
            return v2;              /* 2*p */
        else
            return 2.0f - v2;       /* 2 - 2*p */
    } else {
        return -2.0f - v2;          /* -2 - 2*p */
    }
}

/* ── 0x180368DC0 — juno_pitch_poly ──────────────────────────────────────────
 * Pitch -> ratio via the 13-term spline in juno_pitch_table (the unk_1809894E0
 * table, row = clamp(x,-20,8.9)+20). Exact transcription.
 */
double juno_pitch_poly(double x)
{
    double v1 = fmin(fmax(x, -20.0), 8.9);
    double v2 = v1 * v1 * v1;
    const double *v3 = juno_pitch_table[(int)(v1 + 20.0)];
    double v4 = v2 * v1 * v1;
    double v5 = v4 * v1 * v1;
    double v6 = v5 * v1 * v1;
    return v1 * v3[2]
         + v3[0]
         + v1 * v1 * v3[4]
         + v2 * v3[6]
         + v2 * v1 * v3[8]
         + v4 * v3[10]
         + v4 * v1 * v3[12]
         + v5 * v3[14]
         + v5 * v1 * v3[16]
         + v6 * v3[18]
         + v6 * v1 * v3[20]
         + v6 * v1 * v1 * v3[22]
         + v6 * v1 * v1 * v1 * v3[24];
}

/* ── 0x180368F30 — juno_wrap_unit: wrap to [-1,1) both directions ─────────── */
float juno_wrap_unit(float x)
{
    if (x > 1.0f)  return fmodf(x + 1.0f, 2.0f) - 1.0f;
    if (x < -1.0f) return fmodf(x - 1.0f, 2.0f) + 1.0f;
    return x;
}

/* ── 0x180368F90 — juno_wrap_hi: wrap only when > 1 ───────────────────────── */
float juno_wrap_hi(float x)
{
    if (x > 1.0f) return fmodf(x + 1.0f, 2.0f) - 1.0f;
    return x;
}

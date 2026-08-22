/* jx_voice_helpers.h -- helpers called by the JX voice render arm
 * (sub_1803A22C0). Transcribed from the jxdump2 decompile + 01_closure.asm;
 * table values re-derived from truth/JX3P.vst3 (checksummed) at the rvas.
 * STATUS: READ (static transcription; unproven until null).
 * Names are jx_h_<rva>; semantic naming comes later. No state pointers:
 * all five helpers are pure scalar functions (plus two const .rdata tables
 * private to jx_voice_helpers.c).
 */
#ifndef JX_VOICE_HELPERS_H
#define JX_VOICE_HELPERS_H

/* sub_18039A250: float scale by 2^a2, a2 clamped to [-32, 32], via .rdata
 * power-of-two f32 table (never ldexpf). */
float  jx_h_39A250(float result, int a2);

/* sub_1803A2010: double 13-term polynomial, per-integer-segment coefficients,
 * argument clamped to [-20.0, 8.9]. */
double jx_h_3A2010(double a1);

/* sub_1803A2180: float wrap into [-1, +1] (fmodf based). */
float  jx_h_3A2180(float result);

/* sub_1803A2210: float wrap into [-1, +1], then piecewise: 2x for
 * |x| <= 0.5, 2 - 2x for x > 0.5, -2 - 2x for x < -0.5. Decompile shows an
 * __m128 return; every call site in sub_1803A22C0 consumes .m128_f32[0]
 * only, so the scalar float is the whole contract. */
float  jx_h_3A2210(float a1);

/* sub_1803A9950: integer bit manipulation on (int)(x * 2^24) (tests of bits
 * 21/23/24, doubling, masks), then (float)result * 2^-24. */
float  jx_h_3A9950(float a1);

#endif /* JX_VOICE_HELPERS_H */

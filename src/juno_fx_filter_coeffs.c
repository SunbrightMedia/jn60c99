/* fx_filter_coeffs.c — capture-free seed for the shared FX filter-coefficient
 * templates (chorus / delay / FX-A / effect blocks) of the JUNO-60 C port.
 *
 * Provenance: every value is the binary's invariant, FX-selector-determined
 * coefficient, sourced from the decompiled binary's .rdata tables / param
 * defaults (NOT fitted to audio, NOT copied blindly). The mapping was recovered
 * in refs/fx_coeff_recipe.json + docs/FX_COEFF_SETUP.md and is validated
 * 4-byte float bit-exact. ImageBase 0x7FF91DC60000; rva = addr - imagebase.
 *
 * The FX coefficients are never written by direct stores in the binary; they are
 * bound through the node-coefficient mechanism (sub_1803C1090 /
 * **(float**)(*(*(engine)+56)+40*idx+32) = value), where the *value* pushed is a
 * read of one of:
 *   - the registered param-default biquad block @rva 0x988F90..0x9890E0
 *     (HighCut C0/A0/A1/B0/B2 — the recurring biquad template),
 *   - the "musical ladder" curve LUTs curve58 0x986D68 / curve60 0x987A48 /
 *     curve65 0x987EF0 (HighCut/Damp/LowCut Fc, indexed by the fixed knob step),
 *   - fixed scalar constants (HighCut Qc 0x988F9C=1.41442716, gains, 0.5, 1.0),
 *   - the float32 formula  Chorus CV = -(float)code / (float)255.0,
 *   - effect-block (limiter/compressor/distortion) param defaults.
 *
 * Recurring biquad template (the brief's {0.151557,1.37884,-0.530399,0.205802,
 * 1.41443} and {0.515128,1.03026,-0.447828,-0.612685,0.795497,1.41443}):
 *   Delay/FX-A/CH2 shape  : C0=0.15155718, B0=1.37884212, B2=-0.53039932,
 *                           Fc=curve58[7]=0.20580207, Qc=1.41442716.
 *   Chorus/CH3 shape      : C0=0.51512837, A0=1.03025675(=2*C0), A1=0.51512837,
 *                           B0=-0.44782829, B2=-0.61268526,
 *                           Fc=curve58[13]=0.79549694, Qc=1.41442716.
 * (These are precomputed LUT rows / param defaults; the binary contains no
 *  runtime design(Fc,Qc) routine for them — see docs/FX_COEFF_SETUP.md §4.)
 *
 * Bit-exact: writes raw 32-bit patterns, no float arithmetic at runtime, so the
 * result is independent of host FP. Call on a zeroed engine-state buffer AFTER
 * juno_chorus_init and BEFORE/instead-of juno_runtime_coeffs_apply for the FX
 * filter region.
 */
#include <stdint.h>
#include <string.h>

static void fx_put_bits(unsigned char *st, int off, uint32_t bits)
{
    memcpy(st + off, &bits, sizeof(bits));   /* type-pun safe via memcpy */
}

void juno_fx_filter_coeffs_apply(unsigned char *st)
{
#define PUT(s, o, b) fx_put_bits((s), (o), (b))

    /* ---- CHORUS block ---- */
    PUT(st,  6395328, 0x3f800000u); /* 1            unity/switch default 1.0 */
    PUT(st,  6396128, 0x3d6f8001u); /* 0.0584717    effect-block param (limiter/comp), runtime-computed */
    PUT(st,  6396160, 0x3f000000u); /* 0.5          const 0.5 (rdata 0x93cc69 family) */
    PUT(st,  6396176, 0x3f800000u); /* 1            unity/switch default 1.0 */
    PUT(st,  6396192, 0x3f03df74u); /* 0.515128     CHO HighCut C0: const @rva 0x989054 */
    PUT(st,  6396208, 0x3f83df74u); /* 1.03026      CHO HighCut A0: const @rva 0x989058 */
    PUT(st,  6396224, 0x3f03df74u); /* 0.515128     CHO HighCut A1: const @rva 0x98905c */
    PUT(st,  6396240, 0xbee549c0u); /* -0.447828    CHO HighCut B0: const @rva 0x988fa4 */
    PUT(st,  6396256, 0xbf1cd8f1u); /* -0.612685    CHO HighCut B2: const @rva 0x988fa8 */
    PUT(st,  6396288, 0x3f4ba5b0u); /* 0.795497     CHO HighCut Fc: lut @rva 0x986d9c */
    PUT(st,  6396304, 0x3fb50bf3u); /* 1.41443      CHO HighCut Qc: const @rva 0x988f9c */
    PUT(st,  6396320, 0x3f800000u); /* 1            unity/switch default 1.0 */
    PUT(st,  6396336, 0x3ad6774fu); /* 0.00163625   CHO LowCut Fc: lut @rva 0x987ef4 */
    PUT(st,  6396352, 0x3f800000u); /* 1            unity/switch default 1.0 */
    PUT(st,  6396368, 0x3f800000u); /* 1            unity/switch default 1.0 */
    PUT(st,  6396384, 0x3f800000u); /* 1            unity/switch default 1.0 */
    PUT(st,  6396400, 0x37ffd974u); /* 3.04996e-05  CHO Ip Fc: const @rva 0x9880f4 */
    PUT(st,  6396432, 0x3f800000u); /* 1            unity/switch default 1.0 */
    PUT(st,  6396448, 0x3f800000u); /* 1            unity/switch default 1.0 */
    PUT(st,  6396480, 0x3f800000u); /* 1            unity/switch default 1.0 */
    PUT(st,  6396496, 0x3f353f7du); /* 0.708        CHO Dry Gain: const @rva 0x98906c */
    PUT(st,  6396512, 0x3fb4dd2fu); /* 1.413        CHO Wet Gain: const @rva 0x98909c */

    /* ---- DELAY block ---- */
    PUT(st,  6497168, 0x400c9e00u); /* 2.19714      effect gain 2.19714 (DLY/effect, runtime-computed) */
    PUT(st,  6497184, 0x3e1b31ceu); /* 0.151557     CH2 HighCut C0: const @rva 0x98903c */
    PUT(st,  6497232, 0x3fb07de6u); /* 1.37884      CH2 HighCut B0: const @rva 0x9890d8 */
    PUT(st,  6497248, 0xbf07c840u); /* -0.530399    CH2 HighCut B2: const @rva 0x9890dc */
    PUT(st,  6497280, 0x3e52bdc7u); /* 0.205802     CH2 HighCut Fc: lut @rva 0x986d84 */
    PUT(st,  6497296, 0x3fb50bf3u); /* 1.41443      CH2 HighCut Qc: const @rva 0x988f9c */
    PUT(st,  6497312, 0x3f800000u); /* 1            unity/switch default 1.0 */
    PUT(st,  6497328, 0x3f800000u); /* 1            unity/switch default 1.0 */
    PUT(st,  6497344, 0x3ec0c0c1u); /* 0.376471     mix level 96/255 (float div, bit-exact) */
    PUT(st,  6497376, 0x3ed8d8d9u); /* 0.423529     mix level 108/255 (float div, bit-exact) */
    PUT(st,  6497392, 0x3f800000u); /* 1            unity/switch default 1.0 */
    PUT(st,  6497424, 0x3bab929au); /* 0.00523598   CH2 LFDampFc: lut @rva 0x987a48 */
    PUT(st,  6497440, 0x3f800000u); /* 1            unity/switch default 1.0 */
    PUT(st,  6497456, 0x3f800000u); /* 1            unity/switch default 1.0 */
    PUT(st,  6497472, 0x3f4ba5b0u); /* 0.795497     CH2 HFDampFc: lut @rva 0x986d9c */
    PUT(st,  6497488, 0x3f800000u); /* 1            unity/switch default 1.0 */
    PUT(st,  6497504, 0x3f800000u); /* 1            unity/switch default 1.0 */

    /* ---- FXA block ---- */
    PUT(st,  4297600, 0x3e1b31ceu); /* 0.151557     DL2 HighCut C0: const @rva 0x98903c */
    PUT(st,  4297648, 0x3fb07de6u); /* 1.37884      DL2 HighCut B0: const @rva 0x9890d8 */
    PUT(st,  4297664, 0xbf07c840u); /* -0.530399    DL2 HighCut B2: const @rva 0x9890dc */
    PUT(st,  4297696, 0x3e52bdc7u); /* 0.205802     DL2 HighCut Fc: lut @rva 0x986d84 */
    PUT(st,  4297712, 0x3fb50bf3u); /* 1.41443      DL2 HighCut Qc: const @rva 0x988f9c */
    PUT(st,  4297728, 0x3f800000u); /* 1            unity/switch default 1.0 */
    PUT(st,  4297744, 0x3f800000u); /* 1            unity/switch default 1.0 */
    PUT(st,  4297792, 0x3efefeffu); /* 0.498039     mix level 127/255 (float div, bit-exact) */
    PUT(st,  4297808, 0x3ed8d8d9u); /* 0.423529     mix level 108/255 (float div, bit-exact) */
    PUT(st,  4297824, 0x3f800000u); /* 1            unity/switch default 1.0 */
    PUT(st,  4297856, 0x3f800000u); /* 1            unity/switch default 1.0 */
    PUT(st,  4297888, 0x40000000u); /* 2            DL2 Wet Gain: const @rva 0x969640 */
    PUT(st,  4297904, 0x3bab929au); /* 0.00523598   DL2 LFDampFc: lut @rva 0x987a48 */
    PUT(st,  4297920, 0x3f800000u); /* 1            unity/switch default 1.0 */
    PUT(st,  4297936, 0x3f800000u); /* 1            unity/switch default 1.0 */
    PUT(st,  4297952, 0x3f4ba5b0u); /* 0.795497     DL2 HFDampFc: lut @rva 0x986d9c */
    PUT(st,  4297968, 0x3f800000u); /* 1            unity/switch default 1.0 */
    PUT(st,  4297984, 0x3f800000u); /* 1            unity/switch default 1.0 */

    /* ---- EFFECT block ---- */
    PUT(st,    84448, 0x3f800000u); /* 1            unity/switch default 1.0 */
    PUT(st,    84464, 0x3f800000u); /* 1            unity/switch default 1.0 */
    PUT(st,    84480, 0x3f800000u); /* 1            unity/switch default 1.0 */
    PUT(st,    84496, 0x3f800000u); /* 1            unity/switch default 1.0 */
    PUT(st,    84544, 0x3f800000u); /* 1            unity/switch default 1.0 */
    PUT(st,    84560, 0x3f800000u); /* 1            unity/switch default 1.0 */
    PUT(st,    85152, 0x41008081u); /* 8.03137      effect gain 8.03137 (~2048/255, effect-block) */
    PUT(st,    91120, 0x3c0e0000u); /* 0.00866699   effect coeff 0.00866699 (1-pole ~132Hz, effect-block) */
    PUT(st,    91136, 0x3f77b282u); /* 0.967568     effect coeff 0.967568 (rdata 0x9881d0) */
    PUT(st,    91152, 0x3727c5acu); /* 1e-05        effect coeff 1e-05 (rdata 0xae4f48) */
    PUT(st,    91168, 0x3f800000u); /* 1            unity/switch default 1.0 */
    PUT(st,    91184, 0x3b83126fu); /* 0.004        effect time 0.004 (rdata 0x9881f8) */
    PUT(st,    91200, 0x3a8d5a27u); /* 0.00107843   effect coeff 0.00107843 (~0.275/255) */
    PUT(st,    91216, 0x3fa66666u); /* 1.3          effect ratio 1.3 (rdata 0xae50f8) */
    PUT(st,    91232, 0x3f95c28fu); /* 1.17         effect ratio 1.17 (rdata 0x9881d4) */
    PUT(st,    91248, 0x37ffd974u); /* 3.04996e-05  CHO Ip Fc 3.05e-05 (rdata 0x9880f4) */
    PUT(st,    91264, 0x3f800000u); /* 1            unity/switch default 1.0 */
    PUT(st,    91280, 0x3f800000u); /* 1            unity/switch default 1.0 */
    PUT(st,    96336, 0x3c1abc15u); /* 0.00944426   effect coeff 0.00944426 (effect-block) */
    PUT(st,    96352, 0x37e6c674u); /* 2.75105e-05  effect coeff 2.75105e-05 (effect-block) */
    PUT(st,    96368, 0x3b442984u); /* 0.0029932    effect coeff 0.0029932 (rdata 0x988108) */
    PUT(st,    96384, 0x37ffd974u); /* 3.04996e-05  CHO Ip Fc 3.05e-05 (rdata 0x9880f4) */
    PUT(st,    96400, 0x3f800000u); /* 1            unity/switch default 1.0 */
    PUT(st,    96416, 0x3f800000u); /* 1            unity/switch default 1.0 */
    PUT(st,   101136, 0x3f800000u); /* 1            unity/switch default 1.0 */
    PUT(st,   101152, 0x3e77a5b3u); /* 0.241843     effect coeff 0.241843 (rdata 0x96cae0) */
    PUT(st,   101744, 0x3f800000u); /* 1            unity/switch default 1.0 */
    PUT(st,   102352, 0x400c9e00u); /* 2.19714      effect gain 2.19714 (DLY/effect, runtime-computed) */
    PUT(st,   102368, 0x3e1b31ceu); /* 0.151557     DLY HighCut C0: const @rva 0x98903c */
    PUT(st,   102416, 0x3fb07de6u); /* 1.37884      DLY HighCut B0: const @rva 0x9890d8 */
    PUT(st,   102432, 0xbf07c840u); /* -0.530399    DLY HighCut B2: const @rva 0x9890dc */
    PUT(st,   102464, 0x3e52bdc7u); /* 0.205802     DLY HighCut Fc: lut @rva 0x986d84 */
    PUT(st,   102480, 0x3fb50bf3u); /* 1.41443      DLY HighCut Qc: const @rva 0x988f9c */
    PUT(st,   102496, 0x3f800000u); /* 1            unity/switch default 1.0 */
    PUT(st,   102512, 0x3f800000u); /* 1            DLY Dry Level: lut @rva 0x9d9f20 */
    PUT(st,   102608, 0x3bab929au); /* 0.00523598   DLY LFDampFc: lut @rva 0x987a48 */
    PUT(st,   102624, 0x3f800000u); /* 1            DLY LFDampHp: lut @rva 0x9d9f20 */
    PUT(st,   102640, 0x3f800000u); /* 1            DLY LFDampLp: lut @rva 0x9d9f20 */
    PUT(st,   102656, 0x3f4ba5b0u); /* 0.795497     DLY HFDampFc: lut @rva 0x986d9c */
    PUT(st,   102672, 0x3f800000u); /* 1            DLY HFDampHp: lut @rva 0x9d9f20 */
    PUT(st,   102688, 0x3f800000u); /* 1            DLY HFDampLp: lut @rva 0x9d9f20 */

#undef PUT
}

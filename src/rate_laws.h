/* rate_laws.h -- the plugin's own host-rate laws for the FX cells that RECALL
 * writes (CLAIMS B4).
 *
 * Until 2026-10-05 the recall wrote these cells from 4-arm tables measured at
 * 44100 / 48000 / 88200 / 96000 and used the 96000 arm for EVERY other rate.
 * The plugin computes them from the host rate H, so at 32000 or 192000 the port
 * was wrong (tools/verify/rate_sweep_gate.py: 4 of 9 renders differed within
 * 400 samples). Each law below is READ from the plugin's machine code and is
 * PROVEN by the 18-rate sweeps (rate_sweep_gate.py, finefx_pillar3_gate.py).
 * The 4-arm tables stay in finefx_tables.h as measured anchors:
 * tests/test_rate_laws.c checks every law reproduces every anchor bit for bit.
 *
 * H is the integer host rate; the plugin converts it with cvtdq2ps, which is
 * (float)Hr here. Every expression keeps the plugin's operation order, and the
 * build's -ffp-contract=off keeps each operation separately rounded. */
#ifndef JUNO_RATE_LAWS_H
#define JUNO_RATE_LAWS_H

#include <stdint.h>
#include <string.h>

static inline float rl_f32(uint32_t b) { float f; memcpy(&f, &b, sizeof f); return f; }

/* t96 * 96000 / H (multiply first). Identity at exactly 96000: the plugin skips
 * the scale there (`cmp eax,0x17700 / je`). DELAY LF DAMP FREQ (rva 0x3603b0,
 * table value x f32 96000 at rva 0x98802c, then divss by the rate) and CHORUS
 * LOW CUT (rva 0x361108). */
static inline float rl_scale96(uint32_t t96_bits, int Hr)
{
    float t = rl_f32(t96_bits);
    if (Hr != 96000) t = (t * 96000.0f) / (float)Hr;
    return t;
}

/* A delay time of x milliseconds as the engine's coefficient:
 * ((H * x) * C1) - C2, x == 0 -> 0. The same tail ends the chorus pre-delay
 * (rva 0x360a56) and the DELAY TIME default setSampleRate writes (rva 0x35fbaa,
 * x = 201 ms, clamped to 4778). */
static inline float rl_ms_time(float x, int Hr)
{
    if (x == 0.0f) return 0.0f;
    return (((float)Hr * x) * rl_f32(0x3383126fu)) - rl_f32(0x39000000u);
}

/* CHORUS PRE DELAY, rva 0x360a20. k = the plugin's int table at rva 0x9c4270,
 * which is exactly 5*byte over the parameter's range 0..80 (the recall clamps
 * to it). x = k * 0.1f ms, clamped to the block's 40 ms; then
 * ((H * x) * C1) - C2 with C1 = f32 0x3383126f (rva 0x988f98) and
 * C2 = f32 0x39000000 (rva 0x988104); x == 0 stores 0. */
static inline float rl_chorus_predelay(int pd_byte, int Hr)
{
    float x = (float)(5 * pd_byte) * 0.1f;
    if (x > 40.0f) x = 40.0f;
    return rl_ms_time(x, Hr);
}

/* EFFECT TYPE 5 block-B structural delay 96336, rva 0x357310 (also run by
 * setSampleRate): (H * C3) - C2, C3 = f32 0x33d5febf (rva 0x9880f0). */
static inline float rl_mode5_time(int Hr)
{
    return ((float)Hr * rl_f32(0x33d5febfu)) - rl_f32(0x39000000u);
}

/* Chorus block-A "set mode" method, rva 0x357b80: a 3-row table (EFFECT TYPE
 * 2 chorus I, 3 chorus II, 4 flanger) of {T, depth, a, ., .} (rva 0x988200,
 * 0x9881f0, 0x9881e0, 0x9881d8, 0x9881d0). */
static const uint32_t RL_CHORUS_MODE_T[3] = { 0x3ac49ba6u, 0x3ac49ba6u, 0x3b5844d0u };
static const uint32_t RL_CHORUS_MODE_A[3] = { 0x3ef5c28fu, 0x3f51eb85u, 0x41133333u };

/* delay time T -> 91120: while T > 0.0033 halve it, then ((H*T) - 2) * 1/16384
 * (f32 2.0 at rva 0xae51e8, 1/16384 at rva 0x9880fc); T == 0 stores 0. */
static inline float rl_chorus_mode_time(int row, int Hr)
{
    float x = rl_f32(RL_CHORUS_MODE_T[row]);
    while (x > rl_f32(0x3b5844d0u)) x *= 0.5f;
    if (x == 0.0f) return 0.0f;
    return (((float)Hr * x) - 2.0f) * rl_f32(0x38800000u);
}

/* LFO rate a -> 91152: (a + a) / H. */
static inline float rl_chorus_mode_rate(int row, int Hr)
{
    float a = rl_f32(RL_CHORUS_MODE_A[row]);
    return (a + a) / (float)Hr;
}

#endif /* JUNO_RATE_LAWS_H */

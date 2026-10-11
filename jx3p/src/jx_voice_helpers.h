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

float  jx_h_3A21E0(float result);  /* sub_1803A21E0: positive-side fmodf wrap */

/* Statically linked CRT math, transcribed from the binary's own machine code
 * (non-FMA paths; the CPU-feature flag the dispatcher tests is 0 in a fresh
 * image, which is what the Unicorn oracle executes). System libm differs by
 * 1 ulp on some inputs (proved by the p30/43/53/54/56/62 A/B failures). */
float  jx_h_expf_722EA0(float a1);  /* expf  @ rva 0x722EA0 */
float  jx_h_tanf_725150(float a1);  /* tanf  @ rva 0x725150 */

/* minss / maxss / minsd / maxsd as the plugin's instructions compute them (2026-10-11, tools/verify/nan_sites.py,
 * playbook 219): the first operand when the compare holds, else the SECOND -- so the second when either is NaN,
 * where C's fminf / fmaxf return the one that is not NaN. The compare runs in the CPU's mode (DAZ reads a denormal
 * as 0) and the chosen operand's bits are returned as they are: the emulated plugin's select (Unicorn's minss hands
 * a denormal operand back unflushed, EXECUTED), and on hardware under FTZ no operand is denormal. memcpy, no type
 * pun: ISO C99. */
#include <stdint.h>
#include <string.h>
static inline float jx_minss(float a, float b)
{
    uint32_t ua, ub, m;
    memcpy(&ua, &a, 4); memcpy(&ub, &b, 4);
    m = 0u - (uint32_t)(a < b);
    ua = (ua & m) | (ub & ~m);
    memcpy(&a, &ua, 4);
    return a;
}
static inline float jx_maxss(float a, float b)
{
    uint32_t ua, ub, m;
    memcpy(&ua, &a, 4); memcpy(&ub, &b, 4);
    m = 0u - (uint32_t)(a > b);
    ua = (ua & m) | (ub & ~m);
    memcpy(&a, &ua, 4);
    return a;
}
static inline double jx_minsd(double a, double b)
{
    uint64_t ua, ub, m;
    memcpy(&ua, &a, 8); memcpy(&ub, &b, 8);
    m = (uint64_t)0 - (uint64_t)(a < b);
    ua = (ua & m) | (ub & ~m);
    memcpy(&a, &ua, 8);
    return a;
}
/* ucomiss / ucomisd, then je / jne with NO parity test (2026-10-11, playbook 222): the machine's ZF is 1 for an
 * unordered pair, so its "equal" is TRUE on NaN and its "not equal" FALSE -- where C's == / != read it the other
 * way. nan_sites.py grades each equality by its instruction's flag consumers. The operands go in as double: exact
 * for float ones. */
static inline int jx_feq(double a, double b) { return !(a < b) && !(a > b); }
static inline int jx_fne(double a, double b) { return a < b || a > b; }
static inline double jx_maxsd(double a, double b)
{
    uint64_t ua, ub, m;
    memcpy(&ua, &a, 8); memcpy(&ub, &b, 8);
    m = (uint64_t)0 - (uint64_t)(a > b);
    ua = (ua & m) | (ub & ~m);
    memcpy(&a, &ua, 8);
    return a;
}

#endif /* JX_VOICE_HELPERS_H */

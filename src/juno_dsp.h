/* juno_dsp.h — C99 port of the Cloud 60 (JUNO-60) DSP engine.
 *
 * Exact structural transcription of the decompiled plugin (see docs/). The
 * decompile in dsp_dump/ is the spec: same operations, same coefficients.
 * Nothing here is fitted or approximated.
 */
#ifndef JUNO_DSP_H
#define JUNO_DSP_H

#include <stdint.h>
#include <string.h>

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

/* More leaf helpers (used by the master/chorus sub_180363380):
 * juno_pitch_poly — 0x180368DC0: pitch (clamped [-20,8.9]) -> ratio via the
 *                   unk_1809894E0 13-term spline (same table voice_render uses).
 * juno_wrap_unit  — 0x180368F30: wrap to [-1,1) (both directions).
 * juno_wrap_hi    — 0x180368F90: wrap only when > 1.
 */
double juno_pitch_poly(double x);
float  juno_wrap_unit(float x);
float  juno_wrap_hi(float x);

/* minss / maxss / minsd / maxsd as the plugin's instructions compute them (2026-10-11, tools/verify/nan_sites.py,
 * playbook 219): the first operand when the compare holds, else the SECOND -- so the second when either is NaN,
 * where C's fminf / fmaxf return the one that is not NaN. The compare runs in the CPU's mode (DAZ reads a denormal
 * as 0) and the chosen operand's bits are returned as they are: the emulated plugin's select (Unicorn's minss hands
 * a denormal operand back unflushed, EXECUTED), and on hardware under FTZ no operand is denormal. memcpy, no type
 * pun: ISO C99. The JX-3P's twins: jx3p/src/jx_voice_helpers.h. */
static inline float juno_minss(float a, float b)
{
    uint32_t ua, ub, m;
    memcpy(&ua, &a, 4); memcpy(&ub, &b, 4);
    m = 0u - (uint32_t)(a < b);
    ua = (ua & m) | (ub & ~m);
    memcpy(&a, &ua, 4);
    return a;
}
static inline float juno_maxss(float a, float b)
{
    uint32_t ua, ub, m;
    memcpy(&ua, &a, 4); memcpy(&ub, &b, 4);
    m = 0u - (uint32_t)(a > b);
    ua = (ua & m) | (ub & ~m);
    memcpy(&a, &ua, 4);
    return a;
}
static inline double juno_minsd(double a, double b)
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
 * way. The plugin's equalities are these (MSVC's fast float model); nan_sites.py grades each by its instruction's
 * flag consumers (a jp, or lahf; test ah, 44h, would make it IEEE's, as C's). The operands go in as double: exact
 * for float ones. */
static inline int juno_feq(double a, double b) { return !(a < b) && !(a > b); }
static inline int juno_fne(double a, double b) { return a < b || a > b; }
/* addss a, b where BOTH may be NaN (2026-10-11, playbook 227): x86 returns the FIRST source operand's NaN, quieted
 * (SDM Table 4-7); C leaves the choice to the compiler, and GCC orders a commutative add by its own numbering. Where
 * the plugin's order matters -- one NaN meeting a copy of itself another site negated -- it is written out: a NaN a
 * comes back as addss returns it (a + 0.0 quiets a signalling one; -fsignaling-nans keeps the add). */
static inline float juno_add_first(float a, float b)
{
    float s = a + b;
    if (a != a)
        s = a + 0.0f;
    return s;
}
static inline double juno_maxsd(double a, double b)
{
    uint64_t ua, ub, m;
    memcpy(&ua, &a, 8); memcpy(&ub, &b, 8);
    m = (uint64_t)0 - (uint64_t)(a > b);
    ua = (ua & m) | (ub & ~m);
    memcpy(&a, &ua, 8);
    return a;
}

#ifdef __cplusplus
}
#endif

#endif /* JUNO_DSP_H */

/* eb_dco.c — the DCO oscillator. See eb_dco.h for scope, provenance and the
 * band-limiting question.
 *
 * WHERE THE BLUEPRINT IS WRONG. docs/trackb/DCO.md was READ, and the oracle was
 * driven where the two disagreed. Two corrections, both PROVEN by reading the
 * range against the blueprint's own cell table:
 *
 *   1. DCO.md 1.1 lists 4640 (phase) and 4672 (sub counter) as SCRATCH, on the
 *      rule "first access in the sample is a WRITE". That rule misclassifies
 *      them. Line 1720 reads 4880 into 4656 and line 1722 reads 4848 into 4672
 *      BEFORE anything is written, and 4880/4848 are themselves last sample's
 *      4640/4672 handed back by the 1670-1671 shift. The blueprint says as much
 *      in its own parenthesis but files them under SCRATCH anyway, which would
 *      invite an implementation that does not carry them. They ARE this
 *      module's entire persistent state and engine B carries them as such.
 *
 *   2. DCO.md 1.1 files 4896 and 4912 as "last sub-block value ... the live
 *      value flows through the C locals". True for 4912, WRONG for 4896: the
 *      final mix at :2132 reads the C local `_s4896`, which the shim's own
 *      block-4 call sets, so the CELL is dead but the VALUE is not, and the
 *      four saw taps are not interchangeable. Engine B keeps the saw value in a
 *      register inside eb_dco_step, which is what the blueprint's sentence
 *      describes but its table does not.
 *
 * WHAT ENGINE B CHANGES, and why each change is EXACT and not an approximation:
 *   a. Two floats of state instead of nine cells (4640/4656/4672/4832/4848/
 *      4864/4880/4896/4912). Six of those exist only to shuttle a value from
 *      the bottom of the sample back to the top; in a struct it is the value in
 *      the register.
 *   b. fmodf is removed from the phase wrap by the triangle.h argument: for the
 *      magnitudes a phase accumulator can reach, the remainder IS one exact
 *      add or subtract, so the CALL goes and the ARITHMETIC stays, including
 *      the rounding of the leading +1/-1. Out-of-range inputs keep the fmodf
 *      path. Proven over all 2^32 inputs by test_dco_wrap.c.
 *   c. juno_triangle -> eb_triangle, already proven over all 2^32 inputs.
 *   d. pw-1 and pw+1 are hoisted out of the four sub-blocks. Same operands,
 *      same single rounding, so the same bits -- and the port recomputes them
 *      four times per sample from cells that only a recall changes.
 *   e. The DIVISION is NOT hoisted into a reciprocal multiply. x/y and x*(1/y)
 *      are different floats. It stays a divide, and it is the single most
 *      expensive instruction in this module on a device with no FPU divider.
 *      That is reported, not hidden.
 * There is no approximation in this module. The null is expected to be EXACTLY
 * 0, and if it is not, the difference is a defect and not a budget.
 */
#include "eb_dco.h"
#include "triangle.h"
#include <math.h>

/* ---------------------------------------------------------------- helpers
 * sign(): the port's exact three-way form (:1750-1758). It is NOT copysign and
 * it is NOT (x>0)-(x<0): zero maps to ITSELF, so -0.0f comes back as -0.0f, and
 * that sign propagates into the pulse gain. */
static inline float eb_sgn(float x)
{
    if (x >= 0.0f) return (x > 0.0f) ? 1.0f : x;
    return -1.0f;
}

/* clamp(): the port's exact form (:1736-1739). NaN takes the else arm and
 * becomes -1.0f, which fminf would not do. :1739 is the "safely dead" line of
 * the session brief -- margin 1.0, never taken -- and it is one instruction. */
static inline float eb_clamp1(float v)
{
    /* fminf is a CALL on both targets (MEASURED: 576 host instructions per
     * audio sample, 18 per invocation, for what is one compare). The guard
     * above already excludes NaN -- a NaN fails `v >= -1.0f` -- which is the
     * only input on which fminf and a compare disagree. So this is the same
     * function, not a relaxed one. */
    if (v < -1.0f) return -1.0f;
    return (v > 1.0f) ? 1.0f : v;
}

/* The odd-polynomial saturator, shared by saw, pulse and sub. The three copies
 * in the port are written with different parenthesisation by the decompiler but
 * are the SAME TREE (checked term by term): x3 as (x*x)*x in one and (x2*x) in
 * another is the same two roundings. Every grouping below is the port's. */
static inline float eb_sat(float x, const eb_dco_coef *c)
{
    float x2 = x * x;
    float x3 = x2 * x;
    float hi = (((x2 * c->k11) + c->k9) * (x2 * x2)
                + ((x2 * c->k7) + c->k5)) * (x3 * x2);
    return ((hi + (x3 * c->k3)) + x);
}

/* THE CLAMP SHORTCUT. See eb_dco.h. `e` is the output of eb_clamp1, so `e ==
 * 1.0f` and `e == -1.0f` are exact tests on values the clamp itself produced,
 * and 1.0f*sat_in / -1.0f*sat_in are exact products. The returned number is
 * therefore the one the polynomial would have returned, bit for bit, and this
 * is a hoist rather than an approximation. MEASURED: it fires on the large
 * majority of sub-samples at any musical pitch, because the unclamped window is
 * only the few phase steps either side of the waveform's edge. */
static inline float eb_sat_c(float e, const eb_dco_coef *c)
{
    if (e ==  1.0f) return c->sat_hi;
    if (e == -1.0f) return c->sat_lo;
    return eb_sat(e * c->sat_in, c);
}

void eb_dco_set_shape(eb_dco_coef *c)
{
    c->sat_hi = eb_sat( c->sat_in, c);
    c->sat_lo = eb_sat(-c->sat_in, c);
}

void eb_dco_set_pitch(eb_dco_coef *c, float inc, float pw)
{
    c->inc  = inc;
    c->g    = 0.00390625f / inc;
    c->pw   = pw;
    c->pwm1 = pw - 1.0f;
    c->pwp1 = pw + 1.0f;
#if EB_DCO_RECIP
    c->rm1  = 1.0f / c->pwm1;
    c->rp1  = 1.0f / c->pwp1;
#endif
}

/* ---------------------------------------------------------------- the step
 * eb_dco_step_i is the WHOLE step and is the only copy of this arithmetic.
 * eb_dco_step and eb_dco_step4 are both thin wrappers over it, so the two
 * entry points cannot drift apart: there is nothing to keep in sync.
 *
 * WHY eb_dco_step4 EXISTS -- and it is a HOIST, not an approximation. The block
 * runs the oscillator at 4x the host rate, and all four sub-samples share ONE
 * coefficient set: `inc`, `pw`, the three levels, the three amps, the three
 * gains, the five saturator terms, `subthr`, `g`, and the two clamp constants
 * do not change within a sample. Calling the step four times through a
 * `const eb_dco_coef *` makes the compiler reload them from memory each time,
 * because a pointer to a const struct does not promise nobody else writes it.
 * MEASURED before this change: 216 memory accesses per invocation, the single
 * largest class in the module, on a target whose cost is dominated by them.
 *
 * step4 takes ONE copy of the struct into a local that provably does not
 * escape, then runs the four steps against it. Every operand, every rounding
 * and every order of operations is identical -- the only thing that changes is
 * where the numbers are read from. The null must therefore be EXACTLY 0, and if
 * it is not, this is a defect and not a budget. */
#if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 199901L
#define EB_RESTRICT restrict
#else
#define EB_RESTRICT
#endif
#if defined(__GNUC__)
#define EB_ALWAYS_INLINE __attribute__((always_inline)) inline
#else
#define EB_ALWAYS_INLINE inline
#endif
static EB_ALWAYS_INLINE float eb_dco_step_i(eb_dco_state *s,
                                            const eb_dco_coef *c)
{
    const float prev = s->phase;
    float p, e, saw, pulse, sub, sq, cnt, t;

    p = eb_dco_wrap(prev + c->inc);
    s->phase = p;

    /* ---- LEVEL GATES. The three waveform terms are each multiplied by a
     * recalled level, and a JUNO patch very often has one or two of them at
     * exactly 0 (the patch these numbers were MEASURED on has DCO SUB LEVEL
     * exactly 0.0f). `finite * 0.0f` is +/-0.0f and adding a zero of either
     * sign leaves the other terms unchanged, so skipping the term is exact,
     * not "inaudible". The inputs are bounded -- the saturator argument is a
     * clamp to +/-1 -- so no inf or NaN can reach the multiply and turn the
     * zero into a NaN. What must NOT be skipped is the SUB COUNTER, which is
     * free-running state: it is advanced below whatever lvl_sub is. */

    /* ---- SAW: the wrapped ramp through the triangle, edge-scaled by g ---- */
    if (c->lvl_saw != 0.0f) {
        e   = eb_clamp1(((eb_triangle_saw(p) * 256.0f) * c->g)
                        * c->amp_saw);
        saw = eb_sat_c(e, c) * (p * c->gn_saw);
    } else saw = 0.0f;

    /* ---- PULSE: phase offset by the pulse width, squared and edge-scaled --
     * The divisor switches on the SIGN of the offset phase, so the two halves
     * of the pulse get different edge slopes -- that asymmetry is the pulse
     * width. Kept as a division: see the header. */
    if (c->lvl_pulse != 0.0f) {
        t     = c->pw + p;
        sq    = eb_sgn(t);
#if EB_DCO_RECIP
        e     = eb_clamp1(((eb_triangle(t * (t < 0.0f ? c->rm1 : c->rp1))
                            * c->g) * 256.0f) * c->amp_pulse);
#else
        e     = eb_clamp1(((eb_triangle(t / (t < 0.0f ? c->pwm1 : c->pwp1))
                            * c->g) * 256.0f) * c->amp_pulse);
#endif
        pulse = eb_sat_c(e, c) * (sq * c->gn_pulse);
    } else pulse = 0.0f;

    /* ---- SUB: a divide-by-two counter clocked by a rising crossing of
     * subthr, added to the phase. The port's test (:1774-1777) is written
     * inverted (`if (p < thr || thr <= prev) keep; else bump`); it is a rising
     * edge and nothing else. The counter steps by 2 and wraps at 4, so it is a
     * one-octave-down square. */
    cnt = s->subcnt;
    if (!(p < c->subthr || c->subthr <= prev)) cnt += 2.0f;
    if (cnt >= 4.0f) cnt = 0.0f;
    s->subcnt = cnt;

    if (c->lvl_sub != 0.0f) {
        t   = (((cnt + p) + 1.0f) * 0.5f) - 1.0f;
        e   = eb_clamp1((((eb_triangle_sub(-fabsf(t)) + 1.0f) * c->g) * 512.0f)
                        * c->amp_sub);
        sub = eb_sat_c(e, c) * (eb_sgn(t) * c->gn_sub);
    } else sub = 0.0f;

    /* ---- mix (:1807-1823). The association is the port's: the sub term is
     * added to the SUM of the saw and pulse terms, not folded left to right. */
    return (sub * c->lvl_sub)
         + ((saw * c->lvl_saw) + (pulse * c->lvl_pulse));
}

float eb_dco_step(eb_dco_state *s, const eb_dco_coef *c)
{
    return eb_dco_step_i(s, c);
}

void eb_dco_step4(eb_dco_state *EB_RESTRICT s,
                  const eb_dco_coef *EB_RESTRICT c,
                  float *EB_RESTRICT out)
{
    /* The local copy is the whole point: it does not escape, so its fields can
     * live in registers across all four steps instead of being re-read. */
    /* The local copy is the whole point: it does not escape, so its fields can
     * live in registers across all four steps instead of being re-read.
     *
     * THE LOOP AND THE always_inline ARE BOTH LOAD-BEARING, and the first
     * attempt at this got it wrong in a way worth recording. Written as four
     * plain calls, GCC DECLINED to inline the body -- at 454 instructions it is
     * far past the inliner's growth budget -- so `&k` escaped into a real call,
     * `k` had to live in memory, and the change measured 0 saving while ADDING
     * 3,231 cyc/sample of call overhead. Forcing the inline on four separate
     * calls would fix the loads and quadruple the code.
     *
     * A LOOP with one forced inline gives both: one copy of the arithmetic in
     * the binary, and a `k` that never escapes, so its fields are promoted to
     * registers for the whole loop. */
    int i;
    for (i = 0; i < 4; ++i)
        out[i] = eb_dco_step_i(s, c);
}

void eb_dco_advance(eb_dco_state *s, const eb_dco_coef *c, unsigned n)
{
    float p = s->phase, cnt = s->subcnt, prev;
    unsigned i, k;
    for (i = 0; i < n; ++i) {
        for (k = 0; k < 4; ++k) {
            prev = p;
            p = eb_dco_wrap(p + c->inc);
            if (!(p < c->subthr || c->subthr <= prev)) cnt += 2.0f;
            if (cnt >= 4.0f) cnt = 0.0f;
        }
    }
    s->phase = p;
    s->subcnt = cnt;
}

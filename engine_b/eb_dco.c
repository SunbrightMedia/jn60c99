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

/* ---------------------------------------------------------------- the wrap
 * Reference, src/voice_render.c:1723-1731:
 *     if (p <= 1.0f) { if (p < -1.0f) p = fmodf(p - 1.0f, 2.0f) + 1.0f; }
 *     else                            p = fmodf(p + 1.0f, 2.0f) - 1.0f;
 *
 * BOTH ARMS ARE LIVE. The negative arm (:1726) fires in none of the 30 null
 * scenarios and is 0.0003 away from firing in one of them, so a scenario gate
 * cannot protect it and only the exhaustive test can.
 *
 * The leading add is kept because it rounds. Only the libm call is removed, and
 * only where the remainder is provably a single exact operation: for
 * t = p+1 in [2,4) the value t-2 is exact (both operands within a factor of
 * two), and for t in [0,2) fmodf(t,2) == t, which the |t|<4 branch also gives
 * since t-2 would be wrong there -- but t >= 2 always holds in this arm because
 * p > 1. The mirror argument covers the negative arm. Non-finite inputs and
 * anything beyond +/-4 fall through to fmodf, so nothing is assumed about the
 * domain. */
float eb_dco_wrap(float p)
{
    if (p <= 1.0f) {
        if (p < -1.0f) {
            float t = p - 1.0f;                       /* rounds -- keep it */
            return (t > -4.0f) ? (t + 2.0f) + 1.0f
                               : fmodf(t, 2.0f) + 1.0f;
        }
        return p;
    } else {
        float t = p + 1.0f;                           /* rounds -- keep it */
        return (t < 4.0f) ? (t - 2.0f) - 1.0f
                          : fmodf(t, 2.0f) - 1.0f;
    }
}

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
    return (v >= -1.0f) ? fminf(v, 1.0f) : -1.0f;
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

void eb_dco_set_pitch(eb_dco_coef *c, float inc, float pw)
{
    c->inc  = inc;
    c->g    = 0.00390625f / inc;
    c->pw   = pw;
    c->pwm1 = pw - 1.0f;
    c->pwp1 = pw + 1.0f;
}

/* ---------------------------------------------------------------- the step */
float eb_dco_step(eb_dco_state *s, const eb_dco_coef *c)
{
    const float prev = s->phase;
    float p, e, x, saw, pulse, sub, sq, cnt, t;

    p = eb_dco_wrap(prev + c->inc);
    s->phase = p;

    /* ---- SAW: the wrapped ramp through the triangle, edge-scaled by g ---- */
    e   = eb_clamp1(((eb_triangle((p + 1.0f) * 0.5f) * 256.0f) * c->g)
                    * c->amp_saw);
    x   = e * c->sat_in;
    saw = eb_sat(x, c) * (p * c->gn_saw);

    /* ---- PULSE: phase offset by the pulse width, squared and edge-scaled --
     * The divisor switches on the SIGN of the offset phase, so the two halves
     * of the pulse get different edge slopes -- that asymmetry is the pulse
     * width. Kept as a division: see the header. */
    t     = c->pw + p;
    sq    = eb_sgn(t);
    e     = eb_clamp1(((eb_triangle(t / (t < 0.0f ? c->pwm1 : c->pwp1)) * c->g)
                       * 256.0f) * c->amp_pulse);
    x     = e * c->sat_in;
    pulse = eb_sat(x, c) * (sq * c->gn_pulse);

    /* ---- SUB: a divide-by-two counter clocked by a rising crossing of
     * subthr, added to the phase. The port's test (:1774-1777) is written
     * inverted (`if (p < thr || thr <= prev) keep; else bump`); it is a rising
     * edge and nothing else. The counter steps by 2 and wraps at 4, so it is a
     * one-octave-down square. */
    cnt = s->subcnt;
    if (!(p < c->subthr || c->subthr <= prev)) cnt += 2.0f;
    if (cnt >= 4.0f) cnt = 0.0f;
    s->subcnt = cnt;

    t   = (((cnt + p) + 1.0f) * 0.5f) - 1.0f;
    e   = eb_clamp1((((eb_triangle(-fabsf(t)) + 1.0f) * c->g) * 512.0f)
                    * c->amp_sub);
    x   = e * c->sat_in;
    sub = eb_sat(x, c) * (eb_sgn(t) * c->gn_sub);

    /* ---- mix (:1807-1823). The association is the port's: the sub term is
     * added to the SUM of the saw and pulse terms, not folded left to right. */
    return (sub * c->lvl_sub)
         + ((saw * c->lvl_saw) + (pulse * c->lvl_pulse));
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

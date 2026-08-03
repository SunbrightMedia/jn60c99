/* dco_paths.c — the STATIC half of P3: what each DCO path costs in Xtensa
 * instructions. Compiled for the ESP32-S3 at the shipping flags and counted
 * with objdump by tools/engineb/dco_price.py. Never linked into anything.
 *
 * WHY ISOLATED PROBES RATHER THAN READING eb_dco_step_i's DISASSEMBLY. The real
 * step is one basic-block graph with the three waveform arms interleaved by the
 * scheduler; attributing its instructions to paths by hand is exactly the kind
 * of judgement call this project has been burned by. Each function below
 * contains ONE path's arithmetic, copied verbatim from eb_dco.c, so its cost is
 * counted by the assembler rather than argued about.
 *
 * THE HONEST LIMITATION, STATED HERE RATHER THAN DISCOVERED LATER. Isolation
 * changes register allocation: each probe pays its own function prologue and
 * reloads coefficients the real step keeps in registers across all four
 * sub-samples. That makes these figures an OVER-estimate of the marginal cost
 * of each arm. dco_price.py therefore also counts the real eb_dco_step4 as a
 * whole and reports both, and the two are cross-checked against each other
 * rather than one being quoted alone.
 *
 * `noinline` and `noclone` keep each probe a countable symbol; `volatile` sinks
 * stop the optimiser deleting an arm whose result is otherwise unused, which
 * would price it at zero.
 */
#include "eb_dco.h"
#include "triangle.h"
#include <math.h>

#define PROBE __attribute__((noinline, noclone))

static inline float eb_sgn(float x)
{
    if (x >= 0.0f) return (x > 0.0f) ? 1.0f : x;
    return -1.0f;
}

static inline float eb_clamp1(float v)
{
    if (v < -1.0f) return -1.0f;
    return (v > 1.0f) ? 1.0f : v;
}

static inline float eb_sat(float x, const eb_dco_coef *c)
{
    float x2 = x * x;
    float x3 = x2 * x;
    float hi = (((x2 * c->k11) + c->k9) * (x2 * x2)
                + ((x2 * c->k7) + c->k5)) * (x3 * x2);
    return ((hi + (x3 * c->k3)) + x);
}

/* ---- P_FIXED: the work every step does whatever the levels are: the phase
 * wrap on its fast arm, the phase store, and the sub counter's rising-edge
 * test. This is also the whole cost of a step with all three levels at 0. */
PROBE float p_fixed(eb_dco_state *s, const eb_dco_coef *c)
{
    const float prev = s->phase;
    float p, cnt;
    p = eb_dco_wrap(prev + c->inc);
    s->phase = p;
    cnt = s->subcnt;
    if (!(p < c->subthr || c->subthr <= prev)) cnt += 2.0f;
    if (cnt >= 4.0f) cnt = 0.0f;
    s->subcnt = cnt;
    return p;
}

/* ---- P_SAT: the odd polynomial. This is the cost the clamp shortcut AVOIDS,
 * and the rates say it is avoided on ~99.2-99.7 % of calls. */
PROBE float p_sat(float e, const eb_dco_coef *c)
{
    return eb_sat(e * c->sat_in, c);
}

/* ---- P_SAT_SHORT: the shortcut itself -- two exact compares and a load. */
PROBE float p_sat_short(float e, const eb_dco_coef *c)
{
    if (e ==  1.0f) return c->sat_hi;
    if (e == -1.0f) return c->sat_lo;
    return 0.0f;                      /* the full arm is priced by p_sat */
}

/* ---- the three waveform arms, each EXCLUDING the saturator (priced above) */
PROBE float p_saw(float p, const eb_dco_coef *c)
{
    float e = eb_clamp1(((eb_triangle_saw(p) * 256.0f) * c->g) * c->amp_saw);
    return e * (p * c->gn_saw);
}

PROBE float p_pulse(float p, const eb_dco_coef *c)
{
    float t  = c->pw + p;
    float sq = eb_sgn(t);
    float e;
#if EB_DCO_RECIP
    e = eb_clamp1(((eb_triangle(t * (t < 0.0f ? c->rm1 : c->rp1))
                    * c->g) * 256.0f) * c->amp_pulse);
#else
    e = eb_clamp1(((eb_triangle(t / (t < 0.0f ? c->pwm1 : c->pwp1))
                    * c->g) * 256.0f) * c->amp_pulse);
#endif
    return e * (sq * c->gn_pulse);
}

PROBE float p_sub(float p, float cnt, const eb_dco_coef *c)
{
    float t = (((cnt + p) + 1.0f) * 0.5f) - 1.0f;
    float e = eb_clamp1((((eb_triangle_sub(-fabsf(t)) + 1.0f) * c->g) * 512.0f)
                        * c->amp_sub);
    return e * (eb_sgn(t) * c->gn_sub);
}

/* ---- P_MIX: the final association, including the three level multiplies. */
PROBE float p_mix(float saw, float pulse, float sub, const eb_dco_coef *c)
{
    return (sub * c->lvl_sub)
         + ((saw * c->lvl_saw) + (pulse * c->lvl_pulse));
}

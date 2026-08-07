/* eb_dco_wt.c — see eb_dco_wt.h for the eight measurements this shape rests on.
 *
 * THE PER-SAMPLE PATH IS THE WHOLE POINT, so read it first and the residual
 * bookkeeping second. Away from an edge every arm is exactly +/- sat_hi -- the
 * saturator's own shortcut was MEASURED firing on 98.85 % of sub-steps -- so
 * the oscillator is a phase accumulate, three signs and a mix. Everything else
 * in this file exists to correct the samples where an edge falls.
 */
#include "eb_dco_wt.h"

#if EB_DCO_WT

#include <math.h>
#include <string.h>

/* THE MIP LEVEL, one per semitone. Chosen by the increment because that is
 * what the note actually plays at: vibrato, portamento and CONDITION's detune
 * all move a voice between levels without any rebuild, which is the property
 * that makes one shared table set legal (eb_dco_wt.h, finding 4). */
void eb_dco_wt_set_pitch(eb_dco_wt_coef *c, float inc, float pw)
{
    c->inc = inc;
    c->pw  = pw;
    /* log2 by exponent extraction, 12 steps per octave. No logf: this runs
     * per sample per voice and libm's logf is 150+ instructions on this
     * target, which is more than the whole rest of the tick. */
    {
        unsigned b;
        int e;
        memcpy(&b, &inc, 4);
        e = (int)((b >> 23) & 0xFFu) - 127;          /* floor(log2(inc))     */
        /* the mantissa's top 4 bits refine it to a quarter-octave, then a
         * small table finishes the semitone. Cheap and monotone, which is all
         * a mip index has to be. */
        c->mip = (e + 20) * 12 + (int)((b >> 19) & 0xFu) * 12 / 16;
        if (c->mip < 0) c->mip = 0;
        if (c->mip >= EB_WT_MIPS) c->mip = EB_WT_MIPS - 1;
    }
}

/* Schedule a residual. `frac` is where in the sample the crossing fell, in
 * [0,1); `amp` is the height of the step being corrected. The residual is
 * ADDED into a ring that the tick drains, so several arms crossing in one
 * sample cost one add each and nothing more. */
static void eb_wt_add(eb_dco_wt_state *s, const float *tab, float frac,
                      float amp)
{
    int sub = (int)(frac * (float)EB_WT_RES_OVER);
    const float *r = tab + sub * EB_WT_RES_LEN;
    int i, p = s->rpos;
    for (i = 0; i < EB_WT_RES_LEN; ++i) {
        s->ring[p] += r[i] * amp;
        p = (p + 1) & (EB_WT_RES_LEN - 1);
    }
}

float eb_dco_wt_tick(eb_dco_wt_state *s, const eb_dco_wt_coef *c)
{
    const float prev = s->phase;
    float p, t, u, cnt, out;
    float saw, pulse, sub;

    /* ---- phase. The port's wrap is a pair of compares and an add; the
     * fmodf arms it also has were MEASURED taken 0 times in 61 M sub-steps
     * (docs/engineb/data/dco_real_cost.md), so they are not reproduced on a
     * path whose whole purpose is to be cheap. A phase that could reach them
     * would need an increment above 2.0, which is above Nyquist. */
    p = prev + c->inc;
    if (p >= 1.0f)  p -= 2.0f;
    s->phase = p;

    /* ---- the three arms, FLAT. sat_hi/sat_lo are the saturator evaluated at
     * +/-1, which is what eb_sat_c returns whenever the clamped edge is
     * saturated -- and it is, except within a fraction of a sample of a
     * crossing. Those samples are corrected by the residuals below. */
    saw   = (p * c->gn_saw) * c->sat_hi;

    t     = c->pw + p;
    pulse = (t < 0.0f ? -c->gn_pulse : c->gn_pulse)
          * (t < 0.0f ? c->sat_lo : c->sat_hi);

    /* ---- the sub counter, verbatim from eb_dco.c: a rising crossing of
     * subthr steps it by two and it wraps at four. It is FREE-RUNNING STATE
     * and is advanced whatever lvl_sub is, exactly as the port does. */
    cnt = s->subcnt;
    if (!(p < c->subthr || c->subthr <= prev)) cnt += 2.0f;
    if (cnt >= 4.0f) cnt = 0.0f;
    s->subcnt = cnt;

    u   = (((cnt + p) + 1.0f) * 0.5f) - 1.0f;
    sub = (u < 0.0f ? -c->gn_sub : c->gn_sub) * c->sat_hi;

/* EB_WT_NO_EDGES is a PRICING switch, not a build option. Compiling with it
 * removes the residual blocks so the FLAT path can be counted on its own --
 * 72 Xtensa instructions, which is the number the whole plan turns on. A
 * build that defines it does not produce audio and no gate may use one. */
#ifndef EB_WT_NO_EDGES
#define EB_WT_NO_EDGES 0
#endif
#if !EB_WT_NO_EDGES
    /* ---- the edges. Each arm's edge is a step of known height at a known
     * fractional position, and the residual table carries the difference
     * between the band-limited edge and that flat step. */
    if (p < prev) {                      /* the saw's wrap, and the pulse's
                                          * FIXED edge, both at the phase wrap */
        float frac = (1.0f - prev) / c->inc;
        eb_wt_add(s, c->res_saw + (size_t)c->mip * EB_WT_RES_OVER
                                * EB_WT_RES_LEN, frac,
                  -2.0f * c->gn_saw * c->sat_hi);
        eb_wt_add(s, c->res_pulse_b + (size_t)c->mip * EB_WT_RES_OVER
                                    * EB_WT_RES_LEN, frac,
                  c->gn_pulse * (c->sat_hi - c->sat_lo));
    }
    {   /* the pulse's MOVING edge, where t crosses zero */
        float tprev = c->pw + prev;
        if ((tprev < 0.0f) != (t < 0.0f) && p >= prev) {
            /* THE SLICE, and the two reasons it is an index and not a rebuild:
             * pw crawls (48 % of samples do not move it at all, only 232 of
             * 17.2 M move it past 1e-2), and the grid at 0.01 was MEASURED at
             * the convergence limit already. */
            int sl = (int)((c->pw - EB_WT_PW_LO) * (1.0f / EB_WT_PW_STEP));
            float frac;
            if (sl < 0) sl = 0;
            if (sl >= EB_WT_PW_SLICES) sl = EB_WT_PW_SLICES - 1;
            frac = -tprev / c->inc;
            eb_wt_add(s, c->res_pulse_a
                         + (((size_t)c->mip * EB_WT_PW_SLICES + (size_t)sl)
                            * EB_WT_RES_OVER * EB_WT_RES_LEN),
                      frac, c->gn_pulse * (c->sat_hi - c->sat_lo));
        }
    }
    if (cnt != s->subcnt || (u < 0.0f) != (((((s->subcnt + prev) + 1.0f)
                                             * 0.5f) - 1.0f) < 0.0f)) {
        /* the sub's own crossing; its step is the same height as the pulse's
         * because both are square */
        eb_wt_add(s, c->res_sub + (size_t)c->mip * EB_WT_RES_OVER
                                * EB_WT_RES_LEN, 0.5f,
                  c->gn_sub * (c->sat_hi - c->sat_lo));
    }

#endif
    /* ---- mix, in the port's own association: the sub term is added to the
     * SUM of the saw and pulse terms, not folded left to right. */
    out = (sub * c->lvl_sub)
        + ((saw * c->lvl_saw) + (pulse * c->lvl_pulse));

    /* ---- drain one residual sample and clear the slot behind us */
    out += s->ring[s->rpos];
    s->ring[s->rpos] = 0.0f;
    s->rpos = (s->rpos + 1) & (EB_WT_RES_LEN - 1);
    return out;
}

#endif  /* EB_DCO_WT */

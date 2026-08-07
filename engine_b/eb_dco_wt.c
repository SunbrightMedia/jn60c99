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
#include "eb_wt_tables.h"

void eb_dco_wt_bind_tables(eb_dco_wt_coef *c)
{
    c->res_saw     = &eb_wt_res_saw[0][0][0];
    c->res_sub     = &eb_wt_res_sub[0][0][0];
    c->res_pulse_a = &eb_wt_res_pulse_a[0][0][0];
    c->res_pulse_b = &eb_wt_res_pulse_b[0][0][0];
}

/* THERE IS NOTHING TO DERIVE. The residual is pitch-independent (eb_dco_wt.h,
 * finding 5 -- MEASURED at 2.4290 output samples across five octaves), so this
 * carries the two per-sample numbers and nothing else. The mip-index
 * arithmetic that used to live here, exponent extraction and all, is gone
 * because the dimension it indexed does not exist. */
void eb_dco_wt_set_pitch(eb_dco_wt_coef *c, float inc, float pw)
{
    c->inc = inc;
    c->pw  = pw;
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
    /* MEASURED, not derived. eb_dco.c computes pulse = eb_sat_c(e) * sgn(t) *
     * gn_pulse, where e is the CLAMPED EDGE and its sign is set by tri(x), not
     * by t. Running it: sat_hi = +1, sat_lo = -1, and the flat output is
     * exactly +/- gn_pulse following the sign of t.
     *
     * The first version wrote (t<0 ? -gn : gn) * (t<0 ? sat_lo : sat_hi) --
     * and since sat_lo is NEGATIVE the two sign flips cancelled, so the
     * "pulse" was a constant. It showed up as a residual that stepped once and
     * never came back, because the reference it was measured against never
     * stepped at all. */
    pulse = (t < 0.0f ? -c->gn_pulse : c->gn_pulse) * c->sat_hi;

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
        /* THE LEVEL BELONGS ON THE RESIDUAL TOO. The generator normalises
         * each residual by its step height measured at LEVEL 1, and the flat
         * path below applies the recalled level -- so a residual added without
         * it is scaled by 1/lvl relative to the signal it corrects. Measured:
         * the module's RMS came out 0.85 against the 4x path's 0.21, which is
         * exactly the missing lvl_pulse of 0.25. */
        eb_wt_add(s, c->res_saw, frac,
                  -2.0f * c->gn_saw * c->sat_hi * c->lvl_saw);
        {   int sb = (int)((c->pw - EB_WT_PW_LO)
                           * (float)EB_WT_PWB_SLICES);
            if (sb < 0) sb = 0;
            if (sb >= EB_WT_PWB_SLICES) sb = EB_WT_PWB_SLICES - 1;
        eb_wt_add(s, c->res_pulse_b
                     + (size_t)sb * EB_WT_RES_OVER * EB_WT_RES_LEN, frac,
                  c->gn_pulse * (c->sat_hi - c->sat_lo) * c->lvl_pulse); }
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
                         + ((size_t)sl * EB_WT_RES_OVER * EB_WT_RES_LEN),
                      frac, c->gn_pulse * (c->sat_hi - c->sat_lo)
                            * c->lvl_pulse);
        }
    }
    if (cnt != s->subcnt || (u < 0.0f) != (((((s->subcnt + prev) + 1.0f)
                                             * 0.5f) - 1.0f) < 0.0f)) {
        /* the sub's own crossing; its step is the same height as the pulse's
         * because both are square */
        eb_wt_add(s, c->res_sub, 0.5f,
                  c->gn_sub * (c->sat_hi - c->sat_lo) * c->lvl_sub);
    }

#endif
    /* ---- mix, in the port's own association: the sub term is added to the
     * SUM of the saw and pulse terms, not folded left to right. */
    out = (sub * c->lvl_sub)
        + ((saw * c->lvl_saw) + (pulse * c->lvl_pulse));

    /* ---- THE FLAT VALUE IS DELAYED TO MEET ITS OWN CORRECTION.
     *
     * The residual is centred at tap EB_WT_RES_LEN/2, because a band-limited
     * step has energy on BOTH sides of its edge. Written from the current
     * position it therefore lands half a window LATE, and the first build did
     * exactly that: the flat signal was on time, the correction arrived 32
     * samples afterwards, and the null measured -21 to -37 dB with the
     * alignment search pinned at its limit.
     *
     * That is NOT something an alignment can remove -- a signal whose
     * correction is displaced from it is not a delayed signal, it is a wrong
     * one. So the flat value is written into the same ring at +HALF, where its
     * own residual's centre already lands. The whole oscillator is then
     * delayed by HALF samples UNIFORMLY, which IS a pure delay and which the
     * gate can and does remove.
     *
     * The alternative is a minimum-phase residual, which is causal and needs
     * no delay at all. It is the better answer and it is not this one: it
     * requires a cepstral factorisation in the generator, and the cost here is
     * one add. */
    s->ring[(s->rpos + EB_WT_RES_LEN / 2) & (EB_WT_RES_LEN - 1)] += out;

    /* ---- drain, and clear the slot behind us */
    out = s->ring[s->rpos];
    s->ring[s->rpos] = 0.0f;
    s->rpos = (s->rpos + 1) & (EB_WT_RES_LEN - 1);
    return out;
}

#endif  /* EB_DCO_WT */

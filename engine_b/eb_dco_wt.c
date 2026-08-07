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

/* TWO PER-SAMPLE NUMBERS AND ONE INDEX. The saw's and the pulse's residuals are
 * pitch-independent (eb_dco_wt.h, finding 5 -- MEASURED at 2.4290 output samples
 * across five octaves), so they need no level. THE SUB'S IS NOT (finding 9), and
 * the exponent extraction below is the whole of what that costs. */
void eb_dco_wt_set_pitch(eb_dco_wt_coef *c, float inc, float pw)
{
    c->inc = inc;
    c->pw  = pw;
    /* THE SUB'S MIP LEVEL, one per octave, taken from the FLOAT EXPONENT so it
     * costs no logarithm. inc/EB_WT_SUB_INC0 in [1,2) is level 0, [2,4) is
     * level 1, and so on; the biased exponent of that ratio minus 127 IS the
     * level. Only the sub needs this -- see eb_dco_wt.h, finding 9. */
    {   union { float f; unsigned u; } z;
        int lv;
        z.f = inc * (1.0f / EB_WT_SUB_OINC0);
        lv = (int)((z.u >> 23) & 0xFFu) - 127;
        if (lv < 0) lv = 0;
        if (lv >= EB_WT_SUB_MIPS) lv = EB_WT_SUB_MIPS - 1;
        c->sub_mip = lv;
    }
}

/* Schedule a residual. `frac` is where in the sample the crossing fell, in
 * [0,1); `amp` is the height of the step being corrected. The residual is
 * ADDED into a ring that the tick drains, so several arms crossing in one
 * sample cost one add each and nothing more. */
/* EB_WT_CONV: a TEMPORARY sweep of the fractional-crossing convention.
 * bit 0 = use (1-frac) instead of frac; bit 1 = write one slot later.
 * The relationship between "the edge fell at fraction f through this sample"
 * and "the residual table's sub-position index" has four plausible readings
 * and reasoning has picked the wrong one twice today, so it is MEASURED. */
#ifndef EB_WT_CONV
#define EB_WT_CONV 0
#endif

static void eb_wt_add(eb_dco_wt_state *s, const float *tab, float frac,
                      float amp)
{
    /* INTERPOLATED BETWEEN TWO SUB-POSITIONS. Picking the nearest one
     * quantises the crossing time, and on a correction whose slope reaches
     * 1.2 per sample that quantisation IS the error -- 18 % at four positions,
     * which is what the module measured as -20 dB. The blend costs one
     * multiply and one add per tap and removes it. */
    int sub;
    const float *r0, *r1;
    float g1, g0;
    int i, p = s->rpos;
#if EB_WT_CONV & 1
    frac = 1.0f - frac;
#endif
    if (frac < 0.0f) frac = 0.0f;
    if (frac > 0.99999f) frac = 0.99999f;
    frac *= (float)EB_WT_RES_OVER;
    sub = (int)frac;
    g1 = frac - (float)sub;
    g0 = 1.0f - g1;
    r0 = tab + sub * EB_WT_RES_LEN;
    /* the last slot's partner is the FIRST slot of the NEXT sample's window,
     * which is the same shape shifted one tap -- so it is read one tap in */
    r1 = (sub + 1 < EB_WT_RES_OVER) ? r0 + EB_WT_RES_LEN : r0;
    for (i = 0; i < EB_WT_RES_LEN; ++i) {
        s->ring[p] += (r0[i] * g0 + r1[i] * g1) * amp;
        p = (p + 1) & (EB_WT_RES_LEN - 1);
    }
}

float eb_dco_wt_tick(eb_dco_wt_state *s, const eb_dco_wt_coef *c)
{
    const float prev = s->phase;
    float p, t, u, cnt, cnt_old, out;
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
    /* THE SAW'S PHASE IS DELAYED BY THE DECIMATOR'S GROUP DELAY, and this is
     * the saw arm's whole problem.
     *
     * The pulse and the sub are SQUARE: a filter delays a square and the flat
     * value either side is unchanged, so a residual can carry the delay. The
     * saw is a RAMP, and a delayed ramp is not the same ramp -- it is the ramp
     * minus d*slope, a constant offset PROPORTIONAL TO THE SLOPE. The slope is
     * inc*gn_saw*sat_hi, so that offset changes with pitch and CANNOT live in
     * a pitch-independent table. It has to be here.
     *
     * MEASURED before this: the saw was the worst arm by a wide margin,
     * -16.7 dB at 441 Hz and -5.2 at 1,764, against the pulse's -27.0 and
     * -39.8 -- and it degraded with pitch exactly as a slope-proportional
     * error must.
     *
     * 3.875 is the FIR's group delay: 15.5 sub-samples at four to the output
     * sample, derived from the tap map and confirmed by the alignment shift
     * the first diagnostic needed. */
#ifndef EB_WT_SAWGD
#define EB_WT_SAWGD 3.875f
#endif
    {   /* THE DELAYED PHASE MUST BE WRAPPED. p is in [-1,1), so p minus the
         * group delay falls BELOW -1 for the few samples after each wrap --
         * and left unwrapped the saw's flat value is wrong by a full step for
         * that whole span. The span is 3.875*inc in phase, so its duration
         * scales with pitch, which is exactly how the saw's error behaved:
         * -37.7 dB at 441 Hz and -16.0 at 1,764, about 11 dB per octave.
         *
         * The delay constant itself was swept and is right: the error has a
         * sharp minimum at 3.875 (-37.7 dB) against -28.7 at 3.0 and -27.7 at
         * 5.0, and 3.875 is what the tap map's centroid gives and what feeding
         * a ramp through the FIR measures. */
        float pd = p - (EB_WT_SAWGD) * c->inc;
        if (pd < -1.0f) pd += 2.0f;
        saw = (pd * c->gn_saw) * c->sat_hi;
    }

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
    cnt_old = cnt;          /* BEFORE the toggle -- see the edge test below */
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
    /* THE STEP HEIGHTS ARE COMPUTED FROM THE FLAT PATH, not assembled from
     * constants. The generator divides each residual by its own SIGNED step
     * height, so the tick must supply the same signed number -- and every time
     * one was written out by hand it was a chance to get the sign wrong. The
     * pulse's wrap was wrong that way: the right magnitude with the wrong
     * sign, which is worse than no correction at all, and it cost 8 dB.
     *
     * Here each height is the flat value AFTER the edge minus the flat value
     * BEFORE it, in exactly the expressions the flat path above uses. A sign
     * cannot disagree with itself. */
    {
        const float tp = c->pw + prev;
        /* THE PREVIOUS RAMP USES THE PREVIOUS COUNTER. s->subcnt has already
         * been updated by the time this runs, so using it here computes the
         * previous sample's ramp with the NEW counter -- which is wrong on
         * exactly the sample the counter toggles, i.e. the only sample this
         * test exists to catch. */
        const float up = (((cnt_old + prev) + 1.0f) * 0.5f) - 1.0f;
        const float f_pulse_prev = (tp < 0.0f ? -c->gn_pulse : c->gn_pulse)
                                 * c->sat_hi;
        const float f_sub_prev   = (up < 0.0f ? -c->gn_sub : c->gn_sub)
                                 * c->sat_hi;
        /* THE SAW'S STEP IS KNOWN, and must not be taken as a difference at
         * the detection sample. Its phase carries the group delay, so the ramp
         * wraps 3.875 samples LATER -- at the detection sample the difference
         * is the ramp's SLOPE, and passing that as the step height scales the
         * whole residual by a near-zero number.
         *
         * At a wrap the saw goes from +1 to -1, so the step is exactly
         * -2*gn_saw*sat_hi. The other two arms are square and their step
         * genuinely is the difference across the sample. */
        const float h_saw   = -2.0f * c->gn_saw * c->sat_hi * c->lvl_saw;
        const float h_pulse = (pulse - f_pulse_prev) * c->lvl_pulse;
        const float h_sub   = (sub   - f_sub_prev)   * c->lvl_sub;
        (void)h_saw; (void)h_pulse; (void)h_sub;
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
        eb_wt_add(s, c->res_saw, frac, h_saw);
        {   int sb = (int)((c->pw - EB_WT_PW_LO)
                           * (float)EB_WT_PWB_SLICES);
            if (sb < 0) sb = 0;
            if (sb >= EB_WT_PWB_SLICES) sb = EB_WT_PWB_SLICES - 1;
        /* NEGATIVE. The generator divides each residual by its own SIGNED
         * step height, so a residual is always for a unit POSITIVE step and
         * the tick must supply the sign. At the phase wrap t goes from pw+1
         * (positive) to pw-1 (negative), so the pulse steps DOWN: the height
         * is -2*gn*sat_hi.
         *
         * MEASURED against tools/engineb/wt_decomp.c: the correction needed at
         * the edge is +1.694, and passing +1.70 applied -1.694 -- the right
         * magnitude with the wrong sign, which is worse than no correction. */
        eb_wt_add(s, c->res_pulse_b
                     + (size_t)sb * EB_WT_RES_OVER * EB_WT_RES_LEN, frac,
                  h_pulse); }
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
                      frac, h_pulse);
        }
    }
    /* THE SUB'S EDGE. The old test read
     *     cnt != s->subcnt || (u<0) != (u_from(s->subcnt, prev) < 0)
     * and BOTH halves were broken: s->subcnt had already been assigned `cnt`
     * two lines above, so the first comparison was a value against itself and
     * always false; and the second built the previous ramp from the NEW
     * counter, which is wrong on precisely the sample the counter toggles.
     *
     * The symptom was that the sub was the ONLY arm that did not improve when
     * the tables were rebuilt at exact fractional positions -- it sat at
     * -25.6 dB while the pulse went from -27.0 to -61.7. */
    if ((u < 0.0f) != ((((cnt_old + prev) + 1.0f) * 0.5f - 1.0f) < 0.0f)) {
        /* the sub's own crossing; its step is the same height as the pulse's
         * because both are square */
        /* THE SUB'S OWN FRACTION. Its ramp is u = ((cnt + p + 1)/2) - 1 with
         * cnt in {0,2}: at cnt = 0 that is (p+1)/2 - 1, ALWAYS negative for
         * p in [-1,1); at cnt = 2 it is (p+1)/2, ALWAYS non-negative. So u's
         * SIGN IS THE COUNTER, and the sub's edge is exactly where the counter
         * toggles -- the rising crossing of `subthr`, which is about -0.005.
         *
         * TWO WRONG FRACTIONS CAME BEFORE THIS, and both are the same mistake.
         * A hardcoded 0.5 gave the table an index the caller never really
         * supplied. Then (1-prev)/inc assumed the crossing coincides with the
         * PHASE WRAP -- it does not; subthr sits near zero, half a period away.
         * The sub stayed the worst arm at -26.6 dB through both.
         *
         * The toggle test is `prev < subthr <= p`, so subthr - prev lies in
         * (0, inc] and the fraction is in [0,1) by construction. */
        eb_wt_add(s, c->res_sub
                     + (size_t)c->sub_mip * EB_WT_RES_OVER * EB_WT_RES_LEN,
                  (c->subthr - prev) / c->inc, h_sub);
    }
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

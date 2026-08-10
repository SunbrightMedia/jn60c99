/* eb_delay.c -- ENGINE B, MODULE DELAY (DELAY TYPE 0).
 *
 * Line-for-line from docs/engineb/data/eb_delay_ref.c, which is the literal
 * transcription of src/master_render.c:1055-1264 and which nulled BIT-EXACT
 * against the sealed engine (docs/engineb/FX_DELAY.md). Every multiply and add
 * is kept in the reference's ORDER AND GROUPING; the only thing that changed is
 * where the state lives.
 *
 * Two things in the reference are DELIBERATELY not carried over, both of them
 * dead stores, both named here so the omission is a decision and not a slip:
 *   - cell 102112 (a third biquad output tap) and cell 102208 (a DELAY TIME
 *     latch) are WRITTEN and never READ, in this block or anywhere the delay
 *     path reaches. Dropping a store cannot change a sample.
 *   - cell 101824 (the previous read tap) is written, shifted, and then
 *     overwritten by the LF-damp state before it is used.
 * Everything else, including the one-sample-late feedback tap, the one-sample-
 * late mute fade and the odd `v370` comparison in the time smoother, is
 * reproduced exactly. None of it is "fixed".
 */
#include "eb_delay.h"
#include "eb_minmax.h"
#include <math.h>

#define M (EB_DELAY_LEN - 1)

void eb_delay_process(const eb_delay_cfg *c, eb_delay_state *s,
                      int route_change, float xL, float xR,
                      float *outL, float *outR)
{
    const float x[2] = { xL, xR };
    float ring_in[2];
    float fade_z, fadesum_prev, fadesum, fstep, f, fade_applied;
    float tprev, tt, v369, d, sm, P, frac;
    float out[2];
    int32_t di2;
    int i;

    /* ---- the effect-routing click suppressor (cell 11022348) ---------- */
    if (route_change) { fade_z = 0.0f; fadesum_prev = 0.0f; }
    else              { fade_z = s->fade; fadesum_prev = s->fadesum; }
    fade_applied = fade_z;               /* the fade is ONE SAMPLE LATE */

    /* ---- input HIGH CUT, and what goes into the line ------------------ */
    for (i = 0; i < 2; ++i) {
        float xi = x[i], yA, yB, u, wf, t;
#if EB_DELAY_BIQUAD
        yA = (((c->b1 * s->bx1[i] + c->b0 * xi) + c->b2 * s->bx2[i])
              + c->a1 * s->by1[i]) + c->a2 * s->by2[i];
        s->bx2[i] = s->bx1[i]; s->bx1[i] = xi;
        s->by2[i] = s->by1[i]; s->by1[i] = yA;
#else
        yA = 0.0f;                       /* 102448 == 0.0 away from 44,100 */
#endif
        t  = xi - s->s1[i] * c->svf_r;
        yB = c->svf_g * s->s1[i] + s->s2[i];
        s->s1[i] = (t - s->s2[i]) * c->svf_g + s->s1[i];
        s->s2[i] = yB;
#if EB_DELAY_BIQUAD
        u  = (1.0f - c->mixA) * yB + c->mixA * yA;
#else
        u  = yB;
#endif
        wf = u * c->mixB + (1.0f - c->mixB) * xi;
        ring_in[i] = (wf * c->on + s->fbtap[i] * c->fb) * c->mute;
    }

    /* ---- mute fade: +/- one step, clamped to [0,1], then MUTE --------- */
    fadesum = (c->fade_k + fadesum_prev) * c->fade_gain;
    s->fadesum = fadesum;
    tprev = s->t_smooth;                 /* the PREVIOUS smoothed time */
    fstep = (fadesum - tprev >= 0.0f) ? c->fade_up : c->fade_dn;
    f = fade_z + fstep;
    if (f <= 0.0f) f = 0.0f;
    f = (f >= -1.0f) ? eb_fminf_c(f, 1.0f) : -1.0f;
    s->fade = f * c->mute;

    /* ---- DELAY TIME smoother ------------------------------------------ */
    /* A 4-deep pipeline in the sealed engine (cells 102208 -> 102224 ->
     * 102240 -> 102256, rotated at the top of the sample). Its meaning: the
     * glide DISTANCE is latched when the TARGET CHANGES, and held while it does
     * not -- a constant-TIME glide, not a constant-rate one. Getting this wrong
     * is what the first null run caught at -33.9 dB. */
    tt = c->time_target;
    v369 = (tt - s->t_last != 0.0f) ? (tt - tprev) : s->t_step;
    s->t_last = tt;
    s->t_step = v369;
    d  = fabsf(v369) * c->slew;
    sm = eb_fmaxf(tprev - d, tt);
    if (tt - tprev > 0.0f) sm = eb_fminf(tprev + d, tt);
    s->t_smooth = sm;

    /* ---- tap position: integer part NEGATED, fraction from the positive */
    /* The sealed engine does these three in DOUBLE. Engine B does them in
     * float, and that is not an assumption: the two forms were compared over
     * EVERY float32 bit pattern with |sm| <= 1e6 -- 2,464,696,322 values --
     * with 0 mismatches in the int cast and 0 in the fraction (the scaling is
     * by a power of two, so it is exact, and P - trunc(P) is a difference of
     * neighbouring floats). Values outside that domain set `overrun` below and
     * are refused, so the untested tail is not reachable. This matters on the
     * ESP32-S3, whose FPU is single-precision only: one double here would be a
     * softfloat call per sample. */
    di2  = (int32_t)(sm * -16384.0f);              /* <= 0 */
    P    = sm * 16384.0f;
    frac = P - (float)(int)P;
    if (-di2 + 2 >= EB_DELAY_LEN) s->overrun = 1;  /* never wrap silently */

    /* ---- read, loop damping filter, output, write ---------------------- */
    for (i = 0; i < 2; ++i) {
        float t1, t2, tap, d1, lpn, e, d2, hpn, g;
        int32_t i1 = (s->w[i] - di2 + 1) & M;
        int32_t i2 = (s->w[i] - di2 + 2) & M;
        t1 = s->ring[i][i1];
        t2 = s->ring[i][i2];
        tap = ((frac * t2) - (frac * t1) + t1) * fade_applied;

        d1  = c->k624 * (tap - s->lp[i]);
        lpn = (tap - s->lp[i]) * c->lp_g + s->lp[i];
        e   = d1 - c->lf_damp * lpn;
        s->lp[i] = lpn;
        d2  = e - s->hp[i];
        hpn = d2 * c->hp_g + s->hp[i];
        g   = (c->k688 * hpn - c->hf_damp * d2) - s->dc[i];
        s->hp[i] = hpn;
        s->dc[i] = g * c->dc_g + s->dc[i];
        s->fbtap[i] = g;

        out[i] = (c->on * (c->dry * x[i]) + (1.0f - c->on) * x[i])
               + tap * c->wet;

        s->w[i] = (s->w[i] - 1) & M;
        s->ring[i][s->w[i]] = ring_in[i];
    }
    *outL = out[0];
    *outR = out[1];
}

/* eb_vca_hpf.c — the VCA + HPF output stage. See eb_vca_hpf.h for the scope,
 * the provenance and the list of what is changed.
 *
 * EVALUATION ORDER IS THE SPECIFICATION. The build is -ffp-contract=off and the
 * reference is x86 SSE2 single precision, so an algebraically equal regrouping
 * is a DIFFERENT NUMBER. Every parenthesis below is the source's own. The
 * regroupings that look free here and are NOT taken:
 *     (c*b - c*a) + a          is not      a + c*(b-a)
 *     (x*c1 - c2*x) + c2       is not      c2 + x*(c1-c2)
 *     t*b + a*(1-t)            is not      the distributed lerp above
 * The last one matters most: BOTH shapes occur in this range, twelve lines
 * apart, and docs/trackb/CELLMAP.md flags it. They are kept where they are.
 */
#include "eb_vca_hpf.h"
#include <math.h>

void eb_vca_reset(eb_vca_state *st)
{
    st->sm = st->g1 = st->g2 = st->gate_y = 0.0f;
    st->lp = st->lp2 = st->dcacc = 0.0f;
    st->x1 = st->yA = st->yB = 0.0f;
}

float eb_vca_tick(eb_vca_state *st, const eb_vca_coef *c,
                  float vcf, float env1, float env2, float rescomp,
                  float gate)
{
    float sm, vel, g1, g2;
    float gy, gnext, galt, gclamp, grate;
    float lp_prev, lp, boost, hp_in;
    float env, lvl, y, y2, out;
    float dcacc, x, tone, tA, tB, mix, w;

    /* ---------------------------------------- velocity smoother :1521-1529
     * Two one-poles with the VEL SENS / FIXED LEVEL blend between them. Both
     * blends are the DISTRIBUTED form; the (1-c) complement is never formed. */
    sm  = st->sm;
    sm  = ((c->c9680 - sm) * c->c9744) + sm;                        /* :1525 */
    st->sm = sm;
    vel = ((sm * c->c9600) - (c->c9600 * c->c9616)) + c->c9616;     /* :1527 */

    g1  = st->g1;
    g1  = ((c->c9808 * vel) - (c->c9808 * g1)) + g1;                /* :1532 */
    if (g1 <= 0.0f) g1 = 0.0f;                                      /* :1533 */
    st->g1 = g1;

    /* ------------------------------------------- mute smoother :1539-1549 */
    g2  = st->g2;
    g2  = ((c->c9888 * c->c9824) - (c->c9888 * g2)) + g2;           /* :1543 */
    if (g2 <= 0.0f) g2 = 0.0f;                                      /* :1544 */
    st->g2 = g2;

    /* ----------------------------------------------- gate ramp :1550-1567
     * `gate` is [560] and is 0.0, 1.0 or 2.0 (src/voice_render.c:691). */
    gy     = st->gate_y;
    galt   = gy + c->c9984;                                         /* :1554 */
    gclamp = gy * c->c10000;                                        /* :1553 */
    if (gclamp >= -1.0f) gclamp = fminf(gclamp, 1.0f);              /* :1555 */
    else                 gclamp = -1.0f;
    if ((gy + c->c9952) >= 0.0f)                                    /* :1559 */
        galt = ((c->c9968 * gate) - (c->c9968 * gy)) + gy;          /* :1560 */
    grate = ((gclamp * c->c10016) - (c->c10032 * gclamp)) + c->c10032;
    gnext = ((grate * gate) - (grate * gy)) + gy;                   /* :1563 */
    if (gate != 0.0f) gnext = galt;                                 /* :1564 */
    st->gate_y = gnext;                       /* [9904] and [9936] :1566-7 */

    /* ------------------------------------- HPF / boost network :1577-1599
     * [10096] is a plain 1-pole low pass over the VCF output; the high-passed
     * "boost" signal is built from the PREVIOUS pole value and the new one. */
    lp_prev = st->lp;
    hp_in   = vcf - lp_prev;                                        /* :1580 */
    lp      = lp_prev + ((vcf - lp_prev) * c->c10240);              /* :1583 */
    st->lp  = lp;
    boost   = (hp_in * c->c10352) + (lp * c->c10368);               /* :1585 */

    /* --------------------------------------- VCA source combine :1582-1598 */
    env = (env1 * c->c10192) + (c->c10176 * gnext);                 /* :1582 */
    env = env + (c->c10208 * env2);                                 /* :1587 */
    env = ((c->c10224 * c->c9552) - (c->c10224 * env)) + env;       /* :1586-8 */
    lvl = env * c->c10304;                                          /* :1590 */
    if (lvl <= 0.0f) lvl = 0.0f;                                    /* :1592 */
    lvl = lvl * c->c10320;                                          /* :1598 */

    /* The ONE place in this range where the (1-t) complement IS formed, and
     * the resonance-compensation gain (1 + [6848]*[10336]).  :1591,:1599 */
    y  = (vcf + (c->c10256 * (boost - vcf)))
       * ((rescomp * c->c10336) + 1.0f);   /* PLANTED: undistributed lerp */

    y2 = st->lp2;
    y2 = y2 + ((c->c10384 * y) - (c->c10384 * y2));                 /* :1601-2 */
    st->lp2 = y2;

    out = (((c->c10272 * y2) + (c->c10288 * y)) * lvl) * c->c10400; /* :1604 */

    /* ------------------------------------------- DC blocker :1606-1613
     * Three port cells, one recurrence: [10416] and [10448] are re-derived and
     * :1607's store into [10432] is dead. */
    dcacc = st->dcacc;
    x     = out - dcacc;                                            /* :1610 */
    st->dcacc = (c->c10464 * x) + dcacc;                            /* :1612 */

    /* -------------------------------------- amp TONE crossfade :1614-1637
     * TWO RECURSIVE 1-pole/1-zero filters. The third tap is the filter's own
     * previous output — a 3-tap FIR built from the coefficient list will not
     * null (docs/trackb/CELLMAP.md). */
    tone = c->c9584;
    tA = ((st->x1 * c->c10576) + (x * c->c10560)) + (c->c10592 * st->yA);
    tB = ((st->x1 * c->c10624) + (x * c->c10608)) + (c->c10640 * st->yB);
    st->x1 = x;
    st->yA = tA;
    st->yB = tB;

    w = tone;
    if (w <= 0.0f) w = 0.0f;                                        /* :1623 */
    mix = ((w * tA) - (w * x)) + x;                                 /* :1630 */
    if (!(tone >= 0.0f)) {                                          /* :1635 */
        /* the port's v19 is 0.0 unless tone < -0.0 (:633, :1631), so a NaN
         * tone takes this arm with a weight of exactly 0.0 and passes x. */
        w = (tone < -0.0f) ? -tone : 0.0f;
        mix = x + ((w * tB) - (w * x));                             /* :1634 */
    }

    /* ------------------------------------------- final gains :1638-1640
     * No clamp, no saturation: |result| may exceed 1.0. */
    return (mix * g1) * g2;
}

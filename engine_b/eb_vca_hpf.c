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
#ifndef EB_ZEROCOEF
#define EB_ZEROCOEF 0
#endif
#include <math.h>

void eb_vca_reset(eb_vca_state *st)
{
    st->sm = st->g1 = st->g2 = st->gate_y = 0.0f;
    st->lp = st->lp2 = st->dcacc = 0.0f;
    st->x1 = st->yA = st->yB = 0.0f;
}

/* THE CONTROL HALF -- reads the envelopes, the gate and its own state; never
 * `vcf`. Verbatim statements from eb_vca_tick, in their original order. */
void eb_vca_control(eb_vca_state *st, const eb_vca_coef *c,
                    float env1, float env2, float gate, eb_vca_ctl *o)
{
    float sm, vel, g1, g2;
    float gy, gnext, galt, gclamp, grate;
    float env, lvl;

    sm  = st->sm;
    sm  = ((c->c9680 - sm) * c->c9744) + sm;                        /* :1525 */
    st->sm = sm;
    vel = ((sm * c->c9600) - (c->c9600 * c->c9616)) + c->c9616;     /* :1527 */

    g1  = st->g1;
    g1  = ((c->c9808 * vel) - (c->c9808 * g1)) + g1;                /* :1532 */
    if (g1 <= 0.0f) g1 = 0.0f;                                      /* :1533 */
    st->g1 = g1;

    g2  = st->g2;
    g2  = ((c->c9888 * c->c9824) - (c->c9888 * g2)) + g2;           /* :1543 */
    if (g2 <= 0.0f) g2 = 0.0f;                                      /* :1544 */
    st->g2 = g2;

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

    env = (env1 * c->c10192) + (c->c10176 * gnext);                 /* :1582 */
    env = env + (c->c10208 * env2);                                 /* :1587 */
#if EB_ZEROCOEF
    /* c10224 is zero, so this whole line is env = env. c9552 goes with it. */
#else
    env = ((c->c10224 * c->c9552) - (c->c10224 * env)) + env;       /* :1586-8 */
#endif
    lvl = env * c->c10304;                                          /* :1590 */
    if (lvl <= 0.0f) lvl = 0.0f;                                    /* :1592 */
    lvl = lvl * c->c10320;                                          /* :1598 */

    o->g1 = g1; o->g2 = g2; o->lvl = lvl;
}

/* THE AUDIO HALF -- everything that reads `vcf`. */
float eb_vca_audio(eb_vca_state *st, const eb_vca_coef *c,
                   float vcf, float rescomp, const eb_vca_ctl *o)
{
    float lp_prev, lp, boost, hp_in;
    float y, y2, out;
    float dcacc, x, tone, tA, tB, mix, w;

    lp_prev = st->lp;
    hp_in   = vcf - lp_prev;                                        /* :1580 */
    lp      = lp_prev + ((vcf - lp_prev) * c->c10240);              /* :1583 */
    st->lp  = lp;
#if EB_ZEROCOEF
    boost   = hp_in * c->c10352;                    /* c10368 == 0 :1585 */
#else
    boost   = (hp_in * c->c10352) + (lp * c->c10368);               /* :1585 */
#endif

    y  = ((c->c10256 * boost) + (vcf * (1.0f - c->c10256)))
       * ((rescomp * c->c10336) + 1.0f);

    y2 = st->lp2;
    y2 = y2 + ((c->c10384 * y) - (c->c10384 * y2));                 /* :1601-2 */
    st->lp2 = y2;

    out = (((c->c10272 * y2) + (c->c10288 * y)) * o->lvl) * c->c10400;

    dcacc = st->dcacc;
    x     = out - dcacc;                                            /* :1610 */
    st->dcacc = (c->c10464 * x) + dcacc;                            /* :1612 */

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
        w = (tone < -0.0f) ? -tone : 0.0f;
        mix = x + ((w * tB) - (w * x));                             /* :1634 */
    }

    return (mix * o->g1) * o->g2;
}

/* The original entry point, now a wrapper. The trunk calls this and is
 * therefore untouched; only a fused caller splits the two halves apart. */
float eb_vca_tick(eb_vca_state *st, const eb_vca_coef *c,
                  float vcf, float env1, float env2, float rescomp,
                  float gate)
{
    eb_vca_ctl o;
    eb_vca_control(st, c, env1, env2, gate, &o);
    return eb_vca_audio(st, c, vcf, rescomp, &o);
}

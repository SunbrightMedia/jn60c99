/* eb_reverb.c -- ENGINE B, MODULE REVERB.
 *
 * The arithmetic is the plugin's, in the plugin's order. See eb_reverb.h for
 * what is and is not simplified, and docs/engineb/FX_REVERB.md for how each
 * constant and each structure claim was measured.
 *
 * The element/tap map, taken from the executed reconstruction (tap index k is
 * an entry of the 34-int table the recall writes):
 *
 *   ring   write tap   read tap    role
 *   pd         0           1       pre-delay (the ONLY modulated read)
 *   ap1        2           3       series diffuser 1
 *   ap2        4           5       series diffuser 2
 *   ap3        6           7       series diffuser 3
 *   ap4        8           9       series diffuser 4
 *   la0       10          11       loop A allpass      d0   18   21 (+19 L, 20 R)
 *   la1       12          13       loop B allpass      d1   22   25 (+24 L, 23 R)
 *   la2       14          15       loop C allpass      d2   26   29 (+27 L, 28 R)
 *   la3       16          17       loop D allpass      d3   30   33 (+32 L, 31 R)
 *
 * Each ring is read at its depth BEFORE this sample is written, which is what
 * makes a depth equal to the ring's length legal and is exactly what the masked
 * line does (there the two indices are simply different). The equivalence of
 * this indexing to the plugin's masked line is PROVEN, not argued:
 * tools/engineb/fx_reverb_split_proof.py, 60,000 samples, both rates, both
 * channels, max_abs_err 0.0.
 */
#include "eb_reverb.h"
#include <string.h>

/* the 13 rings, in the order of state->w[] and state->dep[] */
#define EB_REV_NRING 13

static float *eb_rev_ring(eb_reverb_state *s, int k, int32_t *cap)
{
    switch (k) {
    case 0:  *cap = EB_REV_CAP_PD;  return s->pd;
    case 1:  *cap = EB_REV_CAP_AP1; return s->ap1;
    case 2:  *cap = EB_REV_CAP_AP2; return s->ap2;
    case 3:  *cap = EB_REV_CAP_AP3; return s->ap3;
    case 4:  *cap = EB_REV_CAP_AP4; return s->ap4;
    case 5:  *cap = EB_REV_CAP_LA0; return s->la0;
    case 6:  *cap = EB_REV_CAP_LA1; return s->la1;
    case 7:  *cap = EB_REV_CAP_LA2; return s->la2;
    case 8:  *cap = EB_REV_CAP_LA3; return s->la3;
    case 9:  *cap = EB_REV_CAP_D0;  return s->d0;
    case 10: *cap = EB_REV_CAP_D1;  return s->d1;
    case 11: *cap = EB_REV_CAP_D2;  return s->d2;
    default: *cap = EB_REV_CAP_D3;  return s->d3;
    }
}

/* write-tap / read-tap index pairs, in ring order */
static const int8_t EB_REV_KW[EB_REV_NRING] =
    { 0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 22, 26, 30 };
static const int8_t EB_REV_KR[EB_REV_NRING] =
    { 1, 3, 5, 7, 9, 11, 13, 15, 17, 21, 25, 29, 33 };
/* per loop: {write tap, L output tap, R output tap} */
static const int8_t EB_REV_OT[4][3] =
    { { 18, 19, 20 }, { 22, 24, 23 }, { 26, 27, 28 }, { 30, 32, 31 } };

/* Recompute the read depths from the latched tap table, and flag any depth the
 * compile-time capacity cannot serve. The pre-delay is checked against its
 * capacity MINUS the modulation reach, because the modulation only ever makes
 * that read deeper (the sign of the plugin's phase*(+/-2048) product is
 * negative for either sign of the phase -- MEASURED). */
static void eb_rev_derive(eb_reverb_state *s)
{
    int k;
    s->overrun = 0;
    for (k = 0; k < EB_REV_NRING; ++k) {
        int32_t cap;
        (void)eb_rev_ring(s, k, &cap);
        s->dep[k] = s->taps[EB_REV_KR[k]] - s->taps[EB_REV_KW[k]];
        if (k == 0)
            cap -= 416;                 /* the TYPE-5 modulation reach */
        if (s->dep[k] > cap || s->dep[k] < 0)
            s->overrun = 1;
    }
    for (k = 0; k < 4; ++k) {
        s->ot[k][0] = s->taps[EB_REV_OT[k][1]] - s->taps[EB_REV_OT[k][0]];
        s->ot[k][1] = s->taps[EB_REV_OT[k][2]] - s->taps[EB_REV_OT[k][0]];
    }
}

void eb_reverb_init(eb_reverb_state *s)
{
    memset(s, 0, sizeof *s);
    s->wipe = 256;
}

/* the capacity macros again under the ring VARIABLE names, so RD/WR can build
 * the bound from the buffer they are given and cannot be pointed at the wrong
 * one by a copy-paste */
#define EB_REV_CAP_pd  EB_REV_CAP_PD
#define EB_REV_CAP_ap1 EB_REV_CAP_AP1
#define EB_REV_CAP_ap2 EB_REV_CAP_AP2
#define EB_REV_CAP_ap3 EB_REV_CAP_AP3
#define EB_REV_CAP_ap4 EB_REV_CAP_AP4
#define EB_REV_CAP_la0 EB_REV_CAP_LA0
#define EB_REV_CAP_la1 EB_REV_CAP_LA1
#define EB_REV_CAP_la2 EB_REV_CAP_LA2
#define EB_REV_CAP_la3 EB_REV_CAP_LA3
#define EB_REV_CAP_d0  EB_REV_CAP_D0
#define EB_REV_CAP_d1  EB_REV_CAP_D1
#define EB_REV_CAP_d2  EB_REV_CAP_D2
#define EB_REV_CAP_d3  EB_REV_CAP_D3

/* read at depth d, then write v; the index advances by a compare-and-add */
#define RD(buf, k, d)  ((buf)[(s->w[k] - (d) < 0) ? s->w[k] - (d) + EB_REV_CAP_##buf \
                                                 : s->w[k] - (d)])
#define WR(buf, k, v)  do { (buf)[s->w[k]] = (v);                             \
                            if (++s->w[k] == EB_REV_CAP_##buf) s->w[k] = 0; } while (0)

void eb_reverb_process(const eb_reverb_cfg *c, eb_reverb_state *s,
                       const int32_t *pending, int32_t *wipe_arm,
                       float inA, float inB, float *outA, float *outB)
{
    float *pd = s->pd, *ap1 = s->ap1, *ap2 = s->ap2, *ap3 = s->ap3, *ap4 = s->ap4;
    float *la0 = s->la0, *la1 = s->la1, *la2 = s->la2, *la3 = s->la3;
    float *d0 = s->d0, *d1 = s->d1, *d2 = s->d2, *d3 = s->d3;
    float m0 = s->mute, m;

    s->wipe = *wipe_arm;

    /* --- the mute crossfade, exactly the plugin's two arms --- */
    if (s->wipe <= 0) {
        m = m0;
        if (m0 < 1.0f && c->gate > 0.0f) {
            m = m0 + 0.00039999999f;
            s->mute = m;
            if (m > 1.0f) { s->mute = 1.0f; m = 1.0f; }
        }
    } else {
        if (m0 != 0.0f) {
            m0 = m0 - 0.00039999999f;
            s->mute = m0;
            if (m0 < 0.0f) { s->mute = 0.0f; m0 = 0.0f; }
        }
        m = m0;
    }

    if (m <= 0.0f || c->gate <= 0.0f) {
        /* the tank is not running: the send is silent and the dry pair passes */
        *outA = inB;
        *outB = inA;
        if (s->wipe > 0 && m <= 0.0f) {
            /* The plugin wipes one 256-float stripe of its single line per
             * sample. Engine B wipes all thirteen rings at the latch instead --
             * equivalent, because the tank arm above is skipped on every one of
             * these samples, so nothing reads a ring in between. */
            if (--s->wipe <= 0) {
                int k;
                for (k = 0; k < EB_REV_NTAP; ++k)
                    s->taps[k] = pending[k];
                eb_rev_derive(s);
                for (k = 0; k < EB_REV_NRING; ++k) {
                    int32_t cap;
                    float *b = eb_rev_ring(s, k, &cap);
                    memset(b, 0, (size_t)cap * sizeof(float));
                    s->w[k] = 0;
                }
                s->s0 = s->s1 = s->s2 = s->s3 = s->s4 = 0.0f;
                for (k = 0; k < 4; ++k) { s->dlp[k] = 0.0f; s->dhp[k] = 0.0f; }
                s->phase = 0.0f;
            }
        }
        *wipe_arm = s->wipe;
        return;
    }
    *wipe_arm = s->wipe;

    {
        /* --- input: scale by the send, then DC block, then a 2-pole lowpass -- */
        float x = (((inA + inB) * 0.03125f) * c->send) * c->gate * m;
        float v477 = c->f_in[1] * s->s0;
        float v479 = c->f_in[2] * s->s1;
        float v480 = x * c->f_in[0];
        float v481, v482, v483, v484, v485;
        float ph, v487, v488, v506, u, sl, sr, SL, SR;
        int32_t mod;
        s->s0 = x;
        v481 = (v477 + v480) + v479;
        v482 = c->f_in[6] * s->s3;
        v484 = c->f_in[7] * s->s4;
        v483 = ((s->s1 * c->f_in[4]) + (v481 * c->f_in[3])) + (c->f_in[5] * s->s2);
        s->s2 = s->s1;
        s->s1 = v481;
        s->s4 = s->s3;
        v485 = (v483 + v482) + v484;
        s->s3 = v485;

        /* --- the pre-delay modulation saw (dead unless REVERB TYPE 5) --- */
        ph = c->lfo_inc + s->phase;
        if (ph > 1.0f) ph = ph - 2.0f;
        v487 = ph * c->lfo_depth;
        v488 = (ph < 0.0f) ? 2048.0f : -2048.0f;
        s->phase = ph;
        mod = (int32_t)(v487 * v488);

        /* --- pre-delay: read (modulated) before writing --- */
        u = RD(pd, 0, s->dep[0] - mod);
        WR(pd, 0, v485);

        /* --- four series allpasses, one shared coefficient --- */
        {
            float a_, v;
            a_ = RD(ap1, 1, s->dep[1]); v = u - (a_ * c->ap);
            WR(ap1, 1, v); u = (c->ap * v) + a_;
            a_ = RD(ap2, 2, s->dep[2]); v = u - (a_ * c->ap);
            WR(ap2, 2, v); u = (c->ap * v) + a_;
            a_ = RD(ap3, 3, s->dep[3]); v = u - (a_ * c->ap);
            WR(ap3, 3, v); u = (c->ap * v) + a_;
            a_ = RD(ap4, 4, s->dep[4]); v = u - (a_ * c->ap);
            WR(ap4, 4, v); u = (c->ap * v) + a_;
        }
        v506 = u * 0.5f;

        /* --- four parallel damped loops. Written out rather than looped: the
         * four rings are four differently-sized objects and a loop over them
         * costs an indirection per access on the target. --- */
#define EB_REV_LOOP(LA, LK, D, DK, I)                                          \
        do {                                                                   \
            float vr = RD(LA, LK, s->dep[LK]);                                 \
            float vo = (v506 - (vr * c->ap)) + s->dhp[I];                      \
            float e, nlp;                                                      \
            WR(LA, LK, vo);                                                    \
            e = RD(D, DK, s->dep[DK]) - s->dlp[I];                             \
            sl += RD(D, DK, s->ot[I][0]);                                      \
            sr += RD(D, DK, s->ot[I][1]);                                      \
            WR(D, DK, (vo * c->ap) + vr);                                      \
            nlp = (e * c->damp[I][0]) + s->dlp[I];                             \
            s->dlp[I] = nlp;                                                   \
            s->dhp[I] = (nlp * c->damp[I][2]) + (c->damp[I][1] * e);           \
        } while (0)

        /* The stereo sums are NOT in loop order: the plugin adds
         *   L = ((B + A) + C) + D   and   R = ((A + B) + C) + D
         * and float addition is not associative, so the order is load-bearing.
         * Loop A is therefore accumulated into a scalar first and loop B is
         * added on the correct side of it. */
        {
            float aL, aR, bL, bR;
            sl = 0.0f; sr = 0.0f;
            EB_REV_LOOP(la0, 5, d0, 9, 0);
            aL = sl; aR = sr;
            sl = 0.0f; sr = 0.0f;
            EB_REV_LOOP(la1, 6, d1, 10, 1);
            bL = sl; bR = sr;
            sl = bL + aL;               /* L: B + A */
            sr = aR + bR;               /* R: A + B */
            EB_REV_LOOP(la2, 7, d2, 11, 2);
            EB_REV_LOOP(la3, 8, d3, 12, 3);
            SL = sl; SR = sr;
        }
#undef EB_REV_LOOP

        *outA = ((((SL * c->wet) * 16.0f) * m) * c->gate) + (c->dry * inB);
        *outB = ((((SR * c->wet) * 16.0f) * m) * c->gate) + (c->dry * inA);
    }
}

/* Seed the module from an already-running host's cells (the null harness's
 * shim). `taps` is the host's WORKING (already latched) table. */
void eb_reverb_seed(eb_reverb_state *s, const int32_t *taps, float mute,
                    int32_t wipe)
{
    int k;
    memset(s, 0, sizeof *s);
    for (k = 0; k < EB_REV_NTAP; ++k) s->taps[k] = taps[k];
    s->mute = mute;
    s->wipe = wipe;
    eb_rev_derive(s);
}

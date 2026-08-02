/* fx_reverb_cand.c -- CANDIDATE cheap formulation of the JUNO-60 reverb tank for
 * a Cortex-class single-precision FPU with no SIMD, written to be COSTED by
 * tools/engineb/cost.py. It is not (yet) the engine B module; it exists so the
 * cycle and memory claims in docs/engineb/FX_REVERB.md are measured on real code.
 *
 * Structure and coefficients are the ones MEASURED from the sealed port
 * (docs/engineb/FX_REVERB.md): DC block -> 2-pole lowpass -> pre-delay ->
 * 4 series allpasses -> 4 parallel damped loops, each an allpass inside a delay
 * with a one-pole damper, tapped twice for stereo.
 *
 * The one structural change from the plugin is memory: the plugin uses ONE
 * 65,536-float line addressed by a 16-bit mask (262,144 B). Here each element
 * owns its own circular buffer, which is the same DSP with 45,566 floats
 * (182,264 B) at 48 kHz and lets the four long loop delays -- and only those --
 * be placed in PSRAM.
 */
#include <string.h>

/* 48 kHz, REVERB TYPE 2..5, PRE DELAY default. MEASURED tap set. */
#define L_PD   958
#define L_A1   1911
#define L_A2   1517
#define L_A3    907
#define L_A4    361
#define L_LA0  1347
#define L_LA1  1341
#define L_LA2  1351
#define L_LA3  1347
#define L_D0   7165
#define L_D1   7615
#define L_D2   9755
#define L_D3   9991
#define T0A    4189    /* stereo output taps, as delays into each loop delay */
#define T0B    7045
#define T1A    3949
#define T1B    7377
#define T2A    3451
#define T2B    8209
#define T3A    3689
#define T3B    8447

typedef struct {
    /* internal SRAM: 22,586 floats = 90,344 B */
    float pd[L_PD], a1[L_A1], a2[L_A2], a3[L_A3], a4[L_A4];
    float la[4][L_LA2];
    /* PSRAM candidate: 34,526 floats = 138,104 B */
    float d0[L_D0], d1[L_D1], d2[L_D2], d3[L_D3];
    int wpd, wa1, wa2, wa3, wa4, wla[4], wd[4];
    float x1, y1, z1, z2, w1, w2;      /* input filter state */
    float dlp[4], dhp[4];              /* damper state */
    float ap, fc[4], hpc[4], lpc[4];   /* coefficients */
    float b0, b1, a1c, c0, c1, c2, p1, p2, wet;
} eb_rev;

/* One circular tap: read the sample `n` steps back, write `v` at the head.
 * Both index updates are a compare-and-add, never a modulo. */
#define AP(buf, w, len, in, out) do {                                   \
        float _o = (buf)[w];                                            \
        float _v = (in) - r->ap * _o;                                   \
        (buf)[w] = _v;                                                  \
        (out) = r->ap * _v + _o;                                        \
        if (++(w) == (len)) (w) = 0;                                    \
    } while (0)

void eb_reverb_block(eb_rev *r, const float *in, float *outL, float *outR, int n)
{
    int i, k;
    for (i = 0; i < n; ++i) {
        float x, y, z, u, v, sl, sr;
        /* ---- input: DC block then a 2-pole lowpass (5 mul, 4 add) ---- */
        x = in[i];
        y = r->b0 * x + r->b1 * r->x1 + r->a1c * r->y1;
        r->x1 = x;
        z = r->c0 * y + r->c1 * r->y1 + r->c2 * r->z2 + r->p1 * r->w1 + r->p2 * r->w2;
        r->z2 = r->y1; r->y1 = y; r->w2 = r->w1; r->w1 = z;

        /* ---- pre-delay (1 load, 1 store) ---- */
        u = r->pd[r->wpd]; r->pd[r->wpd] = z;
        if (++r->wpd == L_PD) r->wpd = 0;

        /* ---- 4 series allpasses (8 mul, 8 add, 4 ld, 4 st) ---- */
        AP(r->a1, r->wa1, L_A1, u, v);
        AP(r->a2, r->wa2, L_A2, v, u);
        AP(r->a3, r->wa3, L_A3, u, v);
        AP(r->a4, r->wa4, L_A4, v, u);
        u *= 0.5f;

        /* ---- 4 parallel damped loops ---- */
        sl = 0.0f; sr = 0.0f;
        for (k = 0; k < 4; ++k) {
            static const int DL[4] = { L_D0, L_D1, L_D2, L_D3 };
            static const int TA[4] = { T0A, T1A, T2A, T3A };
            static const int TB[4] = { T0B, T1B, T2B, T3B };
            float *d = k == 0 ? r->d0 : k == 1 ? r->d1 : k == 2 ? r->d2 : r->d3;
            int len = DL[k], w = r->wd[k];
            float o, e, lp, ap_out;
            int ia, ib;
            /* loop allpass, fed by the diffused input plus this loop's damper out */
            o = r->la[k][r->wla[k]];
            ap_out = (u + r->dhp[k]) - r->ap * o;
            r->la[k][r->wla[k]] = ap_out;
            if (++r->wla[k] == L_LA2) r->wla[k] = 0;
            ap_out = r->ap * ap_out + o;
            /* long delay: write the allpass output, read the loop return */
            e = d[w] - r->dlp[k];
            d[w] = ap_out;
            lp = r->fc[k] * e + r->dlp[k];
            r->dlp[k] = lp;
            r->dhp[k] = r->lpc[k] * lp + r->hpc[k] * e;
            /* two stereo taps out of the same line */
            ia = w - TA[k]; if (ia < 0) ia += len;
            ib = w - TB[k]; if (ib < 0) ib += len;
            sl += d[ia];
            sr += d[ib];
            if (++w == len) w = 0;
            r->wd[k] = w;
        }
        outL[i] = sl * r->wet;
        outR[i] = sr * r->wet;
    }
}

/* eb_delay_cheap.c -- Engine B candidate DELAY (TYPE 0), 48 kHz only.
 * Derived from the MEASURED spec in docs/engineb/FX_DELAY.md.
 * Simplifications, each justified by a measurement:
 *   - mixA (cell 102448) is 0.0 at every rate except 44100 -> the DF-I biquad
 *     branch of the high-cut is dead at 48 kHz; only the 2-pole SVF runs.
 *   - k624 (102624) and k688 (102688) are 1.0 in every measured state.
 *   - mixB (102496), on (102576), mute (102592) take only 0.0/1.0 -> branches.
 */
#include <stdint.h>
#include <math.h>

#ifndef EB_DLY_LEN            /* COMPILE-TIME budget; power of two */
#define EB_DLY_LEN 65536      /* 65536 >= 38400 = 800 ms @48k manual max */
#endif

typedef struct {
    float svf_g, svf_r;       /* 102464, 102480  HIGH CUT (SVF)   */
    float dry, wet, fb;       /* 102512, 102528, 102560           */
    float lp_g, lf_damp;      /* 102608, 102640  LF DAMP FREQ/AMT */
    float hp_g, hf_damp;      /* 102656, 102672  HF DAMP FREQ/AMT */
    float dc_g;               /* 102704  rate constant            */
    float slew;               /* 102784  rate constant            */
    float time_target;        /* 102352                           */
    unsigned char bypass_hc;  /* mixB == 0                        */
    unsigned char on, mute;   /* 102576, 102592                   */
} eb_dly_cfg;

typedef struct {
    float s1[2], s2[2];             /* input SVF        (101792/101808)   */
    float lp[2], hp[2], dc[2];      /* loop filter      (101840/101856/101888) */
    float fbtap[2];                 /* loop output      (101872)          */
    float t_prev, t_step, t_smooth; /* 102256, 102224, 102240             */
    float t_last;                   /* 102208                             */
    float fade, fade_z;             /* 102288, 102304                     */
    int32_t w[2];
    float ring[2][EB_DLY_LEN];
} eb_dly_state;

void eb_delay_process(const eb_dly_cfg *c, eb_dly_state *s,
                      const float in[2], float out[2])
{
    float tt = c->time_target, prev = s->t_prev, d, lo, hi, sm, frac;
    int i, di;
    /* --- delay-time slew: constant-time glide, |target-prev| * slew --- */
    if (tt != s->t_last) s->t_step = tt - prev;
    s->t_last = tt;
    d  = fabsf(s->t_step) * c->slew;
    hi = prev + d; lo = prev - d;
    sm = (tt - prev > 0.0f) ? (hi < tt ? hi : tt) : (lo > tt ? lo : tt);
    s->t_prev = s->t_smooth; s->t_smooth = sm;
    /* --- mute fade: +/- 1/128 per sample, clamped to [0,1] --- */
    s->fade_z = s->fade;
    { float f = s->fade_z + ((1.0f/16384.0f + s->fade_z) >= prev ? 0.0078125f : -0.0078125f);
      f = f < 0.0f ? 0.0f : (f > 1.0f ? 1.0f : f);
      s->fade = c->mute ? f : 0.0f; }
    di = (int)(sm * 16384.0f); frac = sm * 16384.0f - (float)di;

    for (i = 0; i < 2; ++i) {
        float x = in[i], w, u, tap, y, d1, e, d2, f2, g;
        int32_t rd = (s->w[i] + di + 1) & (EB_DLY_LEN - 1);
        /* --- HIGH CUT: 2-pole state-variable --- */
        { float t = x - c->svf_r * s->s1[i];
          float v = (t - s->s2[i]) * c->svf_g;
          u = c->svf_g * s->s1[i] + s->s2[i];
          s->s1[i] += v; s->s2[i] = u; }
        w = c->bypass_hc ? x : u;
        /* --- read + linear interpolation + mute fade --- */
        tap = s->ring[i][rd];
        y   = (tap + frac * (s->ring[i][(rd + 1) & (EB_DLY_LEN - 1)] - tap)) * s->fade_z;
        /* --- loop damping: LF shelf, HF shelf, DC block --- */
        d1 = y - s->lp[i];  s->lp[i] += c->lp_g * d1;
        e  = d1 - c->lf_damp * s->lp[i];
        d2 = e - s->hp[i];  s->hp[i] += c->hp_g * d2;
        f2 = s->hp[i] - c->hf_damp * d2;
        g  = f2 - s->dc[i]; s->dc[i] += c->dc_g * g;
        /* --- write --- */
        s->w[i] = (s->w[i] - 1) & (EB_DLY_LEN - 1);
        s->ring[i][s->w[i]] = c->mute ? (c->on ? w : 0.0f) + g * c->fb : 0.0f;
        s->fbtap[i] = g;
        out[i] = (c->on ? c->dry * x : x) + y * c->wet;
    }
}

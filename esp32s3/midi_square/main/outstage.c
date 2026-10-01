#include "outstage.h"
#include <math.h>

void outstage_init(outstage_t *o, float sr)
{
    o->env = 0.0f;
    o->rel = expf(-1.0f / (0.100f * sr));          /* 100 ms release: no pumping inside a note */
    o->vol_now = 0.0f;
}

float outstage_vol_law(float v)
{
    return v <= 0.01f ? 0.0f : powf(10.0f, -48.0f * (1.0f - v) / 20.0f);
}

/* Soft knee: below KNEE untouched; above it the level is pressed into
 * KNEE..CEIL-0.5 by tanh. The 0.5 is NOT optional: in float, tanhf saturates
 * to exactly 1.0, the curve then lands ON the ceiling and x * (CEIL/env)
 * rounds a hair over it (the gate saw the safety clip catch 90 samples). */
static inline float limit_level(float e)
{
    if (e <= OUT_KNEE) return e;
    const float w = OUT_CEIL - 0.5f - OUT_KNEE;
    return OUT_KNEE + w * tanhf((e - OUT_KNEE) / w);
}

void outstage_block(outstage_t *o, const int16_t *synth, const int16_t *clip, int n,
                    float vol_to, int16_t *out, outstage_stats *st)
{
    float v = o->vol_now, dv = (vol_to - o->vol_now) / (float)n, env = o->env;
    for (int i = 0; i < n; ++i) {
        v += dv;
        float x[2];
        for (int c = 0; c < 2; ++c) {
            float s = synth[2 * i + c] * OUT_G_SYNTH;
            if (clip) s += clip[2 * i + c] * OUT_G_CLIP;
            x[c] = s * v;
        }
        float a = fabsf(x[0]) > fabsf(x[1]) ? fabsf(x[0]) : fabsf(x[1]);   /* stereo-linked */
        env = a > env ? a : env * o->rel;
#ifndef MSQ_TOOTH_NO_LIMIT
        float g = env > OUT_KNEE ? limit_level(env) / env : 1.0f;
#else
        float g = 1.0f;                                                      /* TOOTH: no limiter */
#endif
        if (g < st->min_gain) st->min_gain = g;
        for (int c = 0; c < 2; ++c) {
            float y = x[c] * g;
            if (y > OUT_CEIL || y < -OUT_CEIL) {                             /* safety: never expected */
                st->hard++;
#ifndef MSQ_TOOTH_NO_LIMIT
                y = y > 0 ? OUT_CEIL : -OUT_CEIL;
#endif
            }
            int q = (int)(y >= 0 ? y + 0.5f : y - 0.5f);
            if (q > 32767) q = 32767;
            if (q < -32768) q = -32768;
            out[2 * i + c] = (int16_t)q;
            int aq = q < 0 ? -q : q;
            if (aq > st->peak) st->peak = aq;
        }
    }
    o->vol_now = vol_to;
    o->env = env;
}

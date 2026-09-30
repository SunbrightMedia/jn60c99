/* FROZEN REFERENCE: the v6 voice renderer (commit of the first 6-voice image),
 * copied verbatim and renamed. test/render_equiv.c grades the shipped
 * renderer against it BIT FOR BIT. Never edit this file to make a test pass. */
#include "msq_core.h"
#include <math.h>
#define SINE_N 1024
static float sine_tab[SINE_N + 1];
void ref_init(void) { for (int i = 0; i <= SINE_N; ++i) sine_tab[i] = sinf(6.28318530718f * i / SINE_N); }

/* polyBLEP residual for a unit step at phase 0, t in [0,1), dt = phase increment */
static inline float blep(float t, float dt)
{
    if (t < dt)       { t /= dt;               return t + t - t * t - 1.0f; }
    if (t > 1.0f - dt){ t = (t - 1.0f) / dt;  return t * t + t + t + 1.0f; }
    return 0.0f;
}

/* All four shapes share the phase of their fundamental (+sin(2 pi t)), so a
 * morph never cancels the fundamental: triangle peaks at t=0.25, the saw falls
 * (its fundamental is +sin), the square is +1 on the first half. */
static inline float wave_at(int k, float t, float dt)
{
    switch (k) {
    case 0: {                                             /* sine */
        float x = t * SINE_N; int i = (int)x; float f = x - i;
        return sine_tab[i] + (sine_tab[i + 1] - sine_tab[i]) * f;
    }
    case 1: {                                             /* triangle */
        float u = t + 0.25f; if (u >= 1.0f) u -= 1.0f;
        return 1.0f - 4.0f * fabsf(u - 0.5f);
    }
    case 2: return 1.0f - 2.0f * t + blep(t, dt);         /* falling saw */
    default: {                                            /* square */
        float t2 = t + 0.5f; if (t2 >= 1.0f) t2 -= 1.0f;
        return (t < 0.5f ? 1.0f : -1.0f) + blep(t, dt) - blep(t2, dt);
    }
    }
}

/* Unison layout, centre-out: offsets in units of (outer detune / 3). */
static const float uni_off[MSQ_UNI] = { 0.0f, -1.0f, 1.0f, -2.0f, 2.0f, -3.0f, 3.0f };

void ref_render_voices(msq_t *m, int v0, int v1, float *out, int n)
{
    float att = m->att_step, rel = m->rel_step;
    float w = m->wave, u = m->unison;
    int   k0 = (int)w; if (k0 > 2) k0 = 2;
    float fw = w - (float)k0;                             /* morph k0 -> k0+1 */
    int   nv = msq_unison_voices(u);
    float cents = msq_unison_cents(u);
    float ratio[MSQ_UNI], gt[MSQ_UNI], gstep = 1.0f / (0.010f * m->sr);   /* 10 ms gain ramps */
    float norm = 1.0f / sqrtf((float)nv);
    for (int o = 0; o < MSQ_UNI; ++o) {
        float c = uni_off[o] * cents / 3.0f;
        ratio[o] = (o == 0 || c == 0.0f) ? 1.0f : powf(2.0f, c / 1200.0f);
        gt[o] = o < nv ? norm : 0.0f;
    }
    for (int i = 0; i < n; ++i) out[i] = 0.0f;
    float acc[64];
    for (int k = v0; k < v1; ++k) {
        msq_voice *v = &m->v[k];
        int gate = v->gate;
        if (!gate && v->level == 0.0f) continue;          /* idle voice: no cost */
        uint32_t inc = v->inc;
        for (int base = 0; base < n; base += 64) {
            int len = n - base > 64 ? 64 : n - base;
            for (int i = 0; i < len; ++i) acc[i] = 0.0f;
            for (int o = 0; o < MSQ_UNI; ++o) {           /* oscillator-major: one shape pair per block */
                float g = v->ugain[o];
                uint32_t oinc = ratio[o] == 1.0f ? inc : (uint32_t)((double)inc * (double)ratio[o]);
                if (g == 0.0f && gt[o] == 0.0f) { v->uph[o] += oinc * (uint32_t)len; continue; }
                float dt = (float)(oinc >> 8) * (1.0f / 16777216.0f);
                uint32_t ph = v->uph[o];
                for (int i = 0; i < len; ++i) {
                    if (g != gt[o]) {
                        g += (gt[o] > g) ? gstep : -gstep;
                        if (fabsf(g - gt[o]) < gstep) g = gt[o];
                    }
                    ph += oinc;
                    float t = (float)(ph >> 8) * (1.0f / 16777216.0f);
                    float s = wave_at(k0, t, dt);
                    if (fw > 0.0f) s += (wave_at(k0 + 1, t, dt) - s) * fw;
                    acc[i] += g * s;
                }
                v->uph[o] = ph; v->ugain[o] = g;
            }
            float lv = v->level;
            for (int i = 0; i < len; ++i) {
                if (gate) { lv += att; if (lv > 1.0f) lv = 1.0f; }
                else      { lv -= rel; if (lv < 0.0f) lv = 0.0f; }
                out[base + i] += acc[i] * m->amp * lv;    /* level 0 -> exactly 0 */
            }
            v->level = lv;
        }
    }
}


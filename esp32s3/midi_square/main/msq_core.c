#include "msq_core.h"
#include <math.h>
#include <string.h>

float msq_note_hz(int note)
{
    return 440.0f * powf(2.0f, (float)(note - 69) / 12.0f);
}

void msq_set_release(msq_t *m, float seconds)
{
#ifndef MSQ_TOOTH_FIXED_RELEASE
    if (seconds < 0.001f) seconds = 0.001f;
    m->release_s = seconds;
    m->rel_step  = 1.0f / (seconds * m->sr);
#else
    (void)seconds;                        /* TOOTH: the knob does nothing */
    m->release_s = 0.010f;
    m->rel_step  = 1.0f / (0.010f * m->sr);
#endif
}

float msq_knob_to_release(float x)
{
    if (x < 0.0f) x = 0.0f;
    if (x > 1.0f) x = 1.0f;
    return 0.010f * powf(200.0f, x);
}

void msq_set_attack(msq_t *m, float seconds)
{
#ifdef MSQ_TOOTH_FIXED_ATTACK
    seconds = 0.002f;                     /* TOOTH: the attack knob does nothing */
#endif
    if (seconds < 0.001f) seconds = 0.001f;
    m->attack_s = seconds;
    m->att_step = 1.0f / (seconds * m->sr);
}

float msq_knob_to_attack(float x)
{
    if (x < 0.0f) x = 0.0f;
    if (x > 1.0f) x = 1.0f;
    return 0.001f * powf(2000.0f, x);
}

void msq_set_wave(msq_t *m, float w)
{
    m->wave = w < 0.0f ? 0.0f : (w > 3.0f ? 3.0f : w);
}

void msq_set_unison(msq_t *m, float u)
{
    m->unison = u < 0.0f ? 0.0f : (u > 1.0f ? 1.0f : u);
}

int msq_unison_voices(float u)
{
    int n = 1 + (int)(u * 6.999f);
    return n < 1 ? 1 : (n > MSQ_UNI ? MSQ_UNI : n);
}

float msq_unison_cents(float u)
{
    return 25.0f * u;                     /* outermost pair at +-25 cents */
}

#define SINE_N 1024
static float sine_tab[SINE_N + 1];

void msq_init(msq_t *m, float sr)
{
    memset(m, 0, sizeof *m);
    m->sr       = sr;
    msq_set_attack(m, 0.002f);            /* 2 ms attack  */
    msq_set_release(m, 0.010f);           /* 10 ms release until the knob speaks */
    m->amp      = 8192.0f;                /* -12 dBFS */
    m->wave     = 3.0f;                   /* square, the v1-v4 sound */
    m->unison   = 0.0f;
    m->ugain[0] = 1.0f;
    for (int i = 0; i < MSQ_UNI; ++i) m->uph[i] = (uint32_t)i * 0x2545F491u;
    m->uph[0] = 0;
    m->last_note = -1;
    if (sine_tab[SINE_N / 4] == 0.0f)
        for (int i = 0; i <= SINE_N; ++i) sine_tab[i] = sinf(6.28318530718f * i / SINE_N);
}

static void publish(msq_t *m)
{
    if (m->nheld > 0) {
        double hz = (double)msq_note_hz(m->held[m->nheld - 1]);
        m->inc  = (uint32_t)(hz / (double)m->sr * 4294967296.0);
        m->gate = 1;
    } else {
        m->gate = 0;                     /* inc kept: the release keeps its pitch */
    }
}

static void key_remove(msq_t *m, uint8_t note)
{
    int i, j;
    for (i = 0; i < m->nheld; ++i)
        if (m->held[i] == note) {
            for (j = i; j < m->nheld - 1; ++j) m->held[j] = m->held[j + 1];
            --m->nheld;
            return;
        }
}

static void note_on(msq_t *m, uint8_t note, uint8_t vel)
{
    key_remove(m, note);
    if (m->nheld == MSQ_MAX_HELD) {      /* full: drop the oldest */
        memmove(m->held, m->held + 1, MSQ_MAX_HELD - 1);
        --m->nheld;
    }
    m->held[m->nheld++] = note;
    m->n_on++; m->last_note = note; m->last_vel = vel; m->last_event = 1;
    publish(m);
}

static void note_off(msq_t *m, uint8_t note)
{
    key_remove(m, note);
    m->n_off++; m->last_note = note; m->last_vel = 0; m->last_event = 2;
    publish(m);
}

int msq_byte(msq_t *m, uint8_t b)
{
    m->n_bytes++;
    if (b >= 0xF8) { m->n_rt++; return 0; }          /* real-time: invisible */
    if (b >= 0xF0) { m->status = 0; m->have = 0; return 0; } /* sysex/common: kills running status */
    if (b & 0x80)  { m->status = b; m->have = 0; return 0; }
    if (!m->status) return 0;                        /* stray data (sysex body) */

    uint8_t hi = m->status & 0xF0;
    if (hi == 0xC0 || hi == 0xD0) { m->n_other++; return 0; } /* one data byte */
    if (!m->have) { m->d1 = b; m->have = 1; return 0; }
    m->have = 0;                                     /* running status stays armed */
#ifdef MSQ_TOOTH_NO_RUNNING_STATUS
    m->status = 0;                                   /* TOOTH: forget the status */
#endif
    if (hi == 0x90 && b > 0) { note_on(m, m->d1, b); return 1; }
    if (hi == 0x90 || hi == 0x80) { note_off(m, m->d1); return 1; }
    if (hi == 0xB0) {
        m->n_cc++;
        if (m->d1 == 120 || m->d1 == 123) {          /* all sound / all notes off */
            m->nheld = 0; m->last_event = 3; publish(m);
            return 1;
        }
        return 0;
    }
    m->n_other++;
    return 0;
}

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

void msq_render_f(msq_t *m, float *out, int n)
{
    uint32_t inc = m->inc;
    int gate = m->gate;
    float att = m->att_step, rel = m->rel_step;
    float w = m->wave, u = m->unison;
    int   k0 = (int)w; if (k0 > 2) k0 = 2;
    float fw = w - (float)k0;                             /* morph k0 -> k0+1 */
    int   nv = msq_unison_voices(u);
    float cents = msq_unison_cents(u);
    uint32_t vinc[MSQ_UNI];
    float gt[MSQ_UNI], gstep = 1.0f / (0.010f * m->sr);   /* 10 ms gain ramps */
    float norm = 1.0f / sqrtf((float)nv);
    for (int v = 0; v < MSQ_UNI; ++v) {
        float c = uni_off[v] * cents / 3.0f;
        vinc[v] = (v == 0 || c == 0.0f) ? inc
                : (uint32_t)((double)inc * (double)powf(2.0f, c / 1200.0f));
        gt[v] = v < nv ? norm : 0.0f;
    }
    for (int i = 0; i < n; ++i) {
        if (gate) { m->level += att; if (m->level > 1.0f) m->level = 1.0f; }
        else      { m->level -= rel; if (m->level < 0.0f) m->level = 0.0f; }
        float acc = 0.0f;
        for (int v = 0; v < MSQ_UNI; ++v) {
            float g = m->ugain[v];
            if (g != gt[v]) {
                g += (gt[v] > g) ? gstep : -gstep;
                if ((gstep > 0) && fabsf(g - gt[v]) < gstep) g = gt[v];
                m->ugain[v] = g;
            }
            m->uph[v] += vinc[v];
            if (g == 0.0f) continue;
            float t  = (float)(m->uph[v] >> 8) * (1.0f / 16777216.0f);
            float dt = (float)(vinc[v] >> 8) * (1.0f / 16777216.0f);
            float s  = wave_at(k0, t, dt);
            if (fw > 0.0f) s += (wave_at(k0 + 1, t, dt) - s) * fw;
            acc += g * s;
        }
        out[i] = acc * m->amp * m->level;                 /* level 0 -> exactly 0 */
    }
}

void msq_render(msq_t *m, int16_t *lr, int n)
{
    float buf[64];
    while (n > 0) {
        int k = n > 64 ? 64 : n;
        msq_render_f(m, buf, k);
        for (int i = 0; i < k; ++i) {
            float x = buf[i];
            int v = (int)(x >= 0.0f ? x + 0.5f : x - 0.5f);
            if (v > 32767) v = 32767;
            if (v < -32768) v = -32768;
            lr[0] = (int16_t)v; lr[1] = (int16_t)v; lr += 2;
        }
        n -= k;
    }
}

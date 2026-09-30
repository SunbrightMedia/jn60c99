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
    m->amp      = 4096.0f;                /* per voice: -18 dBFS, 6 voices fit the FX headroom */
    m->wave     = 3.0f;                   /* square, the v1-v4 sound */
    m->unison   = 0.0f;
    for (int k = 0; k < MSQ_VOICES; ++k) {
        msq_voice *v = &m->v[k];
        v->note = -1;
        v->ugain[0] = 1.0f;
        for (int i = 1; i < MSQ_UNI; ++i) v->uph[i] = (uint32_t)(i + 7 * k) * 0x2545F491u;
    }
    m->last_note = -1;
    if (sine_tab[SINE_N / 4] == 0.0f)
        for (int i = 0; i <= SINE_N; ++i) sine_tab[i] = sinf(6.28318530718f * i / SINE_N);
}

static void count(msq_t *m)
{
    int n = 0;
    for (int k = 0; k < MSQ_VOICES; ++k) n += m->v[k].gate != 0;
    m->nheld = n;
    m->gate = n > 0;
}

static void note_on(msq_t *m, uint8_t note, uint8_t vel)
{
    int pick = -1;
    for (int k = 0; k < MSQ_VOICES && pick < 0; ++k)            /* 1. same key */
        if (m->v[k].note == note) pick = k;
    for (int k = 0; k < MSQ_VOICES && pick < 0; ++k)            /* 2. idle */
        if (!m->v[k].gate && m->v[k].level == 0.0f) pick = k;
    if (pick < 0) {                                              /* 3. quietest releasing */
        float best = 2.0f;
        for (int k = 0; k < MSQ_VOICES; ++k)
            if (!m->v[k].gate && m->v[k].level < best) { best = m->v[k].level; pick = k; }
    }
    if (pick < 0) {                                              /* 4. steal the oldest held */
        uint32_t oldest = 0xFFFFFFFFu;
        for (int k = 0; k < MSQ_VOICES; ++k)
            if (m->v[k].age < oldest) { oldest = m->v[k].age; pick = k; }
    }
#ifdef MSQ_TOOTH_MONO
    pick = 0;                                                    /* TOOTH: one voice only */
#endif
    msq_voice *v = &m->v[pick];
    double hz = (double)msq_note_hz(note);
    v->inc  = (uint32_t)(hz / (double)m->sr * 4294967296.0);
    v->note = note;
    v->age  = ++m->clock;
    v->gate = 1;
    count(m);
    m->n_on++; m->last_note = note; m->last_vel = vel; m->last_event = 1;
}

static void note_off(msq_t *m, uint8_t note)
{
    for (int k = 0; k < MSQ_VOICES; ++k)
        if (m->v[k].note == note && m->v[k].gate) m->v[k].gate = 0;   /* inc kept: the release keeps its pitch */
    count(m);
    m->n_off++; m->last_note = note; m->last_vel = 0; m->last_event = 2;
}

static void all_off(msq_t *m)
{
    for (int k = 0; k < MSQ_VOICES; ++k) m->v[k].gate = 0;
    count(m);
    m->last_event = 3;
}

int msq_voices_sounding(const msq_t *m)
{
    int n = 0;
    for (int k = 0; k < MSQ_VOICES; ++k) n += m->v[k].gate || m->v[k].level > 0.0f;
    return n;
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
            all_off(m);
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
static inline __attribute__((always_inline)) float wave_at(int k, float t, float dt)
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

/* One oscillator over one sub-block. K0 and MORPH are compile-time constants
 * at every call site, so the shape switch and the morph test leave the sample
 * loop. The gain ramp runs only until it lands, then the plain loop takes
 * over. Same arithmetic, same order as the v6 loop: test/render_equiv.c
 * holds it to the frozen v6 copy (test/ref_render.c) BIT FOR BIT. */
static inline __attribute__((always_inline))
void osc_run(const int K0, const int MORPH, float fw, float *acc, int len,
             uint32_t *php, uint32_t oinc, float dt, float *gp, float gt, float gstep)
{
    uint32_t ph = *php;
    float g = *gp;
    int i = 0;
    for (; i < len && g != gt; ++i) {
        g += (gt > g) ? gstep : -gstep;
        if (fabsf(g - gt) < gstep) g = gt;
        ph += oinc;
        float t = (float)(ph >> 8) * (1.0f / 16777216.0f);
        float s = wave_at(K0, t, dt);
        if (MORPH) s += (wave_at(K0 + 1, t, dt) - s) * fw;
        acc[i] += g * s;
    }
    for (; i < len; ++i) {
        ph += oinc;
        float t = (float)(ph >> 8) * (1.0f / 16777216.0f);
        float s = wave_at(K0, t, dt);
        if (MORPH) s += (wave_at(K0 + 1, t, dt) - s) * fw;
        acc[i] += g * s;
    }
    *php = ph;
#ifndef MSQ_TOOTH_RENDER
    *gp = g;                                              /* TOOTH: the ramp restarts every sub-block */
#endif
}

void msq_render_mask(msq_t *m, uint32_t mask, float *out, int n)
{
    float att = m->att_step, rel = m->rel_step;
    float w = m->wave, u = m->unison;
    int   k0 = (int)w; if (k0 > 2) k0 = 2;
    float fw = w - (float)k0;                             /* morph k0 -> k0+1 */
    int   sel = 2 * k0 + (fw > 0.0f);
    int   nv = msq_unison_voices(u);
    float cents = msq_unison_cents(u);
    float ratio[MSQ_UNI], gt[MSQ_UNI], gstep = 1.0f / (0.010f * m->sr);   /* 10 ms gain ramps */
    float norm = 1.0f / sqrtf((float)nv);
    const float amp = m->amp;
    for (int o = 0; o < MSQ_UNI; ++o) {
        float c = uni_off[o] * cents / 3.0f;
        ratio[o] = (o == 0 || c == 0.0f) ? 1.0f : powf(2.0f, c / 1200.0f);
        gt[o] = o < nv ? norm : 0.0f;
    }
    for (int i = 0; i < n; ++i) out[i] = 0.0f;
    float acc[64];
    for (int k = 0; k < MSQ_VOICES; ++k) {
        if (!(mask & (1u << k))) continue;
        msq_voice *v = &m->v[k];
        int gate = v->gate;
        if (!gate && v->level == 0.0f) continue;          /* idle voice: no cost */
        uint32_t inc = v->inc;
        uint32_t oinc[MSQ_UNI];
        float dt[MSQ_UNI];
        for (int o = 0; o < MSQ_UNI; ++o) {
            oinc[o] = ratio[o] == 1.0f ? inc : (uint32_t)((double)inc * (double)ratio[o]);
            dt[o] = (float)(oinc[o] >> 8) * (1.0f / 16777216.0f);
        }
        for (int base = 0; base < n; base += 64) {
            int len = n - base > 64 ? 64 : n - base;
            for (int i = 0; i < len; ++i) acc[i] = 0.0f;
            for (int o = 0; o < MSQ_UNI; ++o) {           /* oscillator-major: one shape pair per block */
                if (v->ugain[o] == 0.0f && gt[o] == 0.0f) { v->uph[o] += oinc[o] * (uint32_t)len; continue; }
                uint32_t *ph = &v->uph[o];
                float *g = &v->ugain[o];
                switch (sel) {
                case 0: osc_run(0, 0, fw, acc, len, ph, oinc[o], dt[o], g, gt[o], gstep); break;
                case 1: osc_run(0, 1, fw, acc, len, ph, oinc[o], dt[o], g, gt[o], gstep); break;
                case 2: osc_run(1, 0, fw, acc, len, ph, oinc[o], dt[o], g, gt[o], gstep); break;
                case 3: osc_run(1, 1, fw, acc, len, ph, oinc[o], dt[o], g, gt[o], gstep); break;
                case 4: osc_run(2, 0, fw, acc, len, ph, oinc[o], dt[o], g, gt[o], gstep); break;
                default: osc_run(2, 1, fw, acc, len, ph, oinc[o], dt[o], g, gt[o], gstep); break;
                }
            }
            float lv = v->level;
            for (int i = 0; i < len; ++i) {
                if (gate) { lv += att; if (lv > 1.0f) lv = 1.0f; }
                else      { lv -= rel; if (lv < 0.0f) lv = 0.0f; }
                out[base + i] += acc[i] * amp * lv;       /* level 0 -> exactly 0 */
            }
            v->level = lv;
        }
    }
}

void msq_render_voices(msq_t *m, int v0, int v1, float *out, int n)
{
    uint32_t mask = 0;
    for (int k = v0; k < v1; ++k) mask |= 1u << k;
    msq_render_mask(m, mask, out, n);
}

void msq_render_f(msq_t *m, float *out, int n)
{
    msq_render_voices(m, 0, MSQ_VOICES, out, n);
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

/* WAVE CHECK: CRC of the float bits of a fixed libm-free render (A4/A5/A3 are
 * exact powers of two of 440 Hz; unison 0 needs no powf; no sine table), over
 * triangle, saw, square and two morphs, with attack and release. The firmware
 * prints it at boot against the host value (test/wave_crc.c): equal = the
 * board renders the same samples the host measured. */
uint32_t msq_wave_crc(void)
{
    static msq_t w;
    static const float waves[5] = { 1.0f, 1.5f, 2.0f, 2.5f, 3.0f };
    static const uint8_t notes[3] = { 69, 81, 57 };
    float b[240];
    uint32_t c = 0xFFFFFFFFu;
    for (int k = 0; k < 5; ++k) {
        msq_init(&w, 48000);
        msq_set_attack(&w, 0.005f); msq_set_release(&w, 0.02f);
        msq_set_wave(&w, waves[k]);
        for (int n = 0; n < 3; ++n) { msq_byte(&w, 0x90); msq_byte(&w, notes[n]); msq_byte(&w, 100); }
        for (int blk = 0; blk < 12; ++blk) {
            if (blk == 8) for (int n = 0; n < 3; ++n) { msq_byte(&w, 0x80); msq_byte(&w, notes[n]); msq_byte(&w, 0); }
            msq_render_voices(&w, 0, MSQ_VOICES, b, 240);
            const uint8_t *p = (const uint8_t *)b;
            for (unsigned i = 0; i < sizeof b; ++i) { c ^= p[i]; for (int j = 0; j < 8; ++j) c = (c >> 1) ^ (0xEDB88320u & (0u - (c & 1u))); }
        }
    }
    return ~c;
}

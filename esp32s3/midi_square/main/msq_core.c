#include "msq_core.h"
#include <math.h>
#include <string.h>

float msq_note_hz(int note)
{
    return 440.0f * powf(2.0f, (float)(note - 69) / 12.0f);
}

void msq_init(msq_t *m, float sr)
{
    memset(m, 0, sizeof *m);
    m->sr       = sr;
    m->att_step = 1.0f / (0.002f * sr);   /* 2 ms attack  */
    m->rel_step = 1.0f / (0.010f * sr);   /* 10 ms release */
    m->amp      = 8192.0f;                /* -12 dBFS */
    m->last_note = -1;
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

void msq_render(msq_t *m, int16_t *lr, int n)
{
    uint32_t inc = m->inc;
    int gate = m->gate;
    for (int i = 0; i < n; ++i) {
        if (gate) { m->level += m->att_step; if (m->level > 1.0f) m->level = 1.0f; }
        else      { m->level -= m->rel_step; if (m->level < 0.0f) m->level = 0.0f; }
        m->phase += inc;
        float s = (m->phase & 0x80000000u) ? -m->amp : m->amp;
        int16_t v = (int16_t)(s * m->level);          /* level 0 -> exactly 0 */
        lr[2 * i] = v; lr[2 * i + 1] = v;
    }
}

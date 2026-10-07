/* juno_midi.c -- the plugin's MIDI controller intake below its render driver
 * (CLAIMS B16). See juno_midi.h. */
#include <math.h>
#include <string.h>
#include "juno_midi.h"
#include "midi_tables.h"
#include "juno_engine.h"
#include "juno_curve.h"
#include "recall_ramp.h"

/* every voice's two cells (sub-objects +25 and +33 of the processor, in that
 * order on each unit; each unit sets all eight voices, the port keeps voice v
 * from unit v) */
static void voices_arm(unsigned char *st, uint32_t cell25, uint32_t cell33, float x)
{
    int v;
    for (v = 0; v < JUNO_NUM_VOICES; ++v)
        juno_rr_arm(st, cell25 + (uint32_t)(v * JUNO_VOICE_MAIN_STRIDE), x, 0);
    for (v = 0; v < JUNO_NUM_VOICES; ++v)
        juno_rr_arm(st, cell33 + (uint32_t)(v * JUNO_VOICE_MAIN_STRIDE), x, 0);
}

void juno_midi_bend(unsigned char *st, int v16)
{
    int v = (int16_t)(uint16_t)v16;          /* the clamp compares the low 16 bits, signed */
    if (v < -8192) v = -8192;
    else if (v > 8191) v = 8191;
    voices_arm(st, 4112u, 7456u, juno_curve(26, v + 8192));
}

void juno_midi_mod(unsigned char *st, int v)
{
    if ((unsigned)v > 127u) return;
    voices_arm(st, 4000u, 7376u, juno_curve(22, v));
}

void juno_midi_expression(unsigned char *st, int v)
{
    if ((unsigned)v > 127u) return;
    juno_rr_arm(st, 101136u, juno_curve(18, v), 1);
}

float juno_midi_cc_value(int entry, int cc)
{
    const juno_midi_param *p = &JUNO_MIDI_PARAM[entry];
    uint32_t range = (uint32_t)p->max - (uint32_t)p->min;
    int32_t x = (int32_t)(range * (uint32_t)cc), q;
    if (p->trunc) {
        q = x / 127;
    } else {                                 /* (trunc(2x / 127) + 1) / 2 */
        int32_t t = (int32_t)((uint32_t)x * 2u) / 127;
        q = (t + 1) / 2;
    }
    if (p->min == p->max) return 0.0f;
    /* both converted from their 32 bits zero-extended (cvtsi2ss of rax) */
    return (float)(int64_t)(uint32_t)q / (float)(int64_t)range;
}

int32_t juno_midi_record_value(int entry, float v)
{
    const juno_midi_param *p = &JUNO_MIDI_PARAM[entry];
    float range = (float)(int64_t)((uint32_t)p->max - (uint32_t)p->min);
    float x = range * v;
    double r;
    x = x + (float)p->min;
    r = (double)x;                           /* rva 0x3F2050: half away from zero */
    r = (r >= 0.0 || r != r) ? floor(r + 0.5) : ceil(r - 0.5);
    if (!(r >= -2147483647.0)) return (int32_t)0x80000001u;
    if (r > 2147483647.0) return 0x7FFFFFFF;
    return (int32_t)r;
}

int juno_midi_entry(uint32_t id)
{
    int lo = 0, hi = JUNO_MIDI_IDMAP_N - 1;
    while (lo <= hi) {
        int mid = (lo + hi) / 2;
        if (JUNO_MIDI_IDMAP[mid].id == id) return JUNO_MIDI_IDMAP[mid].entry;
        if (JUNO_MIDI_IDMAP[mid].id < id) lo = mid + 1;
        else hi = mid - 1;
    }
    return -1;
}

int juno_midi_cc_entry(int cc)
{
    return (cc >= 0 && cc < 128) ? JUNO_CC_MAP[cc] : -1;
}

int juno_midi_entry_host(int entry) { return JUNO_MIDI_PARAM[entry].host; }
uint32_t juno_midi_entry_id(int entry) { return JUNO_MIDI_PARAM[entry].id; }
uint32_t juno_midi_base(void) { return JUNO_MIDI_BASE; }

typedef char juno_ccmap_recs_check[(JUNO_MIDI_PARAM_N == JUNO_CCMAP_RECS) ? 1 : -1];

void juno_ccmap_clear(juno_ccmap *m)
{
    memset(m->map, 0xFF, sizeof m->map);
    memset(m->rec, 0xFF, sizeof m->rec);
}

void juno_ccmap_boot(juno_ccmap *m)
{
    int cc, e;
    juno_ccmap_clear(m);
    for (cc = 0; cc < 128; ++cc) {
        e = juno_midi_cc_entry(cc);
        if (e < 0) continue;
        m->map[cc] = (int8_t)e;
        m->rec[e] = (int8_t)cc;
    }
    m->learn = -1;
}

int juno_ccmap_state_entry(juno_ccmap *m, uint32_t id, int32_t v)
{
    uint32_t cc = id - 0x10000000u;
    int e;
    if (cc > 0x7Fu) return 0;
    if (v < 0) return 1;
    e = juno_midi_entry((uint32_t)v);
    if (e < 0) return 1;
    m->map[cc] = (int8_t)e;
    m->rec[e] = (int8_t)cc;
    return 1;
}

int juno_ccmap_lookup(const juno_ccmap *m, int cc)
{
    if (m->learn >= 0 || cc < 0 || cc > 127) return -1;
    return m->map[cc];
}

int32_t juno_ccmap_state_value(const juno_ccmap *m, int cc)
{
    if (cc < 0 || cc > 127 || m->map[cc] < 0) return -1;
    return (int32_t)JUNO_MIDI_PARAM[m->map[cc]].id;
}

/* tone.c -- see tone.h. Stages: 0.5 s silence, LEFT only 440 Hz 1.5 s, gap,
 * RIGHT only 880 Hz 1.5 s, gap, MELODY on both (the opening of Tarrega's Gran
 * Vals, 1902 -- public domain; the phrase the Nokia ringtone used), 1.5 s
 * silence, repeat. */
#include <math.h>
#include "tone.h"

const char *const bt_stage_name[BT_NSTAGE] =
    { "SILENCE", "LEFT 440Hz", "GAP", "RIGHT 880Hz", "GAP", "MELODY", "SILENCE" };

#define MS(x) ((uint32_t)((x) * BT_SR / 1000))
static const uint32_t stage_ms[BT_NSTAGE] = { 500, 1500, 300, 1500, 300, 0, 1500 };

/* the melody: MIDI note, length in eighths (eighth = 150 ms) */
static const uint8_t mel[][2] = {
    { 76, 1 }, { 74, 1 }, { 66, 2 }, { 68, 2 },     /* E5 D5 F#4 G#4 */
    { 73, 1 }, { 71, 1 }, { 62, 2 }, { 64, 2 },     /* C#5 B4 D4 E4  */
    { 71, 1 }, { 69, 1 }, { 61, 2 }, { 64, 2 },     /* B4 A4 C#4 E4  */
    { 69, 6 },                                      /* A4            */
};
#define NMEL ((int)(sizeof mel / sizeof mel[0]))
#define EIGHTH_MS 150

static int16_t sine[1024];
static int sine_ok;

static uint32_t hz_inc(double hz) { return (uint32_t)(hz * 4294967296.0 / BT_SR + 0.5); }
static double midi_hz(int m) { return 440.0 * pow(2.0, (m - 69) / 12.0); }

static void note_start(bt_tone *t)
{
    t->npos = 0;
    t->nlen = MS(mel[t->note][1] * EIGHTH_MS);
    t->inc = hz_inc(midi_hz(mel[t->note][0]));
}

static void stage_start(bt_tone *t)
{
    t->pos = 0;
    t->ph = 0;
    if (t->stage == BT_MELODY) {
        uint32_t n = 0;
        for (int i = 0; i < NMEL; ++i) n += MS(mel[i][1] * EIGHTH_MS);
        t->len = n;
        t->note = 0;
        note_start(t);
    } else {
        t->len = MS(stage_ms[t->stage]);
        t->inc = hz_inc(t->stage == BT_LEFT ? 440.0 : 880.0);
    }
}

void bt_tone_init(bt_tone *t)
{
    if (!sine_ok) {
        for (int i = 0; i < 1024; ++i) sine[i] = (int16_t)lrint(32767.0 * sin(2 * M_PI * i / 1024));
        sine_ok = 1;
    }
    t->stage = 0;
    stage_start(t);
}

/* linear fade, 5 ms in and 10 ms out: no clicks */
static int32_t fade(uint32_t pos, uint32_t len, int32_t a)
{
    uint32_t in = MS(5), out = MS(10);
    if (pos < in) a = (int32_t)((int64_t)a * pos / in);
    if (len - pos < out) a = (int32_t)((int64_t)a * (len - pos) / out);
    return a;
}

static int16_t sample(bt_tone *t)
{
    int32_t s;
    if (t->stage == BT_MELODY) {
        /* a plucked tone: fundamental + a quiet octave, decaying to 30 % */
        uint32_t p = t->ph;
        int32_t v = sine[p >> 22] * 3 + sine[(p << 1) >> 22];          /* peak <= 4 * 32767 */
        int32_t a = BT_PEAK - (int32_t)((int64_t)(BT_PEAK * 7 / 10) * t->npos / t->nlen);
        a = fade(t->npos, t->nlen, a);
        s = (int32_t)((int64_t)v * a / (4 * 32767));
        if (++t->npos == t->nlen && t->note + 1 < NMEL) { ++t->note; note_start(t); }
    } else if (t->stage == BT_LEFT || t->stage == BT_RIGHT) {
        int32_t a = fade(t->pos, t->len, BT_PEAK);
        s = sine[t->ph >> 22] * a / 32767;
    } else
        s = 0;
    t->ph += t->inc;
    return (int16_t)s;
}

int bt_tone_render(bt_tone *t, int16_t *lr, int n, int *ended, int *endpos)
{
    int hit = 0;
    for (int i = 0; i < n; ++i) {
        int16_t s = sample(t);
        lr[2 * i]     = t->stage == BT_RIGHT ? 0 : s;
        lr[2 * i + 1] = t->stage == BT_LEFT  ? 0 : s;
        if (++t->pos == t->len) {
            hit = 1; *ended = t->stage; *endpos = i + 1;
            t->stage = (t->stage + 1) % BT_NSTAGE;
            stage_start(t);
        }
    }
    return hit;
}

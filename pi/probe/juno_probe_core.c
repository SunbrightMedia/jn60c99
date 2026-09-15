/* juno_probe_core.c — shared render+hash (see juno_probe_core.h).
 * Calls only the engine's public host API; does no DSP math itself, so its own
 * compile flags cannot affect bit-exactness. Built with the proven flags on
 * both host and metal anyway, for one less variable. */
#include "juno_probe_core.h"

/* engine host API — exactly the symbols gui/juno_bridge.c exports */
void *juno_gui_create (float sample_rate, int chorus_mode);
void  juno_gui_destroy(void *ctx);
int   juno_gui_apply_bank(void *ctx, const char *bank, int len, int idx);
void  juno_gui_note_on(void *ctx, int note, int vel);
int   juno_gui_render (void *ctx, float *buf, int nframes);

uint64_t juno_probe_render_hash(const unsigned char *bank, int banklen,
                                int patch, float sr, int note, int vel,
                                int nframes, float *buf, float *peak_out)
{
    void *c = juno_gui_create(sr, 0);   /* chorus_mode 0 = engine default */
    if (!c) { if (peak_out) *peak_out = 0.0f; return 0; }

    juno_gui_apply_bank(c, (const char *)bank, banklen, patch);
    juno_gui_note_on(c, note, vel);
    juno_gui_render(c, buf, nframes);

    uint64_t h = 1469598103934665603ULL;             /* FNV-1a-64 offset basis */
    const unsigned char *p = (const unsigned char *)buf;
    size_t n = sizeof(float) * 2u * (size_t)nframes;
    for (size_t i = 0; i < n; ++i) { h ^= p[i]; h *= 1099511628211ULL; }

    if (peak_out) {
        float peak = 0.0f;
        int i, m = 2 * nframes;
        for (i = 0; i < m; ++i) {
            float a = buf[i] < 0.0f ? -buf[i] : buf[i];
            if (a > peak) peak = a;
        }
        *peak_out = peak;
    }

    juno_gui_destroy(c);
    return h;
}

/* ---- seeded scenario / chunk-invariance ---------------------------------- */

static uint32_t xorshift32(uint32_t *s)
{
    uint32_t x = *s;
    x ^= x << 13; x ^= x >> 17; x ^= x << 5;
    return (*s = x);
}

enum { EV_ON = 0, EV_OFF = 1, EV_PATCH = 2 };
struct ev { int time; int kind; int a; int b; };
#define MAXEV 512

/* Build the deterministic event list from the seed. Same on host and metal. */
static int build_events(uint32_t seed, int total, float sr, struct ev *out)
{
    uint32_t s = seed ? seed : 1u;
    int held[8]; int nheld = 0;             /* recent note-on pool for note-off */
    int t = 0, n = 0;
    int step_lo = (int)(sr * 0.010f);       /* 10 ms .. ~80 ms between events   */
    int step_span = (int)(sr * 0.070f);
    while (n < MAXEV) {
        t += step_lo + (int)(xorshift32(&s) % (uint32_t)step_span);
        if (t >= total) break;
        uint32_t roll = xorshift32(&s) % 100u;
        struct ev e; e.time = t; e.a = 0; e.b = 0;
        if (roll < 55u) {                    /* NOTE ON */
            int note = 36 + (int)(xorshift32(&s) % 48u);
            int vel  = 40 + (int)(xorshift32(&s) % 88u);
            e.kind = EV_ON; e.a = note; e.b = vel;
            if (nheld < 8) held[nheld++] = note; else held[xorshift32(&s) & 7u] = note;
        } else if (roll < 85u && nheld > 0) {/* NOTE OFF a held note */
            int idx = (int)(xorshift32(&s) % (uint32_t)nheld);
            e.kind = EV_OFF; e.a = held[idx];
        } else {                             /* PATCH change */
            e.kind = EV_PATCH; e.a = (int)(xorshift32(&s) % 64u);
        }
        out[n++] = e;
    }
    return n;
}

static void fire(void *c, const unsigned char *bank, int banklen, const struct ev *e)
{
    switch (e->kind) {
    case EV_ON:    juno_gui_note_on(c, e->a, e->b); break;
    case EV_OFF:   juno_gui_note_off(c, e->a);      break;
    case EV_PATCH: juno_gui_apply_bank(c, (const char *)bank, banklen, e->a); break;
    }
}

uint64_t juno_probe_timeline_hash(const unsigned char *bank, int banklen,
                                  float sr, uint32_t seed, int total_frames,
                                  int chunk, float *buf, float *peak_out)
{
    static struct ev evs[MAXEV];
    int nev = build_events(seed, total_frames, sr, evs);

    void *c = juno_gui_create(sr, 0);
    if (!c) { if (peak_out) *peak_out = 0.0f; return 0; }

    int pos = 0, ei = 0;
    while (pos < total_frames) {
        while (ei < nev && evs[ei].time <= pos) fire(c, bank, banklen, &evs[ei++]);

        int chunk_bound = ((pos / chunk) + 1) * chunk;     /* next DMA boundary */
        int seg_end = chunk_bound < total_frames ? chunk_bound : total_frames;
        if (ei < nev && evs[ei].time < seg_end) seg_end = evs[ei].time;

        juno_gui_render(c, buf + 2 * pos, seg_end - pos);  /* continuous state  */
        pos = seg_end;
    }

    uint64_t h = 1469598103934665603ULL;
    const unsigned char *p = (const unsigned char *)buf;
    size_t n = sizeof(float) * 2u * (size_t)total_frames;
    for (size_t i = 0; i < n; ++i) { h ^= p[i]; h *= 1099511628211ULL; }

    if (peak_out) {
        float peak = 0.0f; int i, m = 2 * total_frames;
        for (i = 0; i < m; ++i) { float a = buf[i] < 0 ? -buf[i] : buf[i]; if (a > peak) peak = a; }
        *peak_out = peak;
    }

    juno_gui_destroy(c);
    return h;
}

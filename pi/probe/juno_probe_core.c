/* juno_probe_core.c — shared render+hash (see juno_probe_core.h).
 * Calls only the engine's public host API; does no DSP math itself, so its own
 * compile flags cannot affect bit-exactness. Built with the proven flags on
 * both host and metal anyway, for one less variable. */
#include "juno_probe_core.h"

/* engine host API — exactly the symbols gui/juno_bridge.c exports */
void *juno_gui_create (float sample_rate, int chorus_mode);
void  juno_gui_reinit (void *ctx, float sample_rate, int chorus_mode);
void  juno_gui_destroy(void *ctx);
int   juno_gui_apply_bank(void *ctx, const char *bank, int len, int idx);
void  juno_gui_note_on(void *ctx, int note, int vel);
void  juno_gui_note_off(void *ctx, int note);
int   juno_gui_render (void *ctx, float *buf, int nframes);
/* the WHOLE control surface: 79 named host params, each with a declared range,
 * covering DCO/VCF/VCA/ENV/LFO/BEND/MOD/GLOBAL/ARP/EFFECT/DELAY/CHORUS/REVERB.
 * A patch may or may not touch any of them, so the swarm drives them all. */
int   juno_gui_host_count(void);
int   juno_host_param_min(int i);
int   juno_host_param_max(int i);
void  juno_gui_host_set(void *ctx, int i, int v);
void  juno_gui_set_tempo(void *ctx, float bpm);

/* One engine, reused for every scenario. juno_gui_reinit resets it to the exact
 * COLD state of a fresh create without churning the heap (a 64-patch sweep that
 * created/destroyed the 12 MB state 64x fragmented Circle's low heap to OOM).
 * The output is bit-identical to per-scenario create/destroy — proven by the
 * gate. Not thread-safe; the probe is single-threaded. */
static void *g_ctx = 0;
static void *probe_ctx(float sr, int chorus)
{
    if (g_ctx) juno_gui_reinit(g_ctx, sr, chorus);
    else       g_ctx = juno_gui_create(sr, chorus);
    return g_ctx;
}

uint64_t juno_probe_render_hash(const unsigned char *bank, int banklen,
                                int patch, float sr, int note, int vel,
                                int nframes, float *buf, float *peak_out)
{
    void *c = probe_ctx(sr, 0);         /* chorus_mode 0 = engine default */
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

    return h;
}

/* non-finite (inf or NaN) by exponent==0xff — no libm needed on bare metal */
static int nonfinite(float f)
{
    union { float f; uint32_t u; } x; x.f = f;
    return ((x.u >> 23) & 0xffu) == 0xffu;
}

/* ---- seeded scenario / chunk-invariance ---------------------------------- */

static uint32_t xorshift32(uint32_t *s)
{
    uint32_t x = *s;
    x ^= x << 13; x ^= x >> 17; x ^= x << 5;
    return (*s = x);
}

/* Build the deterministic event list from the seed. Same on host and metal.
 * `wide`=0 is the musical range used by the bit-exact gate; `wide`=1 opens
 * EVERY control to its full VALID extreme — all 128 MIDI notes/velocities and
 * every host param across its true min..max — for the invariant fuzz. Values
 * stay in-range on purpose: out-of-range enum bytes the plugin UI can never
 * emit would test our clamping, not the audio engine's stability.
 * Public (declared in the header) so the multi-core split gate reuses the exact
 * same generator, guaranteeing an identical stream to every core copy. */
int juno_storm_build(uint32_t seed, int total, float sr, int wide,
                     struct juno_ev *out, int max)
{
    uint32_t s = seed ? seed : 1u;
    int held[8]; int nheld = 0;             /* recent note-on pool for note-off */
    int nhost = juno_gui_host_count();      /* 79 — the whole surface           */
    int t = 0, n = 0;
    int step_lo = (int)(sr * 0.008f);       /* ~8 ms .. ~60 ms between events    */
    int step_span = (int)(sr * 0.052f);
    while (n < max) {
        t += step_lo + (int)(xorshift32(&s) % (uint32_t)step_span);
        if (t >= total) break;
        uint32_t roll = xorshift32(&s) % 100u;
        struct juno_ev e; e.time = t; e.a = 0; e.b = 0;
        if (roll < 34u) {                    /* NOTE ON */
            int note = wide ? (int)(xorshift32(&s) % 128u)     /* full MIDI */
                            : 36 + (int)(xorshift32(&s) % 48u);
            int vel  = wide ? (int)(xorshift32(&s) % 128u)
                            : 40 + (int)(xorshift32(&s) % 88u);
            e.kind = JEV_ON; e.a = note; e.b = vel;
            if (nheld < 8) held[nheld++] = note; else held[xorshift32(&s) & 7u] = note;
        } else if (roll < 52u && nheld > 0) {/* NOTE OFF a held note */
            int idx = (int)(xorshift32(&s) % (uint32_t)nheld);
            e.kind = JEV_OFF; e.a = held[idx];
        } else if (roll < 62u) {             /* PATCH change */
            e.kind = JEV_PATCH; e.a = (int)(xorshift32(&s) % 64u);
        } else if (roll < 95u) {             /* HOST PARAM — the whole surface */
            int i = (int)(xorshift32(&s) % (uint32_t)nhost);
            int lo = juno_host_param_min(i), hi = juno_host_param_max(i);
            int span = hi - lo + 1;
            /* both modes stay in-range; wide favours the extremes (edges) */
            int v = lo + (int)(xorshift32(&s) % (uint32_t)span);
            if (wide && (xorshift32(&s) & 1u)) v = (xorshift32(&s) & 1u) ? lo : hi;
            e.kind = JEV_HOST; e.a = i; e.b = v;
        } else {                             /* TEMPO */
            e.kind = JEV_TEMPO; e.a = 20 + (int)(xorshift32(&s) % 280u);
        }
        out[n++] = e;
    }
    return n;
}

void juno_storm_fire(void *c, const unsigned char *bank, int banklen,
                     const struct juno_ev *e)
{
    switch (e->kind) {
    case JEV_ON:    juno_gui_note_on(c, e->a, e->b);   break;
    case JEV_OFF:   juno_gui_note_off(c, e->a);        break;
    case JEV_PATCH: juno_gui_apply_bank(c, (const char *)bank, banklen, e->a); break;
    case JEV_HOST:  juno_gui_host_set(c, e->a, e->b);  break;
    case JEV_TEMPO: juno_gui_set_tempo(c, (float)e->a); break;
    }
}

uint64_t juno_probe_timeline_hash(const unsigned char *bank, int banklen,
                                  float sr, uint32_t seed, int total_frames,
                                  int chunk, float *buf, float *peak_out)
{
    static struct juno_ev evs[JUNO_MAXEV];
    int nev = juno_storm_build(seed, total_frames, sr, 0, evs, JUNO_MAXEV); /* in-range */

    void *c = probe_ctx(sr, 0);
    if (!c) { if (peak_out) *peak_out = 0.0f; return 0; }

    int pos = 0, ei = 0;
    while (pos < total_frames) {
        while (ei < nev && evs[ei].time <= pos) juno_storm_fire(c, bank, banklen, &evs[ei++]);

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

    return h;
}

/* THE INVARIANT: audio never breaks for ANY input. Drive the WHOLE control
 * surface with `wide` (out-of-range notes and params too), render the timeline,
 * and scan every sample. Reports non-finite (NaN/inf) and out-of-|bound| counts;
 * returns 0 iff clean. A ROBUSTNESS gate, not a bit-exact one. */
int juno_probe_fuzz(const unsigned char *bank, int banklen, float sr,
                    uint32_t seed, int total_frames, float bound, float *buf,
                    float *worst_peak, long *nbad_finite, long *nbad_bound)
{
    static struct juno_ev evs[JUNO_MAXEV];
    int nev = juno_storm_build(seed, total_frames, sr, 1, evs, JUNO_MAXEV); /* wide */

    void *c = probe_ctx(sr, 0);
    if (!c) return -1;

    int pos = 0, ei = 0, chunk = 256;
    while (pos < total_frames) {
        while (ei < nev && evs[ei].time <= pos) juno_storm_fire(c, bank, banklen, &evs[ei++]);
        int cb = ((pos / chunk) + 1) * chunk;
        int seg_end = cb < total_frames ? cb : total_frames;
        if (ei < nev && evs[ei].time < seg_end) seg_end = evs[ei].time;
        juno_gui_render(c, buf + 2 * pos, seg_end - pos);
        pos = seg_end;
    }

    long bf = 0, bb = 0; float peak = 0.0f;
    int i, m = 2 * total_frames;
    for (i = 0; i < m; ++i) {
        float f = buf[i];
        if (nonfinite(f)) { ++bf; continue; }
        float a = f < 0 ? -f : f;
        if (a > peak) peak = a;
        if (a > bound) ++bb;
    }
    if (worst_peak)  *worst_peak  = peak;
    if (nbad_finite) *nbad_finite = bf;
    if (nbad_bound)  *nbad_bound  = bb;
    return (bf || bb) ? 1 : 0;
}

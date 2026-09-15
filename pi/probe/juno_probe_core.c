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

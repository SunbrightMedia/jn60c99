/* juno_conv.c -- the plugin's render object (CLAIMS B13): the table lookup (rva
 * 0x343A80) and the rate converter (rva 0x343E30), transcribed from the machine
 * code; the table and its coefficient vectors are the booted plugin's own
 * (src/conv_tables.h, tools/verify/gen_conv_tables.py). */
#include <stdlib.h>
#include <string.h>
#include "juno_conv.h"
#include "conv_tables.h"

void juno_ro_init(juno_ro *ro, int engine, int host)
{
    memset(ro, 0, sizeof *ro);
    ro->engine = engine;
    ro->host = host;
    ro->entry = -1;
}

void juno_ro_free(juno_ro *ro)
{
    free(ro->buf[0]);
    free(ro->buf[1]);
    ro->buf[0] = ro->buf[1] = NULL;
    ro->size = ro->cap = 0;
}

/* std::vector<float>: room for n elements, the first ro->size kept */
static int ro_reserve(juno_ro *ro, int n)
{
    int ch;
    if (n <= ro->cap) return 0;
    for (ch = 0; ch < 2; ++ch) {
        float *p = (float *)realloc(ro->buf[ch], (size_t)n * sizeof(float));
        if (!p) return -1;
        ro->buf[ch] = p;
    }
    ro->cap = n;
    return 0;
}

int juno_ro_lookup(juno_ro *ro)
{
    int k, nv, L, q, ch;
    for (k = 0; ; ++k) {
        ro->entry = k;
        if (JUNO_CONV[k].engine == ro->engine && JUNO_CONV[k].host == ro->host) break;
        if (k == JUNO_CONV_N) {                 /* the terminator: no pair */
            ro->delay = 0;
            ro->acc42 = 0;
            ro->acc43 = 0;
            return 0;
        }
    }
    nv = JUNO_CONV_VLEN[JUNO_CONV[k].vec];
    L = JUNO_CONV[k].L;
    if (L <= 0) { ro->entry = JUNO_CONV_N; return 0; }   /* only the terminator: unreachable */
    q = nv / L;
    if (nv % L) ++q;
    ro->delay = L * q;
    if (ro_reserve(ro, 4096 > 2 * q ? 4096 : 2 * q) < 0) { ro->entry = JUNO_CONV_N; return -1; }
    for (ch = 0; ch < 2; ++ch) memset(ro->buf[ch], 0, (size_t)(2 * q) * sizeof(float));
    ro->size = 2 * q;
    ro->acc42 = 2 * ro->delay;
    ro->acc43 = ro->delay;
    return 1;
}

int juno_ro_kind(const juno_ro *ro)
{
    return ro->entry < 0 ? -1 : JUNO_CONV[ro->entry].kind;
}

int juno_ro_convert(juno_ro *ro, float *const *out, int nch, int n,
                    juno_ro_render_fn render, void *user)
{
    const juno_conv_entry *e = &JUNO_CONV[ro->entry];
    const uint32_t *h = JUNO_CONV_VEC[e->vec];
    const int L = e->L, M = e->M, nh = JUNO_CONV_VLEN[e->vec];
    int v10, v12, v15, v18, v35, ch, j;
    /* the engine samples this block needs, ceil-ahead (trunc + 1 on a remainder) */
    v10 = ro->acc43 + ro->delay + n * M - ro->acc42;
    v12 = v10 / L;
    if (v10 % L) ++v12;
    v15 = 2 * (ro->delay / L);                     /* the history kept */
    v18 = v15 + v12;
    /* the history to the front of each channel's buffer, element by element,
     * ascending (rva 0x343ED8). After a call that rendered -1 engine samples
     * (an upsampling block with n x M < L: the count is trunc(v10 / L) + 1 on a
     * remainder, and v10 = -L gives -1; the lead stays below 2L, so never -2)
     * the source starts one element BEFORE the buffer: the plugin copies the
     * word in front of its vector -- the high half of the raw heap pointer
     * MSVC's aligned allocation keeps there, below 0x8000 for every user-mode
     * address, so a denormal its DAZ reads as +0 -- and, copying upward, smears
     * it over the whole history. */
    for (ch = 0; ch < nch; ++ch) {
        float *b = ro->buf[ch];
        int off = ro->size - v15, i;
        for (i = 0; i < v15; ++i) b[i] = (i + off < 0) ? 0.0f : b[i + off];
    }
    /* both buffers resized: new elements 0 */
    if (ro_reserve(ro, v18) < 0) return -1;
    if (v18 > ro->size)
        for (ch = 0; ch < 2; ++ch) memset(ro->buf[ch] + ro->size, 0, (size_t)(v18 - ro->size) * sizeof(float));
    ro->size = v18;
    if (v12 > 0) {
        float *ptrs[2];
        for (ch = 0; ch < nch; ++ch) ptrs[ch] = ro->buf[ch] + v15;
        render(user, ptrs, nch, v12);
        ro->acc42 += v12 * L;
    }
    v35 = ro->acc42 - v18 * L;
    for (ch = 0; ch < nch; ++ch) {
        const float *x = ro->buf[ch];
        for (j = 0; j < n; ++j) {
            float sum = 0.0f, hk;
            int pos = ro->acc43 + j * M;
            int r = pos % L;
            int k = r ? L - r : 0;                 /* the forward taps */
            if (k < nh) {
                int xi = (pos - v35 + k) / L;
                do {
                    memcpy(&hk, &h[k], 4);
                    sum = sum + x[xi] * hk;
                    k += L;
                    ++xi;
                } while (k < nh);
            }
            k = r ? r : L;                         /* the backward taps */
            if (k < nh) {
                int xi = (pos - k - v35) / L;
                do {
                    memcpy(&hk, &h[k], 4);
                    /* index -1 (after a -1 call): the word in front of the
                     * plugin's vector, +0 under its DAZ (above) */
                    sum = sum + (xi >= 0 ? x[xi] : 0.0f) * hk;
                    k += L;
                    --xi;
                } while (k < nh);
            }
            out[ch][j] = (float)L * sum;
        }
    }
    /* the counters, wrapped below 2^30 by whole periods of L x M */
    ro->acc43 += M * n;
    {
        int w = 0x40000000 - 0x40000000 % (L * M);
        int lim = w + 2 * ro->delay;
        if (lim <= ro->acc43) {
            int a42 = ro->acc42, a43 = ro->acc43;
            do { a42 -= w; a43 -= w; } while (lim <= a43);
            ro->acc42 = a42;
            ro->acc43 = a43;
        }
    }
    return 0;
}

int juno_ro_setting_rate(int value, int engine_rate, int *automatic)
{
    int v = value & 0x7F;
    if (automatic) *automatic = (v == 5);
    return v == 5 ? engine_rate : JUNO_SRATE[v];
}

/* es_fftconv.c -- partitioned overlap-save convolution (see es_fftconv.h). */
#include "es_fftconv.h"
#include "es_math.h"

static es_cpx TW[ES_FC_N / 2];
static int    tw_ready;

static void tw_init(void)
{
    int k;
    for (k = 0; k < ES_FC_N / 2; ++k) {
        const double a = -2.0 * 3.14159265358979323846 * k / ES_FC_N;
        TW[k].re = (float)es_cos(a);
        TW[k].im = (float)es_sin(a);
    }
    tw_ready = 1;
}

/* in-place iterative radix-2; inverse = conjugate twiddles, no scaling */
static void fft(es_cpx *a, int inverse)
{
    int i, j, len, k;
    for (i = 1, j = 0; i < ES_FC_N; ++i) {
        int bit = ES_FC_N >> 1;
        for (; j & bit; bit >>= 1) j ^= bit;
        j ^= bit;
        if (i < j) { es_cpx t = a[i]; a[i] = a[j]; a[j] = t; }
    }
    for (len = 2; len <= ES_FC_N; len <<= 1) {
        const int step = ES_FC_N / len;
        for (i = 0; i < ES_FC_N; i += len) {
            for (k = 0; k < len / 2; ++k) {
                es_cpx w = TW[k * step], u = a[i + k], v = a[i + k + len / 2], t;
                if (inverse) w.im = -w.im;
                t.re = v.re * w.re - v.im * w.im;
                t.im = v.re * w.im + v.im * w.re;
                a[i + k].re = u.re + t.re; a[i + k].im = u.im + t.im;
                a[i + k + len / 2].re = u.re - t.re; a[i + k + len / 2].im = u.im - t.im;
            }
        }
    }
}

void es_fftconv_init(es_fftconv *c, const float *ir, int n)
{
    int p, i;
    if (!tw_ready) tw_init();
    if (n > ES_FC_B * ES_FC_MAXP) n = ES_FC_B * ES_FC_MAXP;
    c->parts = (n + ES_FC_B - 1) / ES_FC_B;
    if (c->parts < 1) c->parts = 1;
    c->pos = 0;
    c->fdl_head = 0;
    for (i = 0; i < ES_FC_N; ++i) c->in[i] = 0;
    for (i = 0; i < ES_FC_B; ++i) c->out[i] = 0;
    for (p = 0; p < ES_FC_MAXP; ++p)
        for (i = 0; i < ES_FC_N; ++i) {
            c->H[p][i].re = c->H[p][i].im = 0;
            c->X[p][i].re = c->X[p][i].im = 0;
        }
    for (p = 0; p < c->parts; ++p) {
        for (i = 0; i < ES_FC_B; ++i) {
            const int t = p * ES_FC_B + i;
            c->H[p][i].re = (t < n) ? ir[t] : 0.0f;
        }
        fft(c->H[p], 0);
    }
}

static void process_block(es_fftconv *c)
{
    es_cpx acc[ES_FC_N];
    int p, i;
    es_cpx *X;
    c->fdl_head = (c->fdl_head + c->parts - 1) % c->parts;
    X = c->X[c->fdl_head];
    for (i = 0; i < ES_FC_N; ++i) { X[i].re = c->in[i]; X[i].im = 0; }
    fft(X, 0);
    for (i = 0; i < ES_FC_N; ++i) acc[i].re = acc[i].im = 0;
    for (p = 0; p < c->parts; ++p) {
        const es_cpx *x = c->X[(c->fdl_head + p) % c->parts], *h = c->H[p];
        for (i = 0; i < ES_FC_N; ++i) {
            acc[i].re += x[i].re * h[i].re - x[i].im * h[i].im;
            acc[i].im += x[i].re * h[i].im + x[i].im * h[i].re;
        }
    }
    fft(acc, 1);
    for (i = 0; i < ES_FC_B; ++i) c->out[i] = acc[ES_FC_B + i].re * (1.0f / ES_FC_N);
    for (i = 0; i < ES_FC_B; ++i) c->in[i] = c->in[ES_FC_B + i];   /* slide */
}

float es_fftconv_tick(es_fftconv *c, float x)
{
    const float y = c->out[c->pos];
    c->in[ES_FC_B + c->pos] = x;
    if (++c->pos == ES_FC_B) { process_block(c); c->pos = 0; }
    return y;
}

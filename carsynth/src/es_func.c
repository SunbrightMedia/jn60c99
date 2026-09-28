/* es_func.c -- C99 port of engine-sim src/function.cpp (MIT, Ange Yaghi). */
#include "es_func.h"
#include "es_math.h"

void es_func_init(es_func *f, double r) { f->size = 0; f->radius = r; }

static int closest(const es_func *f, double x)
{
    int l = 0, r = f->size - 1;
    if (x != x) return 0;
    if (f->size == 0) return -1;
    else if (x <= f->x[l]) return l;
    else if (x >= f->x[r]) return r;
    while (l + 1 < r) {
        const int m = (l + r) / 2;
        if (x > f->x[m]) l = m;
        else if (x < f->x[m]) r = m;
        else if (x == f->x[m]) return m;
    }
    return (x - f->x[l] < f->x[r] - x) ? l : r;
}

void es_func_add(es_func *f, double x, double y)
{
    int c, idx, i;
    if (f->size >= ES_FUNC_CAP) return;
    c = closest(f, x);
    if (c == -1) { f->size = 1; f->x[0] = x; f->y[0] = y; return; }
    idx = x < f->x[c] ? c : c + 1;
    ++f->size;
    for (i = f->size - 1; i > idx; --i) { f->x[i] = f->x[i - 1]; f->y[i] = f->y[i - 1]; }
    f->x[idx] = x;
    f->y[idx] = y;
}

double es_func_tri(const es_func *f, double x)
{
    const int c = closest(f, x);
    double sum = 0, tw = 0;
    int i;
    if (f->size == 0) return 0;
    else if (x >= f->x[f->size - 1]) return f->y[f->size - 1];
    else if (x <= f->x[0]) return f->y[0];
    for (i = c; i >= 0; --i) {
        if (f->x[i] > x) continue;
        if (es_fabs(x - f->x[i]) > f->radius) break;
        { const double w = (f->radius - es_fabs(f->x[i] - x)) / f->radius; sum += w * f->y[i]; tw += w; }
    }
    for (i = c; i < f->size; ++i) {
        if (f->x[i] <= x) continue;
        if (es_fabs(f->x[i] - x) > f->radius) break;
        { const double w = (f->radius - es_fabs(f->x[i] - x)) / f->radius; sum += w * f->y[i]; tw += w; }
    }
    return (tw != 0) ? sum / tw : 0;
}

void es_func_harmonic_cam_lobe(es_func *f, double dur50, double gamma, double lift, int steps)
{
    const double thou = 0.0000254;
    const double angle = dur50 / 4;
    const double s = es_pow(2 * (50 * thou) / lift, 1 / gamma) - 1;
    const double k = es_acos(s) / angle;
    const double extents = ES_PI / k;
    const double step = extents / (steps - 5.0);
    int i;
    es_func_init(f, 1.0);
    for (i = 0; i < steps; ++i) {
        if (i == 0) es_func_add(f, 0.0, lift);
        else {
            const double x = i * step;
            const double l = (x >= extents) ? 0.0 : lift * es_pow(0.5 + 0.5 * es_cos(k * x), gamma);
            es_func_add(f, x, l);
            es_func_add(f, -x, l);
        }
    }
    f->radius = step;
}

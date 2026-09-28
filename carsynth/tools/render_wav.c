/* render_wav.c -- host renderer: carsynth -> 16-bit stereo WAV, with a score.
 * usage: render_wav out.wav seconds [param=v] [@t:param=v] [@t:on=NOTE,VEL] [@t:off=NOTE]
 *   params: engine exhaust load rev tone noise space (0..1)
 * Prints real-time factor (render seconds / audio seconds). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "../src/car.h"

static const char *NAMES[CAR_NPARAM] = {"engine", "exhaust", "load", "rev", "tone", "noise", "space"};
typedef struct { double t; int kind, p; float v; } ev_t;   /* kind 0 param, 1 on, 2 off */

static int parse(const char *s, ev_t *e)
{
    char name[32]; float v, v2; int i;
    e->t = 0;
    if (*s == '@') { e->t = atof(s + 1); s = strchr(s, ':'); if (!s) return 0; s++; }
    if (sscanf(s, "on=%f,%f", &v, &v2) == 2) { e->kind = 1; e->p = (int)v; e->v = v2; return 1; }
    if (sscanf(s, "off=%f", &v) == 1) { e->kind = 2; e->p = (int)v; return 1; }
    if (sscanf(s, "%31[^=]=%f", name, &v) != 2) return 0;
    for (i = 0; i < CAR_NPARAM; i++) if (!strcmp(name, NAMES[i])) { e->kind = 0; e->p = i; e->v = v; return 1; }
    return 0;
}
static void w32(FILE *f, unsigned v) { fputc(v, f); fputc(v >> 8, f); fputc(v >> 16, f); fputc(v >> 24, f); }
static void w16(FILE *f, unsigned v) { fputc(v, f); fputc(v >> 8, f); }

int main(int argc, char **argv)
{
    const int sr = CAR_SR, blk = 128;
    ev_t ev[128]; int nev = 0, i, n; unsigned char done[128] = {0};
    long frames, pos = 0; float L[128], R[128], peak = 0; double t0; FILE *f;
    if (argc < 3) { fprintf(stderr, "usage: see source\n"); return 2; }
    for (i = 3; i < argc && nev < 128; i++)
        if (parse(argv[i], &ev[nev])) nev++; else { fprintf(stderr, "bad arg %s\n", argv[i]); return 2; }
    frames = (long)(atof(argv[2]) * sr);
    car_init();
    f = fopen(argv[1], "wb"); if (!f) return 1;
    fwrite("RIFF", 1, 4, f); w32(f, 36 + frames * 4); fwrite("WAVEfmt ", 1, 8, f);
    w32(f, 16); w16(f, 1); w16(f, 2); w32(f, sr); w32(f, sr * 4); w16(f, 4); w16(f, 16);
    fwrite("data", 1, 4, f); w32(f, frames * 4);
    t0 = (double)clock() / CLOCKS_PER_SEC;
    while (pos < frames) {
        for (i = 0; i < nev; i++) if (!done[i] && ev[i].t * sr <= pos) {
            if (ev[i].kind == 0) car_set(ev[i].p, ev[i].v);
            else if (ev[i].kind == 1) car_note_on(ev[i].p, ev[i].v);
            else car_note_off(ev[i].p);
            done[i] = 1;
        }
        n = frames - pos < blk ? (int)(frames - pos) : blk;
        car_render(L, R, n);
        for (i = 0; i < n; i++) {
            int a = (int)(L[i] * 32767.0f), b = (int)(R[i] * 32767.0f);
            if (L[i] > peak) peak = L[i]; if (-L[i] > peak) peak = -L[i];
            if (L[i] != L[i]) { fprintf(stderr, "NaN at frame %ld\n", pos + i); return 3; }
            w16(f, (unsigned)(a & 0xffff)); w16(f, (unsigned)(b & 0xffff));
        }
        pos += n;
    }
    fclose(f);
    printf("wrote %s: %.1f s, peak %.3f, rpm %.0f, throttle %.2f, realtime x%.2f\n", argv[1],
           (double)frames / sr, peak, car_meter(0), car_meter(2),
           ((double)frames / sr) / ((double)clock() / CLOCKS_PER_SEC - t0));
    return 0;
}

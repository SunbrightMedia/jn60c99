/* render_wav.c -- host renderer: jetsynth -> 16-bit stereo WAV.
 * usage: render_wav out.wav seconds [param=value ...] [@t:param=value ...]
 *   params: throttle spool speed angle distance size space boost (0..1)
 *   @t:...  applies the setting at time t seconds (a simple score). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../src/jet.h"

static const char *NAMES[JET_NPARAM] = {"throttle", "spool", "speed", "angle",
                                        "distance", "size", "space", "boost"};
typedef struct { double t; int p; float v; } ev_t;

static int parse(const char *s, ev_t *e)
{
    char name[32]; float v; int i;
    e->t = 0;
    if (*s == '@') { e->t = atof(s + 1); s = strchr(s, ':'); if (!s) return 0; s++; }
    if (sscanf(s, "%31[^=]=%f", name, &v) != 2) return 0;
    for (i = 0; i < JET_NPARAM; i++) if (!strcmp(name, NAMES[i])) { e->p = i; e->v = v; return 1; }
    return 0;
}

static void w32(FILE *f, unsigned v) { fputc(v, f); fputc(v >> 8, f); fputc(v >> 16, f); fputc(v >> 24, f); }
static void w16(FILE *f, unsigned v) { fputc(v, f); fputc(v >> 8, f); }

int main(int argc, char **argv)
{
    const int sr = 48000, blk = 128;
    ev_t ev[64]; int nev = 0, i, done = 0, n;
    long frames, pos = 0;
    float L[128], R[128];
    FILE *f;
    if (argc < 3) { fprintf(stderr, "usage: render_wav out.wav seconds [p=v] [@t:p=v]\n"); return 2; }
    for (i = 3; i < argc && nev < 64; i++)
        if (parse(argv[i], &ev[nev])) nev++; else { fprintf(stderr, "bad arg %s\n", argv[i]); return 2; }
    frames = (long)(atof(argv[2]) * sr);
    jet_init((float)sr);
    f = fopen(argv[1], "wb");
    if (!f) return 1;
    fwrite("RIFF", 1, 4, f); w32(f, 36 + frames * 4); fwrite("WAVEfmt ", 1, 8, f);
    w32(f, 16); w16(f, 1); w16(f, 2); w32(f, sr); w32(f, sr * 4); w16(f, 4); w16(f, 16);
    fwrite("data", 1, 4, f); w32(f, frames * 4);
    while (pos < frames) {
        for (i = 0; i < nev; i++)
            if (!(done & (1 << i)) && ev[i].t * sr <= pos) { jet_set(ev[i].p, ev[i].v); done |= 1 << i; }
        n = frames - pos < blk ? (int)(frames - pos) : blk;
        jet_render(L, R, n);
        for (i = 0; i < n; i++) {
            int a = (int)(L[i] * 32767.0f), b = (int)(R[i] * 32767.0f);
            w16(f, (unsigned)(a & 0xffff)); w16(f, (unsigned)(b & 0xffff));
        }
        pos += n;
    }
    fclose(f);
    printf("wrote %s (%ld frames), last-block peak %.3f, spool TS %.3f, BPF %.0f Hz, tip Mach %.2f\n",
           argv[1], frames, jet_meter(4), jet_meter(0), jet_meter(2), jet_meter(3));
    return 0;
}

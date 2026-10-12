/* jp8_render.c -- the JUPITER-8, offline: a factory patch and a MIDI file through the plugin's own host path, lifted
 * (jp8h.h: the plugin's process(), patch load and engine, run on the JP8H template), into a WAV file of 32-bit floats.
 *
 *   jp8_render <template.bin> <bank.bin> <patch 0-63> <in.mid> <out.wav> [rate=48000] [tail seconds=2] [plan.txt]
 *
 * plan.txt      (optional) every block's host calls as text -- "B n", "E on offset channel pitch velocity-bits",
 *               "P id offset value-bits" -- so the oracle can replay exactly the calls this run made
 *               (jp8_render_check.py grades the WAV against the plugin run on them)
 *
 * template.bin  the JP8H v2 template, raw (gunzip of jp8/gen/jp8h_template.bin.gz)
 * bank.bin      the plugin's factory bank (jp8/truth/1_Preset.bin: a 22-byte header, 64 records of 20,223 bytes, each
 *               a 16-byte name and the record the patch browser loads)
 * in.mid        a Standard MIDI File, format 0 or 1, ticks per quarter note (SMPTE time is refused); every channel
 * The MIDI reaches the plugin as a VST3 host hands it: notes as note events (velocity / 127), and the controllers
 * through the plugin's own IMidiMapping (jp8_controller_census.py): CC n -> parameter 0x0FFFC100 + n at n / 127,
 * channel pressure -> 0x0FFFC180, pitch bend -> 0x0FFFC181 at the 14-bit value / 16383 -- each a parameter queue point
 * at its sample inside the block. Blocks of 512 samples; at most 8 controller ids, 512 notes and 2048 points a block
 * (the host objects' queues): what does not fit moves to the next block's start, in order. The output words are the
 * plugin's floats, written as they are. Plumbing only: no plugin logic here. ISO C99. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <time.h>
#include "jp8h.h"

#define BLOCK 512
#define BANK_HEADER 22
#define BANK_STRIDE 20223
#define NAME_LEN 16
#define MIDI_BASE 0x0FFFC100u
#define NPQ 8                       /* the parameter queues the host objects hold per block (jp8_host.c NPQ) */

typedef struct { uint64_t tick; uint32_t seq; uint8_t st, d1, d2; } mev;   /* one channel event, merged over tracks */
typedef struct { uint64_t tick; uint32_t usq; } tempo_pt;                  /* microseconds per quarter from tick */

static unsigned char *slurp(const char *path, size_t *n) {
    FILE *f = fopen(path, "rb"); unsigned char *b; long len;
    if (!f) { fprintf(stderr, "cannot open %s\n", path); exit(2); }
    if (fseek(f, 0, SEEK_END) || (len = ftell(f)) < 0 || fseek(f, 0, SEEK_SET)) { fprintf(stderr, "cannot size %s\n", path); exit(2); }
    b = (unsigned char *)malloc((size_t)len + 1);
    if (!b || fread(b, 1, (size_t)len, f) != (size_t)len) { fprintf(stderr, "cannot read %s\n", path); exit(2); }
    fclose(f); *n = (size_t)len; return b;
}
static uint32_t be32(const unsigned char *p) { return (uint32_t)p[0] << 24 | (uint32_t)p[1] << 16 | (uint32_t)p[2] << 8 | p[3]; }
static unsigned be16(const unsigned char *p) { return (unsigned)p[0] << 8 | p[1]; }

static mev *evs; static size_t nevs, cap_evs; static tempo_pt *tmp; static size_t ntmp, cap_tmp; static uint32_t seqno;
static void push_ev(uint64_t tick, uint8_t st, uint8_t d1, uint8_t d2) {
    if (nevs == cap_evs) { cap_evs = cap_evs ? 2 * cap_evs : 1024; evs = (mev *)realloc(evs, cap_evs * sizeof *evs); if (!evs) exit(3); }
    evs[nevs].tick = tick; evs[nevs].seq = seqno++; evs[nevs].st = st; evs[nevs].d1 = d1; evs[nevs].d2 = d2; nevs++;
}
static void push_tempo(uint64_t tick, uint32_t usq) {
    if (ntmp == cap_tmp) { cap_tmp = cap_tmp ? 2 * cap_tmp : 16; tmp = (tempo_pt *)realloc(tmp, cap_tmp * sizeof *tmp); if (!tmp) exit(3); }
    tmp[ntmp].tick = tick; tmp[ntmp].usq = usq; ntmp++;
}
static int cmp_ev(const void *a, const void *b) {
    const mev *x = (const mev *)a, *y = (const mev *)b;
    if (x->tick != y->tick) return x->tick < y->tick ? -1 : 1;
    return x->seq < y->seq ? -1 : (x->seq > y->seq);
}
static int cmp_tmp(const void *a, const void *b) {
    const tempo_pt *x = (const tempo_pt *)a, *y = (const tempo_pt *)b;
    return x->tick < y->tick ? -1 : (x->tick > y->tick);
}
static uint32_t vlq(const unsigned char *b, size_t end, size_t *p) {
    uint32_t v = 0; int k;
    for (k = 0; k < 4 && *p < end; k++) { unsigned char c = b[(*p)++]; v = v << 7 | (c & 0x7F); if (!(c & 0x80)) return v; }
    fprintf(stderr, "a bad variable-length number in the MIDI file\n"); exit(2);
}
static unsigned read_smf(const unsigned char *b, size_t n) {          /* returns ticks per quarter note */
    unsigned fmt, ntrk, div, t; size_t p;
    if (n < 14 || memcmp(b, "MThd", 4) || be32(b + 4) < 6) { fprintf(stderr, "not a Standard MIDI File\n"); exit(2); }
    fmt = be16(b + 8); ntrk = be16(b + 10); div = be16(b + 12);
    if (fmt > 1) { fprintf(stderr, "MIDI format %u: only 0 and 1\n", fmt); exit(2); }
    if (div & 0x8000) { fprintf(stderr, "SMPTE time division: not supported\n"); exit(2); }
    p = 8 + be32(b + 4);
    for (t = 0; t < ntrk; t++) {
        size_t end; uint64_t tick = 0; uint8_t run = 0;
        if (p + 8 > n || memcmp(b + p, "MTrk", 4)) { fprintf(stderr, "track %u missing\n", t); exit(2); }
        end = p + 8 + be32(b + p + 4); p += 8;
        if (end > n) { fprintf(stderr, "track %u cut short\n", t); exit(2); }
        while (p < end) {
            uint8_t st;
            tick += vlq(b, end, &p);
            if (p >= end) break;
            st = b[p];
            if (st == 0xFF) {                                            /* meta: tempo kept, the rest skipped */
                uint8_t type; uint32_t len;
                if (p + 2 > end) break;
                type = b[p + 1]; p += 2; len = vlq(b, end, &p);
                if (type == 0x51 && len == 3 && p + 3 <= end) push_tempo(tick, (uint32_t)b[p] << 16 | (uint32_t)b[p + 1] << 8 | b[p + 2]);
                if (type == 0x2F) { p = end; break; }
                p += len; continue;
            }
            if (st == 0xF0 || st == 0xF7) { uint32_t len; p++; len = vlq(b, end, &p); p += len; continue; }   /* sysex: skipped */
            if (st & 0x80) { run = st; p++; } else if (!run) { fprintf(stderr, "running status with no status\n"); exit(2); }
            st = run;
            {
                unsigned kind = st & 0xF0, nd = (kind == 0xC0 || kind == 0xD0) ? 1 : 2; uint8_t d1, d2 = 0;
                if (p + nd > end) break;
                d1 = b[p]; if (nd == 2) d2 = b[p + 1]; p += nd;
                push_ev(tick, st, d1, d2);
            }
        }
        p = end;
    }
    return div;
}
/* the tick's time in seconds (the tempo map, 120 bpm before the first tempo) */
static double tick_seconds(uint64_t tick, unsigned div) {
    double s = 0.0; uint64_t at = 0; uint32_t usq = 500000; size_t i;
    for (i = 0; i < ntmp && tmp[i].tick <= tick; i++) {
        s += (double)(tmp[i].tick - at) * usq / 1e6 / div; at = tmp[i].tick; usq = tmp[i].usq;
    }
    return s + (double)(tick - at) * usq / 1e6 / div;
}

static void wav_header(FILE *f, uint32_t rate, uint32_t frames) {
    uint32_t data = frames * 8u, v; uint16_t s;
    fwrite("RIFF", 1, 4, f); v = 36 + data; fwrite(&v, 4, 1, f); fwrite("WAVEfmt ", 1, 8, f);
    v = 16; fwrite(&v, 4, 1, f); s = 3; fwrite(&s, 2, 1, f); s = 2; fwrite(&s, 2, 1, f);     /* IEEE float, stereo */
    fwrite(&rate, 4, 1, f); v = rate * 8u; fwrite(&v, 4, 1, f); s = 8; fwrite(&s, 2, 1, f); s = 32; fwrite(&s, 2, 1, f);
    fwrite("data", 1, 4, f); fwrite(&data, 4, 1, f);
}

int main(int argc, char **argv) {
    size_t tn, bn, mn, i, k; unsigned char *tm, *bank, *mid; unsigned div; int patch, rc; double rate = 48000.0, tail = 2.0;
    uint64_t total, done = 0, first_free = 0; uint32_t *outl, *outr; FILE *wav, *plan = NULL; clock_t c0;
    jp8h_event ev[512]; jp8h_param par[2048];
    if (argc < 6) {
        fprintf(stderr, "usage: jp8_render <template.bin> <bank.bin> <patch 0-63> <in.mid> <out.wav> [rate=48000] [tail seconds=2] [plan.txt]\n");
        return 2;
    }
    if (argc > 6) rate = atof(argv[6]);
    if (argc > 7) tail = atof(argv[7]);
    if (argc > 8 && !(plan = fopen(argv[8], "w"))) { fprintf(stderr, "cannot write %s\n", argv[8]); return 2; }
    patch = atoi(argv[3]);
    if (patch < 0 || patch > 63 || rate < 8000.0 || tail < 0.0) { fprintf(stderr, "patch 0-63, rate >= 8000, tail >= 0\n"); return 2; }
    tm = slurp(argv[1], &tn); bank = slurp(argv[2], &bn); mid = slurp(argv[4], &mn);
    if (bn != BANK_HEADER + 64u * BANK_STRIDE) { fprintf(stderr, "%s: not the factory bank's size\n", argv[2]); return 2; }
    div = read_smf(mid, mn);
    qsort(tmp, ntmp, sizeof *tmp, cmp_tmp);
    qsort(evs, nevs, sizeof *evs, cmp_ev);
    if ((rc = jp8h_init(tm, tn, rate, BLOCK))) { fprintf(stderr, "jp8h_init: %d %s\n", rc, jp8h_error()); return 1; }
    {
        const unsigned char *rec = bank + BANK_HEADER + (size_t)patch * BANK_STRIDE;
        fprintf(stderr, "patch %d '%.*s'\n", patch, NAME_LEN, (const char *)rec);
        if ((rc = jp8h_load_patch(rec + NAME_LEN, BANK_STRIDE - NAME_LEN))) { fprintf(stderr, "patch load: %d %s\n", rc, jp8h_error()); return 1; }
    }
    total = (uint64_t)((nevs ? tick_seconds(evs[nevs - 1].tick, div) : 0.0) * rate) + (uint64_t)(tail * rate) + 1;
    outl = (uint32_t *)malloc(BLOCK * 4); outr = (uint32_t *)malloc(BLOCK * 4);
    wav = fopen(argv[5], "wb");
    if (!outl || !outr || !wav) { fprintf(stderr, "cannot write %s\n", argv[5]); return 2; }
    wav_header(wav, (uint32_t)rate, (uint32_t)total);
    c0 = clock(); k = 0;
    while (done < total) {
        int n = (int)(total - done < BLOCK ? total - done : BLOCK), ne = 0, np = 0;
        uint32_t ids[NPQ]; int nid = 0;
        for (; k < nevs; k++) {                                         /* the events inside this block */
            uint64_t at = (uint64_t)(tick_seconds(evs[k].tick, div) * rate);
            unsigned kind = evs[k].st & 0xF0, ch = evs[k].st & 0x0F; int off;
            if (at < first_free) at = first_free;                          /* a deferred event: at the block's start */
            if (at >= done + (uint64_t)n) break;
            if (ne == 512 || np == 2048) break;                            /* full: the rest waits for the next block */
            if (kind == 0xB0 || kind == 0xD0 || kind == 0xE0) {            /* a host has NPQ parameter queues per block */
                uint32_t id = kind == 0xB0 ? MIDI_BASE + evs[k].d1 : kind == 0xD0 ? MIDI_BASE + 128u : MIDI_BASE + 129u;
                int q;
                for (q = 0; q < nid && ids[q] != id; q++) {}
                if (q == nid) { if (nid == NPQ) break; ids[nid++] = id; }
            }
            off = (int)(at - done);
            if ((kind == 0x90 || kind == 0x80) && ne < 512) {
                ev[ne].on = (kind == 0x90 && evs[k].d2 > 0); ev[ne].offset = off; ev[ne].channel = (int)ch;
                ev[ne].pitch = evs[k].d1; ev[ne].velocity = (float)evs[k].d2 / 127.0f; ne++;
            } else if (kind == 0xB0 && np < 2048) {
                par[np].id = MIDI_BASE + evs[k].d1; par[np].offset = off; par[np].value = evs[k].d2 / 127.0; np++;
            } else if (kind == 0xD0 && np < 2048) {
                par[np].id = MIDI_BASE + 128u; par[np].offset = off; par[np].value = evs[k].d1 / 127.0; np++;
            } else if (kind == 0xE0 && np < 2048) {
                par[np].id = MIDI_BASE + 129u; par[np].offset = off; par[np].value = (double)(evs[k].d1 | evs[k].d2 << 7) / 16383.0; np++;
            }
        }
        if (plan) {
            int j;
            fprintf(plan, "B %d\n", n);
            for (j = 0; j < ne; j++) {
                uint32_t vb; memcpy(&vb, &ev[j].velocity, 4);
                fprintf(plan, "E %d %d %d %d %08lx\n", ev[j].on, ev[j].offset, ev[j].channel, ev[j].pitch, (unsigned long)vb);
            }
            for (j = 0; j < np; j++) {
                uint64_t qb; memcpy(&qb, &par[j].value, 8);
                fprintf(plan, "P %08lx %d %08lx%08lx\n", (unsigned long)par[j].id, par[j].offset,
                        (unsigned long)(qb >> 32), (unsigned long)(qb & 0xFFFFFFFFu));
            }
        }
        if ((rc = jp8h_process(n, ev, ne, par, np, NULL, outl, outr))) { fprintf(stderr, "process: %d %s\n", rc, jp8h_error()); return 1; }
        for (i = 0; i < (size_t)n; i++) { fwrite(&outl[i], 4, 1, wav); fwrite(&outr[i], 4, 1, wav); }
        done += (uint64_t)n; first_free = done;                      /* an event left over starts the next block */
    }
    fclose(wav);
    if (plan) fclose(plan);
    fprintf(stderr, "%.2f s of audio at %.0f Hz in %.2f s of CPU (%.0f ms per second of audio) -> %s\n",
            total / rate, rate, (double)(clock() - c0) / CLOCKS_PER_SEC,
            1000.0 * ((double)(clock() - c0) / CLOCKS_PER_SEC) / (total / rate), argv[5]);
    return 0;
}

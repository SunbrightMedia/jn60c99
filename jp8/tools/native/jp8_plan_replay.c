/* jp8_plan_replay.c -- the PORT's side of the native checks (jp8/tools/native/jp8_native_fuzz.py): a factory patch
 * through the plugin's own patch load, then a PLAN replayed through jp8h_process -- the same text the native host
 * (jp8_native_host.c: the real plugin on a CPU) and the Unicorn oracle (jp8/tools/jp8_render_check.py) replay -- and
 * every output word to a file as the native host writes it (per block: the left channel's n floats, then the right's).
 *
 *   jp8_plan_replay <template.bin> <bank.bin> <patch 0-63> <plan.txt> <rate> <maxblock> <out.bin>
 *
 * plan lines (jp8/apps/jp8_render.c writes the first three):
 *   B n                                   a block of n samples (1..maxblock); the lines up to the next B are its input
 *   E on offset channel pitch vel-bits    a note event (on 1 / off 0; the velocity a float's bits, hex)
 *   P id offset value-bits                a parameter queue point (id hex; the value a double's bits, hex)
 *   C state ppq tempo cs ce               the block's ProcessContext (state hex; the doubles' bits, hex): jp8h_ctx
 * Plumbing only: no plugin logic here. ISO C99. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include "jp8h.h"

#define BANK_HEADER 22
#define BANK_STRIDE 20223
#define NAME_LEN 16
#define MAXEV 512

static unsigned char *slurp(const char *path, size_t *n) {
    FILE *f = fopen(path, "rb"); unsigned char *b; long len;
    if (!f) { fprintf(stderr, "cannot open %s\n", path); exit(2); }
    if (fseek(f, 0, SEEK_END) || (len = ftell(f)) < 0 || fseek(f, 0, SEEK_SET)) { fprintf(stderr, "cannot size %s\n", path); exit(2); }
    b = (unsigned char *)malloc((size_t)len + 1);
    if (!b || fread(b, 1, (size_t)len, f) != (size_t)len) { fprintf(stderr, "cannot read %s\n", path); exit(2); }
    fclose(f); *n = (size_t)len; return b;
}
static double dbits(unsigned long hi, unsigned long lo) { uint64_t q = (uint64_t)hi << 32 | lo; double d; memcpy(&d, &q, 8); return d; }
/* "xxxxxxxxyyyyyyyy": a double's 16 hex digits, read as two halves (C99's scanf has no portable 64-bit hex) */
static int dhex(const char *s, double *v) {
    char hi[9], lo[9]; size_t n = strlen(s);
    if (n != 16) return 0;
    memcpy(hi, s, 8); hi[8] = 0; memcpy(lo, s + 8, 8); lo[8] = 0;
    *v = dbits(strtoul(hi, NULL, 16), strtoul(lo, NULL, 16)); return 1;
}

int main(int argc, char **argv) {
    size_t tn, bn; unsigned char *tm, *bank; int patch, maxb, rc, n = -1, nev = 0, npar = 0, cap = 0, has_ctx = 0, blocks = 0;
    double rate; FILE *plan, *out; char line[512]; uint32_t *outl, *outr;
    static jp8h_event ev[MAXEV]; jp8h_param *par = NULL; jp8h_ctx ctx;
    if (argc != 8) {
        fprintf(stderr, "usage: jp8_plan_replay <template.bin> <bank.bin> <patch 0-63> <plan.txt> <rate> <maxblock> <out.bin>\n");
        return 2;
    }
    patch = atoi(argv[3]); rate = atof(argv[5]); maxb = atoi(argv[6]);
    if (patch < 0 || patch > 63 || maxb < 1) { fprintf(stderr, "patch 0-63, maxblock >= 1\n"); return 2; }
    tm = slurp(argv[1], &tn); bank = slurp(argv[2], &bn);
    if (bn != BANK_HEADER + 64u * BANK_STRIDE) { fprintf(stderr, "%s: not the factory bank's size\n", argv[2]); return 2; }
    if ((rc = jp8h_init(tm, tn, rate, maxb))) { fprintf(stderr, "jp8h_init: %d %s\n", rc, jp8h_error()); return 1; }
    {
        const unsigned char *rec = bank + BANK_HEADER + (size_t)patch * BANK_STRIDE;
        if ((rc = jp8h_load_patch(rec + NAME_LEN, BANK_STRIDE - NAME_LEN))) { fprintf(stderr, "patch load: %d %s\n", rc, jp8h_error()); return 1; }
    }
    outl = (uint32_t *)malloc(4 * (size_t)maxb); outr = (uint32_t *)malloc(4 * (size_t)maxb);
    plan = fopen(argv[4], "r"); out = fopen(argv[7], "wb");
    if (!outl || !outr || !plan || !out) { fprintf(stderr, "cannot open the plan or the output\n"); return 2; }
    memset(&ctx, 0, sizeof ctx);
    for (;;) {
        int eof = !fgets(line, sizeof line, plan);
        if ((eof || line[0] == 'B') && n >= 0) {                     /* the block gathered so far, through process() */
            if ((rc = jp8h_process(n, ev, nev, par, npar, has_ctx ? &ctx : NULL, outl, outr))) {
                fprintf(stderr, "process (block %d): %d %s\n", blocks, rc, jp8h_error()); return 1;
            }
            fwrite(outl, 4, (size_t)n, out); fwrite(outr, 4, (size_t)n, out); blocks++;
        }
        if (eof) break;
        if (line[0] == 'B') {
            n = atoi(line + 2); nev = 0; npar = 0; has_ctx = 0;
            if (n < 0 || n > maxb) { fprintf(stderr, "block %d > maxblock %d\n", n, maxb); return 2; }
        } else if (line[0] == 'E') {
            int on, off, ch, pitch; unsigned long vb; uint32_t v32; float vel;
            if (n < 0 || nev == MAXEV || sscanf(line + 2, "%d %d %d %d %lx", &on, &off, &ch, &pitch, &vb) != 5) { fprintf(stderr, "bad E line: %s", line); return 2; }
            v32 = (uint32_t)vb; memcpy(&vel, &v32, 4);
            ev[nev].on = on; ev[nev].offset = off; ev[nev].channel = ch; ev[nev].pitch = pitch; ev[nev].velocity = vel; nev++;
        } else if (line[0] == 'P') {
            unsigned long id; int off; char vs[64]; double v;
            if (n < 0 || sscanf(line + 2, "%lx %d %63s", &id, &off, vs) != 3 || !dhex(vs, &v)) { fprintf(stderr, "bad P line: %s", line); return 2; }
            if (npar == cap) { cap = cap ? 2 * cap : 256; par = (jp8h_param *)realloc(par, sizeof *par * (size_t)cap); if (!par) return 3; }
            par[npar].id = (uint32_t)id; par[npar].offset = off; par[npar].value = v; npar++;
        } else if (line[0] == 'C') {
            unsigned long st; char a[64], b[64], c[64], d[64];
            if (n < 0 || sscanf(line + 2, "%lx %63s %63s %63s %63s", &st, a, b, c, d) != 5
                || !dhex(a, &ctx.ppq) || !dhex(b, &ctx.tempo) || !dhex(c, &ctx.cycle_start) || !dhex(d, &ctx.cycle_end)) {
                fprintf(stderr, "bad C line: %s", line); return 2;
            }
            ctx.state = (uint32_t)st; has_ctx = 1;
        } else if (line[0] != '\n' && line[0] != '#') { fprintf(stderr, "a plan line not understood: %s", line); return 2; }
    }
    fclose(out); fclose(plan);
    fprintf(stderr, "replay: %d blocks\n", blocks);
    return 0;
}

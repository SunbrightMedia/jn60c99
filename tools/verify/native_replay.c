/* native_replay.c -- the JUNO-60 plugin's OWN render code, run on THIS CPU from a state the Unicorn oracle prepared
 * (tools/verify/native_replay.py). The oracle is a model of a CPU (playbooks 220, 226, 227); this runs the same
 * machine code on the real one, so the model can be graded.
 *
 * A snapshot directory holds the oracle's memory -- the image as it stands after boot and recall, the used heap,
 * the stub page (the e2e driver stubs and their parameter blocks), the audio buffers, the low page -- one file per
 * region named by its address (hex), and meta.txt (key = value). Each region is mapped at ITS OWN address
 * (MAP_FIXED_NOREPLACE: every pointer inside stays valid). The render loop is tools/verify/e2e_emu.py's
 * E2E.render(), the harness's plumbing, line for line: per block the assigners' voice count synced and their
 * counter advanced (the plugin's own functions), each voice by the voice stub, then the master by the master stub.
 * The JX-3P's loop (jx3p/tools/jx_native_replay.py, meta asg = 0) renders all eight voices and syncs nothing.
 *   native_replay SNAPDIR FRAMES MXCSR OUT [CELLS|- [OFF:BITS | U@OFF:BITS ..]]
 *   native_replay SNAPDIR FRAMES MXCSR OUT CELLS|- --batch FILE      one scene per line, each from the snapshot
 *       writes OUT, per scene: FRAMES x (L, R) float bits, then the final bytes of the windows meta.txt lists
 *       (win / wsz) -- or, given a CELLS file (`unit offset` lines), those words instead. OFF:BITS writes BITS at OFF
 *       in all nine unit objects before the render (nan_ab.py's rule), U@OFF:BITS in unit U's (jx_nan_ab.py's).
 * MXCSR 0x9FC0 = FTZ + DAZ (the plugin in a host: JUCE's ScopedNoDenormals), 0x1FC0 = DAZ alone (what Unicorn's
 * arithmetic does with 0x9FC0: it never flushes a result, playbook 220). */
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <dirent.h>
#include <sys/mman.h>
#include <xmmintrin.h>

typedef uint64_t (__attribute__((ms_abi)) *fn2_t)(uint64_t, uint64_t);
typedef void (*stub_t)(void);

static uint64_t meta_get(const char *dir, const char *key, int idx)
{
    char path[4096], line[512], want[128];
    snprintf(path, sizeof path, "%s/meta.txt", dir);
    snprintf(want, sizeof want, idx < 0 ? "%s" : "%s%d", key, idx);
    FILE *f = fopen(path, "r");
    if (!f) { perror(path); exit(2); }
    while (fgets(line, sizeof line, f)) {
        char k[128]; unsigned long long v;
        if (sscanf(line, "%127s = %llx", k, &v) == 2 && !strcmp(k, want)) { fclose(f); return v; }
    }
    fprintf(stderr, "meta.txt: no key %s\n", want);
    exit(2);
}

static uint64_t meta_opt(const char *dir, const char *key, uint64_t dflt)
{
    char path[4096], line[512];
    snprintf(path, sizeof path, "%s/meta.txt", dir);
    FILE *f = fopen(path, "r");
    if (!f) return dflt;
    while (fgets(line, sizeof line, f)) {
        char k[128]; unsigned long long v;
        if (sscanf(line, "%127s = %llx", k, &v) == 2 && !strcmp(k, key)) { fclose(f); return v; }
    }
    fclose(f);
    return dflt;
}

static struct { uint8_t *addr, *copy; size_t n; } reg[16];
static int nreg;

static void restore_regions(void)          /* a batch: every scene starts from the snapshot as written */
{
    for (int i = 0; i < nreg; i++) memcpy(reg[i].addr, reg[i].copy, reg[i].n);
}

static void map_regions(const char *dir)
{
    DIR *d = opendir(dir);
    struct dirent *e;
    if (!d) { perror(dir); exit(2); }
    while ((e = readdir(d))) {
        unsigned long long addr;
        char path[4096];
        if (sscanf(e->d_name, "region_%llx.bin", &addr) != 1) continue;
        snprintf(path, sizeof path, "%s/%s", dir, e->d_name);
        FILE *f = fopen(path, "rb");
        fseek(f, 0, SEEK_END);
        long n = ftell(f);
        fseek(f, 0, SEEK_SET);
        size_t len = ((size_t)n + 0xFFF) & ~(size_t)0xFFF;
        void *p = mmap((void *)addr, len, PROT_READ | PROT_WRITE | PROT_EXEC,
                       MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED_NOREPLACE, -1, 0);
        if (p == MAP_FAILED || (uint64_t)p != addr) { fprintf(stderr, "cannot map %llx (+%ld)\n", addr, n); exit(2); }
        if (fread(p, 1, (size_t)n, f) != (size_t)n) { fprintf(stderr, "short read %s\n", path); exit(2); }
        fclose(f);
        if (nreg == 16) { fprintf(stderr, "too many regions\n"); exit(2); }
        reg[nreg].addr = p;
        reg[nreg].n = (size_t)n;
        reg[nreg].copy = malloc((size_t)n);
        if (!reg[nreg].copy) { fprintf(stderr, "no memory for the pristine copy\n"); exit(2); }
        memcpy(reg[nreg].copy, p, (size_t)n);
        nreg++;
    }
    closedir(d);
}

struct ctx {
    uint64_t asg, block, host, nvoff, pbv, pbm, state[9], assign[9], mainb[8], subb[8], offL, offR;
    stub_t sv, sm;
    fn2_t getc, setc;
    const char *dir, *cells;
    uint64_t n;
    unsigned mx;
};

/* one scene: its NaN words (OFF:BITS into all nine objects -- nan_ab.py's rule, the JUNO port keeps one -- or
 * U@OFF:BITS into one unit's -- jx_nan_ab.py's, the JX port keeps nine), the render, its words to `out` */
static void run_scene(struct ctx *c, char **tok, int ntok, FILE *out)
{
    for (int k = 0; k < ntok; k++) {
        char *e = tok[k];
        int unit = -1;
        if (strchr(e, '@')) { unit = (int)strtol(e, &e, 0); e++; }
        uint64_t off = strtoull(e, &e, 0);
        uint32_t bits = (uint32_t)strtoul(e + 1, 0, 0);
        for (int i = 0; i < 9; i++) if (unit < 0 || unit == i) memcpy((void *)(c->state[i] + off), &bits, 4);
    }
    _mm_setcsr(c->mx);
    for (uint64_t done = 0; done < c->n;) {
        uint64_t b = c->n - done < c->block ? c->n - done : c->block;
        int32_t nv = c->asg ? *(int32_t *)(c->host + c->nvoff) : 8;
        for (int v = 0; c->asg && v < 8; v++) {
            if ((uint32_t)c->getc(c->assign[v], 0) != (uint32_t)nv) c->setc(c->assign[v], (uint64_t)(uint32_t)nv);
            *(uint64_t *)(c->assign[v] + 168) += b;
        }
        for (int v = 0; v < 8; v++) {
            if (v >= nv) { memset((void *)c->mainb[v], 0, 4 * b); memset((void *)c->subb[v], 0, 4 * b); continue; }
            uint64_t pb[5] = { c->state[v], (uint64_t)v, c->mainb[v], c->subb[v], b };
            memcpy((void *)c->pbv, pb, sizeof pb);
            c->sv();
        }
        uint64_t pm[4 + 2 + 16] = { c->state[8], c->offL, c->offR, b, 0, 0 };
        for (int v = 0; v < 8; v++) { pm[6 + 2 * v] = c->mainb[v]; pm[7 + 2 * v] = c->subb[v]; }
        memcpy((void *)c->pbm, pm, sizeof pm);
        c->sm();
        for (uint64_t k = 0; k < b; k++) {
            fwrite((void *)(c->offL + 4 * k), 4, 1, out);
            fwrite((void *)(c->offR + 4 * k), 4, 1, out);
        }
        done += b;
    }
    _mm_setcsr(0x1F80);
    if (c->cells && strcmp(c->cells, "-")) {
        FILE *cf = fopen(c->cells, "r");
        unsigned u;
        unsigned long long off;
        if (!cf) { perror(c->cells); exit(2); }
        while (fscanf(cf, "%u %llu", &u, &off) == 2) fwrite((void *)(c->state[u] + off), 4, 1, out);
        fclose(cf);
        return;
    }
    for (int w = 0;; w++) {           /* the windows to hand back: win<i> = addr, wsz<i> = size */
        char kw[32], ks[32];
        snprintf(kw, sizeof kw, "win%d", w);
        snprintf(ks, sizeof ks, "wsz%d", w);
        uint64_t a = meta_opt(c->dir, kw, 0), sz = meta_opt(c->dir, ks, 0);
        if (!a || !sz) break;
        fwrite((void *)a, 1, sz, out);
    }
}

int main(int argc, char **argv)
{
    if (argc < 5) {
        fprintf(stderr, "usage: native_replay SNAPDIR FRAMES MXCSR OUT [CELLS|- [OFF:BITS ..] | CELLS|- --batch FILE]\n");
        return 2;
    }
    struct ctx c;
    memset(&c, 0, sizeof c);
    c.dir = argv[1];
    c.n = strtoull(argv[2], 0, 0);
    c.mx = (unsigned)strtoul(argv[3], 0, 0);
    c.cells = argc > 5 ? argv[5] : 0;   /* a file of `unit offset` lines: write those words, not the windows */
    map_regions(c.dir);
    /* asg = 1: the JUNO loop (each block syncs the assigners' voice count and advances their counter, a unit at
     * or above the count renders silence); asg = 0: the JX-3P's (tools/verify/jx_emu.py JX.render: all 8 voices) */
    c.asg = meta_opt(c.dir, "asg", 1);
    c.block = meta_get(c.dir, "block", -1);
    if (c.asg) {
        c.host = meta_get(c.dir, "HOST", -1);
        c.nvoff = meta_get(c.dir, "HOST_NVOICE", -1);
        c.getc = (fn2_t)meta_get(c.dir, "ASG_GET_COUNT", -1);
        c.setc = (fn2_t)meta_get(c.dir, "ASG_SET_COUNT", -1);
    }
    c.pbv = meta_get(c.dir, "PB_VOICE", -1);
    c.pbm = meta_get(c.dir, "PB_MASTER", -1);
    c.sv = (stub_t)meta_get(c.dir, "SVOICE", -1);
    c.sm = (stub_t)meta_get(c.dir, "SMASTER", -1);
    for (int i = 0; i < 9; i++) { c.state[i] = meta_get(c.dir, "state", i); if (c.asg) c.assign[i] = meta_get(c.dir, "assign", i); }
    uint64_t p = meta_get(c.dir, "BUF_BASE", -1);
    for (int v = 0; v < 8; v++) { c.mainb[v] = p; p += 4 * c.block; c.subb[v] = p; p += 4 * c.block; }
    c.offL = p; p += 4 * c.block; c.offR = p;
    FILE *out = fopen(argv[4], "wb");
    if (!out) { perror(argv[4]); return 2; }
    if (argc > 7 && !strcmp(argv[6], "--batch")) {   /* one scene per line, each from the snapshot as written */
        FILE *bf = fopen(argv[7], "r");
        char line[8192];
        if (!bf) { perror(argv[7]); return 2; }
        while (fgets(line, sizeof line, bf)) {
            char *tok[256];
            int nt = 0;
            for (char *t = strtok(line, " \t\r\n"); t && nt < 256; t = strtok(0, " \t\r\n")) tok[nt++] = t;
            restore_regions();
            run_scene(&c, tok, nt, out);
        }
        fclose(bf);
    } else {
        run_scene(&c, argv + 6, argc > 6 ? argc - 6 : 0, out);
    }
    fclose(out);
    return 0;
}

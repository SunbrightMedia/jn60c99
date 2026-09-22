/* bootdrv.c -- SCRATCH probe (not a gate): replay the layer-3 boot drive on the lifted C twin from the
 * post-static-init dumps, check it reproduces the gate's words + heap, then time each boot step and run a long
 * idle + note window with NO snap to see what the no-snap hosted boot sounds like.
 * usage: bootdrv <refdir> <vals.txt> <recall patch> <build_mxcsr_hex> <idle_n> [dumpwords.bin] */
#include "/home/user/jn60c99/jp8/src/jp8_cpu.h"
#include <time.h>
int jp8_map(uint64_t base, uint64_t size); int jp8_load(uint64_t base, const char *path);
int jp8_call(CPU *c, uint64_t rva, uint64_t rcx, uint64_t rdx, uint64_t r8, uint64_t r9);
int jp8_call_f(CPU *c, uint64_t rva, uint64_t rcx, float f);
const char *jp8_last_trap(void); void jp8_heap_set(uint64_t, uint64_t); void jp8_hc_set(uint64_t); uint64_t jp8_heap_get(void);
void jp8_alloc(CPU *c);
#define IMG 0x180000000ULL
#define HEAP 0x310000000ULL
#define STK 0x200000000ULL
#define STKSZ 0x2000000ULL
#define BUF 0x700000000ULL
#define BUFSZ 0x400000ULL
#define GS (BUF+0x20000)
#define PAIR_V (BUF+0x100)
#define OUT_M (BUF+0x200)
#define OUT_S (BUF+0x204)
#define PAIR_M (BUF+0x300)
#define OUT_L (BUF+0x400)
#define OUT_R (BUF+0x404)
#define A2 (BUF+0x500)
#define VOUT (BUF+0x600)
#define VOICE_WRAP 0x3F80B0
#define MASTER_WRAP 0x3F8040
#define NOTEON 0x445CF0
#define NOTEOFF 0x445C90
#define DISPATCH 0x437630
#define ASG_NOTIFY 0x37CD80
#define BUILD 0x445020
#define SETSR 0x4464F0
#define HOSTPARAM 0x4465B0
static CPU cpu; static uint64_t st[9], pr[9], as[9], host, rsp0; static uint32_t mx = 0x9FC0;
static unsigned char *words; static size_t nw, cap;
static double now(void) { struct timespec t; clock_gettime(CLOCK_MONOTONIC, &t); return t.tv_sec + 1e-9 * t.tv_nsec; }
static void wq(uint64_t a, uint64_t v) { memcpy((void *)(uintptr_t)a, &v, 8); }
static uint64_t rq(uint64_t a) { uint64_t v; memcpy(&v, (void *)(uintptr_t)a, 8); return v; }
static void call(uint64_t rva, uint64_t rcx, uint64_t rdx, uint64_t r8, uint64_t r9) {
    cpu.r[4] = rsp0; cpu.mxcsr = mx;
    if (jp8_call(&cpu, rva, rcx, rdx, r8, r9)) { fprintf(stderr, "%s\n", jp8_last_trap()); exit(2); }
}
static float peakL, peakD; static long nanL;
static void sample(void) {
    int v; float d = 0, l, r;
    for (v = 0; v < 8; v++) {
        wq(OUT_M, 0); wq(PAIR_V, OUT_M); wq(PAIR_V + 8, OUT_S);
        call(VOICE_WRAP, st[v], v, PAIR_V, 0);
        if (words && nw + 8 <= cap) memcpy(words + nw, (void *)(uintptr_t)OUT_M, 8), nw += 8;
        memcpy((void *)(uintptr_t)(VOUT + 8 * v), (void *)(uintptr_t)OUT_M, 8);
        { float m; memcpy(&m, (void *)(uintptr_t)OUT_M, 4); if (m == m) d += m; }
    }
    wq(OUT_L, 0); wq(PAIR_M, OUT_L); wq(PAIR_M + 8, OUT_R);
    call(MASTER_WRAP, st[8], A2, PAIR_M, 0);
    if (words && nw + 8 <= cap) memcpy(words + nw, (void *)(uintptr_t)OUT_L, 8), nw += 8;
    memcpy(&l, (void *)(uintptr_t)OUT_L, 4); memcpy(&r, (void *)(uintptr_t)OUT_R, 4);
    if (l != l || r != r) nanL++; else { if (fabsf(l) > peakL) peakL = fabsf(l); if (fabsf(r) > peakL) peakL = fabsf(r); }
    if (fabsf(d) > peakD) peakD = fabsf(d);
}
static unsigned char *slurp(const char *p, size_t *n) {
    FILE *f = fopen(p, "rb"); long L; unsigned char *b; if (!f) { perror(p); exit(1); }
    fseek(f, 0, SEEK_END); L = ftell(f); fseek(f, 0, SEEK_SET); b = malloc(L); if (fread(b, 1, L, f) != (size_t)L) exit(1); fclose(f); *n = L; return b;
}
int main(int argc, char **argv) {
    char p[512]; const char *d = argv[1]; int rp = atoi(argv[3]); uint32_t bmx = (uint32_t)strtoul(argv[4], 0, 16); long idle = atol(argv[5]);
    int nh, i, u, s; int hid[16], hval[16]; int pid[128], pval[128], np = 0; size_t n, hn; double t0;
    FILE *vf = fopen(argv[2], "r"); if (fscanf(vf, "%d", &nh) != 1) return 1;
    for (i = 0; i < nh; i++) if (fscanf(vf, "%d %d", &hid[i], &hval[i]) != 2) return 1;
    for (;;) { int pp, k; if (fscanf(vf, "%d %d", &pp, &k) != 2) break;
        for (i = 0; i < k; i++) { int a, b; if (fscanf(vf, "%d %d", &a, &b) != 2) return 1; if (pp == rp) { pid[np] = a; pval[np] = b; np++; } } }
    fclose(vf); if (!np) { fprintf(stderr, "patch %d not in vals\n", rp); return 1; }
    uint64_t heap_ptr0 = 13153535136ULL, hc0 = 36896; rsp0 = 8623423488ULL;
    if (jp8_map(IMG, 14577664) || jp8_map(HEAP, 0x8000000) || jp8_map(STK, STKSZ) || jp8_map(BUF, BUFSZ)) return 1;
    snprintf(p, sizeof p, "%s/img.bin", d); jp8_load(IMG, p);
    snprintf(p, sizeof p, "%s/heap_pre.bin", d); jp8_load(HEAP, p);
    snprintf(p, sizeof p, "%s/stack.bin", d); jp8_load(STK, p);
    { unsigned char *pg; snprintf(p, sizeof p, "%s/page0.bin", d); pg = slurp(p, &n); memcpy((void *)(uintptr_t)GS, pg, n); free(pg); }
    jp8_heap_set(heap_ptr0, HEAP + 0x8000000); jp8_hc_set(hc0);
    for (u = 0; u < 8; u++) { wq(A2 + 16 * u, VOUT + 8 * u); wq(A2 + 16 * u + 8, VOUT + 8 * u + 4); }
    cpu.r[1] = 0x8000; jp8_alloc(&cpu); host = cpu.r[0];
    printf("host 0x%llx (oracle 0x%llx)\n", (unsigned long long)host, (unsigned long long)heap_ptr0);
    mx = bmx; t0 = now(); call(BUILD, host, 0, 0, 0); printf("BUILD @%04x: %.3f s, heap used %.1f MB\n", bmx, now() - t0, (jp8_heap_get() - HEAP) / 1e6);
    mx = 0x9FC0;
    for (u = 0; u < 9; u++) { st[u] = rq(host + 0xA0 + 64 * u); pr[u] = rq(host + 0xB0 + 64 * u); as[u] = rq(host + 0xB8 + 64 * u); }
    t0 = now(); cpu.r[4] = rsp0; cpu.mxcsr = mx; if (jp8_call_f(&cpu, SETSR, host, 44100.0f)) { fprintf(stderr, "%s\n", jp8_last_trap()); return 2; }
    printf("SETSR: %.3f s\n", now() - t0);
    t0 = now(); for (i = 0; i < nh; i++) call(HOSTPARAM, host, hid[i], hval[i], 0); printf("host_init (%d writes): %.4f s\n", nh, now() - t0);
    t0 = now(); for (u = 0; u < 9; u++) for (i = 0; i < np; i++) call(DISPATCH, pr[u], pid[i], 0, pval[i]);
    for (u = 0; u < 9; u++) call(ASG_NOTIFY, as[u], 4, 0, 0);
    printf("recall patch %d (%d pools x 9 + notify x 9): %.4f s\n", rp, np, now() - t0);
    cap = 2328 * 72; words = malloc(cap); nw = 0;
    t0 = now(); for (s = 0; s < 2200; s++) sample(); call(NOTEON, host, 60, 100, 0); for (s = 0; s < 64; s++) sample();
    call(NOTEOFF, host, 60, 64, 0); for (s = 0; s < 64; s++) sample();
    printf("gate drive 2328 samples: %.3f s (%.2f us/sample)\n", now() - t0, 1e6 * (now() - t0) / 2328);
    snprintf(p, sizeof p, "%s/words.bin", d);
    { unsigned char *ref = slurp(p, &n); long bad = 0; for (i = 0; i < (int)(n / 4); i++) if (memcmp(ref + 4 * i, words + 4 * i, 4)) bad++;
      snprintf(p, sizeof p, "%s/heap_post.bin", d); unsigned char *post = slurp(p, &hn); size_t hd = 0, k; unsigned char *h = (unsigned char *)(uintptr_t)HEAP;
      for (k = 0; k < hn; k += 4) if (memcmp(post + k, h + k, 4)) hd++;
      printf("vs gate reference: %zu words, %ld differ; heap %zu dwords differ -> %s\n", n / 4, bad, hd, (!bad && !hd) ? "EXACTLY 0 (driver = gate drive)" : "DIFFERS");
      free(ref); free(post); }
    free(words); words = 0;
    /* continue: long idle, then a note, NO snap -- windowed peaks */
    { long w; int win = 1000; for (w = 0; w < idle; w += win) { peakL = peakD = 0; nanL = 0; for (s = 0; s < win; s++) sample();
          if (w % 4000 == 0 || w + win >= idle) printf("  idle %6ld..%6ld: master peak %.4g dry peak %.4g NaN %ld\n", w, w + win, peakL, peakD, nanL); } }
    call(NOTEON, host, 60, 100, 0);
    peakL = peakD = 0; nanL = 0; t0 = now(); for (s = 0; s < 8192; s++) sample();
    printf("  note 60 8192: master peak %.4g dry peak %.4g NaN %ld  (%.2f us/sample)\n", peakL, peakD, nanL, 1e6 * (now() - t0) / 8192);
    call(NOTEOFF, host, 60, 64, 0);
    for (i = 0; i < 4; i++) { peakL = peakD = 0; nanL = 0; for (s = 0; s < 4096; s++) sample(); printf("  release win %d: master peak %.4g dry peak %.4g NaN %ld\n", i, peakL, peakD, nanL); }
    return 0;
}

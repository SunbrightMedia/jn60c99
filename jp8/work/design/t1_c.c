/* t1_c.c -- SCRATCH probe, process B (C only): the lifted C twin driven through the proposed shipping order (T1),
 * from the POST-STATIC-INIT dumps: BUILD -> FTZ -> SETSR -> host_init -> SNAP (latch live) -> recall(5) -> render,
 * note-on 60, render, note-off 60, render. Two render orders:
 *   mode A: the jp8_emu stubs' semantics (voice-major 256-blocks, buffers + PB blocks at the oracle's guest addresses,
 *           wrappers entered at the stub's rsp) -- what the shipping jp8_render() would do;
 *   mode B: sample-major (all 8 voices then the master per sample, layer-gate buffers) -- the independence test.
 * Compares every word with the oracle probe (t1_emu.py) and the final heap.
 * usage: t1_c <dumpdir(post-static-init)> <vals.txt> <oracle_outdir> <A|B> [snap_tooth] */
#include "/home/user/jn60c99/jp8/src/jp8_cpu.h"
int jp8_map(uint64_t base, uint64_t size); int jp8_load(uint64_t base, const char *path);
int jp8_call(CPU *c, uint64_t rva, uint64_t rcx, uint64_t rdx, uint64_t r8, uint64_t r9);
int jp8_call_f(CPU *c, uint64_t rva, uint64_t rcx, float f);
const char *jp8_last_trap(void); void jp8_heap_set(uint64_t, uint64_t); void jp8_hc_set(uint64_t); uint64_t jp8_heap_get(void);
void jp8_alloc(CPU *c);
#define HEAP 0x310000000ULL
#define BUF 0x700000000ULL
#define GS (BUF + 0x20000)
#define STUB_PAGE 0x60000A000ULL
#define PB_VOICE 0x60000A000ULL
#define PB_MASTER 0x60000A100ULL
#define RSP_DIRECT 0x201FF0000ULL     /* jp8_emu.call: entry rsp = this - 8 */
#define RSP_STUB   0x201FEFFC0ULL     /* _run: rsp 0x201FEFFF8, push rbp, sub 0x30, call -> entry 0x201FEFFB8 */
#define BLOCK 256
static CPU cpu; static uint64_t st[9], pr[9], as[9], host;
static unsigned char *words; static size_t nw;
static void wq(uint64_t a, uint64_t v) { memcpy((void *)(uintptr_t)a, &v, 8); }
static uint64_t rq(uint64_t a) { uint64_t v; memcpy(&v, (void *)(uintptr_t)a, 8); return v; }
static void call_at(uint64_t rsp, uint64_t rva, uint64_t rcx, uint64_t rdx, uint64_t r8, uint64_t r9) {
    cpu.r[4] = rsp; cpu.mxcsr = 0x9FC0;
    if (jp8_call(&cpu, rva, rcx, rdx, r8, r9)) { fprintf(stderr, "%s\n", jp8_last_trap()); exit(2); }
}
#define call(rva, a, b, c_, d) call_at(RSP_DIRECT, rva, a, b, c_, d)
static void snap(int tooth) {  /* jp8_emu.snap_ramps, verbatim law (latch NOT cleared) */
    int u; for (u = 0; u < 9; u++) { uint64_t s = st[u], arr = rq(s + 0x58), b0 = rq(s + 0x70), e0 = rq(s + 0x78); long n = (long)(e0 - b0) / 4, i;
        if (tooth && u == 8) n--;
        for (i = 0; i < n; i++) { int32_t id; uint64_t a, t; memcpy(&id, (void *)(uintptr_t)(b0 + 4 * i), 4); a = arr + 40 * (uint64_t)id; t = rq(a);
            if (t) memcpy((void *)(uintptr_t)t, (void *)(uintptr_t)(a + 0x14), 4);
            memset((void *)(uintptr_t)(a + 0xC), 0, 4); *(uint8_t *)(uintptr_t)(a + 0x1C) = 0; }
        wq(s + 0x78, b0); } }
/* mode A: the stubs, byte for byte in effect */
static uint64_t offs_m(int v) { return BUF + (uint64_t)(2 * v) * 4 * BLOCK; }
static uint64_t offs_s(int v) { return BUF + (uint64_t)(2 * v + 1) * 4 * BLOCK; }
#define OFF_L (BUF + 16ULL * 4 * BLOCK)
#define OFF_R (BUF + 17ULL * 4 * BLOCK)
static void render_A(int n) {
    int done = 0;
    while (done < n) {
        int b = n - done < BLOCK ? n - done : BLOCK, v, s, k;
        for (v = 0; v < 8; v++) {                 /* voice stub: PB = {state, v, pMain, pSub, count}, a3 at PB+0x28 */
            uint64_t pm = offs_m(v), ps = offs_s(v);
            wq(PB_VOICE, st[v]); wq(PB_VOICE + 8, v); wq(PB_VOICE + 0x20, b);
            for (s = 0; s < b; s++) {
                wq(PB_VOICE + 0x10, pm + 4 * s); wq(PB_VOICE + 0x18, ps + 4 * s); wq(PB_VOICE + 0x20, b - s);
                wq(PB_VOICE + 0x28, pm + 4 * s); wq(PB_VOICE + 0x30, ps + 4 * s);
                call_at(RSP_STUB, 0x3F80B0, st[v], v, PB_VOICE + 0x28, 0);
            }
            wq(PB_VOICE + 0x10, pm + 4 * b); wq(PB_VOICE + 0x18, ps + 4 * b); wq(PB_VOICE + 0x20, 0);
        }
        wq(PB_MASTER, st[8]);                     /* master stub: {state8, pL, pR, count, a3[2], a2[16]} */
        for (s = 0; s < b; s++) {
            wq(PB_MASTER + 8, OFF_L + 4 * s); wq(PB_MASTER + 0x10, OFF_R + 4 * s); wq(PB_MASTER + 0x18, b - s);
            wq(PB_MASTER + 0x20, OFF_L + 4 * s); wq(PB_MASTER + 0x28, OFF_R + 4 * s);
            for (k = 0; k < 8; k++) { wq(PB_MASTER + 0x30 + 16 * k, offs_m(k) + 4 * s); wq(PB_MASTER + 0x38 + 16 * k, offs_s(k) + 4 * s); }
            call_at(RSP_STUB, 0x3F8040, st[8], PB_MASTER + 0x30, PB_MASTER + 0x20, 0);
        }
        for (k = 0; k < 8; k++) { wq(PB_MASTER + 0x30 + 16 * k, offs_m(k) + 4 * b); wq(PB_MASTER + 0x38 + 16 * k, offs_s(k) + 4 * b); }
        wq(PB_MASTER + 8, OFF_L + 4 * b); wq(PB_MASTER + 0x10, OFF_R + 4 * b); wq(PB_MASTER + 0x18, 0);
        for (s = 0; s < b; s++) {
            for (v = 0; v < 8; v++) { memcpy(words + nw, (void *)(uintptr_t)(offs_m(v) + 4 * s), 4); memcpy(words + nw + 4, (void *)(uintptr_t)(offs_s(v) + 4 * s), 4); nw += 8; }
            memcpy(words + nw, (void *)(uintptr_t)(OFF_L + 4 * s), 4); memcpy(words + nw + 4, (void *)(uintptr_t)(OFF_R + 4 * s), 4); nw += 8;
        }
        done += b;
    }
}
/* mode B: sample-major, layer-gate buffers (jp8_lift_seq) */
#define PAIR_V (BUF+0x8100)
#define OUT_M (BUF+0x8200)
#define OUT_S (BUF+0x8204)
#define PAIR_M (BUF+0x8300)
#define OUT_L (BUF+0x8400)
#define OUT_R (BUF+0x8404)
#define A2 (BUF+0x8500)
#define VOUT (BUF+0x8600)
static void render_B(int n) {
    int s, v;
    for (v = 0; v < 8; v++) { wq(A2 + 16 * v, VOUT + 8 * v); wq(A2 + 16 * v + 8, VOUT + 8 * v + 4); }
    for (s = 0; s < n; s++) {
        for (v = 0; v < 8; v++) {
            wq(PAIR_V, OUT_M); wq(PAIR_V + 8, OUT_S);
            call(0x3F80B0, st[v], v, PAIR_V, 0);
            memcpy(words + nw, (void *)(uintptr_t)OUT_M, 8); nw += 8;
            memcpy((void *)(uintptr_t)(VOUT + 8 * v), (void *)(uintptr_t)OUT_M, 8);
        }
        wq(PAIR_M, OUT_L); wq(PAIR_M + 8, OUT_R);
        call(0x3F8040, st[8], A2, PAIR_M, 0);
        memcpy(words + nw, (void *)(uintptr_t)OUT_L, 8); nw += 8;
    }
}
static unsigned char *slurp(const char *p, size_t *n) {
    FILE *f = fopen(p, "rb"); long L; unsigned char *b; if (!f) { perror(p); exit(1); }
    fseek(f, 0, SEEK_END); L = ftell(f); fseek(f, 0, SEEK_SET); b = malloc(L); if (fread(b, 1, L, f) != (size_t)L) exit(1); fclose(f); *n = L; return b;
}
int main(int argc, char **argv) {
    char p[600]; const char *d = argv[1], *od = argv[3]; int modeA = argv[4][0] == 'A', tooth = argc > 5 ? atoi(argv[5]) : 0;
    int nh, i, u, np = 0, idle, on, off; int hid[16], hval[16], pid[128], pval[128]; size_t n; unsigned long long hend; char hsha[64];
    FILE *vf = fopen(argv[2], "r"); if (fscanf(vf, "%d", &nh) != 1) return 1;
    for (i = 0; i < nh; i++) if (fscanf(vf, "%d %d", &hid[i], &hval[i]) != 2) return 1;
    for (;;) { int pp, k; if (fscanf(vf, "%d %d", &pp, &k) != 2) break; for (i = 0; i < k; i++) { int a, b; if (fscanf(vf, "%d %d", &a, &b) != 2) return 1; if (pp == 5) { pid[np] = a; pval[np] = b; np++; } } }
    fclose(vf);
    snprintf(p, sizeof p, "%s/meta.txt", od); vf = fopen(p, "r"); if (!vf || fscanf(vf, "%d %d %d %llu %63s", &idle, &on, &off, &hend, hsha) != 5) { fprintf(stderr, "no oracle meta\n"); return 1; } fclose(vf);
    if (jp8_map(0x180000000ULL, 14577664) || jp8_map(HEAP, 0x8000000) || jp8_map(0x200000000ULL, 0x2000000) || jp8_map(BUF, 0x400000) || jp8_map(STUB_PAGE, 0x1000)) return 1;
    snprintf(p, sizeof p, "%s/img.bin", d); jp8_load(0x180000000ULL, p);
    snprintf(p, sizeof p, "%s/heap_pre.bin", d); jp8_load(HEAP, p);
    snprintf(p, sizeof p, "%s/stack.bin", d); jp8_load(0x200000000ULL, p);
    { unsigned char *pg; snprintf(p, sizeof p, "%s/page0.bin", d); pg = slurp(p, &n); memcpy((void *)(uintptr_t)GS, pg, n); free(pg); }
    jp8_heap_set(13153535136ULL, HEAP + 0x8000000); jp8_hc_set(36896);
    cpu.r[1] = 0x8000; jp8_alloc(&cpu); host = cpu.r[0];
    call(0x445020, host, 0, 0, 0);                                   /* BUILD (MXCSR 0x9FC0 here; C-twin probe: same heap at 0x1F80) */
    for (u = 0; u < 9; u++) { st[u] = rq(host + 0xA0 + 64 * u); pr[u] = rq(host + 0xB0 + 64 * u); as[u] = rq(host + 0xB8 + 64 * u); }
    cpu.r[4] = RSP_DIRECT; cpu.mxcsr = 0x9FC0; if (jp8_call_f(&cpu, 0x4464F0, host, 44100.0f)) return 2;
    for (i = 0; i < nh; i++) call(0x4465B0, host, hid[i], hval[i], 0);
    snap(tooth);
    for (u = 0; u < 9; u++) for (i = 0; i < np; i++) call(0x437630, pr[u], pid[i], 0, pval[i]);
    for (u = 0; u < 9; u++) call(0x37CD80, as[u], 4, 0, 0);
    words = malloc((size_t)(idle + on + off) * 72); nw = 0;
    if (modeA) { render_A(idle); call(0x445CF0, host, 60, 100, 0); render_A(on); call(0x445C90, host, 60, 64, 0); render_A(off); }
    else { render_B(idle); call(0x445CF0, host, 60, 100, 0); render_B(on); call(0x445C90, host, 60, 64, 0); render_B(off); }
    { unsigned char *ref, *he; size_t rn, hn, k, hd = 0; long bad = 0, first = -1;
      snprintf(p, sizeof p, "%s/words.bin", od); ref = slurp(p, &rn);
      for (k = 0; k < rn && k < nw; k += 4) if (memcmp(ref + k, words + k, 4)) { if (first < 0) first = (long)(k / 4); bad++; }
      snprintf(p, sizeof p, "%s/heap_end.bin", od); he = slurp(p, &hn);
      for (k = 0; k < hn; k += 4) if (memcmp(he + k, (void *)(uintptr_t)(HEAP + k), 4)) { if (hd < 3) fprintf(stderr, "  heap+0x%zx oracle %08x C %08x\n", k, *(uint32_t *)(he + k), *(uint32_t *)(uintptr_t)(HEAP + k)); hd++; }
      printf("mode %s%s: %zu words vs oracle %zu, %ld differ (first word %ld = sample %ld slot %ld); heap ptr C 0x%llx oracle 0x%llx; heap %zu dwords differ -> %s\n",
             modeA ? "A (stubs)" : "B (sample-major)", tooth ? " SNAP TOOTH" : "", nw / 4, rn / 4, bad, first, first < 0 ? -1 : first / 18, first < 0 ? -1 : first % 18,
             (unsigned long long)jp8_heap_get(), hend, hd, (!bad && nw == rn && !hd && jp8_heap_get() == hend) ? "EXACTLY 0" : "DIFFERS"); }
    return 0;
}

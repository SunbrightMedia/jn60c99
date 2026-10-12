/* jp8_rt.c -- runtime for the lifted code: the trap, the address-space loader (the oracle's regions mapped at the
 * SAME virtual addresses, MAP_FIXED_NOREPLACE, then the dumps loaded), FTZ/DAZ, and the entry the gate calls. */
#if !defined(JP8_RELOC) || defined(JP8_FLAT)
#define _GNU_SOURCE
#endif
#include "jp8_cpu.h"
#if !defined(JP8_RELOC) || (defined(JP8_FLAT) && !defined(_WIN32))
#include <sys/mman.h>
#endif
#if defined(JP8_FLAT) && defined(_WIN32)
#include <windows.h>
#endif
#include <setjmp.h>
#include <errno.h>

static JP8_TLS jmp_buf jp8_jb; static JP8_TLS int jp8_jb_set;        /* per thread under JP8H_THREADS (jp8_cpu.h) */
static JP8_TLS char jp8_trap_msg[256];
void jp8_trap(CPU *c, uint64_t rva, const char *what) {
    c->trap_rva = rva; snprintf(jp8_trap_msg, sizeof jp8_trap_msg, "TRAP at rva 0x%llx: %s", (unsigned long long)rva, what);
    if (jp8_jb_set) longjmp(jp8_jb, 1);
    fprintf(stderr, "%s\n", jp8_trap_msg); abort();
}
const char *jp8_last_trap(void) { return jp8_trap_msg; }
static FILE *jp8_trf;
void jp8_trace_open(const char *path) { jp8_trf = fopen(path, "wb"); }
void jp8_trace_close(void) { if (jp8_trf) fclose(jp8_trf); jp8_trf = 0; }
void jp8_tr(CPU *c, uint64_t rva) {
    c->ninstr++;
    if (jp8_trf) { uint32_t r = (uint32_t)rva; fwrite(&r, 4, 1, jp8_trf); fwrite(&c->r[0], 8, 4, jp8_trf); fwrite(&c->x[0], 4, 1, jp8_trf); }
}

#ifdef JP8_RELOC
/* RELOCATED guest memory: one host arena per guest region, found through a 256 MB band table. A region may not cross
 * a band edge and a band holds one region (the oracle's regions: page 0 -> band 0x00, image 0x18, stack 0x20,
 * heap 0x31, BUF 0x70; import stubs 0x60 are call targets only). Guest pointer VALUES never change, so every dump,
 * template and heap compare stays byte-identical to the oracle's. */
uintptr_t jp8_bdelta[JP8_NBANDS]; uint32_t jp8_blo[JP8_NBANDS], jp8_bhi[JP8_NBANDS];
#ifdef JP8_FLAT
/* FLAT: ONE host reservation spans every band (32 GB of address space, nothing committed), so host = guest + jp8_flat
 * for every region and the lifted code adds one register instead of loading a band's delta (playbook 232). A region is
 * committed read-write in place; fresh pages read zero, as calloc's do. */
uintptr_t jp8_flat; static unsigned char *jp8_flat_base;
int jp8_map(uint64_t base, uint64_t size) {          /* FLAT: a region may span bands (one offset for all) */
    uint64_t i = base >> 28, last = (base + size - 1) >> 28, sz = (size + 4095) & ~4095ULL, k;
    if (!size || (base & 4095) || last >= JP8_NBANDS) { fprintf(stderr, "jp8_map(0x%llx, 0x%llx): outside the bands\n", (unsigned long long)base, (unsigned long long)size); return -1; }
    for (k = i; k <= last; k++) if (jp8_bhi[k]) { fprintf(stderr, "jp8_map(0x%llx, 0x%llx): band 0x%llx in use\n", (unsigned long long)base, (unsigned long long)size, (unsigned long long)k); return -1; }
    if (!jp8_flat_base) {
        size_t span = (size_t)JP8_NBANDS << 28; void *p;
#ifdef _WIN32
        p = VirtualAlloc(NULL, span, MEM_RESERVE, PAGE_NOACCESS);
#else
        p = mmap(NULL, span, PROT_NONE, MAP_PRIVATE | MAP_ANONYMOUS | MAP_NORESERVE, -1, 0);
        if (p == MAP_FAILED) p = NULL;
#endif
        if (!p) { fprintf(stderr, "jp8_map: cannot reserve the flat span\n"); return -1; }
        jp8_flat_base = (unsigned char *)p; jp8_flat = (uintptr_t)p;
    }
#ifdef _WIN32
    if (!VirtualAlloc(jp8_flat_base + base, (size_t)sz, MEM_COMMIT, PAGE_READWRITE)) return -1;
#else
    if (mprotect(jp8_flat_base + base, (size_t)sz, PROT_READ | PROT_WRITE)) return -1;
#endif
    for (k = i; k <= last; k++) {                    /* each band: its slice of the region (lo..hi within the band) */
        uint64_t b0 = k << 28, lo = base > b0 ? base - b0 : 0, hi = (base + size < b0 + 0x10000000ULL) ? base + size - b0 : 0x10000000ULL;
        jp8_bdelta[k] = jp8_flat; jp8_blo[k] = (uint32_t)lo; jp8_bhi[k] = (uint32_t)hi;
    }
    return 0;
}
#else
static void *jp8_braw[JP8_NBANDS];
int jp8_map(uint64_t base, uint64_t size) {
    uint64_t i = base >> 28; unsigned char *raw, *h;
    if (!size || i >= JP8_NBANDS || ((base + size - 1) >> 28) != i || jp8_bhi[i]) { fprintf(stderr, "jp8_map(0x%llx, 0x%llx): not one free band\n", (unsigned long long)base, (unsigned long long)size); return -1; }
    raw = (unsigned char *)calloc(1, (size_t)size + 4096); if (!raw) return -1;
    h = raw + ((4096 - ((uintptr_t)raw & 4095)) & 4095);        /* host address == guest address mod 4096 (base is page aligned) */
    jp8_braw[i] = raw; jp8_bdelta[i] = (uintptr_t)h - (uintptr_t)base;
    jp8_blo[i] = (uint32_t)(base & 0x0FFFFFFFu); jp8_bhi[i] = jp8_blo[i] + (uint32_t)size; return 0;
}
#endif
void *jp8_host(uint64_t a) { return JP8_H(a, 1); }      /* for harnesses: guest -> host */
static JP8_TLS CPU *jp8_cur; JP8_TLS uint32_t jp8_badacc; unsigned char jp8_sink[64];
void jp8_fault(uint64_t a, unsigned n) {
    static char msg[80]; snprintf(msg, sizeof msg, "guest access 0x%llx (%u bytes) outside every mapped region", (unsigned long long)a, n);
    if (jp8_cur) jp8_trap(jp8_cur, 0, msg);
    fprintf(stderr, "%s\n", msg); abort();
}
static int jp8_span_ok(uint64_t a, uint64_t n) {       /* [a, a+n) mapped, at one delta (it may span bands: JP8_FLAT) */
    uint64_t i = a >> 28, last = (a + n - 1) >> 28, k;
    if (!n || last >= JP8_NBANDS) return 0;
    for (k = i; k <= last; k++) {
        uint64_t lo = k == i ? (a & 0x0FFFFFFFu) : 0, hi = k == last ? ((a + n - 1) & 0x0FFFFFFFu) + 1 : 0x10000000ULL;
        if (!jp8_bhi[k] || lo < jp8_blo[k] || hi > jp8_bhi[k] || jp8_bdelta[k] != jp8_bdelta[i]) return 0;
    }
    return 1;
}
#else
/* map [base, base+size) at exactly base; returns 0 on success */
int jp8_map(uint64_t base, uint64_t size) {
    void *p = mmap((void *)(uintptr_t)base, (size_t)size, PROT_READ | PROT_WRITE,
                   MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED_NOREPLACE, -1, 0);
    if (p == MAP_FAILED) { fprintf(stderr, "jp8_map(0x%llx, 0x%llx) failed: %s\n", (unsigned long long)base, (unsigned long long)size, strerror(errno)); return -1; }
    if ((uint64_t)(uintptr_t)p != base) { fprintf(stderr, "jp8_map: got %p not 0x%llx\n", p, (unsigned long long)base); munmap(p, (size_t)size); return -1; }
    return 0;
}
#endif
/* load a raw dump file into [base, base+len) */
int jp8_load(uint64_t base, const char *path) {
    FILE *f = fopen(path, "rb"); if (!f) { fprintf(stderr, "jp8_load: cannot open %s\n", path); return -1; }
    size_t n = 0, k; char *p = (char *)JP8_H(base, 1);
#ifdef JP8_RELOC
    { long L; fseek(f, 0, SEEK_END); L = ftell(f); fseek(f, 0, SEEK_SET); if (!jp8_span_ok(base, (uint64_t)L)) { fclose(f); fprintf(stderr, "jp8_load: %s does not fit its region\n", path); return -1; } }
#endif
    while ((k = fread(p + n, 1, 1 << 20, f)) > 0) n += k;
    fclose(f); return (int)(n >> 20);
}
#ifndef JP8_SOFTFP
void jp8_set_ftz(void) { _mm_setcsr(0x9FC0); }
#endif

/* the oracle's bump allocator (jp8_emu.JX.bump): 16-byte rounding, min 16, cap 0x2000000, zero-filled */
static uint64_t jp8_heap_ptr, jp8_heap_lim; static uint64_t jp8_hc = 0x9000;
void jp8_heap_set(uint64_t ptr, uint64_t lim) { jp8_heap_ptr = ptr; jp8_heap_lim = lim; jp8_hc = 0x9000; }
void jp8_hc_set(uint64_t hc) { jp8_hc = hc; }   /* the oracle's fake-handle counter (jp8_emu._hc) at the drive's start */
uint64_t jp8_heap_get(void) { return jp8_heap_ptr; }
/* THE REUSE LAYER (jp8_host_emu.JP8Host.heap_reuse_on: the same rule, so the two sides keep the same addresses). The
 * host's HeapAlloc / HeapFree are plumbing; never reusing a block, a long session runs out of heap (a patch load took
 * 1.32 MB, a process() block 8 KB: MEASURED 2026-10-12). From jp8_heap_reuse(1) a block the plugin frees goes on the
 * free list of its rounded size and the next allocation of that size takes the last one back (LIFO), zero-filled as a
 * new block; a block allocated before is never reused. Off (the default), the allocator is the bump pointer alone. */
typedef struct { uint64_t k; uint32_t v; } jp8_hslot;                  /* a live block -> its rounded size (k 0: empty) */
typedef struct { uint32_t size, n, cap; uint64_t *p; } jp8_fstack;    /* the free blocks of one size (size 0: empty) */
static int jp8_reuse;
static jp8_hslot *jp8_live; static size_t jp8_live_cap, jp8_live_n;
static jp8_fstack *jp8_fl; static size_t jp8_fl_cap, jp8_fl_n; static uint64_t jp8_nfree;
static JP8_TLS int jp8_heap_closed;                   /* a thread that must not allocate (the threaded transport's workers) */
static size_t jp8_hix(uint64_t k, size_t cap) { return (size_t)(((k >> 4) * 0x9E3779B97F4A7C15ULL) >> 20) & (cap - 1); }
static void *jp8_xcalloc(size_t n, size_t sz) {
    void *q = calloc(n, sz);
    if (!q) { fprintf(stderr, "jp8_heap: no host memory for the reuse tables\n"); abort(); }
    return q;
}
static void jp8_live_put(uint64_t k, uint32_t v);
static void jp8_live_grow(void) {
    jp8_hslot *o = jp8_live; size_t oc = jp8_live_cap, i;
    jp8_live_cap = oc ? 2 * oc : (size_t)1 << 16; jp8_live = (jp8_hslot *)jp8_xcalloc(jp8_live_cap, sizeof *jp8_live); jp8_live_n = 0;
    for (i = 0; i < oc; i++) if (o[i].k) jp8_live_put(o[i].k, o[i].v);
    free(o);
}
static void jp8_live_put(uint64_t k, uint32_t v) {
    size_t i;
    if (2 * (jp8_live_n + 1) > jp8_live_cap) jp8_live_grow();
    for (i = jp8_hix(k, jp8_live_cap); jp8_live[i].k && jp8_live[i].k != k; i = (i + 1) & (jp8_live_cap - 1)) {}
    if (!jp8_live[i].k) jp8_live_n++;
    jp8_live[i].k = k; jp8_live[i].v = v;
}
static uint32_t jp8_live_take(uint64_t k) {          /* the size of a live block, removed (backward-shift delete); 0: unknown */
    size_t i, j, h; uint32_t v;
    if (!jp8_live_cap || !k) return 0;
    for (i = jp8_hix(k, jp8_live_cap); jp8_live[i].k != k; i = (i + 1) & (jp8_live_cap - 1)) if (!jp8_live[i].k) return 0;
    v = jp8_live[i].v; jp8_live[i].k = 0; jp8_live_n--;
    for (j = (i + 1) & (jp8_live_cap - 1); jp8_live[j].k; j = (j + 1) & (jp8_live_cap - 1)) {
        h = jp8_hix(jp8_live[j].k, jp8_live_cap);
        if (((j - h) & (jp8_live_cap - 1)) >= ((j - i) & (jp8_live_cap - 1))) { jp8_live[i] = jp8_live[j]; jp8_live[j].k = 0; i = j; }
    }
    return v;
}
static jp8_fstack *jp8_fl_of(uint32_t size, int make) {
    size_t i;
    if (make && 2 * (jp8_fl_n + 1) > jp8_fl_cap) {
        jp8_fstack *o = jp8_fl; size_t oc = jp8_fl_cap, k;
        jp8_fl_cap = oc ? 2 * oc : 1024; jp8_fl = (jp8_fstack *)jp8_xcalloc(jp8_fl_cap, sizeof *jp8_fl);
        for (k = 0; k < oc; k++) if (o[k].size) {
            for (i = jp8_hix((uint64_t)o[k].size, jp8_fl_cap); jp8_fl[i].size; i = (i + 1) & (jp8_fl_cap - 1)) {}
            jp8_fl[i] = o[k];
        }
        free(o);
    }
    if (!jp8_fl_cap) return NULL;
    for (i = jp8_hix((uint64_t)size, jp8_fl_cap); jp8_fl[i].size; i = (i + 1) & (jp8_fl_cap - 1)) if (jp8_fl[i].size == size) return &jp8_fl[i];
    if (!make) return NULL;
    jp8_fl[i].size = size; jp8_fl_n++;
    return &jp8_fl[i];
}
void jp8_heap_reuse(int on) {                         /* on: the layer starts empty here; off: the bump pointer alone */
    size_t i;
    for (i = 0; i < jp8_fl_cap; i++) free(jp8_fl[i].p);
    free(jp8_fl); free(jp8_live); jp8_fl = NULL; jp8_live = NULL; jp8_fl_cap = jp8_fl_n = jp8_live_cap = jp8_live_n = 0; jp8_nfree = 0;
    jp8_reuse = on;
}
void jp8_heap_free(uint64_t p) {                      /* HeapFree's block (free / operator delete: the same) */
    uint32_t r; jp8_fstack *f;
    if (!jp8_reuse || !(r = jp8_live_take(p))) return;
    f = jp8_fl_of(r, 1);
    if (f->n == f->cap) {
        uint64_t *q = (uint64_t *)realloc(f->p, sizeof *q * (f->cap ? 2 * (size_t)f->cap : 16));
        if (!q) { fprintf(stderr, "jp8_heap: no host memory for a free list\n"); abort(); }
        f->p = q; f->cap = f->cap ? 2 * f->cap : 16;
    }
    f->p[f->n++] = p; jp8_nfree++;
}
void jp8_heap_stats(uint64_t *live, uint64_t *nfree) { if (live) *live = jp8_live_n; if (nfree) *nfree = jp8_nfree; }
void jp8_heap_close_thread(void) { jp8_heap_closed = 1; }
static uint64_t jp8_bump(uint64_t sz) {
    sz = (sz + 15) & ~15ULL; if (!sz) sz = 16; if (sz > 0x2000000) sz = 0x2000000;
    if (jp8_reuse) {
        jp8_fstack *f = jp8_fl_of((uint32_t)sz, 0);
        if (f && f->n) {
            uint64_t p = f->p[--f->n]; jp8_nfree--;
            memset(JP8_H(p, 1), 0, (size_t)sz); jp8_live_put(p, (uint32_t)sz); return p;
        }
    }
    uint64_t p = jp8_heap_ptr; jp8_heap_ptr += sz;
    if (jp8_heap_ptr > jp8_heap_lim) { fprintf(stderr, "jp8_bump: heap out of the mapped range\n"); abort(); }
#ifdef JP8_RELOC
    if (!jp8_span_ok(p, sz)) { fprintf(stderr, "jp8_bump: heap block outside its band\n"); abort(); }
#endif
    memset(JP8_H(p, 1), 0, (size_t)sz);
    if (jp8_reuse) jp8_live_put(p, (uint32_t)sz);
    return p;
}
void jp8_alloc(CPU *c) {
    if (jp8_heap_closed) { jp8_trap(c, 0x6F5B04, "a worker job allocates (the threaded transport assumes none does)"); return; }
    c->r[0] = jp8_bump(c->r[1] & 0xFFFFFFFFULL ? c->r[1] & 0xFFFFFFFFULL : 16);
}
extern const char *jp8_import_names[]; extern const int jp8_nimports;
void jp8_import(CPU *c, int idx) {
    const char *n = (idx >= 0 && idx < jp8_nimports) ? jp8_import_names[idx] : "?";
    uint64_t rcx = c->r[1], rdx = c->r[2], r8 = c->r[8];
    if (!strcmp(n, "EncodePointer") || !strcmp(n, "DecodePointer")) { c->r[0] = rcx; return; }
    if (!strcmp(n, "GetProcessHeap")) { c->r[0] = 0x4242000000ULL; return; }
    if (!strcmp(n, "HeapAlloc") || !strcmp(n, "calloc")) {
        uint64_t sz = r8 ? r8 : (rdx ? rdx : 16);
        if (jp8_heap_closed) { jp8_trap(c, 0, "a worker job allocates (the threaded transport assumes none does)"); return; }
        c->r[0] = jp8_bump(sz); return;
    }
    if (!strcmp(n, "malloc")) { c->r[0] = jp8_bump(rcx ? rcx : 16); return; }
    if (!strcmp(n, "HeapFree") || !strcmp(n, "free")) { c->r[0] = 1; return; }
    if (!strncmp(n, "Create", 6) || !strncmp(n, "Open", 4)) { jp8_hc += 16; c->r[0] = jp8_hc; return; }
    if (!strcmp(n, "ResumeThread") || !strcmp(n, "GetModuleHandleExW") || !strcmp(n, "IsDebuggerPresent")) { c->r[0] = 0; return; }
    if (!strcmp(n, "GetCurrentThreadId") || !strcmp(n, "GetCurrentProcessId")) { c->r[0] = 0x1000; return; }
    if (!strcmp(n, "IsProcessorFeaturePresent")) { c->r[0] = 1; return; }
    if (!strncmp(n, "Initialize", 10) || !strcmp(n, "EnterCriticalSection") || !strcmp(n, "LeaveCriticalSection") || !strcmp(n, "DeleteCriticalSection")) { c->r[0] = 1; return; }
    { static char msg[96]; snprintf(msg, sizeof msg, "import %s not shimmed", n); jp8_trap(c, 0x600000000ULL + 8 * (uint64_t)idx, msg); }
}

extern void jp8_run(CPU *c, uint64_t rva);
int jp8_call_x(CPU *c, uint64_t rva);

/* call a lifted function with the Win64 register args; rsp is the caller's stack pointer (the dummy return slot is
 * pushed like a real call). Returns 0, or 1 on a trap (message via jp8_last_trap). */
int jp8_call(CPU *c, uint64_t rva, uint64_t rcx, uint64_t rdx, uint64_t r8, uint64_t r9) {
    c->r[1] = rcx; c->r[2] = rdx; c->r[8] = r8; c->r[9] = r9;
    return jp8_call_x(c, rva);
}
/* SETSR takes its rate as a FLOAT in xmm1 (abi ledger, playbook 87) */
int jp8_call_f(CPU *c, uint64_t rva, uint64_t rcx, float f) {
    c->r[1] = rcx; memset(&c->x[1], 0, 16); c->x[1].f[0] = f;
    return jp8_call_x(c, rva);
}
int jp8_call_x(CPU *c, uint64_t rva) {
#ifndef JP8_SOFTFP
    _mm_setcsr(c->mxcsr ? c->mxcsr : 0x9FC0);
#else
    if (!c->mxcsr) c->mxcsr = 0x9FC0;
#endif
#ifdef JP8_RELOC
    jp8_cur = c;
#endif
    jp8_jb_set = 1;
    if (setjmp(jp8_jb)) { jp8_jb_set = 0; return 1; }
    c->r[4] -= 8;
    jp8_run(c, rva);
    c->r[4] += 8;
#if defined(JP8_RELOC) && JP8_RELOC_CHECK == 2
    if (jp8_badacc) { jp8_badacc = 0; jp8_jb_set = 0; snprintf(jp8_trap_msg, sizeof jp8_trap_msg, "guest access outside every mapped region during this call"); return 1; }
#endif
    jp8_jb_set = 0; return 0;
}

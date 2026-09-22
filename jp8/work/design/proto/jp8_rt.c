/* jp8_rt.c -- runtime for the lifted code: the trap, the address-space loader (the oracle's regions mapped at the
 * SAME virtual addresses, MAP_FIXED_NOREPLACE, then the dumps loaded), FTZ/DAZ, and the entry the gate calls. */
#ifndef JP8_RELOC
#define _GNU_SOURCE
#endif
#include "jp8_cpu.h"
#ifndef JP8_RELOC
#include <sys/mman.h>
#endif
#include <setjmp.h>
#include <errno.h>

static jmp_buf jp8_jb; static int jp8_jb_set;
static char jp8_trap_msg[256];
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
static void *jp8_braw[JP8_NBANDS];
int jp8_map(uint64_t base, uint64_t size) {
    uint64_t i = base >> 28; unsigned char *raw, *h;
    if (!size || i >= JP8_NBANDS || ((base + size - 1) >> 28) != i || jp8_bhi[i]) { fprintf(stderr, "jp8_map(0x%llx, 0x%llx): not one free band\n", (unsigned long long)base, (unsigned long long)size); return -1; }
    raw = (unsigned char *)calloc(1, (size_t)size + 4096); if (!raw) return -1;
    h = raw + ((4096 - ((uintptr_t)raw & 4095)) & 4095);        /* host address == guest address mod 4096 (base is page aligned) */
    jp8_braw[i] = raw; jp8_bdelta[i] = (uintptr_t)h - (uintptr_t)base;
    jp8_blo[i] = (uint32_t)(base & 0x0FFFFFFFu); jp8_bhi[i] = jp8_blo[i] + (uint32_t)size; return 0;
}
void *jp8_host(uint64_t a) { return JP8_H(a, 1); }      /* for harnesses: guest -> host */
static CPU *jp8_cur; uint32_t jp8_badacc; unsigned char jp8_sink[64];
void jp8_fault(uint64_t a, unsigned n) {
    static char msg[80]; snprintf(msg, sizeof msg, "guest access 0x%llx (%u bytes) outside every mapped region", (unsigned long long)a, n);
    if (jp8_cur) jp8_trap(jp8_cur, 0, msg);
    fprintf(stderr, "%s\n", msg); abort();
}
static int jp8_span_ok(uint64_t a, uint64_t n) { uint64_t i = a >> 28; return i < JP8_NBANDS && (a & 0x0FFFFFFFu) >= jp8_blo[i] && (a & 0x0FFFFFFFu) + n <= jp8_bhi[i]; }
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
static uint64_t jp8_bump(uint64_t sz) {
    sz = (sz + 15) & ~15ULL; if (!sz) sz = 16; if (sz > 0x2000000) sz = 0x2000000;
    uint64_t p = jp8_heap_ptr; jp8_heap_ptr += sz;
    if (jp8_heap_ptr > jp8_heap_lim) { fprintf(stderr, "jp8_bump: heap out of the mapped range\n"); abort(); }
#ifdef JP8_RELOC
    if (!jp8_span_ok(p, sz)) { fprintf(stderr, "jp8_bump: heap block outside its band\n"); abort(); }
#endif
    memset(JP8_H(p, 1), 0, (size_t)sz); return p;
}
void jp8_alloc(CPU *c) { c->r[0] = jp8_bump(c->r[1] & 0xFFFFFFFFULL ? c->r[1] & 0xFFFFFFFFULL : 16); }
extern const char *jp8_import_names[]; extern const int jp8_nimports;
void jp8_import(CPU *c, int idx) {
    const char *n = (idx >= 0 && idx < jp8_nimports) ? jp8_import_names[idx] : "?";
    uint64_t rcx = c->r[1], rdx = c->r[2], r8 = c->r[8];
    if (!strcmp(n, "EncodePointer") || !strcmp(n, "DecodePointer")) { c->r[0] = rcx; return; }
    if (!strcmp(n, "GetProcessHeap")) { c->r[0] = 0x4242000000ULL; return; }
    if (!strcmp(n, "HeapAlloc") || !strcmp(n, "calloc")) { uint64_t sz = r8 ? r8 : (rdx ? rdx : 16); c->r[0] = jp8_bump(sz); return; }
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

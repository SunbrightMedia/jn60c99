/* l3_harness.c -- L3 of the JUNO lift (docs/JUNO_LIFT.md): every SHIPPED lifted statement (build/l3/l3_cases.c, from
 * lift/jn_lift.c by tools/lift/l3_cases.py) against the REAL CPU running the plugin's own instruction bytes for ONE
 * step (the trap flag), from the same state: the 16 registers, the flags, XMM0-15, MXCSR and the memory an instruction
 * may touch (a test window, the gs page, the image). States are seeded per (case, state): edge and random integers,
 * floats and doubles. The lifted outcome is compared HERE (lifted vs CPU); every in-state and the CPU's out-state also
 * go to stdout for the Unicorn side (tools/lift/l3_unicorn.py, its own process), which compares the oracle's emulator
 * with the same CPU result.
 * Defined output flags only (an undefined flag is not compared; tools/lift/l3_flags.py proves no reached code reads
 * one). MXCSR's sticky exception flags are reported in a class of their own: the lift keeps the guest's MXCSR as the
 * plugin loaded it (the oracle never sets them; playbook 241).
 * usage: l3_harness <image.bin> <pool.bin> <nstates> <nrep> [--from i] [--to j] [--seed s] [--no-stream] [--self]
 *   nrep: states for the FIRST case of each form (its edge sweep); --self: the isolation control (the CPU against
 *   itself: the harness must be deterministic). A TEST PLATFORM LAYER: Linux x86-64 only (signals, ucontext, fixed
 *   mappings) -- never part of a product. */
#define _GNU_SOURCE
#include <signal.h>
#include <setjmp.h>
#include <ucontext.h>
#include <sys/mman.h>
#include <sys/syscall.h>
#include <asm/prctl.h>
#include <unistd.h>
#include <zlib.h>
#include "l3_rt.h"

#define WBASE 0x700000000ULL       /* the test window: every memory operand, the stack and string pointers land here */
#define WSIZE 0x2000u
#define GBASE 0x580000000ULL       /* the gs page = the product's JP8_GS_BASE (the wrapper oracle's TEB) */
#define GSIZE 0x2000u
#define POOLSZ (1u << 20)

/* ---- the runtime the statements call (the flat build: guest address = host address here) ---- */
uintptr_t jp8_flat = 0;
uintptr_t jp8_bdelta[JP8_NBANDS];
uint32_t jp8_blo[JP8_NBANDS], jp8_bhi[JP8_NBANDS];
uint32_t jp8_badacc;
unsigned char jp8_sink[64];
void jp8_fault(uint64_t a, unsigned n) { fprintf(stderr, "jp8_fault %llx %u\n", (unsigned long long)a, n); abort(); }
static sigjmp_buf trap_jb;
static int t_trapped;
void jp8_trap(CPU *c, uint64_t rva, const char *what) { (void)c; (void)rva; (void)what; t_trapped = 1; siglongjmp(trap_jb, 1); }
void jp8_tr(CPU *c, uint64_t rva) { (void)c; (void)rva; }

int t_kind, t_called;
uint64_t t_target;
CPU t_snap;
uint64_t t_snap_w;
static uint64_t hash(uint64_t base, unsigned n) {
    const Bytef *p = (const Bytef *)(uintptr_t)base;
    return (uint64_t)crc32(0L, p, n) << 32 | (uint64_t)adler32(1L, p, n);
}
void t_call(CPU *c, uint64_t target) {
    if (t_called) return;
    t_called = 1; t_target = target; t_snap = *c; t_snap_w = hash(WBASE, WSIZE);
}
void jp8_icall(CPU *c, uint64_t target) { t_call(c, target); }

/* ---- states ---- */
typedef struct { uint64_t addr; uint32_t len, pad; uint8_t b[16]; } patch;
typedef struct {                    /* one in-state (also the stream's record) */
    uint32_t ci, si;
    uint64_t r[16];
    uint64_t fl;
    X x[16];
    uint32_t mxcsr, woff, goff, npatch;
    patch p[2];
} rec_in;
typedef struct {                    /* the CPU's out-state */
    uint64_t r[16];
    uint64_t rip, fl;
    X x[16];
    uint32_t mxcsr, fault;
    uint64_t whash, ghash;
    uint8_t ea[16];
    uint32_t lres, kind;
} rec_out;

static uint64_t rs;
static uint64_t rnd(void) {
    uint64_t z = (rs += 0x9E3779B97F4A7C15ULL);
    z = (z ^ (z >> 30)) * 0xBF58476D1CE4E5B9ULL; z = (z ^ (z >> 27)) * 0x94D049BB133111EBULL; return z ^ (z >> 31);
}
static const uint64_t GE[] = { 0, 1, 2, 3, 7, 8, 0x1F, 0x20, 0x3F, 0x40, 0x7F, 0x80, 0xFF, 0x100, 0x7FFF, 0x8000, 0xFFFF,
    0x10000, 0x7FFFFFFF, 0x80000000, 0x80000001, 0xFFFFFFFE, 0xFFFFFFFF, 0x100000000ULL, 0x7FFFFFFFFFFFFFFFULL,
    0x8000000000000000ULL, 0x8000000000000001ULL, 0xFFFFFFFFFFFFFFFEULL, 0xFFFFFFFFFFFFFFFFULL, 0xFFFFFFFF80000000ULL };
static const uint32_t FE[] = { 0x00000000, 0x80000000, 0x00000001, 0x80000001, 0x007FFFFF, 0x807FFFFF, 0x00400000,
    0x00800000, 0x80800000, 0x00800001, 0x00FFFFFF, 0x3F800000, 0xBF800000, 0x3F800001, 0x3F7FFFFF, 0x3F000000,
    0x7F7FFFFF, 0xFF7FFFFF, 0x7F000000, 0x7F800000, 0xFF800000, 0x7FC00000, 0xFFC00000, 0x7FC00001, 0xFFF00000,
    0x7FA00000, 0x7F800001, 0xFF800001, 0x4F000000, 0x4EFFFFFF, 0xCF000000, 0xCF000001, 0x5F000000, 0xDF000000,
    0x1F800000, 0x20000000, 0x1F000000, 0x0C000000, 0x4B000000, 0x4B000001, 0x3EFFFFFF, 0x3FC00000, 0x40400000 };
static const uint64_t DE[] = { 0, 0x8000000000000000ULL, 1, 0x8000000000000001ULL, 0x000FFFFFFFFFFFFFULL,
    0x0008000000000000ULL, 0x0010000000000000ULL, 0x8010000000000000ULL, 0x3FF0000000000000ULL, 0xBFF0000000000000ULL,
    0x3FF0000000000001ULL, 0x3FEFFFFFFFFFFFFFULL, 0x3FE0000000000000ULL, 0x7FEFFFFFFFFFFFFFULL, 0x7FF0000000000000ULL,
    0xFFF0000000000000ULL, 0x7FF8000000000000ULL, 0xFFF8000000000000ULL, 0x7FF8000000000001ULL, 0x7FF4000000000000ULL,
    0x7FF0000000000001ULL, 0x41E0000000000000ULL, 0x41DFFFFFFFC00000ULL, 0xC1E0000000000000ULL, 0xC1E0000000200000ULL,
    0x43E0000000000000ULL, 0xC3E0000000000000ULL, 0x3810000000000000ULL, 0x380FFFFFFFFFFFFFULL, 0x36A0000000000000ULL,
    0x3690000000000000ULL, 0x47EFFFFFE0000000ULL, 0x47EFFFFFF0000000ULL, 0x47F0000000000000ULL, 0x3800000000000000ULL,
    0x37FFFFFFFFFFFFFFULL, 0x4330000000000000ULL, 0x3FF8000000000000ULL };
#define N(a) (sizeof(a) / sizeof((a)[0]))

static uint64_t gval(void) {
    switch (rnd() % 8) {
    case 0: case 1: case 2: return GE[rnd() % N(GE)];
    case 3: return rnd() % 65;
    case 4: return (uint64_t)0 - 1 - rnd() % 64;
    case 5: return rnd() & 0xFFFFFFFFULL;
    default: return rnd();
    }
}
static uint32_t fval(void) {
    uint32_t s = (uint32_t)(rnd() & 1) << 31;
    switch (rnd() % 8) {
    case 0: case 1: case 2: case 3: return FE[rnd() % N(FE)];
    case 4: case 5: return s | (uint32_t)(100 + rnd() % 55) << 23 | (uint32_t)(rnd() & 0x7FFFFF);
    case 6: return s | (uint32_t)(rnd() % 31) << 23 | (uint32_t)(rnd() & 0x7FFFFF);
    default: return (uint32_t)rnd();
    }
}
static uint64_t dval(void) {
    uint64_t s = (rnd() & 1) << 63;
    switch (rnd() % 8) {
    case 0: case 1: case 2: case 3: return DE[rnd() % N(DE)];
    case 4: case 5: return s | (uint64_t)(990 + rnd() % 70) << 52 | (rnd() & 0xFFFFFFFFFFFFFULL);
    case 6: return s | (uint64_t)(rnd() % 100) << 52 | (rnd() & 0xFFFFFFFFFFFFFULL);
    default: return rnd();
    }
}
static void lanes(uint8_t *p, unsigned n, int fpk) {        /* n bytes of lane values of the case's kind */
    unsigned i;
    if (fpk == 1) { for (i = 0; i + 4 <= n; i += 4) { uint32_t v = fval(); memcpy(p + i, &v, 4); } }
    else if (fpk == 2) { for (i = 0; i + 8 <= n; i += 8) { uint64_t v = dval(); memcpy(p + i, &v, 8); } }
    else { for (i = 0; i + 8 <= n; i += 8) { uint64_t v = gval(); memcpy(p + i, &v, 8); } }
    for (i = n & ~7u; i < n; i++) p[i] = (uint8_t)rnd();
}

static uint8_t *pool;
static uint64_t img_size;
static uint64_t ea_of(const l3case *k, const rec_in *s) {     /* the memory operand's address in this state */
    if (k->mk == 2) return l3_ib + k->rva + (uint64_t)k->len + (uint64_t)k->mdisp;
    if (k->mk == 3) return GBASE + (uint64_t)k->mdisp;
    return (k->mb >= 0 ? s->r[k->mb] : 0) + (k->mi >= 0 ? s->r[k->mi] * (uint64_t)k->msc : 0) + (uint64_t)k->mdisp;
}
static void add_patch(rec_in *s, uint64_t a, const uint8_t *b, unsigned n) {
    if (s->npatch >= 2 || n > 16) { fprintf(stderr, "patch overflow\n"); abort(); }
    s->p[s->npatch].addr = a; s->p[s->npatch].len = n; memcpy(s->p[s->npatch].b, b, n); s->npatch++;
}
static void make_state(const l3case *k, uint32_t ci, uint32_t si, uint64_t seed, rec_in *s) {
    int i, fpk = k->fpflag >> 8;
    rs = seed ^ ((uint64_t)ci << 32 | si) * 0xD6E8FEB86659FD93ULL;
    memset(s, 0, sizeof *s);
    s->ci = ci; s->si = si;
    for (i = 0; i < 16; i++) s->r[i] = gval();
    s->fl = rnd() & 0x8D5u;                                    /* CF PF AF ZF SF OF; DF = 0 (the ABI) */
    for (i = 0; i < 16; i++) lanes(s->x[i].b, 16, fpk ? fpk : (int)(rnd() % 3));
    s->mxcsr = (rnd() & 1) ? 0x9FC0u : 0x1F80u;                /* the plugin's two modes: IEEE and FTZ|DAZ */
    s->woff = (uint32_t)(rnd() % (POOLSZ - WSIZE)); s->goff = (uint32_t)(rnd() % (POOLSZ - GSIZE));
    if (k->mk == 1) {                                          /* the memory operand into the window's middle */
        uint64_t t = WBASE + 0x800 + rnd() % 0x1000;
        if (k->msz >= 16) t &= ~15ULL; else if (rnd() & 1) t &= ~(uint64_t)7;
        if (k->mb >= 0 && k->mi >= 0 && k->mb != k->mi) {
            uint64_t ix = (uint64_t)((int64_t)(rnd() % 33) - 16);
            s->r[k->mi] = ix; s->r[k->mb] = t - ix * (uint64_t)k->msc - (uint64_t)k->mdisp;
        } else if (k->mb >= 0 && k->mi == k->mb) {
            s->r[k->mb] = (t - (uint64_t)k->mdisp) / (uint64_t)(1 + k->msc);
        } else if (k->mb >= 0) {
            s->r[k->mb] = t - (uint64_t)k->mdisp;
        } else {
            s->r[k->mi] = (t - (uint64_t)k->mdisp) / (uint64_t)k->msc;
        }
    }
    if (k->stack && k->mb != 4 && k->mi != 4) s->r[4] = WBASE + 0xE00 + ((rnd() % 0x400) & ~7ULL);
    if (k->str) { s->r[7] = WBASE + 0x400 + rnd() % 0x200; s->r[6] = WBASE + 0x1200 + rnd() % 0x200; s->r[1] = rnd() % 65; }
    if (k->shk >= 0 && k->shimm < 0 && k->mb != 1 && k->mi != 1) {   /* a count in cl: the edges of the rules */
        static const uint8_t CE[] = { 0, 1, 2, 7, 8, 9, 15, 16, 17, 31, 32, 33, 63, 64, 65, 255 };
        s->r[1] = (s->r[1] & ~0xFFULL) | ((rnd() & 1) ? CE[rnd() % N(CE)] : (rnd() & 0xFF));
    }
    if (k->divk) {                                             /* operands that cannot fault: n = q * d + r */
        uint64_t d = 0;
        if (k->divk == 1) {
            uint32_t dd = (uint32_t)gval(), q = (uint32_t)gval(), r; uint64_t n;
            if (!dd) dd = 1;
            r = (uint32_t)(rnd() % dd); n = (uint64_t)q * dd + r; d = dd;
            s->r[0] = (s->r[0] & ~0xFFFFFFFFULL) | (n & 0xFFFFFFFFULL); s->r[2] = (s->r[2] & ~0xFFFFFFFFULL) | (n >> 32);
        } else if (k->divk == 2) {
            unsigned __int128 n; uint64_t q = gval(), r;
            d = gval(); if (!d) d = 1;
            r = rnd() % d; n = (unsigned __int128)q * d + r;
            s->r[0] = (uint64_t)n; s->r[2] = (uint64_t)(n >> 64);
        } else if (k->divk == 3) {
            int32_t dd = (int32_t)gval(), q = (int32_t)gval(); int64_t n0, n, r0, r;
            if (!dd) dd = 1;
            n0 = (int64_t)q * dd; r0 = (int64_t)(rnd() % (uint64_t)(dd < 0 ? -(int64_t)dd : dd));
            r = n0 > 0 ? r0 : n0 < 0 ? -r0 : ((rnd() & 1) ? r0 : -r0);
            n = n0 + r; d = (uint32_t)dd;
            s->r[0] = (s->r[0] & ~0xFFFFFFFFULL) | ((uint64_t)n & 0xFFFFFFFFULL);
            s->r[2] = (s->r[2] & ~0xFFFFFFFFULL) | (((uint64_t)n >> 32) & 0xFFFFFFFFULL);
        } else {
            int64_t dd = (int64_t)gval(), q = (int64_t)gval(); __int128 n0, n, r0, r;
            if (!dd) dd = 1;
            if (dd == -1 && q == INT64_MIN) q = INT64_MAX;
            n0 = (__int128)q * dd;
            r0 = (__int128)(rnd() % (dd < 0 ? (uint64_t)0 - (uint64_t)dd : (uint64_t)dd));
            r = n0 > 0 ? r0 : n0 < 0 ? -r0 : ((rnd() & 1) ? r0 : -r0);
            n = n0 + r; d = (uint64_t)dd;
            s->r[0] = (uint64_t)n; s->r[2] = (uint64_t)((unsigned __int128)n >> 64);
        }
        if (k->divreg >= 0) {
            if (k->divreg == 0 || k->divreg == 2) { fprintf(stderr, "divisor in rax/rdx: not met\n"); abort(); }
            s->r[k->divreg] = (k->divk == 1 || k->divk == 3) ? (s->r[k->divreg] & ~0xFFFFFFFFULL) | (d & 0xFFFFFFFFULL) : d;
        } else {
            uint8_t b[8]; memcpy(b, &d, 8); add_patch(s, ea_of(k, s), b, (unsigned)k->msz);
        }
    } else if (k->sp == 1) {                                   /* ldmxcsr: a valid MXCSR word */
        static const uint32_t MV[] = { 0x1F80u, 0x9FC0u, 0x1FC0u, 0x9F80u, 0x1F80u | 0x3Fu, 0x9FC0u | 0x21u };
        uint32_t v = MV[rnd() % N(MV)]; add_patch(s, ea_of(k, s), (const uint8_t *)&v, 4);
    } else if (k->mk && k->msz && (rnd() % 4)) {               /* the operand's bytes: lane values (else the pool's) */
        uint8_t b[16]; unsigned n = (unsigned)(k->msz > 16 ? 16 : k->msz);
        if (k->mk == 2 && !(rnd() & 3)) n = 0;                 /* rip-relative: mostly the image's own constants */
        if (n) { lanes(b, n, fpk); add_patch(s, ea_of(k, s), b, n); }
    }
    if (k->ctl) {                                              /* an indirect target: canonical (a jump table's own
                                                                  case half the time, else anywhere in the image) */
        uint64_t t = (k->nct && (rnd() & 1)) ? k->ct[rnd() % (uint64_t)k->nct] : l3_ib + rnd() % img_size;
        if (k->ctl == 1) s->r[k->ctlreg] = t;
        else add_patch(s, k->ctl == 2 ? ea_of(k, s) : s->r[4], (const uint8_t *)&t, 8);
    }
}

/* ---- memory per run: the window and the gs page from the pool, the patches, the image bytes at a rip operand ---- */
static uint8_t ea_save[16];
static void mem_set(const l3case *k, const rec_in *s) {
    unsigned i;
    memcpy((void *)(uintptr_t)WBASE, pool + s->woff, WSIZE);
    memcpy((void *)(uintptr_t)GBASE, pool + s->goff, GSIZE);
    if (k->mk == 2) memcpy((void *)(uintptr_t)ea_of(k, s), ea_save, 16);
    for (i = 0; i < s->npatch; i++) memcpy((void *)(uintptr_t)s->p[i].addr, s->p[i].b, s->p[i].len);
}

/* ---- the real CPU, one step ---- */
static const int GREG[16] = { REG_RAX, REG_RCX, REG_RDX, REG_RBX, REG_RSP, REG_RBP, REG_RSI, REG_RDI,
                              REG_R8, REG_R9, REG_R10, REG_R11, REG_R12, REG_R13, REG_R14, REG_R15 };
static rec_in gin;
static rec_out gout;
static uint64_t gin_rip;
static sigjmp_buf nat_jb;
static void h_go(int sig, siginfo_t *si, void *p) {
    ucontext_t *u = p; greg_t *g = u->uc_mcontext.gregs; unsigned char *fx = (unsigned char *)u->uc_mcontext.fpregs;
    uint32_t magic; int i;
    (void)sig; (void)si;
    for (i = 0; i < 16; i++) g[GREG[i]] = (greg_t)gin.r[i];
    g[REG_RIP] = (greg_t)gin_rip;
    g[REG_EFL] = (greg_t)((gin.fl & 0x8D5u) | 0x100u | 0x2u);        /* TF: trap after one instruction */
    u->uc_mcontext.fpregs->mxcsr = gin.mxcsr;
    for (i = 0; i < 16; i++) memcpy(&u->uc_mcontext.fpregs->_xmm[i], &gin.x[i], 16);
    memcpy(&magic, fx + 464, 4);
    if (magic == 0x46505853u) { uint64_t bv; memcpy(&bv, fx + 512, 8); bv |= 2; memcpy(fx + 512, &bv, 8); }  /* SSE in use */
}
static void h_step(int sig, siginfo_t *si, void *p) {
    ucontext_t *u = p; greg_t *g = u->uc_mcontext.gregs; int i;
    (void)si;
    for (i = 0; i < 16; i++) gout.r[i] = (uint64_t)g[GREG[i]];
    gout.rip = (uint64_t)g[REG_RIP]; gout.fl = (uint64_t)g[REG_EFL];
    gout.mxcsr = u->uc_mcontext.fpregs->mxcsr;
    for (i = 0; i < 16; i++) memcpy(&gout.x[i], &u->uc_mcontext.fpregs->_xmm[i], 16);
    gout.fault = (sig == SIGTRAP) ? 0u : (uint32_t)sig;
    siglongjmp(nat_jb, 1);
}
static void native(const l3case *k, const rec_in *s, rec_out *o) {
    int it = 0;
    gin = *s; gin_rip = l3_ib + k->rva;
    for (;;) {
        memset(&gout, 0, sizeof gout);
        if (!sigsetjmp(nat_jb, 1)) {
            syscall(SYS_tgkill, getpid(), (pid_t)syscall(SYS_gettid), SIGUSR1);
            fprintf(stderr, "the step did not trap\n"); abort();
        }
        /* a REP string instruction traps after EACH iteration with rip still on it: step on until it is done */
        if (!(k->str && gout.rip == gin_rip && !gout.fault)) break;
        if (++it > 4096) { fprintf(stderr, "rep did not end\n"); abort(); }
        memcpy(gin.r, gout.r, sizeof gin.r); gin.fl = gout.fl; memcpy(gin.x, gout.x, sizeof gin.x); gin.mxcsr = gout.mxcsr;
    }
    *o = gout;
    o->whash = hash(WBASE, WSIZE); o->ghash = hash(GBASE, GSIZE);
    if (k->mk == 2) memcpy(o->ea, (void *)(uintptr_t)ea_of(k, s), 16);
}

/* ---- the lifted statement ---- */
enum { R_GPR = 1, R_RIP = 2, R_FLAGS = 4, R_XMM = 8, R_MXC = 16, R_MXF = 32, R_MEMW = 64, R_MEMG = 128, R_EA = 256,
       R_NFAULT = 512, R_TRAP = 1024 };
static uint32_t defined_flags(const l3case *k, const rec_in *s) {
    uint32_t def = (uint32_t)(k->fpflag & 0xFF);
    if (k->shk >= 0) {
        unsigned cnt = k->shimm >= 0 ? (unsigned)k->shimm : (unsigned)(s->r[1] & 0xFF);
        unsigned m = cnt & (k->shsz == 64 ? 63u : 31u);
        if (!m) return 0x1F;                                   /* a zero count: no flag changes */
        if (k->shk == 0) { def = 0x0F; if (m == 1) def |= 0x10; if (m >= (unsigned)k->shsz) def &= ~1u; }
        else { def = 0x0F; if (m == 1) def |= 0x10; }          /* rotates: SF ZF PF unchanged, CF set, OF if 1 */
    }
    return def;
}
static uint32_t fl5(uint64_t f) { return (uint32_t)((f & 1) | ((f >> 2 & 1) << 1) | ((f >> 6 & 1) << 2) | ((f >> 7 & 1) << 3) | ((f >> 11 & 1) << 4)); }
static uint32_t lifted(const l3case *k, const rec_in *s, const rec_out *o, CPU *c) {
    uint32_t res = 0, def, lf; uint64_t lrip = 0, lw; const CPU *L; int i, ret = 0;
    mem_set(k, s);
    memset(c, 0, sizeof *c);
    memcpy(c->r, s->r, sizeof c->r); memcpy(c->x, s->x, sizeof c->x);
    c->cf = (int)(s->fl & 1); c->pf = (int)(s->fl >> 2 & 1); c->zf = (int)(s->fl >> 6 & 1);
    c->sf = (int)(s->fl >> 7 & 1); c->of = (int)(s->fl >> 11 & 1); c->mxcsr = s->mxcsr;
    JP8_FPENV(c);                                              /* the runtime's invariant: real MXCSR = the guest's */
    t_kind = T_RETURNED; t_called = 0; t_trapped = 0;
    if (!sigsetjmp(trap_jb, 0)) k->fn(c);
    _mm_setcsr(0x1F80u);
    if (t_trapped) return R_TRAP;
    L = t_called ? &t_snap : c;
    if (t_called) lrip = t_target;
    else if (t_kind == T_WENT) lrip = t_target;
    else if (t_kind == T_FELL) lrip = l3_ib + k->rva + (uint64_t)k->len;
    else { ret = 1; memcpy(&lrip, (void *)(uintptr_t)s->r[4], 8); }  /* ret: the CPU pops the return address; in
                                                                  the lift the CALLER pops it (R(4)+=8 after the call) */
    for (i = 0; i < 16; i++) if ((i == 4 && ret ? L->r[i] + 8 : L->r[i]) != o->r[i]) res |= R_GPR;
    if (lrip != o->rip) res |= R_RIP;
    def = defined_flags(k, s);
    lf = (uint32_t)(L->cf | L->pf << 1 | L->zf << 2 | L->sf << 3 | L->of << 4);
    if ((lf ^ fl5(o->fl)) & def) res |= R_FLAGS;
    if (memcmp(L->x, o->x, sizeof L->x)) res |= R_XMM;
    if ((L->mxcsr ^ o->mxcsr) & ~0x3Fu) res |= R_MXC;
    if ((o->mxcsr ^ L->mxcsr) & 0x3Fu) res |= R_MXF;
    lw = t_called ? t_snap_w : hash(WBASE, WSIZE);
    if (lw != o->whash) res |= R_MEMW;
    if (hash(GBASE, GSIZE) != o->ghash) res |= R_MEMG;
    if (k->mk == 2 && memcmp((void *)(uintptr_t)ea_of(k, s), o->ea, 16)) res |= R_EA;
    if (o->fault) res |= R_NFAULT;
    return res;
}

static void *map_at(uint64_t a, size_t n, int prot) {
    void *p = mmap((void *)(uintptr_t)a, n, prot, MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED_NOREPLACE, -1, 0);
    if (p != (void *)(uintptr_t)a) { fprintf(stderr, "mmap %llx failed\n", (unsigned long long)a); exit(2); }
    return p;
}
static uint8_t *slurp(const char *path, size_t *n) {
    FILE *f = fopen(path, "rb"); uint8_t *b; long sz;
    if (!f) { fprintf(stderr, "open %s\n", path); exit(2); }
    fseek(f, 0, SEEK_END); sz = ftell(f); fseek(f, 0, SEEK_SET);
    b = malloc((size_t)sz); if (fread(b, 1, (size_t)sz, f) != (size_t)sz) exit(2); fclose(f); *n = (size_t)sz; return b;
}

int main(int argc, char **argv) {
    size_t nimg, npool; uint8_t *img; int i, from = 0, to = l3_ncases, stream = 1, self = 0, nst, nrep;
    uint64_t seed = 0x4C33A5ULL; struct sigaction sa; stack_t alt; int dump_c = -1, dump_s = -1;
    static long nstates_run, nbad, nres[16], form_bad[4096], form_n[4096], form_seen[4096];
    if (argc < 5) { fprintf(stderr, "usage: l3_harness <image.bin> <pool.bin> <nstates> <nrep> [--from i] [--to j] "
                                    "[--seed s] [--no-stream] [--self]\n"); return 2; }
    nst = atoi(argv[3]); nrep = atoi(argv[4]);
    for (i = 5; i < argc; i++) {
        if (!strcmp(argv[i], "--from")) from = atoi(argv[++i]);
        else if (!strcmp(argv[i], "--to")) to = atoi(argv[++i]);
        else if (!strcmp(argv[i], "--seed")) seed = strtoull(argv[++i], 0, 0);
        else if (!strcmp(argv[i], "--no-stream")) stream = 0;
        else if (!strcmp(argv[i], "--self")) self = 1;
        else if (!strcmp(argv[i], "--dump")) { dump_c = atoi(argv[++i]); dump_s = atoi(argv[++i]); }
    }
    if (to > l3_ncases) to = l3_ncases;
    img = slurp(argv[1], &nimg); pool = slurp(argv[2], &npool); img_size = nimg;
    if (npool != POOLSZ) { fprintf(stderr, "pool must be %u bytes\n", POOLSZ); return 2; }
    memcpy(map_at(l3_ib, (nimg + 0xFFF) & ~(size_t)0xFFF, PROT_READ | PROT_WRITE | PROT_EXEC), img, nimg);
    map_at(WBASE, WSIZE, PROT_READ | PROT_WRITE); map_at(GBASE, GSIZE, PROT_READ | PROT_WRITE);
    if (syscall(SYS_arch_prctl, ARCH_SET_GS, (unsigned long)GBASE)) { perror("arch_prctl"); return 2; }
    alt.ss_sp = malloc(1 << 16); alt.ss_size = 1 << 16; alt.ss_flags = 0; sigaltstack(&alt, 0);
    memset(&sa, 0, sizeof sa); sa.sa_flags = SA_SIGINFO | SA_ONSTACK; sigemptyset(&sa.sa_mask);
    sa.sa_sigaction = h_go; sigaction(SIGUSR1, &sa, 0);
    sa.sa_sigaction = h_step;
    sigaction(SIGTRAP, &sa, 0); sigaction(SIGSEGV, &sa, 0); sigaction(SIGBUS, &sa, 0); sigaction(SIGFPE, &sa, 0);
    sigaction(SIGILL, &sa, 0);
    for (i = from; i < to; i++) {
        const l3case *k = &l3_cases[i];
        int s, ns = form_seen[k->form]++ ? nst : nrep;
        if (k->mk == 2) memcpy(ea_save, (void *)(uintptr_t)(l3_ib + k->rva + (uint64_t)k->len + (uint64_t)k->mdisp), 16);
        for (s = 0; s < ns; s++) {
            rec_in in; rec_out o, o2; CPU c; uint32_t r;
            make_state(k, (uint32_t)i, (uint32_t)s, seed, &in);
            mem_set(k, &in); native(k, &in, &o);
            if (self) {
                mem_set(k, &in); native(k, &in, &o2);
                if (memcmp(&o, &o2, sizeof o)) { fprintf(stderr, "SELF: the CPU disagrees with itself at case %d state %d\n", i, s); return 1; }
            }
            r = lifted(k, &in, &o, &c);
            if (i == dump_c && s == dump_s) {
                const CPU *L = t_called ? &t_snap : &c; int q;
                fprintf(stderr, "DUMP case %d state %d rva %#llx res %#x mxcsr in %#x cpu %#x lift %#x fl in %#llx cpu %#llx\n", i, s,
                        (unsigned long long)k->rva, r, in.mxcsr, o.mxcsr, L->mxcsr, (unsigned long long)in.fl, (unsigned long long)o.fl);
                for (q = 0; q < 16; q++) if (L->r[q] != o.r[q] || in.r[q] != o.r[q])
                    fprintf(stderr, "  r%-2d in %016llx cpu %016llx lift %016llx\n", q, (unsigned long long)in.r[q], (unsigned long long)o.r[q], (unsigned long long)L->r[q]);
                for (q = 0; q < 16; q++) if (memcmp(&L->x[q], &o.x[q], 16) || memcmp(&in.x[q], &o.x[q], 16))
                    fprintf(stderr, "  x%-2d in %016llx%016llx cpu %016llx%016llx lift %016llx%016llx\n", q,
                            (unsigned long long)in.x[q].q[1], (unsigned long long)in.x[q].q[0], (unsigned long long)o.x[q].q[1],
                            (unsigned long long)o.x[q].q[0], (unsigned long long)L->x[q].q[1], (unsigned long long)L->x[q].q[0]);
                for (q = 0; q < (int)in.npatch; q++) fprintf(stderr, "  patch %llx len %u: %016llx %016llx\n", (unsigned long long)in.p[q].addr,
                        in.p[q].len, (unsigned long long)*(uint64_t *)in.p[q].b, (unsigned long long)*(uint64_t *)(in.p[q].b + 8));
            }
            o.lres = r; o.kind = (uint32_t)(t_called ? 2 : t_kind);
            if (k->mk == 2) memcpy((void *)(uintptr_t)ea_of(k, &in), ea_save, 16);
            nstates_run++;
            if (r & ~(uint32_t)R_MXF) { form_bad[k->form]++; nbad++; }
            for (int b = 0; b < 12; b++) if (r >> b & 1) nres[b]++;
            form_n[k->form]++;
            if (stream) { fwrite(&in, sizeof in, 1, stdout); fwrite(&o, sizeof o, 1, stdout); }
            if ((r & ~(uint32_t)R_MXF) && form_bad[k->form] <= 3)
                fprintf(stderr, "LIFT != CPU: case %d rva %#llx form %d state %d res %#x (rip lift? cpu %#llx)\n", i,
                        (unsigned long long)k->rva, k->form, s, r, (unsigned long long)o.rip);
        }
    }
    fflush(stdout);
    for (i = 0; i < 4096; i++) if (form_bad[i]) fprintf(stderr, "FORM %d: %ld of %ld states differ\n", i, form_bad[i], form_n[i]);
    {
        long bad = 0; int f;
        for (f = 0; f < 4096; f++) bad += form_bad[f] ? 1 : 0;
        fprintf(stderr, "L3 CPU side: cases %d..%d, %ld states; lift != CPU in %ld states (%ld forms); classes: gpr %ld "
                "rip %ld flags %ld xmm %ld mxcsr %ld mxcsr-flags %ld (excused) mem %ld gs %ld ea %ld cpu-fault %ld "
                "trap %ld\n", from, to, nstates_run, nbad, bad, nres[0], nres[1], nres[2], nres[3],
                nres[4], nres[5], nres[6], nres[7], nres[8], nres[9], nres[10]);
    }
    return 0;
}

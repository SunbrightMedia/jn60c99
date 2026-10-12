/* jp8_engine.c -- the JUPITER-8 engine (jp8.h): plumbing only, nothing here computes a sample.
 * Memory: the template's regions (page 0, image, stack, heap, BUF, PB), each in a host arena under its own guest address
 * (JP8_RELOC band table, jp8_rt.c). Boot = the drive2 order of jp8_emu.JP8.boot (S3_STATUS D7): FACTORY 0x444FE0 and
 * BUILD 0x445020 at MXCSR 0x1F80, then FTZ|DAZ (0x9FC0), SETSR 0x4464F0 (the rate as a float in xmm1), the controller's
 * default push (jp8_hostinit_tab: 3 x HOSTPARAM 0x4465B0). A recall = the oracle's own recorded HOSTPARAM calls
 * (jp8_recall_tab.h). Render = per host sample VOICE_WRAP 0x3F80B0 x8 then MASTER_WRAP 0x3F8040, the lift gates' call
 * layout (jp8/tools/jp8_lift_seq.py: PAIR_V / OUT_M / VOUT / A2 / PAIR_M / OUT_L in BUF). Every call enters exactly as
 * jp8_emu.JX.call does: rsp = the template's rsp less 8, the RET sentinel at [rsp], rcx rdx r8 r9 written, MXCSR set;
 * every other register is what the previous call left (the oracle's too). Each lifted call goes through jp8_call_x
 * (jp8_rt.c), the call path the layer gates graded. Teeth (compile switches): JP8_FULL_TOOTH (a note-on plays key+1),
 * JP8_HOST_TOOTH (one bit of the constructed [HOST+8], the rate, flipped after the FACTORY). */
#include "jp8_cpu.h"
#include "jp8.h"
#include "../gen/jp8_recall_tab.h"
#ifndef JP8_RELOC
#error "jp8_engine.c needs JP8_RELOC (guest memory in host arenas)"
#endif

#define IB          0x180000000ULL
#define FACTORY     0x444FE0ULL
#define BUILD       0x445020ULL
#define SETSR       0x4464F0ULL
#define HOSTPARAM   0x4465B0ULL
#define NOTEON      0x445CF0ULL
#define NOTEOFF     0x445C90ULL
#define VOICE_WRAP  0x3F80B0ULL
#define MASTER_WRAP 0x3F8040ULL
#define ENGINE_VTBL (IB + 0xA704B0ULL)   /* CWaveGen vtable: [HOST] after the ctor (READ, jp8_emu.make_host) */
#define PROC_VPTR   (IB + 0xA54158ULL)   /* CPrmDSPJp8Plugin vtable: [proc[u]] after BUILD (READ, jp8_emu.build) */
#define HOST_RATE0  96000.0f             /* [HOST+8] after the ctor */
#define HOST_NVOICE 8                    /* [HOST+0x38] after the ctor */
#define N_UNITS     9
#define MX_BOOT     0x1F80u              /* the oracle's MXCSR before set_ftz */
#define MX_RUN      0x9FC0u              /* FTZ | DAZ | RNE, all masked: from set_ftz on */
#define BUF         0x700000000ULL       /* jp8_lift_seq.py's render layout */
#define PAIR_V      (BUF + 0x100)
#define OUT_M       (BUF + 0x200)
#define OUT_S       (BUF + 0x204)
#define PAIR_M      (BUF + 0x300)
#define OUT_L       (BUF + 0x400)
#define OUT_R       (BUF + 0x404)
#define A2          (BUF + 0x500)
#define VOUT        (BUF + 0x600)
#define NREG_MAX    8

extern int jp8_map(uint64_t base, uint64_t size);
extern int jp8_call_x(CPU *c, uint64_t rva);
extern const char *jp8_last_trap(void);
extern void jp8_heap_set(uint64_t ptr, uint64_t lim);
extern void jp8_hc_set(uint64_t hc);
extern uint64_t jp8_heap_get(void);

enum { ST_NONE = 0, ST_LIVE = 1, ST_DEAD = 2 };
static struct {
    int st;
    CPU cpu;
    uint32_t mx;                          /* the MXCSR the next lifted call runs at */
    uint64_t rsp, ret, host, state[N_UNITS], proc[N_UNITS], assign[N_UNITS];
    unsigned char *h_ret, *h_pairv, *h_outm, *h_pairm, *h_outl, *h_vout;
    int nreg; uint64_t rbase[NREG_MAX], rsize[NREG_MAX];   /* the mapped regions (kept across jp8_free) */
    uint64_t heap_hi;                     /* the highest bump pointer an earlier engine reached (zeroed on re-init) */
    char msg[256];
} E;

static int err(int code, const char *m) { snprintf(E.msg, sizeof E.msg, "%s", m); return code; }
const char *jp8_error(void) { return E.msg; }
int jp8_npatch(void) { return 64; }

/* guest -> host for the engine's own accesses: NULL unless [a, a+n) lies inside one mapped band */
void *jp8_guest(uint64_t a, size_t n) {
    uint64_t i = a >> 28; uint32_t off;
    if (!n || i >= JP8_NBANDS || !jp8_bhi[i] || ((a + n - 1) >> 28) != i) return NULL;
    off = (uint32_t)(a & 0x0FFFFFFFu);
    if (off < jp8_blo[i] || (uint64_t)off + n > jp8_bhi[i]) return NULL;
    return (void *)((uintptr_t)a + jp8_bdelta[i]);
}
static int rq(uint64_t a, uint64_t *v) { void *p = jp8_guest(a, 8); if (!p) return -1; memcpy(v, p, 8); return 0; }
static void wq(unsigned char *h, uint64_t v) { memcpy(h, &v, 8); }

static uint32_t crc32_of(const unsigned char *p, size_t n) {
    static uint32_t t[256]; static int ready; uint32_t c = 0xFFFFFFFFu; size_t i;
    if (!ready) { uint32_t k, j, x; for (k = 0; k < 256; k++) { x = k; for (j = 0; j < 8; j++) x = (x & 1) ? 0xEDB88320u ^ (x >> 1) : x >> 1; t[k] = x; } ready = 1; }
    for (i = 0; i < n; i++) c = t[(c ^ p[i]) & 0xFF] ^ (c >> 8);
    return c ^ 0xFFFFFFFFu;
}
static uint32_t le32(const unsigned char *p) { return (uint32_t)p[0] | (uint32_t)p[1] << 8 | (uint32_t)p[2] << 16 | (uint32_t)p[3] << 24; }
static uint64_t le64(const unsigned char *p) { return (uint64_t)le32(p) | (uint64_t)le32(p + 4) << 32; }

/* MXCSR of the host thread: saved on entry, restored on exit */
static uint32_t mx_save(void) {
#ifndef JP8_SOFTFP
    return _mm_getcsr();
#else
    return 0;
#endif
}
static void mx_restore(uint32_t m) {
#ifndef JP8_SOFTFP
    _mm_setcsr(m);
#else
    (void)m;
#endif
}

/* one lifted call, entered as jp8_emu.JX.call enters it */
static int call(uint64_t rva, uint64_t rcx, uint64_t rdx, uint64_t r8, uint64_t r9) {
    CPU *c = &E.cpu;
    c->r[4] = E.rsp; wq(E.h_ret, E.ret); c->mxcsr = E.mx;
    c->r[1] = rcx; c->r[2] = rdx; c->r[8] = r8; c->r[9] = r9;
    if (jp8_call_x(c, rva)) { E.st = ST_DEAD; snprintf(E.msg, sizeof E.msg, "%s (call rva 0x%llx)", jp8_last_trap(), (unsigned long long)rva); return -1; }
    return 0;
}
static int dead(uint32_t mx0) { mx_restore(mx0); E.st = ST_DEAD; return JP8_E_TRAP; }
static int ready(void) {
    if (E.st == ST_LIVE) return JP8_OK;
    if (E.st == ST_DEAD) return JP8_E_TRAP;
    return err(JP8_E_STATE, "engine not initialized");
}

/* the template (JP8T v1, jp8_template_export.py) into the arenas; the arenas of an earlier engine are reused */
static int load_template(const unsigned char *b, size_t len, uint64_t *sc) {
    size_t p = 12; uint32_t nreg, r, k, nruns;
    if (len < 16 || memcmp(b, "JP8T", 4) || le32(b + 4) != 1) return err(JP8_E_TEMPLATE, "template: not JP8T version 1");
    if (crc32_of(b, len - 4) != le32(b + len - 4)) return err(JP8_E_TEMPLATE, "template: crc32 mismatch");
    nreg = le32(b + 8);
    if (nreg > NREG_MAX) return err(JP8_E_TEMPLATE, "template: too many regions");
    if (E.nreg && (uint32_t)E.nreg != nreg) return err(JP8_E_TEMPLATE, "template: other regions than the mapped ones");
    for (r = 0; r < nreg; r++) {
        uint64_t base, size; unsigned char *h;
        if (p + 20 > len - 4) return err(JP8_E_TEMPLATE, "template: truncated region header");
        base = le64(b + p); size = le64(b + p + 8); nruns = le32(b + p + 16); p += 20;
        if (E.nreg) {
            if (E.rbase[r] != base || E.rsize[r] != size) return err(JP8_E_TEMPLATE, "template: other regions than the mapped ones");
            h = (unsigned char *)jp8_guest(base, (size_t)size);
            if (!h) return err(JP8_E_TEMPLATE, "template: region lost");
            if (base == 0x310000000ULL) { uint64_t hi = E.heap_hi > base ? E.heap_hi - base : 0; memset(h, 0, (size_t)(hi < size ? hi : size)); }
            else memset(h, 0, (size_t)size);
        } else {
            if (jp8_map(base, size)) return err(JP8_E_TEMPLATE, "template: a region cannot be mapped (band in use or no memory)");
            E.rbase[r] = base; E.rsize[r] = size;
            h = (unsigned char *)jp8_guest(base, (size_t)size);
            if (!h) return err(JP8_E_TEMPLATE, "template: region not reachable after mapping");
        }
        for (k = 0; k < nruns; k++) {
            uint32_t off, ln;
            if (p + 8 > len - 4) return err(JP8_E_TEMPLATE, "template: truncated run header");
            off = le32(b + p); ln = le32(b + p + 4); p += 8;
            if ((uint64_t)off + ln > size || p + ln > len - 4) return err(JP8_E_TEMPLATE, "template: run outside its region");
            memcpy(h + off, b + p, ln); p += ln;
        }
    }
    E.nreg = (int)nreg;
    if (p + 5 * 8 + 4 * 4 != len - 4) return err(JP8_E_TEMPLATE, "template: bad scalar block");
    for (k = 0; k < 5; k++) sc[k] = le64(b + p + 8 * k);   /* heap_ptr0 heap_limit hc0 rsp ret */
    return JP8_OK;
}

int jp8_init(const void *tmpl, size_t len, float rate) {
    uint64_t sc[5], v; uint32_t mx0; int u, rc; float f; int32_t nv;
    if (E.st != ST_NONE) jp8_free();
    E.msg[0] = 0;
    if (!tmpl) return err(JP8_E_ARG, "no template");
    if (rate != 44100.0f && rate != 96000.0f) return err(JP8_E_RATE, "rate other than 44100 or 96000 (S3_STATUS D3)");
    if ((rc = load_template((const unsigned char *)tmpl, len, sc)) != JP8_OK) return rc;
    jp8_heap_set(sc[0], sc[1]); jp8_hc_set(sc[2]);
    E.rsp = sc[3]; E.ret = sc[4];
    E.h_ret = (unsigned char *)jp8_guest(E.rsp - 8, 8);
    E.h_pairv = (unsigned char *)jp8_guest(PAIR_V, 16); E.h_outm = (unsigned char *)jp8_guest(OUT_M, 8);
    E.h_pairm = (unsigned char *)jp8_guest(PAIR_M, 16); E.h_outl = (unsigned char *)jp8_guest(OUT_L, 8);
    E.h_vout = (unsigned char *)jp8_guest(VOUT, 64);
    if (!E.h_ret || !E.h_pairv || !E.h_outm || !E.h_pairm || !E.h_outl || !E.h_vout || !jp8_guest(A2, 256))
        return err(JP8_E_TEMPLATE, "template: the stack or BUF region is missing");
    for (u = 0; u < 8; u++) {                       /* the master's 16 input pointers: voice u's main / sub words */
        wq((unsigned char *)jp8_guest(A2 + 16 * (uint64_t)u, 8), VOUT + 8 * (uint64_t)u);
        wq((unsigned char *)jp8_guest(A2 + 16 * (uint64_t)u + 8, 8), VOUT + 8 * (uint64_t)u + 4);
    }
    memset(&E.cpu, 0, sizeof E.cpu);
    E.st = ST_LIVE; mx0 = mx_save();
    /* FACTORY (ALLOC 0x8D0 + ctor 0x444000) and BUILD, before FTZ */
    E.mx = MX_BOOT;
    if (call(FACTORY, 0, 0, 0, 0)) return dead(mx0);
    E.host = E.cpu.r[0];
    if (rq(E.host, &v) || v != ENGINE_VTBL || !jp8_guest(E.host + 8, 4) || !jp8_guest(E.host + 0x38, 4)) { mx_restore(mx0); E.st = ST_DEAD; return err(JP8_E_STATE, "factory: no CWaveGen"); }
    memcpy(&f, jp8_guest(E.host + 8, 4), 4); memcpy(&nv, jp8_guest(E.host + 0x38, 4), 4);
    if (f != HOST_RATE0 || nv != HOST_NVOICE) { mx_restore(mx0); E.st = ST_DEAD; return err(JP8_E_STATE, "factory: HOST rate / voices not the ctor's"); }
#ifdef JP8_HOST_TOOTH
    ((unsigned char *)jp8_guest(E.host + 8, 4))[2] ^= 0x10;
#endif
    if (call(BUILD, E.host, 0, 0, 0)) return dead(mx0);
    for (u = 0; u < N_UNITS; u++) {
        if (rq(E.host + 0xA0 + 64 * (uint64_t)u, &E.state[u]) || rq(E.host + 0xB0 + 64 * (uint64_t)u, &E.proc[u]) ||
            rq(E.host + 0xB8 + 64 * (uint64_t)u, &E.assign[u]) || rq(E.proc[u], &v) || v != PROC_VPTR || !jp8_guest(E.state[u], 8))
            { mx_restore(mx0); E.st = ST_DEAD; return err(JP8_E_STATE, "BUILD: unit pointers not the plugin's"); }
    }
    /* FTZ, SETSR (float in xmm1, the rest of the register zero), the controller's default push */
    E.mx = MX_RUN;
    memset(&E.cpu.x[1], 0, sizeof E.cpu.x[1]); E.cpu.x[1].f[0] = rate;
    if (call(SETSR, E.host, 0, 0, 0)) return dead(mx0);
    memcpy(&f, jp8_guest(E.host + 8, 4), 4);
    if (f != rate) { mx_restore(mx0); E.st = ST_DEAD; return err(JP8_E_STATE, "SETSR did not land"); }
    for (u = 0; u < JP8_NHOSTINIT; u++)
        if (call(HOSTPARAM, E.host, jp8_hostinit_tab[u][0], jp8_hostinit_tab[u][1], 0)) return dead(mx0);
    mx_restore(mx0);
    return JP8_OK;
}

int jp8_hostparam(uint32_t hid, uint32_t raw) {
    uint32_t mx0; int rc = ready();
    if (rc) return rc;
    mx0 = mx_save();
    if (call(HOSTPARAM, E.host, hid, raw, 0)) return dead(mx0);
    mx_restore(mx0); return JP8_OK;
}

int jp8_recall(int patch) {
    uint32_t mx0; int i, rc = ready();
    if (rc) return rc;
    if (patch < 0 || patch > 63) return err(JP8_E_ARG, "patch outside 0..63");
    mx0 = mx_save();
    for (i = 0; i < JP8_NPOOL; i++)
        if (call(HOSTPARAM, E.host, jp8_recall_hid[i], jp8_recall_val[patch][i], 0)) return dead(mx0);
    mx_restore(mx0); return JP8_OK;
}

static int note(uint64_t fn, int key, int vel) {
    uint32_t mx0; int rc = ready();
    if (rc) return rc;
    if (key < 0 || key > 127 || vel < 0 || vel > 127) return err(JP8_E_ARG, "key or velocity outside 0..127");
#ifdef JP8_FULL_TOOTH
    if (fn == NOTEON) key = (key + 1) & 127;
#endif
    mx0 = mx_save();
    if (call(fn, E.host, (uint64_t)key, (uint64_t)vel, 0)) return dead(mx0);
    mx_restore(mx0); return JP8_OK;
}
int jp8_note_on(int key, int vel) { return note(NOTEON, key, vel); }
int jp8_note_off(int key, int vel) { return note(NOTEOFF, key, vel); }

/* one host sample: the eight voices, then the master on their words (jp8_lift_c.py's render event, call for call) */
static int sample(uint32_t *w, float *l, float *r) {
    int v;
    for (v = 0; v < 8; v++) {
        wq(E.h_outm, 0); wq(E.h_pairv, OUT_M); wq(E.h_pairv + 8, OUT_S);
        if (call(VOICE_WRAP, E.state[v], (uint64_t)v, PAIR_V, 0)) return -1;
        memcpy(E.h_vout + 8 * v, E.h_outm, 8);
        if (w) memcpy(w + 2 * v, E.h_outm, 8);
    }
    wq(E.h_outl, 0); wq(E.h_pairm, OUT_L); wq(E.h_pairm + 8, OUT_R);
    if (call(MASTER_WRAP, E.state[8], A2, PAIR_M, 0)) return -1;
    if (w) memcpy(w + 16, E.h_outl, 8);
    if (l) memcpy(l, E.h_outl, 4);
    if (r) memcpy(r, E.h_outl + 4, 4);
    return 0;
}
static int render(uint32_t *w, float *L, float *R, int n) {
    uint32_t mx0; int i, rc;
    if (n < 0) return err(JP8_E_ARG, "negative sample count");
    rc = ready();
    if (rc) {
        if (w) memset(w, 0, sizeof *w * 18 * (size_t)n);
        if (L) memset(L, 0, sizeof *L * (size_t)n);
        if (R) memset(R, 0, sizeof *R * (size_t)n);
        return rc;
    }
    mx0 = mx_save();
    for (i = 0; i < n; i++)
        if (sample(w ? w + 18 * (size_t)i : NULL, L ? L + i : NULL, R ? R + i : NULL)) {
            if (w) memset(w + 18 * (size_t)i, 0, sizeof *w * 18 * (size_t)(n - i));
            if (L) memset(L + i, 0, sizeof *L * (size_t)(n - i));
            if (R) memset(R + i, 0, sizeof *R * (size_t)(n - i));
            return dead(mx0);
        }
    mx_restore(mx0); return JP8_OK;
}
int jp8_render(float *L, float *R, int n) { return render(NULL, L, R, n); }
int jp8_render_words(uint32_t *w18, int n) { return w18 || !n ? render(w18, NULL, NULL, n) : err(JP8_E_ARG, "no buffer"); }

void jp8_free(void) {
    uint64_t hp = jp8_heap_get();
    if (hp > E.heap_hi) E.heap_hi = hp;
    E.st = ST_NONE; E.host = 0;
}
uint64_t jp8_unit_state(int u) { return (u >= 0 && u < N_UNITS && E.st != ST_NONE) ? E.state[u] : 0; }
uint64_t jp8_host_obj(void) { return E.st != ST_NONE ? E.host : 0; }
uint64_t jp8_heap_top(void) { return jp8_heap_get(); }

/* jx_bridge.c -- the STANDALONE JX-3P engine (charter 7b: the port must play).
 *
 * THE MEMORY IS THE PLUGIN'S (JX-11, 2026-10-10). The port holds the plugin's whole heap, in the plugin's own
 * layout, at the plugin's own guest addresses: one block, started from the plugin's heap after its boot
 * (jx3p/gen/jx_guest_<rate>k.bin, jx3p/tools/jx_guest_export.py). Every object of the engine -- the nine unit
 * states, their parameter objects, note managers, note stores and assigners, the HOST -- is a view into it,
 * found by following the plugin's own pointers from the HOST. Patch loads and host edits run the plugin's OWN
 * parameter system on it: its host entry 0x3F9A30 and everything it reaches, lifted from the binary one C
 * statement per instruction (jx3p/src/jx_lift.c, jx3p/tools/jx_lift.py; graded EXACTLY 0 against the plugin by
 * jx_lift_gate.py) and run under the JP8's runtime (jp8/src/jp8_rt.c, JP8_RELOC: guest addresses kept, every
 * access translated into the blocks below). The transcribed parts run on the same bytes:
 *   note managers        jx_alloc.c     (EXACTLY 0, 22,008 events)
 *   note store           jx_nstore.c    (EXACTLY 0)
 *   key tracker          jx_ktrack.c    (EXACTLY 0, 13,593 events)
 *   note/gate dispatch   jx_dispatch_note.c (EXACTLY 0, 2,500 dispatches)
 *   clock tick, step machine jx_seq.c   (JX-7)
 *   voice + master       jx_voice_render.c / jx_master_render.c (64/64 patches EXACTLY 0 vs the plugin)
 *   here: the units' wrappers and ramp sweeps (0x377080 / 0x377010, 0x3F40E0 / 0x3F4A40) and the engine
 *   render's preamble and output gain stage (0x3F9220), on the plugin's own records and HOST cells.
 * A pointer the plugin stored is a guest address; transcribed code reads it through JX_G2H.
 *
 * FP MODE: callers MUST run with FTZ/DAZ where the hardware has it
 * (jx_enable_hw_ftz from jx_ftz.c); WASM has no MXCSR -- the same caveat
 * the JUNO web build carries. The lifted calls set the plugin's MXCSR themselves and the caller's is put back.
 */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
#include <math.h>

/* ---- the guest heap's translation for transcribed code: host = guest + delta (set at init) ---- */
unsigned long long jx_g2h_delta;
#define JXG_H(g)       ((uint8_t *)(uintptr_t)((unsigned long long)(g) + jx_g2h_delta))
#define JXS_PTR(ns, v) JXG_H(v)              /* jx_seq.c: the note store's +0x20 is the plugin's own pointer */
#define JXA_UNIT_PTRS 1                      /* jx_alloc.c: each note manager is the plugin's own object */

/* ---- proven modules (single-file link; see jx_full_gate.sh) ---- */
#include "../src/jx_alloc.c"
#include "../src/jx_nstore.c"
#include "../src/jx_ktrack.c"
#include "../src/jx_dispatch_note.c"
#include "../src/jx_seq.c"
#define JX_NS_SZ 0xFF0             /* the note store's allocation (4080 bytes, EXECUTED 2026-10-10) */
#include "../src/jx_param_get.h"

/* ---- the plugin's parameter system, lifted, and its runtime ---- */
#define JP8_RELOC 1
#ifndef JP8_RELOC_CHECK
#define JP8_RELOC_CHECK 2          /* an access outside every block is diverted and reported after the call */
#endif
#if !(defined(__x86_64__) || defined(_M_X64)) && !defined(JP8_SOFTFP)
#define JP8_SOFTFP 1               /* no x86 MXCSR: FTZ/DAZ in software, the oracle's semantics */
#endif
#include "../../jp8/src/jp8_rt.c"
#include "../src/jx_lift.c"
/* THE IMAGE GUARD (Linux, native): the image block holds only the pages the guest image carries
 * (jx_guest_export.py image_pages: the census and a static scan of the lifted source); every other page of the
 * block is made no-access, so a read the census missed crashes the gate that made it instead of reading zeros */
#if defined(__linux__) && !defined(JX_NO_IMAGE_GUARD)
#include <sys/mman.h>
#define JX_IMAGE_GUARD 1
#else
#define JX_IMAGE_GUARD 0
#endif

uint64_t jx_voice_render(void *vstate, int v, void *pair);
void *jx_master_render(void *mstate, void *a2, void *a3);

#define NV        8
#define NUNITS    9
#define SNAP_V    0x60000
#define SNAP_M    0xAAD000
#define HOSTPARAM 0x3F9A30         /* the engine's host entry */

typedef struct {
    uint8_t *vstate[NV];           /* the unit states: views into the guest heap */
    uint8_t *vhigh[NV];            /* vstate + 0xA60000 */
    uint8_t *mstate;
    uint8_t *proc[NUNITS];         /* the parameter objects */
    jx_alloc mgr;                  /* the note managers */
    uint8_t *ns[NUNITS];           /* the note stores */
    uint8_t *kt[NUNITS];           /* the assigners (the HOST's assigner pointer and the manager's +0x520) */
    uint8_t *host;                 /* the engine HOST */
    uint64_t stg[NUNITS];          /* the unit states' guest addresses */
    jx_dn_cbs dn;
    int      host_stage_off;
    int64_t  clock;                /* samples rendered */
    const uint8_t *bank;
    size_t   bank_len;
    float    vcells[16];           /* the voice->master seam */
    /* the guest image */
    uint64_t hb, hlen, hostg, ib, slo, slen, rsp;
    uint32_t mx;
    float    rate0;
    uint8_t *file;                 /* the image file (the patch records point into it) */
    uint32_t npatch;
    const uint8_t *prec[64];
    uint32_t nrec[64];
    CPU      cpu;
    int      lift_err;
    char     lift_msg[200];
    unsigned long lift_calls;
} jx3p;

static jx3p G;

/* ---- guest cells ---- */
static uint64_t gq(const uint8_t *p) { uint64_t v; memcpy(&v, p, 8); return v; }
static int32_t  gi(const uint8_t *p) { int32_t v; memcpy(&v, p, 4); return v; }
static float    gf(const uint8_t *p) { float v; memcpy(&v, p, 4); return v; }
static void     si32(uint8_t *p, int32_t v) { memcpy(p, &v, 4); }
static void     sf32(uint8_t *p, float v) { memcpy(p, &v, 4); }
static void     sq64(uint8_t *p, uint64_t v) { memcpy(p, &v, 8); }
/* a guest address in the heap block (n bytes), or NULL */
static uint8_t *jxg_heap(uint64_t g, uint64_t n)
{
    if (g < G.hb || g + n > G.hb + G.hlen || g + n < g) return NULL;
    return JXG_H(g);
}
/* a guest address in any mapped block (the image's included), or NULL */
static uint8_t *jxg_any(uint64_t g, uint64_t n)
{
    uint64_t i = g >> 28;
    uint32_t off = (uint32_t)(g & 0x0FFFFFFFu);
    if (i >= JP8_NBANDS || !jp8_bhi[i] || off < jp8_blo[i] || (uint64_t)off + n > jp8_bhi[i]) return NULL;
    return (uint8_t *)(uintptr_t)(g + jp8_bdelta[i]);
}

/* every block of a previous instance freed: a fresh init starts from fresh (zero) blocks */
static void jxg_unmap_all(void)
{
    for (unsigned i = 0; i < JP8_NBANDS; ++i)
        if (jp8_braw[i]) {
#if JX_IMAGE_GUARD                                /* the guard's no-access pages opened before the block is freed */
            mprotect((void *)(uintptr_t)((((uint64_t)i << 28) + jp8_blo[i]) + jp8_bdelta[i]),
                     jp8_bhi[i] - jp8_blo[i], PROT_READ | PROT_WRITE);
#endif
            free(jp8_braw[i]);
            jp8_braw[i] = NULL; jp8_bdelta[i] = 0; jp8_blo[i] = jp8_bhi[i] = 0;
        }
}

/* ---- one call into the lifted code: rsp the image's, the plugin's MXCSR, the caller's MXCSR put back ---- */
static int jxg_call(uint64_t rva, uint64_t rcx, uint64_t rdx, uint64_t r8, uint64_t r9, uint64_t *rax)
{
    int t;
#ifndef JP8_SOFTFP
    unsigned int mx0 = _mm_getcsr();
#endif
    uint8_t *slot = jxg_any(G.rsp - 8, 8);
    if (G.lift_err) return 1;                  /* a trapped engine is not the plugin's any more: no more calls */
    if (slot) sq64(slot, 0x105000ULL);         /* the return address a call pushes (the oracle's sentinel) */
    G.cpu.r[4] = G.rsp;
    G.cpu.mxcsr = G.mx;
    t = jp8_call(&G.cpu, rva, rcx, rdx, r8, r9);
#ifndef JP8_SOFTFP
    _mm_setcsr(mx0);
#endif
    ++G.lift_calls;
    if (t) {
        G.lift_err = 1;
        snprintf(G.lift_msg, sizeof G.lift_msg, "call %lu (rva 0x%llx, rdx %llu, r8 %llu): %s", G.lift_calls,
                 (unsigned long long)rva, (unsigned long long)rdx, (unsigned long long)r8, jp8_last_trap());
        return 1;
    }
    if (rax) *rax = G.cpu.r[0];
    return 0;
}

/* ---- the engine HOST's cells (jx3p/docs/HOST_LAYER.md 3: the render 0x3F9220 reads them) ---- */
#define H_NVOICES 0x38
#define H_GAIN    0x860
#define H_GSTEP   0x864
#define H_GLEFT   0x868
#define H_GDELAY  0x86C
#define H_GTIME   0x870
#define H_RATESRC 0x878
/* the engine rate: the HOST's rate source [HOST+0x878] -- the HOST itself -- through its vtable +0x20 (0x34ADE0:
 * movss xmm0, [rcx+8]); init refuses an image where it is anything else */
static float jxg_rate(void) { return gf(JXG_H(gq(G.host + H_RATESRC)) + 8); }
static int32_t jxg_nvoices(void)
{
#if JX_VC_TOOTH   /* TOOTH (jx_product_gate.py --tooth-voices): every voice unit plays, the count ignored */
    return NV;
#else
    return gi(G.host + H_NVOICES);
#endif
}

/* ---- the public API ---- */

static void jx_release(void)
{
    jxg_unmap_all();
    free(G.file);
    free((void *)G.bank);
    memset(&G, 0, sizeof G);
    jx_g2h_delta = 0;
}

static uint8_t *read_file(const char *path, size_t *len)
{
    FILE *f = fopen(path, "rb");
    uint8_t *b;
    long L;
    if (!f) return NULL;
    fseek(f, 0, SEEK_END); L = ftell(f); rewind(f);
    if (L <= 0 || !(b = malloc((size_t)L))) { fclose(f); return NULL; }
    if (fread(b, 1, (size_t)L, f) != (size_t)L) { fclose(f); free(b); return NULL; }
    fclose(f);
    *len = (size_t)L;
    return b;
}

static uint32_t crc32_le(const uint8_t *p, size_t n)
{
    uint32_t c = 0xFFFFFFFFu;
    for (size_t i = 0; i < n; ++i) {
        c ^= p[i];
        for (int k = 0; k < 8; ++k) c = (c >> 1) ^ (0xEDB88320u & (0u - (c & 1u)));
    }
    return ~c;
}

/* the guest image (JXG1, jx_guest_export.py): the blocks mapped and filled, the patch records indexed */
static int guest_load(const char *path)
{
    size_t len, o = 8;
    uint8_t *b = read_file(path, &len);
    uint32_t n, crc;
    uint64_t img_lo = ~0ULL, img_hi = 0;
#define NEED(k) do { if (o + (k) > len - 4) return 0; } while (0)
    if (!b) return 0;
    G.file = b;
    if (len < 96 || memcmp(b, "JXG1", 4) || gi(b + 4) != 1) return 0;
    memcpy(&crc, b + len - 4, 4);
    if (crc32_le(b, len - 4) != crc) return 0;
    memcpy(&G.hb, b + o, 8); memcpy(&G.hlen, b + o + 8, 8); memcpy(&G.hostg, b + o + 16, 8);
    memcpy(&G.ib, b + o + 24, 8); memcpy(&G.slo, b + o + 32, 8); memcpy(&G.slen, b + o + 40, 8);
    memcpy(&G.rsp, b + o + 48, 8); o += 56;
    memcpy(&G.mx, b + o, 4); memcpy(&G.rate0, b + o + 4, 4); o += 8;
    if (jp8_map(G.hb, G.hlen) || jp8_map(G.slo, G.slen)) return 0;
    jx_g2h_delta = (unsigned long long)(uintptr_t)jp8_host(G.hb) - G.hb;
    NEED(4); memcpy(&n, b + o, 4); o += 4;
    for (uint32_t i = 0; i < n; ++i) {                      /* the heap's nonzero runs */
        uint32_t off, ln;
        NEED(8); memcpy(&off, b + o, 4); memcpy(&ln, b + o + 4, 4); o += 8;
        NEED(ln);
        if ((uint64_t)off + ln > G.hlen) return 0;
        memcpy(JXG_H(G.hb + off), b + o, ln); o += ln;
    }
    {   size_t o2 = o;                                      /* the image pages: one block over their span */
        NEED(4); memcpy(&n, b + o2, 4); o2 += 4;
        for (uint32_t i = 0; i < n; ++i) {
            uint32_t rva, ln;
            if (o2 + 8 > len - 4) return 0;
            memcpy(&rva, b + o2, 4); memcpy(&ln, b + o2 + 4, 4); o2 += 8 + ln;
            if (rva < img_lo) img_lo = rva;
            if ((uint64_t)rva + ln > img_hi) img_hi = (uint64_t)rva + ln;
        }
        if (!n || o2 > len - 4 || jp8_map(G.ib + img_lo, img_hi - img_lo)) return 0;
    }
    memcpy(&n, b + o, 4); o += 4;
    {   size_t o3 = o;
        for (uint32_t i = 0; i < n; ++i) {
            uint32_t rva, ln;
            memcpy(&rva, b + o, 4); memcpy(&ln, b + o + 4, 4); o += 8;
            memcpy(jxg_any(G.ib + rva, ln), b + o, ln); o += ln;
        }
#if JX_IMAGE_GUARD
        for (uint64_t a = img_lo; a < img_hi; a += 0x1000) {
            size_t o4 = o3;
            int shipped = 0;
            for (uint32_t i = 0; i < n && !shipped; ++i) {
                uint32_t rva, ln;
                memcpy(&rva, b + o4, 4); memcpy(&ln, b + o4 + 4, 4); o4 += 8 + ln;
                shipped = a >= rva && a < (uint64_t)rva + ln;
            }
            if (!shipped) mprotect(jxg_any(G.ib + a, 0x1000), 0x1000, PROT_NONE);
        }
#else
        (void)o3;
#endif
    }
    NEED(4); memcpy(&G.npatch, b + o, 4); o += 4;
    if (G.npatch > 64) return 0;
    for (uint32_t p = 0; p < G.npatch; ++p) {               /* the factory bank's patch records */
        NEED(4); memcpy(&G.nrec[p], b + o, 4); o += 4;
        NEED(8 * (size_t)G.nrec[p]);
        G.prec[p] = b + o; o += 8 * (size_t)G.nrec[p];
    }
#undef NEED
    return o == len - 4;
}

/* the objects, by the plugin's own pointers from the HOST (jx_emu.build: HOST+80/+96/+0x68 + 64 u the state,
 * the parameter object, the assigner; HOST+0x78 + 0x40 u the note manager, its +0x518 the note store, +0x520
 * the assigner again) */
static int guest_link(void)
{
    uint8_t *h = jxg_heap(G.hostg, 0x880);
    if (!h) return 0;
    G.host = h;
    {   uint8_t *rs = jxg_heap(gq(h + H_RATESRC), 16), *vt, *f;
        if (!rs || !(vt = jxg_any(gq(rs), 0x28)) || !(f = jxg_any(gq(vt) + 0x20, 8)) ||
            gq(vt + 0x20) != G.ib + 0x34ADE0) return 0;     /* the rate getter is 0x34ADE0: [rcx+8] */
        (void)f;
    }
    for (int u = 0; u < NUNITS; ++u) {
        uint64_t st = gq(h + 80 + 64 * u), pr = gq(h + 96 + 64 * u), asg = gq(h + 0x68 + 64 * u);
        uint8_t *un = jxg_heap(gq(h + 0x78 + 0x40 * u), JXA_UNIT_SZ);
        if (!un || !jxg_heap(st, SNAP_M) || !jxg_heap(pr, 0x700) || !jxg_heap(asg, 0xB8)) return 0;
        if (gq(un + 0x520) != asg || !jxg_heap(gq(un + 0x518), JX_NS_SZ)) return 0;
        G.stg[u] = st;
        G.proc[u] = JXG_H(pr);
        G.mgr.u[u] = un;
        G.ns[u] = JXG_H(gq(un + 0x518));
        G.kt[u] = JXG_H(asg);
        if (u < NV) { G.vstate[u] = JXG_H(st); G.vhigh[u] = JXG_H(st + 0xA60000); }
        else G.mstate = JXG_H(st);
    }
    return 1;
}

/* jx3p_init is a FRESH instance every time it is called (the gates call it once per patch): what a previous
 * call held is freed. image_path: the guest image (jx3p/gen/jx_guest_44k.bin or _96k); bank_path: the bank
 * file; the third argument is unused (it named the old recall data). */
int jx3p_init(const char *image_path, const char *bank_path, const char *unused)
{
    (void)unused;
    jx_release();
    if (!guest_load(image_path) || !guest_link()) { jx_release(); return 0; }
    {   size_t bl;
        uint8_t *bk = read_file(bank_path, &bl);
        if (!bk) { jx_release(); return 0; }
        G.bank = bk; G.bank_len = bl;
    }
    return 1;
}

/* the last lifted call's trap (an access outside the blocks, an indirect target not lifted, an unsupported
 * instruction), "" when none: after one, the engine stops taking parameter calls */
const char *jx3p_lift_error(void) { return G.lift_err ? G.lift_msg : ""; }
unsigned long jx3p_lift_calls(void) { return G.lift_calls; }

/* ONE HOST EDIT: (id, value) through the plugin's own host entry, as its render driver applies a kind-2
 * record at a block's start (the 32-bit value in r8). Returns the entry's return value, or -1 after a trap. */
long long jx3p_param(int id, int value)
{
    uint64_t rax = 0;
    if (jxg_call(HOSTPARAM, G.hostg, (uint64_t)(uint32_t)id, (uint64_t)(uint32_t)value, 0, &rax)) return -1;
    return (long long)rax;
}

/* A PATCH LOAD: the factory patch's records -- what the plugin's patch browser queues (writePatch first, so
 * every patch change fades as the plugin's does: 0.5 s at gain 0, then 10 ms in; MASTER TUNE; the patch
 * tree) -- through the host entry, on the RUNNING engine, as the plugin applies them (jx3p/docs/
 * HOST_LAYER.md 3b). A fresh jx3p_init and one jx3p_recall is the plugin booted with that patch. */
void jx3p_recall(int idx)
{
    if (idx < 0 || (uint32_t)idx >= G.npatch) return;
    for (uint32_t k = 0; k < G.nrec[idx]; ++k) {
        uint32_t id, v;
        memcpy(&id, G.prec[idx] + 8 * k, 4); memcpy(&v, G.prec[idx] + 8 * k + 4, 4);
        if (jxg_call(HOSTPARAM, G.hostg, id, v, 0, NULL)) return;
    }
}

/* A RECORD LIST: n (id, 32-bit value) pairs through the host entry in order -- a patch the factory bank does not
 * hold (the gates' variants), or a host's edits. Returns 0, or -1 after a trap. */
int jx3p_records(const uint32_t *idval, int n)
{
    for (int k = 0; k < n; ++k)
        if (jxg_call(HOSTPARAM, G.hostg, idval[2 * k], idval[2 * k + 1], 0, NULL)) return -1;
    return 0;
}

/* dispatch a tracker post into the right unit's proc + DSP state; the seam object for slot v is the plugin's
 * [proc+0x110+0x10 v] (its +0x50 the temper table, +0x58, +0x5C), read when the post is made */
static void unit_set48(void *u, int what, int pid, int val)
{
    int unit = (int)(intptr_t)u, v;
    uint8_t *st = (unit < NV) ? G.vstate[unit] : G.mstate, *o110, *tt;
    (void)what;
    if (pid >= 433 && pid <= 440) v = pid - 433;
    else if (pid >= 450 && pid <= 457) v = pid - 450;
    else return;
    o110 = jxg_heap(gq(G.proc[unit] + 0x110 + 0x10 * v), 0x60);
    tt = o110 ? jxg_any(gq(o110 + 0x50) - 44, 23 * 4) : NULL;
    if (!o110 || !tt) {                       /* not the plugin's layout: refuse loudly, as a trap */
        if (!G.lift_err) { G.lift_err = 1; snprintf(G.lift_msg, sizeof G.lift_msg, "unit %d slot %d: no seam object", unit, v); }
        return;
    }
    G.dn.o110_58 = gi(o110 + 0x58);
    G.dn.o110_5c = gi(o110 + 0x5C);
    G.dn.temper23 = (const float *)(const void *)tt;
    if (pid <= 440) jx_dispatch_note_cb(&G.dn, G.proc[unit], st, v, 2, val);
    else            jx_dispatch_gate_cb(&G.dn, G.proc[unit], st, v, 2, val);
}
/* the assigner's parameter read (vtable +0x50, 0x357E60): its parent's GET (the unit's parameter object,
 * vtable +0x60, 0x3E8E10) -- a dword at the id's offset in the parameter object (jx_param_get.h, EXECUTED),
 * found or not */
static int unit_get50(void *u, int what, int pid, int32_t *out)
{
    int unit = (int)(intptr_t)u, lo = 0, hi = JX_PARAM_GET_N - 1;
    (void)what;
    while (lo <= hi) {
        int mid = (lo + hi) / 2;
        if (JX_PARAM_GET[mid][0] == pid) { memcpy(out, G.proc[unit] + JX_PARAM_GET[mid][1], 4); return 1; }
        if (JX_PARAM_GET[mid][0] < pid) lo = mid + 1; else hi = mid - 1;
    }
    return 0;
}
/* the assigner's time read (vtable +0x70, 0x357EF0): its clock [asg+0xB0] / 96, signed, truncating */
static int64_t kt_clock(int u) { int64_t c; memcpy(&c, G.kt[u] + 0xB0, 8); return c; }
static uint32_t unit_get70(void *u)
{ return (uint32_t)(kt_clock((int)(intptr_t)u) / 96); }
/* THE NOTE STORE'S OUTPUTS (jx3p/src/jx_seq.c): its vtable +0 / +8 play into the unit's assigner (+0xFD8:
 * vtable +0x18 note-on, +0x10 note-off), and its drain seam (the tail jump to 0x3EF210 at a full drain)
 * releases its 16 playing columns */
static void seq_kt_on(void *user, int unit, int note, int vel)
{   jx_ktrack_cbs c = { unit_set48, unit_get50, unit_get70, (void *)(intptr_t)unit };
    (void)user; jx_ktrack_on(G.kt[unit], &c, note, vel); }
static void seq_kt_off(void *user, int unit, int note, int vel)
{   jx_ktrack_cbs c = { unit_set48, unit_get50, unit_get70, (void *)(intptr_t)unit };
    (void)user; (void)vel; jx_ktrack_off_full(G.kt[unit], &c, note); }
static uint64_t g_bad_hook;          /* a step-choice function jx_seq.c does not hold: the first one seen */
static void seq_bad_hook(void *user, uint64_t h) { (void)user; if (!g_bad_hook) g_bad_hook = h ? h : 1; }
static jx_seq_cbs seq_cbs(int unit)
{   jx_seq_cbs c = { seq_kt_on, seq_kt_off, seq_bad_hook, NULL, unit }; return c; }
static void ns_drain(void *u, int kind, int a, int b2)
{
    int unit = (int)(intptr_t)u;
    jx_seq_cbs c = seq_cbs(unit);
    (void)kind; (void)a; (void)b2;
    jxs_3EF210(G.ns[unit], &c);                  /* the only seam kind: JXN_CB_EF210 */
}

static void sink518_on(void *u, int unit, int note, int vel)
{   jx_nstore_cbs c = { ns_drain, (void *)(intptr_t)unit };
    (void)u; jx_nstore_on5100(G.ns[unit], &c, note, vel); }
static void sink518_off(void *u, int unit, int note, int vel)
{   jx_nstore_cbs c = { ns_drain, (void *)(intptr_t)unit };
    (void)u; jx_nstore_off(G.ns[unit], &c, note, vel); }
static void sink520_on(void *u, int unit, int note, int vel)
{   jx_ktrack_cbs c = { unit_set48, unit_get50, unit_get70,
                        (void *)(intptr_t)unit };
    (void)u; jx_ktrack_on(G.kt[unit], &c, note, vel); }
static void sink520_off(void *u, int unit, int note, int vel)
{   jx_ktrack_cbs c = { unit_set48, unit_get50, unit_get70,
                        (void *)(intptr_t)unit };
    (void)u; (void)vel; jx_ktrack_off_full(G.kt[unit], &c, note); }

static const jx_alloc_cbs g_acbs =
    { sink518_on, sink518_off, sink520_on, sink520_off, NULL };

void jx3p_note_on(int note, int vel)
{ jx_alloc_note_on(&G.mgr, &g_acbs, note, vel); }
void jx3p_note_off(int note)
{ jx_alloc_note_off(&G.mgr, &g_acbs, note, 0x40); }

/* ---- THE UNITS' WRAPPER AND RAMP RECORDS, the plugin's own (unit state +0x14 the flag, +0xAAC308 the
 * start-mute count, +0x58 the 40-byte ramp slots, +0x70 / +0x78 the active ids' vector) ---- */
/* 0x3F4A40 -- one ramp slot's tick: 1 while it stays active */
static int jxg_ramp_tick(uint8_t *s)
{
    int32_t counter, period;
    float a, cur, lim, sign;
    uint8_t *t;
    if (!s[0x1C]) return 0;
    counter = gi(s + 0x24) + 1;                 /* inc dword [rcx+0x24] */
    si32(s + 0x24, counter);
    period = gi(s + 0x20);
    if (counter < period) return 1;             /* jl */
    sign = gf(s + 8);
    a = sign + gf(s + 0xC);
    t = JXG_H(gq(s));
    si32(s + 0x24, 0);
    sf32(s + 0xC, a);
    sf32(t, a + gf(s + 0x10));
    cur = gf(t); lim = gf(s + 0x14);
    if (!(0.0f >= sign)) {                      /* comiss 0, sign; jae */
        if (!(cur >= lim)) return 1;            /* rising, below the limit */
    } else {
        if (cur > lim) return 1;                /* falling, above the limit */
    }
    sf32(t, lim);
    si32(s + 0xC, 0);                           /* mov [rcx+0xC], edx (= 0) */
    s[0x1C] = 0;
    return 0;
}
/* 0x3F40E0 -- the sweep: every active id's slot ticked, a dead id erased from the vector (the tail moved down,
 * the end pointer -4) */
static void jxg_ramp_sweep(uint8_t *st)
{
    uint64_t b = gq(st + 0x70);
    if (b == gq(st + 0x78)) return;
    for (;;) {
        int32_t id = gi(JXG_H(b));
        if (jxg_ramp_tick(JXG_H(gq(st + 0x58) + (uint64_t)((int64_t)id * 40)))) {
            b += 4;
        } else {
            uint64_t e = gq(st + 0x78);
            memmove(JXG_H(b), JXG_H(b + 4), (size_t)(e - (b + 4)));
            sq64(st + 0x78, e - 4);
        }
        if (b == gq(st + 0x78)) break;
    }
}

void jx3p_render(float *L, float *R, int n)
{
    /* THE MASTER'S INPUT ARRAY IN 8-BYTE SLOTS (2026-10-10, jx_wasm_check.py): the transcribed
     * master reads its voice inputs at the plugin's x64 byte offsets -- `**(_DWORD **)(a2 + 16 * v)`
     * -- so each slot of a2 is a uint64_t with the pointer in its low bytes. The voice pairs and the
     * output pair are read by index (`a2[1]`, `a3[1]`): native pointer arrays. With `void *` slots
     * for a2 the 32-bit WebAssembly master read entries 0, 4, 8, 12 and past the array -- voices 0,
     * 2, 4, 6 and garbage -- while the x64 build was right. */
    void *pairs[NV][2];
    uint64_t a2[16];
    uint32_t outL, outR;
    void *a3[2] = { &outL, &outR };
    int32_t nv = jxg_nvoices();
    for (int v = 0; v < NV; ++v) {
        pairs[v][0] = &G.vcells[2 * v];
        pairs[v][1] = &G.vcells[2 * v + 1];
        a2[2 * v] = (uint64_t)(uintptr_t)&G.vcells[2 * v];
        a2[2 * v + 1] = (uint64_t)(uintptr_t)&G.vcells[2 * v + 1];
    }
    /* THE ENGINE RENDER'S PREAMBLE (rva 0x3F9220, READ; 2026-10-10): per voice unit its assigner's
     * count synced to the HOST's (the setter, jx_ktrack_set_count) and its clock [asg+0xB0] advanced by
     * the call's samples; only units below the count render -- the others' outputs are zero and their
     * wrappers do not run (six voices by default: initialize's record 0x0FFFC00E). */
    if (!G.host_stage_off)
        for (int u = 0; u < NV; ++u) {
            jx_ktrack_cbs c = { unit_set48, unit_get50, unit_get70, (void *)(intptr_t)u };
            int64_t clk;
            if (jx_ktrack_count(G.kt[u]) != nv)
                jx_ktrack_set_count(G.kt[u], &c, nv);
            clk = kt_clock(u) + n;
            memcpy(G.kt[u] + 0xB0, &clk, 8);
        }
    for (int s = 0; s < n; ++s) {
        /* the per-unit WRAPPER (0x377080 voice / 0x377010 master):
         * flag==0 -> untouched; latch>0 -> outputs zeroed, GC only;
         * else -> outputs zeroed, inner render, GC. */
        for (int v = 0; v < NV; ++v) {
            uint8_t *st = G.vstate[v];
            int32_t latch;
            if (!G.host_stage_off && v >= nv) {        /* not rendered: outputs zero */
                G.vcells[2 * v] = G.vcells[2 * v + 1] = 0.0f;
                continue;
            }
            if (!st[0x14]) continue;
            latch = gi(st + 0xAAC308);
            G.vcells[2 * v] = G.vcells[2 * v + 1] = 0.0f;
            if (latch > 0) si32(st + 0xAAC308, latch - 1);
            else jx_voice_render(st, v, pairs[v]);
            jxg_ramp_sweep(st);
        }
        {   uint8_t *st = G.mstate;
            outL = outR = 0;
            if (st[0x14]) {
                int32_t latch = gi(st + 0xAAC308);
                if (latch > 0) si32(st + 0xAAC308, latch - 1);
                else jx_master_render(st, a2, a3);
                jxg_ramp_sweep(st);
            }
        }
        if (!G.host_stage_off) {
            /* THE OUTPUT GAIN STAGE (rva 0x3F9731..0x3F9844, READ), on the HOST's own cells: while samples
             * are left the gain moves by the step, held in [0, 1]; then a positive step holds 1.0, else the
             * gain is 0 and the delay counts down; when it ends the fade-in starts: trunc(rate x time x
             * 0.001) samples (at least 1), step 1 / that (in double). writePatch arms it (1 sample at -1,
             * the delay 0.5 s, the time 10 ms). */
            uint8_t *h = G.host;
            float g;
            int32_t left = gi(h + H_GLEFT);
            si32(h + H_GLEFT, (int32_t)((uint32_t)left - 1u));  /* it counts on below 0, as the asm's dec does */
            if (left > 0) {
                g = gf(h + H_GSTEP) + gf(h + H_GAIN);
                sf32(h + H_GAIN, g);
                if (g >= 1.0f) { sf32(h + H_GAIN, 1.0f); g = 1.0f; }
                else if (!(g > 0.0f)) { sf32(h + H_GAIN, 0.0f); g = 0.0f; }
            } else if (!(0.0f >= gf(h + H_GSTEP))) {    /* comiss 0, step; jae: an unordered step holds 1.0 */
                sf32(h + H_GAIN, 1.0f); g = 1.0f;
            } else {
                int32_t d;
                sf32(h + H_GAIN, 0.0f); g = 0.0f;
                d = gi(h + H_GDELAY);
                if (d > 0) {
                    si32(h + H_GDELAY, d - 1);
                    if (d - 1 <= 0) {
                        float t = jxg_rate() * gf(h + H_GTIME);
                        int32_t k;
                        t = t * 0.001f;
                        k = (int32_t)t;
                        if (k < 1) k = 1;
                        si32(h + H_GLEFT, k);
                        sf32(h + H_GSTEP, (float)(1.0 / (double)k));
                        g = gf(h + H_GAIN);
                    }
                }
            }
            {   float l, r;
                memcpy(&l, &outL, 4); memcpy(&r, &outR, 4);
                l = g * l; r = gf(h + H_GAIN) * r;
                memcpy(&outL, &l, 4); memcpy(&outR, &r, 4);
            }
        }
        memcpy(&L[s], &outL, 4);
        memcpy(&R[s], &outR, 4);
    }
    G.clock += n;
}

/* WEB-PREVIEW DRY RENDER: the 8 voices, summed, the master's effect network bypassed (jx_listen_c.py) */
void jx3p_render_dry(float *L, float *R, int n)
{
    void *pairs[NV][2];                /* read by index: a native pointer array (jx3p_render) */
    for (int v = 0; v < NV; ++v) {
        pairs[v][0] = &G.vcells[2 * v];
        pairs[v][1] = &G.vcells[2 * v + 1];
    }
    for (int s = 0; s < n; ++s) {
        float accL = 0.0f, accR = 0.0f;
        for (int v = 0; v < NV; ++v) {
            uint8_t *st = G.vstate[v];
            int32_t latch;
            if (!st[0x14]) continue;
            latch = gi(st + 0xAAC308);
            G.vcells[2 * v] = G.vcells[2 * v + 1] = 0.0f;
            if (latch > 0) si32(st + 0xAAC308, latch - 1);
            else jx_voice_render(st, v, pairs[v]);
            jxg_ramp_sweep(st);
            accL += G.vcells[2 * v];
            accR += G.vcells[2 * v + 1];
        }
        L[s] = accL; R[s] = accR;
    }
    G.clock += n;
}

/* raw access for the gates (jx_master_bisect.py, jx_recall_data_gate.py, jx_tick_gate.py, jx_lift_gate.py) */
void *jx3p_vstate(int v) { return G.vstate[v]; }
void *jx3p_mstate(void)  { return G.mstate; }
void *jx3p_vhigh(int v)  { return G.vhigh[v]; }
/* the whole guest heap: its guest base, length and host address */
unsigned long long jx3p_heap_base(void) { return G.hb; }
unsigned long long jx3p_heap_len(void)  { return G.hlen; }
void *jx3p_heap(void) { return G.hlen ? JXG_H(G.hb) : NULL; }
/* the control objects: which 0 note manager, 1 note store, 2 assigner, 3 parameter object */
void *jx3p_ctl(int which, int i)
{
    switch (which) {
    case 0: return G.mgr.u[i];
    case 1: return G.ns[i];
    case 2: return G.kt[i];
    default: return G.proc[i];
    }
}
/* the engine HOST's record (voices, gain, step, samples left, delay, fade time, engine rate); returns 1 */
int jx3p_host(uint8_t out[28])
{
    float r = jxg_rate();
    memcpy(out + 0, G.host + H_NVOICES, 4);
    memcpy(out + 4, G.host + H_GAIN, 20);
    memcpy(out + 24, &r, 4);
    return G.host != NULL;
}

/* unit u's wrapper + ramp record in the exporter's form (jx_master_recall_export.py wrap_record): latch, flag,
 * the active ids, then per slot its target as an offset in the unit (0xFFFFFFFF: none) and the slot's bytes
 * +8..+0x27 -- read from the plugin's own records. Returns the length, or -1 when cap is too small. */
int jx3p_wrap_dump(int u, uint8_t *out, int cap)
{
    uint8_t *st = u < NV ? G.vstate[u] : G.mstate, *p = out;
    uint64_t b = gq(st + 0x70), e = gq(st + 0x78), arr = gq(st + 0x58);
    int32_t nids = (int32_t)((e - b) / 4), nslot = 0, i;
    for (i = 0; i < nids; ++i) { int32_t id = gi(JXG_H(b + 4 * (uint64_t)i)); if (id + 1 > nslot) nslot = id + 1; }
    if (16 + 4 * nids + 36 * nslot > cap) return -1;
    memcpy(p, st + 0xAAC308, 4); p[4] = st[0x14]; p[5] = p[6] = p[7] = 0; p += 8;
    memcpy(p, &nids, 4); p += 4;
    if (nids) memcpy(p, JXG_H(b), 4u * (uint32_t)nids);
    p += 4 * nids;
    memcpy(p, &nslot, 4); p += 4;
    for (i = 0; i < nslot; ++i) {
        uint8_t *sl = JXG_H(arr + 40 * (uint64_t)i);
        uint64_t t = gq(sl);
        uint32_t off = t ? (uint32_t)(t - G.stg[u]) : 0xFFFFFFFFu;
        memcpy(p, &off, 4); memcpy(p + 4, sl + 8, 32); p += 36;
    }
    return (int)(p - out);
}

/* gate hook: 0 renders the DSP alone (every unit, no count sync, no gain stage) -- the full-chain
 * gate's DSP mode grades the voices and the master against the plugin's per-unit renders that way;
 * 1 (the default after jx3p_init) is the plugin's engine render. */
void jx3p_host_stage(int on) { G.host_stage_off = !on; }
/* THE ENGINE'S CLOCK TICK (vtable +0xB8, rva 0x3F84A0; the render driver calls it 24 times per beat): per
 * unit its note manager's counter, its tick and its note store's tick (jx3p/src/jx_seq.c) */
void jx3p_tick(void)
{
    for (int u = 0; u < NUNITS; ++u) {
        jx_nstore_cbs n = { ns_drain, (void *)(intptr_t)u };
        jx_seq_cbs c = seq_cbs(u);
        jx_seq_tick_unit(G.mgr.u[u], G.ns[u], &n, &c);
    }
}
/* the first step-choice function the port met but does not hold (an image rva), 0 when none */
unsigned long long jx3p_bad_hook(void) { return (unsigned long long)g_bad_hook; }
/* the step machine's reach since the start: [0] step choices, [1] notes it played, [2] notes it released */
void jx3p_seq_stats(unsigned long out[3]) { out[0] = g_seq_hook_calls; out[1] = g_seq_on; out[2] = g_seq_off; }
/* how often each of the 19 modes' step functions ran since the start */
void jx3p_seq_modes(unsigned long out[19]) { for (int k = 0; k < 19; ++k) out[k] = g_seq_mode_calls[k]; }
/* GATE STIMULUS (jx3p/tools/jx_tick_gate.py --setmode): every unit's note store set to step mode `mode`
 * by the port's transcription of the plugin's mode setter 0x3F1910 -- the modes no patch reaches
 * (jx3p/docs/HOST_LAYER.md 3e); the gate calls the plugin's own setter on its side */
void jx3p_seq_set_mode(int mode) { for (int u = 0; u < NUNITS; ++u) jxs_3F1910(G.ns[u], (uint32_t)mode); }
/* the assigner clock of unit u (the plugin's [assigner+0xB0]): gates and diagnostics */
long long jx3p_ktclock(int u) { return (u >= 0 && u < NUNITS && G.kt[u]) ? (long long)kt_clock(u) : -1; }

/* THE PLUGIN'S RENDER OBJECT (JX-4, 2026-10-10): between its render driver and the engine sits the
 * JUNO-60's render object -- table and coefficient vectors byte for byte (jx3p/tools/jx_conv_tables.py,
 * EXECUTED; jx3p/docs/HOST_LAYER.md 2b) -- so the port takes src/juno_conv.c as it is. The engine runs
 * at the image's own rate (the HOST's: the automatic setting's 96000 for hosts 44100, 48000 and 96000,
 * with the image exported at that rate), the object is looked up for (engine, host): IDENTITY renders the
 * engine for the host block, CONVERTER renders what its filter needs and filters (rva 0x343E30), SILENCE
 * gives zeros. */
#include "../../src/juno_conv.c"
/* the render driver's state (jx3p_product_block below) */
#define JX_DRV_QMAX 256
typedef struct { int off, on, note, vel, kind; } jx_drv_rec;   /* kind 0 a key, 1 a host parameter record (note
                                                                * the id, vel the float value's bits), 2 an
                                                                * engine parameter record */
static jx_drv_rec g_drv_carry[JX_DRV_QMAX]; static int g_drv_ncarry;
static jx_drv_rec g_drv_pend[JX_DRV_QMAX]; static int g_drv_npend;     /* jx3p_product_param's points */
static long long g_drv_ph; static int g_drv_notes, g_drv_rate;

static juno_ro g_ro; static int g_ro_on;
static void jx_ro_engine(void *user, float *const *ptrs, int nch, int count)
{
    (void)user; (void)nch;
    jx3p_render(ptrs[0], ptrs[1], count);
}
/* the object for (the engine's rate, host_rate); returns its kind (0 identity, 1 converter, 2 silence),
 * -1 without an engine or when a buffer cannot be allocated */
int jx3p_product_open(int host_rate)
{
    if (!G.host) return -1;
    if (g_ro_on) juno_ro_free(&g_ro);
    juno_ro_init(&g_ro, (int)jxg_rate(), host_rate);
    g_ro_on = 1;
    g_drv_rate = host_rate; g_drv_ph = 0; g_drv_notes = 0; g_drv_ncarry = 0;   /* the driver at instance start */
    g_drv_npend = 0;
    G.host_stage_off = 0;
    if (juno_ro_lookup(&g_ro) < 0) return -1;
    return juno_ro_kind(&g_ro);
}
/* THE RENDER DRIVER (JX-7, 2026-10-10): the JUNO-60's machine code in the JX (jx3p/tools/fw_map.py), as
 * the JUNO port has it (gui/juno_bridge.c drv_block): the clock -- 24 ticks per beat, the host's tempo or
 * 120, P = (60e9 x host rate / round(tempo x 10)) / 24 in 1e-8 host samples, its phase kept across blocks --
 * and the block's records at their offsets (a note-on at or before the block's last note-off moves one
 * sample after it, offsets never go down, from the first record at or past the block's end every record
 * waits for the next block at offset 0); the block is split at every tick and record, each piece rendered
 * through the render object; the first key down restarts the clock with a tick. */
static void prod_render(float *L, float *R, int t0, int n);
int jx3p_product_process(float *L, float *R, int n);
/* THE HOST PARAMETER RECORDS (kind 1): the JUNO-60's wrapper code in the JX (jx3p/tools/fw_map.py), the
 * tables the JX's own (jx3p/src/jx_midi_tables.h, generated from the booted plugin by
 * jx3p/tools/jx_gen_midi_tables.py). process() (rva 0x34A240) makes one record per host parameter queue
 * below the MIDI-mapping base -- its last point, the value as a float -- after the block's notes; the render
 * driver (rva 0x3210B6) looks the id up in the id map (rva 0x319990: none, nothing) and calls the engine's
 * host entry (vt+0x70) with the record's own id and the parameter's value law (rva 0x31A820). */
#include "../src/jx_midi_tables.h"
#ifndef JX_LAW_TOOTH
#define JX_LAW_TOOTH 0
#endif
static int jx_midi_entry(uint32_t id)
{
    int lo = 0, hi = JX_MIDI_IDMAP_N - 1;
    while (lo <= hi) {
        int mid = (lo + hi) / 2;
        if (JX_MIDI_IDMAP[mid].id == id) return JX_MIDI_IDMAP[mid].entry;
        if (JX_MIDI_IDMAP[mid].id < id) lo = mid + 1;
        else hi = mid - 1;
    }
    return -1;
}
/* rva 0x31A820: (float)(max - min, 32 bits zero-extended) x v + (float)min in single precision, to double,
 * rounded half away from zero (rva 0x428460: below 0 ceil(x - 0.5), else -- NaN too -- floor(x + 0.5)),
 * below -2147483647 (NaN too) 0x80000001, above 2147483647 0x7FFFFFFF, else truncated */
static int32_t jx_midi_record_value(int e, float v)
{
    const jx_midi_param *p = &JX_MIDI_PARAM[e];
    float x = (float)(int64_t)((uint32_t)p->max - (uint32_t)p->min) * v;
    double r;
    x = x + (float)p->min;
    r = (double)x;
#if !JX_LAW_TOOTH   /* TOOTH (jx_product_gate.py --tooth-law): truncated, not rounded */
    r = (0.0 > r) ? ceil(r - 0.5) : floor(r + 0.5);
#else
    r = (0.0 > r) ? ceil(r) : floor(r);
#endif
    if (!(r >= -2147483647.0)) return (int32_t)0x80000001u;
    if (r > 2147483647.0) return 0x7FFFFFFF;
    return (int32_t)r;
}
static void drv_apply(const jx_drv_rec *r)
{
    if (r->kind == 2) { jx3p_param(r->note, r->vel); return; }   /* the engine's host entry (JX-11) */
    if (r->kind == 1) {
        int e = jx_midi_entry((uint32_t)r->note);
        float f;
        memcpy(&f, &r->vel, 4);
        if (e >= 0) jx3p_param(r->note, jx_midi_record_value(e, f));
        return;
    }
    if (r->on) { jx3p_note_on(r->note, r->vel); g_drv_notes++; }
    else       { jx3p_note_off(r->note); g_drv_notes--; }
}
/* One host parameter queue's last point for the next block, as process() (rva 0x34A240) takes it: an id below
 * the MIDI-mapping base (as signed 32-bit values) becomes a parameter record (kind 1) with the value as a
 * float; the next jx3p_product_block puts these after its own events (the plugin's process(): the notes,
 * then one record per queue in queue order). Returns 0; -1 for a MIDI-mapping id (base + 0..129: CC,
 * aftertouch, bend -- not ported yet) or a full queue. */
int jx3p_product_param(unsigned int id, int offset, double value)
{
    float f = (float)value;
    jx_drv_rec *r;
    if (!((int32_t)JX_MIDI_BASE > (int32_t)id) || g_drv_npend >= JX_DRV_QMAX) return -1;
    r = &g_drv_pend[g_drv_npend++];
    r->off = offset; r->on = 0; r->kind = 1; r->note = (int)id;
    memcpy(&r->vel, &f, 4);
    return 0;
}
/* one host block: ev[4 i ..] = { offset, type, a, b }: type 0 a note-on (a key, b velocity 0..127), 1 a
 * note-off (a key), 2 an engine parameter record (a the model id, b the 32-bit value) -- what the plugin's
 * patch browser and editor queue, in queue order: a patch load's records come before the block's keys; then
 * the host parameter points jx3p_product_param queued */
int jx3p_product_block(float *L, float *R, int n, const int *ev, int nev)
{
    jx_drv_rec rec[2 * JX_DRV_QMAX];
    int nrec = 0, i, k, t, cut, s0;
    long long P = (60000000000LL * (long long)g_drv_rate / 1200) / 24, ph;
    if (n <= 0) return 0;
    for (i = 0; i < g_drv_ncarry; ++i) rec[nrec++] = g_drv_carry[i];
    for (i = 0; i < nev && nrec < 2 * JX_DRV_QMAX; ++i) {
        rec[nrec].off = ev[4 * i]; rec[nrec].on = ev[4 * i + 1] == 0;
        rec[nrec].kind = ev[4 * i + 1] == 2 ? 2 : 0;
        rec[nrec].note = ev[4 * i + 2]; rec[nrec].vel = ev[4 * i + 3]; ++nrec;
    }
    for (i = 0; i < g_drv_npend && nrec < 2 * JX_DRV_QMAX; ++i) rec[nrec++] = g_drv_pend[i];
    g_drv_npend = 0;
    g_drv_ncarry = 0;
    {
        int last = -1, lastoff = -1;
        cut = nrec;
        for (i = 0; i < nrec; ++i) {
            int off = rec[i].off;
            if (rec[i].kind) {                      /* a parameter record: only "offsets never go down" */
            } else if (rec[i].on) {
                if (off <= lastoff) { off = lastoff + 1; rec[i].off = off; }
            } else {
                lastoff = off;
            }
            if (off <= last) { rec[i].off = last; off = last; }
            last = off;
            if (n <= off) { cut = i; break; }
        }
        for (i = cut; i < nrec && g_drv_ncarry < JX_DRV_QMAX; ++i) {
            g_drv_carry[g_drv_ncarry] = rec[i];
            g_drv_carry[g_drv_ncarry++].off = 0;
        }
    }
    ph = g_drv_ph;
    k = 0;
    s0 = 0;
    for (t = 0; t < n; ++t) {
        int seg = (t == 0);
        if (ph <= 100000000LL * t) {
            if (!seg) { prod_render(L, R, s0, t - s0); s0 = t; seg = 1; }
            while (ph <= 100000000LL * t) { jx3p_tick(); ph += P; }
        }
        if (k < cut && rec[k].off == t) {
            int before = g_drv_notes;
            if (!seg) { prod_render(L, R, s0, t - s0); s0 = t; seg = 1; }
            while (k < cut && rec[k].off == t) { drv_apply(&rec[k]); ++k; }
#if !JX_DRV_TOOTH   /* TOOTH (jx_product_gate.py --tooth-clock): the first key does not restart the clock */
            if (!before && g_drv_notes > 0) { ph = 100000000LL * t + P; jx3p_tick(); }
#else
            (void)before;
#endif
        }
        if (ph < 100000000LL * (t + 1)) {
            if (!seg) { prod_render(L, R, s0, t - s0); s0 = t; seg = 1; }
            while (ph < 100000000LL * (t + 1)) { jx3p_tick(); ph += P; }
        }
    }
    prod_render(L, R, s0, n - s0);
    g_drv_ph = ph - 100000000LL * n;
    return 0;
}
static void prod_render(float *L, float *R, int t0, int n)
{
    if (n > 0) jx3p_product_process(L + t0, R + t0, n);
}

/* one host block of n samples through the render object */
int jx3p_product_process(float *L, float *R, int n)
{
    int kind = g_ro_on ? juno_ro_kind(&g_ro) : -1;
    if (n <= 0) return 0;
    if (kind == JUNO_RO_IDENTITY) { jx3p_render(L, R, n); return 0; }
    if (kind == JUNO_RO_CONVERTER) {
        float *out[2] = { L, R };
        if (juno_ro_convert(&g_ro, out, 2, n, jx_ro_engine, NULL) == 0) return 0;
    }
    memset(L, 0, (size_t)n * sizeof(float));          /* SILENCE, or a buffer that could not grow */
    memset(R, 0, (size_t)n * sizeof(float));
    return kind == JUNO_RO_SILENCE ? 0 : -1;
}

float jx3p_vcell(int i) { return G.vcells[i]; }

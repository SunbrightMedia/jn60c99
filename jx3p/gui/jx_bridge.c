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
 * access translated into the blocks below). THE NOTE PATH IS THE PLUGIN'S OWN TOO (JX-12b, 2026-10-10): the
 * engine's note entries (vtable +0x80 / +0x78), its clock tick (+0xB8), its CC and bend entries, the note store's
 * mode setter and the assigner's count setter, lifted with all they reach -- the note managers, the note stores
 * and their step machine (the arpeggiator), the assigners (assign modes, legato, portamento) and their posts into
 * the voices (jx_lift_gate.py --loads notes / tick / ctl, jx_tick_gate.py). jx3p/src's transcriptions of that
 * path (jx_alloc.c, jx_nstore.c, jx_ktrack.c, jx_dispatch_note.c, jx_seq.c) keep their own gates but the port
 * no longer runs them: they had met neither legato nor portamento under the sustain and all notes off, where the
 * product gate found them wrong (JX-12). The transcribed parts run on the same bytes:
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

/* ---- the guest heap's translation for transcribed code: host = guest + delta (set at init; the variable is
 * defined once, in jx3p/src/jx_voice_helpers.c, linked into every build) ---- */
extern unsigned long long jx_g2h_delta;
#define JXG_H(g)       ((uint8_t *)(uintptr_t)((unsigned long long)(g) + jx_g2h_delta))
#define JX_NS_SZ  0xFF0            /* the note store's allocation (4080 bytes, EXECUTED 2026-10-10) */
#define JX_MGR_SZ 0x7A8            /* the note manager, through its history list at +0x5A8 (jx_alloc.c) */

/* ---- the plugin's parameter system, lifted, and its runtime ---- */
#define JP8_RELOC 1
#ifndef JP8_RELOC_CHECK
#define JP8_RELOC_CHECK 2          /* an access outside every block is diverted and reported after the call */
#endif
#if !(defined(__x86_64__) || defined(_M_X64)) && !defined(JP8_SOFTFP)
#define JP8_SOFTFP 1               /* no x86 MXCSR: FTZ/DAZ in software, the oracle's semantics */
#endif
#include "../../jp8/src/jp8_rt.c"
#ifdef JX_LIFT_FILE                /* a TOOTH build: a lifted source with one defect put in (jx_tick_gate.py --tooth) */
#include JX_LIFT_FILE
#else
#include "../src/jx_lift.c"
#endif
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
    uint8_t *mgr[NUNITS];          /* the note managers */
    uint8_t *ns[NUNITS];           /* the note stores */
    uint8_t *kt[NUNITS];           /* the assigners (the HOST's assigner pointer and the manager's +0x520) */
    uint8_t *host;                 /* the engine HOST */
    uint64_t stg[NUNITS];          /* the unit states' guest addresses */
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

#ifdef JX_LIFT_VOICE
/* THE VOICE WRAPPER, LIFTED (2026-10-12, the lift experiment): the plugin's own per-unit wrapper 0x377080 -- the
 * unit's flag, its start-up latch, the outputs zeroed, voice v's own copy of the render (eight copies, one per
 * voice: 0x3A22C0, 0x3A99B0 .. 0x3D6110, through the jump table at 0x3771B4), then the ramp sweep 0x3F40E0 --
 * run on the unit's guest state, one C statement per instruction (jx_lift.py, the wrapper among its roots). Its
 * two output cells and their pointer pair sit at the stack block's lowest bytes (the call's stack grows down from
 * G.rsp and never reaches them); the cells carry the last value in, as the wrapper leaves a unit whose flag is 0
 * untouched. Off by default: the transcription stays the product until the lift is graded. */
static void jxg_voice(int v)
{
    uint64_t cells = G.slo + 0x100 + 8 * (uint64_t)v, pair = G.slo + 0x200 + 16 * (uint64_t)v;
    uint8_t *pc = jxg_any(cells, 8), *pp = jxg_any(pair, 16);
    uint32_t mx = G.mx;
    if (!pc || !pp) { G.lift_err = 1; return; }
    memcpy(pc, &G.vcells[2 * v], 8);
    sq64(pp, cells);
    sq64(pp + 8, cells + 4);
    /* the plugin's MXCSR, but FTZ as the caller runs: the gates' oracle mode has it off (Unicorn never flushes a
     * result, playbook 120), the product has it on (jx_enable_hw_ftz) */
#ifndef JP8_SOFTFP
    G.mx = (G.mx & ~0x8000u) | (_mm_getcsr() & 0x8000u);
#endif
    jxg_call(0x377080, G.stg[v], (uint64_t)v, pair, 0, NULL);
    G.mx = mx;
    memcpy(&G.vcells[2 * v], pc, 8);
}
#endif

/* one call whose float argument is in xmm1 (setSampleRate: engine vt+0x18), the rest as jxg_call */
static int jxg_call_f1(uint64_t rva, uint64_t rcx, float f)
{
    memset(&G.cpu.x[1], 0, sizeof G.cpu.x[1]);
    G.cpu.x[1].f[0] = f;
    return jxg_call(rva, rcx, 0, 0, 0, NULL);
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

#ifdef JX_MEMFS
/* A program that carries its files inside itself (jx3p/gui/win/jx3p_win.c: the guest image and the factory bank are
 * resources of JX-3P.exe) answers this: the bytes of `path`, or NULL for a path it does not hold (then the disk). */
const unsigned char *jx_memfs(const char *path, size_t *len);
#endif
static uint8_t *read_file(const char *path, size_t *len)
{
    FILE *f;
    uint8_t *b;
    long L;
#ifdef JX_MEMFS
    {
        size_t n = 0;
        const unsigned char *m = jx_memfs(path, &n);
        if (m) {
            if (!n || !(b = malloc(n))) return NULL;
            memcpy(b, m, n);
            *len = n;
            return b;
        }
    }
#endif
    f = fopen(path, "rb");
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
    if (len < 96 || memcmp(b, "JXG1", 4) || gi(b + 4) != 2) return 0;   /* 2: before initialize's records */
    memcpy(&crc, b + len - 4, 4);
    if (crc32_le(b, len - 4) != crc) return 0;
    memcpy(&G.hb, b + o, 8); memcpy(&G.hlen, b + o + 8, 8); memcpy(&G.hostg, b + o + 16, 8);
    memcpy(&G.ib, b + o + 24, 8); memcpy(&G.slo, b + o + 32, 8); memcpy(&G.slen, b + o + 40, 8);
    memcpy(&G.rsp, b + o + 48, 8); o += 56;
    memcpy(&G.mx, b + o, 4); memcpy(&G.rate0, b + o + 4, 4); o += 8;
    if (jp8_map(G.hb, G.hlen) || jp8_map(G.slo, G.slen)) return 0;
    /* PAGE 0, zero (JX-15): the CRT's stack probe (__chkstk, rva 0x6AC420, under setSampleRate's big frames) reads
     * the thread block's stack limit gs:[0x10]; the oracle's GS base is 0 and its page 0 is zero, so the limit is
     * 0 and nothing is probed. The lift reads gs:[d] at d: the port maps the same zeros (the census refuses any
     * write to page 0: jx_lift_gate.py --pages) */
    if (jp8_map(0, 0x1000)) return 0;
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
        uint8_t *un = jxg_heap(gq(h + 0x78 + 0x40 * u), JX_MGR_SZ);
        if (!un || !jxg_heap(st, SNAP_M) || !jxg_heap(pr, 0x700) || !jxg_heap(asg, 0xB8)) return 0;
        if (gq(un + 0x520) != asg || !jxg_heap(gq(un + 0x518), JX_NS_SZ)) return 0;
        G.stg[u] = st;
        G.proc[u] = JXG_H(pr);
        G.mgr[u] = un;
        G.ns[u] = JXG_H(gq(un + 0x518));
        G.kt[u] = JXG_H(asg);
        if (u < NV) { G.vstate[u] = JXG_H(st); G.vhigh[u] = JXG_H(st + 0xA60000); }
        else G.mstate = JXG_H(st);
    }
    return 1;
}

/* a FRESH instance: what a previous one held is freed; the guest image (JXG1 version 2, jx_guest_export.py: the
 * engine as setActive leaves it -- BUILD, setSampleRate at the image's rate --, no record applied), the model's
 * state at its boot, the bank file */
static void jx_state_boot(void);
static int jx_boot_apply(void);
static int jx_open(const char *image_path, const char *bank_path)
{
    size_t bl;
    uint8_t *bk;
    jx_release();
    if (!guest_load(image_path) || !guest_link()) { jx_release(); return 0; }
    jx_state_boot();
    if (!(bk = read_file(bank_path, &bl))) { jx_release(); return 0; }
    G.bank = bk; G.bank_len = bl;
    return 1;
}
/* jx3p_init is a FRESH instance every time it is called (the gates call it once per patch), with initialize's
 * records applied at once through the lifted host entry: the engine of the oracle's boot(product=True)
 * (tools/verify/jx_emu.py product_boot), for the gates that drive the engine directly (jx3p_recall, jx3p_render).
 * The product path queues those records for its first block instead, as the plugin does (jx3p_product_init).
 * image_path: the guest image (jx3p/gen/jx_guest_44k.bin.gz or _96k, inflated: jx3p/tools/jx_guest.py); bank_path:
 * the bank file; the third argument is unused (it named the old recall data). Returns 0 on a failure -- a trap in
 * the records too (jx3p_lift_error says which). */
int jx3p_init(const char *image_path, const char *bank_path, const char *unused)
{
    (void)unused;
    return jx_open(image_path, bank_path) && jx_boot_apply();
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

/* the assigner clock of unit u, [assigner+0xB0] (its time read, vtable +0x70 0x357EF0, is this / 96) */
static int64_t kt_clock(int u) { int64_t c; memcpy(&c, G.kt[u] + 0xB0, 8); return c; }

/* THE NOTE ENTRIES (JX-12b): the engine's vtable +0x80 (0x3F9150) and +0x78 (0x3F90F0), LIFTED -- the plugin's
 * own note managers, note stores, assigners and posts into the voices (rcx the HOST, dl the key, r8b the
 * velocity: jx_emu.py's note_on / note_off; a note-off's velocity 0x40, the oracle's) */
#define JX_NOTEON   0x3F9150
#define JX_NOTEOFF  0x3F90F0
#define JX_TICK     0x3F84A0       /* the engine's clock tick, vtable +0xB8 */
#define JX_SETMODE  0x3F1910       /* the note store's step-mode setter */
#define JX_SETCOUNT 0x357CE0       /* the assigner's count setter, vtable +0x80 */
/* TOOTH (jx_full_gate.sh, jx_wasm_check.py --tooth): every key one semitone up at the note entries -- the
 * end-to-end gates MUST see it (it lived in the transcribed note dispatch before JX-12b) */
#ifndef JX_FULL_TOOTH
#define JX_FULL_TOOTH 0
#endif
#define JX_KEY(k) ((uint64_t)(uint32_t)((k) + JX_FULL_TOOTH))
void jx3p_note_on(int note, int vel)
{ jxg_call(JX_NOTEON, G.hostg, JX_KEY(note), (uint64_t)(uint32_t)vel, 0, NULL); }
void jx3p_note_off(int note)
{ jxg_call(JX_NOTEOFF, G.hostg, JX_KEY(note), 0x40, 0, NULL); }

/* ---- THE UNITS' WRAPPER AND RAMP RECORDS, the plugin's own (unit state +0x14 the flag, +0xAAC308 the
 * start-mute count, +0x58 the 40-byte ramp slots, +0x70 / +0x78 the active ids' vector) ---- */
#ifndef JX_RAMP_TOOTH
#define JX_RAMP_TOOTH 0
#endif
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
#if JX_RAMP_TOOTH   /* TOOTH (ramp_walk_gate.sh --tooth): the cursor also advances past a retired id -- the walk
                     * skips the id compacted into its place */
            if (b != gq(st + 0x78)) b += 4;
#endif
        }
        if (b == gq(st + 0x78)) break;
    }
}
/* the sweep on one object for the seeded walk (jx3p/tools/ramp_walk_gate.sh, JX-26e): its +0x58 slot base and
 * +0x70 / +0x78 id vector, each slot's target, host addresses -- only before a guest image opens (the delta is 0
 * then, as the walk's records hold host pointers). Returns the live ids left, -1 with an image open. */
int jx3p_ramp_sweep_obj(uint8_t *obj)
{
    if (G.hlen || jx_g2h_delta) return -1;
    jxg_ramp_sweep(obj);
    return (int)((gq(obj + 0x78) - gq(obj + 0x70)) / 4);
}

/* ---- THE OUTPUT PEAKS (JX-22; the meters' engine side, READ from the JX's render 0x3F9220) ----
 * The gain stage's loop takes, after each sample's gain, the larger magnitude per channel: x = |sample| (andps
 * 0x7FFFFFFF), `comiss peak, x; jae` -- the peak becomes x unless peak >= x, so a NaN replaces it and is replaced
 * by the next sample (0x3F984D..0x3F9874); both start at 0 (xorps), so a call of no samples has peaks 0. Then,
 * under the lock at HOST+0x10, the held peaks at HOST+0x20 / +0x24 become maxss(held, peak) -- held if held >
 * peak, else peak (peak when either is NaN) -- for BOTH channels (0x3F989B..0x3F98B7; the JUNO-60's left channel
 * has the operands the other way round: docs/LED_METER.md rule 5). A meter's read (the engine's vt+72, rva
 * 0x34AE30 = the JUNO's 0x34AF70) takes a held peak and zeroes it. Graded: jx3p/tools/jx_meter_gate.py. */
#ifndef JX_LM_TOOTH      /* TEETH (jx_meter_gate.py --tooth): 1 the merge's operands swapped (the JUNO's left),
                          * 2 the peak taken before the gain, 3 the peak test ordered (a NaN never replaces it),
                          * 4 the meter's floor 0.0001, 5 the fade's alpha from k, not k + 1 */
#define JX_LM_TOOTH 0
#endif
static float g_pk[2];
static void jx_peak_begin(void) { g_pk[0] = g_pk[1] = 0.0f; }
static void jx_peak_one(int ch, uint32_t bits)
{
    float x;
    bits &= 0x7FFFFFFFu;
    memcpy(&x, &bits, 4);
#if JX_LM_TOOTH == 3
    if (g_pk[ch] < x) g_pk[ch] = x;
#else
    if (!(g_pk[ch] >= x)) g_pk[ch] = x;
#endif
}
static void jx_peak_end(void)
{
    for (int ch = 0; ch < 2; ++ch) {
        float h = gf(G.host + 0x20 + 4 * ch), p = g_pk[ch];
#if JX_LM_TOOTH == 1
        h = p > h ? p : h;
#else
        h = h > p ? h : p;
#endif
        sf32(G.host + 0x20 + 4 * ch, h);
    }
}
/* THE OUTPUT GAIN STAGE (rva 0x3F9731..0x3F9844, READ), on the HOST's own cells: while samples are left the gain
 * moves by the step, held in [0, 1]; then a positive step holds 1.0, else the gain is 0 and the delay counts down;
 * when it ends the fade-in starts: trunc(rate x time x 0.001) samples (at least 1), step 1 / that (in double).
 * writePatch arms it (1 sample at -1, the delay 0.5 s, the time 10 ms). One sample, in place; then its peaks. */
static void jx_gain_sample(uint32_t *outL, uint32_t *outR)
{
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
                k = (t > -2147483649.0f && t < 2147483648.0f) ? (int32_t)t : INT32_MIN;   /* cvttss2si */
                if (k < 1) k = 1;
                si32(h + H_GLEFT, k);
                sf32(h + H_GSTEP, (float)(1.0 / (double)k));
                g = gf(h + H_GAIN);
            }
        }
    }
    {   float l, r;
        uint32_t l0 = *outL, r0 = *outR;
        memcpy(&l, outL, 4); memcpy(&r, outR, 4);
        l = g * l; r = gf(h + H_GAIN) * r;
        memcpy(outL, &l, 4); memcpy(outR, &r, 4);
#if JX_LM_TOOTH == 2
        jx_peak_one(0, l0); jx_peak_one(1, r0);
#else
        (void)l0; (void)r0;
        jx_peak_one(0, *outL); jx_peak_one(1, *outR);
#endif
    }
}
/* the gate's entry (jx_meter_gate.py part 1): one engine call's gain stage, peaks and merge on these samples, in
 * place, on the HOST's cells -- the plugin's loop 0x3F96DA..0x3F98B7 */
void jx3p_gain_tail(float *L, float *R, int n)
{
    jx_peak_begin();
    for (int s = 0; s < n; ++s) {
        uint32_t l, r;
        memcpy(&l, &L[s], 4); memcpy(&r, &R[s], 4);
        jx_gain_sample(&l, &r);
        memcpy(&L[s], &l, 4); memcpy(&R[s], &r, 4);
    }
    jx_peak_end();
}
/* the HOST's gain cells and held peaks (the gate's inspection and set): gain, step, left, delay, time, held L, R */
void jx3p_gain_cells(uint32_t *io, int set)
{
    static const int off[7] = { H_GAIN, H_GSTEP, H_GLEFT, H_GDELAY, H_GTIME, 0x20, 0x24 };
    for (int k = 0; k < 7; ++k) {
        if (set) memcpy(G.host + off[k], &io[k], 4);
        else memcpy(&io[k], G.host + off[k], 4);
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
     * count (vtable +0x88, 0x357E50: [asg+8]) synced to the HOST's through its setter (vtable +0x80, 0x357CE0,
     * LIFTED: JX-12b) and its clock [asg+0xB0] advanced by the call's samples (0x357EA0: add qword [rcx+0xB0],
     * edx sign-extended); only units below the count render -- the others' outputs are zero and their wrappers
     * do not run (six voices by default: initialize's record 0x0FFFC00E). */
    if (!G.host_stage_off)
        for (int u = 0; u < NV; ++u) {
            int64_t clk;
            if (gi(G.kt[u] + 8) != nv)
                jxg_call(JX_SETCOUNT, gq(G.host + 0x68 + 64 * u), (uint64_t)(uint32_t)nv, 0, 0, NULL);
            clk = kt_clock(u) + n;
            memcpy(G.kt[u] + 0xB0, &clk, 8);
        }
    jx_peak_begin();
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
#ifdef JX_LIFT_VOICE
            (void)st; (void)latch;
            jxg_voice(v);                                 /* the plugin's wrapper, lifted: all of the below */
#else
            if (!st[0x14]) continue;
            latch = gi(st + 0xAAC308);
            G.vcells[2 * v] = G.vcells[2 * v + 1] = 0.0f;
            if (latch > 0) si32(st + 0xAAC308, latch - 1);
            else jx_voice_render(st, v, pairs[v]);
            jxg_ramp_sweep(st);
#endif
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
        if (!G.host_stage_off)
            jx_gain_sample(&outL, &outR);    /* the output gain stage and its peaks (above) */
        memcpy(&L[s], &outL, 4);
        memcpy(&R[s], &outR, 4);
    }
    if (!G.host_stage_off)
        jx_peak_end();                       /* the merge, also after a call of no samples (peaks 0) */
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
    case 0: return G.mgr[i];
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
/* THE ENGINE'S CLOCK TICK (vtable +0xB8, rva 0x3F84A0, LIFTED: JX-12b; the render driver calls it 24 times per
 * beat): per unit its note manager's counter, its tick and its note store's step machine */
void jx3p_tick(void) { jxg_call(JX_TICK, G.hostg, 0, 0, 0, NULL); }
/* GATE STIMULUS (jx3p/tools/jx_tick_gate.py --setmode): every unit's note store set to step mode `mode` by the
 * plugin's own mode setter 0x3F1910, lifted -- the modes no patch reaches (jx3p/docs/HOST_LAYER.md 3e) */
void jx3p_seq_set_mode(int mode)
{ for (int u = 0; u < NUNITS; ++u) jxg_call(JX_SETMODE, gq(G.mgr[u] + 0x518), (uint64_t)(uint32_t)mode, 0, 0, NULL); }
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
#define JX_DRV_QMAX 4096           /* the plugin's queue is a vector: past this the port reports a trap */
typedef struct { int off, st, note, vel, kind; } jx_drv_rec;   /* kind 0 a MIDI message (st its status byte, note
                                                                * and vel its data bytes), 1 a host parameter
                                                                * record (note the id, vel the float value's bits),
                                                                * 2 an engine parameter record (note the id, vel
                                                                * the value) */
static jx_drv_rec g_drv_carry[JX_DRV_QMAX]; static int g_drv_ncarry;
static jx_drv_rec g_drv_pend[JX_DRV_QMAX]; static int g_drv_npend;     /* jx3p_product_param's points */
static long long g_drv_ph; static int g_drv_notes, g_drv_rate;
/* THE HOST TEMPO (JX-8): process()'s ProcessContext tempo for the next blocks and whether the host marks it
 * valid (kTempoValid); the tempo x 10 last given to the engine (core+580, -1 at the boot) */
static double g_drv_tempo = 120.0; static int g_drv_tempo_valid, g_drv_tempo_last = -1;

static juno_ro g_ro; static int g_ro_on;
/* THE ENGINE-RATE SETTING (JX-15): the rate the next block switches the engine to (core+0x24C) -- the setting
 * listener (rva 0x3221D0 = the JUNO's 0x3222F0) sets it from vm.vs.sampleRate & 0x7F: JX_SRATE[v] (0..4: 96000,
 * 88200, 48000, 44100, 32000; 6..127 the image's bytes past the table, rates no render object holds: silence),
 * 5 the automatic setting -- the engine's current rate, rounded (rva 0x34B120) */
#include "../src/jx_srate.h"
static int g_eng_req;
#define JX_SETSR 0x3F9970          /* the engine's setSampleRate, vt+0x18 (the rate a float in xmm1), LIFTED */
static int jx_engine_rate_now(void)
{
    double r = (double)jxg_rate();
    r = r >= 0.0 ? floor(r + 0.5) : ceil(r - 0.5);
    return !(r >= -2147483647.0) ? (int)0x80000001u : (r > 2147483647.0 ? 0x7FFFFFFF : (int)r);
}
static void jx_setting_listener(int32_t v)
{
    v &= 0x7F;
    g_eng_req = v == 5 ? jx_engine_rate_now() : JX_SRATE[v];
}
static void jx_ro_engine(void *user, float *const *ptrs, int nch, int count)
{
    (void)user; (void)nch;
    jx3p_render(ptrs[0], ptrs[1], count);
}
static int g_setup_rate;            /* setupProcessing's stored rate (jx3p_setup_processing) */
/* the object for (the engine's rate, host_rate); returns its kind (0 identity, 1 converter, 2 silence),
 * -1 without an engine or when a buffer cannot be allocated */
int jx3p_product_open(int host_rate)
{
    if (!G.host) return -1;
    if (g_ro_on) juno_ro_free(&g_ro);
    juno_ro_init(&g_ro, (int)jxg_rate(), host_rate);
    g_ro_on = 1;
    g_setup_rate = host_rate;
    g_drv_rate = host_rate; g_drv_ph = 0; g_drv_notes = 0; g_drv_ncarry = 0;   /* the driver at instance start */
    g_eng_req = (int)jxg_rate();              /* the setting's default (0: 96000) is the image's engine rate */
    g_drv_tempo = 120.0; g_drv_tempo_valid = 0; g_drv_tempo_last = -1;
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
/* the engine's entries the driver calls for a MIDI message (rva 0x32113C, the status' table at 0x32193C /
 * 0x32191C, READ): 0x90 note on (vt+0x80, 0x3F9150), 0x80 note off (vt+0x78, 0x3F90F0, with the message's
 * velocity), 0xB0 the CC entry (vt+0x88, 0x34AD50: 1 mod, 11 expression, 64 sustain, 123 all notes off; 10 and
 * every other CC nothing), 0xE0 bend (vt+0x98, 0x3F91B0) with data1 + ((data2 - 64) << 7) as 16 bits -- all four
 * LIFTED (jx_lift_roots.py CONTROL_SLOTS; JX-12, JX-12b) --;
 * 0xA0 (vt+0xA0), 0xC0 (vt+0x90), 0xD0 (vt+0xA8): `ret 0` (READ) */
#define JX_CC_ENTRY    0x34AD50
#define JX_BEND_ENTRY  0x3F91B0
#define JX_TEMPO_ENTRY 0x3F9DD0     /* vt+0xB0: T in 400..3000 -> every unit's dispatch 375 (READ); LIFTED (JX-8) */
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
    switch (r->st & 0xF0) {
    case 0x90: jxg_call(JX_NOTEON, G.hostg, JX_KEY(r->note & 0xFF), (uint64_t)(r->vel & 0xFF), 0, NULL); g_drv_notes++; break;
    case 0x80: jxg_call(JX_NOTEOFF, G.hostg, JX_KEY(r->note & 0xFF), (uint64_t)(r->vel & 0xFF), 0, NULL); g_drv_notes--; break;
    case 0xB0: jxg_call(JX_CC_ENTRY, G.hostg, (uint64_t)(r->note & 0xFF), (uint64_t)(r->vel & 0xFF), 0, NULL); break;
    case 0xE0: {
        uint16_t d = (uint16_t)((r->note & 0xFF) + (uint16_t)(int16_t)(((r->vel & 0xFF) - 0x40) * 0x80));
        jxg_call(JX_BEND_ENTRY, G.hostg, (uint64_t)d, 0, 0, NULL);
        break;
    }
    default: break;
    }
}
/* ---- process() AND THE PUSH (JX-12): the JUNO-60's wrapper code in the JX (process() rva 0x34A240, the push
 * 0x31F3C0 = JUNO 0x31F4E0, the CC value law 0x31A730 = 0x31A850, the CC map lookup 0x319940 = 0x319A60: equal by
 * fw_map --pair), the JX's tables (jx_midi_tables.h) ---- */
/* the model's velSense (0x0FFFC00D): initialize's records set 1 and no path of the port changes it (no model, no
 * state load is ported; the id map lacks the id, so no automation reaches it) */
#define JX_VELSW 1
/* the wrapper's rules for one message, in place (rva 0x31F3C0; the JUNO port's juno_gui_wrapper_midi, graded
 * byte for byte there): a note-on at velocity 0 becomes a note-off at 64; with the velocity switch off a
 * note-on's velocity -- the converted note-off's too -- becomes 100 and a note-off's 64 */
static void jx_wrapper_midi(unsigned char m[3])
{
    if ((m[0] & 0xF0) == 0x90) {
        if (!m[2]) { m[0] = (unsigned char)((m[0] & 0x0F) | 0x80); m[2] = 64; }
        if (!JX_VELSW) m[2] = 100;
    } else if ((m[0] & 0xF0) == 0x80) {
        if (!JX_VELSW) m[2] = 64;
    }
}
/* the value a mapped CC gives its parameter record (rva 0x31A730): the CC byte over the entry's range, rounded
 * ((trunc(2x / 127) + 1) / 2) or, entry byte +16, truncated; both converted from 32 bits zero-extended */
static float jx_midi_cc_value(int e, int cc)
{
    const jx_midi_param *p = &JX_MIDI_PARAM[e];
    uint32_t range = (uint32_t)p->max - (uint32_t)p->min;
    int32_t x = (int32_t)(range * (uint32_t)cc), q;
    if (p->trunc) {
        q = x / 127;
    } else {
        int32_t t = (int32_t)((uint32_t)x * 2u) / 127;
        q = (t + 1) / 2;
    }
    if (p->min == p->max) return 0.0f;
    return (float)(int64_t)(uint32_t)q / (float)(int64_t)range;
}
static void drv_pend(int kind, int off, int st, int a, int b)
{
    jx_drv_rec *r;
    if (g_drv_npend >= JX_DRV_QMAX) {          /* never a silent drop: the port is no longer the plugin */
        if (!G.lift_err) { G.lift_err = 1; snprintf(G.lift_msg, sizeof G.lift_msg, "the driver's queue is full (%d)", JX_DRV_QMAX); }
        return;
    }
    r = &g_drv_pend[g_drv_npend++];
    r->off = off; r->kind = kind; r->st = st; r->note = a; r->vel = b;
}
/* ---- THE DAW STATE (JX-17): the model's parameter store and the core's CC map, as getState writes them and
 * setState reads them -- the JUNO-60's wrapper code (jx3p/tools/fw_map.py: getState 0x349EA0, setState 0x34AAA0,
 * its deserializer, the CC map 0x31A4F0 / 0x31A6A0 / 0x319A60 / 0x319B90 -- the JUNO port's gui/juno_bridge.c and
 * src/juno_midi.c, CLAIMS A31 / A32) on the JX's tables: jx3p/src/jx_state_tables.h (EXECUTED through the
 * plugin's own getState / setState, jx_state_census.py) and jx_midi_tables.h ---- */
#include "../src/jx_state_tables.h"
#include "../src/jx_patch_tables.h"   /* the patch tree's leaves (JX-16; the record image, JX-24) */
#include "../src/jx_record_tables.h"
#ifndef JX_KS_TOOTH      /* MUTANT (jx_state_gate.py --mutants): 1 KEY HOLD at 0 releases nothing */
#define JX_KS_TOOTH 0
#endif
#ifndef JX_STATE_TOOTH   /* MUTANTS (jx_state_gate.py --mutants): 1 no float link, 2 the limit from the state list, */
#define JX_STATE_TOOTH 0 /* 3 the store unmasked -- each must make the gate RED */
#endif
static int32_t g_store[JX_STATE_N];                 /* the model's value of each state parameter */
/* ---- THE MODEL'S RECORD IMAGE (JX-24): what the plugin's serializer (rva 0x335870 = the JUNO-60's 0x335990, fw_map
 * --pair) writes -- the bytes the patch window stores when it writes a patch. At boot the plugin's own image
 * (jx_record_tables.h, generated from the booted plugin); a patch load keeps the record's bytes as given (any
 * bytes, EXECUTED); the set of a state entry that is a leaf of the patch tree writes the leaf in the load's
 * encoding inverted -- INT1X7 the low byte, INT2X4 two nibbles, INT4X4 four, INT8X4 eight, the high one first; the
 * host settings write no byte (jx_record_census.py: 738 sets, 1,258 bytes). Graded: jx_record_gate.py. ---- */
#ifndef JX_PREC_TOOTH    /* TEETH (jx_record_gate.py --tooth): 1 a two-nibble leaf's nibbles swapped, 2 a load keeps
                          * the image (not the record's bytes) */
#define JX_PREC_TOOTH 0
#endif
static uint8_t g_prec[JX_REC_BODY];
static void jx_prec_put(int k)
{
    uint32_t id = JX_STATE_ENT[k].id, v = (uint32_t)g_store[k];
    int e, i, n;
    uint8_t *r;
    for (e = 0; e < JX_PATCH_EV_N; ++e)
        if (JX_PATCH_EV[e].id == id && JX_PATCH_EV[e].dec != JX_DEC_CONST) break;
    if (e == JX_PATCH_EV_N) return;
    r = g_prec + (JX_PATCH_EV[e].roff - 16);
    switch (JX_PATCH_EV[e].dec) {
    case JX_DEC_INT1X7: r[0] = (uint8_t)v; return;
#if JX_PREC_TOOTH == 1
    case JX_DEC_INT2X4: r[1] = (uint8_t)((v >> 4) & 15); r[0] = (uint8_t)(v & 15); return;
#else
    case JX_DEC_INT2X4: r[0] = (uint8_t)((v >> 4) & 15); r[1] = (uint8_t)(v & 15); return;
#endif
    case JX_DEC_INT8X4: n = 8; break;
    default:            n = 4; break;
    }
    for (i = 0; i < n; ++i) r[i] = (uint8_t)((v >> (4 * (n - 1 - i))) & 15);
}
/* the model's record image (the serializer's bytes): `cap` >= JX_REC_BODY; returns its size */
int jx3p_record(unsigned char *out, int cap)
{
    if (!out || cap < (int)JX_REC_BODY) return 0;
    memcpy(out, g_prec, JX_REC_BODY);
    return (int)JX_REC_BODY;
}
/* the CC map (core+24): the record CC n drives (an entry of JX_MIDI_PARAM, -1 none), each record's own CC, the
 * record a MIDI learn waits for (-1 none) */
static struct { int8_t map[128]; int8_t rec[JX_MIDI_PARAM_N]; int learn; } g_cc;
typedef char jx_cc_rec_fits[(JX_MIDI_PARAM_N <= 127) ? 1 : -1];
/* rva 0x31A4F0 (-1): the map emptied, every record's CC -1 (a waiting learn is kept) */
static void jx_cc_clear(void) { memset(g_cc.map, 0xFF, sizeof g_cc.map); memset(g_cc.rec, 0xFF, sizeof g_cc.rec); }
/* the instance as the plugin creates it: the store at initialize's defaults, the boot's CC assignment, no learn */
static void jx_ks_boot(void);
static int g_nedit;                                  /* the editor's host edits pending (JX-18) */
static void jx_state_boot(void)
{
    jx_ks_boot();
    g_nedit = 0;
    for (int k = 0; k < JX_STATE_N; ++k) g_store[k] = JX_STATE_ENT[k].dflt;
    memcpy(g_prec, JX_DEFAULT_REC, JX_REC_BODY);     /* the boot image: the defaults' leaves and the rest */
    jx_cc_clear();
    for (int cc = 0; cc < 128; ++cc)
        if (JX_CC_MAP[cc] >= 0) { g_cc.map[cc] = (int8_t)JX_CC_MAP[cc]; g_cc.rec[JX_CC_MAP[cc]] = (int8_t)cc; }
    g_cc.learn = -1;
}
/* ---- INITIALIZE (JX-15b): IComponent::initialize QUEUES, for the first block, the 82 state parameters' defaults in
 * list order, writePatch (0x0FFFC01D) = 1 and the all-sound-off message (CC 120) -- EXECUTED (jx_state_census.py;
 * jx3p/gen/jx_patch_records.json 'boot' holds the same 83 kind-2 records: jx_gen_state_tables.py checks it).
 * setActive has set the engine's rate (setSampleRate 96000, the guest image) and applies none of them. The first
 * process() switches the engine's rate when the rate setting asks for another, THEN applies the queue (EXECUTED
 * 2026-10-10: setSampleRate before every record) -- so a setState holding the rate setting before the first block
 * gives an engine whose defaults were set at the new rate ---- */
static int jx_boot_apply(void)            /* the records at once, on the engine (jx3p_init) */
{
    for (int k = 0; k < JX_STATE_N; ++k)
        if (jxg_call(HOSTPARAM, G.hostg, JX_STATE_ENT[k].id, (uint64_t)(uint32_t)JX_STATE_ENT[k].dflt, 0, NULL)) return 0;
    return !jxg_call(HOSTPARAM, G.hostg, JX_STATE_WRITEPATCH, 1, 0, NULL);
}
static void jx_boot_queue(void)           /* the records queued for the first block (jx3p_product_init) */
{
    for (int k = 0; k < JX_STATE_N; ++k) drv_pend(2, 0, 0, (int)JX_STATE_ENT[k].id, JX_STATE_ENT[k].dflt);
    drv_pend(2, 0, 0, (int)JX_STATE_WRITEPATCH, 1);
    drv_pend(0, 0, JX_STATE_BOOT_MIDI0, JX_STATE_BOOT_MIDI1, JX_STATE_BOOT_MIDI2);
}
/* A FRESH INSTANCE ON THE PRODUCT PATH (JX-15b) -- createInstance, initialize, setupProcessing(host_rate), setActive:
 * the guest image as setActive leaves the engine, the render object for (the engine's rate, host_rate), and
 * initialize's records queued for the first block; a patch load (jx3p_product_load_patch), a setState
 * (jx3p_state_load) and the first block's events queue after them, as the plugin's do. Returns the render object's
 * kind (jx3p_product_open: 0 identity, 1 converter, 2 silence), -1 on a failure. */
int jx3p_product_init(const char *image_path, const char *bank_path, int host_rate)
{
    int kind;
    if (!jx_open(image_path, bank_path) || (kind = jx3p_product_open(host_rate)) < 0) return -1;
    jx_boot_queue();
    return kind;
}
/* rva 0x319A60: the record CC `cc` drives, -1 when none or while a learn waits */
static int jx_cc_lookup(int cc)
{
    if (g_cc.learn >= 0 || cc < 0 || cc > 127) return -1;
    return g_cc.map[cc];
}
/* rva 0x31A6A0, one state entry: 0 when `id` is not 0x10000000 + 0..127; else 1, and a value >= 0 the id map
 * knows assigns CC n to that record (a negative or unknown value: CC n stays free) */
static int jx_cc_state_entry(uint32_t id, int32_t v)
{
    uint32_t cc = id - JX_STATE_CC_BASE;
    int e;
    if (cc > 0x7Fu) return 0;
    if (v < 0) return 1;
    e = jx_midi_entry((uint32_t)v);
    if (e < 0) return 1;
    g_cc.map[cc] = (int8_t)e;
    g_cc.rec[e] = (int8_t)cc;
    return 1;
}
static int jx_state_index(uint32_t id)
{
    for (int k = 0; k < JX_STATE_N; ++k) if (JX_STATE_ENT[k].id == id) return k;
    return -1;
}
/* the model's set of state entry k: the LFO RATE (0x00600004) and VCF CUTOFF (0x0060003A) bytes also set their
 * host-only float (0x00A00000 / 0x00A02802) to byte x (1 / 255) in single precision -- the JUNO-60's model law
 * (gui/juno_bridge.c store_put), the same ids in the JX (EXECUTED: jx_state_gate.py, a byte set alone) */
static void jx_store_put(int k, int32_t v)
{
    uint32_t id = JX_STATE_ENT[k].id;
    g_store[k] = v;
    jx_prec_put(k);
    if (id == 0x0FFFC015u) jx_setting_listener(v);       /* vm.vs.sampleRate: the core's listener, at once */
    if (JX_STATE_TOOTH != 1 && (id == 0x00600004u || id == 0x0060003Au)) {
        float h = (float)v * (1.0f / 255.0f);
        int kh = jx_state_index(id == 0x00600004u ? 0x00A00000u : 0x00A02802u);
        if (kh >= 0) { memcpy(&g_store[kh], &h, 4); jx_prec_put(kh); }
    }
}
/* ---- THE UI TIMER'S QUEUE AND THE KEYBOARD'S NOTE VALUE (JX-17b): the JUNO-60's code (CLAIMS A32 / A36,
 * gui/juno_bridge.c ui_push / ui_push_midi / ks_* / juno_gui_ui_tick; the JX's UI timer handler 0x320000, the
 * push's store record 0x3220D0, the learn 0x31A920 / 0x319B70 / 0x3191C0 == the JUNO's, fw_map --pair) ----
 * The push queues, besides the engine's records, a second queue the UI timer drains every 50 ms on the plugin's
 * UI thread: a mapped CC's parameter value (only its last one stays; KEY HOLD's in order) and every note. The
 * drain sets the store from it, the notes into the keyboard's note value (ms.ch[0].note: per key the last
 * velocity, minus a note-off's), the first CC below 120 to a waiting MIDI learn. KEY HOLD = 0 -- in a setState
 * entry, a patch load, the drain -- releases every key above 0: a note-off record per key into the engine's
 * queue (the note value's listener 0x321A10, the wrapper's rules). */
#define JX_KEY_HOLD 0x00600138u
#define KS_NONE (-2147483647 - 1)
static struct { uint32_t id; float f; } g_ui_q[JX_STATE_N];
static int g_ui_nq, g_ui_cc;
static int g_ks_note[128], g_ks_pend[128];
static struct { int32_t v; int w0; } g_ks_kh[64];
static unsigned char g_ks_wkey[1024]; static int g_ks_wval[1024];
static int g_ks_nkh, g_ks_nw;
static unsigned char g_ks_lkey[1024]; static int g_ks_lval[1024]; static int g_ks_ln;
static void jx_wrapper_midi(unsigned char m[3]);
static void jx_ks_boot(void)
{
    g_ui_nq = 0; g_ui_cc = -1; g_ks_nkh = g_ks_nw = g_ks_ln = 0;
    for (int k = 0; k < 128; ++k) { g_ks_note[k] = 0; g_ks_pend[k] = KS_NONE; }
}
static void jx_unported(const char *what)
{
    if (!G.lift_err) { G.lift_err = 1; snprintf(G.lift_msg, sizeof G.lift_msg, "past a bound of the port: %s", what); }
}
/* the push's store record (rva 0x3220D0): KEY HOLD's go in order with their value (the record law); any other
 * parameter's earlier record leaves the queue and this one goes last */
static void jx_ui_push(uint32_t id, float f)
{
    int i;
    if (id == JX_KEY_HOLD) {
        int e = jx_midi_entry(id);
        if (g_ks_nkh >= 64) { jx_unported("KEY HOLD records"); return; }
        g_ks_kh[g_ks_nkh].v = e >= 0 ? jx_midi_record_value(e, f) : 0;
        g_ks_kh[g_ks_nkh].w0 = g_ks_nw;
        ++g_ks_nkh;
        return;
    }
    for (i = 0; i < g_ui_nq && g_ui_q[i].id != id; ++i) ;
    if (i < g_ui_nq) { memmove(&g_ui_q[i], &g_ui_q[i + 1], (size_t)(g_ui_nq - i - 1) * sizeof g_ui_q[0]); --g_ui_nq; }
    if (g_ui_nq < JX_STATE_N) { g_ui_q[g_ui_nq].id = id; g_ui_q[g_ui_nq].f = f; ++g_ui_nq; }
}
/* the push's own MIDI record into the second queue: a note is a write the drain will make (on -> velocity, off ->
 * -velocity, whatever the channel) */
static void jx_ui_push_midi(const unsigned char m[3])
{
    int st = m[0] & 0xF0, key = m[1] & 0x7F, v = st == 0x90 ? (int)m[2] : -(int)m[2], i;
    if (st != 0x90 && st != 0x80) return;
    if (!g_ks_nkh) { g_ks_pend[key] = v; return; }
    for (i = g_ks_kh[g_ks_nkh - 1].w0; i < g_ks_nw && g_ks_wkey[i] != key; ++i) ;
    if (i == g_ks_nw) {
        if (g_ks_nw >= (int)sizeof g_ks_wkey) { jx_unported("note writes"); return; }
        g_ks_wkey[g_ks_nw++] = (unsigned char)key;
    }
    g_ks_wval[i] = v;
}
/* the note value's listener (rva 0x321A10): one MIDI record per change, kind 0 at offset 0 -- above 0 a note-on at
 * that velocity, else a note-off at minus the value (its low byte) -- through the wrapper's rules, for the engine */
static void jx_ks_queue(int key, int value)
{
    unsigned char m[3];
    m[0] = value > 0 ? 0x90 : 0x80;
    m[1] = (unsigned char)key;
    m[2] = value > 0 ? (unsigned char)value : (unsigned char)(-(signed char)value);
    jx_wrapper_midi(m);
    drv_pend(0, 0, m[0], m[1], m[2]);
}
static void jx_ks_append(int key, int value)
{
    if (g_ks_ln >= (int)sizeof g_ks_lkey) { jx_unported("the note value's change list"); return; }
    g_ks_lkey[g_ks_ln] = (unsigned char)key; g_ks_lval[g_ks_ln] = value; ++g_ks_ln;
}
static void jx_ks_listen(void) { for (int i = 0; i < g_ks_ln; ++i) jx_ks_queue(g_ks_lkey[i], g_ks_lval[i]); }
static void jx_ks_commit(void) { g_ks_ln = 0; }
/* KEY HOLD at 0 (the core's model handler): every key above 0 released (key order, each to 0, each an entry of the
 * change list), then the listener queues the whole change list */
static void jx_ks_release(void)
{
#if JX_KS_TOOTH != 1
    for (int k = 0; k < 128; ++k)
        if (g_ks_note[k] > 0) { g_ks_note[k] = 0; jx_ks_append(k, 0); }
    jx_ks_listen();
#endif
}
/* THE UI TIMER'S HANDLER (the core's slot 1, rva 0x320000; the plugin runs it every 50 ms on its UI thread, the
 * port when the app calls this): the notes into the note value, the store records into the store (KEY HOLD at 0
 * releases there), the first CC to a waiting MIDI learn; the model's commit at its end */
static int jx_cc_learn_done(int cc);
void jx3p_ui_tick(void)
{
    int i, j, kh = jx_state_index(JX_KEY_HOLD);
    for (i = 0; i < 128; ++i)
        if (g_ks_pend[i] != KS_NONE) { g_ks_note[i] = g_ks_pend[i]; g_ks_pend[i] = KS_NONE; }
    for (j = 0; j < g_ks_nkh; ++j) {
        int end = j + 1 < g_ks_nkh ? g_ks_kh[j + 1].w0 : g_ks_nw;
        if (kh >= 0) jx_store_put(kh, g_ks_kh[j].v);
        if (kh >= 0 && g_store[kh] == 0) jx_ks_release();
        for (i = g_ks_kh[j].w0; i < end; ++i) g_ks_note[g_ks_wkey[i]] = g_ks_wval[i];
    }
    g_ks_nkh = g_ks_nw = 0;
    for (i = 0; i < g_ui_nq; ++i) {
        int e = jx_midi_entry(g_ui_q[i].id), k = jx_state_index(g_ui_q[i].id);
        if (e >= 0 && k >= 0) {
            int32_t v = jx_midi_record_value(e, g_ui_q[i].f);
            if (JX_STATE_ENT[k].mask) v = (int32_t)((uint32_t)v & JX_STATE_ENT[k].mask);
            jx_store_put(k, v);
        }
    }
    jx_ks_commit();
    g_ui_nq = 0;
    if (g_ui_cc >= 0) jx_cc_learn_done(g_ui_cc);
    g_ui_cc = -1;
}
/* the keyboard's note value of `key` (what a panel keyboard draws: down above 0) */
int jx3p_keybed_state(int key) { return key >= 0 && key < 128 ? g_ks_note[key] : 0; }
/* THE PANEL KEYBOARD'S SEND (the JUNO-60's gui/juno_bridge.c juno_gui_keybed_write, CLAIMS A36: rva 0x2D47E0 there;
 * the JX's keyboardX control is the same framework class, jx3p/tools/fw_map.py): a write of the keyboard's note value
 * of `key` -- a change goes on the change list -- then the value's listener queues the change list (jx_ks_queue: the
 * wrapper's rules, a record for the next block) and the model's commit empties it. Returns the changes queued. */
int jx3p_keybed_write(int key, int value)
{
    int n;
    if (key < 0 || key > 127) return 0;
    if (g_ks_note[key] != value) { g_ks_note[key] = value; jx_ks_append(key, value); }
    n = g_ks_ln;
    jx_ks_listen();
    jx_ks_commit();
    return n;
}
/* the MIDI-mapping parameters' first id (process(): base + n CC n, + 128 aftertouch, + 129 bend) */
unsigned int jx3p_midi_base(void) { return JX_MIDI_BASE; }
/* MIDI LEARN (the GUI's menu): arm for the parameter `id` (rva 0x31A920) -- the next drain gives it the first CC
 * below 120 queued since the last drain; while it waits no CC drives a parameter -- or forget its CC (rva
 * 0x3191C0). 0 for an id the CC map has no record of. */
int jx3p_cc_learn(uint32_t id)
{
    int e = jx_midi_entry(id);
    if (e < 0) return 0;
    g_cc.learn = e;
    return 1;
}
int jx3p_cc_forget(uint32_t id)
{
    int e = jx_midi_entry(id), old;
    if (e < 0) return 0;
    old = g_cc.rec[e];
    if (old >= 0) g_cc.map[old] = -1;
    g_cc.rec[e] = -1;
    return 1;
}
/* ---- THE CC ASSIGN MENU'S MODEL (JX-23): the JUNO-60's code (docs/CC_MENU.md rules 3-6; the JX's handler
 * 0x31D300, search 0x31D150, entry 0x3199F0, CC-of 0x319A50, learn 0x31A920, forget 0x3191C0 == the JUNO's,
 * fw_map --pair). A right press on a control whose value has a CC map record opens "Learn MIDI CC" and "Forget
 * MIDI CC" -- with " #n" when the record's CC is n >= 0, greyed without it. The press's search on the panel tree
 * hit-tests rectangles that come from the art's frame sizes: it belongs to the drawn panel (SCOPE_AUDIT row 20).
 * Graded: jx_state_gate.py (every record's CC after every step, its record index). ---- */
#ifndef JX_CCOF_TOOTH    /* MUTANT (jx_state_gate.py --mutants): 1 the CC shown while a learn waits */
#define JX_CCOF_TOOTH 0
#endif
/* the CC map record of a parameter (rva 0x3199F0): -1 when it has none (no menu) */
int jx3p_cc_entry(uint32_t id) { return jx_midi_entry(id); }
/* the CC its menu shows (rva 0x319A50): -1 when none, or while a learn waits */
int jx3p_cc_of(uint32_t id)
{
    int e = jx_midi_entry(id);
#if JX_CCOF_TOOTH == 1
    if (e < 0) return -1;
#else
    if (g_cc.learn >= 0 || e < 0) return -1;
#endif
    return g_cc.rec[e];
}
/* ---- THE EDITOR'S SET (JX-18): a panel control's value through the model (rva 0x283C90 = the JUNO-60's
 * 0x283DB0, fw_map --pair), EXECUTED on every record at 14 values (jx_model_census.py; jx_state_tables.h
 * JX_STATE_EDIT_HOST): the model keeps the value at its storage law (getState), LFO RATE and VCF CUTOFF set their
 * floats too, KEY HOLD at 0 releases the keys the UI timer has seen; then either the HOST's automation round trip
 * -- beginEdit, performEdit(id, (float)(stored - min) / (float)(max - min), both unsigned 32-bit), endEdit, and no
 * engine record: the host sends the value back through process() (jx3p_product_param) -- or, for the 19 entries
 * a host never automates (the patch name, the two floats, the host settings) and writePatch, one engine record
 * (id, the stored value) for the next block. ---- */
#ifndef JX_EDIT_TOOTH    /* MUTANT (jx_state_gate.py --mutants): 1 performEdit's value is the stored value / max */
#define JX_EDIT_TOOTH 0
#endif
#define JX_EDIT_MAX 512
static struct { uint32_t id; double v; int kind; } g_edit[JX_EDIT_MAX];   /* g_nedit: with the state's boot */
/* one host edit of a stored value: performEdit's value (float)(stored - min) / (float)(max - min), both unsigned
 * 32-bit; kind 0 the editor's (beginEdit / performEdit / endEdit), 1 a load's (performEdit alone: no beginEdit while
 * loading -- the JUNO-60's census, docs/B6_WRAPPER_BOOT.md) */
static int jx_edit_push(uint32_t id, int32_t st, int kind)
{
    int e = jx_midi_entry(id);
    float f;
    if (e < 0 || g_nedit >= JX_EDIT_MAX) return 0;
#if JX_EDIT_TOOTH == 1
    f = (float)st / (float)JX_MIDI_PARAM[e].max;
#else
    f = (float)(int64_t)(uint32_t)(st - JX_MIDI_PARAM[e].min) /
        (float)(int64_t)(uint32_t)(JX_MIDI_PARAM[e].max - JX_MIDI_PARAM[e].min);
#endif
    g_edit[g_nedit].id = id; g_edit[g_nedit].v = (double)f; g_edit[g_nedit].kind = kind; ++g_nedit;
    return 1;
}
int jx3p_model_set(uint32_t id, int32_t v)
{
    int k = jx_state_index(id);
    int32_t st;
    if (id == JX_STATE_WRITEPATCH) {
        drv_pend(2, 0, 0, (int)id, (int32_t)((uint32_t)v & JX_STATE_WRITEPATCH_MASK));
        return 1;
    }
    if (k < 0) return 0;
    st = JX_STATE_ENT[k].mask ? (int32_t)((uint32_t)v & JX_STATE_ENT[k].mask) : v;
    jx_store_put(k, st);
    if (id == JX_KEY_HOLD && st == 0) jx_ks_release();
    if (!JX_STATE_EDIT_HOST[k]) {
        drv_pend(2, 0, 0, (int)id, st);
        return 1;
    }
    return jx_edit_push(id, st, 0);
}
/* the host edits the plugin made since the last call, in order -- performEdit's id and value, and (kinds, may be
 * NULL) 0 for the editor's set (beginEdit / performEdit / endEdit: the host sends the value back through process(),
 * jx3p_product_param) or 1 for a load's (setState, the patch browser: performEdit alone, for each host parameter
 * the load sets, in its order -- EXECUTED, jx_state_gate.py). Returns the count; the rest past cap is dropped. */
int jx3p_host_edits(uint32_t *ids, double *vals, int *kinds, int cap)
{
    int n = g_nedit < cap ? g_nedit : cap;
    for (int i = 0; i < n; ++i) {
        ids[i] = g_edit[i].id; vals[i] = g_edit[i].v;
        if (kinds) kinds[i] = g_edit[i].kind;
    }
    g_nedit = 0;
    return n;
}
/* a panel control's commit after its set (the model's notifies and commit, rva 0x285200 / 0x2852A0 / 0x283000):
 * the keyboard's change list empties */
void jx3p_model_commit(void) { jx_ks_commit(); }
/* the model's value of a state parameter as the store holds it (getState writes it); 0 for an id outside the state */
int32_t jx3p_model_get(uint32_t id)
{
    int k = jx_state_index(id);
    return k < 0 ? 0 : g_store[k];
}
/* a value object's own set (its vt+0x70), the one a window's zoom getter makes: the store at its storage law, and
 * nothing else -- no engine record, no host edit (EXECUTED: the JX editor attached on an 800 x 600 screen sets
 * vm.vs.mainZoom 62 -> 39, the engine's queue and the host's edits unchanged; jx_zoom_fit_gate.py) */
int jx3p_value_set(uint32_t id, int32_t v)
{
    int k = jx_state_index(id);
    if (k < 0) return 0;
    jx_store_put(k, JX_STATE_ENT[k].mask ? (int32_t)((uint32_t)v & JX_STATE_ENT[k].mask) : v);
    return 1;
}
/* ---- THE LEVEL METERS' GUI SIDE (JX-22): the JUNO-60's code (docs/LED_METER.md rules 9-12; the JX's meter tick
 * 0x31C330, bar fill 0x2C98F0, bar draw 0x31C0F0 and log10 0x708A70 == the JUNO's 0x31C450, 0x2C9A10, 0x31C210,
 * 0x6D2660, fw_map --pair). The JX panel's meters: Script.xml barGraphL / barGraphR, ch 0 / 1, decay 8, fade 10,
 * horizontal; no LFO LED (the JX's engine vt+104 is 0x34AE20, `ret 0`). ---- */
/* a meter's read (the engine's vt+72, rva 0x34AE30): channel ch's held peak, then 0 */
float jx3p_peak(int ch)
{
    float p;
    if (!G.host || ch < 0 || ch > 1) return 0.0f;
    p = gf(G.host + 0x20 + 4 * ch);
    sf32(G.host + 0x20 + 4 * ch, 0.0f);
    return p;
}
/* cvttss2si / cvttsd2si: NaN and out of range give 0x80000000 */
static int32_t jx_cvtt(double x)
{
    if (!(x > -2147483649.0 && x < 2147483648.0)) return INT32_MIN;
    return (int32_t)x;
}
/* a bar's fill (rva 0x2C98F0): rect and fill are x0 y0 x1 y1; horizontal fills from the left, vertical from the
 * bottom; val of max */
static void jx_bar_fill(const int *rect, int horiz, int max, int val, int *fill)
{
    int32_t v4 = val >= max ? max : val, span, prod;
    fill[0] = rect[0];
    fill[3] = rect[3];
    if (horiz) {
        fill[1] = rect[1];
        fill[2] = rect[0];
        if (max > 0) {
            span = (int32_t)((uint32_t)rect[2] - (uint32_t)rect[0]);
            prod = (int32_t)((uint32_t)span * (uint32_t)v4);
            fill[2] = (int32_t)((uint32_t)(prod / max) + (uint32_t)rect[0]);
        }
    } else {
        fill[2] = rect[2];
        fill[1] = rect[3];
        if (max > 0) {
            span = (int32_t)((uint32_t)rect[3] - (uint32_t)rect[1]);
            prod = (int32_t)((uint32_t)span * (uint32_t)v4);
            fill[1] = (int32_t)((uint32_t)rect[3] - (uint32_t)(prod / max));
        }
    }
}
/* a meter's tick (rva 0x31C330): channel ch's read, the new state from the old one and the decay, the bar's fill
 * of rect (state / 1000 of 999). The dB step: the C library's log10 here, the CRT's there -- every float peak
 * gives the same step (no float lies within 1e-9 of one: docs/LED_METER.md rule 10, the same function) */
int jx3p_meter_tick(int ch, int decay, int state, const int *rect, int horiz, int *fill)
{
    double d;
    int32_t v7, v8;
    float peak = jx3p_peak(ch);
#if JX_LM_TOOTH == 4
    if (!(peak >= 0.0001f)) d = 0.0001;
#else
    if (!(peak >= 0.001f)) d = 0.001;
#endif
    else if (peak > 1.0f) d = 1.0;
    else d = (double)peak;
    v7 = (int32_t)((uint32_t)jx_cvtt(log10(d) * 333.0 + 999.0) * 1000u);
    if (decay <= 0) {
        v8 = v7;
    } else {
        int32_t t = (int32_t)((uint32_t)state - (uint32_t)(500000 / decay));
        if (t >= v7) v7 = t;
        v8 = v7 >= 0 ? v7 : 0;
    }
    jx_bar_fill(rect, horiz, 999, v8 / 1000, fill);
    return v8;
}
/* a horizontal bar's draw (rva 0x31C0F0): its blits in order, 7 ints each -- dst x, dst y, width, height, src x,
 * src y, alpha (-1: the first, a plain blit; then one column at a time at 255 - 255 (k + 1) / fade); returns
 * their count, out holds cap. A vertical bar (none in the JX's Script.xml): 0 */
int jx3p_bar_draw(const int *rect, const int *fill, int horiz, int fade, int *out, int cap)
{
    int32_t w = (int32_t)((uint32_t)fill[2] - (uint32_t)fill[0]);
    int32_t h = (int32_t)((uint32_t)fill[3] - (uint32_t)fill[1]);
    int32_t n = (int32_t)((uint32_t)rect[2] - (uint32_t)w - (uint32_t)rect[0]);
    int32_t m = fade >= w ? w : fade, solid, k, nb = 0;
    if (!horiz) return 0;
    if (n >= m) n = m;
    solid = (int32_t)((uint32_t)w - (uint32_t)n);
    if (nb < cap) {
        int *o = out + 7 * nb;
        o[0] = fill[0]; o[1] = fill[1]; o[2] = solid; o[3] = h; o[4] = 0; o[5] = 0; o[6] = -1;
    }
    ++nb;
    for (k = 0; k < n; ++k, ++nb) {
        if (nb < cap) {
            int *o = out + 7 * nb;
            o[0] = (int32_t)((uint32_t)fill[0] + (uint32_t)solid + (uint32_t)k);
            o[1] = fill[1];
            o[2] = 1;
            o[3] = h;
            o[4] = (int32_t)((uint32_t)solid + (uint32_t)k);
            o[5] = 0;
#if JX_LM_TOOTH == 5
            o[6] = 255 - (int32_t)(255u * (uint32_t)k) / fade;
#else
            o[6] = 255 - (int32_t)(255u * ((uint32_t)k + 1u)) / fade;
#endif
        }
    }
    return nb;
}
/* ---- A WINDOW'S ZOOM (JX-25): the JUNO-60's rules (docs/WINDOW_ZOOM.md, CLAIMS A40); the JX's getter 0x2AA470
 * and fit 0x312580 are the JUNO's 0x2AA590 / 0x312750 (fw_map --pair: equal). The fit: the largest zoom, in
 * percent, at which the panel (w x h, its Script.xml size: main 1924 x 704, patch 1668 x 600) fits the virtual
 * screen cx x cy (GetSystemMetrics 78 / 79) less 40 x 120 pixels -- the smaller of (cy - 120) * 100 / h and
 * (cx - 40) * 100 / w, each an integer division; the window keeps the first positive one (+0x13C). The getter
 * (called by every coordinate conversion of the window): its zoom value, at most the fit, and the value set to
 * that (jx3p_value_set). Graded: jx3p/tools/jx_zoom_fit_gate.py. ---- */
#ifndef JX_ZF_TOOTH      /* TEETH (jx_zoom_fit_gate.py --port-tooth): 1 the margins swapped, 2 the larger fit,
                          * 3 the fits rounded, 4 no fit kept */
#define JX_ZF_TOOTH 0
#endif
int jx3p_zoom_fit(int cx, int cy, int w, int h)
{
    int a, b;
    if (w <= 0 || h <= 0) return 0;                              /* (a panel is never empty) */
#if JX_ZF_TOOTH == 1
    a = (cy - 40) * 100 / h; b = (cx - 120) * 100 / w;
#else
    a = (cy - 120) * 100 / h; b = (cx - 40) * 100 / w;
#endif
#if JX_ZF_TOOTH == 2
    return a >= b ? a : b;
#elif JX_ZF_TOOTH == 3
    a = (int)((double)(cy - 120) * 100 / h + 0.5); b = (int)((double)(cx - 40) * 100 / w + 0.5);
    return a < b ? a : b;
#else
    return a >= b ? b : a;
#endif
}
/* `cache`: the window's kept fit (start at 0). Returns the zoom; the caller sets the value (jx3p_value_set) when it
 * differs from `value` */
int jx3p_zoom_get(int value, int cx, int cy, int w, int h, int *cache)
{
    int f;
#if JX_ZF_TOOTH == 4
    f = jx3p_zoom_fit(cx, cy, w, h);
#else
    if (*cache > 0) f = *cache;
    else f = *cache = jx3p_zoom_fit(cx, cy, w, h);
#endif
    return f < value ? f : value;
}
/* rva 0x319B70, a CC message the drain reads: none waits or cc >= 120 -> 0; else the waiting record's old CC
 * leaves the map, the CC's old record loses its CC, CC `cc` drives the waiting record, none waits */
static int jx_cc_learn_done(int cc)
{
    int r = g_cc.learn, old;
    if (r < 0 || r >= JX_MIDI_PARAM_N || cc >= 120 || cc < 0) return 0;
    old = g_cc.rec[r];
    if (old >= 0) g_cc.map[old] = -1;
    if (g_cc.map[cc] >= 0) g_cc.rec[g_cc.map[cc]] = -1;
    g_cc.map[cc] = (int8_t)r;
    g_cc.rec[r] = (int8_t)cc;
    g_cc.learn = -1;
    return 1;
}
static void put_be32(unsigned char *p, uint32_t v)
{ p[0] = (unsigned char)(v >> 24); p[1] = (unsigned char)(v >> 16); p[2] = (unsigned char)(v >> 8); p[3] = (unsigned char)v; }
static uint32_t be_at(const unsigned char *p, uint32_t len, uint32_t off, uint32_t n)
{
    uint32_t v = 0, i;
    for (i = 0; i < n; ++i) v = (v << 8) | (off + i < len ? p[off + i] : 0u);    /* the low 32 bits are kept */
    return v;
}
static void drv_pend(int kind, int off, int st, int a, int b);
/* IComponent::getState: the count, then (id, value) big-endian -- the parameter list's store, then the CC map's
 * 128 entries (the id of the record CC n drives, -1 none). Returns the bytes written, -1 when `cap` is short. */
int jx3p_state_save(unsigned char *out, int cap)
{
    int k, n = 4 + 8 * (JX_STATE_N + 128);
    unsigned char *p = out + 4;
    if (!out || cap < n) return -1;
    put_be32(out, (uint32_t)(n - 4));
    for (k = 0; k < JX_STATE_N; ++k, p += 8) { put_be32(p, JX_STATE_ENT[k].id); put_be32(p + 4, (uint32_t)g_store[k]); }
    for (k = 0; k < 128; ++k, p += 8) {
        put_be32(p, JX_STATE_CC_BASE + (uint32_t)k);
        put_be32(p + 4, (uint32_t)(g_cc.map[k] < 0 ? -1 : (int32_t)JX_MIDI_PARAM[g_cc.map[k]].id));
    }
    return n;
}
/* IComponent::setState (the JUNO's rva 0x34AAA0 path): `data` the stream, `len` its length. The count's width is 8
 * bytes when the stream is longer than (83 + 128) x 64 / 5 = 2700 bytes, else 4 (rva 0x322210: 83 the CC map's
 * records, 0x319B00 -- the JUNO's 95 gave 2854); its low 32 bits as an int are the payload's byte count: <= 0 ->
 * kResultFalse, nothing set or queued (-1). Past the stream's end the payload reads zeros. Entries are (id, value)
 * with fields of 8 bytes when the count exceeds 2700, else 4 (the low 32 bits kept). The CC map is emptied and the entries 0x10000000 + n refill it; each parameter entry takes value & its
 * storage law into the store and is queued for the engine in PAYLOAD order, between writePatch = 126 and 127
 * (EXECUTED: jx_state_census.py). Returns the parameter entries applied, -1 for kResultFalse. */
int jx3p_state_load(const unsigned char *data, int len)
{
    const uint32_t lim = (uint32_t)((((JX_STATE_TOOTH == 2 ? JX_STATE_N : JX_MIDI_PARAM_N) + 128) << 6) / 5);
                                                                           /* rva 0x322210: the CC map's records */
    uint32_t hw, n, avail, off, w;
    int32_t cnt;
    int k, applied = 0;
    if (!data || len < 0) return -1;
    hw = lim < (uint32_t)len ? 8 : 4;
    cnt = (int32_t)be_at(data, (uint32_t)len, 0, hw);
    if (cnt <= 0) return -1;
    n = (uint32_t)cnt;
    avail = (uint32_t)len > hw ? (uint32_t)len - hw : 0;
    data += (uint32_t)len > hw ? hw : (uint32_t)len;
    w = lim < n ? 8 : 4;
    jx_cc_clear();
    drv_pend(2, 0, 0, (int)JX_STATE_WRITEPATCH, 126);
    for (off = 0; off + 2 * w <= n && off < avail; off += 2 * w) {    /* past the data: zeros, id 0 */
        uint32_t id = be_at(data, avail, off, w);
        int32_t v = (int32_t)be_at(data, avail, off + w, w);
        if (jx_cc_state_entry(id, v)) continue;
        if ((k = jx_state_index(id)) < 0) continue;
        if (JX_STATE_ENT[k].mask && JX_STATE_TOOTH != 3) v = (int32_t)((uint32_t)v & JX_STATE_ENT[k].mask);
        jx_store_put(k, v);
        if (id == JX_KEY_HOLD && v == 0) jx_ks_release();     /* each entry its own set: before its record */
        drv_pend(2, 0, 0, (int)id, v);
        if (JX_STATE_EDIT_HOST[k]) jx_edit_push(id, v, 1);  /* and the host told (performEdit alone) */
        ++applied;
    }
    drv_pend(2, 0, 0, (int)JX_STATE_WRITEPATCH, 127);
    jx_ks_commit();                                          /* setState commits the model */
    return applied;
}
/* GATE ACCESS: the records queued for the next block (setState, the patch browser's loads, process()'s pushes),
 * 5 ints each (kind, offset, status, id or data1, value or data2); returns the count */
int jx3p_product_pending(int *out, int cap)
{
    int i;
    for (i = 0; i < g_drv_npend && 5 * (i + 1) <= cap; ++i) {
        out[5 * i] = g_drv_pend[i].kind; out[5 * i + 1] = g_drv_pend[i].off; out[5 * i + 2] = g_drv_pend[i].st;
        out[5 * i + 3] = g_drv_pend[i].note; out[5 * i + 4] = g_drv_pend[i].vel;
    }
    return g_drv_npend;
}
/* ---- THE PATCH BROWSER'S LOAD (JX-16): a bank record's bytes to the records its load queues -- the plugin's own
 * load (rva 0x335730 = the JUNO-60's 0x335850, fw_map) as jx3p/src/jx_patch_tables.h states it (EXECUTED through
 * the plugin's load: jx_patch_census.py, the factory records and crafted ones; jx_patch_gate.py grades seeded
 * records of random bytes and the factory bank, record for record, the store and the audio after each) ---- */
#ifndef JX_PATCH_TOOTH   /* MUTANT (jx_patch_gate.py --tooth): 1 a two-nibble field's high nibble masked to 3 bits */
#define JX_PATCH_TOOTH 0
#endif
/* the model's set-from-bytes (the JUNO-60's law): the bytes OR-ed in 4 bits apart, nothing masked */
static int32_t jx_patch_value(const uint8_t *r, const jx_patch_ev *e)
{
    uint32_t v = 0;
    int i, n;
    switch (e->dec) {
    case JX_DEC_CONST:  return e->value;
    case JX_DEC_INT1X7: return r[e->roff];
#if JX_PATCH_TOOTH == 1
    case JX_DEC_INT2X4: return ((r[e->roff] & 7) << 4) | r[e->roff + 1];
#else
    case JX_DEC_INT2X4: return (r[e->roff] << 4) | r[e->roff + 1];
#endif
    case JX_DEC_INT8X4: n = 8; break;
    default:            n = 4; break;
    }
    for (i = 0; i < n; ++i) v |= (uint32_t)r[e->roff + i] << (4 * (n - 1 - i));
    return (int32_t)v;
}
/* THE PATCH BROWSER'S LOAD of one bank record (JX_PATCH_REC_BYTES bytes, its 16-byte name first) for the next
 * block: its records queued in the load's order (kind 2), the store takes each record's value for the ids the
 * state lists (as decoded), and a KEY HOLD of 0 releases the keys the UI timer has seen just before ARPEGGIO's
 * record (KEY HOLD's tree node begins with 0x00600108: EXECUTED, jx_keyhold_census.py; the JUNO's rule) -- no
 * commit: the next drain does. Returns the records queued, -1 for a record of another size. */
int jx3p_product_load_record(const unsigned char *rec, int len)
{
    int32_t hold = 1;
    int k;
    if (!rec || len != (int)JX_PATCH_REC_BYTES) return -1;
    for (k = 0; k < JX_PATCH_EV_N; ++k)
        if (JX_PATCH_EV[k].id == JX_KEY_HOLD) hold = jx_patch_value(rec, &JX_PATCH_EV[k]);
    for (k = 0; k < JX_PATCH_EV_N; ++k) {
        uint32_t id = JX_PATCH_EV[k].id;
        int32_t v = jx_patch_value(rec, &JX_PATCH_EV[k]);
        int sk;
        if (id == 0x00600108u && hold == 0) jx_ks_release();
        if ((sk = jx_state_index(id)) >= 0) jx_store_put(sk, v);
        drv_pend(2, 0, 0, (int)id, v);
        if (sk >= 0 && JX_STATE_EDIT_HOST[sk]) jx_edit_push(id, v, 1);
    }
#if JX_PREC_TOOTH != 2
    memcpy(g_prec, rec + 16, JX_REC_BODY);       /* the model keeps the record's bytes as given */
#endif
    return JX_PATCH_EV_N;
}
/* the number of records in the bank file jx3p_init / jx3p_product_init read (the factory bank, or a user's bank of
 * the same format: a 23-byte header, then records of JX_PATCH_REC_BYTES) */
int jx3p_bank_patches(void)
{
    return G.bank && G.bank_len >= JX_PATCH_BANK_HEADER ?
        (int)((G.bank_len - JX_PATCH_BANK_HEADER) / JX_PATCH_REC_BYTES) : 0;
}
/* the patch browser's load of record `idx` of that bank; returns the records queued, -1 for no such record */
int jx3p_product_load_patch(int idx)
{
    if (idx < 0 || idx >= jx3p_bank_patches()) return -1;
    return jx3p_product_load_record(G.bank + JX_PATCH_BANK_HEADER + (size_t)idx * JX_PATCH_REC_BYTES,
                                    (int)JX_PATCH_REC_BYTES);
}
/* a bank file of the same format in place of the one init read (the patch browser opening a user's bank): the
 * next jx3p_product_load_patch reads it. Returns its record count, -1 when it is not such a file. */
int jx3p_bank_open(const char *path)
{
    size_t bl;
    uint8_t *bk = read_file(path, &bl);
    if (!bk || bl < JX_PATCH_BANK_HEADER + JX_PATCH_REC_BYTES ||
        (bl - JX_PATCH_BANK_HEADER) % JX_PATCH_REC_BYTES) { free(bk); return -1; }
    free((void *)G.bank);
    G.bank = bk; G.bank_len = bl;
    return jx3p_bank_patches();
}

/* the push (rva 0x31F3C0): a CC the core's CC map assigns (none while a MIDI learn waits) first queues its
 * parameter's record (kind 1, the CC value law); then every message its own record, after the wrapper's rules
 * (the model's records the push also makes -- the UI timer's -- are not ported yet) */
static void jx_push(unsigned char m[3], int offset)
{
    if ((m[0] & 0xF0) == 0xB0) {
        int e = jx_cc_lookup(m[1]);
        if (e >= 0) {
            float f = jx_midi_cc_value(e, m[2]);
            int bits;
            memcpy(&bits, &f, 4);
            jx_ui_push(JX_MIDI_PARAM[e].id, f);              /* the UI timer's store record (JX-17b) */
            drv_pend(1, offset, 0, (int)JX_MIDI_PARAM[e].id, bits);
        }
        if (g_ui_cc < 0 && m[1] < 120) g_ui_cc = m[1];       /* the message's own record (core+512) */
    }
    jx_wrapper_midi(m);
    jx_ui_push_midi(m);
    drv_pend(0, offset, m[0], m[1], m[2]);
}
/* One host note event for the next block, as process() takes it (the event list, before the parameter queues):
 * type 0 note-on / 1 note-off, the channel, the pitch and the velocity 0..1 -> status | channel, pitch & 0x7F,
 * (int)(float)(velocity x 127.0) & 0x7F, through the push. Returns 0; -1 when the queue is full. */
int jx3p_product_note(int type, int offset, int channel, int pitch, float velocity)
{
    unsigned char m[3];
    if (g_drv_npend >= JX_DRV_QMAX) return -1;
    m[0] = (unsigned char)((channel & 0x0F) | (type == 0 ? 0x90 : 0x80));
    m[1] = (unsigned char)(pitch & 0x7F);
    m[2] = (unsigned char)((int)(float)((double)velocity * 127.0) & 0x7F);
    jx_push(m, offset);
    return 0;
}
/* One host parameter queue's last point for the next block, as process() (rva 0x34A240) takes it, after the
 * block's note events (jx3p_product_note), in queue order: an id below the MIDI-mapping base (as signed 32-bit
 * values) becomes a parameter record (kind 1) with the value as a float; base + n becomes a MIDI message
 * through the push -- n 0..127 the CC n with round(value x 127), 128 channel aftertouch the same, 129 the
 * pitch bend round(value x 16383) as two 7-bit bytes (rounded half away from zero, rva 0x428460; below 0 or
 * NaN 0, above 255 / 65535 that), any other n three zero bytes (the driver skips them). The next
 * jx3p_product_block puts these after its own events. Returns 0; -1 when the queue is full. */
int jx3p_product_param(unsigned int id, int offset, double value)
{
    int32_t sid = (int32_t)id, base = (int32_t)JX_MIDI_BASE;
    unsigned char m[3] = { 0, 0, 0 };
    if (g_drv_npend >= JX_DRV_QMAX - 1) return -1;           /* a mapped CC queues two records */
    if (base > sid) {
        float f = (float)value;
        int bits;
        memcpy(&bits, &f, 4);
        drv_pend(1, offset, 0, (int)id, bits);
        return 0;
    }
    {
        uint32_t d = (uint32_t)sid - (uint32_t)base;
        if (d <= 128u) {
            double x = value * 127.0;
            unsigned char b;
            x = (0.0 > x) ? ceil(x - 0.5) : floor(x + 0.5);
            b = !(x >= 0.0) ? 0 : (x > 255.0 ? 0xFF : (unsigned char)(int)x);
            if (d < 128u) { m[0] = 0xB0; m[1] = (unsigned char)d; m[2] = b; }
            else { m[0] = 0xD0; m[1] = b; }
        } else if (d == 129u) {
            double x = value * 16383.0;
            unsigned w;
            x = (0.0 > x) ? ceil(x - 0.5) : floor(x + 0.5);
            w = !(x >= 0.0) ? 0u : (x > 65535.0 ? 0xFFFFu : (unsigned)(int)x & 0xFFFFu);
            m[0] = 0xE0; m[1] = (unsigned char)(w & 0x7F); m[2] = (unsigned char)((w >> 7) & 0x7F);
        }
    }
    jx_push(m, offset);
    return 0;
}
/* one host block: ev[4 i ..] = { offset, type, a, b }: type 0 a note-on (a key, b velocity 0..127), 1 a
 * note-off (a key), 2 an engine parameter record (a the model id, b the 32-bit value) -- what the plugin's
 * patch browser and editor queue, in queue order: a patch load's records come before the block's keys; then
 * the host parameter points jx3p_product_param queued */
/* The host's tempo for the next blocks, as process() reads its ProcessContext (JX-8): valid when the host sets
 * kTempoValid -- else the driver keeps 120 for its clock and tells the engine nothing */
void jx3p_product_tempo(int valid, double tempo)
{
    g_drv_tempo_valid = valid != 0;
    g_drv_tempo = valid ? tempo : 120.0;
}
static jx_drv_rec g_drv_work[2 * JX_DRV_QMAX];   /* one block's records (static: the WASM stack is 64 KB) */
/* A HOST-RATE CHANGE ON A RUNNING INSTANCE (JX-26c; the JUNO-60's CLAIMS A28, gui/juno_bridge.c
 * juno_gui_setup_processing / juno_gui_set_active -- the same wrapper code in the JX, jx3p/tools/fw_map.py): a host
 * calls setActive(false), setupProcessing(rate), setActive(true). setupProcessing stores the setup and nothing
 * else; setActive, either way, runs the core's setup at the stored rate -- the automatic engine-rate setting (5)
 * re-reads the engine's rate --, gives the render object the rate and looks it up again for (engine rate, host
 * rate): found, its buffers start from zeros and the tick phase and the note count go to 0; then the all-sound-off
 * record (CC 120 at offset 0, which the engine's CC entry ignores). The engine itself is kept. */
void jx3p_setup_processing(int host_rate) { g_setup_rate = host_rate; }
void jx3p_set_active(int on)
{
    int k = jx_state_index(0x0FFFC015u);
    (void)on;
    if (!g_ro_on) return;
    if (k >= 0 && (g_store[k] & 0x7F) == 5) g_eng_req = jx_engine_rate_now();
    g_drv_rate = g_setup_rate;
    g_ro.host = g_setup_rate;
    if (juno_ro_lookup(&g_ro) > 0) { g_drv_ph = 0; g_drv_notes = 0; }
    drv_pend(0, 0, 0xB0, 120, 0);
}
int jx3p_product_block(float *L, float *R, int n, const int *ev, int nev)
{
    jx_drv_rec *rec = g_drv_work;
    int nrec = 0, i, k, t, cut, s0;
    long long P, ph;
    int T;
    if (n <= 0) return 0;
    /* the engine rate (the JX's rva 0x320A82 = the JUNO's 0x320BA2): a requested rate (the setting listener's)
     * other than the render object's switches the engine -- vt+0x18 setSampleRate((float)rate), LIFTED (JX-15) --
     * and looks the object up for it; found, the tick phase and the note count start again. Before the tempo and
     * before the block's records, as the plugin's driver does. */
    if (g_ro_on && g_ro.engine != g_eng_req) {
        jxg_call_f1(JX_SETSR, G.hostg, (float)g_eng_req);
        g_ro.engine = g_eng_req;
        if (juno_ro_lookup(&g_ro) > 0) { g_drv_ph = 0; g_drv_notes = 0; }
    }
    /* the tempo (the JX's rva 0x320AE4 = the JUNO's 0x320C04, fw_map): round(tempo x 10.0), half away from
     * zero (rva 0x428460), clamped to an int; given to the engine (vt+0xB0, LIFTED) only when the host's tempo
     * is valid and T changed (core+580); the tick period (60e9 x host rate / T) / 24 in 1e-8 host samples --
     * T <= 0 never ticks (no host sends it) */
    {
        double r = g_drv_tempo * 10.0;
        r = r >= 0.0 ? floor(r + 0.5) : ceil(r - 0.5);
        T = !(r >= -2147483647.0) ? -2147483647 : (r > 2147483647.0 ? 0x7FFFFFFF : (int)r);
    }
    if (T != g_drv_tempo_last && g_drv_tempo_valid) {
        g_drv_tempo_last = T;
        jxg_call(JX_TEMPO_ENTRY, G.hostg, (uint64_t)(uint32_t)T, 0, 0, NULL);
    }
    P = T > 0 ? (60000000000LL * (long long)g_drv_rate / T) / 24 : (long long)1 << 62;
    if (P <= 0) P = (long long)1 << 62;
    for (i = 0; i < g_drv_ncarry; ++i) rec[nrec++] = g_drv_carry[i];
    for (i = 0; i < nev && nrec < 2 * JX_DRV_QMAX; ++i) {
        rec[nrec].off = ev[4 * i];
        rec[nrec].st = ev[4 * i + 1] == 0 ? 0x90 : 0x80;
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
            int off = rec[i].off, st = rec[i].kind ? 0 : rec[i].st & 0xF0;
            if (st == 0x90) {                       /* a parameter record, a CC, a bend: only "offsets never go down" */
                if (off <= lastoff) { off = lastoff + 1; rec[i].off = off; }
            } else if (st == 0x80) {
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

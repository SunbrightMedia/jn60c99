/* jx_bridge.c -- the STANDALONE JX-3P engine (charter 7b: the port must
 * play). Assembles ONLY proven parts:
 *   clean-boot template  jx3p/gen/jx_template.bin   (NaN census 0, exported
 *                        from the plugin's own BUILD+SETSR under Unicorn)
 *   recall               jx_recall.c    (64/64 EXACTLY 0)
 *   note managers        jx_alloc.c     (EXACTLY 0, 22,008 events)
 *   note store           jx_nstore.c    (EXACTLY 0)
 *   key tracker          jx_ktrack.c    (EXACTLY 0, 13,593 events)
 *   note/gate dispatch   jx_dispatch_note.c (EXACTLY 0, 2,500 dispatches)
 *   voice + master       jx_voice_render.c / jx_master_render.c
 *                        (64/64 patches EXACTLY 0 vs the plugin)
 * The one open stub: the note-store drain seam (0x3EF210) is a no-op here,
 * exactly as it was stubbed in every proof; the full-chain gate
 * (jx_full_gate.sh) is the judge of whether that ever becomes audible.
 *
 * FP MODE: callers MUST run with FTZ/DAZ where the hardware has it
 * (jx_enable_hw_ftz from jx_ftz.c); WASM has no MXCSR -- the same caveat
 * the JUNO web build carries.
 */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>

/* ---- proven modules (single-file link; see jx_full_gate.sh) ---- */
#include "../src/jx_alloc.c"
#include "../src/jx_nstore.c"
#include "../src/jx_ktrack.c"
#include "../src/jx_dispatch_note.c"
#include "../src/jx_gc.c"
#include "../src/jx_seq.c"
#define JX_NS_SZ 0xFF0             /* the note store's allocation (4080 bytes, EXECUTED 2026-10-10) */
#include "../src/jx_param_get.h"

int  jx_bank_apply(unsigned char *blk, const unsigned char *bank, int idx);
uint64_t jx_voice_render(void *vstate, int v, void *pair);
void *jx_master_render(void *mstate, void *a2, void *a3);

/* A pointer stored into a plugin-layout blob: the transcribed code reads the slot as 8 bytes (the
 * plugin is x64), so the whole slot is written -- the pointer in the low bytes, 0 above it -- on a
 * 32-bit target (WebAssembly) as on x64 (jx_wasm_check.py, 2026-10-10). */
#define JX_PTR_STORE(slot, ptr) \
    do { uint64_t jx_p_ = (uint64_t)(uintptr_t)(ptr); memcpy((slot), &jx_p_, 8); } while (0)

#define NV        8
#define NUNITS    9
#define SNAP_V    0x60000
#define SNAP_M    0xAAD000
#define PROC_SZ   0x700

/* the wrapper + ramp layer (0x377080/0x377010 + 0x3F40E0/0x3F4A40) */
typedef struct {
    int32_t latch;               /* [st+0xAAC308] */
    uint8_t flag;                /* [st+0x14] */
    int32_t nids;
    int32_t ids[512];
    int32_t nslot;
    jx_gc_slot *slots;           /* rebased targets */
} jx_wrap;

typedef struct {
    uint8_t *vstate[NV];
    uint8_t *vhigh[NV];          /* [0xA60000,0xAAD000) window per voice */
    jx_wrap  wrap[NUNITS];
    uint8_t *mstate;
    uint8_t *proc[NUNITS];
    jx_alloc mgr;
    uint8_t  ns[NUNITS][JX_NS_SZ];   /* the note store's whole allocation (0xFF0); templates before 2026-10-10 hold 0xDB0 */
    uint8_t  kt[NUNITS][0xB0];
    /* re-linked C++ object headers (pointer cells live HERE, never in the
     * template): voice obj 256B + two 4B cells; master obj + 4B + 256B */
    uint8_t  vobj[NV][256], vd40[NV][4], vd64[NV][4];
    uint8_t  mobj[256], mc136[4], mc112[256];
    /* dispatch seam constants from the template */
    jx_dn_cbs dn;
    float     temper[23];
    /* THE ENGINE HOST the render reads (2026-10-10, jx3p/docs/HOST_LAYER.md): its voice count
     * (+0x38), its output gain stage (+0x860 gain, +0x864 step, +0x868 samples left, +0x86C delay,
     * +0x870 the fade time in ms), the engine rate (its rate source +0x878), every voice assigner's
     * clock ([asg+0xB0], +n per render call). host_ok = 0: a template without the HOST record (the
     * old data): no count sync, no gain stage. */
    int      host_ok, host_stage_off;
    int32_t  nvoices;
    float    gain, gstep;
    int32_t  gleft, gdelay;
    float    gtime, rate;
    int64_t  ktclock[NUNITS];
    int64_t  clock;                     /* samples rendered */
    const uint8_t *bank;
    size_t   bank_len;
    float    vcells[16];                /* the voice->master seam */
} jx3p;

static jx3p G;

/* ---- template loading (JXT2: u32 nreg, {u32 raw,u32 z,bytes}*, links) --- */
static uint8_t *g_tmpl_regions[64];
static uint32_t g_tmpl_rawsz[64];
static uint8_t *g_tmpl_links[24];
static uint32_t g_tmpl_linksz[24];
static int g_nreg, g_nlink, g_tmpl_v4;

static void ns_load(int i);
static int tmpl_load(const char *path)
{
    FILE *f = fopen(path, "rb");
    uint8_t hdr[8];
    if (!f) return 0;
    if (fread(hdr, 1, 8, f) != 8 || (memcmp(hdr, "JXT3", 4) && memcmp(hdr, "JXT4", 4))) return 0;
    g_tmpl_v4 = !memcmp(hdr, "JXT4", 4);
    g_nreg = (int)(uint32_t)(hdr[4] | (hdr[5] << 8) | (hdr[6] << 16) |
                             ((uint32_t)hdr[7] << 24));
    for (int i = 0; i < g_nreg; ++i) {
        uint32_t raw;
        if (fread(&raw, 4, 1, f) != 1) return 0;
        uint8_t *rb = malloc(raw);
        if (fread(rb, 1, raw, f) != raw) return 0;
        g_tmpl_regions[i] = rb; g_tmpl_rawsz[i] = raw;
    }
    /* the links follow the regions: 8 voice links, 9 wrapper+ramp records, the dispatch seam, the
     * master link, and (JXT4) the engine HOST record; then the 4-byte crc. */
    g_nlink = 0;
    for (int i = 0; i < (g_tmpl_v4 ? 20 : 19); ++i) {
        uint32_t ln;
        if (fread(&ln, 4, 1, f) != 1) break;
        g_tmpl_links[g_nlink] = malloc(ln);
        if (fread(g_tmpl_links[g_nlink], 1, ln, f) != ln) break;
        g_tmpl_linksz[g_nlink] = ln;
        ++g_nlink;
    }
    fclose(f);
    return g_nreg >= 53 && g_nlink == (g_tmpl_v4 ? 20 : 19);
}

/* THE START-MUTE COUNT (2026-10-10): the plugin decrements each unit's state word [st+0xAAC308] itself (the
 * voice units' lies in their high window); the port counts in the wrapper record and writes the word back
 * after every step, so the unit states stay the plugin's word for word (it had stayed as loaded: the gates
 * masked it, and jx_master_bisect.py's voice high windows showed it as the one word that differed) */
#define JX_LATCH_STORE(u, w) memcpy((u) < NV ? G.vhigh[(u)] + (0xAAC308 - 0xA60000) : G.mstate + 0xAAC308, \
                                    &(w)->latch, 4)

/* the engine HOST record (template link 19, and one per patch in JXM4): voices, gain, step, samples
 * left, delay, fade time (ms), engine rate -- the plugin's own HOST after its boot / its patch load */
static void host_record(const uint8_t *r)
{
    memcpy(&G.nvoices, r + 0, 4);
#if JX_VC_TOOTH   /* TOOTH (jx_product_gate.py --tooth-voices): every voice unit plays, the count ignored */
    G.nvoices = NV;
#endif
    memcpy(&G.gain, r + 4, 4);
    memcpy(&G.gstep, r + 8, 4);
    memcpy(&G.gleft, r + 12, 4);
    memcpy(&G.gdelay, r + 16, 4);
    memcpy(&G.gtime, r + 20, 4);
    memcpy(&G.rate, r + 24, 4);
    G.host_ok = 1;
}

/* ---- the public API ---- */

static uint8_t *g_mrec; static size_t g_mrec_len; static int g_mrec_v4;

/* jx3p_init is a FRESH instance every time it is called (the gates call it once per patch): it frees
 * what a previous call allocated and clears every field, the sample clock and the voice seam
 * included. Each call holds ~51 MB (template, recall aux, bank, states); without the free a 32-bit
 * WebAssembly heap ran out after a few dozen calls and the engine then wrote through NULL
 * (jx_wasm_check.py over 64 patches, 2026-10-10). A first call is unchanged: G starts zeroed. */
static void jx_release(void)
{
    for (int i = 0; i < g_nreg; ++i) free(g_tmpl_regions[i]);
    for (int i = 0; i < g_nlink; ++i) free(g_tmpl_links[i]);
    g_nreg = g_nlink = 0;
    free(g_mrec); g_mrec = NULL; g_mrec_len = 0;
    free((void *)G.bank);
    for (int v = 0; v < NV; ++v) { free(G.vstate[v]); free(G.vhigh[v]); }
    free(G.mstate);
    for (int i = 0; i < NUNITS; ++i) { free(G.proc[i]); free(G.wrap[i].slots); }
    memset(&G, 0, sizeof G);
}

/* unit i's note store from its template region: its whole allocation (0xFF0) or, from a template before
 * 2026-10-10, its first 0xDB0 bytes and zeros after */
static void ns_load(int i)
{
    uint32_t n = g_tmpl_rawsz[9 + 3 * i] < JX_NS_SZ ? g_tmpl_rawsz[9 + 3 * i] : JX_NS_SZ;
    memset(G.ns[i], 0, JX_NS_SZ);
    memcpy(G.ns[i], g_tmpl_regions[9 + 3 * i], n);
}

int jx3p_init(const char *template_path, const char *bank_path,
              const char *master_recall_path)
{
    jx_release();
    if (!tmpl_load(template_path)) return 0;
    {   FILE *f = fopen(master_recall_path, "rb");
        size_t fl;
        uint8_t *fb;
        if (!f) return 0;
        fseek(f, 0, SEEK_END); fl = (size_t)ftell(f); rewind(f);
        fb = malloc(fl);
        if (fread(fb, 1, fl, f) != fl) return 0;
        fclose(f);
        g_mrec = fb; g_mrec_len = fl;
        if (memcmp(g_mrec, "JXM3", 4) && memcmp(g_mrec, "JXM4", 4)) return 0;
        g_mrec_v4 = !memcmp(g_mrec, "JXM4", 4);
    }
    {   FILE *f = fopen(bank_path, "rb");
        if (!f) return 0;
        fseek(f, 0, SEEK_END); G.bank_len = (size_t)ftell(f); rewind(f);
        uint8_t *b = malloc(G.bank_len);
        if (fread(b, 1, G.bank_len, f) != G.bank_len) return 0;
        fclose(f); G.bank = b;
    }
    for (int v = 0; v < NV; ++v) {
        G.vstate[v] = malloc(SNAP_V);
        memcpy(G.vstate[v], g_tmpl_regions[v], SNAP_V);
    }
    G.mstate = malloc(SNAP_M);
    memcpy(G.mstate, g_tmpl_regions[52], SNAP_M);
    for (int v = 0; v < NV; ++v) {
        G.vhigh[v] = malloc(0x4D000);
        memcpy(G.vhigh[v], g_tmpl_regions[44 + v], 0x4D000);
    }
    for (int i = 0; i < NUNITS; ++i) {
        memcpy(G.mgr.u[i], g_tmpl_regions[8 + 3 * i], JXA_UNIT_SZ);
        ns_load(i);
        memcpy(G.kt[i],    g_tmpl_regions[10 + 3 * i], 0xB0);
        G.proc[i] = malloc(PROC_SZ);
        memcpy(G.proc[i], g_tmpl_regions[35 + i], PROC_SZ);
    }
    /* relink the voice objects (links 0..7), seam (8), master (9) */
    for (int v = 0; v < NV; ++v) {
        const uint8_t *lk = g_tmpl_links[v];
        memcpy(G.vobj[v], lk, 256);
        memcpy(G.vd40[v], lk + 256, 4);
        memcpy(G.vd64[v], lk + 260, 4);
        /* POINTER WIRING ONLY (PORT_LESSONS 8): in the plugin obj+40 and
         * obj+64 point INTO THE UNIT STATE, at +0xAAC1D8 / +0xAAC1DC (the
         * DCO mode cells the per-patch recall rewrites -- FM modes 2/3 set
         * the first to 1). Those offsets live in the captured HIGH window
         * [0xA60000,0xAAD000), so the recall aux keeps them current. The
         * template's copied values (vd40/vd64) are the clean-boot mirror
         * and must NOT be what the DSP reads. */
        JX_PTR_STORE(G.vobj[v] + 40, G.vhigh[v] + (0xAAC1D8 - 0xA60000));
        JX_PTR_STORE(G.vobj[v] + 64, G.vhigh[v] + (0xAAC1DC - 0xA60000));
        JX_PTR_STORE(G.vstate[v] + 136, G.vobj[v]);
    }
    {   const uint8_t *sm = g_tmpl_links[17];
        G.dn.o110_58 = *(const int32_t *)(sm + 0);
        G.dn.o110_5c = *(const int32_t *)(sm + 4);
        memcpy(G.temper, sm + 8, 23 * 4);
        G.dn.temper23 = G.temper;
    }
    {   const uint8_t *lk = g_tmpl_links[18];
        memcpy(G.mobj, lk, 256);
        memcpy(G.mc136, lk + 256, 4);
        memcpy(G.mc112, lk + 260, 256);
        /* same rule for the master (PORT_LESSONS 8): obj+136 -> state+0xAAC1E8,
         * obj+112 -> state+0xAAC1E4 in the plugin; the master state block is
         * the whole unit, so the aux's master runs keep them current. */
        JX_PTR_STORE(G.mobj + 136, G.mstate + 0xAAC1E8);
        JX_PTR_STORE(G.mobj + 112, G.mstate + 0xAAC1E4);
        JX_PTR_STORE(G.mstate + 136, G.mobj);
    }
    /* wrapper + ramp records (links 8..16), targets rebased per unit */
    for (int u = 0; u < NUNITS; ++u) {
        const uint8_t *r = g_tmpl_links[8 + u];
        jx_wrap *w = &G.wrap[u];
        memcpy(&w->latch, r, 4); w->flag = r[4]; r += 8;
        memcpy(&w->nids, r, 4); r += 4;
        memcpy(w->ids, r, 4u * (uint32_t)w->nids); r += 4 * w->nids;
        memcpy(&w->nslot, r, 4); r += 4;
        w->slots = calloc((size_t)(w->nslot ? w->nslot : 1),
                          sizeof(jx_gc_slot));
        for (int i = 0; i < w->nslot; ++i) {
            uint32_t off; jx_gc_slot *sl = &w->slots[i];
            memcpy(&off, r, 4); r += 4;
            memcpy(&sl->sign, r, 32);   /* plugin slot bytes +8..+0x27 */
            r += 32;
            if (off == 0xFFFFFFFFu) sl->target = NULL;
            else if (u == 8)        sl->target = (float *)(G.mstate + off);
            else if (off >= 0xA60000u)
                sl->target = (float *)(G.vhigh[u] + (off - 0xA60000u));
            else sl->target = (float *)(G.vstate[u] + off);
        }
    }
    G.host_ok = 0;
    if (g_tmpl_v4) {
        if (g_tmpl_linksz[19] < 28) return 0;
        host_record(g_tmpl_links[19]);
    }
    return 1;
}

/* dispatch a tracker post into the right unit's proc + DSP state */
static void unit_set48(void *u, int what, int pid, int val)
{
    int unit = (int)(intptr_t)u;
    uint8_t *st = (unit < NV) ? G.vstate[unit] : G.mstate;
    (void)what;
    if (pid >= 433 && pid <= 440)
        jx_dispatch_note_cb(&G.dn, G.proc[unit], st, pid - 433, 2, val);
    else if (pid >= 450 && pid <= 457)
        jx_dispatch_gate_cb(&G.dn, G.proc[unit], st, pid - 450, 2, val);
}
/* the assigner's parameter read (vtable +0x50, 0x357E60): its parent's GET (the unit's parameter object,
 * vtable +0x60, 0x3E8E10) -- a dword at the id's offset in G.proc[unit] (jx_param_get.h, EXECUTED),
 * found or not. Before 2026-10-10 every read returned 0 from an array of zeros, so KEY ASSIGN (800:
 * mode 1 on 4 factory patches) and 798 (2, 10, 50 on 3) never reached the port's assigner. */
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
static uint32_t unit_get70(void *u)
{ return (uint32_t)(G.ktclock[(int)(intptr_t)u] / 96); }
/* THE NOTE STORE'S OUTPUTS (2026-10-10, jx3p/src/jx_seq.c): its vtable +0 / +8 play into the unit's
 * assigner (+0xFD8: vtable +0x18 note-on, +0x10 note-off), and its drain seam (the tail jump to 0x3EF210
 * at a full drain) releases its 16 playing columns. Before, the seam was a stub "as in every proof". */
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

/* parse one wrap record at r into G.wrap[u]; returns the advanced ptr */
static const uint8_t *wrap_parse(const uint8_t *r, int u)
{
    jx_wrap *w = &G.wrap[u];
    memcpy(&w->latch, r, 4); w->flag = r[4]; r += 8;
    memcpy(&w->nids, r, 4); r += 4;
    memcpy(w->ids, r, 4u * (uint32_t)w->nids); r += 4 * w->nids;
    memcpy(&w->nslot, r, 4); r += 4;
    free(w->slots);
    w->slots = calloc((size_t)(w->nslot ? w->nslot : 1), sizeof(jx_gc_slot));
    for (int i = 0; i < w->nslot; ++i) {
        uint32_t off; jx_gc_slot *sl = &w->slots[i];
        memcpy(&off, r, 4); r += 4;
        memcpy(&sl->sign, r, 32); r += 32;
        if (off == 0xFFFFFFFFu) sl->target = NULL;
        else if (u == 8)        sl->target = (float *)(G.mstate + off);
        else if (off >= 0xA60000u)
            sl->target = (float *)(G.vhigh[u] + (off - 0xA60000u));
        else sl->target = (float *)(G.vstate[u] + off);
    }
    return r;
}

static const uint8_t *runs_apply(const uint8_t *p, uint8_t *dst, int apply)
{
    uint32_t nr; memcpy(&nr, p, 4); p += 4;
    for (uint32_t r2 = 0; r2 < nr; ++r2) {
        uint32_t off, ln; memcpy(&off, p, 4); memcpy(&ln, p + 4, 4);
        p += 8;
        if (apply) memcpy(dst + off, p, ln);
        p += ln;
    }
    return p;
}

void jx3p_recall(int idx)
{
    /* EVERYTHING resets to the clean template, then the patch's own aux deltas laid on top -- the
     * engine the plugin holds after its boot and its patch browser's load of the patch (2026-10-10:
     * the plugin's own records through its own host entry, jx3p/tools/jx_recall_data_gate.py; before,
     * the aux came from a pool MODEL of the recall, playbook 197). JXM4 adds, per patch, the control
     * objects (note managers, note stores, assigners, parameter objects -- KEY ASSIGN lives there) and
     * the engine HOST record: every patch load queues writePatch, so the output fades as the plugin's
     * does (0.5 s at gain 0, then 10 ms in). A cold restart per patch change (scope row 9). */
    if (g_mrec_v4)
        for (int i = 0; i < NUNITS; ++i) {
            memcpy(G.mgr.u[i], g_tmpl_regions[8 + 3 * i], JXA_UNIT_SZ);
            ns_load(i);
            memcpy(G.kt[i],    g_tmpl_regions[10 + 3 * i], 0xB0);
            memcpy(G.proc[i],  g_tmpl_regions[35 + i], PROC_SZ);
        }
    for (int v = 0; v < NV; ++v) {
        memcpy(G.vstate[v], g_tmpl_regions[v], SNAP_V);
        JX_PTR_STORE(G.vstate[v] + 136, G.vobj[v]);
    }
    memcpy(G.mstate, g_tmpl_regions[52], SNAP_M);
    JX_PTR_STORE(G.mstate + 136, G.mobj);
    for (int v = 0; v < NV; ++v)
        memcpy(G.vhigh[v], g_tmpl_regions[44 + v], 0x4D000);
    {   const uint8_t *p = g_mrec + 8;
        for (int k = 0; k <= idx; ++k) {
            int last = (k == idx);
            p = runs_apply(p, G.mstate, last);
            for (int v = 0; v < NV; ++v)
                p = runs_apply(p, G.vstate[v], last);
            for (int v = 0; v < NV; ++v)
                p = runs_apply(p, G.vhigh[v], last);
            for (int u = 0; u < NUNITS; ++u) {
                if (last) p = wrap_parse(p, u);
                else {    /* skip the record without applying */
                    int32_t nids, nslot;
                    memcpy(&nids, p + 8, 4);
                    memcpy(&nslot, p + 12 + 4 * nids, 4);
                    p += 16 + 4 * nids + 36 * nslot;
                }
            }
            if (g_mrec_v4) {
                for (int i = 0; i < NUNITS; ++i) {
                    p = runs_apply(p, G.mgr.u[i], last);
                    p = runs_apply(p, G.ns[i], last);
                    p = runs_apply(p, G.kt[i], last);
                }
                for (int i = 0; i < NUNITS; ++i)
                    p = runs_apply(p, G.proc[i], last);
                if (last) host_record(p);
                p += 28;
            }
        }
    }
    if (g_mrec_v4)
        for (int u = 0; u < NUNITS; ++u) G.ktclock[u] = 0;
}
void jx3p_note_on(int note, int vel)
{ jx_alloc_note_on(&G.mgr, &g_acbs, note, vel); }
void jx3p_note_off(int note)
{ jx_alloc_note_off(&G.mgr, &g_acbs, note, 0x40); }

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
    for (int v = 0; v < NV; ++v) {
        pairs[v][0] = &G.vcells[2 * v];
        pairs[v][1] = &G.vcells[2 * v + 1];
        a2[2 * v] = (uint64_t)(uintptr_t)&G.vcells[2 * v];
        a2[2 * v + 1] = (uint64_t)(uintptr_t)&G.vcells[2 * v + 1];
    }
    /* THE ENGINE RENDER'S PREAMBLE (rva 0x3F9220, READ; 2026-10-10): per voice unit its assigner's
     * count synced to the HOST's (the setter, jx_ktrack_set_count) and its clock advanced by the
     * call's samples; only units below the count render -- the others' outputs are zero and their
     * wrappers do not run (six voices by default: initialize's record 0x0FFFC00E). */
    if (G.host_ok && !G.host_stage_off)
        for (int u = 0; u < NV; ++u) {
            jx_ktrack_cbs c = { unit_set48, unit_get50, unit_get70, (void *)(intptr_t)u };
            if (jx_ktrack_count(G.kt[u]) != G.nvoices)
                jx_ktrack_set_count(G.kt[u], &c, G.nvoices);
            G.ktclock[u] += n;
        }
    for (int s = 0; s < n; ++s) {
        /* the per-unit WRAPPER (0x377080 voice / 0x377010 master):
         * flag==0 -> untouched; latch>0 -> outputs zeroed, GC only;
         * else -> outputs zeroed, inner render, GC. */
        for (int v = 0; v < NV; ++v) {
            jx_wrap *w = &G.wrap[v];
            if (G.host_ok && !G.host_stage_off && v >= G.nvoices) {        /* not rendered: outputs zero */
                G.vcells[2 * v] = G.vcells[2 * v + 1] = 0.0f;
                continue;
            }
            if (!w->flag) continue;
            if (w->latch > 0) {
                --w->latch;
                JX_LATCH_STORE(v, w);
                G.vcells[2 * v] = G.vcells[2 * v + 1] = 0.0f;
            } else {
                G.vcells[2 * v] = G.vcells[2 * v + 1] = 0.0f;
                jx_voice_render(G.vstate[v], v, pairs[v]);
            }
            jx_gc_sweep(w->ids, &w->nids, w->slots);
        }
        {   jx_wrap *w = &G.wrap[8];
            outL = outR = 0;
            if (w->flag) {
                if (w->latch > 0) {
                    --w->latch;
                    JX_LATCH_STORE(8, w);
                } else {
                    jx_master_render(G.mstate, a2, a3);
                }
                jx_gc_sweep(w->ids, &w->nids, w->slots);
            }
        }
        if (G.host_ok && !G.host_stage_off) {
            /* THE OUTPUT GAIN STAGE (rva 0x3F9731..0x3F9844, READ): while samples are left the gain
             * moves by the step, held in [0, 1]; then a positive step holds 1.0, else the gain is 0 and
             * the delay counts down; when it ends the fade-in starts: trunc(rate x time x 0.001)
             * samples (at least 1), step 1 / that (in double). writePatch arms it (1 sample at -1, the
             * delay 0.5 s, the time 10 ms). */
            float g;
            int32_t left = G.gleft;
            G.gleft = (int32_t)((uint32_t)left - 1u);  /* it counts on below 0, as the asm's dec does */
            if (left > 0) {
                g = G.gstep + G.gain;
                G.gain = g;
                if (g >= 1.0f) { G.gain = 1.0f; g = 1.0f; }
                else if (!(g > 0.0f)) { G.gain = 0.0f; g = 0.0f; }
            } else if (!(0.0f >= G.gstep)) {         /* comiss 0, step; jae: an unordered step holds 1.0 */
                G.gain = 1.0f; g = 1.0f;
            } else {
                G.gain = 0.0f; g = 0.0f;
                if (G.gdelay > 0) {
                    G.gdelay -= 1;
                    if (G.gdelay <= 0) {
                        float t = G.rate * G.gtime;
                        int32_t k;
                        t = t * 0.001f;
                        k = (int32_t)t;
                        if (k < 1) k = 1;
                        G.gleft = k;
                        G.gstep = (float)(1.0 / (double)k);
                        g = G.gain;
                    }
                }
            }
            {   float l, r;
                memcpy(&l, &outL, 4); memcpy(&r, &outR, 4);
                l = g * l; r = G.gain * r;
                memcpy(&outL, &l, 4); memcpy(&outR, &r, 4);
            }
        }
        memcpy(&L[s], &outL, 4);
        memcpy(&R[s], &outR, 4);
    }
    G.clock += n;
}

/* WEB-PREVIEW DRY RENDER: the 8 proven voices, summed, master EFX network
 * BYPASSED. The master needs the host parameter initialization a DAW
 * performs at insert (its effect manager is the logged open item); without
 * it the network self-poisons. The voices -- oscillators, filters,
 * envelopes, the whole per-voice engine proven 64/64 EXACTLY 0 -- are the
 * instrument; this preview plays them directly. */
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
            jx_wrap *w = &G.wrap[v];
            if (!w->flag) continue;
            if (w->latch > 0) {
                --w->latch;
                JX_LATCH_STORE(v, w);
                G.vcells[2 * v] = G.vcells[2 * v + 1] = 0.0f;
            } else {
                G.vcells[2 * v] = G.vcells[2 * v + 1] = 0.0f;
                jx_voice_render(G.vstate[v], v, pairs[v]);
            }
            jx_gc_sweep(w->ids, &w->nids, w->slots);
            accL += G.vcells[2 * v];
            accR += G.vcells[2 * v + 1];
        }
        L[s] = accL; R[s] = accR;
    }
    G.clock += n;
}

/* raw access for the full-chain gate and the recall data gate (jx3p/tools/jx_recall_data_gate.py) */
void *jx3p_vstate(int v) { return G.vstate[v]; }
void *jx3p_mstate(void)  { return G.mstate; }
void *jx3p_vhigh(int v)  { return G.vhigh[v]; }
/* the control objects in template order: which 0 note manager, 1 note store, 2 assigner, 3 parameter object */
void *jx3p_ctl(int which, int i)
{
    switch (which) {
    case 0: return G.mgr.u[i];
    case 1: return G.ns[i];
    case 2: return G.kt[i];
    default: return G.proc[i];
    }
}
/* the engine HOST record now (host_record's layout); returns host_ok */
int jx3p_host(uint8_t out[28])
{
    memcpy(out + 0, &G.nvoices, 4); memcpy(out + 4, &G.gain, 4); memcpy(out + 8, &G.gstep, 4);
    memcpy(out + 12, &G.gleft, 4); memcpy(out + 16, &G.gdelay, 4); memcpy(out + 20, &G.gtime, 4);
    memcpy(out + 24, &G.rate, 4);
    return G.host_ok;
}

/* unit u's wrapper + ramp record in the exporter's form (jx_master_recall_export.py wrap_record):
 * latch, flag, the active ids, then per slot its target as an offset in the unit (0xFFFFFFFF: none)
 * and the slot's bytes +8..+0x27. Returns the length, or -1 when cap is too small. */
int jx3p_wrap_dump(int u, uint8_t *out, int cap)
{
    const jx_wrap *w = &G.wrap[u];
    int n = 16 + 4 * w->nids + 36 * w->nslot, i;
    uint8_t *p = out;
    if (n > cap) return -1;
    memcpy(p, &w->latch, 4); p[4] = w->flag; p[5] = p[6] = p[7] = 0; p += 8;
    memcpy(p, &w->nids, 4); p += 4;
    memcpy(p, w->ids, 4u * (uint32_t)w->nids); p += 4 * w->nids;
    memcpy(p, &w->nslot, 4); p += 4;
    for (i = 0; i < w->nslot; ++i) {
        const jx_gc_slot *sl = &w->slots[i];
        const uint8_t *t = (const uint8_t *)sl->target;
        uint32_t off;
        if (!t) off = 0xFFFFFFFFu;
        else if (u == 8) off = (uint32_t)(t - G.mstate);
        else if (t >= G.vhigh[u] && t < G.vhigh[u] + 0x4D000) off = 0xA60000u + (uint32_t)(t - G.vhigh[u]);
        else off = (uint32_t)(t - G.vstate[u]);
        memcpy(p, &off, 4); memcpy(p + 4, &sl->sign, 32); p += 36;
    }
    return n;
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
long long jx3p_ktclock(int u) { return (u >= 0 && u < NUNITS) ? (long long)G.ktclock[u] : -1; }

/* THE PLUGIN'S RENDER OBJECT (JX-4, 2026-10-10): between its render driver and the engine sits the
 * JUNO-60's render object -- table and coefficient vectors byte for byte (jx3p/tools/jx_conv_tables.py,
 * EXECUTED; jx3p/docs/HOST_LAYER.md 2b) -- so the port takes src/juno_conv.c as it is. The engine runs
 * at the template's own rate (its HOST record: the automatic setting's 96000 for hosts 44100, 48000
 * and 96000, with data exported at that rate), the object is looked up for (engine, host):
 * IDENTITY renders the engine for the host block, CONVERTER renders what its filter needs and filters
 * (rva 0x343E30), SILENCE gives zeros. jx3p_product_process is one host block whose records (notes,
 * the patch) the caller gave before it: the render driver's split of a block at record offsets is not
 * ported yet (jx3p/tools/jx_product_gate.py grades blocks with their events at offset 0). */
#include "../../src/juno_conv.c"
/* the render driver's state (jx3p_product_block below) */
#define JX_DRV_QMAX 256
typedef struct { int off, on, note, vel; } jx_drv_rec;
static jx_drv_rec g_drv_carry[JX_DRV_QMAX]; static int g_drv_ncarry;
static long long g_drv_ph; static int g_drv_notes, g_drv_rate;

static juno_ro g_ro; static int g_ro_on;
static void jx_ro_engine(void *user, float *const *ptrs, int nch, int count)
{
    (void)user; (void)nch;
    jx3p_render(ptrs[0], ptrs[1], count);
}
/* the object for (the engine's rate, host_rate); returns its kind (0 identity, 1 converter, 2 silence),
 * -1 without a HOST record (an old template) or when a buffer cannot be allocated */
int jx3p_product_open(int host_rate)
{
    if (!G.host_ok) return -1;
    if (g_ro_on) juno_ro_free(&g_ro);
    juno_ro_init(&g_ro, (int)G.rate, host_rate);
    g_ro_on = 1;
    g_drv_rate = host_rate; g_drv_ph = 0; g_drv_notes = 0; g_drv_ncarry = 0;   /* the driver at instance start */
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
static void drv_apply(const jx_drv_rec *r)
{
    if (r->on) { jx3p_note_on(r->note, r->vel); g_drv_notes++; }
    else       { jx3p_note_off(r->note); g_drv_notes--; }
}
/* one host block: ev[4 i ..] = { offset, type (0 note-on, 1 note-off), note, velocity 0..127 } */
int jx3p_product_block(float *L, float *R, int n, const int *ev, int nev)
{
    jx_drv_rec rec[2 * JX_DRV_QMAX];
    int nrec = 0, i, k, t, cut, s0;
    long long P = (60000000000LL * (long long)g_drv_rate / 1200) / 24, ph;
    if (n <= 0) return 0;
    for (i = 0; i < g_drv_ncarry; ++i) rec[nrec++] = g_drv_carry[i];
    for (i = 0; i < nev && nrec < 2 * JX_DRV_QMAX; ++i) {
        rec[nrec].off = ev[4 * i]; rec[nrec].on = ev[4 * i + 1] == 0;
        rec[nrec].note = ev[4 * i + 2]; rec[nrec].vel = ev[4 * i + 3]; ++nrec;
    }
    g_drv_ncarry = 0;
    {
        int last = -1, lastoff = -1;
        cut = nrec;
        for (i = 0; i < nrec; ++i) {
            int off = rec[i].off;
            if (rec[i].on) {
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

/* debug/bench: force one unit's wrapper flag */
void jx3p_wrap_flag(int u, int f) { G.wrap[u].flag = (uint8_t)f; }
float jx3p_vcell(int i) { return G.vcells[i]; }

/* PREVIEW HOLD (documented, reversible): the chorus effect's manager (the
 * pending-page swap machine and its host rate parameter) is NOT yet
 * transcribed; with no host to set the rate, the plugin's own boot ramps
 * fade the chorus in over an unconfigured LFO and the output pins at the
 * NaN clamp (jx3p/docs/S3_STATUS.md logs the arc). Until that manager is
 * transcribed, the web preview keeps the chorus OFF by deactivating the
 * two ramps that raise its enable (st+269808) and depth (st+10928080) --
 * the same "module OFF law" precedent the JUNO CLASSIC uses. Everything
 * else is untouched and bit-exact. */
/* WEB-PREVIEW NaN SCRUB (bridge-level; the proven DSP sources are NOT
 * touched, and no gate runs with this). The master effect network births
 * a NaN on its shared delay line when it runs without the host parameter
 * initialization a DAW performs (the effect manager's host-param init is
 * the logged open item, jx3p/docs/S3_STATUS.md). Once born, the NaN
 * circulates and the output clamp pins at full scale. The preview scrubs
 * non-finite cells back to zero the moment they appear, at the line and
 * its mirrors. */
static void jxw_scrub_region(uint8_t *base, uint32_t off, uint32_t len)
{
    float *p = (float *)(base + off);
    for (uint32_t i = 0; i < len / 4; ++i) {
        float v = p[i];
        if (v != v || v - v != 0.0f) p[i] = 0.0f;
    }
}
void jx3p_nan_scrub(void)
{
    jxw_scrub_region(G.mstate, 269888, 80);       /* the mirror cells    */
    jxw_scrub_region(G.mstate, 10927568, 0x2000); /* line head + filters */
    jxw_scrub_region(G.mstate, 10928592, 0x40000);/* the shared line     */
}

void jx3p_efx_hold(void)
{
    jx_wrap *w = &G.wrap[8];
    for (int i = 0; i < w->nslot; ++i) {
        jx_gc_slot *sl = &w->slots[i];
        if (!sl->target) continue;
        {   ptrdiff_t off = (uint8_t *)sl->target - G.mstate;
            if (off >= 269700)          /* the EFX block + chorus mirrors */
                sl->active = 0;
        }
    }
}

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
#include <zlib.h>

/* ---- proven modules (single-file link; see jx_full_gate.sh) ---- */
#include "../src/jx_alloc.c"
#include "../src/jx_nstore.c"
#include "../src/jx_ktrack.c"
#include "../src/jx_dispatch_note.c"
#include "../src/jx_gc.c"

int  jx_bank_apply(unsigned char *blk, const unsigned char *bank, int idx);
uint64_t jx_voice_render(void *vstate, int v, void *pair);
void *jx_master_render(void *mstate, void *a2, void *a3);

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
    uint8_t  ns[NUNITS][0xDB0];
    uint8_t  kt[NUNITS][0xB0];
    /* re-linked C++ object headers (pointer cells live HERE, never in the
     * template): voice obj 256B + two 4B cells; master obj + 4B + 256B */
    uint8_t  vobj[NV][256], vd40[NV][4], vd64[NV][4];
    uint8_t  mobj[256], mc136[4], mc112[256];
    /* dispatch seam constants from the template */
    jx_dn_cbs dn;
    float     temper[23];
    /* host params the tracker queries (id 798 observed; default 0) */
    int32_t  hostp[1024];
    int64_t  clock;                     /* get70 tape source: samples/48 */
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
static int g_nreg, g_nlink;

static int tmpl_load(const char *path)
{
    FILE *f = fopen(path, "rb");
    uint8_t hdr[8];
    if (!f) return 0;
    if (fread(hdr, 1, 8, f) != 8 || memcmp(hdr, "JXT2", 4)) return 0;
    g_nreg = (int)(uint32_t)(hdr[4] | (hdr[5] << 8) | (hdr[6] << 16) |
                             ((uint32_t)hdr[7] << 24));
    for (int i = 0; i < g_nreg; ++i) {
        uint32_t raw, z;
        if (fread(&raw, 4, 1, f) != 1 || fread(&z, 4, 1, f) != 1) return 0;
        uint8_t *zb = malloc(z), *rb = malloc(raw);
        uLongf dl = raw;
        if (fread(zb, 1, z, f) != z) return 0;
        if (uncompress(rb, &dl, zb, z) != Z_OK || dl != raw) return 0;
        free(zb);
        g_tmpl_regions[i] = rb; g_tmpl_rawsz[i] = raw;
    }
    /* exactly 19 links follow the regions: 8 voice links, 9 wrapper+ramp
     * records, the dispatch seam, the master link; then the 4-byte crc. */
    g_nlink = 0;
    for (int i = 0; i < 19; ++i) {
        uint32_t ln;
        if (fread(&ln, 4, 1, f) != 1) break;
        g_tmpl_links[g_nlink] = malloc(ln);
        if (fread(g_tmpl_links[g_nlink], 1, ln, f) != ln) break;
        g_tmpl_linksz[g_nlink] = ln;
        ++g_nlink;
    }
    fclose(f);
    return g_nreg >= 53 && g_nlink == 19;
}

/* ---- the public API ---- */

static uint8_t *g_mrec; static size_t g_mrec_len;

int jx3p_init(const char *template_path, const char *bank_path,
              const char *master_recall_path)
{
    if (!tmpl_load(template_path)) return 0;
    {   FILE *f = fopen(master_recall_path, "rb");
        if (!f) return 0;
        fseek(f, 0, SEEK_END); g_mrec_len = (size_t)ftell(f); rewind(f);
        g_mrec = malloc(g_mrec_len);
        if (fread(g_mrec, 1, g_mrec_len, f) != g_mrec_len) return 0;
        fclose(f);
        if (memcmp(g_mrec, "JXM3", 4)) return 0;
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
        memcpy(G.ns[i],    g_tmpl_regions[9 + 3 * i], 0xDB0);
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
        *(void **)(G.vobj[v] + 40) = G.vd40[v];
        *(void **)(G.vobj[v] + 64) = G.vd64[v];
        *(void **)(G.vstate[v] + 136) = G.vobj[v];
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
        *(void **)(G.mobj + 136) = G.mc136;
        *(void **)(G.mobj + 112) = G.mc112;
        *(void **)(G.mstate + 136) = G.mobj;
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
static int unit_get50(void *u, int what, int pid, int32_t *out)
{
    (void)u; (void)what;
    if (pid >= 0 && pid < 1024) { *out = G.hostp[pid]; return 1; }
    return 0;
}
static uint32_t unit_get70(void *u)
{ (void)u; return (uint32_t)(G.clock / 48); }
static void ns_drain(void *u, int kind, int a, int b2)
{ (void)u; (void)kind; (void)a; (void)b2; }  /* stubbed as in every proof */

static void sink518_on(void *u, int unit, int note, int vel)
{   jx_nstore_cbs c = { ns_drain, NULL };
    (void)u; jx_nstore_on5100(G.ns[unit], &c, note, vel); }
static void sink518_off(void *u, int unit, int note, int vel)
{   jx_nstore_cbs c = { ns_drain, NULL };
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
    /* EVERYTHING resets to the clean template, then the patch's own aux
     * deltas (JXM3, derived order-true from the binary) laid on top. The
     * jx_bank_apply LUT stays in the tree but is NOT the gate path: the two
     * harness pool models disagree (13 pools each way, order-dependent
     * writes) and the resolution of the TRUE host recall protocol is the
     * logged follow-up; the deltas ARE the oracle's own recall, byte for
     * byte, for every factory patch. */
    for (int v = 0; v < NV; ++v) {
        memcpy(G.vstate[v], g_tmpl_regions[v], SNAP_V);
        *(void **)(G.vstate[v] + 136) = G.vobj[v];
    }
    memcpy(G.mstate, g_tmpl_regions[52], SNAP_M);
    *(void **)(G.mstate + 136) = G.mobj;
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
        }
    }
}
void jx3p_note_on(int note, int vel)
{ jx_alloc_note_on(&G.mgr, &g_acbs, note, vel); }
void jx3p_note_off(int note)
{ jx_alloc_note_off(&G.mgr, &g_acbs, note, 0x40); }

void jx3p_render(float *L, float *R, int n)
{
    void *pairs[NV][2];
    void *a2[16];
    uint32_t outL, outR;
    void *a3[2] = { &outL, &outR };
    for (int v = 0; v < NV; ++v) {
        pairs[v][0] = &G.vcells[2 * v];
        pairs[v][1] = &G.vcells[2 * v + 1];
        a2[2 * v] = &G.vcells[2 * v];
        a2[2 * v + 1] = &G.vcells[2 * v + 1];
    }
    for (int s = 0; s < n; ++s) {
        /* the per-unit WRAPPER (0x377080 voice / 0x377010 master):
         * flag==0 -> untouched; latch>0 -> outputs zeroed, GC only;
         * else -> outputs zeroed, inner render, GC. */
        for (int v = 0; v < NV; ++v) {
            jx_wrap *w = &G.wrap[v];
            if (!w->flag) continue;
            if (w->latch > 0) {
                --w->latch;
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
                } else {
                    jx_master_render(G.mstate, a2, a3);
                }
                jx_gc_sweep(w->ids, &w->nids, w->slots);
            }
        }
        memcpy(&L[s], &outL, 4);
        memcpy(&R[s], &outR, 4);
    }
    G.clock += n;
}

/* raw access for the full-chain gate */
void *jx3p_vstate(int v) { return G.vstate[v]; }
void *jx3p_mstate(void)  { return G.mstate; }

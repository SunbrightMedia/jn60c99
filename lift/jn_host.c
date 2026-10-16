/* jn_host.c -- the JUNO-60 as a DAW runs it, in C: the plugin's own VST3 setupProcessing, setActive, process(),
 * patch load, getState / setState, the UI timer, MIDI learn and the editor's set, LIFTED (lift/jn_lift.c on
 * jp8/src/jp8_cpu.h via jp8_rt.c), on the memory the JUNO host oracle (tools/verify/host_process_emu.HostProcess on
 * probes/b6/wrapper_emu.py) had after booting the plugin up to the point a host learns its sample rate (a JNH1
 * template, tools/lift/jn_host_ref.py). Plumbing ONLY, the oracle's, line for line (docs/JUNO_LIFT.md L4):
 *  - junoh_init makes the host's setup calls the oracle's setup() makes, at the rate it is given, and creates the
 *    blocks' host objects in the oracle's order (one bump arena: the same guest addresses);
 *  - the host objects the plugin calls (IEventList, IParameterChanges, IParamValueQueue, IComponentHandler, IBStream)
 *    answer as host_process_emu / wrapper_emu answer; the imports answer as e2e_emu / wrapper_emu shim them;
 *  - the engine render's thread transport (CWaveGen vt+56, rva 0x3C7400, --replace) is served by jp8_hook as the
 *    oracle's _on_render serves it: the plugin's own voice / master, composed by the host (the DSP is lifted).
 * No plugin logic is reimplemented here. Built with lift/jn_lift.c and jp8/src/jp8_rt.c (-DJP8_RELOC, the GS base the
 * oracle's TEB 0x580000000). The lift generated with gen_juno_lift.sh (--hostcalls --alloc 0x67522C --replace). */
#include "jp8_cpu.h"
#include "junoh.h"
#include "jn_oracle_imports.h"   /* GENERATED (tools/lift/gen_oracle_imports.py): every import the oracle singles out */
#ifndef JP8_RELOC
#error "jn_host.c needs JP8_RELOC"
#endif

#include "jn_entries.h"            /* every rva the glue calls directly -- each is a lift root (jn_extra_roots.py) */
#define IB            0x180000000ULL
#define ENGINE_RENDER 0x3C7400ULL     /* CWaveGen vt+56: the engine render's thread transport (served by the host) */
#define VOICE_WRAP    JN_RVA_VOICE_WRAP
#define MASTER_WRAP   JN_RVA_MASTER_WRAP
#define ASG_GET_COUNT JN_RVA_ASG_GET_COUNT
#define ASG_SET_COUNT JN_RVA_ASG_SET_COUNT
#define HOST_NVOICE   0x38ULL         /* the engine's voice count (HOST + 0x38) */
#define ASG_COUNTER   168ULL          /* the assigner sample counter (assign[v] + 168) += block */
#define BUF_BASE      0x700000000ULL  /* the audio buffers (per-voice main/sub, then master L/R) + render scratch */
#define UITICK        JN_RVA_UITICK
#define CC_LEARN      JN_RVA_CC_LEARN
#define CC_FORGET     JN_RVA_CC_FORGET
#define REC_ID        JN_RVA_REC_ID
#define MODEL_SET     JN_RVA_MODEL_SET
#define ZOOM_GET      JN_RVA_ZOOM_GET
#define WINDOW_FIT    JN_RVA_WINDOW_FIT  /* a lifter hook (gen_juno_lift.sh --hook): the window is found by its fit */
#define NWIN_MAX      16
#define NGD_MAX       4096            /* GDI+ images (the module init makes 26) */
#define NDIB_MAX      4096            /* DIB sections (the module init makes 26) */
#define NSKIN_MAX     256             /* the skin's bitmaps (Script.xml names 30) */
#define NSKIN_NAME    64
#define PROCESS_SLOT  9               /* IAudioProcessor::process (rva 0x34A380) */
#define NPQ           8               /* parameter queues a block may use (one per parameter id) */
#define NCC_MAX       1024
#define NREG_MAX      16
#define NSTUB_MAX     4096
#define NKV_MAX       256             /* TLS / FLS slots and run-once entries the oracle's dicts may hold */
#define NSL_MAX       16              /* SList heads */
#define NUNH_MAX      128             /* distinct imports answered by the oracle's default (counted, like its .unhandled) */
#define MAXEV         512
#define S_OK_         0ULL
#define E_FAIL_       0x80004005ULL
#define E_NOINTERFACE_ 0x80004002ULL

extern int jp8_map(uint64_t base, uint64_t size);
extern int jp8_call_x(CPU *c, uint64_t rva);
extern const char *jp8_last_trap(void);
extern void jp8_heap_set(uint64_t ptr, uint64_t lim);
extern void jp8_hc_set(uint64_t hc);
extern uint64_t jp8_heap_get(void);
extern void jp8_run(CPU *c, uint64_t rva);
extern void jp8_heap_reuse(int on);
extern void jp8_heap_free(uint64_t p);
extern uint64_t jp8_heap_alloc(uint64_t sz);
extern uint64_t jp8_hc_next(void);
extern void jp8_trace_open(const char *path);   /* the per-instruction trace (a --trace lift), for the L5 diff */
extern void jp8_trace_close(void);

/* the IBStream interface id (wrapper_emu.IID_IBSTREAM, vst_iid byte order) */
static const uint8_t IID_IBSTREAM[16] = { 0xA2,0x6E,0xBF,0xC3, 0x99,0x30,0x52,0x47, 0x9B,0x6B,0xF9,0x90, 0x1E,0xE3,0x3E,0x9B };

typedef struct { uint64_t addr; char name[48]; } stub_t;
static struct {
    int st;                              /* 0 none, 1 live, 2 dead */
    CPU cpu;
    char msg[256];
    int nreg; uint64_t rbase[NREG_MAX], rsize[NREG_MAX];
    /* the template's facts (tools/lift/jn_host_ref.py) */
    uint64_t rsp, ret, audio, comp, core, ctrl, process_fn, patch_fn, com_next, mx0,
             vt_events, vt_pchanges, vt_pqueue, vt_stream, fake_heap, lasterr;
    uint64_t reg[16], xreg[16][2], eflags;
    /* the host objects junoh_init makes after the setup calls (host_process_emu.setup's order) */
    uint64_t bufl, bufr, bus, ctx, pd, ev, pc, pq[NPQ]; double rate; uint64_t maxblock;
    /* the IBStream of the state call in flight (one per call, as the oracle makes it) */
    uint64_t s_addr; unsigned char *s_data; size_t s_len, s_cap; int64_t s_pos;
    /* the host objects' contents for the call in flight */
    int nev; uint8_t evs[MAXEV][48];
    int npq; uint32_t pq_id[NPQ]; int pq_n[NPQ]; int32_t *pq_off[NPQ]; double *pq_val[NPQ];
    /* the performEdit calls the plugin hands the component handler (for the gates) */
    uint32_t *edit_id; double *edit_val; int nedit, edit_cap;
    stub_t stub[NSTUB_MAX]; int nstub;
    uint64_t njobs;                      /* engine render calls served */
    /* the engine the plugin built (core+272) and its per-unit objects (host_process_emu.setup), for the render */
    uint64_t HOST, state[9], assign[9];
    /* the oracle's PYTHON-SIDE state -- not guest memory, so the template carries it as facts (jn_host_ref.py) and the
     * glue keeps it exactly as the oracle keeps it: the TLS / FLS dicts (key = the full rcx, as the oracle's dict keys),
     * the SList heads (each a stack, bottom first: wrapper_emu.slists), the run-once set (wrapper_emu.once), and the
     * imports answered by the oracle's default (0, counted as its .unhandled is) */
    int ntls; uint64_t tls_k[NKV_MAX], tls_v[NKV_MAX], tls_ctr;
    int nfls; uint64_t fls_k[NKV_MAX], fls_v[NKV_MAX], fls_ctr;
    int nsl; uint64_t sl_head[NSL_MAX]; uint64_t *sl_e[NSL_MAX]; int sl_n[NSL_MAX], sl_cap[NSL_MAX];
    int nonce; uint64_t once[NKV_MAX];
    int nunh; const char *unh_name[NUNH_MAX]; uint64_t unh_n[NUNH_MAX];
    /* the editor (host_process_emu.attach_editor): from its first attach on, each panel window found by its fit's
     * call (WINDOW_FIT) -- windows[(w, h)] = the window, the latest of a size */
    int ed_on; int nwin; struct { int32_t w, h; uint64_t win; } win[NWIN_MAX];
    /* the editor's imports (wrapper_emu._imp / _gdip): the virtual screen (GetSystemMetrics 78 / 79, others 0), the
     * GUI's clock (GetTickCount: the oracle's tick_ms), the GDI+ images (gdip_imgs: handle -> w, h, format), the DIB
     * sections (dibs) and the skin's blank-image sizes by file name (wrapper_emu.skin_sizes over Script.xml): the
     * oracle's Python-side state, seeded from the template's facts gi/gs/gf, dh/dw/dp/db, sk/sn (jn_host_ref.py) */
    int32_t scr_cx, scr_cy; uint64_t tick_ms;
    int ngd; struct { uint64_t hd; uint32_t w, h, fmt; } gd[NGD_MAX];
    int ndib; struct { uint64_t hb, bits; int32_t w, h; uint32_t bpp, stride; } dib[NDIB_MAX];
    int nskin; struct { char name[NSKIN_NAME]; uint32_t w, h; } skin[NSKIN_MAX];
} H;

/* ---------------------------------------------------------------- guest memory (one mapped band region) */
void *junoh_guest(uint64_t a, size_t n) {
    uint64_t i = a >> 28, last = (a + n - 1) >> 28, k;
    if (!n || last >= JP8_NBANDS) return NULL;
    for (k = i; k <= last; k++) {
        uint64_t lo = k == i ? (a & 0x0FFFFFFFu) : 0, hi = k == last ? ((a + n - 1) & 0x0FFFFFFFu) + 1 : 0x10000000ULL;
        if (!jp8_bhi[k] || lo < jp8_blo[k] || hi > jp8_bhi[k] || jp8_bdelta[k] != jp8_bdelta[i]) return NULL;
    }
    return (void *)((uintptr_t)a + jp8_bdelta[i]);
}
static uint64_t gq(uint64_t a) { uint64_t v = 0; void *p = junoh_guest(a, 8); if (p) memcpy(&v, p, 8); return v; }
static int32_t gi(uint64_t a) { int32_t v = 0; void *p = junoh_guest(a, 4); if (p) memcpy(&v, p, 4); return v; }
static void wq(uint64_t a, uint64_t v) { void *p = junoh_guest(a, 8); if (p) memcpy(p, &v, 8); }
static void wmem(uint64_t a, const void *s, size_t n) { void *p = junoh_guest(a, n); if (p && n) memcpy(p, s, n); }
static uint32_t le32(const unsigned char *p) { return (uint32_t)p[0] | (uint32_t)p[1] << 8 | (uint32_t)p[2] << 16 | (uint32_t)p[3] << 24; }
static uint64_t le64(const unsigned char *p) { return (uint64_t)le32(p) | (uint64_t)le32(p + 4) << 32; }
static uint32_t crc32_of(const unsigned char *p, size_t n) {
    static uint32_t t[256]; static int ready; uint32_t c = 0xFFFFFFFFu; size_t i;
    if (!ready) { uint32_t k, j, x; for (k = 0; k < 256; k++) { x = k; for (j = 0; j < 8; j++) x = (x & 1) ? 0xEDB88320u ^ (x >> 1) : x >> 1; t[k] = x; } ready = 1; }
    for (i = 0; i < n; i++) c = t[(c ^ p[i]) & 0xFF] ^ (c >> 8);
    return c ^ 0xFFFFFFFFu;
}
static int err(int code, const char *m) { snprintf(H.msg, sizeof H.msg, "%s", m); return code; }
const char *junoh_error(void) { return H.msg; }

/* ---------------------------------------------------------------- the bump arena (the oracle's alloc_com) */
static uint64_t alloc_com(uint64_t n) { uint64_t p = H.com_next; H.com_next += (n + 15) & ~15ULL; return p; }
static uint64_t new_obj(uint64_t vt) { uint64_t p = alloc_com(16); wq(p, vt); return p; }

/* ---------------------------------------------------------------- the stub table (imports + COM methods) */
static const char *stub_name(uint64_t target) {
    int lo = 0, hi = H.nstub - 1;
    while (lo <= hi) { int m = (lo + hi) / 2; if (H.stub[m].addr == target) return H.stub[m].name; if (H.stub[m].addr < target) lo = m + 1; else hi = m - 1; }
    return NULL;
}
static void record_edit(uint32_t id, double v) {
    if (H.nedit == H.edit_cap) {
        int cap = H.edit_cap ? 2 * H.edit_cap : 256;
        uint32_t *a = (uint32_t *)realloc(H.edit_id, sizeof *a * (size_t)cap);
        double *b = (double *)realloc(H.edit_val, sizeof *b * (size_t)cap);
        if (!a || !b) return;
        H.edit_id = a; H.edit_val = b; H.edit_cap = cap;
    }
    H.edit_id[H.nedit] = id; H.edit_val[H.nedit] = v; H.nedit++;
}
static int pq_index(uint64_t this_) { int i; for (i = 0; i < NPQ; i++) if (H.pq[i] == this_) return i; return -1; }

/* ---------------------------------------------------------------- the oracle's Python-side state (TLS, FLS, SLists, once) */
static int kv_find(int n, const uint64_t *k, uint64_t key) { int i; for (i = 0; i < n; i++) if (k[i] == key) return i; return -1; }
static int kv_set(int *n, uint64_t *k, uint64_t *v, uint64_t key, uint64_t val) {   /* the oracle's d[key] = val; -1: full */
    int i = kv_find(*n, k, key);
    if (i < 0) { if (*n == NKV_MAX) return -1; i = (*n)++; k[i] = key; }
    v[i] = val; return 0;
}
static uint64_t kv_get(int n, const uint64_t *k, const uint64_t *v, uint64_t key) {   /* the oracle's d.get(key, 0) */
    int i = kv_find(n, k, key); return i < 0 ? 0 : v[i];
}
static int sl_of(uint64_t head) {                    /* wrapper_emu: slists.setdefault(head, []); -1: no room */
    int i;
    for (i = 0; i < H.nsl; i++) if (H.sl_head[i] == head) return i;
    if (H.nsl == NSL_MAX) return -1;
    H.sl_head[H.nsl] = head; H.sl_n[H.nsl] = 0; return H.nsl++;
}
static int sl_put(int s, int idx, uint64_t e) {      /* entry idx of head s (bottom first), growing the stack */
    if (idx >= H.sl_cap[s]) {
        int cap = H.sl_cap[s] ? 2 * H.sl_cap[s] : 256; uint64_t *p;
        while (cap <= idx) cap *= 2;
        p = (uint64_t *)realloc(H.sl_e[s], sizeof *p * (size_t)cap); if (!p) return -1;
        H.sl_e[s] = p; H.sl_cap[s] = cap;
    }
    H.sl_e[s][idx] = e; if (idx >= H.sl_n[s]) H.sl_n[s] = idx + 1;
    return 0;
}
static int once_has(uint64_t a) { int i; for (i = 0; i < H.nonce; i++) if (H.once[i] == a) return 1; return 0; }
static void unhandled(const char *n) {               /* e2e_emu: self.unhandled[name] += 1 (n lives in the stub table) */
    int i;
    for (i = 0; i < H.nunh; i++) if (!strcmp(H.unh_name[i], n)) { H.unh_n[i]++; return; }
    if (H.nunh < NUNH_MAX) { H.unh_name[H.nunh] = n; H.unh_n[H.nunh++] = 1; }
}
static int cmp_name(const void *a, const void *b) { return strcmp((const char *)a, *(const char *const *)b); }
static int oracle_special(const char *n) {           /* the oracle singles this name out (lift/jn_oracle_imports.h) */
    return bsearch(n, JN_ORACLE_SPECIAL, JN_ORACLE_NSPECIAL, sizeof JN_ORACLE_SPECIAL[0], cmp_name) != NULL;
}
static int name_in(const char *n, const char *const *set) { for (; *set; set++) if (!strcmp(n, *set)) return 1; return 0; }

/* ---------------------------------------------------------------- the host objects and the imports (jp8_hostcall) */
/* ---------------------------------------------------------------- the editor's imports (wrapper_emu._imp / _gdip)
 * Answered EXACTLY as the oracle answers them, from the state it keeps on its Python side (H: screen, tick_ms,
 * gdip_imgs, dibs, skin). Plumbing: blank images of the skin's real geometry; nothing here is plugin logic. */
static uint64_t stack_arg(CPU *c, int k) { return gq(c->r[4] + 8 + 8 * (uint64_t)k); }    /* wrapper_emu.stack_arg */
static uint8_t gb(uint64_t a) { uint8_t v = 0; void *p = junoh_guest(a, 1); if (p) memcpy(&v, p, 1); return v; }
static int gd_find(uint64_t hd) { int i; for (i = 0; i < H.ngd; i++) if (H.gd[i].hd == hd) return i; return -1; }
static void gd_of(uint64_t hd, uint32_t *w, uint32_t *h, uint32_t *fmt) {   /* imgs.get(h, dict(w=64, h=64, fmt=0x26200A)) */
    int i = gd_find(hd);
    *w = i < 0 ? 64 : H.gd[i].w; *h = i < 0 ? 64 : H.gd[i].h; *fmt = i < 0 ? 0x26200Au : H.gd[i].fmt;
}
static uint64_t new_img(CPU *c, uint32_t w, uint32_t h, uint32_t fmt) {     /* _gdip's new_img: alloc_com(32), imgs[hnd] */
    uint64_t hd = alloc_com(32); int i = gd_find(hd);
    if (i < 0) { if (H.ngd >= NGD_MAX) { jp8_trap(c, 0, "too many GDI+ images"); return 0; } i = H.ngd++; }
    H.gd[i].hd = hd; H.gd[i].w = w; H.gd[i].h = h; H.gd[i].fmt = fmt;
    return hd;
}
static int gui_import(CPU *c, const char *n) {      /* 1: answered (rax set); 0: not one of these */
    uint64_t rcx = c->r[1], rdx = c->r[2], r8 = c->r[8], r9 = c->r[9];
    if (!strcmp(n, "GetTickCount")) { c->r[0] = H.tick_ms & 0xFFFFFFFFULL; return 1; }    /* getattr(self, 'tick_ms', 0) */
    if (!strcmp(n, "GetSystemMetrics")) {                                 /* self.screen.get(i, 0): 78 / 79 only */
        uint32_t i = (uint32_t)rcx;
        c->r[0] = i == 0x4E ? (uint64_t)(int64_t)H.scr_cx : i == 0x4F ? (uint64_t)(int64_t)H.scr_cy : 0; return 1;
    }
    if (!strcmp(n, "MultiByteToWideChar")) {     /* latin1 bytes -> UTF-16 units; n = -1: rstr (to the NUL, <= 1200) + NUL */
        uint64_t outp = stack_arg(c, 4); uint32_t outn = (uint32_t)stack_arg(c, 5), cnt = (uint32_t)r9, len, k;
        if (cnt == 0xFFFFFFFFu) { for (len = 0; len < 1200 && gb(r8 + len); len++) {} len++; }
        else len = cnt;
        if (outn == 0) { c->r[0] = len; return 1; }
        for (k = 0; k < len && k < outn; k++) { uint16_t w = (k < len - (cnt == 0xFFFFFFFFu)) ? gb(r8 + k) : 0; wmem(outp + 2 * (uint64_t)k, &w, 2); }
        c->r[0] = len < outn ? len : outn; return 1;
    }
    if (!strncmp(n, "Gdip", 4)) {                                      /* _gdip: GdiplusStartup and every Gdip* name */
        uint32_t w, h, fmt;
        if (!strcmp(n, "GdiplusStartup")) { wq(rcx, 1); c->r[0] = 0; return 1; }
        if (!strcmp(n, "GdipAlloc")) { c->r[0] = alloc_com(rcx > 16 ? rcx : 16); return 1; }    /* NOT e2e_emu's bump */
        if (!strcmp(n, "GdipCreateBitmapFromFile") || !strcmp(n, "GdipCreateBitmapFromFileICM")) {
            /* skin.get(base name, lower case; (16, 16)) -- rstr(rcx, wide): UTF-16 to the NUL. The plugin asks for its
             * Script.xml names (ASCII; the template asserts the skin's keys are): a non-ASCII unit matches no key */
            char nm[NSKIN_NAME + 1]; size_t k = 0, i; int j, bad = 0; uint16_t ch;
            for (i = 0; i < 600; i++) {
                ch = (uint16_t)(gb(rcx + 2 * i) | gb(rcx + 2 * i + 1) << 8);
                if (!ch) break;
                if (ch == '\\' || ch == '/') { k = 0; bad = 0; continue; }
                if (ch > 0x7F) bad = 1;
                if (k < NSKIN_NAME) nm[k] = (char)(ch >= 'A' && ch <= 'Z' ? ch + 32 : ch);
                k++;
            }
            w = 16; h = 16;
            if (!bad && k < NSKIN_NAME) {
                nm[k] = 0;
                for (j = 0; j < H.nskin; j++) if (!strcmp(H.skin[j].name, nm)) { w = H.skin[j].w; h = H.skin[j].h; break; }
            }
            wq(rdx, new_img(c, w, h, 0x26200Au)); c->r[0] = 0; return 1;
        }
        if (!strcmp(n, "GdipCreateBitmapFromHBITMAP")) { wq(r8, new_img(c, 64, 64, 0x26200Au)); c->r[0] = 0; return 1; }
        if (!strcmp(n, "GdipCreateBitmapFromScan0")) {
            wq(stack_arg(c, 5), new_img(c, (uint32_t)rcx, (uint32_t)rdx, (uint32_t)r9)); c->r[0] = 0; return 1;
        }
        if (!strcmp(n, "GdipCloneImage")) { gd_of(rcx, &w, &h, &fmt); wq(rdx, new_img(c, w, h, fmt)); c->r[0] = 0; return 1; }
        if (!strcmp(n, "GdipGetImageWidth") || !strcmp(n, "GdipGetImageHeight") || !strcmp(n, "GdipGetImagePixelFormat")) {
            uint32_t v; gd_of(rcx, &w, &h, &fmt); v = strstr(n, "Width") ? w : strstr(n, "Height") ? h : fmt;
            wmem(rdx, &v, 4); c->r[0] = 0; return 1;
        }
        if (!strcmp(n, "GdipGetImagePaletteSize")) { int32_t v = 8; wmem(rdx, &v, 4); c->r[0] = 0; return 1; }
        if (!strcmp(n, "GdipGetImagePalette")) { uint64_t z = 0; wmem(rdx, &z, 8); c->r[0] = 0; return 1; }
        if (!strcmp(n, "GdipBitmapLockBits")) {              /* bump(w h 4 + 16), zeroed; '<IIiIQQ' at stack argument 4 */
            uint8_t d[32]; uint64_t buf, data = stack_arg(c, 4); int32_t st_;
            gd_of(rcx, &w, &h, &fmt);
            buf = jp8_heap_alloc((uint64_t)w * h * 4 + 16);
            memset(d, 0, sizeof d); memcpy(d, &w, 4); memcpy(d + 4, &h, 4); st_ = (int32_t)(w * 4); memcpy(d + 8, &st_, 4);
            memcpy(d + 12, &fmt, 4); memcpy(d + 16, &buf, 8);
            wmem(data, d, 32); c->r[0] = 0; return 1;
        }
        if (!strcmp(n, "GdipGetImageGraphicsContext") || !strcmp(n, "GdipCreateFromHDC") || !strcmp(n, "GdipCreatePath") ||
            !strcmp(n, "GdipCreateSolidFill") || !strcmp(n, "GdipCloneBrush")) { wq(rdx, alloc_com(32)); c->r[0] = 0; return 1; }
        if (!strcmp(n, "GdipCreatePen1")) { wq(stack_arg(c, 3), alloc_com(32)); c->r[0] = 0; return 1; }   /* as the oracle */
        if (!strcmp(n, "GdipCreateLineBrushI")) { wq(stack_arg(c, 5), alloc_com(32)); c->r[0] = 0; return 1; }
        if (!strcmp(n, "GdipGetSmoothingMode")) { int32_t v = 0; wmem(rdx, &v, 4); c->r[0] = 0; return 1; }
        if (!strcmp(n, "GdipGetImageEncodersSize")) { uint32_t v = 0; wmem(rcx, &v, 4); wmem(rdx, &v, 4); c->r[0] = 0; return 1; }
        c->r[0] = 0; return 1;                                          /* every other Gdip*: Ok (0), nothing written */
    }
    if (!strcmp(n, "CreateDIBSection")) {                /* blank bits of the real geometry: bump, zeroed; hb by count */
        int32_t w_ = gi(rdx + 4), h_ = gi(rdx + 8); uint32_t bpp = ((uint32_t)gi(rdx + 12) >> 16) & 0xFFFFu, stride, size, ah;
        uint64_t bits;
        ah = (uint32_t)(h_ < 0 ? -h_ : h_); stride = ((uint32_t)(w_ < 0 ? -w_ : w_) * bpp + 31) / 32 * 4;
        size = stride * ah; if (size < 16) size = 16;
        if (H.ndib >= NDIB_MAX) { jp8_trap(c, 0, "too many DIB sections"); return 1; }
        bits = jp8_heap_alloc(size);
        H.dib[H.ndib].hb = 0xB0000 + 0x10 * (uint64_t)H.ndib; H.dib[H.ndib].bits = bits; H.dib[H.ndib].w = w_; H.dib[H.ndib].h = h_;
        H.dib[H.ndib].bpp = bpp; H.dib[H.ndib].stride = stride;
        if (r9) wq(r9, bits);
        c->r[0] = H.dib[H.ndib++].hb; return 1;
    }
    if (!strcmp(n, "GetObjectA") || !strcmp(n, "GetObjectW")) {
        int i; uint8_t bm[104]; int32_t v; uint32_t u; uint16_t hw;
        for (i = 0; i < H.ndib && H.dib[i].hb != rcx; i++) {}
        if (i == H.ndib) { c->r[0] = 0; return 1; }
        memset(bm, 0, sizeof bm);                                       /* '<iiiiHHIQ', then (>= 104) '<IiiHHIIiiII' + 12 + '<QI' */
        v = H.dib[i].w; memcpy(bm + 4, &v, 4); v = H.dib[i].h < 0 ? -H.dib[i].h : H.dib[i].h; memcpy(bm + 8, &v, 4);
        v = (int32_t)H.dib[i].stride; memcpy(bm + 12, &v, 4); hw = 1; memcpy(bm + 16, &hw, 2); hw = (uint16_t)H.dib[i].bpp; memcpy(bm + 18, &hw, 2);
        memcpy(bm + 24, &H.dib[i].bits, 8);
        if ((uint32_t)rdx >= 104) {
            u = 40; memcpy(bm + 32, &u, 4); v = H.dib[i].w; memcpy(bm + 36, &v, 4); v = H.dib[i].h; memcpy(bm + 40, &v, 4);
            hw = 1; memcpy(bm + 44, &hw, 2); hw = (uint16_t)H.dib[i].bpp; memcpy(bm + 46, &hw, 2);
            u = H.dib[i].stride * (uint32_t)(H.dib[i].h < 0 ? -H.dib[i].h : H.dib[i].h); memcpy(bm + 52, &u, 4);
            wmem(r8, bm, 96); c->r[0] = 104; return 1;                  /* bm[:104] of a 96-byte struct: 96 written */
        }
        wmem(r8, bm, 32); c->r[0] = 32; return 1;
    }
    if (!strcmp(n, "SelectObject")) { c->r[0] = 0x77770; return 1; }
    if (!strcmp(n, "DeleteObject") || !strcmp(n, "DeleteDC") || !strcmp(n, "ReleaseDC")) { c->r[0] = 1; return 1; }
    return 0;
}

void jp8_hostcall(CPU *c, uint64_t target) {
    const char *n = stub_name(target); uint64_t rcx = c->r[1], rdx = c->r[2], r8 = c->r[8], r9 = c->r[9];
    char msg[160];
    if (!n) { snprintf(msg, sizeof msg, "stub 0x%llx not in the template", (unsigned long long)target); jp8_trap(c, target, msg); return; }
    if (!strncmp(n, "COM:", 4)) {
        const char *kind = n + 4; const char *colon = strchr(kind, ':'); int slot = colon ? atoi(colon + 1) : -1;
        size_t kl = colon ? (size_t)(colon - kind) : 0;
        if (slot == 1 || slot == 2) { c->r[0] = 1; return; }                                  /* addRef / release */
        if (kl == 6 && !strncmp(kind, "events", 6)) {                                          /* IEventList */
            if (slot == 3) { c->r[0] = (uint64_t)H.nev; return; }
            if (slot == 4) { uint32_t i = (uint32_t)rdx; if ((int)i >= H.nev || i >= MAXEV) { c->r[0] = 1; return; } wmem(r8, H.evs[i], 48); c->r[0] = 0; return; }
            c->r[0] = 1; return;
        }
        if (kl == 8 && !strncmp(kind, "pchanges", 8)) {                                        /* IParameterChanges */
            if (slot == 3) { c->r[0] = (uint64_t)H.npq; return; }
            if (slot == 4) { uint32_t i = (uint32_t)rdx; c->r[0] = (int)i < H.npq ? H.pq[i] : 0; return; }
            c->r[0] = 0; return;
        }
        if (kl == 6 && !strncmp(kind, "pqueue", 6)) {                                          /* IParamValueQueue */
            int q = pq_index(rcx);
            if (q < 0) { jp8_trap(c, target, "a parameter queue the template does not carry"); return; }
            if (slot == 3) { c->r[0] = H.pq_id[q]; return; }
            if (slot == 4) { c->r[0] = (uint64_t)(q < H.npq ? H.pq_n[q] : 0); return; }
            if (slot == 5) {
                uint32_t i = (uint32_t)rdx; int32_t off; double v;
                if (q >= H.npq || (int)i >= H.pq_n[q]) { c->r[0] = 1; return; }
                off = H.pq_off[q][i]; v = H.pq_val[q][i]; wmem(r8, &off, 4); wmem(r9, &v, 8); c->r[0] = 0; return;
            }
            c->r[0] = 1; return;
        }
        if (kl == 6 && !strncmp(kind, "stream", 6)) {                                          /* IBStream */
            if (slot == 0) {                                   /* queryInterface(iid, obj): only IBStream -> this */
                void *p = junoh_guest(rdx, 16); uint64_t out = 0;
                if (p && !memcmp(p, IID_IBSTREAM, 16)) { out = rcx; wq(r8, out); c->r[0] = S_OK_; return; }
                wq(r8, 0); c->r[0] = E_NOINTERFACE_; return;
            }
            if (rcx != H.s_addr) { jp8_trap(c, target, "a stream this runtime did not make"); return; }
            if (slot == 3) {                                   /* read(buffer, numBytes, numBytesRead*) */
                int64_t want = (int64_t)(uint32_t)r8, avail = (int64_t)H.s_len - H.s_pos, k = want < avail ? want : avail; int32_t k32;
                if (H.s_pos < 0) { jp8_trap(c, target, "a stream read before its start"); return; }
                if (k < 0) k = 0;
                if (k) wmem(rdx, H.s_data + H.s_pos, (size_t)k);
                H.s_pos += k; k32 = (int32_t)k; if (r9) wmem(r9, &k32, 4);
                c->r[0] = S_OK_; return;
            }
            if (slot == 4) {                                   /* write(buffer, numBytes, numBytesWritten*) */
                size_t k = (uint32_t)r8, pos = H.s_pos < 0 ? 0 : (size_t)H.s_pos, need = pos + k; int32_t k32 = (int32_t)k;
                if (H.s_pos < 0) { jp8_trap(c, target, "a stream write before its start"); return; }
                if (need > H.s_cap) {
                    size_t cap = H.s_cap ? H.s_cap : 4096; unsigned char *d;
                    while (cap < need) cap *= 2;
                    d = (unsigned char *)realloc(H.s_data, cap); if (!d) { jp8_trap(c, target, "no memory for a stream"); return; }
                    H.s_data = d; H.s_cap = cap;
                }
                if (pos > H.s_len) memset(H.s_data + H.s_len, 0, pos - H.s_len);
                if (k) { void *src = junoh_guest(rdx, k); if (!src) { jp8_trap(c, target, "a stream write from unmapped memory"); return; } memcpy(H.s_data + pos, src, k); }
                H.s_pos += (int64_t)k; if ((size_t)H.s_pos > H.s_len) H.s_len = (size_t)H.s_pos;
                if (r9) wmem(r9, &k32, 4);
                c->r[0] = S_OK_; return;
            }
            if (slot == 5) {                                   /* seek(pos, mode, result*) */
                int64_t pos = (int64_t)rdx; int mode = (int)(r8 & 3);
                H.s_pos = (mode == 0 ? 0 : mode == 1 ? H.s_pos : (int64_t)H.s_len) + pos;
                if (r9) wmem(r9, &H.s_pos, 8);
                c->r[0] = S_OK_; return;
            }
            if (slot == 6) { wmem(rdx, &H.s_pos, 8); c->r[0] = S_OK_; return; }      /* tell(pos*) */
            c->r[0] = E_FAIL_; return;
        }
        if (kl == 7 && !strncmp(kind, "handler", 7)) {                                         /* IComponentHandler */
            if (slot == 4) record_edit((uint32_t)rdx, c->x[2].d[0]);     /* performEdit(id, ParamValue in xmm2) */
            if (slot >= 3) { c->r[0] = 0; return; }
        }
        snprintf(msg, sizeof msg, "host object method %s not served", n); jp8_trap(c, target, msg); return;
    }
    /* the imports, answered EXACTLY as the oracle answers them (tools/verify/e2e_emu.py under probes/b6/wrapper_emu.py):
     * wrapper_emu._imp's rules, then e2e_emu._imp's, in their order. A name the oracle SINGLES OUT that this glue does
     * not mirror TRAPS (lift/jn_oracle_imports.h, generated from the oracle's own source): the oracle does something the
     * glue does not. Only a name the oracle does not single out takes its defaults -- Create* / Open* a new handle,
     * Get* / Query* 0, anything else 0 counted as unhandled (junoh_unhandled; a gate compares it with the oracle's). */
    {
        static const char *const PTR[] = { "EncodePointer", "DecodePointer", "EncodeSystemPointer", "DecodeSystemPointer", NULL };
        static const char *const ONE[] = { "InitCommonControlsEx", "AcquireSRWLockExclusive", "ReleaseSRWLockExclusive",
            "AcquireSRWLockShared", "ReleaseSRWLockShared", "WakeAllConditionVariable", "WakeConditionVariable",
            "MakeSureDirectoryPathExists", "AllocateAndInitializeSid", "FlushInstructionCache", "LoadCursorA", "LoadCursorW",
            "FlsFree", NULL };
        static const char *const CLASS[] = { "RegisterClassExA", "RegisterClassExW", "RegisterClassA", "RegisterClassW", NULL };
        static const char *const ACL[] = { "SetEntriesInAclA", "SetEntriesInAclW", "SetNamedSecurityInfoA", "SetNamedSecurityInfoW", NULL };
        static const char *const E_ONE[] = { "HeapFree", "HeapDestroy", "DeleteCriticalSection", "EnterCriticalSection",
            "LeaveCriticalSection", NULL };
        static const char *const E_UNH[] = { "RaiseException", "RtlPcToFileHeader", "RtlUnwind", "RtlUnwindEx",
            "RtlCaptureContext", "RtlLookupFunctionEntry", "RtlVirtualUnwind", "_CxxThrowException", "terminate", "abort", NULL };
        int s;
        /* ---- wrapper_emu._imp */
        if (!strcmp(n, "RaiseException") && (uint32_t)rcx == 0xE06D7363u) { jp8_trap(c, target, "the plugin threw a C++ exception (RaiseException 0xE06D7363)"); return; }
        if (name_in(n, PTR)) { c->r[0] = rcx; return; }
        if (!strcmp(n, "IsProcessorFeaturePresent")) { c->r[0] = 1; return; }
        if (!strcmp(n, "IsDebuggerPresent")) { c->r[0] = 0; return; }
        if (gui_import(c, n)) return;                /* GetTickCount, GetSystemMetrics, MultiByteToWideChar, Gdip*, the DIBs */
        if (!strcmp(n, "FlsAlloc")) { c->r[0] = H.fls_ctr++; return; }
        if (!strcmp(n, "FlsSetValue")) { if (kv_set(&H.nfls, H.fls_k, H.fls_v, rcx, rdx)) { jp8_trap(c, target, "FLS table full"); return; } c->r[0] = 1; return; }
        if (!strcmp(n, "FlsGetValue")) { c->r[0] = kv_get(H.nfls, H.fls_k, H.fls_v, rcx); return; }
        if (!strcmp(n, "GetModuleHandleW") || !strcmp(n, "GetModuleHandleA")) { c->r[0] = IB; return; }
        if (!strncmp(n, "Initialize", 10) || name_in(n, ONE)) { c->r[0] = 1; return; }
        if (!strcmp(n, "InitOnceExecuteOnce")) {
            if (once_has(rcx)) { c->r[0] = 1; return; }
            jp8_trap(c, target, "InitOnceExecuteOnce first run after the template (the oracle runs the callback in place; not mirrored)"); return;
        }
        if (!strcmp(n, "GetProcAddress") && rdx < 0x10000) { c->r[0] = 0; return; }   /* by name it makes a stub: traps below */
        if (!strcmp(n, "GetLastError")) { c->r[0] = H.lasterr & 0xFFFFFFFFu; return; }
        if (!strcmp(n, "SetLastError")) { H.lasterr = rcx & 0xFFFFFFFFu; c->r[0] = 0; return; }
        if (name_in(n, CLASS)) { c->r[0] = 0xC001; return; }
        if (!strcmp(n, "InterlockedPushEntrySList")) {     /* entry->Next = the old top (in memory); push; return the old top */
            uint64_t old;
            if ((s = sl_of(rcx)) < 0) { jp8_trap(c, target, "SList table full"); return; }
            old = H.sl_n[s] ? H.sl_e[s][H.sl_n[s] - 1] : 0;
            wq(rdx, old);
            if (sl_put(s, H.sl_n[s], rdx)) { jp8_trap(c, target, "no memory for an SList"); return; }
            c->r[0] = old; return;
        }
        if (!strcmp(n, "InterlockedPopEntrySList")) {      /* the oracle pops its list; memory is not read */
            if ((s = sl_of(rcx)) < 0) { jp8_trap(c, target, "SList table full"); return; }
            c->r[0] = H.sl_n[s] ? H.sl_e[s][--H.sl_n[s]] : 0; return;
        }
        if (!strcmp(n, "InterlockedFlushSList")) {
            if ((s = sl_of(rcx)) < 0) { jp8_trap(c, target, "SList table full"); return; }
            c->r[0] = H.sl_n[s] ? H.sl_e[s][H.sl_n[s] - 1] : 0; H.sl_n[s] = 0; return;
        }
        if (name_in(n, ACL)) { c->r[0] = 0; return; }
        /* ---- e2e_emu._imp (wrapper_emu's super) */
        if (!strcmp(n, "GetProcessHeap")) { c->r[0] = H.fake_heap ? H.fake_heap : 0x4242000000ULL; return; }
        if (!strcmp(n, "HeapAlloc")) { c->r[0] = jp8_heap_alloc(r8); return; }   /* bump(dwBytes); fresh memory is zero */
        if (!strcmp(n, "HeapReAlloc")) {                   /* bump(dwBytes), then copy min(dwBytes, 0x1000) of the old block */
            uint64_t p = jp8_heap_alloc(r9); size_t k = r9 < 0x1000 ? (size_t)r9 : 0x1000;
            if (r8 && k) { void *src = junoh_guest(r8, k), *dst = junoh_guest(p, k); if (src && dst) memmove(dst, src, k); }
            c->r[0] = p; return;
        }
        if (name_in(n, E_ONE)) { c->r[0] = 1; return; }    /* HeapFree frees nothing: the oracle's heap is a pure bump */
        if (!strcmp(n, "HeapSize")) { c->r[0] = 0x1000; return; }
        if (!strcmp(n, "VirtualAlloc") || !strcmp(n, "VirtualAllocEx")) { c->r[0] = jp8_heap_alloc(rdx ? rdx : 0x1000); return; }
        /* (e2e_emu's rule also names GdipAlloc: shadowed in the oracle by wrapper_emu's Gdip* rule -- answered above) */
        if (!strcmp(n, "CoTaskMemAlloc") || !strcmp(n, "GlobalAlloc") || !strcmp(n, "SysAllocString")) { c->r[0] = jp8_heap_alloc(rcx ? rcx : 0x100); return; }
        if (!strcmp(n, "TlsAlloc")) { c->r[0] = H.tls_ctr++; return; }
        if (!strcmp(n, "TlsSetValue")) { if (kv_set(&H.ntls, H.tls_k, H.tls_v, rcx, rdx)) { jp8_trap(c, target, "TLS table full"); return; } c->r[0] = 1; return; }
        if (!strcmp(n, "TlsGetValue")) { c->r[0] = kv_get(H.ntls, H.tls_k, H.tls_v, rcx); return; }
        if (!strcmp(n, "GetCurrentThreadId") || !strcmp(n, "GetCurrentProcessId")) { c->r[0] = 0x1000; return; }
        /* ---- a name the oracle singles out that is not mirrored above: stop (never answer it with a default) */
        if (oracle_special(n) && !name_in(n, E_UNH)) {
            snprintf(msg, sizeof msg, "the oracle answers import %s specially; not mirrored here (from rva 0x%llx)", n,
                     (unsigned long long)(gq(c->r[4]) - IB));
            jp8_trap(c, target, msg); return;
        }
        /* ---- e2e_emu._imp's tail: Create* / Open*, its RaiseException group, Get* / Query*, then the default */
        if (!strncmp(n, "Create", 6) || !strncmp(n, "Open", 4)) { c->r[0] = jp8_hc_next(); return; }
        if (name_in(n, E_UNH)) { unhandled(n); c->r[0] = 0; return; }
        if (!strncmp(n, "Get", 3) || !strncmp(n, "Query", 5)) { c->r[0] = 0; return; }
        unhandled(n); c->r[0] = 0; return;
    }
}
int jp8_thunk(CPU *c, uint64_t target) { (void)c; (void)target; return 0; }   /* no ATL run-time thunk on the host path (yet) */

/* ---------------------------------------------------------------- the render transport (--replace 0x3C7400)
 * The plugin's engine render (CWaveGen vt+56) drives its voice workers through thread events this runtime does not
 * run. The oracle (host_process_emu._serve) stops at its entry and composes the render over the plugin's OWN voice
 * (VOICE_WRAP, one sample of one voice) and master (MASTER_WRAP, one sample of the mix) -- the DSP is the plugin's,
 * lifted. This is that composition in C, the twin of jp8_host.c's thread transport. The sub-calls run on a COPY of
 * the process() CPU, on a stack 1 MB below it, so the in-flight process() frame is preserved; a trap inside falls
 * through to the outer jp8_call_x and fails the process call. */
static void rcall(CPU *nc, uint64_t top, uint64_t rva, uint64_t rcx, uint64_t rdx, uint64_t r8) {
    nc->r[1] = rcx; nc->r[2] = rdx; nc->r[8] = r8; nc->r[9] = 0;
    nc->r[4] = top - 8;                         /* rsp at a callee's entry: 16-aligned top, less the pushed return */
    JP8_FPENV(nc);
    jp8_run(nc, rva);
}
void jp8_hook(CPU *c, uint64_t rva) {
    if (rva == ENGINE_RENDER) {
        CPU nc; uint64_t top, a4, mainb[8], subb[8], offL, offR, A3, A2, LR, p; int32_t nch, n, nv; int v, i, k;
        if (c->r[1] != H.HOST) { jp8_trap(c, rva, "engine render on an engine this runtime did not build"); return; }
        a4 = c->r[9]; nch = gi(c->r[4] + 0x28); n = gi(c->r[4] + 0x30);
        if (nch != 2) { jp8_trap(c, rva, "engine render with a channel count other than 2"); return; }
        H.njobs++;
        nv = gi(H.HOST + (int)HOST_NVOICE);
        memcpy(&nc, c, sizeof nc);
        top = (c->r[4] - 0x100000ULL) & ~0xFULL;
        for (v = 0; v < 8; v++) {               /* the assigner voice-count sync, and (n>0) its sample counter += n */
            rcall(&nc, top, ASG_GET_COUNT, H.assign[v], 0, 0);
            if ((uint32_t)nc.r[0] != (uint32_t)nv) rcall(&nc, top, ASG_SET_COUNT, H.assign[v], (uint32_t)nv, 0);
            if (n > 0) wq(H.assign[v] + ASG_COUNTER, gq(H.assign[v] + ASG_COUNTER) + (uint64_t)n);
        }
        if (n <= 0) { JP8_FPENV(c); c->r[0] = 0; return; }    /* the flush / preamble (no samples, host_process_emu) */
        p = BUF_BASE;                           /* per-voice main[n], sub[n]; then master L, R (the oracle's layout) */
        for (v = 0; v < 8; v++) { mainb[v] = p; p += 4 * (uint64_t)n; subb[v] = p; p += 4 * (uint64_t)n; }
        offL = p; p += 4 * (uint64_t)n; offR = p; p += 4 * (uint64_t)n;
        A3 = BUF_BASE + 0x1C0000; A2 = A3 + 16; LR = A2 + 128;   /* the render's pointer scratch (above the audio) */
        for (v = 0; v < 8; v++) {               /* voices: a unit at or above the voice count outputs zeros */
            if (v >= nv) {
                void *m = junoh_guest(mainb[v], 4 * (size_t)n), *s = junoh_guest(subb[v], 4 * (size_t)n);
                if (m) memset(m, 0, 4 * (size_t)n); if (s) memset(s, 0, 4 * (size_t)n);
                continue;
            }
            for (i = 0; i < n; i++) {
                wq(A3, mainb[v] + 4 * (uint64_t)i); wq(A3 + 8, subb[v] + 4 * (uint64_t)i);
                rcall(&nc, top, VOICE_WRAP, H.state[v], (uint64_t)(uint32_t)v, A3);   /* one sample of voice v */
            }
        }
        for (i = 0; i < n; i++) {               /* master: one sample of the mix over the 16 voice buffers */
            for (k = 0; k < 8; k++) { wq(A2 + 16 * (uint64_t)k, mainb[k] + 4 * (uint64_t)i); wq(A2 + 16 * (uint64_t)k + 8, subb[k] + 4 * (uint64_t)i); }
            wq(LR, offL + 4 * (uint64_t)i); wq(LR + 8, offR + 4 * (uint64_t)i);
            rcall(&nc, top, MASTER_WRAP, H.state[8], A2, LR);
        }
        {   /* the render writes L / R to the buffers the plugin passed (a4 -> {outL, outR}) */
            uint64_t outL = gq(a4), outR = gq(a4 + 8);
            void *dl = junoh_guest(outL, 4 * (size_t)n), *sl = junoh_guest(offL, 4 * (size_t)n);
            void *dr = junoh_guest(outR, 4 * (size_t)n), *sr = junoh_guest(offR, 4 * (size_t)n);
            if (dl && sl) memcpy(dl, sl, 4 * (size_t)n);
            if (dr && sr) memcpy(dr, sr, 4 * (size_t)n);
        }
        JP8_FPENV(c); c->r[0] = 0;               /* the render's MXCSR restored; the callers ignore the return value */
        return;
    }
    if (rva == WINDOW_FIT) {                     /* a panel window lays itself out: the oracle's attach_editor hook (set
                                                    at the first attach) records windows[(w, h)] = this; nothing written */
        int32_t rc_[4]; int i; void *p;
        if (!H.ed_on) return;
        p = junoh_guest(c->r[1] + 0x18, 16);
        if (!p) { jp8_trap(c, rva, "a window's rectangle is not mapped"); return; }
        memcpy(rc_, p, 16);
        for (i = 0; i < H.nwin && !(H.win[i].w == rc_[2] - rc_[0] && H.win[i].h == rc_[3] - rc_[1]); i++) {}
        if (i == H.nwin) { if (H.nwin >= NWIN_MAX) { jp8_trap(c, rva, "too many windows"); return; } H.nwin++; }
        H.win[i].w = rc_[2] - rc_[0]; H.win[i].h = rc_[3] - rc_[1]; H.win[i].win = c->r[1];
        return;
    }
    { char m[64]; snprintf(m, sizeof m, "a hook this runtime does not know (rva 0x%llx)", (unsigned long long)rva); jp8_trap(c, rva, m); }
}

/* ---------------------------------------------------------------- calls, as the oracle's call() makes them */
static int call(uint64_t fn, uint64_t rcx, uint64_t rdx, uint64_t r8, uint64_t r9) {
    CPU *c = &H.cpu;
    c->r[4] = H.rsp; wq(H.rsp - 8, H.ret);
    c->r[1] = rcx; c->r[2] = rdx; c->r[8] = r8; c->r[9] = r9;
    if (jp8_call_x(c, fn - IB)) {
        snprintf(H.msg, sizeof H.msg, "%s (call rva 0x%llx)", jp8_last_trap(), (unsigned long long)(fn - IB));
        if (getenv("JN_DEBUG")) {                 /* the image return addresses on the stack at the trap: the call chain */
            int k; fprintf(stderr, "jn: %s; stack image addrs:", H.msg);
            for (k = 0; k < 220; k++) { uint64_t v = gq(c->r[4] + 8 * (uint64_t)k); if (v >= IB && v < IB + 0xd75000) fprintf(stderr, " +%x:0x%llx", 8 * k, (unsigned long long)(v - IB)); }
            fprintf(stderr, "\n");
        }
        H.st = 2; return -1;
    }
    return 0;
}
static int vcall(uint64_t obj, int slot, uint64_t a1, uint64_t a2, uint64_t a3, uint32_t *hr) {
    if (call(gq(gq(obj) + 8 * (uint64_t)slot), obj, a1, a2, a3)) return JUNOH_E_TRAP;
    if (hr) *hr = (uint32_t)H.cpu.r[0];
    return JUNOH_OK;
}
static int live(void) { return H.st == 1 ? JUNOH_OK : H.st == 2 ? JUNOH_E_TRAP : err(JUNOH_E_STATE, "not initialized"); }

/* ---------------------------------------------------------------- the template (JNH1, tools/lift/jn_host_ref.py) */
static int load(const unsigned char *b, size_t len) {
    size_t p = 12; uint32_t nreg, r, k, nf, ns;
    uint64_t heap_ptr = 0, heap_lim = 0, hc = 0x9000;
    if (len < 16 || memcmp(b, "JNH1", 4) || le32(b + 4) != 1) return err(JUNOH_E_TEMPLATE, "template: not JNH1 v1");
    if (crc32_of(b, len - 4) != le32(b + len - 4)) return err(JUNOH_E_TEMPLATE, "template: crc32 mismatch");
    nreg = le32(b + 8);
    if (nreg > NREG_MAX) return err(JUNOH_E_TEMPLATE, "template: regions");
    for (r = 0; r < nreg; r++) {
        uint64_t base, size; uint32_t nruns; unsigned char *h;
        if (p + 20 > len - 4) return err(JUNOH_E_TEMPLATE, "template: truncated region");
        base = le64(b + p); size = le64(b + p + 8); nruns = le32(b + p + 16); p += 20;
        if (jp8_map(base, size)) return err(JUNOH_E_TEMPLATE, "template: a region cannot be mapped");
        H.rbase[r] = base; H.rsize[r] = size;
        h = (unsigned char *)junoh_guest(base, (size_t)size); if (!h) return err(JUNOH_E_TEMPLATE, "template: region not reachable");
        for (k = 0; k < nruns; k++) {
            uint32_t off, ln;
            if (p + 8 > len - 4) return err(JUNOH_E_TEMPLATE, "template: truncated run");
            off = le32(b + p); ln = le32(b + p + 4); p += 8;
            if ((uint64_t)off + ln > size || p + ln > len - 4) return err(JUNOH_E_TEMPLATE, "template: run outside its region");
            memcpy(h + off, b + p, ln); p += ln;
        }
    }
    H.nreg = (int)nreg;
    if (p + 4 > len - 4) return err(JUNOH_E_TEMPLATE, "template: no facts");
    nf = le32(b + p); p += 4;
    for (k = 0; k < nf; k++) {
        char key[25]; uint64_t v;
        if (p + 32 > len - 4) return err(JUNOH_E_TEMPLATE, "template: truncated facts");
        memcpy(key, b + p, 24); key[24] = 0; v = le64(b + p + 24); p += 32;
#define KV(name, dst) else if (!strcmp(key, name)) dst = v
        if (0) {}
        KV("heap_ptr", heap_ptr); KV("heap_limit", heap_lim); KV("hc", hc); KV("mxcsr", H.mx0); KV("rsp", H.rsp);
        KV("ret", H.ret); KV("audio", H.audio); KV("comp", H.comp); KV("core", H.core); KV("ctrl", H.ctrl);
        KV("process_fn", H.process_fn); KV("patch_fn", H.patch_fn); KV("com_next", H.com_next);
        KV("vt_events", H.vt_events); KV("vt_pchanges", H.vt_pchanges); KV("vt_pqueue", H.vt_pqueue);
        KV("vt_stream", H.vt_stream); KV("fake_heap", H.fake_heap); KV("lasterr", H.lasterr); KV("eflags", H.eflags);
        KV("tls_ctr", H.tls_ctr); KV("fls_ctr", H.fls_ctr);
        /* the oracle's Python-side state at the cut (jn_host_ref.py): tls:<key>, fls:<key>, once:<i>, sl:<head>:<i> */
        else if (!strncmp(key, "tls:", 4)) { if (kv_set(&H.ntls, H.tls_k, H.tls_v, strtoull(key + 4, NULL, 10), v)) return err(JUNOH_E_TEMPLATE, "template: TLS table full"); }
        else if (!strncmp(key, "fls:", 4)) { if (kv_set(&H.nfls, H.fls_k, H.fls_v, strtoull(key + 4, NULL, 10), v)) return err(JUNOH_E_TEMPLATE, "template: FLS table full"); }
        else if (!strncmp(key, "once:", 5)) { if (H.nonce == NKV_MAX) return err(JUNOH_E_TEMPLATE, "template: once table full"); H.once[H.nonce++] = v; }
        else if (!strncmp(key, "sl:", 3)) {
            char *e; uint64_t head = strtoull(key + 3, &e, 10); long idx = (*e == ':') ? strtol(e + 1, NULL, 10) : -1; int s_;
            if (idx < 0 || (s_ = sl_of(head)) < 0 || sl_put(s_, (int)idx, v)) return err(JUNOH_E_TEMPLATE, "template: an SList entry");
        }
        /* the editor imports' state at the cut: GDI+ images gi/gs/gf:<i>, DIB sections dh/dw/dp/db:<i>, skin sk:<i> + sn:<i>:<k> */
        else if (key[0] == 'g' && (key[1] == 'i' || key[1] == 's' || key[1] == 'f') && key[2] == ':') {
            long i_ = strtol(key + 3, NULL, 10);
            if (i_ < 0 || i_ >= NGD_MAX) return err(JUNOH_E_TEMPLATE, "template: a GDI+ image index");
            if (key[1] == 'i') H.gd[i_].hd = v;
            else if (key[1] == 's') { H.gd[i_].w = (uint32_t)(v >> 32); H.gd[i_].h = (uint32_t)v; }
            else H.gd[i_].fmt = (uint32_t)v;
            if (i_ + 1 > H.ngd) H.ngd = (int)i_ + 1;
        }
        else if (key[0] == 'd' && (key[1] == 'h' || key[1] == 'w' || key[1] == 'p' || key[1] == 'b') && key[2] == ':') {
            long i_ = strtol(key + 3, NULL, 10);
            if (i_ < 0 || i_ >= NDIB_MAX) return err(JUNOH_E_TEMPLATE, "template: a DIB section index");
            if (key[1] == 'h') H.dib[i_].hb = v;
            else if (key[1] == 'w') { H.dib[i_].w = (int32_t)(uint32_t)(v >> 32); H.dib[i_].h = (int32_t)(uint32_t)v; }
            else if (key[1] == 'p') { H.dib[i_].bpp = (uint32_t)(v >> 32); H.dib[i_].stride = (uint32_t)v; }
            else H.dib[i_].bits = v;
            if (i_ + 1 > H.ndib) H.ndib = (int)i_ + 1;
        }
        else if (key[0] == 's' && (key[1] == 'k' || key[1] == 'n') && key[2] == ':') {
            char *e; long i_ = strtol(key + 3, &e, 10);
            if (i_ < 0 || i_ >= NSKIN_MAX) return err(JUNOH_E_TEMPLATE, "template: a skin index");
            if (key[1] == 'k') { H.skin[i_].w = (uint32_t)(v >> 32); H.skin[i_].h = (uint32_t)v; }
            else {                                          /* 8 bytes of the name, little endian, at chunk k */
                long k_ = (*e == ':') ? strtol(e + 1, NULL, 10) : -1; int j;
                if (k_ < 0 || 8 * k_ + 8 >= NSKIN_NAME) return err(JUNOH_E_TEMPLATE, "template: a skin name");
                for (j = 0; j < 8; j++) H.skin[i_].name[8 * k_ + j] = (char)(v >> (8 * j));
            }
            if (i_ + 1 > H.nskin) H.nskin = (int)i_ + 1;
        }
        else if (key[0] == 'r' && key[1] >= '0' && key[1] <= '9') { int r_ = atoi(key + 1); if (r_ >= 0 && r_ < 16) H.reg[r_] = v; }
        else if (key[0] == 'x' && key[1] >= '0' && key[1] <= '9') {
            int r_ = atoi(key + 1); const char *t = strstr(key, "hi"); if (r_ >= 0 && r_ < 16) H.xreg[r_][t ? 1 : 0] = v;
        }
#undef KV
    }
    if (!H.audio || !H.comp || !H.core || !H.ctrl || !H.process_fn || !H.patch_fn || !H.vt_events || !H.vt_pchanges || !H.vt_pqueue || !H.vt_stream)
        return err(JUNOH_E_TEMPLATE, "template: a fact is missing");
    for (k = 0; k < (uint32_t)H.ngd; k++) if (!H.gd[k].hd) return err(JUNOH_E_TEMPLATE, "template: a GDI+ image is missing");
    for (k = 0; k < (uint32_t)H.ndib; k++)            /* the oracle's handles: 0xB0000 + 0x10 * (the count before it) */
        if (H.dib[k].hb != 0xB0000 + 0x10 * (uint64_t)k) return err(JUNOH_E_TEMPLATE, "template: a DIB section handle");
    for (k = 0; k < (uint32_t)H.nskin; k++) if (!H.skin[k].name[0]) return err(JUNOH_E_TEMPLATE, "template: a skin name is missing");
    jp8_heap_set(heap_ptr, heap_lim); jp8_hc_set(hc);
    if (p + 4 > len - 4) return err(JUNOH_E_TEMPLATE, "template: no stubs");
    ns = le32(b + p); p += 4;
    if (ns > NSTUB_MAX) return err(JUNOH_E_TEMPLATE, "template: too many stubs");
    for (k = 0; k < ns; k++) {
        uint32_t nl;
        if (p + 12 > len - 4) return err(JUNOH_E_TEMPLATE, "template: truncated stub");
        H.stub[k].addr = le64(b + p); nl = le32(b + p + 8); p += 12;
        if (nl >= sizeof H.stub[k].name || p + nl > len - 4) return err(JUNOH_E_TEMPLATE, "template: stub name");
        memcpy(H.stub[k].name, b + p, nl); H.stub[k].name[nl] = 0; p += nl;
        if (k && H.stub[k].addr <= H.stub[k - 1].addr) return err(JUNOH_E_TEMPLATE, "template: stubs not sorted");
    }
    H.nstub = (int)ns;
    if (p != len - 4) return err(JUNOH_E_TEMPLATE, "template: trailing bytes");
    return JUNOH_OK;
}

/* ---------------------------------------------------------------- the host setup (host_process_emu.setup) */
static int setup_processing(double rate) {      /* ProcessSetup {0, 0, max, rate}: IAudioProcessor slot 7 */
    uint8_t b[24]; int32_t v[3]; uint64_t setup = alloc_com(24); uint32_t hr; int rc;
    v[0] = 0; v[1] = 0; v[2] = (int32_t)H.maxblock;
    memset(b, 0, sizeof b); memcpy(b, v, 12); memcpy(b + 16, &rate, 8); wmem(setup, b, 24);
    if ((rc = vcall(H.audio, 7, setup, 0, 0, &hr))) return rc;
    if (hr) return err(JUNOH_E_STATE, "setupProcessing returned an error");
    H.rate = rate;
    return JUNOH_OK;
}
static int set_active(int on) {                 /* IComponent::setActive: slot 11 */
    uint32_t hr; int rc = vcall(H.comp, 11, on ? 1 : 0, 0, 0, &hr);
    if (rc) return rc;
    return hr ? err(JUNOH_E_STATE, "setActive returned an error") : JUNOH_OK;
}

int junoh_init(const void *tmpl, size_t len, double rate, int max_block) {
    int rc, i;
    H.st = 0; H.msg[0] = 0; H.nedit = 0; H.njobs = 0; H.s_addr = 0; H.s_len = 0; H.s_pos = 0; H.nev = 0; H.npq = 0;
    /* the oracle's Python-side state starts as the oracle's constructors start it (e2e_emu tls_ctr 1, wrapper_emu
     * fls_ctr 1); the template's facts then set it to its value at the cut */
    H.ntls = 0; H.nfls = 0; H.nonce = 0; H.nunh = 0; H.tls_ctr = 1; H.fls_ctr = 1;
    for (i = 0; i < H.nsl; i++) H.sl_n[i] = 0;
    H.nsl = 0;
    if (!tmpl) return err(JUNOH_E_ARG, "no template");
    if (max_block <= 0 || !(rate > 0.0)) return err(JUNOH_E_ARG, "rate or block size");
    if ((rc = load((const unsigned char *)tmpl, len)) != JUNOH_OK) return rc;
    jp8_heap_reuse(0);                          /* the JUNO oracle (e2e_emu._alloc, tools/verify/e2e_emu.py) is a PURE
                                                 * BUMP: the plugin's own allocator (0x67522C, --alloc) and every
                                                 * HeapAlloc / HeapFree / free is a bump that NEVER reuses a freed block,
                                                 * so the host matches it with reuse OFF. (The init / process gates
                                                 * matched with it ON only because their drive frees nothing; the patch
                                                 * browser frees the old patch, and reuse would then put the new blocks
                                                 * at lower addresses than the oracle's bump -- the heap end-state
                                                 * diverges. The JP8 oracle reused; the JUNO's does not.) */
    memset(&H.cpu, 0, sizeof H.cpu); H.cpu.mxcsr = (uint32_t)H.mx0;
    for (i = 0; i < 16; i++) { H.cpu.r[i] = H.reg[i]; H.cpu.x[i].q[0] = H.xreg[i][0]; H.cpu.x[i].q[1] = H.xreg[i][1]; }
    H.cpu.cf = (int)(H.eflags & 1); H.cpu.pf = (int)((H.eflags >> 2) & 1); H.cpu.zf = (int)((H.eflags >> 6) & 1);
    H.cpu.sf = (int)((H.eflags >> 7) & 1); H.cpu.of = (int)((H.eflags >> 11) & 1);
    H.st = 1;
    /* host_process_emu.setup: setupProcessing, setActive(1), then the blocks' host objects in its order */
    H.maxblock = (uint64_t)max_block;
    if ((rc = setup_processing(rate)) || (rc = set_active(1))) return rc;
    H.HOST = gq(H.core + 272);           /* the engine the plugin built; its per-unit objects (host_process_emu.setup) */
    for (i = 0; i < 9; i++) { H.state[i] = gq(H.HOST + 80 + 64 * (uint64_t)i); H.assign[i] = gq(H.HOST + 104 + 64 * (uint64_t)i); }
    H.bufl = alloc_com(4 * H.maxblock); H.bufr = alloc_com(4 * H.maxblock);
    {
        uint64_t chans = alloc_com(16); uint8_t bus[24]; int32_t two = 2;
        wq(chans, H.bufl); wq(chans + 8, H.bufr);
        H.bus = alloc_com(24); memset(bus, 0, sizeof bus); memcpy(bus, &two, 4); memcpy(bus + 16, &chans, 8); wmem(H.bus, bus, 24);
    }
    H.ctx = alloc_com(160); H.pd = alloc_com(96);
    H.ev = new_obj(H.vt_events); H.pc = new_obj(H.vt_pchanges);
    for (i = 0; i < NPQ; i++) H.pq[i] = 0;      /* the reusable parameter queues are created lazily, as the oracle's */
    return JUNOH_OK;
}

int junoh_set_active(int on) { int rc = live(); return rc ? rc : set_active(on); }
int junoh_set_rate(double rate) {
    int rc = live();
    if (rc) return rc;
    if (!(rate > 0.0)) return err(JUNOH_E_ARG, "rate");
    if ((rc = set_active(0)) || (rc = setup_processing(rate)) || (rc = set_active(1))) return rc;
    return JUNOH_OK;
}

/* ---------------------------------------------------------------- patch load (wrapper_emu.load_patch) */
int junoh_load_patch(const void *rec, size_t n) {
    uint64_t data, vec; int rc = live();
    if (rc) return rc;
    data = alloc_com(n + 16); wmem(data, rec, n);
    vec = alloc_com(24); wq(vec, data); wq(vec + 8, data + n); wq(vec + 16, data + n);
    return call(H.patch_fn, vec, gq(H.comp + 280 + 8), 0, 0) ? JUNOH_E_TRAP : JUNOH_OK;
}

/* ---------------------------------------------------------------- state (wrapper_emu.get_state / set_state) */
static uint64_t new_stream(const void *data, size_t n) {   /* a fresh stream object each call, as the oracle makes it */
    uint64_t st = new_obj(H.vt_stream);
    H.s_addr = st; H.s_pos = 0; H.s_len = 0;
    if (n > H.s_cap) { unsigned char *d = (unsigned char *)realloc(H.s_data, n); if (!d) return 0; H.s_data = d; H.s_cap = n; }
    if (n && data) memcpy(H.s_data, data, n);
    H.s_len = n;
    return st;
}
int junoh_get_state(void *buf, size_t cap, size_t *n) {
    uint32_t hr; int rc = live(); uint64_t st;
    if (rc) return rc;
    st = new_stream(NULL, 0); if (!st) return err(JUNOH_E_ARG, "no memory");
    if ((rc = vcall(H.comp, 13, st, 0, 0, &hr))) return rc;
    if (hr) return err(JUNOH_E_STATE, "getState returned an error");
    if (n) *n = H.s_len;
    if (buf && cap) memcpy(buf, H.s_data, H.s_len < cap ? H.s_len : cap);
    return JUNOH_OK;
}
int junoh_set_state(const void *data, size_t n, uint32_t *result) {
    uint32_t hr; int rc = live(); uint64_t st;
    if (rc) return rc;
    if (n && !data) return err(JUNOH_E_ARG, "no state");
    st = new_stream(data, n); if (!st && n) return err(JUNOH_E_ARG, "no memory");
    if ((rc = vcall(H.comp, 12, st, 0, 0, &hr))) return rc;
    if (result) *result = hr;
    return JUNOH_OK;
}

/* ---------------------------------------------------------------- the UI timer, MIDI learn, the editor's set */
int junoh_ui_tick(void) { int rc = live(); return rc ? rc : (call(IB + UITICK, H.core, 0, 0, 0) ? JUNOH_E_TRAP : JUNOH_OK); }
static int rec_count(void) { return (int)((gq(H.core + 32) - gq(H.core + 24)) / 24); }
static int cc_record(uint32_t id) {             /* the record index whose id matches (the last one, as the oracle's) */
    int i, nr = rec_count(), r = -1;
    for (i = 0; i < nr; i++) { if (call(IB + REC_ID, H.core + 24, (uint64_t)i, 0, 0)) return -2; if ((uint32_t)H.cpu.r[0] == id) r = i; }
    return r;
}
int junoh_cc_learn(uint32_t id) {
    int rc = live(), k;
    if (rc) return rc;
    k = cc_record(id); if (k == -2) return JUNOH_E_TRAP;
    return call(IB + CC_LEARN, H.core + 24, k < 0 ? 0xFFFFFFFFULL : (uint64_t)k, 0, 0) ? JUNOH_E_TRAP : JUNOH_OK;
}
int junoh_cc_forget(uint32_t id) {
    int rc = live(), k;
    if (rc) return rc;
    k = cc_record(id); if (k == -2) return JUNOH_E_TRAP;
    if (k < 0) return JUNOH_OK;
    return call(IB + CC_FORGET, H.core + 24, (uint64_t)k, 0, 0) ? JUNOH_E_TRAP : JUNOH_OK;
}
int junoh_rec_id(int index, uint32_t *id, uint64_t *obj) {
    int rc = live();
    if (rc) return rc;
    if (index < 0 || index >= rec_count()) return err(JUNOH_E_ARG, "record index out of range");
    if (call(IB + REC_ID, H.core + 24, (uint64_t)index, 0, 0)) return JUNOH_E_TRAP;
    if (id) *id = (uint32_t)H.cpu.r[0];
    if (obj) *obj = gq(gq(H.core + 24) + 24 * (uint64_t)index);
    return JUNOH_OK;
}
int junoh_model_set(uint64_t obj, uint32_t value) {
    int rc = live(); uint64_t model;
    if (rc) return rc;
    model = gq(gq(H.core + 8));
    return call(IB + MODEL_SET, model, obj, (uint64_t)value, 1) ? JUNOH_E_TRAP : JUNOH_OK;
}
int junoh_commit(void) {         /* the panel's commit: rva 0x285320, 0x2853C0, 0x283120 on the model (editor_gate TRIO) */
    static const uint64_t trio[3] = { JN_RVA_COMMIT0, JN_RVA_COMMIT1, JN_RVA_COMMIT2 };
    int rc = live(), i; uint64_t model;
    if (rc) return rc;
    model = gq(gq(H.core + 8));
    for (i = 0; i < 3; i++) if (call(IB + trio[i], model, 0, 0, 0)) return JUNOH_E_TRAP;
    return JUNOH_OK;
}
/* ---------------------------------------------------------------- the editor (host_process_emu.attach_editor) */
int junoh_screen(int32_t cx, int32_t cy) {      /* the machine's virtual screen changes: self.screen = {78: cx, 79: cy} */
    int rc = live(); if (rc) return rc;
    H.scr_cx = cx; H.scr_cy = cy; return JUNOH_OK;
}
int junoh_attach_editor(int32_t cx, int32_t cy, uint64_t *view) {   /* attach_editor(cx, cy), the oracle's steps in order */
    uint64_t name, t, v; int rc = live(); if (rc) return rc;
    H.scr_cx = cx; H.scr_cy = cy;
    H.ed_on = 1;                                 /* its window-fit hook, installed at the first attach, stays */
    name = alloc_com(16); t = alloc_com(16);
    wmem(name, "editor", 7); wmem(t, "HWND", 5);
    if (call(gq(gq(H.ctrl) + 8 * 17), H.ctrl, name, 0, 0)) return JUNOH_E_TRAP;     /* IEditController::createView */
    v = H.cpu.r[0];
    if (!v) return err(JUNOH_E_STATE, "createView(\"editor\") gave no view");
    if (call(gq(gq(v) + 8 * 4), v, 0x10010, t, 0)) return JUNOH_E_TRAP;               /* IPlugView::attached */
    if (view) *view = v;
    return JUNOH_OK;
}
int junoh_window_zoom(int32_t w, int32_t h, int32_t *zoom) {   /* window_conv: the w x h window's own zoom getter */
    int i, rc = live(); if (rc) return rc;
    for (i = 0; i < H.nwin && !(H.win[i].w == w && H.win[i].h == h); i++) {}
    if (i == H.nwin) return err(JUNOH_E_ARG, "no window of that size has laid itself out");
    if (call(IB + ZOOM_GET, H.win[i].win, 0, 0, 0)) return JUNOH_E_TRAP;
    if (zoom) *zoom = (int32_t)(uint32_t)H.cpu.r[0];
    return JUNOH_OK;
}
int junoh_set_tick(uint32_t ms) { int rc = live(); if (rc) return rc; H.tick_ms = ms; return JUNOH_OK; }
int junoh_call(uint64_t target, uint64_t rcx, uint64_t rdx, uint64_t r8, uint64_t r9, uint64_t *rax) {
    int rc = live(); if (rc) return rc;          /* the oracle's call(): one call of plugin code at a guest address */
    if (call(target, rcx, rdx, r8, r9)) return JUNOH_E_TRAP;
    if (rax) *rax = H.cpu.r[0];
    return JUNOH_OK;
}
int junoh_unhandled(char *buf, size_t cap) {   /* "name=count\n" per import answered by the oracle's default; distinct names */
    size_t p = 0; int i;
    if (buf && cap) buf[0] = 0;
    for (i = 0; i < H.nunh && buf; i++) {
        int k = snprintf(buf + p, cap > p ? cap - p : 0, "%s=%llu\n", H.unh_name[i], (unsigned long long)H.unh_n[i]);
        if (k < 0) break;
        p += (size_t)k;
    }
    return H.nunh;
}

/* ---------------------------------------------------------------- process() (host_process_emu.process) */
int junoh_process(int n, const junoh_event *ev, int nev, const junoh_param *par, int npar, const junoh_ctx *ctx,
                  uint32_t *outl, uint32_t *outr) {
    uint8_t pd[96]; uint64_t cptr = 0; int i; int rc = live();
    if (rc) return rc;
    if (n < 0 || (uint64_t)n > H.maxblock || nev < 0 || nev > MAXEV || npar < 0) return err(JUNOH_E_ARG, "block, events or parameters out of range");
    /* the events: 48-byte VST3 Events (host_process_emu.process) */
    H.nev = nev;
    for (i = 0; i < nev; i++) {
        uint8_t *b = H.evs[i]; int32_t off = ev[i].offset; int16_t ch = (int16_t)ev[i].channel, pitch = (int16_t)ev[i].pitch;
        float z = 0.0f, vel = ev[i].velocity; int32_t m1 = -1; uint16_t t;
        memset(b, 0, 48); memcpy(b + 4, &off, 4);
        if (ev[i].on) { t = 0; memcpy(b + 18, &t, 2); memcpy(b + 24, &ch, 2); memcpy(b + 26, &pitch, 2); memcpy(b + 28, &z, 4); memcpy(b + 32, &vel, 4); memcpy(b + 36, &m1, 4); memcpy(b + 40, &m1, 4); }
        else { t = 1; memcpy(b + 18, &t, 2); memcpy(b + 24, &ch, 2); memcpy(b + 26, &pitch, 2); memcpy(b + 28, &vel, 4); memcpy(b + 32, &m1, 4); }
    }
    /* the parameter changes: one queue per id, in the order the ids first appear (the oracle's dict order); the
     * IParamValueQueue objects are created lazily and reused, as host_process_emu does (so com_next matches) */
    H.npq = 0;
    for (i = 0; i < npar; i++) {
        int q;
        for (q = 0; q < H.npq; q++) if (H.pq_id[q] == par[i].id) break;
        if (q == H.npq) {
            if (H.npq == NPQ) return err(JUNOH_E_ARG, "more parameter ids in one block than the template's queues");
            if (!H.pq[q]) H.pq[q] = new_obj(H.vt_pqueue);     /* lazily made, bumping com_next like the oracle */
            H.pq_id[q] = par[i].id; H.pq_n[q] = 0; H.npq++;
            free(H.pq_off[q]); free(H.pq_val[q]);
            H.pq_off[q] = (int32_t *)malloc(sizeof(int32_t) * (size_t)npar); H.pq_val[q] = (double *)malloc(sizeof(double) * (size_t)npar);
            if (!H.pq_off[q] || !H.pq_val[q]) return err(JUNOH_E_ARG, "no memory");
        }
        H.pq_off[q][H.pq_n[q]] = par[i].offset; H.pq_val[q][H.pq_n[q]] = par[i].value; H.pq_n[q]++;
    }
    if (ctx) {      /* host_process_emu.process's ProcessContext: state, the host rate, ppq, the cycle, the tempo */
        uint8_t cx[160];
        memset(cx, 0, sizeof cx); memcpy(cx, &ctx->state, 4); memcpy(cx + 8, &H.rate, 8); memcpy(cx + 40, &ctx->ppq, 8);
        memcpy(cx + 56, &ctx->cycle_start, 8); memcpy(cx + 64, &ctx->cycle_end, 8); memcpy(cx + 72, &ctx->tempo, 8);
        wmem(H.ctx, cx, sizeof cx); cptr = H.ctx;
    }
    memset(pd, 0, sizeof pd);
    { int32_t v[5]; v[0] = 0; v[1] = 0; v[2] = n; v[3] = 0; v[4] = 1; memcpy(pd, v, sizeof v); }
    { uint64_t q7[7]; q7[0] = 0; q7[1] = H.bus; q7[2] = npar ? H.pc : 0; q7[3] = 0; q7[4] = nev ? H.ev : 0; q7[5] = 0; q7[6] = cptr;
      memcpy(pd + 24, q7, sizeof q7); }
    wmem(H.pd, pd, sizeof pd);
    if (n) {
        void *l = junoh_guest(H.bufl, 4 * (size_t)n), *r = junoh_guest(H.bufr, 4 * (size_t)n);
        if (!l || !r) return err(JUNOH_E_STATE, "output buffers");
        memset(l, 0, 4 * (size_t)n); memset(r, 0, 4 * (size_t)n);
    }
    if (call(H.process_fn, H.audio, H.pd, 0, 0)) return JUNOH_E_TRAP;      /* IAudioProcessor::process (slot 9) */
    if ((uint32_t)H.cpu.r[0] != 0) return err(JUNOH_E_STATE, "process() returned an error");
    if (n) { memcpy(outl, junoh_guest(H.bufl, 4 * (size_t)n), 4 * (size_t)n); memcpy(outr, junoh_guest(H.bufr, 4 * (size_t)n), 4 * (size_t)n); }
    return JUNOH_OK;
}

/* ---------------------------------------------------------------- the gates' accessors */
void junoh_trace_open(const char *path) { jp8_trace_open(path); }    /* the L5 trace-diff: a --trace lift records each insn */
void junoh_trace_close(void) { jp8_trace_close(); }
uint64_t junoh_heap_top(void) { return jp8_heap_get(); }
uint64_t junoh_com_next(void) { return H.com_next; }
uint64_t junoh_renders(void) { return H.njobs; }
uint64_t junoh_core(void) { return H.core; }
int junoh_edits(uint32_t *id, double *val, int cap) {
    int i, m = H.nedit < cap ? H.nedit : cap;
    for (i = 0; i < m; i++) { id[i] = H.edit_id[i]; val[i] = H.edit_val[i]; }
    return H.nedit;
}

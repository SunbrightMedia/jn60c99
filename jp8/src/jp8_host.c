/* jp8_host.c -- the JUPITER-8 as a DAW runs it, in C: the plugin's own VST3 process(), its own patch load and its own
 * engine, its setupProcessing, setActive, getState and setState, LIFTED (jp8_lift.py --hostcalls --hook), on the
 * memory the host oracle (jp8/tools/jp8_host_emu.py) had after booting the plugin up to the point a host learns its
 * sample rate (the JP8H template, jp8/tools/jp8_host_ref.py). Plumbing only, the oracle's, line for line:
 *  - jp8h_init makes the host's setup calls the oracle's setup() makes, at the rate it is given, and creates the
 *    blocks' host objects in the oracle's order (one bump allocator: the same guest addresses);
 *  - the host objects the plugin calls (IEventList, IParameterChanges, IParamValueQueue, IComponentHandler, IBStream)
 *    answer as tools/verify/host_process_emu.py and probes/b6/wrapper_emu.py answer: every stub address named by
 *    the template;
 *  - the imports the host path reaches answer as the oracle's shims do (an unknown one traps, named);
 *  - THE THREAD TRANSPORT (the JX oracle's, jx3p/tools/jx_host_emu.py): the engine render stops where it is about to
 *    wait for its workers (the done lock's acquire, rva 0x4460E7: hook), the worker function runs from its entry for
 *    every unit whose job is flagged, on a stack 1 MB below the render's, with the registers the render (then the
 *    previous worker) left, until it is back at the top of its loop with its job done (rva 0x4456F0: hook, flag 0),
 *    and the render goes on. No plugin logic is reimplemented here: this file decides WHEN a worker runs.
 * Built with the lifted source of the host path and jp8_rt.c (JP8_RELOC, JP8_GS_BASE = the oracle's TEB). */
#include "jp8_cpu.h"
#include "jp8h.h"
#include <setjmp.h>
#ifndef JP8_RELOC
#error "jp8_host.c needs JP8_RELOC"
#endif

#define IB          0x180000000ULL
#define JOBS_DUE    0x4460E7ULL      /* in the engine render: the done lock's acquire before the wait (READ) */
#define WORKER      0x445670ULL      /* a unit's worker thread body (rcx = job, edx = unit; READ) */
#define WORKER_PARK 0x4456F0ULL      /* the top of the worker's loop: its job lock taken here (READ) */
#define JOB_BASE    0x4D0ULL         /* job u = HOST + 0x4D0 + 0x80 u (the render's r13 - 0x38; READ) */
#define JOB_STRIDE  0x80ULL
#define DONE_LOCK   0x488ULL         /* rcx at JOBS_DUE = HOST + 0x488 (READ: lea rcx,[r15+0x488] at 0x4460CD) */
#define CC_INDEX    0x325870ULL      /* the CC records' lookup: rcx = core + 24, edx = index -> its parameter id */
#define CC_LEARN    0x326660ULL      /* MIDI learn armed: rcx = core + 24, edx = the record index (the GUI's menu) */
#define CC_FORGET   0x324F00ULL      /* the menu's Forget (the three: the JUNO-60's functions, byte-equal: fw_map) */
#define NCC_MAX     1024
#define NREG_MAX    16
#define NSTUB_MAX   4096
#define NPQ         8                /* parameter queues created after setup (one per parameter id of a block) */
#define S_OK_       0ULL
#define E_FAIL_     0x80004005ULL
#define MAXEV       512

extern int jp8_map(uint64_t base, uint64_t size);
extern int jp8_call_x(CPU *c, uint64_t rva);
extern const char *jp8_last_trap(void);
extern void jp8_heap_set(uint64_t ptr, uint64_t lim);
extern void jp8_hc_set(uint64_t hc);
extern uint64_t jp8_heap_get(void);
extern void jp8_run(CPU *c, uint64_t rva);
extern const char *jp8_import_names[]; extern const int jp8_nimports;
extern void jp8_heap_reuse(int on);
extern void jp8_heap_free(uint64_t p);
extern void jp8_heap_stats(uint64_t *live, uint64_t *nfree);
extern void jp8_heap_close_thread(void);

/* THE HOST'S SCRATCH AREA (jp8_host_emu.SCR, the same offsets): one block of the host-object area, made in jp8h_init,
 * for every buffer a host call hands the plugin, cleared before each use -- the host-object area does not grow after
 * jp8h_init (before v6 every call took new bytes: a long session would have run past its end) */
#define SCR_SETUP   0x0
#define SCR_QI      0x20
#define SCR_STR     0x60
#define SCR_TEXT    0x160
#define SCR_VAL     0x260
#define SCR_INFO    0x270
#define SCR_UNIT    0x590
#define SCR_VEC     0x6A0
#define SCR_PATCH   0x6C0
#define SCR_PATCH_N 0x10000
#define SCR_EDNAME  0x106C0          /* v8: the editor's createView name and attached's platform type (jp8_host_emu SCR) */
#define SCR_EDTYPE  0x106D0
#define SCR_SIZE    0x106E0
#define WINDOW_FIT  0x31B790ULL      /* a window's fit to the screen (a lifter hook: the window is found by its call) */
#define ZOOM_GET    0x2ACC30ULL      /* a window's zoom getter (jp8_host_emu PROFILE; EXECUTED 2026-10-12) */
#define NDIB_MAX    256
#define NSL_MAX     64
#define NGD_MAX     4096
#define NSKIN_MAX   1024
#define NWIN_MAX    16
static const uint8_t IID_IMIDIMAPPING[16] = { 0xF7, 0xF9, 0x0F, 0xDF, 0xB7, 0x49, 0x69, 0x46, 0xB6, 0x3A, 0xB7, 0x32, 0x7A, 0xDB, 0xF5, 0xE5 };
static const uint8_t IID_IUNITINFO[16] = { 0xB5, 0xD6, 0x4B, 0x3D, 0x3A, 0x91, 0xD2, 0x4F, 0xA8, 0x86, 0xE7, 0x68, 0xA5, 0xEB, 0x92, 0xC1 };

typedef struct { uint64_t addr; char name[48]; } stub_t;
typedef struct { uint32_t off; uint8_t b[48]; } ev_t;
static struct {
    int st;                              /* 0 none, 1 live, 2 dead */
    CPU cpu, wcpu;                       /* the caller's registers; the workers' */
    char msg[256];
    int nreg; uint64_t rbase[NREG_MAX], rsize[NREG_MAX];
    /* the template's facts (jp8_host_ref.py) */
    uint64_t rsp, ret, audio, comp, core, ctrl, process_fn, patch_fn, com_next, mx0, vt_events, vt_pchanges, vt_pqueue,
             vt_stream;
    /* the host objects jp8h_init creates after the setup calls (host_process_emu.setup's order) */
    uint64_t pd, bus, ctx, ev, pc, pq[NPQ], bufl, bufr, maxblock; double rate;
    /* the IBStream of the state call in flight (wrapper_emu's 'stream': data and a position) */
    uint64_t s_addr; unsigned char *s_data; size_t s_len, s_cap; int64_t s_pos;
    /* the CC records' parameter ids by record index (the plugin's own lookup, read once at init) */
    uint32_t cc_id[NCC_MAX]; int ncc;
    stub_t stub[NSTUB_MAX]; int nstub;
    /* the host objects' contents for the call in flight */
    int nev; uint8_t evs[MAXEV][48];
    int npq; uint32_t pq_id[NPQ]; int pq_n[NPQ]; int32_t *pq_off[NPQ]; double *pq_val[NPQ];
    /* the edits the plugin hands the component handler (performEdit), for the gates */
    uint32_t *edit_id; double *edit_val; int nedit, edit_cap;
    /* the thread transport */
    uint64_t job; jmp_buf park; int in_job; uint64_t njobs;
    /* v6: the scratch area, the controller's IMidiMapping and IUnitInfo, the end of the host-object region */
    uint64_t scr, mm, ui, com_end; int32_t nparam, nunit;
    uint64_t reg[16], xreg[16][2], eflags;   /* the oracle's registers at template time */
    /* v8 (E1): the editor -- the state the oracle's answers to the GUI's imports keep (template v3, jp8_host_emu.gui_state) */
    int32_t scr_cx, scr_cy;                 /* the machine's virtual screen: GetSystemMetrics 78 / 79 (others 0) */
    uint64_t lasterr, fake_heap, view;
    int ndib; struct { uint64_t hb, bits; int32_t w, h; uint32_t bpp, stride; } dib[NDIB_MAX];
    int nsl; struct { uint64_t head; int n, cap; uint64_t *e; } sl[NSL_MAX];
    int ngd; struct { uint64_t hd; uint32_t w, h, fmt; } gd[NGD_MAX];
    int nskin; struct { char name[96]; uint32_t w, h; } skin[NSKIN_MAX];
    int nwin; struct { int32_t w, h; uint64_t win; } win[NWIN_MAX];
} H;

static int err(int code, const char *m) { snprintf(H.msg, sizeof H.msg, "%s", m); return code; }
const char *jp8h_error(void) { return H.msg; }
void *jp8h_guest(uint64_t a, size_t n) {            /* host pointer of [a, a+n), one mapped region (may span bands) */
    uint64_t i = a >> 28, last = (a + n - 1) >> 28, k;
    if (!n || last >= JP8_NBANDS) return NULL;
    for (k = i; k <= last; k++) {
        uint64_t lo = k == i ? (a & 0x0FFFFFFFu) : 0, hi = k == last ? ((a + n - 1) & 0x0FFFFFFFu) + 1 : 0x10000000ULL;
        if (!jp8_bhi[k] || lo < jp8_blo[k] || hi > jp8_bhi[k] || jp8_bdelta[k] != jp8_bdelta[i]) return NULL;
    }
    return (void *)((uintptr_t)a + jp8_bdelta[i]);
}
static uint64_t gq(uint64_t a) { uint64_t v = 0; void *p = jp8h_guest(a, 8); if (p) memcpy(&v, p, 8); return v; }
static int32_t gi(uint64_t a) { int32_t v = 0; void *p = jp8h_guest(a, 4); if (p) memcpy(&v, p, 4); return v; }
static void wq(uint64_t a, uint64_t v) { void *p = jp8h_guest(a, 8); if (p) memcpy(p, &v, 8); }
static void wmem(uint64_t a, const void *s, size_t n) { void *p = jp8h_guest(a, n); if (p) memcpy(p, s, n); }
static uint32_t le32(const unsigned char *p) { return (uint32_t)p[0] | (uint32_t)p[1] << 8 | (uint32_t)p[2] << 16 | (uint32_t)p[3] << 24; }
static uint64_t le64(const unsigned char *p) { return (uint64_t)le32(p) | (uint64_t)le32(p + 4) << 32; }
static uint32_t crc32_of(const unsigned char *p, size_t n) {
    static uint32_t t[256]; static int ready; uint32_t c = 0xFFFFFFFFu; size_t i;
    if (!ready) { uint32_t k, j, x; for (k = 0; k < 256; k++) { x = k; for (j = 0; j < 8; j++) x = (x & 1) ? 0xEDB88320u ^ (x >> 1) : x >> 1; t[k] = x; } ready = 1; }
    for (i = 0; i < n; i++) c = t[(c ^ p[i]) & 0xFF] ^ (c >> 8);
    return c ^ 0xFFFFFFFFu;
}

/* ---------------------------------------------------------------- the host objects and the imports */
static const char *stub_name(uint64_t target) {
    int lo = 0, hi = H.nstub - 1;
    while (lo <= hi) { int m = (lo + hi) / 2; if (H.stub[m].addr == target) return H.stub[m].name; if (H.stub[m].addr < target) lo = m + 1; else hi = m - 1; }
    return NULL;
}
static void record_edit(uint32_t id, double v) {
    if (H.nedit == H.edit_cap) {
        int cap = H.edit_cap ? 2 * H.edit_cap : 256; uint32_t *a = (uint32_t *)realloc(H.edit_id, sizeof *a * (size_t)cap);
        double *b = (double *)realloc(H.edit_val, sizeof *b * (size_t)cap);
        if (!a || !b) { free(a == H.edit_id ? NULL : a); return; }
        H.edit_id = a; H.edit_val = b; H.edit_cap = cap;
    }
    H.edit_id[H.nedit] = id; H.edit_val[H.nedit] = v; H.nedit++;
}
#ifdef JP8H_THREADS
static int w_self_free_check(void);              /* a worker thread? (the threaded transport, below) */
#endif
static int pq_index(uint64_t this_) { int i; for (i = 0; i < NPQ; i++) if (H.pq[i] == this_) return i; return -1; }
/* ---------------------------------------------------------------- v8 (E1): the GUI's imports, as the oracle answers them
 * (probes/b6/wrapper_emu.py: _imp, _gdip; jp8_emu.py: _imp) -- the editor's open makes 335 calls of 36 imports
 * (jp8/logs/editor_imports.log). Plumbing: each answer is the oracle's, state and all. */
static uint64_t alloc_com(uint64_t n);
static uint64_t stack_arg(CPU *c, int k) { return gq(c->r[4] + 8 + 8 * (uint64_t)k); }    /* wrapper_emu.stack_arg */
static uint8_t gb(uint64_t a) { uint8_t v = 0; void *p = jp8h_guest(a, 1); if (p) memcpy(&v, p, 1); return v; }
static int gd_find(uint64_t hd) { int i; for (i = 0; i < H.ngd; i++) if (H.gd[i].hd == hd) return i; return -1; }
static void gd_of(uint64_t hd, uint32_t *w, uint32_t *h, uint32_t *fmt) {     /* imgs.get(h, dict(w=64, h=64, fmt=0x26200A)) */
    int i = gd_find(hd);
    *w = i < 0 ? 64 : H.gd[i].w; *h = i < 0 ? 64 : H.gd[i].h; *fmt = i < 0 ? 0x26200Au : H.gd[i].fmt;
}
static uint64_t new_img(CPU *c, uint32_t w, uint32_t h, uint32_t fmt) {        /* _gdip's new_img: alloc_com(32) */
    uint64_t hd = alloc_com(32); int i = gd_find(hd);
    if (i < 0) { if (H.ngd >= NGD_MAX) { jp8_trap(c, 0, "too many GDI+ images"); return 0; } i = H.ngd++; }
    H.gd[i].hd = hd; H.gd[i].w = w; H.gd[i].h = h; H.gd[i].fmt = fmt;
    return hd;
}
static int sl_of(CPU *c, uint64_t head) {                                      /* slists.setdefault(head, []) */
    int i; for (i = 0; i < H.nsl; i++) if (H.sl[i].head == head) return i;
    if (H.nsl >= NSL_MAX) { jp8_trap(c, 0, "too many singly linked lists"); return -1; }
    i = H.nsl++; H.sl[i].head = head; H.sl[i].n = 0; H.sl[i].cap = 16;
    if (!(H.sl[i].e = (uint64_t *)malloc(16 * sizeof(uint64_t)))) { jp8_trap(c, 0, "no memory"); return -1; }
    return i;
}
static int gui_import(CPU *c, const char *n) {      /* 1: answered (rax set); 0: not a GUI import */
    uint64_t rcx = c->r[1], rdx = c->r[2], r8 = c->r[8], r9 = c->r[9];
    if (!strcmp(n, "GetSystemMetrics")) {                             /* the screen dict holds 78 and 79 only */
        uint32_t i = (uint32_t)rcx;
#ifdef JP8H_TOOTH_EDITOR    /* the gate's tooth: the screen's width and height swapped (the zoom's fit must see it) */
        i = i == 0x4E ? 0x4F : i == 0x4F ? 0x4E : i;
#endif
        c->r[0] = (uint64_t)(int64_t)(i == 0x4E ? H.scr_cx : i == 0x4F ? H.scr_cy : 0); return 1;
    }
    if (!strcmp(n, "LoadCursorA") || !strcmp(n, "LoadCursorW") || !strcmp(n, "FlushInstructionCache") ||
        !strcmp(n, "AllocateAndInitializeSid") || !strcmp(n, "WakeAllConditionVariable") || !strcmp(n, "WakeConditionVariable") ||
        !strcmp(n, "DeleteObject") || !strcmp(n, "DeleteDC") || !strcmp(n, "ReleaseDC")) { c->r[0] = 1; return 1; }
    if (!strcmp(n, "RegisterClassExA") || !strcmp(n, "RegisterClassExW") || !strcmp(n, "RegisterClassA") ||
        !strcmp(n, "RegisterClassW")) { c->r[0] = 0xC001; return 1; }
    if (!strcmp(n, "SelectObject")) { c->r[0] = 0x77770; return 1; }
    if (!strcmp(n, "GetLastError")) { c->r[0] = H.lasterr & 0xFFFFFFFFu; return 1; }
    if (!strcmp(n, "SetLastError")) { H.lasterr = rcx & 0xFFFFFFFFu; c->r[0] = 0; return 1; }
    if (!strcmp(n, "GetProcessHeap")) { c->r[0] = H.fake_heap; return 1; }
    if (!strcmp(n, "HeapAlloc")) { c->r[0] = jp8_heap_alloc(r8 ? r8 : rdx ? rdx : 16); return 1; }   /* r8 or rdx or 16 */
    if (!strcmp(n, "HeapReAlloc")) { c->r[0] = jp8_heap_alloc(r9); return 1; }   /* a new block, nothing copied: the oracle's */
    if (!strcmp(n, "GetCurrentProcess")) { c->r[0] = 0; return 1; }
    if (!strncmp(n, "Create", 6) && strcmp(n, "CreateDIBSection") && strncmp(n, "CreateFile", 10)) { c->r[0] = jp8_hc_next(); return 1; }
    /* the imports the oracle does not model: its default answer, 0 (e2e_emu / jp8_emu: counted, unhandled) */
    if (!strcmp(n, "GetClassInfoExA") || !strcmp(n, "HeapSize") || !strcmp(n, "SetTimer") || !strcmp(n, "InvalidateRect") ||
        !strcmp(n, "SetWindowPos") || !strcmp(n, "EnumThreadWindows") || !strcmp(n, "GetDesktopWindow") || !strcmp(n, "IsWindow") ||
        !strcmp(n, "DestroyWindow") || !strcmp(n, "LoadLibraryExA") || !strcmp(n, "KillTimer")) { c->r[0] = 0; return 1; }
    if (!strcmp(n, "MultiByteToWideChar")) {
        uint64_t outp = stack_arg(c, 4); uint32_t outn = (uint32_t)stack_arg(c, 5), cnt = (uint32_t)r9, len, k;
        if (cnt == 0xFFFFFFFFu) { for (len = 0; len < 1200 && gb(r8 + len); len++) {} len++; }   /* rstr + '\0' */
        else len = cnt;
        if (outn == 0) { c->r[0] = len; return 1; }
        for (k = 0; k < len && k < outn; k++) { uint16_t w = k < len - (cnt == 0xFFFFFFFFu) ? gb(r8 + k) : 0; wmem(outp + 2 * (uint64_t)k, &w, 2); }
        c->r[0] = len < outn ? len : outn; return 1;
    }
    if (!strcmp(n, "CreateDIBSection")) {
        int32_t w_ = gi(rdx + 4), h_ = gi(rdx + 8); uint32_t bpp = ((uint32_t)gi(rdx + 12) >> 16) & 0xFFFFu, stride, size, ah;
        uint64_t bits;
        ah = (uint32_t)(h_ < 0 ? -h_ : h_); stride = ((uint32_t)(w_ < 0 ? -w_ : w_) * bpp + 31) / 32 * 4;
        size = stride * ah; if (size < 16) size = 16;
        if (H.ndib >= NDIB_MAX) { jp8_trap(c, 0, "too many DIB sections"); return 1; }
        bits = jp8_heap_alloc(size);                                    /* self.bump(size_), zeroed */
        H.dib[H.ndib].hb = 0xB0000 + 0x10 * (uint64_t)H.ndib; H.dib[H.ndib].bits = bits; H.dib[H.ndib].w = w_; H.dib[H.ndib].h = h_;
        H.dib[H.ndib].bpp = bpp; H.dib[H.ndib].stride = stride;
        if (r9) wq(r9, bits);
        c->r[0] = H.dib[H.ndib++].hb; return 1;
    }
    if (!strcmp(n, "GetObjectA") || !strcmp(n, "GetObjectW")) {
        int i; uint8_t bm[104]; int32_t v; uint32_t u; uint16_t hw;
        for (i = 0; i < H.ndib && H.dib[i].hb != rcx; i++) {}
        if (i == H.ndib) { c->r[0] = 0; return 1; }
        memset(bm, 0, sizeof bm);                                       /* '<iiiiHHIQ' then (104) '<IiiHHIIiiII' + 12 + '<QI' */
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
    if (!strcmp(n, "InterlockedPushEntrySList")) {
        int i = sl_of(c, rcx); uint64_t old;
        if (i < 0) return 1;
        old = H.sl[i].n ? H.sl[i].e[H.sl[i].n - 1] : 0; wq(rdx, old);
        if (H.sl[i].n == H.sl[i].cap) {
            uint64_t *q = (uint64_t *)realloc(H.sl[i].e, sizeof(uint64_t) * 2 * (size_t)H.sl[i].cap);
            if (!q) { jp8_trap(c, 0, "no memory"); return 1; }
            H.sl[i].e = q; H.sl[i].cap *= 2;
        }
        H.sl[i].e[H.sl[i].n++] = rdx; c->r[0] = old; return 1;
    }
    if (!strcmp(n, "InterlockedPopEntrySList")) { int i = sl_of(c, rcx); if (i >= 0) c->r[0] = H.sl[i].n ? H.sl[i].e[--H.sl[i].n] : 0; return 1; }
    if (!strcmp(n, "InterlockedFlushSList")) {
        int i = sl_of(c, rcx); if (i >= 0) { c->r[0] = H.sl[i].n ? H.sl[i].e[H.sl[i].n - 1] : 0; H.sl[i].n = 0; } return 1;
    }
    if (!strncmp(n, "Gdip", 4)) {                                      /* _gdip (GdiplusStartup and every Gdip*) */
        uint32_t w, h, fmt;
        if (!strcmp(n, "GdiplusStartup")) { wq(rcx, 1); c->r[0] = 0; return 1; }
        if (!strcmp(n, "GdipAlloc")) { c->r[0] = alloc_com(rcx > 16 ? rcx : 16); return 1; }
        if (!strcmp(n, "GdipCreateBitmapFromFile") || !strcmp(n, "GdipCreateBitmapFromFileICM")) {
            char nm[96]; size_t k = 0, last = 0, i; int j;
            uint16_t ch;
            for (i = 0; i < 600; i++) {                                 /* rstr(rcx, True) -> basename, lower case */
                ch = (uint16_t)(gb(rcx + 2 * i) | gb(rcx + 2 * i + 1) << 8);
                if (!ch) break;
                if (ch == '\\' || ch == '/') { k = 0; last = i + 1; continue; }
                if (k + 1 < sizeof nm) nm[k++] = (char)(ch >= 'A' && ch <= 'Z' ? ch + 32 : ch);
            }
            (void)last; nm[k] = 0; w = 16; h = 16;
            for (j = 0; j < H.nskin; j++) if (!strcmp(H.skin[j].name, nm)) { w = H.skin[j].w; h = H.skin[j].h; break; }
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
        if (!strcmp(n, "GdipBitmapLockBits")) {
            uint8_t d[32]; uint64_t buf, data = stack_arg(c, 4); int32_t st_;
            gd_of(rcx, &w, &h, &fmt);
            buf = jp8_heap_alloc((uint64_t)w * h * 4 + 16);             /* bump(w h 4 + 16), the first w h 4 bytes zeroed */
            memset(d, 0, sizeof d); memcpy(d, &w, 4); memcpy(d + 4, &h, 4); st_ = (int32_t)(w * 4); memcpy(d + 8, &st_, 4);
            memcpy(d + 12, &fmt, 4); memcpy(d + 16, &buf, 8);
            wmem(data, d, 32); c->r[0] = 0; return 1;
        }
        if (!strcmp(n, "GdipGetImageGraphicsContext") || !strcmp(n, "GdipCreateFromHDC") || !strcmp(n, "GdipCreatePath") ||
            !strcmp(n, "GdipCreateSolidFill") || !strcmp(n, "GdipCloneBrush")) { wq(rdx, alloc_com(32)); c->r[0] = 0; return 1; }
        if (!strcmp(n, "GdipCreatePen1")) { wq(stack_arg(c, 3), alloc_com(32)); c->r[0] = 0; return 1; }
        if (!strcmp(n, "GdipCreateLineBrushI")) { wq(stack_arg(c, 5), alloc_com(32)); c->r[0] = 0; return 1; }
        if (!strcmp(n, "GdipGetSmoothingMode")) { int32_t v = 0; wmem(rdx, &v, 4); c->r[0] = 0; return 1; }
        if (!strcmp(n, "GdipGetImageEncodersSize")) { uint32_t v = 0; wmem(rcx, &v, 4); wmem(rdx, &v, 4); c->r[0] = 0; return 1; }
        c->r[0] = 0; return 1;                                          /* every other Gdip*: Ok, nothing written */
    }
    return 0;
}
void jp8_hostcall(CPU *c, uint64_t target) {
    const char *n = stub_name(target); uint64_t rcx = c->r[1], rdx = c->r[2], r8 = c->r[8], r9 = c->r[9];
    char msg[96];
    if (!n) { snprintf(msg, sizeof msg, "stub 0x%llx not in the template", (unsigned long long)target); jp8_trap(c, target, msg); return; }
    if (!strncmp(n, "COM:", 4)) {
        const char *kind = n + 4; const char *colon = strchr(kind, ':'); int slot = colon ? atoi(colon + 1) : -1;
        size_t kl = colon ? (size_t)(colon - kind) : 0;
        if (slot == 1 || slot == 2) { c->r[0] = 1; return; }                                  /* addRef / release */
        if (kl == 6 && !strncmp(kind, "events", 6)) {                                           /* IEventList */
            if (slot == 3) { c->r[0] = (uint64_t)H.nev; return; }
            if (slot == 4) { uint32_t i = (uint32_t)rdx; if ((int)i >= H.nev || i >= MAXEV) { c->r[0] = 1; return; } wmem(r8, H.evs[i], 48); c->r[0] = 0; return; }
            c->r[0] = 1; return;
        }
        if (kl == 8 && !strncmp(kind, "pchanges", 8)) {                                         /* IParameterChanges */
            if (slot == 3) { c->r[0] = (uint64_t)H.npq; return; }
            if (slot == 4) { uint32_t i = (uint32_t)rdx; c->r[0] = (int)i < H.npq ? H.pq[i] : 0; return; }
            c->r[0] = 0; return;
        }
        if (kl == 6 && !strncmp(kind, "pqueue", 6)) {                                           /* IParamValueQueue */
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
        if (kl == 6 && !strncmp(kind, "stream", 6)) {                                           /* IBStream */
            if (rcx != H.s_addr) { jp8_trap(c, target, "a stream this runtime did not make"); return; }
            if (slot == 3) {                                       /* read(buffer, numBytes, numBytesRead*) */
                int64_t want = (int64_t)(uint32_t)r8, avail = (int64_t)H.s_len - H.s_pos, n = want < avail ? want : avail;
                int32_t n32;
                if (H.s_pos < 0) { jp8_trap(c, target, "a stream read before its start"); return; }
                if (n < 0) n = 0;
                if (n) wmem(rdx, H.s_data + H.s_pos, (size_t)n);
#ifdef JP8H_TOOTH_STREAM      /* the gate's tooth: every (id, value) entry's value read one off (its lowest bit) */
                { int64_t o; for (o = H.s_pos; o < H.s_pos + n; o++) if (o >= 4 && (o - 4) % 8 == 7) {
                      unsigned char x = (unsigned char)(H.s_data[o] ^ 0x01); wmem(rdx + (uint64_t)(o - H.s_pos), &x, 1); } }
#endif
                H.s_pos += n; n32 = (int32_t)n;
                if (r9) wmem(r9, &n32, 4);
                c->r[0] = S_OK_; return;
            }
            if (slot == 4) {                                       /* write(buffer, numBytes, numBytesWritten*) */
                size_t n = (uint32_t)r8, start = H.s_pos < 0 ? 0 : (size_t)H.s_pos < H.s_len ? (size_t)H.s_pos : H.s_len;
                size_t end = (size_t)H.s_pos + n < H.s_len ? (size_t)H.s_pos + n : H.s_len, nl;   /* the slice [pos:pos+n] */
                int32_t n32 = (int32_t)n;
                if (H.s_pos < 0) { jp8_trap(c, target, "a stream write before its start"); return; }
                if (end < start) end = start;
                nl = H.s_len - (end - start) + n;                  /* bytearray slice assignment, as the oracle's */
                if (nl > H.s_cap) {
                    size_t cap = H.s_cap ? H.s_cap : 4096; unsigned char *d;
                    while (cap < nl) cap *= 2;
                    d = (unsigned char *)realloc(H.s_data, cap); if (!d) { jp8_trap(c, target, "no memory for a stream"); return; }
                    H.s_data = d; H.s_cap = cap;
                }
                memmove(H.s_data + start + n, H.s_data + end, H.s_len - end);
                if (n) { void *src = jp8h_guest(rdx, n); if (!src) { jp8_trap(c, target, "a stream write from unmapped memory"); return; } memcpy(H.s_data + start, src, n); }
                H.s_len = nl; H.s_pos += (int64_t)n;
                if (r9) wmem(r9, &n32, 4);
                c->r[0] = S_OK_; return;
            }
            if (slot == 5) {                                       /* seek(pos, mode, result*) */
                int64_t pos = (int64_t)rdx; int mode = (int)(r8 & 3);
                if (mode == 3) { jp8_trap(c, target, "a stream seek mode the oracle does not have"); return; }
                H.s_pos = (mode == 0 ? 0 : mode == 1 ? H.s_pos : (int64_t)H.s_len) + pos;
                if (r9) wmem(r9, &H.s_pos, 8);
                c->r[0] = S_OK_; return;
            }
            if (slot == 6) { wmem(rdx, &H.s_pos, 8); c->r[0] = S_OK_; return; }      /* tell(pos*) */
            c->r[0] = E_FAIL_; return;
        }
        if (kl == 7 && !strncmp(kind, "handler", 7)) {                                          /* IComponentHandler: record, accept */
            if (slot == 4) record_edit((uint32_t)rdx, c->x[2].d[0]);
            if (slot >= 3) { c->r[0] = 0; return; }
        }
        snprintf(msg, sizeof msg, "host object method %s not served", n); jp8_trap(c, target, msg); return;
    }
    /* the imports the host path reaches, answered as the oracle's shims answer them */
    if (!strcmp(n, "AcquireSRWLockExclusive") || !strcmp(n, "ReleaseSRWLockExclusive") ||
        !strcmp(n, "AcquireSRWLockShared") || !strcmp(n, "ReleaseSRWLockShared") ||
        !strcmp(n, "EnterCriticalSection") || !strcmp(n, "LeaveCriticalSection")) { c->r[0] = 1; return; }   /* e2e_emu: 1 */
    if (!strcmp(n, "GetCurrentThreadId") || !strcmp(n, "GetCurrentProcessId")) { c->r[0] = 0x1000; return; }
    if (!strcmp(n, "HeapFree") || !strcmp(n, "free") || !strcmp(n, "??3@YAXPEAX@Z")) {   /* the block back to the reuse layer */
#ifdef JP8H_THREADS
        if (w_self_free_check()) { jp8_trap(c, target, "a worker job frees a block (the threaded transport assumes none does)"); return; }
#endif
        jp8_heap_free(!strcmp(n, "HeapFree") ? r8 : rcx); c->r[0] = 1; return;
    }
    if (!strcmp(n, "EncodePointer") || !strcmp(n, "DecodePointer")) { c->r[0] = rcx; return; }
    /* the editor's focus calls a setState makes when it moves the GUI model (rva 0x31bd8b): no window here -- the
     * oracle's own answer (e2e_emu's default for an import it does not model: 0) */
    if (!strcmp(n, "GetFocus") || !strcmp(n, "SetFocus")) { c->r[0] = 0; return; }
    /* an exception the plugin raises and handles itself is answered 0 (e2e_emu's RaiseException); a C++ THROW
     * (0xE06D7363) has no unwinder here, as in the oracle (wrapper_emu: PluginThrow): it traps, named */
    if (!strcmp(n, "RaiseException")) {
        if ((uint32_t)rcx == 0xE06D7363u) { jp8_trap(c, target, "the plugin threw a C++ exception (RaiseException 0xE06D7363)"); return; }
        c->r[0] = 0; return;
    }
    if (gui_import(c, n)) return;                       /* v8 (E1): the editor's imports */
    snprintf(msg, sizeof msg, "import %s not shimmed on the host path (called from rva 0x%llx)", n,
             (unsigned long long)(gq(c->r[4]) - IB));
    if (getenv("JP8H_DEBUG")) {                         /* the image addresses on the stack above: the call chain */
        int k; fprintf(stderr, "jp8h: %s; stack image addresses:", msg);
        for (k = 0; k < 160; k++) { uint64_t v = gq(c->r[4] + 8 * (uint64_t)k); if (v >= IB && v < IB + 0xDE7000) fprintf(stderr, " +%x:0x%llx", 8 * k, (unsigned long long)(v - IB)); }
        fprintf(stderr, "\n");
    }
    jp8_trap(c, target, msg);
}

/* ---------------------------------------------------------------- the thread transport */
#define RENDER_DONE 0x44580AULL      /* in the worker: its render loop has ended, its bookkeeping begins (READ) */
#ifdef JP8H_THREADS
/* ---------------------------------------------------------------- THE THREADED TRANSPORT (a platform layer: POSIX
 * threads, not ISO C99). The plugin renders its units on eight threads; here too. Each flagged job starts on its own
 * thread with the render's registers and its own stack (128 KB apart, 1 MB below the render's); all render at once;
 * at RENDER_DONE each waits for its turn, and the bookkeeping -- flag 0, the done count, the condition, the unlocks --
 * runs one job at a time in unit order, the sequential transport's order: only the render overlaps. A job never
 * allocates (a counted drive: 0 of 50,504 allocations inside a job). The gate grades this build like the others. */
#include <pthread.h>
#include <semaphore.h>
typedef struct {
    pthread_t th; sem_t go, rendered, turn, parked; CPU cpu; uint64_t job; jmp_buf park; int up, trapped; char msg[256];
} wslot;
static wslot WS[8];
static JP8_TLS wslot *w_self;                   /* the worker slot of this thread; NULL on the render's */
static int w_self_free_check(void) { return w_self != NULL; }
static void *w_main(void *arg) {
    wslot *w = (wslot *)arg; w_self = w;
    jp8_heap_close_thread();                     /* a job never allocates (a counted drive): if one does, it traps */
    for (;;) {
        sem_wait(&w->go);
        if (!setjmp(w->park)) {
            if (jp8_call_x(&w->cpu, WORKER)) snprintf(w->msg, sizeof w->msg, "%s", jp8_last_trap());
            else snprintf(w->msg, sizeof w->msg, "a worker returned instead of parking");
            w->trapped = 1; sem_post(&w->rendered); sem_post(&w->parked);       /* no one waits forever */
            continue;
        }
        sem_post(&w->parked);
    }
    return NULL;
}
static int w_start(void) {
    int u;
    for (u = 0; u < 8; u++) {
        if (WS[u].up) continue;
        if (sem_init(&WS[u].go, 0, 0) || sem_init(&WS[u].rendered, 0, 0) || sem_init(&WS[u].turn, 0, 0) ||
            sem_init(&WS[u].parked, 0, 0) || pthread_create(&WS[u].th, NULL, w_main, &WS[u])) return -1;
        WS[u].up = 1;
    }
    return 0;
}
static void jobs_threaded(CPU *c, uint64_t host, uint64_t top) {
    int u, k, n = 0, fl[8];
    if (w_start()) { jp8_trap(c, JOBS_DUE, "the worker threads cannot start"); return; }
    for (u = 0; u < 8; u++) {
        uint64_t job = host + JOB_BASE + JOB_STRIDE * (uint64_t)u, t = (top - 0x20000ULL * (uint64_t)u) & ~0xFULL;
        wslot *w = &WS[u];
        if (gi(job + 0x34) != 1) continue;
#ifdef JP8H_TOOTH_SKIPJOB
        if (u == 7) continue;
#endif
        memcpy(&w->cpu, c, sizeof w->cpu); w->cpu.r[4] = t; wq(t - 8, H.ret);
        w->cpu.r[1] = job; w->cpu.r[2] = (uint64_t)u; w->job = job; w->trapped = 0; H.njobs++; fl[n++] = u;
    }
    for (k = 0; k < n; k++) sem_post(&WS[fl[k]].go);
    for (k = 0; k < n; k++) sem_wait(&WS[fl[k]].rendered);
    for (k = 0; k < n; k++) {                    /* the bookkeeping, one job at a time, in unit order */
        wslot *w = &WS[fl[k]];
        if (!w->trapped) sem_post(&w->turn);
        sem_wait(&w->parked);
    }
    for (k = 0; k < n; k++) if (WS[fl[k]].trapped) { jp8_trap(c, WORKER, WS[fl[k]].msg); return; }
    for (k = 0; k < n; k++) if (gi(WS[fl[k]].job + 0x34) != 0) { jp8_trap(c, WORKER, "a worker parked with its job not done"); return; }
}
#endif
void jp8_hook(CPU *c, uint64_t rva) {
#ifdef JP8H_THREADS
    if (w_self) {                                /* a worker thread */
        if (rva == RENDER_DONE) { sem_post(&w_self->rendered); sem_wait(&w_self->turn); return; }
        if (rva == WORKER_PARK) { if (gi(w_self->job + 0x34) == 0) longjmp(w_self->park, 1); return; }
        jp8_trap(c, rva, "engine render reached from inside a worker job"); return;
    }
    if (rva == JOBS_DUE) {
        uint32_t mx = c->mxcsr;
        jobs_threaded(c, c->r[1] - DONE_LOCK, (c->r[4] - 0x100000ULL) & ~0xFULL);
        c->mxcsr = mx; JP8_FPENV(c);
        return;
    }
#endif
    if (rva == WINDOW_FIT) {                     /* v8 (E1): a window lays itself out -- found by its fit's call, as the
                                                    oracle's editor_attach finds it: windows[(w, h)] = this */
        int32_t rc_[4]; int i; void *p = jp8h_guest(c->r[1] + 0x18, 16);
        if (!p) { jp8_trap(c, rva, "a window's rectangle is not mapped"); return; }
        memcpy(rc_, p, 16);
        for (i = 0; i < H.nwin && !(H.win[i].w == rc_[2] - rc_[0] && H.win[i].h == rc_[3] - rc_[1]); i++) {}
        if (i == H.nwin) { if (H.nwin >= NWIN_MAX) { jp8_trap(c, rva, "too many windows"); return; } H.nwin++; }
        H.win[i].w = rc_[2] - rc_[0]; H.win[i].h = rc_[3] - rc_[1]; H.win[i].win = c->r[1];
        return;
    }
    if (rva == RENDER_DONE) return;              /* the sequential transport: the bookkeeping follows at once */
    if (rva == JOBS_DUE) {
        uint64_t host = c->r[1] - DONE_LOCK, top = (c->r[4] - 0x100000ULL) & ~0xFULL; int u;
        uint32_t mx = c->mxcsr;
        if (H.in_job) { jp8_trap(c, rva, "engine render reached from inside a worker job"); return; }
        memcpy(&H.wcpu, c, sizeof H.wcpu);              /* the first worker starts on the render's registers */
        for (u = 0; u < 8; u++) {
            uint64_t job = host + JOB_BASE + JOB_STRIDE * (uint64_t)u;
            if (gi(job + 0x34) != 1) continue;
#ifdef JP8H_TOOTH_SKIPJOB                               /* the gate's tooth: the last unit's job never runs */
            if (u == 7) continue;
#endif
            H.wcpu.r[4] = top; wq(top - 8, H.ret);     /* jp8_call_x pushes: the worker enters at top - 8, RET there */
            H.wcpu.r[1] = job; H.wcpu.r[2] = (uint64_t)u;
            H.job = job; H.in_job = 1; H.njobs++;
            if (!setjmp(H.park)) {
                H.wcpu.r[4] -= 8; jp8_run(&H.wcpu, WORKER); H.wcpu.r[4] += 8;
                H.in_job = 0; jp8_trap(c, WORKER, "a worker returned instead of parking");
                return;
            }
            H.in_job = 0;
            if (gi(job + 0x34) != 0) { jp8_trap(c, WORKER, "a worker parked with its job not done"); return; }
        }
        c->mxcsr = mx; JP8_FPENV(c);                     /* the render's MXCSR (the oracle restores its context) */
        return;
    }
    if (rva == WORKER_PARK) {
        if (H.in_job && gi(H.job + 0x34) == 0) longjmp(H.park, 1);   /* the job done: back to the render */
        return;
    }
    jp8_trap(c, rva, "a hook this runtime does not know");
}

/* ---------------------------------------------------------------- calls, as the oracle's call() makes them */
static int call(uint64_t fn, uint64_t rcx, uint64_t rdx, uint64_t r8, uint64_t r9) {
    CPU *c = &H.cpu; uint32_t hmx = 0;
#ifndef JP8_SOFTFP
    hmx = _mm_getcsr();
#endif
    c->r[4] = H.rsp; wq(H.rsp - 8, H.ret);
    c->r[1] = rcx; c->r[2] = rdx; c->r[8] = r8; c->r[9] = r9;
    if (jp8_call_x(c, fn - IB)) {
        snprintf(H.msg, sizeof H.msg, "%s (call rva 0x%llx)", jp8_last_trap(), (unsigned long long)(fn - IB));
        H.st = 2; H.in_job = 0;
#ifndef JP8_SOFTFP
        _mm_setcsr(hmx);
#endif
        return -1;
    }
#ifndef JP8_SOFTFP
    _mm_setcsr(hmx);
#endif
    (void)hmx;
    return 0;
}

/* ---------------------------------------------------------------- the template (JP8H v2 / v3, jp8_host_ref.py) */
static int load(const unsigned char *b, size_t len) {
    size_t p = 12; uint32_t nreg, r, k, nkv, ns, ver;
    if (len < 16 || memcmp(b, "JP8H", 4) || ((ver = le32(b + 4)) != 2 && ver != 3)) return err(JP8H_E_TEMPLATE, "template: not JP8H version 2 or 3");
    if (crc32_of(b, len - 4) != le32(b + len - 4)) return err(JP8H_E_TEMPLATE, "template: crc32 mismatch");
    nreg = le32(b + 8);
    if (nreg > NREG_MAX || (H.nreg && (uint32_t)H.nreg != nreg)) return err(JP8H_E_TEMPLATE, "template: regions");
    for (r = 0; r < nreg; r++) {
        uint64_t base, size; uint32_t nruns; unsigned char *h;
        if (p + 20 > len - 4) return err(JP8H_E_TEMPLATE, "template: truncated region");
        base = le64(b + p); size = le64(b + p + 8); nruns = le32(b + p + 16); p += 20;
        if (H.nreg) {
            if (H.rbase[r] != base || H.rsize[r] != size) return err(JP8H_E_TEMPLATE, "template: other regions than the mapped ones");
            h = (unsigned char *)jp8h_guest(base, (size_t)size); if (!h) return err(JP8H_E_TEMPLATE, "template: region lost");
            memset(h, 0, (size_t)size);
        } else {
            if (jp8_map(base, size)) return err(JP8H_E_TEMPLATE, "template: a region cannot be mapped");
            H.rbase[r] = base; H.rsize[r] = size;
            h = (unsigned char *)jp8h_guest(base, (size_t)size); if (!h) return err(JP8H_E_TEMPLATE, "template: region not reachable");
        }
        for (k = 0; k < nruns; k++) {
            uint32_t off, ln;
            if (p + 8 > len - 4) return err(JP8H_E_TEMPLATE, "template: truncated run");
            off = le32(b + p); ln = le32(b + p + 4); p += 8;
            if ((uint64_t)off + ln > size || p + ln > len - 4) return err(JP8H_E_TEMPLATE, "template: run outside its region");
            memcpy(h + off, b + p, ln); p += ln;
        }
    }
    H.nreg = (int)nreg;
    if (p + 4 > len - 4) return err(JP8H_E_TEMPLATE, "template: no facts");
    nkv = le32(b + p); p += 4;
    {
        uint64_t heap_ptr = 0, heap_lim = 0, hc = 0x9000;
        for (k = 0; k < nkv; k++) {
            char key[25]; uint64_t v;
            if (p + 32 > len - 4) return err(JP8H_E_TEMPLATE, "template: truncated facts");
            memcpy(key, b + p, 24); key[24] = 0; v = le64(b + p + 24); p += 32;
#define KV(name, dst) else if (!strcmp(key, name)) dst = v
            if (0) {}
            KV("heap_ptr", heap_ptr); KV("heap_limit", heap_lim); KV("hc", hc); KV("mxcsr", H.mx0); KV("rsp", H.rsp);
            KV("ret", H.ret); KV("audio", H.audio); KV("comp", H.comp); KV("core", H.core); KV("ctrl", H.ctrl);
            KV("process_fn", H.process_fn); KV("patch_fn", H.patch_fn); KV("com_next", H.com_next);
            KV("vt_events", H.vt_events); KV("vt_pchanges", H.vt_pchanges); KV("vt_pqueue", H.vt_pqueue);
            KV("vt_stream", H.vt_stream);
            else if (key[0] == 'r' && key[1] >= '0' && key[1] <= '9') { int r_ = atoi(key + 1); if (r_ >= 0 && r_ < 16) H.reg[r_] = v; }
            else if (key[0] == 'x' && key[1] >= '0' && key[1] <= '9') {
                int r_ = atoi(key + 1); const char *t = strchr(key, 'l') ? "lo" : "hi";
                if (r_ >= 0 && r_ < 16) H.xreg[r_][t[0] == 'h'] = v;
            }
            KV("eflags", H.eflags); KV("lasterr", H.lasterr); KV("fake_heap", H.fake_heap);
#undef KV
        }
        if (!H.audio || !H.comp || !H.ctrl || !H.process_fn || !H.patch_fn || !H.vt_events || !H.vt_pchanges || !H.vt_pqueue || !H.vt_stream)
            return err(JP8H_E_TEMPLATE, "template: a fact is missing");
        jp8_heap_set(heap_ptr, heap_lim); jp8_hc_set(hc);
    }
    if (p + 4 > len - 4) return err(JP8H_E_TEMPLATE, "template: no stubs");
    ns = le32(b + p); p += 4;
    if (ns > NSTUB_MAX) return err(JP8H_E_TEMPLATE, "template: too many stubs");
    for (k = 0; k < ns; k++) {
        uint32_t nl;
        if (p + 12 > len - 4) return err(JP8H_E_TEMPLATE, "template: truncated stub");
        H.stub[k].addr = le64(b + p); nl = le32(b + p + 8); p += 12;
        if (nl >= sizeof H.stub[k].name || p + nl > len - 4) return err(JP8H_E_TEMPLATE, "template: stub name");
        memcpy(H.stub[k].name, b + p, nl); H.stub[k].name[nl] = 0; p += nl;
        if (k && H.stub[k].addr <= H.stub[k - 1].addr) return err(JP8H_E_TEMPLATE, "template: stubs not sorted");
    }
    H.nstub = (int)ns;
    for (k = 0; k < (uint32_t)H.nsl; k++) free(H.sl[k].e);
    H.ndib = H.nsl = H.ngd = H.nskin = H.nwin = 0; H.view = 0; H.scr_cx = H.scr_cy = 0;
    if (!H.fake_heap) H.fake_heap = 0x4242000000ULL;               /* jp8_emu.FAKE_HEAP (a v2 template names none) */
    if (ver == 3) {                                                   /* the GUI's import state */
        uint32_t nd, nl, ng, nk, j;
        if (p + 4 > len - 4 || (nd = le32(b + p)) > NDIB_MAX) return err(JP8H_E_TEMPLATE, "template: DIB sections");
        p += 4;
        for (k = 0; k < nd; k++, p += 32) {
            if (p + 32 > len - 4) return err(JP8H_E_TEMPLATE, "template: truncated DIB");
            H.dib[k].hb = le64(b + p); H.dib[k].w = (int32_t)le32(b + p + 8); H.dib[k].h = (int32_t)le32(b + p + 12);
            H.dib[k].bpp = le32(b + p + 16); H.dib[k].stride = le32(b + p + 20); H.dib[k].bits = le64(b + p + 24);
        }
        H.ndib = (int)nd;
        if (p + 4 > len - 4 || (nl = le32(b + p)) > NSL_MAX) return err(JP8H_E_TEMPLATE, "template: lists");
        p += 4;
        for (k = 0; k < nl; k++) {
            uint32_t n_;
            if (p + 12 > len - 4) return err(JP8H_E_TEMPLATE, "template: truncated list");
            H.sl[k].head = le64(b + p); n_ = le32(b + p + 8); p += 12;
            if (p + 8 * (size_t)n_ > len - 4) return err(JP8H_E_TEMPLATE, "template: truncated list entries");
            H.sl[k].cap = n_ > 16 ? (int)n_ : 16; H.sl[k].n = (int)n_;
            if (!(H.sl[k].e = (uint64_t *)malloc(sizeof(uint64_t) * (size_t)H.sl[k].cap))) return err(JP8H_E_TEMPLATE, "no memory");
            for (j = 0; j < n_; j++, p += 8) H.sl[k].e[j] = le64(b + p);
            H.nsl = (int)k + 1;
        }
        if (p + 4 > len - 4 || (ng = le32(b + p)) > NGD_MAX) return err(JP8H_E_TEMPLATE, "template: images");
        p += 4;
        for (k = 0; k < ng; k++, p += 20) {
            if (p + 20 > len - 4) return err(JP8H_E_TEMPLATE, "template: truncated image");
            H.gd[k].hd = le64(b + p); H.gd[k].w = le32(b + p + 8); H.gd[k].h = le32(b + p + 12); H.gd[k].fmt = le32(b + p + 16);
        }
        H.ngd = (int)ng;
        if (p + 4 > len - 4 || (nk = le32(b + p)) > NSKIN_MAX) return err(JP8H_E_TEMPLATE, "template: skin");
        p += 4;
        for (k = 0; k < nk; k++) {
            uint32_t nl_;
            if (p + 4 > len - 4) return err(JP8H_E_TEMPLATE, "template: truncated skin");
            nl_ = le32(b + p); p += 4;
            if (nl_ >= sizeof H.skin[k].name || p + nl_ + 8 > len - 4) return err(JP8H_E_TEMPLATE, "template: skin name");
            memcpy(H.skin[k].name, b + p, nl_); H.skin[k].name[nl_] = 0; p += nl_;
            H.skin[k].w = le32(b + p); H.skin[k].h = le32(b + p + 4); p += 8;
        }
        H.nskin = (int)nk;
    }
    if (p != len - 4) return err(JP8H_E_TEMPLATE, "template: trailing bytes");
    return JP8H_OK;
}

static uint64_t alloc_com(uint64_t n) { uint64_t p = H.com_next; H.com_next += (n + 15) & ~15ULL; return p; }
static uint64_t scratch(uint64_t off, size_t n) {   /* jp8_host_emu.JP8Host.scratch: a slot of the scratch area, cleared */
    void *p = jp8h_guest(H.scr + off, n); if (p) memset(p, 0, n); return H.scr + off;
}
static uint64_t new_obj(uint64_t vt) { uint64_t p = alloc_com(16); wq(p, vt); return p; }   /* wrapper_emu.new_obj */
static int live(void) { return H.st == 1 ? JP8H_OK : H.st == 2 ? JP8H_E_TRAP : err(JP8H_E_STATE, "not initialized"); }
/* wrapper_emu.vcall: the method at slot of obj's vtable, rcx = obj, then up to three arguments (absent ones 0) */
static int vcall(uint64_t obj, int slot, uint64_t a1, uint64_t a2, uint64_t a3, uint32_t *hr) {
    if (call(gq(gq(obj) + 8 * (uint64_t)slot), obj, a1, a2, a3)) return JP8H_E_TRAP;
    *hr = (uint32_t)H.cpu.r[0];
    return JP8H_OK;
}
static int setup_processing(double rate) {      /* host_process_emu.setup_processing: ProcessSetup {0, 0, max, rate} */
    uint8_t b[24]; int32_t v[3]; uint64_t setup = H.scr ? scratch(SCR_SETUP, 24) : alloc_com(24); uint32_t hr; int rc;
    v[0] = 0; v[1] = 0; v[2] = (int32_t)H.maxblock;
    memset(b, 0, sizeof b); memcpy(b, v, 12); memcpy(b + 16, &rate, 8); wmem(setup, b, 24);
    if ((rc = vcall(H.audio, 7, setup, 0, 0, &hr))) return rc;
    if (hr) return err(JP8H_E_STATE, "setupProcessing returned an error");
    H.rate = rate;
    return JP8H_OK;
}
static int set_active(int on) {                  /* host_process_emu.set_active */
    uint32_t hr; int rc = vcall(H.comp, 11, on ? 1 : 0, 0, 0, &hr);
    if (rc) return rc;
    return hr ? err(JP8H_E_STATE, "setActive returned an error") : JP8H_OK;
}

static int qi(const uint8_t iid[16], uint64_t *out) {    /* jp8_host_emu.JP8Host._qi: queryInterface, the controller */
    uint64_t b = scratch(SCR_QI, 0x40); uint32_t hr; int rc;
    wmem(b, iid, 16);
    if ((rc = vcall(H.ctrl, 0, b, b + 0x30, 0, &hr))) return rc;
    if (hr) return err(JP8H_E_STATE, "the controller does not answer an interface");
    *out = gq(b + 0x30);
    return JP8H_OK;
}
int jp8h_init(const void *tmpl, size_t len, double rate, int max_block) {
    int rc, i;
    H.st = 0; H.msg[0] = 0; H.nedit = 0; H.njobs = 0; H.in_job = 0; H.s_addr = 0; H.s_len = 0; H.s_pos = 0;
    H.scr = 0; H.mm = 0; H.ui = 0; H.com_end = 0; H.nparam = 0; H.nunit = 0;
    if (!tmpl) return err(JP8H_E_ARG, "no template");
    if (max_block <= 0 || !(rate > 0.0)) return err(JP8H_E_ARG, "rate or block size");
    if ((rc = load((const unsigned char *)tmpl, len)) != JP8H_OK) return rc;
#ifdef JP8H_TOOTH_NOREUSE                               /* the gate's tooth: the C side never reuses a freed block */
    jp8_heap_reuse(0);
#else
    jp8_heap_reuse(1);                  /* freed blocks reused from the template's point (jp8_host_emu.heap_reuse_on) */
#endif
    for (i = 0; i < H.nreg; i++) if (H.rbase[i] <= H.com_next && H.com_next < H.rbase[i] + H.rsize[i]) H.com_end = H.rbase[i] + H.rsize[i];
    if (!H.com_end) return err(JP8H_E_TEMPLATE, "template: the host-object area is in no region");
    memset(&H.cpu, 0, sizeof H.cpu); H.cpu.mxcsr = (uint32_t)H.mx0;
    {   /* the oracle's registers: they persist between its calls (only rsp, rcx, rdx, r8, r9 are written per call) */
        int r_;
        for (r_ = 0; r_ < 16; r_++) { H.cpu.r[r_] = H.reg[r_]; H.cpu.x[r_].q[0] = H.xreg[r_][0]; H.cpu.x[r_].q[1] = H.xreg[r_][1]; }
        H.cpu.cf = (int)(H.eflags & 1); H.cpu.pf = (int)((H.eflags >> 2) & 1); H.cpu.zf = (int)((H.eflags >> 6) & 1);
        H.cpu.sf = (int)((H.eflags >> 7) & 1); H.cpu.of = (int)((H.eflags >> 11) & 1);
    }
    H.st = 1;
    /* host_process_emu.setup (no DAW state, no setting): setupProcessing, setActive(1), then the blocks' objects */
    H.maxblock = (uint64_t)max_block;
    if ((rc = setup_processing(rate)) || (rc = set_active(1))) return rc;
    H.bufl = alloc_com(4 * H.maxblock); H.bufr = alloc_com(4 * H.maxblock);
    {
        uint64_t chans = alloc_com(16); uint8_t bus[24]; int32_t two = 2;
        wq(chans, H.bufl); wq(chans + 8, H.bufr);
        H.bus = alloc_com(24); memset(bus, 0, sizeof bus); memcpy(bus, &two, 4); memcpy(bus + 16, &chans, 8); wmem(H.bus, bus, 24);
    }
    H.ctx = alloc_com(160); H.pd = alloc_com(96);
    H.ev = new_obj(H.vt_events); H.pc = new_obj(H.vt_pchanges);
    for (i = 0; i < NPQ; i++) H.pq[i] = new_obj(H.vt_pqueue);    /* jp8_host_ref.py: every queue a block may use */
    {   /* jp8_host_emu.cc_index_table: every CC record's parameter id, in index order */
        uint64_t n = (gq(H.core + 32) - gq(H.core + 24)) / 24, k;
        if (n > NCC_MAX) return err(JP8H_E_STATE, "more CC records than this runtime holds");
        for (k = 0; k < n; k++) {
            if (call(IB + CC_INDEX, H.core + 24, k, 0, 0)) return JP8H_E_TRAP;
            H.cc_id[k] = (uint32_t)H.cpu.r[0];
        }
        H.ncc = (int)n;
    }
    /* jp8_host_emu.JP8Host.host_setup's rest, in its order: the scratch area, the controller's IMidiMapping and
     * IUnitInfo (queryInterface), its parameter and unit counts (the bounds this API checks: an index past them makes
     * the plugin throw), the one stream object every state call reuses */
    H.scr = alloc_com(SCR_SIZE);
    if ((rc = qi(IID_IMIDIMAPPING, &H.mm)) || (rc = qi(IID_IUNITINFO, &H.ui))) return rc;
    {
        uint32_t hr;
        if ((rc = vcall(H.ctrl, 8, 0, 0, 0, &hr))) return rc;
        H.nparam = (int32_t)hr;
        if ((rc = vcall(H.ui, 3, 0, 0, 0, &hr))) return rc;
        H.nunit = (int32_t)hr;
    }
    H.s_addr = new_obj(H.vt_stream);
    if (H.com_next > H.com_end) return err(JP8H_E_STATE, "the host objects do not fit the host-object region");
    return JP8H_OK;
}
int jp8h_set_rate(double rate) {                 /* a host-rate change: setActive(0), setupProcessing, setActive(1) */
    int rc = live();
    if (rc) return rc;
    if (!(rate > 0.0)) return err(JP8H_E_ARG, "rate");
#ifdef JP8H_TOOTH_RATE                                  /* the gate's tooth: the setActive after the new rate dropped */
    if ((rc = set_active(0)) || (rc = setup_processing(rate))) return rc;
#else
    if ((rc = set_active(0)) || (rc = setup_processing(rate)) || (rc = set_active(1))) return rc;
#endif
    return JP8H_OK;
}
int jp8h_set_active(int on) { int rc = live(); return rc ? rc : set_active(on); }
/* the UI timer's handler: the core's vtable slot 1 (rva 0x33A290) -- the parameter store from the mapped CCs, a
 * MIDI learn completed (jp8_host_emu.ui_drain) */
int jp8h_ui_tick(void) {
    int rc = live();
    if (rc) return rc;
#ifdef JP8H_TOOTH_NODRAIN                          /* the gate's tooth: the UI timer never drains */
    return JP8H_OK;
#endif
    return call(gq(gq(H.core) + 8), H.core, 0, 0, 0) ? JP8H_E_TRAP : JP8H_OK;
}
static int cc_record(uint32_t id) {              /* the oracle's {id: index}: a repeated id maps to its last index */
    int k, r = -1;
    for (k = 0; k < H.ncc; k++) if (H.cc_id[k] == id) r = k;
    return r;
}
int jp8h_cc_learn(uint32_t id) {                 /* jp8_host_emu.cc_learn: no record arms index 0xFFFFFFFF */
    int rc = live(), k;
    if (rc) return rc;
    k = cc_record(id);
    return call(IB + CC_LEARN, H.core + 24, k < 0 ? 0xFFFFFFFFULL : (uint64_t)k, 0, 0) ? JP8H_E_TRAP : JP8H_OK;
}
int jp8h_cc_forget(uint32_t id) {                /* jp8_host_emu.cc_forget: an id without a record calls nothing */
    int rc = live(), k;
    if (rc) return rc;
    k = cc_record(id);
    if (k < 0) return JP8H_OK;
    return call(IB + CC_FORGET, H.core + 24, (uint64_t)k, 0, 0) ? JP8H_E_TRAP : JP8H_OK;
}
static int new_stream(const void *data, size_t n) {    /* jp8_host_emu.JP8Host.stream(data): the one stream object */
    if (!H.s_addr) return err(JP8H_E_STATE, "no stream object");
    H.s_len = 0; H.s_pos = 0;
    if (n > H.s_cap) {
        unsigned char *d = (unsigned char *)realloc(H.s_data, n); if (!d) return err(JP8H_E_ARG, "no memory");
        H.s_data = d; H.s_cap = n;
    }
    if (n) memcpy(H.s_data, data, n);
    H.s_len = n;
    return JP8H_OK;
}
int jp8h_get_state(void *buf, size_t cap, size_t *n) {
    uint32_t hr; int rc = live();
    if (rc) return rc;
    if ((rc = new_stream(NULL, 0)) || (rc = vcall(H.comp, 13, H.s_addr, 0, 0, &hr))) return rc;
    if (hr) return err(JP8H_E_STATE, "getState returned an error");
    if (n) *n = H.s_len;
    if (buf && cap) memcpy(buf, H.s_data, H.s_len < cap ? H.s_len : cap);
    return JP8H_OK;
}
int jp8h_set_state(const void *data, size_t n, uint32_t *result) {
    uint32_t hr; int rc = live();
    if (rc) return rc;
    if (n && !data) return err(JP8H_E_ARG, "no state");
    if ((rc = new_stream(data, n)) || (rc = vcall(H.comp, 12, H.s_addr, 0, 0, &hr))) return rc;
    if (result) *result = hr;                    /* the plugin's answer (kResultFalse for a state it refuses) */
    return JP8H_OK;
}

/* ---------------------------------------------------------------- the edit controller's own calls
 * IEditController slot k of the controller (rcx), the parameter id (edx), a ParamValue as the third argument (xmm2, its
 * upper half 0 -- jp8_host_emu.ctl), r8 / r9 as given; the answer (eax) and xmm0 (a ParamValue result). The buffers
 * the calls write are bump-allocated in the host-object area as the oracle allocates them (each call: new ones). */
static int ctl(int slot, uint32_t id, double v, uint64_t r8, uint64_t r9, uint32_t *hr, uint64_t *x0) {
    uint64_t bits; int rc = live();
    if (rc) return rc;
    memcpy(&bits, &v, 8); H.cpu.x[2].q[0] = bits; H.cpu.x[2].q[1] = 0;
    if (call(gq(gq(H.ctrl) + 8 * (uint64_t)slot), H.ctrl, id, r8, r9)) return JP8H_E_TRAP;
    if (hr) *hr = (uint32_t)H.cpu.r[0];
    if (x0) *x0 = H.cpu.x[0].q[0];
    return JP8H_OK;
}
static double dbl(uint64_t q) { double d; memcpy(&d, &q, 8); return d; }
int jp8h_param_get(uint32_t id, double *v) { uint64_t x; int rc = ctl(14, id, 0.0, 0, 0, NULL, &x); if (!rc && v) *v = dbl(x); return rc; }
int jp8h_param_set(uint32_t id, double v, uint32_t *hr) { return ctl(15, id, v, 0, 0, hr, NULL); }
int jp8h_param_to_plain(uint32_t id, double v, double *plain) { uint64_t x; int rc = ctl(12, id, v, 0, 0, NULL, &x); if (!rc && plain) *plain = dbl(x); return rc; }
int jp8h_param_to_norm(uint32_t id, double plain, double *v) { uint64_t x; int rc = ctl(13, id, plain, 0, 0, NULL, &x); if (!rc && v) *v = dbl(x); return rc; }
int jp8h_param_string(uint32_t id, double v, uint16_t out[128], uint32_t *hr) {      /* String128: UTF-16, 0-ended */
    uint64_t buf; int rc = live();
    if (rc) return rc;
    buf = scratch(SCR_STR, 256);
    if ((rc = ctl(10, id, v, 0, buf, hr, NULL))) return rc;
    if (out) memcpy(out, jp8h_guest(buf, 256), 256);
    return JP8H_OK;
}
int jp8h_param_parse(uint32_t id, const uint16_t *text, double *v, uint32_t *hr) {   /* text: UTF-16, 0-ended */
    uint64_t sp, vp; size_t n = 0; int rc = live();
    if (rc) return rc;
    if (!text) return err(JP8H_E_ARG, "no text");
    while (text[n]) n++;
    if (2 * (n + 1) > 256) return err(JP8H_E_ARG, "a text above 127 characters");
    sp = scratch(SCR_TEXT, 256); wmem(sp, text, 2 * (n + 1)); vp = scratch(SCR_VAL, 8);
    if ((rc = ctl(11, id, 0.0, sp, vp, hr, NULL))) return rc;
    if (v) memcpy(v, jp8h_guest(vp, 8), 8);
    return JP8H_OK;
}
/* the gate: the raw answer and xmm0 of a get / set / plain / norm call (the C driver grades the bits) */
int jp8h_ctl_raw(int slot, uint32_t id, double v, uint32_t *hr, uint64_t *x0) {
    if (slot != 12 && slot != 13 && slot != 14 && slot != 15) return err(JP8H_E_ARG, "not a value call");
    return ctl(slot, id, v, 0, 0, hr, x0);
}

/* ---------------------------------------------------------------- what a DAW asks the controller (v6; jp8_host_emu
 * JP8Host.info_step: the same calls, the same scratch slots) */
int jp8h_param_count(int32_t *n) {
    uint32_t hr; int rc = live();
    if (rc) return rc;
    if ((rc = vcall(H.ctrl, 8, 0, 0, 0, &hr))) return rc;
    if (n) *n = (int32_t)hr;
    return JP8H_OK;
}
int jp8h_param_info(int32_t index, jp8h_pinfo *info, uint32_t *result) {
    uint64_t b; uint32_t hr; const unsigned char *g; int rc = live();
    if (rc) return rc;
    if (index < 0 || index >= H.nparam) return err(JP8H_E_ARG, "a parameter index outside [0, count) (the plugin throws)");
    b = scratch(SCR_INFO, 792);
    if ((rc = vcall(H.ctrl, 9, (uint64_t)(uint32_t)index, b, 0, &hr))) return rc;
    if (result) *result = hr;
    g = (const unsigned char *)jp8h_guest(b, 792);
    if (info && g) {                           /* VST3 ParameterInfo, field by field */
        memcpy(&info->id, g, 4); memcpy(info->title, g + 4, 256); memcpy(info->short_title, g + 260, 256);
#ifdef JP8H_TOOTH_INFO                                   /* the gate's tooth: the short title copied from the title */
        memcpy(info->short_title, g + 4, 256);
#endif
        memcpy(info->units, g + 516, 256); memcpy(&info->step_count, g + 772, 4); memcpy(&info->default_value, g + 776, 8);
        memcpy(&info->unit_id, g + 784, 4); memcpy(&info->flags, g + 788, 4);
    }
    return JP8H_OK;
}
int jp8h_midi_assignment(int32_t bus, int16_t channel, int16_t cc, uint32_t *id, uint32_t *result) {
    uint64_t b; uint32_t v; int rc = live();
    if (rc) return rc;
    b = scratch(SCR_VAL, 8);
    wq(H.rsp + 0x20, b);                       /* the ParamID& at [rsp + 0x28] at entry (the call pushes its return) */
    if (call(gq(gq(H.mm) + 8 * 3), H.mm, (uint64_t)(int64_t)bus, (uint64_t)(int64_t)channel, (uint64_t)(int64_t)cc)) return JP8H_E_TRAP;
    if (result) *result = (uint32_t)H.cpu.r[0];
    v = (uint32_t)gi(b);
    if (id) *id = v;
    return JP8H_OK;
}
int jp8h_unit_count(int32_t *n) {
    uint32_t hr; int rc = live();
    if (rc) return rc;
    if ((rc = vcall(H.ui, 3, 0, 0, 0, &hr))) return rc;
    if (n) *n = (int32_t)hr;
    return JP8H_OK;
}
int jp8h_unit_info(int32_t index, jp8h_uinfo *info, uint32_t *result) {
    uint64_t b; uint32_t hr; const unsigned char *g; int rc = live();
    if (rc) return rc;
    if (index < 0 || index >= H.nunit) return err(JP8H_E_ARG, "a unit index outside [0, count) (the plugin throws)");
    b = scratch(SCR_UNIT, 268);
    if ((rc = vcall(H.ui, 4, (uint64_t)(uint32_t)index, b, 0, &hr))) return rc;
    if (result) *result = hr;
    g = (const unsigned char *)jp8h_guest(b, 268);
    if (info && g) {                           /* VST3 UnitInfo */
        memcpy(&info->id, g, 4); memcpy(&info->parent_id, g + 4, 4); memcpy(info->name, g + 8, 256); memcpy(&info->program_list_id, g + 264, 4);
    }
    return JP8H_OK;
}
int jp8h_program_list_count(int32_t *n) {
    uint32_t hr; int rc = live();
    if (rc) return rc;
    if ((rc = vcall(H.ui, 5, 0, 0, 0, &hr))) return rc;
    if (n) *n = (int32_t)hr;
    return JP8H_OK;
}
int jp8h_selected_unit(int32_t *id) {
    uint32_t hr; int rc = live();
    if (rc) return rc;
    if ((rc = vcall(H.ui, 11, 0, 0, 0, &hr))) return rc;
    if (id) *id = (int32_t)hr;
    return JP8H_OK;
}
int jp8h_select_unit(int32_t id, uint32_t *result) {
    uint32_t hr; int rc = live();
    if (rc) return rc;
    if ((rc = vcall(H.ui, 12, (uint64_t)(int64_t)id, 0, 0, &hr))) return rc;
    if (result) *result = hr;
    return JP8H_OK;
}
int jp8h_ctl_get_state(void *buf, size_t cap, size_t *n, uint32_t *result) {   /* IEditController::getState */
    uint32_t hr; int rc = live();
    if (rc) return rc;
    if ((rc = new_stream(NULL, 0)) || (rc = vcall(H.ctrl, 7, H.s_addr, 0, 0, &hr))) return rc;
    if (result) *result = hr;
    if (n) *n = H.s_len;
    if (buf && cap) memcpy(buf, H.s_data, H.s_len < cap ? H.s_len : cap);
    return JP8H_OK;
}
int jp8h_ctl_set_state(const void *data, size_t n, uint32_t *result) {          /* IEditController::setState */
    uint32_t hr; int rc = live();
    if (rc) return rc;
    if (n && !data) return err(JP8H_E_ARG, "no state");
    if ((rc = new_stream(data, n)) || (rc = vcall(H.ctrl, 6, H.s_addr, 0, 0, &hr))) return rc;
    if (result) *result = hr;
    return JP8H_OK;
}
int jp8h_component_state(const void *data, size_t n, uint32_t *result) {        /* IEditController::setComponentState */
    uint32_t hr; int rc = live();
    if (rc) return rc;
    if (n && !data) return err(JP8H_E_ARG, "no state");
    if ((rc = new_stream(data, n)) || (rc = vcall(H.ctrl, 5, H.s_addr, 0, 0, &hr))) return rc;
    if (result) *result = hr;
    return JP8H_OK;
}
void jp8h_heap_stats(uint64_t *live_blocks, uint64_t *free_blocks) { jp8_heap_stats(live_blocks, free_blocks); }

int jp8h_load_patch(const void *rec, size_t n) {
    uint64_t data, vec; int rc = live();
    if (rc) return rc;
    if (n + 16 > SCR_PATCH_N) return err(JP8H_E_ARG, "a record above the scratch area");
    data = scratch(SCR_PATCH, SCR_PATCH_N); vec = scratch(SCR_VEC, 24);   /* jp8_host_emu.JP8Host.load_patch */
    wmem(data, rec, n); wq(vec, data); wq(vec + 8, data + n); wq(vec + 16, data + n);
    return call(H.patch_fn, vec, gq(H.comp + 280 + 8), 0, 0) ? JP8H_E_TRAP : JP8H_OK;   /* rdx read now, as the oracle does */
}

int jp8h_process(int n, const jp8h_event *ev, int nev, const jp8h_param *par, int npar, const jp8h_ctx *ctx,
                 uint32_t *outl, uint32_t *outr) {
    uint8_t pd[96]; uint64_t cptr = 0; int i, rc = live();
    if (rc) return rc;
    if (n < 0 || (uint64_t)n > H.maxblock || nev < 0 || nev > MAXEV || npar < 0) return err(JP8H_E_ARG, "block, events or parameters out of range");
    /* the events: host_process_emu.process's 48-byte VST3 Events */
    H.nev = nev;
    for (i = 0; i < nev; i++) {
        uint8_t *b = H.evs[i]; int32_t off = ev[i].offset; int16_t ch = (int16_t)ev[i].channel, pitch = (int16_t)ev[i].pitch;
        float z = 0.0f, vel = ev[i].velocity; int32_t m1 = -1; uint16_t t;
        memset(b, 0, 48); memcpy(b + 4, &off, 4);
        if (ev[i].on) { t = 0; memcpy(b + 18, &t, 2); memcpy(b + 24, &ch, 2); memcpy(b + 26, &pitch, 2); memcpy(b + 28, &z, 4); memcpy(b + 32, &vel, 4); memcpy(b + 36, &m1, 4); memcpy(b + 40, &m1, 4); }
        else { t = 1; memcpy(b + 18, &t, 2); memcpy(b + 24, &ch, 2); memcpy(b + 26, &pitch, 2); memcpy(b + 28, &vel, 4); memcpy(b + 32, &m1, 4); }
    }
    /* the parameter changes: one queue per id, in the order the ids first appear (the oracle's dict order) */
    H.npq = 0;
    for (i = 0; i < npar; i++) {
        int q;
#ifdef JP8H_TOOTH_SWEEP                                  /* the gate's tooth: host automation of EFFECT TYPE never arrives */
        if (par[i].id == 0x600258u) continue;
#endif
        for (q = 0; q < H.npq; q++) if (H.pq_id[q] == par[i].id) break;
        if (q == H.npq) {
            if (H.npq == NPQ) return err(JP8H_E_ARG, "more parameter ids in one block than the template's queues");
            H.pq_id[q] = par[i].id; H.pq_n[q] = 0; H.npq++;
            free(H.pq_off[q]); free(H.pq_val[q]);
            H.pq_off[q] = (int32_t *)malloc(sizeof(int32_t) * (size_t)npar); H.pq_val[q] = (double *)malloc(sizeof(double) * (size_t)npar);
            if (!H.pq_off[q] || !H.pq_val[q]) return err(JP8H_E_ARG, "no memory");
        }
        H.pq_off[q][H.pq_n[q]] = par[i].offset; H.pq_val[q][H.pq_n[q]] = par[i].value; H.pq_n[q]++;
    }
    if (ctx) {      /* host_process_emu.process's ProcessContext: state, the host rate, ppq, the cycle, the tempo */
        uint8_t c[160];
        memset(c, 0, sizeof c); memcpy(c, &ctx->state, 4); memcpy(c + 8, &H.rate, 8); memcpy(c + 40, &ctx->ppq, 8);
#ifdef JP8H_TOOTH_TRANSPORT     /* the gate's tooth: the transport always playing, never looping (v8's stops / loop) */
        { uint32_t st = (ctx->state | 0x2u) & ~0x4u; memcpy(c, &st, 4); }
#endif
        memcpy(c + 56, &ctx->cycle_start, 8); memcpy(c + 64, &ctx->cycle_end, 8); memcpy(c + 72, &ctx->tempo, 8);
        wmem(H.ctx, c, sizeof c); cptr = H.ctx;
    }
    memset(pd, 0, sizeof pd);
    { int32_t v[5]; v[0] = 0; v[1] = 0; v[2] = n; v[3] = 0; v[4] = 1; memcpy(pd, v, sizeof v); }
    { uint64_t q7[7]; q7[0] = 0; q7[1] = H.bus; q7[2] = npar ? H.pc : 0; q7[3] = 0; q7[4] = nev ? H.ev : 0; q7[5] = 0; q7[6] = cptr;
      memcpy(pd + 24, q7, sizeof q7); }
    wmem(H.pd, pd, sizeof pd);
    if (n) {
        void *l = jp8h_guest(H.bufl, 4 * (size_t)n), *r = jp8h_guest(H.bufr, 4 * (size_t)n);
        if (!l || !r) return err(JP8H_E_STATE, "output buffers");
        memset(l, 0, 4 * (size_t)n); memset(r, 0, 4 * (size_t)n);
    }
    if (call(H.process_fn, H.audio, H.pd, 0, 0)) return JP8H_E_TRAP;
    if ((uint32_t)H.cpu.r[0] != 0) return err(JP8H_E_STATE, "process() returned an error");
    if (n) { memcpy(outl, jp8h_guest(H.bufl, 4 * (size_t)n), 4 * (size_t)n); memcpy(outr, jp8h_guest(H.bufr, 4 * (size_t)n), 4 * (size_t)n); }
    return JP8H_OK;
}

uint64_t jp8h_heap_top(void) { return jp8_heap_get(); }
uint64_t jp8h_jobs(void) { return H.njobs; }
uint64_t jp8h_com_next(void) { return H.com_next; }
/* ---------------------------------------------------------------- v8 (E1): the editor (jp8_host_emu.editor_attach) */
int jp8h_screen(int32_t cx, int32_t cy) {           /* the machine's virtual screen: GetSystemMetrics 78 / 79 */
    int rc = live(); if (rc) return rc;
    H.scr_cx = cx; H.scr_cy = cy; return JP8H_OK;
}
int jp8h_attach_editor(uint64_t *view, uint32_t *result) {   /* createView("editor"), attached(parent, "HWND") */
    uint64_t name, t; int rc = live(); if (rc) return rc;
    name = scratch(SCR_EDNAME, 16); wmem(name, "editor", 7);
    t = scratch(SCR_EDTYPE, 16); wmem(t, "HWND", 5);
    if (call(gq(gq(H.ctrl) + 8 * 17), H.ctrl, name, 0, 0)) return JP8H_E_TRAP;              /* IEditController::createView */
    H.view = H.cpu.r[0];
    if (!H.view) return err(JP8H_E_STATE, "createView(\"editor\") gave no view");
    if (call(gq(gq(H.view) + 8 * 4), H.view, 0x10010, t, 0)) return JP8H_E_TRAP;           /* IPlugView::attached */
    if (view) *view = H.view;
    if (result) *result = (uint32_t)H.cpu.r[0];
    return JP8H_OK;
}
int jp8h_window_zoom(int32_t w, int32_t h, int32_t *zoom) {  /* host_process_emu.window_conv: the window's zoom getter */
    int i, rc = live(); if (rc) return rc;
    for (i = 0; i < H.nwin && !(H.win[i].w == w && H.win[i].h == h); i++) {}
    if (i == H.nwin) return err(JP8H_E_ARG, "no window of that size has laid itself out");
    if (call(IB + ZOOM_GET, H.win[i].win, 0, 0, 0)) return JP8H_E_TRAP;
    if (zoom) *zoom = (int32_t)(uint32_t)H.cpu.r[0];
    return JP8H_OK;
}
int jp8h_windows(int32_t *wh, int cap) {            /* the windows laid out so far: w, h pairs; the count returned */
    int i;
    for (i = 0; i < H.nwin && i < cap; i++) { wh[2 * i] = H.win[i].w; wh[2 * i + 1] = H.win[i].h; }
    return H.nwin;
}
int jp8h_threaded(void) {                  /* 1: the workers run on threads (their stacks are their own) */
#ifdef JP8H_THREADS
    return 1;
#else
    return 0;
#endif
}
int jp8h_edits(uint32_t *id, double *val, int cap) {
    int i, n = H.nedit < cap ? H.nedit : cap;
    for (i = 0; i < n; i++) { id[i] = H.edit_id[i]; val[i] = H.edit_val[i]; }
    return H.nedit;
}

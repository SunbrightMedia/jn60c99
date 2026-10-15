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
#ifndef JP8_RELOC
#error "jn_host.c needs JP8_RELOC"
#endif

#define IB            0x180000000ULL
#define ENGINE_RENDER 0x3C7400ULL     /* CWaveGen vt+56: the engine render's thread transport (served by the host) */
#define UITICK        0x320120ULL     /* the plugin's UI timer (host_process_emu drains it through the core) */
#define CC_LEARN      0x31AA40ULL     /* the CC menu's Learn: rcx = core + 24, edx = the record index */
#define CC_FORGET     0x3192E0ULL     /* the CC menu's Forget */
#define REC_ID        0x319C50ULL     /* the record at an index -> its parameter id: rcx = core + 24, edx = index */
#define MODEL_SET     0x283DB0ULL     /* the editor's record set: rcx = model, rdx = object, r8 = value, r9 = 1 */
#define PROCESS_SLOT  9               /* IAudioProcessor::process (rva 0x34A380) */
#define NPQ           8               /* parameter queues a block may use (one per parameter id) */
#define NCC_MAX       1024
#define NREG_MAX      16
#define NSTUB_MAX     4096
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

/* ---------------------------------------------------------------- the host objects and the imports (jp8_hostcall) */
void jp8_hostcall(CPU *c, uint64_t target) {
    const char *n = stub_name(target); uint64_t rcx = c->r[1], rdx = c->r[2], r8 = c->r[8], r9 = c->r[9];
    char msg[112];
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
    /* the imports the host path reaches, answered as the oracle's shims answer them (e2e_emu / wrapper_emu) */
    if (!strcmp(n, "AcquireSRWLockExclusive") || !strcmp(n, "ReleaseSRWLockExclusive") ||
        !strcmp(n, "AcquireSRWLockShared") || !strcmp(n, "ReleaseSRWLockShared") ||
        !strcmp(n, "EnterCriticalSection") || !strcmp(n, "LeaveCriticalSection") ||
        !strncmp(n, "Initialize", 10) || !strcmp(n, "DeleteCriticalSection")) { c->r[0] = 1; return; }
    if (!strcmp(n, "GetCurrentThreadId") || !strcmp(n, "GetCurrentProcessId")) { c->r[0] = 0x1000; return; }
    if (!strcmp(n, "GetProcessHeap")) { c->r[0] = H.fake_heap ? H.fake_heap : 0x4242000000ULL; return; }
    if (!strcmp(n, "HeapAlloc") || !strcmp(n, "calloc")) { c->r[0] = jp8_heap_alloc(r8 ? r8 : rdx ? rdx : 16); return; }
    if (!strcmp(n, "HeapReAlloc")) { c->r[0] = jp8_heap_alloc(r9); return; }
    if (!strcmp(n, "malloc")) { c->r[0] = jp8_heap_alloc(rcx ? rcx : 16); return; }
    if (!strcmp(n, "HeapFree") || !strcmp(n, "free") || !strcmp(n, "??3@YAXPEAX@Z")) { jp8_heap_free(!strcmp(n, "HeapFree") ? r8 : rcx); c->r[0] = 1; return; }
    if (!strcmp(n, "EncodePointer") || !strcmp(n, "DecodePointer")) { c->r[0] = rcx; return; }
    if (!strcmp(n, "GetLastError")) { c->r[0] = H.lasterr & 0xFFFFFFFFu; return; }
    if (!strcmp(n, "SetLastError")) { H.lasterr = rcx & 0xFFFFFFFFu; c->r[0] = 0; return; }
    if (!strcmp(n, "GetFocus") || !strcmp(n, "SetFocus")) { c->r[0] = 0; return; }
    if (!strcmp(n, "IsProcessorFeaturePresent")) { c->r[0] = 1; return; }
    if (!strcmp(n, "GetCurrentProcess")) { c->r[0] = 0; return; }
    if (!strncmp(n, "Create", 6) || !strncmp(n, "Open", 4)) { c->r[0] = jp8_hc_next(); return; }
    if (!strcmp(n, "ResumeThread") || !strcmp(n, "GetModuleHandleExW") || !strcmp(n, "IsDebuggerPresent")) { c->r[0] = 0; return; }
    if (!strcmp(n, "RaiseException")) {
        if ((uint32_t)rcx == 0xE06D7363u) { jp8_trap(c, target, "the plugin threw a C++ exception (RaiseException 0xE06D7363)"); return; }
        c->r[0] = 0; return;
    }
    snprintf(msg, sizeof msg, "import %s not shimmed on the host path (from rva 0x%llx)", n,
             (unsigned long long)(gq(c->r[4]) - IB));
    jp8_trap(c, target, msg);
}
int jp8_thunk(CPU *c, uint64_t target) { (void)c; (void)target; return 0; }   /* no ATL run-time thunk on the host path (yet) */

/* ---------------------------------------------------------------- the render transport (--replace 0x3C7400) */
void jp8_hook(CPU *c, uint64_t rva) {
    if (rva == ENGINE_RENDER) {
        /* TODO L4/L5: compose the render over the plugin's own voice (0x398F30) / master (0x398EC0) as the oracle's
         * host_process_emu._serve does; for now the static paths (init, patch, state, UI, CC, editor set) do not
         * reach it. A reach here before the composition is written is a named stop, never a silent zero. */
        jp8_trap(c, rva, "the engine render composition is not written yet (L4/L5 process path)");
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
        else if (key[0] == 'r' && key[1] >= '0' && key[1] <= '9') { int r_ = atoi(key + 1); if (r_ >= 0 && r_ < 16) H.reg[r_] = v; }
        else if (key[0] == 'x' && key[1] >= '0' && key[1] <= '9') {
            int r_ = atoi(key + 1); const char *t = strstr(key, "hi"); if (r_ >= 0 && r_ < 16) H.xreg[r_][t ? 1 : 0] = v;
        }
#undef KV
    }
    if (!H.audio || !H.comp || !H.core || !H.ctrl || !H.process_fn || !H.patch_fn || !H.vt_events || !H.vt_pchanges || !H.vt_pqueue || !H.vt_stream)
        return err(JUNOH_E_TEMPLATE, "template: a fact is missing");
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
    memset(&H.njobs, 0, 0); H.st = 0; H.msg[0] = 0; H.nedit = 0; H.njobs = 0; H.s_addr = 0; H.s_len = 0; H.s_pos = 0; H.nev = 0; H.npq = 0;
    if (!tmpl) return err(JUNOH_E_ARG, "no template");
    if (max_block <= 0 || !(rate > 0.0)) return err(JUNOH_E_ARG, "rate or block size");
    if ((rc = load((const unsigned char *)tmpl, len)) != JUNOH_OK) return rc;
    jp8_heap_reuse(1);                          /* the host's heap reuses freed blocks from the template's point */
    memset(&H.cpu, 0, sizeof H.cpu); H.cpu.mxcsr = (uint32_t)H.mx0;
    for (i = 0; i < 16; i++) { H.cpu.r[i] = H.reg[i]; H.cpu.x[i].q[0] = H.xreg[i][0]; H.cpu.x[i].q[1] = H.xreg[i][1]; }
    H.cpu.cf = (int)(H.eflags & 1); H.cpu.pf = (int)((H.eflags >> 2) & 1); H.cpu.zf = (int)((H.eflags >> 6) & 1);
    H.cpu.sf = (int)((H.eflags >> 7) & 1); H.cpu.of = (int)((H.eflags >> 11) & 1);
    H.st = 1;
    /* host_process_emu.setup: setupProcessing, setActive(1), then the blocks' host objects in its order */
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

/* ---------------------------------------------------------------- process() -- TODO L4/L5 (needs the render) */
int junoh_process(int n, const junoh_event *ev, int nev, const junoh_param *par, int npar, const junoh_ctx *ctx,
                  uint32_t *outl, uint32_t *outr) {
    (void)n; (void)ev; (void)nev; (void)par; (void)npar; (void)ctx; (void)outl; (void)outr;
    return err(JUNOH_E_STATE, "junoh_process is not written yet (the render composition is the next L4/L5 step)");
}

/* ---------------------------------------------------------------- the gates' accessors */
uint64_t junoh_heap_top(void) { return jp8_heap_get(); }
uint64_t junoh_com_next(void) { return H.com_next; }
uint64_t junoh_renders(void) { return H.njobs; }
uint64_t junoh_core(void) { return H.core; }
int junoh_edits(uint32_t *id, double *val, int cap) {
    int i, m = H.nedit < cap ? H.nedit : cap;
    for (i = 0; i < m; i++) { id[i] = H.edit_id[i]; val[i] = H.edit_val[i]; }
    return H.nedit;
}

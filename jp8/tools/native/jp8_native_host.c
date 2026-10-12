/* jp8_native_host.c -- THE NATIVE ORACLE (scope row 23): the real JUPITER-8 plugin in a real Windows process (wine
 * on Linux), booted as the Unicorn oracle boots it (jp8_host_emu.JP8Host.boot_host: DllMain by LoadLibrary, InitDll,
 * the processor from the factory, IComponent::initialize, the controller from the factory, initialize, both
 * IConnectionPoints connected, a component handler, setComponentState), set up as host_setup sets it up
 * (setupProcessing, setActive(1)), a factory record through the plugin's own patch load (rva 0x355F90, as
 * wrapper_emu.load_patch calls it), then a render plan (jp8/apps/jp8_render's plan.txt: B / E / P lines) replayed
 * through the plugin's own process(); every output word to a file. Harness only: every host answer mirrors the
 * Unicorn oracle's host objects (probes/b6/wrapper_emu.py, tools/verify/host_process_emu.py). What differs from that
 * oracle is the machine: a CPU runs the plugin, so FTZ flushes a denormal RESULT as on a PC (Unicorn never does).
 *   x86_64-w64-mingw32-gcc -O1 -o jp8_native_host.exe jp8_native_host.c
 *   wine64 jp8_native_host.exe <module.vst3> <record.bin> <plan.txt> <rate> <out.bin> [maxblock=512]
 * plan lines: B n (a block), E on offset channel pitch vel-bits (a note), P id offset value-bits (a queue point),
 * C state ppq tempo cycle-start cycle-end (the block's ProcessContext, as jp8/src/jp8_host.c's jp8h_process builds it:
 * state, the host rate, ppq, the cycle, the tempo; the rest 0) -- jp8/tools/native/jp8_plan_replay.c reads the same.
 * (jp8_native_check.py lays the module out as the plugin expects -- its Script folder beside it -- and grades.
 * maxblock: setupProcessing's maximum block; 512 is what jp8/apps/jp8_render's jp8h_init asks for.) */
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

typedef long tresult;
#define S_OK_ 0
#define S_FALSE_ 1
#define E_NOINTERFACE_ ((tresult)0x80004002L)
#define E_FAIL_ ((tresult)0x80004005L)
#define E_NOTIMPL_ ((tresult)0x80004001L)
#define PATCH_LOAD 0x355F90u                     /* the patch browser's load (jp8_host_emu PROFILE PATCH_LOAD) */
#define MAXBLOCK 16384

static void vst_iid(uint8_t *o, uint32_t l1, uint32_t l2, uint32_t l3, uint32_t l4) {   /* wrapper_emu.vst_iid */
    o[0] = (uint8_t)l1; o[1] = (uint8_t)(l1 >> 8); o[2] = (uint8_t)(l1 >> 16); o[3] = (uint8_t)(l1 >> 24);
    o[4] = (uint8_t)(l2 >> 16); o[5] = (uint8_t)(l2 >> 24); o[6] = (uint8_t)l2; o[7] = (uint8_t)(l2 >> 8);
    o[8] = (uint8_t)(l3 >> 24); o[9] = (uint8_t)(l3 >> 16); o[10] = (uint8_t)(l3 >> 8); o[11] = (uint8_t)l3;
    o[12] = (uint8_t)(l4 >> 24); o[13] = (uint8_t)(l4 >> 16); o[14] = (uint8_t)(l4 >> 8); o[15] = (uint8_t)l4;
}
static uint8_t IID_COMPONENT[16], IID_EDITCONTROLLER[16], IID_CONNECTIONPOINT[16], IID_AUDIOPROCESSOR[16],
    IID_HANDLER[16], IID_HOSTAPP[16], IID_MESSAGE[16], IID_ATTRS[16], IID_BSTREAM[16];

/* ---------------------------------------------------------------- the host's objects (one struct, a kind each) */
enum { K_HOSTCTX, K_HANDLER, K_STREAM, K_MESSAGE, K_ATTRS, K_EVENTS, K_PCHANGES, K_PQUEUE };
#define NATTR 64
typedef struct Obj {
    void **vt; int kind;
    /* stream */ uint8_t *data; size_t len, cap; int64_t pos;
    /* message */ char *msgid; struct Obj *attrs;
    /* attrs */ int nattr; struct { char key[64]; char type; int64_t i; uint64_t f; uint16_t s[256]; void *b; uint32_t bn; } at[NATTR];
    /* events */ int nev; uint8_t (*ev)[48];
    /* pchanges */ int nq; struct Obj **q;
    /* pqueue */ uint32_t id; int np, qcap; int32_t *off; double *val;
} Obj;
static Obj *new_obj(void **vt, int kind) { Obj *o = (Obj *)calloc(1, sizeof(Obj)); o->vt = vt; o->kind = kind; return o; }

static tresult qi_common(Obj *o, const uint8_t *iid, void **out) {
    const uint8_t *mine = o->kind == K_HOSTCTX ? IID_HOSTAPP : o->kind == K_HANDLER ? IID_HANDLER : o->kind == K_STREAM ? IID_BSTREAM
                        : o->kind == K_MESSAGE ? IID_MESSAGE : o->kind == K_ATTRS ? IID_ATTRS : NULL;
    if (mine && !memcmp(iid, mine, 16)) { *out = o; return S_OK_; }
    *out = NULL; return E_NOINTERFACE_;
}
static tresult m_qi(Obj *o, const uint8_t *iid, void **out) { return qi_common(o, iid, out); }
static unsigned long m_ref(Obj *o) { (void)o; return 1; }
static tresult m_notimpl(Obj *o) { (void)o; return E_NOTIMPL_; }

/* IHostApplication: getName "emu"; createInstance makes IMessage / IAttributeList */
static void *vt_message[8], *vt_attrs[12];
static tresult hc_getName(Obj *o, uint16_t *name) { (void)o; name[0] = 'e'; name[1] = 'm'; name[2] = 'u'; name[3] = 0; return S_OK_; }
static tresult hc_create(Obj *o, const uint8_t *cid, const uint8_t *iid, void **out) {
    (void)o; (void)cid;
    if (!memcmp(iid, IID_MESSAGE, 16)) { Obj *m = new_obj(vt_message, K_MESSAGE); m->attrs = new_obj(vt_attrs, K_ATTRS); *out = m; return S_OK_; }
    if (!memcmp(iid, IID_ATTRS, 16)) { *out = new_obj(vt_attrs, K_ATTRS); return S_OK_; }
    *out = NULL; return E_NOINTERFACE_;
}
/* IMessage */
static const char *msg_getId(Obj *o) { return o->msgid; }
static void msg_setId(Obj *o, const char *id) { size_t n = strlen(id) + 1; o->msgid = (char *)malloc(n); memcpy(o->msgid, id, n); }
static Obj *msg_attrs(Obj *o) { return o->attrs; }
/* IAttributeList */
static int at_find(Obj *o, const char *k) { int i; for (i = 0; i < o->nattr; i++) if (!strcmp(o->at[i].key, k)) return i; return -1; }
static int at_slot(Obj *o, const char *k) {
    int i = at_find(o, k);
    if (i < 0) { if (o->nattr >= NATTR) { fprintf(stderr, "too many attributes\n"); exit(3); } i = o->nattr++; strncpy(o->at[i].key, k, 63); }
    return i;
}
static tresult at_setInt(Obj *o, const char *k, int64_t v) { int i = at_slot(o, k); o->at[i].type = 'i'; o->at[i].i = v; return S_OK_; }
static tresult at_getInt(Obj *o, const char *k, int64_t *v) { int i = at_find(o, k); if (i < 0) return S_FALSE_; *v = o->at[i].i; return S_OK_; }
static tresult at_setFloat(Obj *o, const char *k, double v) { int i = at_slot(o, k); o->at[i].type = 'f'; memcpy(&o->at[i].f, &v, 8); return S_OK_; }
static tresult at_getFloat(Obj *o, const char *k, double *v) { int i = at_find(o, k); if (i < 0) return S_FALSE_; memcpy(v, &o->at[i].f, 8); return S_OK_; }
static tresult at_setString(Obj *o, const char *k, const uint16_t *s) {
    int i = at_slot(o, k), j; o->at[i].type = 's';
    for (j = 0; j < 255 && s[j]; j++) o->at[i].s[j] = s[j];
    o->at[i].s[j] = 0; return S_OK_;
}
static tresult at_getString(Obj *o, const char *k, uint16_t *s, uint32_t size) {
    int i = at_find(o, k), j; uint32_t n;
    if (i < 0) return S_FALSE_;
    n = size / 2 ? size / 2 : 1;                 /* wrapper_emu: the string's bytes and its zero, cut to max(2, size) bytes */
    for (j = 0; (uint32_t)j < n; j++) { s[j] = o->at[i].s[j]; if (!o->at[i].s[j]) break; }
    return S_OK_;
}
static tresult at_setBinary(Obj *o, const char *k, const void *d, uint32_t n) {
    int i = at_slot(o, k); o->at[i].type = 'b'; o->at[i].b = malloc(n > 16 ? n : 16); if (n) memcpy(o->at[i].b, d, n); o->at[i].bn = n; return S_OK_;
}
static tresult at_getBinary(Obj *o, const char *k, const void **d, uint32_t *n) {
    int i = at_find(o, k); if (i < 0) return S_FALSE_; *d = o->at[i].b; *n = o->at[i].bn; return S_OK_;
}
/* IComponentHandler: accept every call (wrapper_emu records them; the result is 0) */
static tresult h_any(Obj *o) { (void)o; return S_OK_; }
/* IBStream */
static tresult st_read(Obj *o, void *buf, int32_t n, int32_t *got) {
    int64_t avail = (int64_t)o->len - o->pos, k = (int64_t)(uint32_t)n < avail ? (int64_t)(uint32_t)n : avail;
    if (k < 0) k = 0;
    if (k) memcpy(buf, o->data + o->pos, (size_t)k);
    o->pos += k; if (got) *got = (int32_t)k; return S_OK_;
}
static tresult st_write(Obj *o, const void *buf, int32_t n, int32_t *put) {
    size_t need = (size_t)o->pos + (uint32_t)n;
    if (need > o->cap) { o->cap = need * 2 + 64; o->data = (uint8_t *)realloc(o->data, o->cap); }
    if (n) memcpy(o->data + o->pos, buf, (uint32_t)n);
    o->pos += (uint32_t)n; if ((size_t)o->pos > o->len) o->len = (size_t)o->pos; if (put) *put = n; return S_OK_;
}
static tresult st_seek(Obj *o, int64_t pos, int32_t mode, int64_t *res) {
    o->pos = (mode == 0 ? 0 : mode == 1 ? o->pos : (int64_t)o->len) + pos; if (res) *res = o->pos; return S_OK_;
}
static tresult st_tell(Obj *o, int64_t *pos) { *pos = o->pos; return S_OK_; }
/* IEventList / IParameterChanges / IParamValueQueue (the C runtime's answers, jp8_host.c) */
static int32_t ev_count(Obj *o) { return o->nev; }
static tresult ev_get(Obj *o, int32_t i, uint8_t *e) { if (i < 0 || i >= o->nev) return S_FALSE_; memcpy(e, o->ev[i], 48); return S_OK_; }
static int32_t pc_count(Obj *o) { return o->nq; }
static Obj *pc_get(Obj *o, int32_t i) { return i >= 0 && i < o->nq ? o->q[i] : NULL; }
static uint32_t pq_id(Obj *o) { return o->id; }
static int32_t pq_count(Obj *o) { return o->np; }
static tresult pq_point(Obj *o, int32_t i, int32_t *off, double *v) {
    if (i < 0 || i >= o->np) return S_FALSE_;
    *off = o->off[i]; *v = o->val[i]; return S_OK_;
}

static void *vt_hostctx[16], *vt_handler[10], *vt_stream[8], *vt_events[6], *vt_pchanges[6], *vt_pqueue[7];
static void vtables(void) {
    void **all[] = { vt_hostctx, vt_handler, vt_stream, vt_message, vt_attrs, vt_events, vt_pchanges, vt_pqueue };
    int ns[] = { 16, 10, 8, 8, 12, 6, 6, 7 }, i, j;
    for (i = 0; i < 8; i++) {
        all[i][0] = (void *)m_qi; all[i][1] = (void *)m_ref; all[i][2] = (void *)m_ref;
        for (j = 3; j < ns[i]; j++) all[i][j] = (void *)m_notimpl;
    }
    vt_hostctx[3] = (void *)hc_getName; vt_hostctx[4] = (void *)hc_create;
    for (j = 3; j < 10; j++) vt_handler[j] = (void *)h_any;
    vt_stream[3] = (void *)st_read; vt_stream[4] = (void *)st_write; vt_stream[5] = (void *)st_seek; vt_stream[6] = (void *)st_tell;
    vt_message[3] = (void *)msg_getId; vt_message[4] = (void *)msg_setId; vt_message[5] = (void *)msg_attrs;
    vt_attrs[3] = (void *)at_setInt; vt_attrs[4] = (void *)at_getInt; vt_attrs[5] = (void *)at_setFloat; vt_attrs[6] = (void *)at_getFloat;
    vt_attrs[7] = (void *)at_setString; vt_attrs[8] = (void *)at_getString; vt_attrs[9] = (void *)at_setBinary; vt_attrs[10] = (void *)at_getBinary;
    vt_events[3] = (void *)ev_count; vt_events[4] = (void *)ev_get;
    vt_pchanges[3] = (void *)pc_count; vt_pchanges[4] = (void *)pc_get;
    vt_pqueue[3] = (void *)pq_id; vt_pqueue[4] = (void *)pq_count; vt_pqueue[5] = (void *)pq_point;
}

/* ---------------------------------------------------------------- calls through a plugin object's vtable */
typedef tresult (*fn0)(void *);
typedef tresult (*fn1p)(void *, void *);
typedef tresult (*fn1i)(void *, int32_t);
typedef tresult (*fn2p)(void *, const void *, void **);
typedef tresult (*fn3p)(void *, const void *, const void *, void **);
static void *slot(void *obj, int k) { return (*(void ***)obj)[k]; }
static void die(const char *what, tresult r) { fprintf(stderr, "%s -> 0x%lx\n", what, (unsigned long)r); exit(1); }

static uint8_t *slurp(const char *path, size_t *n) {
    FILE *f = fopen(path, "rb"); uint8_t *b; long m;
    if (!f) { fprintf(stderr, "cannot read %s\n", path); exit(2); }
    fseek(f, 0, SEEK_END); m = ftell(f); fseek(f, 0, SEEK_SET);
    b = (uint8_t *)malloc((size_t)m + 16); if (fread(b, 1, (size_t)m, f) != (size_t)m) { fprintf(stderr, "short read %s\n", path); exit(2); }
    fclose(f); *n = (size_t)m; return b;
}

int main(int argc, char **argv) {
    HMODULE mod; FARPROC init_dll, getf; void *fac, *comp = NULL, *proc = NULL, *ctrl = NULL, *cpp = NULL, *cpc = NULL;
    uint8_t cids[2][16]; int i, ncls; tresult r; Obj *hostctx, *handler, *stream; double rate;
    size_t reclen; uint8_t *rec; FILE *plan, *out; char line[256]; int maxb;
    if (argc != 6 && argc != 7) { fprintf(stderr, "usage: jp8_native_host <module.vst3> <record.bin> <plan.txt> <rate> <out.bin> [maxblock]\n"); return 2; }
    rate = atof(argv[4]); maxb = argc == 7 ? atoi(argv[6]) : 512;
    if (maxb < 1 || maxb > MAXBLOCK) { fprintf(stderr, "maxblock %d: 1..%d\n", maxb, MAXBLOCK); return 2; }
    vst_iid(IID_COMPONENT, 0xE831FF31, 0xF2D54301, 0x928EBBEE, 0x25697802);
    vst_iid(IID_EDITCONTROLLER, 0xDCD7BBE3, 0x7742448D, 0xA874AACC, 0x979C759E);
    vst_iid(IID_CONNECTIONPOINT, 0x70A4156F, 0x6E6E4026, 0x989148BF, 0xAA60D8D1);
    vst_iid(IID_AUDIOPROCESSOR, 0x42043F99, 0xB7DA453C, 0xA569E79D, 0x9AAEC33D);
    vst_iid(IID_HANDLER, 0x93A0BEA3, 0x0BD045DB, 0x8E890B0C, 0xC1E46AC6);
    vst_iid(IID_HOSTAPP, 0x58E595CC, 0xDB2D4969, 0x8B6AAF8C, 0x36A664E5);
    vst_iid(IID_MESSAGE, 0x936F033B, 0xC6C047DB, 0xBB0882F8, 0x13C1E613);
    vst_iid(IID_ATTRS, 0x1E5F0AEB, 0xCC7F4533, 0xA2544011, 0x38AD5EE4);
    vst_iid(IID_BSTREAM, 0xC3BF6EA2, 0x30994752, 0x9B6BF990, 0x1EE33E9B);
    vtables();
    mod = LoadLibraryA(argv[1]);                               /* DllMain(PROCESS_ATTACH) */
    if (!mod) { fprintf(stderr, "LoadLibrary %s: %lu\n", argv[1], GetLastError()); return 1; }
    init_dll = GetProcAddress(mod, "InitDll");
    if (!init_dll || !(((uint8_t (*)(void))(void (*)(void))init_dll)())) { fprintf(stderr, "InitDll failed\n"); return 1; }
    getf = GetProcAddress(mod, "GetPluginFactory");
    fac = ((void *(*)(void))(void (*)(void))getf)();
    ncls = ((int32_t (*)(void *))slot(fac, 4))(fac);          /* the class ids: [0] the processor, [1] the controller */
    for (i = 0; i < ncls && i < 2; i++) {
        uint8_t ci[16 + 4 + 32 + 64];
        ((tresult (*)(void *, int32_t, void *))slot(fac, 5))(fac, i, ci); memcpy(cids[i], ci, 16);
    }
    hostctx = new_obj(vt_hostctx, K_HOSTCTX); handler = new_obj(vt_handler, K_HANDLER);
    if ((r = ((fn3p)slot(fac, 6))(fac, cids[0], IID_COMPONENT, &comp))) die("createInstance(processor)", r);
    if ((r = ((fn1p)slot(comp, 3))(comp, hostctx))) die("IComponent::initialize", r);
    if ((r = ((fn2p)slot(comp, 0))(comp, IID_AUDIOPROCESSOR, &proc))) die("QI IAudioProcessor", r);
    if ((r = ((fn3p)slot(fac, 6))(fac, cids[1], IID_EDITCONTROLLER, &ctrl))) die("createInstance(controller)", r);
    if ((r = ((fn1p)slot(ctrl, 3))(ctrl, hostctx))) die("IEditController::initialize", r);
    if ((r = ((fn2p)slot(comp, 0))(comp, IID_CONNECTIONPOINT, &cpp))) die("QI component IConnectionPoint", r);
    if ((r = ((fn2p)slot(ctrl, 0))(ctrl, IID_CONNECTIONPOINT, &cpc))) die("QI controller IConnectionPoint", r);
    if ((r = ((fn1p)slot(cpp, 3))(cpp, cpc)) || (r = ((fn1p)slot(cpc, 3))(cpc, cpp))) die("connect", r);
    if ((r = ((fn1p)slot(ctrl, 16))(ctrl, handler))) die("setComponentHandler", r);
    stream = new_obj(vt_stream, K_STREAM);
    if ((r = ((fn1p)slot(comp, 13))(comp, stream))) die("IComponent::getState", r);    /* the component's state ... */
    stream->pos = 0;
    if ((r = ((fn1p)slot(ctrl, 5))(ctrl, stream))) die("setComponentState", r);        /* ... handed to the controller */
    {   /* host_setup: setupProcessing(rate, maxblock), setActive(1) */
        struct { int32_t mode, size, maxb, pad; double rate; } ps = { 0, 0, 0, 0, 0.0 };
        ps.maxb = maxb; ps.rate = rate;
        if ((r = ((fn1p)slot(proc, 7))(proc, &ps))) die("setupProcessing", r);
        if ((r = ((fn1i)slot(comp, 11))(comp, 1))) die("setActive", r);
    }
    rec = slurp(argv[2], &reclen);
    {   /* the plugin's own patch load: rcx = {begin, end, end}, rdx = the component's +288, as wrapper_emu.load_patch */
        uint8_t *data = (uint8_t *)malloc(reclen + 16); void *vec[3];
        memcpy(data, rec, reclen); vec[0] = data; vec[1] = data + reclen; vec[2] = data + reclen;
        ((void (*)(void *, void *, void *, void *))((uint8_t *)mod + PATCH_LOAD))(vec, *(void **)((uint8_t *)comp + 288), NULL, NULL);
    }
    plan = fopen(argv[3], "r"); out = fopen(argv[5], "wb");
    if (!plan || !out) { fprintf(stderr, "cannot open the plan or the output\n"); return 2; }
    {
        static float L[MAXBLOCK], R[MAXBLOCK];
        static uint8_t evs[512][48]; static uint8_t ctxb[160]; int has_ctx = 0;
        static Obj *qs[64]; static Obj events, pchanges;
        int n = -1, nev = 0, nq = 0, blocks = 0; void *chans[2]; struct { int32_t nch, pad; uint64_t silence; void **bufs; } bus;
        struct { int32_t mode, size, n, nin, nout, pad; void *in, *outb, *inp, *outp, *inev, *outev, *ctx; } pd;
        events.vt = vt_events; events.kind = K_EVENTS; events.ev = evs; pchanges.vt = vt_pchanges; pchanges.kind = K_PCHANGES; pchanges.q = qs;
        for (i = 0; i < 64; i++) qs[i] = new_obj(vt_pqueue, K_PQUEUE);
        chans[0] = L; chans[1] = R; bus.nch = 2; bus.pad = 0; bus.silence = 0; bus.bufs = chans;
        for (;;) {
            int eof = !fgets(line, sizeof line, plan);
            if ((eof || line[0] == 'B') && n >= 0) {           /* the block gathered so far through process() */
                memset(&pd, 0, sizeof pd); pd.n = n; pd.nout = 1; pd.outb = &bus;
                events.nev = nev; pchanges.nq = nq;
                pd.inp = nq ? (void *)&pchanges : NULL; pd.inev = nev ? (void *)&events : NULL; pd.ctx = has_ctx ? (void *)ctxb : NULL;
                memset(L, 0, sizeof(float) * (size_t)n); memset(R, 0, sizeof(float) * (size_t)n);
                if ((r = ((fn1p)slot(proc, 9))(proc, &pd))) die("process", r);
                fwrite(L, 4, (size_t)n, out); fwrite(R, 4, (size_t)n, out); blocks++;
            }
            if (eof) break;
            if (line[0] == 'B') { n = atoi(line + 2); nev = 0; nq = 0; has_ctx = 0; if (n < 0 || n > maxb) { fprintf(stderr, "block %d > maxblock %d\n", n, maxb); return 2; } }
            else if (line[0] == 'E') {                         /* E on off ch pitch velocity-bits: host_process_emu.process's record */
                int on, off, ch, pitch; unsigned vb; float vel; uint8_t *e;
                if (nev == 512) { fprintf(stderr, "more than 512 events in a block\n"); return 2; }
                e = evs[nev++];
                sscanf(line + 2, "%d %d %d %d %x", &on, &off, &ch, &pitch, &vb); memcpy(&vel, &vb, 4);
                memset(e, 0, 48); memcpy(e + 4, &off, 4);
                if (on) { int16_t c16 = (int16_t)ch, p16 = (int16_t)pitch; float tun = 0.0f; int32_t m1 = -1;
                    e[18] = 0; memcpy(e + 24, &c16, 2); memcpy(e + 26, &p16, 2); memcpy(e + 28, &tun, 4); memcpy(e + 32, &vel, 4);
                    memcpy(e + 36, &m1, 4); memcpy(e + 40, &m1, 4); }
                else { int16_t c16 = (int16_t)ch, p16 = (int16_t)pitch; int32_t m1 = -1; uint16_t t1 = 1;
                    memcpy(e + 18, &t1, 2); memcpy(e + 24, &c16, 2); memcpy(e + 26, &p16, 2); memcpy(e + 28, &vel, 4); memcpy(e + 32, &m1, 4); }
            } else if (line[0] == 'P') {                       /* P id offset value-bits: grouped by id, first seen first */
                unsigned id; int off, k; unsigned long long vb; double v;
                sscanf(line + 2, "%x %d %llx", &id, &off, &vb); memcpy(&v, &vb, 8);
                for (k = 0; k < nq && qs[k]->id != id; k++) {}
                if (k == nq) { if (nq == 64) { fprintf(stderr, "more than 64 parameter ids in a block\n"); return 2; } qs[nq]->id = id; qs[nq]->np = 0; nq++; }
                if (qs[k]->np == qs[k]->qcap) {
                    qs[k]->qcap = qs[k]->qcap ? 2 * qs[k]->qcap : 64;
                    qs[k]->off = (int32_t *)realloc(qs[k]->off, sizeof(int32_t) * (size_t)qs[k]->qcap);
                    qs[k]->val = (double *)realloc(qs[k]->val, sizeof(double) * (size_t)qs[k]->qcap);
                    if (!qs[k]->off || !qs[k]->val) { fprintf(stderr, "no memory\n"); return 3; }
                }
                qs[k]->off[qs[k]->np] = off; qs[k]->val[qs[k]->np] = v; qs[k]->np++;
            } else if (line[0] == 'C') {                       /* C state ppq tempo cycle-start cycle-end (bits, hex) */
                unsigned st; unsigned long long a, b, c, d;
                if (sscanf(line + 2, "%x %llx %llx %llx %llx", &st, &a, &b, &c, &d) != 5) { fprintf(stderr, "bad C line: %s", line); return 2; }
                memset(ctxb, 0, sizeof ctxb); memcpy(ctxb, &st, 4); memcpy(ctxb + 8, &rate, 8); memcpy(ctxb + 40, &a, 8);
                memcpy(ctxb + 56, &c, 8); memcpy(ctxb + 64, &d, 8); memcpy(ctxb + 72, &b, 8); has_ctx = 1;
            } else if (line[0] != '\n' && line[0] != '#') { fprintf(stderr, "a plan line not understood: %s", line); return 2;
            }
        }
        fprintf(stderr, "native: %d blocks\n", blocks);
    }
    fclose(out); fclose(plan);
    return 0;
}

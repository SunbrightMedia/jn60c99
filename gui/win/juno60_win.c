/* juno60_win.c -- the JUNO-60 as ONE Windows program: the C99 port (native: the
 * same sources as libjuno.so) under the plugin's own panel, with its own window,
 * audio output (waveOut) and MIDI input (winmm). Script.xml, the sprite sheets
 * and the banks are embedded (tools/dist/make_native.py).
 *
 * The panel logic is gui/skin/skin.js in C (the tested web version): every
 * position, sprite frame, range, label, font and panel condition comes from
 * Script.xml; each control's id is its value ref walked through the value tree
 * to a Roland 7-bit address; the CHORUS buttons / LEDs and the key velocity are
 * the plugin's own code, READ (rva 0x351410 / 0x3515B0 / 0x2D4AA0 / 0x2D4C40).
 *
 * The engine runs as the plugin runs in a DAW: each audio block is the plugin's
 * own process() (juno_gui_process_ex) on the audio thread (WASAPI, the device's
 * own rate when the plugin's table has it), in the plugin's SSE FTZ / DAZ mode; keys arrive as host note events, CC / pitch bend / aftertouch
 * as its MIDI-mapping parameters; a GUI edit is the model set (rva 0x283DB0), a
 * patch load the patch browser's queued load (rva 0x335850).
 *
 * Test modes (no window): --dump-controls FILE (every control's resolved id, for
 * the comparison with the web version), --shot FILE.bmp [--patch N] (the panel),
 * --render FILE [--bank B] [--patch N] (the audio thread's own path on a fixed
 * key / controller / panel script: raw float L R to FILE, every engine call to
 * FILE.log -- tools/dist/native_check.py replays the log through the proven
 * libjuno.so and the two outputs must be equal bit for bit), --play FILE --seed N
 * [--fp-oracle] (a seeded performance through the program's own inputs: MIDI
 * through the winmm callback, the keybed through the mouse handlers; the log is
 * played into the plugin itself by tools/dist/exe_oracle_check.py), --kbscript
 * FILE (panel events through the program's own handlers, every engine call to
 * FILE.log: tools/verify/skin_kb_check.mjs plays the same script into the web
 * skin and requires the same calls).
 */
#define WIN32_LEAN_AND_MEAN
#ifndef _WIN32_WINNT
#define _WIN32_WINNT 0x0601
#endif
#include <windows.h>
#include <windowsx.h>
#include <mmsystem.h>
#include <commdlg.h>
#include <shlwapi.h>
#include <shellapi.h>
#include <shlobj.h>
#include <objidl.h>
#include <mmreg.h>
#include <initguid.h>          /* the WASAPI interface ids are defined in this file */
#include <mmdeviceapi.h>
#include <audioclient.h>
#include <avrt.h>
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <ctype.h>
#include <math.h>
#include "assets.h"     /* generated: resource ids of Script.xml, the banks, the sprite sheets */

/* ------------------------------------------------------------- the engine */
typedef struct { int offset, type, channel, pitch; float velocity; } juno_host_note;
typedef struct { uint32_t id; int offset; double value; } juno_host_param;
void *juno_gui_create(float sample_rate, int chorus_mode);
int juno_gui_plugin_init(void *c);
int juno_gui_model_set(void *c, uint32_t id, int32_t v);
int juno_gui_state_save(const void *c, unsigned char *out, int cap);
int juno_gui_queue_patch(void *c, const unsigned char *bank, int len, int idx);
void juno_gui_ui_tick(void *c);
void juno_gui_setup_processing(void *c, double host_rate);
void juno_gui_set_active(void *c, int on);
int juno_gui_process_ex(void *c, const juno_host_note *ev, int nev, const juno_host_param *par, int npar,
                        int tempo_valid, double tempo, float *outL, float *outR, int n);
uint32_t juno_midi_base(void);
int juno_gui_keybed_write(void *c, int key, int value);
void juno_gui_commit(void *c);
int juno_gui_keybed_state(const void *c, int key);
void juno_enable_hw_ftz(void);
void juno_set_fp_oracle_mode(int on);

/* ------------------------------------------------------- GDI+ (flat API) */
typedef struct { UINT32 GdiplusVersion; void *DebugEventCallback; BOOL SuppressBackgroundThread; BOOL SuppressExternalCodecs; } GpStartupIn;
typedef struct { UINT Width, Height; INT Stride; INT PixelFormat; void *Scan0; UINT_PTR Reserved; } GpBitmapData;
typedef struct { INT X, Y, Width, Height; } GpRect;
int WINAPI GdiplusStartup(ULONG_PTR *token, const GpStartupIn *in, void *out);
int WINAPI GdipCreateBitmapFromStream(IStream *stream, void **bitmap);
int WINAPI GdipGetImageWidth(void *image, UINT *w);
int WINAPI GdipGetImageHeight(void *image, UINT *h);
int WINAPI GdipBitmapLockBits(void *bitmap, const GpRect *rect, UINT flags, INT format, GpBitmapData *data);
int WINAPI GdipBitmapUnlockBits(void *bitmap, GpBitmapData *data);
int WINAPI GdipDisposeImage(void *image);
#define GP_PARGB 0x000E200B
#define GP_READ 1

static const unsigned char *resource(int id, DWORD *len)
{
    HRSRC h = FindResourceA(NULL, MAKEINTRESOURCEA(id), MAKEINTRESOURCEA(10));   /* RT_RCDATA */
    HGLOBAL g;
    if (!h || !(g = LoadResource(NULL, h))) return NULL;
    *len = SizeofResource(NULL, h);
    return (const unsigned char *)LockResource(g);
}

static void *xmalloc(size_t n) { void *p = calloc(1, n ? n : 1); if (!p) ExitProcess(3); return p; }
static char *xstrndup(const char *s, size_t n) { char *p = xmalloc(n + 1); memcpy(p, s, n); p[n] = 0; return p; }
static char *xstrdup(const char *s) { return xstrndup(s, strlen(s)); }

/* ----------------------------------------------------------- a tiny XML DOM
 * Script.xml uses elements and text only: no attributes, no CDATA; comments,
 * one declaration, the entities &amp; &lt; (&gt; &quot; &apos; too). */
typedef struct XN { char *tag, *text; struct XN **k; int n, cap; } XN;

static void xn_add(XN *p, XN *c)
{
    if (p->n == p->cap) {
        p->cap = p->cap ? 2 * p->cap : 8;
        p->k = realloc(p->k, sizeof *p->k * (size_t)p->cap);
        if (!p->k) ExitProcess(3);
    }
    p->k[p->n++] = c;
}

static char *xml_text(const char *s, size_t n)
{
    char *o = xmalloc(n + 1), *w = o;
    size_t i = 0, a, b;
    while (i < n) {
        if (s[i] == '&') {
            static const struct { const char *e; char c; } E[] = {
                {"&amp;", '&'}, {"&lt;", '<'}, {"&gt;", '>'}, {"&quot;", '"'}, {"&apos;", '\''}};
            size_t k, done = 0;
            for (k = 0; k < 5; ++k) {
                size_t L = strlen(E[k].e);
                if (i + L <= n && !strncmp(s + i, E[k].e, L)) { *w++ = E[k].c; i += L; done = 1; break; }
            }
            if (done) continue;
        }
        *w++ = s[i++];
    }
    *w = 0;
    /* trimmed, as the web version's textContent.trim() */
    a = 0; b = strlen(o);
    while (a < b && isspace((unsigned char)o[a])) ++a;
    while (b > a && isspace((unsigned char)o[b - 1])) --b;
    memmove(o, o + a, b - a);
    o[b - a] = 0;
    return o;
}

static XN *xml_parse(const char *s, size_t len)
{
    XN *root = xmalloc(sizeof *root), *stack[128];
    int sp = 0;
    size_t i = 0, tstart = 0;
    root->tag = xstrdup("#doc");
    stack[sp++] = root;
    while (i < len) {
        if (s[i] != '<') { ++i; continue; }
        if (!strncmp(s + i, "<?", 2)) { const char *p = strstr(s + i, "?>"); i = p ? (size_t)(p - s) + 2 : len; tstart = i; continue; }
        if (!strncmp(s + i, "<!--", 4)) { const char *p = strstr(s + i + 4, "-->"); i = p ? (size_t)(p - s) + 3 : len; continue; }
        if (s[i + 1] == '/') {                               /* a close tag */
            XN *cur = stack[sp - 1];
            if (!cur->n && !cur->text) cur->text = xml_text(s + tstart, i - tstart);
            if (sp > 1) --sp;
            while (i < len && s[i] != '>') ++i;
            tstart = ++i;
            continue;
        }
        {                                                   /* an open tag */
            size_t j = i + 1, k;
            XN *e;
            while (j < len && s[j] != '>' && s[j] != '/' && !isspace((unsigned char)s[j])) ++j;
            e = xmalloc(sizeof *e);
            e->tag = xstrndup(s + i + 1, j - i - 1);
            xn_add(stack[sp - 1], e);
            k = j;
            while (k < len && s[k] != '>') ++k;
            if (k > 0 && s[k - 1] == '/') e->text = xstrdup("");
            else if (sp < 128) stack[sp++] = e;
            i = k + 1;
            tstart = i;
        }
    }
    return root;
}

static XN *xchild(XN *e, const char *tag)
{
    int i;
    for (i = 0; e && i < e->n; ++i) if (!strcmp(e->k[i]->tag, tag)) return e->k[i];
    return NULL;
}
static const char *xtext(XN *e, const char *tag)
{
    XN *c = xchild(e, tag);
    return c ? (c->text ? c->text : "") : NULL;
}
static int ints(const char *s, int *out, int max)
{
    int n = 0;
    while (s && *s && n < max) {
        char *end;
        long v = strtol(s, &end, 10);
        if (end == s) { ++s; continue; }
        out[n++] = (int)v;
        s = end;
        while (*s && *s != ',') ++s;
        if (*s == ',') ++s;
    }
    return n;
}

/* ------------------------------------------------------------ the value tree */
typedef struct { char *name; uint32_t id; int w, min, max, def; } Leaf;
#define HCAP 32768
static Leaf *g_leaf[HCAP];
static struct { char *ref; Leaf *L; } g_refc[4096];
static int g_nrefc;

static uint32_t fnv(const char *s) { uint32_t h = 2166136261u; while (*s) h = (h ^ (unsigned char)*s++) * 16777619u; return h; }
static Leaf *leaf_get(const char *name)
{
    uint32_t h = fnv(name) & (HCAP - 1);
    while (g_leaf[h]) { if (!strcmp(g_leaf[h]->name, name)) return g_leaf[h]; h = (h + 1) & (HCAP - 1); }
    return NULL;
}
static void leaf_put(Leaf *L)
{
    uint32_t h = fnv(L->name) & (HCAP - 1);
    while (g_leaf[h]) h = (h + 1) & (HCAP - 1);
    g_leaf[h] = L;
}

static int width_of(const char *t)
{
    if (!strcmp(t, "int1x7")) return 1;
    if (!strcmp(t, "int2x4")) return 2;
    if (!strcmp(t, "int3x4")) return 3;
    if (!strcmp(t, "int4x4")) return 4;
    if (!strcmp(t, "int8x4")) return 8;
    return 0;
}
static void add7(const int *base, const int *off, int noff, int *out)
{
    int o[4] = {0, 0, 0, 0}, i, carry = 0;
    for (i = 0; i < noff && i < 4; ++i) o[4 - noff + i] = off[i];
    for (i = 3; i >= 0; --i) { int s = base[i] + o[i] + carry; out[i] = s & 0x7f; carry = s >> 7; }
}
static uint32_t pid(const int *a) { return ((uint32_t)a[0] << 21) | ((uint32_t)a[1] << 14) | ((uint32_t)a[2] << 7) | (uint32_t)a[3]; }
static int hexaddr(const char *s, int *out)
{
    int n = 0;
    while (s && *s && n < 4) {
        char *end;
        long v = strtol(s, &end, 16);
        if (end == s) { ++s; continue; }
        out[n++] = (int)v;
        s = end;
    }
    return n;
}

static XN *g_doc, *g_script;
static XN *structtype(const char *type)
{
    int i;
    for (i = 0; i < g_script->n; ++i) {
        XN *e = g_script->k[i];
        const char *t;
        if (strcmp(e->tag, "structType")) continue;
        t = xtext(e, "type");
        if (t && !strcmp(t, type)) return e;
    }
    return NULL;
}

static void walk(const char *type, const int *base, const char *path)
{
    XN *d = structtype(type);
    int i, off = 0;
    if (!d) return;
    for (i = 0; i < d->n; ++i) {
        XN *c = d->k[i];
        if (!strcmp(c->tag, "value")) {
            const char *t = xtext(c, "type"), *nm = xtext(c, "name"), *a0 = xtext(c, "address"), *r, *df;
            int a[4], o[4], no;
            char *key;
            if (!t || !*t) t = "int1x7";
            if (!nm) continue;
            if (a0) { no = hexaddr(a0, o); add7(base, o, no, a); }
            else { o[0] = 0; o[1] = 0; o[2] = off >> 7; o[3] = off & 0x7f; add7(base, o, 4, a); }
            key = xmalloc(strlen(path) + strlen(nm) + 2);
            sprintf(key, "%s.%s", path, nm);
            if (!leaf_get(key)) {
                Leaf *L = xmalloc(sizeof *L);
                int rg[2] = {0, 0};
                L->name = key;
                L->id = pid(a);
                L->w = width_of(t);
                r = xtext(c, "range");
                if (r && ints(r, rg, 2) == 2) { L->min = rg[0]; L->max = rg[1]; }
                df = xtext(c, "default");
                L->def = df ? atoi(df) : 0;
                leaf_put(L);
            } else free(key);
            if (!a0) off += width_of(t);
        } else if (!strcmp(c->tag, "struct")) {
            const char *ct = xtext(c, "type"), *cn = xtext(c, "name"), *tn = NULL;
            XN *st;
            int o[4], no, a[4];
            char *np;
            if (!ct) continue;
            st = structtype(ct);
            if (st) tn = xtext(st, "name");
            if (!cn || !*cn) cn = (tn && strcmp(tn, "$name")) ? tn : ct;
            no = hexaddr(xtext(c, "address"), o);
            add7(base, o, no, a);
            np = xmalloc(strlen(path) + strlen(cn) + 2);
            sprintf(np, "%s.%s", path, cn);
            walk(ct, a, np);
            free(np);
        }
    }
}

/* a value ref -> its leaf; "x[i]" is element i of the leaf array x */
static Leaf *resolve(const char *ref)
{
    int i;
    const char *br;
    Leaf *L;
    if (!ref) return NULL;
    for (i = 0; i < g_nrefc; ++i) if (!strcmp(g_refc[i].ref, ref)) return g_refc[i].L;
    br = strrchr(ref, '[');
    if (br && ref[strlen(ref) - 1] == ']') {
        char *base = xstrndup(ref, (size_t)(br - ref));
        Leaf *B = leaf_get(base);
        free(base);
        L = NULL;
        if (B) {
            int k = atoi(br + 1), u[4], o[4], a[4];
            u[0] = (B->id >> 21) & 0x7f; u[1] = (B->id >> 14) & 0x7f; u[2] = (B->id >> 7) & 0x7f; u[3] = B->id & 0x7f;
            o[0] = 0; o[1] = 0; o[2] = (k * B->w) >> 7; o[3] = (k * B->w) & 0x7f;
            add7(u, o, 4, a);
            L = xmalloc(sizeof *L);
            *L = *B;
            L->name = xstrdup(ref);
            L->id = pid(a);
        }
    } else L = leaf_get(ref);
    if (g_nrefc < 4096) { g_refc[g_nrefc].ref = xstrdup(ref); g_refc[g_nrefc].L = L; ++g_nrefc; }
    return L;
}

/* --------------------------------------------------- bitmaps, fonts, tables */
typedef struct { char name[64]; int n, dir, w, h; uint32_t *px; } Bmp;     /* px: premultiplied BGRA */
static Bmp g_bmp[64];
static int g_nbmp;
typedef struct { char name[32]; char face[64]; int size, has_back, alignH, alignV; COLORREF color; int br, bg, bb, ba; HFONT font; } Writer;
static Writer g_wr[48];
static int g_nwr;
typedef struct { char name[32]; char **s; int n; } STable;
static STable g_st[64];
static int g_nst;
typedef struct { char name[32]; int g[16][12], gn[16], n; } NTable;
static NTable g_nt[16];
static int g_nnt;

static Bmp *bmp_get(const char *name)
{
    int i;
    for (i = 0; name && i < g_nbmp; ++i) if (!strcmp(g_bmp[i].name, name)) return &g_bmp[i];
    return NULL;
}
static Writer *wr_get(const char *name)
{
    int i;
    for (i = 0; name && i < g_nwr; ++i) if (!strcmp(g_wr[i].name, name)) return &g_wr[i];
    return NULL;
}
static STable *st_get(const char *name)
{
    int i;
    for (i = 0; name && i < g_nst; ++i) if (!strcmp(g_st[i].name, name)) return &g_st[i];
    return NULL;
}
static NTable *nt_get(const char *name)
{
    int i;
    for (i = 0; name && i < g_nnt; ++i) if (!strcmp(g_nt[i].name, name)) return &g_nt[i];
    return NULL;
}

static int decode_png(const unsigned char *data, DWORD len, Bmp *b)
{
    IStream *st = SHCreateMemStream(data, len);
    void *bm = NULL;
    UINT w = 0, h = 0, y;
    GpRect r;
    GpBitmapData bd;
    if (!st) return 0;
    if (GdipCreateBitmapFromStream(st, &bm) || !bm) { st->lpVtbl->Release(st); return 0; }
    GdipGetImageWidth(bm, &w);
    GdipGetImageHeight(bm, &h);
    r.X = 0; r.Y = 0; r.Width = (INT)w; r.Height = (INT)h;
    if (GdipBitmapLockBits(bm, &r, GP_READ, GP_PARGB, &bd)) { GdipDisposeImage(bm); st->lpVtbl->Release(st); return 0; }
    b->w = (int)w;
    b->h = (int)h;
    b->px = xmalloc((size_t)w * h * 4);
    for (y = 0; y < h; ++y) memcpy(b->px + (size_t)y * w, (const unsigned char *)bd.Scan0 + (ptrdiff_t)y * bd.Stride, (size_t)w * 4);
    GdipBitmapUnlockBits(bm, &bd);
    GdipDisposeImage(bm);
    st->lpVtbl->Release(st);
    return 1;
}

static int hex_list(const char *s, int *out, int max)
{
    int n = 0;
    while (s && *s && n < max) {
        char *end;
        long v = strtol(s, &end, 16);
        if (end == s) { ++s; continue; }
        out[n++] = (int)v;
        s = end;
    }
    return n;
}

static void load_script_tables(void)
{
    int i;
    for (i = 0; i < g_script->n; ++i) {
        XN *e = g_script->k[i];
        if (!strcmp(e->tag, "bitmap") && g_nbmp < 64) {
            Bmp *b = &g_bmp[g_nbmp];
            const char *nm = xtext(e, "name"), *sc = xtext(e, "stateCount"), *dr = xtext(e, "direction");
            DWORD len;
            const unsigned char *d;
            int k, id = -1;
            if (!nm) continue;
            snprintf(b->name, sizeof b->name, "%s", nm);
            b->n = sc ? atoi(sc) : 1;
            if (b->n < 1) b->n = 1;
            b->dir = dr ? atoi(dr) : 0;
            for (k = 0; k < ASSET_PNG_N; ++k) if (!strcmp(ASSET_PNG[k].name, nm)) id = ASSET_PNG[k].id;
            if (id >= 0 && (d = resource(id, &len))) decode_png(d, len, b);
            ++g_nbmp;
        } else if (!strcmp(e->tag, "textWriter") && g_nwr < 48) {
            Writer *w = &g_wr[g_nwr++];
            const char *nm = xtext(e, "name"), *f = xtext(e, "fontFaceName"), *h = xtext(e, "fontHeight"),
                       *c = xtext(e, "fontColor"), *b = xtext(e, "backColor"), *ah = xtext(e, "alignH"), *av = xtext(e, "alignV");
            int v[4];
            snprintf(w->name, sizeof w->name, "%s", nm ? nm : "");
            snprintf(w->face, sizeof w->face, "%s", (!f || !strcmp(f, "DEFAULT")) ? "Segoe UI" : f);
            w->size = h ? atoi(h) : 14;
            w->color = RGB(0xc0, 0xc0, 0xc0);
            if (c && hex_list(c, v, 3) == 3) w->color = RGB(v[0], v[1], v[2]);
            if (b) {
                int n = hex_list(b, v, 4);
                if (n >= 3) { w->has_back = 1; w->br = v[0]; w->bg = v[1]; w->bb = v[2]; w->ba = n > 3 ? v[3] : 255; }
            }
            w->alignH = ah ? (!strcmp(ah, "center") ? 1 : !strcmp(ah, "right") ? 2 : 0) : 0;
            w->alignV = av ? (!strcmp(av, "center") ? 1 : 0) : 0;
        }
    }
    /* string and number tables sit anywhere in the document */
    {
        XN *stack[256];
        int sp = 0;
        stack[sp++] = g_doc;
        while (sp) {
            XN *e = stack[--sp];
            int k;
            if (!strcmp(e->tag, "stringTable") && g_nst < 64) {
                STable *t = &g_st[g_nst++];
                const char *nm = xtext(e, "name"), *tb = xtext(e, "table");
                const char *p = tb ? tb : "";
                snprintf(t->name, sizeof t->name, "%s", nm ? nm : "");
                t->s = xmalloc(sizeof *t->s * 4096);
                while (*p && t->n < 4096) {
                    const char *q = strchr(p, ',');
                    size_t L = q ? (size_t)(q - p) : strlen(p);
                    char *it = xstrndup(p, L), *a = it, *z;
                    while (*a && isspace((unsigned char)*a)) ++a;
                    z = a + strlen(a);
                    while (z > a && isspace((unsigned char)z[-1])) --z;
                    *z = 0;
                    t->s[t->n++] = xstrdup(a);
                    free(it);
                    if (!q) break;
                    p = q + 1;
                }
                if (t->n && !*t->s[t->n - 1]) --t->n;
            } else if (!strcmp(e->tag, "numberTable") && g_nnt < 16) {
                NTable *t = &g_nt[g_nnt++];
                const char *nm = xtext(e, "name"), *tb = xtext(e, "table"), *p;
                snprintf(t->name, sizeof t->name, "%s", nm ? nm : "");
                for (p = tb ? tb : ""; *p && t->n < 16;) {
                    while (*p && t->gn[t->n] < 12) {
                        char *end;
                        long v = strtol(p, &end, 10);
                        if (end == p) break;
                        t->g[t->n][t->gn[t->n]++] = (int)v;
                        p = end;
                        if (*p == '|') { ++p; continue; }
                        break;
                    }
                    ++t->n;
                    if (*p == ',') ++p;
                    else break;
                }
            }
            for (k = e->n - 1; k >= 0 && sp < 256; --k) stack[sp++] = e->k[k];
        }
    }
}

/* ---------------------------------------------------------- panels, controls */
enum { C_SLIDER, C_KNOB, C_DISPLAY, C_LATCH, C_UNLATCH, C_MENU, C_SETUP, C_JU60BTN, C_JU60LED, C_LFOLED,
       C_PATCHNAME, C_KEYBOARD, C_PATCHBANKNAME, C_PATCHLIST, C_OTHER };
typedef struct { int n, black, shape, x, y, w, h; } Key;
typedef struct Ctl {
    int type, x, y, w, h, has_size;
    XN *el;
    char *typestr, *refs[12];
    int nrefs;
    Bmp *bmp, *pic;
    int piclist[32], npic;
    const char *table, *fn, *args, *unit;
    Writer *wr[3];
    int nwr;
    int onValue, offValue, offsetValue, role, has_on, has_off, role_set;
    int sr0, sr1, has_sr, clickable, x2, y2, has_p2, tipx, tipy, timeout;
    Key keys[64];
    int nkeys, rects[14][2][4];
    int bx, by, tx, ty, tw, th;
} Ctl;
typedef struct Panel Panel;
typedef struct { Panel *p; Ctl *c; } Item;
struct Panel { char *type; int x, y, w, h, has_size; const char *cond; Bmp *bmp; Item *items; int n, cap; };

static XN *paneltype(const char *type)
{
    int i;
    for (i = 0; i < g_script->n; ++i) {
        XN *e = g_script->k[i];
        const char *t;
        if (strcmp(e->tag, "panelType")) continue;
        t = xtext(e, "type");
        if (t && !strcmp(t, type)) return e;
    }
    return NULL;
}

static void item_add(Panel *p, Panel *sub, Ctl *c)
{
    if (p->n == p->cap) {
        p->cap = p->cap ? 2 * p->cap : 16;
        p->items = realloc(p->items, sizeof *p->items * (size_t)p->cap);
        if (!p->items) ExitProcess(3);
    }
    p->items[p->n].p = sub;
    p->items[p->n].c = c;
    ++p->n;
}

static void frame_size(const Bmp *b, int *w, int *h)
{
    if (!b || !b->px) { *w = *h = 0; return; }
    if (b->dir == 1) { *w = b->w / b->n; *h = b->h; }
    else { *w = b->w; *h = b->h / b->n; }
}

/* The panel keyboard's keys (the plugin's layout, rva 0x2D45E0): keyRange low..
 * high (the parser keeps high + 1, rva 0x2D3190); the white keys -- the first and
 * the last key always, else C D E F G A B -- one width / their count apart from the
 * control's left; the first key draws chromaticRect 12, the last 13, the others their
 * pitch class; a black key sits at the right edge of the key before it, plus its
 * chromaticOffset, less half its own width (C division) */
static void keyboard_init(Ctl *c)
{
    int kr[2] = {36, 96}, i, lo, hi, white = 0, step, acc = 0, offs[14] = {0};
    for (i = 0; i < c->el->n; ++i) {
        XN *e = c->el->k[i];
        int v[6];
        if (!strcmp(e->tag, "keyRange")) ints(e->text, kr, 2);
        else if (!strcmp(e->tag, "chromaticRect") && ints(e->text, v, 6) == 6 && v[0] >= 0 && v[0] < 14 && (v[1] == 0 || v[1] == 1)) {
            c->rects[v[0]][v[1]][0] = v[2];
            c->rects[v[0]][v[1]][1] = v[3];
            c->rects[v[0]][v[1]][2] = v[4] - v[2];
            c->rects[v[0]][v[1]][3] = v[5] - v[3];
        } else if (!strcmp(e->tag, "chromaticOffset") && ints(e->text, v, 2) == 2 && v[0] >= 0 && v[0] < 14) offs[v[0]] = v[1];
    }
    lo = kr[0];
    hi = kr[1] + 1;
    for (i = lo; i < hi; ++i) {
        int pc = i % 12;
        white += (i == lo || i == hi - 1) ? 1 : pc > 4 ? pc % 2 == 1 : (pc & 1) == 0;
    }
    step = white ? c->w / white : 0;
    for (i = lo; i < hi && c->nkeys < 64; ++i) {
        int shape = i == lo ? 12 : i == hi - 1 ? 13 : i % 12;
        int is_white = shape > 11 ? 1 : shape > 4 ? (shape & 1) == 1 : (shape & 1) == 0;
        Key *k = &c->keys[c->nkeys];
        k->n = i;
        k->black = !is_white;
        k->shape = shape;
        k->w = c->rects[shape][0][2];
        k->h = c->rects[shape][0][3];
        if (is_white) { k->x = c->x + acc; acc += step; }
        else k->x = c->keys[c->nkeys - 1].x + c->keys[c->nkeys - 1].w + offs[shape] - k->w / 2;
        k->y = c->y;
        ++c->nkeys;
    }
}

static Ctl *control(XN *el, int ox, int oy)
{
    Ctl *c = xmalloc(sizeof *c);
    const char *t = xtext(el, "type"), *s;
    int v[8], i;
    c->el = el;
    c->typestr = xstrdup(t ? t : "");
    c->type = !strcmp(c->typestr, "slider") ? C_SLIDER : !strcmp(c->typestr, "knob") ? C_KNOB :
              !strcmp(c->typestr, "display") ? C_DISPLAY : !strcmp(c->typestr, "latchButton") ? C_LATCH :
              !strcmp(c->typestr, "unlatchButton") ? C_UNLATCH : !strcmp(c->typestr, "menuButton") ? C_MENU :
              !strcmp(c->typestr, "setupButton") ? C_SETUP : !strcmp(c->typestr, "ju60UnlatchButton") ? C_JU60BTN :
              !strcmp(c->typestr, "ju60Led") ? C_JU60LED : !strcmp(c->typestr, "lfoLed") ? C_LFOLED :
              !strcmp(c->typestr, "patchName") ? C_PATCHNAME : !strcmp(c->typestr, "keyboardX") ? C_KEYBOARD :
              !strcmp(c->typestr, "patchBankName") ? C_PATCHBANKNAME : !strcmp(c->typestr, "patch") ? C_PATCHLIST : C_OTHER;
    s = xtext(el, "position");
    c->x = ox; c->y = oy;
    if (s && ints(s, v, 2) == 2) { c->x = ox + v[0]; c->y = oy + v[1]; }
    s = xtext(el, "size");
    if (s && ints(s, v, 2) == 2) { c->w = v[0]; c->h = v[1]; c->has_size = 1; }
    for (i = 0; i < el->n; ++i) {
        XN *e = el->k[i];
        if (!strcmp(e->tag, "valueRef") && c->nrefs < 12) c->refs[c->nrefs++] = e->text;
        else if (!strcmp(e->tag, "textWriterRef") && c->nwr < 3) c->wr[c->nwr++] = wr_get(e->text);
    }
    c->bmp = bmp_get(xtext(el, "bitmapRef"));
    s = xtext(el, "pictorialBitmapRef");
    c->npic = -1;
    if (s) {
        const char *sl = strstr(s, "//");
        char nm[64];
        snprintf(nm, sizeof nm, "%.*s", (int)(sl ? (size_t)(sl - s) : strlen(s)), s);
        c->pic = bmp_get(nm);
        if (sl) c->npic = ints(sl + 2, c->piclist, 32);
    }
    c->table = xtext(el, "stringTableRef");
    if ((s = xtext(el, "onValue")) && *s) { c->onValue = atoi(s); c->has_on = 1; }
    if ((s = xtext(el, "offValue")) && *s) { c->offValue = atoi(s); c->has_off = 1; }
    if ((s = xtext(el, "offsetValue")) && *s) c->offsetValue = atoi(s);
    if ((s = xtext(el, "role")) && *s) { c->role = atoi(s); c->role_set = 1; }
    if ((s = xtext(el, "bitmapStateRange")) && ints(s, v, 2) == 2) { c->sr0 = v[0]; c->sr1 = v[1]; c->has_sr = 1; }
    c->clickable = (s = xtext(el, "clickable")) && !strcmp(s, "1");
    c->fn = xtext(el, "function");
    c->args = xtext(el, "arguments");
    c->unit = xtext(el, "unit");
    if ((s = xtext(el, "position2")) && ints(s, v, 2) == 2) { c->x2 = ox + v[0]; c->y2 = oy + v[1]; c->has_p2 = 1; }
    if ((s = xtext(el, "tipBarPosition")) && ints(s, v, 2) == 2) { c->tipx = v[0]; c->tipy = v[1]; }
    if ((s = xtext(el, "timeout"))) c->timeout = atoi(s);
    if (c->type == C_KEYBOARD) keyboard_init(c);
    if (c->type == C_PATCHNAME) {
        int b[2] = {0, 0}, tp[2] = {0, 0}, ts[2] = {0, 0};
        ints(xtext(el, "buttonPosition"), b, 2);
        ints(xtext(el, "textPosition"), tp, 2);
        ints(xtext(el, "textSize"), ts, 2);
        c->bx = c->x + b[0]; c->by = c->y + b[1]; c->tx = c->x + tp[0]; c->ty = c->y + tp[1]; c->tw = ts[0]; c->th = ts[1];
    }
    if (c->type == C_PATCHBANKNAME) {
        int b[2] = {0, 0}, tp[2] = {0, 0};
        ints(xtext(el, "buttonPosition"), b, 2);
        ints(xtext(el, "textPosition"), tp, 2);
        c->bx = c->x + b[0]; c->by = c->y + b[1]; c->tx = c->x + tp[0]; c->ty = c->y + tp[1];
    }
    return c;
}

static Panel *build(const char *type, int ox, int oy)
{
    XN *p = paneltype(type);
    Panel *n = xmalloc(sizeof *n);
    const char *s;
    int v[2], i;
    n->type = xstrdup(type);
    if (!p) return n;
    s = xtext(p, "position");
    n->x = ox; n->y = oy;
    if (s && ints(s, v, 2) == 2 && strcmp(type, "main")) { n->x = ox + v[0]; n->y = oy + v[1]; }
    s = xtext(p, "size");
    if (s && ints(s, v, 2) == 2) { n->w = v[0]; n->h = v[1]; n->has_size = 1; }
    n->cond = xtext(p, "openCondition");
    n->bmp = bmp_get(xtext(p, "bitmapRef"));
    for (i = 0; i < p->n; ++i) {
        XN *e = p->k[i];
        if (!strcmp(e->tag, "panel")) item_add(n, build(xtext(e, "type"), n->x, n->y), NULL);
        else if (!strcmp(e->tag, "control")) item_add(n, NULL, control(e, n->x, n->y));
    }
    return n;
}

/* ----------------------------------------------------------------- the model */
static void *g_eng;
static CRITICAL_SECTION g_lock;            /* every engine call */
/* --render: every engine call that changes the engine, in order (floats and
 * doubles as their bits), for the replay through the proven build */
static FILE *g_log;
static uint32_t fbits(float f) { uint32_t u; memcpy(&u, &f, 4); return u; }
static unsigned long long dbits(double d) { unsigned long long u; memcpy(&u, &d, 8); return u; }
static int E_model_set(uint32_t id, int32_t v)
{
    if (g_log) fprintf(g_log, "model_set %u %d\n", (unsigned)id, (int)v);
    return juno_gui_model_set(g_eng, id, v);
}
static int E_keybed_write(int key, int value)
{
    if (g_log) fprintf(g_log, "keybed %d %d\n", key, value);
    return juno_gui_keybed_write(g_eng, key, value);
}
static void E_commit(void)
{
    if (g_log) fprintf(g_log, "commit\n");
    juno_gui_commit(g_eng);
}
static void E_ui_tick(void)
{
    if (g_log) fprintf(g_log, "ui_tick\n");
    juno_gui_ui_tick(g_eng);
}
static void E_process(const juno_host_note *ev, int nev, const juno_host_param *par, int npar, double tempo,
                      float *L, float *R, int n)
{
    int i;
    if (g_log) {
        fprintf(g_log, "process %d %016llx %d %d\n", n, dbits(tempo), nev, npar);
        for (i = 0; i < nev; ++i)
            fprintf(g_log, "ev %d %d %d %d %08x\n", ev[i].offset, ev[i].type, ev[i].channel, ev[i].pitch, (unsigned)fbits(ev[i].velocity));
        for (i = 0; i < npar; ++i)
            fprintf(g_log, "par %u %d %016llx\n", (unsigned)par[i].id, par[i].offset, dbits(par[i].value));
    }
    juno_gui_process_ex(g_eng, ev, nev, par, npar, 1, tempo, L, R, n);
}
static uint32_t g_eid[256];
static int32_t g_ev[256];
static int g_neng;
static struct { uint32_t id; int32_t v; } g_loc[256];
static int g_nloc;
static int g_dirty = 1;
static Panel *g_tree, *g_patchwin;
static int g_fbw = 1924, g_fbh = 740;

static int eng_refresh(void)              /* the model as getState writes it; call under the lock */
{
    unsigned char buf[4 + 8 * 256];
    int n = juno_gui_state_save(g_eng, buf, (int)sizeof buf), i, k = 0, changed = 0;
    unsigned bytes;
    if (n < 0) return 0;
    bytes = ((unsigned)buf[0] << 24) | ((unsigned)buf[1] << 16) | ((unsigned)buf[2] << 8) | buf[3];
    for (i = 4; i + 8 <= 4 + (int)bytes && k < 256; i += 8, ++k) {
        uint32_t id = ((uint32_t)buf[i] << 24) | ((uint32_t)buf[i + 1] << 16) | ((uint32_t)buf[i + 2] << 8) | buf[i + 3];
        int32_t v = (int32_t)(((uint32_t)buf[i + 4] << 24) | ((uint32_t)buf[i + 5] << 16) | ((uint32_t)buf[i + 6] << 8) | buf[i + 7]);
        if (k >= g_neng || g_eid[k] != id || g_ev[k] != v) changed = 1;
        g_eid[k] = id;
        g_ev[k] = v;
    }
    if (k != g_neng) changed = 1;
    g_neng = k;
    return changed;
}

static int val_get(const Leaf *L)
{
    int i;
    if (!L) return 0;
    for (i = 0; i < g_neng; ++i) if (g_eid[i] == L->id) return g_ev[i];
    for (i = 0; i < g_nloc; ++i) if (g_loc[i].id == L->id) return g_loc[i].v;
    return L->def;
}
static int get(const char *ref) { return val_get(resolve(ref)); }

static double g_tempo = 128.0;
static DWORD g_note_flash;
static void zoom_apply(void);

/* a value the engine's state list does not hold (the view's own): kept here */
static void local_put(uint32_t id, int v)
{
    int i;
    for (i = 0; i < g_nloc && g_loc[i].id != id; ++i) ;
    if (i == g_nloc && g_nloc < 256) ++g_nloc;
    if (i < 256) { g_loc[i].id = id; g_loc[i].v = v; }
}
static void val_set(const Leaf *L, int v)
{
    int r;
    if (!L) return;
    if (L->max > L->min) { if (v < L->min) v = L->min; if (v > L->max) v = L->max; }
    EnterCriticalSection(&g_lock);
    r = E_model_set(L->id, v);
    E_commit();                       /* a panel control commits after its set (rva 0x2DD100) */
    if (r) eng_refresh();
    LeaveCriticalSection(&g_lock);
    if (!r) local_put(L->id, v);
    if (!strcmp(L->name, "fm.SYNTH.COM.TEMPO")) g_tempo = 40.0 + v / 10.0;     /* "40.0BPM" + 0.1 per step */
    if (!strcmp(L->name, "vm.vs.mainZoom")) zoom_apply();
    if (!strcmp(L->name, "fm.PATCH.CTRL.TEMPO SYNC")) g_note_flash = GetTickCount();
    g_dirty = 1;
}
static void set(const char *ref, int v) { val_set(resolve(ref), v); }

/* postfix condition */
static int eval_cond(const char *expr)
{
    int st[32], sp = 0;
    const char *p = expr;
    while (p && *p) {
        const char *q = strchr(p, ',');
        size_t L = q ? (size_t)(q - p) : strlen(p);
        char tok[128];
        snprintf(tok, sizeof tok, "%.*s", (int)L, p);
        {
            char *a = tok, *z;
            while (*a && isspace((unsigned char)*a)) ++a;
            z = a + strlen(a);
            while (z > a && isspace((unsigned char)z[-1])) --z;
            *z = 0;
            if (!strcmp(a, "==") || !strcmp(a, "!=") || !strcmp(a, "<") || !strcmp(a, "<=") || !strcmp(a, ">") ||
                !strcmp(a, ">=") || !strcmp(a, "&&") || !strcmp(a, "||")) {
                int b2 = sp ? st[--sp] : 0, a2 = sp ? st[--sp] : 0, r;
                r = !strcmp(a, "==") ? a2 == b2 : !strcmp(a, "!=") ? a2 != b2 : !strcmp(a, "<") ? a2 < b2 :
                    !strcmp(a, "<=") ? a2 <= b2 : !strcmp(a, ">") ? a2 > b2 : !strcmp(a, ">=") ? a2 >= b2 :
                    !strcmp(a, "&&") ? (a2 && b2) : (a2 || b2);
                if (sp < 32) st[sp++] = r;
            } else if ((*a == '-' && isdigit((unsigned char)a[1])) || isdigit((unsigned char)*a)) {
                if (sp < 32) st[sp++] = atoi(a);
            } else if (*a) {
                if (sp < 32) st[sp++] = get(a);
            }
        }
        if (!q) break;
        p = q + 1;
    }
    return sp ? st[sp - 1] != 0 : 0;
}
static int panel_open(const Panel *p) { return !p->cond || eval_cond(p->cond); }

/* ------------------------------------------------------------ control values */
static Leaf *cleaf(const Ctl *c) { return c->nrefs ? resolve(c->refs[0]) : NULL; }
static int cval(const Ctl *c) { return c->nrefs ? get(c->refs[0]) : 0; }
static double cnorm(const Ctl *c)
{
    Leaf *L = cleaf(c);
    if (!L || L->max == L->min) return 0.0;
    return (double)(cval(c) - L->min) / (double)(L->max - L->min);
}
static int position(const Ctl *c)
{
    int v = cval(c), i, j;
    NTable *t = nt_get(c->table);
    Leaf *L;
    if (t) {
        for (i = 0; i < t->n; ++i) for (j = 0; j < t->gn[i]; ++j) if (t->g[i][j] == v) return i;
        return 0;
    }
    L = cleaf(c);
    return L ? v - L->min : v;
}
static int value_at(const Ctl *c, int pos)
{
    NTable *t = nt_get(c->table);
    Leaf *L;
    if (t) {
        if (pos < 0) pos = 0;
        if (pos > t->n - 1) pos = t->n - 1;
        return t->g[pos][0];
    }
    L = cleaf(c);
    return (L ? L->min : 0) + pos;
}
static void label(const Ctl *c, char *out, size_t cap)
{
    Leaf *L = cleaf(c);
    STable *t = st_get(c->table);
    int v;
    if (!L) { out[0] = 0; return; }
    v = cval(c);
    if (t && t->n) {
        int i = v - L->min;
        if (i < 0) i = 0;
        if (i > t->n - 1) i = t->n - 1;
        snprintf(out, cap, "%s", t->s[i]);
        return;
    }
    snprintf(out, cap, "%d%s%s", v + c->offsetValue, c->unit ? " " : "", c->unit ? c->unit : "");
}

/* ----------------------------------------------------------------- drawing */
static uint32_t *g_fb;
static HDC g_fbdc;
static HBITMAP g_fbbm;

static void blit(const Bmp *b, int sx, int sy, int w, int h, int dx, int dy)
{
    int x, y;
    if (!b || !b->px) return;
    for (y = 0; y < h; ++y) {
        int ty = dy + y, syy = sy + y;
        const uint32_t *s;
        uint32_t *d;
        if (ty < 0 || ty >= g_fbh || syy < 0 || syy >= b->h) continue;
        s = b->px + (size_t)syy * b->w;
        d = g_fb + (size_t)ty * g_fbw;
        for (x = 0; x < w; ++x) {
            int tx = dx + x, sxx = sx + x;
            uint32_t p, q, a, ia;
            if (tx < 0 || tx >= g_fbw || sxx < 0 || sxx >= b->w) continue;
            p = s[sxx];
            a = p >> 24;
            if (a == 255) { d[tx] = p; continue; }
            if (!a) continue;
            q = d[tx];
            ia = 255 - a;
            d[tx] = (((p & 0xff) + ((q & 0xff) * ia + 127) / 255)) |
                    (((((p >> 8) & 0xff) + (((q >> 8) & 0xff) * ia + 127) / 255)) << 8) |
                    (((((p >> 16) & 0xff) + (((q >> 16) & 0xff) * ia + 127) / 255)) << 16) | 0xff000000u;
        }
    }
}
static void draw_frame(const Bmp *b, int f, int x, int y)
{
    int w, h;
    if (!b || !b->px) return;
    frame_size(b, &w, &h);
    if (f < 0) f = 0;
    if (f > b->n - 1) f = b->n - 1;
    blit(b, b->dir == 1 ? f * w : 0, b->dir == 1 ? 0 : f * h, w, h, x, y);
}
static void fill(int x0, int y0, int w, int h, int r, int g, int b, int a)
{
    int x, y;
    for (y = y0; y < y0 + h; ++y) {
        uint32_t *d;
        if (y < 0 || y >= g_fbh) continue;
        d = g_fb + (size_t)y * g_fbw;
        for (x = x0; x < x0 + w; ++x) {
            uint32_t q;
            if (x < 0 || x >= g_fbw) continue;
            q = d[x];
            d[x] = (uint32_t)(((b * a + (int)(q & 0xff) * (255 - a) + 127) / 255)) |
                   ((uint32_t)((g * a + (int)((q >> 8) & 0xff) * (255 - a) + 127) / 255) << 8) |
                   ((uint32_t)((r * a + (int)((q >> 16) & 0xff) * (255 - a) + 127) / 255) << 16) | 0xff000000u;
        }
    }
}
static void draw_text_wr(Writer *w, const char *s, int x, int y, int cw, int ch, int alignV)
{
    RECT r;
    UINT fl = DT_SINGLELINE | DT_NOPREFIX;
    if (!w) return;
    if (w->has_back) fill(x, y, cw, ch, w->br, w->bg, w->bb, w->ba);
    if (!w->font)
        w->font = CreateFontA(-w->size, 0, 0, 0, FW_NORMAL, 0, 0, 0, DEFAULT_CHARSET, OUT_DEFAULT_PRECIS,
                              CLIP_DEFAULT_PRECIS, ANTIALIASED_QUALITY, DEFAULT_PITCH, w->face);
    GdiFlush();
    SelectObject(g_fbdc, w->font);
    SetTextColor(g_fbdc, w->color);
    SetBkMode(g_fbdc, TRANSPARENT);
    r.left = x; r.top = y; r.right = x + cw; r.bottom = y + ch;
    fl |= w->alignH == 1 ? DT_CENTER : w->alignH == 2 ? DT_RIGHT : DT_LEFT;
    fl |= alignV ? DT_VCENTER : DT_TOP;
    DrawTextA(g_fbdc, s, -1, &r, fl);
    GdiFlush();
}
static void draw_text(Writer *w, const char *s, int x, int y, int cw, int ch) { if (w) draw_text_wr(w, s, x, y, cw, ch, w->alignV); }

/* the patch name: eight words of two characters (fm.PATCH.NAME0.name[0..7]) */
static void patch_name(char *out)
{
    int i, n = 0;
    char ref[64];
    for (i = 0; i < 8; ++i) {
        int w;
        snprintf(ref, sizeof ref, "fm.PATCH.NAME0.name[%d]", i);
        w = get(ref) & 0xffff;
        out[n++] = (char)(((w >> 8) & 0xff) ? (w >> 8) & 0xff : ' ');
        out[n++] = (char)((w & 0xff) ? w & 0xff : ' ');
    }
    while (n > 0 && out[n - 1] == ' ') --n;
    out[n] = 0;
}

/* the CHORUS LEDs (rva 0x3515B0) and buttons (rva 0x351410) */
static int chorus_led(const Ctl *c)
{
    int t = get("fm.PATCH.NAME3.EFFECT TYPE"), d = get("fm.PATCH.EFX.EFFECT DEPTH");
    if (c->role == 1) return (t == 2 || t == 4) && d > 0;
    if (c->role == 2) return (t == 3 || t == 4) && d > 0;
    return 0;
}
static void chorus_press(const Ctl *c, int both)
{
    if (c->role == 0) {
        int t = get("fm.PATCH.NAME3.EFFECT TYPE");
        if (t >= 2 && t <= 4) set("fm.PATCH.EFX.EFFECT DEPTH", 0);
        return;
    }
    set("fm.PATCH.NAME3.EFFECT TYPE", both ? 4 : c->role == 1 ? 2 : 3);
    set("fm.PATCH.EFX.EFFECT DEPTH", 255);
    set("fm.PATCH.NAME3.EFFECT TONE", 128);
}

static Ctl *g_pressed[8];
static int g_npressed;
static int is_pressed(const Ctl *c) { int i; for (i = 0; i < g_npressed; ++i) if (g_pressed[i] == c) return 1; return 0; }
static void press(Ctl *c) { if (g_npressed < 8 && !is_pressed(c)) g_pressed[g_npressed++] = c; }

/* the keys in key order (rva 0x2D3E20): key i down when the note value's state of
 * i + 12 x OCTAVE SHIFT is above 0 (what the UI timer drained and the keyboard wrote) */
static void draw_keyboard(const Ctl *c)
{
    int i, shift = get("fm.PATCH.NAME1.OCTAVE SHIFT"), st[128];
    if (!c->bmp || !c->bmp->px) return;
    EnterCriticalSection(&g_lock);
    for (i = 0; i < 128; ++i) st[i] = juno_gui_keybed_state(g_eng, i);
    LeaveCriticalSection(&g_lock);
    for (i = 0; i < c->nkeys; ++i) {
        const Key *k = &c->keys[i];
        unsigned n = (unsigned)(k->n + 12 * shift);
        const int *r = c->rects[k->shape][n <= 127u && st[n] > 0];
        blit(c->bmp, r[0], r[1], r[2], r[3], k->x, k->y);
    }
    if (shift && c->nwr) {
        char s[32];
        snprintf(s, sizeof s, "OCTAVE %s%d", shift > 0 ? "+" : "", shift);
        draw_text(c->wr[0], s, c->x + 4, c->y + 4, 150, 26);
    }
}

static void draw_control(Ctl *c)
{
    int held = is_pressed(c), w, h;
    char s[256];
    switch (c->type) {
    case C_SLIDER:
        if (!c->bmp || !c->bmp->px) return;
        frame_size(c->bmp, &w, &h);
        draw_frame(c->bmp, 0, c->x + (c->w - w) / 2, (int)floor(c->y + (c->h - h) * (1.0 - cnorm(c)) + 0.5));
        return;
    case C_KNOB:
        if (!c->bmp || !c->bmp->px) return;
        if (c->bmp->n <= 4) { draw_frame(c->bmp, position(c), c->x, c->y); return; }
        {
            int s0 = c->has_sr ? c->sr0 : 0, s1 = c->has_sr ? c->sr1 : c->bmp->n - 1;
            draw_frame(c->bmp, s0 + (int)floor(cnorm(c) * (s1 - s0) + 0.5), c->x, c->y);
        }
        return;
    case C_DISPLAY:
        if (c->pic) {
            int v = cval(c), f;
            if (!strcmp(c->pic->name, "displayNote.png")) {
                f = v && GetTickCount() - g_note_flash < (DWORD)c->timeout;
                if (f) g_dirty = 1;
            } else if (c->npic >= 0) f = (v >= 0 && v < c->npic) ? c->piclist[v] : 0;
            else f = v;
            draw_frame(c->pic, f, c->x, c->y);
        } else if (c->nwr && c->wr[0]) {
            label(c, s, sizeof s);
            draw_text(c->wr[0], s, c->x, c->y, c->w, c->h);
        }
        return;
    case C_LATCH: {
        int on = c->has_on ? cval(c) == c->onValue : cval(c) != 0;
        draw_frame(c->bmp, (on ? 2 : 0) + (held ? 1 : 0), c->x, c->y);
        return;
    }
    case C_UNLATCH:
    case C_MENU:
    case C_SETUP:
        if (c->fn && !strcmp(c->fn, "PlugOut")) return;          /* SYSTEM-8 PLUG-OUT: not part of this port */
        draw_frame(c->bmp, held ? 1 : 0, c->x, c->y);
        if (c->type == C_SETUP && c->nwr && c->args) {
            const char *comma = strchr(c->args, ',');
            frame_size(c->bmp, &w, &h);
            draw_text(c->wr[0], comma ? comma + 1 : c->args, c->x, c->y, w, h);
        }
        return;
    case C_JU60BTN:
        draw_frame(c->bmp, held ? 1 : 0, c->x, c->y);
        return;
    case C_JU60LED:
        draw_frame(c->pic, chorus_led(c), c->x, c->y);
        return;
    case C_LFOLED:
        draw_frame(c->pic, 0, c->x, c->y);                       /* not yet ported: drawn idle */
        return;
    case C_PATCHNAME:
        draw_frame(c->bmp, held ? 1 : 0, c->bx, c->by);
        patch_name(s);
        if (c->nwr) draw_text(c->wr[0], s, c->tx, c->ty, c->tw, c->th);
        return;
    case C_KEYBOARD:
        draw_keyboard(c);
        return;
    default:
        return;
    }
}

static void draw_panel(Panel *p)
{
    int i;
    if (!panel_open(p)) return;
    if (p->bmp && p->bmp->px) blit(p->bmp, 0, 0, p->bmp->w, p->bmp->h, p->x, p->y);
    for (i = 0; i < p->n; ++i) {
        if (p->items[i].p) draw_panel(p->items[i].p);
        else draw_control(p->items[i].c);
    }
}

/* ------------------------------------------------------- banks and patches */
typedef struct { char name[64]; unsigned char *bytes; int len; } Bank;
static Bank g_banks[32];
static int g_nbanks, g_bank, g_patch, g_patchsel;
#define HEADER 23
#define STRIDE 20223

static void bank_name(const Bank *b, int i, char *out)
{
    int k, n = 0;
    const unsigned char *r = b->bytes + HEADER + (size_t)i * STRIDE;
    for (k = 0; k < 16; ++k) out[n++] = (char)((r[k] >= 32 && r[k] < 127) ? r[k] : ' ');
    while (n > 0 && out[n - 1] == ' ') --n;
    out[n] = 0;
}
static int bank_add(const char *name, unsigned char *bytes, int len)
{
    if (g_nbanks >= 32 || len < HEADER + 64 * STRIDE || memcmp(bytes, "KoaBankFile00003", 16)) return -1;
    snprintf(g_banks[g_nbanks].name, sizeof g_banks[0].name, "%s", name);
    g_banks[g_nbanks].bytes = bytes;
    g_banks[g_nbanks].len = len;
    return g_nbanks++;
}
/* the embedded banks: count, then per bank name, size and a zero-run code
 * (byte b != 0: itself; 0, lo, hi: that many zeros) */
static void banks_load(void)
{
    DWORD len;
    const unsigned char *d = resource(ASSET_BANKS, &len), *p, *end;
    uint32_t n, i;
    if (!d) return;
    p = d;
    end = d + len;
    n = (uint32_t)p[0] | ((uint32_t)p[1] << 8) | ((uint32_t)p[2] << 16) | ((uint32_t)p[3] << 24);
    p += 4;
    for (i = 0; i < n && p < end; ++i) {
        uint32_t nl = (uint32_t)p[0] | ((uint32_t)p[1] << 8), raw, enc, o = 0, k;
        char name[64];
        unsigned char *b;
        snprintf(name, sizeof name, "%.*s", (int)nl, (const char *)p + 2);
        p += 2 + nl;
        raw = (uint32_t)p[0] | ((uint32_t)p[1] << 8) | ((uint32_t)p[2] << 16) | ((uint32_t)p[3] << 24);
        enc = (uint32_t)p[4] | ((uint32_t)p[5] << 8) | ((uint32_t)p[6] << 16) | ((uint32_t)p[7] << 24);
        p += 8;
        b = xmalloc(raw);
        for (k = 0; k < enc && o < raw;) {
            if (p[k]) { b[o++] = p[k++]; continue; }
            {
                uint32_t run = (uint32_t)p[k + 1] | ((uint32_t)p[k + 2] << 8);
                o += run;                                   /* xmalloc is zeroed */
                k += 3;
            }
        }
        p += enc;
        bank_add(name, b, (int)raw);
    }
}

static char g_status[256] = "JUNO-60";
static HWND g_wnd;
static void status_set(const char *s)
{
    char t[300];
    snprintf(g_status, sizeof g_status, "%s", s);
    snprintf(t, sizeof t, "JUNO-60  --  %s", s);
    if (g_wnd) SetWindowTextA(g_wnd, t);
}

/* A patch load while the audio plays is landed by the audio thread (land_patch):
 * it first renders ahead -- the queue grows by the last load's measured block --
 * so the load's slow block cannot empty it, then queues the load at a block
 * boundary. The change lands some ms late; the audio never breaks (END_GOAL's
 * INVARIANT). The calls are the same as below: the patch browser's load, then the
 * view's patch id. */
static volatile LONG g_preq = -1;      /* the load to land: bank * 64 + idx; -1 none */
static volatile LONG g_landed;         /* 1: landed, the GUI shows it */
static LONG g_landed_req, g_landed_ok;
static double g_load_ms = 12.0;        /* the slowest recent load's block, measured on this computer */
static const Leaf *g_patchid;          /* vm.vs.patchId */
static volatile LONG g_audio_state;    /* 0 starting, 1 WASAPI, 2 waveOut, -1 no output device */
static int audio_live(void) { return g_audio_state == 1 || g_audio_state == 2; }

static void land_patch(void)            /* the audio thread, between two blocks */
{
    LONG r = InterlockedExchange(&g_preq, -1), commit;
    int ok = 0;
    if (r < 0) return;
    commit = r & 0x40000000;
    r &= 0x3FFFFFFF;
    if (r / 64 >= g_nbanks) return;
    EnterCriticalSection(&g_lock);
    if (g_log) fprintf(g_log, "queue_patch %d %s\n", (int)(r % 64), g_banks[r / 64].name);
    juno_gui_queue_patch(g_eng, g_banks[r / 64].bytes, g_banks[r / 64].len, (int)(r % 64));
    if (g_patchid) ok = E_model_set(g_patchid->id, (int)(r % 64));
    if (commit) E_commit();
    LeaveCriticalSection(&g_lock);
    g_landed_req = r;
    g_landed_ok = ok;
    InterlockedExchange(&g_landed, 1);
}

/* A patch load: the plugin's load (rva 0x338090: the patch, then its set of the
 * patch number, no commit), then -- from the panel's ManagePatch buttons, whose
 * command handler ends with one (rva 0x322E60) -- the model's commit; a load
 * from the patch window's list does not commit (rva 0x3278C0, the window open) */
static void load_patch(int idx, int commit)
{
    Bank *b;
    char nm[32], s[128];
    if (g_bank < 0 || g_bank >= g_nbanks) return;
    b = &g_banks[g_bank];
    if (audio_live() && !g_log) {
        g_patch = g_patchsel = idx;
        snprintf(s, sizeof s, "%s: %d ...", b->name, idx + 1);
        status_set(s);
        InterlockedExchange(&g_preq, (commit ? 0x40000000 : 0) | (g_bank * 64 + idx));
        g_dirty = 1;
        return;
    }
    EnterCriticalSection(&g_lock);
    if (g_log) fprintf(g_log, "queue_patch %d %s\n", idx, b->name);
    juno_gui_queue_patch(g_eng, b->bytes, b->len, idx);     /* the patch browser's load, at the next block */
    if (g_patchid && !E_model_set(g_patchid->id, idx)) local_put(g_patchid->id, idx);
    if (commit) E_commit();
    eng_refresh();
    LeaveCriticalSection(&g_lock);
    g_patch = g_patchsel = idx;
    patch_name(nm);
    snprintf(s, sizeof s, "%s: %d %s", b->name, idx + 1, nm);
    status_set(s);
    g_dirty = 1;
}

/* --------------------------------------------- MIDI and key events -> audio */
static volatile LONG g_qhead, g_qtail;
static uint32_t g_queue[1024];
static CRITICAL_SECTION g_qlock;
static void push_midi(uint32_t m)
{
    EnterCriticalSection(&g_qlock);
    if (g_log) fprintf(g_log, "midi %06x\n", (unsigned)m);
    if (((g_qhead + 1) & 1023) != g_qtail) { g_queue[g_qhead] = m; g_qhead = (g_qhead + 1) & 1023; }
    LeaveCriticalSection(&g_qlock);
    g_dirty = 1;
}

static HMIDIIN g_midi;
static int g_mididev = -1;
static void CALLBACK midi_cb(HMIDIIN h, UINT msg, DWORD_PTR inst, DWORD_PTR p1, DWORD_PTR p2)
{
    (void)h; (void)inst; (void)p2;
    if (msg == MIM_DATA && ((p1 & 0xF0) >= 0x80) && ((p1 & 0xF0) < 0xF0)) push_midi((uint32_t)p1);
}
static void midi_open(int dev)
{
    if (g_midi) { midiInStop(g_midi); midiInClose(g_midi); g_midi = NULL; }
    g_mididev = -1;
    if (dev < 0 || dev >= (int)midiInGetNumDevs()) return;
    if (midiInOpen(&g_midi, (UINT)dev, (DWORD_PTR)midi_cb, 0, CALLBACK_FUNCTION) == MMSYSERR_NOERROR) {
        MIDIINCAPSA caps;
        char s[128];
        midiInStart(g_midi);
        g_mididev = dev;
        midiInGetDevCapsA((UINT_PTR)dev, &caps, sizeof caps);
        snprintf(s, sizeof s, "MIDI in: %s", caps.szPname);
        status_set(s);
    }
}

/* --------------------------------------------------------------- settings
 * The window's own choices -- audio latency, zoom, MIDI input -- kept in
 * %APPDATA%\JUNO-60\settings.ini (not the plugin's state; no test mode reads it). */
static char g_ini[MAX_PATH];
static void ini_init(void)
{
    char d[MAX_PATH];
    if (FAILED(SHGetFolderPathA(NULL, CSIDL_APPDATA, NULL, 0, d))) return;
    snprintf(g_ini, sizeof g_ini, "%s\\JUNO-60", d);
    CreateDirectoryA(g_ini, NULL);
    strncat(g_ini, "\\settings.ini", sizeof g_ini - strlen(g_ini) - 1);
}
static int ini_get(const char *sec, const char *key, int def) { return g_ini[0] ? (int)GetPrivateProfileIntA(sec, key, def, g_ini) : def; }
static void ini_put(const char *sec, const char *key, int v)
{
    char s[32];
    if (!g_ini[0]) return;
    snprintf(s, sizeof s, "%d", v);
    WritePrivateProfileStringA(sec, key, s, g_ini);
}
static void ini_gets(const char *sec, const char *key, char *out, int cap)
{
    out[0] = 0;
    if (g_ini[0]) GetPrivateProfileStringA(sec, key, "", out, (DWORD)cap, g_ini);
}
static void ini_puts(const char *sec, const char *key, const char *v) { if (g_ini[0]) WritePrivateProfileStringA(sec, key, v, g_ini); }

/* ------------------------------------------------------------------- audio
 * WASAPI, shared mode, event-driven (Windows Vista and later). The engine renders
 * for the device's own mix rate when the plugin's converter table has it --
 * 44100, 48000, 88200, 96000, 176400, 192000, 384000: as in a DAW at that rate,
 * nothing resamples -- else for 48000 and Windows converts. The queue holds the
 * latency setting's worth of 128-sample blocks; "lowest" asks the device for its
 * smallest period (IAudioClient3, Windows 10). waveOut is the fallback. */
#define BLK 128                        /* one engine block: 2.67 ms at 48000 */
static int g_rate = 48000;             /* the host rate the engine renders for */
static volatile LONG g_lat_ms = 21;    /* the latency setting in ms; 0 = the device's lowest */
static volatile LONG g_reopen;         /* a new setting: the output reopens */
static char g_audio_desc[192] = "Output: starting";
static CRITICAL_SECTION g_desc_lock;   /* g_audio_desc: the audio thread writes, the GUI reads */
static void audio_desc(const char *fmt, ...)
{
    va_list a;
    va_start(a, fmt);
    EnterCriticalSection(&g_desc_lock);
    vsnprintf(g_audio_desc, sizeof g_audio_desc, fmt, a);
    LeaveCriticalSection(&g_desc_lock);
    va_end(a);
}
static void audio_desc_get(char *out, size_t cap)
{
    EnterCriticalSection(&g_desc_lock);
    snprintf(out, cap, "%s", g_audio_desc);
    LeaveCriticalSection(&g_desc_lock);
}
static float g_gain = 0.5f;            /* the monitor fader after the engine (a DAW fader's role) */
static volatile LONG g_run = 1;
static HANDLE g_audio_thread;
static volatile LONG g_dropouts;       /* the device found the queue empty: a gap */
static volatile LONG g_blocks;         /* blocks rendered for the device */

static int rate_in_table(int r)
{
    return r == 44100 || r == 48000 || r == 88200 || r == 96000 || r == 176400 || r == 192000 || r == 384000;
}

static void render_block(float *L, float *R)
{
    juno_host_note ev[256];
    juno_host_param par[256];
    int nev = 0, npar = 0;
    uint32_t base = juno_midi_base();
    EnterCriticalSection(&g_qlock);
    while (g_qtail != g_qhead && nev < 256 && npar < 256) {
        uint32_t m = g_queue[g_qtail];
        unsigned st = m & 0xF0, ch = m & 0x0F, d1 = (m >> 8) & 0x7F, d2 = (m >> 16) & 0x7F;
        g_qtail = (g_qtail + 1) & 1023;
        if (st == 0x90 || st == 0x80) {                  /* a host note event, as a DAW sends it */
            ev[nev].offset = 0;
            ev[nev].type = (st == 0x90 && d2) ? 0 : 1;
            ev[nev].channel = (int)ch;
            ev[nev].pitch = (int)d1;
            ev[nev].velocity = (st == 0x90 && d2) ? (float)d2 / 127.0f : 0.5f;
            ++nev;
        } else if (st == 0xB0) {                         /* CC n: the MIDI-mapping parameter base + n */
            par[npar].id = base + d1; par[npar].offset = 0; par[npar].value = d2 / 127.0; ++npar;
        } else if (st == 0xD0) {                         /* channel aftertouch: base + 128 */
            par[npar].id = base + 128; par[npar].offset = 0; par[npar].value = d1 / 127.0; ++npar;
        } else if (st == 0xE0) {                         /* pitch bend: base + 129 */
            par[npar].id = base + 129; par[npar].offset = 0; par[npar].value = (double)(d1 | (d2 << 7)) / 16383.0; ++npar;
        }
    }
    LeaveCriticalSection(&g_qlock);
    EnterCriticalSection(&g_lock);
    E_process(ev, nev, par, npar, g_tempo, L, R, BLK);
    LeaveCriticalSection(&g_lock);
}

/* the samples into the device's format: 0 float32, 1 int16, 2 int24, 3 int32 */
static void put_samples(unsigned char *dst, int kind, int ch, const float *L, const float *R, int n)
{
    int k, c;
    for (k = 0; k < n; ++k) {
        float v[2];
        v[0] = L[k] * g_gain;
        v[1] = R[k] * g_gain;
        for (c = 0; c < 2; ++c) v[c] = v[c] > 1.f ? 1.f : v[c] < -1.f ? -1.f : v[c];
        for (c = 0; c < ch; ++c) {
            float x = ch == 1 ? 0.5f * (v[0] + v[1]) : c < 2 ? v[c] : 0.f;
            if (kind == 0) { memcpy(dst, &x, 4); dst += 4; }
            else if (kind == 1) { short q = (short)lrintf(x * 32767.f); memcpy(dst, &q, 2); dst += 2; }
            else if (kind == 2) { long q = lrintf(x * 8388607.f); dst[0] = (unsigned char)q; dst[1] = (unsigned char)(q >> 8); dst[2] = (unsigned char)(q >> 16); dst += 3; }
            else { int32_t q = (int32_t)lrint((double)x * 2147483647.0); memcpy(dst, &q, 4); dst += 4; }
        }
    }
}

static const GUID SUB_FLOAT = {0x00000003, 0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}};
static const GUID SUB_PCM = {0x00000001, 0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}};
static int fmt_kind(const WAVEFORMATEX *f)
{
    int pcm = f->wFormatTag == WAVE_FORMAT_PCM, flt = f->wFormatTag == WAVE_FORMAT_IEEE_FLOAT;
    if (f->wFormatTag == WAVE_FORMAT_EXTENSIBLE && f->cbSize >= 22) {
        const WAVEFORMATEXTENSIBLE *x = (const WAVEFORMATEXTENSIBLE *)f;
        pcm = IsEqualGUID(&x->SubFormat, &SUB_PCM);
        flt = IsEqualGUID(&x->SubFormat, &SUB_FLOAT);
    }
    if (flt && f->wBitsPerSample == 32) return 0;
    if (pcm) return f->wBitsPerSample == 16 ? 1 : f->wBitsPerSample == 24 ? 2 : f->wBitsPerSample == 32 ? 3 : -1;
    return -1;
}

typedef struct {
    IMMDevice *dev;
    IAudioClient *ac;
    IAudioRenderClient *rc;
    WAVEFORMATEX *fmt;                 /* CoTaskMemAlloc'd, or &own */
    WAVEFORMATEXTENSIBLE own;
    int kind, ch;
    UINT32 frames, period, target;     /* the buffer, the device period, the queue to keep */
} Out;

static void out_close(Out *o)
{
    if (o->ac) o->ac->lpVtbl->Stop(o->ac);
    if (o->rc) o->rc->lpVtbl->Release(o->rc);
    if (o->ac) o->ac->lpVtbl->Release(o->ac);
    if (o->dev) o->dev->lpVtbl->Release(o->dev);
    if (o->fmt && o->fmt != &o->own.Format) CoTaskMemFree(o->fmt);
    memset(o, 0, sizeof *o);
}

/* the default device's mix rate (0: no device) */
static int device_rate(void)
{
    IMMDeviceEnumerator *en = NULL;
    IMMDevice *dev = NULL;
    IAudioClient *ac = NULL;
    WAVEFORMATEX *mix = NULL;
    int r = 0;
    if (SUCCEEDED(CoCreateInstance(&CLSID_MMDeviceEnumerator, NULL, CLSCTX_ALL, &IID_IMMDeviceEnumerator, (void **)&en)) &&
        SUCCEEDED(en->lpVtbl->GetDefaultAudioEndpoint(en, eRender, eConsole, &dev)) &&
        SUCCEEDED(dev->lpVtbl->Activate(dev, &IID_IAudioClient, CLSCTX_ALL, NULL, (void **)&ac)) &&
        SUCCEEDED(ac->lpVtbl->GetMixFormat(ac, &mix)))
        r = (int)mix->nSamplesPerSec;
    if (mix) CoTaskMemFree(mix);
    if (ac) ac->lpVtbl->Release(ac);
    if (dev) dev->lpVtbl->Release(dev);
    if (en) en->lpVtbl->Release(en);
    return r;
}

static int out_open(Out *o, HANDLE ev, int lat_ms)
{
    IMMDeviceEnumerator *en = NULL;
    WAVEFORMATEX *mix = NULL;
    REFERENCE_TIME defp = 0, minp = 0;
    int lowest = 0, rate;
    memset(o, 0, sizeof *o);
    if (FAILED(CoCreateInstance(&CLSID_MMDeviceEnumerator, NULL, CLSCTX_ALL, &IID_IMMDeviceEnumerator, (void **)&en)))
        return 0;
    if (FAILED(en->lpVtbl->GetDefaultAudioEndpoint(en, eRender, eConsole, &o->dev))) { en->lpVtbl->Release(en); return 0; }
    en->lpVtbl->Release(en);
    /* the lowest setting: the device's smallest shared-mode period */
    if (lat_ms == 0) {
        IAudioClient3 *a3 = NULL;
        if (SUCCEEDED(o->dev->lpVtbl->Activate(o->dev, &IID_IAudioClient3, CLSCTX_ALL, NULL, (void **)&a3))) {
            UINT32 def = 0, fund = 0, mn = 0, mx = 0;
            if (SUCCEEDED(a3->lpVtbl->GetMixFormat(a3, &mix)) && (int)mix->nSamplesPerSec == g_rate && fmt_kind(mix) >= 0 &&
                SUCCEEDED(a3->lpVtbl->GetSharedModeEnginePeriod(a3, mix, &def, &fund, &mn, &mx)) && mn > 0 &&
                SUCCEEDED(a3->lpVtbl->InitializeSharedAudioStream(a3, AUDCLNT_STREAMFLAGS_EVENTCALLBACK, mn, mix, NULL))) {
                o->ac = (IAudioClient *)a3;          /* IAudioClient3 begins with IAudioClient's slots */
                o->fmt = mix;
                o->period = mn;
                lowest = 1;
            } else {
                if (mix) CoTaskMemFree(mix);
                mix = NULL;
                a3->lpVtbl->Release(a3);
            }
        }
        if (!lowest) lat_ms = 11;
    }
    if (!o->ac) {
        DWORD flags = AUDCLNT_STREAMFLAGS_EVENTCALLBACK;
        if (FAILED(o->dev->lpVtbl->Activate(o->dev, &IID_IAudioClient, CLSCTX_ALL, NULL, (void **)&o->ac))) { o->ac = NULL; out_close(o); return 0; }
        if (FAILED(o->ac->lpVtbl->GetMixFormat(o->ac, &mix))) { out_close(o); return 0; }
        if ((int)mix->nSamplesPerSec == g_rate && fmt_kind(mix) >= 0) o->fmt = mix;
        else {                                       /* our own format; Windows converts */
            CoTaskMemFree(mix);
            memset(&o->own, 0, sizeof o->own);
            o->own.Format.wFormatTag = WAVE_FORMAT_EXTENSIBLE;
            o->own.Format.nChannels = 2;
            o->own.Format.nSamplesPerSec = (DWORD)g_rate;
            o->own.Format.wBitsPerSample = 32;
            o->own.Format.nBlockAlign = 8;
            o->own.Format.nAvgBytesPerSec = (DWORD)g_rate * 8;
            o->own.Format.cbSize = 22;
            o->own.Samples.wValidBitsPerSample = 32;
            o->own.dwChannelMask = 3;                /* front left, front right */
            o->own.SubFormat = SUB_FLOAT;
            o->fmt = &o->own.Format;
            flags |= AUDCLNT_STREAMFLAGS_AUTOCONVERTPCM | AUDCLNT_STREAMFLAGS_SRC_DEFAULT_QUALITY;
        }
        /* a buffer room for the largest setting; the queue is kept at the setting */
        if (FAILED(o->ac->lpVtbl->Initialize(o->ac, AUDCLNT_SHAREMODE_SHARED, flags, 1000000, 0, o->fmt, NULL))) { out_close(o); return 0; }
        o->ac->lpVtbl->GetDevicePeriod(o->ac, &defp, &minp);
        o->period = (UINT32)((defp * g_rate + 9999999) / 10000000);
    }
    o->kind = fmt_kind(o->fmt);
    o->ch = o->fmt->nChannels;
    if (FAILED(o->ac->lpVtbl->GetBufferSize(o->ac, &o->frames)) ||
        FAILED(o->ac->lpVtbl->GetService(o->ac, &IID_IAudioRenderClient, (void **)&o->rc)) ||
        FAILED(o->ac->lpVtbl->SetEventHandle(o->ac, ev))) { out_close(o); return 0; }
    rate = g_rate;
    if (lowest) o->target = o->frames;
    else {
        UINT32 want = (UINT32)((LONGLONG)lat_ms * rate / 1000);
        if (want < o->period + BLK) want = o->period + BLK;
        o->target = want < o->frames ? want : o->frames;
    }
    audio_desc("Output: WASAPI, %d Hz, %d ch, period %.1f ms, queue %.1f ms%s%s", rate, o->ch, o->period * 1000.0 / rate,
               o->target * 1000.0 / rate, lowest ? " (the device's lowest)" : "",
               o->fmt == &o->own.Format ? " (Windows converts the rate)" : "");
    return 1;
}

/* fill the queue up to its target, one engine block at a time */
static HRESULT out_fill(Out *o, int counting)
{
    UINT32 pad;
    HRESULT hr = o->ac->lpVtbl->GetCurrentPadding(o->ac, &pad);
    float L[BLK], R[BLK];
    if (FAILED(hr)) return hr;
    UINT32 target = o->target;
    if (counting && pad == 0) InterlockedIncrement(&g_dropouts);
    if (g_preq >= 0) {                     /* a patch load waits: render ahead first */
        UINT32 more = (UINT32)((g_load_ms * 1.5 + 2.0) * g_rate / 1000.0);
        target = o->target + more;
        if (target > o->frames) target = o->frames;
    }
    for (;;) {
        static int heavy;                  /* the next block is the landed load's */
        BYTE *data;
        LARGE_INTEGER t0, t1, f;
        if (g_preq >= 0 && pad + BLK > target) { land_patch(); heavy = 1; }
        if (pad + BLK > (heavy ? o->frames : target)) break;
        hr = o->rc->lpVtbl->GetBuffer(o->rc, BLK, &data);
        if (FAILED(hr)) return hr;
        QueryPerformanceCounter(&t0);
        render_block(L, R);
        QueryPerformanceCounter(&t1);
        put_samples(data, o->kind, o->ch, L, R, BLK);
        o->rc->lpVtbl->ReleaseBuffer(o->rc, BLK, 0);
        InterlockedIncrement(&g_blocks);
        pad += BLK;
        if (heavy) {                       /* the load's block: what the next render-ahead allows for */
            double ms;
            QueryPerformanceFrequency(&f);
            ms = (double)(t1.QuadPart - t0.QuadPart) * 1000.0 / (double)f.QuadPart;
            g_load_ms = ms > g_load_ms ? ms : 0.8 * g_load_ms + 0.2 * ms;
            heavy = 0;
            break;
        }
    }
    return S_OK;
}

static int run_wasapi(void)
{
    HANDLE ev = CreateEventA(NULL, FALSE, FALSE, NULL);
    Out o;
    int opened = 0;
    while (g_run) {
        int lat = (int)g_lat_ms, dev;
        InterlockedExchange(&g_reopen, 0);
        /* a device with a new mix rate the table has: the host's rate change on a
         * running instance (setActive / setupProcessing / setActive, CLAIMS A28) */
        dev = device_rate();
        if (opened && dev && dev != g_rate && rate_in_table(dev)) {
            EnterCriticalSection(&g_lock);
            juno_gui_set_active(g_eng, 0);
            juno_gui_setup_processing(g_eng, (double)dev);
            juno_gui_set_active(g_eng, 1);
            LeaveCriticalSection(&g_lock);
            g_rate = dev;
        }
        if (!out_open(&o, ev, lat)) {
            if (!opened) { CloseHandle(ev); return 0; }    /* no WASAPI: waveOut */
            InterlockedExchange(&g_audio_state, -1);
            Sleep(500);                                    /* the device is gone: try again */
            continue;
        }
        opened = 1;
        InterlockedExchange(&g_audio_state, 1);
        if (SUCCEEDED(out_fill(&o, 0)) && SUCCEEDED(o.ac->lpVtbl->Start(o.ac))) {
            while (g_run && !g_reopen) {
                WaitForSingleObject(ev, 200);
                if (FAILED(out_fill(&o, 1))) break;       /* the device changed or is gone */
            }
        }
        out_close(&o);
    }
    CloseHandle(ev);
    return 1;
}

static void run_waveout(void)
{
    WAVEFORMATEX wf;
    HWAVEOUT wo;
    enum { NB = 64 };
    WAVEHDR hdr[NB];
    static short pcm[NB][BLK * 2];
    float L[BLK], R[BLK];
    HANDLE ev = CreateEventA(NULL, FALSE, FALSE, NULL);
    int i, k;
    memset(&wf, 0, sizeof wf);
    wf.wFormatTag = WAVE_FORMAT_PCM;
    wf.nChannels = 2;
    wf.nSamplesPerSec = (DWORD)g_rate;
    wf.wBitsPerSample = 16;
    wf.nBlockAlign = 4;
    wf.nAvgBytesPerSec = (DWORD)g_rate * 4;
    if (waveOutOpen(&wo, WAVE_MAPPER, &wf, (DWORD_PTR)ev, 0, CALLBACK_EVENT) != MMSYSERR_NOERROR) {
        InterlockedExchange(&g_audio_state, -1);
        audio_desc("Output: none (no audio device)");
        return;
    }
    InterlockedExchange(&g_audio_state, 2);
    memset(hdr, 0, sizeof hdr);
    for (i = 0; i < NB; ++i) {
        hdr[i].lpData = (LPSTR)pcm[i];
        hdr[i].dwBufferLength = sizeof pcm[i];
        waveOutPrepareHeader(wo, &hdr[i], sizeof hdr[i]);
        hdr[i].dwFlags |= WHDR_DONE;
    }
    while (g_run) {
        static int shown_nb;
        int done = 0, started = 0, nb = (int)(((LONGLONG)(g_lat_ms ? g_lat_ms : 21) * g_rate / 1000 + BLK - 1) / BLK);
        if (nb < 3) nb = 3;
        if (nb > NB) nb = NB;
        if (nb != shown_nb) { shown_nb = nb; audio_desc("Output: waveOut, %d Hz, queue %.1f ms", g_rate, nb * BLK * 1000.0 / g_rate); }
        if (g_preq >= 0) {                 /* a patch load waits: render ahead first, then land it */
            int ahead = nb + (int)((g_load_ms * 1.5 + 2.0) * g_rate / 1000.0 / BLK) + 1, queued = 0;
            if (ahead > NB) ahead = NB;
            for (i = 0; i < ahead; ++i) if (!(hdr[i].dwFlags & WHDR_DONE)) ++queued;
            if (queued >= ahead - 1) land_patch();
            else nb = ahead;
        }
        for (i = 0; i < nb; ++i) {
            if (hdr[i].dwFlags & WHDR_DONE) ++done;
            if (hdr[i].dwUser) ++started;
        }
        if (started == nb && done == nb) InterlockedIncrement(&g_dropouts);
        for (i = 0; i < nb; ++i) {
            if (!(hdr[i].dwFlags & WHDR_DONE)) continue;
            hdr[i].dwUser = 1;
            InterlockedIncrement(&g_blocks);
            render_block(L, R);
            for (k = 0; k < BLK; ++k) {
                float l = L[k] * g_gain, r = R[k] * g_gain;
                l = l > 1.f ? 1.f : l < -1.f ? -1.f : l;
                r = r > 1.f ? 1.f : r < -1.f ? -1.f : r;
                pcm[i][2 * k] = (short)lrintf(l * 32767.f);
                pcm[i][2 * k + 1] = (short)lrintf(r * 32767.f);
            }
            hdr[i].dwFlags &= ~(DWORD)WHDR_DONE;
            waveOutWrite(wo, &hdr[i], sizeof hdr[i]);
        }
        WaitForSingleObject(ev, 20);
    }
    waveOutReset(wo);
    for (i = 0; i < NB; ++i) waveOutUnprepareHeader(wo, &hdr[i], sizeof hdr[i]);
    waveOutClose(wo);
}

static DWORD WINAPI audio_main(LPVOID arg)
{
    DWORD task = 0;
    HANDLE mm;
    (void)arg;
    CoInitializeEx(NULL, COINIT_MULTITHREADED);
    mm = AvSetMmThreadCharacteristicsW(L"Pro Audio", &task);   /* the system's audio scheduling class */
    juno_enable_hw_ftz();                  /* this thread renders: the plugin's SSE FTZ / DAZ mode */
    if (!run_wasapi()) run_waveout();
    if (mm) AvRevertMmThreadCharacteristics(mm);
    CoUninitialize();
    return 0;
}

/* -------------------------------------------------------------- interaction */
static Ctl *g_drag;
static int g_dy, g_dv, g_dboth;
static double g_dacc;
static char g_tip[128];
static int g_tipx, g_tipy, g_has_tip;

static int visible_list(Panel *p, Ctl **out, int n, int max)
{
    int i;
    if (!panel_open(p)) return n;
    for (i = 0; i < p->n; ++i) {
        if (p->items[i].p) n = visible_list(p->items[i].p, out, n, max);
        else if (n < max) out[n++] = p->items[i].c;
    }
    return n;
}
static int bounds(const Ctl *c, int *b)
{
    int w, h;
    if (c->type == C_SLIDER || c->type == C_KEYBOARD) { b[0] = c->x; b[1] = c->y; b[2] = c->w; b[3] = c->h; return 1; }
    if (c->type == C_PATCHNAME) { frame_size(c->bmp, &w, &h); b[0] = c->bx; b[1] = c->by; b[2] = w; b[3] = h; return w > 0; }
    if (c->bmp && c->bmp->px) { frame_size(c->bmp, &w, &h); b[0] = c->x; b[1] = c->y; b[2] = w; b[3] = h; return 1; }
    if (c->has_size) { b[0] = c->x; b[1] = c->y; b[2] = c->w; b[3] = c->h; return 1; }
    return 0;
}
static Ctl *hit(int x, int y)
{
    Ctl *list[512];
    int n = visible_list(g_tree, list, 0, 512), i, b[4];
    for (i = n - 1; i >= 0; --i) {
        Ctl *c = list[i];
        if (c->type == C_DISPLAY || c->type == C_JU60LED || c->type == C_LFOLED) continue;
        if (c->fn && !strcmp(c->fn, "PlugOut")) continue;
        if (bounds(c, b) && x >= b[0] && x < b[0] + b[2] && y >= b[1] && y < b[1] + b[3]) return c;
    }
    return NULL;
}
static void show_tip(const Ctl *c)
{
    int w = c->w, h;
    if (c->bmp && c->bmp->px && !c->has_size) frame_size(c->bmp, &w, &h);
    label(c, g_tip, sizeof g_tip);
    g_tipx = c->x + w / 2 + c->tipx;
    g_tipy = c->y + c->tipy;
    g_has_tip = 1;
}
/* The key at a point and the velocity there (rva 0x2D4AA0): the point clamped into
 * the control; from the lowest key: a next key that overlaps this one's right edge (a
 * black key) if the point is in it, else this key if the point is left of its right
 * edge, else on to the next key (past a black key that missed it); the velocity
 * 1016 x (y - the key's top) / its height, / 7, in 1..127 (C division) */
static int key_hit(const Ctl *c, int px, int py, int *vel)
{
    int x = px < c->x ? c->x : px > c->x + c->w - 1 ? c->x + c->w - 1 : px;
    int y = py < c->y ? c->y : py > c->y + c->h - 1 ? c->y + c->h - 1 : py;
    int i = 0, v;
    const Key *k = &c->keys[0];
    while (i < c->nkeys - 1) {
        const Key *cur = &c->keys[i], *nx = &c->keys[i + 1];
        int missed = 0;
        k = cur;
        if (nx->x < cur->x + cur->w) {
            if (nx->x <= x && nx->y <= y && x < nx->x + nx->w && y < nx->y + nx->h) { k = nx; break; }
            missed = 1;
        }
        if (x < cur->x + cur->w) break;
        i += missed ? 2 : 1;
        k = &c->keys[i < c->nkeys ? i : c->nkeys - 1];
    }
    v = 1016 * (y - k->y) / k->h / 7;
    *vel = v < 1 ? 1 : v > 127 ? 127 : v;
    return k->n;
}

/* the keyboard's model values: OCTAVE SHIFT moves the notes by 12 (rva 0x2D4C40);
 * vm.ks.onVel / offVel (Script.xml defaults 0 and 64: no control of this panel
 * changes them) */
static int kb_note(int n) { return n + 12 * get("fm.PATCH.NAME1.OCTAVE SHIFT"); }
#define KS_ON_VEL 0
#define KS_OFF_VEL 64
static int g_kb_drag, g_kb_key = -1;     /* the control's drag flag (+48) and its key (+240) */

/* the send (rva 0x2D47E0): a press at onVel when it is set, a release at -offVel,
 * into the note value (the bridge queues it on a change) */
static void kb_send(int key, int v)
{
    int r = v <= 0 ? -KS_OFF_VEL : KS_ON_VEL;
    if (r) v = r;
    EnterCriticalSection(&g_lock);
    E_keybed_write(key, v);
    LeaveCriticalSection(&g_lock);
    g_dirty = 1;
}
/* a press (rva 0x2D4920): a note in the shifted key range other than the held key;
 * with KEY HOLD off, or without Shift, every key above 0 is released first (key
 * order); then the note at the velocity */
static void kb_press(const Ctl *c, int note, int vel, int shift)
{
    int i, st;
    if ((unsigned)note > 127u || note < kb_note(c->keys[0].n) || note >= kb_note(c->keys[c->nkeys - 1].n + 1) || g_kb_key == note)
        return;
    if (!get("fm.PATCH.NAME1.KEY HOLD") || !shift)
        for (i = 0; i < 128; ++i) {
            EnterCriticalSection(&g_lock);
            st = juno_gui_keybed_state(g_eng, i);
            LeaveCriticalSection(&g_lock);
            if (st > 0) kb_send(i, -vel);
        }
    kb_send(note, vel);
    g_kb_key = note;
}
/* the release (rva 0x2D48A0): the held key, unless KEY HOLD is on, at the velocity
 * where the button went up */
static void kb_release(int vel)
{
    if (g_kb_key >= 0 && !get("fm.PATCH.NAME1.KEY HOLD")) kb_send(g_kb_key, -vel);
    g_kb_key = -1;
}

static void option_menu(void);
static void midi_menu(void);
static void action(const char *fn, const char *args);

static int patch_down(int x, int y, int dbl);

static void mouse_down(int x, int y, int shift, int dbl)
{
    Ctl *c;
    Leaf *L;
    if (get("vm.vs.panelPatch") == 1 && patch_down(x, y, dbl)) return;
    if (!(c = hit(x, y))) return;
    L = cleaf(c);
    g_drag = c;
    g_dy = y;
    g_dv = L ? cval(c) : 0;
    g_dacc = 0;
    g_dboth = 0;
    switch (c->type) {
    case C_SLIDER: {
        int w, h;
        double travel, capy;
        frame_size(c->bmp, &w, &h);
        travel = c->h - h;
        capy = c->y + travel * (1.0 - cnorm(c));
        if (L && (y < capy || y > capy + h) && travel > 0) {
            int nv = L->min + (int)floor((1.0 - (y - c->y - h / 2.0) / travel) * (L->max - L->min) + 0.5);
            val_set(L, nv);
            g_dv = cval(c);
        }
        show_tip(c);
        break;
    }
    case C_KNOB:
        if (c->bmp && c->bmp->n <= 4 && c->clickable) {
            NTable *t = nt_get(c->table);
            int n = t ? t->n : (L ? L->max - L->min + 1 : c->bmp->n);
            if (n > c->bmp->n) n = c->bmp->n;
            if (n > 0) val_set(L, value_at(c, (position(c) + 1) % n));
            g_drag = NULL;
        }
        show_tip(c);
        break;
    case C_LATCH:
        press(c);
        if (c->has_on && c->has_off && c->onValue != c->offValue) val_set(L, cval(c) == c->onValue ? c->offValue : c->onValue);
        else if (c->has_on) val_set(L, c->onValue);
        else val_set(L, cval(c) ? 0 : 1);
        break;
    case C_UNLATCH:
        press(c);
        action(c->fn, c->args);
        break;
    case C_MENU:
        press(c);
        g_dirty = 1;
        option_menu();
        break;
    case C_SETUP:
        press(c);
        g_dirty = 1;
        midi_menu();
        break;
    case C_JU60BTN: {
        int both = shift, i;
        for (i = 0; i < g_npressed; ++i)
            if (g_pressed[i] != c && g_pressed[i]->type == C_JU60BTN && g_pressed[i]->role && g_pressed[i]->role != c->role) both = 1;
        press(c);
        chorus_press(c, both);
        break;
    }
    case C_PATCHNAME:
        press(c);
        break;
    case C_KEYBOARD: {                  /* the control's mouse handler (rva 0x2D41F0): down */
        int vel, n = key_hit(c, x, y, &vel);
        g_kb_drag = 1;
        kb_press(c, kb_note(n), vel, shift);
        break;
    }
    default:
        break;
    }
    g_dirty = 1;
}

static void mouse_move(int x, int y, int shift)
{
    Ctl *c = g_drag;
    Leaf *L;
    double fine = shift ? 0.1 : 1.0;
    if (!c) return;
    L = cleaf(c);
    if (c->type == C_SLIDER && L) {
        int w, h;
        frame_size(c->bmp, &w, &h);
        if (c->h - h > 0) g_dacc += (double)(g_dy - y) / (c->h - h) * (L->max - L->min) * fine;
        g_dy = y;
        val_set(L, (int)floor(g_dv + g_dacc + 0.5));
        show_tip(c);
    } else if (c->type == C_KNOB && L) {
        if (c->bmp->n <= 4) {
            int steps = (g_dy - y) / 20;
            if (steps) { val_set(L, value_at(c, position(c) + (steps > 0 ? 1 : -1))); g_dy = y; }
        } else {
            g_dacc += (double)(g_dy - y) / 200.0 * (L->max - L->min) * fine;
            g_dy = y;
            val_set(L, (int)floor(g_dv + g_dacc + 0.5));
        }
        show_tip(c);
    } else if (c->type == C_JU60BTN && c->has_p2 && !g_dboth) {
        int w, h;
        frame_size(c->bmp, &w, &h);
        if (x >= c->x2 && x < c->x2 + w && y >= c->y2 && y < c->y2 + h) { g_dboth = 1; chorus_press(c, 1); }
    } else if (c->type == C_KEYBOARD && g_kb_drag) {      /* a move while it drags */
        int vel, n = key_hit(c, x, y, &vel);
        kb_press(c, kb_note(n), vel, shift);
    }
    g_dirty = 1;
}

/* the button up: on the keyboard (rva 0x2D41F0) the drag ends and the held key is
 * released (at -offVel: the velocity of the up position, which the hit test gives,
 * is replaced, offVel being 1..127) */
static void mouse_up(void)
{
    if (g_drag && g_drag->type == C_KEYBOARD && g_kb_drag) { g_kb_drag = 0; kb_release(1); }
    g_drag = NULL;
    g_npressed = 0;
    g_has_tip = 0;
    g_dirty = 1;
}

static void mouse_wheel(int x, int y, int up)
{
    Ctl *c = hit(x, y);
    Leaf *L;
    if (c && c->type == C_KEYBOARD && c->nwr) {   /* the keyboard's wheel (rva 0x2D4420): OCTAVE SHIFT */
        const Leaf *O = resolve("fm.PATCH.NAME1.OCTAVE SHIFT");       /* + the step, in its range, */
        if (O) val_set(O, get("fm.PATCH.NAME1.OCTAVE SHIFT") + (up ? 1 : -1));   /* then the commit */
        g_dirty = 1;
        return;
    }
    if (!c || !(c->type == C_SLIDER || c->type == C_KNOB) || !(L = cleaf(c))) return;
    if (c->type == C_KNOB && c->bmp && c->bmp->n <= 4) val_set(L, value_at(c, position(c) + (up ? 1 : -1)));
    else val_set(L, cval(c) + (up ? 1 : -1));
    show_tip(c);
    g_dirty = 1;
}

static void mouse_dbl(int x, int y)
{
    Ctl *c = hit(x, y);
    Leaf *L;
    if (!c || !(c->type == C_SLIDER || (c->type == C_KNOB && c->bmp && c->bmp->n > 4)) || !(L = cleaf(c))) return;
    val_set(L, L->def);
}

/* --------------------------------------------------------- the patch window */
static void draw_patchwin(void)
{
    Panel *t = g_patchwin;
    int i;
    char s[96], nm[32];
    fill(0, 0, g_fbw, g_fbh, 0, 0, 0, 140);
    if (t->bmp && t->bmp->px) blit(t->bmp, 0, 0, t->bmp->w, t->bmp->h, t->x, t->y);
    for (i = 0; i < t->n; ++i) {
        Ctl *c = t->items[i].c;
        if (!c) continue;
        if (c->type == C_UNLATCH) {
            if (c->args && (!strcmp(c->args, "sendUser") || !strcmp(c->args, "getUser"))) continue;
            draw_frame(c->bmp, is_pressed(c) ? 1 : 0, c->x, c->y);
        } else if (c->type == C_PATCHBANKNAME) {
            draw_frame(c->bmp, 0, c->bx, c->by);
            if (c->nwr) draw_text(c->wr[0], g_nbanks ? g_banks[g_bank].name : "(no bank)", c->tx, c->ty, c->w - (c->tx - c->x), c->h - (c->ty - c->y));
        } else if (c->type == C_PATCHLIST && g_nbanks) {
            int k;
            double cw = c->w / 4.0, rh = c->h / 16.0;
            for (k = 0; k < 64; ++k) {
                int x = c->x + (int)((k / 16) * cw), y = c->y + (int)((k % 16) * rh);
                Writer *w = k == g_patchsel && c->nwr > 1 ? c->wr[1] : c->wr[0];
                bank_name(&g_banks[g_bank], k, nm);
                snprintf(s, sizeof s, "%02d %s", k + 1, nm);
                if (w) draw_text_wr(w, s, x + 8, y, (int)cw - 12, (int)rh, 1);
            }
        }
    }
}

static int patch_down(int x, int y, int dbl)
{
    Panel *t = g_patchwin;
    int i, w, h;
    for (i = 0; i < t->n; ++i) {
        Ctl *c = t->items[i].c;
        if (!c) continue;
        if (c->type == C_PATCHLIST && x >= c->x && x < c->x + c->w && y >= c->y && y < c->y + c->h) {
            int k = (int)((x - c->x) / (c->w / 4.0)) * 16 + (int)((y - c->y) / (c->h / 16.0));
            if (k >= 0 && k < 64) {
                g_patchsel = k;
                if (dbl) load_patch(k, 0);
            }
            g_dirty = 1;
            return 1;
        }
        if (c->type == C_UNLATCH && c->bmp && c->bmp->px) {
            if (c->args && (!strcmp(c->args, "sendUser") || !strcmp(c->args, "getUser"))) continue;
            frame_size(c->bmp, &w, &h);
            if (x >= c->x && x < c->x + w && y >= c->y && y < c->y + h) {
                press(c);
                action(c->fn, c->args);
                g_dirty = 1;
                return 1;
            }
        }
    }
    if (x < t->x || y < t->y || x >= t->x + t->w || y >= t->y + t->h) {
        set("vm.vs.panelPatch", 0);           /* a click outside closes the window */
        return 1;
    }
    return 1;
}

/* ------------------------------------------------------- functions, menus */
static void bank_import(void)
{
    OPENFILENAMEA o;
    char path[MAX_PATH] = "";
    FILE *f;
    long len;
    unsigned char *b;
    memset(&o, 0, sizeof o);
    o.lStructSize = sizeof o;
    o.hwndOwner = g_wnd;
    o.lpstrFilter = "JUNO-60 bank (*.bin)\0*.bin\0All files\0*.*\0";
    o.lpstrFile = path;
    o.nMaxFile = MAX_PATH;
    o.Flags = OFN_FILEMUSTEXIST | OFN_PATHMUSTEXIST;
    if (!GetOpenFileNameA(&o) || !(f = fopen(path, "rb"))) return;
    fseek(f, 0, SEEK_END);
    len = ftell(f);
    fseek(f, 0, SEEK_SET);
    b = xmalloc((size_t)len);
    if (fread(b, 1, (size_t)len, f) == (size_t)len) {
        char *nm = strrchr(path, '\\'), *dot;
        nm = nm ? nm + 1 : path;
        if ((dot = strrchr(nm, '.'))) *dot = 0;
        if (bank_add(nm, b, (int)len) >= 0) { g_bank = g_nbanks - 1; status_set("bank loaded"); }
        else { status_set("not a JUNO-60 bank file"); free(b); }
    } else free(b);
    fclose(f);
    g_dirty = 1;
}
static void bank_export(void)
{
    OPENFILENAMEA o;
    char path[MAX_PATH];
    FILE *f;
    if (!g_nbanks) return;
    snprintf(path, sizeof path, "%s.bin", g_banks[g_bank].name);
    memset(&o, 0, sizeof o);
    o.lStructSize = sizeof o;
    o.hwndOwner = g_wnd;
    o.lpstrFilter = "JUNO-60 bank (*.bin)\0*.bin\0";
    o.lpstrFile = path;
    o.nMaxFile = MAX_PATH;
    o.lpstrDefExt = "bin";
    o.Flags = OFN_OVERWRITEPROMPT;
    if (!GetSaveFileNameA(&o) || !(f = fopen(path, "wb"))) return;
    fwrite(g_banks[g_bank].bytes, 1, (size_t)g_banks[g_bank].len, f);
    fclose(f);
    status_set("bank saved");
}

static void action(const char *fn, const char *args)
{
    if (!fn) return;
    if (!strcmp(fn, "ManagePatch") && args && (!strcmp(args, "inc") || !strcmp(args, "dec")))
        load_patch((g_patch + (!strcmp(args, "inc") ? 1 : 63)) % 64, 1);
    else if (!strcmp(fn, "ManagePatch") && args && !strcmp(args, "load"))
        load_patch(g_patchsel, 1);
    else if (!strcmp(fn, "ManagePatchBank") && args && (!strcmp(args, "inc") || !strcmp(args, "dec"))) {
        if (g_nbanks) g_bank = (g_bank + (!strcmp(args, "inc") ? 1 : g_nbanks - 1)) % g_nbanks;
        g_dirty = 1;
    } else if (!strcmp(fn, "ManagePatchBank") && args && !strcmp(args, "import")) bank_import();
    else if (!strcmp(fn, "ManagePatchBank") && args && !strcmp(args, "export")) bank_export();
    else if (!strcmp(fn, "Help"))
        MessageBoxA(g_wnd, "Knobs and sliders: drag up or down (Shift: fine), wheel: one step, double-click: default.\n"
                    "Levers: click. Keys: lower on a key = louder.\nCHORUS I + II: hold Shift and click I or II, "
                    "or press I and slide onto II.\nPATCH: the patch window. OPTION: voices, engine rate, zoom. "
                    "SETTING: MIDI input.", "JUNO-60", MB_OK);
    else if (!strcmp(fn, "About"))
        MessageBoxA(g_wnd, "JUNO-60\n\nThe C99 port of the Roland Cloud JUNO-60 plugin (bit-exact in every test of "
                    "its repository), under the plugin's own panel: its Script.xml and sprite sheets.\n\nFor the "
                    "owner's personal use.", "About", MB_OK);
    else {
        char s[128];
        snprintf(s, sizeof s, "%s %s: not part of this port", fn, args ? args : "");
        status_set(s);
    }
}

static void option_menu(void)
{
    HMENU m = CreatePopupMenu();
    POINT pt;
    int cmd, i, mode = get("vm.vs.mode"), vc = get("vm.vs.voiceCount"), sr = get("vm.vs.sampleRate"), z = get("vm.vs.mainZoom");
    static const int Z[] = {50, 62, 75, 100, 125, 150, 200};
    static const char *RATE[] = {"96 kHz", "88.2 kHz", "48 kHz", "44.1 kHz"};
    static const int LAT[] = {0, 5, 8, 11, 16, 21, 32, 43};
    char s[64];
    AppendMenuA(m, MF_STRING | (mode == 0 ? MF_CHECKED : 0), 100, "Panel: Original");
    AppendMenuA(m, MF_STRING | (mode == 1 ? MF_CHECKED : 0), 101, "Panel: SYSTEM-8 layout");
    AppendMenuA(m, MF_SEPARATOR, 0, NULL);
    for (i = 2; i <= 8; ++i) { snprintf(s, sizeof s, "Voices: %d", i); AppendMenuA(m, MF_STRING | (vc == i ? MF_CHECKED : 0), 200 + i, s); }
    AppendMenuA(m, MF_SEPARATOR, 0, NULL);
    /* the engine-rate setting indexes the plugin's table (rva 0x94AB80) */
    for (i = 0; i < 4; ++i) { snprintf(s, sizeof s, "Engine rate: %s", RATE[i]); AppendMenuA(m, MF_STRING | (sr == i ? MF_CHECKED : 0), 300 + i, s); }
    AppendMenuA(m, MF_SEPARATOR, 0, NULL);
    for (i = 0; i < 7; ++i) { snprintf(s, sizeof s, "Zoom: %d%%", Z[i]); AppendMenuA(m, MF_STRING | (z == Z[i] ? MF_CHECKED : 0), 400 + Z[i], s); }
    AppendMenuA(m, MF_SEPARATOR, 0, NULL);
    /* the audio output's queue (this program's, not the plugin's): lower plays
     * faster, higher is safer against drop-outs on a busy computer */
    for (i = 0; i < 8; ++i) {
        if (LAT[i]) snprintf(s, sizeof s, "Audio latency: %d ms", LAT[i]);
        else snprintf(s, sizeof s, "Audio latency: the lowest the device allows");
        AppendMenuA(m, MF_STRING | (g_lat_ms == LAT[i] ? MF_CHECKED : 0), 700 + LAT[i], s);
    }
    {
        char d[192];
        audio_desc_get(d, sizeof d);
        AppendMenuA(m, MF_STRING | MF_GRAYED, 0, d);
    }
    GetCursorPos(&pt);
    cmd = TrackPopupMenu(m, TPM_RETURNCMD | TPM_NONOTIFY, pt.x, pt.y, 0, g_wnd, NULL);
    DestroyMenu(m);
    if (cmd == 100 || cmd == 101) set("vm.vs.mode", cmd - 100);
    else if (cmd >= 202 && cmd <= 208) set("vm.vs.voiceCount", cmd - 200);
    else if (cmd >= 300 && cmd <= 303) set("vm.vs.sampleRate", cmd - 300);
    else if (cmd >= 700) { InterlockedExchange(&g_lat_ms, cmd - 700); InterlockedExchange(&g_reopen, 1); ini_put("audio", "latency_ms", cmd - 700); }
    else if (cmd >= 400) { set("vm.vs.mainZoom", cmd - 400); ini_put("window", "zoom", cmd - 400); }
    mouse_up();
}

static void midi_menu(void)
{
    HMENU m = CreatePopupMenu();
    POINT pt;
    int cmd, i, n = (int)midiInGetNumDevs();
    for (i = 0; i < n; ++i) {
        MIDIINCAPSA caps;
        if (midiInGetDevCapsA((UINT_PTR)i, &caps, sizeof caps) == MMSYSERR_NOERROR)
            AppendMenuA(m, MF_STRING | (i == g_mididev ? MF_CHECKED : 0), 500 + i, caps.szPname);
    }
    if (!n) AppendMenuA(m, MF_STRING | MF_GRAYED, 0, "no MIDI input");
    AppendMenuA(m, MF_SEPARATOR, 0, NULL);
    AppendMenuA(m, MF_STRING, 499, "MIDI input off");
    GetCursorPos(&pt);
    cmd = TrackPopupMenu(m, TPM_RETURNCMD | TPM_NONOTIFY, pt.x, pt.y, 0, g_wnd, NULL);
    DestroyMenu(m);
    if (cmd >= 500) {
        MIDIINCAPSA caps;
        midi_open(cmd - 500);
        if (midiInGetDevCapsA((UINT_PTR)(cmd - 500), &caps, sizeof caps) == MMSYSERR_NOERROR) ini_puts("midi", "input", caps.szPname);
    } else if (cmd == 499) { midi_open(-1); status_set("MIDI input off"); ini_puts("midi", "input", "off"); }
    mouse_up();
}

/* ---------------------------------------------------------------- the window */
static int g_zoom = 75;
static void render(void)
{
    memset(g_fb, 0, (size_t)g_fbw * g_fbh * 4);
    draw_panel(g_tree);
    if (get("vm.vs.panelPatch") == 1) draw_patchwin();
    if (g_has_tip) {
        SIZE sz;
        int w, h = 26, x, y;
        static Writer tipw;
        if (!tipw.font) {
            snprintf(tipw.face, sizeof tipw.face, "Arial");
            tipw.size = 18;
            tipw.color = RGB(0xf0, 0xf0, 0xf0);
            tipw.alignH = 1;
            tipw.alignV = 1;
            tipw.font = CreateFontA(-18, 0, 0, 0, FW_NORMAL, 0, 0, 0, DEFAULT_CHARSET, OUT_DEFAULT_PRECIS,
                                    CLIP_DEFAULT_PRECIS, ANTIALIASED_QUALITY, DEFAULT_PITCH, "Arial");
        }
        GdiFlush();
        SelectObject(g_fbdc, tipw.font);
        GetTextExtentPoint32A(g_fbdc, g_tip, (int)strlen(g_tip), &sz);
        w = sz.cx + 16;
        x = g_tipx - w / 2;
        y = g_tipy - h - 4;
        fill(x, y, w, h, 0, 0, 0, 209);
        draw_text_wr(&tipw, g_tip, x, y, w, h, 1);
    }
    GdiFlush();
}

static void zoom_apply(void)
{
    RECT r;
    DWORD st;
    int z = get("vm.vs.mainZoom");
    if (z < 25) z = 25;
    if (z > 200) z = 200;
    g_zoom = z;
    if (!g_wnd) return;
    r.left = 0; r.top = 0; r.right = g_fbw * z / 100; r.bottom = g_fbh * z / 100;
    st = (DWORD)GetWindowLongA(g_wnd, GWL_STYLE);
    AdjustWindowRect(&r, st, FALSE);
    SetWindowPos(g_wnd, NULL, 0, 0, r.right - r.left, r.bottom - r.top, SWP_NOMOVE | SWP_NOZORDER);
    InvalidateRect(g_wnd, NULL, FALSE);
}

static LRESULT CALLBACK wndproc(HWND h, UINT m, WPARAM wp, LPARAM lp)
{
    switch (m) {
    case WM_PAINT: {
        PAINTSTRUCT ps;
        HDC dc = BeginPaint(h, &ps);
        RECT r;
        GetClientRect(h, &r);
        if (g_dirty) { g_dirty = 0; render(); }
        SetStretchBltMode(dc, HALFTONE);
        SetBrushOrgEx(dc, 0, 0, NULL);
        StretchBlt(dc, 0, 0, r.right, r.bottom, g_fbdc, 0, 0, g_fbw, g_fbh, SRCCOPY);
        EndPaint(h, &ps);
        return 0;
    }
    case WM_ERASEBKGND:
        return 1;
    case WM_LBUTTONDOWN:
    case WM_LBUTTONDBLCLK:
        SetCapture(h);
        mouse_down(GET_X_LPARAM(lp) * 100 / g_zoom, GET_Y_LPARAM(lp) * 100 / g_zoom, (wp & MK_SHIFT) != 0, m == WM_LBUTTONDBLCLK);
        if (m == WM_LBUTTONDBLCLK) mouse_dbl(GET_X_LPARAM(lp) * 100 / g_zoom, GET_Y_LPARAM(lp) * 100 / g_zoom);
        InvalidateRect(h, NULL, FALSE);
        return 0;
    case WM_MOUSEMOVE:
        if (g_drag) { mouse_move(GET_X_LPARAM(lp) * 100 / g_zoom, GET_Y_LPARAM(lp) * 100 / g_zoom, (wp & MK_SHIFT) != 0); InvalidateRect(h, NULL, FALSE); }
        return 0;
    case WM_LBUTTONUP:
        ReleaseCapture();
        mouse_up();
        InvalidateRect(h, NULL, FALSE);
        return 0;
    case WM_MOUSEWHEEL: {
        POINT p;
        p.x = GET_X_LPARAM(lp);
        p.y = GET_Y_LPARAM(lp);
        ScreenToClient(h, &p);
        mouse_wheel(p.x * 100 / g_zoom, p.y * 100 / g_zoom, GET_WHEEL_DELTA_WPARAM(wp) > 0);
        InvalidateRect(h, NULL, FALSE);
        return 0;
    }
    case WM_TIMER: {
        int changed;
        static LONG shown, shown_state;
        /* the audio loop's counters, readable by a test driver (GetPropA) */
        SetPropA(h, "juno.blocks", (HANDLE)(INT_PTR)g_blocks);
        SetPropA(h, "juno.dropouts", (HANDLE)(INT_PTR)g_dropouts);
        SetPropA(h, "juno.audio", (HANDLE)(INT_PTR)(g_audio_state + 1));
        {
            static char shown_desc[192];
            char d[192];
            audio_desc_get(d, sizeof d);
            if (strcmp(d, shown_desc)) {
                ATOM old = (ATOM)(UINT_PTR)GetPropA(h, "juno.desc");
                snprintf(shown_desc, sizeof shown_desc, "%s", d);
                if (old) GlobalDeleteAtom(old);
                SetPropA(h, "juno.desc", (HANDLE)(UINT_PTR)GlobalAddAtomA(shown_desc));
            }
        }
        if (g_dropouts != shown || g_audio_state != shown_state) {
            char t[400];
            shown = g_dropouts;
            shown_state = g_audio_state;
            if (shown_state < 0) snprintf(t, sizeof t, "JUNO-60  --  %s  --  NO AUDIO OUTPUT DEVICE", g_status);
            else snprintf(t, sizeof t, "JUNO-60  --  %s  --  audio drop-outs: %ld (OPTION: a higher audio latency)", g_status, (long)shown);
            if (shown || shown_state < 0) SetWindowTextA(h, t);
            else status_set(g_status);            /* the device is back: the plain title */
        }
        /* the plugin's UI timer: the drain (rva 0x320120), then what changed -- the
         * model's values and the keyboard's note value (the drained notes) */
        EnterCriticalSection(&g_lock);
        E_ui_tick();
        changed = eng_refresh();
        {
            static int ks[128];
            int k, v;
            for (k = 0; k < 128; ++k) { v = juno_gui_keybed_state(g_eng, k) > 0; changed |= v != ks[k]; ks[k] = v; }
        }
        LeaveCriticalSection(&g_lock);
        if (changed) g_dirty = 1;
        if (InterlockedExchange(&g_landed, 0)) {   /* the audio thread landed a patch load */
            char nm[32], s[128];
            LONG r = g_landed_req;
            if (!g_landed_ok && g_patchid) local_put(g_patchid->id, (int)(r % 64));
            patch_name(nm);
            snprintf(s, sizeof s, "%s: %d %s", r / 64 < g_nbanks ? g_banks[r / 64].name : "", (int)(r % 64) + 1, nm);
            status_set(s);
            g_dirty = 1;
        }
        if (g_dirty) InvalidateRect(h, NULL, FALSE);
        return 0;
    }
    case WM_DESTROY:
        RemovePropA(h, "juno.blocks");
        RemovePropA(h, "juno.dropouts");
        RemovePropA(h, "juno.audio");
        {
            ATOM old = (ATOM)(UINT_PTR)GetPropA(h, "juno.desc");
            if (old) GlobalDeleteAtom(old);
            RemovePropA(h, "juno.desc");
        }
        PostQuitMessage(0);
        return 0;
    }
    return DefWindowProcA(h, m, wp, lp);
}

/* ------------------------------------------------------------ the test modes */
static void dump_controls(Panel *p, FILE *f)
{
    int i, k;
    for (i = 0; i < p->n; ++i) {
        if (p->items[i].p) { dump_controls(p->items[i].p, f); continue; }
        for (k = 0; k < p->items[i].c->nrefs; ++k) {
            Leaf *L = resolve(p->items[i].c->refs[k]);
            if (L) fprintf(f, "%s\t%s\t%u\n", p->items[i].c->typestr, p->items[i].c->refs[k], (unsigned)L->id);
            else fprintf(f, "%s\t%s\t-\n", p->items[i].c->typestr, p->items[i].c->refs[k]);
        }
    }
}
static int save_bmp(const char *path)
{
    FILE *f = fopen(path, "wb");
    BITMAPFILEHEADER fh;
    BITMAPINFOHEADER ih;
    int y, rowb = (g_fbw * 3 + 3) & ~3;
    unsigned char *row = xmalloc((size_t)rowb);
    if (!f) return 0;
    memset(&fh, 0, sizeof fh);
    memset(&ih, 0, sizeof ih);
    fh.bfType = 0x4D42;
    fh.bfOffBits = sizeof fh + sizeof ih;
    fh.bfSize = fh.bfOffBits + (DWORD)rowb * g_fbh;
    ih.biSize = sizeof ih;
    ih.biWidth = g_fbw;
    ih.biHeight = g_fbh;
    ih.biPlanes = 1;
    ih.biBitCount = 24;
    fwrite(&fh, sizeof fh, 1, f);
    fwrite(&ih, sizeof ih, 1, f);
    for (y = g_fbh - 1; y >= 0; --y) {
        int x;
        for (x = 0; x < g_fbw; ++x) {
            uint32_t p = g_fb[(size_t)y * g_fbw + x];
            row[3 * x] = p & 0xff;
            row[3 * x + 1] = (p >> 8) & 0xff;
            row[3 * x + 2] = (p >> 16) & 0xff;
        }
        fwrite(row, 1, (size_t)rowb, f);
    }
    fclose(f);
    free(row);
    return 1;
}

/* the --render script: MIDI as a driver delivers it ('m'), a panel edit as a
 * slider drag makes it ('s'), a key click as the mouse makes it ('k' key index,
 * 'K' its release), the next patch through the patch browser ('p') */
typedef struct { int block; char kind; uint32_t midi; int v; const char *ref; } Step;
#define S(step) ((step) * 256 / BLK)        /* the script's steps are 256 samples */
static const Step SCRIPT[] = {
    {S(2), 'm', 0x643C90, 0, NULL},                         /* note on 60, velocity 100 */
    {S(4), 'm', 0x504090, 0, NULL}, {S(4), 'm', 0x7F4390, 0, NULL},
    {S(30), 'm', 0x6401B0, 0, NULL},                        /* CC 1 (modulation) 100 */
    {S(40), 's', 0, 200, "fm.PATCH.FLT.VCF CUTOFF FREQ"},
    {S(50), 'm', 0x5D60E0, 0, NULL},                        /* pitch bend 12000 */
    {S(60), 'm', 0x0040D0, 0, NULL},                        /* channel aftertouch 64 */
    {S(80), 'm', 0x403C80, 0, NULL}, {S(80), 'm', 0x404080, 0, NULL}, {S(80), 'm', 0x404380, 0, NULL},
    {S(84), 'm', 0x4000E0, 0, NULL}, {S(84), 'm', 0x0001B0, 0, NULL},
    {S(90), 'k', 0, 24, NULL}, {S(120), 'K', 0, 0, NULL},
    {S(130), 's', 0, 1, "fm.PATCH.NAME1.ARPEGGIO SW"},      /* the arp at the host tempo */
    {S(132), 'm', 0x643090, 0, NULL}, {S(132), 'm', 0x643790, 0, NULL},
    {S(240), 'm', 0x403080, 0, NULL}, {S(240), 'm', 0x403780, 0, NULL},
    {S(250), 's', 0, 0, "fm.PATCH.NAME1.ARPEGGIO SW"},
    {S(270), 'p', 0, 0, NULL}, {S(274), 'm', 0x5A3C90, 0, NULL}, {S(300), 'm', 0x403C80, 0, NULL},
};
#define RENDER_BLOCKS S(340)

static Ctl *find_type(Panel *p, int type)
{
    int i;
    for (i = 0; i < p->n; ++i) {
        Ctl *c = p->items[i].p ? find_type(p->items[i].p, type) : p->items[i].c;
        if (c && c->type == type) return c;
    }
    return NULL;
}

static int render_test(const char *path)
{
    FILE *f = fopen(path, "wb");
    float L[BLK], R[BLK], o[2 * BLK];
    int b, i, held = -1;
    Ctl *kb = find_type(g_tree, C_KEYBOARD);
    LARGE_INTEGER t0, t1, fq, b0, b1;
    double worst = 0;
    int worst_b = -1;
    if (!f) return 2;
    QueryPerformanceFrequency(&fq);
    QueryPerformanceCounter(&t0);
    for (b = 0; b < RENDER_BLOCKS; ++b) {
        for (i = 0; i < (int)(sizeof SCRIPT / sizeof SCRIPT[0]); ++i) {
            const Step *st = &SCRIPT[i];
            if (st->block != b) continue;
            if (st->kind == 'm') push_midi(st->midi);
            else if (st->kind == 's') set(st->ref, st->v);
            else if (st->kind == 'k' && kb && st->v < kb->nkeys) {      /* the keyboard control's press */
                int vel, n = key_hit(kb, kb->keys[st->v].x + kb->keys[st->v].w / 2, kb->keys[st->v].y + kb->keys[st->v].h / 2, &vel);
                g_kb_drag = 1;
                kb_press(kb, kb_note(n), vel, 0);
                held = n;
            } else if (st->kind == 'K' && held >= 0) { g_kb_drag = 0; kb_release(1); held = -1; }
            else if (st->kind == 'p') load_patch((g_patch + 1) % 64, 1);
        }
        if (b % 10 == 9) {                 /* the 50 ms UI timer (WM_TIMER) */
            EnterCriticalSection(&g_lock);
            E_ui_tick();
            eng_refresh();
            LeaveCriticalSection(&g_lock);
        }
        QueryPerformanceCounter(&b0);
        render_block(L, R);
        QueryPerformanceCounter(&b1);
        if ((double)(b1.QuadPart - b0.QuadPart) > worst) { worst = (double)(b1.QuadPart - b0.QuadPart); worst_b = b; }
        for (i = 0; i < BLK; ++i) { o[2 * i] = L[i]; o[2 * i + 1] = R[i]; }
        fwrite(o, sizeof o, 1, f);
    }
    QueryPerformanceCounter(&t1);
    if (g_log) fprintf(g_log, "# rendered %d ms of audio in %.1f ms; worst block %.2f ms (block %d), block period %.2f ms\n",
                       RENDER_BLOCKS * BLK * 1000 / g_rate, (double)(t1.QuadPart - t0.QuadPart) * 1000.0 / (double)fq.QuadPart,
                       worst * 1000.0 / (double)fq.QuadPart, worst_b, BLK * 1000.0 / g_rate);
    fclose(f);
    return 0;
}

/* --play: a seeded performance through the program's own input paths -- MIDI
 * through the winmm callback (midi_cb), the keybed through the mouse handlers
 * (mouse_down / mouse_move / mouse_up at panel coordinates) -- rendered by the
 * audio thread's own block (render_block), the 50 ms UI timer every 19 blocks.
 * Raw float L R to FILE, every engine call to FILE.log. */
static uint32_t g_rnd;
static uint32_t rnd(void) { g_rnd ^= g_rnd << 13; g_rnd ^= g_rnd >> 17; g_rnd ^= g_rnd << 5; return g_rnd; }
static void midi_in(uint32_t m, int t) { midi_cb(NULL, MIM_DATA, 0, (DWORD_PTR)m, (DWORD_PTR)t); }

/* a point for the keybed: on the keys mostly, some in the gaps, some past the edges */
static void kb_point(const Ctl *kb, int *x, int *y)
{
    *x = kb->x - 30 + (int)(rnd() % (unsigned)(kb->w + 60));
    *y = kb->y - 10 + (int)(rnd() % (unsigned)(kb->h + 20));
}

static int play_test(const char *path, int change_patch)
{
    enum { PLAY = 900, TAIL = 200 };
    FILE *f = fopen(path, "wb");
    float L[BLK], R[BLK], o[2 * BLK];
    Ctl *kb = find_type(g_tree, C_KEYBOARD);
    int held[16], heldch[16], nheld = 0, b, i, down = 0, down_left = 0, sus = 0, change_at = change_patch ? PLAY / 2 : -1;
    if (!f || !kb || kb->nkeys < 2) return 2;
    for (b = 0; b < PLAY + TAIL; ++b) {
        if (b < PLAY) {
            unsigned r = rnd() % 1000;
            if (r < 40 && nheld < 8) {                                    /* a MIDI key, any channel */
                int n = 36 + (int)(rnd() % 61), v = 1 + (int)(rnd() % 127), ch = rnd() % 4 ? 0 : (int)(rnd() % 16);
                for (i = 0; i < nheld && held[i] != n; ++i) ;
                if (i == nheld) { held[nheld] = n; heldch[nheld++] = ch; midi_in(0x90u | (uint32_t)ch | ((uint32_t)n << 8) | ((uint32_t)v << 16), b); }
            } else if (r < 75 && nheld > 0) {                             /* its release: note-off, or note-on at 0 */
                i = (int)(rnd() % (unsigned)nheld);
                if (rnd() % 5) midi_in(0x80u | (uint32_t)heldch[i] | ((uint32_t)held[i] << 8) | ((rnd() % 128) << 16), b);
                else midi_in(0x90u | (uint32_t)heldch[i] | ((uint32_t)held[i] << 8), b);
                --nheld;
                held[i] = held[nheld];
                heldch[i] = heldch[nheld];
            } else if (r < 85) midi_in(0xB0u | (1u << 8) | ((rnd() % 128) << 16), b);          /* modulation */
            else if (r < 92) { unsigned w = rnd() % 16384; midi_in(0xE0u | ((w & 127) << 8) | ((w >> 7) << 16), b); }
            else if (r < 95) midi_in(0xD0u | ((rnd() % 128) << 8), b);                         /* aftertouch */
            else if (r < 97) { sus = !sus; midi_in(0xB0u | (64u << 8) | ((sus ? 127u : 0u) << 16), b); }
            if (!down && rnd() % 1000 < 30) {                             /* the keybed: a click (Shift at times) */
                int x = kb->x + (int)(rnd() % (unsigned)kb->w), y = kb->y + (int)(rnd() % (unsigned)kb->h);
                mouse_down(x, y, rnd() % 4 == 0, 0);
                down = g_drag == kb;
                down_left = 5 + (int)(rnd() % 100);
            } else if (down && --down_left <= 0) {
                mouse_up();
                down = 0;
            } else if (down && rnd() % 1000 < 40) {                      /* a drag, inside or past the edges */
                int x, y;
                kb_point(kb, &x, &y);
                mouse_move(x, y, rnd() % 4 == 0);
            }
            if (rnd() % 1000 < 5) set("fm.PATCH.NAME1.KEY HOLD", !get("fm.PATCH.NAME1.KEY HOLD"));
            if (rnd() % 1000 < 3) set("fm.PATCH.NAME1.OCTAVE SHIFT", (int)(rnd() % 7) - 3);
            if (b == change_at || rnd() % 1000 < 3) load_patch((int)(rnd() % 64), (int)(rnd() & 1));   /* buttons / list */
        } else if (b == PLAY) {                                          /* everything up */
            for (i = 0; i < nheld; ++i) midi_in(0x80u | (uint32_t)heldch[i] | ((uint32_t)held[i] << 8) | (64u << 16), b);
            nheld = 0;
            if (sus) midi_in(0xB0u | (64u << 8), b);
            midi_in(0xE0u | (64u << 16), b);
            if (down) { mouse_up(); down = 0; }
            if (get("fm.PATCH.NAME1.KEY HOLD")) set("fm.PATCH.NAME1.KEY HOLD", 0);
        }
        if (b % 19 == 18) {                                              /* the 50 ms UI timer */
            EnterCriticalSection(&g_lock);
            E_ui_tick();
            eng_refresh();
            LeaveCriticalSection(&g_lock);
        }
        render_block(L, R);
        for (i = 0; i < BLK; ++i) { o[2 * i] = L[i]; o[2 * i + 1] = R[i]; }
        fwrite(o, sizeof o, 1, f);
    }
    fclose(f);
    return 0;
}

/* --kbscript: one panel event per line through the program's own handlers --
 *   down X Y SHIFT | move X Y SHIFT | up | wheel X Y UP     the mouse, panel pixels
 *   set V REF                                               a panel control's edit
 *   patch IDX COMMIT                                        a patch load (buttons: 1)
 *   note N V | off N                                        MIDI in, channel 1
 *   block                                                   one audio block
 *   tick                                                    the 50 ms UI timer
 * every engine call to FILE.log (the calls a GUI makes, in order). */
static int kb_script(const char *path)
{
    FILE *in = fopen(path, "r");
    char line[256], ref[128];
    float L[BLK], R[BLK];
    int a, b, c;
    if (!in) return 2;
    fprintf(g_log, "# kbscript\n");                  /* the calls before it are the boot's */
    while (fgets(line, sizeof line, in)) {
        if (sscanf(line, "down %d %d %d", &a, &b, &c) == 3) mouse_down(a, b, c, 0);
        else if (sscanf(line, "move %d %d %d", &a, &b, &c) == 3) mouse_move(a, b, c);
        else if (!strncmp(line, "up", 2)) mouse_up();
        else if (sscanf(line, "wheel %d %d %d", &a, &b, &c) == 3) mouse_wheel(a, b, c);
        else if (sscanf(line, "set %d %127[^\r\n]", &a, ref) == 2) set(ref, a);
        else if (sscanf(line, "patch %d %d", &a, &b) == 2) load_patch(a, b);
        else if (sscanf(line, "note %d %d", &a, &b) == 2) midi_in(0x90u | ((uint32_t)a << 8) | ((uint32_t)b << 16), 0);
        else if (sscanf(line, "off %d", &a) == 1) midi_in(0x80u | ((uint32_t)a << 8) | (64u << 16), 0);
        else if (!strncmp(line, "block", 5)) render_block(L, R);
        else if (!strncmp(line, "tick", 4)) {
            EnterCriticalSection(&g_lock);
            E_ui_tick();
            eng_refresh();
            LeaveCriticalSection(&g_lock);
        }
    }
    fclose(in);
    return 0;
}

/* ------------------------------------------------------------------- main */
int WINAPI WinMain(HINSTANCE inst, HINSTANCE prev, LPSTR cmdline, int show)
{
    ULONG_PTR gtok;
    GpStartupIn gin = {1, NULL, FALSE, FALSE};
    DWORD len;
    const unsigned char *x;
    char *xs, *dump = NULL, *shot = NULL, *rend = NULL;
    int argc, i, shot_patch = 0, bank0 = 0, lat_arg = -1, seed = -1, fp_oracle = 0;
    char *play = NULL, *kbs = NULL;
    LPWSTR *argvw = CommandLineToArgvW(GetCommandLineW(), &argc);
    BITMAPINFO bi;
    void *bits;
    (void)prev; (void)cmdline;
    for (i = 1; argvw && i < argc; ++i) {
        char a[MAX_PATH];
        WideCharToMultiByte(CP_ACP, 0, argvw[i], -1, a, sizeof a, NULL, NULL);
        if (!strcmp(a, "--dump-controls") && i + 1 < argc) { char b[MAX_PATH]; WideCharToMultiByte(CP_ACP, 0, argvw[++i], -1, b, sizeof b, NULL, NULL); dump = xstrdup(b); }
        else if (!strcmp(a, "--shot") && i + 1 < argc) { char b[MAX_PATH]; WideCharToMultiByte(CP_ACP, 0, argvw[++i], -1, b, sizeof b, NULL, NULL); shot = xstrdup(b); }
        else if (!strcmp(a, "--patch") && i + 1 < argc) { char b[32]; WideCharToMultiByte(CP_ACP, 0, argvw[++i], -1, b, sizeof b, NULL, NULL); shot_patch = atoi(b); }
        else if (!strcmp(a, "--bank") && i + 1 < argc) { char b[32]; WideCharToMultiByte(CP_ACP, 0, argvw[++i], -1, b, sizeof b, NULL, NULL); bank0 = atoi(b); }
        else if (!strcmp(a, "--play") && i + 1 < argc) { char b[MAX_PATH]; WideCharToMultiByte(CP_ACP, 0, argvw[++i], -1, b, sizeof b, NULL, NULL); play = xstrdup(b); }
        else if (!strcmp(a, "--seed") && i + 1 < argc) { char b[32]; WideCharToMultiByte(CP_ACP, 0, argvw[++i], -1, b, sizeof b, NULL, NULL); seed = atoi(b); }
        else if (!strcmp(a, "--fp-oracle")) fp_oracle = 1;
        else if (!strcmp(a, "--latency") && i + 1 < argc) { char b[32]; WideCharToMultiByte(CP_ACP, 0, argvw[++i], -1, b, sizeof b, NULL, NULL); lat_arg = atoi(b); }
        else if (!strcmp(a, "--render") && i + 1 < argc) { char b[MAX_PATH]; WideCharToMultiByte(CP_ACP, 0, argvw[++i], -1, b, sizeof b, NULL, NULL); rend = xstrdup(b); }
        else if (!strcmp(a, "--kbscript") && i + 1 < argc) { char b[MAX_PATH]; WideCharToMultiByte(CP_ACP, 0, argvw[++i], -1, b, sizeof b, NULL, NULL); kbs = rend = xstrdup(b); }
    }
    if (play) {
        rend = play;                                   /* the render test's plumbing: the log, no device */
        g_rnd = 2463534242u ^ (uint32_t)(seed < 0 ? 1 : seed) * 2654435761u;
        if (!g_rnd) g_rnd = 1;
    }
    if (rend) {
        char lp[MAX_PATH + 8];
        snprintf(lp, sizeof lp, "%s.log", rend);
        if (!(g_log = fopen(lp, "w"))) return 2;
    }
    if (!dump && !shot && !rend) SetProcessDPIAware();
    InitializeCriticalSection(&g_lock);
    InitializeCriticalSection(&g_qlock);
    InitializeCriticalSection(&g_desc_lock);
    GdiplusStartup(&gtok, &gin, NULL);
    x = resource(ASSET_SCRIPT_XML, &len);
    if (!x) { MessageBoxA(NULL, "Script.xml missing from the program", "JUNO-60", MB_OK); return 1; }
    xs = xstrndup((const char *)x, len);
    g_doc = xml_parse(xs, len);
    g_script = xchild(g_doc, "script");
    if (!g_script) { MessageBoxA(NULL, "Script.xml: no <script>", "JUNO-60", MB_OK); return 1; }
    {
        int i2;
        for (i2 = 0; i2 < g_script->n; ++i2) {
            XN *e = g_script->k[i2];
            int a[4] = {0, 0, 0, 0};
            if (strcmp(e->tag, "struct")) continue;
            hexaddr(xtext(e, "address"), a);
            walk(xtext(e, "type"), a, xtext(e, "name"));
        }
    }
    load_script_tables();
    {
        XN *mp = paneltype("main");
        int v[2];
        if (mp && ints(xtext(mp, "size"), v, 2) == 2) { g_fbw = v[0]; g_fbh = v[1]; }
    }
    g_tree = build("main", 0, 0);
    g_patchid = resolve("vm.vs.patchId");
    {
        XN *pp = paneltype("patch");
        int v[2] = {1690, 696};
        if (pp) ints(xtext(pp, "size"), v, 2);
        g_patchwin = build("patch", (g_fbw - v[0]) / 2, (g_fbh - v[1]) / 2);
    }
    if (dump) {
        FILE *f = fopen(dump, "w");
        Panel *orig = NULL;
        for (i = 0; i < g_tree->n; ++i) if (g_tree->items[i].p && !strcmp(g_tree->items[i].p->type, "orig")) orig = g_tree->items[i].p;
        if (!f || !orig) return 2;
        dump_controls(orig, f);
        fclose(f);
        return 0;
    }
    /* the framebuffer: a top-down 32-bit DIB that GDI can also draw text into */
    memset(&bi, 0, sizeof bi);
    bi.bmiHeader.biSize = sizeof bi.bmiHeader;
    bi.bmiHeader.biWidth = g_fbw;
    bi.bmiHeader.biHeight = -g_fbh;
    bi.bmiHeader.biPlanes = 1;
    bi.bmiHeader.biBitCount = 32;
    bi.bmiHeader.biCompression = BI_RGB;
    g_fbdc = CreateCompatibleDC(NULL);
    g_fbbm = CreateDIBSection(g_fbdc, &bi, DIB_RGB_COLORS, &bits, NULL, 0);
    g_fb = (uint32_t *)bits;
    SelectObject(g_fbdc, g_fbbm);
    /* the engine, as a host boots the plugin: initialize (six voices, the 95
     * defaults, the start-up mute) at the output rate */
    /* the device's own rate when the plugin's converter table has it */
    CoInitializeEx(NULL, COINIT_APARTMENTTHREADED);
    if (!dump && !shot && !rend) {
        int r = device_rate();
        if (rate_in_table(r)) g_rate = r;
    }
    g_eng = juno_gui_create((float)g_rate, 0);
    if (fp_oracle) juno_set_fp_oracle_mode(1);         /* after create, which sets the production FTZ */
    if (g_log) fprintf(g_log, "create %d 0\nplugin_init\n", g_rate);
    if (!g_eng || !juno_gui_plugin_init(g_eng)) { MessageBoxA(NULL, "engine start failed", "JUNO-60", MB_OK); return 1; }
    banks_load();
    if (bank0 >= 0 && bank0 < g_nbanks) g_bank = bank0;
    if (play) {                                        /* the seed picks the bank and the patch */
        g_bank = (int)(rnd() % (unsigned)g_nbanks);
        shot_patch = (int)(rnd() % 64);
    }
    EnterCriticalSection(&g_lock);
    eng_refresh();
    LeaveCriticalSection(&g_lock);
    g_tempo = 40.0 + get("fm.SYNTH.COM.TEMPO") / 10.0;
    if (g_nbanks) load_patch((shot || rend) ? shot_patch : 0, 0);
    if (shot) {
        render();
        return save_bmp(shot) ? 0 : 2;
    }
    {
        HDC sdc = GetDC(NULL);
        int dpi = GetDeviceCaps(sdc, LOGPIXELSX), z;
        ReleaseDC(NULL, sdc);
        z = 75 * dpi / 96;
        if (!rend) {                                  /* the window: the user's own settings */
            static const int LAT[] = {0, 5, 8, 11, 16, 21, 32, 43};
            int k, l, zs;
            ini_init();
            zs = ini_get("window", "zoom", 0);
            if (zs >= 25 && zs <= 200) z = zs;
            l = lat_arg >= 0 ? lat_arg : ini_get("audio", "latency_ms", 21);
            for (k = 0; k < 8 && LAT[k] != l; ++k) ;
            g_lat_ms = k < 8 ? l : 21;
        }
        set("vm.vs.mainZoom", z < 25 ? 25 : z > 200 ? 200 : z);
    }
    if (rend) {
        int r;
        if (play) r = play_test(play, (int)(rnd() & 1));
        else if (kbs) r = kb_script(kbs);
        else {
            if (!fp_oracle) juno_enable_hw_ftz();      /* as the audio thread */
            r = render_test(rend);
        }
        fclose(g_log);
        return r;
    }
    {
        WNDCLASSA wc;
        RECT r;
        DWORD st = WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX;
        MSG msg;
        memset(&wc, 0, sizeof wc);
        wc.style = CS_DBLCLKS;
        wc.lpfnWndProc = wndproc;
        wc.hInstance = inst;
        wc.hCursor = LoadCursor(NULL, IDC_ARROW);
        wc.hIcon = LoadIconA(inst, MAKEINTRESOURCEA(1));
        wc.lpszClassName = "JUNO60";
        RegisterClassA(&wc);
        g_zoom = get("vm.vs.mainZoom");
        r.left = 0; r.top = 0; r.right = g_fbw * g_zoom / 100; r.bottom = g_fbh * g_zoom / 100;
        AdjustWindowRect(&r, st, FALSE);
        g_wnd = CreateWindowA("JUNO60", "JUNO-60", st, CW_USEDEFAULT, CW_USEDEFAULT, r.right - r.left, r.bottom - r.top,
                              NULL, NULL, inst, NULL);
        status_set(g_status);
        {
            char nm[32], s[96];
            patch_name(nm);
            snprintf(s, sizeof s, "%s: 1 %s", g_nbanks ? g_banks[0].name : "", nm);
            status_set(s);
        }
        ShowWindow(g_wnd, show);
        SetTimer(g_wnd, 1, 50, NULL);
        {
            char want[64];
            int k, n = (int)midiInGetNumDevs(), pick = n > 0 ? 0 : -1;
            ini_gets("midi", "input", want, sizeof want);
            if (!strcmp(want, "off")) pick = -1;
            else for (k = 0; want[0] && k < n; ++k) {
                MIDIINCAPSA caps;
                if (midiInGetDevCapsA((UINT_PTR)k, &caps, sizeof caps) == MMSYSERR_NOERROR && !strcmp(caps.szPname, want)) pick = k;
            }
            if (pick >= 0) midi_open(pick);
        }
        g_audio_thread = CreateThread(NULL, 0, audio_main, NULL, 0, NULL);
        if (g_audio_thread) SetThreadPriority(g_audio_thread, THREAD_PRIORITY_TIME_CRITICAL);
        while (GetMessageA(&msg, NULL, 0, 0) > 0) { TranslateMessage(&msg); DispatchMessageA(&msg); }
        InterlockedExchange(&g_run, 0);
        if (g_audio_thread) WaitForSingleObject(g_audio_thread, 2000);
        midi_open(-1);
    }
    return 0;
}

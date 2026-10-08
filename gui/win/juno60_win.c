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
 * own process() (juno_gui_process_ex) on the audio thread, in the plugin's SSE
 * FTZ / DAZ mode; keys arrive as host note events, CC / pitch bend / aftertouch
 * as its MIDI-mapping parameters; a GUI edit is the model set (rva 0x283DB0), a
 * patch load the patch browser's queued load (rva 0x335850).
 *
 * Test modes (no window): --dump-controls FILE (every control's resolved id, for
 * the comparison with the web version), --shot FILE.bmp [--patch N] (the panel),
 * --render FILE [--bank B] [--patch N] (the audio thread's own path on a fixed
 * key / controller / panel script: raw float L R to FILE, every engine call to
 * FILE.log -- tools/dist/native_check.py replays the log through the proven
 * libjuno.so and the two outputs must be equal bit for bit).
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
#include <objidl.h>
#include <stdio.h>
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
int juno_gui_process_ex(void *c, const juno_host_note *ev, int nev, const juno_host_param *par, int npar,
                        int tempo_valid, double tempo, float *outL, float *outR, int n);
uint32_t juno_midi_base(void);
void juno_enable_hw_ftz(void);

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

static void keyboard_init(Ctl *c)
{
    int kr[2] = {36, 96}, i, white = 0, offs[12] = {0};
    for (i = 0; i < c->el->n; ++i) {
        XN *e = c->el->k[i];
        int v[6];
        if (!strcmp(e->tag, "keyRange")) ints(e->text, kr, 2);
        else if (!strcmp(e->tag, "chromaticRect") && ints(e->text, v, 6) == 6 && v[0] >= 0 && v[0] < 14 && (v[1] == 0 || v[1] == 1)) {
            c->rects[v[0]][v[1]][0] = v[2];
            c->rects[v[0]][v[1]][1] = v[3];
            c->rects[v[0]][v[1]][2] = v[4] - v[2];
            c->rects[v[0]][v[1]][3] = v[5] - v[3];
        } else if (!strcmp(e->tag, "chromaticOffset") && ints(e->text, v, 2) == 2 && v[0] >= 0 && v[0] < 12) offs[v[0]] = v[1];
    }
    for (i = kr[0]; i <= kr[1] && c->nkeys < 64; ++i) {
        int ch = i % 12, black = (ch == 1 || ch == 3 || ch == 6 || ch == 8 || ch == 10);
        Key *k = &c->keys[c->nkeys++];
        k->n = i;
        k->black = black;
        k->shape = (!black && i == kr[1]) ? 13 : ch;
        k->w = c->rects[k->shape][0][2];
        k->h = c->rects[k->shape][0][3];
        if (black) k->x = c->x + white * 40 - 1 - k->w / 2 + offs[ch];
        else k->x = c->x + white++ * 40;
        k->y = c->y;
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

static void val_set(const Leaf *L, int v)
{
    int r, i;
    if (!L) return;
    if (L->max > L->min) { if (v < L->min) v = L->min; if (v > L->max) v = L->max; }
    EnterCriticalSection(&g_lock);
    r = E_model_set(L->id, v);
    if (r) eng_refresh();
    LeaveCriticalSection(&g_lock);
    if (!r) {
        for (i = 0; i < g_nloc && g_loc[i].id != L->id; ++i) ;
        if (i == g_nloc && g_nloc < 256) ++g_nloc;
        if (i < 256) { g_loc[i].id = L->id; g_loc[i].v = v; }
    }
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
static volatile LONG g_notes[128];

static void draw_keyboard(const Ctl *c)
{
    int pass, i, shift = get("fm.PATCH.NAME1.OCTAVE SHIFT");
    if (!c->bmp || !c->bmp->px) return;
    for (pass = 0; pass < 2; ++pass)
        for (i = 0; i < c->nkeys; ++i) {
            const Key *k = &c->keys[i];
            int n = k->n + 12 * shift, down = n >= 0 && n < 128 && g_notes[n];
            const int *r;
            if (k->black != pass) continue;
            r = c->rects[k->shape][down];
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

static void load_patch(int idx)
{
    Bank *b;
    char nm[32], s[128];
    if (g_bank < 0 || g_bank >= g_nbanks) return;
    b = &g_banks[g_bank];
    EnterCriticalSection(&g_lock);
    if (g_log) fprintf(g_log, "queue_patch %d %s\n", idx, b->name);
    juno_gui_queue_patch(g_eng, b->bytes, b->len, idx);     /* the patch browser's load, at the next block */
    eng_refresh();
    LeaveCriticalSection(&g_lock);
    g_patch = g_patchsel = idx;
    set("vm.vs.patchId", idx);
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
    {
        unsigned st = m & 0xF0, d1 = (m >> 8) & 0x7F, d2 = (m >> 16) & 0x7F;
        if (st == 0x90 && d2) InterlockedExchange(&g_notes[d1], 1);
        else if (st == 0x80 || st == 0x90) InterlockedExchange(&g_notes[d1], 0);
        g_dirty = 1;
    }
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

/* ------------------------------------------------------------------- audio */
#define SR 48000
#define BLK 256                        /* one output buffer: 5.3 ms */
#define NBUF 16
static volatile LONG g_nbuf = 8;       /* buffers in flight: the output latency, 8 x 5.3 = 43 ms */
static float g_gain = 0.5f;            /* the monitor fader after the engine (a DAW fader's role) */
static volatile LONG g_run = 1;
static HANDLE g_audio_thread;
static volatile LONG g_dropouts;       /* the device ran dry: every buffer played before the next was ready */
static volatile LONG g_blocks;         /* blocks rendered for the device */
static volatile LONG g_audio_state;    /* 0 starting, 1 playing, -1 no output device */

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

static DWORD WINAPI audio_main(LPVOID arg)
{
    WAVEFORMATEX wf;
    HWAVEOUT wo;
    WAVEHDR hdr[NBUF];
    short pcm[NBUF][BLK * 2];
    float L[BLK], R[BLK];
    HANDLE ev = CreateEventA(NULL, FALSE, FALSE, NULL);
    int i, k;
    (void)arg;
    juno_enable_hw_ftz();                  /* this thread renders: the plugin's SSE FTZ / DAZ mode */
    memset(&wf, 0, sizeof wf);
    wf.wFormatTag = WAVE_FORMAT_PCM;
    wf.nChannels = 2;
    wf.nSamplesPerSec = SR;
    wf.wBitsPerSample = 16;
    wf.nBlockAlign = 4;
    wf.nAvgBytesPerSec = SR * 4;
    if (waveOutOpen(&wo, WAVE_MAPPER, &wf, (DWORD_PTR)ev, 0, CALLBACK_EVENT) != MMSYSERR_NOERROR) {
        InterlockedExchange(&g_audio_state, -1);
        return 0;
    }
    InterlockedExchange(&g_audio_state, 1);
    memset(hdr, 0, sizeof hdr);
    for (i = 0; i < NBUF; ++i) {
        hdr[i].lpData = (LPSTR)pcm[i];
        hdr[i].dwBufferLength = sizeof pcm[i];
        waveOutPrepareHeader(wo, &hdr[i], sizeof hdr[i]);
        hdr[i].dwFlags |= WHDR_DONE;
    }
    while (g_run) {
        int done = 0, started = 0;
        for (i = 0; i < g_nbuf; ++i) {
            if (hdr[i].dwFlags & WHDR_DONE) ++done;
            if (hdr[i].dwUser) ++started;
        }
        if (started == g_nbuf && done == g_nbuf) InterlockedIncrement(&g_dropouts);
        for (i = 0; i < g_nbuf; ++i) {
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
    for (i = 0; i < NBUF; ++i) waveOutUnprepareHeader(wo, &hdr[i], sizeof hdr[i]);
    waveOutClose(wo);
    return 0;
}

/* -------------------------------------------------------------- interaction */
static Ctl *g_drag;
static int g_dy, g_dv, g_dkey_note = -1, g_dboth;
static double g_dacc;
static const Key *g_dkey;
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
static const Key *key_at(const Ctl *c, int x, int y)
{
    int i, pass;
    for (pass = 1; pass >= 0; --pass)
        for (i = 0; i < c->nkeys; ++i) {
            const Key *k = &c->keys[i];
            if (k->black == pass && x >= k->x && x < k->x + k->w && y >= k->y && y < k->y + k->h) return k;
        }
    return NULL;
}
/* the click velocity (rva 0x2D4AA0) */
static int key_velocity(const Key *k, int y)
{
    int yy = y < k->y ? k->y : y > k->y + k->h - 1 ? k->y + k->h - 1 : y;
    int v = ((1016 * (yy - k->y)) / k->h) / 7;
    return v < 1 ? 1 : v > 127 ? 127 : v;
}
static int key_on(const Key *k, int y)
{
    int n = k->n + 12 * get("fm.PATCH.NAME1.OCTAVE SHIFT");       /* rva 0x2D4C40 */
    if (n < 0 || n > 127) return -1;
    push_midi(0x90u | ((uint32_t)n << 8) | ((uint32_t)key_velocity(k, y) << 16));
    return n;
}
static void key_off(int n) { if (n >= 0) push_midi(0x80u | ((uint32_t)n << 8) | (64u << 16)); }

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
    case C_KEYBOARD:
        g_dkey = key_at(c, x, y);
        g_dkey_note = g_dkey ? key_on(g_dkey, y) : -1;
        break;
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
    } else if (c->type == C_KEYBOARD) {
        const Key *k = key_at(c, x, y);
        if (k != g_dkey) {
            key_off(g_dkey_note);
            g_dkey = k;
            g_dkey_note = k ? key_on(k, y) : -1;
        }
    }
    g_dirty = 1;
}

static void mouse_up(void)
{
    if (g_drag && g_drag->type == C_KEYBOARD) key_off(g_dkey_note);
    g_dkey_note = -1;
    g_dkey = NULL;
    g_drag = NULL;
    g_npressed = 0;
    g_has_tip = 0;
    g_dirty = 1;
}

static void mouse_wheel(int x, int y, int up)
{
    Ctl *c = hit(x, y);
    Leaf *L;
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
                if (dbl) load_patch(k);
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
        load_patch((g_patch + (!strcmp(args, "inc") ? 1 : 63)) % 64);
    else if (!strcmp(fn, "ManagePatch") && args && !strcmp(args, "load"))
        load_patch(g_patchsel);
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
    static const int NB[] = {4, 6, 8, 12};
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
    /* the audio output's buffering (this program's, not the plugin's): lower is
     * faster to play, higher is safer against drop-outs on a busy computer */
    for (i = 0; i < 4; ++i) {
        snprintf(s, sizeof s, "Audio latency: %d ms", NB[i] * BLK * 1000 / SR);
        AppendMenuA(m, MF_STRING | (g_nbuf == NB[i] ? MF_CHECKED : 0), 700 + NB[i], s);
    }
    GetCursorPos(&pt);
    cmd = TrackPopupMenu(m, TPM_RETURNCMD | TPM_NONOTIFY, pt.x, pt.y, 0, g_wnd, NULL);
    DestroyMenu(m);
    if (cmd == 100 || cmd == 101) set("vm.vs.mode", cmd - 100);
    else if (cmd >= 202 && cmd <= 208) set("vm.vs.voiceCount", cmd - 200);
    else if (cmd >= 300 && cmd <= 303) set("vm.vs.sampleRate", cmd - 300);
    else if (cmd >= 700) InterlockedExchange(&g_nbuf, cmd - 700);
    else if (cmd >= 400) set("vm.vs.mainZoom", cmd - 400);
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
    if (cmd >= 500) midi_open(cmd - 500);
    else if (cmd == 499) { midi_open(-1); status_set("MIDI input off"); }
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
        if (g_dropouts != shown || g_audio_state != shown_state) {
            char t[400];
            shown = g_dropouts;
            shown_state = g_audio_state;
            if (shown_state < 0) snprintf(t, sizeof t, "JUNO-60  --  %s  --  NO AUDIO OUTPUT DEVICE", g_status);
            else snprintf(t, sizeof t, "JUNO-60  --  %s  --  audio drop-outs: %ld (OPTION: a higher audio latency)", g_status, (long)shown);
            if (shown || shown_state < 0) SetWindowTextA(h, t);
        }
        /* the plugin's UI timer: the drain (rva 0x320120), then what changed */
        EnterCriticalSection(&g_lock);
        E_ui_tick();
        changed = eng_refresh();
        LeaveCriticalSection(&g_lock);
        if (changed) g_dirty = 1;
        if (g_dirty) InvalidateRect(h, NULL, FALSE);
        return 0;
    }
    case WM_DESTROY:
        RemovePropA(h, "juno.blocks");
        RemovePropA(h, "juno.dropouts");
        RemovePropA(h, "juno.audio");
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
static const Step SCRIPT[] = {
    {2, 'm', 0x643C90, 0, NULL},                         /* note on 60, velocity 100 */
    {4, 'm', 0x504090, 0, NULL}, {4, 'm', 0x7F4390, 0, NULL},
    {30, 'm', 0x6401B0, 0, NULL},                        /* CC 1 (modulation) 100 */
    {40, 's', 0, 200, "fm.PATCH.FLT.VCF CUTOFF FREQ"},
    {50, 'm', 0x5D60E0, 0, NULL},                        /* pitch bend 12000 */
    {60, 'm', 0x0040D0, 0, NULL},                        /* channel aftertouch 64 */
    {80, 'm', 0x403C80, 0, NULL}, {80, 'm', 0x404080, 0, NULL}, {80, 'm', 0x404380, 0, NULL},
    {84, 'm', 0x4000E0, 0, NULL}, {84, 'm', 0x0001B0, 0, NULL},
    {90, 'k', 0, 24, NULL}, {120, 'K', 0, 0, NULL},
    {130, 's', 0, 1, "fm.PATCH.NAME1.ARPEGGIO SW"},      /* the arp at the host tempo */
    {132, 'm', 0x643090, 0, NULL}, {132, 'm', 0x643790, 0, NULL},
    {240, 'm', 0x403080, 0, NULL}, {240, 'm', 0x403780, 0, NULL},
    {250, 's', 0, 0, "fm.PATCH.NAME1.ARPEGGIO SW"},
    {270, 'p', 0, 0, NULL}, {274, 'm', 0x5A3C90, 0, NULL}, {300, 'm', 0x403C80, 0, NULL},
};
#define RENDER_BLOCKS 340

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
    juno_enable_hw_ftz();                  /* as the audio thread */
    QueryPerformanceFrequency(&fq);
    QueryPerformanceCounter(&t0);
    for (b = 0; b < RENDER_BLOCKS; ++b) {
        for (i = 0; i < (int)(sizeof SCRIPT / sizeof SCRIPT[0]); ++i) {
            const Step *st = &SCRIPT[i];
            if (st->block != b) continue;
            if (st->kind == 'm') push_midi(st->midi);
            else if (st->kind == 's') set(st->ref, st->v);
            else if (st->kind == 'k' && kb && st->v < kb->nkeys)
                held = key_on(&kb->keys[st->v], kb->keys[st->v].y + kb->keys[st->v].h / 2);
            else if (st->kind == 'K') { key_off(held); held = -1; }
            else if (st->kind == 'p') load_patch((g_patch + 1) % 64);
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
                       RENDER_BLOCKS * BLK * 1000 / SR, (double)(t1.QuadPart - t0.QuadPart) * 1000.0 / (double)fq.QuadPart,
                       worst * 1000.0 / (double)fq.QuadPart, worst_b, BLK * 1000.0 / SR);
    fclose(f);
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
    int argc, i, shot_patch = 0, bank0 = 0;
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
        else if (!strcmp(a, "--render") && i + 1 < argc) { char b[MAX_PATH]; WideCharToMultiByte(CP_ACP, 0, argvw[++i], -1, b, sizeof b, NULL, NULL); rend = xstrdup(b); }
    }
    if (rend) {
        char lp[MAX_PATH + 8];
        snprintf(lp, sizeof lp, "%s.log", rend);
        if (!(g_log = fopen(lp, "w"))) return 2;
    }
    if (!dump && !shot && !rend) SetProcessDPIAware();
    InitializeCriticalSection(&g_lock);
    InitializeCriticalSection(&g_qlock);
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
    g_eng = juno_gui_create((float)SR, 0);
    if (g_log) fprintf(g_log, "create %d 0\nplugin_init\n", SR);
    if (!g_eng || !juno_gui_plugin_init(g_eng)) { MessageBoxA(NULL, "engine start failed", "JUNO-60", MB_OK); return 1; }
    banks_load();
    if (bank0 >= 0 && bank0 < g_nbanks) g_bank = bank0;
    EnterCriticalSection(&g_lock);
    eng_refresh();
    LeaveCriticalSection(&g_lock);
    g_tempo = 40.0 + get("fm.SYNTH.COM.TEMPO") / 10.0;
    if (g_nbanks) load_patch((shot || rend) ? shot_patch : 0);
    if (shot) {
        render();
        return save_bmp(shot) ? 0 : 2;
    }
    {
        HDC sdc = GetDC(NULL);
        int dpi = GetDeviceCaps(sdc, LOGPIXELSX), z;
        ReleaseDC(NULL, sdc);
        z = 75 * dpi / 96;
        set("vm.vs.mainZoom", z < 25 ? 25 : z > 200 ? 200 : z);
    }
    if (rend) {
        int r = render_test(rend);
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
        if (midiInGetNumDevs() > 0) midi_open(0);
        g_audio_thread = CreateThread(NULL, 0, audio_main, NULL, 0, NULL);
        if (g_audio_thread) SetThreadPriority(g_audio_thread, THREAD_PRIORITY_TIME_CRITICAL);
        while (GetMessageA(&msg, NULL, 0, 0) > 0) { TranslateMessage(&msg); DispatchMessageA(&msg); }
        InterlockedExchange(&g_run, 0);
        if (g_audio_thread) WaitForSingleObject(g_audio_thread, 2000);
        midi_open(-1);
    }
    return 0;
}

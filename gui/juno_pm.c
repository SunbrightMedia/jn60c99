/* juno_pm.c -- the plugin's patch manager (rva 0x330D10), ported: CLAIMS A39,
 * docs/PATCH_MANAGER.md. Every rule here is READ from the binary (the rva at each function) and
 * graded against the plugin's own code by tools/verify/patch_manager_gate.py: the same command
 * sequences on both, the banks, histories, clipboard, selection, the view's sound and the files
 * compared after every command.
 *
 * Records are shared between the history's states (a reference count): a state is 64 pointers,
 * so a push copies pointers, not 1.3 MB; a change makes a new record. The plugin copies the whole
 * bank per push; what any read sees is the same. */
#include "juno_pm.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>

int juno_gui_record(const void *c, unsigned char *out, int cap);
int juno_gui_queue_record(void *c, const unsigned char *body, int len);
int juno_gui_model_get(const void *c, unsigned int id);
int juno_gui_model_set(void *c, unsigned int id, int v);
void juno_gui_commit(void *c);
/* the view's values (model+0x80, rva 0x34E170; EXECUTED): bank vt+0x50, patch vt+0x58, patchManager
 * vt+0x60, patchListMain vt+0x68, patchListSub vt+0x70; the list control's value refs (Script.xml):
 * patchManager, panelPatch, patchListMain */
#define BANK_VALUE  JPM_ID_BANK
#define PATCH_VALUE JPM_ID_PATCH

typedef struct pm_rec { int ref; unsigned char b[JPM_BODY]; } pm_rec;
typedef struct pm_state {
    pm_rec *rec[JPM_NPATCH];     /* the bank's records (the plugin's one group, State+8) */
    char *name;                  /* State+0x20 */
    int view;                    /* State+0: the view given at its push (1) or none (0) */
    pm_rec *edit;                /* State+0x40: the view's record image at that push */
} pm_state;
typedef struct pm_bank { pm_state *h[JPM_HIST]; int n, cur; } pm_bank;

struct juno_pm {
    void *ctx;
    juno_pm_io io;
    char *dir[4];                /* data, patch, old, script */
    pm_bank *bank;
    int nbank, capbank;
    int cur[2];                  /* pm+0x08: the current bank, main list (the sub list: no control) */
    int sel[2];                  /* pm+0x10: the selected patch */
    pm_rec *clip;                /* pm+0x50 */
    pm_rec *init;                /* the init record (global rva 0xCB05B8) */
    int ref;                     /* pm+0x68 */
    int tick;                    /* pm+0x6C */
    /* the list control's mouse state (rva 0x327D70): captured (+48), the last point (+200), the
     * drag's source and target cells (+192, +196), a double click's read on release (+168) */
    int cap, lastx, lasty, src, tgt, dbl;
    char **inst; int ninst;      /* InstalledBankNames.dat's lines */
    char *pref;                  /* the setting PatchManager/BankName (the last bank's name) */
    int wv[5];                   /* the window's values: panelPatch, -, patchManager, patchListMain, patchListSub */
};

#ifndef PM_TOOTH
#define PM_TOOTH 0                /* a gate's tooth (tools/verify/patch_manager_gate.py --tooth N, N = 1..19) */
#endif
static int g_format = PM_TOOTH == 10 ? 0 : 2;      /* its static value: 2 */
int juno_pm_move(juno_pm *pm, int from, int to);             /* the list's number format, process-wide (rva 0xC43B50) */

/* ------------------------------------------------------------------ records, states */
static pm_rec *rec_new(const unsigned char *b)
{
    pm_rec *r = malloc(sizeof *r);
    if (!r) return NULL;
    r->ref = 1;
    if (b) memcpy(r->b, b, JPM_BODY); else memset(r->b, 0, JPM_BODY);
    return r;
}
static pm_rec *rec_ref(pm_rec *r) { if (r) ++r->ref; return r; }
static void rec_unref(pm_rec *r) { if (r && --r->ref == 0) free(r); }
static void rec_set(pm_rec **slot, pm_rec *r) { pm_rec *o = *slot; *slot = rec_ref(r); rec_unref(o); }

static char *sdup(const char *s)
{
    size_t n = strlen(s ? s : "");
    char *d = malloc(n + 1);
    if (d) memcpy(d, s ? s : "", n + 1);
    return d;
}

static pm_state *state_new(pm_rec *init, const char *name)
{
    pm_state *s = calloc(1, sizeof *s);
    int k;
    if (!s) return NULL;
    for (k = 0; k < JPM_NPATCH; ++k) s->rec[k] = rec_ref(init);
    s->name = sdup(name);
    s->edit = rec_ref(init);
    return s;
}
static pm_state *state_copy(const pm_state *o)
{
    pm_state *s = calloc(1, sizeof *s);
    int k;
    if (!s) return NULL;
    for (k = 0; k < JPM_NPATCH; ++k) s->rec[k] = rec_ref(o->rec[k]);
    s->name = sdup(o->name);
    s->view = o->view;
    s->edit = rec_ref(o->edit);
    return s;
}
static void state_free(pm_state *s)
{
    int k;
    if (!s) return;
    for (k = 0; k < JPM_NPATCH; ++k) rec_unref(s->rec[k]);
    rec_unref(s->edit);
    free(s->name);
    free(s);
}
static void bank_clear(pm_bank *b)
{
    int i;
    for (i = 0; i < b->n; ++i) state_free(b->h[i]);
    b->n = b->cur = 0;
}
static pm_state *cur_state(const juno_pm *pm, int b)
{
    return (b >= 0 && b < pm->nbank && pm->bank[b].n) ? pm->bank[b].h[pm->bank[b].cur] : NULL;
}
/* the view's record image (the serializer, rva 0x335990) */
static pm_rec *view_rec(juno_pm *pm)
{
    pm_rec *r = rec_new(NULL);
    if (!r) return NULL;
    if (pm->io.record) pm->io.record(pm->io.u, r->b, JPM_BODY);
    else juno_gui_record(pm->ctx, r->b, JPM_BODY);
    return r;
}
/* a record into the view (the patch browser's load, rva 0x335850) */
static void view_load(juno_pm *pm, const pm_rec *r)
{
    if (!r) return;
    if (pm->io.load) pm->io.load(pm->io.u, r->b, JPM_BODY);
    else juno_gui_queue_record(pm->ctx, r->b, JPM_BODY);
}
/* the window's own values (panelPatch .. patchListSub) live here; the rest is the model's */
static int *wslot(juno_pm *pm, unsigned int id)
{
    return (id >= JPM_ID_PANEL && id <= JPM_ID_LIST_SUB && id != 0x0FFFC003u) ? &pm->wv[id - JPM_ID_PANEL] : NULL;
}
static int vget(juno_pm *pm, unsigned int id)
{
    int *w = wslot(pm, id);
    if (w) return *w;
    return pm->io.model ? pm->io.model(pm->io.u, JPM_GET, id, 0, 0) : juno_gui_model_get(pm->ctx, id);
}
static void vset(juno_pm *pm, unsigned int id, int v, int flag)     /* rva 0x283DB0 */
{
    int *w = wslot(pm, id);
    if (w) *w = v;
    if (pm->io.model) pm->io.model(pm->io.u, JPM_SET, id, v, flag);
    else if (!w) juno_gui_model_set(pm->ctx, id, v);
}
/* the model's notify (rva 0x2853C0); its listeners: the open window's list (rva 0x3285F0, the list's
 * slot 18) sets its value refs patchManager and patchListMain back to 0 (raw: no set, no notify) */
static void vnotify(juno_pm *pm)
{
    if (pm->io.model) pm->io.model(pm->io.u, JPM_NOTIFY, 0, 0, 0);
    if (pm->wv[0] && PM_TOOTH != 14) { pm->wv[JPM_ID_MANAGER - JPM_ID_PANEL] = 0; pm->wv[JPM_ID_LIST_MAIN - JPM_ID_PANEL] = 0; }
}
static void vcommit(juno_pm *pm)                                    /* rva 0x283120 */
{
    if (pm->io.model) pm->io.model(pm->io.u, JPM_COMMIT, 0, 0, 0); else juno_gui_commit(pm->ctx);
}
/* the list's close (rva 0x3262C0): the window open (panelPatch, the list's value ref 1): it closes */
static void wclose(juno_pm *pm)
{
    if (vget(pm, JPM_ID_PANEL) == 0 || PM_TOOTH == 13) return;     /* TOOTH 13: the window stays open */
    vset(pm, JPM_ID_PANEL, 0, 0);
    vnotify(pm);
    vcommit(pm);
}
/* the list's key and mouse tail (rva 0x327CF8, 0x327E95, 0x328038): patchManager (the list's value
 * ref 0) not 1: set to 1 */
static void wtail(juno_pm *pm)
{
    if (vget(pm, JPM_ID_MANAGER) == 1 || PM_TOOTH == 11) return;  /* TOOTH 11: no key / mouse tail */
    vset(pm, JPM_ID_MANAGER, 1, 0);
    vnotify(pm);
    vcommit(pm);
}
/* the buttons' tail (ManagePatch rva 0x3232F6, ManagePatchBank rva 0x324850) and the bank name's
 * commit (rva 0x33F402): patchManager and the list's value (the sub list's for incSub / decSub) to 1 */
static void tail(juno_pm *pm, int sub)
{
    vset(pm, JPM_ID_MANAGER, 1, 0);
    if (PM_TOOTH != 12) vset(pm, sub ? JPM_ID_LIST_SUB : JPM_ID_LIST_MAIN, 1, 0);   /* TOOTH 12: no list value */
    vnotify(pm);
    vcommit(pm);
}

/* push (rva 0x32CA60, bank, view): at cursor 63 the oldest state goes, else the redo tail goes;
 * the state that was current takes the view (and, given one, the view's record image); a copy of
 * it is appended and becomes current */
static void push(juno_pm *pm, int b, int view)
{
    pm_bank *k = &pm->bank[b];
    pm_state *p, *c;
    if (k->cur == JPM_HIST - 1 - (PM_TOOTH == 8)) {
        state_free(k->h[0]);
        memmove(k->h, k->h + 1, (size_t)(k->n - 1) * sizeof k->h[0]);
        --k->n;
    } else {
        ++k->cur;
        while (k->n > k->cur) state_free(k->h[--k->n]);
    }
    p = k->h[k->n - 1];
    p->view = view;
    if (view) { pm_rec *r = view_rec(pm); rec_set(&p->edit, r); rec_unref(r); }
    c = state_copy(p);
    if (c) k->h[k->n++] = c;
}

/* undo (rva 0x335AE0): the cursor back; when the state it reaches was pushed with the view, the
 * state left keeps the view's image and the view takes the reached state's */
static int undo(juno_pm *pm, int b)
{
    pm_bank *k = &pm->bank[b];
    int v3 = k->cur;
    if (v3 <= 0) return 0;
    k->cur = v3 - 1;
    if (k->h[v3 - 1]->view && PM_TOOTH != 2) {
        pm_rec *r = view_rec(pm);
        rec_set(&k->h[v3]->edit, r); rec_unref(r);
        view_load(pm, k->h[v3 - 1]->edit);
    }
    return 1;
}
/* redo (rva 0x333480): the cursor on; when the state left was pushed with the view, the view
 * takes the reached state's image */
static int redo(juno_pm *pm, int b)
{
    pm_bank *k = &pm->bank[b];
    int v3 = k->cur;
    if (k->n - 1 <= v3) return 0;
    k->cur = v3 + 1;
    if (k->h[v3]->view) view_load(pm, k->h[v3 + 1]->edit);
    return 1;
}

/* ------------------------------------------------------------------ names */
static int is_space(int ch) { return ch == ' ' || (ch >= 9 && ch <= 13); }   /* isspace, "C" (rva 0x6BEA7C) */

/* trim both ends (rva 0x3E3F20) */
static void trim(const char *in, char *out, int cap)
{
    const char *a = in, *e;
    int n;
    while (*a && is_space((unsigned char)*a)) ++a;
    e = a + strlen(a);
    while (e > a && is_space((unsigned char)e[-1])) --e;
    n = (int)(e - a);
    if (n > cap - 1) n = cap - 1;
    memcpy(out, a, (size_t)n);
    out[n] = 0;
}

/* the record's name (rva 0x33BC80): 16 chars at body offset 140, two nibble bytes each */
static void rec_name(const unsigned char *b, char out[17])
{
    int k;
    for (k = 0; k < 16; ++k) out[k] = (char)(unsigned char)(b[140 + 2 * k] * 16 + b[141 + 2 * k]);
    out[16] = 0;
}
/* set it (rva 0x33CDA0): cut to 16, padded with spaces */
static void rec_set_name(unsigned char *b, const char *name, int n)
{
    int k;
    for (k = 0; k < 16; ++k) {
        unsigned char ch = (unsigned char)(k < n ? name[k] : ' ');
        b[140 + 2 * k] = (unsigned char)((ch >> 4) & 15);
        b[141 + 2 * k] = (unsigned char)(ch & 15);
    }
}

/* a name not among the banks' (rva 0x334F20): `base`, else "base 1", "base 2", ... (1..999) */
static int unique_name(const juno_pm *pm, const char *base, char *out, int cap, int skip)
{
    int i, n;
    snprintf(out, (size_t)cap, "%s", base);
    for (n = 0; n < 1000; ++n) {
        int hit = 0;
        if (n) snprintf(out, (size_t)cap, "%s %d", base, n);
        for (i = 0; i < pm->nbank; ++i) {
            const pm_state *s = cur_state(pm, i);
            if (i != skip && s && !strcmp(s->name, out)) { hit = 1; break; }
        }
        if (!hit) return 1;
    }
    return 0;
}

/* ------------------------------------------------------------------ bank list */
static int bank_add(juno_pm *pm, pm_state *s)
{
    if (!s) return -1;
    if (pm->nbank == pm->capbank) {
        int cap = pm->capbank ? 2 * pm->capbank : 8;
        pm_bank *nb = realloc(pm->bank, (size_t)cap * sizeof *nb);
        if (!nb) { state_free(s); return -1; }
        pm->bank = nb; pm->capbank = cap;
    }
    memset(&pm->bank[pm->nbank], 0, sizeof pm->bank[0]);
    pm->bank[pm->nbank].h[0] = s;
    pm->bank[pm->nbank].n = 1;
    return pm->nbank++;
}
static int clampi(int v, int lo, int hi) { return v < lo ? lo : v > hi ? hi : v; }

/* ------------------------------------------------------------------ the commands */
/* load (rva 0x338090, push flag, idx -1 = the selection): the view takes the record; the view's
 * bank and patch values take the current bank and the selection */
static void cmd_load(juno_pm *pm, int pushed, int idx)
{
    int b = pm->cur[0];
    pm_state *s;
    if (pushed) push(pm, b, 1);
    s = cur_state(pm, b);
    if (!s) return;
    view_load(pm, s->rec[idx == -1 ? pm->sel[0] : idx]);
    vset(pm, BANK_VALUE, pm->cur[0], 1);
    vset(pm, PATCH_VALUE, pm->sel[0], 1);
}
/* write (rva 0x332960): the view's image into the selection, pushed without the view */
static void cmd_write(juno_pm *pm)
{
    int b = pm->cur[0];
    pm_rec *r;
    push(pm, b, 0);
    r = view_rec(pm);
    rec_set(&cur_state(pm, b)->rec[pm->sel[0]], r);
    rec_unref(r);
}
/* sync from the view (rva 0x330E10): the bank and the selection take the view's values */
static void sync_view(juno_pm *pm)
{
    pm->cur[0] = clampi(vget(pm, BANK_VALUE), 0, pm->nbank - 1);
    pm->sel[0] = clampi(vget(pm, PATCH_VALUE), 0, 63);
}
static void cmd_rename_patch(juno_pm *pm)
{
    int b = pm->cur[0];
    pm_state *s = cur_state(pm, b);
    char nm[17], off[17], in[512], t[512];
    pm_rec *r;
    if (!s || !pm->io.text) return;
    rec_name(s->rec[pm->sel[0]]->b, nm);
    trim(nm, off, sizeof off);                         /* the text offered: trimmed (rva 0x325C60) */
    if (!pm->io.text(pm->io.u, JPM_TEXT_PATCH, off, in, sizeof in)) return;
    trim(in, t, sizeof t);
    push(pm, b, 0);
    s = cur_state(pm, b);
    r = rec_new(s->rec[pm->sel[0]]->b);
    if (!r) return;
    rec_set_name(r->b, t, (int)strlen(t));
    rec_set(&s->rec[pm->sel[0]], r);
    rec_unref(r);
}
static void ins_at(pm_state *s, int at, pm_rec *r)      /* insert at, the last one dropped */
{
    int k;
#if PM_TOOTH == 3
    rec_set(&s->rec[at], r); return;                         /* TOOTH 3: replaces */
#endif
    rec_unref(s->rec[JPM_NPATCH - 1]);
    for (k = JPM_NPATCH - 1; k > at; --k) s->rec[k] = s->rec[k - 1];
    s->rec[at] = rec_ref(r);
}
static void del_at(pm_state *s, int at, pm_rec *fill)  /* erase at, `fill` appended */
{
    int k;
    rec_unref(s->rec[at]);
    for (k = at; k < JPM_NPATCH - 1; ++k) s->rec[k] = s->rec[k + 1];
    s->rec[JPM_NPATCH - 1] = rec_ref(fill);
}
static void cmd_edit(juno_pm *pm, int what)
{
    int b = pm->cur[0], i = pm->sel[0];
    pm_state *s = cur_state(pm, b);
    if (!s || i < 0 || i >= JPM_NPATCH) return;
    switch (what) {
    case 'C': rec_set(&pm->clip, s->rec[i]); return;                      /* rva 0x32D6E0 */
    case 'N': push(pm, b, 0); ins_at(cur_state(pm, b), i, pm->init); return; /* rva 0x32C970 */
    case 'D': push(pm, b, 0); del_at(cur_state(pm, b), i, pm->init); return; /* rva 0x32E070 */
    case 'X': push(pm, b, 0); s = cur_state(pm, b);                        /* rva 0x32D950 */
              rec_set(&pm->clip, s->rec[i]); del_at(s, i, pm->init); return;
    case 'V': push(pm, b, 0); rec_set(&cur_state(pm, b)->rec[i], pm->clip); return;  /* rva 0x333960 */
    case 'Y': push(pm, b, 0); ins_at(cur_state(pm, b), i, pm->clip); return;  /* rva 0x3307C0 */
    }
}
static void cmd_new_bank(juno_pm *pm)                     /* rva 0x32C6E0 */
{
    char nm[600];
    pm_state *s;
    if (!unique_name(pm, "Initial", nm, sizeof nm, -1)) return;
    s = state_new(pm->init, nm);
    if (bank_add(pm, s) >= 0) pm->cur[0] = pm->nbank - 1;
}
static void cmd_delete_bank(juno_pm *pm)                  /* rva 0x32DDC0 */
{
    int b = pm->cur[0];
    if (PM_TOOTH != 4 && (!pm->io.confirm || !pm->io.confirm(pm->io.u, JPM_MSG_DELETE_BANK))) return;
    if (b < 0 || b >= pm->nbank) return;
    bank_clear(&pm->bank[b]);
    memmove(pm->bank + b, pm->bank + b + 1, (size_t)(pm->nbank - b - 1) * sizeof pm->bank[0]);
    --pm->nbank;
    if (!pm->nbank) bank_add(pm, state_new(pm->init, "Initial"));   /* EXECUTED: "Initial" */
    if (pm->cur[0] > pm->nbank - 1) pm->cur[0] = pm->nbank - 1;
    if (pm->cur[1] > pm->nbank - 1) pm->cur[1] = pm->nbank - 1;
}
/* a bank name a file can carry (rva 0x3F2700): not empty, no leading '.', none of the nine
 * characters a Windows file name refuses (double quote, star, slash, colon, angles, ?, backslash, bar) */
static int name_ok(const char *t)
{
    return t[0] && t[0] != '.' && !strpbrk(t, "\"*/:<>?\\|");
}
static int same_lower(const char *a, const char *b)       /* rva 0x3E3D30: tolower, "C" locale */
{
    for (; *a && *b; ++a, ++b) if (tolower((unsigned char)*a) != tolower((unsigned char)*b)) return 0;
    return !*a && !*b;
}
/* rename bank (ctrl+W: the bank name control's edit, commit rva 0x33F260): the text trimmed; not
 * a file's name, or another bank's (case ignored): message 37 (rva 0x33F4C2) and the edit opens
 * again with it. Every commit ends in the tail, the name taken or not (rva 0x33F402 / 0x33F190) */
static void cmd_rename_bank(juno_pm *pm)
{
    int b = pm->cur[0], i, bad;
    pm_state *s = cur_state(pm, b);
    char off[512], in[512], t[512];
    if (!s || !pm->io.text) return;
    snprintf(off, sizeof off, "%s", s->name);
    for (;;) {
        if (!pm->io.text(pm->io.u, JPM_TEXT_BANK, off, in, sizeof in)) return;
        trim(in, t, sizeof t);
        bad = !name_ok(t);
        for (i = 0; !bad && i < pm->nbank; ++i)
            if (i != b && (PM_TOOTH == 5 ? !strcmp(cur_state(pm, i)->name, t) : same_lower(cur_state(pm, i)->name, t))) bad = 1;
        if (!bad) break;
        if (pm->io.confirm) pm->io.confirm(pm->io.u, JPM_MSG_BANK_NAME);
        if (PM_TOOTH != 16) tail(pm, 0);                /* TOOTH 16: no tail for a refused name */
        snprintf(off, sizeof off, "%s", t);
    }
    free(s->name);
    s->name = sdup(t);
    tail(pm, 0);
}
static int cmd_select_bank(juno_pm *pm)                   /* rva 0x3344C0: 1 when a bank was chosen */
{
    const char **items;
    int *chk, i, r, got = 0;
    if (!pm->io.menu || pm->nbank <= 0) return 0;
    items = malloc((size_t)pm->nbank * sizeof *items);
    chk = malloc((size_t)pm->nbank * sizeof *chk);
    if (items && chk) {
        for (i = 0; i < pm->nbank; ++i) { items[i] = cur_state(pm, i)->name; chk[i] = (i == pm->cur[0]); }
        r = pm->io.menu(pm->io.u, items, chk, pm->nbank);
        if (r >= 0 && r < pm->nbank) { pm->cur[0] = r; got = 1; }     /* a menu returns an item or -1 */
    }
    free(items); free(chk);
    return got;
}
/* move (rva 0x330A80): the record at `from` to `to`, the ones between shifted */
int juno_pm_move(juno_pm *pm, int from, int to)
{
    int b, k;
    pm_state *s;
    pm_rec *r;
    if (!pm || from == -1 || to == -1 || from == to) return 0;
    if (from < 0 || from >= JPM_NPATCH || to < 0 || to >= JPM_NPATCH) return 0;
    b = pm->cur[0];
    push(pm, b, 0);
    s = cur_state(pm, b);
    r = s->rec[from];
    if (from < to) for (k = from; k < to; ++k) s->rec[k] = s->rec[k + 1];
    else           for (k = from; k > to; --k) s->rec[k] = s->rec[k - 1];
    s->rec[to] = r;
    return 1;
}
/* the list's mouse (rva 0x327D70) on the list's rectangle r = left, top, right, bottom: 4 columns of
 * 16 cells (the JUNO's list mode 0). Messages: 0 down, 1 up, 2 double click, 3 move. A down or a
 * double click outside the list while not captured is not taken; a down captures and notes the
 * cell (the drag's source), a double click also arms a read on release; a move while captured
 * selects the cell under the pointer (the drag's target; outside: the source, no target); the up
 * releases and, inside the list, selects its cell, moves source -> target (rva 0x330A80) and
 * reads with a push when armed. Returns 1 when taken. */
static int hit(const int r[4], int x, int y) { return x >= r[0] && x < r[2] && y >= r[1] && y < r[3]; }
int juno_pm_mouse(juno_pm *pm, int type, int x, int y, const int r[4])
{
    const int cols = 4, rows = 16;
    int col, row;
    if (!pm || !r) return 0;
    if (!pm->cap && !hit(r, x, y)) return 0;
    switch (type) {
    case 0: case 2:
        pm->cap = 1;
        pm->lastx = x; pm->lasty = y;
        if (hit(r, x, y)) { col = cols * (x - r[0]) / (r[2] - r[0]); row = (y - r[1]) * rows / (r[3] - r[1]); }
        else col = row = -1;
        pm->src = col * rows + row;
        if (type == 2) pm->dbl = 1;
        return 1;
    case 3:
        if (!pm->cap) return 0;
        if (x == pm->lastx && y == pm->lasty) return 1;
        pm->lastx = x; pm->lasty = y;
        if (hit(r, x, y)) {
            col = cols * (x - r[0]) / (r[2] - r[0]); row = (y - r[1]) * rows / (r[3] - r[1]);
            pm->tgt = row + col * rows;
            pm->sel[0] = pm->tgt;
        } else {
            pm->sel[0] = pm->src;
            pm->tgt = -1;
        }
        wtail(pm);
        return 1;
    case 1:
        if (!pm->cap) return 0;
        pm->cap = 0;
        if (hit(r, x, y)) {
            col = cols * (x - r[0]) / (r[2] - r[0]);
            pm->sel[0] = rows * (y - r[1]) / (r[3] - r[1]) + col * rows;
            if (PM_TOOTH != 7) juno_pm_move(pm, pm->src, pm->tgt);
            if (pm->dbl) { cmd_load(pm, 1, -1); pm->dbl = 0; }
        }
        pm->lastx = pm->lasty = (int)0x80000001;
        pm->src = pm->tgt = -1;
        wtail(pm);
        return 1;
    }
    return 0;
}

/* the bank name control's mouse (rva 0x33F0A0) on its rectangle r: a down or a double click on its
 * button (b: its bitmap's frame at buttonPosition; EXECUTED 64,60 14x34) opens its text edit: the
 * bank's rename (the text edit control's handler, rva 0x2DE890 -> vt+0x140); elsewhere on it the
 * bank menu (rva 0x3344C0), a bank chosen: the tail (rva 0x33F190). 1 when taken */
int juno_pm_bank_mouse(juno_pm *pm, int type, int x, int y, const int r[4], const int b[4])
{
    if (!pm || !r || !hit(r, x, y) || (type != 0 && type != 2)) return 0;
    if (b && hit(b, x, y) && PM_TOOTH != 19) { cmd_rename_bank(pm); return 1; }    /* TOOTH 19: the menu there */
    if (!cmd_select_bank(pm)) return 0;
    if (PM_TOOTH != 18) tail(pm, 0);                      /* TOOTH 18: no tail after the menu */
    return 1;
}

void juno_pm_drag(const juno_pm *pm, int *src, int *tgt)  /* the list's drag: source, target (-1 none) */
{
    if (src) *src = pm ? pm->src : -1;
    if (tgt) *tgt = pm ? pm->tgt : -1;
}

int juno_pm_select(juno_pm *pm, int idx)                  /* rva 0x334E90: no clamp */
{
    if (!pm) return 0;
    pm->sel[0] = idx;
    return 1;
}

/* ------------------------------------------------------------------ bank files */
static const char KOA[16] = { 'K','o','a','B','a','n','k','F','i','l','e','0','0','0','0','3' };
#define FILE_BYTES (16 + 7 + JPM_NPATCH * (16 + JPM_BODY))

static unsigned char *bank_image(const pm_state *s)        /* rva 0x336A80 / 0x336830 */
{
    unsigned char *f = malloc(FILE_BYTES), *p;
    int k;
    if (!f) return NULL;
    memcpy(f, KOA, 16);
    memcpy(f + 16, "PG-JU60", 7);
    for (k = 0, p = f + 23; k < JPM_NPATCH; ++k, p += 16 + JPM_BODY) {
        char nm[17];
        rec_name(s->rec[k]->b, nm);
        memcpy(p, nm, 16);
        memcpy(p + 16, s->rec[k]->b, JPM_BODY);
    }
    return f;
}
static void path_join(char *out, int cap, const char *dir, const char *name, const char *ext)
{
    snprintf(out, (size_t)cap, "%s/%s%s", dir, name, ext);
}
/* write through tmp.tmp (rva 0x336A80): the image to tmp.tmp, the old file deleted, tmp moved */
static int write_bank_file(juno_pm *pm, const pm_state *s, const char *path)
{
    char tmp[1024];
    const char *sl = strrchr(path, '/');
    unsigned char *img = bank_image(s);
    int ok = 0;
    if (!img || !pm->io.write || !pm->io.move) { free(img); return 0; }
    snprintf(tmp, sizeof tmp, "%.*s/tmp.tmp", sl ? (int)(sl - path) : 0, path);
    if (pm->io.write(pm->io.u, tmp, img, FILE_BYTES)) {
        if (pm->io.exists && pm->io.exists(pm->io.u, path) && pm->io.remove) pm->io.remove(pm->io.u, path);
        ok = pm->io.move(pm->io.u, tmp, path);
    }
    free(img);
    return ok;
}
/* a bank file's records (rva 0x331530): KoaBankFile00003, the product PG-JU60, 64 records */
static int read_bank_file(const unsigned char *f, long len, pm_state *s)
{
    int k;
    if (len < FILE_BYTES || memcmp(f, KOA, 16) || memcmp(f + 16, "PG-JU60", 7)) return 0;
    for (k = 0; k < JPM_NPATCH; ++k) {
        const unsigned char *e = f + 23 + (long)k * (16 + JPM_BODY);
        pm_rec *r = rec_new(e + 16);
        if (!r) return 0;
        if (PM_TOOTH != 9) rec_set_name(r->b, (const char *)e, 16);   /* the file's name wins (rva 0x330ED0) */
        rec_set(&s->rec[k], r);
        rec_unref(r);
    }
    return 1;
}

static int has_ext(const char *n, const char *ext)
{
    size_t a = strlen(n), b = strlen(ext);
    return a > b && !strcmp(n + a - b, ext);
}

/* save all (rva 0x336FD0): every bank to <data>/<name>.bin; a .bin there no bank wrote is moved
 * to <name>.bak (a name not among the .bak files: "<name>", "<name> 1", ...) */
int juno_pm_save_all(juno_pm *pm)
{
    char **bins = NULL, **all, path[1024], to[1024];
    int nb = 0, nall = 0, i, j;
    if (!pm || !pm->dir[0] || !pm->dir[0][0]) return 0;
    all = pm->io.list ? pm->io.list(pm->io.u, pm->dir[0], &nall) : NULL;
    for (i = 0; i < nall; ++i)
        if (has_ext(all[i], ".bin")) {
            char **nbn = realloc(bins, (size_t)(nb + 1) * sizeof *bins);
            if (!nbn) break;
            bins = nbn;
            bins[nb] = sdup(all[i]);
            bins[nb][strlen(bins[nb]) - 4] = 0;
            ++nb;
        }
    for (i = 0; i < pm->nbank; ++i) {
        const pm_state *s = cur_state(pm, i);
        path_join(path, sizeof path, pm->dir[0], s->name, ".bin");
        if (write_bank_file(pm, s, path))
            for (j = 0; j < nb; ++j)
                if (bins[j] && !strcmp(bins[j], s->name)) { free(bins[j]); bins[j] = NULL; break; }
    }
    for (j = 0; j < nb; ++j) {
        int n, hit;
        if (!bins[j] || PM_TOOTH == 6) { free(bins[j]); continue; }
        for (n = 0; n < 1000; ++n) {
            if (n) snprintf(to, sizeof to, "%s/%s %d.bak", pm->dir[0], bins[j], n);
            else   snprintf(to, sizeof to, "%s/%s.bak", pm->dir[0], bins[j]);
            hit = pm->io.exists && pm->io.exists(pm->io.u, to);
            if (!hit) break;
        }
        path_join(path, sizeof path, pm->dir[0], bins[j], ".bin");
        if (n < 1000 && pm->io.move) pm->io.move(pm->io.u, path, to);
        free(bins[j]);
    }
    free(bins);
    for (i = 0; i < nall; ++i) free(all[i]);
    free(all);
    return 1;
}

/* a dialog's path in the plugin's form: '/' separators */
static void slashes(char *p) { for (; *p; ++p) if (*p == '\\') *p = '/'; }

/* export (ctrl+E, rva 0x32EAD0): the save dialog ("Save Patch Bank", the bank's name + .bin), the
 * current bank written there through tmp.tmp; a failed write: message 3 */
static void cmd_export(juno_pm *pm)
{
    pm_state *s = cur_state(pm, pm->cur[0]);
    char sug[600], path[1024];
    if (!s || !pm->io.save_file) return;
    snprintf(sug, sizeof sug, "%s.bin", s->name);
    if (!pm->io.save_file(pm->io.u, "Save Patch Bank", sug, path, sizeof path)) return;
    slashes(path);
    if (!write_bank_file(pm, s, path) && pm->io.confirm) pm->io.confirm(pm->io.u, JPM_MSG_EXPORT);
}
/* import (ctrl+I, rva 0x32F2B0): the open dialog ("Load Patch Bank / Import Patch", .bin, many
 * files: rva 0x40B5D0 reads the first item's path, the others' display names, and joins each name
 * to the first item's folder -- EXECUTED); each bank file a new bank named by its file (a name not
 * among the banks', case kept: rva 0x334F20); a file that is no bank: message 2 after all; any
 * added: the last is current */
static void cmd_import(juno_pm *pm)
{
    char **paths = NULL, nm[600];
    int n = 0, i, added = 0, bad = 0;
    if (!pm->io.open_files || !pm->io.open_files(pm->io.u, "Load Patch Bank / Import Patch", ".bin", &paths, &n)) return;
    if (n > 0) slashes(paths[0]);
    for (i = 0; i < n; ++i) {
        long len = 0;
        unsigned char *f;
        pm_state *s = state_new(pm->init, "");
        const char *b, *e, *d = strrchr(paths[0], '/');
        char path[1024];
        if (i == 0 || PM_TOOTH == 17) snprintf(path, sizeof path, "%s", paths[i]);   /* TOOTH 17: a name read as a path */
        else snprintf(path, sizeof path, "%.*s/%s", d ? (int)(d - paths[0]) : 0, paths[0], paths[i]);
        f = pm->io.read ? pm->io.read(pm->io.u, path, &len) : NULL;
        b = strrchr(path, '/'); b = b ? b + 1 : path;
        e = strrchr(b, '.'); if (!e) e = b + strlen(b);
        snprintf(nm, sizeof nm, "%.*s", (int)(e - b), b);
        if (s && f && read_bank_file(f, len, s)) {
            char un[600];
            if (unique_name(pm, nm, un, sizeof un, -1)) {
                free(s->name); s->name = sdup(un);
                if (bank_add(pm, s) >= 0) added = 1;
            } else { state_free(s); bad = 1; }
        } else { state_free(s); bad = 1; }
        free(f);
    }
    for (i = 0; i < n; ++i) free(paths[i]);              /* the first one names the others' folder */
    free(paths);
    if (bad && pm->io.confirm) pm->io.confirm(pm->io.u, JPM_MSG_IMPORT);
    if (added) pm->cur[0] = pm->nbank - 1;
}

/* ctrl+Shift+D (rva 0x32E190, in no help text): the current bank as text, <data>/<name>.txt, a
 * line per patch: its number in the current format, ": ", its 16-char name (text mode: CRLF) */
static void cmd_text(juno_pm *pm)
{
    pm_state *s = cur_state(pm, pm->cur[0]);
    char path[1024], num[24], nm[17];
    unsigned char *t;
    long k = 0;
    int j;
    if (!s || !pm->dir[0] || !pm->dir[0][0] || !pm->io.write) return;
    t = malloc(JPM_NPATCH * 48);
    if (!t) return;
    for (j = 0; j < JPM_NPATCH; ++j) {               /* a line: the list's cell text (rva 0x335640) */
        rec_name(s->rec[j]->b, nm);
        if (juno_pm_number(j, num, sizeof num) > 0) k += sprintf((char *)t + k, "%s: ", num);
        memcpy(t + k, nm, 16); k += 16;
        t[k++] = '\r'; t[k++] = '\n';
    }
    path_join(path, sizeof path, pm->dir[0], s->name, ".txt");
    pm->io.write(pm->io.u, path, t, k);
    free(t);
}

/* ------------------------------------------------------------------ the list's keys */
static int key_cmd(juno_pm *pm, int code, int ctrl, int shift, int *close)
{
    int sel = pm->sel[0], cols = 4, rows = 16;
    switch (code) {
    case 'W': if (!ctrl) return 0; cmd_rename_bank(pm); return 1;
    case 'B': if (!ctrl) return 0; cmd_select_bank(pm); return 1;
    case 'R': if (!ctrl) return 0; cmd_new_bank(pm); return 1;
    case 'T': if (!ctrl) return 0; cmd_delete_bank(pm); return 1;
    case 'I': if (!ctrl) return 0; cmd_import(pm); return 1;
    case 'E': if (!ctrl) return 0; cmd_export(pm); return 1;
    case 'U': case 'G': return ctrl;                   /* SYSTEM-8 send / get (rva 0x341F10 / 0x340B80): not ported */
    case 'N': if (!ctrl) return 0; cmd_edit(pm, 'N'); return 1;
    case JPM_KEY_DELETE: cmd_edit(pm, 'D'); return 1;
    case 'O': if (!ctrl) return 0; cmd_load(pm, 1, -1); return 1;
    case 'S': if (!ctrl) return 0; cmd_write(pm); return 1;
    case JPM_KEY_SPACE: cmd_rename_patch(pm); return 1;
    case 'C': if (!ctrl) return 0; cmd_edit(pm, 'C'); return 1;
    case 'X': if (!ctrl) return 0; cmd_edit(pm, 'X'); return 1;
    case 'V': if (!ctrl) return 0; cmd_edit(pm, 'V'); return 1;
    case 'Y': if (!ctrl) return 0; cmd_edit(pm, 'Y'); return 1;
    case 'Z': if (!ctrl) return 0; if (shift) redo(pm, pm->cur[0]); else undo(pm, pm->cur[0]); return 1;
    case 'J': if (!ctrl) return 0; g_format = (g_format + 1) % 3; return 1;
    case 'D': if (!ctrl || !shift) return 0; cmd_text(pm); return 1;
    case JPM_KEY_UP:    pm->sel[0] = sel - 1 < 0 ? 0 : sel - 1; return 1;
    case JPM_KEY_DOWN:  pm->sel[0] = sel + 1 > 63 ? 63 : sel + 1; return 1;
    case JPM_KEY_LEFT:  pm->sel[0] = ((sel / rows - 1) < 0 ? 0 : sel / rows - 1) * rows + sel % rows; return 1;
    case JPM_KEY_RIGHT: pm->sel[0] = ((sel / rows + 1) >= cols - 1 ? cols - 1 : sel / rows + 1) * rows + sel % rows; return 1;
    case JPM_KEY_ENTER: cmd_load(pm, 1, -1); wclose(pm); if (close) *close = 1; return 1;   /* rva 0x3262C0 */
    case JPM_KEY_ESC:   wclose(pm); if (close) *close = 1; return 1;
    }
    return 0;
}
/* every key the list handles ends in its tail (rva 0x327CF8) */
int juno_pm_key(juno_pm *pm, int code, int flags, int *close)
{
    int r;
    if (close) *close = 0;
    if (!pm) return 0;
    r = key_cmd(pm, code, (flags & JPM_CTRL) != 0, (flags & JPM_SHIFT) != 0, close);
    if (r) wtail(pm);
    return r;
}

/* ------------------------------------------------------------------ the buttons' functions */
/* ManagePatch (rva 0x322E60): every argument ends in the tail (rva 0x3232F6), "load" closes the
 * window first (rva 0x32D180 -> 0x3262C0; returns 2); the SYSTEM-8 ones (sendTemp, getTemp,
 * sendUser, getUser) are not ported: the tail alone. ManagePatchBank (rva 0x323FD0): every
 * argument ends in its tail (rva 0x324850; incSub / decSub: the sub list's). Returns 1 for an
 * argument it knows, 0 else. */
static int func_patch(juno_pm *pm, const char *args)
{
    if (!strcmp(args, "load")) { cmd_load(pm, 1, -1); wclose(pm); return 2; }
    if (!strcmp(args, "save")) { cmd_write(pm); return 1; }
    if (!strcmp(args, "saveLast")) { sync_view(pm); cmd_write(pm); return 1; }
    if (!strcmp(args, "rename")) { cmd_rename_patch(pm); return 1; }
    if (!strcmp(args, "inc") || !strcmp(args, "dec")) {                 /* rva 0x3245C0 */
        sync_view(pm);
#if PM_TOOTH == 1
        pm->sel[0] = (pm->sel[0] + (args[0] == 'i' ? 1 : 63)) % 64;                /* TOOTH 1: wraps */
#else
        pm->sel[0] = clampi(pm->sel[0] + (args[0] == 'i' ? 1 : -1), 0, 63);       /* rva 0x334EA0 */
#endif
        cmd_load(pm, 0, -1);
        return 1;
    }
    return 0;
}
static int func_bank(juno_pm *pm, const char *args)
{
    if (!strcmp(args, "select")) { cmd_select_bank(pm); return 1; }
    if (!strcmp(args, "new")) { cmd_new_bank(pm); return 1; }
    if (!strcmp(args, "delete")) { cmd_delete_bank(pm); return 1; }
    if (!strcmp(args, "import")) { cmd_import(pm); return 1; }
    if (!strcmp(args, "export")) { cmd_export(pm); return 1; }
    if (!strcmp(args, "inc") || !strcmp(args, "dec")) {                 /* rva 0x32F100, 0x334E20 */
        pm->cur[0] = clampi(pm->cur[0] + (args[0] == 'i' ? 1 : -1), 0, pm->nbank - 1);
        return 1;
    }
    if (!strcmp(args, "incSub") || !strcmp(args, "decSub")) {           /* the sub list's bank (no JUNO control shows it) */
        pm->cur[1] = clampi(pm->cur[1] + (args[0] == 'i' ? 1 : -1), 0, pm->nbank - 1);
        return 1;
    }
    return 0;
}
int juno_pm_func(juno_pm *pm, const char *fn, const char *args)
{
    int r;
    if (!pm || !fn || !args) return 0;
    if (!strcmp(fn, "ManagePatch")) {
        r = func_patch(pm, args);
        tail(pm, 0);
        return r;
    }
    if (!strcmp(fn, "ManagePatchBank")) {
        r = func_bank(pm, args);
        tail(pm, !strcmp(args, "incSub") || !strcmp(args, "decSub"));
        return r;
    }
    return 0;
}

/* ------------------------------------------------------------------ create, attach, reads */
juno_pm *juno_pm_create(void *ctx, const juno_pm_io *io, const char *data_dir, const char *patch_dir,
                        const char *old_dir, const char *script_dir)
{
    juno_pm *pm = calloc(1, sizeof *pm);
    if (!pm) return NULL;
    pm->ctx = ctx;
    if (io) pm->io = *io;
    pm->dir[0] = sdup(data_dir); pm->dir[1] = sdup(patch_dir);
    pm->dir[2] = sdup(old_dir);  pm->dir[3] = sdup(script_dir);
    pm->src = pm->tgt = -1;
    pm->lastx = pm->lasty = (int)0x80000001;
    return pm;
}
void juno_pm_free(juno_pm *pm)
{
    int i;
    if (!pm) return;
    for (i = 0; i < pm->nbank; ++i) bank_clear(&pm->bank[i]);
    free(pm->bank);
    rec_unref(pm->clip); rec_unref(pm->init);
    for (i = 0; i < 4; ++i) free(pm->dir[i]);
    for (i = 0; i < pm->ninst; ++i) free(pm->inst[i]);
    free(pm->inst);
    free(pm->pref);
    free(pm);
}

/* InstalledBankNames.dat (rva 0x3326A0 read, 0x337CC0 write): one key per line, CRLF */
static void inst_add(juno_pm *pm, const char *key)
{
    char **n = realloc(pm->inst, (size_t)(pm->ninst + 1) * sizeof *n);
    if (!n) return;
    pm->inst = n;
    pm->inst[pm->ninst++] = sdup(key);
}
static int inst_has(const juno_pm *pm, const char *key)
{
    int i;
    for (i = 0; i < pm->ninst; ++i) if (!strcmp(pm->inst[i], key)) return 1;
    return 0;
}
static void inst_read(juno_pm *pm, const char *path)
{
    long len = 0, a = 0, i;
    unsigned char *f = pm->io.read ? pm->io.read(pm->io.u, path, &len) : NULL;
    if (!f) return;
    for (i = 0; i <= len; ++i)
        if (i == len || f[i] == '\n') {
            long e = i;
            char line[1024];
            if (e > a && f[e - 1] == '\r') --e;
            if (e - a < (long)sizeof line && (i < len || e > a)) {
                memcpy(line, f + a, (size_t)(e - a)); line[e - a] = 0;
                inst_add(pm, line);
            }
            a = i + 1;
        }
    free(f);
}
static void inst_write(juno_pm *pm, const char *path)
{
    long n = 0, k = 0;
    int i;
    unsigned char *f;
    for (i = 0; i < pm->ninst; ++i) n += (long)strlen(pm->inst[i]) + 2;
    f = malloc((size_t)n + 1);
    if (!f || !pm->io.write) { free(f); return; }
    for (i = 0; i < pm->ninst; ++i) {
        size_t l = strlen(pm->inst[i]);
        memcpy(f + k, pm->inst[i], l); k += (long)l;
        f[k++] = '\r'; f[k++] = '\n';
    }
    pm->io.write(pm->io.u, path, f, n);
    free(f);
}

/* the file paths of a folder's .bin files, appended to *list (rva 0x333BE0) */
static void list_bins(juno_pm *pm, const char *dir, char ***list, int *n, const char *prefix)
{
    char **names, path[1024];
    int k = 0, i;
    if (!dir || !dir[0] || !pm->io.list) return;
    names = pm->io.list(pm->io.u, dir, &k);
    for (i = 0; i < k; ++i) {
        if (has_ext(names[i], ".bin")) {
            int add = 1;
            if (prefix) {                                     /* rva 0x334070: once per key */
                char key[600];
                snprintf(key, sizeof key, "%s%.*s", prefix, (int)strlen(names[i]) - 4, names[i]);
                if (inst_has(pm, key)) add = 0; else inst_add(pm, key);
            }
            if (add) {
                char **nl = realloc(*list, (size_t)(*n + 1) * sizeof *nl);
                if (nl) {
                    *list = nl;
                    snprintf(path, sizeof path, "%s/%s", dir, names[i]);
                    (*list)[(*n)++] = sdup(path);
                }
            }
        }
        free(names[i]);
    }
    free(names);
}
static int cmp_path(const void *a, const void *b)
{
    return strcmp(*(char *const *)a, *(char *const *)b);
}

/* the banks of the folders (rva 0x331D50): the data folder's .bin files; the Patch folder's and
 * the old folder's ("P/", "O/") each once (InstalledBankNames.dat, written back); all sorted by
 * path (bytes); each a bank named by its file (a name not among the banks', rva 0x334F20); none:
 * one "Initial" */
static void load_banks(juno_pm *pm)
{
    char **list = NULL, path[1024];
    int n = 0, i;
    for (i = 0; i < pm->nbank; ++i) bank_clear(&pm->bank[i]);
    pm->nbank = 0;
    for (i = 0; i < pm->ninst; ++i) free(pm->inst[i]);
    free(pm->inst); pm->inst = NULL; pm->ninst = 0;
    list_bins(pm, pm->dir[0], &list, &n, NULL);
    if (pm->dir[0] && pm->dir[0][0]) {
        snprintf(path, sizeof path, "%s/InstalledBankNames.dat", pm->dir[0]);
        inst_read(pm, path);
    }
    list_bins(pm, pm->dir[1], &list, &n, "P/");
    list_bins(pm, pm->dir[2], &list, &n, "O/");
    if (pm->dir[0] && pm->dir[0][0]) inst_write(pm, path);
    if (n > 1) qsort(list, (size_t)n, sizeof *list, cmp_path);
    for (i = 0; i < n; ++i) {
        long len = 0;
        unsigned char *f = pm->io.read ? pm->io.read(pm->io.u, list[i], &len) : NULL;
        pm_state *s = state_new(pm->init, "Initial");
        if (s && f && read_bank_file(f, len, s)) {
            const char *b = strrchr(list[i], '/');
            char nm[600], un[600];
            b = b ? b + 1 : list[i];
            snprintf(nm, sizeof nm, "%.*s", (int)strlen(b) - 4, b);
            if (unique_name(pm, nm, un, sizeof un, -1)) {
                free(s->name); s->name = sdup(un);
                bank_add(pm, s); s = NULL;
            }
        }
        state_free(s);
        free(f);
        free(list[i]);
    }
    free(list);
    if (!pm->nbank) bank_add(pm, state_new(pm->init, "Initial"));
}

/* the first attach (rva 0x32FD50): the init record = the view's image (Script/Initial.bin's first
 * record when it reads), the clipboard = the init record, the banks of the folders; the current
 * bank: the one named by the setting "PatchManager/BankName" (else 0); the selection 0 */
int juno_pm_attach(juno_pm *pm)
{
    char path[1024];
    long len = 0;
    unsigned char *f;
    int i;
    if (!pm) return 0;
    if (pm->ref++ > 0) return 1;
    pm->init = view_rec(pm);
    if (pm->dir[3] && pm->dir[3][0] && pm->io.read) {
        path_join(path, sizeof path, pm->dir[3], "Initial", ".bin");
        f = pm->io.read(pm->io.u, path, &len);
        if (f) {
            pm_state *s = state_new(pm->init, "");
            if (s && read_bank_file(f, len, s)) rec_set(&pm->init, s->rec[0]);
            state_free(s);
            free(f);
        }
    }
    rec_set(&pm->clip, pm->init);
    load_banks(pm);
    pm->cur[0] = pm->cur[1] = 0;
    for (i = 0; pm->pref && i < pm->nbank; ++i)
        if (!strcmp(cur_state(pm, i)->name, pm->pref)) { pm->cur[0] = pm->cur[1] = i; break; }
    pm->sel[0] = pm->sel[1] = 0;
    return 1;
}

/* IComponent::initialize's load (rva 0x320420 -> 0x338090: no push), then the model's commit */
void juno_pm_initialize(juno_pm *pm)
{
    if (!pm) return;
    cmd_load(pm, 0, -1);
    vcommit(pm);
}
/* the last detach (rva 0x32EEC0): the setting PatchManager/BankName = the current bank's name, then
 * save all */
void juno_pm_detach(juno_pm *pm)
{
    const pm_state *s;
    if (!pm) return;
    if (--pm->ref > 0) return;
    s = cur_state(pm, pm->cur[0]);
    free(pm->pref);
    pm->pref = sdup(s ? s->name : "");
    juno_pm_save_all(pm);
}
const char *juno_pm_pref(const juno_pm *pm) { return pm ? pm->pref : NULL; }
void juno_pm_set_pref(juno_pm *pm, const char *bank_name) { if (pm) { free(pm->pref); pm->pref = bank_name ? sdup(bank_name) : NULL; } }
void juno_pm_tick(juno_pm *pm)                             /* rva 0x32F280 */
{
    int old;
    if (!pm) return;
    old = pm->tick++;
    if (old > 6000) { juno_pm_save_all(pm); pm->tick = 0; }
}

int juno_pm_nbanks(const juno_pm *pm) { return pm ? pm->nbank : 0; }
int juno_pm_cur_bank(const juno_pm *pm) { return pm ? pm->cur[0] : 0; }
int juno_pm_cur(const juno_pm *pm, int sub) { return pm ? pm->cur[sub ? 1 : 0] : 0; }
int juno_pm_sel(const juno_pm *pm) { return pm ? pm->sel[0] : 0; }
int juno_pm_patch(const juno_pm *pm) { return pm ? vget((juno_pm *)pm, PATCH_VALUE) : 0; }
int juno_pm_value(const juno_pm *pm, unsigned int id)
{
    const int *w = pm ? wslot((juno_pm *)pm, id) : NULL;
    return w ? *w : 0;
}
/* the window opens (panelPatch from 0): the bank name control's show (rva 0x33F4F0 / 0x33F200) syncs
 * the bank and the selection from the view (rva 0x330E10); the list's show (rva 0x328330) registers
 * it (rva 0x3308C0): every bank keeps its current state alone, the history's cursor 0; the open
 * list's listener (rva 0x3285F0) sets patchManager and patchListMain to 0. The close changes nothing
 * more (the controls unregister). EXECUTED: patch_manager_gate opens the window before each command */
static void wopen(juno_pm *pm)
{
    int b, i;
    sync_view(pm);
    for (b = 0; b < pm->nbank && PM_TOOTH != 15; ++b) {
        pm_bank *k = &pm->bank[b];
        pm_state *c;
        if (k->n <= 1) { k->cur = 0; continue; }
        c = k->h[k->cur];
        for (i = 0; i < k->n; ++i) if (i != k->cur) state_free(k->h[i]);
        k->h[0] = c;
        k->n = 1;
        k->cur = 0;
    }
    pm->wv[JPM_ID_MANAGER - JPM_ID_PANEL] = 0;
    pm->wv[JPM_ID_LIST_MAIN - JPM_ID_PANEL] = 0;
}
void juno_pm_set_value(juno_pm *pm, unsigned int id, int v)
{
    int *w = pm ? wslot(pm, id) : NULL;
    if (!w) return;
    if (id == JPM_ID_PANEL && *w == 0 && v != 0) { *w = v; wopen(pm); return; }
    *w = v;
}
int juno_pm_format(void) { return g_format; }
const char *juno_pm_bank_name(const juno_pm *pm, int b)
{
    const pm_state *s = pm ? cur_state(pm, b) : NULL;
    return s ? s->name : NULL;
}
int juno_pm_patch_name(const juno_pm *pm, int b, int idx, char out[17])
{
    const pm_state *s = pm ? cur_state(pm, b) : NULL;
    if (!s || idx < 0 || idx >= JPM_NPATCH) return 0;
    rec_name(s->rec[idx]->b, out);
    return 1;
}
const unsigned char *juno_pm_body(const juno_pm *pm, int b, int idx)
{
    const pm_state *s = pm ? cur_state(pm, b) : NULL;
    return (s && idx >= 0 && idx < JPM_NPATCH) ? s->rec[idx]->b : NULL;
}
int juno_pm_hist(const juno_pm *pm, int b, int *cur)
{
    if (!pm || b < 0 || b >= pm->nbank) return 0;
    if (cur) *cur = pm->bank[b].cur;
    return pm->bank[b].n;
}
const unsigned char *juno_pm_clip(const juno_pm *pm) { return pm && pm->clip ? pm->clip->b : NULL; }

/* the list's number (rva 0x335640): format 0, 1, 2; any other value: none (the empty text) */
int juno_pm_number(int idx, char *out, int cap)
{
    switch (g_format) {
    case 0:  return snprintf(out, (size_t)cap, "%0*d", 2, idx + 1);
    case 1:  return snprintf(out, (size_t)cap, "%0*d-%d", 1, idx / 8 + 1, idx % 8 + 1);
    case 2:  return snprintf(out, (size_t)cap, "%c-%d", 'A' + idx / 8, idx % 8 + 1);
    default: if (cap > 0) out[0] = 0; return 0;
    }
}
int juno_pm_cell_text(const juno_pm *pm, int b, int idx, char *out, int cap)
{
    char num[24], nm[17];
    if (!juno_pm_patch_name(pm, b, idx, nm)) { if (cap > 0) out[0] = 0; return 0; }
    if (juno_pm_number(idx, num, sizeof num) > 0) return snprintf(out, (size_t)cap, "%s: %s", num, nm);
    return snprintf(out, (size_t)cap, "%s", nm);
}
/* the setting's text the plugin's way (rva 0x3E33F0): spaces skipped, one '-' noted and skipped,
 * then "%i" (decimal, 0x hex, 0 octal); no number: 0 */
void juno_pm_load_format(const char *pref)
{
    const char *p = pref;
    int v = 0, neg;
    if (!p) return;                                   /* absent: the default text is the value's own */
    while (*p && is_space((unsigned char)*p)) ++p;
    neg = *p == '-';
    if (neg) ++p;
    if (sscanf(p, "%i", &v) <= 0) { g_format = 0; return; }
    g_format = neg ? -v : v;
}

/* the gate's reads: state i of bank b's history */
int juno_pm_state_info(const juno_pm *pm, int b, int i, const char **name, int *view, const unsigned char **edit)
{
    const pm_state *s;
    if (!pm || b < 0 || b >= pm->nbank || i < 0 || i >= pm->bank[b].n) return 0;
    s = pm->bank[b].h[i];
    if (name) *name = s->name;
    if (view) *view = s->view;
    if (edit) *edit = s->edit->b;
    return 1;
}
const unsigned char *juno_pm_state_rec(const juno_pm *pm, int b, int i, int idx)
{
    if (!pm || b < 0 || b >= pm->nbank || i < 0 || i >= pm->bank[b].n || idx < 0 || idx >= JPM_NPATCH) return NULL;
    return pm->bank[b].h[i]->rec[idx]->b;
}
void juno_pm_view_values(const juno_pm *pm, int *bank, int *patch, int *tick)
{
    if (!pm) return;
    if (bank) *bank = vget((juno_pm *)pm, BANK_VALUE);
    if (patch) *patch = vget((juno_pm *)pm, PATCH_VALUE);
    if (tick) *tick = pm->tick;
}

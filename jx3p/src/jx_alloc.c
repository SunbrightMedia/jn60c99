/* jx_alloc.c -- the JX-3P NOTE MANAGER layer, transcribed bit-literal.
 *
 * Source of truth: the plugin's own machine code, read via
 * jx3p/tools/disasm.py (binary resolved through tools/verify/truth.py):
 *   NOTEON fan-out  0x3F9150   NOTEOFF fan-out 0x3F90F0   (9 units, +0x40)
 *   noteon body     0x3F5F90   noteoff body    0x3F5EF0 / list path 0x3F5800
 *   release-all-sustained 0x3F5790    all-release sweep 0x3F5C60
 *   int-list  {remove 0x3F6310, add-unique 0x3F63C0, contains 0x3F63F0,
 *              nonempty 0x3F6420}
 *   byte-map  {put-if-free 0x3F6570, has 0x3F6590, any 0x3F65A0,
 *              clear 0x3F64C0, take 0x3F64D0}
 *   setters   0x3F61C0 (+0xc pending), 0x3F61E0 (+0x9 sustain),
 *             0x3F6200 (+0x4), 0x3F6210 (+0xa), 0x3F6230 (+0x8)
 *
 * The unit state is kept as a RAW BYTE BLOB at the plugin's own offsets, so
 * the differential gate compares memory 1:1 against the oracle's object.
 * The two sinks (the objects at +0x518 and +0x520 in the plugin) are
 * CALLBACKS here -- they are the seam to the next layer down (the voice
 * choice), which is transcribed separately. Everything above the seam is
 * this file, and only this file.
 *
 * Transcription is LITERAL: each branch mirrors an instruction. Do not
 * "improve" the logic -- bit-exact or nothing (RULE 1 of the project).
 */
#include <stdint.h>
#include <string.h>

#define JXA_UNIT_SZ  0x7A8      /* through the history list at +0x5a8 */
#define JXA_UNITS    9

/* the seam: where accepted notes leave this layer */
typedef struct {
    void (*s518_on)(void *u, int unit, int note, int vel);   /* 0x3F5100 */
    void (*s518_off)(void *u, int unit, int note, int vel);  /* 0x3F0EF0 */
    void (*s520_on)(void *u, int unit, int note, int vel);   /* vtbl+0x18 */
    void (*s520_off)(void *u, int unit, int note, int vel);  /* vtbl+0x10 */
    void *user;
} jx_alloc_cbs;

/* ---- field accessors at the plugin's own offsets ---- */
#define B8(o)     (b[(o)])
#define BI(o)     (*(int32_t *)(b + (o)))
#define LIST_A    0x010     /* int count + 128 ints */
#define LIST_B    0x214
#define MAP_A     0x418     /* 128 bytes, 0xFF = free */
#define MAP_B     0x498
#define VEL_TAB   0x528     /* 128 bytes */
#define HIST      0x5A8     /* 128 ints, MRU at [0] */

/* int-list ops (count dword, then entries) */
static int  jxl_contains(uint8_t *b, int base, int32_t v)          /* 3F63F0 */
{
    int32_t n = *(int32_t *)(b + base), i;
    for (i = 0; i < n; ++i)
        if (*(int32_t *)(b + base + 4 + 4 * i) == v) return 1;
    return 0;
}
static void jxl_add(uint8_t *b, int base, int32_t v)               /* 3F63C0 */
{
    int32_t n = *(int32_t *)(b + base), i;
    for (i = 0; i < n; ++i)
        if (*(int32_t *)(b + base + 4 + 4 * i) == v) return;
    *(int32_t *)(b + base + 4 + 4 * n) = v;
    *(int32_t *)(b + base) += 1;
}
static void jxl_remove(uint8_t *b, int base, int32_t v)            /* 3F6310 */
{
    int32_t n = *(int32_t *)(b + base), i;
    for (i = 0; i < n; ++i)
        if (*(int32_t *)(b + base + 4 + 4 * i) == v) {
            int32_t j;
            *(int32_t *)(b + base) = n - 1;
            for (j = i; j < n - 1; ++j)
                *(int32_t *)(b + base + 4 + 4 * j) =
                    *(int32_t *)(b + base + 4 + 4 * (j + 1));
            return;
        }
}
static int  jxl_nonempty(uint8_t *b, int base)                     /* 3F6420 */
{ return *(int32_t *)(b + base) > 0; }

/* byte-map ops (128 bytes, 0xFF = empty) */
static int  jxm_put(uint8_t *b, int base, int32_t k, uint8_t v)    /* 3F6570 */
{ if (b[base + k] != 0xFF) return 0; b[base + k] = v; return 1; }
static int  jxm_has(uint8_t *b, int base, int32_t k)               /* 3F6590 */
{ return b[base + k] != 0xFF; }
static int  jxm_any(uint8_t *b, int base)                          /* 3F65A0 */
{ int i; for (i = 0; i < 0x80; ++i) if (b[base + i] != 0xFF) return 1;
  return 0; }
static void jxm_clr(uint8_t *b, int base, int32_t k)               /* 3F64C0 */
{ b[base + k] = 0xFF; }
static int  jxm_take(uint8_t *b, int base, int32_t k, int32_t *out)/* 3F64D0 */
{ uint8_t v = b[base + k]; if (v == 0xFF) return 0;
  *out = v; b[base + k] = 0xFF; return 1; }

/* 0x3F5790: release every sustain-held note through the +0x518 sink */
static void jx_rel_sus(uint8_t *b, const jx_alloc_cbs *cb, int unit)
{
    int n;
    for (n = 0; n < 0x80; ++n)
        if (jxl_contains(b, LIST_B, n)) {
            cb->s518_off(cb->user, unit, n, 0x40);
            jxl_remove(b, LIST_B, n);
        }
}

/* 0x3F5C60: sweep MAP_B released, flavor by mode (the byte at +8) */
static void jx_sweep_mapb(uint8_t *b, const jx_alloc_cbs *cb, int unit,
                          int mode)
{
    int i;
    if (mode == 1) {                       /* descending 127..0 */
        for (i = 0x80; i >= 1; --i)
            if (jxm_has(b, MAP_B, i - 1)) {
                cb->s520_off(cb->user, unit, i - 1, 0x40);
                jxm_clr(b, MAP_B, i - 1);
            }
    } else if (mode == 2) {                /* ascending 0..127 */
        for (i = 0; i <= 0x7F; ++i)
            if (jxm_has(b, MAP_B, i)) {
                cb->s520_off(cb->user, unit, i, 0x40);
                jxm_clr(b, MAP_B, i);
            }
    } else {                               /* history order, newest first */
        /* LITERAL: the index is the FULL stored dword (an empty entry is
         * -1 and aliases one byte below MAP_B -- the plugin's own quirk,
         * reproduced by the shared blob layout). The sink argument is the
         * LOW BYTE only (movzx dl, byte [rdi]). */
        for (i = 0x7F; i >= 0; --i) {
            int32_t h = *(int32_t *)(b + HIST + 4 * i);
            if (jxm_has(b, MAP_B, h)) {
                cb->s520_off(cb->user, unit, (uint8_t)h, 0x40);
                jxm_clr(b, MAP_B, h);
            }
        }
    }
}

/* the pending +0xc -> +0x8 commit at the top of the noteon body */
static void jx_commit_pending(uint8_t *b)
{
    if (B8(0xB)) {
        uint8_t m = B8(0xC), c = B8(8);
        if ((uint8_t)(m - 1) <= 1) { if (c != 1) b[8] = 1; }
        else                       { if (c != 0) b[8] = 0; }
        b[0xB] = 0;
    }
}

/* history MRU update at the tail of the noteon body (0x3F615E..) */
static void jx_hist_push(uint8_t *b, int32_t note)
{
    int i;
    for (i = 0; i < 0x80; ++i) {
        int32_t h = *(int32_t *)(b + HIST + 4 * i);
        if (h == note || h == -1) {
            int j;
            for (j = i; j >= 1; --j)
                *(int32_t *)(b + HIST + 4 * j) =
                    *(int32_t *)(b + HIST + 4 * (j - 1));
            *(int32_t *)(b + HIST) = note;
            return;
        }
    }
    /* full and absent: the plugin falls off the scan loop and RETURNS
     * without inserting (0x3F617D) */
}

/* 0x3F5F90 -- one unit's note-on */
static void jx_unit_note_on(uint8_t *b, const jx_alloc_cbs *cb, int unit,
                            int note, int vel)
{
    int32_t n;
    jx_commit_pending(b);
    n = (int32_t)(int8_t)B8(7) + note;
    if ((int8_t)n < 0) return;      /* js 0x3F61B4: NO history store */
    if (B8(4)) {                                   /* list path */
        if (B8(9) && !jxl_nonempty(b, LIST_A))
            jx_rel_sus(b, cb, unit);
        if (!jxl_contains(b, LIST_A, n)) {
            jxl_add(b, LIST_A, n);
            if (!jxl_contains(b, LIST_B, n))
                cb->s518_on(cb->user, unit, n, vel);
            jxl_remove(b, LIST_B, n);
        }
    } else {                                       /* map path */
        int32_t sn = n;
        if (B8(0xA) && !jxm_any(b, MAP_A)) {
            int i;    /* history sweep 0x3F6090 -- full-dword index, see
                       * the LITERAL note in jx_sweep_mapb */
            for (i = 0x7F; i >= 0; --i) {
                int32_t h = *(int32_t *)(b + HIST + 4 * i);
                if (jxm_has(b, MAP_B, h)) {
                    cb->s520_off(cb->user, unit, (uint8_t)h, 0x40);
                    jxm_clr(b, MAP_B, h);
                }
            }
        }
        jxm_put(b, MAP_A, sn, (uint8_t)sn);        /* value IS the note */
        if (B8(0xA) && jxm_has(b, MAP_B, sn))
            jxm_take(b, MAP_B, sn, &sn);           /* sn := stored value */
        if (!jxm_has(b, MAP_B, sn))
            cb->s520_on(cb->user, unit, (uint8_t)sn, vel);
    }
    b[VEL_TAB + n] = (uint8_t)vel;                 /* 0x3F6154 */
    jx_hist_push(b, note);                         /* keyed on the RAW note */
}

/* 0x3F5800 -- list-path note-off */
static void jx_unit_off_list(uint8_t *b, const jx_alloc_cbs *cb, int unit,
                             int32_t n, int vel)
{
    if (jxl_contains(b, LIST_A, n)) {
        jxl_remove(b, LIST_A, n);
#if JX_ALLOC_TOOTH
        /* the tooth: sustain is ignored -- the gate MUST catch this */
        cb->s518_off(cb->user, unit, n, vel);
#else
        if (B8(9)) jxl_add(b, LIST_B, n);
        else       cb->s518_off(cb->user, unit, n, vel);
#endif
    }
}

/* 0x3F5EF0 -- one unit's note-off */
static void jx_unit_note_off(uint8_t *b, const jx_alloc_cbs *cb, int unit,
                             int note, int vel)
{
    int32_t n = (int32_t)(int8_t)B8(7) + note;
    if (B8(4)) { jx_unit_off_list(b, cb, unit, n, vel); return; }
    {
        int32_t sn = n;
        jxm_take(b, MAP_A, n, &sn);
        if (B8(0xA)) jxm_put(b, MAP_B, sn, (uint8_t)sn);
        if (!jxm_has(b, MAP_B, sn))
            cb->s520_off(cb->user, unit, (uint8_t)sn, vel);
    }
}

/* ---- the 9-unit fan-outs (0x3F9150 / 0x3F90F0) and setters ---- */

typedef struct { uint8_t u[JXA_UNITS][JXA_UNIT_SZ]; } jx_alloc;

void jx_alloc_note_on(jx_alloc *a, const jx_alloc_cbs *cb, int note, int vel)
{
    int i;
    for (i = 0; i < JXA_UNITS; ++i)
        jx_unit_note_on(a->u[i], cb, i, (uint8_t)note, (uint8_t)vel);
}
void jx_alloc_note_off(jx_alloc *a, const jx_alloc_cbs *cb, int note, int vel)
{
    int i;
    for (i = 0; i < JXA_UNITS; ++i)
        jx_unit_note_off(a->u[i], cb, i, (uint8_t)note, (uint8_t)vel);
}

/* setters, one unit each (the plugin routes these per unit) */
void jx_alloc_set_pending_mode(jx_alloc *a, int unit, int m)   /* 3F61C0 */
{
    uint8_t *b = a->u[unit];
    if (B8(0xC) <= 2 && (int32_t)(int8_t)B8(0xC) != m) {
        b[0xC] = (uint8_t)m; b[0xB] = 1;
    }
}
void jx_alloc_set_sustain(jx_alloc *a, const jx_alloc_cbs *cb, int unit,
                          int d)                               /* 3F61E0 */
{
    uint8_t *b = a->u[unit];
    if ((uint8_t)d != B8(9)) {
        b[9] = (uint8_t)d;
        if (!d) jx_rel_sus(b, cb, unit);
    }
}
void jx_alloc_set_poly(jx_alloc *a, int unit, int d)           /* 3F6200 */
{
    uint8_t *b = a->u[unit];
    if ((uint8_t)d != B8(4)) b[4] = (uint8_t)d;
}
void jx_alloc_set_hold(jx_alloc *a, const jx_alloc_cbs *cb, int unit, int d)
{                                                              /* 3F6210 */
    uint8_t *b = a->u[unit];
    if ((uint8_t)d != B8(0xA)) {
        b[0xA] = (uint8_t)d;
        if (!d) jx_sweep_mapb(b, cb, unit, (int32_t)(int8_t)B8(8));
    }
}
void jx_alloc_set_mode8(jx_alloc *a, int unit, int d)          /* 3F6230 */
{
    uint8_t *b = a->u[unit];
    if (d != (int32_t)(int8_t)B8(8) && (uint32_t)d <= 2) b[8] = (uint8_t)d;
}

/* raw state access for the differential gate */
void *jx_alloc_unit_blob(jx_alloc *a, int unit) { return a->u[unit]; }
int   jx_alloc_unit_size(void)                  { return JXA_UNIT_SZ; }

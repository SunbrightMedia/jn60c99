/* jx_ktrack.c -- the JX-3P KEY TRACKER object, transcribed bit-literal.
 *
 * Source of truth: the plugin's own machine code, read via
 * jx3p/tools/disasm.py (binary resolved through tools/verify/truth.py):
 *   note-on wrapper   0x357BC0  (bitmap bit set/clear + mode dispatch)
 *   note-off wrapper  0x357B20  (bitmap bit clear + mode dispatch)
 *   entry A (dispatch on wt + mode 3)      0x355A60
 *   mode-1 engine (mono, voice 0)          0x355AE0
 *   mode-2 entry / engine (unison)         0x355D00 / 0x355D60
 *   poly engine                            0x355340
 *   mode-3-with-wt engine (chord regroup)  0x355700
 *   helpers: voice write  0x357A00, note-only write 0x357860,
 *            masked gate-off sweep 0x357570, masked note sweep 0x3577A0
 *
 * The object is a RAW BYTE BLOB at the plugin's own offsets so a
 * differential gate can compare memory 1:1 against the oracle.
 *
 * FIELD MAP (inferred, READ(static)):
 *   +0x08  int   voice count (<= 8)
 *   +0x0C  int   all-voices bit mask
 *   +0x10  int   mode (1 = mono, 2 = unison, else A; 3 special when wt)
 *   +0x14  int   flag: enables the 0x1D3 group-gate block in 355340
 *   +0x18  int   flag: "mark instead of release" (sustain-ish) in off paths
 *   +0x20  int   bit accumulator (|=/&=~ mask 0x0C in 355340)
 *   +0x24  int[8]  per-voice timestamp (from get70), 355700 only
 *   +0x44  int   retrigger mask (355340)
 *   +0x50  u32[4] 128-bit held-note bitmap (bit = note&0x1F of dword note>>5)
 *   +0x60+4i u8  per-voice note (signed byte)
 *   +0x61+4i u8  per-voice gate
 *   +0x62+4i u8  per-voice released/marked flag
 *   +0x7C  ...  = order array entry [-1] (aliases voice-7 record; the
 *                plugin's own shift loops read arr[j-1] through +0x7C)
 *   +0x80  int[8] voice order array (MRU at [0])
 *   +0xA0  int   order array count-ish index (arr[BI(0xA0)] read via +0x7C)
 *   +0xA4  int   param-post mode: {0,1,3,4} -> bank A, 2 -> bank B (+4),
 *                <0 or >4 -> no parameter posts
 *
 * SEAM: virtual calls through [vtbl+0x48] (parameter SET post) and
 * [vtbl+0x50] (GET) are callbacks.  DEVIATION from the requested struct,
 * forced by the machine code: every [vtbl+0x48] site loads THREE argument
 * registers -- edx (always 2 here), r8d (param id), r9d (the value being
 * posted: note/gate/flag).  A two-argument set48 would drop r9d, so set48
 * carries all three.  Additionally 0x355700 calls [vtbl+0x70]() -> eax
 * (a clock read); it is modeled as get70.
 *
 * Transcription is LITERAL: each branch mirrors an instruction. Do not
 * "improve" the logic -- bit-exact or nothing (RULE 1 of the project).
 */
#include <stdint.h>
#include <string.h>

#define JXK_UNIT_SZ 0xB0   /* highest touched byte 0xA7 (+0xA4 dword), to 16 */

typedef struct {
    /* [vtbl+0x48](obj, edx=what, r8d=param_id, r9d=val) -- SET post.
     * what is 2 at every site in this file. */
    void (*set48)(void *u, int what, int param_id, int val);
    /* [vtbl+0x50](obj, edx=4, r8d=param_id, r9=&out_dword) -- GET; ret al */
    int  (*get50)(void *u, int what, int param_id, int32_t *out);
    /* [vtbl+0x70](obj) -> eax -- clock/tick read (0x355835) */
    uint32_t (*get70)(void *u);
    void *user;
} jx_ktrack_cbs;

#define B8(o)  (b[(o)])
#define BI(o)  (*(int32_t *)(b + (o)))

/* the +0xA4 dispatch that guards every parameter post (pattern at e.g.
 * 0x3575AF): returns -1 = no post, 0 = bank A, 4 = bank B */
static int jxk_bank(uint8_t *b)
{
    int32_t a4 = BI(0xA4);
    if (a4 < 0) return -1;                       /* js  */
    if (a4 <= 1) return 0;                       /* jle */
    if (a4 == 2) return 4;                       /* je  */
    if ((uint32_t)(a4 - 3) <= 1) return 0;       /* ja skips; 3,4 fall in */
    return -1;
}

/* 0x350 bitmap scan: lowest set bit of the 4 dwords at +0x50, -1 if none
 * (pattern at 0x355BF7 / 0x355C91 / 0x355FC7 / 0x35605E) */
static int jxk_lowbit(uint8_t *b)
{
    int d, bit;
    for (d = 0; d < 4; ++d) {
        uint32_t w = *(uint32_t *)(b + 0x50 + 4 * d);
        if (w == 0) continue;
        for (bit = 0; bit < 32; ++bit)           /* bt; jb */
            if (w & (1u << bit)) return (d << 5) + bit;
    }
    return -1;
}

/* 0x357570 -- masked gate-off sweep: for each set mask bit i, post gate 0
 * if the voice was gated, then clear the gate byte */
static void jxk_357570(uint8_t *b, const jx_ktrack_cbs *cb, uint32_t mask)
{
    int i = 0;
    if (BI(8) <= 0) return;
    for (;;) {
        uint32_t m0 = mask;                      /* r14d, pre-shift */
        if (mask & 1) {
            if (B8(0x61 + 4 * i) != 0) {
                int bk = jxk_bank(b);
                if (bk >= 0)
                    cb->set48(cb->user, 2, 0x1C2 + bk + i, 0);
            }
            b[0x61 + 4 * i] = 0;
        }
        mask >>= 1;                              /* shr ebp,1 */
        if (m0 < 2) break;                       /* cmp r14d,2; jb */
        ++i;
        if (i >= BI(8)) break;
    }
}

/* 0x3577A0 -- masked note sweep: for each set mask bit i, post the note if
 * it changed, then store note and clear the released flag */
static void jxk_3577A0(uint8_t *b, const jx_ktrack_cbs *cb, uint32_t mask,
                       int note)
{
    int i = 0;
    if (BI(8) <= 0) return;
    for (;;) {
        uint32_t m0 = mask;
        if (mask & 1) {
            int bk = jxk_bank(b);
            if (bk >= 0 &&
                (int32_t)(int8_t)B8(0x60 + 4 * i) != note)   /* movsx */
                cb->set48(cb->user, 2, i + 0x1B1 + bk, note);
            b[0x60 + 4 * i] = (uint8_t)note;
            b[0x62 + 4 * i] = 0;
        }
        mask >>= 1;
        if (m0 < 2) break;
        ++i;
        if (i >= BI(8)) break;
    }
}

/* 0x357860 -- single-voice note write: post if changed, store note, clear
 * the released flag (gate byte untouched) */
static void jxk_357860(uint8_t *b, const jx_ktrack_cbs *cb, int v, int note)
{
    int bk = jxk_bank(b);
    if (bk >= 0 &&
        (int32_t)(int8_t)B8(0x60 + 4 * v) != note)           /* movsx */
        cb->set48(cb->user, 2, v + 0x1B1 + bk, note);
    b[0x60 + 4 * v] = (uint8_t)note;
    b[0x62 + 4 * v] = 0;
}

/* 0x357A00 -- single-voice note+gate write: post each if changed (gate is
 * also re-posted when the stored gate is 0), then store note, gate, 0 */
static void jxk_357A00(uint8_t *b, const jx_ktrack_cbs *cb, int v, int note,
                       int gate)
{
    int bk = jxk_bank(b);
    if (bk >= 0) {
        if ((int32_t)(int8_t)B8(0x60 + 4 * v) != note)       /* movsx */
            cb->set48(cb->user, 2, v + 0x1B1 + bk, note);
        {
            uint8_t cur = B8(0x61 + 4 * v);                  /* movzx */
            /* jne -> post; equal but zero -> post; equal nonzero -> skip */
            if ((int)cur != gate || cur == 0)
                cb->set48(cb->user, 2, v + 0x1C2 + bk, gate);
        }
    }
    b[0x60 + 4 * v] = (uint8_t)note;
    b[0x61 + 4 * v] = (uint8_t)gate;
    b[0x62 + 4 * v] = 0;
}

/* order-array normalize at 0x355B53 / 0x355EC7: find a zero entry scanning
 * arr[n-1..1]; shift arr[1..c] down and put 0 at arr[0].  arr[0] itself is
 * never examined (the plugin's own loop shape). */
static void jxk_order_zero_front(uint8_t *b)
{
    int32_t n = BI(0xA0) - 1;
    intptr_t c = (intptr_t)n;                    /* movsxd */
    if (n <= 0) return;
    while (c > 0) {                              /* checks c = n..1 */
        if (BI(0x80 + 4 * c) == 0) {
            intptr_t j;
            for (j = c; j >= 1; --j)             /* arr[j] = arr[j-1] */
                BI(0x80 + 4 * j) = BI(0x7C + 4 * j);
            BI(0x80) = 0;
            return;
        }
        --c;
    }
}

/* order-array move-to-front of voice v at 0x3555D5 / 0x355929: scan
 * arr[n-1..1] for v; shift down, arr[0] = v.  arr[0] never examined. */
static void jxk_order_mtf(uint8_t *b, int32_t v)
{
    int32_t n = BI(0xA0) - 1;
    intptr_t c = (intptr_t)n;
    if (n <= 0) return;
    while (c > 0) {
        if (BI(0x80 + 4 * c) == v) {
            intptr_t j;
            for (j = c; j >= 1; --j)
                BI(0x80 + 4 * j) = BI(0x7C + 4 * j);
            BI(0x80) = v;
            return;
        }
        --c;
    }
}

/* shared note-off body of 0x355340 (0x35563C) and 0x355700 (0x3559B7) --
 * byte-identical logic in both engines */
static void jxk_off_common(uint8_t *b, const jx_ktrack_cbs *cb, uint8_t note)
{
    int i;
    if (BI(0x18) != 0) {
        /* mark matching gated voices released */
        for (i = 0; i < BI(8); ++i)
            if (B8(0x61 + 4 * i) != 0 &&
                (int32_t)(int8_t)B8(0x60 + 4 * i) == (int32_t)note)
                b[0x62 + 4 * i] = 1;
        return;
    }
    {
        uint32_t m = 0;                          /* r8, bts per voice */
        if (BI(8) <= 0) return;
        for (i = 0; i < BI(8); ++i) {
            if (B8(0x61 + 4 * i) != 0 &&
                (int32_t)(int8_t)B8(0x60 + 4 * i) == (int32_t)note) {
                m |= 1u << i;                    /* bts r8d, edi */
                b[0x62 + 4 * i] = 0;
            }
        }
        if ((uint8_t)m != 0)                     /* test r8b; movzx edx,r8b */
            jxk_357570(b, cb, (uint32_t)(uint8_t)m);
    }
}

/* 0x355AE0 -- mode-1 engine (mono on voice 0) */
static void jxk_355AE0(uint8_t *b, const jx_ktrack_cbs *cb, uint8_t note,
                       uint8_t onv)
{
    if (onv != 0) {
        if (B8(0x61) == 0 || B8(0x62) == 1) {
            int bk = jxk_bank(b);
            if (bk >= 0)
                cb->set48(cb->user, 2, 0x1C2 + bk, 0);
            b[0x61] = 0;
        }
        jxk_357A00(b, cb, 0, (int32_t)note, (int32_t)onv);
        jxk_order_zero_front(b);
        jxk_357570(b, cb, 0xFFFFFFFEu);          /* mov edx,-2 */
        return;
    }
    /* note-off */
    if ((int32_t)(int8_t)B8(0x60) != (int32_t)note)          /* movsx */
        return;
    if (BI(0x18) != 0) {
        int32_t n = BI(8);
        int c, other = 0;
        for (c = 0; c < n; ++c)                  /* c==0 gate not tested */
            if (c != 0 && B8(0x61 + 4 * c) != 0) { other = 1; break; }
        if (other) {
            for (c = 0; c < BI(8); ++c)
                if (B8(0x61 + 4 * c) != 0 &&
                    (int32_t)(int8_t)B8(0x60 + 4 * c) == (int32_t)note)
                    b[0x62 + 4 * c] = 1;
            return;
        }
        {
            int idx = jxk_lowbit(b);
            if (idx == -1) {                     /* 0x355C28 */
                b[0x62] = 1;
                jxk_357570(b, cb, 0xFFFFFFFEu);
                return;
            }
            jxk_357860(b, cb, 0, idx);           /* 0x355C80 */
            jxk_357570(b, cb, 0xFFFFFFFEu);
            return;
        }
    }
    {
        int idx = jxk_lowbit(b);                 /* 0x355C91 */
        if (idx == -1) {                         /* 0x355CB8 */
            jxk_357570(b, cb, (uint32_t)BI(0xC));
            return;
        }
        jxk_357860(b, cb, 0, idx);               /* 0x355CE0 */
        jxk_357570(b, cb, 0xFFFFFFFEu);
    }
}

/* 0x355D60 -- mode-2 engine (unison over the +0xC mask) */
static void jxk_355D60(uint8_t *b, const jx_ktrack_cbs *cb, uint8_t note,
                       uint8_t onv)
{
    if (onv != 0) {
        if (B8(0x61) == 0 || B8(0x62) == 1) {
            /* masked gate-off sweep, NO stored-gate precheck (0x355DB4) */
            if (BI(8) > 0) {
                uint32_t mask = (uint32_t)BI(0xC);
                int i = 0;
                for (;;) {
                    uint32_t m0 = mask;
                    if (mask & 1) {
                        int bk = jxk_bank(b);
                        if (bk >= 0)
                            cb->set48(cb->user, 2, 0x1C2 + bk + i, 0);
                        b[0x61 + 4 * i] = 0;
                    }
                    mask >>= 1;
                    if (m0 < 2) break;
                    ++i;
                    if (i >= BI(8)) break;
                }
            }
        }
        /* masked note+gate write, inline 357A00 per voice (0x355E19);
         * store order here is 0x61, 0x60, 0x62 (0x355E9B) */
        if (BI(8) > 0) {
            uint32_t mask = (uint32_t)BI(0xC);
            int i = 0;
            for (;;) {
                uint32_t m0 = mask;
                if (mask & 1) {
                    int bk = jxk_bank(b);
                    if (bk >= 0) {
                        if ((int32_t)(int8_t)B8(0x60 + 4 * i) !=
                            (int32_t)note)
                            cb->set48(cb->user, 2, i + 0x1B1 + bk,
                                      (int32_t)note);
                        {
                            uint8_t cur = B8(0x61 + 4 * i);
                            if ((int32_t)cur != (int32_t)onv || cur == 0)
                                cb->set48(cb->user, 2, i + 0x1C2 + bk,
                                          (int32_t)onv);
                        }
                    }
                    b[0x61 + 4 * i] = onv;
                    b[0x60 + 4 * i] = note;
                    b[0x62 + 4 * i] = 0;
                }
                mask >>= 1;
                if (m0 < 2) break;
                ++i;
                if (i >= BI(8)) break;
            }
        }
        jxk_order_zero_front(b);                 /* 0x355EC7 */
        return;
    }
    /* note-off (0x355F87) */
    if ((int32_t)(int8_t)B8(0x60) != (int32_t)note)
        return;
    if (BI(0x18) != 0) {
        int32_t n = BI(8);
        int c, other = 0;
        for (c = 0; c < n; ++c)                  /* c==0 gate not tested */
            if (c != 0 && B8(0x61 + 4 * c) != 0) { other = 1; break; }
        if (other) {                             /* 0x356006 */
            for (c = 0; c < BI(8); ++c)
                if (B8(0x61 + 4 * c) != 0 &&
                    (int32_t)(int8_t)B8(0x60 + 4 * c) == (int32_t)note)
                    b[0x62 + 4 * c] = 1;
            return;
        }
        {
            int idx = jxk_lowbit(b);
            if (idx == -1) {                     /* 0x355FF8 */
                b[0x62] = 1;
                return;
            }
            jxk_3577A0(b, cb, (uint32_t)BI(0xC), idx);   /* 0x35604A */
            return;
        }
    }
    {
        int idx = jxk_lowbit(b);                 /* 0x35605E */
        if (idx != -1) {
            jxk_3577A0(b, cb, (uint32_t)BI(0xC), idx);
            return;
        }
        jxk_357570(b, cb, (uint32_t)BI(0xC));    /* 0x35609A */
    }
}

/* 0x355340 -- poly engine (entered from 0x355A60 when mode != 3) */
static void jxk_355340(uint8_t *b, const jx_ktrack_cbs *cb, uint8_t note,
                       uint8_t onv, uint8_t wt)
{
    int32_t nv = BI(8);
    if (onv == 0) { jxk_off_common(b, cb, note); return; }

    {
        int32_t sel;                             /* r14d */
        int have = 0;
        if (nv - 1 >= 0) {
            int32_t r14 = -1, r10 = -1, r11 = -1, cN = -1;
            intptr_t di;
            for (di = (intptr_t)nv - 1; di >= 0; --di) {
                int32_t v = BI(0x80 + 4 * di);   /* movsxd */
                int32_t c = v;
                if ((int32_t)(int8_t)B8(0x60 + 4 * v) != (int32_t)note)
                    c = r14;                     /* cmovne */
                r14 = c;
                if (r10 == -1 && B8(0x61 + 4 * v) == 0) r10 = v;
                if (r11 == -1 && B8(0x62 + 4 * v) == 1) r11 = v;
                cN = c;
            }
            if (cN != -1)        { sel = r14; have = 1; }
            else if (r10 != cN)  { sel = r10; have = 1; }
            else if (r11 != cN)  { sel = r11; have = 1; }
            else                 { sel = 0; }    /* falls to steal */
        } else sel = 0;
        if (!have) {                             /* 0x3553F4 steal */
            if (wt == 0)
                sel = BI(0x7C + 4 * (intptr_t)BI(0xA0));  /* arr[cnt-1] */
            else
                sel = BI(0x80);                  /* arr[0] */
        }

        if (BI(0x14) != 0 && wt == 1) {          /* 0x35540E */
            int all_zero = 1;
            {
                int c;
                for (c = 0; c < nv; ++c)
                    if (B8(0x61 + 4 * c) != 0) { all_zero = 0; break; }
            }
            {
                int32_t mset = BI(0xC);          /* r12d */
                uint32_t mask = (uint32_t)mset;  /* ebp */
                if (all_zero) {
                    if (nv > 0) {
                        int p = 0x1D3;           /* esi */
                        for (;;) {
                            uint32_t m0 = mask;
                            if (mask & 1) {
                                int bk = jxk_bank(b);
                                if (bk >= 0)
                                    cb->set48(cb->user, 2, p + bk, 1);
                            }
                            mask >>= 1;
                            if (m0 < 2) {        /* 0x3554C8 */
                                BI(0x20) |= mset;
                                break;
                            }
                            ++p;
                            if (p - 0x1D3 >= BI(8)) break;
                        }
                    }
                    BI(0x44) = BI(0xC);          /* both exits store 0x44 */
                } else {
                    if (nv > 0) {
                        int p = 0x1D3;
                        for (;;) {
                            uint32_t m0 = mask;
                            if (mask & 1) {
                                int bk = jxk_bank(b);
                                if (bk >= 0)
                                    cb->set48(cb->user, 2, p + bk, 0);
                            }
                            mask >>= 1;
                            if (m0 < 2) {        /* 0x355535 */
                                BI(0x20) &= ~mset;
                                break;
                            }
                            ++p;
                            if (p - 0x1D3 >= BI(8)) break;
                        }
                    }
                    /* NOTE: no +0x44 store on this branch (0x35552D) */
                }
            }
            {                                    /* 0x35553C retrigger */
                int di;
                for (di = 0; di < BI(8); ++di)
                    if (di != sel && ((BI(0x44) >> di) & 1))
                        jxk_357860(b, cb, di, (int32_t)note);
            }
        }

        /* 0x355569 -- the selected voice */
        if (B8(0x61 + 4 * sel) != 0) {
            int bk = jxk_bank(b);
            if (bk >= 0)
                cb->set48(cb->user, 2, sel + 0x1C2 + bk, 0);
        }
        b[0x61 + 4 * sel] = 0;                   /* before the write call */
        jxk_357A00(b, cb, sel, (int32_t)note, (int32_t)onv);
        BI(0x44) &= ~(1 << sel);                 /* shl/not/and */
        jxk_order_mtf(b, sel);                   /* 0x3555D5 */
    }
}

/* 0x355700 -- engine for mode 3 with wt (chord regroup by timestamp) */
static void jxk_355700(uint8_t *b, const jx_ktrack_cbs *cb, uint8_t note,
                       uint8_t onv, uint8_t wt)
{
    if (onv == 0) { jxk_off_common(b, cb, note); return; }

    {
        int32_t sel = 0;
        int found = 0;
        intptr_t n = (intptr_t)BI(8);            /* movsxd */
        uint32_t t;
        if (n > 0) {
            intptr_t c;
            for (c = 0; c < n; ++c) {
                if (B8(0x62 + 4 * c) == 1) {     /* released voice wins */
                    if (B8(0x61 + 4 * c) != 0) {
                        int bk = jxk_bank(b);
                        if (bk >= 0)
                            cb->set48(cb->user, 2, (int)c + 0x1C2 + bk, 0);
                    }
                    b[0x61 + 4 * c] = 0;
                    sel = (int32_t)c; found = 1; break;
                }
                if (B8(0x61 + 4 * c) == 0) {     /* free voice */
                    sel = (int32_t)c; found = 1; break;
                }
            }
        }
        if (!found) {                            /* 0x3557B2 steal */
            if (wt == 0)
                sel = BI(0x7C + 4 * (intptr_t)BI(0xA0));  /* arr[cnt-1] */
            else
                sel = BI(0x80);                  /* arr[0] */
        }

        /* 0x3557D3 */
        if (B8(0x61 + 4 * sel) != 0) {
            int bk = jxk_bank(b);
            if (bk >= 0)
                cb->set48(cb->user, 2, sel + 0x1C2 + bk, 0);
        }
        b[0x61 + 4 * sel] = 0;
        jxk_357A00(b, cb, sel, (int32_t)note, (int32_t)onv);

        t = cb->get70(cb->user);                 /* [vtbl+0x70] clock */
        BI(0x24 + 4 * (intptr_t)sel) = (int32_t)t;

        {
            int32_t buf[8];                      /* [rsp+0x20..0x3F] */
            int32_t cnt = 0;                     /* r9d */
            uint32_t selmask = 0;                /* ebp */
            uint32_t rolbit = 1;                 /* edx */
            int32_t nn = BI(8);
            intptr_t i;
            memset(buf, 0, sizeof buf);          /* four qword zero stores */
            for (i = 0; i < nn; ++i) {
                if (B8(0x61 + 4 * i) != 0) {
                    uint32_t d = t - (uint32_t)BI(0x24 + 4 * i);
                    if (d <= 0x64) {             /* cmp 0x64; ja skip */
                        buf[cnt++] = BI(0x60 + 4 * i);  /* packed record */
                        selmask |= rolbit;
                    }
                }
                rolbit = (rolbit << 1) | (rolbit >> 31);  /* rol edx,1 */
            }
            /* bubble sort ascending on the SIGNED low byte (the note),
             * swapping whole dwords (0x3558A1) */
            if (cnt > 0) {
                intptr_t r8 = 0, pass;
                for (pass = (intptr_t)cnt; pass > 0; --pass) {
                    intptr_t dx = (intptr_t)cnt - 1;
                    for (; dx > r8; --dx) {
                        if ((int8_t)(buf[dx - 1] & 0xFF) >
                            (int8_t)(buf[dx] & 0xFF)) {
                            int32_t a = buf[dx - 1];
                            buf[dx - 1] = buf[dx];
                            buf[dx] = a;
                        }
                    }
                    ++r8;
                }
            }
            /* redistribute (0x3558EC): sorted records back onto the
             * selected voices in voice order */
            if (nn > 0) {
                const int32_t *p = buf;          /* rsi */
                int32_t bx;
                for (bx = 0; bx < BI(8); ++bx) {
                    if ((selmask >> bx) & 1) {   /* bt ebp,ebx */
                        jxk_357A00(b, cb, bx,
                                   (int32_t)(int8_t)(*p & 0xFF),  /* movsx */
                                   (int32_t)(uint8_t)((*p >> 8) & 0xFF));
                        ++p;
                    }
                    if ((int32_t)(int8_t)B8(0x60 + 4 * bx) == (int32_t)note)
                        jxk_order_mtf(b, bx);    /* 0x355929 */
                }
            }
        }
    }
}

/* 0x355A60 -- entry A: query 0x31E through get50; wt = (out != 0); mode 3
 * goes to 0x355700, everything else to the poly engine 0x355340 */
static void jxk_355A60(uint8_t *b, const jx_ktrack_cbs *cb, uint8_t note,
                       uint8_t onv)
{
    int32_t out = 0;   /* asm leaves [rsp+0x30] uninitialized before get50 */
    if (!cb->get50(cb->user, 4, 0x31E, &out))
        return;
    {
        uint8_t wt = (out != 0);                 /* setne r9b */
        if (BI(0x10) == 3)
            jxk_355700(b, cb, note, onv, wt);
        else
            jxk_355340(b, cb, note, onv, wt);
    }
}

/* 0x355D00 -- mode-2 entry: get50(4, 0x31E) gates the engine; the fetched
 * dword itself is NOT used */
static void jxk_355D00(uint8_t *b, const jx_ktrack_cbs *cb, uint8_t note,
                       uint8_t onv)
{
    int32_t out = 0;
    if (cb->get50(cb->user, 4, 0x31E, &out))
        jxk_355D60(b, cb, note, onv);
}

/* 0x357BC0 from `mov ecx,[r9+0x10]` onward -- the mode dispatch.
 * The asm has one register (r8b) for on/velocity: engines treat nonzero as
 * on and post it as the gate value.  is_on must equal (vel & 0xFF) != 0. */
void jx_ktrack_dispatch(uint8_t *b, const jx_ktrack_cbs *cb, int note,
                        int vel, int is_on)
{
    (void)is_on;
    {
        int32_t m = BI(0x10);
        if (m == 1) { jxk_355AE0(b, cb, (uint8_t)note, (uint8_t)vel); return; }
        if (m == 2) { jxk_355D00(b, cb, (uint8_t)note, (uint8_t)vel); return; }
        jxk_355A60(b, cb, (uint8_t)note, (uint8_t)vel);
    }
}

/* 0x357BC0 -- note event in: set (vel nonzero) or clear the held-note
 * bitmap bit, then dispatch on mode */
void jx_ktrack_on(uint8_t *b, const jx_ktrack_cbs *cb, int note, int vel)
{
    uint32_t n7 = (uint32_t)(uint8_t)note;       /* movzx dl */
    uint32_t bit = 1u << (n7 & 0x1F);
    uint32_t *w = (uint32_t *)(b + 0x50 + 4 * (n7 >> 5));
    if ((uint8_t)vel != 0) *w |= bit;
    else                   *w &= ~bit;
    jx_ktrack_dispatch(b, cb, note, vel, (uint8_t)vel != 0);
}

/* 0x357B20 from `mov ecx,[rbx+0x10]` onward -- note-off dispatch (the
 * bitmap bit clear before that line belongs to the caller's wrapper).
 * Mode 2 does its own get50(4, 0x31E) gate inline (0x357B72). */
void jx_ktrack_off(uint8_t *b, const jx_ktrack_cbs *cb, int note)
{
    int32_t m = BI(0x10);
    if (m == 1) { jxk_355AE0(b, cb, (uint8_t)note, 0); return; }
    if (m == 2) {
        int32_t out = 0;
        if (cb->get50(cb->user, 4, 0x31E, &out))
            jxk_355D60(b, cb, (uint8_t)note, 0);
        return;
    }
    jxk_355A60(b, cb, (uint8_t)note, 0);
}

/* 0x357B20 complete: the bitmap clear, then the off dispatch above */
void jx_ktrack_off_full(uint8_t *b, const jx_ktrack_cbs *cb, int note)
{
    uint32_t n7 = (uint32_t)(uint8_t)note;
#if !JX_KTRACK_TOOTH
    /* the tooth build SKIPS the bitmap clear -- the gate MUST catch it */
    *(uint32_t *)(b + 0x50 + 4 * (n7 >> 5)) &= ~(1u << (n7 & 0x1F));
#endif
    jx_ktrack_off(b, cb, note);
}

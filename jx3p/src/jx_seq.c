/* jx_seq.c -- the JX-3P note store's STEP MACHINE and the engine's CLOCK TICK, transcribed bit-literal from
 * the plugin's machine code (2026-10-10; jx3p/docs/HOST_LAYER.md 3c).
 *
 * Source of truth (disasm via jx3p/tools/disasm.py, binary via truth.py):
 *   0x3F84A0  the engine's tick (vtable +0xB8; the render driver calls it 24 times per beat): per unit
 *             its note manager's counter += 1, the manager's tick, the note store's tick
 *   0x3F5910  the note manager's tick (plays its note lists again at a 12/24-tick boundary)
 *   0x3F56E0  the note manager's release of every listed note (then 0x3F4BC0: jmp 0x3EF910)
 *   0x3EF910  the note store's reset          0x3EF210  its release of the 16 playing columns
 *   0x3EFD10  the note store's tick: the state machine (+0x2C) and the step clock (+0x14 / +0x18)
 *   0x3F1650  load a step pattern (src +6: 0x22-byte rows) into the step table (+0x324)
 *   0x3EFBF0  clear the step table            0x3EF3B0  drop empty columns, sort columns by note
 *   0x3F1B10  each column's step times        0x3F1EA0 / 0x3F2120  play one step (queue / free-slot mode)
 *   0x3F5260 / 0x3F5240  the note store's vtable +0 / +8: note-on / note-off into the assigner at +0xFD8
 *   the step's note choice: the function at +0xD98, one of 19 (the mode setter 0x3F1910's table at
 *   0x3F1A50; any mode above 18 installs mode 12's), all transcribed; 9, 10 and 18 draw from the store's
 *   random numbers (0x3F2A90, the word at +8). A stored function outside the 19 stops the port loudly
 *   (the bad_hook callback). The factory bank holds modes 0, 3 and 6 (EXECUTED).
 *
 * The objects are RAW BYTE BLOBS at the plugin's own offsets (jx_alloc.c, jx_nstore.c). The note store's
 * pointer at +0x20 is kept as its OFFSET in the store (0 or 0xDA8: the store's own pattern, EXECUTED) -- or,
 * in the port's guest memory (jx_bridge.c, JX-11), as the plugin's own pointer, read through JXS_PTR;
 * +0xFD8 (the assigner) and the vtable are the callbacks below.
 *
 * Transcription is LITERAL: each branch mirrors an instruction. Do not "improve" the logic -- bit-exact
 * or nothing (RULE 1 of the project). Unrolled loops are written as loops where the stores are to
 * distinct cells (order-free); every quirk is kept (e.g. 0x3F5910's second loop reads list A with list
 * B's count; 0x3EF3B0's sort swaps a column's note byte and cells only).
 */
#include <stdint.h>
#include <string.h>

#define JXS_IB 0x180000000ULL           /* the image base the stored hook addresses carry */

typedef struct {
    void (*kt_on)(void *user, int unit, int note, int vel);    /* assigner vtable +0x18 (0x357BC0) */
    void (*kt_off)(void *user, int unit, int note, int vel);   /* assigner vtable +0x10 (0x357B20) */
    void (*bad_hook)(void *user, uint64_t hook);               /* a step-choice function not transcribed */
    void *user;
    int unit;
} jx_seq_cbs;

/* reach: how often the step machine chose and played (jx3p/tools/jx_tick_gate.py refuses a run without),
 * and how often each mode's step function ran (the gate prints the modes it graded) */
static unsigned long g_seq_hook_calls, g_seq_on, g_seq_off, g_seq_mode_calls[19];

#define S8(o)   (ns[(o)])
#define SI(o)   (*(int32_t *)(ns + (o)))
#define SW(o)   (*(uint16_t *)(ns + (o)))
#define SQ(o)   (*(uint64_t *)(ns + (o)))
#ifndef JXS_PTR
#define JXS_PTR(ns, v) ((ns) + (v))      /* +0x20 as an offset in the store */
#endif

/* 0x3F5240 -- vtable +8: rcx = [rcx+0xFD8]; r8b = 0x40; jmp [vtbl+0x10] (the assigner's note-off) */
static void jxs_off(uint8_t *ns, const jx_seq_cbs *cb, int note)
{
    (void)ns;
    ++g_seq_off;
    cb->kt_off(cb->user, cb->unit, note, 0x40);
}

/* 0x3F5260 -- vtable +0: the velocity scaled by +0xFD3 (percent) and +0xFD4 (or the 4th argument), then
 * jmp [[+0xFD8] vtbl +0x18] (the assigner's note-on). edx = note, r8b = vel, r9b = held velocity. */
static void jxs_on(uint8_t *ns, const jx_seq_cbs *cb, int note, int vel, int r9)
{
    uint32_t r11 = S8(0xFD4);                    /* movzx r11d, byte [rcx+0xfd4] */
    int32_t r8 = 0x7F - (int32_t)(uint8_t)vel;   /* r8d = 0x7f - (uint8)vel */
    r8 = r8 * (int32_t)S8(0xFD3);                /* imul r8d, byte [rcx+0xfd3] */
    {   int64_t p = (int64_t)r8 * (int64_t)0x51EB851F;     /* imul r8d (signed): edx = high */
        int32_t edx = (int32_t)(p >> 32);
        edx >>= 5;                                         /* sar edx, 5 */
        edx += (int32_t)((uint32_t)edx >> 31);             /* + sign bit: / 100 toward zero */
        uint8_t r10b = (uint8_t)(0x7F - (uint8_t)edx);     /* sub r10b, dl */
        uint32_t ecx = r10b;                               /* movzx ecx, r10b */
        if ((uint8_t)r11 == 0)                             /* test r11b,r11b; cmove r11d, eax */
            r11 = (uint8_t)r9;                             /* eax = movzx r9b */
        ecx = ecx * (uint8_t)r11;                          /* imul ecx, eax */
        {   uint64_t q = (uint64_t)ecx * 0x2040811ULL;     /* mul ecx: edx = high */
            uint32_t hi = (uint32_t)(q >> 32);
            ecx = ecx - hi;                                /* sub ecx, edx */
            ecx >>= 1;                                     /* shr ecx, 1 */
            ecx += hi;                                     /* add ecx, edx */
            ecx >>= 6;                                     /* shr ecx, 6: / 127 */
        }
        {   uint32_t r8d = (uint8_t)ecx;                   /* movzx r8d, cl */
            if ((uint8_t)ecx == 0)                         /* test cl,cl; cmove r8d, 1 */
                r8d = 1;
            ++g_seq_on;
            cb->kt_on(cb->user, cb->unit, (uint8_t)note, (int)r8d);   /* movzx edx, dil */
        }
    }
}

/* ---- the 19 step-choice functions (+0xD98): rcx = store, edx = column; return the note (or < 0) ---- */

/* 0x3F0270 -- mode 6: up and down over the queue */
static int32_t jxs_h3F0270(uint8_t *ns)
{
    int32_t eax = (int8_t)S8(0xBEE);
    int32_t r11 = 0;
    int64_t r9 = (int32_t)SI(0xCF8);
    int32_t edx = (int32_t)r9 - eax;
    int32_t ecx;
    eax = (edx >= 0) ? edx : r11;                /* cmovns */
    eax = eax * 2 - 1;                           /* lea eax, [rax*2-1] */
    if (SI(0x38) > eax)                          /* cmp [rcx+0x38], eax; jle */
        SI(0x38) = r11;
    ecx = SI(0xD88);
    edx = (int32_t)r9 + (int32_t)r9;             /* lea edx, [r9+r9] */
    eax = edx - 2;
    if (ecx > eax) {                             /* jle 0x3F02CC */
        ecx = 0;
        S8(0xD8C) = 1;
        ecx = ((int32_t)r9 > 1) ? 1 : 0;         /* cmp r9d,1; setg cl */
        SI(0xD88) = ecx;
    }
    if (ecx < 0) {                               /* test ecx,ecx; jns */
        SI(0xD88) = r11;
        ecx = r11;
    }
    {
        uint32_t r10 = S8(0xD84);
        int64_t rax;
        eax = (int32_t)r9 - 1;
        if (!(ecx > eax)) {                      /* jg 0x3F02FE */
            if ((uint8_t)r10 == 0) {             /* test r10b; jne */
                SI(0xD88) = r11;
                ecx = r11;
            }
            rax = ecx;                           /* movsxd rax, ecx */
        } else {
            if ((uint8_t)r10 != 0) {             /* je 0x3F030A */
                edx = edx - ecx;
                edx = edx - 2;
            } else {
                SI(0xD88) = r11;
                edx = r11;
                ecx = r11;
            }
            rax = edx;                           /* movsxd rax, edx */
        }
        {
            uint8_t dl = S8(0xBF8 + rax);
            int32_t res = (int8_t)dl;
            if ((int8_t)dl < 0)                  /* test dl,dl; jns */
                res = (int8_t)S8(0xBF7 + r9);
            if ((uint8_t)r10 == 0)
                S8(0xD84) = 1;
            ecx += 1;
            SI(0xD88) = ecx;
            return res;
        }
    }
}

/* 0x3F0430 -- mode 3: down the queue (from its top) */
static int32_t jxs_h3F0430(uint8_t *ns)
{
    int32_t eax = (int8_t)S8(0xBEE);
    int64_t r9 = (int32_t)SI(0xCF8);
    int32_t ecx = 0;
    int32_t edx = (int32_t)r9 - eax;
    eax = (edx >= 0) ? edx : ecx;                /* cmovns */
    if (SI(0x38) > eax)                          /* jle */
        SI(0x38) = ecx;
    edx = SI(0xD88);
    eax = (int32_t)r9 - 1;
    if (edx > eax) {                             /* jle 0x3F047A */
        SI(0xD88) = ecx;
        edx = ecx;
        S8(0xD8C) = 1;
    }
    if (edx < 0) {                               /* test edx,edx; jns */
        SI(0xD88) = ecx;
        edx = ecx;
    }
    {
        uint32_t r10 = S8(0xD84);
        if ((uint8_t)r10 != 0) {                 /* je 0x3F049D */
            ecx = (int32_t)r9;
            ecx = ecx - edx;
            ecx -= 1;
        } else {
            SI(0xD88) = ecx;                     /* ecx = 0 here */
            edx = ecx;
        }
        {
            int64_t rax = ecx;
            int32_t res = (int8_t)S8(0xBF8 + rax);
            if (res < 0)                         /* test eax,eax; jns */
                res = (int8_t)S8(0xBF7 + r9);
            if ((uint8_t)r10 == 0)
                S8(0xD84) = 1;
            SI(0xD88) = edx + 1;                 /* lea ecx, [rdx+1] */
            return res;
        }
    }
}

/* 0x3F0C20 -- mode 0: up the queue */
static int32_t jxs_h3F0C20(uint8_t *ns)
{
    int64_t r9 = (int32_t)SI(0xCF8);
    int32_t r10 = 0;
    int32_t eax = (int8_t)S8(0xBEE);
    int32_t edx = (int32_t)r9 - eax;
    int32_t ecx, res;
    uint8_t dl;
    if (SI(0x38) > edx)                          /* cmp [rcx+0x38], edx; jle */
        SI(0x38) = r10;
    ecx = SI(0xD88);
    eax = (int32_t)r9 - 1;
    if (ecx > eax) {                             /* jle 0x3F0C62 */
        SI(0xD88) = r10;
        ecx = r10;
        S8(0xD8C) = 1;
    }
    if (ecx < 0) {                               /* test ecx; jns */
        SI(0xD88) = r10;
        ecx = r10;
    }
    dl = S8(0xD84);
    if (dl == 0) {                               /* test dl,dl; jne */
        SI(0xD88) = r10;
        ecx = r10;
    }
    res = (int8_t)S8(0xBF8 + (int64_t)ecx);
    if (res < 0)                                 /* test eax,eax; jns */
        res = (int8_t)S8(0xBF7 + r9);
    if (dl == 0)
        S8(0xD84) = 1;
    SI(0xD88) = ecx + 1;
    return res;
}

/* 0x3F2A90 -- the store's random numbers: state (the word at +8) = state x 0x497D + 1, value = state x range
 * / 65535 (the magic division, signed, as the code does it) */
static uint32_t jxs_rand(uint8_t *ns, uint32_t range)
{
    uint32_t r8 = (uint32_t)*(uint16_t *)(ns + 8) * 0x497Du;   /* imul r8d, 0x497d */
    uint32_t eax = range & 0xFFFF;               /* movzx eax, dx */
    uint16_t r8w = (uint16_t)(r8 + 1);           /* inc r8w */
    uint32_t r9 = r8w;
    int64_t p;
    int32_t edx;
    *(uint16_t *)(ns + 8) = r8w;
    r9 = r9 * eax;                               /* imul r9d, eax */
    p = (int64_t)(int32_t)r9 * (int64_t)(int32_t)0x80008001u;   /* imul r9d (signed): edx = high */
    edx = (int32_t)(p >> 32);
    edx += (int32_t)r9;
    edx >>= 15;                                  /* sar edx, 0xf */
    return (uint32_t)edx + ((uint32_t)edx >> 31);
}

/* the queue's entry at i, or its last entry when that one is empty (the common tail) */
#define JXS_PICK(i, cnt) ( (int8_t)S8(0xBF8 + (int64_t)(i)) >= 0 ? (int32_t)(int8_t)S8(0xBF8 + (int64_t)(i)) \
                                                              : (int32_t)(int8_t)S8(0xBF7 + (int64_t)(cnt)) )

/* 0x3F0CC0 -- mode 1 */
static int32_t jxs_h3F0CC0(uint8_t *ns, int32_t edx)
{
    int64_t r9 = (int32_t)SI(0xCF8);
    int32_t r10 = (int8_t)S8(0xBEE);
    int32_t eax = (int32_t)r9 - r10;
    int32_t r8 = SI(0x38);
    if (r8 > eax) { r8 = 0; SI(0x38) = 0; }
    eax = r10 - 1;
    if (edx == eax) edx = (int32_t)r9 - 1;
    else if (edx != 0) edx += r8;
    return JXS_PICK(edx, r9);
}

/* 0x3F0D20 -- mode 2 */
static int32_t jxs_h3F0D20(uint8_t *ns, int32_t edx)
{
    int64_t r10 = (int32_t)SI(0xCF8);
    int32_t ecx = SI(0x38);
    int32_t r8 = (int32_t)r10 - (int8_t)S8(0xBEE);
    if (ecx > r8) { ecx = 0; SI(0x38) = 0; }
    return JXS_PICK(ecx + edx, r10);
}

/* 0x3F04E0 -- mode 4 */
static int32_t jxs_h3F04E0(uint8_t *ns, int32_t edx)
{
    int64_t r9 = (int32_t)SI(0xCF8);
    int32_t r11 = (int8_t)S8(0xBEE);
    int32_t eax = (int32_t)r9 - r11;
    int32_t r10 = SI(0x38);
    int32_t r8 = (eax >= 0) ? eax : 0;           /* cmovns r8d, eax */
    if (r10 > r8) { SI(0x38) = 0; r10 = 0; }
    if (edx == r11 - 1) edx = (int32_t)r9 - 1;
    else if (edx != 0) { r8 -= r10; edx += r8; }
    return JXS_PICK(edx, r9);
}

/* 0x3F0550 -- mode 5 */
static int32_t jxs_h3F0550(uint8_t *ns, int32_t edx)
{
    int32_t eax = (int8_t)S8(0xBEE);
    int64_t r9 = (int32_t)SI(0xCF8);
    int32_t r8 = (int32_t)r9 - eax;
    eax = (r8 >= 0) ? r8 : 0;
    r8 = SI(0x38);
    if (r8 > eax) { SI(0x38) = 0; r8 = 0; }
    eax = eax - r8 + edx;
    return JXS_PICK(eax, r9);
}

/* 0x3F0350 -- mode 7 */
static int32_t jxs_h3F0350(uint8_t *ns, int32_t edx)
{
    int64_t r9 = (int32_t)SI(0xCF8);
    int32_t ebx = (int8_t)S8(0xBEE);
    int32_t eax = (int32_t)r9 - ebx;
    int32_t r8 = SI(0x38);
    int32_t r11 = (eax >= 0) ? eax : 0;          /* cmovns r11d, eax */
    int32_t r10 = r11 + r11;
    eax = r10 - 1;
    if (r8 > eax) { SI(0x38) = 0; r8 = 0; }
    if (edx == ebx - 1) edx = (int32_t)r9 - 1;
    else if (edx != 0) {
        r10 -= r8;
        if (r8 > r11) r8 = r10;                  /* cmovg r8d, r10d */
        edx += r8;
    }
    return JXS_PICK(edx, r9);
}

/* 0x3F03D0 -- mode 8 */
static int32_t jxs_h3F03D0(uint8_t *ns, int32_t col)
{
    int32_t eax = (int8_t)S8(0xBEE);
    int64_t r10 = (int32_t)SI(0xCF8);
    int32_t edx = SI(0x38);
    int32_t r8 = (int32_t)r10 - eax;
    int32_t r9 = (r8 >= 0) ? r8 : 0;
    r8 = r9 + r9;
    eax = r8 - 1;
    if (edx > eax) { SI(0x38) = 0; edx = 0; }
    r8 -= edx;
    if (edx > r9) edx = r8;                      /* cmovg edx, r8d */
    return JXS_PICK(col + edx, r10);
}

/* 0x3F0A10 -- mode 9: a random spread over the queue, drawn again when +0x38 or the count changed */
static int32_t jxs_h3F0A10(uint8_t *ns, int32_t edx)
{
    int32_t ecx = SI(0x38);
    int64_t rbp = edx;
    if (!(SI(0x3C) == ecx && SI(0x40) == SI(0xCF8))) {
        int32_t eax = (int8_t)S8(0xBEE);
        int32_t r14 = 1, r12 = 1, esi;
        SI(0x3C) = ecx;
        ecx = SI(0xCF8);
        SI(0x40) = ecx;
        ecx = ecx - eax + 1;
        S8(0x44) = 0;
        if ((int8_t)S8(0xBEE) > 1) {             /* cmp byte, r12b(1); jle */
            uint8_t *r15 = ns + 0x45;
            esi = (ecx >= 0) ? ecx : 0;          /* test ecx; cmovns esi, ecx */
            do {
                uint32_t r = jxs_rand(ns, (uint16_t)esi) & 0xFFFF;   /* movzx ecx, ax */
                int32_t e2 = r14 + 1 + (int32_t)r;
                r15 += 1;
                esi -= (int32_t)r;
                r12 += 1;
                r15[-1] = (uint8_t)((int32_t)r + r14);
                r14 = (e2 < SI(0xCF8)) ? e2 : SI(0xCF8) - 1;          /* cmp edx, eax; cmovl */
            } while (r12 < (int8_t)S8(0xBEE));
        }
    }
    if (rbp != 0) rbp = (int8_t)S8(0x44 + rbp);
    return JXS_PICK(rbp, (int32_t)SI(0xCF8));
}

/* 0x3F0B20 -- mode 10: a random note, a random octave (+0xD94 > 0: up to it) */
static int32_t jxs_h3F0B20(uint8_t *ns)
{
    uint32_t r = jxs_rand(ns, *(uint16_t *)(ns + 0xCF8)) & 0xFFFF;
    int32_t edi = (int8_t)S8(0xBF8 + r);
    int32_t eax = SI(0xD94), ecx;
    if (eax == 0) return edi;
    r = jxs_rand(ns, (uint32_t)(eax + 1)) & 0xFFFF;
    switch (r) {
    case 1: eax = -1; ecx = 1; break;
    case 2: eax = -2; ecx = 2; break;
    case 3: eax = -3; ecx = 3; break;
    case 4: eax = -4; ecx = 4; break;
    default:
        SI(0xD90) = 0;
        return edi;
    }
    if (SI(0xD94) > 0) eax = ecx;                /* cmovg eax, ecx */
    SI(0xD90) = eax;
    return edi;
}

/* 0x3F09B0 -- mode 11: the newest note moved by the column's note against the default note (+0xBF4) */
static int32_t jxs_h3F09B0(uint8_t *ns, int32_t edx)
{
    uint8_t r10 = S8(0xD7C);
    int32_t r9;
    int64_t rax;
    if ((int8_t)r10 < 0) return -1;
    r9 = S8(0x324 + 12 * (int64_t)edx);          /* [rcx + (edx+0x43)*12] */
    r9 -= S8(0xBF4);
    r9 += (int8_t)r10;
    rax = r9;
    if (S8(0xC78 + rax) == 0)
        S8(0x1D0 + rax) = S8(0x1D0 + (int8_t)r10);
    return r9;
}

/* 0x3F0990 -- mode 12 (and any mode above 18) */
static int32_t jxs_h3F0990(uint8_t *ns, int32_t edx)
{
    return JXS_PICK(edx, (int32_t)SI(0xCF8));
}

/* 0x3F05A0 -- mode 13 (no fallback) */
static int32_t jxs_h3F05A0(uint8_t *ns, int32_t edx)
{
    int32_t r8 = 0;
    if (edx != 0) {
        r8 = SI(0xCF8) - (int8_t)S8(0xBEE) + edx;
        if (r8 < 0) r8 = 0;                      /* cmovs */
    }
    return (int8_t)S8(0xBF8 + (int64_t)r8);
}

/* 0x3F0BE0 -- mode 14 */
static int32_t jxs_h3F0BE0(uint8_t *ns, int32_t edx)
{
    if (edx == (int8_t)S8(0xBEE) - 1) edx = SI(0xCF8) - 1;
    return JXS_PICK(edx, (int32_t)SI(0xCF8));
}

/* the free-slot queue walk the modes 15-17 share: the entry whose rank among the filled slots is +0xD88 */
static int32_t jxs_rank_walk(uint8_t *ns, int32_t eax, int32_t count, int32_t *edx_out)
{
    int32_t r10 = -1, ecx = 0, edx;
    int64_t r9 = 0;
    for (;;) {
        edx = eax;
        if (ecx >= count) break;
        r10 = (int8_t)S8(0xBF8 + r9);
        eax = SI(0xD88);
        if (r10 > -1) {
            edx = eax;
            if (eax == ecx) break;
            ++ecx;
        }
        ++r9;
        edx = eax;
        if (!(r9 < 0x80)) break;
    }
    *edx_out = edx;
    return r10;
}

/* 0x3F08E0 -- mode 15: up the filled slots */
static int32_t jxs_h3F08E0(uint8_t *ns)
{
    int64_t r11 = (int32_t)SI(0xCF8);
    int32_t edx = (int32_t)r11 - (int8_t)S8(0xBEE), eax, r10;
    if (SI(0x38) > edx) SI(0x38) = 0;
    eax = SI(0xD88);
    if (!(eax < (int32_t)r11)) { SI(0xD88) = 0; eax = 0; S8(0xD8C) = 1; }
    r10 = jxs_rank_walk(ns, eax, (int32_t)r11, &edx);
    if (r10 < 0) r10 = (int8_t)S8(0xBF7 + r11);
    if (S8(0xD84) == 0) S8(0xD84) = 1;
    SI(0xD88) = edx + 1;
    return r10;
}

/* 0x3F0770 -- mode 16: down the filled slots */
static int32_t jxs_h3F0770(uint8_t *ns)
{
    int64_t r11 = (int32_t)SI(0xCF8);
    int32_t edx = (int32_t)r11 - (int8_t)S8(0xBEE), eax, r10;
    eax = (edx >= 0) ? edx : 0;
    if (SI(0x38) > eax) SI(0x38) = 0;
    eax = SI(0xD88);
    edx = (int32_t)r11 - 1;
    if (eax > edx) {
        do { eax -= 1; } while (eax > edx);
        SI(0xD88) = eax;
    }
    if (eax < 0) { SI(0xD88) = edx; eax = edx; S8(0xD8C) = 1; }
    r10 = jxs_rank_walk(ns, eax, (int32_t)r11, &edx);
    if (r10 < 0) r10 = (int8_t)S8(0xBF7 + r11);
    if (S8(0xD84) == 0) S8(0xD84) = 1;
    SI(0xD88) = edx - 1;
    return r10;
}

/* 0x3F05F0 -- mode 17: up and down the filled slots, turning at the ends (+0xD85 the direction), the octave
 * counter's ends (+0xD90 against +0xD94 / 0) deciding the turn */
static int32_t jxs_h3F05F0(uint8_t *ns)
{
    int64_t r10 = (int32_t)SI(0xCF8);
    int32_t edx = (int32_t)r10 - (int8_t)S8(0xBEE), eax, r11, ebx;
    eax = (edx >= 0) ? edx : 0;
    eax = eax * 2 - 1;
    if (SI(0x38) > eax) SI(0x38) = 0;
    eax = SI(0xD88);
    if (S8(0xD85) != 0) {
        if (!(eax < (int32_t)r10)) {
            if (SI(0xD90) != SI(0xD94)) {        /* 0x3F0685 */
                SI(0xD88) = 0; eax = 0;
                S8(0xD8C) = 1;
            } else if ((int32_t)r10 <= 1) {      /* 0x3F066C */
                eax = 0; S8(0xD8C) = 1; SI(0xD88) = 0; S8(0xD85) = 0;
            } else {
                eax = (int32_t)r10 - 2; S8(0xD85) = 0; SI(0xD88) = eax;
            }
        }
    } else {
        if (eax < 0) {
            if (SI(0xD90) != 0) {                /* 0x3F06CD */
                eax = (int32_t)r10 - 1; SI(0xD88) = eax;
                S8(0xD8C) = 1;
            } else if ((int32_t)r10 <= 1) {      /* 0x3F06B4 */
                eax = 0; S8(0xD8C) = 1; SI(0xD88) = 0; S8(0xD85) = 1;
            } else {
                eax = 1; S8(0xD85) = 1; SI(0xD88) = 1;
            }
        }
    }
    r11 = jxs_rank_walk(ns, eax, (int32_t)r10, &edx);
    if (r11 < 0) r11 = (int8_t)S8(0xBF7 + r10);
    if (S8(0xD84) == 0) S8(0xD84) = 1;
    ebx = (S8(0xD85) != 0) ? 1 : -1;             /* cmovne ebx, edi */
    SI(0xD88) = ebx + edx;
    return r11;
}

/* 0x3F0850 -- mode 18: a random octave (0..+0xD94) and a random filled slot */
static int32_t jxs_h3F0850(uint8_t *ns)
{
    uint32_t r = jxs_rand(ns, (uint16_t)(*(uint16_t *)(ns + 0xD94) + 1)) & 0xFFFF;
    int32_t r9, r8, eax = 0, edx = -1;
    int64_t rcx = 0;
    SI(0xD90) = (int32_t)r;
    r = jxs_rand(ns, *(uint16_t *)(ns + 0xCF8)) & 0xFFFF;
    r9 = SI(0xCF8);
    r8 = (int32_t)r;
    SI(0xD88) = r8;
    for (;;) {
        if (eax >= r9) break;
        edx = (int8_t)S8(0xBF8 + rcx);
        if (edx > -1) {
            if (r8 == eax) break;
            ++eax;
        }
        ++rcx;
        if (!(rcx < 0x80)) break;
    }
    return edx;
}

/* the stored function: the image address the plugin wrote (the recall data carry it as it is) */
static int32_t jxs_hook(uint8_t *ns, const jx_seq_cbs *cb, int col)
{
    uint64_t h = SQ(0xD98) - JXS_IB;
    ++g_seq_hook_calls;
    switch (h) {
    case 0x3F0C20: ++g_seq_mode_calls[0]; return jxs_h3F0C20(ns);         /* mode 0 */
    case 0x3F0CC0: ++g_seq_mode_calls[1]; return jxs_h3F0CC0(ns, col);    /* 1 */
    case 0x3F0D20: ++g_seq_mode_calls[2]; return jxs_h3F0D20(ns, col);    /* 2 */
    case 0x3F0430: ++g_seq_mode_calls[3]; return jxs_h3F0430(ns);         /* 3 */
    case 0x3F04E0: ++g_seq_mode_calls[4]; return jxs_h3F04E0(ns, col);    /* 4 */
    case 0x3F0550: ++g_seq_mode_calls[5]; return jxs_h3F0550(ns, col);    /* 5 */
    case 0x3F0270: ++g_seq_mode_calls[6]; return jxs_h3F0270(ns);         /* 6 */
    case 0x3F0350: ++g_seq_mode_calls[7]; return jxs_h3F0350(ns, col);    /* 7 */
    case 0x3F03D0: ++g_seq_mode_calls[8]; return jxs_h3F03D0(ns, col);    /* 8 */
    case 0x3F0A10: ++g_seq_mode_calls[9]; return jxs_h3F0A10(ns, col);    /* 9 */
    case 0x3F0B20: ++g_seq_mode_calls[10]; return jxs_h3F0B20(ns);         /* 10 */
    case 0x3F09B0: ++g_seq_mode_calls[11]; return jxs_h3F09B0(ns, col);    /* 11 */
    case 0x3F0990: ++g_seq_mode_calls[12]; return jxs_h3F0990(ns, col);    /* 12, and any mode above 18 */
    case 0x3F05A0: ++g_seq_mode_calls[13]; return jxs_h3F05A0(ns, col);    /* 13 */
    case 0x3F0BE0: ++g_seq_mode_calls[14]; return jxs_h3F0BE0(ns, col);    /* 14 */
    case 0x3F08E0: ++g_seq_mode_calls[15]; return jxs_h3F08E0(ns);         /* 15 */
    case 0x3F0770: ++g_seq_mode_calls[16]; return jxs_h3F0770(ns);         /* 16 */
    case 0x3F05F0: ++g_seq_mode_calls[17]; return jxs_h3F05F0(ns);         /* 17 */
    case 0x3F0850: ++g_seq_mode_calls[18]; return jxs_h3F0850(ns);         /* 18 */
    default:
        if (cb->bad_hook) cb->bad_hook(cb->user, h);
        return -1;
    }
}

/* 0x3F1910 -- the mode setter (its one caller: the pattern apply 0x3F4C50, jx3p/docs/HOST_LAYER.md 3e):
 * [rcx+0xD98] = mode edx's step function from the jump table at 0x3F1A50 (each case 'lea rax, fn; mov
 * [rcx+0xd98], rax; ret'); above 18, unsigned (cmp edx, 0x12; ja), mode 12's. The port's recall data
 * carry the stored function as the plugin's patch load wrote it, so the product path never calls this:
 * it is the tick gate's stimulus for the modes no patch reaches (jx_tick_gate.py --setmode). */
static const uint32_t jxs_mode_fn[19] = {
    0x3F0C20, 0x3F0CC0, 0x3F0D20, 0x3F0430, 0x3F04E0, 0x3F0550, 0x3F0270, 0x3F0350, 0x3F03D0, 0x3F0A10,
    0x3F0B20, 0x3F09B0, 0x3F0990, 0x3F05A0, 0x3F0BE0, 0x3F08E0, 0x3F0770, 0x3F05F0, 0x3F0850 };
static void jxs_3F1910(uint8_t *ns, uint32_t mode)
{
    SQ(0xD98) = JXS_IB + (mode > 0x12 ? 0x3F0990u : jxs_mode_fn[mode]);
}

/* 0x3EF210 -- release the 16 playing columns */
static void jxs_3EF210(uint8_t *ns, const jx_seq_cbs *cb)
{
    int k;
    for (k = 0; k < 16; ++k) {
        uint8_t *slot = ns + 0x326 + 12 * k;     /* rbx = rcx + 0x326, += 0xc */
        uint32_t edx = slot[0];
        if (edx < 0x80) {                        /* jae: skip */
            jxs_off(ns, cb, (int)edx);           /* call [vtbl+8] (r8d = 0x40) */
            S8(0xCFC + (int8_t)slot[1]) = 0x80;  /* movsx rax, byte [rbx+1] */
            slot[0] = 0x80;
        }
    }
}

/* 0x3EF910 -- the note store's reset */
static void jxs_3EF910(uint8_t *ns, const jx_seq_cbs *cb)
{
    int i;
    if ((uint32_t)(SI(0x2C) - 1) <= 2) {         /* dec; cmp 2; ja */
        SI(0x2C) = 0;
        jxs_3EF210(ns, cb);
    }
    for (i = 0; i < 128; ++i) {                  /* the unrolled loop: 4 x 32 */
        SW(0xD0 + 2 * i) = 0;
        S8(0xBF8 + i) = 0xFF;
        S8(0xC78 + i) = 0;
        S8(0xCFC + i) = 0x80;
    }
    SQ(0xC8) = 0;                                /* +0xC8 and +0xCC */
    SI(0x250) = 0;                               /* +0x250 and +0x252 */
    SI(0xCF8) = 0;
    S8(0xD7C) = 0xFF;
}

/* 0x3EFBF0 -- clear the step table at dst (16 columns of 12 bytes, 32 rows of 16 four-byte cells) */
static void jxs_3EFBF0(uint8_t *dst)
{
    int c, r;
    for (c = 0; c < 16; ++c) {
        dst[12 * c] = 0x80;
        dst[12 * c + 2] = 0x80;
    }
    for (r = 0; r < 32; ++r)
        for (c = 0; c < 16; ++c)
            dst[0xC0 + 0x40 * r + 4 * c] = 0;
    dst[0x8D0] = 0x3C;
}

/* 0x3EF3B0 -- drop the columns whose cells are all empty, then sort the columns by note (Shell sort, gaps
 * 8 4 2 1, unsigned): the note byte and the cells move, the column's other bytes do not (literal) */
static void jxs_3EF3B0(uint8_t *ns, uint8_t *dst)
{
    int c, gap;
    if (dst == 0) {                              /* test rdx,rdx; jne */
        dst = ns + 0x324;
        jxs_3EF3B0(ns, dst);
    }
    for (c = 0; c < 16; ++c) {
        if (dst[12 * c] < 0x80) {                /* cmp byte, 0x80; jae */
            int64_t r8 = (int8_t)dst[0x8CB], r;
            int all0 = 1;
            for (r = 0; r < r8; ++r)             /* test r8,r8; jle: all empty when none */
                if (dst[0xC0 + 4 * c + 0x40 * r] & 0x7F) { all0 = 0; break; }
            if (all0)
                dst[12 * c] = 0x80;
        }
    }
    gap = 8;
    do {
        int64_t i;
        int32_t r15 = 0;
        for (i = gap; i < 16; ++i, ++r15) {
            int64_t j = i - gap;
            int32_t esi = r15;
            if (esi < 0) continue;
            for (;;) {
                uint8_t a = dst[12 * j], b = dst[12 * (j + gap)];
                if (a <= b) break;               /* cmp r8b, al; jbe */
                dst[12 * j] = b;
                dst[12 * (j + gap)] = a;
                {   int32_t r11 = 0;
                    if ((int8_t)dst[0x8CB] > 0) {    /* cmp byte, r11b; jle */
                        do {
                            uint8_t *p = dst + 0xC0 + 4 * j + 0x40 * r11;
                            uint8_t *q = dst + 0xC0 + 4 * (j + gap) + 0x40 * r11;
                            uint8_t t = *p;
                            *p = *q;
                            *q = t;
                            ++r11;
                        } while (r11 < (int8_t)dst[0x8CB]);
                    }
                }
                j -= gap;
                esi -= gap;
                if (esi < 0) break;              /* sub esi, ebp; jns */
            }
        }
        gap = gap / 2;                           /* cdq; sub; sar: toward zero */
    } while (gap > 0);
}

/* 0x3F1650 -- load the pattern at src (or none) into the step table dst */
static void jxs_3F1650(uint8_t *ns, const uint8_t *src, uint8_t *dst)
{
    int32_t edi = 0;
    if (src == 0) {                              /* test rdx,rdx; jne */
        dst[0x8CB] = 1;
        if ((int8_t)dst[0x8C9] > 0) {            /* cmp byte, dil(0); jle */
            uint8_t *rbx = dst, *rcx = dst + 0xC0;
            do {
                rbx[0] = 0x80;
                ++edi;
                rcx[0] = 0;
                rcx += 4;
                rbx += 12;
            } while (edi < (int8_t)dst[0x8C9]);
        }
        return;
    }
    jxs_3EFBF0(dst);
    {
        uint8_t al = src[0];
        uint8_t cl = 0x20;
        if (al < cl) cl = al;                    /* cmp al, cl; cmovb ecx, eax */
        dst[0x8CB] = cl;
    }
    {
        const uint8_t *rcx = src + 6;
        int32_t r9 = 0;
        edi = 0;
        if ((int8_t)dst[0x8C9] > 0) {            /* cmp byte, dil; jle */
            uint8_t *r8 = dst;
            uint8_t *rdx = dst + 0x100;
            for (;;) {
                int k;
                uint8_t al = rcx[0];
                r8[0] = al;
                if (al >= 0x80) break;           /* cmp al, 0x80; jae 0x3F1863 */
                ++r9;
                rdx[-0x40] = rcx[1];
                r8 += 12;
                for (k = 2; k <= 0x20; ++k)      /* rows 1..31: [rdx + 0x40*(k-2)] = rcx[k] */
                    rdx[0x40 * (k - 2)] = rcx[k];
                rcx += 0x22;
                rdx += 4;
                if (!(r9 < (int8_t)dst[0x8C9])) break;
            }
        }
    }
    jxs_3EF3B0(ns, dst);
    {
        int32_t r11 = (int8_t)dst[0x8CB];
        uint8_t *r10 = dst + 0xC0;
        int32_t eax = 0x80;
        for (;;) {                               /* 0x3F1882 */
            if (edi >= r11) break;               /* cmp edi, r11d; jge */
            {
                int32_t ecx = (int8_t)dst[0x8C9];
                if (ecx > 0) {
                    uint8_t *r8 = dst, *rdx = r10;
                    int64_t r9 = ecx;
                    do {
                        uint32_t c = rdx[0];
                        if (c != 0 && c < 0x80) {    /* test cl; je / cmp cl,0x80; jae */
                            int32_t n = r8[0];
                            if (n < eax) eax = n;    /* cmp ecx, eax; cmovl eax, ecx */
                        }
                        rdx += 4;
                        r8 += 12;
                    } while (--r9);
                }
            }
            ++edi;
            r10 += 0x40;
            if (eax != 0x80) break;              /* cmp eax, 0x80; je loop */
        }
        dst[0x8D0] = (eax == 0x80) ? 0x3C : (uint8_t)eax;
    }
}

/* 0x3F1B10 -- each column's step times: walking back from its first nonzero row, every row's word at
 * cell +2 = the running sum of the row lengths (store words +0x262 / +0x264 by the previous cell's sign) */
static void jxs_3F1B10(uint8_t *ns, uint8_t *dst)
{
    int32_t col;
    if (S8(0xDA0) != 0) return;                  /* cmp byte [rcx+0xda0], 0; jne */
    if (dst == 0) {
        dst = ns + 0x324;
        jxs_3F1B10(ns, dst);
    }
    dst[0x8CA] = 0;
    if (!((int8_t)dst[0x8C9] > 0)) return;
    for (col = 0; col < (int8_t)dst[0x8C9]; ++col) {
        uint8_t *hdr = dst + 12 * col;           /* r13 */
        int64_t r12 = 2 + 4 * col;
        uint32_t r8 = 0;
        int64_t rbx = 0;
        int32_t edx_rows;
        if (hdr[0] >= 0x80) return;              /* jae 0x3F1CD8: the whole function ends */
        dst[0x8CA] += 1;
        edx_rows = dst[0x8CB];                   /* movzx edx */
        if ((int8_t)edx_rows <= 0) continue;     /* test dl,dl; jle 0x3F1CAC */
        {
            uint8_t *rax = dst + r12 + 0xBE;     /* cell[0][col] */
            int64_t rbp = (int8_t)edx_rows;
            uint32_t cl = 0;
            int found = 0;
            for (;;) {
                cl = rax[0];
                if (cl & 0x7F) { found = 1; break; }
                r8 += 1; rbx += 1; rax += 0x40;
                if (!((int32_t)r8 < (int32_t)rbp)) break;
            }
            if (!found) continue;
            {
                uint32_t r9 = cl;                /* movzx r9d, cl */
                uint32_t eax = 0;                /* movzx eax, r11w (r11 = 0) */
                int64_t rsi = (int32_t)r8;
                do {
                    int64_t rdx = rsi - 1;
                    int64_t rcx = (rdx >= 0) ? rsi : rbp;           /* cmovns rcx, rsi */
                    uint32_t ecx32;
                    uint8_t *r11p, *cellrow, *r14;
                    uint32_t edi, r10, dxw, cx;
                    rsi = rcx - 1;
                    ecx32 = (rdx >= 0) ? r8 : (uint32_t)rbp;        /* cmovns ecx, r8d */
                    r8 = ecx32 - 1;
                    r11p = ns + 6 * rsi;                            /* r10 + rcx*2, rcx = rsi*3 */
                    cellrow = dst + ((rsi + 3) << 6);               /* (rsi+3)<<6 + r15 */
                    edi = cellrow[r12 - 2];                         /* byte [r12 + rcx - 2] */
                    if ((int8_t)r9 < 0)                             /* test r9b,r9b; jns */
                        r9 = *(uint16_t *)(r11p + 0x262);
                    else
                        r9 = *(uint16_t *)(r11p + 0x264);
                    r10 = edi & 0x7F;
                    r14 = cellrow + r12;                            /* the cell's word at +2 */
                    dxw = r10 ? (eax + r9) : 0;                     /* lea edx, [rax+r9] / xor edx */
                    cx = 0;
                    *(uint16_t *)r14 = (uint16_t)dxw;
                    if (r10 == 0)                                   /* cmove cx, ax */
                        cx = eax & 0xFFFF;
                    if ((uint16_t)r9 != 0) {                        /* test r9w; jne 0x3F1C84 */
                        cx = (uint16_t)(cx + (uint16_t)r9);
                        eax = (edi & 0x80) ? cx : 0;                /* mov eax, 0; cmovne ax, cx */
                    } else {
                        eax = (uint16_t)(*(uint16_t *)(r11p + 0x262) + (uint16_t)cx);
                    }
                    r9 = edi;
                } while (rsi != rbx);
            }
        }
    }
}

/* 0x3F2297..0x3F2332 -- the free-slot player's octave counter at a column's note-off: by the stored
 * function (ecx = +0xD94, nonzero; +0xD8C already cleared) */
static void jxs_octave_freeslot(uint8_t *ns, const jx_seq_cbs *cb, int32_t ecx, int32_t eax)
{
    uint64_t h = SQ(0xD98) - JXS_IB;
    (void)cb;
    if (h == 0x3F0850) return;                   /* mode 18: unchanged */
    if (h == 0x3F0770) {                         /* mode 16: down, wrapping to the top */
        eax -= 1;
        SI(0xD90) = eax;
        if (eax < 0) SI(0xD90) = ecx;
        return;
    }
    if (h == 0x3F05F0) {                         /* mode 17: by the direction byte +0xD85 */
        if (S8(0xD85) != 0) {
            eax += 1;
            SI(0xD90) = eax;
            if (eax > ecx) SI(0xD90) = ecx;
        } else {
            eax -= 1;
            SI(0xD90) = eax;
            if (eax < 0) SI(0xD90) = 0;
        }
        return;
    }
    if (ecx >= 0) {                              /* test ecx,ecx; js */
        eax += 1;
        SI(0xD90) = eax;
        if (eax > ecx) SI(0xD90) = 0;
    } else {
        eax -= 1;
        if (eax < ecx) eax = 0;
        SI(0xD90) = eax;
    }
}

/* the step player: 0x3F1EA0 (the queue's order, +0xDA1 = 0) and 0x3F2120 (free slots, +0xDA1 != 0); they
 * differ only in the octave counter's update at the column's note-off */
static void jxs_play(uint8_t *ns, const jx_seq_cbs *cb, int freeslot)
{
    uint32_t ecx = (uint32_t)SI(0xBF0) + 1;
    int32_t eax = (int8_t)S8(0xBEF);
    int64_t rdx;
    uint8_t *r13, *rsi;
    int32_t edi = -1, ebp = 0;
    SI(0xBF0) = (int32_t)ecx;
    if (!((int32_t)ecx < eax)) {                 /* cmp ecx, eax; jl */
        SI(0x34) += 1;
        ecx = 0;
        SI(0x38) += 1;
        SI(0xBF0) = 0;
    }
    rdx = (int32_t)ecx;
    r13 = ns + 0x3E4 + (rdx << 6);
    rsi = ns + 0x324;
    SI(0xBE8) += *(uint16_t *)(ns + 0x262 + 6 * rdx);
    if (!((int8_t)S8(0xBEE) > 0)) return;
    for (;;) {
        int32_t r12 = r13[0] & 0x7F;
        eax = edi;
        if (r12 == 0) goto next;
        if (!(SI(0x10) < 0xB)) {                 /* cmp dword [rbx+0x10], 0xb; jl */
            edi = rsi[0];
            if (eax >= edi) edi = eax;           /* cmovge edi, eax */
            goto next;
        }
        if (SI(0xCF8) == 0) goto next;
        {
            int32_t note = jxs_hook(ns, cb, ebp);
            int64_t r15 = note, r14;
            uint32_t c;
            int32_t r8;
            if (note < 0) goto next;             /* js */
            c = S8(0xCFC + r15);
            r14 = r15;
            if (c < 0x80) {                      /* jae 0x3F1FD0 */
                uint8_t *h;
                if ((int32_t)c < ebp) goto next; /* cmp ecx, ebp; jl */
                h = ns + 0x324 + 12 * (int64_t)c;
                if (h[2] < 0x80) {
                    jxs_off(ns, cb, h[2]);
                    S8(0xCFC + (int8_t)h[3]) = 0x80;
                    h[2] = 0x80;
                }
                r14 = r15;
            }
            if (rsi[2] < 0x80) {
                jxs_off(ns, cb, rsi[2]);
                S8(0xCFC + (int8_t)rsi[3]) = 0x80;
                rsi[2] = 0x80;
            }
            if (S8(0xD8C) != 0 && SI(0xD94) != 0) {
                int32_t lim = SI(0xD94);
                int32_t e = SI(0xD90);
                S8(0xD8C) = 0;
                if (!freeslot) {
                    if (lim >= 0) {              /* js 0x3F202E (the sign of +0xD94) */
                        e += 1;
                        SI(0xD90) = e;
                        if (e > lim) SI(0xD90) = 0;
                    } else {
                        e -= 1;
                        if (e < lim) e = 0;      /* cmp eax, ecx; cmovl eax, 0 */
                        SI(0xD90) = e;
                    }
                } else {
                    jxs_octave_freeslot(ns, cb, lim, e);
                }
            }
            r8 = (int32_t)r15 + 12 * SI(0xD90);
            if (r8 > 0x7F) {                     /* fold above 127 down by whole octaves */
                uint32_t q = (uint32_t)(r8 - 0x80) / 12u;
                r8 += -12 - (int32_t)(12u * q);
            }
            if (r8 < 0) {                        /* and below 0 up */
                uint32_t q = (uint32_t)(~r8) / 12u;
                r8 = r8 + (int32_t)(12u * q) + 12;
            }
            if (S8(0x255) != 0) {
                if (edi >= r8) r8 = edi;         /* cmp edi, r8d; cmovge r8d, edi */
                edi = r8;
                goto next;
            }
            S8(0xCFC + r14) = (uint8_t)ebp;
            rsi[3] = (uint8_t)r15;
            if (S8(0xC4) != 0)
                r12 = (int8_t)S8(0x1D0 + r14);
            rsi[2] = (uint8_t)r8;
            *(int32_t *)(rsi + 8) = (int32_t)*(uint16_t *)(r13 + 2) + SI(0x18);
            jxs_on(ns, cb, (uint8_t)r8, r12, (int8_t)S8(0x1D0 + r14));
        }
next:
        ++ebp;
        rsi += 12;
        r13 += 4;
        if (!(ebp < (int8_t)S8(0xBEE))) break;
    }
}

/* 0x3EFD10 -- the note store's tick */
static void jxs_tick_ns(uint8_t *ns, const jx_seq_cbs *cb)
{
    int32_t edx = SI(0x30);
    int32_t st;
    if (edx != 0) {                              /* the countdown */
        edx -= 1;
        SI(0x30) = edx;
    }
    st = SI(0x2C);
    switch (st) {
    case 0:                                      /* 0x3EFE0A */
        if (SI(0xCF8) != 0 || SW(0x250) != 0) goto start;
        if (SI(0xCC) == 0) goto tail;
        goto start;
    case 1:                                      /* 0x3EFDDA */
        if (SI(0xCF8) != 0 || SW(0x250) != 0 || SI(0xCC) != 0) {
            if (edx != 0) goto tail;             /* 0x3EFE04 */
            goto start;
        }
        goto to0;
    case 2:                                      /* 0x3EFD8C */
        if (SI(0xCF8) != 0 || SW(0x250) != 0 || SI(0xCC) != 0) goto tail;
        SI(0x25C) = SI(0x258);
        if (S8(0x260) == 0)
            jxs_3EF210(ns, cb);
        SI(0x2C) = 3;
        goto tail;
    case 3:                                      /* 0x3EFD4C */
        if (SI(0xCF8) != 0 || SW(0x250) != 0 || SI(0xCC) != 0) goto set2;
        if (SI(0x25C) != 0) goto to0;
        SI(0x25C) = -1;
        goto tail;
    default:
        goto tail;
    }
to0:                                             /* 0x3EFDF6 */
    SI(0x2C) = 0;
    jxs_3EF210(ns, cb);
    goto tail;
start:                                           /* 0x3EFE26 */
    {
        int32_t eax = SI(0x18) + 1;
        SQ(0x3C) = 0xFFFFFFFFFFFFFFFFULL;
        SI(0xBE8) = eax;
        SQ(0x34) = 0;
        SI(0xBF0) = -1;
    }
set2:                                            /* 0x3EFE47 */
    SI(0x2C) = 2;
tail:                                            /* 0x3EFE4E */
    if (S8(0xC5) == 0) return;
    {
#if JX_SEQ_TOOTH
        int32_t ecx = SI(0x14);                  /* the tooth: the step clock stands still -- the gate MUST see it */
#else
        int32_t ecx = SI(0x14) + 1;
#endif
        int32_t eax;
        SI(0x14) = ecx;
        if (SI(0x2C) < 2) {                      /* jl 0x3EFFB8 */
            SI(0x18) = ecx;
            return;
        }
        eax = SI(0x18);
        if (ecx == eax) return;
        do {                                     /* 0x3EFE90 */
            int32_t ebp = eax + 1;
            int32_t esi = 0;
            SI(0x18) = ebp;
            if ((int8_t)S8(0xBEE) > 0) {
                uint8_t *rdi = ns + 0x326;
                do {
                    if (*(int32_t *)(rdi + 6) == ebp) {
                        uint32_t n = rdi[0];
                        if (n < 0x80) {
                            jxs_off(ns, cb, (int)n);
                            S8(0xCFC + (int8_t)rdi[1]) = 0x80;
                            rdi[0] = 0x80;
                        }
                    }
                    ++esi;
                    rdi += 12;
                } while (esi < (int8_t)S8(0xBEE));
            }
            if (SI(0x18) == SI(0xBE8)) {         /* 0x3EFEF0 */
                if (S8(0x28) != 0) {
                    int32_t bp2 = SI(0x2C);
                    if ((uint32_t)(bp2 - 1) <= 2) {
                        int k;
                        SI(0x2C) = 0;
                        for (k = 0; k < 16; ++k) {
                            uint8_t *slot = ns + 0x326 + 12 * k;
                            uint32_t n = slot[0];
                            if (n < 0x80) {
                                jxs_off(ns, cb, (int)n);
                                S8(0xCFC + (int8_t)slot[1]) = 0x80;
                                slot[0] = 0x80;
                            }
                        }
                    }
                    SI(0x2C) = bp2;
                    jxs_3F1650(ns, SQ(0x20) ? JXS_PTR(ns, SQ(0x20)) : 0, ns + 0x324);   /* +0x20 (see top) */
                    jxs_3F1B10(ns, 0);
                    S8(0x28) = 0;
                }
                jxs_play(ns, cb, S8(0xDA1) != 0);
            }
            eax = SI(0x18);
        } while (SI(0x14) != eax);
    }
}

/* ---- the note manager (jx_alloc.c's blob and list helpers) ---- */

/* 0x3F56E0 -- release every listed note into the store (list B first, then list A), then 0x3F4BC0: jmp
 * 0x3EF910, the store's reset */
static void jxm_3F56E0(uint8_t *b, uint8_t *ns, const jx_nstore_cbs *ncb, const jx_seq_cbs *cb)
{
    int32_t n;
    for (n = 0; n < 0x80; ++n) {
        if (jxl_contains(b, 0x214, n)) {
            jx_nstore_off(ns, ncb, n, 0x40);
            jxl_remove(b, 0x214, n);
        } else if (jxl_contains(b, 0x10, n)) {
            jx_nstore_off(ns, ncb, n, 0x40);
            jxl_remove(b, 0x10, n);
        }
    }
    jxs_3EF910(ns, cb);
}

/* 0x3F5910 -- the note manager's tick: at the counter's 12- (+5 = 0) or 24-tick boundary, while the flag +6
 * (set by the KEY ASSIGN setter, 0x3F2C28) is up: clear it, release and replay both note lists */
static void jxm_tick(uint8_t *b, uint8_t *ns, const jx_nstore_cbs *ncb, const jx_seq_cbs *cb)
{
    uint8_t la[0x204], lb[0x204];
    int32_t div, ebp, edi, lbcount;
    uint32_t r12;
    if (b[6] == 0) return;
    div = 24 / ((b[5] != 0) ? 1 : 2);            /* neg al; sbb; add 2; cdq; idiv */
    if (*(uint32_t *)b % (uint32_t)div != 0)     /* xor edx; div ecx */
        return;
    b[6] = 0;
    memcpy(la, b + 0x10, sizeof la);             /* the whole lists, stale entries included */
    memcpy(lb, b + 0x214, sizeof lb);
    r12 = ns[0xD88];                             /* 0x3F4C40: movzx eax, byte [rcx+0xd88] */
    jxm_3F56E0(b, ns, ncb, cb);
    for (ebp = 0; ebp < *(int32_t *)la; ++ebp) {
        int32_t n = *(int32_t *)(la + 4 + 4 * ebp);              /* 0x3F63B0 */
        jx_nstore_on5100(ns, ncb, n, b[0x528 + n]);
        jxl_add(b, 0x10, n);
    }
    lbcount = *(int32_t *)lb;
    for (edi = 0; edi < lbcount; ++edi) {
        int32_t n = *(int32_t *)(la + 4 + 4 * edi);              /* list A with list B's count: literal */
        if (jxl_contains(la, 0, n)) continue;
        jx_nstore_on5100(ns, ncb, n, b[0x528 + n]);
        jxl_add(b, 0x214, n);
    }
    *(int32_t *)(ns + 0xD88) = (int32_t)r12;     /* 0x3F5170 */
    ns[0xD84] = 1;
}

/* 0x3F84A0 -- one unit's share of the engine's tick: its note manager's counter, its tick, its store's tick */
static void jx_seq_tick_unit(uint8_t *mgr, uint8_t *ns, const jx_nstore_cbs *ncb, const jx_seq_cbs *cb)
{
    *(int32_t *)mgr += 1;                        /* inc dword [rcx] */
    jxm_tick(mgr, ns, ncb, cb);
    jxs_tick_ns(ns, cb);
}

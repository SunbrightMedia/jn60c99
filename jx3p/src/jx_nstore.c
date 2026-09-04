/* jx_nstore.c -- the JX-3P NOTE STORE object (at +0x518 of each note-manager
 * unit), transcribed bit-literal from the plugin's machine code.
 *
 * Source of truth (disasm via jx3p/tools/disasm.py):
 *   0x3F0D70  note-off core (release path)
 *   0x3F0DF0  note-on body
 *   0x3F0EF0  note-off entry: jmp 0x3F0D70
 *   0x3F0F00  queue-remove (FIFO/sorted queue at +0xBF8)
 *   0x3F5100  mov byte [rcx+0xC5],1 ; jmp 0x3F0DF0
 *
 * The state is a RAW BYTE BLOB at the plugin's own offsets, same convention
 * as jx_alloc.c, so the differential gate compares memory 1:1.
 *
 * SEAM (the one transfer outside 0x3F0000-0x3F2000):
 *   at 0x3F100E, `jmp 0x1803EF210` with rcx = obj (tail call, no other args
 *   live except edx = 0 count). Modeled as the callback below, kind
 *   JXN_CB_EF210. Everything else is transcribed in full.
 *
 * Transcription is LITERAL: each branch mirrors an instruction. Do not
 * "improve" the logic -- bit-exact or nothing (RULE 1 of the project).
 */
#include <stdint.h>

/* Field map (all READ(static) from the code above):
 *   +0x02C  dword  state/phase (queue-drain checks 1..3, resets to 0)
 *   +0x0C5  byte   set to 1 by the 0x3F5100 entry wrapper
 *   +0x0C8  dword  total held count (inc on-on, dec on-off)
 *   +0x0CC  dword  distinct-note count (inc when word goes 0->1, dec ->0)
 *   +0x0D0  word[128] per-note refcount word; bit15 sticky "released" tag
 *   +0x1D0  byte[128] per-note velocity
 *   +0x250  word   release-tag mask OR'd into refcount on note-off
 *   +0x252  word   last release-tag written
 *   +0x254  byte   return value of on/off (mode flag, set by 0x3F1030)
 *   +0xBF8  byte[128] note queue (sorted ascending; 0xFF/negative = empty)
 *   +0xC78  byte[128] per-note in-queue flag
 *   +0xCF8  dword  queue count
 *   +0xD7C  byte   top-of-queue note (0xFF when empty)
 *   +0xD88  dword  cleared on full drain
 *   +0xD8C  byte   cleared on full drain
 *   +0xD90  dword  cleared on full drain
 *   +0xDA1  byte   mode flag: nonzero = unsorted/free-slot queue mode
 * Extent: last byte touched 0xDA1 -> 0xDA2, rounded up to 16: */
#define JXN_UNIT_SZ 0xDB0

#define JXN_CB_EF210 0  /* tail jmp 0x3EF210(obj) when store fully drains */

typedef struct {
    void (*cb)(void *u, int kind, int a, int b); /* a=b=0 for EF210 */
    void *user;
} jx_nstore_cbs;

#define B8(o)   (b[(o)])
#define BI(o)   (*(int32_t *)(b + (o)))
#define BW(o)   (*(uint16_t *)(b + (o)))

static void jxn_3F0F00(uint8_t *b, const jx_nstore_cbs *cb, int note);

/* 0x3F0D70 -- note-off core. rcx=obj, edx=note. Returns al. */
static int jxn_3F0D70(uint8_t *b, const jx_nstore_cbs *cb, int note)
{
    int64_t rax = (int32_t)note;                 /* movsxd rax, edx */
    uint16_t w = BW(0xD0 + rax * 2);             /* movzx eax, word [rcx+rax*2+0xD0] */
    uint16_t ax = (uint16_t)(w & 0x7fff);        /* and ax, 0x7fff */
    if (ax == 0)                                 /* jne taken when nonzero */
        return 0;                                /* eax==0 here; caller takes al */
    ax = (uint16_t)(ax - 1);                     /* dec ax */
    ax = (uint16_t)(ax | BW(0x250));             /* or ax, word [rbx+0x250] */
    BW(0xD0 + rax * 2) = ax;                     /* store back */
    uint16_t tag = BW(0x250);                    /* movzx eax, word [rbx+0x250] */
    BI(0xC8) -= 1;                               /* dec dword [rbx+0xC8] */
    BW(0x252) = tag;                             /* mov word [rbx+0x252], ax */
    if (BW(0xD0 + rax * 2) == 0) {               /* cmp word [rcx+0xD0], 0 */
        int32_t c = BI(0xCC);
        if (c != 0)
            BI(0xCC) = c - 1;
        jxn_3F0F00(b, cb, note);                 /* call 0x3F0F00 (rcx=obj, edx=note) */
    }
    return B8(0x254);                            /* movzx eax, byte [rbx+0x254] */
}

/* 0x3F0F00 -- remove `note` from the queue at +0xBF8. rcx=obj, edx=note. */
static void jxn_3F0F00(uint8_t *b, const jx_nstore_cbs *cb, int note)
{
    int64_t r9 = (int32_t)note;                  /* movsxd r9, edx */
    if (B8(0xC78 + r9) == 0)                     /* cmp byte [r9+rcx+0xC78],0 */
        return;                                  /* je 0x3F1013 (plain ret) */
    if (B8(0xDA1) != 0) {                        /* jne 0x3F0F6C */
        /* unsorted mode: linear search for the entry */
        int32_t r8 = 0;
        int64_t rdx = 0;
        int found = 0;
        while (rdx < 0x80) {                     /* loop 0x3F0F71..0x3F0F8B */
            int32_t v = (int8_t)B8(0xBF8 + rdx); /* movsx eax, byte */
            if (v == (int32_t)r9) { found = 1; break; } /* je 0x3F0F8F */
            r8 += 1;
            rdx += 1;
        }
        if (found) {
            B8(0xBF8 + (int64_t)r8) = 0xff;      /* mov byte, 0xff */
            BI(0xCF8) -= 1;                      /* dec dword [rcx+0xCF8] */
        }
        /* both paths fall to 0x3F0FA0 */
    } else {
        /* sorted mode: shift entries above `note` down by one */
        int64_t r8cnt = BI(0xCF8);               /* movsxd r8, dword [rcx+0xCF8] */
        uint8_t r10b = 0xff;                     /* mov r10d, 0xffffffff */
        BI(0xCF8) = (int32_t)(r8cnt - 1);        /* lea eax,[r8-1]; store */
        int64_t rax = r8cnt - 1;
        if (rax >= 0) {                          /* js 0x3F0FA0 when negative */
            int64_t idx = rax;                   /* rdx = rcx+0xBF8+rax */
            for (;;) {                           /* loop 0x3F0F50 */
                int32_t v = (int8_t)B8(0xBF8 + idx); /* movsx eax, byte [rdx] */
                B8(0xBF8 + idx) = r10b;          /* mov [rdx], r10b */
                r10b = (uint8_t)v;               /* mov r10d, eax */
                if (v == (int32_t)r9)            /* je 0x3F0FA0 */
                    break;
                idx -= 1;                        /* dec rdx */
                if (idx < 0)                     /* lea rax,[r8+rdx]; jns */
                    break;                       /* jmp 0x3F0FA0 */
            }
        }
    }
    /* 0x3F0FA0 */
    B8(0xC78 + r9) = 0;                          /* clear in-queue flag */
    int32_t edx = BI(0xCF8);                     /* movsxd rdx, dword [rcx+0xCF8] */
    uint8_t r8b;
    if (edx > 0)                                 /* jle 0x3F0FBF */
        r8b = B8(0xBF7 + (int64_t)edx);          /* top entry: [rdx+rcx+0xBF7] */
    else
        r8b = 0xff;
    B8(0xD7C) = r8b;                             /* mov byte [rcx+0xD7C], r8b */
    if (edx > 0)                                 /* jg 0x3F1013 */
        return;
    BI(0xD88) = 0;
    BI(0xD90) = 0;
    B8(0xD8C) = 0;
    if (edx != 0)                                /* jne 0x3F0FE8: ZF from `test edx,edx`
                                                    above still governs -- edx<0 rets */
        return;
    if (BW(0x250) != 0)                          /* cmp word [rcx+0x250], 0 */
        return;
    if (BI(0xCC) != 0)                           /* cmp dword [rcx+0xCC], 0 */
        return;
    int32_t eax = BI(0x2C);                      /* mov eax, dword [rcx+0x2C] */
    if ((uint32_t)(eax - 1) > 2)                 /* dec; cmp 2; ja */
        return;
    BI(0x2C) = 0;                                /* mov dword [rcx+0x2C], 0 */
    if (cb && cb->cb)                            /* jmp 0x3EF210 (rcx=obj) -- SEAM */
        cb->cb(cb->user, JXN_CB_EF210, 0, 0);
}

/* 0x3F0DF0 -- note-on body. rcx=obj, edx=note, r8d=vel. Returns al. */
static int jxn_3F0DF0(uint8_t *b, const jx_nstore_cbs *cb, int note, int vel)
{
    int64_t r10 = (int32_t)note;                 /* movsxd r10, edx */
    if (vel == 0)                                /* test r8d,r8d; jne */
        return jxn_3F0D70(b, cb, note);          /* jmp 0x3F0D70 */
    uint16_t dx = BW(0xD0 + r10 * 2);            /* movzx edx, word */
    uint16_t ax = (uint16_t)(dx & 0x7fff);       /* and ax, 0x7fff */
    if (ax == 0x7fff)                            /* cmp; jne */
        return 1;                                /* mov al,1; ret */
    ax = (uint16_t)(ax + 1);                     /* inc ax */
    BW(0xD0 + r10 * 2) = ax;                     /* store (bit15 dropped, literal) */
    BI(0xC8) += 1;                               /* inc dword [rcx+0xC8] */
    if (dx == 0)                                 /* test dx,dx; jne */
        BI(0xCC) += 1;                           /* inc dword [rcx+0xCC] */
    int inq = (B8(0xC78 + r10) != 0);            /* cmp byte [r10+rcx+0xC78],0 */
    B8(0x1D0 + r10) = (uint8_t)vel;              /* mov byte [r10+rcx+0x1D0], r8b */
    if (inq)                                     /* jne 0x3F0EE0 */
        return B8(0x254);
    int64_t rax;
    if (B8(0xDA1) != 0) {                        /* jne 0x3F0E96 */
        /* unsorted mode: first negative (free) slot */
        int32_t edx2 = 0;
        int64_t i = 0;
        for (;;) {                               /* loop 0x3F0EA0 */
            if ((int8_t)B8(0xBF8 + i) < 0)       /* jl 0x3F0EBF */
                break;
            edx2 += 1;
            i += 1;
            if (i >= 0x80)                       /* cmp rax, 0x80; jl */
                return B8(0x254);                /* no slot: ret without insert */
        }
        rax = (int32_t)edx2;                     /* movsxd rax, edx */
    } else {
        /* sorted mode: shift greater-or-equal entries up */
        int64_t r9 = BI(0xCF8);                  /* movsxd r9, dword [rcx+0xCF8] */
        int64_t rdx = r9;
        int32_t r9d = (int32_t)r9;
        if ((int32_t)r9 > 0) {                   /* jle 0x3F0E91 */
            for (;;) {                           /* loop 0x3F0E70 */
                int32_t r8v = (int8_t)B8(0xBF7 + rdx); /* movsx r8d, byte */
                if (r8v < (int32_t)r10)          /* cmp r8d,r10d; jl */
                    break;
                B8(0xBF8 + rdx) = (uint8_t)r8v;  /* shift up */
                r9d -= 1;                        /* dec r9d */
                rdx -= 1;                        /* dec rdx */
                if (rdx <= 0)                    /* test rdx,rdx; jg */
                    break;
            }
        }
        rax = r9d;                               /* movsxd rax, r9d */
    }
    /* 0x3F0EC2 */
    B8(0xBF8 + rax) = (uint8_t)r10;              /* mov byte [rax+rcx+0xBF8], r10b */
    B8(0xC78 + r10) = 1;                         /* in-queue flag */
    BI(0xCF8) += 1;                              /* inc dword [rcx+0xCF8] */
    B8(0xD7C) = (uint8_t)r10;                    /* newest note */
    return B8(0x254);                            /* 0x3F0EE0 */
}

/* ---- exports ---- */

int jx_nstore_on(uint8_t *b, const jx_nstore_cbs *cb, int note, int vel)
{
    return jxn_3F0DF0(b, cb, note, vel);
}

int jx_nstore_off(uint8_t *b, const jx_nstore_cbs *cb, int note, int vel)
{
    (void)vel;                                   /* 0x3F0EF0: jmp 0x3F0D70; r8d dead */
#if JX_NSTORE_TOOTH
    /* the tooth: skip one counter update -- the gate MUST catch it */
    if (BI(0xC8) > 0) BI(0xC8) -= 1;
#endif
    return jxn_3F0D70(b, cb, note);
}

/* 0x3F5100: mov byte [rcx+0xC5],1 ; jmp 0x3F0DF0 (tail call: al flows out) */
int jx_nstore_on5100(uint8_t *b, const jx_nstore_cbs *cb, int note, int vel)
{
    B8(0xC5) = 1;
    return jxn_3F0DF0(b, cb, note, vel);
}

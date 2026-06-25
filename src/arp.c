/* arp.c — faithful C99 transcription of the JUNO-60 CArpeggio step/clock engine.
 *
 * Source of truth: allcode/decomp_380000.c and decomp_3C0000.c (image base
 * 0x7FF91DC60000). Each function below cites its sub_/rva. Offset arithmetic and
 * control flow are kept VERBATIM from the decompile; the only deliberate
 * deviations are:
 *   (1) vtable note emission -> juno_arp_callbacks (documented at each site);
 *   (2) the +3480 direction selector is a real C function pointer (juno_arp_selector)
 *       stored in the faithful struct, dispatched exactly where the decompile does
 *       `(*(fnptr*)(a1+3480))(a1, v7, v2)`.
 *
 * Build with -fno-strict-aliasing.
 */
#include "arp.h"
#include <string.h>

/* IDA pseudocode primitive types, matching src/master_render.c. */
typedef uint8_t  _BYTE;
typedef uint16_t _WORD;
typedef uint32_t _DWORD;
typedef uint64_t _QWORD;
typedef int64_t  __int64;
#define __int16   short            /* so `unsigned __int16` -> `unsigned short` */
#define __int8    char             /* so `unsigned __int8`  -> `unsigned char`  */
#define LODWORD(x)  (*((_DWORD *)&(x)))
#define LOBYTE(x)   (*((_BYTE  *)&(x)))

/* Offset accessors into the faithful state block, exactly as voice_render.c:
 *   JF = *(float*), JI = *(int32*). Bytes are read via *(a1+off) directly. */
#undef JF
#undef JI
#define JI(st, off)  (*(int32_t *)((unsigned char *)(st) + (off)))

/* The wrapper carrying the callbacks is found by container_of from the faithful
 * state pointer: the faithful `st` is the first member of juno_arp, so the
 * wrapper base == st. This lets the verbatim functions (which only have `a1`)
 * reach the host callbacks without polluting the byte-exact struct. */
static juno_arp *arp_from_st(unsigned char *a1)
{
    return (juno_arp *)a1; /* st is the first member of juno_arp */
}

/* Note emission dispatch. The decompile uses:
 *   noteOn  : (**a1)(a1, note, vel, key)        vtable slot 0
 *   noteOff : (*(*a1 + 8))(a1, note, 64)        vtable slot 1
 * We map slot 0 -> cb.note_on, slot 1 -> cb.note_off. */
static void arp_note_on(unsigned char *a1, int note, int vel, int key)
{
    juno_arp *arp = arp_from_st(a1);
    if (arp->cb.note_on)
        arp->cb.note_on(arp->cb.ud, note, vel, key);
}
static void arp_note_off(unsigned char *a1, int note, int vel)
{
    juno_arp *arp = arp_from_st(a1);
    if (arp->cb.note_off)
        arp->cb.note_off(arp->cb.ud, note, vel);
}

/* The +3480 selector slot holds a juno_arp_selector. */
#define ARP_SEL(a1)  (*(juno_arp_selector *)((unsigned char *)(a1) + 3480))

/* Forward decls of internal transcriptions. */
static void     sub_7FF91E01D3A0(unsigned char *a1);   /* flush all voices */
static __int64  sub_7FF91E020E50(unsigned __int16 *a1, unsigned __int16 a2); /* LCG */
static void     sub_7FF91E01F2A0(unsigned char *a1, int a2);
static __int16  sub_7FF91E01F110_pub(unsigned char *a1, __int64 a2);

/* ======================================================================== */
/* LCG random.  sub_7FF91E020E50 @ rva 0x3C0E50.                            */
/*   x = 18813*x + 1 ;  return a2 * x / 0xFFFF                              */
/* The PRNG state lives at +8 (seeded 31415 in the ctor).                  */
/* ======================================================================== */
static __int64 sub_7FF91E020E50(unsigned __int16 *a1, unsigned __int16 a2)
{
    unsigned __int16 v2; // r8

    v2 = 18813 * *a1 + 1;
    *a1 = v2;
    return (unsigned int)(a2 * v2 / 0xFFFF);
}

/* sub_7FF91E020E40 @ rva 0x3C0E40 — seed the PRNG word. */
static void sub_7FF91E020E40(unsigned __int16 *a1, __int16 a2)
{
    *a1 = a2;
}

/* ======================================================================== */
/* CArpeggio constructor.  sub_7FF91E01D270 @ rva 0x3BD270.                 */
/* ======================================================================== */
static __int64 sub_7FF91E01D270(__int64 a1_)
{
    unsigned char *a1 = (unsigned char *)a1_;

    /* *(_QWORD *)a1 = &CArpeggio::vftable;  — the vtable ptr. We do not install
     * a real vtable (note emission is routed through juno_arp_callbacks); the
     * wrapper init wires the callbacks instead. Slot left zero. */
    *(_QWORD *)(a1 + 0) = 0;

    sub_7FF91E020E40((unsigned __int16 *)(a1 + 8), 31415);
    *(_BYTE *)(a1 + 10) = 0;
    *(_QWORD *)(a1 + 20) = 0;
    *(_QWORD *)(a1 + 32) = 0;
    *(_BYTE *)(a1 + 40) = 0;
    *(_DWORD *)(a1 + 44) = 0;
    *(_DWORD *)(a1 + 3464) = 0;
    *(_BYTE *)(a1 + 3468) = 0;
    *(_QWORD *)(a1 + 3472) = 0;
    *(_WORD *)(a1 + 3488) = 0;
    *(_DWORD *)(a1 + 3456) = -1;
    *(_WORD *)(a1 + 3460) = 256;
    *(_BYTE *)(a1 + 3053) = 16;
    return a1_;
}

/* ======================================================================== */
/* sub_7FF91E01D3A0 @ rva 0x3BD3A0 — flush all 16 voice slots (note-off).   */
/*   noteOff = (*(*a1+8))(a1, note, 64)  -> arp_note_off.                   */
/* ======================================================================== */
static void sub_7FF91E01D3A0(unsigned char *a1)
{
    unsigned char *v2; // rbx
    __int64 v3; // rdi
    __int64 v4; // rdx

    v2 = a1 + 806;
    v3 = 16;
    do
    {
        v4 = *v2;
        if ( (unsigned int)v4 < 0x80 )
        {
            arp_note_off(a1, (int)v4, 64);            /* (*(*a1+8))(a1,v4,64) */
            a1[(char)v2[1] + 3324] = 0x80;
            *v2 = 0x80;
        }
        v2 += 12;
        --v3;
    }
    while ( v3 );
}

/* ======================================================================== */
/* DIRECTION SELECTORS                                                       */
/* Each reads the sorted held list +3064, maintains its cursor +3464, sets   */
/* the octave-wrap latch +3468 at sequence ends, and returns the chosen key. */
/* ======================================================================== */

/* UP.  sub_7FF91E01EC80 @ rva 0x3BEC80. */
int64_t juno_arp_sel_up(unsigned char *a1, int a2, int64_t a3)
{
    __int64 v1; // r11
    int v3; // edx
    int v4; // ecx
    int v5; // eax
    int v6; // r10d
    __int64 i; // r9
    int v8; // edx
    (void)a2; (void)a3;

    v1 = *(int *)(a1 + 3320);
    v3 = *(_DWORD *)(a1 + 3320) - *(char *)(a1 + 3054);
    v4 = 0;
    if ( *(_DWORD *)(a1 + 56) > (unsigned)v3 )
        *(_DWORD *)(a1 + 56) = 0;
    v5 = *(_DWORD *)(a1 + 3464);
    if ( v5 >= (int)v1 )
    {
        *(_DWORD *)(a1 + 3464) = 0;
        v5 = 0;
        *(_BYTE *)(a1 + 3468) = 1;
    }
    v6 = -1;
    v8 = v5;
    for ( i = 0; i < 128; ++i )
    {
        v8 = v5;
        if ( v4 >= (int)v1 )
            break;
        v6 = *(char *)(i + a1 + 3064);
        v5 = *(_DWORD *)(a1 + 3464);
        if ( v6 > -1 )
        {
            v8 = *(_DWORD *)(a1 + 3464);
            if ( v5 == v4 )
                break;
            ++v4;
        }
        v8 = *(_DWORD *)(a1 + 3464);
    }
    if ( v6 < 0 )
        v6 = *(char *)(v1 + a1 + 3063);
    if ( !*(_BYTE *)(a1 + 3460) )
        *(_BYTE *)(a1 + 3460) = 1;
    *(_DWORD *)(a1 + 3464) = v8 + 1;
    return (unsigned int)v6;
}

/* DOWN.  sub_7FF91E01EB10 @ rva 0x3BEB10. */
int64_t juno_arp_sel_down(unsigned char *a1, int a2, int64_t a3)
{
    int v1; // eax
    __int64 v3; // r11
    int v4; // ecx
    int v6; // edx
    int v7; // eax
    int v8; // eax
    int v9; // edx
    int v10; // r10d
    __int64 i; // r9
    int v12; // edx
    (void)a2; (void)a3;

    v1 = *(char *)(a1 + 3054);
    v3 = *(int *)(a1 + 3320);
    v4 = 0;
    v6 = v3 - v1;
    v7 = 0;
    if ( !((int)v3 - v1 < 0) )
        v7 = v6;
    if ( *(_DWORD *)(a1 + 56) > (unsigned)v7 )
        *(_DWORD *)(a1 + 56) = 0;
    v8 = *(_DWORD *)(a1 + 3464);
    v9 = v3 - 1;
    if ( v8 > (int)v3 - 1 )
    {
        do
            --v8;
        while ( v8 > v9 );
        *(_DWORD *)(a1 + 3464) = v8;
    }
    if ( v8 < 0 )
    {
        *(_DWORD *)(a1 + 3464) = v9;
        v8 = v3 - 1;
        *(_BYTE *)(a1 + 3468) = 1;
    }
    v10 = -1;
    v12 = v8;
    for ( i = 0; i < 128; ++i )
    {
        v12 = v8;
        if ( v4 >= (int)v3 )
            break;
        v10 = *(char *)(i + a1 + 3064);
        v8 = *(_DWORD *)(a1 + 3464);
        if ( v10 > -1 )
        {
            v12 = *(_DWORD *)(a1 + 3464);
            if ( v8 == v4 )
                break;
            ++v4;
        }
        v12 = *(_DWORD *)(a1 + 3464);
    }
    if ( v10 < 0 )
        v10 = *(char *)(v3 + a1 + 3063);
    if ( !*(_BYTE *)(a1 + 3460) )
        *(_BYTE *)(a1 + 3460) = 1;
    *(_DWORD *)(a1 + 3464) = v12 - 1;
    return (unsigned int)v10;
}

/* UP-DOWN / pendulum.  sub_7FF91E01E990 @ rva 0x3BE990. */
int64_t juno_arp_sel_updown(unsigned char *a1, int a2, int64_t a3)
{
    int v1; // r8d
    __int64 v2; // r10
    int v3; // eax
    int v4; // eax
    int v5; // ebx
    __int64 v6; // r9
    int v7; // r11d
    int v8; // edx
    __int64 result; // rax
    (void)a2; (void)a3;

    v1 = 0;
    v2 = *(int *)(a1 + 3320);
    v3 = 0;
    if ( (int)(*(_DWORD *)(a1 + 3320) - *(char *)(a1 + 3054)) >= 0 )
        v3 = *(_DWORD *)(a1 + 3320) - *(char *)(a1 + 3054);
    if ( *(_DWORD *)(a1 + 56) > (unsigned)(2 * v3 - 1) )
        *(_DWORD *)(a1 + 56) = 0;
    v4 = *(_DWORD *)(a1 + 3464);
    if ( *(_BYTE *)(a1 + 3461) )
    {
        if ( v4 >= (int)v2 )
        {
            if ( *(_DWORD *)(a1 + 3472) == *(_DWORD *)(a1 + 3476) )
            {
                if ( (int)v2 <= 1 )
                {
                    v4 = 0;
                    *(_BYTE *)(a1 + 3468) = 1;
                    *(_DWORD *)(a1 + 3464) = 0;
                    *(_BYTE *)(a1 + 3461) = 0;
                }
                else
                {
                    v4 = v2 - 2;
                    *(_BYTE *)(a1 + 3461) = 0;
                    *(_DWORD *)(a1 + 3464) = v2 - 2;
                }
                goto LABEL_19;
            }
            *(_DWORD *)(a1 + 3464) = 0;
            v4 = 0;
            goto LABEL_18;
        }
    }
    else if ( v4 < 0 )
    {
        if ( !*(_DWORD *)(a1 + 3472) )
        {
            if ( (int)v2 <= 1 )
            {
                v4 = 0;
                *(_BYTE *)(a1 + 3468) = 1;
                *(_DWORD *)(a1 + 3464) = 0;
                *(_BYTE *)(a1 + 3461) = 1;
            }
            else
            {
                v4 = 1;
                *(_BYTE *)(a1 + 3461) = 1;
                *(_DWORD *)(a1 + 3464) = 1;
            }
            goto LABEL_19;
        }
        v4 = v2 - 1;
        *(_DWORD *)(a1 + 3464) = v2 - 1;
LABEL_18:
        *(_BYTE *)(a1 + 3468) = 1;
    }
LABEL_19:
    v5 = -1;
    v6 = 0;
    v7 = -1;
    v8 = v4;
    do
    {
        v8 = v4;
        if ( v1 >= (int)v2 )
            break;
        v7 = *(char *)(v6 + a1 + 3064);
        v4 = *(_DWORD *)(a1 + 3464);
        if ( v7 > -1 )
        {
            v8 = *(_DWORD *)(a1 + 3464);
            if ( v4 == v1 )
                break;
            ++v1;
        }
        ++v6;
        v8 = *(_DWORD *)(a1 + 3464);
    }
    while ( v6 < 128 );
    if ( v7 < 0 )
        v7 = *(char *)(v2 + a1 + 3063);
    if ( !*(_BYTE *)(a1 + 3460) )
        *(_BYTE *)(a1 + 3460) = 1;
    result = (unsigned int)v7;
    if ( *(_BYTE *)(a1 + 3461) )
        v5 = 1;
    *(_DWORD *)(a1 + 3464) = v8 + v5;
    return result;
}

/* RANDOM.  sub_7FF91E01EBF0 @ rva 0x3BEBF0. Uses the LCG sub_7FF91E020E50. */
int64_t juno_arp_sel_random(unsigned char *a1, int a2, int64_t a3)
{
    unsigned __int16 v2; // ax
    __int64 v3; // rdx
    unsigned __int16 v4; // ax
    int v5; // r9d
    int v6; // r8d
    int v7; // eax
    __int64 v8; // rcx
    int v9; // edx
    (void)a2; (void)a3;

    v2 = (unsigned __int16)sub_7FF91E020E50((unsigned __int16 *)(a1 + 8),
                                            (unsigned __int16)(*(_WORD *)(a1 + 3476) + 1));
    v3 = *(unsigned __int16 *)(a1 + 3320);
    *(_DWORD *)(a1 + 3472) = v2;
    v4 = (unsigned __int16)sub_7FF91E020E50((unsigned __int16 *)(a1 + 8), (unsigned __int16)v3);
    v5 = *(_DWORD *)(a1 + 3320);
    v6 = v4;
    v7 = 0;
    *(_DWORD *)(a1 + 3464) = v6;
    v8 = 0;
    v9 = -1;
    do
    {
        if ( v7 >= v5 )
            break;
        v9 = *(char *)(v8 + a1 + 3064);
        if ( v9 > -1 )
        {
            if ( v6 == v7 )
                return (unsigned int)v9;
            ++v7;
        }
        ++v8;
    }
    while ( v8 < 128 );
    return (unsigned int)v9;
}

/* ORDER / as-played fallback.  sub_7FF91E01ED30 @ rva 0x3BED30. */
int64_t juno_arp_sel_order(unsigned char *a1, int a2, int64_t a3)
{
    __int64 result; // rax
    (void)a3;

    result = (unsigned int)*(char *)(a2 + a1 + 3064);
    if ( (int)result < 0 )
        return (unsigned int)*(char *)(*(int *)(a1 + 3320) + a1 + 3063);
    return result;
}

/* Transpose passthrough (mode 11).  sub_7FF91E01ED50 @ rva 0x3BED50. */
int64_t juno_arp_sel_transpose(unsigned char *a1, int a2, int64_t a3)
{
    char v2; // r10
    int v4; // r9d
    (void)a3;

    v2 = *(_BYTE *)(a1 + 3452);
    if ( v2 < 0 )
        return 0xFFFFFFFFLL;
    v4 = v2 + *(unsigned __int8 *)(a1 + 12 * (a2 + 67LL)) - *(unsigned __int8 *)(a1 + 3060);
    if ( !*(_BYTE *)(v4 + a1 + 3192) )
        *(_BYTE *)(v4 + a1 + 464) = *(_BYTE *)(v2 + a1 + 464);
    return (unsigned int)v4;
}

/* ======================================================================== */
/* Mode installer.  sub_7FF91E01FCB0 @ rva 0x3BFCB0.                        */
/* Installs the +3480 selector ptr by mode index (docs/ARP_DSP.md §5).      */
/* Modes 15/16/17/18 -> UP/DOWN/UP-DOWN/RANDOM (transcribed); 11 -> transpose;*/
/* default -> ORDER. Modes 0-10,13,14,19,20 share the held-list-walk shape   */
/* but were NOT individually traced (Open Questions §6); we install the      */
/* ORDER fallback for them and flag it, rather than invent their ordering.   */
/* ======================================================================== */
static void sub_7FF91E01FCB0(unsigned char *a1, int a2)
{
    switch ( a2 )
    {
        /* --- transcribed direction modes --- */
        case 15: ARP_SEL(a1) = juno_arp_sel_up;        break; /* sub_7FF91E01EC80 */
        case 16: ARP_SEL(a1) = juno_arp_sel_down;      break; /* sub_7FF91E01EB10 */
        case 17: ARP_SEL(a1) = juno_arp_sel_updown;    break; /* sub_7FF91E01E990 */
        case 18: ARP_SEL(a1) = juno_arp_sel_random;    break; /* sub_7FF91E01EBF0 */
        case 11: ARP_SEL(a1) = juno_arp_sel_transpose; break; /* sub_7FF91E01ED50 */

        /* --- not transcribed: same selector shape, ordering untraced --- */
        /* case 0:  sub_7FF91E01EFC0 — not transcribed */
        /* case 1:  sub_7FF91E01F060 — not transcribed */
        /* case 2:  sub_7FF91E01F0C0 — not transcribed */
        /* case 3:  sub_7FF91E01E6E0 — not transcribed */
        /* case 4:  sub_7FF91E01E790 — not transcribed */
        /* case 5:  sub_7FF91E01E800 — not transcribed */
        /* case 6:  sub_7FF91E01E400 — not transcribed */
        /* case 7:  sub_7FF91E01E4E0 — not transcribed */
        /* case 8:  sub_7FF91E01E560 — not transcribed */
        /* case 9:  sub_7FF91E01EDB0 — chord build, not transcribed */
        /* case 10: sub_7FF91E01EEC0 — not transcribed */
        /* case 13: sub_7FF91E01E940 — not transcribed */
        /* case 14: sub_7FF91E01EF80 — not transcribed */
        /* case 19: sub_7FF91E01E850 — not transcribed */
        /* case 20: sub_7FF91E01E5C0 — not transcribed */

        default: ARP_SEL(a1) = juno_arp_sel_order;     break; /* sub_7FF91E01ED30 */
    }
}

/* ======================================================================== */
/* Held-note add.  sub_7FF91E023440 @ rva 0x3C3440.                         */
/* Inserts key into sorted list +3064; a3==0 routes to remove.             */
/* Returns *(_BYTE*)(a1+596). The flat (+3489) variant appends at tail.    */
/* ======================================================================== */
static char sub_7FF91E023440(unsigned char *a1, unsigned int a2, int a3)
{
    __int64 v3; // r10
    __int16 v5; // dx
    int v6; // zf (decompile: bool v6)
    __int64 v7; // r9
    __int64 v8; // rdx
    int v9; // r8d
    __int64 v10; // rax
    int v11; // edx
    __int64 v12; // rax

    *(_BYTE *)(a1 + 197) = 1;
    v3 = (int)a2;
    if ( !a3 )
        return (char)sub_7FF91E01F110_pub(a1, a2);
    v5 = *(_WORD *)(a1 + 2LL * (int)a2 + 208);
    if ( (v5 & 0x7FFF) == 0x7FFF )
        return 1;
    *(_WORD *)(a1 + 2 * v3 + 208) = (v5 & 0x7FFF) + 1;
    ++*(_DWORD *)(a1 + 200);
    if ( !v5 )
        ++*(_DWORD *)(a1 + 204);
    v6 = *(_BYTE *)(v3 + a1 + 3192) == 0;
    *(_BYTE *)(v3 + a1 + 464) = a3;
    if ( v6 )
    {
        if ( *(_BYTE *)(a1 + 3489) )
        {
            v11 = 0;
            v12 = 0;
            while ( *(char *)(a1 + v12 + 3064) >= 0 )
            {
                ++v11;
                if ( ++v12 >= 128 )
                    return *(_BYTE *)(a1 + 596);
            }
            v10 = v11;
        }
        else
        {
            v7 = *(int *)(a1 + 3320);
            v8 = v7;
            if ( (int)v7 > 0 )
            {
                do
                {
                    v9 = *(char *)(a1 + v8 + 3063);
                    if ( v9 < (int)v3 )
                        break;
                    *(_BYTE *)(v8 + a1 + 3064) = v9;
                    LODWORD(v7) = v7 - 1;
                    --v8;
                }
                while ( v8 > 0 );
            }
            v10 = (int)v7;
        }
        *(_BYTE *)(v10 + a1 + 3064) = v3;
        *(_BYTE *)(v3 + a1 + 3192) = 1;
        ++*(_DWORD *)(a1 + 3320);
        *(_BYTE *)(a1 + 3452) = v3;
    }
    return *(_BYTE *)(a1 + 596);
}

/* ======================================================================== */
/* Held-note remove.  sub_7FF91E01F110 @ rva 0x3BF110 -> sub_7FF91E01F2A0.  */
/* ======================================================================== */
__int16 sub_7FF91E01F110_pub(unsigned char *a1, __int64 a2)
{
    __int64 v3; // rcx
    __int16 result; // ax
    __int16 v5; // ax
    int v6; // eax

    v3 = (__int64)a1 + 2LL * (int)a2;
    result = *(_WORD *)(v3 + 208) & 0x7FFF;
    if ( result )
    {
        *(_WORD *)(v3 + 208) = *(_WORD *)(a1 + 592) | (result - 1);
        v5 = *(_WORD *)(a1 + 592);
        --*(_DWORD *)(a1 + 200);
        *(_WORD *)(a1 + 594) = v5;
        if ( !*(_WORD *)(v3 + 208) )
        {
            v6 = *(_DWORD *)(a1 + 204);
            if ( v6 )
                *(_DWORD *)(a1 + 204) = v6 - 1;
            sub_7FF91E01F2A0(a1, (int)a2);
        }
        return *(unsigned __int8 *)(a1 + 596);
    }
    return result;
}

/* sub_7FF91E01F2A0 @ rva 0x3BF2A0 — list compaction + last-key update + flush. */
static void sub_7FF91E01F2A0(unsigned char *a1, int a2)
{
    __int64 v2; // r9
    __int64 v3; // r8
    char v4; // r10
    unsigned char *v5; // rdx
    int v6; // eax
    int v7; // r8d
    __int64 v8; // rdx
    __int64 v9; // rdx
    unsigned char v10; // r8

    v2 = a2;
    if ( a1[a2 + 3192] )
    {
        if ( a1[3489] )
        {
            v7 = 0;
            v8 = 0;
            while ( (_DWORD)(char)a1[v8 + 3064] != (_DWORD)v2 )
            {
                ++v7;
                if ( ++v8 >= 128 )
                    goto LABEL_13;
            }
            a1[v7 + 3064] = -1;
            --*((_DWORD *)a1 + 830);   /* a1+3320 */
        }
        else
        {
            v3 = *((int *)a1 + 830);    /* a1+3320 */
            v4 = -1;
            *((_DWORD *)a1 + 830) = v3 - 1;
            if ( v3 - 1 >= 0 )
            {
                v5 = &a1[v3 + 3063];
                do
                {
                    v6 = (char)*v5;
                    *v5 = v4;
                    v4 = v6;
                    if ( (_DWORD)v6 == (_DWORD)v2 )
                        break;
                    --v5;
                }
                while ( (__int64)&v5[-3064LL - (__int64)a1] >= 0 );
            }
        }
LABEL_13:
        a1[v2 + 3192] = 0;
        v9 = *((int *)a1 + 830);        /* a1+3320 */
        if ( (int)v9 <= 0 )
            v10 = -1;
        else
            v10 = a1[v9 + 3063];
        a1[3452] = v10;
        if ( (int)v9 <= 0 )
        {
            *((_DWORD *)a1 + 866) = 0;   /* a1+3464 */
            *((_DWORD *)a1 + 868) = 0;   /* a1+3472 */
            a1[3468] = 0;
            if ( !(_DWORD)v9
              && !*((_WORD *)a1 + 296)   /* a1+592 */
              && !*((_DWORD *)a1 + 51)   /* a1+204 */
              && (unsigned int)(*((_DWORD *)a1 + 11) - 1) <= 2 )  /* a1+44 */
            {
                *((_DWORD *)a1 + 11) = 0; /* a1+44 */
                sub_7FF91E01D3A0(a1);
            }
        }
    }
}

/* ======================================================================== */
/* Scanner — the per-tick step engine.  sub_7FF91E020260 @ rva 0x3C0260.    */
/*   noteOn  : (**a1)(a1, note, vel, key)   -> arp_note_on                  */
/*   noteOff : (*(*a1+8))(a1, note, 64)     -> arp_note_off                 */
/*   selector: (*(fnptr*)(a1+3480))(a1, v7, v2) -> ARP_SEL(a1)(a1, v7, v2)  */
/* ======================================================================== */
static __int64 sub_7FF91E020260(unsigned char *a1)
{
    __int64 v2; // r8
    int v3; // ecx
    int v4; // eax
    unsigned char *v5; // rsi
    int v6; // edi
    int v7; // ebp
    __int64 result; // rax
    __int64 v9; // r13
    int v10; // eax
    unsigned int v11; // r12d
    int v12; // eax
    __int64 v13; // r15
    __int64 v14; // rcx
    __int64 v15; // r14
    __int64 v16; // rcx
    __int64 v17; // rdx
    __int64 v18; // r14
    __int64 v19; // rdx
    int v20; // ecx
    int v21; // eax
    int v22; // eax
    int v23; // eax

    v2 = 0;
    v3 = *(_DWORD *)(a1 + 3056) + 1;
    v4 = *(char *)(a1 + 3055);
    *(_DWORD *)(a1 + 3056) = v3;
    if ( v3 >= v4 )
    {
        ++*(_DWORD *)(a1 + 52);
        v3 = 0;
        ++*(_DWORD *)(a1 + 56);
        *(_DWORD *)(a1 + 3056) = 0;
    }
    v5 = a1 + 804;
    v6 = -1;
    v7 = 0;
    result = 3LL * v3;
    (void)result;
    v9 = ((__int64)v3 << 6) + (__int64)a1 + 996;
    *(_DWORD *)(a1 + 3048) += *(unsigned __int16 *)(a1 + 6LL * v3 + 610);
    if ( *(char *)(a1 + 3054) > 0 )
    {
        do
        {
            v10 = v6;
            v11 = *(_BYTE *)v9 & 0x7F;
            if ( (*(_BYTE *)v9 & 0x7F) != 0 )
            {
                if ( *(int *)(a1 + 16) < 11 )
                {
                    if ( *(_DWORD *)(a1 + 3320) )
                    {
                        v12 = (int)ARP_SEL(a1)(a1, (unsigned int)v7, v2);
                        v13 = v12;
                        if ( v12 >= 0 )
                        {
                            v14 = *(unsigned __int8 *)(v12 + (__int64)a1 + 3324);
                            v15 = v12;
                            if ( (unsigned int)v14 >= 0x80 )
                                goto LABEL_16;
                            if ( (int)v14 >= v7 )
                            {
                                v16 = v14 + 67;
                                v17 = *(unsigned __int8 *)(a1 + 12 * v16 + 2);
                                v18 = (__int64)a1 + 12 * v16;
                                if ( (unsigned int)v17 < 0x80 )
                                {
                                    arp_note_off(a1, (int)v17, 64);
                                    *(_BYTE *)(*(char *)(v18 + 3) + (__int64)a1 + 3324) = 0x80;
                                    *(_BYTE *)(v18 + 2) = 0x80;
                                }
                                v15 = v13;
LABEL_16:
                                v19 = v5[2];
                                if ( (unsigned int)v19 < 0x80 )
                                {
                                    arp_note_off(a1, (int)v19, 64);
                                    *(_BYTE *)((char)v5[3] + (__int64)a1 + 3324) = 0x80;
                                    v5[2] = 0x80;
                                }
                                if ( *(_BYTE *)(a1 + 3468) )
                                {
                                    v20 = *(_DWORD *)(a1 + 3476);
                                    if ( v20 )
                                    {
                                        v21 = *(_DWORD *)(a1 + 3472);
                                        *(_BYTE *)(a1 + 3468) = 0;
                                        if ( v20 < 0 )
                                        {
                                            v23 = v21 - 1;
                                            if ( v23 < v20 )
                                                v23 = 0;
LABEL_25:
                                            *(_DWORD *)(a1 + 3472) = v23;
                                        }
                                        else
                                        {
                                            v22 = v21 + 1;
                                            *(_DWORD *)(a1 + 3472) = v22;
                                            if ( v22 > v20 )
                                            {
                                                v23 = 0;
                                                goto LABEL_25;
                                            }
                                        }
                                    }
                                }
                                v2 = (unsigned int)(v13 + 12 * *(_DWORD *)(a1 + 3472));
                                if ( (int)v2 > 127 )
                                    v2 = -12 - 12 * (((int)v2 - 128) / 0xCu) + (unsigned int)v2;
                                if ( (int)v2 < 0 )
                                    v2 = (unsigned int)v2 + 12 * (~(_DWORD)v2 / 0xCu) + 12;
                                if ( *(_BYTE *)(a1 + 597) )
                                {
                                    if ( v6 >= (int)v2 )
                                        v2 = (unsigned int)v6;
                                    v6 = v2;
                                }
                                else
                                {
                                    *(_BYTE *)(v15 + (__int64)a1 + 3324) = v7;
                                    v5[3] = v13;
                                    if ( *(_BYTE *)(a1 + 196) )
                                        v11 = *(char *)(v15 + (__int64)a1 + 464);
                                    v5[2] = v2;
                                    *((_DWORD *)v5 + 2) = *(_DWORD *)(a1 + 24)
                                                        + *(unsigned __int16 *)(v9 + 2);
                                    arp_note_on(a1, (unsigned __int8)v2, v11,
                                                (unsigned int)*(char *)(v15 + (__int64)a1 + 464));
                                }
                            }
                        }
                    }
                }
                else
                {
                    v6 = *v5;
                    if ( v10 >= v6 )
                        v6 = v10;
                }
            }
            result = (unsigned int)*(char *)(a1 + 3054);
            ++v7;
            v5 += 12;
            v9 += 4;
        }
        while ( v7 < (int)result );
    }
    return result;
}

/* ======================================================================== */
/* Clock driver.  sub_7FF91E01DEA0 @ rva 0x3BDEA0.                          */
/* Advances +20 by host position and chases +24, firing the scanner each    */
/* time +24 reaches +3048, and sweeping the 16 voice slots for note-offs.   */
/* NOTE: the original increments +20 by 1 per call. We call it nsamples      */
/* times from juno_arp_clock. The pattern-reload branch (+40 flag) calls the */
/* CKbdArp expander sub_7FF91E01F9F0 which is NOT transcribed; that path is  */
/* only taken when a preset is staged (+40 set), which the faithful-core     */
/* tests never set, so it is unreachable here and elided (flagged below).    */
/* sub_7FF91E0204E0 (the +3489 expanded scanner) is likewise not transcribed.*/
/* ======================================================================== */
static void sub_7FF91E01DEA0(unsigned char *a1)
{
    int v1; // edx
    int v3; // ecx
    int v4; // ecx
    int v5; // ecx
    int v6; // eax
    int v7; // ecx
    int v8; // cc (bool)
    int v9; // eax
    int v10; // ebp
    int v11; // esi
    unsigned char *v12; // rdi
    __int64 v13; // rdx
    int v14; // ebp
    unsigned char *v15; // rdi
    __int64 v16; // rsi
    __int64 v17; // rdx

    v1 = *(_DWORD *)(a1 + 48);
    if ( v1 )
        *(_DWORD *)(a1 + 48) = --v1;
    v3 = *(_DWORD *)(a1 + 44);
    if ( !v3 )
    {
        if ( !*(_DWORD *)(a1 + 3320) && !*(_WORD *)(a1 + 592) && !*(_DWORD *)(a1 + 204) )
            goto LABEL_29;
        goto LABEL_27;
    }
    v4 = v3 - 1;
    if ( !v4 )
    {
        if ( !*(_DWORD *)(a1 + 3320) && !*(_WORD *)(a1 + 592) && !*(_DWORD *)(a1 + 204) )
        {
LABEL_21:
            *(_DWORD *)(a1 + 44) = 0;
            sub_7FF91E01D3A0(a1);
            goto LABEL_29;
        }
        if ( v1 )
            goto LABEL_29;
LABEL_27:
        v6 = *(_DWORD *)(a1 + 24) + 1;
        *(_QWORD *)(a1 + 60) = -1;
        *(_DWORD *)(a1 + 3048) = v6;
        *(_QWORD *)(a1 + 52) = 0;
        *(_DWORD *)(a1 + 3056) = -1;
LABEL_28:
        *(_DWORD *)(a1 + 44) = 2;
        goto LABEL_29;
    }
    v5 = v4 - 1;
    if ( v5 )
    {
        if ( v5 != 1 )
            goto LABEL_29;
        if ( !*(_DWORD *)(a1 + 3320) && !*(_WORD *)(a1 + 592) && !*(_DWORD *)(a1 + 204) )
        {
            if ( !*(_DWORD *)(a1 + 604) )
            {
                *(_DWORD *)(a1 + 604) = -1;
                goto LABEL_29;
            }
            goto LABEL_21;
        }
        goto LABEL_28;
    }
    if ( !*(_DWORD *)(a1 + 3320) && !*(_WORD *)(a1 + 592) && !*(_DWORD *)(a1 + 204) )
    {
        *(_DWORD *)(a1 + 604) = *(_DWORD *)(a1 + 600);
        if ( !*(_BYTE *)(a1 + 608) )
            sub_7FF91E01D3A0(a1);
        *(_DWORD *)(a1 + 44) = 3;
    }
LABEL_29:
    if ( *(_BYTE *)(a1 + 197) )
    {
        v7 = *(_DWORD *)(a1 + 20) + 1;
        v8 = *(_DWORD *)(a1 + 44) < 2;
        *(_DWORD *)(a1 + 20) = v7;
        if ( v8 )
        {
            *(_DWORD *)(a1 + 24) = v7;
        }
        else
        {
            v9 = *(_DWORD *)(a1 + 24);
            if ( v7 != v9 )
            {
                do
                {
                    v10 = v9 + 1;
                    v11 = 0;
                    *(_DWORD *)(a1 + 24) = v9 + 1;
                    if ( *(char *)(a1 + 3054) > 0 )
                    {
                        v12 = a1 + 806;
                        do
                        {
                            if ( *(_DWORD *)(v12 + 6) == (_DWORD)v10 )
                            {
                                v13 = *v12;
                                if ( (unsigned int)v13 < 0x80 )
                                {
                                    arp_note_off(a1, (int)v13, 64);
                                    *(_BYTE *)((char)v12[1] + (__int64)a1 + 3324) = 0x80;
                                    *v12 = 0x80;
                                }
                            }
                            ++v11;
                            v12 += 12;
                        }
                        while ( v11 < *(char *)(a1 + 3054) );
                    }
                    if ( *(_DWORD *)(a1 + 24) == *(_DWORD *)(a1 + 3048) )
                    {
                        if ( *(_BYTE *)(a1 + 40) )
                        {
                            /* CKbdArp pattern-reload path (sub_7FF91E01F9F0 +
                             * sub_7FF91E01FED0). NOT transcribed — only reached
                             * when a preset is staged (+40 set). See header note. */
                            v14 = *(_DWORD *)(a1 + 44);
                            if ( (unsigned int)(v14 - 1) <= 2 )
                            {
                                *(_DWORD *)(a1 + 44) = 0;
                                v15 = a1 + 806;
                                v16 = 16;
                                do
                                {
                                    v17 = *v15;
                                    if ( (unsigned int)v17 < 0x80 )
                                    {
                                        arp_note_off(a1, (int)v17, 64);
                                        *(_BYTE *)((char)v15[1] + (__int64)a1 + 3324) = 0x80;
                                        *v15 = 0x80;
                                    }
                                    v15 += 12;
                                    --v16;
                                }
                                while ( v16 );
                            }
                            *(_DWORD *)(a1 + 44) = v14;
                            /* sub_7FF91E01F9F0(a1, *(_QWORD*)(a1+32), a1+804); */
                            /* sub_7FF91E01FED0(a1, 0); */
                            *(_BYTE *)(a1 + 40) = 0;
                        }
                        if ( *(_BYTE *)(a1 + 3489) )
                        {
                            /* sub_7FF91E0204E0(a1) — expanded scanner, not
                             * transcribed (Open Questions). Fall back to simple. */
                            sub_7FF91E020260(a1);
                        }
                        else
                        {
                            sub_7FF91E020260(a1);
                        }
                    }
                    v9 = *(_DWORD *)(a1 + 24);
                }
                while ( *(_DWORD *)(a1 + 20) != (_DWORD)v9 );
            }
        }
    }
}

/* sub_7FF91E01FE60 @ rva 0x3BFE60 — octave range. */
static void sub_7FF91E01FE60(unsigned char *a1, int a2)
{
    *(_DWORD *)(a1 + 3472) = 0;
    *(_DWORD *)(a1 + 3476) = a2;
}

/* sub_7FF91E01FE90 @ rva 0x3BFE90 — enable/run. */
static __int64 sub_7FF91E01FE90(unsigned char *a1, char a2)
{
    __int64 result; // rax

    if ( (unsigned int)(*(_DWORD *)(a1 + 44) - 1) <= 2 )
    {
        *(_DWORD *)(a1 + 44) = 0;
        sub_7FF91E01D3A0(a1);
    }
    result = *(unsigned int *)(a1 + 20);
    *(_DWORD *)(a1 + 24) = result;
    *(_BYTE *)(a1 + 197) = a2;
    return result;
}

/* ======================================================================== */
/* Public API wrappers.                                                     */
/* ======================================================================== */
void juno_arp_init(juno_arp *arp, const juno_arp_callbacks *cb)
{
    memset(arp->st, 0, sizeof arp->st);
    if ( cb )
        arp->cb = *cb;
    else
        memset(&arp->cb, 0, sizeof arp->cb);
    sub_7FF91E01D270((__int64)arp->st);
    /* The ctor leaves +3480 for the mode installer; default to ORDER so an
     * arp that is clocked before set-mode is safe (matches sub_7FF91E01FCB0
     * default). */
    ARP_SEL(arp->st) = juno_arp_sel_order;
}

void juno_arp_note_on(juno_arp *arp, int key, int vel)
{
    sub_7FF91E023440(arp->st, (unsigned int)key, vel);
}

void juno_arp_note_off(juno_arp *arp, int key)
{
    sub_7FF91E01F110_pub(arp->st, key);
}

void juno_arp_set_mode(juno_arp *arp, int mode)
{
    sub_7FF91E01FCB0(arp->st, mode);
}

void juno_arp_set_range(juno_arp *arp, int octaves)
{
    sub_7FF91E01FE60(arp->st, octaves);
}

void juno_arp_set_running(juno_arp *arp, int running)
{
    sub_7FF91E01FE90(arp->st, (char)running);
}

void juno_arp_clock(juno_arp *arp, int nsamples)
{
    int i;
    for ( i = 0; i < nsamples; ++i )
        sub_7FF91E01DEA0(arp->st);
}

void juno_arp_scan(juno_arp *arp)
{
    sub_7FF91E020260(arp->st);
}

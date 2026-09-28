/* jet_libc.c -- the libc symbols the JUNO FX modules need when jetsynth is
 * built for wasm32 with no libc: memset, memcpy, fabsf, fmodf.
 *
 * fmodf MUST be exact: eb_chorus.c wraps its LFO with it, and this project
 * has already shipped a wrong fmodf once (8,388,608 of 2^32 inputs). This is
 * the classic bitwise algorithm (as in musl, MIT), which is exact by
 * construction; tests/test_fmodf.c compares it with the host libm on every
 * input class that matters. Compiled ONLY into the wasm build. */
#include <stdint.h>
#include <stddef.h>

#ifdef JET_WASM
void *memset(void *d, int c, size_t n)
{
    unsigned char *p = (unsigned char *)d;
    while (n--) *p++ = (unsigned char)c;
    return d;
}

void *memcpy(void *d, const void *s, size_t n)
{
    unsigned char *p = (unsigned char *)d;
    const unsigned char *q = (const unsigned char *)s;
    while (n--) *p++ = *q++;
    return d;
}

float fabsf(float x)
{
    union { float f; uint32_t i; } u = { x };
    u.i &= 0x7fffffffu;
    return u.f;
}

/* C99 7.12.12: a NaN argument yields the other argument */
float fminf(float a, float b)
{
    if (a != a) return b;
    if (b != b) return a;
    return a < b ? a : b;
}
float fmaxf(float a, float b)
{
    if (a != a) return b;
    if (b != b) return a;
    return a > b ? a : b;
}
#endif

float jet_fmodf(float x, float y)
{
    union { float f; uint32_t i; } ux = { x }, uy = { y };
    int ex = ux.i >> 23 & 0xff;
    int ey = uy.i >> 23 & 0xff;
    uint32_t sx = ux.i & 0x80000000u;
    uint32_t i;
    uint32_t uxi = ux.i;

    if (uy.i << 1 == 0 || (uy.i & 0x7fffffffu) > 0x7f800000u || ex == 0xff)
        return (x * y) / (x * y);
    if (uxi << 1 <= uy.i << 1) {
        if (uxi << 1 == uy.i << 1)
            return 0 * x;
        return x;
    }
    /* normalize x and y */
    if (!ex) {
        for (i = uxi << 9; i >> 31 == 0; ex--, i <<= 1);
        uxi <<= -ex + 1;
    } else {
        uxi &= (uint32_t)-1 >> 9;
        uxi |= 1u << 23;
    }
    if (!ey) {
        for (i = uy.i << 9; i >> 31 == 0; ey--, i <<= 1);
        uy.i <<= -ey + 1;
    } else {
        uy.i &= (uint32_t)-1 >> 9;
        uy.i |= 1u << 23;
    }
    /* x mod y */
    for (; ex > ey; ex--) {
        i = uxi - uy.i;
        if (i >> 31 == 0) {
            if (i == 0)
                return 0 * x;
            uxi = i;
        }
        uxi <<= 1;
    }
    i = uxi - uy.i;
    if (i >> 31 == 0) {
        if (i == 0)
            return 0 * x;
        uxi = i;
    }
    for (; uxi >> 23 == 0; uxi <<= 1, ex--);
    /* scale result up */
    if (ex > 0) {
        uxi -= 1u << 23;
        uxi |= (uint32_t)ex << 23;
    } else {
        uxi >>= -ex + 1;
    }
    uxi |= sx;
    ux.i = uxi;
    return ux.f;
}

#ifdef JET_WASM
float fmodf(float x, float y) { return jet_fmodf(x, y); }
#endif

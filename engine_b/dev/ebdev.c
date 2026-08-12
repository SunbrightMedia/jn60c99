/* ebdev.c -- the device cell array. See ebdev.h for the design and for why
 * the fast path is an inline chain in the header rather than a function here.
 *
 * This file holds only the cold paths, the reference (table) form, and the
 * exhaustive equivalence self-test between the two.
 */
#include "ebdev.h"

ebdev_state EBDEV_S;
ebdev_state *const EBDEV = &EBDEV_S;

/* Where an unplaceable offset goes. 8 bytes so a float or an int32 store fits
 * without corrupting anything real. */
static unsigned char SINK[8];

unsigned long EBDEV_SEGHIT[EBDEV_NSEG];
unsigned long EBDEV_VHIT, EBDEV_SHIT, EBDEV_GHIT;
unsigned long EBDEV_MISSLIST[8192];
int           EBDEV_NMISS;

void *ebdev_miss(unsigned long off)
{
    int j;
    ++EBDEV_S.miss;
    EBDEV_S.lastmiss = off;
    for (j = 0; j < EBDEV_NMISS; ++j)
        if (EBDEV_MISSLIST[j] == off) return SINK;
    if (EBDEV_NMISS < (int)(sizeof EBDEV_MISSLIST / sizeof EBDEV_MISSLIST[0]))
        EBDEV_MISSLIST[EBDEV_NMISS++] = off;
    return SINK;
}

void *ebdev_scatter_slow(unsigned long off)
{
    unsigned v = (unsigned)((off - EBDEV_VLO) / EBDEV_VSTRIDE);
    unsigned k = (unsigned)(off - (unsigned long)v * EBDEV_VSTRIDE);
    int i;
    if (v < EBDEV_NV)
        for (i = 0; i < EBDEV_NSCAT; ++i)
            if (k == EBDEV_SCATTAB[i]) return &EBDEV_S.scat[v][i];
    return ebdev_miss(off);
}

/* ------------------------------------------------------- the reference form */
void *ebdev_at_ref(unsigned long off)
{
    int i;
    if (off < EBDEV_VTILE) {
#ifndef EBDEV_TOOTH_SCAT0_IN_TILE
        for (i = 0; i < EBDEV_NSCAT; ++i)
            if (off == EBDEV_SCATTAB[i]) { ++EBDEV_SHIT; return &EBDEV_S.scat[0][i]; }
#endif
        ++EBDEV_VHIT;
        return EBDEV_S.v0 + off;
    }
    if (off < EBDEV_VHI) {
        unsigned v = (unsigned)((off - EBDEV_VLO) / EBDEV_VSTRIDE);
        unsigned k = (unsigned)(off - (unsigned long)v * EBDEV_VSTRIDE);
        if (v < EBDEV_NV)
            for (i = 0; i < EBDEV_NSCAT; ++i)
                if (k == EBDEV_SCATTAB[i]) { ++EBDEV_SHIT; return &EBDEV_S.scat[v][i]; }
        return ebdev_miss(off);
    }
    for (i = 0; i < EBDEV_NSEG; ++i)
        if (off >= EBDEV_SEGTAB[i].lo && off < EBDEV_SEGTAB[i].hi) {
            ++EBDEV_SEGHIT[i]; ++EBDEV_GHIT;
            return EBDEV_S.sg + EBDEV_SEGTAB[i].at + (off - EBDEV_SEGTAB[i].lo);
        }
    return ebdev_miss(off);
}

#ifdef EBDEV_INSTRUMENT
void *ebdev_at(unsigned long off) { return ebdev_at_ref(off); }
#endif

/* ---------------------------------------------------------------- the rest */
void *ebdev_at_v(int v, unsigned long off)
{
    if (v <= 0) return ebdev_at(off);
    return ebdev_at((unsigned long)v * EBDEV_VSTRIDE + off);
}

void ebdev_voice_select(int v)
{
    int i;
    if (v < 0 || v >= EBDEV_NV) return;
    for (i = 0; i < EBDEV_NSCAT; ++i)
        *(float *)(EBDEV_S.v0 + EBDEV_SCATTAB[i]) = EBDEV_S.scat[v][i];
}

void ebdev_broadcast_scatter(void)
{
    int v, i;
    for (v = 1; v < EBDEV_NV; ++v)
        for (i = 0; i < EBDEV_NSCAT; ++i)
            EBDEV_S.scat[v][i] = EBDEV_S.scat[0][i];
}

void ebdev_reset_counters(void)
{
    int i;
    EBDEV_S.miss = 0; EBDEV_S.lastmiss = 0;
    EBDEV_VHIT = EBDEV_SHIT = EBDEV_GHIT = 0;
    EBDEV_NMISS = 0;
    for (i = 0; i < EBDEV_NSEG; ++i) EBDEV_SEGHIT[i] = 0;
}

/* Exhaustive over: the whole voice tile, every voice's whole block, and every
 * segment plus a guard band on each side. Under EBDEV_INSTRUMENT `ebdev_at`
 * IS `ebdev_at_ref`, so the sweep is vacuous there and says so by returning
 * -1 rather than a flattering 0. */
long ebdev_selftest(void)
{
#ifdef EBDEV_INSTRUMENT
    return -1;
#else
    unsigned long off;
    long bad = 0;
    int i, sm, sn;
    unsigned long saved_miss = EBDEV_S.miss;
    int saved_nmiss = EBDEV_NMISS;
    for (off = 0; off < EBDEV_VHI; ++off)
        if (ebdev_at(off) != ebdev_at_ref(off)) ++bad;
    for (i = 0; i < EBDEV_NSEG; ++i) {
        unsigned long lo = EBDEV_SEGTAB[i].lo, hi = EBDEV_SEGTAB[i].hi;
        for (off = (lo > 8 ? lo - 8 : 0); off < hi + 8; ++off)
            if (ebdev_at(off) != ebdev_at_ref(off)) ++bad;
    }
    /* and a coarse sweep of the whole 11 MB space, so a segment the generator
     * placed at a bogus address cannot hide between the guard bands */
    for (off = 0; off < 11022352u; off += 997u)
        if (ebdev_at(off) != ebdev_at_ref(off)) ++bad;
    EBDEV_S.miss = saved_miss; EBDEV_NMISS = saved_nmiss;
    sm = 0; sn = 0; (void)sm; (void)sn;
    return bad;
#endif
}

#include "ebdev.h"
#include <stdio.h>
ebdev_state *EBDEV;
const unsigned EBDEV_SCAT[EBDEV_NSCAT] = { 1072u, 3968u, 5520u, 7600u, 10320u };
static unsigned char SINK[8];           /* where an unmapped offset goes: nowhere */

void *ebdev_at(unsigned long off)
{
    ebdev_state *s = EBDEV;
    int i;
    if (off < EBDEV_VTILE) return s->v0 + off;               /* voice 0 + cell 16 */
    if (off < 84272u) {                                      /* voice v>0 */
        unsigned v = (unsigned)((off - 176u) / 10512u);
        unsigned k = (unsigned)(off - (unsigned long)v * 10512u);
        if (v < EBDEV_NV)
            for (i = 0; i < EBDEV_NSCAT; ++i)
                if (k == EBDEV_SCAT[i]) return &s->scat[v][i];
        ++s->miss; s->lastmiss = off; return SINK;
    }
    for (i = 0; i < EBDEV_NSEG; ++i)
        if (off >= EBDEV_SEG[i].lo && off < EBDEV_SEG[i].hi)
            return s->sg + EBDEV_SEG[i].at + (off - EBDEV_SEG[i].lo);
    ++s->miss; s->lastmiss = off; return SINK;
}

void ebdev_voice_select(int v)
{
    int i;
    if (v < 0 || v >= EBDEV_NV) return;
    for (i = 0; i < EBDEV_NSCAT; ++i)
        *(float *)(EBDEV->v0 + EBDEV_SCAT[i]) = EBDEV->scat[v][i];
}

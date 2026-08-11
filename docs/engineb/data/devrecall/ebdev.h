#ifndef EBDEV_H
#define EBDEV_H
#include <stdint.h>
#include <stddef.h>
#include "ebdev_seg.h"
#ifndef EBDEV_NV
#define EBDEV_NV 8
#endif
#define EBDEV_NSCAT 5
extern const unsigned EBDEV_SCAT[EBDEV_NSCAT];   /* 1072,3968,5520,7600,10320 */
typedef struct {
    unsigned char v0[EBDEV_VTILE];      /* voice tile at NATIVE offsets [0,10688) */
    unsigned char sg[EBDEV_SEGBYTES];   /* the 15 non-voice segments, dense       */
    float         scat[EBDEV_NV][EBDEV_NSCAT];
    unsigned long miss;                 /* offsets the map could not place        */
    unsigned long lastmiss;
} ebdev_state;
extern ebdev_state *EBDEV;              /* the one live array (harness convenience) */
void *ebdev_at(unsigned long off);
void  ebdev_voice_select(int v);        /* poke voice v's scatter into the tile */
#endif

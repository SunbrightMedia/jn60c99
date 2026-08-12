#include "jc_trace.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

unsigned char *jc_base = 0;
int jc_on = 0;
/* ---- device-map mode ---- */
int jc_dev = 0;
unsigned jc_scat[32]; int jc_nscat = 0;
float jc_scatv[8][32];
unsigned long jc_miss = 0, jc_lastmiss = 0;
static unsigned char SINK[16];
unsigned char *jc_tile;
int jc_fold=0;
int jc_auxfold=0;
unsigned long jc_fold_n=0;
void jc_sel(int v){int i;for(i=0;i<jc_nscat;++i) *(float*)(jc_tile+jc_scat[i])=jc_scatv[v][i];}

#define TBITS 22
#define TSIZE (1u<<TBITS)
#define NSITE 10
typedef struct { unsigned long off; const char *f[NSITE]; int l[NSITE]; int n; } ent;
static ent *T;
void jc_reset(void){ if(!T) T = calloc(TSIZE, sizeof(ent)); else memset(T,0,(size_t)TSIZE*sizeof(ent)); }

void *jc_at(unsigned char *p, unsigned long off, const char *file, int line)
{
    unsigned long a = (unsigned long)(p - jc_base) + off;
    if (jc_on) {
        unsigned long h = (a * 2654435761u) >> (32-TBITS);
        for(;;){
            ent *e = &T[h & (TSIZE-1)];
            if (!e->off) { e->off = a+1; }
            if (e->off == a+1) { int i;
                for (i=0;i<e->n;++i) if (e->l[i]==line && e->f[i]==file) break;
                if (i==e->n && e->n<NSITE) { e->f[e->n]=file; e->l[e->n]=line; e->n++; }
                break; }
            h++;
        }
    }
    if (!jc_dev) return (void*)(jc_base + a);
    if (jc_auxfold && a >= 101504u && a < 101760u) return (void*)(jc_base + 101504u + ((a - 101504u) & 31u));
    if (a < 84272u) {
        unsigned v = (a < 10688u) ? 0u : (unsigned)((a - 176u)/10512u);
        unsigned k = (unsigned)(a - (unsigned long)v*10512u);
        int i;
        for (i=0;i<jc_nscat;++i) if (k==jc_scat[i]) return &jc_scatv[v][i];
        if (v == 0u) return (void*)(jc_base + a);
        ++jc_miss; jc_lastmiss = a; return SINK;
    }
    return (void*)(jc_base + a);
}
void jc_dump(const char *path)
{
    FILE *o = fopen(path,"w"); unsigned long i;
    for (i=0;i<TSIZE;++i){ ent *e=&T[i]; int k; if(!e->off) continue;
        fprintf(o,"%lu",e->off-1);
        for(k=0;k<e->n;++k) fprintf(o,"\t%s:%d",e->f[k],e->l[k]);
        fprintf(o,"\n"); }
    fclose(o);
}

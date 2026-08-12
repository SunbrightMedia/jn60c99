/* WARM vs COLD recall: does recalling patch B on top of patch A give the same
 * cells and the same coefficients as recalling patch B from a fresh boot? */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "juno_engine.h"
#include "juno_apply.h"
#include "juno_driver.h"
#include "eb_coefs.h"
#include "eb_master_coefs.h"
#define BANK_HEADER 23
#define BANK_STRIDE 20223
static eb_render_coefs RA, RB;
static eb_master_coef  MA, MB;

static void boot(unsigned char *st, int rate){
    memset(st,0,JUNO_STATE_BYTES);
    juno_chorus_init(st); JF(st,16)=(float)rate;
    juno_engine_init(st); juno_engine_prepare(st);
}
static void recall(unsigned char *st, const unsigned char *bank, int p){
    juno_bank_apply(st,bank,p);
    juno_driver_seed_voices(st);
    juno_apply_unison_spread(st,juno_bank_assign(bank,p));
    juno_apply_condition(st,juno_bank_condition(bank,p));
    juno_apply_lfo_tempo(st,juno_bank_lfo_rate_byte(bank,p),128.0f);
}
int main(int argc,char**argv){
    FILE*f=fopen(argv[1],"rb");fseek(f,0,SEEK_END);long bl=ftell(f);fseek(f,0,SEEK_SET);
    unsigned char*bank=malloc(bl); if(fread(bank,1,bl,f)!=(size_t)bl){puts("short");return 1;} fclose(f);
    unsigned char*C=malloc(JUNO_STATE_BYTES), *W=malloc(JUNO_STATE_BYTES);
    int rate=44100;
    int worstpairs=0, coefbad=0, mcoefbad=0, cellbad=0;
    long worstcells=0;
    for(int a=0;a<64;++a){
        int b=(a+1)%64;
        boot(C,rate); recall(C,bank,b);
        eb_render_coefs_build(C,&RA); eb_master_coefs_build(C,&MA);
        boot(W,rate); recall(W,bank,a); recall(W,bank,b);
        eb_render_coefs_build(W,&RB); eb_master_coefs_build(W,&MB);
        int rc = memcmp(&RA,&RB,sizeof RA)!=0;
        int mc = memcmp(&MA,&MB,sizeof MA)!=0;
        long nd=0; for(unsigned long i=0;i<JUNO_STATE_BYTES;++i) if(C[i]!=W[i]) ++nd;
        if(rc) ++coefbad; if(mc) ++mcoefbad; if(nd) ++cellbad;
        if(nd>worstcells){worstcells=nd;worstpairs=a;}
        if(1)
            printf("PAIR %d %d %d %d %ld\n", a,b, rc, mc, nd);
    }
    printf("\nWARM vs COLD over 64 consecutive pairs at 44100:\n");
    printf("  render_coefs differ : %d of 64\n", coefbad);
    printf("  master_coef  differ : %d of 64\n", mcoefbad);
    printf("  cell array   differ : %d of 64 (worst %ld bytes, pair starting %d)\n",
           cellbad, worstcells, worstpairs);
    return 0;
}

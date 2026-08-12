#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "juno_engine.h"
#include "juno_apply.h"
#include "juno_driver.h"
static void boot(unsigned char*st,int r){memset(st,0,JUNO_STATE_BYTES);juno_chorus_init(st);JF(st,16)=(float)r;juno_engine_init(st);juno_engine_prepare(st);}
static void recall(unsigned char*st,const unsigned char*bk,int p){
    juno_bank_apply(st,bk,p); juno_driver_seed_voices(st);
    juno_apply_unison_spread(st,juno_bank_assign(bk,p));
    juno_apply_condition(st,juno_bank_condition(bk,p));
    juno_apply_lfo_tempo(st,juno_bank_lfo_rate_byte(bk,p),128.0f);}
int main(int argc,char**argv){
    FILE*f=fopen(argv[1],"rb");fseek(f,0,SEEK_END);long bl=ftell(f);fseek(f,0,SEEK_SET);
    unsigned char*bank=malloc(bl); if(fread(bank,1,bl,f)!=(size_t)bl)return 1; fclose(f);
    unsigned char*C=malloc(JUNO_STATE_BYTES),*W=malloc(JUNO_STATE_BYTES);
    for(int a=0;a<64;++a){ int b=(a+1)%64;
        boot(C,44100); recall(C,bank,b);
        boot(W,44100); recall(W,bank,a); recall(W,bank,b);
        printf("PAIRCELLS %d %d :",a,b);
        unsigned long last=~0ul;
        for(unsigned long i=0;i<JUNO_STATE_BYTES;++i) if(C[i]!=W[i]){ unsigned long c=(i/16)*16; if(c!=last){printf(" %lu",c); last=c;} }
        printf("\n"); }
    return 0; }

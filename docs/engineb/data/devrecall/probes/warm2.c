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
static eb_render_coefs RA,RB; static eb_master_coef MA,MB;
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
    int a=atoi(argv[2]), b=atoi(argv[3]);
    boot(C,44100); recall(C,bank,b); eb_render_coefs_build(C,&RA); eb_master_coefs_build(C,&MA);
    boot(W,44100); recall(W,bank,a); recall(W,bank,b); eb_render_coefs_build(W,&RB); eb_master_coefs_build(W,&MB);
    printf("pair %d->%d  DELAY TYPE a=%d b=%d\n",a,b,
        (int)((bank[BANK_HEADER+a*BANK_STRIDE+16+3054]&0xF)),(int)((bank[BANK_HEADER+b*BANK_STRIDE+16+3054]&0xF)));
    printf("STALE CELL OFFSETS (cold vs warm), first 40 runs:\n");
    unsigned long i=0; int runs=0;
    while(i<JUNO_STATE_BYTES && runs<40){
        if(C[i]!=W[i]){ unsigned long s=i; while(i<JUNO_STATE_BYTES&&C[i]!=W[i])++i;
            float fc,fw; memcpy(&fc,C+(s&~3ul),4); memcpy(&fw,W+(s&~3ul),4);
            printf("  [%lu..%lu)  cold=%g warm=%g\n",s,i,fc,fw); ++runs; }
        else ++i; }
    printf("render_coefs %s   master_coef %s\n",
        memcmp(&RA,&RB,sizeof RA)?"DIFFER":"same", memcmp(&MA,&MB,sizeof MA)?"DIFFER":"same");
    /* which render_coefs bytes */
    { const unsigned char*x=(void*)&RA,*y=(void*)&RB; unsigned long n=0,first=~0ul;
      for(unsigned long j=0;j<sizeof RA;++j) if(x[j]!=y[j]){++n; if(first==~0ul)first=j;}
      printf("render_coefs differing bytes %lu first at %lu of %lu\n",n,first,(unsigned long)sizeof RA); }
    { const unsigned char*x=(void*)&MA,*y=(void*)&MB; unsigned long n=0,first=~0ul;
      for(unsigned long j=0;j<sizeof MA;++j) if(x[j]!=y[j]){++n; if(first==~0ul)first=j;}
      printf("master_coef  differing bytes %lu first at %lu of %lu\n",n,first,(unsigned long)sizeof MA); }
    return 0; }

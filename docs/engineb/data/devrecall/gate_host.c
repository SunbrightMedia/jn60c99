#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "juno_engine.h"
#include "juno_apply.h"
#include "juno_driver.h"
#include "eb_coefs.h"
#include "eb_master_coefs.h"
#include "ebdev_seg.h"
#define EBDEV_NV 8
#define EBDEV_NSCAT 5
#define BANK_HEADER 23
#define BANK_STRIDE 20223
static eb_render_coefs RC;
static eb_master_coef  MC;
static unsigned char *ST;
static const unsigned SCAT[EBDEV_NSCAT]={1072u,3968u,5520u,7600u,10320u};
/* gather the port's 11 MB array into the device layout */
static void gather(unsigned char *v0, unsigned char *sg, float scat[][EBDEV_NSCAT]){
    memcpy(v0, ST, EBDEV_VTILE);
    for (int i=0;i<EBDEV_NSEG;++i)
        memcpy(sg+EBDEV_SEG[i].at, ST+EBDEV_SEG[i].lo, EBDEV_SEG[i].hi-EBDEV_SEG[i].lo);
    for (int v=0;v<EBDEV_NV;++v) for(int k=0;k<EBDEV_NSCAT;++k)
        scat[v][k] = JF(ST, (unsigned)v*10512u + SCAT[k]);
}
int main(int argc,char**argv){
    FILE*f=fopen(argv[1],"rb");fseek(f,0,SEEK_END);long bl=ftell(f);fseek(f,0,SEEK_SET);
    unsigned char*bank=malloc(bl);fread(bank,1,bl,f);fclose(f);
    unsigned char*wb=malloc(bl);
    ST=malloc(JUNO_STATE_BYTES);
    static unsigned char v0[EBDEV_VTILE], sg[EBDEV_SEGBYTES];
    static float scat[EBDEV_NV][EBDEV_NSCAT];
    int rates[3]={44100,48000,96000};
    FILE*o=fopen(argv[2],"wb");
    FILE*b=fopen(argv[3],"wb");           /* the BAKED BOOT IMAGE, one per rate */
    srand(4242);
    for(int r=0;r<3;++r){                 /* boot images first, same order dev reads */
        memset(ST,0,JUNO_STATE_BYTES);
        juno_chorus_init(ST); JF(ST,16)=(float)rates[r];
        juno_engine_init(ST); juno_engine_prepare(ST);
        gather(v0,sg,scat);
        fwrite(v0,1,sizeof v0,b); fwrite(sg,1,sizeof sg,b); fwrite(scat,1,sizeof scat,b);
    }
    for(int trial=0;trial<2;++trial){
      memcpy(wb,bank,bl);
      if(trial==1) for(int p=0;p<64;++p){unsigned char*rr=wb+BANK_HEADER+p*BANK_STRIDE;
          for(long i=16;i<BANK_STRIDE;++i) rr[i]=(unsigned char)(rand()&0xFF);}
      for(int r=0;r<3;++r) for(int p=0;p<64;++p){
        memset(ST,0,JUNO_STATE_BYTES);
        juno_chorus_init(ST); JF(ST,16)=(float)rates[r];
        juno_engine_init(ST); juno_engine_prepare(ST);
        juno_bank_apply(ST,wb,p);
        juno_driver_seed_voices(ST);
        juno_apply_unison_spread(ST,(trial==0)?juno_bank_assign(wb,p):(rand()%4));
        juno_apply_condition(ST,(trial==0)?juno_bank_condition(wb,p):(rand()%256));
        juno_apply_lfo_tempo(ST,juno_bank_lfo_rate_byte(wb,p),128.0f);
        eb_render_coefs_build(ST,&RC);
        eb_master_coefs_build(ST,&MC);
        fwrite(&RC,1,sizeof RC,o); fwrite(&MC,1,sizeof MC,o);
      }
    }
    fclose(o); fclose(b);
    printf("HOST path done. boot image per rate = %u B; 3 rates = %u B\n",
           (unsigned)(sizeof v0+sizeof sg+sizeof scat),
           (unsigned)(3*(sizeof v0+sizeof sg+sizeof scat)));
    return 0;
}

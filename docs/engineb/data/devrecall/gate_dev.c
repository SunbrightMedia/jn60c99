/* THE GATE, device half: boot image + recall into the 24 KB array, then build. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "juno_engine.h"
#include "juno_apply.h"
#include "juno_driver.h"
#include "eb_coefs.h"
#include "eb_master_coefs.h"
#include "ebdev.h"
#define BANK_HEADER 23
#define BANK_STRIDE 20223
static eb_render_coefs RC;
static eb_master_coef  MC;
static ebdev_state DS;
int LUTEQ, LUTNE;
static unsigned char BOOT[3][EBDEV_VTILE+EBDEV_SEGBYTES+EBDEV_NV*EBDEV_NSCAT*4];
int main(int argc,char**argv){
    FILE*f=fopen(argv[1],"rb");fseek(f,0,SEEK_END);long bl=ftell(f);fseek(f,0,SEEK_SET);
    unsigned char*bank=malloc(bl);fread(bank,1,bl,f);fclose(f);
    unsigned char*wb=malloc(bl);
    FILE*bf=fopen(argv[3],"rb");
    if(fread(BOOT,1,sizeof BOOT,bf)!=sizeof BOOT){printf("BOOT: short read\n");return 1;}
    fclose(bf);
    EBDEV=&DS;
    int rates[3]={44100,48000,96000};
    FILE*o=fopen(argv[2],"wb");
    srand(4242);
    unsigned char*ST=(unsigned char*)1;
    for(int trial=0;trial<2;++trial){
      memcpy(wb,bank,bl);
      if(trial==1) for(int p=0;p<64;++p){unsigned char*rr=wb+BANK_HEADER+p*BANK_STRIDE;
          for(long i=16;i<BANK_STRIDE;++i) rr[i]=(unsigned char)(rand()&0xFF);}
      for(int r=0;r<3;++r) for(int p=0;p<64;++p){
        memset(&DS,0,sizeof DS);
        memcpy(DS.v0, BOOT[r], EBDEV_VTILE);
        memcpy(DS.sg, BOOT[r]+EBDEV_VTILE, EBDEV_SEGBYTES);
        memcpy(DS.scat, BOOT[r]+EBDEV_VTILE+EBDEV_SEGBYTES, sizeof DS.scat);
        (void)rates[r];
        juno_bank_apply(ST,wb,p);
        juno_apply_unison_spread(ST,(trial==0)?juno_bank_assign(wb,p):(rand()%4));
        juno_apply_condition(ST,(trial==0)?juno_bank_condition(wb,p):(rand()%256));
        juno_apply_lfo_tempo(ST,juno_bank_lfo_rate_byte(wb,p),128.0f);
        eb_render_coefs_build((const unsigned char*)0,&RC);
        eb_master_coefs_build((const unsigned char*)0,&MC);
        fwrite(&RC,1,sizeof RC,o); fwrite(&MC,1,sizeof MC,o);
#if EB_VCF_RES_LUT
        { extern int LUTEQ, LUTNE; int vv;
          for(vv=1; vv<EB_NUM_VOICES; ++vv)
              if(memcmp(RC.res[vv].lut, RC.res[0].lut, sizeof RC.res[0].lut)==0) ++LUTEQ; else ++LUTNE; }
#endif
      }
    }
    fclose(o);
    printf("DEVICE path done. cell array = %u B  unmapped accesses = %lu (last off %lu)\n",
           (unsigned)sizeof(ebdev_state), DS.miss, DS.lastmiss);
    { extern unsigned long EBDEV_MISSLIST[]; extern int EBDEV_NMISS; FILE*m=fopen("miss.txt","w");
      for(int j=0;j<EBDEV_NMISS;++j) fprintf(m,"%lu\n",EBDEV_MISSLIST[j]); fclose(m);
      printf("distinct unmapped offsets: %d\n", EBDEV_NMISS); }
    { extern unsigned long EBDEV_VHIT,EBDEV_SHIT,EBDEV_GHIT,EBDEV_PROBES;
      double N=384.0;
      printf("ACCESS MIX per recall: tile %.1f  scatter %.1f  segment %.1f  (linear probes %.1f, %.1f per segment hit)\n",
             EBDEV_VHIT/N, EBDEV_SHIT/N, EBDEV_GHIT/N, EBDEV_PROBES/N, EBDEV_PROBES/(double)(EBDEV_GHIT?EBDEV_GHIT:1)); }
    { extern unsigned long EBDEV_SEGHIT[]; int t=0;
      printf("SEGMENT COVERAGE: "); for(int j=0;j<EBDEV_NSEG;++j){ if(EBDEV_SEGHIT[j]) ++t; else printf("[%d cold] ",j); }
      printf("\n  %d of %d segments touched by this gate\n", t, EBDEV_NSEG); }
#if EB_VCF_RES_LUT
    printf("RES LUT across voices: %d IDENTICAL, %d DIFFERENT\n", LUTEQ, LUTNE);
#endif
    return 0;
}

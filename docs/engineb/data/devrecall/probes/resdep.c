#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "juno_engine.h"
#include "juno_apply.h"
#include "juno_driver.h"
void jc_log(unsigned long off,int isw){(void)off;(void)isw;}
#define BANK_HEADER 23
#define BANK_STRIDE 20223
static unsigned char *STATE,*GOLD;
static unsigned long hres(void){ unsigned long h=146959810393466UL; unsigned o;
    for(o=7856;o<=8192;o+=16){ h^=*(unsigned*)(STATE+o); h*=1099511628211UL; } return h; }
static unsigned long hall(void){ unsigned long h=1469598103934665603UL; unsigned o;
    for(o=176;o<10688;o+=16){ h^=*(unsigned*)(STATE+o); h*=1099511628211UL; } return h; }
static void restore(void){ memcpy(STATE+176,GOLD+176,8u*10512u); memcpy(STATE+84272,GOLD+84272,4096); }
static void rec(const unsigned char*bank,int idx){
    restore(); juno_bank_apply(STATE,bank,idx); juno_driver_seed_voices(STATE);
    juno_apply_unison_spread(STATE,juno_bank_assign(bank,idx));
    juno_apply_condition(STATE,juno_bank_condition(bank,idx));
    juno_apply_lfo_tempo(STATE,juno_bank_lfo_rate_byte(bank,idx),128.0f); }
int main(int argc,char**argv){
    FILE*f=fopen(argv[1],"rb");fseek(f,0,SEEK_END);long bl=ftell(f);fseek(f,0,SEEK_SET);
    unsigned char*bank=malloc(bl);fread(bank,1,bl,f);fclose(f);
    unsigned char*wb=malloc(bl); memcpy(wb,bank,bl);
    STATE=malloc(JUNO_STATE_BYTES); memset(STATE,0,JUNO_STATE_BYTES);
    juno_chorus_init(STATE); JF(STATE,16)=44100.0f;
    juno_engine_init(STATE); juno_engine_prepare(STATE);
    GOLD=malloc(JUNO_STATE_BYTES); memcpy(GOLD,STATE,JUNO_STATE_BYTES);
    FILE*g=fopen(argv[2],"r"); static int pos[512]; int np=0;
    while(fscanf(g,"%d",&pos[np])==1)++np; fclose(g);
    int patches[4]={0,17,32,61}; static char hitres[512],hitany[512];
    const unsigned char V[3]={0x00,0x37,0x7F};
    int pi,i,k,resdep=0,anydep=0;
    for(pi=0;pi<4;++pi){ int p=patches[pi];
      unsigned char*r=wb+BANK_HEADER+p*BANK_STRIDE;
      unsigned long br,ba; rec(wb,p); br=hres(); ba=hall();
      for(i=0;i<np;++i){ unsigned char sv=r[pos[i]];
        for(k=0;k<3;++k){ if(V[k]==sv)continue; r[pos[i]]=V[k]; rec(wb,p);
          if(hres()!=br) hitres[i]=1; if(hall()!=ba) hitany[i]=1; }
        r[pos[i]]=sv; } }
    for(i=0;i<np;++i){ resdep+=hitres[i]; anydep+=hitany[i]; }
    printf("of %d recall-affecting record bytes: %d move the VCF-RES tail block (7856..8192), %d move any voice cell\n",np,resdep,anydep);
    printf("res-moving record offsets: "); for(i=0;i<np;++i) if(hitres[i]) printf("%d ",pos[i]); printf("\n");
    return 0;
}

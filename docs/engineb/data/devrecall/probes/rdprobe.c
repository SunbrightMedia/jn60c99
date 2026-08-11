#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "juno_engine.h"
#include "juno_apply.h"
#include "juno_driver.h"
void jc_log(unsigned long off,int isw){(void)off;(void)isw;}
#define BANK_HEADER 23
#define BANK_STRIDE 20223
static unsigned char *STATE;
/* hash the cells the recall can touch: use the 343-offset list */
static unsigned long *OFF; static int NOFF;
static unsigned long hash_state(void){
    unsigned long h=1469598103934665603UL;
    for(int i=0;i<NOFF;++i){
        unsigned long w=*(unsigned*)(STATE+OFF[i]);
        h^=w; h*=1099511628211UL;
    }
    return h;
}
static unsigned long run(const unsigned char*bank,int idx,int rate){
    memset(STATE,0,JUNO_STATE_BYTES);
    juno_chorus_init(STATE); JF(STATE,16)=(float)rate;
    juno_engine_init(STATE); juno_engine_prepare(STATE);
    juno_bank_apply(STATE,bank,idx);
    juno_driver_seed_voices(STATE);
    juno_apply_unison_spread(STATE,juno_bank_assign(bank,idx));
    juno_apply_condition(STATE,juno_bank_condition(bank,idx));
    juno_apply_lfo_tempo(STATE,juno_bank_lfo_rate_byte(bank,idx),128.0f);
    return hash_state();
}
int main(int argc,char**argv){
    FILE*f=fopen(argv[1],"rb");fseek(f,0,SEEK_END);long bl=ftell(f);fseek(f,0,SEEK_SET);
    unsigned char*bank=malloc(bl);fread(bank,1,bl,f);fclose(f);
    /* load offsets */
    FILE*g=fopen("touched.txt","r"); OFF=malloc(sizeof(long)*5000); NOFF=0;
    while(fscanf(g,"%lu",&OFF[NOFF])==1) ++NOFF; fclose(g);
    STATE=malloc(JUNO_STATE_BYTES);
    unsigned char*wb=malloc(bl);
    unsigned char mark[BANK_STRIDE]; memset(mark,0,sizeof mark);
    const unsigned char VALS[3]={0x00,0xFF,0x5A};
    int patches[8]={0,2,5,17,32,45,61,63};
    srand(999);
    for(int trial=0;trial<2;++trial){
        memcpy(wb,bank,bl);
        if(trial==1) for(int p=0;p<64;++p){unsigned char*r=wb+BANK_HEADER+p*BANK_STRIDE;
            for(long i=16;i<BANK_STRIDE;++i) r[i]=(unsigned char)(rand()&0xFF);}
        for(int pi=0;pi<8;++pi){
            int p=patches[pi];
            unsigned char*rec=wb+BANK_HEADER+p*BANK_STRIDE;
            unsigned long base=run(wb,p,44100);
            for(long i=0;i<BANK_STRIDE;++i){
                if(mark[i]) continue;
                unsigned char sv=rec[i];
                for(int k=0;k<3;++k){
                    if(VALS[k]==sv) continue;
                    rec[i]=VALS[k];
                    if(run(wb,p,44100)!=base){mark[i]=1;break;}
                }
                rec[i]=sv;
            }
        }
    }
    int n=0; FILE*o=fopen("recread.txt","w");
    for(long i=0;i<BANK_STRIDE;++i) if(mark[i]){++n;fprintf(o,"%ld\n",i);}
    fclose(o);
    printf("RECORD BYTE POSITIONS THAT AFFECT RECALL: %d of %d\n",n,BANK_STRIDE);
    return 0;
}

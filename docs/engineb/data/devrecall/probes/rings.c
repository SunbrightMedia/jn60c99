#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "juno_engine.h"
#include "juno_apply.h"
#include "juno_driver.h"
static const unsigned RC9[9]={6395252,6429412,8594772,10691940,10726260,10759044,101028,6463716,6496500};
int main(int argc,char**argv){
    FILE*f=fopen(argv[1],"rb");fseek(f,0,SEEK_END);long bl=ftell(f);fseek(f,0,SEEK_SET);
    unsigned char*bank=malloc(bl); if(fread(bank,1,bl,f)!=(size_t)bl)return 1; fclose(f);
    unsigned char*st=malloc(JUNO_STATE_BYTES);
    int distinct=0; long long seen[64][9]; int nseen=0;
    for(int p=0;p<64;++p){
        memset(st,0,JUNO_STATE_BYTES);
        juno_chorus_init(st); JF(st,16)=44100.0f;
        juno_engine_init(st); juno_engine_prepare(st);
        juno_bank_apply(st,bank,p); juno_driver_seed_voices(st);
        long long r[9]; long long tot=0;
        for(int i=0;i<9;++i){ r[i]=JI(st,RC9[i]); tot+=r[i]; }
        int found=0; for(int j=0;j<nseen;++j){int eq=1;for(int i=0;i<9;++i)if(seen[j][i]!=r[i])eq=0;if(eq){found=1;break;}}
        if(!found){ for(int i=0;i<9;++i)seen[nseen][i]=r[i]; ++nseen;
            printf("patch %2d NEW ring set: ",p);
            for(int i=0;i<9;++i)printf("%lld ",r[i]);
            printf(" total %lld floats = %.2f MB\n",tot,tot*4.0/1048576.0); }
        distinct=nseen;
    }
    printf("\nDISTINCT ring-length sets across the 64 factory patches: %d\n",distinct);
    return 0; }

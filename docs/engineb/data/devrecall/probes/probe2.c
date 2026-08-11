#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "juno_engine.h"
#include "juno_apply.h"
#include "juno_driver.h"

/* offset log */
#define MAXOFF 40000
static unsigned long *L; static int NL;
static unsigned char *SEEN;   /* bitmap over 12MB/4 words */
static int capture = 0;
long ACC=0;
void jc_log(unsigned long off, int isw){
    (void)isw;
    if(!capture) return;
    ++ACC;
    unsigned long w = off>>2;
    if (off & 3u) { printf("UNALIGNED %lu\n", off); }
    if (w >= (12u*1024u*1024u/4u)) { printf("OOB %lu\n", off); return; }
    if (!(SEEN[w>>3] & (1u<<(w&7)))) { SEEN[w>>3] |= (1u<<(w&7));
        if (NL<MAXOFF) L[NL++]=off; }
}

/* record byte reads: we instrument by copying record into a guarded buffer? simpler:
   run recall over records where every non-carried byte is a distinct marker is hard.
   Instead: differential -- flip each record byte and see if any state cell changes. */

#define BANK_HEADER 23
#define BANK_STRIDE 20223
#define BANK_BLOB   16

static unsigned char *STATE;

static void full_recall(const unsigned char *bank, int idx, int cond, int assign){
    juno_bank_apply(STATE, bank, idx);
    juno_driver_seed_voices(STATE);
    juno_apply_unison_spread(STATE, assign);
    juno_apply_condition(STATE, cond);
    juno_apply_lfo_tempo(STATE, juno_bank_lfo_rate_byte(bank, idx), 128.0f);
}

int main(int argc, char**argv){
    FILE*f=fopen(argv[1],"rb"); if(!f){perror("bank");return 1;}
    fseek(f,0,SEEK_END); long bl=ftell(f); fseek(f,0,SEEK_SET);
    unsigned char*bank=malloc(bl); fread(bank,1,bl,f); fclose(f);
    printf("bank %ld bytes, %d patches\n", bl, juno_bank_num_patches(bank,bl));

    L=malloc(sizeof(long)*MAXOFF);
    SEEN=calloc(12u*1024u*1024u/4u/8u+8,1);
    STATE=malloc(JUNO_STATE_BYTES);

    int rates[3]={44100,48000,96000};
    unsigned char *wb = malloc(bl);

    srand(12345);
    for(int trial=0; trial<3; ++trial){
      memcpy(wb,bank,bl);
      if(trial>0){
        /* synthetic: randomise every record nibble in the body (past the 16-char name) */
        for(int p=0;p<64;++p){
          unsigned char*rec=wb+BANK_HEADER+p*BANK_STRIDE;
          for(long i=16;i<BANK_STRIDE;++i) rec[i]=(unsigned char)(rand()&0xFF);
        }
      }
      for(int r=0;r<3;++r){
        for(int p=0;p<64;++p){
            memset(STATE,0,JUNO_STATE_BYTES);
            capture=0;
            juno_chorus_init(STATE); JF(STATE,16)=(float)rates[r];
            juno_engine_init(STATE); juno_engine_prepare(STATE);
            capture=1;
            int assign = (trial==0)? juno_bank_assign(wb,p) : (rand()%4);
            int cond   = (trial==0)? juno_bank_condition(wb,p) : (rand()%256);
            full_recall(wb,p,cond,assign);
            capture=0;
        }
      }
      printf("after trial %d (%s): %d distinct offsets\n", trial,
             trial? "SYNTHETIC":"factory", NL);
    }

    /* cluster */
    int cmp(const void*a,const void*b){unsigned long x=*(const unsigned long*)a,y=*(const unsigned long*)b;return x<y?-1:x>y;}
    qsort(L,NL,sizeof(long),cmp);
    FILE*o=fopen("touched.txt","w");
    for(int i=0;i<NL;++i) fprintf(o,"%lu\n",L[i]);
    fclose(o);
    printf("ACCESSES total %ld  per (patch,rate,trial) %.0f\n", ACC, (double)ACC/(64*3*3));
    printf("TOTAL %d distinct 4-byte cells touched by recall\n", NL);
    return 0;
}

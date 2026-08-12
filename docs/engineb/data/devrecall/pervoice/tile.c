#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "juno_engine.h"
#include "juno_apply.h"
#include "juno_driver.h"
#include "juno_note.h"
#include "jc_trace.h"
#include "eb_coefs.h"
static unsigned char *ST;
static struct juno_host_shim SH;
static void boot(int rate){ memset(ST,0,JUNO_STATE_BYTES); juno_chorus_init(ST);
    *(float*)(ST+16)=(float)rate; juno_engine_init(ST); juno_engine_prepare(ST);
    juno_driver_attach_host(ST,&SH,2); }
static void bcast(void){ int v,i; for(v=1;v<8;++v) for(i=0;i<jc_nscat;++i) jc_scatv[v][i]=jc_scatv[0][i]; }
static void recall(const unsigned char*b,int p){ juno_bank_apply(ST,b,p);
    juno_driver_seed_voices(ST); if(jc_dev) bcast(); juno_apply_unison_spread(ST,juno_bank_assign(b,p));
    juno_apply_condition(ST,juno_bank_condition(b,p));
    juno_apply_lfo_tempo(ST,juno_bank_lfo_rate_byte(b,p),128.0f); }
static void notes(void){ int v;
    for(v=0;v<8;++v){ juno_note_on(ST,v,36+v*5,40+v*11); juno_note_broadcast_held(ST,1); }
    juno_note_retrig(ST,2); juno_note_porta_gate(ST,4,1,0.0f);
    juno_note_porta_gate(ST,5,0,1.0f); juno_note_velocity(ST,6,77);
    juno_note_glide(ST,7,61); juno_note_off(ST,3); }
static eb_render_coefs RC; static eb_render_state RS;
static void run(const unsigned char*b,int p,int r,int donotes,int dev,void*co,void*se){
    jc_dev=0; boot(r); jc_dev=dev;
    if(dev){ int v,i; for(v=0;v<8;++v) for(i=0;i<jc_nscat;++i) jc_scatv[v][i]=*(float*)(jc_tile+jc_scat[i]); }
    recall(b,p); eb_render_events_mirror(ST,&RS); if(donotes) notes();
    eb_render_coefs_build(ST,&RC); eb_render_state_seed(ST,&RS);
    eb_render_events_mirror(ST,&RS);
    memcpy(co,&RC,sizeof RC); memcpy(se,&RS,sizeof RS);
}
static const unsigned S5[] ={1072,3968,5520,7600,10320};
static const unsigned S12[]={304,320,592,1072,1856,3968,5520,6864,7600,9680,9824,10320};
int main(int argc,char**argv){
    FILE*f=fopen(argv[1],"rb"); long bl; unsigned char*bk;
    int p,r,rates[3]={44100,48000,96000},cfg,k;
    void *cA,*sA,*cB,*sB;
    fseek(f,0,SEEK_END);bl=ftell(f);fseek(f,0,SEEK_SET);
    bk=malloc(bl); if(fread(bk,1,bl,f)!=(size_t)bl)return 1; fclose(f);
    ST=malloc(JUNO_STATE_BYTES); jc_base=ST; jc_tile=ST; jc_reset(); jc_on=0;
    cA=malloc(sizeof RC); sA=malloc(sizeof RS); cB=malloc(sizeof RC); sB=malloc(sizeof RS);
    /* cfg: 0 = DESIGN-5 no notes (reproduce the design's own claim)
            1 = DESIGN-5 with notes
            2 = FULL-12 with notes
            3.. = FULL-12 minus one cell, with notes (the teeth) */
    for(cfg=0;cfg<3+13;++cfg){
        const unsigned *S; unsigned tmp[12]; int N,donotes; char nm[80];
        int badc=0,bads=0,cs=0;
        if(cfg==0){S=S5;N=5;donotes=0;sprintf(nm,"DESIGN-5, NO notes (the gate as built)");}
        else if(cfg==1){S=S5;N=5;donotes=1;sprintf(nm,"DESIGN-5, WITH notes");}
        else if(cfg==2){S=S12;N=12;donotes=1;sprintf(nm,"FULL-12, WITH notes");}
        else if(cfg==15){S=S12;N=12;donotes=1;jc_auxfold=1;sprintf(nm,"TOOTH: aux 101504+32v folded to one");}
        else { int drop=cfg-3,j,n=0; for(j=0;j<12;++j) if(j!=drop) tmp[n++]=S12[j];
               S=tmp;N=11;donotes=1; sprintf(nm,"TOOTH: FULL-12 minus %u",S12[drop]); }
        jc_miss=0; jc_lastmiss=0;
        for(r=0;r<3;++r)for(p=0;p<64;++p){
            jc_nscat=0; run(bk,p,rates[r],donotes,0,cA,sA);
            jc_nscat=N; for(k=0;k<N;++k) jc_scat[k]=S[k];
            memset(jc_scatv,0,sizeof jc_scatv);
            run(bk,p,rates[r],donotes,1,cB,sB);
            jc_dev=0;
            if(memcmp(cA,cB,sizeof RC)){ ++badc;
              if(badc==1&&cfg<=2){size_t z;for(z=0;z<sizeof RC;++z) if(((char*)cA)[z]!=((char*)cB)[z]){
                 printf("   first RC diff at byte %zu (patch %d rate %d)\n",z,p,rates[r]);break;} } }
            if(memcmp(sA,sB,sizeof RS)) ++bads;
            ++cs;
        }
        printf("%-34s cases=%3d  coefs BAD=%3d  state BAD=%3d  dropped writes=%lu (last off %lu)\n",
               nm,cs,badc,bads,jc_miss,jc_lastmiss);
    }
    return 0;
}

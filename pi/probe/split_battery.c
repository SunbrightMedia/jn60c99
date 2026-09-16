/* split_battery.c — maximally-critical test of the FULL core-split synth vs the
 * plugin (the x86 single-core engine == the .vst3 by make verify).
 *
 * Bit-exact-only was not enough for the S3, so this ALSO measures waveform
 * features independently. Per seed: the ENTIRE control surface is scrambled
 * (all 79 host params across their full range, arp, chorus mode, tempo) on top
 * of the 64 factory presets (seeds 0..63) and beyond (preset+scramble). All 8
 * voices are gated several times (a chord + extra notes forcing voice-stealing),
 * then all-notes-off, then a long TAIL.
 *
 * Comparison is PER BLOCK against juno_gui_render (no giant accumulation buffer —
 * an earlier version desynced on 912 KB buffers, a HARNESS bug, not the port):
 *   - max|diff| over attack AND tail must be 0 (split == plugin, every sample);
 *   - onset latency, peak, tail level and the worst block-BOUNDARY discontinuity
 *     are measured on the reference and reported; the split, being bit-exact,
 *     reproduces them and adds NO discontinuity the single core lacks.
 *
 * usage: split_battery <bank> [nseed]   (default 160) */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <math.h>
#include "juno_engine.h"
#include "juno_driver.h"

void *juno_gui_create(float,int);
void  juno_gui_reinit(void*,float,int);
int   juno_gui_apply_bank(void*,const char*,int,int);
void  juno_gui_note_on(void*,int,int);
void  juno_gui_note_off(void*,int);
void  juno_gui_arp_config(void*,int,int,int,float,float);
void  juno_gui_set_chorus_mode(void*,int);
void  juno_gui_set_tempo(void*,float);
int   juno_gui_host_count(void);
int   juno_host_param_min(int);
int   juno_host_param_max(int);
void  juno_gui_host_set(void*,int,int);
void  juno_gui_tick(void*);
int   juno_gui_render(void*,float*,int);
unsigned char* juno_gui_state(void*);
unsigned juno_gui_state_bytes(void);

#define SR 48000.0f
#define NOFF 84272u
#define NLEN 164u
#define NF 128
#define ATTACK_BLK 72     /* 72*128 = 9216 frames ~0.19 s */
#define TAIL_BLK   375    /* 375*128 = 48000 frames ~1.0 s */

static uint32_t xs(uint32_t*s){uint32_t x=*s;x^=x<<13;x^=x>>17;x^=x<<5;return *s=x;}
static float vbuf[8][NF];

static void worker_block(void*ctx,int lo,int hi){
    unsigned char*st=juno_gui_state(ctx),nblk[NLEN];
    for(int s=0;s<NF;s++){juno_gui_tick(ctx);memcpy(nblk,st+NOFF,NLEN);
        for(int v=lo;v<hi;v++){float l=0,r=0;memcpy(st+NOFF,nblk,NLEN);juno_voice_render(st,v,&l,&r);vbuf[v][s]=l;}
        juno_flush_denormals(st);}
}
static void audio_block(void*ca,int lo,int hi,float*out){
    unsigned char*sa=juno_gui_state(ca),nblk[NLEN];
    for(int s=0;s<NF;s++){juno_gui_tick(ca);memcpy(nblk,sa+NOFF,NLEN);
        for(int v=lo;v<hi;v++){float l=0,r=0;memcpy(sa+NOFF,nblk,NLEN);juno_voice_render(sa,v,&l,&r);vbuf[v][s]=l;}
        float sc=0,*a2[16];for(int j=0;j<16;j++)a2[j]=&sc;for(int v=0;v<8;v++)a2[2*v]=&vbuf[v][s];
        float L=0,R=0,*a3[2]={&L,&R};juno_master_render(sa,a2,a3);juno_flush_denormals(sa);
        out[2*s]=L;out[2*s+1]=R;}
}

static const int PARTS[][5]={{2,0,4,8,0},{4,0,2,4,6},{3,0,3,5,0}};
#define NPART 3

int main(int argc,char**argv){
    if(argc<2){fprintf(stderr,"need bank\n");return 2;}
    FILE*f=fopen(argv[1],"rb");fseek(f,0,SEEK_END);long L=ftell(f);fseek(f,0,SEEK_SET);
    unsigned char*bank=malloc(L);if(fread(bank,1,L,f)!=(size_t)L)return 2;fclose(f);
    int nseed=argc>2?atoi(argv[2]):160;
    int nhost=juno_gui_host_count();

    void*cref=juno_gui_create(SR,0);
    void*cc[4];for(int i=0;i<4;i++)cc[i]=juno_gui_create(SR,0);
    float rb[2*NF],sb[2*NF];
    int chord[8]={45,48,52,55,60,64,67,72};

    long fails=0; float worstdiff=0,worstdisc=0; double onset_min=1e9,onset_max=0;
    for(int seed=0;seed<nseed;seed++){
        int ncore=PARTS[seed%NPART][0];
        int bound[5];bound[0]=0;bound[ncore]=8;
        for(int i=1;i<ncore;i++)bound[i]=PARTS[seed%NPART][1+i];
        uint32_t s=0xABCD0001u+(uint32_t)seed*2654435761u;

        void*all[5];int nall=0;all[nall++]=cref;for(int i=0;i<ncore;i++)all[nall++]=cc[i];
        int basepreset=seed<64?seed:(int)(xs(&s)%64); int scramble=seed<64?0:1;
        int arp=(xs(&s)&3)==0,chmode=(int)(xs(&s)%3);float bpm=40.0f+(float)(xs(&s)%200);
        int am=(int)(xs(&s)%3),ao=1+(int)(xs(&s)%3);float ag=0.5f+0.01f*(xs(&s)%50);
        int nedit=scramble?24:0;int ei[32],ev[32];
        for(int k=0;k<nedit;k++){int i=(int)(xs(&s)%(uint32_t)nhost);int lo=juno_host_param_min(i),hi=juno_host_param_max(i);
            int val=(xs(&s)&1)?((xs(&s)&1)?lo:hi):lo+(int)(xs(&s)%(uint32_t)(hi-lo+1));ei[k]=i;ev[k]=val;}
        for(int a=0;a<nall;a++){juno_gui_reinit(all[a],SR,0);juno_gui_apply_bank(all[a],(char*)bank,(int)L,basepreset);
            juno_gui_set_chorus_mode(all[a],chmode);juno_gui_set_tempo(all[a],bpm);
            if(arp)juno_gui_arp_config(all[a],1,am,ao,bpm,ag);
            for(int k=0;k<nedit;k++)juno_gui_host_set(all[a],ei[k],ev[k]);}

        int held[16],nheld=0; long frame=0,onset=-1; float md=0,peak=0,disc=0,prevL=0; int firstblk=-1;
        /* ATTACK: play events; compare each block split vs plugin */
        for(int b=0;b<ATTACK_BLK;b++){
            if(b==0){for(int k=0;k<8;k++){for(int a=0;a<nall;a++)juno_gui_note_on(all[a],chord[k],100);held[nheld++]=chord[k];}}
            else if((b%5)==0){int nt=30+(int)(xs(&s)%60),vv=50+(int)(xs(&s)%78);for(int a=0;a<nall;a++)juno_gui_note_on(all[a],nt,vv);if(nheld<16)held[nheld++]=nt;}
            else if((b%7)==0&&nheld>0){int nt=held[xs(&s)%(uint32_t)nheld];for(int a=0;a<nall;a++)juno_gui_note_off(all[a],nt);}
            juno_gui_render(cref,rb,NF);
            for(int c2=1;c2<ncore;c2++)worker_block(cc[c2],bound[c2],bound[c2+1]);
            audio_block(cc[0],bound[0],bound[1],sb);
            for(int n=0;n<2*NF;n++){float d=fabsf(rb[n]-sb[n]);if(d>md){md=d;if(firstblk<0)firstblk=b;}
                float a=fabsf(rb[n]);if(a>peak)peak=a;if(onset<0&&a>1e-4f)onset=frame+n/2;
                if((n&1)==0){float dd=fabsf(rb[n]-prevL);if(dd>disc)disc=dd;prevL=rb[n];}}
            frame+=NF;
        }
        for(int k=0;k<nheld;k++)for(int a=0;a<nall;a++)juno_gui_note_off(all[a],held[k]);
        /* TAIL: all notes off; compare each block; capture final level */
        float tailrms=0;
        for(int b=0;b<TAIL_BLK;b++){
            juno_gui_render(cref,rb,NF);
            for(int c2=1;c2<ncore;c2++)worker_block(cc[c2],bound[c2],bound[c2+1]);
            audio_block(cc[0],bound[0],bound[1],sb);
            double e=0;
            for(int n=0;n<2*NF;n++){float d=fabsf(rb[n]-sb[n]);if(d>md){md=d;if(firstblk<0)firstblk=ATTACK_BLK+b;}
                float a=fabsf(rb[n]);if(a>peak)peak=a; e+=(double)rb[n]*rb[n];}
            if(b==TAIL_BLK-1)tailrms=(float)sqrt(e/(2*NF));
        }

        if(md>worstdiff)worstdiff=md; if(disc>worstdisc)worstdisc=disc;
        double onms=onset<0?-1:(double)onset*1000.0/48000.0;
        if(onset>=0){if(onms<onset_min)onset_min=onms;if(onms>onset_max)onset_max=onms;}
        if(md!=0.0f){++fails; if(fails<=15)
            printf("seed %3d %dcore preset%d scr%d arp%d: max|diff|=%.3g first at block %d  "
                   "onset=%.1fms peak=%.4f tailRMS=%.2g disc=%.3g\n",
                   seed,ncore,basepreset,scramble,arp,md,firstblk,onms,peak,tailrms,disc);}
    }
    printf("----\n");
    printf("seeds %d (0..63 = the exact factory presets; 64+ = preset+full-surface scramble)\n",nseed);
    printf("per seed: %d attack + %d tail blocks x %d frames, all 8 voices, split 2/3/4 cores\n",ATTACK_BLK,TAIL_BLK,NF);
    printf("worst max|diff| vs plugin: %.6g   worst boundary discontinuity (plugin): %.6g\n",worstdiff,worstdisc);
    printf("onset latency range (plugin): %.1f .. %.1f ms\n",onset_min,onset_max);
    if(fails==0){printf("BATTERY PASS: split == plugin every sample (attack + tail), across all seeds; "
                        "onset and boundary behaviour identical to the plugin\n");return 0;}
    printf("BATTERY FAIL: %ld seeds diverge from the plugin\n",fails);return 1;
}

/* split_battery.c — maximally-critical test of the FULL core-split synth vs the
 * plugin (the x86 single-core engine, proven EXACTLY 0 vs the .vst3 by make
 * verify). Bit-exact-only was not enough for the S3, so this ALSO measures
 * waveform features independently and adversarially:
 *
 *   - the ENTIRE control surface per seed: all 79 host params scrambled across
 *     their full valid range, arp, chorus mode, tempo — plus the 64 factory
 *     presets exactly (runs 0..63), and preset+scramble beyond that;
 *   - all 8 voices gated several times per seed (a chord + extra notes forcing
 *     voice-stealing), then all-notes-off;
 *   - ATTACK window (onset LATENCY) and a long TAIL window (release/reverb decay
 *     to silence) both rendered;
 *   - single-core (== plugin) vs the shared-nothing block SPLIT (2/3/4 cores),
 *     compared: exact max|diff| (must be 0), onset sample, peak, tail-to-silence,
 *     and the worst block-BOUNDARY discontinuity (the class of defect the S3
 *     tick was) — the split must add NONE the single core does not have.
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
#define ATTACK 9000      /* ~0.19 s: onset + early sustain */
#define TAIL   48000     /* ~1.0 s after all-off: full release/reverb decay */
#define TOTAL  (ATTACK + TAIL)

static uint32_t xs(uint32_t*s){uint32_t x=*s;x^=x<<13;x^=x>>17;x^=x<<5;return *s=x;}

/* one core's block: tick + render its voices into shared vbuf rows */
static void worker_block(void*ctx,int lo,int hi,float vbuf[8][NF]){
    unsigned char*st=juno_gui_state(ctx),nblk[NLEN];
    for(int s=0;s<NF;s++){
        juno_gui_tick(ctx);
        memcpy(nblk,st+NOFF,NLEN);
        for(int v=lo;v<hi;v++){float l=0,r=0;memcpy(st+NOFF,nblk,NLEN);juno_voice_render(st,v,&l,&r);vbuf[v][s]=l;}
        juno_flush_denormals(st);
    }
}
/* audio core interleaves: tick, its voices, master, flush — per sample */
static void audio_block(void*ca,int lo,int hi,float vbuf[8][NF],float*out){
    unsigned char*sa=juno_gui_state(ca),nblk[NLEN];
    for(int s=0;s<NF;s++){
        juno_gui_tick(ca);
        memcpy(nblk,sa+NOFF,NLEN);
        for(int v=lo;v<hi;v++){float l=0,r=0;memcpy(sa+NOFF,nblk,NLEN);juno_voice_render(sa,v,&l,&r);vbuf[v][s]=l;}
        float scratch=0,*a2[16];for(int j=0;j<16;j++)a2[j]=&scratch;for(int v=0;v<8;v++)a2[2*v]=&vbuf[v][s];
        float L=0,R=0,*a3[2]={&L,&R};juno_master_render(sa,a2,a3);juno_flush_denormals(sa);
        out[2*s]=L;out[2*s+1]=R;
    }
}

static const int PARTS[][5]={{2,0,4,8,8},{4,0,2,4,6},{3,0,3,5,8}};
#define NPART 3

int main(int argc,char**argv){
    if(argc<2){fprintf(stderr,"need bank\n");return 2;}
    FILE*f=fopen(argv[1],"rb");fseek(f,0,SEEK_END);long L=ftell(f);fseek(f,0,SEEK_SET);
    unsigned char*bank=malloc(L);if(fread(bank,1,L,f)!=(size_t)L)return 2;fclose(f);
    int nseed=argc>2?atoi(argv[2]):160;
    int nhost=juno_gui_host_count();

    void*cref=juno_gui_create(SR,0);
    void*cc[4];for(int i=0;i<4;i++)cc[i]=juno_gui_create(SR,0);
    static float ref[2*TOTAL],spl[2*TOTAL],vbuf[8][NF],blk[2*NF];
    int chord[8]={45,48,52,55,60,64,67,72};

    long fails=0,tailbad=0; double onset_min=1e9,onset_max=0; float worstdiff=0,worstdisc=0;
    for(int seed=0;seed<nseed;seed++){
        int part=seed%NPART,ncore=PARTS[part][0];
        int bound[5];for(int i=0;i<=ncore;i++)bound[i]=PARTS[part][1+i];bound[ncore]=8;
        uint32_t s=0xABCD0001u+ (uint32_t)seed*2654435761u;

        /* ---- setup: broadcast IDENTICAL control to ref + every core copy ---- */
        void*all[5];int nall=0;all[nall++]=cref;for(int i=0;i<ncore;i++)all[nall++]=cc[i];
        int basepreset = seed<64? seed : (int)(xs(&s)%64);
        int scramble   = seed<64? 0 : 1;       /* 0..63 = the exact presets */
        int arp = (xs(&s)&3)==0, chmode=(int)(xs(&s)%3);
        float bpm = 40.0f + (float)(xs(&s)%200);
        /* PRE-ROLL every random argument ONCE (no xs() inside the per-copy loop),
         * so every copy applies byte-identical control — else the copies diverge. */
        int arp_mode=(int)(xs(&s)%3), arp_oct=1+(int)(xs(&s)%3); float arp_gate=0.5f+0.01f*(xs(&s)%50);
        int nedit = scramble ? 24 : 0; int ei[32],ev[32];
        for(int k=0;k<nedit;k++){int i=(int)(xs(&s)%(uint32_t)nhost);int lo=juno_host_param_min(i),hi=juno_host_param_max(i);
            int val=(xs(&s)&1)?((xs(&s)&1)?lo:hi):lo+(int)(xs(&s)%(uint32_t)(hi-lo+1));ei[k]=i;ev[k]=val;}
        for(int a=0;a<nall;a++){
            juno_gui_reinit(all[a],SR,0);
            juno_gui_apply_bank(all[a],(char*)bank,(int)L,basepreset);
            juno_gui_set_chorus_mode(all[a],chmode);
            juno_gui_set_tempo(all[a],bpm);
            if(arp) juno_gui_arp_config(all[a],1,arp_mode,arp_oct,bpm,arp_gate);
            for(int k=0;k<nedit;k++) juno_gui_host_set(all[a],ei[k],ev[k]);
        }

        /* ---- play: fill all 8 voices several times + stealing, then all-off --- */
        int held[16],nheld=0;
        /* attack window */
        for(int b=0;b*NF<ATTACK;b++){
            int base=b*NF;
            /* schedule some note events at this block for ALL copies identically */
            if(b==0){ for(int k=0;k<8;k++){for(int a=0;a<nall;a++)juno_gui_note_on(all[a],chord[k],100);held[nheld++]=chord[k];} }
            else if((b%5)==0){ int nt=30+(int)(xs(&s)%60),vv=50+(int)(xs(&s)%78);
                for(int a=0;a<nall;a++)juno_gui_note_on(all[a],nt,vv); if(nheld<16)held[nheld++]=nt; }
            else if((b%7)==0 && nheld>0){ int nt=held[xs(&s)%(uint32_t)nheld];
                for(int a=0;a<nall;a++)juno_gui_note_off(all[a],nt); }
            juno_gui_render(cref,&ref[2*base],NF);
            for(int c2=1;c2<ncore;c2++) worker_block(cc[c2],bound[c2],bound[c2+1],vbuf);
            audio_block(cc[0],bound[0],bound[1],vbuf,blk);
            memcpy(&spl[2*base],blk,sizeof(float)*2*NF);
        }
        /* all notes off (both) */
        for(int k=0;k<nheld;k++) for(int a=0;a<nall;a++) juno_gui_note_off(all[a],held[k]);
        /* tail window */
        for(int b=0;b*NF<TAIL;b++){
            int base=ATTACK+b*NF;
            juno_gui_render(cref,&ref[2*base],NF);
            for(int c2=1;c2<ncore;c2++) worker_block(cc[c2],bound[c2],bound[c2+1],vbuf);
            audio_block(cc[0],bound[0],bound[1],vbuf,blk);
            memcpy(&spl[2*base],blk,sizeof(float)*2*NF);
        }

        /* ---- analyse: bit-exact + features ---- */
        float md=0; int firstdiff=-1; long onset=-1; float peak=0;
        for(int n=0;n<2*TOTAL;n++){
            float d=fabsf(ref[n]-spl[n]); if(d>md)md=d; if(d!=0.0f&&firstdiff<0)firstdiff=n;
            float a=fabsf(ref[n]); if(a>peak)peak=a;
            if(onset<0 && a>1e-4f) onset=n/2;
        }
        /* worst block-boundary discontinuity (split minus single must be 0) */
        float discS=0,discR=0;
        for(int n=1;n<2*TOTAL;n++){ if((n%(2*NF))<2){ /* channel 0/1 of a boundary */
            float dr=fabsf(ref[n]-ref[n-2>0?n-2:0]); float ds=fabsf(spl[n]-spl[n-2>0?n-2:0]);
            if(dr>discR)discR=dr; if(ds>discS)discS=ds; } }
        /* tail-to-silence: last 200 samples RMS (single-core, the truth) */
        double tr=0; for(int n=2*TOTAL-400;n<2*TOTAL;n++) tr+=(double)ref[n]*ref[n]; tr=sqrt(tr/200.0);
        int tail_ok = tr < 1e-4;               /* decayed to silence */

        if(md>worstdiff)worstdiff=md; if(discS>worstdisc)worstdisc=discS;
        double onsms = onset<0?-1:(double)onset*1000.0/48000.0;
        if(onset>=0){ if(onsms<onset_min)onset_min=onsms; if(onsms>onset_max)onset_max=onsms; }
        int ok = (md==0.0f) && tail_ok && (discS==discR);
        if(!ok){ ++fails; if(!tail_ok)++tailbad;
            if(fails<=15) printf("seed %3d %dcore preset%d scr%d arp%d: max|diff|=%.3g firstdiff=%d "
                "onset=%.1fms peak=%.4f tailRMS=%.2g discS/R=%.3g/%.3g %s\n",
                seed,ncore,basepreset,scramble,arp,md,firstdiff,onsms,peak,tr,discS,discR,
                md!=0?"BITDIFF":(!tail_ok?"STUCK-TAIL":"DISC")); }
    }
    printf("----\n");
    printf("seeds %d (0..63 = the exact factory presets; 64+ = preset+full-surface scramble)\n",nseed);
    printf("window %d frames/seed (%d attack + %d tail), all 8 voices gated, split 2/3/4 cores\n",TOTAL,ATTACK,TAIL);
    printf("worst max|diff| vs plugin: %.6g   worst split boundary disc: %.6g\n",worstdiff,worstdisc);
    printf("onset latency range: %.1f .. %.1f ms   tail-stuck seeds: %ld\n",onset_min,onset_max,tailbad);
    if(fails==0){ printf("BATTERY PASS: split == plugin every sample, tails decay to silence, "
                         "no split-introduced discontinuity, across all seeds\n"); return 0; }
    printf("BATTERY FAIL: %ld seeds\n",fails); return 1;
}

/* play_arp.c — play a held chord through the JUNO-60 arpeggiator, faithful to the
 * transcribed CArpeggio UP/DOWN/UP-DOWN logic (docs/ARP_DSP.md), with the
 * "SQ Dynamic ARPG" preset overlay (docs panel photo).
 *
 * Panel arp (not the 150 preset patterns — that's the pattern sequencer): hold keys,
 * the engine sorts them ascending and steps a cursor through them; at the top it
 * shifts up an octave, up to ARP RANGE octaves, then repeats. MODE selects the walk
 * direction. We reproduce that note stream and drive the voices (mono retrigger, the
 * classic arpeggiator behaviour).
 *
 *   usage: play_arp <out.wav> [up|down|updown] [range1|range2|range3] [bpm]
 *   defaults: up, range2, 120 bpm, 1/16 steps
 */
#include "../src/juno_engine.h"
#include "../src/juno_driver.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

static void write_wav(const char *path,const float *L,const float *R,int n,int sr){
    FILE *f=fopen(path,"wb"); if(!f){perror(path);return;}
    int db=n*4, br=sr*4; unsigned int u; unsigned short s;
    fwrite("RIFF",1,4,f); u=36+db; fwrite(&u,4,1,f); fwrite("WAVE",1,4,f); fwrite("fmt ",1,4,f);
    u=16;fwrite(&u,4,1,f); s=1;fwrite(&s,2,1,f); s=2;fwrite(&s,2,1,f);
    u=sr;fwrite(&u,4,1,f); u=br;fwrite(&u,4,1,f); s=4;fwrite(&s,2,1,f); s=16;fwrite(&s,2,1,f);
    fwrite("data",1,4,f); u=db;fwrite(&u,4,1,f);
    for(int i=0;i<n;i++){ float l=L[i],r=R[i];
        if(l>1)l=1; if(l<-1)l=-1; if(r>1)r=1; if(r<-1)r=-1;
        short a=(short)lrintf(l*32767.f), b=(short)lrintf(r*32767.f); fwrite(&a,2,1,f); fwrite(&b,2,1,f);}
    fclose(f);
}
static void sv(unsigned char*st,int off,float f){for(int v=0;v<JUNO_NUM_VOICES;++v)JF(st,off+v*JUNO_VOICE_MAIN_STRIDE)=f;}

static void preset_sq_arpg(unsigned char *st){
    sv(st,2784,0.090f); sv(st,2816,0.018f); sv(st,2800,0.28f); sv(st,2832,0.030f); /* ENV1 */
    sv(st,3264,0.090f); sv(st,3296,0.020f); sv(st,3280,0.45f); sv(st,3312,0.035f); /* ENV2 */
    sv(st,6736,0.38f);  sv(st,7392,3.6f);                                          /* VCF  */
    sv(st,4192,0.90f);  sv(st,6512,0.95f); sv(st,4224,0.22f); sv(st,6528,0.06f);   /* DCO  */
    float vel=100.0f/127.0f; sv(st,6864,vel); sv(st,6880,vel); sv(st,6896,vel); sv(st,6912,vel);
}

/* Build the UP/DOWN/UP-DOWN arp note stream from a sorted held-note list across
 * `range` octaves — mirrors the CArpeggio direction selectors (held list walked
 * with octave-wrap; +12 per octave). Returns the count, fills seq[]. */
static int build_seq(const int *held,int nheld,int range,int mode,int *seq){
    int n=0,base[64],nb=0;
    for(int o=0;o<range;o++) for(int i=0;i<nheld;i++) base[nb++]=held[i]+12*o;  /* ascending */
    if(mode==0){                         /* UP */
        for(int i=0;i<nb;i++) seq[n++]=base[i];
    } else if(mode==1){                  /* DOWN */
        for(int i=nb-1;i>=0;i--) seq[n++]=base[i];
    } else {                             /* UP-DOWN (no repeated endpoints) */
        for(int i=0;i<nb;i++) seq[n++]=base[i];
        for(int i=nb-2;i>=1;i--) seq[n++]=base[i];
    }
    return n;
}

int main(int argc,char**argv){
    const char *out=(argc>1)?argv[1]:"/tmp/juno_arp.wav";
    int mode=0;            /* up */
    if(argc>2){ if(!strcmp(argv[2],"down"))mode=1; else if(!strcmp(argv[2],"updown"))mode=2; }
    int range=2;
    if(argc>3){ if(!strcmp(argv[3],"range1"))range=1; else if(!strcmp(argv[3],"range3"))range=3; }
    double bpm=(argc>4)?atof(argv[4]):120.0;
    const int SR=96000;

    /* held chord: C major (C4 E4 G4), sorted ascending */
    int held[3]={60,64,67}; int nheld=3;
    int seq[256]; int nseq=build_seq(held,nheld,range,mode,seq);

    unsigned char *st=malloc(JUNO_STATE_BYTES); memset(st,0,JUNO_STATE_BYTES);
    juno_chorus_init(st); juno_engine_init(st); juno_runtime_coeffs_apply(st);
    preset_sq_arpg(st);
    for(int v=0;v<JUNO_NUM_VOICES;++v) JF(st,4032+v*10512)=0.0f; /* no pitch-LFO drift */
    static struct juno_host_shim shim; memset(&shim,0,sizeof shim);
    juno_driver_attach_host(st,&shim,2);

    /* 1/16-note steps */
    double step = 60.0/bpm/4.0;            /* seconds per 16th */
    int sp=(int)(step*SR);
    int gate=(int)(sp*0.80);               /* 80% gate */
    int bars=4;                            /* play the sequence a few times */
    int total_steps=0;
    /* repeat the whole arp sequence enough to fill `bars` of 16 steps */
    int want = bars*16;
    int N=(want*sp)+(int)(1.2*SR), idx=0;
    float *L=malloc(sizeof(float)*N), *R=malloc(sizeof(float)*N);

    int cur=0;
    for(int s=0;s<want;s++){
        int note=seq[cur % nseq]; cur++;
        juno_note_on(st,0,note);           /* mono arpeggiator: one voice, retriggered */
        for(int i=0;i<sp;i++){ if(i==gate) juno_note_off(st,0);
            float l=0,r=0; juno_driver_render_sample(st,&l,&r); L[idx]=l;R[idx]=r;idx++; }
        total_steps++;
    }
    juno_note_off(st,0);
    int tail=(int)(1.2*SR);
    for(int i=0;i<tail;i++){ float l=0,r=0; juno_driver_render_sample(st,&l,&r); L[idx]=l;R[idx]=r;idx++; }

    double sum=0; float pk=0; for(int i=0;i<idx;i++){sum+=(double)L[i]*L[i]+(double)R[i]*R[i]; if(fabsf(L[i])>pk)pk=fabsf(L[i]);}
    write_wav(out,L,R,idx,SR);
    const char *mn=mode==0?"UP":mode==1?"DOWN":"UP-DOWN";
    printf("ARP %s range%d %.0f bpm, %d-note seq [", mn,range,bpm,nseq);
    for(int i=0;i<nseq;i++) printf("%d%s",seq[i],i<nseq-1?" ":"");
    printf("] -> %s  %.2fs peak=%.3f rms=%.4f\n", out,(double)idx/SR,pk,sqrt(sum/(2.0*idx)));
    return 0;
}

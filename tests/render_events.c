/* render_events.c — Phase 0 oracle: render the port from an explicit event log so its
 * output can be A/B'd sample-for-sample against a plugin reference render.
 *
 *   usage: render_events <events.txt> <out.wav>
 *
 * events.txt (whitespace-separated; '#' comments):
 *   sr     96000            # sample rate (engine coeffs are 96 kHz — keep 96000)
 *   dur    5.0              # total seconds to render
 *   patch  base|sqarpg      # base = captured PD Juno Pad; sqarpg = + SQ overlay
 *   <t> on  <midi> <vel>    # note-on  at time t (s), velocity 1..127
 *   <t> off <midi>          # note-off at time t (s)
 *
 * Notes are auto-allocated to the 8 voices (first free voice; freed on note-off).
 * This is the ground-truth-comparable renderer — keep it deterministic and free of
 * any "matching" fudge. Patch overlays live here only so we can test what we can. */
#include "../src/juno_engine.h"
#include "../src/juno_driver.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

static void write_wav(const char *path,const float *L,const float *R,int n,int sr){
    FILE *f=fopen(path,"wb"); if(!f){perror(path);exit(1);}
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

/* SQ Dynamic ARPG overlay (hand-tuned approximation; documented as such). */
static void overlay_sqarpg(unsigned char *st){
    sv(st,2784,0.060f); sv(st,2816,0.0047f); sv(st,2800,0.80f); sv(st,2832,0.030f);
    sv(st,3264,0.060f); sv(st,3296,5.0f);    sv(st,3280,1.00f); sv(st,3312,0.035f);
    sv(st,6736,0.37f);  sv(st,7392,2.5f);    sv(st,10320,0.85f);
    sv(st,4192,0.90f);  sv(st,6512,0.95f);   sv(st,4224,0.22f); sv(st,6528,0.06f);
}

typedef struct { double t; int on; int note; int vel; } Event;

int main(int argc,char**argv){
    if(argc<3){ fprintf(stderr,"usage: render_events <events.txt> <out.wav>\n"); return 2; }
    FILE *ef=fopen(argv[1],"r"); if(!ef){ perror(argv[1]); return 1; }
    int SR=96000; double dur=5.0; char patch[32]="base";
    Event ev[1024]; int nev=0;
    char line[256];
    while(fgets(line,sizeof line,ef)){
        char *h=line; while(*h==' '||*h=='\t')h++;
        if(*h=='#'||*h=='\n'||*h==0) continue;
        if(!strncmp(h,"sr",2))         sscanf(h,"sr %d",&SR);
        else if(!strncmp(h,"dur",3))   sscanf(h,"dur %lf",&dur);
        else if(!strncmp(h,"patch",5)) sscanf(h,"patch %31s",patch);
        else {
            double t; char cmd[8]; int note=0,vel=100;
            int k=sscanf(h,"%lf %7s %d %d",&t,cmd,&note,&vel);
            if(k>=3){ ev[nev].t=t; ev[nev].on=!strcmp(cmd,"on"); ev[nev].note=note; ev[nev].vel=vel; nev++; }
        }
    }
    fclose(ef);

    unsigned char *st=malloc(JUNO_STATE_BYTES); memset(st,0,JUNO_STATE_BYTES);
    JF(st,16)=(float)SR;
    juno_chorus_init(st); juno_engine_init(st); juno_runtime_coeffs_apply(st);
    if(!strcmp(patch,"sqarpg")) overlay_sqarpg(st);
    static struct juno_host_shim shim; memset(&shim,0,sizeof shim);
    juno_driver_attach_host(st,&shim,2);

    int N=(int)(dur*SR), idx=0;
    float *L=malloc(sizeof(float)*N), *R=malloc(sizeof(float)*N);
    int voice_of[128]; for(int i=0;i<128;i++) voice_of[i]=-1;
    int next=0, ei=0;
    for(int i=0;i<N;i++){
        double t=(double)i/SR;
        while(ei<nev && ev[ei].t<=t){
            Event *e=&ev[ei++];
            if(e->on){
                int v=-1;
                for(int k=0;k<JUNO_NUM_VOICES;k++){ int vv=(next+k)%JUNO_NUM_VOICES; int used=0;
                    for(int m=0;m<128;m++) if(voice_of[m]==vv){used=1;break;} if(!used){v=vv;break;} }
                if(v<0){ v=next%JUNO_NUM_VOICES; } /* steal */
                next=(v+1)%JUNO_NUM_VOICES; voice_of[e->note]=v;
                float vel=e->vel/127.0f; sv(st,6864,vel); sv(st,6880,vel); sv(st,6896,vel); sv(st,6912,vel);
                juno_note_on(st,v,e->note);
            } else {
                int v=voice_of[e->note]; if(v>=0){ juno_note_off(st,v); voice_of[e->note]=-1; }
            }
        }
        float l=0,r=0; juno_driver_render_sample(st,&l,&r); L[idx]=l; R[idx]=r; idx++;
    }
    write_wav(argv[2],L,R,idx,SR);
    double sum=0; float pk=0; for(int i=0;i<idx;i++){sum+=(double)L[i]*L[i]+(double)R[i]*R[i]; if(fabsf(L[i])>pk)pk=fabsf(L[i]);}
    printf("rendered %s: %d events, %.2fs @ %d Hz, patch=%s -> %s  peak=%.3f rms=%.4f\n",
           argv[1],nev,(double)idx/SR,SR,patch,argv[2],pk,sqrt(sum/(2.0*idx)));
    return 0;
}

/* play_captured.c — render with the plugin's OWN captured coefficient state.
 *
 * This is the validation render: faithful DSP (voice_render/master_render) running on
 * the real coefficient values dumped from the live plugin (refs/captures, via
 * tools/parse_state.py -> src/captured_state_voice.c). If this sounds like the captured
 * patch, the DSP transcription is confirmed correct and the only gap was the state.
 *
 *   usage: play_captured <out.wav> [hold_seconds]
 */
#include "../src/juno_engine.h"
#include "../src/juno_driver.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

void juno_load_captured_voice(unsigned char *st);   /* from src/captured_state_voice.c */

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

int main(int argc,char**argv){
    const char *out=(argc>1)?argv[1]:"/tmp/juno_captured.wav";
    double hold=(argc>2)?atof(argv[2]):2.0;
    const int SR=96000;

    unsigned char *st=malloc(JUNO_STATE_BYTES); memset(st,0,JUNO_STATE_BYTES);
    juno_chorus_init(st);            /* BBD structure (deep offsets) */
    juno_engine_init(st);            /* static coefficient tables */
    juno_load_captured_voice(st);    /* OVERWRITE voice region with the plugin's real coefficients */

    /* chorus mode selector via the host-params shim (mode 2 = JUNO Chorus I) */
    static struct juno_host_shim shim; memset(&shim,0,sizeof shim);
    juno_driver_attach_host(st,&shim,2);

    int per=(int)(hold*SR), rel=(int)(0.15*SR), tail=(int)(1.0*SR);
    int N=per+tail, idx=0;
    float *L=malloc(sizeof(float)*N), *R=malloc(sizeof(float)*N);

    int notes[3]={60,64,67};                 /* C major triad, C4 root */
    for(int v=0;v<3;v++) juno_note_on(st,v,notes[v]);
    for(int i=0;i<per;i++){ if(i==per-rel) for(int v=0;v<3;v++) juno_note_off(st,v);
        float l=0,r=0; juno_driver_render_sample(st,&l,&r); L[idx]=l;R[idx]=r;idx++; }
    for(int v=0;v<3;v++) juno_note_off(st,v);
    for(int i=0;i<tail;i++){ float l=0,r=0; juno_driver_render_sample(st,&l,&r); L[idx]=l;R[idx]=r;idx++; }

    double sum=0; float pk=0; int nonfin=0;
    for(int i=0;i<idx;i++){ sum+=(double)L[i]*L[i]+(double)R[i]*R[i];
        if(fabsf(L[i])>pk)pk=fabsf(L[i]); if(fabsf(R[i])>pk)pk=fabsf(R[i]);
        if(L[i]!=L[i]||R[i]!=R[i])nonfin++; }
    write_wav(out,L,R,idx,SR);
    printf("captured-state render -> %s  (%.2fs) peak=%.3f rms=%.4f nonfinite=%d\n",
           out,(double)idx/SR,pk,sqrt(sum/(2.0*idx)),nonfin);
    return 0;
}

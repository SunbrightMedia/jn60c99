/* play_chord.c — polyphonic demo: chords across the 8 voices through the chorus.
 * Proves the verified per-voice offset remap: each voice renders the same DSP at
 * its own state region, summed by the master. Plays a small I–V–vi–IV progression.
 *   usage: play_chord <out.wav> [nolfo]
 * Pass "nolfo" to zero the DCO LFO->pitch depth ("LFO Level", offset 4032) on all
 * voices — removes the ~3.8-cent LFO vibrato/drift, leaving filter LFO/PWM/envelopes
 * intact (4032 feeds only the pitch-mod term). */

#include "../src/juno_engine.h"
#include "../src/juno_driver.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

static void write_wav(const char *path, const float *L, const float *R, int n, int sr){
    FILE *f=fopen(path,"wb"); if(!f){perror(path);return;}
    int db=n*2*2, br=sr*2*2; unsigned int u; unsigned short s;
    fwrite("RIFF",1,4,f); u=36+db; fwrite(&u,4,1,f); fwrite("WAVE",1,4,f); fwrite("fmt ",1,4,f);
    u=16;fwrite(&u,4,1,f); s=1;fwrite(&s,2,1,f); s=2;fwrite(&s,2,1,f);
    u=sr;fwrite(&u,4,1,f); u=br;fwrite(&u,4,1,f); s=4;fwrite(&s,2,1,f); s=16;fwrite(&s,2,1,f);
    fwrite("data",1,4,f); u=db;fwrite(&u,4,1,f);
    for(int i=0;i<n;i++){ float l=L[i],r=R[i];
        if(l>1)l=1;if(l<-1)l=-1;if(r>1)r=1;if(r<-1)r=-1;
        short a=(short)lrintf(l*32767.f), b=(short)lrintf(r*32767.f); fwrite(&a,2,1,f); fwrite(&b,2,1,f);}
    fclose(f);
}

int main(int argc, char **argv){
    const char *out=(argc>1)?argv[1]:"/tmp/juno_chord.wav";
    const int SR=96000;
    /* C  G  Am  F  — three notes each (voices 0,1,2) */
    int chords[4][3]={ {60,64,67}, {55,59,62}, {57,60,64}, {53,57,60} };
    double hold=1.6, rel=0.12;
    int per=(int)(hold*SR), gap=(int)(rel*SR), tail=(int)(1.0*SR);
    int N=4*per+tail; float *L=malloc(sizeof(float)*N), *R=malloc(sizeof(float)*N);

    int nolfo = (argc>2 && strcmp(argv[2],"nolfo")==0);

    unsigned char *st=malloc(JUNO_STATE_BYTES); memset(st,0,JUNO_STATE_BYTES);
    juno_chorus_init(st); juno_engine_init(st); juno_runtime_coeffs_apply(st);
    if (nolfo) for (int v=0; v<JUNO_NUM_VOICES; ++v) JF(st, 4032 + v*10512) = 0.0f;
    static struct juno_host_shim shim; memset(&shim,0,sizeof shim);
    juno_driver_attach_host(st,&shim,2);

    int idx=0;
    for(int c=0;c<4;c++){
        for(int v=0;v<3;v++) juno_note_on(st, v, chords[c][v]);
        for(int i=0;i<per;i++){
            if(i==per-gap) for(int v=0;v<3;v++) juno_note_off(st,v);
            float l=0,r=0; juno_driver_render_sample(st,&l,&r); L[idx]=l;R[idx]=r;idx++;
        }
    }
    for(int v=0;v<3;v++) juno_note_off(st,v);
    for(int i=0;i<tail;i++){ float l=0,r=0; juno_driver_render_sample(st,&l,&r); L[idx]=l;R[idx]=r;idx++; }

    double sum=0; float pk=0; for(int i=0;i<idx;i++){sum+=(double)L[i]*L[i]+(double)R[i]*R[i]; if(fabsf(L[i])>pk)pk=fabsf(L[i]);}
    write_wav(out,L,R,idx,SR);
    printf("rendered 4 triads (C G Am F) -> %s  (%.2fs) peak=%.3f rms=%.4f\n",
           out,(double)idx/SR,pk,sqrt(sum/(2.0*idx)));
    return 0;
}

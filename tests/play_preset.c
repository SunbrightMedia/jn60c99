/* play_preset.c — render a chord/arpeggio with the FAITHFUL "SQ Dynamic ARPG" preset.
 *
 * The preset params are no longer hand-tuned: they are SQ ARPG's real per-parameter
 * steps, decoded from the factory bank and bound to engine offsets via the plugin's
 * own Script.xml (docs/SCRIPT_PARAM_MAP.md), then applied through the proven LUT apply
 * engine (juno_param_apply_lut). The LFO->pitch depth (offset 4032) is the preset's
 * real value, NOT zeroed — so the vibrato is SQ ARPG's own.
 *
 *   usage: play_preset <out.wav> [block]
 *     default            -> staggered up-arpeggio per chord (sequenced "ARPG" feel)
 *     block              -> held block chords
 */
#include "../src/juno_engine.h"
#include "../src/juno_driver.h"
#include "../src/juno_params.h"
#include "sqarpg_apply.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

static void write_wav(const char *path,const float *L,const float *R,int n,int sr){
    FILE *f=fopen(path,"wb"); if(!f){perror(path);return;}
    int db=n*2*2, br=sr*2*2; unsigned int u; unsigned short s;
    fwrite("RIFF",1,4,f); u=36+db; fwrite(&u,4,1,f); fwrite("WAVE",1,4,f); fwrite("fmt ",1,4,f);
    u=16;fwrite(&u,4,1,f); s=1;fwrite(&s,2,1,f); s=2;fwrite(&s,2,1,f);
    u=sr;fwrite(&u,4,1,f); u=br;fwrite(&u,4,1,f); s=4;fwrite(&s,2,1,f); s=16;fwrite(&s,2,1,f);
    fwrite("data",1,4,f); u=db;fwrite(&u,4,1,f);
    for(int i=0;i<n;i++){ float l=L[i],r=R[i];
        if(l>1)l=1; if(l<-1)l=-1; if(r>1)r=1; if(r<-1)r=-1;
        short a=(short)lrintf(l*32767.f), b=(short)lrintf(r*32767.f); fwrite(&a,2,1,f); fwrite(&b,2,1,f);}
    fclose(f);
}

/* write value f to a per-voice offset across all 8 voices (main-block stride) */
static void set_voices(unsigned char *st,int off,float f){
    for(int v=0;v<JUNO_NUM_VOICES;++v) JF(st, off + v*JUNO_VOICE_MAIN_STRIDE)=f;
}

/* --- "SQ Dynamic ARPG" — FAITHFUL apply -----------------------------------
 * SQ ARPG's real per-parameter steps (from the factory bank), bound to engine
 * offsets via Script.xml, applied through the proven LUT engine. Table generated
 * by tools/build_sqarpg_apply.py -> tests/sqarpg_apply.h. Broadcast to all 8 voices.
 * Velocity into the filter path kept (it is not a patch-stored param). */
static void preset_sq_arpg(unsigned char *st){
    for(int i=0;i<SQARPG_APPLY_N;i++)
        juno_param_apply_lut(st, SQARPG_APPLY[i].off, SQARPG_APPLY[i].tid,
                             SQARPG_APPLY[i].step, /*broadcast=*/1);
    { float vel=100.0f/127.0f;
      set_voices(st,6864,vel); set_voices(st,6880,vel); set_voices(st,6896,vel); set_voices(st,6912,vel); }
}

int main(int argc,char**argv){
    const char *out=(argc>1)?argv[1]:"/tmp/juno_preset.wav";
    int block=(argc>2 && strcmp(argv[2],"block")==0);
    const int SR=96000;

    /* I–V–vi–IV, three notes each (C5-rooted register, matching the reference octave) */
    int chords[4][3]={ {72,76,79}, {67,71,74}, {69,72,76}, {65,69,72} };

    unsigned char *st=malloc(JUNO_STATE_BYTES); memset(st,0,JUNO_STATE_BYTES);
    juno_chorus_init(st); juno_engine_init(st); juno_runtime_coeffs_apply(st);
    preset_sq_arpg(st);
    /* LFO->pitch (offset 4032) is now SQ ARPG's real depth (DB753, step 128) — not zeroed. */
    static struct juno_host_shim shim; memset(&shim,0,sizeof shim);
    juno_driver_attach_host(st,&shim,2);

    int N, idx=0; float *L,*R;
    if(block){
        double hold=1.4, rel=0.10; int per=(int)(hold*SR), gap=(int)(rel*SR), tail=(int)(1.2*SR);
        N=4*per+tail; L=malloc(sizeof(float)*N); R=malloc(sizeof(float)*N);
        for(int c=0;c<4;c++){
            for(int v=0;v<3;v++) juno_note_on(st,v,chords[c][v]);
            for(int i=0;i<per;i++){ if(i==per-gap) for(int v=0;v<3;v++) juno_note_off(st,v);
                float l=0,r=0; juno_driver_render_sample(st,&l,&r); L[idx]=l;R[idx]=r;idx++; }
        }
        for(int v=0;v<3;v++) juno_note_off(st,v);
        for(int i=0;i<tail;i++){ float l=0,r=0; juno_driver_render_sample(st,&l,&r); L[idx]=l;R[idx]=r;idx++; }
    } else {
        /* sequenced up-arpeggio: each chord = its 3 notes plucked in turn, repeating,
         * 16th-ish at ~120 BPM (step 0.125 s), 4 steps per chord ~ one bar each */
        double step=0.125; int sp=(int)(step*SR), gate=(int)(0.11*SR), tail=(int)(1.0*SR);
        int steps_per=4; N=4*steps_per*sp+tail; L=malloc(sizeof(float)*N); R=malloc(sizeof(float)*N);
        for(int c=0;c<4;c++){
            for(int s=0;s<steps_per;s++){
                int note=chords[c][s%3];
                juno_note_on(st,0,note);          /* one voice, retriggered = arp */
                for(int i=0;i<sp;i++){ if(i==gate) juno_note_off(st,0);
                    float l=0,r=0; juno_driver_render_sample(st,&l,&r); L[idx]=l;R[idx]=r;idx++; }
            }
        }
        juno_note_off(st,0);
        for(int i=0;i<tail;i++){ float l=0,r=0; juno_driver_render_sample(st,&l,&r); L[idx]=l;R[idx]=r;idx++; }
    }

    double sum=0; float pk=0; for(int i=0;i<idx;i++){sum+=(double)L[i]*L[i]+(double)R[i]*R[i]; if(fabsf(L[i])>pk)pk=fabsf(L[i]); if(fabsf(R[i])>pk)pk=fabsf(R[i]);}
    /* Output gain-staging (master/VCA level param) is not yet bound; normalize to
     * -1 dBFS so the tonal + LFO character is audible without clip distortion. */
    if(pk>0.001f){ float g=0.891f/pk; for(int i=0;i<idx;i++){L[i]*=g; R[i]*=g;} }
    write_wav(out,L,R,idx,SR);
    printf("SQ Dynamic ARPG (%s) -> %s  (%.2fs) peak=%.3f rms=%.4f\n",
           block?"block chords":"arpeggio", out,(double)idx/SR,pk,sqrt(sum/(2.0*idx)));
    return 0;
}

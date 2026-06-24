/* play_preset.c — render a chord/arpeggio with a preset overlay applied on top of
 * the validated base patch. First target: "SQ Dynamic ARPG" (from the panel photo).
 *
 * The exact panel-value -> coefficient curves are not transcribed, so this is a
 * "similar, not exact" overlay: start from the validated base state, then push the
 * audible macro params (envelopes, VCF, DCO mix, chorus) toward the photo. Values
 * are broadcast to all 8 voices exactly as juno_runtime_coeffs_apply does.
 *
 *   usage: play_preset <out.wav> [block]
 *     default            -> staggered up-arpeggio per chord (sequenced "ARPG" feel)
 *     block              -> held block chords
 */
#include "../src/juno_engine.h"
#include "../src/juno_driver.h"
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

/* --- "SQ Dynamic ARPG" overlay --------------------------------------------
 * Offsets from docs/PARAM_MAP.tsv. Base (PD Juno Pad) values noted in comments.
 * Goal: pluckier/percussive amp + moving filter, saw+pulse DCO, chorus II. */
static void preset_sq_arpg(unsigned char *st){
    /* ENV-1 (filter envelope): pluck the cutoff — fast attack, quick decay, low sustain */
    set_voices(st,2784, 0.090f);   /* E1 Attack rate  (base 0.00297 -> faster)  */
    set_voices(st,2816, 0.018f);   /* E1 Decay rate   (base 0.00472 -> quicker) */
    set_voices(st,2800, 0.28f);    /* E1 Sustain lvl  (base 0.695  -> lower)    */
    set_voices(st,2832, 0.030f);   /* E1 Release rate (base 0.00334)            */

    /* ENV-2 (amp envelope): percussive — fast attack, medium decay, low-mid sustain */
    set_voices(st,3264, 0.090f);   /* E2 Attack  (base 0.00121)                 */
    set_voices(st,3296, 0.020f);   /* E2 Decay   (base 5.33 -> short)           */
    set_voices(st,3280, 0.45f);    /* E2 Sustain (base 1.0 -> pluck)            */
    set_voices(st,3312, 0.035f);   /* E2 Release (base 0.00354)                 */

    /* VCF: moderate cutoff, a little resonance, strong env-1 sweep for movement */
    set_voices(st,6736, 0.38f);    /* LPF Cutoff (base 0.416)                   */
    set_voices(st,7392, 3.6f);     /* ENV->filter depth (base 3.158 -> a touch more) */

    /* DCO: keep saw + pulse forward, trim sub/noise for a cleaner sequenced tone */
    set_voices(st,4192, 0.90f);    /* Saw level  (base 0.860)                   */
    set_voices(st,6512, 0.95f);    /* Pulse level (base 1.007)                  */
    set_voices(st,4224, 0.22f);    /* Sub level  (base 0.316 -> less)           */
    set_voices(st,6528, 0.06f);    /* Noise level (base 0.176 -> less)          */
    /* Chorus II is already the base mode; left as-is. */
}

int main(int argc,char**argv){
    const char *out=(argc>1)?argv[1]:"/tmp/juno_preset.wav";
    int block=(argc>2 && strcmp(argv[2],"block")==0);
    const int SR=96000;

    /* I–V–vi–IV, three notes each */
    int chords[4][3]={ {60,64,67}, {55,59,62}, {57,60,64}, {53,57,60} };

    unsigned char *st=malloc(JUNO_STATE_BYTES); memset(st,0,JUNO_STATE_BYTES);
    juno_chorus_init(st); juno_engine_init(st); juno_runtime_coeffs_apply(st);
    preset_sq_arpg(st);
    /* kill the DCO LFO->pitch vibrato (offset 4032) for a tighter sequenced feel */
    for(int v=0;v<JUNO_NUM_VOICES;++v) JF(st,4032+v*10512)=0.0f;
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

    double sum=0; float pk=0; for(int i=0;i<idx;i++){sum+=(double)L[i]*L[i]+(double)R[i]*R[i]; if(fabsf(L[i])>pk)pk=fabsf(L[i]);}
    write_wav(out,L,R,idx,SR);
    printf("SQ Dynamic ARPG (%s) -> %s  (%.2fs) peak=%.3f rms=%.4f\n",
           block?"block chords":"arpeggio", out,(double)idx/SR,pk,sqrt(sum/(2.0*idx)));
    return 0;
}

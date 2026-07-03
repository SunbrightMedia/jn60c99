/* juno_render.c — CLI host for the bit-exact JUNO-60 port.
 * Loads a factory bank preset (capture-free), derives its chorus/reverb from the
 * patch, renders a note (or a simple sequence) to a stereo WAV.
 *
 *   juno_render <bank.bin> <record#> <out.wav> [midi_note ...]
 */
#include "../src/juno_engine.h"
#include "../src/juno_driver.h"
#include "../src/juno_params.h"
#include "../src/juno_reverb.h"
#include "../src/juno_preset.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
void juno_runtime_coeffs_apply(unsigned char*);
/* Capture-free product seed (see src/juno_capture_free_seed.c); -DJUNO_USE_CAPTURE
 * restores the old "PD The Juno Pad" memory-capture seed (test oracle only). */
#ifdef JUNO_USE_CAPTURE
#  define JUNO_SEED(st) juno_runtime_coeffs_apply(st)
#else
#  define JUNO_SEED(st) juno_capture_free_seed(st)
#endif
static void wav(const char*p,float*L,float*R,int n,int sr){FILE*f=fopen(p,"wb");if(!f){perror(p);return;}int db=n*4,br=sr*4;unsigned u;unsigned short s;
 fwrite("RIFF",1,4,f);u=36+db;fwrite(&u,4,1,f);fwrite("WAVE",1,4,f);fwrite("fmt ",1,4,f);u=16;fwrite(&u,4,1,f);s=1;fwrite(&s,2,1,f);s=2;fwrite(&s,2,1,f);
 u=sr;fwrite(&u,4,1,f);u=br;fwrite(&u,4,1,f);s=4;fwrite(&s,2,1,f);s=16;fwrite(&s,2,1,f);fwrite("data",1,4,f);u=db;fwrite(&u,4,1,f);
 for(int i=0;i<n;i++){float l=L[i],r=R[i];if(l>1)l=1;if(l<-1)l=-1;if(r>1)r=1;if(r<-1)r=-1;short a=(short)lrintf(l*32767),b=(short)lrintf(r*32767);fwrite(&a,2,1,f);fwrite(&b,2,1,f);}fclose(f);}
int main(int argc,char**argv){
 if(argc<4){fprintf(stderr,"usage: %s <bank.bin> <record#> <out.wav> [note ...]\n",argv[0]);return 2;}
 const char*bank=argv[1]; int rec=atoi(argv[2]); const char*out=argv[3];
 int notes[16],nn=0; for(int i=4;i<argc&&nn<16;i++)notes[nn++]=atoi(argv[i]);
 if(nn==0){notes[0]=60;notes[1]=64;notes[2]=67;nn=3;}
 const int SR=48000;
 unsigned char*st=malloc(JUNO_STATE_BYTES);memset(st,0,JUNO_STATE_BYTES);
 JF(st,16)=(float)SR;   /* engine SR: selects init coeff set + SR-family LUTs */
 juno_chorus_init(st);juno_engine_init(st);JUNO_SEED(st);
 juno_preset_info pi;
 if(juno_preset_load(st,bank,rec,&pi)!=0){fprintf(stderr,"preset load failed\n");return 1;}
 /* velocity into the filter path (not a patch param) */
 {float vel=100.f/127.f;for(int o=6864;o<=6912;o+=16)for(int vv=0;vv<JUNO_NUM_VOICES;vv++)JF(st,o+vv*JUNO_VOICE_MAIN_STRIDE)=vel;}
 /* FX from the preset: chorus mode + reverb type (HALL2=3 activatable) */
 int chorus = (pi.chorus_mode>=1)?pi.chorus_mode:0;
 static struct juno_host_shim sh;memset(&sh,0,sizeof sh);juno_driver_attach_host(st,&sh,chorus?chorus:2);
 if(pi.reverb_type>=0 && pi.reverb_type<=5) juno_reverb_activate(st,pi.reverb_type,1.0f);
 /* warm-up pre-roll: settle the chorus delay smoother (tau=32787 samples) +
  * reverb retune/fade, matching a live plugin that has been processing silence
  * since activation (authentic-behavior parity; see host/juno_synth.c). */
 for(int i=0;i<8*32787;i++){float l,r;juno_driver_render_sample(st,&l,&r);}
 printf("preset: \"%s\"  model=%d filter=%d chorus=%d fxA=%d reverb=%d  (%d params)\n",
   pi.name,pi.model,pi.filter_type,pi.chorus_mode,pi.fxa_type,pi.reverb_type,pi.applied);
 /* play the notes as a slow up-arpeggio, 1 voice retriggered */
 double step=0.4; int sp=(int)(step*SR),gate=(int)(0.34*SR),tail=(int)(2.0*SR);
 int N=nn*sp+tail,idx=0; float*L=malloc(4*N),*R=malloc(4*N);
 for(int s=0;s<nn;s++){ juno_note_on(st,0,notes[s]);
   for(int i=0;i<sp;i++){if(i==gate)juno_note_off(st,0);float l=0,r=0;juno_driver_render_sample(st,&l,&r);L[idx]=l;R[idx]=r;idx++;}}
 juno_note_off(st,0);
 for(int i=0;i<tail;i++){float l=0,r=0;juno_driver_render_sample(st,&l,&r);L[idx]=l;R[idx]=r;idx++;}
 double pk=0;for(int i=0;i<idx;i++)if(fabs(L[i])>pk)pk=fabs(L[i]);
 if(pk>0.001){float g=0.89f/pk;for(int i=0;i<idx;i++){L[i]*=g;R[i]*=g;}}
 wav(out,L,R,idx,SR);
 printf("rendered %d notes -> %s (%.1fs) peak=%.3f\n",nn,out,(double)idx/SR,pk);
 return 0;}

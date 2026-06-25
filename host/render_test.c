/* render_test.c — render the EXACT SQ Dynamic ARPG factory preset (bank record 1)
 * arpeggiating a held C-major chord (C4 E4 G4) at 120 BPM for 3 seconds.
 * Fully capture-free: preset loader + chorus CV + HALL2 reverb + faithful arp. */
#include "../src/juno_engine.h"
#include "../src/juno_driver.h"
#include "../src/juno_params.h"
#include "../src/juno_reverb.h"
#include "../src/juno_preset.h"
#include "../src/arp.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <stdint.h>
void juno_runtime_coeffs_apply(unsigned char*);
static void wav(const char*p,float*L,float*R,int n,int sr){FILE*f=fopen(p,"wb");int db=n*4,br=sr*4;unsigned u;unsigned short s;
 fwrite("RIFF",1,4,f);u=36+db;fwrite(&u,4,1,f);fwrite("WAVE",1,4,f);fwrite("fmt ",1,4,f);u=16;fwrite(&u,4,1,f);s=1;fwrite(&s,2,1,f);s=2;fwrite(&s,2,1,f);
 u=sr;fwrite(&u,4,1,f);u=br;fwrite(&u,4,1,f);s=4;fwrite(&s,2,1,f);s=16;fwrite(&s,2,1,f);fwrite("data",1,4,f);u=db;fwrite(&u,4,1,f);
 for(int i=0;i<n;i++){float l=L[i],r=R[i];if(l>1)l=1;if(l<-1)l=-1;if(r>1)r=1;if(r<-1)r=-1;short a=(short)lrintf(l*32767),b=(short)lrintf(r*32767);fwrite(&a,2,1,f);fwrite(&b,2,1,f);}fclose(f);}
static int g_note=-1;
static void on_on(void*u,int n,int v,int k){(void)u;(void)v;(void)k;g_note=n;}
static void on_off(void*u,int n,int v){(void)u;(void)n;(void)v;}
int main(int argc,char**argv){
 const char*out=argc>1?argv[1]:"/tmp/sqarpg_Cmaj.wav";
 const int SR=96000;
 unsigned char*st=malloc(JUNO_STATE_BYTES);memset(st,0,JUNO_STATE_BYTES);
 juno_chorus_init(st);juno_engine_init(st);juno_runtime_coeffs_apply(st);
 juno_preset_info pi;
 if(juno_preset_load(st,"refs/preset_banks/bank1.bin",1,&pi)){fprintf(stderr,"load fail\n");return 1;}
 printf("preset[1] = \"%s\"  chorus=%d(CH%d) fxA=%d reverb=%d\n",pi.name,pi.chorus_mode,pi.chorus_mode-1,pi.fxa_type,pi.reverb_type);
 {float vel=100.f/127.f;for(int o=6864;o<=6912;o+=16)for(int vv=0;vv<JUNO_NUM_VOICES;vv++)JF(st,o+vv*JUNO_VOICE_MAIN_STRIDE)=vel;}
 static struct juno_host_shim sh;memset(&sh,0,sizeof sh);juno_driver_attach_host(st,&sh,pi.chorus_mode>=1?pi.chorus_mode:2);
 if(pi.reverb_type>=0&&pi.reverb_type<=5) juno_reverb_activate(st,pi.reverb_type,1.0f);
 /* faithful arp on a held C major triad, UP, 1 octave */
 juno_arp arp; juno_arp_callbacks cb={on_on,on_off,NULL};
 juno_arp_init(&arp,&cb); unsigned char*a=arp.st;
 *(int8_t*)(a+3054)=1; *(int8_t*)(a+3055)=1; *(uint16_t*)(a+610)=1;
 *(uint8_t*)(a+996)=0x01; *(uint16_t*)(a+996+2)=1;
 juno_arp_note_on(&arp,60,100); juno_arp_note_on(&arp,64,100); juno_arp_note_on(&arp,67,100); /* C E G */
 juno_arp_set_mode(&arp,15); juno_arp_set_range(&arp,0); juno_arp_set_running(&arp,1);
 /* 120 BPM, 1/16 steps = 0.125 s */
 int step=(int)(0.125*SR), gate=(int)(step*0.7);
 int N=(int)(3.0*SR), idx=0, cur=-1, gate_off=-1, next=0, steps=0;
 float*L=malloc(4*N),*R=malloc(4*N);
 for(int i=0;i<N;i++){
   if(i>=next){ juno_arp_scan(&arp);
     if(g_note>=0){ if(cur>=0)juno_note_off(st,0); juno_note_on(st,0,g_note); cur=g_note; gate_off=i+gate; steps++; }
     next+=step; }
   if(gate_off>=0&&i==gate_off&&cur>=0){ juno_note_off(st,0); cur=-1; gate_off=-1; }
   float l=0,r=0; juno_driver_render_sample(st,&l,&r); L[idx]=l;R[idx]=r;idx++;
 }
 double pk=0,sm=0;for(int i=0;i<idx;i++){if(fabs(L[i])>pk)pk=fabs(L[i]);sm+=(double)L[i]*L[i];}
 if(pk>0.001){float g=0.89f/pk;for(int i=0;i<idx;i++){L[i]*=g;R[i]*=g;}}
 wav(out,L,R,idx,SR);
 printf("rendered C-major arp (120 BPM, 1/16) 3.0s, %d steps -> %s  peak=%.3f rms=%.4f\n",steps,out,pk,sqrt(sm/idx));
 return 0;}

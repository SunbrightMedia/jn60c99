#include "../src/juno_engine.h"
#include "../src/juno_driver.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
void juno_runtime_coeffs_apply(unsigned char*);
void juno_overlay_patch(unsigned char*);
/* Dump the chorus LFO phase (6395600) and modulator output (6395680) per sample,
 * measure the LFO period directly. */
int main(int c,char**v){int SR=96000;int chorus=c>1?atoi(v[1]):2;
 unsigned char*st=malloc(JUNO_STATE_BYTES);memset(st,0,JUNO_STATE_BYTES);
 juno_chorus_init(st);juno_engine_init(st);juno_runtime_coeffs_apply(st);juno_overlay_patch(st);
 static struct juno_host_shim sh;memset(&sh,0,sizeof sh);juno_driver_attach_host(st,&sh,chorus);
 juno_note_on(st,0,60);
 int N=SR*6;
 printf("chorus CV(6395312)=%.5f depth(6395328)=%.5f ratescale(6395648)=%.6g\n",
   *(float*)(st+6395312),*(float*)(st+6395328),*(float*)(st+6395648));
 /* track zero-crossings of LFO modulator (6395680 around its mean ~0.5) */
 double prev=0; int crossings=0; double first=-1,last=-1;
 for(int i=0;i<N;i++){float l=0,r=0;juno_driver_render_sample(st,&l,&r);
   double mod=*(float*)(st+6395680);   /* v260: 1-sided 0..1 mod */
   double centered=mod-0.5;
   if(i>0 && ((prev<0&&centered>=0))){ if(first<0)first=i; last=i; crossings++; }
   prev=centered;
 }
 if(crossings>1){double period=(last-first)/(crossings-1); printf("LFO period=%.1f samples = %.4f Hz (over %d cycles)\n",period,SR/period,crossings-1);}
 else printf("crossings=%d (LFO slower than 6s window)\n",crossings);
 return 0;}

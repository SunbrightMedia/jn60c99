/* measure_fxa_bypass.c — demonstrates the FX-A routing fix for the chorus
 * "exaggerated depth" issue. The master (sub_180363380) runs TWO effects in
 * series: the System-8 FX-A slot (v551, params+112) THEN the JUNO Delay/Chorus
 * slot (v39, params+136). The offline driver used to force BOTH to the chorus
 * mode, so FX-A ran as a second chorus and compounded the pitch wobble
 * (35.6c p2p). With FX-A bypassed (the new driver default) only the authentic
 * JUNO chorus colours the signal (24.2c p2p). See docs/CHORUS_VIBRATO_DIAG.md.
 *
 * Build: cc -std=c99 -O2 -fno-strict-aliasing tests/measure_fxa_bypass.c src/*.c -lm -o /tmp/m
 */
#include "../src/juno_engine.h"
#include "../src/juno_driver.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif
void juno_runtime_coeffs_apply(unsigned char*);
void juno_overlay_patch(unsigned char*);
static double dep(int bypass){int SR=96000;
 unsigned char*st=malloc(JUNO_STATE_BYTES);memset(st,0,JUNO_STATE_BYTES);
 juno_chorus_init(st);juno_engine_init(st);juno_runtime_coeffs_apply(st);juno_overlay_patch(st);
 static struct juno_host_shim sh;memset(&sh,0,sizeof sh);juno_driver_attach_host(st,&sh,2);
 juno_driver_set_fxa_bypass(bypass);
 juno_note_on(st,0,60);
 double f0=440.0*pow(2.0,(60-69)/12.0);int N=SR*8;double w=2*M_PI*f0/SR;
 double Ig[4]={0},Qg[4]={0};double a=exp(-2*M_PI*30.0/SR);double ph=0;
 double*c=malloc(8.0*N);int nc=0;double pa=0;int s0=0;
 for(int i=0;i<N;i++){float l=0,r=0;juno_driver_render_sample(st,&l,&r);
  double s=l;double I=s*cos(ph),Q=-s*sin(ph);ph+=w;if(ph>2*M_PI)ph-=2*M_PI;
  double xi=I,xq=Q;for(int k=0;k<4;k++){Ig[k]=a*Ig[k]+(1-a)*xi;xi=Ig[k];Qg[k]=a*Qg[k]+(1-a)*xq;xq=Qg[k];}
  if(i>SR){double an=atan2(xq,xi);if(s0){double d=an-pa;while(d>M_PI)d-=2*M_PI;while(d<-M_PI)d+=2*M_PI;c[nc++]=1200.0*log2((f0+d*SR/(2*M_PI))/f0);}pa=an;s0=1;}}
 double mn=1e9,mx=-1e9;for(int i=0;i<nc;i++){if(c[i]<mn)mn=c[i];if(c[i]>mx)mx=c[i];}
 free(c);free(st);double p=mx-mn;return p>5000?-1:p;}
int main(void){
 printf("default driver, FX-A bypass ON (new default): %.1f c\n",dep(1));
 printf("FX-A bypass OFF (old behaviour, FX-A off=silent): %.1f c\n",dep(0));
 return 0;}

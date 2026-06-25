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
int main(int c,char**v){int SR=96000;int note=c>1?atoi(v[1]):60;int chorus=c>2?atoi(v[2]):2;
 unsigned char*st=malloc(JUNO_STATE_BYTES);memset(st,0,JUNO_STATE_BYTES);
 juno_chorus_init(st);juno_engine_init(st);juno_runtime_coeffs_apply(st);juno_overlay_patch(st);
 static struct juno_host_shim sh;memset(&sh,0,sizeof sh);juno_driver_attach_host(st,&sh,chorus);
 juno_note_on(st,0,note);
 double f0=440.0*pow(2.0,(note-69)/12.0);
 int N=SR*8; double w=2*M_PI*f0/SR;
 double Ig[4]={0},Qg[4]={0}; double a=exp(-2*M_PI*30.0/SR);
 double ph=0; int cap=N; double *cents=malloc(sizeof(double)*cap); int nc=0;
 double prevAng=0; int started=0;
 for(int i=0;i<N;i++){float l=0,r=0;juno_driver_render_sample(st,&l,&r);
   double s=l; double I=s*cos(ph),Q=-s*sin(ph); ph+=w; if(ph>2*M_PI)ph-=2*M_PI;
   double xi=I,xq=Q; for(int k=0;k<4;k++){Ig[k]=a*Ig[k]+(1-a)*xi; xi=Ig[k]; Qg[k]=a*Qg[k]+(1-a)*xq; xq=Qg[k];}
   if(i>SR){ double ang=atan2(xq,xi);
     if(started){ double d=ang-prevAng; while(d>M_PI)d-=2*M_PI; while(d<-M_PI)d+=2*M_PI;
        cents[nc++]=1200.0*log2((f0+d*SR/(2*M_PI))/f0); }
     prevAng=ang; started=1; }
 }
 /* downsample cents to 1kHz, remove mean, DFT 0.1..12Hz */
 int ds=SR/1000; int M=nc/ds; double *x=malloc(sizeof(double)*M); double mean=0;
 for(int i=0;i<M;i++){x[i]=cents[i*ds];mean+=x[i];} mean/=M; for(int i=0;i<M;i++)x[i]-=mean;
 double fsd=1000.0; double bestf=0,bestp=0;
 for(double f=0.1;f<=12.0;f+=0.02){ double re=0,im=0; for(int i=0;i<M;i++){double t=i/fsd; re+=x[i]*cos(2*M_PI*f*t); im+=x[i]*sin(2*M_PI*f*t);} double p=re*re+im*im; if(p>bestp){bestp=p;bestf=f;} }
 double mn=1e9,mx=-1e9; for(int i=0;i<nc;i++){if(cents[i]<mn)mn=cents[i];if(cents[i]>mx)mx=cents[i];}
 printf("mode %d: pitch p2p=%.1fc  dominant modulation = %.2f Hz\n",chorus,mx-mn,bestf);
 return 0;}

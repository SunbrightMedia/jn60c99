#include <stdio.h>
#include <stdint.h>
#include <string.h>
int main(int argc,char**argv){
  FILE*fp=fopen("noise_core_200k.bin","rb"); (void)fp;
  /* replicate the transcription */
  float w; uint32_t b0; 
  FILE*f=fopen("core.raw","rb"); if(!f){printf("no core.raw\n");return 1;}
  uint32_t *ref=malloc(200000*4); fread(ref,4,200000,f); fclose(f);
  /* initial state: read from ref[0]? we need state BEFORE first step. Reconstruct backwards is hard;
     instead start from ref[0] and predict ref[1..] */
  memcpy(&w,&ref[0],4);
  int bad=0;
  for(int i=1;i<200000;i++){
    int32_t n=(int32_t)(w*-16777216.0f);
    int32_t m;
    if(n==0) m=1; else { int b23=(n>>23)&1, b21=(n>>21)&1; m=2*n+((b23==b21)?1:0); }
    m = (m & 0x1000000) ? (m | (int32_t)0xFF000000) : (m & 0xFFFFFF);
    w=(float)m*5.9604645e-8f;
    uint32_t bb; memcpy(&bb,&w,4);
    if(bb!=ref[i]){ if(bad<3) printf("mismatch at %d\n",i); bad++; }
  }
  printf("mismatches=%d / 199999\n",bad);
  return 0;}

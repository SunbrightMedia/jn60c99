#include <stdio.h>
#include <math.h>
#include <stdint.h>
int main(){
  uint64_t d1=0,d2=0,n=0;
  for(uint32_t b=0x3F800001u; b<=0x40400000u; ++b){   /* (1,3] */
    float p; __builtin_memcpy(&p,&b,4); ++n;
    float ref=fmodf(p+1.0f,2.0f)-1.0f;
    float cand=((p+1.0f)-2.0f)-1.0f;
    if(ref!=cand) ++d1;}
  for(uint32_t b=0xBF800001u; b<=0xC0400000u; ++b){   /* [-3,-1) */
    float p; __builtin_memcpy(&p,&b,4);
    float ref=fmodf(p-1.0f,2.0f)+1.0f;
    float cand=((p-1.0f)+2.0f)+1.0f;
    if(ref!=cand) ++d2;}
  printf("n=%llu  pos-mismatch=%llu  neg-mismatch=%llu\n",(unsigned long long)n,(unsigned long long)d1,(unsigned long long)d2);
  /* wider: |p| up to 11 (inc up to 10) */
  uint64_t d3=0,tot=0;
  for(uint32_t b=0x3F800001u; b<=0x41300000u; ++b){   /* (1,11] */
    float p; __builtin_memcpy(&p,&b,4); ++tot;
    float ref=fmodf(p+1.0f,2.0f)-1.0f;
    float cand=((p+1.0f)-2.0f)-1.0f;
    if(ref!=cand) ++d3;}
  printf("(1,11]: tot=%llu mismatch=%llu\n",(unsigned long long)tot,(unsigned long long)d3);
  return 0;}

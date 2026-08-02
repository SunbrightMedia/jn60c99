#include <stdio.h>
#include <math.h>
#include <stdint.h>
int main(){
  double lo=9,hi=-9; uint64_t d=0;
  for(uint32_t b=0x3F800001u; b<=0x40400000u; ++b){
    float p; __builtin_memcpy(&p,&b,4);
    float a=fmodf(p+1.0f,2.0f)-1.0f, c=p-2.0f;
    if(a!=c){ if(p<lo)lo=p; if(p>hi)hi=p; ++d;} }
  printf("diff range p in [%.9g,%.9g] count %llu\n",lo,hi,(unsigned long long)d);
  float p=1.5f; printf("p=1.5 fmod=%.9g sub=%.9g\n",fmodf(p+1,2)-1,p-2);
  p=2.5f; printf("p=2.5 fmod=%.9g sub=%.9g\n",fmodf(p+1,2)-1,p-2);
  p=1.0000001f; printf("p=1.0000001 fmod=%.9g sub=%.9g\n",fmodf(p+1,2)-1,p-2);
  return 0;}

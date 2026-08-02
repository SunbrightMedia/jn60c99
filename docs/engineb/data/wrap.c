#include <stdio.h>
#include <math.h>
#include <stdint.h>
int main(){
  uint64_t n=0,diff=0; float worst=0;
  /* exhaustive over all float32 in (1,3] */
  for(uint32_t b=0x3F800001u; b<=0x40400000u; ++b){
    float p; __builtin_memcpy(&p,&b,4);
    float a=fmodf(p+1.0f,2.0f)-1.0f, c=p-2.0f;
    ++n; if(a!=c){++diff; if(fabsf(a-c)>worst) worst=fabsf(a-c);} }
  printf("(1,3]: n=%llu diff=%llu worst=%g\n",(unsigned long long)n,(unsigned long long)diff,worst);
  n=diff=0; worst=0;
  for(uint32_t b=0xBF800001u; b<=0xC0400000u; ++b){
    float p; __builtin_memcpy(&p,&b,4);
    float a=fmodf(p-1.0f,2.0f)+1.0f, c=p+2.0f;
    ++n; if(a!=c){++diff; if(fabsf(a-c)>worst) worst=fabsf(a-c);} }
  printf("[-3,-1): n=%llu diff=%llu worst=%g\n",(unsigned long long)n,(unsigned long long)diff,worst);
  return 0;}

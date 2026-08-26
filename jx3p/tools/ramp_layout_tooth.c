#include <stddef.h>
#include <stdio.h>
#include "jx_ramp.h"
int main(void){
  struct { const char*n; size_t got, want; } t[] = {
    {"target",offsetof(jx_ramp,target),0x00},{"step",offsetof(jx_ramp,step),0x08},
    {"acc",offsetof(jx_ramp,acc),0x0C},{"offset",offsetof(jx_ramp,offset),0x10},
    {"limit",offsetof(jx_ramp,limit),0x14},{"enabled",offsetof(jx_ramp,enabled),0x1C},
    {"period",offsetof(jx_ramp,period),0x20},{"counter",offsetof(jx_ramp,counter),0x24}};
  int bad=0;
  for(unsigned i=0;i<sizeof t/sizeof*t;i++){
    if(t[i].got!=t[i].want){printf("  MISMATCH %-8s got %zu want %zu\n",t[i].n,t[i].got,t[i].want);bad=1;}
  }
  printf(bad?"LAYOUT TOOTH: FAIL\n":"LAYOUT TOOTH: PASS -- every field at its machine-code offset\n");
  return bad;
}

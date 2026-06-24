/* test_apply.c — proves the param-apply LUT engine reproduces the captured PD Juno Pad
 * coefficients bit-exact: coeff = juno_lut_apply(tableId, step). */
#include "../src/juno_param_luts.h"
#include "apply_vectors.h"
#include <stdio.h>
#include <string.h>
int main(void){
    int n=sizeof(APPLY_VECS)/sizeof(APPLY_VECS[0]), ok=0, bad=0;
    for(int i=0;i<n;i++){
        float got=juno_lut_apply(APPLY_VECS[i].tableId, APPLY_VECS[i].step);
        unsigned int gb; memcpy(&gb,&got,4);
        if(gb==APPLY_VECS[i].bits) ok++;
        else { bad++; if(bad<=6){ float ex; memcpy(&ex,&APPLY_VECS[i].bits,4);
            printf("  MISMATCH off=%d tbl=%d step=%d got=%.9g(0x%08x) exp=%.9g(0x%08x)\n",
                   APPLY_VECS[i].off,APPLY_VECS[i].tableId,APPLY_VECS[i].step,got,gb,ex,APPLY_VECS[i].bits);} }
    }
    printf("apply LUT bit-exact: %d/%d  (%d mismatch)\n", ok, n, bad);
    return bad? 1:0;
}

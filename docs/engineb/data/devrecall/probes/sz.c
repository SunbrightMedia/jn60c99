#include <stdio.h>
#include "eb_render.h"
#include "eb_master.h"
#include "eb_coefs.h"
#include "eb_vcf_res.h"
int main(void){
  printf("EB_NUM_VOICES        %d\n", EB_NUM_VOICES);
  printf("EB_VCF_RES_LUT       %d\n", EB_VCF_RES_LUT);
  printf("sizeof eb_render_coefs %zu\n", sizeof(eb_render_coefs));
  printf("sizeof eb_master_coef  %zu\n", sizeof(eb_master_coef));
  printf("sizeof eb_render_state %zu\n", sizeof(eb_render_state));
  printf("sizeof eb_master_state %zu\n", sizeof(eb_master_state));
  printf("sizeof eb_vcf_res_coef %zu\n", sizeof(eb_vcf_res_coef));
  return 0;
}

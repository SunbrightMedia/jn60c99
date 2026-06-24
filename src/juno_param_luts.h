/* juno_param_luts.h - denormalize LUTs from sub_356380 (.rdata), generated.
   Stored as raw float32 bit patterns for bit-exactness. */
#ifndef JUNO_PARAM_LUTS_H
#define JUNO_PARAM_LUTS_H
#include <string.h>
#define JUNO_LUT_COUNT 66
#define JUNO_LUT_SIZE 256
extern const unsigned int juno_param_lut_bits[JUNO_LUT_COUNT][JUNO_LUT_SIZE];
/* coefficient = lut[tableId][clamp(step,0,255)] */
static inline float juno_lut_apply(int tableId,int step){
  float f; unsigned int b;
  if(step<0)step=0; else if(step>255)step=255;
  b=juno_param_lut_bits[tableId][step]; memcpy(&f,&b,4); return f;
}
#endif

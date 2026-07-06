/* hpf_type_lut.h — see hpf_type_lut.c. */
#ifndef JUNO_HPF_TYPE_LUT_H
#define JUNO_HPF_TYPE_LUT_H
#include <stdint.h>
extern const uint32_t HPF_T1_10240[256];
extern const uint32_t HPF_T1_10272[256];
extern const uint32_t HPF_T1_10288[256];
/* Apply the HPF TYPE recall over the four HPF coefficients (see .c). */
void juno_apply_hpf_type(unsigned char *state, int cutoff, int type);
#endif

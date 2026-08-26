/* jx_ramp.h -- see jx_ramp.c for the derivation and the NaN rules. */
#ifndef JX_RAMP_H
#define JX_RAMP_H
#include <stdint.h>

/* Layout derived from sub_1803F4A40's own machine code; the padding names the
 * bytes the plugin does not touch, so the struct stays offset-faithful. */
typedef struct {
    float   *target;    /* +0x00 */
    float    step;      /* +0x08 */
    float    acc;       /* +0x0C */
    float    offset;    /* +0x10 */
    float    limit;     /* +0x14 */
    uint32_t pad18;     /* +0x18 (untouched by the stepper) */
    uint8_t  enabled;   /* +0x1C */
    uint8_t  pad1d[3];  /* +0x1D */
    int32_t  period;    /* +0x20 */
    int32_t  counter;   /* +0x24 */
} jx_ramp;

int  jx_ramp_step(jx_ramp *r);    /* 1 = still running, 0 = retired */
void jx_ramp_finish(jx_ramp *r);  /* force to limit and retire */

#endif /* JX_RAMP_H */

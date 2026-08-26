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

/* The WALKER's live list (sub_1803F40E0). The plugin holds it as three fields
 * inside the voice object; the names here are the roles its code proves:
 *   pool   [obj+0x58]  base of a 40-byte record array (index * 40)
 *   begin  [obj+0x70]  first live int32 INDEX
 *   end    [obj+0x78]  one past the last; the list COMPACTS toward begin
 * The element type is an int32 index, not a pointer: the walker computes
 * pool + idx*40 with `lea rcx,[rax+rax*4]` then `lea rcx,[rax+rcx*8]`. */
typedef struct {
    jx_ramp *pool;      /* +0x58 */
    int32_t *begin;     /* +0x70 */
    int32_t *end;       /* +0x78 */
} jx_ramp_list;

void jx_ramp_walk(jx_ramp_list *L);

#endif /* JX_RAMP_H */

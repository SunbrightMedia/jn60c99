/* ramp_engine.h — JUNO control-layer ramp/envelope engine (exact transcription).
 * See src/ramp_engine.c for the source RVAs and the 40-byte object layout. */
#ifndef JUNO_RAMP_ENGINE_H
#define JUNO_RAMP_ENGINE_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* 40-byte ramp object, byte-offset compatible with the plugin's struct. */
struct juno_ramp {
    float   *target;      /* +0  */
    float    incr;        /* +8  */
    float    accum;       /* +12 */
    float    start;       /* +16 */
    float    target_val;  /* +20 */
    float    range;       /* +24 */
    uint8_t  active;      /* +28 */
    uint8_t  _pad[3];
    int32_t  subdiv;      /* +32 */
    int32_t  step;        /* +36 */
};

void          juno_ramp_init   (struct juno_ramp *r, float *target, float range, int32_t subdiv);
unsigned char juno_ramp_trigger(struct juno_ramp *r, float target, float time_ms, int32_t subdiv);
char          juno_ramp_step   (struct juno_ramp *r);
void          juno_ramp_reset  (struct juno_ramp *r);

#ifdef __cplusplus
}
#endif

#endif /* JUNO_RAMP_ENGINE_H */

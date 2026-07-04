/* juno_ramp.h — the JUNO-60 stepped-linear ramp engine (note-on gate + any
 * ramped parameter). Exact transcription of sub_1803C2E80/2E00/2E60. */
#ifndef JUNO_RAMP_H
#define JUNO_RAMP_H

#ifdef __cplusplus
extern "C" {
#endif

/* Mirrors the plugin's 40-byte ramp object. `out` points at the state slot
 * being ramped; `rate` is the per-session constant (plugin engine+80). */
typedef struct {
    float *out;      /* +0  slot to ramp            */
    float  incr;     /* +8  per-step increment      */
    float  accum;    /* +12 accumulated             */
    float  start;    /* +16 value at ramp start     */
    float  target;   /* +20 ramp target             */
    float  rate;     /* +24 session rate constant   */
    int    active;   /* +28 armed?                  */
    int    subdiv;   /* +32 ticks per increment     */
    int    step_cnt; /* +36 tick counter            */
} juno_ramp;

void juno_ramp_init(juno_ramp *r, float *slot, float rate);
int  juno_ramp_start(juno_ramp *r, float target, float time_ms, int subdiv);
int  juno_ramp_step(juno_ramp *r);
void juno_ramp_reset(juno_ramp *r);

#ifdef __cplusplus
}
#endif
#endif /* JUNO_RAMP_H */

/* ramp_engine.c — exact C99 transcription of the JUNO control-layer ramp engine.
 *
 * These are the routines that generate the per-voice envelopes and the gate.
 * voice_render (sub_180369070) is a per-sample DSP that READS modulation/envelope
 * slots (e.g. the VCA env target at +9824) and never writes them; those slots are
 * driven by THIS engine, one linear ramp per envelope/gate, advanced once per
 * sample by the pruner (sub_1803C24A0). Without it the voice's envelope slots stay
 * at their reset/silent values and the voice is inaudible — which is exactly what
 * both a fresh init and the (silent) live state dump show. See docs/SOUND_TEST.md.
 *
 * Sources (image base 0x180000000):
 *   sub_1803C2D80  — ramp constructor (bind target, set range + subdivisions)
 *   sub_1803C2E80  — trigger a ramp toward a target value over a time
 *   sub_1803C2E00  — advance a ramp one step (per sample); returns 1 while active
 *   sub_1803C2E60  — reset a ramp to its target value
 *
 * The 40-byte ramp object layout (verified from the decompile's byte offsets):
 *   +0  float*  target      (the flat-state slot this ramp drives)
 *   +8  float   incr        (per-step increment of the accumulator)
 *   +12 float   accum       (accumulated delta)
 *   +16 float   start       (snapshot of *target at trigger)
 *   +20 float   target_val  (destination value)
 *   +24 float   range       (value range / scale, set at construction)
 *   +28 uint8   active
 *   +32 int32   subdiv      (samples per accumulator step)
 *   +36 int32   step        (sample counter within the current subdivision)
 */
#include "ramp_engine.h"
#include <string.h>

/* bit-pattern float constants used by the trigger when the computed increment is
 * exactly zero (decompile stores raw dwords 528482304 / -1619001344). */
static float f_from_bits(uint32_t b) { float f; memcpy(&f, &b, 4); return f; }

/* sub_1803C2D80 — construct/bind a ramp. a2=target slot ptr, a3=range, a4=subdiv. */
void juno_ramp_init(struct juno_ramp *r, float *target, float range, int32_t subdiv)
{
    r->range      = range;       /* +24 */
    r->incr       = 0.0f;        /* +8  (decompile clears +8/+12 as one qword) */
    r->accum      = 0.0f;        /* +12 */
    r->start      = 0.0f;        /* +16 (decompile clears +16/+20 as one qword) */
    r->target_val = 0.0f;        /* +20 */
    r->active     = 0;           /* +28 */
    r->step       = 0;           /* +36 */
    r->target     = target;      /* +0  */
    r->subdiv     = subdiv;      /* +32 */
}

/* sub_1803C2E80 — trigger the ramp toward `target` over `time_ms`, in `subdiv`
 * subdivisions. Returns the previous "was idle" flag (decompile returns v8).
 * a1=r, a2=target value, a3=time(ms), a4=subdivisions. */
unsigned char juno_ramp_trigger(struct juno_ramp *r, float target, float time_ms, int32_t subdiv)
{
    float *tgt;
    float range, cur, incr;
    unsigned char was_idle;

    if ( target == r->target_val )          /* already heading there */
        return 0;
    tgt      = r->target;
    range    = r->range;
    was_idle = (r->active == 0);
    r->target_val = target;                 /* +20 = a2 */
    cur      = *tgt;
    r->start = *tgt;                         /* +16 = current value */
    r->subdiv = subdiv;                      /* +32 = a4 */
    r->step   = 0;                           /* +36 = 0 */
    incr = (float)((float)(target - cur) * (float)(1000.0f / time_ms))
         / (float)(range / (float)subdiv);
    r->incr = incr;                          /* +8 */
    if ( incr == 0.0f ) {
        if ( cur < target ) {
            r->accum  = 0.0f;                /* +12 = 0 */
            r->incr   = f_from_bits(528482304u);   /* tiny +inc */
            r->active = 1;
            return was_idle;
        }
        if ( cur > target )
            r->incr = f_from_bits((uint32_t)-1619001344);  /* tiny -inc */
    }
    r->accum  = 0.0f;                        /* +12 = 0 */
    r->active = 1;                           /* +28 = 1 */
    return was_idle;
}

/* sub_1803C2E00 — advance one sample. Returns 1 while the ramp is still active,
 * 0 once it has reached its target (the pruner drops the voice on 0). */
char juno_ramp_step(struct juno_ramp *r)
{
    float v1, v3, v4;

    if ( r->active ) {
        if ( ++r->step < r->subdiv )         /* still within this subdivision */
            return 1;
        v1 = r->incr + r->accum;             /* advance the accumulator */
        r->step  = 0;
        r->accum = v1;
        *r->target = v1 + r->start;          /* *target = start + accumulated */
        v3 = *r->target;
        v4 = r->target_val;
        if ( r->incr <= 0.0f ) {
            if ( v3 > v4 )                    /* descending, not past target yet */
                return 1;
        } else if ( v3 < v4 ) {              /* ascending, not past target yet */
            return 1;
        }
        *r->target = v4;                     /* clamp to target, deactivate */
        r->accum   = 0.0f;
        r->active  = 0;
    }
    return 0;
}

/* sub_1803C2E60 — hard reset to target value. */
void juno_ramp_reset(struct juno_ramp *r)
{
    *r->target = r->target_val;
    r->step    = 0;
    r->accum   = 0.0f;
    r->active  = 0;
}

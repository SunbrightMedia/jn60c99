/* juno_ramp.c — exact C99 transcription of the JUNO-60 gate/parameter ramp
 * engine (sub_1803C2E80 start / sub_1803C2E00 step / sub_1803C2E60 reset).
 * This is the stepped-linear ramp that drives the note-on gate (and any ramped
 * parameter) toward a target over a time in ms. Verified against the decompile;
 * the two "tiny nudge" constants (0x1F800000 / 0x9F800000) preserve ramp
 * direction when the per-step increment rounds to exactly 0.
 *
 * Layout mirrors the plugin's 40-byte ramp object: out-pointer, incr, accum,
 * start, target, rate, active, subdiv, step_cnt.  See docs/CONTROL_LAYER.md.
 */
#include "juno_ramp.h"
#include <string.h>

static float bits_to_f(unsigned int b) { float f; memcpy(&f, &b, 4); return f; }

/* sub_1803C2E80: arm a ramp of *r->out toward `target` over `time_ms`,
 * advancing every `subdiv` step() ticks. Returns 1 if it was inactive. */
int juno_ramp_start(juno_ramp *r, float target, float time_ms, int subdiv)
{
    float start, incr;
    int was_inactive;
    if (target == r->target) return 0;
    start = *r->out;
    was_inactive = (r->active == 0);
    r->target   = target;
    r->start    = start;
    r->subdiv   = subdiv;
    r->step_cnt = 0;
    incr = ((target - start) * (1000.0f / time_ms)) / (r->rate / (float)subdiv);
    r->incr = incr;
    if (incr == 0.0f) {
        if (start < target) {           /* increment underflowed to 0: nudge up */
            r->accum = 0.0f;
            r->incr = bits_to_f(0x1F800000u);
            r->active = 1;
            return was_inactive;
        }
        if (start > target)             /* ...or down */
            r->incr = bits_to_f(0x9F800000u);
    }
    r->accum = 0.0f;
    r->active = 1;
    return was_inactive;
}

/* sub_1803C2E00: advance one control tick. Returns 1 while still ramping,
 * 0 once the target is reached (and the ramp deactivates). */
int juno_ramp_step(juno_ramp *r)
{
    float v, out, target;
    if (!r->active) return 0;
    if (++r->step_cnt < r->subdiv) return 1;   /* only every `subdiv` ticks */
    v = r->incr + r->accum;
    r->step_cnt = 0;
    r->accum = v;
    *r->out = v + r->start;
    out = *r->out;
    target = r->target;
    if (r->incr <= 0.0f) { if (out > target) return 1; }
    else                 { if (out < target) return 1; }
    *r->out = target;                          /* reached: clamp + deactivate */
    r->accum = 0.0f;
    r->active = 0;
    return 0;
}

/* sub_1803C2E60: snap to target and deactivate. */
void juno_ramp_reset(juno_ramp *r)
{
    *r->out = r->target;
    r->accum = 0.0f;
    r->active = 0;
}

/* Bind a ramp to a state slot; set its rate (plugin engine+80 constant). */
void juno_ramp_init(juno_ramp *r, float *slot, float rate)
{
    memset(r, 0, sizeof *r);
    r->out = slot;
    r->rate = rate;
    r->target = *slot;
}

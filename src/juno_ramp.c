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

/* ORDERED-AND-UNEQUAL -- what x86's `ucomiss a,b ; jne <taken>` actually tests.
 * ucomiss sets ZF=1 when the operands are UNORDERED, so `jne` is NOT taken if
 * either side is NaN, exactly as it is not taken when they are equal. C's
 * `a != b` is TRUE for NaN, so neither `a != b` nor `!(a != b)` reproduces the
 * jump. Only this does. Paid for twice on 2026-08-26: the first inverted
 * rewrite here was still wrong, and the ramp A/B said so. */
#define JR_NE(a, b) ((a) < (b) || (a) > (b))

/* sub_1803C2E80: arm a ramp of *r->out toward `target` over `time_ms`,
 * advancing every `subdiv` step() ticks. Returns 1 if it was inactive. */
int juno_ramp_start(juno_ramp *r, float target, float time_ms, int subdiv)
{
    float start, incr;
    int was_inactive;
    /* 3C2E86: `ucomiss xmm3(target), [rcx+0x14] ; jne` -- jne is NOT taken
     * when unordered, so a NaN target EARLY-OUTS and arms nothing. C's
     * `target == r->target` is false on NaN and armed the ramp instead. */
    if (!JR_NE(target, r->target)) return 0;
    start = *r->out;
    was_inactive = (r->active == 0);
    r->target   = target;
    r->start    = start;
    r->subdiv   = subdiv;
    r->step_cnt = 0;
    incr = ((target - start) * (1000.0f / time_ms)) / (r->rate / (float)subdiv);
    r->incr = incr;
    /* 3C2EDF: `ucomiss xmm2, xmm0(0.0) ; jne` -- jne is NOT taken when
     * unordered, so a NaN increment ENTERS this block. C's `incr == 0.0f` is
     * false on NaN and would skip it. Write the JUMP, not the operator
     * (playbook 81). */
    if (!JR_NE(incr, 0.0f)) {
        /* 3C2EE9: `comiss xmm4(start), xmm3(target) ; jae` -- jae is NOT taken
         * when unordered, so a NaN start or target takes the UP-nudge path.
         * `start < target` is false on NaN and took the wrong branch. */
        if (!(start >= target)) {       /* increment underflowed to 0: nudge up */
            r->accum = 0.0f;
            r->incr = bits_to_f(0x1F800000u);
            r->active = 1;
            return was_inactive;
        }
        /* 3C2F00: `jbe` IS taken when unordered, so the down-nudge is skipped.
         * Only ordered start > target reaches it -- but write it as the jump. */
        if (!(start <= target))         /* ...or down */
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
    /* 3C2E34 `comiss 0.0, incr ; jae` selects the branch; jae is not taken on
     * unordered, so a NaN incr takes the ELSE arm -- which C's `incr <= 0.0f`
     * also does, so this one test needed no change.
     * 3C2E4E arm (incr <= 0): `comiss out, target ; ja` -- ja not taken on
     * unordered, so a NaN falls through to the clamp, and C's `out > target`
     * being false does the same. Correct as written.
     * 3C2E46 arm (incr > 0): `comiss out, target ; jae` -- jae NOT taken on
     * unordered, so a NaN KEEPS RAMPING (returns 1). C's `out < target` is
     * false on NaN and clamped instead. That one was wrong. */
    if (r->incr <= 0.0f) { if (out > target) return 1; }
    else                 { if (!(out >= target)) return 1; }
    *r->out = target;                          /* reached: clamp + deactivate */
    r->accum = 0.0f;
    r->active = 0;
    return 0;
}

/* sub_1803C2E60: snap to target and deactivate. */
void juno_ramp_reset(juno_ramp *r)
{
    *r->out = r->target;
    /* 3C2E6A: `mov dword ptr [rcx+0x24], eax` with eax = 0. The port omitted
     * this for the whole life of the file: reset cleared accum and active but
     * LEFT step_cnt at whatever the interrupted ramp had reached, so the next
     * ramp armed on this record fired its first increment early -- by up to
     * subdiv-1 control ticks. Found 2026-08-26 by ramp_ab (the JUNO's first
     * ramp differential gate); no existing gate could see it, which is exactly
     * why `ramp_const` was a mutation SURVIVOR. */
    r->step_cnt = 0;
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

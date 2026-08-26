/* ramp_ab_shim.c -- plumbing only for the JUNO ramp A/B (harness rule: it may
 * never reimplement plugin logic). Rebuilds the 40-byte ramp record from flat
 * bytes, repoints `out` at the caller's slot, then replays start, then the
 * steps, then reset. */
#include <string.h>
#include <stdint.h>
#include "../../src/juno_ramp.h"

void juno_enable_hw_ftz(void);

/* rec: 40 bytes in the plugin's layout. slot: the ramped float.
 * steps_rc / steps_rec / steps_slot: per-step outputs, caller-allocated. */
int jr_case(void *rec_bytes, void *slot_bytes,
            uint32_t target_bits, uint32_t time_bits, int subdiv,
            int nstep, int32_t *steps_rc, void *steps_rec, void *steps_slot,
            void *after_start, void *after_reset)
{
    juno_ramp *r = (juno_ramp *)rec_bytes;
    float *slot = (float *)slot_bytes;
    float target, time_ms;
    int i, rc_start;

    juno_enable_hw_ftz();               /* the plugin's FP mode, as ever */

    memcpy(&target, &target_bits, 4);
    memcpy(&time_ms, &time_bits, 4);
    r->out = slot;

    rc_start = juno_ramp_start(r, target, time_ms, subdiv);
    memcpy(after_start, r, 40);

    for (i = 0; i < nstep; i++) {
        steps_rc[i] = juno_ramp_step(r);
        memcpy((char *)steps_rec + 40 * i, r, 40);
        memcpy((char *)steps_slot + 4 * i, slot, 4);
    }

    juno_ramp_reset(r);
    memcpy(after_reset, r, 40);
    return rc_start;
}

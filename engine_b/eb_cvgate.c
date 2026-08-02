/* eb_cvgate.c — see eb_cvgate.h. Order and parenthesisation are the port's. */
#include "eb_cvgate.h"

void eb_cvgate(const eb_cvgate_in *in, eb_cvgate_out *out)
{
    float v27 = in->p28;
    float v26 = in->k;
    /* :657-658 — a one-pole step toward the target, written as
     * (target*k - prev*k) + prev. NOT prev + k*(target-prev): the port forms
     * both products separately and subtracts them, which rounds differently. */
    float v28 = ((in->t28 * v26) - (v26 * v27)) + v27;
    float v29 = ((in->t29 * v26) - (in->p29 * v26)) + in->p29;
    float v31 = v29 + in->gate_off;
    float v32 = (v31 < 0.0f) ? v31 : 0.0f;
    /* :667-671 — v29 EXACTLY zero forces -1.0; otherwise the clipped sum. */
    float v34 = (v29 == 0.0f) ? -1.0f : v32;

    out->c336 = v27;
    out->c448 = v26;
    out->c464 = v28;
    out->c480 = v29;
    out->c496 = v34;

    /* :673-680 — the three-way sign. Zero maps to ZERO, not to +1. */
    if (v34 >= 0.0f) out->sign = (v34 > 0.0f) ? 1.0f : v34;
    else             out->sign = -1.0f;
}

/* eb_chorus_cost.c — executed-instruction driver for ENGINE B module M-CHORUS.
 *
 * Renders n samples through eb_chorus_tick() and nothing else, so
 * `tools/engineb/cost.py density` can MEASURE the module's dynamic instruction
 * count and its execution density rho, instead of charging the static count.
 * That matters here for one specific reason: eb_wrap_unit contains two fmodf
 * calls that the STATIC count charges at 80..300 cycles each, but which are
 * only reached when the LFO phase crosses +/-1 -- MEASURED once per LFO period,
 * i.e. once in 100,000 samples at 48 kHz. A static-only cost for this module is
 * wrong by construction and this driver is how that is shown rather than
 * asserted.
 *
 * The coefficients are the SEALED PORT's own, read out of a live engine at
 * 48 kHz with factory patch 0 recalled (juno_gui_peek, bit patterns below), so
 * the branch behaviour measured here is the branch behaviour of a real patch.
 * EFFECT DEPTH is patch 0's 0.0; it is overridden to a non-zero wet gain below
 * so the wet path is not measured in a state no chorus patch is ever in.
 *
 * Build: cc -O2 -ffp-contract=off -I engine_b -o /tmp/ebchcost \
 *            tools/engineb/eb_chorus_cost.c engine_b/eb_chorus.c -lm
 * Use:   /tmp/ebchcost <n>
 */
#include "eb_chorus.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static const unsigned int COEF_BITS[39] = {
    0x3b8c0000u, 0x3f77b282u, 0x37a7c5acu, 0x3f800000u, 0x3b83126fu,
    0x3b247b86u, 0x3fa66666u, 0x00000000u, 0x387fd974u, 0x3f800000u,
    0x3f800000u, 0x3da23a31u, 0x3e223a31u, 0x3da23a31u, 0x3f9bb474u,
    0xbf088600u, 0x3f7fbfb9u, 0xbf7fbfb9u, 0x3f7f7f72u, 0x3e80d8ceu,
    0x3fc4ec4fu, 0x350637bdu, 0x40bb8000u, 0x39000000u, 0x38800000u,
    0x3d800000u, 0x3c000000u, 0xbc000000u, 0x3f800000u, 0x3e99999au,
    0x3f5bb937u, 0xbf5bb937u, 0x3f37726fu, 0x3d486075u, 0x3dc86075u,
    0x3d486075u, 0x3fb5a42du, 0xbf1d6077u, 0x00000400u
};

static float fb(unsigned int u) { float f; memcpy(&f, &u, 4); return f; }

int main(int argc, char **argv)
{
    static eb_chorus_state s;
    eb_chorus_coef k;
    float *p = (float *)&k;
    int n = (argc > 1) ? atoi(argv[1]) : 1000;
    int i;
    double acc = 0.0;

    for (i = 0; i < 38; ++i) p[i] = fb(COEF_BITS[i]);
    k.ring_len = (int)COEF_BITS[38];
    k.wet = 0.28296f;                 /* EFFECT DEPTH 128, MEASURED table entry */
    eb_chorus_reset(&s);

    for (i = 0; i < n; ++i) {
        float l, r;
        float in = (float)((i % 97) - 48) * 0.25f;   /* cheap non-zero input */
        eb_chorus_tick(&s, &k, in, &l, &r);
        acc += (double)l + (double)r;
    }
    printf("%d %.9g\n", n, acc);
    return 0;
}

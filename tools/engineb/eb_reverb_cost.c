/* eb_reverb_cost.c -- callgrind driver for engine_b/eb_reverb.c, so the module's
 * EXECUTION DENSITY (rho) is MEASURED rather than transferred from
 * juno_voice_render. Two run lengths, so the seed/latch/wipe cost cancels in the
 * slope and what is left is the steady-state per-sample cost of the tank.
 *
 * Coefficients are the MEASURED REVERB TYPE 2 set at 48,000 Hz
 * (docs/engineb/data/fx_reverb.json -> reference_vectors.ir_48000_type2), which
 * is the worst case for memory: the longest tap set of the six types.
 *
 * Build: cc -O2 -std=c99 -ffp-contract=off -Iengine_b -o eb_reverb_cost \
 *          tools/engineb/eb_reverb_cost.c engine_b/eb_reverb.c
 * Run:   ./eb_reverb_cost <nsamples>
 */
#include "eb_reverb.h"
#include <stdio.h>
#include <stdlib.h>

static const int32_t TAPS[34] = { 1, 959, 1921, 3832, 3834, 5351, 5353, 6260, 6262, 6623, 6625, 7972, 7974, 9315, 9317, 10668, 10670, 12017, 12019, 16208, 19064, 19184, 19186, 23135, 26563, 26801, 26803, 30254, 35012, 36558, 36560, 40249, 45007, 46551 };

int main(int argc, char **argv)
{
    static eb_reverb_state s;
    eb_reverb_cfg c;
    int32_t wipe = 256;
    long n = (argc > 1) ? atol(argv[1]) : 10000, i;
    double acc = 0.0;
    float ph = 0.0f;
    const float FIN[8] = { 0.9982222318649292f, -0.9982222318649292f, 0.99644440412521362f, 0.047680456191301346f, 0.095360912382602692f, 0.047680456191301346f, 1.2943686246871948f, -0.4850904643535614f };
    const float DAMP[4][3] = { { 0.13027560710906982f, 0.51116722822189331f, -0.72466951608657837f }, { 0.13027560710906982f, 0.51116722822189331f, -0.72466951608657837f }, { 0.13027560710906982f, 0.42142596840858459f, -0.65494924783706665f }, { 0.13027560710906982f, 0.42142596840858459f, -0.65494924783706665f } };
    int k, j;

    eb_reverb_init(&s);
    c.send = 0.372772216796875f; c.gate = 1.0f; c.dry = 1.0f;
    c.wet = 0.49803921580314636f; c.ap = 0.5f;
    for (k = 0; k < 8; ++k) c.f_in[k] = FIN[k];
    for (k = 0; k < 4; ++k) for (j = 0; j < 3; ++j) c.damp[k][j] = DAMP[k][j];
    c.lfo_inc = 0.0f; c.lfo_depth = 0.0f;

    for (i = 0; i < n; ++i) {
        float a, b;
        ph += 0.01f; if (ph > 1.0f) ph -= 2.0f;
        eb_reverb_process(&c, &s, TAPS, &wipe, ph * 0.3f, ph * 0.2f, &a, &b);
        acc += a + b;
    }
    if (s.overrun) { fprintf(stderr, "OVERRUN\n"); return 2; }
    printf("%ld %.9g\n", n, acc);
    return 0;
}

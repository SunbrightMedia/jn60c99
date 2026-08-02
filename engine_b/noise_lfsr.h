/* noise_lfsr.h — the JUNO-60's "analog noise", exactly.
 *
 * PROVEN: reproduces 200,000 consecutive oracle samples BIT-IDENTICALLY from the
 * cold-start seed alone (docs/engineb/data/noise_core_200k.npy). Not an
 * approximation and not a model — the same integer sequence, and the same float
 * bits after scaling.
 *
 * This is the first concrete evidence for the corrected accuracy standard
 * (docs/trackb/ACCURACY_STANDARD.md): the "analog" noise is a deterministic
 * 25-bit LFSR, so engine B copies it rather than approximating it. There is no
 * spectral-equivalence compromise to make here.
 *
 * The recurrence, recovered from the capture rather than read from the decompile:
 *
 *     u        = x & 0x01FFFFFF                 (unsigned 25-bit view)
 *     b        = 1 ^ bit21(u) ^ bit23(u)        (feedback)
 *     x        = wrap25(-2*x + b)               (signed 25-bit)
 *     output   = (float)x * 2^-24
 *
 * Cold-start seed is x = 1, which is why the first samples are
 * 1, -1, 3, -5, 11, -21, 43, -85, ... scaled by 2^-24.
 *
 * COST: 6 integer operations, one convert, one multiply. It is cheap enough that
 * a silent-voice skip never needs to apply to it — just run it every sample and
 * lockstep is preserved for free. (docs/trackb/ACCURACY_STANDARD.md requires an
 * O(1) advance-by-N for free-running state; for this generator the honest answer
 * is that stepping is already cheaper than any skip logic would be.)
 */
#ifndef ENGINEB_NOISE_LFSR_H
#define ENGINEB_NOISE_LFSR_H

#include <stdint.h>

#define EB_NOISE_SEED  1
#define EB_NOISE_SCALE (1.0f / 16777216.0f)   /* 2^-24 */

typedef struct { int32_t x; } eb_noise;

static inline void eb_noise_init(eb_noise *n) { n->x = EB_NOISE_SEED; }

/* Emits the CURRENT state, THEN advances. That order is load-bearing: emitting
 * after the advance shifts the whole sequence by one sample, which is audible
 * and which the bit-exact test below catches immediately. */
static inline float eb_noise_step(eb_noise *n)
{
    float out = (float)n->x * EB_NOISE_SCALE;

    uint32_t u = (uint32_t)n->x & 0x01FFFFFFu;
    int32_t  b = 1 ^ (int32_t)((u >> 21) & 1u) ^ (int32_t)((u >> 23) & 1u);
    int32_t  v = -2 * n->x + b;
    /* wrap to signed 25-bit: [-2^24, 2^24) */
    n->x = (int32_t)(((uint32_t)(v + 0x01000000) & 0x01FFFFFFu)) - 0x01000000;

    return out;
}

#endif

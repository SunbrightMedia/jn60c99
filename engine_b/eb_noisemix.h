/* eb_noisemix.h — the noise SVF's output mix.
 *
 * SCOPE. src/voice_render.c:1141-1149 exactly. This is the block
 * eb_noise_svf.h deliberately left behind: its comment says lines 1141-1149
 * "delay and scale cells 6416/6448/6544 that are written and read OUTSIDE this
 * block", and that a module boundary drawn for tidiness is not one that can be
 * proven. Now that the surrounding blocks are modules, it can be.
 *
 * IT IS A PURE FUNCTION. No state at all: the one cell that both reads and
 * writes (6432) is loaded from 6416 at the top and read below in the same
 * sample, and 6544's own read feeds only the dead cell 6560.
 *
 * WHICH INPUTS ARE COEFFICIENTS WAS CHECKED, NOT ASSUMED, and the check
 * changed the interface. A grep for writes across the whole voice function
 * shows 6416, 6448, 6512 and 6528 are never written there, so those four are
 * recall coefficients and may be cached. But 3536 IS written, at :1076, as a
 * per-sample delayed copy of 3520 -- so it is a PER-SAMPLE INPUT. Caching it
 * with the others would have frozen a value that changes every sample, which
 * the coefficient-generation guard could never have caught because the cell
 * genuinely does not change at recall time.
 *
 * FIVE DEAD STORES are not reproduced: 6464, 6480, 6496, 6560 and the 6432
 * copy. None has a reader outside this block.
 *
 * The arithmetic is four multiplies and an add. It is claimed not for its cost
 * but because it is the last thing standing between the noise path and being
 * wholly engine B's.
 */
#ifndef ENGINEB_EB_NOISEMIX_H
#define ENGINEB_EB_NOISEMIX_H

typedef struct {
    float k6416, k6448, k6512, k6528;
} eb_noisemix_coef;

/* Returns the value the port stores in cell 6544. `nsv4320` is the noise SVF's
 * output (cell 4320) and `in3536` the per-sample cell 3536. */
float eb_noisemix_tick(const eb_noisemix_coef *c, float nsv4320, float in3536);

#endif /* ENGINEB_EB_NOISEMIX_H */

/* eb_notecv.h — the JUNO's shared "analog" noise generator: the 25-bit LFSR and
 * the one-pole filter on its output.
 *
 * SCOPE. src/voice_render.c:595-656 exactly. The boundary is set by the
 * NEIGHBOURING MODULE, not by taste: module 'cvgate' owns :657-681, and it
 * computes the values this block used to be drawn around. merge_shims.py's
 * overlap guard refused to build a composite while the two ranges collided --
 * twice, as the boundary was walked back from 681 to 672 to 656. That guard is
 * the reason this file describes the noise generator and nothing else.
 *
 * WHAT IT PRODUCES. One value: base cell 84432, the noise sample every voice's
 * noise SVF and DCO read. Everything else in the range is either a plain recall
 * cell read that the shim keeps where the port put it, or a dead store.
 *
 * STATE IS TWO FLOATS: the LFSR register (84336) and its filter (84368).
 *
 * ELEVEN DEAD STORES are not reproduced -- a1 192/224/256/288/336/352/400/416/
 * 432/512 and base 84288/84320/84352/84384. Each was grepped across src/ and
 * gui/; the only hits are chorus_init.c zeroing them at construction and
 * coincidental digit matches inside juno_init.c's constants.
 *
 * THE LFSR IS TRANSCRIBED, NOT SUBSTITUTED. engine_b/noise_lfsr.h holds the
 * same generator in a cheaper integer form, PROVEN bit-identical over 200,000
 * consecutive samples. It is deliberately not used here: the port carries this
 * state as a FLOAT in cell 84336, the shim must write that cell back, and this
 * module's first gate must attribute any divergence to the transcription
 * alone. Swapping in eb_noise_step is a separate change with its own null run,
 * and it is worth making -- the port's form spends a float->int->float round
 * trip per sample that the integer form does not.
 */
#ifndef ENGINEB_EB_NOTECV_H
#define ENGINEB_EB_NOTECV_H

typedef struct {
    float n84336;              /* LFSR register, carried as the port does */
    float n84368;              /* the noise one-pole filter               */
} eb_notecv_state;

typedef struct {
    float n84272, n84304, n84400, n84416;
} eb_notecv_coef;

/* One sample. Returns the noise value the port stores in base cell 84432. */
float eb_notecv_tick(eb_notecv_state *s, const eb_notecv_coef *c);

#endif /* ENGINEB_EB_NOTECV_H */

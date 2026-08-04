/* eb_master_in.h — the MASTER INPUT STAGE: eight voices in, two channel
 * signals out. src/master_render.c:826-886 exactly.
 *
 * WHY THIS RANGE. Chosen by the same live-variable analysis that chose every
 * voice module's boundary, not by eye: MEASURED (tools/engineb/master_cuts.py)
 * it has ZERO live-in and three live-out locals, the narrowest cut in the first
 * third of the function. It is the first block of task 1b-1.
 *
 * WHAT IT DOES. Sums the eight voices in pairs, applies the three pair gains
 * and the fourth pair's own scale, runs the summed signal through a one-pole,
 * and produces the two channel signals the DELAY routing switch at :887
 * consumes. It is the instrument's whole output before any effect.
 *
 * ---------------------------------------------------------------------------
 * THE CELL CLASSIFICATION, and TWO cells here are the trap this project keeps
 * re-learning. Checked over the WHOLE function with BOTH accessors, because
 * master_render.c copies with `_DWORD` exactly as freely as voice_render.c
 * copies with `JI` -- and a one-accessor grep is how the DCO oscillator levels
 * came to be cached from per-sample cells and made the engine emit silence.
 *
 *   COEFFICIENTS (no writer anywhere in master_render.c):
 *     84448 84464 84480  the three pair gains
 *     84496              the fourth pair's scale (the port's v5)
 *     84512              the sum scale
 *     84544 84560        the two mid/side-style factors (v9, v14)
 *     84640 84656        the one-pole
 *     84800 84816        the feedback mix
 *     101072             the master level
 *
 *   THIS BLOCK'S OWN STATE:
 *     84768              read at :850 as v25, written at :872 as v32 -- a
 *                        one-sample delay of this block's own one-pole output
 *
 *   ★ CROSS-SAMPLE FEEDBACK FROM A BLOCK THAT RUNS LATER IN THE SAME SAMPLE:
 *     84672 84704        read at :864 and :847, and WRITTEN at :2496, :2625,
 *                        :2747, :2936 and :2940 -- by the chorus/EFFECT stage,
 *                        at the very end of the function. So this block reads
 *                        the PREVIOUS sample's values.
 *
 *   **A read-before-write scan of :826-886 ALONE calls both of those
 *   coefficients.** They are only visible as state when the scan covers the
 *   whole function. That is trap 1 of THE FOUR WAYS THE SCRIPT LIES
 *   (CLAUDE.md), in the master chain, on the very first block.
 *
 *   They are ARGUMENTS here, not state, and deliberately so: they belong to the
 *   block that WRITES them, which is not yet transcribed. When that block is
 *   claimed they become its state and these arguments go away. Declaring them
 *   state now would mean two modules both claiming to own one value.
 *
 * DEAD STORES. The block writes 23 further cells that nothing in
 * master_render.c reads -- the eight per-voice input mirrors (10672 + v*10512)
 * and fifteen intermediate values. They are dropped here, exactly as eb_lfo
 * dropped its seven, and the EXACTLY-0 null is what proves them dead. Cell
 * 84624 is NOT among them: four later blocks read it, so it is a real output.
 */
#ifndef ENGINEB_EB_MASTER_IN_H
#define ENGINEB_EB_MASTER_IN_H

typedef struct {
    float k84448, k84464, k84480;   /* pair gains for voices 0-1, 2-3, 4-5   */
    float k84496;                   /* the 4th pair's scale (v5)             */
    float k84512;                   /* the sum scale                         */
    float k84544;                   /* v9                                    */
    float k84560;                   /* v14                                   */
    float k84640, k84656;           /* the one-pole: y = x*k84640 + k84656   */
    float k84800, k84816;           /* the feedback mix                      */
    float k101072;                  /* the master level                      */
} eb_master_in_coef;

typedef struct {
    float s84768;                   /* one-sample delay of the one-pole out  */
} eb_master_in_state;

/* One sample. `voice[8]` are the eight voice samples in voice order. `fb84672`
 * and `fb84704` are the previous sample's cells 84672 and 84704 -- see the
 * cross-sample note above. Writes the two channel signals (the port's v36 and
 * v38, cells 101104 and 101120) and the one-pole output (the port's v32, cell
 * 84624, which four later blocks read). */
void eb_master_in_tick(eb_master_in_state *s, const eb_master_in_coef *c,
                       const float *voice, float fb84672, float fb84704,
                       float *out36, float *out38, float *out32);

#endif /* ENGINEB_EB_MASTER_IN_H */

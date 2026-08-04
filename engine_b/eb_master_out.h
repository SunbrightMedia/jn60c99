/* eb_master_out.h — the MASTER OUTPUT STAGE: the boost saturator and the
 * output gain. src/master_render.c:2338-2377, plus the doubling at :2941-2943.
 *
 * WHY THIS RANGE. MEASURED by tools/engineb/master_cuts.py: TWO live-in
 * (the port's v529 and v530, the two channel signals after the effects) and
 * ZERO live-out. That is the cleanest cut in the whole function -- the eb_lfo
 * shape -- and it is why this block lifts as a module rather than as a
 * marshalling exercise.
 *
 * WHY IT SWALLOWS THE FUNCTION'S TAIL. The cut map reports a zero-width cut at
 * :2941, and taken literally that suggests a separate "output assembly" module.
 * It is not one: those three lines are `**a3 = 2 * cell101264` and
 * `*result = 2 * cell101280` -- no arithmetic beyond a doubling, on the two
 * cells THIS block writes. Wrapping them in their own module would add a call
 * and move nothing into engine B; it would improve the blocks-claimed count and
 * not the engine. That is the judgement eb_dcoprep already recorded about the
 * port's :1665-1671, applied again. The doubling is this module's last step.
 *
 * THE CELL CLASSIFICATION, whole-function and BOTH accessors:
 *
 *   COEFFICIENTS -- every one of them written only by juno_init/juno_prepare,
 *   never by master_render.c:
 *     101136 101152   the two gain terms (reached through the delayed copies
 *                     101168 and 101184, see below)
 *     101296          the saturator input scale
 *     101312          the output gain
 *     101328 101344 101360 101376 101392 101408
 *                     the saturator polynomial
 *     101424 101440   the upper clamp threshold and its value
 *     101456 101472   the lower clamp threshold and its value
 *
 *   NO STATE AT ALL. This block carries nothing across samples.
 *
 *   WRITE-THEN-READ, NOT A DELAY. The port writes 101168 <- 101136 and
 *   101184 <- 101152 and then READS both back in the same sample, so they
 *   carry the CURRENT coefficient and there is no one-sample lag to model.
 *   Checked rather than assumed: this is trap 3's shape (a cell that looks
 *   like state because it is written and read in the same range) and the
 *   opposite mistake -- modelling a lag that is not there -- would be just as
 *   wrong as missing one that is.
 *
 *   DEAD STORES: 101200, 101216, 101232, 101248 and the header mirrors at 32
 *   and 36. Nothing in master_render.c reads them after this block. The shim
 *   keeps 32 and 36 because they are the host-visible output mirror and cost
 *   two stores; the four intermediates are dropped and the EXACTLY-0 null is
 *   what proves them dead.
 *
 * THE TWO CLAMPS ARE NOT SYMMETRIC IN THE PORT AND ARE NOT MADE SO HERE. For
 * the left channel the port tests the LOW threshold first and the HIGH one
 * after, and each test OVERWRITES the polynomial result rather than clamping
 * it. Written in the port's order, because the second test wins when both are
 * true and any tidier formulation would change which value survives.
 */
#ifndef ENGINEB_EB_MASTER_OUT_H
#define ENGINEB_EB_MASTER_OUT_H

typedef struct {
    float k101136, k101152;          /* the two gain terms                   */
    float k101296;                   /* saturator input scale                */
    float k101312;                   /* output gain                          */
    float k101328, k101344, k101360; /* saturator polynomial                 */
    float k101376, k101392, k101408;
    float k101424, k101440;          /* upper clamp: threshold, value        */
    float k101456, k101472;          /* lower clamp: threshold, value        */
} eb_master_out_coef;

/* One sample. `inL`/`inR` are the port's v529 and v530. Writes the two cells
 * the port's tail doubles (101264 and 101280) through `cell264`/`cell280`, and
 * the FINAL stereo sample pair -- already doubled -- through `outL`/`outR`. */
void eb_master_out_tick(const eb_master_out_coef *c, float inL, float inR,
                        float *cell264, float *cell280,
                        float *outL, float *outR);

#endif /* ENGINEB_EB_MASTER_OUT_H */

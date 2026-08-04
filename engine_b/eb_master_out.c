/* eb_master_out.c — see eb_master_out.h.
 *
 * Transcribed from src/master_render.c:2338-2377 parenthesis for parenthesis.
 * The decompile's `(float)(...)` casts mark single-precision roundings and
 * decide the result, so they are kept as explicit temporaries. The two channels
 * do NOT share a helper: the port evaluates them with differently-associated
 * expressions (the left builds the odd powers by repeated multiplication of
 * v541, the right reuses v543 = v542*v542 and v546 = v543*v542), and folding
 * them into one function would change the association and therefore the result.
 * Built with -ffp-contract=off, like the rest of the engine.
 */
#include "eb_master_out.h"

void eb_master_out_tick(const eb_master_out_coef *c, float inL, float inR,
                        float *cell264, float *cell280,
                        float *outL, float *outR)
{
    float v535, v536, v537, v538, v539, v540;
    float v541, v542, v543, v544, v545, v546, v547, v548, v549, v550;

    /* 101168 <- 101136 and 101184 <- 101152, then both read back in the SAME
     * sample: the current coefficients, no delay. See the header. */
    v535 = c->k101136;

    /* THE ORDER OF THESE TWO PRODUCTS IS THE PORT'S AND IS NOT SYMMETRIC.
     * The port computes v537 with the gain on the LEFT of the product and v536
     * with it on the right; float multiplication is commutative, but the
     * grouping around them is not, so both are written as it wrote them. */
    v536 = (float)(v535 * inR) * c->k101152;
    v537 = c->k101152 * (float)(v535 * inL);

    v538 = c->k101296;
    v539 = c->k101328;
    v540 = c->k101376;
    v541 = v537 * v538;
    v542 = v536 * v538;
    v543 = v542 * v542;

    /* ---- left channel ---- */
    v544 = (float)((float)((float)((float)((float)(v541 * v541) * v541) * v541)
                           * c->k101392)
                   + (float)((float)((float)((float)(c->k101344 * v541) + v539)
                                     + (float)(c->k101360 * (float)(v541 * v541)))
                             + (float)(v540 * (float)((float)(v541 * v541) * v541))))
         + (float)((float)((float)((float)((float)(v541 * v541) * v541) * v541)
                           * v541) * c->k101408);
    if ((float)(c->k101456 - v541) <= 0.0f) v544 = c->k101472;

    v545 = c->k101360 * v543;
    v546 = v543 * v542;
    v547 = (float)((float)(c->k101344 * v542) + v539) + v545;

    /* THE SECOND TEST WINS WHEN BOTH ARE TRUE. The port applies the upper clamp
     * AFTER the lower one and each assignment overwrites, so this order is
     * load-bearing. */
    if ((float)(c->k101424 - v541) >= 0.0f) v544 = c->k101440;

    v548 = v544 * c->k101312;

    /* ---- right channel ---- */
    v549 = (float)((float)((float)(v546 * v542) * c->k101392)
                   + (float)(v547 + (float)(v540 * v546)))
         + (float)((float)((float)(v546 * v542) * v542) * c->k101408);
    if ((float)(c->k101456 - v542) <= 0.0f) v549 = c->k101472;
    if ((float)(c->k101424 - v542) >= 0.0f) v549 = c->k101440;

    v550 = v549 * c->k101312;

    *cell264 = v548;
    *cell280 = v550;
    /* the port's tail, :2941-2943: the output is the cell added to itself. It
     * is written that way rather than as `2.0f *` because that is what the
     * binary does, and for a denormal the two are not the same. */
    *outL = v548 + v548;
    *outR = v550 + v550;
}

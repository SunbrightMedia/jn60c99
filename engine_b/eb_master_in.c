/* eb_master_in.c — see eb_master_in.h.
 *
 * The expression shapes below are the port's, parenthesis for parenthesis. The
 * decompile's `(float)(...)` casts mark where the original rounded a single-
 * precision intermediate, so they decide the result and are kept as explicit
 * float temporaries rather than collapsed. Built with -ffp-contract=off like
 * the rest of the engine: the reference is x86 SSE2 with no fused multiply-add.
 */
#include "eb_master_in.h"

void eb_master_in_tick(eb_master_in_state *s, const eb_master_in_coef *c,
                       const float *voice, float fb84672, float fb84704,
                       float *out36, float *out38, float *out32)
{
    float v8, v13, v18, v24;
    float v5, v9, v11, v14, v16, v19, v21, v25, v26, v27, v28, v29, v30;
    float v31, v32, v33, v34, v35, v37;

    /* the four pair sums, in the port's order */
    v8  = voice[1] + voice[0];
    v13 = voice[3] + voice[2];
    v18 = voice[5] + voice[4];
    v24 = voice[7] + voice[6];

    v5  = c->k84496;
    v9  = c->k84544;
    v14 = c->k84560;
    v19 = fb84704;
    v29 = fb84672;

    v11 = v8  * c->k84448;
    v16 = v13 * c->k84464;
    v21 = v18 * c->k84480;

    /* THE READ COMES BEFORE THE WRITE. The port reads 84768 at :850 and writes
     * it at :872, so v26 uses LAST sample's one-pole output. Updating the state
     * first would use this sample's and is the one-sample-skew shape this
     * project has had to fix more than once. */
    v25 = s->s84768;
    v26 = v25 * c->k84816;

    v27 = v21 + (float)(v24 * v5);
    v28 = v19 * v14;
    v30 = v29 * v14;

    v31 = (float)((float)(v16 + v11) + v27) * c->k84512;
    v32 = (float)(v31 * c->k84640) + c->k84656;
    s->s84768 = v32;                                   /* the port's :872 */

    v33 = v26 + (float)(v32 * c->k84800);
    v34 = c->k101072;
    v35 = (float)((float)(v30 * v9) - (float)(v9 * v33)) + v33;
    v37 = (float)((float)(v28 * v9) - (float)(v9 * v33)) + v33;

    *out36 = v34 * v35;
    *out38 = v34 * v37;
    *out32 = v32;
}

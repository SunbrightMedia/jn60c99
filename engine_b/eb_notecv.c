/* eb_notecv.c — see eb_notecv.h. A transcription of src/voice_render.c:595-656.
 *
 * The LFSR's bit ladder and its goto structure are the decompiler's and are
 * kept: the sign-extension games (v13 = v9 & 0xFFFFFF, v17 = v9 | 0xFF000000,
 * selected on bit 24) ARE the generator, and rewriting them into something
 * tidier is precisely the class of edit this project has been caught by.
 */
#include "eb_notecv.h"

float eb_notecv_tick(eb_notecv_state *s, const eb_notecv_coef *c)
{
    float v5, v6, v7, v18, v20, v21, v22, v24;
    int v8, v9, v10, v13, v15, v17;

    v5 = s->n84336;
    v6 = c->n84272;
    v7 = c->n84304;
    v8 = (int)(float)(v5 * -16777216.0f);
    if (!v8) {
        v9 = 1;
        goto LABEL_11;
    }
    v10 = v8 & 0x200000;
    if ((v8 & 0x800000) != 0) {
        if (!v10) {
            v9 = 2 * v8;
            goto LABEL_11;
        }
    } else if (v10) {
        v9 = 2 * v8;
        goto LABEL_11;
    }
    v9 = 2 * v8 + 1;
LABEL_11:
    v13 = v9 & 0xFFFFFF;
    v15 = v9;
    v17 = v9 | 0xFF000000;
    v18 = v6 * v7;
    if ((v15 & 0x1000000) == 0)
        v17 = v13;
    v20 = (float)v17 * 0.000000059604645f;
    s->n84336 = v20;
    v21 = (float)(v20 * c->n84400) + c->n84416;
    s->n84368 = v21;
    v22 = v18 - (float)(v7 * v21);
    v24 = v22 + v21;
    return v24;
}

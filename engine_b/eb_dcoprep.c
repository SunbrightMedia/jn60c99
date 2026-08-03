/* eb_dcoprep.c — see eb_dcoprep.h. A transcription of
 * src/voice_render.c:1702-1717 with the port's variable numbers kept. */
#include "eb_dcoprep.h"
#include <math.h>

float eb_dcoprep_tick(const eb_dcoprep_coef *c, float pitch, float pwmcv,
                      float in3808,
                      float *out4800, float *out4816, float *out5456)
{
    float v395 = pwmcv + c->k6304;
    float v396 = pitch * c->k5536;
    float v397 = c->k5520;
    float v398 = fmaxf(c->k5568, v396);
    float v399 = (float)(v395 * c->k6320) + c->k6288;
    float v400;

    *out4816 = v397 + in3808;
    if (v399 <= 0.0f)
        v400 = 0.0f;
    else
        v400 = v399;
    *out4800 = 0.00390625f / v398;
    *out5456 = v400;
    return v398;
}

/* eb_noisemix.c — see eb_noisemix.h. A transcription of
 * src/voice_render.c:1141-1149 with the port's variable numbers kept. */
#include "eb_noisemix.h"

float eb_noisemix_tick(const eb_noisemix_coef *c, float nsv4320,
                       float in3536)
{
    float v197 = c->k6448;
    float v198 = v197 * in3536;
    float v199 = c->k6416 * nsv4320;
    return (float)(v199 * c->k6528) + (float)(v198 * c->k6512);
}

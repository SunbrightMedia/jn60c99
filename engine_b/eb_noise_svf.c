/* eb_noise_svf.c — see eb_noise_svf.h. The order below is the port's, term for
 * term; a regrouping is a different float. */
#include "eb_noise_svf.h"

float eb_nsvf_tick(eb_nsvf_state *s, const eb_nsvf_coef *c,
                   float x, float *s04_out)
{
    /* :1130 — cell 4320 takes 4304's OLD value before anything reads 4320, so
     * 4320 carries nothing between samples. */
    float v191 = s->s88;
    float t4320 = s->s04;
    float v192 = (v191 * c->k36) + t4320;
    float v193 = (v191 * c->k52) + v192;
    float v194 = v192 * c->k00;
    float v195 = x - v193;
    float v196 = (v195 * c->k36) + v191;
    float out  = ((v195 * c->k68) + v194) + (v196 * c->k84);

    s->s88 = v196;              /* :1139 cell 4288 */
    s->s04 = v192;              /* :1134 cell 4304 (the :1132 write is dead) */
    *s04_out = v192;
    return out;                 /* :1140 cell 4320 */
}

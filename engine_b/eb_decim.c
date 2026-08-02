/* eb_decim.c — see eb_decim.h for the tap map and the provenance.
 *
 * The only thing worth repeating here: the accumulation order below is the
 * port's, term for term, and it is load-bearing. `((a+b)+c)` and `(a+(b+c))`
 * are different floats. Compiled with -ffp-contract=off, as the whole engine
 * is, because the reference is x86 SSE2 with no fused multiply-add.
 */
#include "eb_decim.h"

float eb_decim_tick(eb_decim_state *s, const eb_decim_coef *c,
                    float s0, float s1, float s2, float s3)
{
    const float *k = c->c;
    unsigned w;
    float v519, v522, v523, v524, v520, v521, v525, v526;

    /* THE SHIFT, replaced by a rotation. The port moves 30 cells per voice per
     * sample so that "k samples ago" lives at a fixed address; the index does
     * the same job and moves nothing. Newest first: step w BACK one, then
     * store, so that h[p][(w + k) & 7] is the k-th newest. */
    /* THE BIQUAD'S STATE ROTATES TOO, at the top of the sample, and it is
     * easy to miss: src/voice_render.c:1701-1702 does cell 5504 <- 5488 and
     * 5488 <- 5472 as part of the same shift block as the delay lines, several
     * hundred lines before the biquad itself runs. Reading the biquad in
     * isolation would give a filter one sample out of step. */
    s->b3 = s->b1;                       /* cell 5504 <- 5488 */
    s->b1 = s->b2;                       /* cell 5488 <- 5472 */

    w = (s->w + 7u) & 7u;
    s->w = w;
    s->h[0][w] = s0;
    s->h[1][w] = s1;
    s->h[2][w] = s2;
    s->h[3][w] = s3;

#define H(p, age) (s->h[(p)][(w + (unsigned)(age)) & 7u])

    /* :2137-2158 — twelve pairs, strictly left-nested, the port's order. */
    v519 = (((((((((((  (H(2,7) + H(1,0)) * k[0]
                      + (H(3,7) + H(0,0)) * k[1])
                      + (H(2,0) + H(1,7)) * k[2])
                      + (H(3,0) + H(0,7)) * k[3])
                      + (H(3,6) + H(0,1)) * k[4])
                      + (H(2,6) + H(1,1)) * k[5])
                      + (H(2,1) + H(1,6)) * k[6])
                      + (H(3,1) + H(0,6)) * k[7])
                      + (H(3,5) + H(0,2)) * k[8])
                      + (H(1,2) + H(2,5)) * k[9])
                      + (H(2,2) + H(1,5)) * k[10])
                      + (H(0,5) + H(3,2)) * k[11]);

    /* :2160-2166 — the biquad's own state is read BEFORE the last four taps
     * are added, exactly as the port reads cell 5488 into v520 there. */
    v520 = s->b1;
    v521 = v520 * c->k6256 + s->b3;

    v522 = ((v519 + (H(3,4) + H(0,3)) * k[12])
                  + (H(2,4) + H(1,3)) * k[13])
                  + (H(2,3) + H(1,4)) * k[14];
    v523 =          (H(3,3) + H(0,4)) * k[15];

    s->b1 = v521;
    v524 = v522 + v523;
    v525 = v524 - (v520 * c->k6272 + v521);
    s->b2 = v525 * c->k6256 + v520;
    v526 = ((v521 - v525 * c->k5456) * c->k6336 - c->k6336 * v524) + v524;

#undef H
    return v526;
}

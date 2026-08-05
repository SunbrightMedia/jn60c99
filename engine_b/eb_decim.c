/* eb_decim.c — see eb_decim.h for the tap map and the provenance.
 *
 * The only thing worth repeating here: the accumulation order below is the
 * port's, term for term, and it is load-bearing. `((a+b)+c)` and `(a+(b+c))`
 * are different floats. Compiled with -ffp-contract=off, as the whole engine
 * is, because the reference is x86 SSE2 with no fused multiply-add.
 */
#include "eb_decim.h"
#include "eb_fork_config.h"
#if EB_HALF_OS
#include "eb_halfos_fir.h"
#endif

#if EB_HALF_OS
/* HALF-OVERSAMPLING DECIMATOR (EB_HALF_OS=1). Two sub-samples in, one out,
 * through the DESIGNED 24-tap symmetric FIR whose in-band magnitude matches
 * the port's own 4x FIR to 0.078 dB over 20 Hz..16 kHz (see
 * tools/engineb/gen_halfos_fir.py, which MEASURES the 4x reference by
 * executing the code below rather than reading its tap order off a comment).
 *
 * The biquad tail is the port's, byte for byte, including the state rotation
 * at the top and the k5456 feedback term -- only the FIR changes. That is
 * deliberate: the biquad is rate-dependent recall data and reproducing it is
 * free, so the half-OS relaxation stays confined to the one thing it must
 * touch.
 *
 * The ring holds 2x samples newest-first; `w` counts down like the 4x path's.
 */
float eb_decim_tick(eb_decim_state *s, const eb_decim_coef *c, float k5456,
                    float s0, float s1, float s2, float s3)
{
    unsigned w;
    float v519, v520, v521, v524, v525, v526;
    int t;

    (void)s2; (void)s3;                 /* not produced when EB_DCO_SUBSTEPS==2 */

    s->b3 = s->b1;
    s->b1 = s->b2;

    /* PUSH, into a DOUBLE-WRITTEN linear buffer rather than a masked ring.
     * Each sub-sample is stored twice, at wb and wb+32, so the newest 24
     * samples are always CONTIGUOUS and the tap loop walks two plain
     * pointers with no index masking. That is worth measuring rather than
     * asserting: the masked-ring form cost 176 executed Xtensa instructions
     * against the 4x path's 151, i.e. the "half" decimator was MORE
     * expensive than the one it replaces. This form is what makes the line
     * a saving instead of a cost. */
    s->hb[s->wb] = s0; s->hb[s->wb + EB_HALFOS_RING] = s0;
    s->wb = (s->wb + 1u) & (EB_HALFOS_RING - 1u);
    s->hb[s->wb] = s1; s->hb[s->wb + EB_HALFOS_RING] = s1;
    w = s->wb + EB_HALFOS_RING;         /* absolute index of the newest */
    s->wb = (s->wb + 1u) & (EB_HALFOS_RING - 1u);

    /* FOLDED, and the fold is not an optimisation invented here: the port's
     * own 4x FIR is written as sixteen (a+b)*k pairs for exactly this reason.
     * The designed FIR is symmetric by construction (gen_halfos_fir.py builds
     * it from the half-length cosine basis), so a[t] == a[N-1-t] holds
     * exactly, not approximately.
     *
     * (a*k + b*k) -> (a+b)*k is a DIFFERENT float, and in the trunk that
     * would be forbidden. Here it is the fork, whose standard is gate 1 and
     * gate 2, and both are re-run after this. */
    {
        const float *a = s->hb + w;                          /* walks down */
        const float *b = s->hb + w - (EB_HALFOS_FIR_TAPS - 1);  /* walks up */
        v519 = 0.0f;
        /* UNROLLED, because it was MEASURED: the rolled loop costs 166
         * executed Xtensa instructions and the 4x path it replaces costs
         * 151. Three of the ten instructions in the loop body are pointer
         * arithmetic; unrolling turns them into constant offsets. A "half"
         * decimator that is slower than the whole one is not a saving, and
         * the only way to know which it is, is to count. */
#if defined(__GNUC__)
#pragma GCC unroll 12
#endif
        for (t = 0; t < EB_HALFOS_FIR_TAPS / 2; ++t)
            v519 += (a[-t] + b[t]) * eb_halfos_fir[t];
    }
    v524 = v519;

    v520 = s->b1;
    v521 = v520 * c->k6256 + s->b3;
    s->b1 = v521;
    v525 = v524 - (v520 * c->k6272 + v521);
    s->b2 = v525 * c->k6256 + v520;
    v526 = ((v521 - v525 * k5456) * c->k6336 - c->k6336 * v524) + v524;
    return v526;
}
#else
float eb_decim_tick(eb_decim_state *s, const eb_decim_coef *c, float k5456,
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
    v526 = ((v521 - v525 * k5456) * c->k6336 - c->k6336 * v524) + v524;

#undef H
    return v526;
}
#endif  /* EB_HALF_OS */

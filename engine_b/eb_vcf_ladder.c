/* eb_vcf_ladder.c — the 4-pole ladder core. See eb_vcf_ladder.h for the
 * topology, the provenance and the list of what is changed.
 *
 * EVALUATION ORDER IS THE SPECIFICATION. The build is -ffp-contract=off and the
 * reference is x86 SSE2 single precision, so an algebraically equal regrouping
 * is a DIFFERENT NUMBER. Every parenthesis below is the source's own. Three
 * regroupings that look free and are not, and are therefore NOT taken here:
 *     1 - (G+G)                 is not      1 - 2*G
 *     x + ((((x*x)*x)*x)*(x*K)) is not      x*(1 + K*(x*x)*(x*x))
 *     1/(((G*G)*(G*G))*k + 1)   is not      a reciprocal approximation
 * The third is called out by docs/trackb/VCF.md §3.8 and is the one that would
 * be tempting on a divider-less FPU: the ESP32-S3 has no FP divide, so this
 * division is a soft-float call, and it is measured rather than avoided.
 */
#include "eb_vcf_ladder.h"

/* ------------------------------------------------------------- wrap24
 * Verbatim from src/juno_dsp.c:20-45 (0x180368D60). Copied rather than called
 * so the module is self-contained on a target that does not link the port.
 * The bit fiddling IS the algorithm and is not re-expressed as a formula; the
 * copy is byte-for-byte, and engine_b/tests/test_vcf_wrap24.c compares the two
 * over ALL 2^32 float bit patterns because this project has already been bitten
 * once by an "obviously identical" wrap replacement (eb_triangle, 8,388,608
 * disagreements out of 2^32, rounding alone).
 */
static float eb_wrap24(float x)
{
    int v1 = (int)(x * 16777216.0f);
    int v2, v5, v6;
    if (v1 == 0) {
        v2 = 1;
    } else {
        int v3 = v1 & 0x200000;
        if ((v1 & 0x800000) != 0)
            v2 = (v3 == 0) ? 2 * v1 : 2 * v1 + 1;
        else
            v2 = (v3 != 0) ? 2 * v1 : 2 * v1 + 1;
    }
    v5 = v2 & 0xFFFFFF;
    v6 = v2 | (int)0xFF000000;
    if ((v2 & 0x1000000) == 0)
        v6 = v5;
    return (float)v6 * 5.960464477539063e-08f;
}

void eb_vcf_reset(eb_vcf_state *st)
{
    int i;
    st->nl = st->y1 = st->y2 = st->y3 = st->y4 = 0.0f;
    st->s1 = st->s2 = 0.0f;
    st->drive_prev = 0.0f;
    st->dith = 0.0f;
    for (i = 0; i < 32; ++i) st->h[i] = 0.0f;
    st->hi = 31;
}

float eb_vcf_hist_get(const eb_vcf_state *st, int i)
{
    return st->h[(st->hi - i) & 31];
}

void eb_vcf_hist_set(eb_vcf_state *st, int i, float v)
{
    st->h[(st->hi - i) & 31] = v;
}

/* ---------------------------------------------------------- one sub-step
 * READ src/voice_render.c:1355-1384 (sub-step 1); :1388-1419, :1424-1454 and
 * :1458-1488 are the same shape, and the only textual differences are the
 * commutations listed in eb_vcf_ladder.h item 2.
 *
 * `ins` is the interpolated input ALREADY multiplied by R = 1/(1+k*G^4).
 * Returns the 24 dB tap; leaves the pipeline advanced.
 */
static float eb_vcf_substep(eb_vcf_state *st, const eb_vcf_coef *c,
                            float ins, float G, float A, float Rk)
{
    float x, nl, y1, y2, y3, y4, t, p2, S;
    float xz = st->nl, y1z = st->y1, y2z = st->y2, y3z = st->y3, y4z = st->y4;

    /* ZDF resolution of the resonance feedback. [9536] is 0.0, so the second
     * term contributes nothing -- and it is still MULTIPLIED, because 0*inf and
     * 0*NaN are not nothing. :1355-1357 */
    x = ins - (((st->s1 * c->c9520) + (st->s2 * c->c9536)) * Rk);

    /* hard clip, NaN -> -1.0 (the >= test fails on NaN). :1358-1361 */
    if (x >= -1.0f) { if (x > 1.0f) x = 1.0f; }
    else            { x = -1.0f; }

    /* the saturation curve. :1362 */
    nl = x + ((((x * x) * x) * x) * (x * c->c9184));

    /* four cascaded bilinear one-poles. :1365-1375 */
    y1 = (G * (nl + xz)) + (y1z * A);
    t  = G * (y1 + y1z);
    p2 = G * (((G * nl) + (A * y1)) + y1);      /* stage-2, one step ahead */
    y2 = t + (y2z * A);
    y3 = (G * (y2 + y2z)) + (y3z * A);
    y4 = ((y3z + y3) * G) + (A * y4z);

    /* zero-input response of the whole chain one sub-step ahead. :1377-1381 */
    S  = (G * (((G * ((p2 + (A * y2)) + y2)) + (A * y3)) + y3)) + (A * y4);

    st->nl = nl; st->y1 = y1; st->y2 = y2; st->y3 = y3; st->y4 = y4;
    st->s2 = st->s1; st->s1 = S;

    /* :1382-1384 */
    return ((y3 * c->c9088) + (y4 * c->c9104)) + (c->c9072 * y2);
}

float eb_vcf_tick(eb_vcf_state *st, const eb_vcf_coef *c,
                  float in, float G, float k)
{
    float A, R, Rk, d, drive, prev, acc;
    float *h = st->h;
    int hi = st->hi;
    int j;

    /* --------------------------------------------------- the input node
     * :1340-1349. The dither is a free-running 24-bit wrap oscillator that
     * never reads the audio; the port's [8992] shadow of it is dropped.      */
    d     = st->dith;
    drive = (((k * c->c9168) + 1.0f) * (in * c->c9136)) + ((-d) * c->c9120);
    st->dith = eb_wrap24(-d);
    prev  = st->drive_prev;
    st->drive_prev = drive;

    A  = 1.0f - (G + G);                                        /* :1344 */
    R  = 1.0f / ((((G * G) * (G * G)) * k) + 1.0f);             /* :1345 */
    Rk = R * k;                                                 /* :1349 */

    /* ------------------------------------- four sub-steps, 4x oversampled
     * The input interpolation weights are the port's own cells, applied in the
     * port's own order (:1350-1352, :1386, :1421, :1456).                    */
    hi = (hi + 1) & 31;
    h[hi] = eb_vcf_substep(st, c, ((prev * c->c9216) + (drive * c->c9232)) * R,
                           G, A, Rk);
    hi = (hi + 1) & 31;
    h[hi] = eb_vcf_substep(st, c, ((prev + drive) * c->c9248) * R,
                           G, A, Rk);
    hi = (hi + 1) & 31;
    h[hi] = eb_vcf_substep(st, c, ((prev * c->c9232) + (drive * c->c9216)) * R,
                           G, A, Rk);
    hi = (hi + 1) & 31;
    h[hi] = eb_vcf_substep(st, c, (drive * c->c9200) * R,
                           G, A, Rk);
    st->hi = hi;

    /* ------------------------------------------------------- decimator
     * :1489-1513. A symmetric 32-tap FIR folded into 16 coefficients,
     * accumulated CENTRE PAIR FIRST and outward -- which is the port's own
     * association order, not a choice made here. The port's spelling of the
     * same sum interleaves four 8-cell lines; the mapping (line, slot) ->
     * 4x delay is  A/B/C/D = delay 0/1/2/3 mod 4, slot = delay/4, which is why
     * this is one ring and not four.                                        */
    acc = (h[(hi - 15) & 31] + h[(hi - 16) & 31]) * c->fir[0];
    for (j = 1; j < 16; ++j)
        acc += (h[(hi - (15 - j)) & 31] + h[(hi - (16 + j)) & 31]) * c->fir[j];

    return acc * c->c9152;                                      /* :1513 */
}

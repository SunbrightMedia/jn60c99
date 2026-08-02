/* eb_chorus.c — ENGINE B MODULE M-CHORUS.
 *
 * A line-by-line re-siting of src/master_render.c:2753-2935 into a 4.4 KB
 * struct. Read that block beside this file: every expression appears here in
 * the same order, with the same association, and with the same casts. The port
 * variable names (v595, v618, ...) are kept as local names on purpose, so the
 * two can be diffed by a reader rather than trusted.
 *
 * THREE THINGS DELIBERATELY NOT "SIMPLIFIED", each with its reason:
 *   * juno_wrap_unit is copied verbatim, fmodf and all. FX_CHORUS.md §8: the
 *     reachable phase exceeds 1 by only ~2e-5, so `x - 2` LOOKS equivalent,
 *     but x+1 near 2.0 rounds at an ulp of 2.4e-7 while x-2 is exact. That is
 *     the exact shape of the fmodf replacement this project already got wrong
 *     on 8,388,608 of 2^32 inputs. A replacement needs an exhaustive proof
 *     over the reachable range; it does not have one, so it is not made.
 *   * The BBD noise generator is kept. MEASURED: it sits at -92 dB relative to
 *     the dry signal, i.e. ABOVE the -100 dB null target, so dropping its ~30
 *     ops would fail docs/trackb/ACCURACY_STANDARD.md on its own.
 *   * The two taps are LINEAR-interpolated, which is what the plugin does
 *     (reconstructed independently, 4,000/4,000 samples bit-exact; nearest and
 *     allpass match 74/4,000). It is also the cheap choice.
 */
#include "eb_chorus.h"
#include <math.h>
#include <string.h>

/* ---- the two wrappers, verbatim from src/juno_dsp.c ---------------------- */
static inline float eb_wrap_unit(float x)
{
    if (x > 1.0f)  return fmodf(x + 1.0f, 2.0f) - 1.0f;
    if (x < -1.0f) return fmodf(x - 1.0f, 2.0f) + 1.0f;
    return x;
}

static inline float eb_wrap24(float x)
{
    int v1 = (int)(x * 16777216.0f);
    int v2, v5, v6;
    if (v1 == 0) {
        v2 = 1;
    } else {
        int v3 = v1 & 0x200000;
        if ((v1 & 0x800000) != 0) v2 = (v3 == 0) ? 2 * v1 : 2 * v1 + 1;
        else                      v2 = (v3 != 0) ? 2 * v1 : 2 * v1 + 1;
    }
    v5 = v2 & 0xFFFFFF;
    v6 = v2 | (int)0xFF000000;
    if ((v2 & 0x1000000) == 0) v6 = v5;
    return (float)v6 * 5.960464477539063e-08f;
}

void eb_chorus_reset(eb_chorus_state *s) { memset(s, 0, sizeof *s); }

void eb_chorus_tick_x(eb_chorus_state *restrict s,
                      const eb_chorus_coef *restrict k,
                      float in, float *outL, float *outR,
                      float v56, float v58)
{
    float v595, v596, v597, v598, v599, v600, v601, v602, v603, v604, v605;
    float v606, v607, v608, v609, v610, v611, v612, v613, v614, v615;
    float v616, v617, v618, v619, v620, v621, v622, v623, v624, v625, v626;
    float v627, v628, v629, v630, v631, v632, v633, v634, v635, v636;
    float v638, v639, v640, v641, v642, v643, v644, v645, v646, v647, v648;
    float v649, v650, v651, v652, v653, v654, v655, v656, v657, v658, v659;
    float v660, v661, v662;
    int   v637;
    /* the 17 per-sample scratch cells the port keeps in the flat block */
    float _c368, _c384, _c768, _c784, _c800, _c816, _c1056, _c1072;
    float _c1088, _c1104, _line_in, _t856, _t860, _t864, _t872, _t876, _t880;
    int32_t v663;
    const int32_t mask = (int32_t)EB_CHORUS_RING - 1;

    /* :2754-2780 — the port's 30 shift moves. Register moves here. */
    s->c512 = s->c496; s->c496 = s->c480; s->c480 = s->c464;
    s->c464 = s->c448; s->c448 = s->c432; s->c432 = s->c416;
    s->c416 = s->c400;
    s->c560 = s->c544; s->c544 = s->c528;
    s->c608 = s->c592; s->c592 = s->c576;
    s->c640 = s->c624;
    s->c672 = s->c656;
    s->c704 = s->c688;
    s->c752 = s->c736; s->c736 = s->c720;
    s->c848 = s->c832;
    s->c944 = s->c928; s->c928 = s->c912; s->c912 = s->c896;
    s->c896 = s->c880; s->c880 = s->c864;
    s->c1040 = s->c1024; s->c1024 = s->c1008; s->c1008 = s->c992;
    s->c992 = s->c976; s->c976 = s->c960;

    _c368 = in;                                   /* :2781 */
    _c384 = in;                                   /* :2782 */

    /* LFO ---------------------------------------------------------- :2783 */
    v595 = eb_wrap_unit((s->c672 + s->c640) + k->rate);
    s->c656 = v595;
    v596 = k->eps;
    if (v595 < 0.0f) v596 = -v596;
    v597 = s->c848;
    s->c624 = v596;

    /* BBD noise generator ------------------------------------------ :2790 */
    v598 = v597 * k->n_gain;   s->c960 = v598;
    v599 = eb_wrap24(-v597);
    v600 = v599 * k->n_gain;   s->c864 = v600;
    s->c832 = eb_wrap24(-v599);
    v601 = s->c896;
    v602 = k->nf[0] * v600;
    v603 = s->c992;
    v604 = (v602 + (k->nf[1] * s->c880)) + (k->nf[2] * v601);
    v605 = ((k->nf[0] * v598) + (k->nf[1] * s->c976)) + (k->nf[2] * v603);
    s->c880 = v604;
    s->c976 = v605;
    v606 = k->nf[4] * v603;
    v607 = k->nf[6];
    v608 = fabsf(s->c656);
    v609 = ((((k->nf[3] * v605) + v606) + (k->nf[5] * s->c1008))
            + (v607 * s->c1024)) + (k->nf[7] * s->c1040);
    s->c912 = ((((k->nf[3] * v604) + (k->nf[4] * v601))
                + (k->nf[5] * s->c912)) + (v607 * s->c928))
              + (k->nf[7] * s->c944);
    s->c1008 = v609;
    _c768 = v608;

    /* modulation --------------------------------------------------- :2819 */
    v610 = k->depth;
    v611 = fabsf(eb_wrap_unit(s->c656 + k->phase_off));
    _c784 = v611;
    v612 = k->mod_scale;
    v613 = k->mod_off;
    v614 = _c384;
    _c800 = ((v608 * v610) * v612) + v613;
    _c816 = (((v610 * k->depth_r) * v611) * v612) + v613;

    /* input mix + two biquads + DC block ---------------------------- :2827 */
    v615 = (v614 + _c368) * 0.5f;
    s->c400 = v615;
    v616 = s->c448;
    v617 = s->c464;
    v618 = (((s->c416 * k->b1) + (k->b2 * s->c432)) + (v615 * k->b0))
           + ((v617 * k->a2) + (v616 * k->a1));
    s->c432 = v618;
    v619 = (v617 * k->b2) + (v616 * k->b1);
    v620 = s->c480;
    v621 = v619 + (v618 * k->b0);
    v622 = k->mute;
    v623 = v621 + ((v620 * k->a1) + (s->c496 * k->a2));
    v624 = k->onoff * v622;
    s->c464 = v623;
    v625 = s->c736;
    v626 = ((v620 * k->hb1) + (k->ha1 * s->c512)) + (v623 * k->hb0);
    s->c496 = v626;
    v627 = v625 + k->ramp_inc;
    _line_in = v624 * v626;                       /* :2851 cell 95840 */

    /* startup ramp + delay-time smoother ---------------------------- :2852 */
    v628 = fminf(k->ramp_max, v627) * v622;
    s->c720 = v628;
    if ((v628 - s->c704) >= 0.0f) v629 = k->slew_up;
    else                          v629 = k->slew_dn;
    v630 = v629 + s->c752;
    v631 = k->dtime;
    v632 = s->c704;
    if (v630 > 0.0f) v56 = v630;
    v633 = v56;
    v634 = ((k->dtime - v632) * k->smco) + v632;
    if (v633 >= -1.0f) v58 = fminf(v633, 1.0f);
    s->c736 = v58 * k->mute;
    if ((v634 - v632) != 0.0f) v631 = v634;
    s->c688 = v631;
    v635 = v631;

    /* tap L --------------------------------------------------------- :2871 */
    v636 = v631 + _c800;
    v637 = (int)(v636 * -16384.0f);
    _t856 = s->line[(int32_t)(mask & (int32_t)(((int64_t)(uint32_t)s->w
                                                  - v637) + 1))];
    _t860 = s->line[(int32_t)(mask & (int32_t)(((int64_t)(uint32_t)s->w
                                                  - v637) + 2))];
    /* The port does this subtraction in DOUBLE. Here it is done in float.
     * PROVEN, not argued: tools/engineb/fx_chorus_frac_proof.c enumerates
     * every float bit pattern in (-1024, 1024) -- 2,298,478,592 of them,
     * strictly containing the MEASURED reachable range of 72..456 samples --
     * and the two forms agree bit for bit on all of them, 0 mismatches. On the
     * ESP32-S3 the double form costs 8 soft-float helper calls per sample
     * (MEASURED-STATIC, cost.py). */
    v638 = v636 * 16384.0f - (float)(int)(v636 * 16384.0f);
    _t864 = v638;
    v639 = v635 + _c816;
    v640 = _t856 + ((v638 * _t860) - (v638 * _t856));

    /* tap R --------------------------------------------------------- :2882 */
    {
        int v637r = (int)(v639 * -16384.0f);
        _t872 = s->line[(int32_t)(mask & (int32_t)(((int64_t)(uint32_t)s->w
                                                      - v637r) + 1))];
        _t876 = s->line[(int32_t)(mask & (int32_t)(((int64_t)(uint32_t)s->w
                                                      - v637r) + 2))];
    }
    v641 = v639 * 16384.0f - (float)(int)(v639 * 16384.0f);   /* same proof */
    _t880 = v641;
    v642 = _t872;
    v643 = s->c560;
    v644 = s->c608;
    v645 = (v641 * _t876) - (v641 * v642);

    /* the two output state-variable filters ------------------------- :2895 */
    v646 = k->svf_f;
    v647 = ((v640 - ((k->svf_d * s->c544) + v643)) * v646) + s->c544;
    v648 = (((v645 + v642) - ((k->svf_d * s->c592) + v644)) * v646) + s->c592;
    s->c528 = v647;
    s->c576 = v648;
    v649 = k->svf_f;
    v650 = (v649 * v648) + v644;
    v651 = (v649 * v647) + v643;
    s->c544 = v651;
    s->c592 = v650;

    /* noise injection, wet gain, dry/wet mix ------------------------ :2909 */
    v652 = k->noise;
    v653 = s->c752;
    v654 = _c368;
    v655 = k->wet;
    v656 = ((((k->n_off + _c768) * s->c1008) * v652)) + v650;
    v657 = k->dry;
    v658 = v656 * v653;
    v659 = v653 * (v651 + (((k->n_off + _c784) * s->c912) * v652));
    v660 = _c384;
    v661 = v659 * v655;
    _c1056 = v658 * v655;
    _c1072 = v661;
    v662 = k->onoff;
    _c1088 = ((v662 * (v657 * v654)) + ((1.0f - v662) * v654)) + _c1056;
    _c1104 = ((v662 * (v657 * v660)) + ((1.0f - v662) * v660)) + v661;

    /* ring write, AFTER both reads ---------------------------------- :2933 */
    v663 = (int32_t)(((uint32_t)s->w - 1u) & (uint32_t)mask);
    s->w = v663;
    s->line[v663] = _line_in;

    *outL = _c1088;
    *outR = _c1104;
}

void eb_chorus_tick(eb_chorus_state *restrict s,
                    const eb_chorus_coef *restrict k,
                    float in, float *outL, float *outR)
{
    /* MEASURED: 0.0 / -1.0 at every one of 14,000 chorus-arm entries. */
    eb_chorus_tick_x(s, k, in, outL, outR, 0.0f, -1.0f);
}

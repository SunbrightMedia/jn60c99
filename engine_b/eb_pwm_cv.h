/* eb_pwm_cv.h — ENGINE B MODULE M-MODCV: the pitch / PWM modulation CV block.
 *
 * SCOPE. This module owns src/voice_render.c:1076-1128 and nothing else: the
 * mod ROUTER (the latches of the pitch CV, the keyboard CV, the two envelope
 * outputs and the bend source), the PITCH MODULATION SUM (port cell [3776],
 * consumed by the DCO at :1641 and :1666) and the PULSE-WIDTH MODULATION SUM
 * (port cell [3808], consumed at :1711 as [4816] = DutyTune + [3808]).
 * The LFO that produces [1792]/[1808], the envelopes that produce [2752]/
 * [3232] and the keyboard CV [752]/[880] are OTHER modules and are consumed
 * here as arguments.
 *
 * PROVENANCE. Every equation is READ from src/voice_render.c:1076-1128, line by
 * line, and cross-checked against docs/trackb/MOD.md §3.9 and §3.10. The
 * blueprint agrees with the oracle on all of the arithmetic in this range; the
 * one place where it needs correcting is a CLASSIFICATION, not a formula, and
 * it is recorded in eb_pwm_cv.c (the "[3744] mod-wheel term" is not a wheel
 * term at all — it is the UNDELAYED LFO fed through the same two gains that
 * feed the PWM sum).
 *
 * CONTROL-RATE OR NOT? MEASURED, not assumed: of the 27 cells this range reads,
 * 23 have no writer anywhere in src/voice_render.c and change only on a patch
 * recall. Only FOUR are per-sample signals — [752] (pitch CV), [880] (keyboard
 * CV), [1792]/[1808] (LFO, delayed and undelayed) — plus the two envelope
 * outputs [2752]/[3232]. So the block is a per-SAMPLE mixer of six live signals
 * with a large constant fringe, and the constant fringe is what engine B hoists.
 *
 * WHAT ENGINE B CHANGES, and why each change is EXACT rather than approximate:
 *   1. The bend term [3760] is computed ONCE at recall instead of every sample.
 *      Its formula ((c3856*[3680]) - (c4112*c3856) + c4112) * c4128 reads only
 *      recall-constant cells ([3680] is a same-sample copy of [3552], which has
 *      no writer in the render at all), so the per-sample recomputation is a
 *      loop invariant. Its product with c3872, as it enters the pitch sum, is
 *      hoisted with it: same two operands, same single rounding.
 *   2. The dead stores are dropped. GREPPED over src/ and gui/: [3568], [3616],
 *      [3632], [3696] and [3824] have no reader outside the block that writes
 *      them ([3616] feeds only [3632], and [3632] feeds nothing), so the whole
 *      v188 chain at :1116/:1124 is dead arithmetic. Dropping a store nothing
 *      reads cannot change audio — but it DOES break state-cell parity, so this
 *      is a sonic-identity claim and not a bit-exact-state one, the same
 *      standing modules M7 and M-VCF already have.
 *   3. The remaining latches ([3648], [3664], [3680], [3712], [3744]) become
 *      registers. They are same-sample copies read a few lines later; a copy is
 *      not arithmetic and deleting it cannot change a number.
 *   4. The four STAGING copies at :1115 and :1125-1128 ([3792]=[3840],
 *      [4240]=[4192], [4256]=[4208], [4272]=[4224]) are bit copies of
 *      recall-constant cells into cells read at :1664 and :1667-1669. In engine
 *      B the consumer reads the source, so they do not exist; the shim still
 *      performs them because its consumer is the port's own code.
 *   5. [3536] is a genuine ONE-SAMPLE DELAY of [3520] (the port writes [3520] at
 *      :2174, AFTER this block), read at :1144. MOD.md §3.9 flags it as a
 *      boundary cell "not MOD-owned"; it is kept here because it lies inside the
 *      range, and it is the module's ONLY state: one float.
 * There is no approximation in this module. The null is expected to be EXACTLY
 * 0, and anything else is a defect, not a budget.
 *
 * SIZE. eb_modcv_state is 4 bytes per voice. eb_modcv_coef is 68 bytes and is
 * SHARED by every voice playing the patch (nothing in it is per-voice), so it
 * costs the voice budget nothing.
 */
#ifndef ENGINEB_EB_PWM_CV_H
#define ENGINEB_EB_PWM_CV_H

/* ---------------------------------------------------------------- state */
typedef struct {
    float z_pitch;   /* one-sample delay of the port's [3520] -> [3536]     */
} eb_modcv_state;

/* ---------------------------------------------------------- coefficients
 * Rebuilt on a parameter change only. Field names are the port cell numbers
 * plus the role READ from MOD.md; where a role name would be a guess the cell
 * number is the name.
 */
typedef struct {
    /* keyboard / pitch CV mix (both 1.0 in every patch READ so far)        */
    float k_pcv;        /* [3584] weight of [752]                          */
    float k_kbd;        /* [3600] weight of [880]                          */
    /* LFO path                                                            */
    float lfo_gain;     /* [4016] common LFO gain, both arms               */
    float pitch_lfo;    /* [4032] LFO -> pitch depth                       */
    float pitch_lfo_out;/* [4048] pitch-sum weight of the LFO arm          */
    float pwmarm_a;     /* [3984]                                          */
    float pwmarm_b;     /* [4000]  -> [3744], the UNDELAYED-LFO term       */
    /* envelope -> pitch                                                   */
    float env1_pitch;   /* [4064]                                          */
    float env2_pitch;   /* [4080]                                          */
    float envmix_pitch; /* [4096]                                          */
    /* pitch sum offsets                                                   */
    float pitch_off1;   /* [3952]                                          */
    float pitch_off2;   /* [3968]                                          */
    /* PWM sum                                                             */
    float pwm_lfo;      /* [4160]                                          */
    float pwm_manual;   /* [4176]                                          */
    float pwm_scale;    /* [3888]                                          */
    float env1_pwm;     /* [3904]                                          */
    float env2_pwm;     /* [3920]                                          */
    float pwm_off;      /* [3936]                                          */
    float out_gain;     /* [4144]                                          */
    /* HOISTED: the bend term [3760] and its pitch-sum contribution.       */
    float bend;         /* == the port's [3760]                            */
    float bend_pitch;   /* == [3872] * [3760], as the sum consumes it      */
} eb_modcv_coef;

/* Build the coefficient set. The arguments are the port's cell VALUES, not
 * patch bytes: the byte->value law belongs to the PARAM module and guessing it
 * here would smuggle an ungated law into a gated module.
 * `c3856`, `c4112`, `c4128`, `c3872` and `modsrc` ([3552]) are consumed only to
 * fold the bend term and are not stored. */
void eb_modcv_set(eb_modcv_coef *c,
                  float c3584, float c3600, float c3856, float c3872,
                  float c3888, float c3904, float c3920, float c3936,
                  float c3952, float c3968, float c3984, float c4000,
                  float c4016, float c4032, float c4048, float c4064,
                  float c4080, float c4096, float c4112, float c4128,
                  float c4144, float c4160, float c4176, float modsrc);

/* One sample. Six live inputs; two live outputs.
 *   pitch_cv  [752]   kbd  [880]
 *   lfo_del   [1792]  lfo_undel [1808]
 *   env1      [2752]  env2 [3232]
 * `*pitch_out` receives [3776], `*pwm_out` receives [3808]. */
void eb_modcv_tick(const eb_modcv_coef *c,
                   float pitch_cv, float kbd, float lfo_del, float lfo_undel,
                   float env1, float env2,
                   float *pitch_out, float *pwm_out);

/* The one-sample latch of the range, kept separate because its input is
 * produced at the END of the voice's sample (port :2174) and its output is
 * consumed at :1144, i.e. it spans the whole voice pass. */
float eb_modcv_tap(eb_modcv_state *s);          /* -> [3536] for this sample */
void  eb_modcv_latch(eb_modcv_state *s, float v3520);

/* Power-on state. The port zeroes [3520]/[3536] in chorus_init.c, so zero is
 * the plugin's own power-on value and not a convenient default. */
void eb_modcv_reset(eb_modcv_state *s);

/* The eight-voice shape, MEASURED cheaper (eb_pwm_cv.c and the commit message):
 * identical arithmetic, identical roundings, with the 21 coefficient loads and
 * the two global LFO arms hoisted out of the per-voice loop. */
void eb_modcv_block(const eb_modcv_coef *c, int nvoices,
                    const float *pitch_cv, const float *kbd,
                    float lfo_del, float lfo_undel,
                    const float *env1, const float *env2,
                    float *pitch_out, float *pwm_out);

#endif /* ENGINEB_EB_PWM_CV_H */

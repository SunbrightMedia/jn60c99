/* eb_master.c — see eb_master.h. The dispatch structure below is the port's,
 * read off src/master_render.c and not inferred from the arm numbering:
 *
 *   if (v39 == 1)          -> the TYPE 1 algorithm, complete           (:890)
 *   else if (v39 <= 1)     -> the shared core, i.e. TYPE 0            (:1055)
 *   else if (v39 <= 3)     -> the TYPE 2/3 algorithm                  (:1271)
 *   else if (v39 == 5)     -> the TYPE 5 algorithm                    (:1459)
 *   else if (v39 == 4)     -> the TYPE 4 algorithm  (NOT TRANSCRIBED) (:1870)
 *   else (v39 >= 6)        -> the shared core again, via goto LABEL_69
 *
 * TYPE 1 DOES NOT FALL THROUGH INTO THE CORE. :1049-1050 is `}` followed by
 * `else`. An earlier reading of this project's had types 0, 1 and >= 6 sharing
 * the core, which would have made the type-1 arm's outputs dead; they are not.
 *
 * The EFFECT dispatch has the same shape around v551:
 *   == 1 -> the e1 arm (:2381) | <= 1 -> LABEL_164 (NOT TRANSCRIBED, :2503)
 *   == 5 -> the e5 arm (:2633) | >= 6 -> LABEL_164 | else (2,3,4) -> chorus
 */
#include "eb_master.h"
#include <string.h>

int eb_master_render(eb_master_state *s, const eb_master_coef *c,
                     const eb_master_rings *r, const float *voices,
                     float *outL, float *outR)
{
    float v36, v38, v32, v176, v177, v56, v58, v529, v530, v593;
    float dL, dR;

    *outL = 0.0f;
    *outR = 0.0f;

    /* No refusals left: task 1b-3 gave DELAY TYPE 4 and the EFFECT LABEL_164
     * core their modules, so every value either dispatch can take is covered. */

    /* ---- 1. the input stage. The feedback pair is LAST sample's. -------- */
    eb_master_in_tick(&s->in, &c->in, voices, s->fb84672, s->fb84704,
                      &v36, &v38, &v32);

    /* ---- 2. the DELAY dispatch ------------------------------------------ */
    v56 = 0.0f;
    v58 = -1.0f;
    if (c->delay_type == 1) {
        s->d1.ring = r->t1;
        eb_dly1_tick(&s->d1, &c->d1, v36, v38, c->in.k84496,
                     &v176, &v177, &v56, &v58);
    } else if (c->delay_type <= 1 || c->delay_type >= 6) {
        /* the shared core, which the port reaches for TYPE 0 and, through
         * `goto LABEL_69`, for anything >= 6. It sets v56/v58 to the constants
         * initialised above -- the port's :1177 and :1182. */
        /* ★ THE CORE'S OUTPUTS ARE CROSSED AND GAINED, and they are the only
         * delay path where that happens outside the module. The port:
         *     cell102320 = ebL;  cell102336 = ebR;
         *     v176 = v418 * cell102336;   <- v176 takes the RIGHT output
         *     v177 = v418 * cell102320;   <- v177 takes the LEFT
         * Passing the core's outputs straight through, as the first version
         * did, swaps the stereo image: MEASURED, the standalone gate showed
         * portL == ebR and portR == ebL exactly, on every sample of every
         * DELAY-TYPE-0 scenario. The four arm modules each end with this same
         * multiply internally, which is why only the core needs it here. */
        eb_delay_process(&c->dcore, &s->dcore, s->route_change, v36, v38,
                         &dL, &dR);
        s->route_change = 0;
        v176 = c->k101744 * dR;
        v177 = c->k101744 * dL;
    } else if (c->delay_type <= 3) {
        s->d23.ring = r->t23;
        eb_dly23_tick(&s->d23, &c->d23, v36, v38, c->in.k84496,
                      &v176, &v177, &v56, &v58);
    } else if (c->delay_type == 4) {
        s->d4.ring0 = r->t4_0; s->d4.ring1 = r->t4_1;
        eb_dly_t4_tick(&s->d4, &c->d4, v36, v38, c->in.k84496,
                       &v176, &v177, &v56, &v58);
    } else {                                        /* delay_type == 5 */
        s->d5.ring0 = r->t5_0; s->d5.ring1 = r->t5_1;
        s->d5.ring2 = r->t5_2; s->d5.ring3 = r->t5_3;
        eb_dly5_tick(&s->d5, &c->d5, v36, v38, c->in.k84496,
                     &v176, &v177, &v56, &v58);
    }

    /* ---- 3. the reverb. It CROSSES its channels; see eb_reverb.h. ------- */
    eb_reverb_process(&c->rev, &s->rev, s->rev_pending, &s->rev_wipe,
                      v176, v177, &v529, &v530);

    /* ---- 4. the output stage. THE SAMPLE IS FINISHED HERE. -------------- */
    {
        /* cells 101264/101280 are the port's pre-doubling pair; the module
         * reports them and the already-doubled output separately. Nothing in
         * engine B reads the cells, so they are discarded here rather than
         * stored -- and named, so the discard is visible. */
        float cell101264, cell101280;
        eb_master_out_tick(&c->out, v529, v530,
                           &cell101264, &cell101280, outL, outR);
        (void)cell101264; (void)cell101280;
    }

    /* ---- 5. the EFFECT dispatch, which feeds the NEXT sample ------------ */
    if (c->effect_type == 0 || c->effect_type >= 6) {
        /* the LABEL_164 core */
        eb_fx_e0_tick(&s->e0, &c->e0, v32, v56, v58, &v56, &v58, &v593);
        s->fb84672 = s->e0.s84672;
    } else if (c->effect_type == 1) {
        eb_fx_e1_tick(&s->e1, &c->e1, v32, v56, v58, &v56, &v58, &v593);
        s->fb84672 = s->e1.s84672;
    } else if (c->effect_type == 5) {
        s->e5.ring = r->e5;
        eb_fx_e5_tick(&s->e5, &c->e5, v32, v56, v58, &v56, &v58, &v593);
        s->fb84672 = s->e5.s84672;
        /* v56/v58 go IN as well as out: the port assigns them only on one
         * branch of this arm, so on the other branch they keep what the DELAY
         * stage left. See eb_fx_e1.h. */
    } else {                                        /* 2, 3, 4 -> chorus */
        float chL, chR;
        eb_chorus_tick_x(&s->cho, &c->cho, v32, &chL, &chR, v56, v58);
        /* the port's :2936-2937: 84672 takes the LEFT output and v593 the
         * RIGHT one. They are not interchangeable -- 84672 feeds the input
         * stage's v29 and 84704 its v19, which are different coefficients. */
        s->fb84672 = chL;
        v593 = chR;
    }
    s->fb84704 = v593;                              /* the port's LABEL_205 */
    return EB_MASTER_OK;
}

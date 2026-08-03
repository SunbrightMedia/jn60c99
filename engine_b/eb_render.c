/* eb_render.c — see eb_render.h for scope, for what is missing, and for why
 * this refuses to run as a complete engine.
 *
 * The call order below is the PORT's, taken from src/voice_render.c and from
 * src/juno_driver.c, and it is load-bearing in two places that are easy to get
 * wrong and that the port had to fix once already:
 *
 *   1. THE NOISE LFSR STEPS ONCE PER SAMPLE FOR THE WHOLE ENGINE, not once per
 *      voice. The plugin runs eight isolated units in lockstep, so every voice
 *      reads the SAME one-step advance. Chaining it through the voice loop runs
 *      it eight times too fast, which is audible and which is exactly the bug
 *      juno_driver.c's snapshot-and-restore exists to prevent.
 *
 *   2. A VOICE AT REST SKIPS ITS AUDIO WORK AND NEVER ITS STATE ADVANCE.
 *      MEASURED: one single idle sample before a note changes every sample of
 *      that note, because the phases free-run. Skipping the advance sounds
 *      right in every cold-start test and wrong in a DAW, and null_b.py plants
 *      precisely that bug in its teeth battery.
 */
#include "eb_render.h"
#include "juno_tables.h"

int eb_engine_render(eb_engine *e, eb_render_state *st, const eb_render_coefs *c,
                     const eb_render_needs *n, float *outL, float *outR)
{
    float mix = 0.0f;
    int v;

    /* THE GUARD. Nothing sets render_ok, so this returns silence today. It is
     * not a placeholder to be quietly deleted: it comes out when
     * eb_render_needs is empty and the three gates in docs/engineb/
     * STANDALONE.md have been run. Until then, a caller that wires this up by
     * mistake gets silence and a return code, not plausible-sounding audio
     * nobody has compared to anything. */
    if (!e->render_ok) {
        *outL = 0.0f;
        *outR = 0.0f;
        return EB_RENDER_INCOMPLETE;
    }

    /* The noise LFSR now advances inside eb_notecv_tick, which is where the
     * port advances it. The engine-wide single-advance law is preserved by
     * the same mechanism the port uses (juno_driver.c's snapshot/restore),
     * and reproducing that is part of the remaining engine work -- it is
     * NOT done here, which is one more reason render_ok stays unset. */

    for (v = 0; v < EB_NUM_VOICES; ++v) {
        eb_voice *vc = &e->v[v];
        float e1, e2, pit, pwm, cut, o6704, o6848;
        float dly_env, pitch_cv, lfo_del, lfo_undel, lfo_pulse;
        float gate_sign, pit_in, noise_v;
        float q[4], nsv04, nsvo, decimo, vcfo, cv;
        eb_cvgate_in gi;
        eb_cvgate_out go;

        if (vc->atrest) {
            /* State advance only. The DCO's phase and its sub counter must keep
             * running; eb_dco_advance does exactly that and no audio work.
             * MEASURED at about 8 % of a sounding voice, and it is EXACT --
             * see the free-run note in eb_dco.h, which also explains why this
             * cannot be an O(1) closed form. */
            eb_dco_advance(&st->dco[v], &st->dco_live[v], 1);
            continue;
        }

        /* ---- control rate ------------------------------------------------
         * THE ORDER BELOW IS THE PORT'S, and it is not the order this
         * function used to have. The port runs notecv (:594-681), then glide
         * (:682-796), then the LFO (:797-963), and only THEN the envelopes
         * (:964+). The envelopes' gate input is built from cell 560, which
         * glide writes, and cell 1824, which the LFO writes -- both in the
         * SAME sample. Ticking the envelopes first, as this function did while
         * those two blocks were still caller-supplied, would feed them last
         * sample's values. That is a one-sample skew: inaudible in a cold
         * start and wrong everywhere else, which is this project's most
         * repeated bug shape. */
        /* THE NOISE, first, as the port has it: its LFSR advance sits at
         * :595-656, ahead of everything else in the voice. */
        noise_v = eb_notecv_tick(&st->notecv[v], &c->notecv[v]);

        /* CV/GATE next (:657-681). Its inputs are ALL recall cells plus the
         * aux-latched cell 320 -- NOT the envelopes, which is what this call
         * wrongly passed while the surrounding blocks were still caller-
         * supplied placeholders. Corrected against the port. Its outputs are
         * the pre-glide pitch CV (c464) and the gate sign. */
        gi.t28 = c->cvg_t28[v];  gi.t29 = c->cvg_t29[v];
        gi.k   = c->cvg_k[v];    gi.p28 = c->cvg_p28[v];
        gi.p29 = st->gate_cell320[v];
        gi.gate_off = c->cvg_gate_off[v];
        eb_cvgate(&gi, &go);
        pit_in    = go.c464;
        gate_sign = go.sign;

        dly_env = eb_glide_tick(&st->glide[v], &c->glide[v],
                                gate_sign, c->kbd[v], c->vel[v], pit_in,
                                &pitch_cv);

        lfo_del = eb_lfo_tick(&st->lfo[v], &c->lfo[v], dly_env,
                              c->lfo_ext_gate[v], c->lfo_ext0[v],
                              c->lfo_ext1[v], noise_v, &lfo_undel, &lfo_pulse);

        /* the envelope gate, exactly as the port's envelope block builds it:
         * cell 560 (= gate_sign + 1, glide's own state) gated by the LFO pulse
         * polarity unless that envelope's LFO TRIG switch is off. */
        {
            float k0 = (lfo_pulse <= 0.0f) ? 0.0f : 1.0f;
            float k1 = k0;
            if (c->env_lfo_trig[v][0] == 0.0f) k0 = 1.0f;
            if (c->env_lfo_trig[v][1] == 0.0f) k1 = 1.0f;
            e1 = eb_env_tick(&st->env[v][0], &c->env[v][0],
                             st->glide[v].s560 * k0);
            e2 = eb_env_tick(&st->env[v][1], &c->env[v][1],
                             st->glide[v].s560 * k1);
        }

        eb_modcv_tick(&c->mod[v], pitch_cv, c->kbd[v],
                      lfo_del, lfo_undel, e1, e2, &pit, &pwm);
        eb_modcv_latch(&st->mod[v], pwm);

        cv = eb_pitch_eval(pit, 1.0f);

        cut = eb_vcf_cv_tick(&st->cv[v], &c->cv[v], pit, pwm,
                             lfo_del, lfo_undel, e1, e2, &o6704, &o6848);

        /* ---- audio rate --------------------------------------------------- */
        if (!st->dco_live_seeded[v]) {
            st->dco_live[v] = c->dco[v];
            st->dco_live_seeded[v] = 1;
        }
        eb_dco_set_pitch(&st->dco_live[v], cv, pwm);
        eb_dco_step4(&st->dco[v], &st->dco_live[v], q);
        decimo = eb_decim_tick(&st->dec[v], &c->dec[v], q[0], q[1], q[2], q[3]);
        nsvo   = eb_nsvf_tick(&st->nsv[v], &c->nsv[v], noise_v, &nsv04);
        vcfo   = eb_vcf_tick(&st->vcf[v], &c->vcf[v], decimo + nsvo, cut, o6848);
        mix   += eb_vca_tick(&st->vca[v], &c->vca[v], vcfo, e1, e2,
                             o6704, go.sign);
    }

    /* ---- FX, once for the whole engine. The chorus LFO free-runs whether or
     * not anything is sounding, which is why it is outside the voice loop and
     * unconditional. */
    {
        float l = mix, r = mix;
        eb_chorus_tick_x(&st->chorus, &c->chorus, mix, &l, &r, 0, 0.0f);
        eb_delay_process(&c->delay, &st->delay, 0, l, r, &l, &r);
        eb_reverb_process(&c->reverb, &st->reverb,
                          st->rev_pending, &st->rev_wipe, l, r, &l, &r);
        *outL = l;
        *outR = r;
    }
    return EB_RENDER_OK;
}

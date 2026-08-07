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
#include "eb_fork_config.h"
#include "juno_tables.h"
#include "eb_master.h"
#ifdef EB_VOICES_DEBUG
#include <stdio.h>
unsigned long ebdbg_n;
#endif

int eb_engine_render_voices(eb_engine *e, eb_render_state *st,
                            const eb_render_coefs *c, const eb_render_needs *n,
                            float *vout)
{
    float noise_v;
#if EB_LFO_SHARED
    float sh_lfo_del = 0.0f, sh_lfo_und = 0.0f, sh_lfo_pul = 0.0f;
#endif
    (void)n;
    int v;

    /* THE GUARD. Nothing sets render_ok, so this returns silence today. It is
     * not a placeholder to be quietly deleted: it comes out when
     * eb_render_needs is empty and the three gates in docs/engineb/
     * STANDALONE.md have been run. Until then, a caller that wires this up by
     * mistake gets silence and a return code, not plausible-sounding audio
     * nobody has compared to anything. */
    if (!e->render_ok) {
        for (v = 0; v < EB_NUM_VOICES; ++v) vout[v] = 0.0f;
        return EB_RENDER_INCOMPLETE;
    }

    /* THE NOISE, ONCE, FOR ALL EIGHT VOICES. juno_driver.c restores the shared
     * noise block before each voice, so every voice steps from the same state
     * and reads the SAME value, and the block ends the sample advanced exactly
     * once. Since the state and the coefficients are both shared, that is
     * identical to computing it once here -- and unlike a per-voice call it
     * cannot drift to eight times too fast. */
    noise_v = eb_notecv_tick(&st->notecv, &c->notecv);

    for (v = 0; v < EB_NUM_VOICES; ++v) {
        eb_voice *vc = &e->v[v];
        float e1, e2, pit, pwm, cut, o6704, o6848;
        float dly_env, pitch_cv, lfo_del, lfo_undel, lfo_pulse;
        float gate_sign, pit_in;
        float q[4], nsv04, nsvo, decimo, vcfo, cv;
        float reso, o7536, nmixo, inc, g_edge, pw_live, pwm_out;
        float n_3808, n_3536;

        eb_cvgate_in gi;
        eb_cvgate_out go;

        vout[v] = 0.0f;
        if (vc->atrest) {
            /* State advance only. The DCO's phase and its sub counter must keep
             * running; eb_dco_advance does exactly that and no audio work.
             * MEASURED at about 8 % of a sounding voice, and it is EXACT --
             * see the free-run note in eb_dco.h, which also explains why this
             * cannot be an O(1) closed form. */
            eb_dco_advance(&st->dco[v], &st->dco_live[v], 1);
#if EB_DCO_WT
            /* AND THE WAVETABLE'S OWN STATE, which is the one the sounding
             * path actually runs. Advancing only the trunk's left an at-rest
             * voice's wavetable phase frozen; see eb_dco_wt_advance. */
            {   eb_dco_wt_coef *w = &st->wt_live[v];
                w->inc    = st->dco_live[v].inc;
                w->subthr = st->dco_live[v].subthr;
                eb_dco_wt_advance(&st->wt[v], w, 1);
            }
#endif
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
        /* CV/GATE next (:657-681). Its inputs are ALL recall cells plus the
         * aux-latched cell 320 -- NOT the envelopes, which is what this call
         * wrongly passed while the surrounding blocks were still caller-
         * supplied placeholders. Corrected against the port. Its outputs are
         * the pre-glide pitch CV (c464) and the gate sign. */
        gi.t28 = c->cvg_t28[v];  gi.t29 = c->cvg_t29[v];
        gi.k   = c->cvg_k[v];    gi.p28 = c->cvg_p28[v];
        /* THE RETRIGGER ONE-SHOT, port :587-594 and :2175-2179, which no module
         * claims. When the aux edge is armed this sample's cell-320 read is
         * FORCED to 0.0 and the edge is consumed; cell 320 itself is unchanged
         * (the port saves and restores it). Modelling it here rather than in a
         * module is deliberate: it is engine-level event state, not arithmetic,
         * and the two port sites sit either side of the whole voice function. */
        if (st->aux_edge[v]) {
            gi.p29 = 0.0f;
            st->aux_edge[v] = 0;
        } else {
            gi.p29 = st->gate_cell320[v];
        }
        gi.gate_off = c->cvg_gate_off[v];
        eb_cvgate(&gi, &go);
        pit_in    = go.c464;
        gate_sign = go.sign;

        dly_env = eb_glide_tick(&st->glide[v], &c->glide[v],
                                gate_sign, c->kbd[v], c->vel[v], pit_in,
                                &pitch_cv);

#if EB_LFO_SHARED
        /* THE SHARED LFO (fork lever, gated EXACTLY 0 -- see the flag's note
         * in eb_fork_config.h). MEASURED FIRST, IMPLEMENTED SECOND: across
         * all 64 factory patches with STAGGERED note-ons, with LFO TRIG ENV
         * forced on, and with LFO DELAY TIME doctored to its maximum, the
         * eight per-voice LFO phases are IDENTICAL -- because the LFO's key
         * input is the any-key-held flag the plugin itself BROADCASTS to all
         * voices (the b2_bcast2 finding). So voice 0's tick is every voice's
         * tick, and this is a removal of redundant computation, not an
         * approximation. The gate that holds it to that claim is the full
         * null at EXACTLY 0: any input this reasoning missed fails loudly.
         * Voices 1..N keep their state untouched; only voice 0's advances. */
        if (v == 0) {
            lfo_del = eb_lfo_tick(&st->lfo[0], &c->lfo[0], dly_env,
                                  c->lfo_ext_gate[0], c->lfo_ext0[0],
                                  c->lfo_ext1[0], noise_v,
                                  &lfo_undel, &lfo_pulse);
            sh_lfo_del = lfo_del; sh_lfo_und = lfo_undel;
            sh_lfo_pul = lfo_pulse;
        } else {
            lfo_del = sh_lfo_del; lfo_undel = sh_lfo_und;
            lfo_pulse = sh_lfo_pul;
        }
#else
        lfo_del = eb_lfo_tick(&st->lfo[v], &c->lfo[v], dly_env,
                              c->lfo_ext_gate[v], c->lfo_ext0[v],
                              c->lfo_ext1[v], noise_v, &lfo_undel, &lfo_pulse);
#endif

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

        /* THE TAP COMES BEFORE THE LATCH. Cell 3536 is the ONE-SAMPLE DELAY
         * of cell 3520 (:1076), which is what eb_modcv_tap/eb_modcv_latch
         * already implement -- so this need was never new work, only an
         * unrouted value. Tapping after latching would hand this sample's
         * value to a consumer the port feeds with last sample's. */
        n_3536 = eb_modcv_tap(&st->mod[v]);
        /* THE SECOND ARGUMENT IS CELL 880, glide's own state -- the
         * key-follow + velocity SUM it computes -- NOT the raw key-follow cell
         * 368. The shim passes JF(a1, 880); this function passed c->kbd[v].
         * Third inherited guess found by the audit. */
        eb_modcv_tick(&c->mod[v], pitch_cv, st->glide[v].s880,
                      lfo_del, lfo_undel, e1, e2, &pit, &pwm);
        /* eb_modcv_tick's `pwm_out` IS cell 3808 (eb_pwm_cv.c:91 "THE PWM SUM,
         * [3808]"), which is eb_dcoprep's per-sample input. The second need
         * was likewise a value already computed and merely not routed. */
        n_3808 = pwm;

        /* THE PORT: fmin(fmax(cell4448 + cell3776, -20), 8.9), gained by
         * cell 3792 (a delayed copy of recall cell 3840). `pit` IS cell 3776,
         * modcv's pitch sum. The offset and the gain were both missing. */
        cv = eb_pitch_eval(c->pitch_off[v] + pit, c->pitch_gain[v]);

        /* SAME two inputs as modcv, per the shim: cells 752 and 880. `pit`
         * here is cell 752 (the glide output), NOT modcv's pitch_sum -- the
         * shim reads JF(a1, 752) for both calls. */
        cut = eb_vcf_cv_tick(&st->cv[v], &c->cv[v], pitch_cv, st->glide[v].s880,
                             lfo_del, lfo_undel, e1, e2, &o6704, &o6848);

        /* the resonance shaper takes the cutoff CV and the two side outputs,
         * and returns the ladder's feedback term (the port's v241). */
        reso = eb_vcf_res_tick(&st->res[v], &c->res[v], cut, o6704, o6848,
                               &o7536);

        /* ---- audio rate --------------------------------------------------- */
        if (!st->dco_live_seeded[v]) {
            st->dco_live[v] = c->dco[v];
            st->dco_live_seeded[v] = 1;
        }
        /* DCO PREP is the port's own increment/width derivation (:1702-1717).
         * It supersedes the earlier eb_dco_set_pitch(cv, pwm) shortcut, which
         * guessed this block's inputs before the block was a module: the
         * increment is NOT the raw pitch CV, it is fmaxf(k5568, cv*k5536),
         * and the width comes from cell 5520 plus the per-sample 3808. */
        /* THE SECOND ARGUMENT IS CELL 3776 (the port's v392 = modcv's pitch
         * sum), NOT the PWM sum. Fourth inherited guess. */
        inc = eb_dcoprep_tick(&c->dprep[v], cv, pit, n_3808,
                              &g_edge, &pw_live, &pwm_out);
        /* THE HALF-OS INCREMENT COMES FROM eb_dco_inc_scale(), the single
         * expression every path uses -- see the long note on it in eb_dco.h,
         * which records the two opposite octave errors that got it there.
         * This line does NOT reimplement the factor.
         *
         * `g` IS NOT RESCALED, and this is the one thing here that reasoning
         * got backwards and measurement corrected. g = 0.00390625/inc, so
         * 256*g = 1/inc, and the saw's edge term is clamp1(tri(p)/inc): a
         * smoothing ramp whose width IN PHASE is proportional to inc. Scaling
         * g with the new increment keeps the edge the same number of
         * SUB-SAMPLES wide -- which is twice the TIME, i.e. a duller
         * oscillator. MEASURED with g halved: -0.30 dB at f0 1.8 kHz, -3.56 dB
         * at 7 kHz, -4.95 dB at 10.6 kHz. With g UNCHANGED the level matches
         * the 4x path within 0.01 dB at every pitch tested.
         *
         * The cost of that choice is the honest one: the edge now spans one
         * sub-sample instead of two, so it is less band-limited -- which is
         * precisely the alias increase gate 2 exists to bound. */
        st->dco_live[v].inc  = eb_dco_inc_scale(inc);
        st->dco_live[v].g    = g_edge;
        st->dco_live[v].pw   = pw_live;
        st->dco_live[v].pwm1 = pw_live - 1.0f;
        st->dco_live[v].pwp1 = pw_live + 1.0f;
#if EB_DCO_PULSEFAST
        /* g just changed, so the edge thresholds must be re-derived. The
         * shim path gets this through eb_dco_set_pitch; this path assigns
         * the fields directly and would otherwise run on stale values. */
        eb_dco_set_edge_thresholds(&st->dco_live[v]);
#endif
#if EB_DCO_WT
        /* THE BAND-LIMITED DCO. It replaces eb_dco_step4 AND the decimator's
         * FIR; the biquad tail below still runs, because it is rate-dependent
         * recall data and not anti-aliasing.
         *
         * The per-recall fields are copied from the SAME eb_dco_coef the 4x
         * path uses, so the two builds cannot disagree about a level, a gain
         * or the saturator -- and if they ever do, it is one struct to look at
         * rather than two derivations to compare. */
        {
            eb_dco_wt_coef *w = &st->wt_live[v];
            const eb_dco_coef *d = &st->dco_live[v];
            /* BOUND UNCONDITIONALLY. The guard `if (!w->res_saw)` assumes
             * eb_render_state arrives zeroed, and its seeder only clears
             * named members -- so a non-zero garbage pointer would never be
             * replaced and the module would read whatever was at that address.
             * It is a pointer assignment; the guard saved nothing and risked
             * everything. */
            eb_dco_wt_bind_tables(w);
            w->sat_hi = d->sat_hi;   w->sat_lo = d->sat_lo;
            w->lvl_saw = d->lvl_saw; w->lvl_pulse = d->lvl_pulse;
            w->lvl_sub = d->lvl_sub;
            w->gn_saw = d->gn_saw;   w->gn_pulse = d->gn_pulse;
            w->gn_sub = d->gn_sub;   w->subthr = d->subthr;
            /* THE INCREMENT COMES FROM dco_live, which already holds
             * eb_dco_inc_scale(inc) -- inc*4 under EB_QUARTER_OS, which is
             * exactly one output sample of phase. Writing "inc * 4" here
             * instead would be a SECOND copy of that rule, and a second copy
             * is how this project's octave bug survived twice. There is one
             * expression and this line reads it. */
            eb_dco_wt_set_pitch(w, st->dco_live[v].inc, pw_live);
            q[0] = eb_dco_wt_tick(&st->wt[v], w);
            q[1] = q[2] = q[3] = 0.0f;
        }
#else
        eb_dco_step4(&st->dco[v], &st->dco_live[v], q);
#endif
        /* pwm_out IS CELL 5456, eb_dcoprep's third output, and the decimator's
         * per-sample feedback term. It was discarded here as `(void)pwm_out`
         * while the decimator read a CACHED 5456 -- the tenth inherited defect,
         * and the second of the same class as the DCO levels. */
        decimo = eb_decim_tick(&st->dec[v], &c->dec[v], pwm_out,
                               q[0], q[1], q[2], q[3]);
        nsvo   = eb_nsvf_tick(&st->nsv[v], &c->nsv[v], noise_v, &nsv04);
        /* the noise mix consumes the SVF's cell-4320 output and the per-sample
         * cell 3536; its result is the ladder's noise input (cell 6544). */
        /* eb_nsvf_tick RETURNS cell 4320 and reports cell 4304 through
         * `s04_out`; noisemix consumes 4320. Passing nsv04 here would have fed
         * it the wrong one of the two -- sixth inherited guess, found by the
         * same audit. */
        nmixo  = eb_noisemix_tick(&c->nmix[v], nsvo, n_3536);
        /* REVIEW FIX (Fable): the latch input is NOT the PWM sum. Cell 3520
         * is v526 = eb_decim_tick's RETURN VALUE, written at the port's :2174
         * -- the one-sample-delayed decimator output that noisemix scales into
         * the ladder input next sample. The earlier draft latched `pwm` here,
         * a guess this function inherited from before dcoprep existed; it was
         * caught by reading :2170's operands (decimator coefficients 5456 and
         * 6336, not PWM cells). The latch therefore happens AFTER the decim
         * call, below. */
        vcfo   = eb_vcf_tick(&st->vcf[v], &c->vcf[v], nmixo, reso, o7536);
        eb_modcv_latch(&st->mod[v], decimo);
        (void)nsv04;
        /* THE LAST TWO ARGUMENTS ARE CELL 6848 and CELL 560, per the shim
         * (JF(a1, 6848), JF(a1, 560)) -- not o6704 and the gate sign. Fifth
         * inherited guess. */
        vout[v] = eb_vca_tick(&st->vca[v], &c->vca[v], vcfo, e1, e2,
                              o6848, st->glide[v].s560);
    }
#ifdef EB_VOICES_DEBUG
    { extern unsigned long ebdbg_n; ++ebdbg_n; }
#endif
    return EB_RENDER_OK;
}

int eb_engine_render(eb_engine *e, eb_render_state *st, const eb_render_coefs *c,
                     const eb_render_needs *n,
                     eb_master_state *ms, const eb_master_coef *mc,
                     const eb_master_rings *rings,
                     float *outL, float *outR)
{
    float vbuf[EB_NUM_VOICES];

    if (eb_engine_render_voices(e, st, c, n, vbuf) != EB_RENDER_OK) {
        *outL = 0.0f;
        *outR = 0.0f;
        return EB_RENDER_INCOMPLETE;
    }
    /* THE MASTER IS eb_master_render's, NOT A MODEL OF IT.
     *
     * This function used to sum the voices and call the three FX directly.
     * That was a MODEL of the master stage and it was wrong in a way worth
     * recording, because it looked entirely reasonable: it treated the effect
     * send as an INSERT. The port forms its output BEFORE dispatching the
     * effect arms, and an arm's result reaches the audio only through cells
     * 84672/84704 on the NEXT sample. It also had no DELAY or EFFECT type
     * dispatch at all -- one chorus, one delay, one reverb, always.
     *
     * eb_master_render is the real chain and is gated: null_b.py
     * --module standalone, all 33 scenarios, EXACTLY 0 at both rates. */
    if (eb_master_render(ms, mc, rings, vbuf, outL, outR) != EB_MASTER_OK) {
        *outL = 0.0f;
        *outR = 0.0f;
        return EB_RENDER_INCOMPLETE;
    }
    return EB_RENDER_OK;
}


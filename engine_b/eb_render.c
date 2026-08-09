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
#ifdef EB_DUMP_DCO
/* THE DCO CHAIN'S OWN OUTPUT, dumped per voice per sample. The whole-engine
 * null is 15 to 25 dB worse than any per-arm module figure, and no amount of
 * module work explains that. This says whether the oscillator is worse IN SITU
 * or whether its error is amplified downstream -- two different searches. */
#include <stdio.h>
#include <stdlib.h>
static FILE *ebdd_f;
static void ebdd_open(void)
{
    const char *p = getenv("EB_DUMP_DCO");
    if (!ebdd_f && p) ebdd_f = fopen(p, "ab");
}
#endif
#ifdef EB_VOICES_DEBUG
#include <stdio.h>
unsigned long ebdbg_n;
#endif

/* See eb_render.h. This duplicates no arithmetic: it runs the same three
 * calls the range would have run for voice 0, and the range then skips them.
 * The at-rest test is the loop's own, because if voice 0 is at rest the loop
 * `continue`s BEFORE the LFO block and every voice sees a zero LFO -- that is
 * the behaviour the EXACTLY-0 gate certified, and the prologue must
 * reproduce it rather than improve on it. */
void eb_engine_render_shared(eb_engine *e, eb_render_state *st,
                             const eb_render_coefs *c, eb_shared_tick *sh)
{
    eb_cvgate_in  gi;
    eb_cvgate_out go;
    float lfo_undel = 0.0f, lfo_pulse = 0.0f;

    sh->lfo_del = sh->lfo_und = sh->lfo_pul = 0.0f;
    sh->v0_pit_in = sh->v0_gate_sign = 0.0f;
    sh->v0_dly_env = sh->v0_pitch_cv = 0.0f;
    sh->noise_v = eb_notecv_tick(&st->notecv, &c->notecv);

    sh->v0_atrest = e->v[0].atrest ? 1 : 0;
    if (sh->v0_atrest) { sh->ready = 1; return; }

    gi.t28 = c->cvg_t28[0];  gi.t29 = c->cvg_t29[0];
    gi.k   = c->cvg_k[0];    gi.p28 = c->cvg_p28[0];
    if (st->aux_edge[0]) { gi.p29 = 0.0f; st->aux_edge[0] = 0; }
    else                 { gi.p29 = st->gate_cell320[0]; }
    gi.gate_off = c->cvg_gate_off[0];
    eb_cvgate(&gi, &go);
    sh->v0_pit_in    = go.c464;
    sh->v0_gate_sign = go.sign;
    sh->v0_dly_env   = eb_glide_tick(&st->glide[0], &c->glide[0],
                                     go.sign, c->kbd[0], c->vel[0], go.c464,
                                     &sh->v0_pitch_cv);
#if EB_LFO_SHARED
    sh->lfo_del = eb_lfo_tick(&st->lfo[0], &c->lfo[0], sh->v0_dly_env,
                              c->lfo_ext_gate[0], c->lfo_ext0[0],
                              c->lfo_ext1[0], sh->noise_v,
                              &lfo_undel, &lfo_pulse);
    sh->lfo_und = lfo_undel; sh->lfo_pul = lfo_pulse;
#else
    (void)lfo_undel; (void)lfo_pulse;
#endif
    sh->ready = 1;
}


/* ---- EB_ABLATE: per-module CYCLE attribution by ABLATION ------------------
 *
 * WHY ABLATION AND NOT CCOUNT PROBES. The per-voice chain is twelve calls in
 * one hot loop. Bracketing each with a cycle-counter read changes inlining,
 * register allocation and scheduling around every one of them -- and this
 * project has now been misled THREE times by measurements that perturbed or
 * mis-metered what they measured (interleave judged on instruction count, the
 * flash-resident wavetables missed entirely, a cache fix that measured zero).
 * A probe that costs what it measures cannot answer "which module is biggest".
 *
 * Instead: build N firmwares, each with ONE module's work replaced by a cheap
 * constant, and take the delta of the wake=0xfc number the board already
 * prints. The remaining code, its inlining and its cache layout are untouched.
 *
 * THE AUDIO IS WRONG IN AN ABLATED BUILD, DELIBERATELY. These builds measure
 * COST ONLY. They are never gated and never shipped -- EB_ABLATE is a
 * measurement flag, and a nonzero value is refused by the sonic/null gates.
 *
 * READ THE RESULT WITH THE NOISE FLOOR IN MIND: the sweep's own 4-voice point
 * came in 273 cycles BELOW its 3-voice point although the critical path is
 * identical, so anything under ~300 cycles is not a finding.
 *
 * Values are one-hot so a build can never ablate two modules at once. */
/* EB_ATREST_BLOCK -- run the at-rest voices' free-run advance ONCE PER BLOCK
 * instead of once per sample. EXACT BY CONSTRUCTION, not by approximation:
 * eb_dco_wt_advance already takes a sample count and its body loop is the
 * same statements in the same order either way. What disappears is the
 * per-sample PROLOGUE -- the function call, the primed test, the inc4-change
 * test and eb_dco_wt_set_pitch, which recomputes the sub's mip level from a
 * float exponent every sample for a voice that is producing silence.
 *
 * THE PRECONDITION, stated because it is what makes the two spellings equal:
 * an at-rest voice's increment cannot move inside the block. It comes from
 * st->dco_live[v].inc, which only that voice's own tick writes, and an
 * at-rest voice does not tick. The caller must also hold `atrest` constant
 * across the block, which the firmware does -- WAKE is per chunk.
 *
 * Gated fork-vs-fork BIT-IDENTICAL, the same gate that proved the trunk
 * advance dead under the wavetable. A sonic gate would be the wrong
 * instrument for a change that claims to be exact. */
/* EB_SLOTS -- render only the first N voice slots; the rest are held AT REST.
 * A DIAGNOSTIC for the six-voice question, not a shipping configuration.
 *
 * WHAT IT ANSWERS AND WHAT IT DOES NOT. UNISON stacks every voice on one
 * note, so which slots are dropped is arbitrary and this reproduces a
 * six-voice unison exactly. It does NOT answer the POLY question: the port's
 * assigner scans 7 downward, so capping the TOP would silence the first notes
 * played rather than shrink the pool. A real six-slot POLY engine needs the
 * harness rebuild (regenerate blob and masks), not this flag.
 *
 * The low slots are kept deliberately: voice 0 drives the shared-LFO
 * prologue, and holding it at rest would zero the LFO for every voice --
 * which would look like a six-voice artefact and be nothing of the kind. */
#ifndef EB_SLOTS
#define EB_SLOTS EB_NUM_VOICES
#endif


/* ---- EB_ZC_PROBE2: which candidate coefficients are nonzero WHILE RENDERING
 * The lesson from k6864: zero_proof.c sweeps PRESETS and never plays a note,
 * so a note/gate-written cell reads zero there for the wrong reason. This
 * reads the remaining candidates from inside the voice loop, with notes
 * sounding, and is the confirmation every deletion now has to pass. */
#ifndef EB_ZC_PROBE2
#define EB_ZC_PROBE2 0
#endif
#if EB_ZC_PROBE2
#include <stdio.h>
#define ZCN 9
static float zc2[ZCN];
static const char *zc2n[ZCN] = {
    "vca.c9552","vca.c9680","vca.c10224","vca.c10368",
    "glide.k912","glide.k1040","nsvf.k84","vcf_res.k7616","dcoprep.k6320" };
static void zc2_rep(void) __attribute__((destructor));
static void zc2_rep(void){ int i; FILE*f=fopen("/tmp/zc2.log","a"); if(!f)return;
    for(i=0;i<ZCN;++i) fprintf(f,"%-16s max|v| %.9g\n",zc2n[i],(double)zc2[i]);
    fclose(f); }
#define ZC2(i,v) do{ float _a=(v)<0?-(v):(v); if(_a>zc2[i]) zc2[i]=_a; }while(0)
static float zc2l[14];
static void zc2l_rep(void) __attribute__((destructor));
static void zc2l_rep(void){ int i; FILE*f=fopen("/tmp/zc2l.log","a"); if(!f)return;
    for(i=0;i<14;++i) fprintf(f,"lfo[%d] max|v| %.9g\n",i,(double)zc2l[i]);
    fclose(f); }
#define ZC2L(i,v) do{ float _a=(v)<0?-(v):(v); if(_a>zc2l[i]) zc2l[i]=_a; }while(0)
#endif

#ifndef EB_FUSE_VCA
#define EB_FUSE_VCA 0
#endif

#ifndef EB_ATREST_BLOCK
#define EB_ATREST_BLOCK 0
#endif

#ifndef EB_ABLATE
#define EB_ABLATE 0
#endif
/* An ablated build produces WRONG AUDIO ON PURPOSE. It must never reach a
 * gate or a listening firmware, so the gates refuse it outright rather than
 * relying on anyone remembering. EB_ABLATE is a MEASUREMENT flag. */
#if EB_ABLATE
#ifdef EB_GATED_BUILD
#error "EB_ABLATE is a cost-measurement flag and produces deliberately wrong audio: it cannot be combined with a gated build."
#endif
#endif
#define EB_ABL_VCF      1
#define EB_ABL_VCF_RES  2
#define EB_ABL_VCA      3
#define EB_ABL_ENV      4
#define EB_ABL_DCO      5
#define EB_ABL_PITCH    6
#define EB_ABL_VCF_CV   7
#define EB_ABL_GLIDE    8
#define EB_ABL_DECIM    9
#define EB_ABL_NSVF     10
#define EB_ABL_DCOPREP  11
#define EB_ABL_MODCV    12
#define EB_ABL_ATREST   13
/* NOT one-hot, and deliberately so. The per-sample wiring is ~648 cycles
 * spread over five small modules -- roughly 110 each, which is BELOW this
 * board's ~300-cycle noise floor, so five separate binaries would each
 * measure noise and cost five flashing rounds to do it. Ablating all five at
 * once asks the only question the floor can answer: is the 648 concentrated
 * in one place, or is it genuinely spread? */
#define EB_ABL_WIRING   14

void eb_engine_advance_atrest(eb_engine *e, eb_render_state *st,
                              const eb_render_coefs *c, int v0, int v1, int n)
{
#if EB_ATREST_BLOCK && EB_DCO_WT
    int v;
    (void)c;
    if (n <= 0) return;
    for (v = v0; v < v1; ++v) {
        if (!e->v[v].atrest) continue;
        {   eb_dco_wt_coef *w = &st->wt_live[v];
            eb_dco_wt_set_pitch(w, st->dco_live[v].inc * 0.25f, w->pw);
            w->subthr = st->dco_live[v].subthr;
            eb_dco_wt_advance(&st->wt[v], w, n);
        }
    }
#else
    (void)e; (void)st; (void)c; (void)v0; (void)v1; (void)n;
#endif
}

int eb_engine_render_range(eb_engine *e, eb_render_state *st,
                           const eb_render_coefs *c, const eb_render_needs *n,
                           int v0, int v1, eb_shared_tick *sh, float *vout)
{
    /* OWN_SHARED: this call computes the shared noise and LFO rather than
     * consuming another core's. It is true for the range that contains voice
     * 0, because the shared LFO's input is voice 0's own glide output. */
    const int own_shared = (v0 == 0);
    float noise_v;
#if EB_VCF_ILV
    /* VCF interleaving buffers. The four sub-steps of one voice are a serial
     * chain and cannot overlap; two voices are independent. So the ladder is
     * DEFERRED here and run pairwise below through eb_vcf_tick2, which gives
     * the in-order FPU two dependency chains to fill each other's stalls.
     * Everything crossing the VCF boundary is stashed per voice. */
    float ilv_nmix[EB_NUM_VOICES], ilv_reso[EB_NUM_VOICES], ilv_7536[EB_NUM_VOICES];
    float ilv_e1[EB_NUM_VOICES], ilv_e2[EB_NUM_VOICES], ilv_6848[EB_NUM_VOICES];
    float ilv_decimo[EB_NUM_VOICES];
    unsigned char ilv_live[EB_NUM_VOICES];
    int ilv_w;
    for (ilv_w = 0; ilv_w < EB_NUM_VOICES; ++ilv_w) ilv_live[ilv_w] = 0;
#endif
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
        for (v = v0; v < v1; ++v) vout[v] = 0.0f;
        return EB_RENDER_INCOMPLETE;
    }

    /* THE NOISE, ONCE, FOR ALL EIGHT VOICES. juno_driver.c restores the shared
     * noise block before each voice, so every voice steps from the same state
     * and reads the SAME value, and the block ends the sample advanced exactly
     * once. Since the state and the coefficients are both shared, that is
     * identical to computing it once here -- and unlike a per-voice call it
     * cannot drift to eight times too fast. */
    /* THE NOISE ADVANCES ONCE PER SAMPLE, not once per core. The consuming
     * range reads the value the owner published; advancing it on both cores
     * would step the LFSR twice per sample. */
    if (sh && sh->ready) {
        noise_v = sh->noise_v;        /* the prologue already advanced it */
    } else if (own_shared) {
        noise_v = eb_notecv_tick(&st->notecv, &c->notecv);
        if (sh) sh->noise_v = noise_v;
    } else {
        noise_v = sh ? sh->noise_v : 0.0f;
    }

    for (v = v0; v < v1; ++v) {
        eb_voice *vc = &e->v[v];
        float e1, e2, pit, pwm, cut, o6704, o6848;
        float dly_env, pitch_cv, lfo_del, lfo_undel, lfo_pulse;
        float gate_sign, pit_in;
        float q[4], nsv04, nsvo, decimo, vcfo, cv;
        float reso, o7536, nmixo, inc, g_edge, pw_live, pwm_out;
        float n_3808, n_3536;

        eb_cvgate_in gi;
        eb_cvgate_out go;
#if EB_FUSE_VCA
        eb_vca_ctl vca_ctl;
#endif

        vout[v] = 0.0f;
        if (vc->atrest || v >= EB_SLOTS) {
#if EB_ATREST_BLOCK || (defined(EB_ABLATE) && EB_ABLATE == 13)
            /* The advance is hoisted to eb_engine_advance_atrest(), which the
             * caller runs ONCE PER BLOCK. See that function for why the two
             * spellings are the same arithmetic. Under EB_ABLATE=13 the caller
             * runs nothing at all, which bounds the lever. */
            continue;
#endif
            /* State advance only. The DCO's phase and its sub counter must keep
             * running; eb_dco_advance does exactly that and no audio work.
             * MEASURED at about 8 % of a sounding voice, and it is EXACT --
             * see the free-run note in eb_dco.h, which also explains why this
             * cannot be an O(1) closed form. */
#if !EB_DCO_WT
            eb_dco_advance(&st->dco[v], &st->dco_live[v], 1);
#else
            /* DEAD UNDER EB_DCO_WT, PROVEN by fork-vs-fork A/B: with this
             * advance removed, all 36 scenarios are BIT-IDENTICAL (0 differ).
             * st->dco[v] is read only by eb_dco_step4, which is compiled out
             * under the wavetable; the sounding state is st->wt[v], advanced
             * by eb_dco_wt_advance below. NOTE the first gate of this change
             * was INVALID -- null_b with JUNO_EB_DCO_WT compares fork against
             * TRUNK oracle and always reads -36.6 dB; the correct gate is the
             * fork-vs-fork bit compare, which is what proved it. */
#endif
#if EB_DCO_WT
            /* AND THE WAVETABLE'S OWN STATE, which is the one the sounding
             * path actually runs. Advancing only the trunk's left an at-rest
             * voice's wavetable phase frozen; see eb_dco_wt_advance. */
            {   eb_dco_wt_coef *w = &st->wt_live[v];
                /* set_pitch, not a field poke: it is the one place that knows
                 * inc4 and inc are two different numbers. The at-rest voice
                 * keeps the last live increment, exactly as eb_dco_advance
                 * does with dco_live. */
                eb_dco_wt_set_pitch(w, st->dco_live[v].inc * 0.25f, w->pw);
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
        if (sh && sh->ready && v == 0) {
            /* the prologue ran these and advanced the glide state; running
             * them again would tick the glide twice in one sample */
            pit_in    = sh->v0_pit_in;
            gate_sign = sh->v0_gate_sign;
            dly_env   = sh->v0_dly_env;
            pitch_cv  = sh->v0_pitch_cv;
        } else {
        eb_cvgate(&gi, &go);
        pit_in    = go.c464;
        gate_sign = go.sign;

#if EB_ABLATE == EB_ABL_GLIDE || EB_ABLATE == EB_ABL_WIRING
        dly_env = gate_sign; pitch_cv = pit_in;
#else
        dly_env = eb_glide_tick(&st->glide[v], &c->glide[v],
                                gate_sign, c->kbd[v], c->vel[v], pit_in,
                                &pitch_cv);
#endif
        }

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
        if (sh && sh->ready) {
            lfo_del = sh->lfo_del; lfo_undel = sh->lfo_und;
            lfo_pulse = sh->lfo_pul;
        } else if (v == 0) {
            lfo_del = eb_lfo_tick(&st->lfo[0], &c->lfo[0], dly_env,
                                  c->lfo_ext_gate[0], c->lfo_ext0[0],
                                  c->lfo_ext1[0], noise_v,
                                  &lfo_undel, &lfo_pulse);
            sh_lfo_del = lfo_del; sh_lfo_und = lfo_undel;
            sh_lfo_pul = lfo_pulse;
            if (sh) { sh->lfo_del = lfo_del; sh->lfo_und = lfo_undel;
                      sh->lfo_pul = lfo_pulse; }
        } else if (own_shared) {
            lfo_del = sh_lfo_del; lfo_undel = sh_lfo_und;
            lfo_pulse = sh_lfo_pul;
        } else {
            /* a range that does not contain voice 0 never runs the v==0 arm,
             * so its only source is what the owner published */
            lfo_del = sh ? sh->lfo_del : 0.0f;
            lfo_undel = sh ? sh->lfo_und : 0.0f;
            lfo_pulse = sh ? sh->lfo_pul : 0.0f;
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
#if EB_ABLATE == EB_ABL_ENV
            e1 = st->glide[v].s560 * k0;
            e2 = st->glide[v].s560 * k1;
#else
            e1 = eb_env_tick(&st->env[v][0], &c->env[v][0],
                             st->glide[v].s560 * k0);
            e2 = eb_env_tick(&st->env[v][1], &c->env[v][1],
                             st->glide[v].s560 * k1);
#endif
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
#if EB_ABLATE == EB_ABL_MODCV || EB_ABLATE == EB_ABL_WIRING
        pit = pitch_cv; pwm = 0.0f;
#else
        eb_modcv_tick(&c->mod[v], pitch_cv, st->glide[v].s880,
                      lfo_del, lfo_undel, e1, e2, &pit, &pwm);
#endif
        /* eb_modcv_tick's `pwm_out` IS cell 3808 (eb_pwm_cv.c:91 "THE PWM SUM,
         * [3808]"), which is eb_dcoprep's per-sample input. The second need
         * was likewise a value already computed and merely not routed. */
        n_3808 = pwm;

        /* THE PORT: fmin(fmax(cell4448 + cell3776, -20), 8.9), gained by
         * cell 3792 (a delayed copy of recall cell 3840). `pit` IS cell 3776,
         * modcv's pitch sum. The offset and the gain were both missing. */
#if EB_ABLATE == EB_ABL_PITCH
        cv = c->pitch_off[v] + pit;
#else
        cv = eb_pitch_eval(c->pitch_off[v] + pit, c->pitch_gain[v]);
#endif

        /* SAME two inputs as modcv, per the shim: cells 752 and 880. `pit`
         * here is cell 752 (the glide output), NOT modcv's pitch_sum -- the
         * shim reads JF(a1, 752) for both calls. */
#if EB_ABLATE == EB_ABL_VCF_CV || EB_ABLATE == EB_ABL_WIRING
        cut = pitch_cv; o6704 = 0.0f; o6848 = 0.0f;
#else
        cut = eb_vcf_cv_tick(&st->cv[v], &c->cv[v], pitch_cv, st->glide[v].s880,
                             lfo_del, lfo_undel, e1, e2, &o6704, &o6848);
#endif

        /* the resonance shaper takes the cutoff CV and the two side outputs,
         * and returns the ladder's feedback term (the port's v241). */
#if EB_ABLATE == EB_ABL_VCF_RES
        reso = cut; o7536 = cut; (void)o6704; (void)o6848;
#else
        reso = eb_vcf_res_tick(&st->res[v], &c->res[v], cut, o6704, o6848,
                               &o7536);
#endif

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
#if EB_ABLATE == EB_ABL_DCOPREP || EB_ABLATE == EB_ABL_WIRING
        inc = cv; g_edge = 0.0f; pw_live = 0.5f; pwm_out = 0.0f;
#else
        inc = eb_dcoprep_tick(&c->dprep[v], cv, pit, n_3808,
                              &g_edge, &pw_live, &pwm_out);
#endif
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
            /* THE UNSCALED INCREMENT, which is the SUB-STEP one. The module
             * advances its phase in four sub-steps exactly as the port does,
             * because adding 4*inc4 once and adding inc4 four times are the
             * same number only when the arithmetic is exact -- see the drift
             * note in eb_dco_wt.c. dco_live[v].inc holds the SCALED value and
             * passing it here made the module's phase drift away from the
             * port's over seconds. */
            eb_dco_wt_set_pitch(w, inc, pw_live);
#if EB_ABLATE == EB_ABL_DCO
            q[0] = 0.0f; (void)w;
#else
            q[0] = eb_dco_wt_tick(&st->wt[v], w);
#endif
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
#if EB_ABLATE == EB_ABL_NSVF || EB_ABLATE == EB_ABL_WIRING
        nsvo = noise_v; nsv04 = noise_v;
#else
        nsvo   = eb_nsvf_tick(&st->nsv[v], &c->nsv[v], noise_v, &nsv04);
#endif
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
#if EB_VCF_ILV
        /* DEFER the ladder: stash its inputs and everything the post-ladder
         * work needs, and run it pairwise after the loop. */
        ilv_nmix[v]=nmixo; ilv_reso[v]=reso; ilv_7536[v]=o7536;
        ilv_e1[v]=e1; ilv_e2[v]=e2; ilv_6848[v]=o6848;
        ilv_decimo[v]=decimo; ilv_live[v]=1;
        (void)nsv04;
#else
#if EB_FUSE_VCA
        /* THE CONTROL HALF OF THE VCA, HOISTED ABOVE THE LADDER.
         *
         * The ladder is four serially dependent sub-steps and on this in-order
         * FPU it stalls: 516 instructions measured against 1,083 cycles, c/i
         * 2.1. The compiler cannot fill those bubbles because inside one voice
         * there is nothing legal to move into them -- every neighbouring
         * module either feeds the ladder or is fed by it.
         *
         * The VCA's control strands are the exception: sm, vel, g1, g2, the
         * gate ramp and lvl never read the ladder's output. Computed here they
         * become ~100 instructions of INDEPENDENT work sitting next to the
         * chain, which is exactly what an in-order machine needs.
         *
         * BIT-EXACT, not approximate: no operation's inputs, grouping or
         * rounding changes -- only the interleaving of two chains that do not
         * touch. The composite null gate holds it to EXACTLY 0. */
        eb_vca_control(&st->vca[v], &c->vca[v], e1, e2, st->glide[v].s560,
                       &vca_ctl);
#endif
#if EB_ABLATE == EB_ABL_VCF
        vcfo = nmixo;
#else
        vcfo   = eb_vcf_tick(&st->vcf[v], &c->vcf[v], nmixo, reso, o7536);
#endif
#ifdef EB_DUMP_DCO
        ebdd_open();
        if (ebdd_f) fwrite(&decimo, sizeof decimo, 1, ebdd_f);
#endif
        eb_modcv_latch(&st->mod[v], decimo);
        (void)nsv04;
#if EB_ZC_PROBE2
        {   /* the LFO's own candidates, probed IN-RENDER for the same reason
             * the first probe exists: a preset sweep never plays a note. */
            const eb_lfo_coef *L = &c->lfo[0];
            ZC2L(0,L->k1856); ZC2L(1,L->k1904); ZC2L(2,L->k1968);
            ZC2L(3,L->k1984); ZC2L(4,L->k2000); ZC2L(5,L->k2016);
            ZC2L(6,L->k2032); ZC2L(7,L->k2048); ZC2L(8,L->k2096);
            ZC2L(9,L->k2112); ZC2L(10,L->k2304); ZC2L(11,L->k2336);
            ZC2L(12,L->k2496); ZC2L(13,L->k2512);
        }
        ZC2(0,c->vca[v].c9552);  ZC2(1,c->vca[v].c9680);
        ZC2(2,c->vca[v].c10224); ZC2(3,c->vca[v].c10368);
        ZC2(4,c->glide[v].k912); ZC2(5,c->glide[v].k1040);
        ZC2(6,c->nsv[v].k84);    ZC2(7,c->res[v].k7616);
        ZC2(8,c->dprep[v].k6320);
#endif
        /* THE LAST TWO ARGUMENTS ARE CELL 6848 and CELL 560, per the shim
         * (JF(a1, 6848), JF(a1, 560)) -- not o6704 and the gate sign. Fifth
         * inherited guess. */
#if EB_ABLATE == EB_ABL_VCA
        vout[v] = vcfo * e1; (void)e2; (void)o6848;
#elif EB_FUSE_VCA
        vout[v] = eb_vca_audio(&st->vca[v], &c->vca[v], vcfo, o6848, &vca_ctl);
#else
        vout[v] = eb_vca_tick(&st->vca[v], &c->vca[v], vcfo, e1, e2,
                              o6848, st->glide[v].s560);
#endif
#endif
    }
#if EB_VCF_ILV
    /* THE PAIRWISE LADDER PASS. Walk the live voices two at a time; the last
     * odd one, if any, uses the single-voice tick. modcv_latch stays BEFORE
     * vca, exactly as the inline path orders it. */
    {   int p = v0;
        while (p < v1) {
            int a = p; while (a < v1 && !ilv_live[a]) ++a;
            if (a >= v1) break;
            int b = a + 1; while (b < v1 && !ilv_live[b]) ++b;
            if (b < v1) {
                float oa, ob;
                eb_vcf_tick2(&st->vcf[a], &c->vcf[a], ilv_nmix[a], ilv_reso[a], ilv_7536[a], &oa,
                             &st->vcf[b], &c->vcf[b], ilv_nmix[b], ilv_reso[b], ilv_7536[b], &ob);
                eb_modcv_latch(&st->mod[a], ilv_decimo[a]);
                vout[a] = eb_vca_tick(&st->vca[a], &c->vca[a], oa, ilv_e1[a], ilv_e2[a], ilv_6848[a], st->glide[a].s560);
                eb_modcv_latch(&st->mod[b], ilv_decimo[b]);
                vout[b] = eb_vca_tick(&st->vca[b], &c->vca[b], ob, ilv_e1[b], ilv_e2[b], ilv_6848[b], st->glide[b].s560);
                p = b + 1;
            } else {
                float oa = eb_vcf_tick(&st->vcf[a], &c->vcf[a], ilv_nmix[a], ilv_reso[a], ilv_7536[a]);
                eb_modcv_latch(&st->mod[a], ilv_decimo[a]);
                vout[a] = eb_vca_tick(&st->vca[a], &c->vca[a], oa, ilv_e1[a], ilv_e2[a], ilv_6848[a], st->glide[a].s560);
                p = a + 1;
            }
        }
    }
#endif
#ifdef EB_VOICES_DEBUG
    { extern unsigned long ebdbg_n; ++ebdbg_n; }
#endif
    return EB_RENDER_OK;
}

/* The original entry point, unchanged in meaning: one core, every voice. It
 * is the SAME code, not a copy, so the split cannot drift from it. */
int eb_engine_render_voices(eb_engine *e, eb_render_state *st,
                            const eb_render_coefs *c, const eb_render_needs *n,
                            float *vout)
{
#if EB_SPLIT_TEST
    /* EB_SPLIT_TEST=N drives the SAME two calls the two-core firmware makes,
     * on one core and in order, so the whole 36-scenario battery can gate the
     * split. It must be EXACTLY 0 -- the split moves no arithmetic, it only
     * chooses which core runs it.
     *
     * WHY THIS EXISTS AND A LOCAL HARNESS DID NOT DO: a hand-written probe on
     * the firmware's own blob showed the split bit-identical AND showed both
     * noise perturbations passing, because that patch's noise level is 0. The
     * noise path was gated by scenario coverage, not by construction. */
    eb_shared_tick sh;
    sh.ready = 0;
    eb_engine_render_shared(e, st, c, &sh);
    (void)eb_engine_render_range(e, st, c, n, 0, EB_SPLIT_TEST, &sh, vout);
    return eb_engine_render_range(e, st, c, n, EB_SPLIT_TEST,
                                  EB_NUM_VOICES, &sh, vout);
#else
    return eb_engine_render_range(e, st, c, n, 0, EB_NUM_VOICES,
                                  (eb_shared_tick *)0, vout);
#endif
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


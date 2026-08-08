/* eb_render.h — eb_engine_render(): one stereo sample from engine B state only.
 *
 * WHAT THIS IS. The per-sample chain of the shipped engine: the thirteen gated
 * modules called in the port's order, reading and writing engine B's own
 * structs, touching no port memory cell anywhere. It is what
 * `tools/engineb/standalone_cost.c` was written toward and what the whole
 * step-by-step marshalling removal has been converging on.
 *
 * WHAT IT IS NOT, AND THIS MUST NOT BE MISREAD. It is **not yet a complete
 * engine**, and it will refuse to run as one -- see EB_RENDER_INCOMPLETE below.
 * Engine B has thirteen modules; the port's voice function contains more work
 * than those thirteen cover, and that remainder has NOT been transcribed.
 *
 * MEASURED, host callgrind, 8 voices, patch 20, 48 kHz, after four rounds of
 * marshalling removal:
 *
 *     whole engine through the harness      29,647 instr/sample
 *     engine B's own DSP (the thirteen)     15,431
 *     STILL IN THE PORT'S voice function    10,267   <- not yet engine B's
 *
 * That 10,267 is now mostly REAL WORK rather than glue, and it is diffuse: a
 * 100-line-band profile finds no hot spot above 1,504 instructions per sample.
 * It is the LFO, the glide and portamento, key tracking and velocity, the
 * CONDITION scatter, and the per-sample derivation that feeds the modules'
 * inputs. Until those are modules too, this function cannot produce the
 * plugin's samples, because it does not have their values.
 *
 * SO WHAT DOES IT DO WITH THEM? It takes them from `eb_voice`/`eb_engine`
 * fields, and every one of those fields is listed in EB_RENDER_NEEDS below.
 * That is the point of writing the function now rather than last: the missing
 * work becomes an enumerated list of named inputs instead of a vague "the rest
 * of the port". Each entry is a block still to be claimed, in exactly the way
 * the decimator, the noise SVF, the pitch polynomial and the CV/gate block were
 * claimed -- write the module, gate it at EXACTLY 0, delete the field here.
 *
 * HOW IT WILL BE GATED, unchanged from docs/engineb/STANDALONE.md and not
 * weakened for being new:
 *   - null_b.py, all 30 scenarios, EXACTLY 0 against the port
 *   - plugin_check.py against the PLUGIN at 44,100 and 48,000 Hz, BIT-EXACT
 *   - its own measured teeth bracket
 * None of those can run until EB_RENDER_NEEDS is empty. Nothing here claims
 * otherwise, and the runtime guard makes it impossible to claim by accident.
 */
#ifndef ENGINEB_EB_RENDER_H
#define ENGINEB_EB_RENDER_H

#include "eb_types.h"
#include "eb_envgen.h"
#include "eb_pwm_cv.h"
#include "eb_vcf_cv.h"
#include "eb_vcf_ladder.h"
#include "eb_vca_hpf.h"
#include "eb_dco.h"
#include "eb_dco_wt.h"
#include "eb_decim.h"
#include "eb_noise_svf.h"
#include "eb_cvgate.h"
#include "eb_lfo.h"
#include "eb_glide.h"
#include "eb_notecv.h"
#include "eb_noisemix.h"
#include "eb_vcf_res.h"
#include "eb_dcoprep.h"
#include "eb_pitch.h"
#include "eb_chorus.h"
#include "eb_delay.h"
#include "eb_reverb.h"
#include "eb_master.h"

/* The per-voice coefficient sets. In the shipped engine these are computed once
 * at recall. They are here rather than in eb_types.h because that header is
 * included by every module header, so pulling the module types into it would be
 * circular -- and they are COEFFICIENTS, not state, which is the distinction
 * that lets a voice be reset without touching them. */
typedef struct {
    eb_env_coef       env[EB_NUM_VOICES][2];
    eb_modcv_coef     mod[EB_NUM_VOICES];
    eb_vcf_cv_derived cv[EB_NUM_VOICES];
    eb_vcf_coef       vcf[EB_NUM_VOICES];
    eb_vca_coef       vca[EB_NUM_VOICES];
    eb_dco_coef       dco[EB_NUM_VOICES];
    eb_decim_coef     dec[EB_NUM_VOICES];
    eb_nsvf_coef      nsv[EB_NUM_VOICES];
    eb_lfo_coef       lfo[EB_NUM_VOICES];
    eb_glide_coef     glide[EB_NUM_VOICES];
    /* THE NOISE IS ENGINE-WIDE, NOT PER VOICE, and the singular here is the
     * whole point. Its cells live in the port's SHARED region (base+84272..),
     * not in any voice's block, and juno_driver.c snapshots and RESTORES that
     * region before each voice so all eight step from the same state and read
     * an identical one-step advance -- leaving it advanced exactly once per
     * sample. Carrying it per voice would step it eight times too fast, which
     * is audible and is a bug an earlier driver version actually shipped. */
    eb_notecv_coef    notecv;
    eb_noisemix_coef  nmix[EB_NUM_VOICES];
    eb_vcf_res_coef   res[EB_NUM_VOICES];
    eb_dcoprep_coef   dprep[EB_NUM_VOICES];
    /* eb_cvgate's inputs. MEASURED against the port (:657-681): they are cells
     * 176, 208, 272*240, 304 and 544 -- all recall values. The envelopes do
     * NOT feed this block; an earlier draft of eb_engine_render passed e1/e2
     * here, which is why 'drive' and 'held' looked like unknown per-sample
     * inputs when they are in fact coefficients. */
    float             cvg_t28[EB_NUM_VOICES];       /* cell 176  */
    float             cvg_t29[EB_NUM_VOICES];       /* cell 208  */
    float             cvg_k[EB_NUM_VOICES];         /* 272 * 240 */
    float             cvg_p28[EB_NUM_VOICES];       /* cell 304  */
    float             cvg_gate_off[EB_NUM_VOICES];  /* cell 544  */
    /* THE PITCH BLOCK's two inputs, both recall cells (no writer anywhere in
     * voice_render): the polynomial's CV OFFSET and its GAIN. An earlier draft
     * of eb_engine_render called eb_pitch_eval(pit, 1.0f) -- dropping the
     * offset and inventing the gain. Found by the audit Fable ordered after
     * two other inherited guesses were caught in this same function. */
    float             pitch_off[EB_NUM_VOICES];     /* cell 4448 */
    float             pitch_gain[EB_NUM_VOICES];    /* cell 3840 -> 3792 */
    /* cells 368/384: key-follow and velocity. Plain recall reads that the
     * port makes inside the notecv range, so they are coefficients here
     * rather than per-sample inputs. */
    float             kbd[EB_NUM_VOICES];
    float             vel[EB_NUM_VOICES];
    /* cell 2560+off: the per-envelope LFO TRIG switch. */
    float             env_lfo_trig[EB_NUM_VOICES][2];
    /* the external LFO inputs and gate: plain recall cells 944/976/1008 that
     * the port reads inside the LFO's line range. Coefficients, not state. */
    float             lfo_ext_gate[EB_NUM_VOICES];
    float             lfo_ext0[EB_NUM_VOICES];
    float             lfo_ext1[EB_NUM_VOICES];
    /* The FX are engine-wide, not per voice. They live here for the same
     * reason as the rest: eb_types.h cannot see the module types. eb_fx in
     * eb_types.h is the older skeleton layout and holds raw buffers, not
     * module state; it is left alone rather than half-converted. */
    eb_chorus_coef    chorus;
    eb_delay_cfg      delay;
    eb_reverb_cfg     reverb;
} eb_render_coefs;

/* The per-voice state eb_engine_render() drives. Same reasoning: module types.
 * This is where eb_voice's own fields end up once the standalone engine owns
 * the whole chain; until then it is a separate struct so eb_types.h stays free
 * of module dependencies. */
typedef struct {
    eb_env_state    env[EB_NUM_VOICES][2];
    eb_modcv_state  mod[EB_NUM_VOICES];
    eb_vcf_cv_state cv[EB_NUM_VOICES];
    eb_vcf_state    vcf[EB_NUM_VOICES];
    eb_vca_state    vca[EB_NUM_VOICES];
    eb_dco_state    dco[EB_NUM_VOICES];
    /* The DCO's pitch and pulse width are MODULATED EVERY SAMPLE, so the coef
     * struct that carries them cannot be the const recall one. A live copy per
     * voice is seeded from the recall coefficients and has its pitch fields
     * rewritten each sample. The alternative -- casting const away on the
     * recall struct -- would work today and be a trap the first time two voices
     * or two threads shared one. */
    eb_dco_coef     dco_live[EB_NUM_VOICES];
    unsigned char   dco_live_seeded[EB_NUM_VOICES];
#if EB_DCO_WT
    /* THE BAND-LIMITED DCO's per-voice state and its live coefficients. The
     * residual TABLES are not here: they are shared by every voice and every
     * pitch (eb_dco_wt.h findings 4 and 5), so they live once in the module. */
    eb_dco_wt_state wt[EB_NUM_VOICES];
    eb_dco_wt_coef  wt_live[EB_NUM_VOICES];
#endif
    eb_decim_state  dec[EB_NUM_VOICES];
    eb_nsvf_state   nsv[EB_NUM_VOICES];
    eb_lfo_state    lfo[EB_NUM_VOICES];
    eb_glide_state  glide[EB_NUM_VOICES];
    eb_notecv_state notecv;         /* engine-wide; see eb_render_coefs */
    eb_vcf_res_state res[EB_NUM_VOICES];
    /* cell 320 after the port's aux latch: eb_notecv_tick's gate_in. */
    float           gate_cell320[EB_NUM_VOICES];
    /* THE DCO RETRIGGER ONE-SHOT, port cell 101504 + v*32. It is NOT inside any
     * claimed module: the port reads it at :589, and when it is 1.0 it forces
     * this sample's cell-320 read to 0.0 (:592), then clears the one-shot at
     * :2178. Both sites are outside every module boundary, so the standalone
     * engine has to own the latch itself or it silently never retriggers -- the
     * exact defect class the MONO retrigger fix (e611f7d) already cost this
     * project once, and one that no COLD scenario can see. Set by a note event,
     * consumed by the first sample after it. */
    unsigned char   aux_edge[EB_NUM_VOICES];
    eb_chorus_state chorus;
    eb_delay_state  delay;
    eb_reverb_state reverb;
    /* the reverb's pending-tap array and wipe arm: real storage, never NULL */
    /* EB_REV_NTAP (34), not 33: eb_reverb_process reads EB_REV_NTAP entries.
     * The [33] here was the same off-by-one found in eb_master_state, where it
     * cost the reverb's B channel its last bits. Fixed in both. */
    int32_t         rev_pending[EB_REV_NTAP];
    int32_t         rev_wipe;
} eb_render_state;

/* EB_RENDER_NEEDS — THE LIST IS EMPTY, and this time nothing is defaulted.
 *
 * It started at eight. Every entry was removed by claiming the block that
 * produces it, never by choosing a value. The last two closed without any new
 * transcription at all, because both were values engine B already computed
 * and simply had not routed:
 *   cell 3808 IS eb_modcv_tick's `pwm_out` (eb_pwm_cv.c:91 says so);
 *   cell 3536 IS eb_modcv_tap()'s one-sample delay of 3520 (:1076) --
 * and 3520 is the DECIMATOR's return value (:2174), so the latch stores
 * `decimo` after the decim call, and the tap is taken at the top of the next
 * sample. The first routing latched the PWM sum here; review caught it by
 * reading :2170's operands.
 *
 * The struct is kept, empty, on purpose: it is the place a future input goes
 * if one is ever found, and a caller that passes NULL still compiles.
 *
 * THE GUARD DOES NOT COME OFF FOR THIS. An empty list is not the finish line;
 * the three gates named at the top of this header are. Outstanding:
 *   - the standalone shim (eb_coefs feeds it) is not written yet, so
 *     eb_engine_render has never rendered a scenario;
 *   - eb_engine.c's note handling drives eb_alloc (gated) but does not yet
 *     apply its RETRIG / PORTA_GATE events to the CV modules;
 *   - the two delayed copies in port range :1665-1671 are still unmodelled.
 * render_ok stays unset until null_b, plugin_check and a teeth bracket have
 * all run against this function. */
typedef struct {
    int unused;
} eb_render_needs;

/* Render one stereo sample. `n` supplies the values listed above.
 *
 * RETURNS EB_RENDER_INCOMPLETE and writes silence unless the caller has set
 * e->render_ok, which nothing sets today. That is deliberate: a half-finished
 * render that silently produces plausible audio is exactly how this project
 * would end up shipping something it had never gated. It must be impossible to
 * use this by accident before its gates exist. */
#define EB_RENDER_OK          0
#define EB_RENDER_INCOMPLETE  1

int eb_engine_render(eb_engine *e, eb_render_state *st, const eb_render_coefs *c,
                     const eb_render_needs *n,
                     eb_master_state *ms, const eb_master_coef *mc,
                     const eb_master_rings *rings,
                     float *outL, float *outR);

/* THE VOICE CHAIN ALONE: one mono sample per voice into vout[EB_NUM_VOICES],
 * no summing and no FX. eb_engine_render() is this plus the mix and the FX.
 *
 * WHY IT IS SEPARATE, and it is not a convenience. `null_b.py --module voices`
 * gates exactly this against the port by feeding vout into the PORT's own
 * master stage, so the residual it measures is the voice chain's and nothing
 * else. That gate is WEAKER than the standalone gate -- the master chain is
 * still the port's -- and docs/engineb/PHASE1_ORDERS.md labels it so. It exists
 * because eb_engine_render had never been EXECUTED, and eight wrong inputs had
 * already been found in it by reading alone.
 *
 * Obeys the same guard as eb_engine_render: silence and EB_RENDER_INCOMPLETE
 * unless the caller has set e->render_ok. */
/* THE TWO-CORE SPLIT.
 *
 * eb_engine_render_voices() renders every voice on the calling core. Every
 * measurement this project has taken was therefore SINGLE CORE, while the
 * budget it was measured against assumed two -- the S3's second core has
 * never run a sample.
 *
 * The voices are independent: voice v touches only slot v of every array in
 * eb_render_state. Three things are NOT per voice and must be computed once:
 * the shared noise LFSR (advancing it per voice steps it N times too fast --
 * a bug an earlier driver shipped), and under EB_LFO_SHARED the one LFO,
 * whose input is voice 0's glide output. So voice 0's owner computes them and
 * publishes; the other core consumes them.
 *
 * eb_engine_render_range() renders voices [v0,v1). With sh == NULL it does
 * the shared work itself and stores it for the other core; with sh non-NULL
 * it uses what it is given. eb_engine_render_voices() is exactly
 * render_range(0, EB_NUM_VOICES, NULL), which is what keeps the split from
 * being a second implementation of the chain. */
typedef struct {
    float noise_v;
    float lfo_del, lfo_und, lfo_pul;
    /* voice 0's control-rate outputs, computed by the prologue so its range
     * does not run them twice. The LFO's input is voice 0's glide, which is
     * why the prologue must reach this far and no further. */
    float v0_pit_in, v0_gate_sign, v0_dly_env, v0_pitch_cv;
    int   v0_atrest;              /* voice 0 took the at-rest branch */
    int   ready;                  /* the publishing core sets this last */
} eb_shared_tick;

/* THE PROLOGUE. Computes ONLY what both cores need before either can start:
 * the shared noise, voice 0's cvgate and glide, and the shared LFO. Without
 * it core 1 must wait for core 0 to finish a whole voice, which serialises
 * one voice in six and caps the split near 1.5x instead of 2x.
 *
 * After this call, eb_engine_render_range() with sh->ready set consumes the
 * result -- including for voice 0, whose glide state this call has already
 * advanced. Calling the range without the prologue (sh == NULL) is still the
 * single-core path and is unchanged. */
void eb_engine_render_shared(eb_engine *e, eb_render_state *st,
                             const eb_render_coefs *c, eb_shared_tick *sh);

int eb_engine_render_range(eb_engine *e, eb_render_state *st,
                           const eb_render_coefs *c, const eb_render_needs *n,
                           int v0, int v1, eb_shared_tick *sh, float *vout);

int eb_engine_render_voices(eb_engine *e, eb_render_state *st,
                            const eb_render_coefs *c, const eb_render_needs *n,
                            float *vout);

#endif /* ENGINEB_EB_RENDER_H */

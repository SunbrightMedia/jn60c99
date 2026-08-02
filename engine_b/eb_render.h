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
#include "eb_decim.h"
#include "eb_noise_svf.h"
#include "eb_cvgate.h"
#include "eb_pitch.h"
#include "eb_chorus.h"
#include "eb_delay.h"
#include "eb_reverb.h"

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
    eb_decim_state  dec[EB_NUM_VOICES];
    eb_nsvf_state   nsv[EB_NUM_VOICES];
    eb_chorus_state chorus;
    eb_delay_state  delay;
    eb_reverb_state reverb;
    /* the reverb's pending-tap array and wipe arm: real storage, never NULL */
    int32_t         rev_pending[33];
    int32_t         rev_wipe;
} eb_render_state;

/* EB_RENDER_NEEDS — the inputs this function cannot yet compute.
 *
 * Each is supplied per sample by the caller today. Each is a port block that
 * has not been made a module. The list IS the remaining work, and it shrinks by
 * one entry per block claimed.
 *
 *   gate        the three-way gate sign and its ramp        (partly: eb_cvgate)
 *   lfo_del     the delayed LFO output                      (LFO block)
 *   lfo_undel   the undelayed LFO output                    (LFO block)
 *   pitch_cv    the final pitch CV before the polynomial    (glide/portamento)
 *   kbd         key-follow amount for this voice            (key tracking)
 *   vel         velocity contribution                       (note handling)
 *   drive       the VCF drive / resonance compensation      (VCF CV remainder)
 *   held        the engine-wide "any key held" flag         (note handling)
 *
 * When this struct is empty the function is the engine. */
typedef struct {
    float gate;
    float lfo_del, lfo_undel;
    float pitch_cv;
    float kbd;
    float vel;
    float drive;
    float held;
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
                     const eb_render_needs *n, float *outL, float *outR);

#endif /* ENGINEB_EB_RENDER_H */

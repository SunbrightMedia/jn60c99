/* eb_types.h — engine B's data structures.
 *
 * THE PROBLEM THIS SOLVES. The sealed port in src/ is a transcription of a
 * decompile, so every intermediate value round-trips through a flat 12 MB byte
 * array addressed by offset macros: MEASURED, 9,850 memory accesses per sample,
 * 620 distinct cells per voice per sample, each landing on its own 16-byte
 * boundary. On a Daisy Seed that is 669,682 cycles per sample against an 8,333
 * budget, and 68 cycles times 9,850 accesses accounts for the whole of it to
 * 0.02%. The port is not slow because its arithmetic is heavy; it is slow
 * because it never keeps anything in a register.
 *
 * SO THE RULES HERE ARE:
 *   1. Plain C structs and locals. No flat byte array, no offset macros.
 *   2. The per-sample working set of one voice is CONTIGUOUS and at the FRONT of
 *      the struct, so a voice's hot state is a handful of cache lines rather
 *      than 620 scattered ones.
 *   3. Control-rate state (recomputed on a parameter change or once per block)
 *      sits behind it and is never touched in the inner loop.
 *   4. Nothing that can be recomputed cheaply is stored.
 *
 * BUDGETS (docs/engineb/SCOPE.md, user-set):
 *   per voice hot state   < 1 KB   (the port uses 10,512 B)
 *   all voices            < 8 KB
 *   total internal RAM    < 200 KB
 * These are enforced by _Static_assert below and re-reported by
 * engine_b/tests/test_sizes.c, so a field added carelessly is a build error and
 * not a discovery on silicon.
 *
 * FIELD PROVENANCE. The field SET is INFERRED from the JUNO-60 architecture and
 * from what the port's own recall writes; no field's LAW is claimed here. Laws
 * arrive per module, each with its own gate, from docs/engineb/ and
 * scratchpad/engineb/ (cutoff sweeps, resonance and HPF laws, filter response,
 * spline fits) or from the oracle. A struct is a place to put answers, not an
 * answer.
 */
#ifndef ENGINEB_EB_TYPES_H
#define ENGINEB_EB_TYPES_H

#include <stdint.h>
#include "eb_freerun.h"

#define EB_NUM_VOICES 8

/* ------------------------------------------------------------------ voice
 *
 * ORDER IS LOAD-BEARING. Group 1 is everything read or written on EVERY sample
 * of a sounding voice; it is sized so that it fits in a small number of cache
 * lines and so that the compiler can hold most of it in registers across the
 * inner loop. Group 2 is written when a parameter or a note changes and read
 * only when group 1 is recomputed. Group 3 is bookkeeping for the allocator.
 *
 * Every float here is `float`. The ESP32-S3's FPU is single-precision and has
 * no divider: MEASURED-STATIC, the sealed port compiled for the S3 emits 168
 * soft-float helper calls per sample, 158 of them soft DOUBLE
 * (docs/engineb/COST_RIG.md). Engine B must never emit one. There is therefore
 * no `double` in this file, and there must never be one.
 */
/* One envelope generator. 16 bytes, so a voice's two of them are one quarter of
 * a cache line rather than two scattered regions. */
typedef struct {
    float   level;
    float   coef;              /* one-pole coefficient of the current stage  */
    float   target;
    uint8_t stage;             /* EB_ENV_*                                   */
    uint8_t atrest;            /* level is exactly 0 and stage is IDLE       */
    uint8_t pad[2];
} eb_env;

enum { EB_ENV_IDLE = 0, EB_ENV_ATTACK, EB_ENV_DECAY, EB_ENV_SUSTAIN,
       EB_ENV_RELEASE };
enum { EB_ENV1 = 0, EB_ENV2 = 1 };

typedef struct {
    /* ---- group 1: per-sample hot state ---------------------------------- */
    /* free-running: advanced even when the voice is silent (eb_freerun.h) */
    eb_phase dco;              /* main DCO phase accumulator                 */
    eb_phase sub;              /* sub-oscillator phase accumulator           */

    /* oscillator mix, already folded to the values the inner loop multiplies */
    float lvl_saw;
    float lvl_pulse;
    float lvl_sub;
    float lvl_noise;
    float pw;                  /* current pulse width, 0..1                  */

    /* VCF: 4-pole state + the two coefficients the inner loop needs          */
    float vcf_z1, vcf_z2, vcf_z3, vcf_z4;
    float vcf_g;               /* per-sample cutoff coefficient              */
    float vcf_k;               /* per-sample resonance feedback              */

    /* HPF: the JUNO's non-resonant high pass                                */
    float hpf_z1, hpf_z2;
    float hpf_g;

    /* TWO envelopes, as the instrument has: ENV1 opens the filter, ENV2 drives
     * the amp (the port's own naming, and its "pluck has a slow attack" bug was
     * exactly a voice that ran the filter off the wrong one). NOT free-running:
     * see eb_freerun.h -- an envelope may not be "advanced by n", it may only be
     * skipped once it is exactly at rest, which is what atrest records. */
    eb_env env[2];             /* [EB_ENV1] filter, [EB_ENV2] amp            */
    float amp;                 /* VCA gain actually applied this sample      */

    /* portamento / pitch, per-sample because it glides                       */
    float pitch;               /* current pitch, in the DCO's own units      */

    /* ---- group 2: control-rate state ------------------------------------ */
    float pitch_target;
    float porta_coef;
    float env_rate[2][3];      /* attack / decay / release coefficients      */
    float env_sus[2];          /* sustain levels                             */
    float env_to_vcf;
    float env_to_pwm;
    float lfo_to_vcf;
    float lfo_to_pitch;
    float lfo_to_pwm;
    float kbd_track;
    float vca_level;           /* patch VCA level x velocity                 */
    float cutoff_base;         /* recalled cutoff before modulation          */
    float cond_detune;         /* CONDITION scatter, per voice, deterministic */
    float cond_scale;

    /* ---- group 2b: state the SHIMS still keep in the port's cells --------
     * These fields are the standalone engine's whole reason for existing
     * (docs/engineb/STANDALONE.md). While a module is gated as a shim it keeps
     * its state in the port's memory cells and reloads it every sample, so the
     * null harness can substitute one module at a time. That reload is not
     * free and it is not small: MEASURED on the host, 8 voices, 48 kHz, the
     * marshalling costs 27,585 executed instructions per sample, 56.6 % of the
     * whole engine, and the two lines that copy the ladder history in and out
     * account for 9,088 of it on their own.
     *
     * Declaring the fields here does NOT switch anything over. The shims keep
     * working exactly as they do until the standalone render path is gated;
     * these are the destination, added first so the modules being written now
     * have a home and are not written twice.
     *
     * A note on the decimator, because it is the one that proved the point:
     * it is the first module that tried to own its state, and it could not be
     * gated as a shim at all -- a `static` array outlives the engine context,
     * and the harness builds a new context per scenario. See
     * engine_b/wip/README.md. */
    float vcf_hist[24];        /* ladder delay chain, port cells 8208..8544  */
    float decim_h[4][8];       /* 4x polyphase FIR history, cells 4944..5440 */
    unsigned decim_w;          /* rotating index; the port shifts 30 cells   */
    float decim_b1, decim_b2, decim_b3;   /* biquad, cells 5488/5472/5504    */

    /* ---- group 3: allocator / note bookkeeping -------------------------- */
    uint32_t age;              /* allocation order (LRU)                     */
    uint8_t  note;             /* MIDI note, 0xFF = none                     */
    uint8_t  vel;
    uint8_t  gate;             /* key held                                    */
    uint8_t  active;           /* producing audio                             */
    uint8_t  atrest;           /* both envelopes at exactly 0 AND all filter,
                                  HPF and glide state at exactly 0: the ONLY
                                  condition under which the AUDIO work may be
                                  skipped. The STATE ADVANCE is never skipped
                                  (eb_freerun.h).                             */
    uint8_t  pad[3];
} eb_voice;

/* ------------------------------------------------------------------ params
 *
 * The DECODED patch. Engine B's ONLY parameter input is the 118-byte compact
 * patch (docs/preset/COMPACT_FORMAT.md, PROVEN: 64/64 factory patches reproduce
 * the engine state EXACTLY from those 118 bytes). eb_patch.c turns those bytes
 * into this struct; nothing else may write it.
 *
 * These stay as the instrument's own 0..255 BYTES here. Every JUNO-60 parameter
 * is already a single byte -- that is the instrument's resolution, not a
 * compression choice -- so the byte is the honest storage, and the conversion to
 * a coefficient is each module's own law, gated per module. Converting early
 * would bake in a law that has not been proven yet.
 */
typedef struct {
    /* --- resolved: the blob position is transcribed from the port's own
     *     recall (src/juno_apply.c), which is itself gated against the plugin */
    uint8_t lfo_delay, lfo_rate, dco_lfo, vcf_lfo;
    uint8_t dco_pwm_depth, dco_pwm_src, dco_range;
    uint8_t dco_pulse, dco_saw, dco_sub, dco_noise;
    uint8_t vcf_freq, vcf_res, hpf, vcf_env, vcf_kbd;
    uint8_t env1_a, env1_d, env1_s, env1_r;      /* filter envelope          */
    uint8_t env2_a, env2_d, env2_s, env2_r;      /* amp envelope             */
    uint8_t chorus_mode, reverb_level, delay_level, delay_time;
    uint8_t portamento, assign_mode, bend_range, delay_sync, vca_level;
    uint8_t vca_mode, condition, hpf_type, delay_type, vcf_env_src;
    uint8_t arp_sw, arp_type, arp_step;

    /* --- NOT YET LOCATED. These are real JUNO-60 parameters engine B will
     *     need; their blob positions have not been derived here and are NOT
     *     guessed. eb_patch_decode() counts them as UNRESOLVED, separately from
     *     parameters that are located but not carried by the 118 bytes. */
    uint8_t effect_type, effect_depth, delay_fb, reverb_type, reverb_time;
    uint8_t legato, transpose;
    uint8_t dly_hicut, dly_locut, dly_lfdamp, dly_hfdamp;
    uint8_t cho_hicut, cho_locut, cho_predelay;
    uint8_t rev_predelay, rev_locut, rev_hicut, rev_density;
} eb_params;

/* ------------------------------------------------------------------ FX
 *
 * Delay-line lengths are a COMPILE-TIME BUDGET, exactly as docs/engineb/SCOPE.md
 * requires, so that the total-RAM figure is a number this file can assert rather
 * than something discovered when a board fails to link. They are PLACEHOLDERS:
 * the real lengths come from each FX module's own extraction, and changing one
 * changes only these three lines. On a part with PSRAM the delay and reverb
 * buffers are the two that may move out.
 */
#ifndef EB_CHORUS_LEN
#define EB_CHORUS_LEN 1024        /* BBD line, per channel                    */
#endif
#ifndef EB_DELAY_LEN
#define EB_DELAY_LEN  12000       /* 250 ms at 48 kHz, per channel            */
#endif
/* EB_REVERB_LEN IS GONE. It was a skeleton placeholder of 8,192 floats for
 * "the whole comb/allpass network", and it was 6.0x too small: the reverb is 13
 * separate delay elements totalling 49,824 floats = 199,296 B at the 48 kHz
 * worst case (MEASURED, docs/engineb/FX_REVERB.md section 7 and
 * sizeof(eb_reverb_state)). The budget now lives in engine_b/eb_reverb.h as one
 * EB_REV_CAP_* per element, because the four long loop delays (138,104 B) must
 * be placeable separately from the nine short ones (61,192 B). A single length
 * cannot express that, which is why the placeholder is deleted rather than
 * corrected. */

typedef struct {
    /* free-running: the chorus LFO must advance while the engine idles, which
     * is one of the things the idle-prefix scenarios exist to catch */
    eb_phase cho_lfo;
    uint32_t cho_w, dly_w, rev_w;         /* write indices                    */
    float    cho_depth, cho_rate_hz, cho_mix;
    float    dly_fb, dly_mix; uint32_t dly_taps;
    float    rev_fb, rev_mix;
    float    cho[2][EB_CHORUS_LEN];
    float    dly[2][EB_DELAY_LEN];
    /* the reverb tank is eb_reverb_state (engine_b/eb_reverb.h), 199,640 B */
} eb_fx;

/* ------------------------------------------------------------------ engine */
typedef struct {
    /* free-running shared state. The noise LFSR steps once per sample for the
     * whole engine, never once per voice: the plugin runs isolated units in
     * lockstep, so all voices read the same one-step advance. Stepping it per
     * voice runs it 8x too fast -- a mistake the port had to fix once already. */
    eb_noise noise;
    eb_phase lfo;
    float    lfo_val;          /* this sample's LFO output, shared by voices  */
    float    lfo_delay_env;

    float    sr;
    uint32_t age_counter;
    uint32_t held[4];          /* 128-bit held-note mask (mono/unison law)    */

    eb_params p;
    eb_voice  v[EB_NUM_VOICES];
    eb_fx     fx;
} eb_engine;

/* ------------------------------------------------------------------ budgets */
#if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 201112L
_Static_assert(sizeof(eb_voice) <= 1024,
               "eb_voice exceeds the 1 KB per-voice budget (SCOPE.md)");
_Static_assert(sizeof(eb_voice) * EB_NUM_VOICES <= 8192,
               "all-voice hot state exceeds the 8 KB budget (SCOPE.md)");
_Static_assert(sizeof(eb_engine) <= 200u * 1024u,
               "eb_engine exceeds the 200 KB total-internal-RAM budget");
#endif

#endif /* ENGINEB_EB_TYPES_H */

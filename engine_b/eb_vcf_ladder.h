/* eb_vcf_ladder.h — ENGINE B MODULE M-VCF: the 4-pole ladder CORE.
 *
 * SCOPE. This module owns src/voice_render.c:1298-1515 and nothing else: the
 * ladder's input node, its FOUR 4x-oversampled sub-steps (ZDF solve ->
 * saturation -> four cascaded bilinear one-poles), the four dispersion lines
 * they feed, and the 32-tap folded decimating FIR that produces the VCF output
 * cell [9040]. The cutoff->coefficient mapper that produces G and k
 * (:1230-1297) is a DIFFERENT module and is consumed here as two arguments.
 *
 * PROVENANCE. Every equation below is READ from src/voice_render.c:1298-1515,
 * line by line, and cross-checked against docs/trackb/VCF.md §3.8-3.9. Where
 * the two disagreed the ORACLE was driven and it decided; the one disagreement
 * found is recorded in eb_vcf_ladder.c and in docs/engineb/MVCF_LADDER_RESULT.md.
 *
 * TOPOLOGY, as EXTRACTED (the task asks for this explicitly):
 *   * 4x oversampling. FOUR sub-steps per host sample, input linearly
 *     interpolated between last sample's drive and this one's with weights
 *     0.25 / 0.5 / 0.75 / 1.0 (cells [9232]/[9248]/[9216]/[9200]).
 *   * FOUR one-pole stages per sub-step, each a bilinear integrator
 *         y[n] = G*(x[n] + x[n-1]) + (1-2G)*y[n-1]
 *     with G = g/(1+g), g = tan(pi*fc/(4H)). Tap gains [9072]/[9088]/[9104] are
 *     0 / 0 / 1.0, so the output is the 4-pole (24 dB/oct) tap ONLY; the 12 and
 *     18 dB taps are computed and multiplied by zero every sub-step.
 *   * FEEDBACK enters AHEAD of the saturation, at the input node, and is
 *     RESOLVED, not iterated: S is the zero-input response of the whole 4-pole
 *     chain one sub-step ahead, and the node solves u*(1 + k*G^4) = in - k*S
 *     as a straight division. That is why a native rewrite can be straight-line
 *     code with no iteration and no unit-delay error.
 *   * SATURATION sits on the SOLVED node, outside the loop:
 *         x = clamp(x, -1, +1);   nl = x + ((((x*x)*x)*x) * (x * -0.2))
 *     i.e. a hard clip followed by a QUINTIC x - 0.2*x^5. The task's brief says
 *     the curve matters more than the pole count, so it is transcribed in the
 *     source's exact evaluation order and NOT re-expressed: x*(1 - 0.2*x^4) is
 *     algebraically the same number and a different float.
 *   * The four sub-step outputs feed four 8-deep dispersion lines = 32 samples
 *     of 4x history, decimated by a symmetric 32-tap FIR folded into 16
 *     coefficients ([9264]..[9504], centre pair first) and scaled by 4.0.
 *
 * WHAT ENGINE B CHANGES, and why each change is EXACT:
 *   1. The 39-cell shift chain at :1300-1334 disappears. The port moves 7
 *      pipeline cells and 28 dispersion cells by hand EVERY SAMPLE, purely so
 *      last sample's values can be read back from memory. Here the pipeline is
 *      7 floats that are simply not overwritten until they are used, and the
 *      dispersion lines are ONE ring buffer of 32 with a 2-bit phase. Moving a
 *      value is not arithmetic; deleting the move cannot change a number.
 *   2. The four sub-steps become one inlined helper. Sub-step 4 in the port
 *      writes different cells and associates its output tap as
 *      ((y4*c24) + (c18*y3)) + (y2*c12) instead of ((y3*c18) + (y4*c24)) +
 *      (c12*y2). Those differ only by the COMMUTATIVITY of + and *, which is
 *      exact in IEEE-754 for non-NaN, so one helper is correct for all four.
 *   3. The SHADOW stores are dropped: [8992] (z-1 of the dither phase) and the
 *      six scratch cells [8336..8416] that the port writes to memory as well as
 *      to its promoted registers. GREPPED: no reader outside this block. Audio
 *      cannot change; per-cell state parity does, so this is a sonic-identity
 *      claim and not a bit-exact-state one -- the same standing this project
 *      already gave module M7.
 * There is no approximation in this module. The null is expected to be EXACTLY
 * 0, and anything else is a defect, not a budget.
 *
 * SIZE. eb_vcf_state is 172 bytes, of which 128 is the 4x history the
 * decimator cannot do without (32 floats is the FIR's own length). The port
 * spends 8208..8960 = 48 cells x 16 bytes = 768 bytes on the same information.
 */
#ifndef ENGINEB_EB_VCF_LADDER_H
#define ENGINEB_EB_VCF_LADDER_H
#include "eb_fork_config.h"

/* ---------------------------------------------------------------- state
 * Per voice. Hot every sample of a sounding voice; nothing here is
 * free-running in the eb_freerun.h sense EXCEPT the dither phase, which is a
 * self-driving 24-bit wrap oscillator that never looks at the audio -- but it
 * is NOT given an advance(n), because the four one-poles and the 32-deep
 * history around it are input-driven and cannot be skipped, so nothing would
 * be saved by skipping the dither alone.                                    */
typedef struct {
    /* the pipeline: what the previous sub-step left behind */
    float nl;       /* saturator output            (port cell 8208/8224) */
    float y1, y2, y3, y4;               /* the four stages  (8240..8288) */
    float s1, s2;   /* S of the last / second-to-last sub-step (8304/8320) */
#if EB_VCF_ADAA
    /* ADAA needs the PREVIOUS input to the saturation, which nothing else in
     * this filter keeps: st->nl is the saturation's OUTPUT. */
    float xprev;
#if EB_VCF_ADAA >= 2
    float xprev2;                /* ADAA2 needs two inputs back */
    float F2p, F2pp;             /* cached second antiderivatives */
#endif
#endif

    float drive_prev;                   /* previous input drive   (8960) */
    float dith;                         /* dither phase           (8976) */

    float h[32];    /* 4x oversampled tap history, ring, newest at [hi]   */
    int   hi;
} eb_vcf_state;

/* ---------------------------------------------------------- coefficients
 * All INPUT-CONST in the port: written by recall / prepare, never by the
 * render. Named by the port cell so the transcription can be checked against
 * src/voice_render.c without a decoder ring.                                */
typedef struct {
    float c9520, c9536;     /* feedback taps on S, S-1  (1.0 / 0.0)        */
    float c9184;            /* quintic saturation coefficient  (-0.2)      */
    float c9072, c9088, c9104;  /* 12 / 18 / 24 dB tap gains (0 / 0 / 1.0) */
    float c9200, c9216, c9232, c9248;   /* 1.0 / 0.75 / 0.25 / 0.5         */
    float c9120;            /* dither -> input gain                        */
    float c9136;            /* input drive gain           (0.25)           */
    float c9168;            /* resonance -> input-gain compensation (0.5)  */
    float c9152;            /* decimator output gain      (4.0)            */
    float fir[16];          /* [9504] .. [9264], CENTRE PAIR FIRST         */
} eb_vcf_coef;

void  eb_vcf_reset(eb_vcf_state *st);

/* One host sample. `in` is the DCO/noise mix [6544], `G` the ladder integrator
 * gain [7520] and `k` the resonance drive [7536]. Returns the VCF output that
 * the port stores in [9040]. */
float eb_vcf_tick(eb_vcf_state *st, const eb_vcf_coef *c,
                  float in, float G, float k);

/* History accessors, for the gate shim ONLY: they let the null harness keep the
 * module's 4x history in the port's own dispersion cells, so the module
 * inherits the port's create/destroy/eight-voice lifecycle exactly. `i` is a
 * DELAY in 4x samples, 0 = newest. Not used by the engine and not counted in
 * any cycle figure. */
float eb_vcf_hist_get(const eb_vcf_state *st, int i);
void  eb_vcf_hist_set(eb_vcf_state *st, int i, float v);

#endif /* ENGINEB_EB_VCF_LADDER_H */

/* eb_vcf_cv.h — ENGINE B MODULE M-VCFCV: the VCF CUTOFF CV SUMMING network.
 *
 * SCOPE. This module owns src/voice_render.c:1150-1229 and nothing else: the
 * node that combines the recalled CUTOFF, the ENV MOD amount, the LFO, KEY
 * FOLLOW and the velocity/aftertouch legs into the single control value that
 * the cutoff->coefficient mapper (:1230-1297, a DIFFERENT module) turns into
 * the ladder's G. Its outputs are exactly three floats:
 *      cv      -- the summed control value (the port's local v227)
 *      c6704   -- the clamped quartic-spline leg (port cell [6704])
 *      c6848   -- the resonance-side copy         (port cell [6848])
 * The port's own :1230 and :1231 read the latter two out of state; every other
 * cell this block writes is GREPPED to have no reader anywhere in src/ or gui/
 * (see eb_vcf_cv.c, "the dead stores").
 *
 * PROVENANCE. PROVEN by transcription of src/voice_render.c:1150-1229, line by
 * line, then executed: tools/engineb/null_b.py --module vcf_cv.
 *
 * THE BLUEPRINT WAS WRONG, and the oracle decided. docs/trackb/VCF.md describes
 * the cutoff CV path as a per-block control-rate sum. It is NOT: two of its six
 * signal inputs are the per-sample ENV outputs ([752]/[880] and [1792]/[1808]),
 * and three ONE-POLE SMOOTHERS inside the block ([6896], [7088], [7168]) are
 * driven at audio rate. Running this network per block is therefore a change to
 * the sound, not a free move, and the size of that change is MEASURED rather
 * than argued -- see docs/engineb/MVCFCV_RESULT.md.
 *
 * STRUCTURE, as EXTRACTED:
 *   * a QUARTIC spline leg: y = k0 + k1*x + k2*x^2 + k3*x^3 + k4*x^4 evaluated
 *     on a lerped input, clamped to [0,1] -> [6704]. Evaluated in the source's
 *     own Horner-less order, which is NOT Horner and NOT re-associated here.
 *   * THREE one-pole smoothers, all of the shape s += (in - s)*a, each with a
 *     SECOND output tap ((in-s_old)*b + c*s_new) that is not the state.
 *   * two two-term mixers and two lerps, all combinational.
 *   * one final 8-term sum with the source's exact bracketing. -ffp-contract=off
 *     and an x86-SSE2 reference mean the bracketing IS the specification.
 *
 * SIZE. eb_vcf_cv_state is 12 bytes: the three smoother states and nothing
 * else. The port spends 21 cells x 16 bytes = 336 bytes on the same block, of
 * which 18 cells are stores that nothing ever reads.
 */
#ifndef ENGINEB_EB_VCF_CV_H
#define ENGINEB_EB_VCF_CV_H

/* ------------------------------------------------------------------ state */
typedef struct {
    float s_env;   /* port cell [6896] — smoother fed by [6864]            */
    float s_a;     /* port cell [7088] — smoother fed by [1792]            */
    float s_b;     /* port cell [7168] — smoother fed by [1808]            */
} eb_vcf_cv_state;

/* ----------------------------------------------------------- coefficients
 * Recall-written, constant for the sample. Field names carry the port cell so
 * the transcription can be checked against src/voice_render.c by eye. The four
 * "x" members are cells that recall leaves alone in every patch measured, but
 * they are READ as inputs here rather than folded away: "constant in every
 * factory patch" is not a licence (CLAUDE.md, the recall rule).             */
typedef struct {
    float x6576, x6608, x6640, x6672;   /* the four modulation inputs       */
    float k6720, k6736;                 /* the spline's input lerp          */
    float k6752, k6768, k6784, k6800, k6816;   /* the spline, x^0..x^4      */
    float x6832;                        /* -> [6848]                        */
    float k6864, k6928;                 /* smoother s_env: input, rate      */
    float k6944, k6960;                 /* the [6976] mixer                 */
    float k7008, k7024;                 /* the [7072] lerp pair             */
    float k7120, k7136, k7152;          /* smoother s_a: rate, tap, gain    */
    float k7200, k7216, k7232;          /* smoother s_b: rate, tap, gain    */
    float k7296, k7312;                 /* the shared depth / offset pair   */
    float k7328, k7344, k7360, k7376, k7392, k7408, k7424;
    float k7440, k7456, k7472, k7488, k7504;   /* the final sum's weights   */
} eb_vcf_cv_coef;

/* ------------------------------------------------------------------- API
 * One host sample of ONE voice. `in752`/`in880`/`in1792`/`in1808`/`in2752`/
 * `in3232` are the six live inputs the block reads from outside itself.
 * Returns the summed CV (v227); the two escaping cells come back by pointer.
 *
 * There is NO advance(n): every input is produced by an upstream module that
 * itself has to run, and the three smoothers are input-driven, so this module
 * has nothing a silent voice could skip. It is a pure function of its inputs
 * and its 12 bytes of state.
 */
float eb_vcf_cv_tick(eb_vcf_cv_state *st, const eb_vcf_cv_coef *c,
                     float in752, float in880, float in1792, float in1808,
                     float in2752, float in3232,
                     float *out6704, float *out6848);

void eb_vcf_cv_reset(eb_vcf_cv_state *st);

#endif /* ENGINEB_EB_VCF_CV_H */

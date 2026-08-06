/* eb_dco.h — ENGINE B MODULE: THE DCO OSCILLATOR.
 *
 * REPLACES src/voice_render.c:1718-2136 — the FOUR identical 4x-oversampled
 * oscillator sub-blocks. The session brief names 1718-1830; that is sub-block
 * ONE of four. PROVEN (executed, this session, tools/engineb/dco_blockdiff.py):
 * after renaming decompiler temporaries, sub-blocks 1, 2 and 3 are TOKEN-
 * IDENTICAL apart from the polyphase output cell (4944 / 5072 / 5200), and
 * sub-block 4 (cell 5328) differs only in three decompiler artefacts that are
 * the same arithmetic: the sub saturator's `(tri+1.0f)` is hoisted into its own
 * temporary, the carried phase is re-read as JI instead of JF (same bits), and
 * the sub clamp's dead `else -1.0` arm is elided. So the module is ONE function
 * called four times, and this file's per-call cost figure is the honest one.
 *
 * IS THE OSCILLATOR BAND-LIMITED? NO — and that is why this module can be a
 * direct transcription rather than a BLEP rewrite. The waveform generators here
 * are naive: a wrapped phase ramp shaped by juno_triangle, hard sign functions
 * for the pulse and sub squares, and a polynomial saturator. The band-limiting
 * is entirely DOWNSTREAM and OUTSIDE this module: the block runs at 4x the host
 * rate into four polyphase delay lines (cells 4944.., 5072.., 5200.., 5328..)
 * which src/voice_render.c:2137-2172 decimates with a 26-tap FIR plus a
 * correction biquad. Reproducing the plugin's ALIASING therefore means
 * reproducing this arithmetic verbatim; any "better" oscillator would be
 * audibly wrong, not audibly better.
 *
 * THE PHASE WRAP IS THE ONE PLACE A SHORTCUT WAS ALMOST TAKEN AND WAS NOT.
 * The session brief's warning is MEASURED and it holds up: src/voice_render.c
 * :1726, the NEGATIVE wrap arm, executes in none of the 30 null scenarios, but
 * the phase reaches -0.999657 -- 0.0003 from firing. It is live code protected
 * by nothing. eb_dco_wrap() therefore implements both arms, and
 * engine_b/test_dco_wrap.c proves it bit-identical to the reference over ALL
 * 2^32 float32 bit patterns, exactly as triangle.h was. (:1739, the saw
 * saturator's negative clamp, is the OTHER unexecuted line and is a different
 * finding -- its input never approaches -1, margin 1.0 -- but it costs one
 * instruction, so it is implemented too rather than argued about.)
 *
 * PROVENANCE: every equation READ from src/voice_render.c:1718-1825 and
 * cross-checked against the other three sub-blocks by the token diff above.
 * Where docs/trackb/DCO.md and the oracle disagree the ORACLE WINS; the
 * disagreements found are recorded in eb_dco.c.
 *
 * Compiled -ffp-contract=off against an x86 SSE2 reference: every parenthesis
 * below is load-bearing and an algebraically equal regrouping is a different
 * number.
 */
#ifndef ENGINEB_EB_DCO_H
#define ENGINEB_EB_DCO_H

#include <math.h>
#include "eb_fork_config.h"

#if defined(__GNUC__)
#define EB_INLINE static __inline__
#else
#define EB_INLINE static
#endif

/* ------------------------------------------------- THE ONE OPTIONAL INEXACTNESS
 * EB_DCO_RECIP replaces the pulse phase's DIVISION with a multiply by a
 * reciprocal built once per sample. It is OFF by default and the default build
 * of this module contains no approximation at all.
 *
 * Why it exists: the ESP32-S3 has no FPU divider, so GCC emits __divsf3, and
 * this module performs 32 of them per audio sample (one per sub-block per
 * voice). MEASURED-STATIC at 25..180 cycles each, that is 800..5,760 cycles per
 * sample for one operation.
 *
 * What it costs in accuracy, MEASURED, not estimated -- tools/engineb/null_b.py
 * --module dco with EB_DCO_RECIP=1, all 30 scenarios:
 *     worst global residual  -121.1 dB   (gate -100 dB, 21 dB of margin)
 *     worst block  residual  -115.2 dB   (gate  -80 dB, 35 dB of margin)
 *     every scenario PASSES; the exact build is EXACTLY 0 on all 30.
 * So it is a CHOSEN error with a written budget, which is what
 * docs/trackb/ACCURACY_STANDARD.md requires, and it is not free: -121 dB is a
 * real difference from the plugin where the default has none.
 *
 * What it BUYS, MEASURED: on the host, which has a hardware divide, nothing
 * (5,184 -> 5,216 instructions per sample, i.e. noise). The whole saving is on
 * the S3 and it is 16 of the 32 __divsf3 calls, so 400..2,880 cycles per sample.
 * That does not change this module's verdict; see the header note below.       */
#ifndef EB_DCO_PULSEFAST
#define EB_DCO_PULSEFAST 0
#endif

#ifndef EB_DCO_RECIP
#define EB_DCO_RECIP 0
#endif

/* ---------------------------------------------------------------- state
 * EIGHT BYTES per voice. The port spends five cells plus four shadow cells
 * (4640, 4656, 4672, 4832, 4848, 4864, 4880, 4896, 4912) = 144 bytes of address
 * space on the same two numbers, six of those cells existing only to carry a
 * value from the bottom of the sample back to the top.
 *
 * FREE-RUNNING (eb_freerun.h): the DCO reads no gate. `phase` advances by `inc`
 * whatever the voice is doing, so a silent voice may skip its AUDIO work only if
 * this state is still advanced -- analytically, never by omission.            */
typedef struct {
    float phase;   /* carried DCO phase in [-1,1]      (port cells 4864/4880) */
    float subcnt;  /* sub-oscillator counter, 0 or 2   (port cells 4832/4848) */
} eb_dco_state;

/* ---------------------------------------------------------------- coefficients
 * Split in two by UPDATE RATE, which is the point of the split:
 *   - inc/g/pw/pwm1/pwp1 move every sample (they are modulated), and are built
 *     by eb_dco_set_pitch() from the two numbers the CV summing module hands
 *     over. They are shared by all four sub-block calls.
 *   - everything else changes only on a patch recall, so a voice's inner loop
 *     reads one read-only cache line.
 * `pwm1`/`pwp1` are pw-1 and pw+1 precomputed: the same two operands and the
 * same single rounding as the port's own expression, so hoisting them is EXACT.
 * The DIVISION in the pulse phase is NOT hoisted into a reciprocal -- x/y and
 * x*(1/y) are different numbers and this module claims an exact null.        */
typedef struct {
    /* per sample */
    float inc;        /* phase increment       port 4784 = max(5568, cv*5536) */
    float g;          /* 0.00390625f / inc                          port 4800 */
    float pw;         /* pulse width           port 4816 = 5520 + 3808        */
    float pwm1, pwp1; /* pw-1, pw+1                                           */
#if EB_DCO_RECIP
    float rm1, rp1;   /* 1/pwm1, 1/pwp1 -- the RECIPROCAL OPTION, below       */
#endif
    /* per recall */
    float lvl_saw, lvl_pulse, lvl_sub;   /* port 4736, 4752, 4768             */
    float gn_saw,  gn_pulse,  gn_sub;    /* port 5648, 5664, 5680             */
    float amp_saw, amp_pulse, amp_sub;   /* port 5600, 5616, 5632             */
    /* PULSE EDGE SHORT-CIRCUIT (EB_DCO_PULSEFAST). Half-width, in triangle-
     * argument units, of the region around each of tri()'s zero crossings
     * where the clamped edge is NOT saturated. Outside it the edge is
     * EXACTLY +/-1 and neither the triangle nor the saturator polynomial
     * needs evaluating. Derived at recall: the edge is
     * clamp1(tri(x) * g * 256 * amp_pulse), tri has slope 2, so |tri| >= 1
     * once |x - zero| >= 1/(2 * g * 256 * amp_pulse). MEASURED: the
     * saturator's own shortcut already fires on 98.85 % of sub-steps, which
     * is the same population this skips the work for. */
    float pulse_h;
    /* Same short-circuit for the SAW and SUB edges. Both their triangles are
     * NON-NEGATIVE, so the clamp can only saturate to +1 and the guarded
     * band is one-sided in value:
     *   saw: tri_saw(p) peaks 1 at p=0, zero at p=+/-1, slope 1
     *        -> saturated for p in [saw_h - 1, 1 - saw_h]
     *   sub: (tri_sub(-|t|)+1) peaks 1 at |t|=0 and 1, zero at |t|=0.5,
     *        slope 2 -> saturated for | |t| - 0.5 | >= sub_h */
    float saw_h, sub_h;
    float sat_in;                        /* port 5552                         */
    float k3, k5, k7, k9, k11;           /* port 5952, 5968, 5984, 6000, 6016 */
    float subthr;                        /* port 5584                         */
    /* THE CLAMP CONSTANTS. MEASURED: the saturator's input is a clamp to
     * +/-1 of an expression whose magnitude is the phase-ramp slope divided by
     * the phase increment, so it is PINNED at exactly +1.0f or exactly -1.0f
     * for ~97% of sub-samples at a musical pitch. 1.0f*sat_in and -1.0f*sat_in
     * are exact, so on those sub-samples the eleven-term polynomial always
     * evaluates at the SAME two arguments and can be replaced by its two
     * precomputed values. That is a lookup of a number the polynomial would
     * have produced bit for bit -- not an approximation of it.
     * Built by eb_dco_set_shape() on a recall. */
    float sat_hi;                        /* eb_sat(+sat_in)                   */
    float sat_lo;                        /* eb_sat(-sat_in)                   */
} eb_dco_coef;

/* ---------------------------------------------------------------- THE VERDICT
 * THIS MODULE IS ACCURATE AND IT IS NOT AFFORDABLE. Reported here rather than
 * in a document nobody opens.
 *
 * MEASURED (callgrind, host x86-64, all three waveform levels non-zero):
 * 5,184 dynamic instructions per audio sample for the whole DCO -- 8 voices x
 * 4 sub-samples -- of which 4,513 are in eb_dco_step, 141 per invocation, at
 * rho 0.236. Three exact removals took that from 9,350: inlining the wrap,
 * replacing fminf with a compare, and the clamp-constant hoist.
 *
 * MODELED from that measured density (tools/engineb/cost.py):
 *     Cortex-M7   13,841 cyc/sample nominal, band  7,492..28,626
 *     ESP32-S3    17,413 cyc/sample nominal, band 10,329..32,811
 * The tool's band is pessimistic at the top -- it charges the 9 STATIC fmodf
 * call sites at rho, and callgrind shows fmodf never executes at all. A floor
 * built from the S3 static count instead (614 instructions x rho 0.236 = 145
 * per invocation x 32 = 4,640 instructions/sample, at 1 cycle each, plus 32
 * __divsf3 at 25..180) is about 5,400..10,400 cyc/sample.
 *
 * The budget left after the two ADSRs is ~2,300 cyc/sample. So the DCO alone is
 * between 2.3x and 7.5x the WHOLE remaining budget, with the VCF, the mixers
 * and all FX still unpaid. It is also 1.5x..5x the entire 3,500 budget.
 *
 * THE COST IS STRUCTURAL, NOT SLOPPY. 4x oversampling makes 32 invocations per
 * sample, and each one carries three saturators, three triangles and a divide.
 * The only lever large enough to matter is the OVERSAMPLING RATIO, and it is
 * not a tuning knob: the 4x rate feeds the 26-tap polyphase FIR at
 * src/voice_render.c:2137, so 2x would change the decimator, the aliasing and
 * therefore the sound. Its error has NOT been measured and must not be guessed.
 * That measurement is the next decision this module needs, and it belongs to
 * whoever owns the accuracy/affordability trade, not to this file.
 */

/* One 4x-rate sub-sample. Call four times per host sample; the four results are
 * the four polyphase inputs, in order. */
float eb_dco_step(eb_dco_state *s, const eb_dco_coef *c);

/* The four sub-samples of one audio sample, against ONE coefficient load.
 * Bit-identical to four eb_dco_step calls -- same operands, same order, same
 * roundings; only the place the coefficients are read from differs. See the
 * comment above eb_dco_step_i in eb_dco.c. */
void  eb_dco_step4(eb_dco_state *s, const eb_dco_coef *c, float *out);

/* Per-sample coefficient build (the two modulated numbers -> inc, g, pw). */
/* THE SUB-STEP INCREMENT SCALE, IN ONE EXPRESSION, USED BY EVERY PATH.
 *
 * Under EB_HALF_OS the DCO runs 2 sub-steps per audio sample instead of 4, so
 * each step must advance twice the phase to cover the same sample. Getting
 * this wrong is exactly one octave, and it has now been got wrong TWICE, in
 * opposite directions, because the factor lived somewhere only one of the two
 * callers went through:
 *
 *   1. In eb_render.c only -> the SHIM path never doubled -> every note an
 *      octave DOWN. Reported by ear, by the user, after every numeric gate in
 *      the project had passed.
 *   2. Moved into eb_dco_set_pitch only -> eb_render.c assigns
 *      dco_live[v].inc DIRECTLY and never calls set_pitch, so the STANDALONE
 *      path -- the one the listen firmware uses -- went an octave down in its
 *      turn. Caught by fork_authority.py at -1212.1 cents, AFTER I had looked
 *      at a 64.6 Hz fundamental under a 130.8 Hz note and talked myself into
 *      "that will be the sub-oscillator".
 *
 * So it is a function and both callers call it. There is no third place left
 * to put a factor of two. */
/* THE EDGE-SATURATION THRESHOLDS, IN ONE PLACE, USED BY EVERY PATH.
 *
 * They depend on `g`, which CHANGES EVERY SAMPLE (eb_render.c:230 sets it
 * from eb_dcoprep_tick's modulated edge gain). The first version derived
 * them only inside eb_dco_set_pitch, which the SHIM calls per sample but
 * eb_render.c does not -- it assigns dco_live's fields directly. The shim
 * null therefore passed EXACTLY 0 while the STANDALONE path would have run
 * on thresholds frozen at their first value.
 *
 * That is the eb_dco_inc_scale mistake exactly: a derived quantity living
 * where only one of two callers goes through it. It is a function now, and
 * both callers call it. */
EB_INLINE void eb_dco_set_edge_thresholds(eb_dco_coef *c)
{
    float d = (c->g * 256.0f) * c->amp_pulse;
    c->pulse_h = (d > 1e-12f) ? (0.51f / d) : 2.0f;   /* tri slope 2 */
    d = (c->g * 256.0f) * c->amp_saw;
    c->saw_h   = (d > 1e-12f) ? (1.02f / d) : 2.0f;   /* tri_saw slope 1 */
    d = (c->g * 512.0f) * c->amp_sub;
    c->sub_h   = (d > 1e-12f) ? (0.51f / d) : 2.0f;   /* tri_sub slope 2 */
}

EB_INLINE float eb_dco_inc_scale(float inc4)
{
#if EB_DCO_SUBSTEPS == 1
    return inc4 * 4.0f;
#elif EB_DCO_SUBSTEPS == 2
    return inc4 * 2.0f;
#else
    return inc4;
#endif
}

void  eb_dco_set_pitch(eb_dco_coef *c, float inc, float pw);

/* Per-RECALL coefficient build: fills sat_hi/sat_lo from sat_in and k3..k11.
 * Must be called after any of those six change and before eb_dco_step. */
void  eb_dco_set_shape(eb_dco_coef *c);

/* THE PHASE WRAP. Lives in the header and is INLINE for a MEASURED reason: as
 * an out-of-line call it cost 320 host instructions per audio sample -- 10 per
 * invocation, 32 invocations -- to wrap a float that is in range on 217 of
 * every 218 sub-samples.
 *
 * Reference, src/voice_render.c:1723-1731:
 *     if (p <= 1.0f) { if (p < -1.0f) p = fmodf(p - 1.0f, 2.0f) + 1.0f; }
 *     else                            p = fmodf(p + 1.0f, 2.0f) - 1.0f;
 *
 * BOTH ARMS ARE LIVE. The negative arm (:1726) fires in none of the 30 null
 * scenarios and is 0.0003 away from firing in one of them, so a scenario gate
 * cannot protect it and only the exhaustive test can.
 *
 * The leading add is KEPT because it rounds -- that rounding is exactly what
 * made eb_triangle's "obvious" replacement disagree on 8,388,608 of 2^32
 * inputs. Only the libm CALL is removed, and only where the remainder is
 * provably one exact operation: for t = p+1 in [2,4) the subtraction t-2 is
 * exact because both operands are within a factor of two, and t >= 2 always
 * holds in that arm because p > 1. The mirror argument covers the negative arm.
 * Non-finite inputs and anything past +/-4 keep the fmodf path, so nothing is
 * assumed about the domain.
 *
 * PROVEN bit-identical to the reference over ALL 2^32 float32 bit patterns,
 * NaN payloads included: engine_b/test_dco_wrap.c, 0 mismatches. */
static inline float eb_dco_wrap(float p)
{
    if (p <= 1.0f) {
        if (p < -1.0f) {
            float t = p - 1.0f;                       /* rounds -- keep it */
            return (t > -4.0f) ? (t + 2.0f) + 1.0f
                               : fmodf(t, 2.0f) + 1.0f;
        }
        return p;
    } else {
        float t = p + 1.0f;                           /* rounds -- keep it */
        return (t < 4.0f) ? (t - 2.0f) - 1.0f
                          : fmodf(t, 2.0f) - 1.0f;
    }
}

/* Free-run contract (eb_freerun.h). READ THE LIMITATION, it is stated here
 * rather than discovered on silicon: this advance is O(n), NOT O(1), and the
 * contract's O(1) wish cannot be met EXACTLY for this quantity.
 *
 * The reason is the wrap itself. The port wraps with `fmodf(p+1,2)-1`, and that
 * leading add ROUNDS -- the same rounding that made eb_triangle's "obvious"
 * replacement disagree on 8,388,608 of 2^32 inputs. So the phase after n samples
 * is not p + n*inc reduced; it is the composition of n roundings, and no closed
 * form reproduces it bit for bit. Advancing approximately would put a voice a
 * fraction of a cycle from where the oracle has it, which is precisely the
 * audible error the idle-prefix scenarios exist to catch.
 *
 * What this function does instead is drop the AUDIO work and keep the STATE
 * advance: MEASURED, 4 sub-blocks x 5 ops = 20 ops per sample against ~250 for
 * the full step, so a silent voice costs about 8% of a sounding one. That is a
 * real saving and it is exact. It is not the O(1) the header file wanted.
 * Valid only while `inc` and `subthr` are constant over the n samples, which is
 * what "silent voice, nothing modulating" means. */
void  eb_dco_advance(eb_dco_state *s, const eb_dco_coef *c, unsigned n);

#endif /* ENGINEB_EB_DCO_H */

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
    float rm1, rp1;   /* MEASUREMENT VARIANT ONLY: 1/pwm1, 1/pwp1             */
    /* per recall */
    float lvl_saw, lvl_pulse, lvl_sub;   /* port 4736, 4752, 4768             */
    float gn_saw,  gn_pulse,  gn_sub;    /* port 5648, 5664, 5680             */
    float amp_saw, amp_pulse, amp_sub;   /* port 5600, 5616, 5632             */
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

/* One 4x-rate sub-sample. Call four times per host sample; the four results are
 * the four polyphase inputs, in order. */
float eb_dco_step(eb_dco_state *s, const eb_dco_coef *c);

/* Per-sample coefficient build (the two modulated numbers -> inc, g, pw). */
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

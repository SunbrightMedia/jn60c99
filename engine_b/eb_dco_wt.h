/* eb_dco_wt.h — THE BAND-LIMITED DCO. Row 6 of docs/engineb/S3_PLAN_V2.md.
 *
 * WHAT IT REPLACES: eb_dco_step4 running at 2x or 4x plus the whole of
 * eb_decim.c. Together those are 3,918 of the S3 fork's instructions per
 * sample at six voices, and this replaces them with arithmetic that is flat
 * almost everywhere plus a short residual at each edge.
 *
 * ------------------------------------------------------------------------
 * WHY THIS SHAPE, and every clause is a measurement recorded in
 * docs/engineb/data/wavetable_result.md.
 *
 * 1. A BAND-LIMITED TABLE OF THIS OSCILLATOR IS INDISTINGUISHABLE FROM THE 4x
 *    PATH. Alias floor DROPS 71-92 dB; harmonics agree to 2.88 dB worst
 *    against the 3.27 dB that half-oversampling -- already shipping --
 *    measures on the same metric.
 *
 *    This is NOT the 1x DCO that was closed negative the same day. That build
 *    ran the shaping nonlinearity at the OUTPUT rate, which is where the
 *    harmonics come from, and they came out 13.6 dB wrong. Here the
 *    nonlinearity runs ONCE, at high phase resolution, at recall time.
 *
 * 2. THE OUTPUT IS FLAT ALMOST EVERYWHERE. eb_dco.c's EB_DCO_PULSEFAST
 *    measured the saturator's shortcut firing on 98.85 % of sub-steps: away
 *    from an edge every arm is exactly +/- sat_hi. So the per-sample
 *    arithmetic is a phase accumulate, three signs and a mix -- and the whole
 *    cost of the oscillator is its EDGES.
 *
 * 3. SO THE TABLE IS A RESIDUAL, NOT A WAVEFORM. Store the difference between
 *    the band-limited edge and the flat step it replaces. It is non-zero only
 *    within a few samples of a crossing, so it is short, and it is ADDED to
 *    the cheap arithmetic rather than replacing it.
 *
 * 4. ONE TABLE SET SERVES ALL EIGHT VOICES. Over all 51 factory patches the
 *    per-voice spread of every DCO shape and gain coefficient is EXACTLY 0;
 *    CONDITION's scatter enters through the PITCH, which at runtime is just
 *    the increment. It is per-voice for free.
 *
 * 5. THE RESIDUAL DOES NOT DEPEND ON PITCH, and this is what makes the table
 *    small enough to exist. The edge half-width in the triangle argument is
 *    inc4/(2*amp); x = t/(pw-1) puts it at |pw-1|*inc4/(2*amp) in phase; the
 *    phase advances 4*inc4 per output sample; so the width in SAMPLES is
 *    |pw-1|/(8*amp) and inc4 CANCELS.
 *
 *    MEASURED, because a derivation is a hypothesis until it is executed:
 *    the pulse edge is 2.4290 output samples wide at 220, 441, 1,764 AND
 *    7,056 Hz -- identical to four decimals across five octaves
 *    (tools/engineb/edge_width.c).
 *
 *    A PHASE-indexed table DID depend on pitch, about one semitone per level,
 *    and that measurement stands -- it is why this module indexes the residual
 *    by TIME instead. Same edge, different coordinate, and the coordinate is
 *    the whole difference between 7.5 MB of tables and 42 KB.
 *
 *    ONE LIMIT FOUND ON THE WAY: above about 10 kHz the edge is wider than the
 *    period and the pulse never reaches +/-1 at all. The residual model
 *    assumes a flat step to correct; at those pitches there is no flat part.
 *    A JUNO's top key is 4 kHz, so no note reaches it, but a patch with the
 *    DCO RANGE up and the LFO sweeping might -- and this note is the only
 *    warning that exists.
 *
 * 6. THE PULSE HAS TWO EDGE SHAPES, NOT ONE. The port divides the pulse phase
 *    by pwm1 below zero and pwp1 above, so the two halves have different
 *    slopes -- "that asymmetry IS the pulse width", as eb_dco.c says. Assuming
 *    one shape put a -53.6 dB harmonic at -166 dB.
 *
 * 7. THE PULSE WIDTH IS A PHASE OFFSET, NOT A BLEND. Interpolating two pulse
 *    waveforms blends edges that sit in different PLACES, and the blend of two
 *    edges is two edges: 15.6 dB error even at a half-spacing of 0.0125. The
 *    offset moves the edge exactly; only its SHAPE is interpolated, and the
 *    shapes' edges are both at argument 0 by construction so blending them
 *    moves nothing. That converges: 5.41 dB at half-spacing 0.005 against the
 *    direct table's own 5.59.
 *
 * 8. AND pw CRAWLS. Of 17,199,352 per-voice comparisons, 48 % are exactly 0,
 *    33 % are under 1e-3, and only 232 exceed 1e-2. So a FIXED GRID of step
 *    pairs at spacing 0.01 covers every patch with no rebuild ever.
 *
 * ------------------------------------------------------------------------
 * WHAT IS NOT CLAIMED. This header describes a module whose GATE is the fork's
 * (indistinguishability), not the trunk's. The trunk keeps eb_dco.c exactly as
 * it is; this compiles only under EB_DCO_WT.
 */
#ifndef ENGINEB_EB_DCO_WT_H
#define ENGINEB_EB_DCO_WT_H

#include "eb_fork_config.h"

#ifndef EB_DCO_WT
#define EB_DCO_WT 0
#endif

/* THE RESIDUAL'S LENGTH AND ITS FRACTIONAL RESOLUTION, both MEASURED rather
 * than chosen.
 *
 * LENGTH 16. The correction is `port_1x - naive_1x`, and printing it directly
 * (tools/engineb/wt_decomp.c) shows it is EXACTLY ZERO outside a span of TEN
 * samples around the edge -- zero to six decimals, not merely small. 64 was
 * four times longer than anything it had to hold.
 *
 * OVER 16, WITH INTERPOLATION. This is where the error was. At 4 positions the
 * crossing time is quantised to a quarter of a sample, and the correction's
 * steepest slope is about 1.2 per sample on an amplitude of 1.7 -- so the
 * quantisation alone is an 18 % error, which is the -20 dB the module measured.
 * Sixteen positions with a linear blend between adjacent ones removes it.
 *
 * The two changes pay for each other: 16x16 is the same memory as 64x4. */
/* Both are OVERRIDABLE so they can be SWEPT. A length compiled in as a plain
 * #define cannot be measured, and a first attempt to sweep it silently
 * measured the same 16 four times. The length must stay a POWER OF TWO: the
 * ring is masked, not divided. */
#ifndef EB_WT_RES_LEN
#define EB_WT_RES_LEN    16
#endif
/* OVER 64, RAISED FROM 16 BY MEASUREMENT AND ONLY PART OF THE WAY. The saw's
 * error at a fixed pitch is a LOTTERY in the crossing fraction: over inc 0.009
 * to 0.018 it jumped between -63 and -22 dB on pitch changes of half a percent.
 * Raising the resolution lifts the worst of those -- 0.0105 goes -28.9 to
 * -46.0, 0.014 goes -22.6 to -58.1 -- and costs table memory only, since the
 * per-edge work is unchanged.
 *
 * IT DOES NOT CLOSE IT, and 128 proves that: two pitches (0.0115 and 0.0155)
 * sit at -29 and -30 at OVER 64 and only reach -35 and -38 at 128, while every
 * other entry does not move at all. A quantisation error would keep halving.
 * So a structural fault remains in the saw arm, it is NOT the sub-position
 * resolution, and it is not claimed to be fixed. */
#ifndef EB_WT_RES_OVER
#define EB_WT_RES_OVER   64
#endif

/* THE FLAT PATH'S DELAY, AND THE DEFECT ONLY THE WHOLE ENGINE COULD FIND.
 *
 * A band-limited step has energy on BOTH sides of its edge, so the residual
 * must start before the crossing and the flat path must be delayed to meet it.
 * That delay was EB_WT_RES_LEN/2 -- eight samples -- on the reasoning that a
 * uniform delay of the whole oscillator "IS a pure delay, which the gate can
 * and does remove".
 *
 * IT IS A PURE DELAY OF THE OSCILLATOR AND NOT OF THE VOICE. The DCO feeds a
 * filter whose cutoff, resonance and envelope are computed from control
 * signals that are NOT delayed, and it is mixed with noise that is not delayed
 * either. Delaying one input of a time-varying system does not delay its
 * output; it detunes the timing inside it, and no alignment can undo that.
 *
 * MEASURED, and the module's own gate could not have seen it. Per arm the
 * module measures -39 to -72 dB against the port's 4x path. Put in the engine
 * with an eight-sample delay it took all 36 whole-engine scenarios to -16 to
 * -51 dB, with the gate's alignment reporting a clean 16-sample lag -- while
 * the SAME engine without this module passes 27 of 36 at lag +0.000.
 *
 * So the delay is matched to the one the module REMOVES: the port's own
 * decimator FIR, 3.875 samples. Everything downstream then sees the timing it
 * saw before. The residual keeps EB_WT_DELAY taps before the step instead of
 * half the window. */
/* SWEPT, 0/1/2/4, and the arms do not want the same thing:
 *
 *   DELAY  saw @0.0025  saw @0.02   pulse    sub
 *     0      -16.6        -7.7      BROKEN   BROKEN
 *     1      -57.9       -36.5      -71.9    -48.5
 *     2      -65.3       -49.1      -71.9    -48.5
 *     4      -68.2       -50.7      -71.9    -48.5
 *
 * THE PULSE AND THE SUB ARE IDENTICAL AT 1, 2 AND 4 -- they are square, so
 * their correction is causal once the FIR's own delay is inside it. ONLY THE
 * SAW needs pre-ring, because its correction has to undo a ramp offset as well
 * as band-limit a step, and DELAY 0 breaks all three.
 *
 * 2 is the smallest delay that keeps the saw within 1.6 dB of its best. Every
 * sample of delay here is a sample of timing error inside the voice, so the
 * choice is the smallest that the saw survives, not the best per-arm number. */
#ifndef EB_WT_DELAY
#define EB_WT_DELAY      2
#endif

/* THE PULSE-WIDTH GRID. Measured range of pw over all 36 scenarios is
 * [-0.015, 0.939]; the grid spans [-0.05, 1.00] at 0.01, the spacing the
 * convergence measurement showed to be at the limit already.
 *
 * THE SLICES ARE IN EDGE WIDTH, not in pw, because that is what the residual
 * actually depends on: |pw-1|/(8*amp) for the moving edge and |pw+1|/(8*amp)
 * for the fixed one. Over the measured pw range [-0.015, 0.939] the moving
 * edge's width varies 16x and the fixed edge's only 2x, so they get different
 * slice counts instead of one number covering both badly. */
#define EB_WT_PW_LO     (-0.05f)
#define EB_WT_PW_STEP    (0.01f)
#define EB_WT_PW_SLICES  106
#ifndef EB_WT_PWB_SLICES
#define EB_WT_PWB_SLICES   8
#endif

/* NO MIP LEVELS FOR THE SAW OR THE PULSE. See finding 5: their residuals are
 * pitch-independent, so a dimension that would have cost 72x and forced a
 * per-patch rebuild is simply not there.
 *
 * 9. THE SUB IS THE EXCEPTION, AND ONLY MEASUREMENT FOUND IT. Finding 5 was
 *    proven on the PULSE edge, and it was quietly assumed to hold for all three
 *    arms. Building the sub's residual at four pitches and testing each at four
 *    pitches gives a matrix whose DIAGONAL is -41.8, -42.9, -54.1 and -58.9 dB
 *    and whose off-diagonal entries are 10 to 20 dB worse. The sub's edge width
 *    in samples DOES scale with pitch.
 *
 *    Why: the pulse's edge width carries `g = 0.00390625/inc`, so inc cancels.
 *    The sub's ramp is (cnt + p + 1)/2 and its amplitude does not carry g, so
 *    nothing cancels.
 *
 *    The cost of admitting this is small -- the sub's table is 1 KB per level,
 *    against the pulse's 106 slices -- so it gets one level per octave.
 *
 *    THE TOP TWO LEVELS ARE NOT BUILT, and this is a limit of the GENERATOR,
 *    not of the method: above inc 0.04 the sub's period approaches the residual
 *    window plus the filter's reach, so a second edge enters the window. The
 *    index therefore CLAMPS, and a note above about 3.5 kHz uses the highest
 *    built level. Measured cost of that clamp: -42.0 dB at inc 0.04 against the
 *    -58.9 a matched level gives. It is recorded here because a clamp that is
 *    not written down reads as a table that covers everything.
 *
 *    TWO INCREMENTS, AND THEY ARE NOT THE SAME NUMBER. The generator builds
 *    at the SUB-STEP increment; the tick holds the OUTPUT-rate one, which is
 *    four times larger. Indexing one by the other picked a level two octaves
 *    out and left the sub at -36 dB where a matched level gives -43. Both
 *    constants are spelled out below so the two cannot be confused again. */
#define EB_WT_SUB_INC0  (0.00125f)   /* level 0, SUB-STEP rate: the generator */
#define EB_WT_SUB_OINC0 (0.005f)     /* level 0, OUTPUT rate: the tick        */
#define EB_WT_SUB_MIPS  5            /* octaves, to sub-step inc 0.02         */

typedef struct {
    float phase;      /* [-1,1), the port's own DCO phase   */
    float subcnt;     /* 0 or 2, the divide-by-two counter  */
    /* THE PREVIOUS SAMPLE'S OWN t = pw + phase, REMEMBERED RATHER THAN
     * RECOMPUTED. Rebuilding it from the CURRENT pw and the previous phase
     * makes pw's own motion move it: a pw change of 1e-4 flipped its sign
     * while the phase had not crossed anything, so the same crossing was
     * detected in TWO consecutive samples and corrected twice. The module then
     * output -1.91 where its own flat level is +/-0.85.
     *
     * MEASURED: with pw swept +/-0.2 the pulse arm read -32.2 dB against
     * -62.9 static. That is the whole of the gap between this module's
     * isolated figures and the engine's, and no static-pw probe could see it,
     * because with pw still the two forms are identical. */
    float tprev;
    /* ACTIVE RESIDUALS. An edge crossed at a fractional position schedules a
     * residual that is added over the next EB_WT_RES_LEN samples. Three arms
     * can each cross in one sample, and a very high note can cross twice, so
     * the ring is sized for the worst case rather than the common one. */
    float ring[EB_WT_RES_LEN];
    int   rpos;
} eb_dco_wt_state;

typedef struct {
    /* per sample, from the CV chain -- the same two numbers eb_dco_set_pitch
     * takes today */
    float inc;
    float pw;
    /* per recall */
    float sat_hi, sat_lo;
    float lvl_saw, lvl_pulse, lvl_sub;
    float gn_saw,  gn_pulse,  gn_sub;
    float subthr;
    int   sub_mip;             /* the sub's pitch level -- finding 9         */
    /* THE RESIDUAL TABLES, caller-owned and SHARED BY ALL VOICES (finding 4)
     * AND BY EVERY PITCH (finding 5). saw and sub are single tables; the
     * pulse's two edges are sliced by the pulse width, which is the only thing
     * their shape depends on. Total 42 KB for the whole instrument. */
    const float *res_saw;      /* [EB_WT_RES_OVER][EB_WT_RES_LEN]            */
    const float *res_sub;      /* [EB_WT_RES_OVER][EB_WT_RES_LEN]            */
    const float *res_pulse_a;  /* [EB_WT_PW_SLICES][OVER][LEN] -- moving edge */
    const float *res_pulse_b;  /* [EB_WT_PWB_SLICES][OVER][LEN] -- at the wrap*/
} eb_dco_wt_coef;

/* Point a coefficient block at the module's own residual tables. They are
 * generated by tools/engineb/gen_wt_tables.c and are SHARED by every voice and
 * every pitch, so this is a pointer assignment and not a copy. */
void  eb_dco_wt_bind_tables(eb_dco_wt_coef *c);

void  eb_dco_wt_set_pitch(eb_dco_wt_coef *c, float inc, float pw);

/* FREE-RUN, for an AT-REST voice. The port's DCO keeps its phase and its
 * divide-by-two counter running while a voice is silent, and eb_render.c's
 * at-rest shortcut calls eb_dco_advance to do exactly that.
 *
 * THAT SHORTCUT ADVANCED THE TRUNK'S STATE ONLY. Under EB_DCO_WT the sounding
 * path runs THIS module's state instead, so a voice that went at rest had its
 * wavetable phase stop dead while the trunk's kept running -- and when the
 * voice sounded again the two oscillators were at unrelated points in their
 * cycle. It is why the idle scenarios were the worst of the 36 and why several
 * of them measured a worst block ABOVE 0 dB, which is what uncorrelated looks
 * like.
 *
 * No arms, no residual, no output: the same phase and counter arithmetic the
 * tick does, and nothing else. */
void  eb_dco_wt_advance(eb_dco_wt_state *s, const eb_dco_wt_coef *c, int n);
float eb_dco_wt_tick(eb_dco_wt_state *s, const eb_dco_wt_coef *c);

#endif

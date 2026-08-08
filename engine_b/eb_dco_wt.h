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
/* THE SAW'S GROUP-DELAY CONSTANT, moved here so BOTH the tick and the
 * generator read one number. It was 3.875 in two files and hardcoded in four
 * more places in the generator. */
#ifndef EB_WT_SAWGD
#define EB_WT_SAWGD 3.875f
#endif

/* SIX, RE-SWEPT ONCE THE LEAD MADE IT FREE. This was 2, chosen when the
 * module's delay was a raw timing error inside the voice and every sample of
 * it cost accuracy downstream. The lead removed that cost entirely -- the
 * oscillator runs EB_WT_DELAY samples ahead and the gate's alignment comes
 * back at +0.000 for every value -- so the constraint that picked 2 no longer
 * exists, and the constant was never re-measured against it.
 *
 * MEASURED, saw arm through the correct filter, lag +0.000 throughout:
 *
 *   DELAY   0.0005   0.002    0.004    0.0075
 *     2     -51.1    -42.6    -45.0    -38.9
 *     4     -65.7    -56.7    -57.1    -47.5
 *     6     -69.8    -61.4    -57.7    -47.3
 *     8     -69.8    -61.4    -57.7    -47.3
 *
 * 8 is identical to 6, so 6 is the knee. The sub does not move at all -- it is
 * square, and only the SAW needs pre-ring, which is the same split DELAY 0/1/2
 * found before. */
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
/* THE MOVING EDGE'S SLICES ARE UNIFORM IN EDGE WIDTH, WHICH IS WHAT THE
 * PARAGRAPH ABOVE ALWAYS SAID AND THE CODE NEVER DID. It used a LINEAR pw grid
 * at 0.01, and the moving edge's width goes as |pw-1|: at pw 0.02 a step of
 * 0.01 changes the width by 1 %, and at pw 0.85 it changes it by 6.7 %. The
 * grid was six times too coarse exactly where the edge is narrowest.
 *
 * MEASURED, module pulse arm at inc 0.004 across the pw range the 36 scenarios
 * actually reach: -73.9 dB at pw 0.02 but -49.9 at 0.7 and -46.0 at 0.85. The
 * saw and the sub do not move with pw at all, so this is the pulse's alone.
 *
 * u = 1 - pw is the edge width, and it spans [0.06, 1.05] over that range --
 * about four octaves. Sixteen slices per octave, indexed from u's own float
 * exponent and top four mantissa bits, is FEWER slices than the linear grid
 * and puts them where the width is changing. */
#define EB_WT_PW_LO     (-0.05f)
#define EB_WT_PW_STEP    (0.01f)
/* GUARDED so it can be SWEPT. This file already carries a note that a plain
 * #define cannot be measured, and this constant was added as one anyway -- the
 * first sweep of it returned three identical columns. */
#ifndef EB_WT_PWA_PER_OCT
#define EB_WT_PWA_PER_OCT 16
#endif
#define EB_WT_PWA_EMIN   (-5)          /* u down to 1/32 */
/* THE MANTISSA BITS THE INDEX USES, derived from the slice count instead of
 * written out. Hardcoding four bits made every resolution but 16 mis-index --
 * measured as the pulse falling to -16 dB at 32 per octave, which is the
 * signature of reading the wrong table row, not of a coarse one. */
#if   EB_WT_PWA_PER_OCT == 8
#define EB_WT_PWA_SHIFT 20
#elif EB_WT_PWA_PER_OCT == 16
#define EB_WT_PWA_SHIFT 19
#elif EB_WT_PWA_PER_OCT == 32
#define EB_WT_PWA_SHIFT 18
#elif EB_WT_PWA_PER_OCT == 64
#define EB_WT_PWA_SHIFT 17
#else
#error "EB_WT_PWA_PER_OCT must be 8, 16, 32 or 64"
#endif
#define EB_WT_PW_SLICES  (6 * EB_WT_PWA_PER_OCT)
/* THE FIXED EDGE'S OWN RANGE, stated rather than inherited. Its build range
 * used to be LO + EB_WT_PW_STEP * EB_WT_PW_SLICES -- the MOVING edge's slice
 * count -- which at 106 linear slices came to 1.01 and matched the tick's
 * implicit range by accident. The moment the moving edge was re-sliced the
 * coupling showed: at 192 slices the range became 1.87, so most fixed-edge
 * slices were built at pulse widths that never occur, and the tick read a row
 * built for pw 1.75 when it wanted pw 0.7.
 *
 * MEASURED: that is the whole of why 32 slices per octave collapsed to -16 dB
 * while 16 gave -59.7. The tables and the moving edge's index were both
 * correct; the FIXED edge's range was not. */
#define EB_WT_PWB_HI     (1.00f)
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
#define EB_WT_SUB_INC0  (0.00015625f) /* level 0, SUB-STEP rate: the generator */
#define EB_WT_SUB_OINC0 (0.000625f)  /* level 0, OUTPUT rate: the tick        */
/* QUARTER-OCTAVE LEVELS, NOT OCTAVES. At one level per octave a note halfway
 * between two levels uses a table built up to half an octave away, and the sub
 * measured -41 to -48 dB where the saw and the pulse reach -58 to -72. The
 * levels are indexed by the float exponent AND the top two mantissa bits, so
 * the index is still a shift and a mask; the table costs 1 KB per level.
 *
 * Level L = 4*e + j covers inc in INC0*2^e*[1 + j/4, 1 + (j+1)/4) and is built
 * at that interval's midpoint. */
/* FOUR PER OCTAVE, AND EIGHT WAS MEASURED AND REJECTED. Doubling the levels
 * helped two pitches (inc 0.00187 -56.6 -> -62.9, inc 0.013 -61.7 -> -64.5),
 * did NOT touch the dip it was aimed at (inc 0.005, -49.1 -> -50.9), and made
 * the PITCH-MODULATED case worse -- -56.5 -> -51.9 -- because a moving pitch
 * then switches level twice as often. The engine never holds a pitch still, so
 * the modulated row is the one that decides.
 *
 * That the 441 Hz dip survives an 8x finer ladder is the useful part: it is
 * NOT level quantisation, and whatever it is has not been found. */
/* GUARDED, AND THE SHIFT DERIVED. This is the THIRD constant in this file to
 * be added as a plain #define and then "swept" -- each time returning
 * identical columns, each time costing a cycle before the sameness was
 * noticed. Any constant a measurement might vary is #ifndef-guarded here, and
 * any bit position that depends on it is computed from it. */
#ifndef EB_WT_SUB_PER_OCT
/* SIXTEEN, MEASURED. Once the constant could actually be swept, the sub arm
 * over the pitch range the 36 scenarios reach:
 *
 *   inc      4/oct   8/oct   16/oct
 *   0.0005   -62.1   -62.1   -66.5
 *   0.001    -68.9   -65.2   -80.8
 *   0.002    -55.0   -54.4   -55.2
 *   0.004    -72.3   -68.6   -84.4
 *   0.0075   -55.1   -65.1   -58.0
 *
 * 16 wins at four of five points, by up to 12 dB, for 455 KB against 113. The
 * ladder is NOT monotonic -- 8 is worse than 4 at two points -- which is what
 * a level grid whose midpoints happen to land well or badly looks like.
 *
 * THE inc 0.002 DIP SURVIVES ALL THREE at -55 dB. It is not level
 * quantisation, and it is not explained. */
#define EB_WT_SUB_PER_OCT 16
#endif
#if   EB_WT_SUB_PER_OCT == 4
#define EB_WT_SUB_SHIFT 21
#elif EB_WT_SUB_PER_OCT == 8
#define EB_WT_SUB_SHIFT 20
#elif EB_WT_SUB_PER_OCT == 16
#define EB_WT_SUB_SHIFT 19
#else
#error "EB_WT_SUB_PER_OCT must be 4, 8 or 16"
#endif
/* THE LADDER RUNS THREE OCTAVES LOWER THAN IT DID. Level 0 used to sit at
 * sub-step 0.00125, about 110 Hz, and everything below that CLAMPED -- the sub
 * measured -42.7 dB at 79 Hz where its neighbours reach -56. Extending
 * downwards is free: the generator's only limit is at the TOP, where the
 * period approaches the residual window, and a longer period is never a
 * problem. Twelve more levels, 12 KB.
 *
 * The top is still capped at sub-step 0.01875, the highest the generator
 * builds soundly. Above it a second edge enters the window and the index
 * clamps instead. */
#ifndef EB_WT_SUB_MIPS
#define EB_WT_SUB_MIPS  (7 * EB_WT_SUB_PER_OCT)   /* seven octaves */
#endif

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
    /* THE LEAD. The module's output is EB_WT_DELAY samples later than the
     * port's, because its flat path waits that long to meet its correction.
     * On its own that is a pure delay -- but the DCO reaches the VCF ONLY
     * through the noise mix, and the NOISE term is not delayed, so the mix is
     * skewed internally and no alignment can undo it. So the oscillator runs
     * EB_WT_DELAY samples AHEAD and the ring puts it back on time. Primed
     * once, on the first tick, from the increment then in force. */
    int   primed;
    /* THE INCREMENT THE LEAD WAS BUILT WITH. The lead is a PHASE offset of
     * EB_WT_DELAY*4*inc4, so a lead that is two samples at one pitch is not two
     * samples at another. Priming once and leaving it made the lead drift with
     * every pitch change: MONO glide measured -18.2 dB against -41.1 before the
     * lead existed, and the gate's alignment came back at +0, -2, -4.031 and
     * -4.000 on different scenarios -- four different delays in one engine,
     * which is what a pitch-dependent lead looks like. The correction below
     * keeps it exact for three operations a sample. */
    float inc4_prev;
    /* ACTIVE RESIDUALS. An edge crossed at a fractional position schedules a
     * residual that is added over the next EB_WT_RES_LEN samples. Three arms
     * can each cross in one sample, and a very high note can cross twice, so
     * the ring is sized for the worst case rather than the common one. */
    float ring[EB_WT_RES_LEN];
    int   rpos;
} eb_dco_wt_state;

typedef struct {
    /* per sample, from the CV chain -- the same two numbers eb_dco_set_pitch
     * takes today. inc4 is the SUB-STEP increment and inc is 4*inc4, the
     * output-rate one; both are kept because the module needs both and
     * deriving one from the other at the wrong moment is what caused the
     * drift described below. */
    float inc4;
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
    /* THE FOUR TABLE POINTERS ARE GONE, and their removal is a correctness
     * fix rather than a tidy-up. They were always the SAME four base
     * addresses -- bind_tables set them from the globals and nothing ever
     * varied them -- but eb_render_state embeds wt_live[EB_NUM_VOICES], so
     * 32 pointers lived inside the state a HOST writes into a firmware blob.
     * That made sizeof(eb_render_state) 128 bytes larger on the host than on
     * the S3, which the blob's layout equality caught, and it would have put
     * host addresses in front of a target that followed them.
     *
     * eb_dco_wt.c now names the tables directly. The struct is word-size
     * independent, and four pointer loads per voice per sample go with it. */
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

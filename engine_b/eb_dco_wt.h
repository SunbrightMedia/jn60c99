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
#define EB_WT_RES_LEN    16
#define EB_WT_RES_OVER   16

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
#define EB_WT_PWB_SLICES   8

/* NO MIP LEVELS. See finding 5: the residual is pitch-independent, so a
 * dimension that would have cost 72x and forced a per-patch rebuild is simply
 * not there. */

typedef struct {
    float phase;      /* [-1,1), the port's own DCO phase   */
    float subcnt;     /* 0 or 2, the divide-by-two counter  */
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
float eb_dco_wt_tick(eb_dco_wt_state *s, const eb_dco_wt_coef *c);

#endif

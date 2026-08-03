/* eb_pitch.h — the pitch CV to DCO-increment polynomial.
 *
 * SCOPE, narrower than the module map's "pitch" region: only
 * src/voice_render.c:1641-1664 -- the clamp, the table row lookup and the
 * twelfth-order polynomial. The rest of 1641-1717 is the delay-line shift,
 * which the DECIMATOR module already owns; two shims may not edit the same
 * lines and the composite generator refuses such a merge.
 *
 * THIS BLOCK IS STATELESS. Input in, value out, nothing carried between
 * samples. That is why it can be taken while the standalone engine is still
 * being built: it has no state needing a home.
 *
 * IT IS DOUBLE PRECISION, and that is the whole risk in it. `fmin`/`fmax` are
 * the DOUBLE functions, the table is `double[29][26]`, and every power of the
 * clamped CV is formed in double. Only at the very end does `fminf`/`fmaxf`
 * bring it back to float. Writing this block in float throughout would look
 * identical and be wrong everywhere -- the same class as the two rewrites that
 * were algebraically identical and disagreed on millions of inputs.
 *
 * The powers are copied as the port BUILDS them, not re-derived from the
 * exponents: v386 = x*x*x, v388 = v386*x*x, v389 = v388*x*x*x,
 * v390 = v389*x*x. Forming x^10 any other way is a different double.
 *
 * OBSERVABILITY, MEASURED before writing: a 0.1 % error here moves 30 of the 30
 * scenarios and lands at +4.9 dB, because a relative error on a pitch is hugely
 * amplified at the output. No risk of a blind gate.
 */
#ifndef ENGINEB_EB_PITCH_H
#define ENGINEB_EB_PITCH_H

/* THE MODULE OWNS THE TABLE. `cv` is the port's JF(4448) + JF(3776); `gain` is
 * its cell 3792. The row is selected inside, from the same clamp the port uses.
 *
 * The row pointer used to be a parameter, and that was the one thing blocking
 * the EB_PITCH_FAST build from being float-only on the ESP32-S3: a pointer to
 * a row cannot be turned back into a row INDEX (`juno_pitch_table` is `static`
 * per translation unit), so the pre-split coefficient table could not be
 * indexed and the split had to run per call in soft-double. Taking the CV
 * instead costs nothing and removes 13 `__subdf3` per call from the S3's
 * per-sample path. */
int   eb_pitch_row(float cv);
float eb_pitch_eval(float cv, float gain);

#if EB_PITCH_FAST
/* 0 if the generated pre-split table matches df_coef bit for bit on all
 * 29x13 entries. Only exists in the fast build; see eb_pitch.c. */
int   eb_pitch_tab_selfcheck(void);
#endif

/* ------------------------------------------------- CONTROL-RATE PITCH (C1)
 * EB_PITCH_CR = N evaluates the full v7 polynomial every Nth call per voice
 * and, between anchors, EXTRAPOLATES linearly from the last two anchors.
 *
 * THE DESIGN IS FIRST-ORDER TAYLOR IN THE INPUT, and the road matters: the
 * first build extrapolated the OUTPUT from past anchors and FAILED the gate
 * hard (N=2 -54.8 dB; the pitch CV carries sample-rate content -- envelope
 * attacks, S&H and noise LFO modes -- that no output-side scheme can track).
 * The Taylor form uses the TRUE per-sample cv, which the caller computes
 * anyway, and decimates only the expensive polynomial: per sample it applies
 * A + D*(cv - cv0). A radius guard re-anchors on large excursions, so hot
 * modulation degenerates toward per-sample anchoring: slower, never wrong.
 *
 * Note events bump eb_coef_gen, which the shim uses to reset this state --
 * a note step therefore re-anchors immediately.
 *
 * N = 1 anchors every call: BIT-IDENTICAL to the plain fast build by
 * construction, and the harness proves it (the ladder's self-test).
 * State is per voice and owned by the CALLER (shim or engine). */
#ifndef EB_PITCH_CR
#define EB_PITCH_CR 0
#endif
#if EB_PITCH_CR > 1
#error "Control-rate pitch is DEAD, by measurement (2026-08-03): on the real pluck-POLY trajectory the Taylor evaluator is accurate to 1e-7 worst / 4e-8 RMS and the null STILL fails at -89.5 dB, because a smooth deterministic error is a BIAS and the DCO phase integrates it. The gate demands bias below ~1e-9 on any phase-integrated quantity; no causal approximation delivers that. See docs/engineb/data/pitch_p2_study.md section 6. N=1 (exact, anchors every call) remains for the harness self-test only."
#endif
#if EB_PITCH_CR > 0
#if !EB_PITCH_FAST
#error "EB_PITCH_CR anchors with the v7 fast path; build with EB_PITCH_FAST=1."
#endif
/* Re-anchor radius, in CV units (one unit here is about an octave of pitch).
 * Within it the first-order error is (P''/2)*radius^2, relative ~1e-4 at the
 * instant worst case and far smaller on average; beyond it the evaluator
 * re-anchors. Tightening it trades anchors for accuracy at run time. */
#ifndef EB_PITCH_CR_RADIUS
#define EB_PITCH_CR_RADIUS 0.005f
#endif

typedef struct {
    float x0;                  /* anchor input, CLAMPED domain             */
    int   row0;                /* anchor row -- crossing a knot re-anchors  */
    float a_cur;               /* anchor output A = P(cv0) * gain          */
    float slope;               /* D = P'(cv0) * gain                       */
    float half2;               /* P''(cv0)/2 * gain (second-order term)    */
    int   k;                   /* samples since the anchor (0 = anchor due)*/
    int   primed;              /* 0 until the first anchor exists          */
} eb_pitch_cr_state;

float eb_pitch_eval_cr(eb_pitch_cr_state *s, float cv, float gain);
#endif /* EB_PITCH_CR */

#endif /* ENGINEB_EB_PITCH_H */

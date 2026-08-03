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

#endif /* ENGINEB_EB_PITCH_H */

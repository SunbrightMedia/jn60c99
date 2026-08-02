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

/* `tab` is the port's juno_pitch_table row (26 doubles; even indices used).
 * `cv` is the port's JF(4448) + JF(3776); `gain` is its cell 3792.
 * The caller selects the row, because the row index is (int)(clamped + 20.0)
 * and the clamp happens here -- see eb_pitch_row(). */
int   eb_pitch_row(float cv);
float eb_pitch_eval(float cv, const double *tab, float gain);

#endif /* ENGINEB_EB_PITCH_H */

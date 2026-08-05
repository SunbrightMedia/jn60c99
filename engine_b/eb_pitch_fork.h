/* eb_pitch_fork.h — the S3 FORK pitch evaluator (F3).
 *
 * THIS IS FORK CODE, NOT TRUNK CODE. The trunk's pitch is eb_pitch.c and is
 * bit-exact double (EXACTLY 0 under the null); nothing here touches it. This
 * file exists because the trunk evaluator costs 34,952 instr/sample on the
 * ESP32-S3 (half the whole engine) and that cost is IRREDUCIBLE under the
 * bit-exact standard — proven twice, docs/engineb/data/pitch_p2_study.md.
 *
 * THE ACCURACY STANDARD IS DIFFERENT HERE, BY USER DECISION (recorded in
 * CLAUDE.md's Phase-2 charter): not the −100 dB null, but a CENTS bound.
 * The plugin's own double evaluation carries up to ~2^-53 x 2^37 ≈ 1e-5
 * relative rounding noise (the 2^37 cancellation of its own sum structure,
 * measured in exact rationals); ≈ 0.02 cents. The instrument's own UNISON
 * scatter is 18.2 cents peak-to-peak. The fork evaluator must sit within
 * 0.05 cents of the plugin — inside the plugin's own noise floor's order,
 * ~360x below the instrument's own voice scatter. The gate that holds it
 * there is tools/engineb/pitch_cents_gate.py and it is EXHAUSTIVE: every
 * representable float32 input, not a sampling.
 *
 * HOW IT WORKS. The plugin's pitch is a 29-row spline of degree-12
 * polynomials evaluated at ABSOLUTE x — which is why plain float dies (up to
 * 2.7 octaves wrong, pitch_cents_study.md §2): the terms reach magnitude
 * ~2^37 above the result and cancel. RECENTERING evaluates row r at
 * t = x − (r − 19.5), |t| ≤ 0.5, with coefficients transformed EXACTLY
 * (rational arithmetic, gen_fork_tab.py) from the plugin's own table. The
 * cancellation disappears; a plain float Horner then tracks the TRUE spline
 * to a few ULP, and therefore tracks the plugin to the plugin's own noise.
 */
#ifndef ENGINEB_EB_PITCH_FORK_H
#define ENGINEB_EB_PITCH_FORK_H

float eb_pitch_fork_eval(float x);

#endif

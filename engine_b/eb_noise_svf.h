/* eb_noise_svf.h — the noise state-variable filter (Chamberlin form).
 *
 * SCOPE. src/voice_render.c:1129-1140 only: the filter itself. Lines 1141-1149
 * are a separate matter (they delay and scale cells 6416/6448/6544 that are
 * written and read OUTSIDE this block) and are deliberately left in the port.
 * A module boundary drawn where the state is self-contained is a module that
 * can be proven; one drawn for tidiness is not.
 *
 * PROVENANCE. Every coefficient cell and the exact order of operations are READ
 * from those twelve lines. The order is reproduced term for term.
 *
 * THE STATE IS TWO FLOATS, and finding that out was the point of reading it
 * carefully. The port touches three cells -- 4288, 4304 and 4320 -- but 4320's
 * OLD value is never used: line 1130 overwrites it with 4304's old value before
 * anything reads it. So the filter carries 4288 and 4304, and 4320 is an
 * OUTPUT. The port also writes 4304 twice (:1132 then :1134); the first write
 * is dead, and engine B does not repeat it.
 *
 * OBSERVABILITY, MEASURED before this module was written, because the project's
 * standing rule is that no module may be rewritten behind a blind gate: a 0.1 %
 * error planted here moves 6 of the 30 scenarios and lands at -72.6 dB. So the
 * block IS visible, and the -100 dB gate catches an error of about 2.3e-5 in
 * it. The older CLAUDE.md warning that this filter is invisible was measured on
 * an earlier scenario set and no longer holds.
 */
#ifndef ENGINEB_EB_NOISE_SVF_H
#define ENGINEB_EB_NOISE_SVF_H

typedef struct {
    float s88;                 /* port cell 4288 */
    float s04;                 /* port cell 4304 */
} eb_nsvf_state;

typedef struct {
    float k36, k52, k68, k84, k00;   /* cells 4336, 4352, 4368, 4384, 4400 */
} eb_nsvf_coef;

/* One sample. `x` is the shared noise input (the port's JF(base, 84432)).
 * Returns the value the port stores in cell 4320; `s04_out` returns the value
 * it stores in 4304, which other code reads. */
float eb_nsvf_tick(eb_nsvf_state *s, const eb_nsvf_coef *c,
                   float x, float *s04_out);

#endif /* ENGINEB_EB_NOISE_SVF_H */

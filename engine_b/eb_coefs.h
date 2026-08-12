/* eb_coefs.h — build an eb_render_coefs / eb_render_state from the PORT's
 * recalled state.
 *
 * WHAT THIS IS FOR, and what it is NOT. `eb_engine_render` needs a filled
 * coefficient set, and until now nothing built one -- which is the only reason
 * the engine could not be gated. This file supplies it by reading the port's
 * recalled cells, exactly as each module's SHIM already does. That is
 * legitimate GATE plumbing: it lets the standalone engine be compared against
 * the port sample for sample.
 *
 * IT IS NOT THE INSTRUMENT'S RECALL PATH. Engine B computing its own
 * coefficients from the patch bytes (eb_patch) is a separate, later, separately
 * gated job. Do not conflate the two: this function needs a port context to
 * exist, so an engine built on it is not yet standalone at RECALL time -- only
 * at RENDER time, which is what the per-sample cost measurement is about.
 *
 * PROVENANCE. Every cell below is copied from the gather block of the shim that
 * owns that module -- code already proven EXACTLY 0 against the port. Nothing
 * here was re-derived from src/voice_render.c, because re-deriving is how a
 * transcription error enters a path that already had a proven one.
 *
 * THE TRAP THIS FILE MUST NOT FALL INTO. A cell that the VOICE FUNCTION writes
 * every sample is NOT a coefficient, and caching one freezes a moving value in
 * a way the generation guard can never detect (eb_noisemix's cell 3536 is the
 * proven example). Every cell here was checked to have no `JF(a1, N) =` writer
 * in src/voice_render.c. The per-sample inputs stay arguments.
 */
#ifndef ENGINEB_EB_COEFS_H
#define ENGINEB_EB_COEFS_H

#include "eb_render.h"

/* `base` is the port's engine state pointer (the same `base` voice_render.c
 * takes). Fills every coefficient for all EB_NUM_VOICES voices plus the FX. */
void eb_render_coefs_build(const unsigned char *base, eb_render_coefs *c);

/* ONE voice's coefficients, for callers that know only one voice changed --
 * a key press being the whole reason this exists. It does NOT memset: the
 * caller owns the other seven voices' values and must have put them there.
 * `for (v...) eb_coefs_voice(base, c, v)` after a memset IS
 * eb_render_coefs_build; that identity is what devrecall_gate.py checks. */
void eb_coefs_voice(const unsigned char *base, eb_render_coefs *c, int v);

/* Seed engine B's state from the port's, ONCE, at context start. After this
 * the engine owns its state and never re-reads a cell -- re-seeding free-run
 * state per sample is exactly what would mask a lockstep defect. */
void eb_render_state_seed(const unsigned char *base, eb_render_state *s);

/* EVENT MIRRORING, at an event boundary only (a bump of eb_coef_gen).
 *
 * Note events do not go through engine B's own note path under the null gates;
 * they are driven into the PORT by gui/juno_bridge.c, exactly as every other
 * gate in this project drives them. This re-reads the cells such an event
 * writes that are NOT coefficients -- the gate cell 320 and the DCO retrigger
 * one-shot -- and consumes the one-shot on the port's side, because the port's
 * own voice function (which normally clears it) is the thing being replaced.
 *
 * PER-SAMPLE re-reading is forbidden here and always will be: it would re-seed
 * free-run state from the oracle and mask precisely the lockstep defects these
 * gates exist to find. `base` is non-const for the one-shot clear alone. */
void eb_render_events_mirror(unsigned char *base, eb_render_state *s);

#endif /* ENGINEB_EB_COEFS_H */

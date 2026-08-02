/* eb_engine.h — engine B's public API. Deliberately tiny.
 *
 * The whole engine is one struct the caller owns. There is no allocation, no
 * global, no context handle and no init order to get wrong; firmware puts an
 * eb_engine in BSS and calls eb_engine_init(). That is a target requirement, not
 * a preference: docs/engineb/SCOPE.md gives 200 KB of internal RAM and one core.
 */
#ifndef ENGINEB_EB_ENGINE_H
#define ENGINEB_EB_ENGINE_H

#include "eb_types.h"
#include "eb_patch.h"

/* Return codes of eb_engine_process(). */
enum {
    EB_OK = 0,
    EB_INCOMPLETE = 1     /* a module is missing; *outL/*outR are NOT audio and
                             the caller must fall back to the oracle. See
                             eb_modules.h -- this is a structural refusal. */
};

void eb_engine_init(eb_engine *e, float sample_rate);

/* The ONLY parameter entry point (docs/preset/COMPACT_FORMAT.md).
 * Returns eb_patch_decode()'s missing count: 0 means the compact format carried
 * every parameter engine B reads. */
int  eb_engine_set_patch(eb_engine *e, const eb_patch *p);

void eb_engine_note_on (eb_engine *e, int note, int vel);
void eb_engine_note_off(eb_engine *e, int note);

/* One stereo sample. Returns EB_OK or EB_INCOMPLETE. */
int  eb_engine_process(eb_engine *e, float *outL, float *outR);

/* THE FREE-RUN CONTRACT, at engine level (eb_freerun.h).
 * Advance every free-running quantity in the engine by n samples in O(1),
 * without producing audio. Used when the whole engine is idle. It must be
 * EXACTLY equal to n calls of eb_engine_process() on a silent engine; that
 * equality is a unit test, engine_b/tests/test_freerun.c.
 *
 * Voice envelopes, filters and delay lines are deliberately NOT touched here:
 * they are not free-running, and this call is only legal when every voice is
 * at rest. eb_engine_all_atrest() is the predicate. */
void eb_engine_advance(eb_engine *e, uint32_t n);

/* One sample of the same set, by the single-step path. Exposed so the
 * equivalence test compares TWO code paths, not one against itself. */
void eb_engine_step_freerun_public(eb_engine *e);
int  eb_engine_all_atrest(const eb_engine *e);

#endif /* ENGINEB_EB_ENGINE_H */

/* eb_recall.h -- THE PUBLISH CONTRACT.
 *
 * A pointer swap publishes COEFFICIENTS. A patch change also moves STATE that
 * lives in neither `eb_render_coefs` nor `eb_master_coef`: the reverb wipe
 * countdown, the delay route latch, the DCO live copy, the ADSR gate mirror.
 * Three of those four transitions had never executed anywhere in this project,
 * because every gate recalls cold, one patch per scenario, with all voices
 * forced awake. That is defect 3 of docs/engineb/DEVICE_RECALL.md.
 *
 * THE REFERENCE ORDER, which this reproduces, is the shim's own
 * (engine_b/shim/standalone/juno_driver.c:357-365; voices shim :222-232):
 *
 *     if (EB_GEN_SEEN != eb_coef_gen) {
 *         eb_render_coefs_build(st, &EBC);      voice coefficients
 *         eb_master_coefs_build(st, &MC);       master coefficients
 *         eb_render_events_mirror(st, &EBS);    gate320 / aux / dco_live
 *         EB_GEN_SEEN = eb_coef_gen;
 *     }
 *
 * There it sits at the top of the per-sample function and is atomic with
 * respect to the sample loop by being single-threaded. On the device that has
 * to be MADE true, which is what the split below is for:
 *
 *   eb_recall_build()    steps 1-2. ~90,000 cycles. Runs OUTSIDE the quiescent
 *                        window, into the SHADOW bank. The builder memsets
 *                        first (eb_coefs.c:17), so an in-place build hands the
 *                        audio loop an all-zero coefficient set for the whole
 *                        burst -- silence, then a click.
 *   eb_recall_publish()  steps 3-8. A few hundred cycles. Runs ONLY inside the
 *                        window where the worker core is parked.
 *
 * WHY THE CELL ARRAY IS NOT DOUBLE-BUFFERED, in one line each:
 *   1. the mirror writes a CONSUMPTION, not a value -- it clears the aux
 *      retrigger one-shot in the array (eb_coefs.c:372-379). Two arrays either
 *      lose the retrigger or fire one nobody played.
 *   2. the voice tile is SHARED and the build mutates it (ebdev_voice_select).
 *      During the burst the array holds no consistent picture of any voice.
 *   3. it is ~25 KB and the copy buys nothing.
 * The rule instead is ONE array, ONE writer, and the audio loop never touches
 * it -- true today: eb_engine_render_voices/_range/_shared and eb_master_render
 * take (engine, state, coefs, rings) and no `base`.
 */
#ifndef EB_RECALL_H
#define EB_RECALL_H

#include "eb_coefs.h"
#include "eb_master_coefs.h"
#include "eb_render.h"
#include "eb_master.h"
#include "eb_engine.h"

/* What the render path reads. `volatile` is on the POINTER, not the pointee,
 * so no render signature changes and the compiler may not hoist the load out
 * of the block loop. */
extern const eb_render_coefs * volatile EB_RC;
extern const eb_master_coef  * volatile EB_MC;

typedef struct {
    eb_render_coefs *rc[2];       /* caller-owned, internal SRAM  2 x 10,564 */
    eb_master_coef  *mc[2];       /*                              2 x  1,704 */
    eb_render_state *rs;
    eb_master_state *ms;
    const eb_engine *eng;         /* for the at-rest flags; NULL = all awake */
    int   cur;                    /* which bank is live                      */
    int   route_last;             /* -1 until the first publish              */
    const eb_master_coef *mc_pending;   /* the FX-pipe one-block deferral    */
    unsigned long gen;            /* +1 per publish, for the firmware banner */
    unsigned long unmapped_at_publish;
} eb_recall;

/* Quiescence. A rule that cannot fail is not a rule: publish ASSERTS this
 * rather than assuming it. The firmware points it at (w_done && !w_go); the
 * default says "single core, always quiescent". Returns non-zero when it is
 * safe to publish. */
extern int (*eb_recall_quiescent)(void);

void eb_recall_init(eb_recall *r,
                    eb_render_coefs *rc0, eb_render_coefs *rc1,
                    eb_master_coef *mc0, eb_master_coef *mc1,
                    eb_render_state *rs, eb_master_state *ms,
                    const eb_engine *eng);

/* Steps 1-2: build into the SHADOW bank. Outside the window. */
void eb_recall_build(eb_recall *r);

/* Steps 3-8: swap, route latch, reverb wipe, voice mirror, barrier.
 * Returns 0 on success, non-zero if the quiescence precondition failed --
 * in which case NOTHING is published. */
int  eb_recall_publish(eb_recall *r);

/* The FX-pipe deferral: call once per block boundary, after the block that
 * followed a publish. Applies mc_pending to EB_MC. No-op when nothing pends. */
void eb_recall_block_boundary(eb_recall *r);

/* ---------------------------------------------------------------- the teeth
 * Deliberate defects the gate turns on to prove the checks can fail. A gate
 * that has never been seen to fail is not a gate. These are compile-time so
 * they cost nothing when off, and they are listed here rather than hidden in
 * the .c so nobody can ship one by accident:
 *
 *   EB_RECALL_TOOTH_NODCO   step 7c: skip clearing dco_live_seeded
 *   EB_RECALL_TOOTH_NOGATE  step 7a: skip refreshing gate_cell320
 *   EB_RECALL_TOOTH_NOAUX   step 7b: skip consuming the aux one-shot
 *   EB_RECALL_TOOTH_NOREV   step 6:  skip the reverb wipe + pending taps
 *   EB_RECALL_TOOTH_NOROUTE step 5:  skip the delay route latch
 *   EB_RECALL_TOOTH_NOSWAP  step 4:  skip the pointer swap
 */
#endif /* EB_RECALL_H */

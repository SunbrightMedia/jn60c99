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
    /* O2: the chunked build's cursor. 0 = idle, otherwise the NEXT step to
     * run. Lives here rather than in a file static so that a second recall
     * context cannot silently share one cursor. */
    int   chunk_step;
    /* O2: which voices the chunked build still owes, and whether it owes the
     * shared tail and the master set. A PATCH build owes all three; a NOTE
     * build owes only the voices the allocator named. */
    unsigned chunk_mask;
    int   chunk_tail;
    int   chunk_master;
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

/* ===================== O2: THE SAME BUILD, ONE PIECE AT A TIME ===========
 *
 * WHY. eb_recall_build() is ~1.25 M cycles and the whole patch-change burst is
 * ~2.1 M against a 5.8 ms block. MEASURED on silicon: 1-4 missed block
 * deadlines per program change (data/b4_first_run.md, b6_split_sweep.md).
 * THE INVARIANT rule 2 requires that work to be INCREMENTAL AND CAPPED, and
 * rule 3 says the change may ARRIVE LATER -- so the build is spread over
 * blocks and the audio keeps playing the CURRENT bank until one atomic
 * publish swaps it.
 *
 * THIS IS SAFE BECAUSE THE SHADOW IS NOT READ BY THE AUDIO PATH. Every step
 * writes only r->rc[shadow] / r->mc[shadow]; the render loop reads
 * r->rc[cur]. A half-built shadow is therefore inaudible, which is the whole
 * reason the shadow exists (see eb_recall_build's own note).
 *
 * USAGE:
 *     eb_recall_chunk_begin(r);
 *     while (eb_recall_chunk_step(r)) { }     // one call per block
 *     eb_recall_publish(r);                   // in the quiescent window
 *
 * eb_recall_chunk_step() returns 1 while more work remains and 0 when the
 * shadow is complete. Each call does ONE bounded piece: one voice, the shared
 * tail, or the master build. THE CALLER DECIDES HOW MANY STEPS A BLOCK CAN
 * AFFORD -- this file does not know the block period and must not guess.
 *
 * ⚠ BIT-IDENTICAL TO eb_recall_build BY GATE, not by argument:
 * tools/engineb/chunk_gate.py builds all 64 patches both ways and compares
 * the structs byte for byte, with planted teeth. */
#define EB_RECALL_CHUNK_STEPS (EB_NUM_VOICES + 2)   /* voices + tail + master */

void eb_recall_chunk_begin(eb_recall *r);

/* ===================== O2: THE NOTE BUILD, ALSO ONE PIECE AT A TIME =====
 *
 * WHY THIS EXISTS AND WHY IT IS NOT OPTIONAL. MEASURED on silicon
 * (b8_robot_attribution.md): a NOTE burst is 1.06-1.27 M cycles -- 4.4-5.3 ms
 * inside a 5.8 ms block, and 1.6x core 0's entire slack. Every block carrying
 * one runs late BY CONSTRUCTION, and the FINAL_GUIDE's stated expectation for
 * it was ~135,000 cycles, so the plan was 7.9x optimistic.
 *
 * O2 chunked the PATCH build and left this one whole, which made it the
 * largest single-block cost in the firmware. THE INVARIANT rule 2 names it
 * explicitly -- "recall, parameter refresh and NOTE BURSTS get a FIXED budget
 * of work per block" -- so O2 was only half done.
 *
 * A note touches the voices the allocator named, so this is popcount(mask) + 1
 * steps, not fifteen: the +1 is the shadow copy, which must happen FIRST and
 * as its own step because every later step writes into what it copied.
 *
 * ⚠ IT DOES NOT BUILD THE SHARED TAIL OR THE MASTER SET, and that is not an
 * omission -- eb_recall_build_voices did not either. A note moves per-voice
 * cells; the FX configuration and the master chain cannot have changed, and
 * the shadow copy carries the current ones forward. */
void eb_recall_chunk_begin_voices(eb_recall *r, unsigned mask);

/* ===================== O3: THE PARAMETER BUILD -- AN ARBITRARY SUBSET =====
 *
 * A parameter edit re-runs only the sub-builders its class needs
 * (data/b13_param_map.md §7): the voices in `mask`, the shared tail if
 * `tail`, the master set if `master`. The classes come from the GENERATED
 * eb_param_class table, which tools/engineb/devboot/paramclass_gate.c both
 * derives and holds -- pre-edit coefficients + this subset == full rebuild,
 * byte for byte, over all 59 parameters, with three teeth.
 *
 * Like the note build it copies the live bank into the shadow first, so what
 * is not rebuilt is carried, never stale. begin(mask=all, tail=1, master=1)
 * is NOT the same as eb_recall_chunk_begin: a patch build starts from a
 * memset shadow, this starts from a copy. A patch change must keep calling
 * eb_recall_chunk_begin. */
void eb_recall_chunk_begin_subset(eb_recall *r, unsigned mask,
                                  int tail, int master);

/* How many steps a begin() just committed to. The firmware budgets blocks
 * against this rather than counting them afterwards. */
int  eb_recall_chunk_steps(const eb_recall *r);
int  eb_recall_chunk_step(eb_recall *r);
/* Non-zero while a chunked build is part-way through. The caller must not
 * start a note build or a second patch build while this is true -- the shadow
 * has one owner at a time. */
int  eb_recall_chunk_busy(const eb_recall *r);

/* Steps 1-2: build into the SHADOW bank. Outside the window. */
void eb_recall_build(eb_recall *r);

/* Steps 3-8: swap, route latch, reverb wipe, voice mirror, barrier.
 * Returns 0 on success, non-zero if the quiescence precondition failed --
 * in which case NOTHING is published. */
int  eb_recall_publish(eb_recall *r);

/* THE INCREMENTAL BURST. Rebuilds ONLY the voices in `mask`, after copying the
 * live bank into the shadow so the rest is carried rather than stale. Read the
 * block above its definition: the caller must name every voice whose cells
 * moved, including a voice that was STOLEN. Master coefficients are copied,
 * not rebuilt -- correct for a note event, WRONG for a patch change, which
 * must keep calling eb_recall_build(). */
void eb_recall_build_voices(eb_recall *r, unsigned mask);

/* THE BURST SPLIT. Cycles spent in each half of the last eb_recall_build().
 * Written only when EB_RECALL_PROF is 1; zero otherwise. Read the block above
 * their definition in eb_recall.c for why they exist. */
extern unsigned long eb_recall_t_rc, eb_recall_t_mc;

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

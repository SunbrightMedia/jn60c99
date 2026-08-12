/* eb_recall.c -- THE PUBLISH CONTRACT for device-side recall.
 *
 * Drop into engine_b/dev/eb_recall.c. Written 2026-08-11 against the repo at
 * that date; every structural claim below carries a file:line.
 *
 * WHAT THIS FILE IS. The design (docs/engineb/data/devrecall/DESIGN_full.md)
 * says publishing a new patch is "one pointer swap at the block boundary".
 * That is not sufficient and, as stated, not sound. A pointer swap publishes
 * COEFFICIENTS. A patch change also moves STATE -- the reverb wipe countdown,
 * the delay route latch, the DCO's live coefficient copy, the ADSR gate
 * mirror -- and none of it is in eb_render_coefs or eb_master_coef. This file
 * is the ordered sequence, and the table at the bottom of the accompanying
 * report says what you HEAR when a step is dropped.
 *
 * THE REFERENCE ORDER, which the device must reproduce or it is a different
 * instrument (engine_b/shim/standalone/juno_driver.c:355-365):
 *
 *     if (EB_GEN_SEEN != eb_coef_gen) {
 *         eb_render_coefs_build(st, &EBC);      // voice coefficients
 *         eb_master_coefs_build(st, &MC);       // master coefficients
 *         eb_render_events_mirror(st, &EBS);    // gate320 / aux / dco_live
 *         EB_GEN_SEEN = eb_coef_gen;
 *     }
 *
 * engine_b/shim/voices/juno_driver.c:222-232 is the same three lines without
 * the master. Both run the whole group ATOMICALLY with respect to the sample
 * loop -- they sit at the top of the per-sample function, before
 * eb_engine_render_voices. On the device "atomically" has to be made true;
 * on the host it is true by being single-threaded.
 *
 * WHAT THE SHIMS DO NOT DO, AND THE DEVICE MUST. The shims recall COLD and
 * never change patch inside a scenario. So three transitions have never
 * executed anywhere in this project:
 *   - a DELAY TYPE change  (the route latch, five mirrors of one port cell)
 *   - a REVERB TYPE / PRE DELAY change (the wipe + pending tap latch)
 *   - a patch change with some voices AT REST (the shims force every voice
 *     awake: juno_driver.c:231 `EBE.v[v].atrest = 0;`)
 * Steps 5, 6 and 7c below exist entirely for those three, and none of them is
 * covered by any gate that exists today. Label: the code paths are READ from
 * the port and from engine B; the transitions are UNEXECUTED.
 */

#include "eb_coefs.h"
#include "eb_master_coefs.h"
#include "eb_render.h"
#include "ebdev.h"
#include <string.h>

/* ---------------------------------------------------------------------------
 * 0. THE OBJECTS, AND WHICH OF THEM MAY BE DOUBLE-BUFFERED
 *
 * DOUBLE-BUFFERED (read-only to the audio loop, so a shadow can be built at
 * leisure and swapped):
 *      eb_render_coefs   10,564 B measured on the host at trunk flags
 *      eb_master_coef     1,704 B
 *   -> 12,268 B for the shadow pair. The board prints ~163 KB free internal
 *      SRAM (esp32s3/main/juno_s3_listen.c:930-932), so this is affordable
 *      and both banks MUST be internal: they are read on the per-sample path
 *      by both cores.
 *
 * NOT DOUBLE-BUFFERED -- and this is defect 3's real content:
 *      the CELL ARRAY (ebdev_state, ~29 KB)
 *      eb_render_state  RS      (the audio loop mutates it every sample)
 *      eb_master_state  MS      (ditto)
 *
 * IS THE CELL ARRAY SAFE TO DOUBLE-BUFFER? NO. Three reasons, in order of
 * how hard they are to work around:
 *
 * (a) THE MIRROR WRITES INTO IT, and what it writes is a ONE-SHOT
 *     CONSUMPTION, not a value. engine_b/eb_coefs.c:372-379 reads the aux
 *     retrigger latch at 101504+32v and, if it is 1.0f, stores 0.0f BACK INTO
 *     THE ARRAY. The comment there says why: the port clears the same latch
 *     at src/voice_render.c:2178 when its voice function runs, and under
 *     engine B that function does not run, so an uncleared 1.0f "would be
 *     re-armed by every later event and the retrigger would fire repeatedly".
 *     With two cell arrays the arm and the consume can land in different
 *     buffers. Arm in A, publish from B: the retrigger is LOST (the note
 *     starts with the envelope where the last one left it). Arm in A, copy
 *     A->B, consume in B: A is still armed, so the NEXT publish retriggers a
 *     note nobody played. Both are audible and neither is a race in the
 *     threading sense -- they are wrong even single-threaded.
 *
 * (b) THE VOICE TILE IS SHARED AND IS MUTATED BY THE BUILD ITSELF.
 *     ebdev.c:26-33 `ebdev_voice_select(v)` pokes voice v's five scatter
 *     floats into the ONE shared tile before that voice's coefficients are
 *     built. So during the burst the cell array does not hold a consistent
 *     picture of any voice; it holds voice v's for the duration of voice v.
 *     A second writer during the burst -- a note-on landing on cell 320, a
 *     knob edit landing on 6864 -- corrupts whichever voice is in the tile.
 *
 * (c) THE ARRAY IS ~29 KB (DEVICE_RECALL.md:53-56) and the burst that fills
 *     it is ~28,000 instructions. Copying A->B to keep them consistent adds
 *     a second, pointless 29 KB touch inside the same window.
 *
 * THE CORRECT CONCURRENCY STORY, stated as rules:
 *
 *   R1. ONE cell array. SINGLE WRITER: the control context on core 0. MIDI,
 *       encoders, preset load and the note path all enqueue; the queue is
 *       drained at the block boundary and nowhere else.
 *   R2. THE AUDIO LOOP NEVER TOUCHES THE CELL ARRAY. This is TRUE TODAY and
 *       is worth keeping: eb_engine_render_voices / _range / _shared and
 *       eb_master_render take (engine, state, coefs, rings) and no `base`
 *       pointer -- engine_b/eb_render.h:279-330, engine_b/eb_master.h. It is
 *       the RECALL-PATH helpers that take `base`: eb_render_coefs_build
 *       (eb_coefs.c:14), eb_master_coefs_build (eb_master_coefs.c:19),
 *       eb_render_events_mirror (eb_coefs.c:360). The design's claim "nobody
 *       listens to the cell array" is true of the render and false of the
 *       publish; that is the whole of defect 3.
 *   R3. QUIESCENCE. Everything in eb_recall_publish() below touches RS, MS or
 *       the live coefficient pointers, so it may run ONLY while core 1 is
 *       parked. There is exactly one such window and the firmware already has
 *       it: between `while (!w_done) { }` (juno_s3_listen.c:794, the one
 *       barrier per block) and the next `w_go = 1` (:719). In that window
 *       core 1 executes only `while (!w_go) { if (w_quit) ... }` (:628) and
 *       touches no engine object. The existing load_coefs() calls at :1134
 *       and :1100 are already inside it -- safely, but by accident: nothing
 *       in the file says so, and moving load_coefs inside render_block, or
 *       making the worker free-running, would break it silently.
 *   R4. THE BURST MAY RUN OUTSIDE THE WINDOW, the publish may not. The
 *       ~90,000-cycle planning burst (DEVICE_RECALL.md:56-58) writes the cell
 *       array and the SHADOW coefficient bank, neither of which the audio
 *       loop reads. Only steps 3-8 below need the window, and they are a few
 *       hundred cycles.
 *   R5. NEVER PUBLISH MID-BLOCK. Core 0 renders its voice range and core 1
 *       renders the rest of the SAME sample (juno_s3_listen.c:748 vs :678).
 *       A swap seen by one core and not the other renders one sample under
 *       two patches -- and with a per-block prologue (w_shb, :744-753) the
 *       shared LFO and voice 0's glide would be from a third. That is
 *       correction 5 in DEVICE_RECALL.md:149-153 ("the chord splits") one
 *       level lower down.
 */

/* ---------------------------------------------------------------------------
 * THE LIVE POINTERS.
 *
 * `volatile` on the POINTER (not on the pointee) so core 1 reloads it once
 * per pass instead of hoisting it out of its loop. The pointee stays const so
 * the render signatures are unchanged. Same discipline as `w_cur`
 * (juno_s3_listen.c:463): one writer, core 0, and the worker latches a local
 * copy at the top of its pass so its whole pass sees one value. */
const eb_render_coefs * volatile EB_RC;      /* what render_range reads */
const eb_master_coef  * volatile EB_MC;      /* what eb_master_render reads */

static eb_render_coefs RC_BANK[2];           /* internal SRAM */
static eb_master_coef  MC_BANK[2];
static int             RC_CUR;               /* core 0 only */

/* deferred master publish -- see step 4 */
static const eb_master_coef *MC_PENDING;

/* the outgoing DELAY arm's id, kept because the port keeps it in ONE cell and
 * engine B keeps it in FIVE. See step 5. */
static int ROUTE_LAST = -1;

extern eb_render_state *RS;
extern eb_master_state *MS;
extern eb_engine        EBE;

unsigned long EB_PUB_GEN;                    /* publish counter, for the log */

/* ===========================================================================
 * STEP 1 and 2 -- THE BURST. Runs on core 0, OUTSIDE the quiescent window.
 * Nothing here is read by the audio loop.
 * ========================================================================= */
void eb_recall_build(const unsigned char *cells)
{
    const int shadow = 1 - RC_CUR;

    /* STEP 1: the voice coefficients, into the SHADOW bank.
     *
     * WHY THE SHADOW AND NOT IN PLACE: eb_render_coefs_build() memsets its
     * target first (eb_coefs.c:17) and then fills it voice by voice. Building
     * in place would hand the audio loop an all-zero coefficient set for the
     * length of the burst -- silence, then a click.
     *
     * ⚠ PER-VOICE: the builder reads per-voice cells through VBASE(base,v)
     * = base + v*10512 (eb_coefs.c:11). Under the 29 KB rebase only voice 0's
     * tile exists; ebdev.c:14-22 maps a v>0 offset only if it is one of the
     * five EBDEV_SCAT cells and otherwise counts a MISS and returns SINK.
     * That is defect 2. Until the per-voice map lands, this call must be
     * driven one voice at a time with ebdev_voice_select(v) around it, and
     * the caller must check EBDEV->miss == 0 afterwards. It is not this
     * file's job to fix, but publishing a coefficient set built through SINK
     * would publish voice 0's pitch and velocity into all six voices. */
    eb_render_coefs_build(cells, &RC_BANK[shadow]);

    /* STEP 2: the master coefficients, into the shadow. Same reason.
     * The rings are NOT rebuilt: the nine lengths are ONE set over all 64
     * factory patches and over a randomised bank (devrecall/probes/rings.c,
     * DEVICE_RECALL.md:74-77), so eb_master_rings survives a patch change
     * untouched. If that ever stops being true this is where a realloc would
     * have to go, and it cannot go in the quiescent window. */
    eb_master_coefs_build(cells, &MC_BANK[shadow]);

    /* The resonance LUT is deliberately NOT rebuilt here. Under
     * EB_VCF_RES_LUT the builder would call eb_vcf_res_prepare per voice
     * (eb_coefs.c:207-209) -- ~460,000 instructions for six voices, which
     * would dominate the entire burst. It is a function of SAMPLE RATE alone:
     * identical in every voice (2,688/2,688) and moved by 0 of 123
     * recall-affecting record bytes (DEVICE_RECALL.md:59-65). Build it once
     * at boot. Trunk default is EB_VCF_RES_LUT 0 (eb_vcf_res.h:47-48), so at
     * shipping flags this paragraph is a no-op and a warning for later. */
}

/* ===========================================================================
 * eb_recall_publish -- STEPS 3..8. THE QUIESCENT WINDOW ONLY.
 *
 * Call from core 0 after `while (!w_done)` returns and before `w_go = 1`.
 * `cells` is the SAME single array the burst wrote; steps 5-7 read
 * recall-written STATE out of it, which is not in either coefficient struct.
 * ========================================================================= */
void eb_recall_publish(unsigned char *cells)
{
    int v, k;

    /* STEP 3: THE PRECONDITION, ASSERTED, NOT ASSUMED.
     * A gate that cannot fail is not a gate; the same applies to a rule. */
    EB_PUB_ASSERT_QUIESCENT();      /* == (w_done && !w_go), or one core */

    /* STEP 4: THE POINTER SWAP.
     *
     * This is the only part the design had. It publishes the two read-only
     * structs to both cores at once.
     *
     * WHAT THE SWAP NEEDS TO BECOME VISIBLE TO CORE 1 -- exactly three
     * things, and no more:
     *   (i)  the pointer must be re-read by core 1 rather than hoisted:
     *        EB_RC / EB_MC are `volatile`-qualified pointers and the worker
     *        latches them into locals at the top of its pass, so its whole
     *        pass sees ONE value (the w_cur discipline, :459-463).
     *   (ii) the stores must not sink past the release of core 1. `w_go` is
     *        volatile (:415) but C99 volatile does NOT order the surrounding
     *        NON-volatile stores, so an explicit barrier is required. The
     *        release barrier is at step 8.
     *   (iii) both banks must be in memory core 1 can see coherently. Put
     *        them in INTERNAL SRAM. On this part the point is moot anyway --
     *        core 1 is parked at a spin and has executed no engine load since
     *        before the publish -- but internal placement also keeps them off
     *        the PSRAM path the FX chain was already measured suffering on
     *        (juno_s3_listen.c:955-975 makes the same argument for RS).
     * That is ALL it needs. It does NOT need a lock, a queue, or an atomic:
     * the publish is a single-writer store into a window where the reader is
     * provably not running. INFERRED for (ii)-(iii) from the toolchain and
     * the part; falsifiable by disassembling the publish and checking a MEMW
     * is emitted, and by moving the publish INTO render_block and hearing the
     * split chord R5 predicts. */
    RC_CUR = 1 - RC_CUR;
    EB_RC  = &RC_BANK[RC_CUR];

#if S3L_FX_PIPE
    /* THE MASTER COEFFICIENTS ARE PUBLISHED ONE BLOCK LATE, ON PURPOSE.
     * With the FX pipeline, core 1's next pass runs eb_master_render over
     * w_vbb[prev] -- the PREVIOUS chunk's voices (juno_s3_listen.c:659-672).
     * Publishing MC now would apply the new patch's delay, reverb and chorus
     * to voices rendered under the old patch: a 5.8 ms window in which the
     * instrument is half of each. Deferring MC by exactly one block restores
     * the alignment the port has by construction. */
    MC_PENDING = &MC_BANK[RC_CUR];
#else
    EB_MC = &MC_BANK[RC_CUR];
#endif

    /* STEP 5: THE DELAY ROUTE LATCH. Five mirrors of ONE port cell.
     *
     * THE PORT: cell 11022348 is written by the MASTER, not by recall. Each
     * delay arm compares it to its own id on entry and, if it differs, zeroes
     * that arm's feedback taps -- the click suppressor:
     *     arm 1        src/master_render.c:890-896  (zeroes 4297504/520/536)
     *     core (0,>=6) src/master_render.c:1055-1060 and :1116
     *     arm 2/3      :1272-1278
     *     arm 5        :1459-1468
     *     arm 4        :1871-1877
     *
     * ENGINE B: the ONE cell became FIVE INDEPENDENT COPIES --
     *     eb_master_state.route_change      (eb_master.h:141, core arm)
     *     eb_delay_t1.h:75   s11022348      (eb_delay_t1.c:97-103)
     *     eb_delay_t23.h:91  s11022348      (eb_delay_t23.c:96-102)
     *     eb_dly_t4.h:106    s11022348      (eb_dly_t4.c:102-108)
     *     eb_delay_t5.h:178  s11022348      (eb_delay_t5.c:175-184)
     * Each arm updates only its OWN copy, and exactly one arm runs per patch.
     * So on a DELAY TYPE change the incoming arm compares against a value it
     * wrote itself, sees no change, and the suppressor DOES NOT FIRE. The
     * port would have fired it. No gate has ever changed delay type inside a
     * render, which is why this has never been seen.
     *
     * THE FIX IS THE INVARIANT, NOT A SPECIAL CASE: at every publish, force
     * all five mirrors to the value the port's single cell would hold, i.e.
     * the id the LAST-RUNNING arm latched. Then the incoming arm's own
     * compare does the rest, exactly as the port's does. */
    if (ROUTE_LAST >= 0) {
        MS->route_change  = ROUTE_LAST;   /* eb_master.c:91-93 consumes+clears */
        MS->d1.s11022348  = ROUTE_LAST;
        MS->d23.s11022348 = ROUTE_LAST;
        MS->d4.s11022348  = ROUTE_LAST;
        MS->d5.s11022348  = ROUTE_LAST;
    }
    /* the id the NEW patch's arm will latch, for the next publish. The
     * mapping is the port's dispatch (eb_master.c:73-109): type 1 -> 1,
     * types 0 and >=6 -> 0 (the core, master_render.c:1116), 2..3 -> 2,
     * 4 -> 4, 5 -> 5. */
    {
        const int t = (int)MC_BANK[RC_CUR].delay_type;
        ROUTE_LAST = (t == 1) ? 1 : (t <= 1 || t >= 6) ? 0
                   : (t <= 3) ? 2 : (t == 4) ? 4 : 5;
    }

    /* STEP 6: THE REVERB WIPE AND THE PENDING TAP TABLE.
     *
     * THE PORT RE-ARMS A COUNTDOWN ON EVERY RECALL: src/reverb_recall.c:288
     * writes 256 into cell 10759872, and the header note at :274-287 records
     * that this was MEASURED from the plugin's own recall under emulation and
     * that it closed a warm-recall ledger item on patches 7 and 39 (+0.68 and
     * +0.60 dB warm, to -0.000 dB). While armed, the master wipes the reverb
     * line and holds the crossfade down (master_render.c:2108-2126), and on
     * completion latches the NEW tap indices from 11022208.. into 11022064..
     * (:2130+). reverb_recall.c:195-200 is what writes those pending taps,
     * and they move with REVERB TYPE and PRE DELAY.
     *
     * ENGINE B MODELS BOTH, and reads them ONLY in eb_master_state_seed
     * (eb_master_coefs.c:738-739) -- i.e. once, at context start. The
     * consumer is eb_reverb_process (eb_reverb.c:116-168): it latches
     * pending[] into taps[] and clears every ring when the countdown expires.
     * Nothing on the device re-arms it, so without this step a patch change
     * leaves the reverb on the PREVIOUS patch's tap layout forever and rings
     * the previous patch's tail through it.
     *
     * Note the shape: rev_pending and rev_wipe are STATE that RECALL WRITES.
     * They are the counter-example to "coefficients are the only thing recall
     * publishes", and the reason this function exists at all. */
    for (k = 0; k < EB_REV_NTAP; ++k)
        MS->rev_pending[k] = *(const int32_t *)EBDEV_AT(cells, 11022208u + 4u*k);
    MS->rev_wipe = *(const int32_t *)EBDEV_AT(cells, 10759872u);   /* == 256 */

    /* STEP 7: THE VOICE-SIDE MIRROR -- the device's eb_render_events_mirror.
     *
     * ⚠ THE SHIM FUNCTION CANNOT BE CALLED HERE. eb_render_events_mirror
     * addresses per-voice cells as base + v*10512 (eb_coefs.c:11, :364) and
     * the aux latch as base + 101504 + 32v (:365). Under the rebase those are
     * not addresses. Every read must go through the map. This is a
     * transcription of eb_coefs.c:360-385 with ebdev_at() substituted, and
     * with one behavioural change (7c) that the shims cannot have needed. */

    /* 7a. THE ADSR GATE MIRROR. eb_render.c:484-488 reads
     * st->gate_cell320[v] every sample to build the cvgate's p29 input, and
     * eb_coefs.c:371 refreshes it at every event boundary. The comment at
     * :366-370 is the justification for doing it at a boundary rather than
     * per sample: cell 320 is written ONLY by note events (src/juno_note.c);
     * inside src/voice_render.c its only writers are the save/restore pair at
     * :593 and :2177, which leave it unchanged.
     *
     * ⚠ For v > 0 this cell is NOT IN THE MAP: ebdev.c:16-22 places a v>0
     * offset only if it equals one of EBDEV_SCAT {1072,3968,5520,7600,10320}
     * (ebdev.c:11); 320 is not among them, so today it lands in SINK and
     * counts a miss. That is defect 2 stated at the one line where it bites
     * the publish. */
    for (v = 0; v < EB_NUM_VOICES; ++v) {
        RS->gate_cell320[v] = *(const float *)EBDEV_AT_V(cells, v, 320u);

        /* 7b. THE RETRIGGER ONE-SHOT, ARMED BY THE NOTE PATH AND CONSUMED
         * HERE. eb_coefs.c:372-379. The store back into the array is what
         * makes this a consumption; see (a) in the concurrency note above for
         * why it forbids double-buffering the array. */
        {
            float *aux = (float *)EBDEV_AT(cells, 101504u + 32u*(unsigned)v);
            if (*aux == 1.0f) { RS->aux_edge[v] = 1; *aux = 0.0f; }
        }
    }

    /* 7c. THE DCO's LIVE COEFFICIENT COPY -- and this is where the shim's own
     * mirror is WRONG FOR THE DEVICE.
     *
     * WHAT THE SHIM DOES: eb_coefs.c:384 clears dco_live_seeded for every
     * voice. eb_render.c:653-655 then re-seeds st->dco_live[v] from c->dco[v]
     * on that voice's next sample. Without it "the voice keeps the last
     * patch's non-pitch DCO fields" (eb_coefs.c:381-383) -- levels, gains,
     * the saturator, the sub threshold. An audible, bisected instrument: the
     * filter and envelope move to the new patch, the oscillator does not.
     *
     * WHY IT IS NOT ENOUGH ON THE DEVICE: the re-seed at :653 is inside the
     * SOUNDING path. An at-rest voice takes the `continue` at eb_render.c:382
     * and never reaches it, so its dco_live keeps the OLD patch's fields --
     * and it is still heard: eb_engine_advance_atrest (eb_render.c:270-284)
     * free-runs it from st->dco_live[v].inc and st->wt_live[v], and the
     * firmware's own measurement says those free-running voices are 29 % of
     * the signal and "the instrument's own character"
     * (juno_s3_listen.c:884-895). The shims cannot have hit this: they force
     * every voice awake (juno_driver.c:231).
     *
     * WHY A PLAIN STRUCT COPY IS A TRAP: eb_dco_coef is split by update rate
     * (eb_dco.h:113-125). eb_render_coefs_build memsets (eb_coefs.c:17) and
     * sets only the PER-RECALL half (:134-144), so c->dco[v].inc is ZERO.
     * Copying the whole struct into an at-rest voice sets its phase increment
     * to 0 and the voice stops free-running -- it goes silent until played,
     * which is a bigger change than the staleness it was fixing. A sounding
     * voice survives the same copy only because :697-706 overwrites the
     * per-sample half in the same sample.
     *
     * SO: sounding voices get the flag cleared (identical to the shim);
     * at-rest voices get a FIELD-WISE refresh that preserves the per-sample
     * half and re-derives what depends on it. */
    for (v = 0; v < EB_NUM_VOICES; ++v) {
        if (!EBE.v[v].atrest) {
            RS->dco_live_seeded[v] = 0;             /* eb_coefs.c:384 */
        } else {
            eb_dco_coef *L = &RS->dco_live[v];
            const float inc = L->inc, g = L->g, pw = L->pw;
            const float pwm1 = L->pwm1, pwp1 = L->pwp1;
            *L = EB_RC->dco[v];                     /* per-recall half */
            L->inc = inc; L->g = g; L->pw = pw;     /* per-sample half back */
            L->pwm1 = pwm1; L->pwp1 = pwp1;
#if EB_DCO_PULSEFAST
            eb_dco_set_edge_thresholds(L);          /* eb_render.c:702-706 */
#endif
#if EB_DCO_WT
            /* wt_live's non-pitch fields are refilled from dco_live every
             * sample on the sounding path (eb_render.c:412-437) but NOT on
             * the at-rest path, which only re-sets pitch
             * (eb_render.c:279-281). Refill them here or the wavetable voice
             * free-runs at the old patch's levels and sub threshold. */
            {   eb_dco_wt_coef *w = &RS->wt_live[v];
                eb_dco_wt_bind_tables(w);
                w->sat_hi = L->sat_hi;     w->sat_lo    = L->sat_lo;
                w->lvl_saw = L->lvl_saw;   w->lvl_pulse = L->lvl_pulse;
                w->lvl_sub = L->lvl_sub;   w->gn_saw    = L->gn_saw;
                w->gn_pulse = L->gn_pulse; w->gn_sub    = L->gn_sub;
                w->subthr = L->subthr;
            }
#endif
        }
    }

    /* 7d. THE CONTROL-RATE HOLD SLOTS, if the build has any.
     * eb_render.c:564-651: with EB_CR_N > 1 each held module keeps its last
     * output in st->cr_*[v] and, under EB_CR_LERP, the next emitted value is
     * the MIDPOINT of the held and the new (eb_render.c:398-410). Across a
     * patch change that midpoint is halfway between two different patches.
     * Re-priming makes the first sample after the publish emit the new value
     * straight, which is exactly what the at-rest path already does for a
     * new note (eb_render.c:384-390). Trunk/shipping default is EB_CR_N == 1
     * -- control-rate holds were CLOSED BY MEASUREMENT (CLAUDE.md live state)
     * -- so this compiles away today and is here so a future flag cannot
     * quietly reintroduce a cross-patch interpolation. */
#if EB_CR_N > 1
    for (v = 0; v < EB_NUM_VOICES; ++v) { RS->cr_ph[v] = 0; RS->cr_prime[v] = 1; }
#endif

    /* STEP 8: THE RELEASE BARRIER AND THE LOG.
     *
     * Everything above is an ordinary store. This is what keeps the compiler
     * and the store buffer from moving any of it past `w_go = 1`. It costs
     * one instruction per publish and it is the difference between a contract
     * and a hope. */
    __sync_synchronize();
    ++EB_PUB_GEN;
    /* Print min/max/last burst CCOUNT from the first flash. DEVICE_RECALL.md
     * correction 6: not one instruction of recall has executed on Xtensa, and
     * that is Step 1's gate, not a footnote. */
}

/* ---------------------------------------------------------------------------
 * WHAT IS DELIBERATELY NOT IN THIS FUNCTION
 *
 * - eb_render_state_seed / eb_master_state_seed. They memset the whole state
 *   (eb_coefs.c:322, eb_master_coefs.c:398) -- envelopes to zero, DCO phases
 *   to zero, the delay and reverb lines to zero. Running either on a patch
 *   change restarts every sounding note and silences the FX tail. A patch
 *   change is not a context start. Steps 5-7 are precisely the SUBSET of the
 *   two seeders that recall really writes.
 *
 * - the 8,488-byte voice-state memcpy. juno_s3_listen.c:271 (load_coefs) and
 *   :594 copy S3L_VOICE_SZ bytes of eb_render_state out of the blob, and the
 *   comment at :262-270 says why it is there: "the gate lives in state --
 *   with coefficients alone the note does not release at all, MEASURED". That
 *   memcpy is a STAND-IN FOR A NOTE PATH, not a recall mechanism. It works
 *   only because the blob holds pre-captured on/off snapshots and because the
 *   firmware's hold length is pinned to the length the snapshot was captured
 *   at (:1213-1220 -- a mismatch was audible as a pluck at the end of every
 *   note). THIS IS THE SEAM WHERE THE REAL NOTE PATH ATTACHES, and the shape
 *   of the attachment is:
 *
 *       note event  ->  write the 13 per-voice cells (DEVICE_RECALL.md:140-144:
 *                       304 pitch, 320 gate, 6864 + 9680 velocity, 1856,
 *                       9824, 592 portamento gate, aux 101504+32v, plus the
 *                       five already-mapped scatter cells)
 *                   ->  REBUILD THAT VOICE'S COEFFICIENT TILE. Six of those
 *                       eight are read by the builder -- 304 at eb_coefs.c:264,
 *                       6864 at :58, 9680 at :92, 592 at :218, 1856 at :233,
 *                       9824 at :93 -- so a note-on is a coefficient change,
 *                       not only a state change.
 *                   ->  eb_recall_publish() steps 3,4,7,8 (NOT 5,6: a note
 *                       does not change delay type or reverb taps).
 *
 *   So the note path and the patch path share this function; a note publish
 *   is the patch publish minus the master steps. What the note path must NOT
 *   do is copy a state snapshot: the envelope and phase must be advanced by
 *   the engine, from the gate. The blob-snapshot mechanism must be deleted at
 *   the same commit that adds the note path, or the two will fight -- the
 *   snapshot overwrites gate_cell320 and the aux latch that step 7 just set.
 *
 * - a whole-array rebuild on a single-parameter edit. Out of scope here and
 *   listed as unbuilt in DEVICE_RECALL.md:166-171, but note that it uses this
 *   same publish: build shadow, swap, and do NOT run step 7c (re-seeding
 *   dco_live mid-note is audible on a live knob move).
 */

/* eb_recall.c -- THE PUBLISH CONTRACT. Read eb_recall.h first.
 *
 * Every step below carries the reason it exists and what you HEAR if it is
 * omitted. That is not decoration: three of these transitions have never
 * executed anywhere in this project, so the failure mode is the only evidence
 * that exists for them until a rendered device null does.
 */
#include "eb_recall.h"
#include "ebdev.h"
#include "eb_dco.h"
#include "eb_dco_wt.h"
#include <string.h>

const eb_render_coefs * volatile EB_RC;
const eb_master_coef  * volatile EB_MC;

static int always_quiescent(void) { return 1; }
int (*eb_recall_quiescent)(void) = always_quiescent;

/* A release barrier. C99 `volatile` orders volatile accesses against each
 * other and says NOTHING about the surrounding non-volatile stores, so the
 * pointer store can sink past the flag that hands the worker its go-ahead.
 * INFERRED for this toolchain, and falsifiable: disassemble the publish and
 * check a MEMW is emitted. */
#if defined(__GNUC__)
#define EB_RELEASE() __sync_synchronize()
#else
#define EB_RELEASE() do { } while (0)
#endif

void eb_recall_init(eb_recall *r,
                    eb_render_coefs *rc0, eb_render_coefs *rc1,
                    eb_master_coef *mc0, eb_master_coef *mc1,
                    eb_render_state *rs, eb_master_state *ms,
                    const eb_engine *eng)
{
    memset(r, 0, sizeof *r);
    r->rc[0] = rc0; r->rc[1] = rc1;
    r->mc[0] = mc0; r->mc[1] = mc1;
    r->rs = rs; r->ms = ms; r->eng = eng;
    r->cur = 0;
    r->route_last = -1;
    r->chunk_step = 0;
    r->chunk_mask = 0u;
    r->chunk_tail = 0;
    r->chunk_master = 0;
    EB_RC = rc0;
    EB_MC = mc0;
}

/* ---- THE BURST SPLIT, measured rather than attributed ---------------------
 * MEASURED 2026-08-12 on silicon: the whole burst is ~1.95 M cycles, against
 * this header's ~90,000. That is 21x, and it is the third time a number about
 * this burst has been stated without being measured -- the res-LUT
 * attribution, my own 90,000, and the "fits in ONE audio block" claim in
 * DEVICE_RECALL.md are all now suspect for the same reason.
 *
 * So the burst is split in two and each half is COUNTED. Nothing is optimised
 * until these two numbers exist. Zero cost when EB_RECALL_PROF is off. */
unsigned long eb_recall_t_rc = 0, eb_recall_t_mc = 0;
#if EB_RECALL_PROF
/* CCOUNT is read INLINE and not through esp_cpu.h on purpose: these sources
 * build at -std=c99, where the bare `asm` keyword IDF's xt_utils.h uses is not
 * a keyword. `__asm__` is the standard-clean spelling and needs no header. */
static inline unsigned long eb__ccount(void)
{
    unsigned long c;
    __asm__ __volatile__("rsr.ccount %0" : "=a"(c));
    return c;
}
static unsigned long eb__t0;
#define EB_RECALL_T0() eb__t0 = eb__ccount()
#define EB_RECALL_T1(dst) (dst) = eb__ccount() - eb__t0
#else
#define EB_RECALL_T0() do { } while (0)
#define EB_RECALL_T1(dst) do { } while (0)
#endif

/* ==================================================== STEPS 1-2: THE BURST */
void eb_recall_build(eb_recall *r)
{
    const int shadow = 1 - r->cur;
    int v;

    /* 1. Into the SHADOW. eb_render_coefs_build memsets its output first
     *    (eb_coefs.c:17); building in place would hand the audio loop an
     *    all-zero coefficient set for the whole ~90,000-cycle burst -- about
     *    2 ms of silence mid-note, then a click as the values appear.
     *
     *    ebdev_voice_select() inside eb_coefs.c's VBASE pokes each voice's
     *    scatter into the shared tile, so the builder must be allowed to walk
     *    the voices itself; there is nothing to do here but call it. What DOES
     *    have to be true is that no offset sinks: a SINK-built set puts voice
     *    0's pitch and velocity into every voice. The count is captured at
     *    publish and the firmware mutes on it. */
    EB_RECALL_T0();
    eb_render_coefs_build((const unsigned char *)0, r->rc[shadow]);
    EB_RECALL_T1(eb_recall_t_rc);

    /* 2. Master coefficients, same reason.
     *    NOT rebuilt here, deliberately:
     *      - the delay RINGS. The nine lengths are ONE set over the factory
     *        bank AND over a fully randomised synthetic bank (probes/rings.c).
     *        If that ever stops being true the realloc goes HERE and can never
     *        go in the window.
     *      - the VCF resonance LUT. ~460,000 instructions for six voices
     *        (eb_coefs.c:207-209) and a function of SAMPLE RATE alone --
     *        2,688 of 2,688 comparisons identical across voices, 0 of 123
     *        recall-affecting record bytes move it. Build it once at boot. */
    EB_RECALL_T0();
    eb_master_coefs_build((const unsigned char *)0, r->mc[shadow]);
    EB_RECALL_T1(eb_recall_t_mc);

    (void)v;
}

/* ==================================== O2: THE CHUNKED PATCH BUILD =========
 * The pieces of eb_recall_build, callable one at a time. See eb_recall.h for
 * why this is safe (the shadow is never read by the audio path) and for the
 * gate that holds it bit-identical to the monolithic build.
 *
 * THE ORDER IS THE MONOLITHIC ORDER: memset, then voices 0..7, then the shared
 * tail, then the master. Preserved deliberately -- these write into one struct
 * and a reordering would only be provably harmless after someone proved no two
 * steps touch the same field. Keeping the order means nobody has to. */
void eb_recall_chunk_begin(eb_recall *r)
{
    const int shadow = 1 - r->cur;
    /* The memset happens HERE, in step 0, and not lazily inside step 1: a
     * caller that begins a build and is then interrupted must leave a shadow
     * that is definitely stale-and-zeroed rather than half of two patches. */
    memset(r->rc[shadow], 0, sizeof *r->rc[shadow]);
    r->chunk_mask = (1u << EB_NUM_VOICES) - 1u;   /* a patch moves them all */
    r->chunk_tail = 1;                            /* ...and the tail+master */
    r->chunk_master = 1;
    r->chunk_step = 1;
}

void eb_recall_chunk_begin_voices(eb_recall *r, unsigned mask)
{
    const int shadow = 1 - r->cur;
    r->chunk_mask = mask & ((1u << EB_NUM_VOICES) - 1u);
    r->chunk_tail = 0;             /* a note moves no FX and no master cell */
    r->chunk_master = 0;
    /* AN EMPTY MASK TOUCHES NOTHING, INCLUDING THE COPY. eb_recall_build_voices
     * returns before its copy for mask 0, so a chunked path that copied anyway
     * would differ from the monolith on that one input -- which the gate saw
     * and refused. Matching it exactly is also the safer behaviour: no voices
     * changed, so the shadow has no business being disturbed. */
    if (r->chunk_mask == 0u) { r->chunk_step = 0; return; }
    /* THE COPY IS STEP 0 AND MUST BE, for the same reason the memset is: every
     * later step writes into this shadow, so a build interrupted after the
     * copy holds the CURRENT patch's coefficients -- correct, merely stale --
     * rather than a mixture. This is the same copy eb_recall_build_voices
     * makes; it has simply stopped sharing a block with eight voice builds. */
    *r->rc[shadow] = *r->rc[r->cur];
    *r->mc[shadow] = *r->mc[r->cur];
    r->chunk_step = 1;
}

/* The subset begin. The copy-first rule is begin_voices's, for the same
 * reason: an interrupted build must hold a bank that is CURRENT-but-stale,
 * never a mixture. An empty subset touches nothing, including the copy. */
void eb_recall_chunk_begin_subset(eb_recall *r, unsigned mask,
                                  int tail, int master)
{
    const int shadow = 1 - r->cur;
    r->chunk_mask   = mask & ((1u << EB_NUM_VOICES) - 1u);
    r->chunk_tail   = tail ? 1 : 0;
    r->chunk_master = master ? 1 : 0;
    if (r->chunk_mask == 0u && !r->chunk_tail && !r->chunk_master) {
        r->chunk_step = 0;
        return;
    }
    *r->rc[shadow] = *r->rc[r->cur];
    *r->mc[shadow] = *r->mc[r->cur];
    r->chunk_step = 1;
}

int eb_recall_chunk_steps(const eb_recall *r)
{
    int n = 0, v;
    for (v = 0; v < EB_NUM_VOICES; ++v)
        if (r->chunk_mask & (1u << v)) ++n;
    return n + (r->chunk_tail ? 1 : 0) + (r->chunk_master ? 1 : 0);
}

int eb_recall_chunk_busy(const eb_recall *r)
{
    return r->chunk_step != 0;
}

int eb_recall_chunk_step(eb_recall *r)
{
    const int shadow = 1 - r->cur;
    int st = r->chunk_step;

    if (st == 0) return 0;                    /* nothing in progress */

    /* THE CURSOR IS A SLOT WALK. Slots 1..V are the voices, V+1 is the shared
     * tail, V+2 the master set; a slot the build does not owe is SKIPPED here,
     * never half-executed. The first version of the subset extension ran the
     * master build in the tail's slot when the tail was not owed and then ran
     * it AGAIN in its own -- idempotent, but a step count that lies to the
     * budget. Skip first, then execute exactly the slot under the cursor. */
    while (st <= EB_NUM_VOICES && !(r->chunk_mask & (1u << (st - 1)))) ++st;
    if (st == EB_NUM_VOICES + 1 && !r->chunk_tail)   ++st;
    if (st == EB_NUM_VOICES + 2 && !r->chunk_master) {
        r->chunk_step = 0;                    /* owed nothing further */
        return 0;
    }
    if (st > EB_NUM_VOICES + 2) { r->chunk_step = 0; return 0; }

    if (st <= EB_NUM_VOICES) {
        /* one voice. The most expensive single step, and the reason the step
         * granularity is a voice and not "the voice build": MEASURED at about
         * 140,000 cycles each against a ~1.12 M whole. */
        EB_RECALL_T0();
        eb_coefs_voice((const unsigned char *)0, r->rc[shadow], st - 1);
        EB_RECALL_T1(eb_recall_t_rc);
    } else if (st == EB_NUM_VOICES + 1) {
        /* A NOTE BUILD NEVER REACHES HERE. It owes no shared tail and no
         * master set: a note moves per-voice cells only, and the shadow copy
         * carries the current FX and master values forward. */
        eb_render_coefs_build_shared((const unsigned char *)0, r->rc[shadow]);
    } else {
        EB_RECALL_T0();
        eb_master_coefs_build((const unsigned char *)0, r->mc[shadow]);
        EB_RECALL_T1(eb_recall_t_mc);
    }

    /* ⚑ RETURN 0 ON THE CALL THAT DID THE LAST PIECE OF WORK, not on a later
     * one that finds nothing to do. The first version returned 1 after the
     * final voice and 0 from an extra call, which cost a whole 5.8 ms block
     * per note build to discover it was finished -- a 3-voice note took 4
     * blocks. The gate caught it by counting steps against popcount(mask),
     * which is why the count is part of the contract and not a nicety. */
    ++st;
    while (st <= EB_NUM_VOICES && !(r->chunk_mask & (1u << (st - 1)))) ++st;
    if (st == EB_NUM_VOICES + 1 && !r->chunk_tail)   ++st;
    if (st == EB_NUM_VOICES + 2 && !r->chunk_master) ++st;
    if (st <= EB_NUM_VOICES + 2) { r->chunk_step = st; return 1; }
    r->chunk_step = 0;
    return 0;
}

/* ============================================ THE INCREMENTAL BURST (NOTES)
 * WHY. A patch change alters every voice's coefficients and every master
 * coefficient, and eb_recall_build above is the honest price of that. A KEY
 * PRESS does not: juno_note.c writes cells 304, 320, 6864 and 9680 for ONE
 * voice, so seven eighths of the voice build and the whole master build are
 * recomputing values that cannot have moved.
 *
 * MEASURED on silicon 2026-08-12, and this is the arithmetic that justifies
 * the function: the voice build is 1,082,812 cycles and the master build is
 * 121,213, against a 5,442-cycle sample budget and a 5.8 ms block. A key press
 * paying the full burst is 8 ms of stall -- a click on every note.
 *
 * WHAT MAKES IT EXACT. The shadow bank holds the build from TWO patches ago,
 * not the live one, so a partial build into it would leave seven voices stale.
 * The copy below is therefore not an optimisation to be trimmed later: it is
 * what makes the result equal to a full build. It costs one 18 KB memcpy of
 * internal SRAM against ~135,000 cycles of arithmetic per voice skipped.
 *
 * THE CALLER'S OBLIGATION, stated because getting it wrong is silent: `mask`
 * must have a bit set for EVERY voice whose cells changed. A note that steals
 * a voice changes the STOLEN one too. eb_alloc names both, and the note path
 * passes what it names -- it does not infer. */
void eb_recall_build_voices(eb_recall *r, unsigned mask)
{
    const int shadow = 1 - r->cur;
    int v;

    if (mask == 0u) return;

    *r->rc[shadow] = *r->rc[r->cur];
    *r->mc[shadow] = *r->mc[r->cur];

    EB_RECALL_T0();
    for (v = 0; v < EB_NUM_VOICES; ++v)
        if (mask & (1u << v))
            eb_coefs_voice((const unsigned char *)0, r->rc[shadow], v);
    EB_RECALL_T1(eb_recall_t_rc);
    eb_recall_t_mc = 0;
}

/* ================================== STEPS 3-8: THE QUIESCENT WINDOW ONLY */
int eb_recall_publish(eb_recall *r)
{
    int v, k, t;

    /* 3. PRECONDITION, ASSERTED not assumed. Everything below writes state the
     *    worker core reads. The existing firmware calls its coefficient load
     *    inside (w_done && !w_go) already -- safely, but BY ACCIDENT: nothing
     *    in juno_s3_listen.c says so, and making the worker free-running
     *    breaks it silently. */
    if (!eb_recall_quiescent || !eb_recall_quiescent()) return 1;

    r->unmapped_at_publish = EBDEV_S.miss;

    /* 4. THE SWAP -- the only part the first design had. */
#ifndef EB_RECALL_TOOTH_NOSWAP
    r->cur = 1 - r->cur;
    EB_RC  = r->rc[r->cur];
#endif
#if EB_RECALL_FX_PIPE
    /* MASTER COEFFICIENTS GO ONE BLOCK LATE, ON PURPOSE. With the FX pipeline
     * the worker's next pass runs eb_master_render over the PREVIOUS chunk's
     * voices. Publishing MC now applies the new patch's delay/reverb/chorus to
     * voices rendered under the old one: one chunk (5.8 ms at CHUNK=256) of
     * the wrong effect on every program change. Deferring by exactly one block
     * restores the alignment the port has by construction. */
    /* ⚠ KNOWN, MEASURED, UNGUARDED: two publishes with no block boundary
     * between them overwrite mc_pending and the first patch's master
     * coefficients are never applied. The firmware calls
     * eb_recall_block_boundary() every block, so it cannot happen there -- but
     * nothing here says so, and the gate's own publish section provoked it
     * while proving the deferral. Recorded rather than "fixed" blind: the right
     * answer is a caller contract, and the caller does not exist yet. */
    r->mc_pending = r->mc[r->cur];
#else
    EB_MC = r->mc[r->cur];
#endif

    /* 5. THE DELAY ROUTE LATCH -- five mirrors of ONE port cell.
     * PORT: cell 11022348 is written by the MASTER, not by recall. Each arm
     * compares it to its own id on entry and zeroes its feedback taps if it
     * differs -- the click suppressor (master_render.c:890-896, :1272-1278,
     * :1459-1468, :1871-1877).
     * ENGINE B: FIVE independent copies -- eb_master.h:141 route_change,
     * eb_delay_t1.c:97-103, eb_delay_t23.c:96-102, eb_dly_t4.c:102-108,
     * eb_delay_t5.c:175-184. Each arm updates only its own and one arm runs
     * per patch, so on a DELAY TYPE change the incoming arm compares against
     * a value IT wrote, sees no change, and THE SUPPRESSOR DOES NOT FIRE.
     * The invariant, not a special case: force all five to the id the
     * last-running arm latched, and let the incoming arm's own compare do the
     * rest, exactly as the port's does.
     * OMIT IT and you hear the old delay's feedback tail re-entering the new
     * delay line: a click, then a rogue repeat belonging to neither patch. */
#ifndef EB_RECALL_TOOTH_NOROUTE
    if (r->route_last >= 0) {
        r->ms->route_change  = r->route_last;
        r->ms->d1.s11022348  = r->route_last;
        r->ms->d23.s11022348 = r->route_last;
        r->ms->d4.s11022348  = r->route_last;
        r->ms->d5.s11022348  = r->route_last;
    }
#endif
    t = (int)r->mc[r->cur]->delay_type;             /* eb_master.c:73-109 */
    r->route_last = (t == 1) ? 1
                  : (t <= 1 || t >= 6) ? 0
                  : (t <= 3) ? 2
                  : (t == 4) ? 4 : 5;

    /* 6. THE REVERB WIPE + PENDING TAPS -- state that RECALL writes.
     * PORT: src/reverb_recall.c:288 writes 256 into cell 10759872 on EVERY
     * recall, and :274-287 records that this was measured from the plugin's
     * own recall and closed a warm-recall ledger item (+0.68/+0.60 dB on
     * patches 7 and 39). While armed the master wipes the line and holds the
     * crossfade down, then latches the new taps on completion.
     * ENGINE B reads both ONLY in eb_master_state_seed (eb_master_coefs.c:738
     * -739) -- once, at context start. A patch change is not a context start.
     * OMIT the wipe and the reverb NEVER re-latches its pending taps
     * (eb_reverb.c:152-155 latches only when the countdown expires): the new
     * patch's REVERB TYPE and PRE DELAY are ignored for the rest of the
     * power-on session. */
#ifndef EB_RECALL_TOOTH_NOREV
    for (k = 0; k < EB_REV_NTAP; ++k)
        r->ms->rev_pending[k] =
            *(const int32_t *)ebdev_at(11022208u + 4u * (unsigned)k);
    r->ms->rev_wipe = *(const int32_t *)ebdev_at(10759872u);
#endif

    /* 7. THE VOICE MIRROR -- the device's eb_render_events_mirror.
     * The shim function CANNOT be called: it addresses per-voice cells as
     * base + v*10512 (eb_coefs.c:11,:364) and the aux latch as
     * base + 101504 + 32v (:365). Under the rebase those are not addresses.
     * This is eb_coefs.c:360-385 with ebdev_at() substituted, plus 7c. */
    for (v = 0; v < EB_NUM_VOICES; ++v) {
        /* 7a. THE ADSR GATE. eb_render.c:484-488 reads gate_cell320[v] every
         * sample; eb_coefs.c:366-370 justifies refreshing it at an event
         * boundary rather than per sample. For v>0 this is exactly the cell
         * that defect 2 left unaddressable -- with a shared tile every voice
         * takes voice 0's gate and voices 1..N-1 cannot sound a note. */
#ifndef EB_RECALL_TOOTH_NOGATE
        r->rs->gate_cell320[v] = *(const float *)ebdev_at_v(v, 320u);
#endif
        /* 7b. the retrigger one-shot: armed by the note path, CONSUMED here.
         * The store BACK is what makes this a consumption, and it is reason
         * (1) that the cell array cannot be double-buffered. Omit it and the
         * retrigger is re-armed by every later event: a machine-gun on every
         * program change. */
#ifndef EB_RECALL_TOOTH_NOAUX
        {
            float *aux = (float *)ebdev_at(101504u + 32u * (unsigned)v);
            if (*aux == 1.0f) { r->rs->aux_edge[v] = 1; *aux = 0.0f; }
        }
#endif
    }

    /* 7c. THE DCO LIVE COPY. The shim clears dco_live_seeded for every voice
     * (eb_coefs.c:384) and eb_render.c:648-651 re-seeds from c->dco[v] on that
     * voice's next sample. Omit it and you get THE BISECTED INSTRUMENT: filter,
     * envelope, LFO and FX move to the new patch, the oscillator keeps the old
     * patch's levels, gains, saturator and sub threshold.
     *
     * NOT ENOUGH ON THE DEVICE, and this is the part the shims cannot reach
     * because they force every voice awake (juno_driver.c:231): the re-seed at
     * :648 is inside the SOUNDING path. An AT-REST voice takes `continue` at
     * eb_render.c:382 and never reaches it, yet is still heard -- the at-rest
     * advance free-runs it from dco_live[v], and the firmware's own
     * measurement puts those free-running voices at 29 % of the signal.
     *
     * A PLAIN STRUCT COPY IS A TRAP. eb_dco_coef is split by update rate
     * (eb_dco.h:113-125); the builder memsets and fills only the per-recall
     * half, so c->dco[v].inc == 0. Copying whole into an at-rest voice sets
     * its increment to 0 and it STOPS free-running -- a bigger change than the
     * staleness. A sounding voice survives only because eb_render.c:697-706
     * overwrites the per-sample half that same sample. So: field-wise. */
    for (v = 0; v < EB_NUM_VOICES; ++v) {
        int atrest = r->eng ? (int)r->eng->v[v].atrest : 0;
        if (!atrest) {
#ifndef EB_RECALL_TOOTH_NODCO
            r->rs->dco_live_seeded[v] = 0;
#endif
            continue;
        }
        {
            eb_dco_coef *L = &r->rs->dco_live[v];
            /* SAVE THE PER-SAMPLE HALF BY ITS EXTENT, NOT BY NAMING FIELDS.
             * It used to name five (inc/g/pw/pwm1/pwp1) and that is a list
             * nothing kept in step with the struct: with -DEB_DCO_RECIP=1
             * eb_dco.h grows rm1/rp1 in the SAME per-sample group and the
             * hand list drops them -- PROVEN by compiling the old statement at
             * that flag, where rm1/rp1 came back 0.000 instead of 0.400/0.220.
             * It is inert today (eb_dco_advance reads only inc and subthr) and
             * it is exactly the trap step 7c exists to warn about, so the
             * boundary is now the struct's own: eb_dco.h declares the split and
             * EB_DCO_PERSAMPLE_BYTES is where it falls. */
            unsigned char keep[EB_DCO_PERSAMPLE_BYTES];
            memcpy(keep, L, EB_DCO_PERSAMPLE_BYTES);
            *L = r->rc[r->cur]->dco[v];              /* the per-recall half */
            memcpy(L, keep, EB_DCO_PERSAMPLE_BYTES);
#if EB_DCO_PULSEFAST
            eb_dco_set_edge_thresholds(L);           /* eb_render.c:702-706 */
#endif
#if EB_DCO_WT
            /* wt_live's non-pitch fields are refilled from dco_live every
             * sample on the SOUNDING path (eb_render.c:412-437); the at-rest
             * path only re-sets pitch, so they must be refreshed here. */
            {
                eb_dco_wt_coef *w = &r->rs->wt_live[v];
                eb_dco_wt_bind_tables(w);
                w->lvl_saw = L->lvl_saw; w->lvl_pulse = L->lvl_pulse;
                w->lvl_sub = L->lvl_sub; w->gn_saw = L->gn_saw;
                w->gn_pulse = L->gn_pulse; w->gn_sub = L->gn_sub;
            }
#endif
        }
    }

    /* 7d. CONTROL-RATE HOLD SLOTS. Under EB_CR_LERP the next emitted value is
     * the MIDPOINT of held and new (eb_render.c:398-410) -- across a publish
     * that is halfway between two patches. Re-priming emits the new value
     * straight, which is what the at-rest path already does for a new note.
     * EB_CR_N is 1 by default (control-rate holds were CLOSED BY MEASUREMENT),
     * so this compiles away; it is here so a future flag cannot quietly
     * reintroduce a cross-patch lerp. */
#if defined(EB_CR_N) && EB_CR_N > 1
    for (v = 0; v < EB_NUM_VOICES; ++v) { r->rs->cr_ph[v] = 0; r->rs->cr_prime[v] = 1; }
#endif

    /* 8. RELEASE BARRIER + generation counter. One instruction; the difference
     * between a contract and a hope. */
    EB_RELEASE();
    ++r->gen;
    return 0;
}

void eb_recall_block_boundary(eb_recall *r)
{
    if (r->mc_pending) { EB_MC = r->mc_pending; r->mc_pending = 0; }
}

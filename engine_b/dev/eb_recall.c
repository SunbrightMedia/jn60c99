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
    EB_RC = rc0;
    EB_MC = mc0;
}

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
    eb_render_coefs_build((const unsigned char *)0, r->rc[shadow]);

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
    eb_master_coefs_build((const unsigned char *)0, r->mc[shadow]);

    (void)v;
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

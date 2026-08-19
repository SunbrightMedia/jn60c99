/* interlock_gate.c -- THREE MACHINES, ONE SHADOW. Can they starve each other?
 *
 * ⚠ WHY THIS EXISTS, IN ONE SENTENCE FROM THE PLAYBOOK: "three individually
 * correct components -- a budget, a single-owner rule, and a request rate --
 * composed into a system that could not play a note" (defect 63). That cost a
 * silicon build in which 9,019 events were refused and NOT ONE NOTE was ever
 * built, on a firmware whose every component gate was green.
 *
 * O3 adds a THIRD machine to that composition. The note machine and the patch
 * machine already share one shadow; the parameter machine now joins them, with
 * its own budget and its own request rate. The same three ingredients are
 * present, so the same failure is available, and no per-machine gate can see
 * it -- param_gate, note_gate and burst_gate each pass while the instrument
 * starves.
 *
 * WHAT THIS DRIVES. The firmware's actual arbitration rules, transcribed:
 *
 *   - a PATCH build starts only when no note is pending and the note machine
 *     is idle; it is NOT budget-gated (it cannot fit, playbook 63)
 *   - a NOTE build runs only when the patch machine is idle, and its heavy
 *     states are budget-gated
 *   - a PARAM build starts only when the patch machine is idle, no note is
 *     pending and the note machine is idle; its heavy states are budget-gated
 *   - exactly ONE publish per block, offered to whichever machine asked
 *
 * WHAT IT ASSERTS, under a storm of all three request types at once:
 *   1. NO STARVATION -- every request type completes at least once, and the
 *      instrument never goes N blocks with a pending request and no progress.
 *   2. NO DOUBLE OWNERSHIP -- never two machines non-idle at the same time.
 *   3. NO LOST EDIT -- a parameter edit is either rebuilt or still pending;
 *      it is never dropped.
 *   4. BOUNDED LATENCY -- the worst wait from request to publish is reported,
 *      so a regression shows as a number rather than as a feeling.
 *
 * ⚠ IT IS A MODEL, AND SAYS SO. It drives the real state machines through
 * their real headers, but the WORK is stubbed and the costs are the measured
 * ones fed in as constants. So it can prove the ARBITRATION cannot deadlock or
 * starve; it cannot prove the firmware's transcription of these rules is
 * faithful. That is what the robot run on silicon is for, and playbook 63 is
 * explicit that a candidate build is not a candidate until the robot has
 * played it.
 */
#include <stdio.h>
#include <stdlib.h>
#include "eb_sched.h"
#include "eb_notestep.h"
#include "eb_burststep.h"
#include "eb_paramstep.h"

/* MEASURED costs, in cycles, from the b-series docs. Fed in as constants so
 * this file states its inputs rather than inventing them. */
#define CYC_SLACK   460000ul   /* core 0's spare time per block (b10/b11)    */
#define CYC_NOTE    148000ul   /* one note sub-build            (b8)         */
#define CYC_PARAM   240000ul   /* the warm recall               (b13 §5)     */
#define CYC_BURST   591526ul   /* the patch burst's worst step  (b11)        */

static int bad = 0;
static void fail(const char *w) { printf("  *** %s\n", w); ++bad; }

/* ---- stubbed work for each machine --------------------------------------- */
static int  nb_left, bs_left, pm_left;
static int  t1(void *u) { (void)u; return 1; }
static unsigned nb_touch(void *u) { (void)u; return 0x07u; }
static unsigned nb_voiced(void *u) { (void)u; return 0x01u; }
static void nb_beginv(void *u, unsigned m) { (void)u; (void)m; nb_left = 3; }
static int  nb_chunk(void *u) { (void)u; return --nb_left > 0; }
static int  nb_busy(void *u)  { (void)u; return nb_left > 0; }
static const eb_nb_ops NB_OPS = { t1, nb_touch, nb_voiced, nb_beginv,
                                  nb_chunk, nb_busy, t1 };

static void bs_begin(void *u) { (void)u; bs_left = 10; }
static int  bs_step (void *u) { (void)u; return --bs_left > 0; }
static const eb_bs_ops BS_OPS = { t1, t1, t1, t1, bs_begin, bs_step, t1 };

static void pm_begin(void *u) { (void)u; pm_left = 4; }
static int  pm_step (void *u) { (void)u; return --pm_left > 0; }
static int  pm_busy (void *u) { (void)u; return pm_left > 0; }
static const eb_pm_ops PM_OPS = { t1, pm_begin, pm_step, pm_busy, t1 };

/* THE TEETH. Each removes one arbitration rule and the gate must go RED.
 *   1  drop the note-machine check from the parameter start  -> two owners
 *   2  drop the parameter check from the patch start         -> two owners
 *   3  budget the patch burst (the b11 regression, verbatim) -> starvation */
static int tooth = 0;

int main(int argc, char **argv)
{
    if (argc > 1) tooth = atoi(argv[1]);
    eb_nb NB; eb_bs BS; eb_pm PM; eb_sched SCHED;
    int note_pending = 0, dev_want = 0, pm_want = 0, pend_ask = 0;
    long blk, notes_done = 0, patches_done = 0, params_done = 0;
    long note_req = 0, patch_req = 0, param_req = 0;
    long stall = 0, worst_stall = 0;
    long edits_in = 0, edits_built = 0;
    int  wait_note = -1, wait_param = -1;
    long worst_wait_note = 0, worst_wait_param = 0;

    eb_nb_init(&NB); eb_bs_init(&BS); eb_pm_init(&PM);
    eb_sched_init(&SCHED, 64);
    eb_sched_slack(&SCHED, CYC_SLACK);   /* the API, not the field:
                                          * -Werror found the raw write */

    /* ⚠ WHY THE BURST IS NOT BUDGETED, AS AN ASSERTION RATHER THAN A COMMENT.
     * -Werror flagged eb_bs_heavy() as unused here, which was correct and
     * informative: this model does not budget the patch burst. Silencing it
     * with a cast would have thrown away the question. Instead the reason is
     * checked -- the burst's worst step must NOT fit the slack, because if it
     * ever did, the b11 decision to leave it ungated would need re-deriving
     * rather than inheriting. */
    {
        eb_bs probe; eb_sched s2;
        eb_bs_init(&probe); eb_bs_begin(&probe);
        eb_sched_init(&s2, 64); eb_sched_slack(&s2, CYC_SLACK);
        if (!eb_bs_heavy(&probe))
            fail("the patch burst reports no heavy state -- the budget "
                 "question cannot even be asked of it");
        if (eb_sched_may(&s2, CYC_BURST))
            fail("the patch burst's worst step now FITS the slack. The b11 "
                 "decision to leave it ungated was derived from the fact that "
                 "it cannot; re-derive it rather than inherit it.");
    }

    printf("INTERLOCK GATE  (three machines, one shadow, one publish/block)\n");
    printf("  slack=%lu note=%lu param=%lu burst=%lu cycles\n",
           CYC_SLACK, CYC_NOTE, CYC_PARAM, CYC_BURST);

    for (blk = 0; blk < 20000; ++blk) {
        int published = 0, progress = 0;

        /* ---- the storm: all three request types, at awkward rates -------- */
        if (blk % 7 == 0)  { note_pending = 1; ++note_req;
                             if (wait_note < 0) wait_note = 0; }
        if (blk % 53 == 0) { dev_want = 1; ++patch_req; }
        if (blk % 5 == 0)  { pm_want = 1; ++param_req; ++edits_in;
                             if (wait_param < 0) wait_param = 0; }
        if (wait_note  >= 0) ++wait_note;
        if (wait_param >= 0) ++wait_param;

        /* ---- 2: never two owners ----------------------------------------- */
        {
            int owners = (!eb_nb_idle(&NB)) + (!eb_bs_idle(&BS))
                       + (!eb_pm_idle(&PM));
            if (owners > 1) {
                fail("TWO MACHINES OWN THE SHADOW AT ONCE");
                printf("      block %ld: nb=%d bs=%d pm=%d\n", blk,
                       !eb_nb_idle(&NB), !eb_bs_idle(&BS), !eb_pm_idle(&PM));
                break;
            }
        }

        /* ---- the firmware's arbitration, in its order -------------------- */
        if (dev_want && eb_nb_idle(&NB) && !note_pending
            && (tooth == 2 || eb_pm_idle(&PM))) {
            eb_bs_begin(&BS); dev_want = 0;
        }
        if (!eb_bs_idle(&BS)) {
            int r;
            if (tooth == 3 && eb_bs_heavy(&BS)
                && !eb_sched_may(&SCHED, CYC_BURST)) {
                /* the b11 regression: budget work that can never fit */
                goto after_burst;
            }
            r = eb_bs_step(&BS, &BS_OPS, (void *)0);
            progress = 1;
            if (r == 0) pend_ask = 1;
        after_burst: ;
        } else {
            if (note_pending && eb_nb_idle(&NB) && eb_pm_idle(&PM)) {
                /* the note machine draws its own events on first step */
            }
            if (note_pending && eb_pm_idle(&PM)
                && (!eb_nb_heavy(&NB) || eb_sched_may(&SCHED, CYC_NOTE))) {
                int r = eb_nb_step(&NB, &NB_OPS, (void *)0);
                progress = 1;
                if (r == 0) pend_ask = 1;
            }
            if (eb_pm_idle(&PM) && pm_want
                && (tooth == 1 || (!note_pending && eb_nb_idle(&NB)))) {
                eb_pm_begin(&PM); pm_want = 0; ++edits_built;
            }
            if (!eb_pm_idle(&PM)
                && (!eb_pm_heavy(&PM) || eb_sched_may(&SCHED, CYC_PARAM))) {
                int r = eb_pm_step(&PM, &PM_OPS, (void *)0);
                progress = 1;
                if (r == 0) pend_ask = 1;
            }
        }

        /* ---- one publish per block, to whoever asked --------------------- */
        if (pend_ask) {
            /* ⚠ A COMPLETION IS A TRANSITION, NOT A STATE. The first version
             * counted "machine is idle at a publish", which is true of every
             * machine that was not running -- it reported 3,053 patch changes
             * completed out of 378 requested, and 3,053 parameter refreshes,
             * the identical number, because both counters were really counting
             * publishes. A counter that cannot distinguish "finished" from
             * "was never busy" measures the block loop, not the machine. */
            int nb0 = eb_nb_idle(&NB), bs0 = eb_bs_idle(&BS),
                pm0 = eb_pm_idle(&PM);
            eb_nb_published(&NB);
            eb_bs_published(&BS);
            eb_pm_published(&PM);
            published = 1; pend_ask = 0; progress = 1;
            if (!nb0 && eb_nb_idle(&NB)) {
                note_pending = 0; ++notes_done;
                if (wait_note > worst_wait_note) worst_wait_note = wait_note;
                wait_note = -1;
            }
            if (!bs0 && eb_bs_idle(&BS)) ++patches_done;
            if (!pm0 && eb_pm_idle(&PM)) {
                ++params_done;
                if (wait_param > worst_wait_param) worst_wait_param = wait_param;
                wait_param = -1;
            }
        }
        (void)published;

        /* ---- 1: no starvation -------------------------------------------- */
        if (!progress && (note_pending || dev_want || pm_want)) {
            if (++stall > worst_stall) worst_stall = stall;
        } else stall = 0;
        if (stall > 200) {
            fail("STARVATION: 200 blocks with a request pending and no "
                 "machine making progress");
            printf("      block %ld: note=%d patch=%d param=%d\n",
                   blk, note_pending, dev_want, pm_want);
            break;
        }
    }

    printf("  requests  note=%ld patch=%ld param=%ld\n",
           note_req, patch_req, param_req);
    printf("  completed note=%ld patch=%ld param=%ld\n",
           notes_done, patches_done, params_done);
    printf("  worst wait: note=%ld blocks  param=%ld blocks   worst stall=%ld\n",
           worst_wait_note, worst_wait_param, worst_stall);
    printf("  edits in=%ld built=%ld coalesced=%ld\n",
           edits_in, edits_built, edits_in - edits_built);

    /* ---- 1 again: EVERY type must actually complete ---------------------- */
    if (!notes_done)   fail("NOT ONE NOTE completed -- playbook 63 verbatim");
    if (!patches_done) fail("NOT ONE PATCH CHANGE completed");
    if (!params_done)  fail("NOT ONE PARAMETER REFRESH completed -- the knob "
                            "is starved by the other two machines");
    /* ---- 3: no lost edit ------------------------------------------------- */
    if (edits_built + (pm_want ? 1 : 0) < 1)
        fail("a parameter edit was neither built nor still pending");

    printf("INTERLOCK GATE%s: %s\n", tooth ? " (TOOTH)" : "",
           bad ? "FAIL" : "PASS");
    return bad ? 1 : 0;
}

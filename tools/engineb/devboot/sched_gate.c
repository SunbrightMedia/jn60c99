/* sched_gate.c -- O2's SCHEDULER GATE. The burst budget is control logic on
 * the audio path, and it went in with no gate at all, which is the shape this
 * project has paid for more than any other.
 *
 * It drives eb_sched.h -- THE HEADER THE FIRMWARE ITSELF INCLUDES, not a copy
 * of its reasoning -- through the situations the board actually produces, and
 * checks the three rules eb_sched.h states it enforces.
 *
 * WHAT IT CHECKS, and each has a planted tooth in sched_teeth.sh:
 *   1. FIT       a step that fits always runs, and never counts a deferral
 *   2. REFUSE    a step that does not fit is refused, and counted
 *   3. BOUND     a permanently over-budget instrument still makes progress:
 *                exactly one step in every starve_max blocks, for ever. This
 *                is THE INVARIANT rule 3 as an arithmetic property -- "the
 *                change arrives later" must mean LATER, not NEVER.
 *   4. NO DEADLOCK  the self-correction the firmware depends on: a deferred
 *                block runs no step, so it refreshes the slack measurement,
 *                so a first deferral can never become permanent. Modelled the
 *                way the firmware wires it, because the property belongs to
 *                the WIRING and not to eb_sched_may alone.
 *   5. SEPARATE  a huge worst-case for one machine never gates the other --
 *                the reseed-vs-note-step defect, which would be invisible in
 *                any test that used one cost.
 *   6. COUNTED   defer and forced are counted apart and never double-counted:
 *                every call is exactly one of run-free, defer, or force.
 *   7. BOOTSTRAP with no measurement yet, work is allowed rather than blocked
 *                for ever waiting for a measurement only work can produce.
 *
 * usage: sched_gate      (no arguments -- it is pure arithmetic)
 */
#include <stdio.h>
#include "eb_sched.h"

static int bad = 0;

static void fail(const char *what)
{
    printf("  *** %s\n", what);
    ++bad;
}

int main(void)
{
    printf("SCHED GATE  (engine_b/dev/eb_sched.h, the firmware's own copy)\n");

    /* ---- 7. BOOTSTRAP ---------------------------------------------------
     * Before anything has been measured there is nothing to compare. If this
     * refused, the firmware would wait for a measurement that only running
     * work can produce, and no note would ever be built. */
    {
        eb_sched s; eb_sched_init(&s, 64);
        if (!eb_sched_may(&s, 100000ul))
            fail("bootstrap: refused with no slack measured yet -- the "
                 "instrument would never run a first step");
        eb_sched_slack(&s, 500000ul);
        if (!eb_sched_may(&s, 0ul))
            fail("bootstrap: refused with no step cost measured yet");
        if (s.n_defer || s.n_forced)
            fail("bootstrap: counted a deferral for a step it allowed");
    }

    /* ---- 1. FIT ---------------------------------------------------------- */
    {
        eb_sched s; int i;
        eb_sched_init(&s, 64);
        eb_sched_slack(&s, 300000ul);
        for (i = 0; i < 1000; ++i)
            if (!eb_sched_may(&s, 148000ul))
                { fail("fit: refused a step that fits the measured slack"); break; }
        if (s.n_defer || s.n_forced)
            fail("fit: counted a deferral or a force while everything fitted");
        /* the boundary case: cost EXACTLY equal to slack must fit. An
         * off-by-one here silently halves the burst rate. */
        eb_sched_init(&s, 64);
        eb_sched_slack(&s, 148000ul);
        if (!eb_sched_may(&s, 148000ul))
            fail("fit: a step costing EXACTLY the slack was refused");
    }

    /* ---- 2. REFUSE + 3. BOUND -------------------------------------------
     * A permanently over-budget instrument: slack never covers the step.
     * Progress must still happen, at a KNOWN rate. */
    {
        eb_sched s; int i; const unsigned long SM = 64ul;
        unsigned long ran = 0;
        eb_sched_init(&s, SM);
        eb_sched_slack(&s, 1000ul);           /* far below the step cost */
        for (i = 0; i < 6400; ++i)
            if (eb_sched_may(&s, 148000ul)) ++ran;
        if (ran == 0ul)
            fail("bound: an over-budget instrument NEVER ran a step -- 'the "
                 "change arrives later' became 'never', which is the "
                 "invariant broken, not degraded");
        if (ran != 6400ul / SM)
            printf("  *** bound: ran %lu steps in 6400 blocks, expected %lu "
                   "(one per starve_max)\n", ran, 6400ul / SM), ++bad;
        if (s.n_forced != ran)
            fail("counted: forced steps do not equal the steps that ran");
        if (s.n_defer + s.n_forced != 6400ul)
            fail("counted: calls are not exactly one of defer or force -- a "
                 "deferral is going unreported (rule 4)");
    }

    /* ---- 4. NO DEADLOCK, wired the way the firmware wires it -------------
     * The firmware refreshes slack ONLY from blocks that ran no step. A
     * deferred block runs no step, so it is such a block. Model that loop and
     * require that the instrument recovers once the load drops: if the
     * refresh were taken from any block, the slack measured DURING a burst
     * would be near zero and the scheduler would starve on its own output. */
    {
        eb_sched s; int i; unsigned long ran = 0;
        eb_sched_init(&s, 64);
        eb_sched_slack(&s, 300000ul);         /* healthy to begin with */
        for (i = 0; i < 200; ++i) {
            int did = eb_sched_may(&s, 148000ul);
            if (did) {
                ++ran;
                /* a block that RAN a step: the firmware does NOT refresh from
                 * it. Feeding the post-step slack here is the defect this
                 * check exists to catch, and tooth 5 plants exactly that. */
            } else {
                eb_sched_slack(&s, 300000ul); /* quiet block: refresh */
            }
        }
        if (ran != 200ul)
            fail("deadlock: a healthy instrument stopped running steps -- the "
                 "scheduler starved on its own output");
    }

    /* ---- 5. SEPARATE ----------------------------------------------------
     * The reseed-vs-note defect. One machine's enormous worst case must not
     * gate the other's. eb_sched holds no per-machine state, so this is a
     * property of the interface: the cost is an ARGUMENT, never remembered. */
    {
        eb_sched s; int i; unsigned long note_ran = 0;
        eb_sched_init(&s, 64);
        eb_sched_slack(&s, 300000ul);
        for (i = 0; i < 100; ++i) {
            eb_sched_may(&s, 440000ul);        /* the patch reseed: too big */
            if (eb_sched_may(&s, 148000ul)) ++note_ran;   /* the note: fits */
        }
        if (note_ran != 100ul)
            fail("separate: an expensive BURST step gated the cheap NOTE step "
                 "-- the budget starving the work it was added to protect");
    }

    /* ---- 6. COUNTED, on a mixed load ------------------------------------ */
    {
        eb_sched s; int i; unsigned long ran = 0, calls = 0;
        eb_sched_init(&s, 8);
        eb_sched_slack(&s, 200000ul);
        for (i = 0; i < 1000; ++i) {
            unsigned long cost = (i % 3) ? 100000ul : 400000ul;
            ++calls;
            if (eb_sched_may(&s, cost)) ++ran;
            if (!(i % 7)) eb_sched_slack(&s, 200000ul);
        }
        if (s.n_defer + ran != calls)
            fail("counted: defer + ran != calls on a mixed load");
    }

    /* ---- 8. THE STARVE COUNTER IS RESET BY A STEP THAT FITS -------------
     * ⚠ THIS CHECK WAS MISSING AND A TOOTH FOUND THE HOLE. Every other check
     * ran at a CONSTANT load -- always fitting, or never fitting -- and under
     * a constant load the reset is unobservable. A real instrument is neither:
     * it moves between patches, and a run of refusals on a delay patch is
     * followed by room again on the next.
     *
     * Without the reset, refusals are remembered FOR EVER, so a scheduler that
     * struggled once forces a step on a perfectly healthy instrument minutes
     * later -- a deliberate missed deadline with no cause visible anywhere
     * near it. A gate that only tests steady states cannot see that. */
    {
        eb_sched s; int i;
        eb_sched_init(&s, 64);
        eb_sched_slack(&s, 1000ul);
        for (i = 0; i < 63; ++i) eb_sched_may(&s, 148000ul);   /* starve = 63 */
        if (s.n_forced)
            fail("reset: forced before starve_max was reached");
        eb_sched_slack(&s, 300000ul);                          /* room again */
        for (i = 0; i < 10; ++i)
            if (!eb_sched_may(&s, 148000ul))
                { fail("reset: refused a step that fits"); break; }
        /* the instrument gets tight again. ONE refusal must be a refusal, not
         * a force -- the 63 from before must have been forgotten. */
        eb_sched_slack(&s, 1000ul);
        if (eb_sched_may(&s, 148000ul))
            fail("reset: the starve counter survived a run of fitting steps -- "
                 "a healthy instrument was forced to miss on old history");
    }

    /* ---- 9. A ZERO starve_max IS REFUSED --------------------------------
     * Also found by a tooth going uncaught. eb_sched_init clamps 0 to 1, and
     * nothing checked that it does. With 0 accepted, `++starve >= 0` is true
     * on the first refusal, so EVERY step is forced: the budget is entirely
     * gone while the struct, the counters and the report all still look
     * present. It would read as "the scheduler is installed and never
     * defers", which is indistinguishable from "the scheduler is working
     * well" in any log. */
    {
        eb_sched s; int i; unsigned long ran = 0;
        eb_sched_init(&s, 0ul);
        eb_sched_slack(&s, 1000ul);
        for (i = 0; i < 100; ++i) if (eb_sched_may(&s, 148000ul)) ++ran;
        if (ran == 100ul)
            fail("starve_max 0 was accepted -- every step forced, the budget "
                 "gone while still appearing to be there");
    }

    printf("SCHED GATE: %s\n", bad == 0
           ? "PASS -- fits run, refusals are counted, progress is bounded"
           : "FAIL");
    return bad == 0 ? 0 : 1;
}

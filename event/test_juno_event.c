/* test_juno_event.c -- the O1 boundary's gate.
 *
 * WHAT IT PROVES, and each of these is a rule from THE INVARIANT rather than a
 * property someone liked the sound of:
 *
 *   1. FIFO order is preserved, across mixed sources and kinds.
 *   2. The source tag survives the queue. (rule 4: the health line must be
 *      able to say WHICH input caused a fault.)
 *   3. `max` is an honest cap: drain never returns more, and what it did not
 *      take is still there, IN ORDER, next time. (rule 2, and rule 3 --
 *      LATE, NOT LOST. This is the one the old note path failed.)
 *   4. A full queue REFUSES and COUNTS; it does not overwrite, and it does not
 *      corrupt the events already queued. (rule 4.)
 *   5. Velocity 0 on a note-on becomes a note-off, at the boundary, once.
 *   6. Out-of-range input is clamped, not passed through as an array index.
 *
 * ⚠ EVERY CHECK IS SEEN TO FAIL. Build with -DTOOTH=n to plant defect n; the
 * script runs all of them and requires each to be CAUGHT. A gate that has
 * never gone red is an untested detector -- playbook defect 1, the oldest rule
 * in this project. The teeth are listed at the bottom.
 */
#include <stdio.h>
#include <string.h>
#include "juno_event.h"

static int fails = 0;

static void ck(int cond, const char *what)
{
    if (!cond) { printf("  *** FAIL: %s\n", what); ++fails; }
}

/* ------------------------------------------------------------------ 1 + 2 */
static void t_order_and_source(void)
{
    juno_event ev[16];
    int n, i;
    juno_event_reset();
    printf("1/2 FIFO order and the source tag\n");

    juno_event_note_on (JUNO_SRC_DIN,     60, 100);
    juno_event_param   (JUNO_SRC_PANEL,   7, 200);
    juno_event_note_off(JUNO_SRC_KEYBED,  60);
    juno_event_note_on (JUNO_SRC_USB,     72, 64);

    n = juno_event_drain(ev, 16);
    ck(n == 4, "four events in, four out");
    ck(ev[0].kind == JUNO_EV_NOTE_ON  && ev[0].src == JUNO_SRC_DIN
       && ev[0].a == 60 && ev[0].b == 100, "event 0 intact");
    ck(ev[1].kind == JUNO_EV_PARAM    && ev[1].src == JUNO_SRC_PANEL
       && ev[1].a == 7  && ev[1].b == 200, "event 1 intact (param value > 127)");
    ck(ev[2].kind == JUNO_EV_NOTE_OFF && ev[2].src == JUNO_SRC_KEYBED,
       "event 2 intact");
    ck(ev[3].kind == JUNO_EV_NOTE_ON  && ev[3].src == JUNO_SRC_USB
       && ev[3].a == 72, "event 3 intact");
    for (i = 0; i < 4; ++i) ck(ev[i].src != JUNO_SRC_NONE, "source not lost");
    ck(juno_event_depth() == 0, "queue empty after a full drain");
}

/* ---------------------------------------------------------------------- 3 */
/* THE ONE THE OLD PATH FAILED. `s3_midi_event` dropped a note that arrived
 * while a burst was pending. Here the surplus must WAIT. */
static void t_cap_is_late_not_lost(void)
{
    juno_event ev[8];
    int n, i;
    juno_event_reset();
    printf("3   the cap defers, it does not discard\n");

    for (i = 0; i < 10; ++i) juno_event_note_on(JUNO_SRC_KEYBED, 40 + i, 100);
    ck(juno_event_depth() == 10, "ten queued");

    n = juno_event_drain(ev, 3);
    ck(n == 3, "drain honours max=3");
    ck(ev[0].a == 40 && ev[1].a == 41 && ev[2].a == 42, "first three, in order");
    ck(juno_event_depth() == 7, "seven still waiting -- LATE, NOT LOST");

    n = juno_event_drain(ev, 3);
    ck(n == 3 && ev[0].a == 43, "the next block resumes where it stopped");

    n = juno_event_drain(ev, 8);
    ck(n == 4 && ev[0].a == 46 && ev[3].a == 49, "the tail arrives complete");
    ck(juno_event_depth() == 0, "nothing left over");

    {   juno_event_stats s;
        juno_event_get_stats(&s);
        ck(s.submitted == 10 && s.delivered == 10 && s.refused == 0,
           "ten submitted, ten delivered, none refused");
    }
}

/* ---------------------------------------------------------------------- 4 */
static void t_full_refuses_and_counts(void)
{
    juno_event ev[JUNO_EVQ_N];
    juno_event_stats s;
    int i, acc = 0, ref = 0, n;
    juno_event_reset();
    printf("4   a full queue refuses, counts, and keeps what it has\n");

    /* Push far past the end. Notes 0..127 so the payload identifies the slot. */
    for (i = 0; i < JUNO_EVQ_N * 2; ++i) {
        if (juno_event_note_on(JUNO_SRC_DIN, i & 127, 100)) ++acc; else ++ref;
    }
    ck(acc == JUNO_EVQ_N - 1, "accepts exactly capacity (one slot reserved)");
    ck(ref > 0, "the rest are refused");

    juno_event_get_stats(&s);
    ck(s.refused == (unsigned long)ref, "refusals counted");
    ck(s.refused_by_src[JUNO_SRC_DIN] == (unsigned long)ref,
       "refusals attributed to the SOURCE");
    ck(s.depth_max == (unsigned long)acc, "high-water mark recorded");

    /* THE EVENTS ALREADY QUEUED MUST BE UNHARMED. A ring that overwrites on
     * full loses the OLDEST note -- the one already being played. */
    n = juno_event_drain(ev, JUNO_EVQ_N);
    ck(n == acc, "everything accepted comes back");
    for (i = 0; i < n; ++i)
        if (ev[i].a != (unsigned char)(i & 127)) {
            ck(0, "a queued event was overwritten by a refused one"); break;
        }
}

/* ------------------------------------------------------------------ 5 + 6 */
static void t_boundary_rules(void)
{
    juno_event ev[8];
    int n;
    juno_event_reset();
    printf("5/6 velocity-0 policy and range clamping\n");

    juno_event_note_on(JUNO_SRC_DIN, 60, 0);        /* = note off */
    n = juno_event_drain(ev, 8);
    ck(n == 1 && ev[0].kind == JUNO_EV_NOTE_OFF,
       "note-on velocity 0 IS a note-off, decided once at the boundary");

    juno_event_reset();
    juno_event_note_on (JUNO_SRC_PANEL, 999, 999);
    juno_event_note_off(JUNO_SRC_PANEL, -5);
    juno_event_param   (JUNO_SRC_PANEL, 999, 999);
    juno_event_param   (JUNO_SRC_PANEL, -1, -1);
    n = juno_event_drain(ev, 8);
    ck(n == 4, "four clamped events");
    ck(ev[0].a == 127 && ev[0].b == 127, "note/velocity clamped high");
    ck(ev[1].a == 0, "note clamped low");
    ck(ev[2].a == 255 && ev[2].b == 255, "param id/value clamped high");
    ck(ev[3].a == 0 && ev[3].b == 0, "param id/value clamped low");

    /* An unknown source must not index off the end of by_src[]. */
    juno_event_reset();
    juno_event_note_on((juno_src)99, 60, 100);
    {   juno_event_stats s; juno_event_get_stats(&s);
        ck(s.by_src[JUNO_SRC_NONE] == 1, "an unknown source folds to NONE"); }
}

int main(void)
{
    printf("=== O1: the internal event boundary ===\n");
#ifdef TOOTH
    printf("TOOTH %d PLANTED -- this run MUST fail\n", TOOTH);
#endif
    t_order_and_source();
    t_cap_is_late_not_lost();
    t_full_refuses_and_counts();
    t_boundary_rules();
    printf("%s (%d failure%s)\n", fails ? "FAIL" : "PASS",
           fails, fails == 1 ? "" : "s");
    return fails ? 1 : 0;
}

/* THE TEETH (event/teeth.sh runs them; each must be CAUGHT)
 *   1  drain ignores `max`                       -> check 3 goes red
 *   2  full queue overwrites instead of refusing -> check 4 goes red
 *   3  the source tag is not stored              -> check 2 goes red
 *   4  velocity 0 stays a note-on                -> check 5 goes red
 *   5  the range clamp is removed                -> check 6 goes red
 *   6  drain does not advance the read index     -> check 3 goes red
 */

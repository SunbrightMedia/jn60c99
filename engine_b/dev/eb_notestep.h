/* eb_notestep.h -- THE NOTE SEQUENCE. Header-only, portable C99, no IDF.
 *
 * WHAT IT IS: the state machine that turns one key press into blocks of work
 * and two publishes. It used to live inside juno_s3_listen.c, where NOTHING
 * COULD GATE IT -- and two defects in it were found by reading the code, not
 * by any test:
 *
 *   1. a REFUSED publish let the catch-up build copy over the shadow that
 *      still held the priority voice. That voice was then never rebuilt: it
 *      played the previous patch's coefficients until some later note happened
 *      to name it. A stale voice and no error, which is the single defect
 *      shape this project has paid for most.
 *   2. a program change arriving mid-note opened a patch build over the note's
 *      half-finished shadow. The note branch already refused the reverse; the
 *      reverse of the reverse was simply missing.
 *
 * Finding those by reading was luck. This header exists so the next one is
 * found by a gate: tools/engineb/note_gate.py drives THESE LINES -- the ones
 * the firmware runs -- through every mask pair and every publish outcome,
 * with teeth.
 *
 * ⚠ IT DOES NO WORK AND KNOWS NO ENGINE. The caller supplies the work through
 * eb_nb_ops. That is what makes the sequence testable without a device, and
 * what makes it an ITEM-7 tool: "apply the events, build what the player is
 * waiting for, publish, build the rest, publish" is how any polyphonic synth
 * with a coefficient hoist must behave. Nothing here is JUNO.
 *
 * ================= THE SEQUENCE, ONE STATE PER AUDIO BLOCK =================
 *
 *   NB_EVENTS      apply the allocator's events; open the PRIORITY build
 *   NB_PRI         the voices the allocator NAMED, one per block
 *   NB_PUB1        --> the caller publishes. THE KEY BECOMES AUDIBLE HERE.
 *   NB_REST_BEGIN  open the catch-up build over the bank just published
 *   NB_REST        every other voice the broadcast touched, one per block
 *   NB_CHECK       the unmapped-cell check, which must see the WHOLE build
 *   NB_PUB2        --> the caller publishes. The note is complete.
 *
 * ⚠ THE TWO PUB STATES ARE NOT DECORATION. eb_nb_step() returns 0 to ask for
 * a publish; the machine does NOT advance on that. It advances only when the
 * caller calls eb_nb_published(), which the caller must do ONLY when the
 * publish actually happened. If the publish is refused, the machine asks again
 * next block and TOUCHES NOTHING -- no new build is opened over a shadow that
 * has not been handed over. That is defect 1 above, made structurally
 * impossible rather than remembered.
 *
 * ⚠ eb_nb_idle() IS THE INTERLOCK FOR THE WHOLE INSTRUMENT. While it is false
 * the note owns the shadow, so the caller must not draw new events and must
 * not start a patch build. That is defect 2 above. The caller keeps its
 * request queued rather than dropping it: the change arrives later, which is
 * THE INVARIANT rule 3.
 */
#ifndef EB_NOTESTEP_H
#define EB_NOTESTEP_H

enum { NB_IDLE = 0, NB_EVENTS, NB_PRI, NB_PUB1,
       NB_REST_BEGIN, NB_REST, NB_CHECK, NB_PUB2 };

typedef struct {
    /* Apply the queued events. Returns non-zero on success, 0 if an event
     * could not be applied -- which must MUTE, never be skipped, because an
     * unapplied event is a note the instrument did not play. */
    int      (*apply_events)(void *u);
    /* The voices the events wrote (the whole obligation) and the subset the
     * allocator NAMED (the publish order). Read AFTER apply_events. */
    unsigned (*touched)(void *u);
    unsigned (*voiced)(void *u);
    void     (*begin_voices)(void *u, unsigned mask);
    int      (*chunk_step)(void *u);   /* non-zero while more work remains */
    int      (*chunk_busy)(void *u);
    /* Non-zero if the whole build touched no unmapped cell. */
    int      (*check_ok)(void *u);
} eb_nb_ops;

typedef struct {
    int      st;
    unsigned pri, rest;
    /* blocks from the event apply to the publish that made the key audible.
     * THE number the split publish exists to move: 10 before it, 2 after. */
    unsigned key_blocks;
    unsigned pub_retry;     /* publishes refused mid-note. Must read 0. */
} eb_nb;

static void eb_nb_init(eb_nb *n)
{
    n->st = NB_IDLE; n->pri = 0u; n->rest = 0u;
    n->key_blocks = 0u; n->pub_retry = 0u;
}

/* False while the note owns the shadow. See the interlock note above. */
static int eb_nb_idle(const eb_nb *n) { return n->st == NB_IDLE; }

/* Which states actually BUILD, and are therefore worth budgeting. The genuinely
 * cheap ones -- a publish request and the unmapped check -- are not: deferring
 * those would hold the key silent to save work that does not exist.
 *
 * ⚠ NB_EVENTS IS HEAVY, AND A GATE CHECK FOUND THAT. It was originally listed
 * as cheap because "it only applies events". It does not: it also calls
 * begin_voices, whose shadow copy is ~20 KB of memcpy, so the FIRST build of
 * every note opened outside the budget entirely -- the budget skipping the
 * work it was added to schedule. NB_IDLE is heavy for the same reason: it
 * falls through into NB_EVENTS within the same call, so a caller that budgets
 * on the state it sees BEFORE the call must see the truth about what that call
 * will do.
 *
 * THE RULE THIS ENCODES: a predicate that says what work costs must be checked
 * against the work actually done, not against what the state is named. */
static int eb_nb_heavy(const eb_nb *n)
{
    return n->st == NB_IDLE  || n->st == NB_EVENTS ||
           n->st == NB_PRI   || n->st == NB_REST   || n->st == NB_REST_BEGIN;
}

/* The caller calls this ONLY when a publish actually succeeded. */
static void eb_nb_published(eb_nb *n)
{
    if      (n->st == NB_PUB1) n->st = NB_REST_BEGIN;
    else if (n->st == NB_PUB2) n->st = NB_IDLE;
}

/* One audio block's worth. Returns 1 = more to do, 0 = PUBLISH NOW,
 * -1 = fatal, mute (and the machine is left idle, owing nothing). */
static int eb_nb_step(eb_nb *n, const eb_nb_ops *o, void *u)
{
    switch (n->st) {
    case NB_IDLE:
        n->st = NB_EVENTS;
        /* FALLTHRU -- the first call does the event apply */
    case NB_EVENTS:
        if (!o->apply_events(u)) { n->st = NB_IDLE; return -1; }
        /* BOTH MASKS ARE THE APPLIER'S, never inferred here. A consumer that
         * infers the mask gets stale voices and no error. */
        n->pri  = o->voiced(u) & o->touched(u);
        n->rest = o->touched(u) & ~n->pri;
        n->key_blocks = 1u;                 /* this block, the one that applied */
        if (n->pri) {
            o->begin_voices(u, n->pri);
            n->st = o->chunk_busy(u) ? NB_PRI : NB_REST_BEGIN;
        } else {
            /* An event batch that named no voice is not an error. Fall through
             * to the catch-up rather than publishing nothing. */
            n->st = NB_REST_BEGIN;
        }
        return 1;

    case NB_PRI:
        ++n->key_blocks;
        if (!o->chunk_step(u)) { n->st = NB_PUB1; return 0; }
        return 1;

    case NB_PUB1:
    case NB_PUB2:
        /* Reachable only when the publish was REFUSED -- eb_nb_published()
         * advances these on success. Ask again, TOUCH NOTHING. */
        ++n->pub_retry;
        return 0;

    case NB_REST_BEGIN:
        if (n->rest) {
            o->begin_voices(u, n->rest);
            n->st = o->chunk_busy(u) ? NB_REST : NB_CHECK;
        } else {
            n->st = NB_CHECK;
        }
        return 1;

    case NB_REST:
        if (!o->chunk_step(u)) n->st = NB_CHECK;
        return 1;

    case NB_CHECK:
        /* THE CHECK MUST SEE THE WHOLE BUILD, which is why it is its own state
         * rather than folded into the last voice: a cell that missed during
         * voice 5 must still be caught after voice 7. */
        if (!o->check_ok(u)) { n->st = NB_IDLE; return -1; }
        n->st = NB_PUB2;
        return 0;
    }
    n->st = NB_IDLE;
    return -1;                      /* an unknown state is a defect, not a nop */
}

#endif /* EB_NOTESTEP_H */

/* eb_burststep.h -- THE PATCH SEQUENCE. Header-only, portable C99, no IDF.
 *
 * The other half of O2. eb_notestep.h spreads a KEY PRESS over blocks; this
 * spreads a PROGRAM CHANGE over blocks. They are separate machines because
 * they do different work -- a patch reseeds the cell array, installs the
 * record, runs the port's recall and rebuilds every voice, the shared tail and
 * the master set; a note touches per-voice cells only.
 *
 * ⚠ WHY IT WAS EXTRACTED, AND WHAT THAT FOUND. The note sequence was pulled
 * out and gated first, and the gate immediately paid for itself. Reading THIS
 * machine afterwards, with the note machine's contract in mind, showed the
 * SAME DEFECT still live in the shipping path:
 *
 *     BST_CHECK set the state to IDLE and returned "publish me" in one step.
 *
 * If that publish is REFUSED -- and the firmware counts refusals, so it is a
 * case that exists -- the machine is already IDLE. The whole ~2.1 M-cycle
 * build then sits in the shadow, unpublished and forgotten: the instrument
 * keeps playing the OLD patch, so the program change silently did nothing.
 * Worse, the next key press calls the note build, whose first act is to copy
 * the LIVE bank over the shadow -- destroying the built patch outright. The
 * player turns the knob and nothing happens, with no error anywhere.
 *
 * The note machine had this fixed by hand after being found by reading. THE
 * PATCH MACHINE DID NOT, because the fix was applied to the code that had just
 * been read rather than to the CLASS of defect. That is the lesson: a defect
 * found in one state machine is a QUESTION to ask of every other one.
 *
 * So both machines now hold the same contract, and both are gated:
 *   eb_XX_step() returns 0 to ASK for a publish and does NOT advance;
 *   the caller calls eb_XX_published() ONLY when the publish really happened.
 * A refused publish leaves the machine asking, owning its shadow, opening
 * nothing new. Structurally impossible rather than remembered.
 *
 * ⚠ IT DOES NO WORK. The caller supplies it through eb_bs_ops, which is what
 * makes the sequence testable without a device and keeps it synth-agnostic:
 * "reseed, install, recall, seed notes, build, check, publish" is the shape of
 * any patch change on a port that hoists coefficients. Nothing here is JUNO.
 *
 * GATE: tools/engineb/burst_gate.py, with teeth.
 */
#ifndef EB_BURSTSTEP_H
#define EB_BURSTSTEP_H

enum { BS_IDLE = 0, BS_RESEED, BS_INSTALL, BS_RECALL,
       BS_NOTES, BS_COEFS, BS_CHECK, BS_PUB };

typedef struct {
    /* Each returns non-zero on success. A failure MUTES -- it must never be
     * skipped, because a patch that half-installed is coefficients the
     * instrument cannot vouch for. */
    int  (*reseed) (void *u);
    int  (*install)(void *u);
    int  (*recall) (void *u);
    int  (*notes)  (void *u);
    void (*begin)  (void *u);        /* open the full coefficient build */
    int  (*step)   (void *u);        /* non-zero while more work remains */
    int  (*verify) (void *u);        /* the CRC / unmapped-cell check */
} eb_bs_ops;

typedef struct {
    int      st;
    unsigned blocks;        /* blocks this program change has taken */
    unsigned pub_retry;     /* publishes refused mid-build. Must read 0. */
} eb_bs;

static void eb_bs_init(eb_bs *b)
{ b->st = BS_IDLE; b->blocks = 0u; b->pub_retry = 0u; }

static void eb_bs_begin(eb_bs *b)
{ b->st = BS_RESEED; b->blocks = 0u; }

/* False while the build owns the shadow. The caller must not start a note
 * build, and must not begin a SECOND patch build, while this is false --
 * except deliberately, as a restart, which is what eb_bs_begin is for. */
static int eb_bs_idle(const eb_bs *b) { return b->st == BS_IDLE; }

/* Every state of a patch build does real work; only the publish request does
 * not. Kept as a function so the caller budgets both machines the same way,
 * and so this stays checkable rather than assumed. */
static int eb_bs_heavy(const eb_bs *b)
{ return b->st != BS_IDLE && b->st != BS_PUB; }

/* The caller calls this ONLY when a publish actually succeeded. */
static void eb_bs_published(eb_bs *b)
{ if (b->st == BS_PUB) b->st = BS_IDLE; }

/* One audio block's worth. 1 = more to do, 0 = PUBLISH NOW, -1 = fatal. */
static int eb_bs_step(eb_bs *b, const eb_bs_ops *o, void *u)
{
    ++b->blocks;
    switch (b->st) {
    case BS_IDLE:    return 1;
    case BS_RESEED:
        if (!o->reseed(u))  { b->st = BS_IDLE; return -1; }
        b->st = BS_INSTALL;  return 1;
    case BS_INSTALL:
        if (!o->install(u)) { b->st = BS_IDLE; return -1; }
        b->st = BS_RECALL;   return 1;
    case BS_RECALL:
        if (!o->recall(u))  { b->st = BS_IDLE; return -1; }
        b->st = BS_NOTES;    return 1;
    case BS_NOTES:
        if (!o->notes(u))   { b->st = BS_IDLE; return -1; }
        o->begin(u);
        b->st = BS_COEFS;    return 1;
    case BS_COEFS:
        if (!o->step(u)) b->st = BS_CHECK;
        return 1;
    case BS_CHECK:
        /* THE CHECK MUST SEE THE WHOLE BUILD, which is why it is its own
         * state: a cell that missed during voice 5 must still be caught after
         * the master set. */
        if (!o->verify(u)) { b->st = BS_IDLE; return -1; }
        b->st = BS_PUB;
        return 0;
    case BS_PUB:
        /* Reachable only when the publish was REFUSED. Ask again, TOUCH
         * NOTHING -- see the header block for the patch this loses otherwise. */
        ++b->pub_retry;
        return 0;
    }
    b->st = BS_IDLE;
    return -1;                     /* an unknown state is a defect, not a nop */
}

#endif /* EB_BURSTSTEP_H */

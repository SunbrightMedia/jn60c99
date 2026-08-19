/* eb_paramstep.h -- THE PARAMETER SEQUENCE. Header-only, portable C99, no IDF.
 *
 * The third of the three. eb_notestep.h spreads a KEY PRESS over blocks,
 * eb_burststep.h spreads a PROGRAM CHANGE, and this spreads a KNOB MOVE.
 *
 * ⚠ WHY IT IS A SEPARATE MACHINE AND NOT THE BURST WITH NO-OP OPS. A patch
 * change reseeds the cell array, installs a record, recalls, re-seeds notes and
 * rebuilds EVERYTHING. A knob move does none of that: it writes two record
 * bytes, recalls WARM over the live cells, and rebuilds only the sub-builders
 * its parameter can reach. Driving the burst machine with reseed/install/notes
 * stubbed to "return 1" would spend THREE BLOCKS per knob move doing nothing,
 * and would leave a machine whose states lie about the work they do -- which
 * is the defect eb_notestep.h's heavy() note already records.
 *
 * ================= THE SEQUENCE, ONE STATE PER AUDIO BLOCK =================
 *
 *   PM_APPLY   write the edited record bytes; WARM recall; open the subset
 *              build for this parameter's class
 *   PM_COEFS   one sub-builder per block -- a voice, the shared tail, or the
 *              master set (eb_recall_chunk_step)
 *   PM_CHECK   the unmapped-cell check, which must see the WHOLE build
 *   PM_PUB     --> the caller publishes. The knob takes effect here.
 *
 * ⚠ THE WARM RECALL IS DELIBERATE AND IT IS MEASURED. It does NOT reseed from
 * the boot image the way a program change does. That is the decision
 * eb_devseq.h flagged for exactly this moment -- "correct for a device whose
 * recall is a program change and wrong for one that must imitate a DAW's live
 * parameter edits... REVISITED, NOT INHERITED" -- and it is now settled by
 * measurement rather than argument: of 2,040 parameters, 2,036 land byte for
 * byte where a cold recall would, and the four that do not (EFFECT TYPE, DELAY
 * TYPE and two related cells) are LATCHES that settle, where WARM is the
 * CORRECT answer for a live edit because the plugin does not reseed either.
 * Gated by tools/engineb/devboot/paramwarm.c, which names those four and fails
 * in both directions, with three teeth.
 *
 * ⚠ THE PUBLISH CONTRACT IS THE OTHER TWO MACHINES', AND THAT IS THE POINT.
 * eb_pm_step() returns 0 to ASK for a publish and does NOT advance; the caller
 * calls eb_pm_published() only when the publish really happened. Both of the
 * other machines shipped with this defect and both were found by reading
 * rather than by a test (playbook 62: a defect found in one state machine is a
 * QUESTION to ask of every other one). This one is built to the contract from
 * its first line rather than corrected into it.
 *
 * ⚠ eb_pm_idle() JOINS AN INTERLOCK THAT IS NOW THREE-WAY. The shadow bank has
 * ONE owner. While this machine is not idle the caller must not start a note
 * build or a patch build; while either of those is running this must not
 * start. Three machines means three pairs, so the caller checks all of them --
 * a two-way check that grew a third machine is how a stale shadow gets built.
 *
 * ⚠ IT DOES NO WORK. The caller supplies everything through eb_pm_ops, which
 * is what makes the sequence testable without a device and keeps it
 * synth-agnostic. "write the edit, recall, rebuild what it reached, publish"
 * is the shape of a knob on any port that hoists coefficients. Nothing here is
 * JUNO -- not a cell, not a record offset, not a parameter name.
 *
 * GATE: tools/engineb/param_gate.py, with teeth.
 */
#ifndef EB_PARAMSTEP_H
#define EB_PARAMSTEP_H

enum { PM_IDLE = 0, PM_APPLY, PM_COEFS, PM_CHECK, PM_PUB };

typedef struct {
    /* Write the pending edits into the record and recall WARM over the live
     * cells. Returns non-zero on success; 0 MUTES, because a parameter that
     * half-applied is coefficients the instrument cannot vouch for. */
    int  (*apply)(void *u);
    /* Open the subset build for the accumulated class. Read AFTER apply. */
    void (*begin)(void *u);
    int  (*step)(void *u);      /* non-zero while more work remains */
    int  (*busy)(void *u);      /* did begin() actually open anything */
    int  (*verify)(void *u);    /* the unmapped-cell check */
} eb_pm_ops;

typedef struct {
    int      st;
    unsigned blocks;        /* blocks this knob move has taken */
    unsigned pub_retry;     /* publishes refused mid-build. Must read 0. */
} eb_pm;

static void eb_pm_init(eb_pm *m)
{ m->st = PM_IDLE; m->blocks = 0u; m->pub_retry = 0u; }

static void eb_pm_begin(eb_pm *m)
{ m->st = PM_APPLY; m->blocks = 0u; }

/* False while the build owns the shadow. See the three-way interlock note. */
static int eb_pm_idle(const eb_pm *m) { return m->st == PM_IDLE; }

/* Which states actually BUILD, and are therefore worth budgeting.
 *
 * ⚠ PM_APPLY IS THE HEAVY ONE AND IT IS NOT OBVIOUS. It looks like "write two
 * bytes", but it also runs the WARM RECALL -- MEASURED at ~0.24 M cycles on
 * silicon, which is the single most expensive step this machine takes, bigger
 * than any one voice build. Calling it cheap would let the biggest step in the
 * sequence escape the budget entirely, which is precisely the mistake
 * eb_notestep.h's NB_EVENTS made and its comment records.
 *
 * ⚠ AND UNLIKE THE PATCH BURST, THIS ONE MAY BE BUDGETED AT ALL. The burst's
 * worst step is 591,526 cycles against ~460,000 of slack, so it can never fit
 * and gating it starved the whole instrument (playbook 63). The parameter
 * path's worst step is the warm recall at ~0.24 M, which FITS -- so the b11
 * rule permits a budget here, and the same rule forbids one there. */
static int eb_pm_heavy(const eb_pm *m)
{ return m->st == PM_APPLY || m->st == PM_COEFS; }

/* The caller calls this ONLY when a publish actually succeeded. */
static void eb_pm_published(eb_pm *m)
{ if (m->st == PM_PUB) m->st = PM_IDLE; }

/* One audio block's worth. 1 = more to do, 0 = PUBLISH NOW, -1 = fatal. */
static int eb_pm_step(eb_pm *m, const eb_pm_ops *o, void *u)
{
    ++m->blocks;
    switch (m->st) {
    case PM_IDLE:
        return 1;

    case PM_APPLY:
        if (!o->apply(u)) { m->st = PM_IDLE; return -1; }
        o->begin(u);
        /* A CLASS THAT OPENED NOTHING STILL PUBLISHES. The subset can be empty
         * only if the class table says this parameter reaches no builder, and
         * the caller refuses those before it ever gets here -- but if one
         * arrives, going straight to the check and the publish is correct and
         * cheap. Falling back to "do nothing and go idle" would drop the edit
         * silently, which is the one outcome never allowed. */
        m->st = o->busy(u) ? PM_COEFS : PM_CHECK;
        return 1;

    case PM_COEFS:
        if (!o->step(u)) m->st = PM_CHECK;
        return 1;

    case PM_CHECK:
        /* THE CHECK MUST SEE THE WHOLE BUILD, which is why it is its own
         * state: a cell that missed during voice 5 must still be caught after
         * the master set. */
        if (!o->verify(u)) { m->st = PM_IDLE; return -1; }
        m->st = PM_PUB;
        return 0;

    case PM_PUB:
        /* Reachable only when the publish was REFUSED. Ask again, TOUCH
         * NOTHING -- the shadow still holds a build that was not handed over,
         * and opening anything over it loses the knob move. */
        ++m->pub_retry;
        return 0;
    }
    m->st = PM_IDLE;
    return -1;                     /* an unknown state is a defect, not a nop */
}

#endif /* EB_PARAMSTEP_H */

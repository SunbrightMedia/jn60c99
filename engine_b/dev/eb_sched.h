/* eb_sched.h -- THE BURST BUDGET. Header-only, portable C99, no IDF.
 *
 * WHAT IT DECIDES: may one more piece of incremental work run in THIS audio
 * block? That is THE INVARIANT rule 2 -- "recall, parameter refresh and note
 * bursts get a FIXED budget of work per block and take more blocks when there
 * is more to do" -- reduced to the one function that has to be right.
 *
 * WHY IT IS A HEADER AND NOT FIRMWARE CODE. It is the second implementation of
 * a rule this project already got wrong once by writing it twice (playbook 28,
 * roles swapped). The firmware and the gate must run THE SAME LINES, or the
 * gate proves a scheduler nobody ships. Nothing here knows about JUNO, ESP32,
 * cycles-per-sample, or audio -- it takes two numbers and returns a decision,
 * which is also what makes it an ITEM-7 tool: the JX-3P's burst needs exactly
 * this and needs it to be the same code.
 *
 * ================= WHY A BUDGET AND NOT A FIXED LUMP =================
 * MEASURED, b10_split_publish_field.md: O2 first read rule 2 as ONE VOICE PER
 * BLOCK. A voice is not a budget -- it is ~148,000 cycles, fixed, and whether
 * it fits depends on what the block was already doing. On DELAY TYPE 0 there
 * is room; on patches 5/16/21/49 the block is over budget before any burst
 * work starts. Result on silicon: 23 missed deadlines in ~4,160 note-build
 * blocks. The step nearly always fitted; it missed when it landed on a block
 * with no slack. A BUDGET IS A MEASUREMENT, NOT A CONSTANT (playbook 61).
 *
 * ================= THE THREE RULES IT ENFORCES =================
 * 1. FIT. A step runs when the measured slack covers the measured worst cost
 *    of that step. Both numbers come from the instrument at run time.
 * 2. NEVER STARVE. "The change arrives later" is the invariant; "the change
 *    never arrives" is not. On a patch whose steady-state cost already exceeds
 *    the period, slack never appears, and a pure fit rule would defer for
 *    ever. After `starve_max` refusals the step is FORCED. That block may miss
 *    its deadline, and missing one block is better than leaving a key silent.
 * 3. SAY SO. Deferrals and forced steps are counted SEPARATELY (rule 4). They
 *    mean different things: `defer` is the budget working, `forced` is the
 *    budget admitting it never found room -- which is a steady-state overrun
 *    (O4) reported through O2's counter, not a fault of the chunking.
 *
 * ⚠ ONE WORST-CASE PER MACHINE, NOT ONE SHARED. The caller passes the worst
 * cost of the work IT is about to do. A patch reseed is ~440,000 cycles and a
 * note's voice step ~148,000; a shared maximum lets the reseed's figure gate
 * every note step for ever -- the budget starving the exact work it was added
 * to protect. The struct holds no per-machine state for this on purpose: the
 * number belongs to the caller, so it cannot be conflated.
 *
 * ⚠ THE CALLER MUST REFRESH `slack` FROM BLOCKS THAT RAN NO STEP. A slack
 * figure taken from a block that ran a step measures the slack AFTER the step
 * consumed it, and the scheduler would then starve itself on its own output.
 * Because a deferred block runs no step, it is automatically such a block --
 * which is what makes a first deferral impossible to make permanent.
 *
 * GATE: tools/engineb/sched_gate.py, with teeth. Every rule above is a check
 * and every check has a planted defect that must be caught.
 */
#ifndef EB_SCHED_H
#define EB_SCHED_H

typedef struct {
    unsigned long slack;        /* measured spare capacity, burst-free block */
    unsigned long starve;       /* consecutive refusals so far               */
    unsigned long starve_max;   /* refusals before a step is FORCED          */
    unsigned long n_defer;      /* rule 4: counted, never silent             */
    unsigned long n_forced;     /* rule 4: counted SEPARATELY -- see above   */
} eb_sched;

static void eb_sched_init(eb_sched *s, unsigned long starve_max)
{
    s->slack = 0ul; s->starve = 0ul;
    /* ⚠ THE FLOOR IS 2, NOT 1, AND A GATE CHECK FOUND THAT. A zero makes
     * `++starve >= starve_max` true on the first refusal, so every step is
     * forced and the budget is entirely gone -- while the struct, the counters
     * and the report all still look present, which reads in a log as "the
     * scheduler never defers", indistinguishable from "the scheduler is
     * working well".
     *
     * Clamping to 1 was the first fix and it is the SAME BEHAVIOUR: >= 1 is
     * also true on the first refusal. A value below 2 cannot defer anything,
     * so it is not a budget, and the floor has to be the smallest value that
     * can actually refuse once. */
    s->starve_max = starve_max < 2ul ? 2ul : starve_max;
    s->n_defer = 0ul; s->n_forced = 0ul;
}

/* Called with the slack measured on a block that ran NO burst work. */
static void eb_sched_slack(eb_sched *s, unsigned long slack) { s->slack = slack; }

/* May one step of cost `worst` run now? Non-zero for yes. */
static int eb_sched_may(eb_sched *s, unsigned long worst)
{
    /* BOOTSTRAP. With no history there is nothing to compare, and refusing
     * until measured would mean never measuring -- the first steps ARE the
     * measurement. Allowing here is not a hole: it happens once, before any
     * step has ever run, and the very next block has both numbers. */
    if (s->slack == 0ul || worst == 0ul) return 1;

    if (worst <= s->slack) { s->starve = 0ul; return 1; }

    if (++s->starve >= s->starve_max) {
        s->starve = 0ul;
        ++s->n_forced;
        return 1;
    }
    ++s->n_defer;
    return 0;
}

#endif /* EB_SCHED_H */

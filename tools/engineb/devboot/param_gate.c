/* param_gate.c -- O3's PARAMETER SEQUENCE GATE.
 *
 * The third of the three, and the first one written BEFORE its machine
 * shipped rather than after a defect was found by reading it. The note machine
 * and the patch machine both shipped with the same publish-hand-over defect
 * (playbook 62); this gate exists so that history does not need a third entry.
 *
 * WHAT IT CHECKS:
 *   1. ORDER        apply, begin, step..., verify. Every stage exactly once
 *                   and in that order. A build opened before its warm recall
 *                   would gather the PREVIOUS knob position.
 *   2. TERMINATION  bounded blocks, ends idle, exactly one publish.
 *   3. HAND-OVER    a refused publish NEVER advances and NEVER re-opens the
 *                   build -- the defect the other two machines had, as a
 *                   property rather than as a memory.
 *   4. FATAL        a failing apply or verify leaves the machine IDLE owing
 *                   nothing, so a MUTE cannot also strand the shadow.
 *   5. INTERLOCK    idle is false from begin until the publish is TAKEN, and
 *                   continuously -- not merely at some point.
 *   6. BUDGET       eb_pm_heavy() is true on exactly the states that work.
 *                   PM_APPLY is the trap: it looks like two byte writes and
 *                   is really the ~0.24 M-cycle warm recall.
 *   7. EMPTY CLASS  a class that opens no builder still reaches the publish.
 *                   Dropping the edit silently is the one outcome never
 *                   allowed.
 */
#include <stdio.h>
#include "eb_paramstep.h"

static int bad = 0;
static void fail(const char *w) { printf("  *** %s\n", w); ++bad; }

typedef struct {
    char seq[64];
    int  n;
    int  steps_left;
    int  fail_at;        /* 0 = apply fails, 1 = verify fails, -1 = none */
    int  begins;
    int  open;           /* what begin() opens: 0 = nothing (empty class) */
} stub;

/* ⚠ TERMINATE THE STRING. The first version did not, so every printed
 * sequence was the current marks followed by whatever the PREVIOUS test had
 * left in the buffer -- "ABV" printed as "ABVsVV". A harness that prints a
 * stale buffer as its evidence is worse than one that prints nothing, because
 * it is read and believed. */
static int mark(stub *s, char c, int stage)
{
    if (s->n < 63) { s->seq[s->n++] = c; s->seq[s->n] = 0; }
    return s->fail_at != stage;
}

/* Work the BUDGET is meant to schedule, as opposed to any op call at all.
 * apply runs the ~0.24 M-cycle warm recall; step runs one sub-builder. begin
 * is a cursor open and verify reads a counter -- deliberately unbudgeted, for
 * the reason eb_notestep.h states: deferring those would hold the knob still
 * to save work that does not exist. Counting them as work would make this
 * check fire on correct code, and a check that cries wolf gets deleted. */
static int expensive = 0;
static int  s_apply (void *u) { ++expensive; return mark((stub *)u, 'A', 0); }
static void s_begin (void *u) { stub *s = (stub *)u; mark(s, 'B', -9);
                                ++s->begins; s->steps_left = s->open; }
static int  s_step  (void *u) { stub *s = (stub *)u; ++expensive;
                                mark(s, 's', -9);
                                return --s->steps_left > 0; }
static int  s_busy  (void *u) { return ((stub *)u)->steps_left > 0; }
static int  s_verify(void *u) { return mark((stub *)u, 'V', 1); }

static const eb_pm_ops OPS = { s_apply, s_begin, s_step, s_busy, s_verify };

static void reset(stub *s, int fail_at, int open)
{ s->n = 0; s->steps_left = 0; s->fail_at = fail_at; s->begins = 0;
  s->open = open; s->seq[0] = 0; expensive = 0; }

/* Drive one knob move to completion. `refuse` publishes to refuse before
 * accepting. Returns blocks spent; fills *pubs with publishes asked for. */
static int drive(stub *s, eb_pm *m, int refuse, int *pubs, int *asked)
{
    int i, taken = 0;
    *pubs = 0; *asked = 0;
    for (i = 0; i < 200; ++i) {
        int heavy = eb_pm_heavy(m);
        int e0 = expensive;
        int r = eb_pm_step(m, &OPS, s);
        if (expensive != e0 && !heavy)
            fail("budget: a state the budget calls cheap ran expensive work");
        if (r < 0) return i + 1;
        if (r > 0 && eb_pm_idle(m))
            fail("interlock: reported IDLE with a build still owed -- the "
                 "caller would start a note build over this shadow");
        if (r == 0) {
            ++*asked;
            if (*asked <= refuse) {
                /* REFUSED: do NOT call published(). The machine must ask
                 * again next block and touch nothing. */
                int n1 = s->n;
                if (eb_pm_idle(m))
                    fail("hand-over: went IDLE on a publish that was refused "
                         "-- the build is stranded and the knob does nothing");
                (void)n1;
            } else {
                eb_pm_published(m);
                ++*pubs;
                ++taken;
                if (eb_pm_idle(m)) return i + 1;
            }
        }
    }
    fail("termination: the sequence never finished in 200 blocks");
    return 200;
}

int main(void)
{
    printf("PARAM GATE  (engine_b/dev/eb_paramstep.h, the firmware's own copy)\n");

    /* ---- 1, 2, 5, 6: a clean knob move, class opening 3 builders -------- */
    {
        stub s; eb_pm m; int pubs, asked;
        reset(&s, -1, 3); eb_pm_init(&m);
        if (!eb_pm_idle(&m)) fail("a fresh machine is not idle");
        eb_pm_begin(&m);
        if (eb_pm_idle(&m)) fail("idle immediately after begin()");
        drive(&s, &m, 0, &pubs, &asked);
        printf("  clean move: seq=%s blocks=%u publishes=%d\n",
               s.seq, m.blocks, pubs);
        if (s.n != 6 || s.seq[0] != 'A' || s.seq[1] != 'B' ||
            s.seq[2] != 's' || s.seq[3] != 's' || s.seq[4] != 's' ||
            s.seq[5] != 'V')
            fail("order: expected A B s s s V");
        if (pubs != 1) fail("termination: not exactly one publish");
        if (!eb_pm_idle(&m)) fail("did not end idle");
        if (s.begins != 1) fail("opened the build more than once");
        if (m.pub_retry != 0u) fail("pub_retry non-zero on a clean move");
    }

    /* ---- 3: THE HAND-OVER. Refuse the publish twice, then accept. ------- */
    {
        stub s; eb_pm m; int pubs, asked;
        reset(&s, -1, 2); eb_pm_init(&m); eb_pm_begin(&m);
        drive(&s, &m, 2, &pubs, &asked);
        printf("  refused twice: seq=%s asked=%d retry=%u\n",
               s.seq, asked, m.pub_retry);
        if (asked != 3) fail("hand-over: did not re-ask after each refusal");
        if (m.pub_retry != 2u) fail("hand-over: pub_retry did not count the "
                                    "refusals");
        if (s.begins != 1)
            fail("hand-over: re-opened the build over an un-handed shadow -- "
                 "the exact defect the other two machines shipped with");
        if (s.n != 5)
            fail("hand-over: a refused publish did WORK; it must touch nothing");
        if (!eb_pm_idle(&m)) fail("did not end idle after the accepted publish");
    }

    /* ---- 4: FATAL at apply, and at verify ------------------------------ */
    {
        stub s; eb_pm m; int r;
        reset(&s, 0, 3); eb_pm_init(&m); eb_pm_begin(&m);
        r = eb_pm_step(&m, &OPS, &s);
        if (r != -1) fail("fatal: a failing apply did not report -1");
        if (!eb_pm_idle(&m))
            fail("fatal: a failed apply left the shadow owned -- the mute "
                 "would also block every future build");
        if (s.begins != 0) fail("fatal: opened a build after apply failed");

        reset(&s, 1, 2); eb_pm_init(&m); eb_pm_begin(&m);
        for (r = 1; r > 0; ) r = eb_pm_step(&m, &OPS, &s);
        if (r != -1) fail("fatal: a failing verify did not report -1");
        if (!eb_pm_idle(&m)) fail("fatal: a failed verify left the shadow owned");
    }

    /* ---- 7: an EMPTY class still publishes ----------------------------- */
    {
        stub s; eb_pm m; int pubs, asked;
        reset(&s, -1, 0); eb_pm_init(&m); eb_pm_begin(&m);
        drive(&s, &m, 0, &pubs, &asked);
        printf("  empty class: seq=%s publishes=%d\n", s.seq, pubs);
        if (pubs != 1)
            fail("an empty class did not publish -- the edit was dropped "
                 "silently, which is the one outcome never allowed");
        if (!eb_pm_idle(&m)) fail("empty class did not end idle");
    }

    /* ---- 5 again: idle must be false CONTINUOUSLY, not just once ------- */
    {
        stub s; eb_pm m; int i, r;
        reset(&s, -1, 4); eb_pm_init(&m); eb_pm_begin(&m);
        for (i = 0; i < 50; ++i) {
            r = eb_pm_step(&m, &OPS, &s);
            if (r == 0) break;
            if (r < 0) break;
            if (eb_pm_idle(&m))
                fail("interlock: idle went true MID-BUILD -- a machine that "
                     "reports idle for one block is a shadow with two owners");
        }
    }

    /* ---- 8: A STRAY published() MID-BUILD MUST NOT ADVANCE -------------
     *
     * eb_pm_published() is guarded on PM_PUB. That guard was untested until a
     * tooth removing it was NOT CAUGHT -- the gate only ever called
     * published() at the moment the machine asked for one, which is the one
     * case the guard is not for.
     *
     * What it IS for: the caller runs three machines and publishes once per
     * block for whichever of them asked. A caller that mis-attributes a
     * publish -- the note machine asked, the parameter machine is told --
     * would, without the guard, jump this machine straight from a half-built
     * shadow to IDLE. The build is then abandoned mid-way AND the shadow is
     * declared free, so the next builder opens over a bank that was never
     * handed to the audio. With three machines sharing one shadow that
     * mis-attribution is a live possibility, not a hypothetical. */
    {
        stub s; eb_pm m; int st_before;
        reset(&s, -1, 4); eb_pm_init(&m); eb_pm_begin(&m);
        eb_pm_step(&m, &OPS, &s);          /* PM_APPLY -> PM_COEFS */
        eb_pm_step(&m, &OPS, &s);          /* one sub-builder done */
        st_before = m.st;
        if (st_before == PM_PUB) fail("test 8 setup: already at PM_PUB");
        eb_pm_published(&m);               /* the caller lies */
        if (m.st != st_before)
            fail("a published() call in a NON-publish state advanced the "
                 "machine -- a mis-attributed publish abandons a half-built "
                 "shadow and declares it free");
        if (eb_pm_idle(&m))
            fail("a stray published() mid-build made the machine idle");
    }

    printf("PARAM GATE: %s\n", bad ? "FAIL" : "PASS");
    return bad ? 1 : 0;
}

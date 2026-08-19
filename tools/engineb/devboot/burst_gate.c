/* burst_gate.c -- O2's PATCH SEQUENCE GATE.
 *
 * The twin of note_gate.c. It exists because extracting and gating the NOTE
 * machine, then reading the PATCH machine with that contract in mind, found
 * the same publish-hand-over defect STILL LIVE in the shipping path: BST_CHECK
 * went IDLE and asked for a publish in one step, so a refused publish left a
 * whole ~2.1 M-cycle build stranded in the shadow -- a program change that
 * silently did nothing, and a built patch destroyed by the next key press.
 *
 * WHAT IT CHECKS:
 *   1. ORDER        reseed, install, recall, notes, begin, step..., verify.
 *                   Every stage exactly once and in that order -- a patch
 *                   installed before its reseed is the old cells' record.
 *   2. TERMINATION  bounded blocks, ends idle, exactly one publish.
 *   3. HAND-OVER    a refused publish NEVER advances and NEVER re-opens the
 *                   build. The defect above, as a property.
 *   4. FATAL        any stage failing leaves the machine IDLE owing nothing.
 *   5. INTERLOCK    idle is false from begin until the publish is taken.
 *   6. BUDGET       eb_bs_heavy() is true exactly on the states that work.
 */
#include <stdio.h>
#include "eb_burststep.h"

static int bad = 0;
static void fail(const char *w){ printf("  *** %s\n", w); ++bad; }

typedef struct {
    char seq[64]; int n;
    int  voices_left;
    int  fail_at;          /* which stage returns failure, -1 = none */
    int  begins;
} stub;

static int mark(stub *s, char c, int stage)
{
    if (s->n < 63) s->seq[s->n++] = c;
    return s->fail_at != stage;
}
static int s_reseed (void *u){ return mark((stub*)u,'R',0); }
static int s_install(void *u){ return mark((stub*)u,'I',1); }
static int s_recall (void *u){ return mark((stub*)u,'C',2); }
static int s_notes  (void *u){ return mark((stub*)u,'N',3); }
static void s_begin (void *u){ stub*s=(stub*)u; mark(s,'B',-9); ++s->begins;
                               s->voices_left = 10; }
static int s_step   (void *u){ stub*s=(stub*)u; mark(s,'s',-9);
                               return --s->voices_left > 0; }
static int s_verify (void *u){ return mark((stub*)u,'V',4); }

static const eb_bs_ops OPS = { s_reseed, s_install, s_recall, s_notes,
                               s_begin, s_step, s_verify };

static void reset(stub *s, int fail_at)
{ s->n = 0; s->voices_left = 0; s->fail_at = fail_at; s->begins = 0; }

int main(void)
{
    printf("BURST GATE  (engine_b/dev/eb_burststep.h, the firmware's own copy)\n");

    /* ---- 1, 2, 5, 6: a clean program change ---------------------------- */
    {
        stub s; eb_bs b; int i, pubs = 0;
        reset(&s, -1); eb_bs_init(&b); eb_bs_begin(&b);
        for (i = 0; i < 200; ++i) {
            int heavy = eb_bs_heavy(&b);
            int n0 = s.n;
            int r = eb_bs_step(&b, &OPS, &s);
            if (s.n != n0 && !heavy)
                fail("budget: a state the budget calls cheap did real work");
            if (r > 0 && eb_bs_idle(&b))
                fail("interlock: reported IDLE with a build still owed -- a "
                     "note would take the shadow from under the patch");
            if (r < 0) { fail("a clean patch change reported fatal"); break; }
            if (r == 0) { ++pubs; eb_bs_published(&b);
                          if (eb_bs_idle(&b)) break; }
        }
        s.seq[s.n] = 0;

        {   const char *want = "RICNBssssssssssV";   /* 10 steps, one per stub voice */
            int k; for (k = 0; want[k] || s.seq[k]; ++k)
                if (want[k] != s.seq[k]) {
                    printf("  *** order: got \"%s\", expected \"%s\" -- a stage "
                           "ran out of order, twice, or not at all\n",
                           s.seq, want);
                    ++bad; break;
                }
        }
        if (pubs != 1) { printf("  *** %d publishes, expected 1\n", pubs); ++bad; }
        if (!eb_bs_idle(&b)) fail("termination: ended not idle");
        if (s.begins != 1) fail("order: the coefficient build was opened more "
                                "than once");
    }

    /* ---- 3: HAND-OVER. The caller never acknowledges. ------------------- */
    {
        stub s; eb_bs b; int i, asked = -1;
        reset(&s, -1); eb_bs_init(&b); eb_bs_begin(&b);
        for (i = 0; i < 300; ++i) {
            int r = eb_bs_step(&b, &OPS, &s);
            if (r == 0 && asked < 0) asked = s.n;
            /* deliberately never call eb_bs_published() */
        }
        if (asked < 0) fail("hand-over: never asked to publish");
        else if (s.n != asked)
            printf("  *** hand-over: work continued after a REFUSED publish "
                   "(%d calls, was %d at the ask) -- the built patch is "
                   "stranded in the shadow and the next note destroys it\n",
                   s.n, asked), ++bad;
        if (eb_bs_idle(&b))
            fail("hand-over: went IDLE without ever publishing -- the program "
                 "change silently did nothing");
        if (b.pub_retry == 0u) fail("hand-over: retries not counted (rule 4)");
    }

    /* ---- 4: FATAL at every stage --------------------------------------- */
    {
        int stage;
        for (stage = 0; stage <= 4; ++stage) {
            stub s; eb_bs b; int i, got = 0;
            reset(&s, stage); eb_bs_init(&b); eb_bs_begin(&b);
            for (i = 0; i < 200; ++i) {
                int r = eb_bs_step(&b, &OPS, &s);
                if (r == 0) eb_bs_published(&b);
                if (r < 0) { got = 1; break; }
                if (eb_bs_idle(&b)) break;
            }
            if (!got) { printf("  *** fatal: stage %d failed and was not "
                               "reported\n", stage); ++bad; }
            if (!eb_bs_idle(&b)) { printf("  *** fatal: stage %d left a publish "
                                          "owed\n", stage); ++bad; }
        }
    }

    printf("BURST GATE: %s\n", bad == 0
           ? "PASS -- ordered, terminates, hands over, mutes cleanly" : "FAIL");
    return bad == 0 ? 0 : 1;
}

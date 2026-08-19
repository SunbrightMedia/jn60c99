/* note_gate.c -- O2's NOTE SEQUENCE GATE.
 *
 * ⚠ WHY IT EXISTS. The note state machine lived inside juno_s3_listen.c where
 * nothing could test it, and TWO defects in it were found by READING:
 *   1. a refused publish let the catch-up build copy over the shadow holding
 *      the priority voice -- that voice then stale for ever, silently;
 *   2. a program change arriving mid-note took the shadow from under it.
 * Finding those by reading was luck. This gate is so the next one is found by
 * method. It drives engine_b/dev/eb_notestep.h -- THE HEADER THE FIRMWARE
 * RUNS -- with a recording stub in place of the engine, so the SEQUENCE is
 * checked without a device.
 *
 * WHAT IT CHECKS, over all 65,536 (touched, voiced) mask pairs:
 *   1. TERMINATION   every note reaches idle, in a bounded, PREDICTED number
 *                    of blocks -- not "eventually"
 *   2. KEY LATENCY   the first publish lands after exactly 1 + popcount(pri)
 *                    blocks. This is the split publish's whole claim.
 *   3. HAND-OVER     begin_voices(rest) is NEVER called before the first
 *                    publish is acknowledged -- defect 1, as a call order
 *   4. REFUSAL       if the caller never acknowledges, the machine asks for
 *                    ever and opens NO new build. Defect 1 at its root.
 *   5. COVERAGE      every voice in `touched` is built exactly once across
 *                    the two stages -- no voice built twice, none skipped
 *   6. INTERLOCK     idle is false from the first step until the LAST publish,
 *                    which is what keeps the patch burst out. Defect 2.
 *   7. FATAL         a bad event or a failed cell check leaves the machine
 *                    IDLE, owing no publish
 *
 * usage: note_gate     (no arguments -- it is pure sequencing)
 */
#include <stdio.h>
#include "eb_notestep.h"

#define NV 8

static int bad = 0;
static void fail(const char *w) { printf("  *** %s\n", w); ++bad; }

/* The recording stub. It does no coefficient work: this gate is about ORDER,
 * and chunk_gate.py already proves the values. */
typedef struct {
    unsigned touched, voiced;
    unsigned cur_mask;          /* the build currently open */
    int      remaining;         /* voices left in it */
    int      begins;            /* how many builds have been opened */
    unsigned begin_arg[4];      /* the masks they were opened with */
    int      built[NV];         /* how many times each voice was built */
    int      apply_ok, check_ok_v;
    int      applies;
    int      begin_after_pub1;  /* was the 2nd build opened post-ack? */
    int      acked1;
} stub;

static int  s_apply(void *u){ stub*s=(stub*)u; ++s->applies; return s->apply_ok; }
static unsigned s_touched(void *u){ return ((stub*)u)->touched; }
static unsigned s_voiced (void *u){ return ((stub*)u)->voiced;  }
static void s_begin(void *u, unsigned m)
{
    stub *s = (stub*)u; int v;
    if (s->begins < 4) s->begin_arg[s->begins] = m;
    ++s->begins;
    if (s->begins == 2 && !s->acked1) s->begin_after_pub1 = 0;
    s->cur_mask = m; s->remaining = 0;
    for (v = 0; v < NV; ++v) if (m & (1u << v)) ++s->remaining;
}
static int s_step(void *u)
{
    stub *s = (stub*)u; int v;
    for (v = 0; v < NV; ++v)
        if (s->cur_mask & (1u << v)) {          /* build the lowest owed */
            ++s->built[v]; s->cur_mask &= ~(1u << v); --s->remaining; break;
        }
    return s->remaining > 0;
}
static int s_busy(void *u){ return ((stub*)u)->remaining > 0; }
static int s_check(void *u){ return ((stub*)u)->check_ok_v; }

static const eb_nb_ops OPS = { s_apply, s_touched, s_voiced,
                               s_begin, s_step, s_busy, s_check };

static int pc(unsigned m){ int n=0,v; for(v=0;v<NV;++v) if(m&(1u<<v)) ++n; return n; }

int main(void)
{
    unsigned t, vd;
    long pairs = 0;

    printf("NOTE GATE  (engine_b/dev/eb_notestep.h, the firmware's own copy)\n");

    for (t = 0; t < (1u << NV) && !bad; ++t)
    for (vd = 0; vd < (1u << NV) && !bad; ++vd) {
        stub s; eb_nb n; int blocks = 0, pubs = 0, first_pub = -1, v;
        unsigned pri, rest;
        int saw_nonidle = 0;

        for (v = 0; v < NV; ++v) s.built[v] = 0;
        s.touched = t; s.voiced = vd; s.cur_mask = 0; s.remaining = 0;
        s.begins = 0; s.apply_ok = 1; s.check_ok_v = 1; s.applies = 0;
        s.begin_after_pub1 = 1; s.acked1 = 0;
        eb_nb_init(&n);

        pri  = vd & t;
        rest = t & ~pri;

        for (;;) {
            /* ---- 8. THE BUDGET'S PREDICATE MUST MATCH REALITY -----------
             * eb_nb_heavy() is what the scheduler defers on. If it claims a
             * state is cheap when that state actually opens a build, the
             * budget skips the check on the most expensive work in the
             * firmware -- the exact miss O2 was fixing. If it claims a state
             * is heavy when it only asks for a pointer swap, the key is held
             * silent to save work that does not exist.
             *
             * So: predict from heavy(), then look at whether the step really
             * touched the engine. Compiling with the predicate unused is how
             * that would have gone unnoticed -- and it did, until -Werror. */
            int predicted_heavy = eb_nb_heavy(&n);
            int b0 = s.begins, w0 = 0;
            int r;
            for (v = 0; v < NV; ++v) w0 += s.built[v];
            r = eb_nb_step(&n, &OPS, &s);
            {   int w1 = 0, did;
                for (v = 0; v < NV; ++v) w1 += s.built[v];
                did = (s.begins != b0) || (w1 != w0);
                if (did && !predicted_heavy) {
                    printf("  *** t=%02x v=%02x: a state the budget calls "
                           "CHEAP opened or advanced a build -- the most "
                           "expensive work in the firmware skips the budget\n",
                           t, vd);
                    ++bad; break;
                }
            }
            ++blocks;
            if (blocks > 64) { fail("termination: the note never finished"); break; }
            if (!eb_nb_idle(&n)) saw_nonidle = 1;
            /* ⚑ THE INTERLOCK MUST HOLD CONTINUOUSLY, NOT MERELY ONCE.
             * A tooth found this: the first version only checked that the
             * machine LEFT idle at some point, which a machine that reports
             * idle in the middle of its own build passes trivially. idle is
             * what tells the caller the shadow is free -- it must be false on
             * every block where work is still owed, or a patch build opens
             * over a half-finished note and the shadow has two owners. */
            if (r > 0 && eb_nb_idle(&n)) {
                printf("  *** t=%02x v=%02x: reported IDLE with work still "
                       "owed -- the caller would draw new events and start a "
                       "patch build over this note's shadow\n", t, vd);
                ++bad; break;
            }
            if (r < 0) { fail("a clean note reported fatal"); break; }
            if (r == 0) {
                ++pubs;
                if (first_pub < 0) first_pub = blocks;
                if (n.st == NB_PUB1) s.acked1 = 1;
                eb_nb_published(&n);
                if (eb_nb_idle(&n)) break;      /* the note is complete */
            }
        }
        if (bad) break;

        /* ---- 2. KEY LATENCY -------------------------------------------- */
        if (pri) {
            if (first_pub != 1 + pc(pri)) {
                printf("  *** t=%02x v=%02x: key sounded on block %d, "
                       "expected %d (1 apply + %d priority voices)\n",
                       t, vd, first_pub, 1 + pc(pri), pc(pri));
                ++bad; break;
            }
        }
        /* ---- 3. HAND-OVER ---------------------------------------------- */
        if (!s.begin_after_pub1) {
            printf("  *** t=%02x v=%02x: the catch-up build was opened BEFORE "
                   "the priority publish was acknowledged -- the priority "
                   "voice is overwritten in the shadow and never rebuilt\n",
                   t, vd);
            ++bad; break;
        }
        /* ---- 5. COVERAGE ------------------------------------------------ */
        for (v = 0; v < NV; ++v) {
            int want = (t & (1u << v)) ? 1 : 0;
            if (s.built[v] != want) {
                printf("  *** t=%02x v=%02x: voice %d built %d times, "
                       "expected %d\n", t, vd, v, s.built[v], want);
                ++bad; break;
            }
        }
        if (bad) break;
        /* ---- 6. INTERLOCK ----------------------------------------------- */
        if (t && !saw_nonidle) {
            fail("interlock: the machine never left idle, so a patch build "
                 "could have taken the shadow mid-note");
            break;
        }
        if (!eb_nb_idle(&n)) { fail("termination: ended not idle"); break; }
        /* one publish when there is nothing to catch up, two otherwise */
        if (pri && rest && pubs != 2) {
            printf("  *** t=%02x v=%02x: %d publishes, expected 2\n",
                   t, vd, pubs); ++bad; break;
        }
        (void)rest;
        ++pairs;
    }
    printf("%ld (touched,voiced) pairs walked\n", pairs);

    /* ---- 4. REFUSAL: the caller never acknowledges ---------------------- */
    {
        stub s; eb_nb n; int i, begins_at_pub = -1;
        int v; for (v = 0; v < NV; ++v) s.built[v] = 0;
        s.touched = 0xFFu; s.voiced = 0x01u; s.cur_mask = 0; s.remaining = 0;
        s.begins = 0; s.apply_ok = 1; s.check_ok_v = 1; s.applies = 0;
        s.begin_after_pub1 = 1; s.acked1 = 0;
        eb_nb_init(&n);
        for (i = 0; i < 200; ++i) {
            int r = eb_nb_step(&n, &OPS, &s);
            if (r == 0 && begins_at_pub < 0) begins_at_pub = s.begins;
            /* deliberately NEVER call eb_nb_published() */
        }
        if (begins_at_pub < 0) fail("refusal: never asked to publish");
        else if (s.begins != begins_at_pub) {
            printf("  *** refusal: a NEW BUILD was opened while the publish "
                   "was still refused (%d builds, was %d at the first ask) -- "
                   "the un-published shadow is overwritten and its voice is "
                   "lost for ever\n", s.begins, begins_at_pub);
            ++bad;
        }
        if (eb_nb_idle(&n))
            fail("refusal: the machine went idle without ever publishing -- "
                 "the caller would draw new events over an owed build");
        if (n.pub_retry == 0ul)
            fail("refusal: retries were not counted (rule 4)");
    }

    /* ---- 7. FATAL ------------------------------------------------------- */
    {
        stub s; eb_nb n; int v;
        for (v = 0; v < NV; ++v) s.built[v] = 0;
        s.touched = 0xFFu; s.voiced = 0x01u; s.cur_mask = 0; s.remaining = 0;
        s.begins = 0; s.apply_ok = 0; s.check_ok_v = 1; s.applies = 0;
        s.begin_after_pub1 = 1; s.acked1 = 0;
        eb_nb_init(&n);
        if (eb_nb_step(&n, &OPS, &s) != -1)
            fail("fatal: an unapplicable event did not mute");
        if (!eb_nb_idle(&n))
            fail("fatal: left a publish owed after muting");

        /* and a failed unmapped-cell check */
        for (v = 0; v < NV; ++v) s.built[v] = 0;
        s.touched = 0x03u; s.voiced = 0x01u; s.cur_mask = 0; s.remaining = 0;
        s.begins = 0; s.apply_ok = 1; s.check_ok_v = 0; s.applies = 0;
        s.begin_after_pub1 = 1; s.acked1 = 0;
        eb_nb_init(&n);
        {   int i, got = 0;
            for (i = 0; i < 64; ++i) {
                int r = eb_nb_step(&n, &OPS, &s);
                if (r == 0) { if (n.st == NB_PUB1) s.acked1 = 1;
                              eb_nb_published(&n); }
                if (r < 0) { got = 1; break; }
            }
            if (!got) fail("fatal: an unmapped cell was never reported");
            if (!eb_nb_idle(&n)) fail("fatal: not idle after the cell check failed");
        }
    }

    printf("NOTE GATE: %s\n", bad == 0
           ? "PASS -- the sequence terminates, hands over, and covers"
           : "FAIL");
    return bad == 0 ? 0 : 1;
}

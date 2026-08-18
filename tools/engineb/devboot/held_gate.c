/* held_gate.c -- the HELD-broadcast narrowing: same coefficients, fewer voices.
 *
 * WHAT IT GUARDS. eb_devseq_events used to widen the touched-voice mask to all
 * eight on EVERY note event, because EB_EV_HELD broadcasts cell 1856 to every
 * voice. MEASURED consequence (b9_held_broadcast.md): every note paid the full
 * 1.12 M-cycle voice build -- 7.9x its plan, and once the note build was
 * chunked, TEN BLOCKS of key latency.
 *
 * The narrowing widens only when the broadcast actually MOVES the cell. That is
 * a correctness claim about seven voices nobody can hear individually, so it is
 * gated rather than argued.
 *
 * TWO CHECKS, AND BOTH ARE NEEDED:
 *
 *   1. EQUIVALENCE. For every event batch, build with the NARROWED mask and
 *      build with ~0u, then compare the coefficient sets byte for byte. If the
 *      narrowing ever drops a voice whose cells really changed, they differ.
 *      This check alone is not enough: a path that never narrows passes it
 *      trivially.
 *
 *   2. THE MASK IS ACTUALLY NARROW WHEN IT SHOULD BE, and WIDE when it must be.
 *      The first key down and the last key up transition cell 1856 and MUST
 *      widen. A note-on while another key is already held MUST NOT. Without
 *      this, check 1 would bless a no-op.
 *
 * The sequence below is the smallest one that exercises both transitions and
 * the middle: press A (widen), press B while A is held (narrow), release B
 * while A is held (narrow), release A (widen).
 *
 * usage: held_gate <boot.bin> <bank64.bin> <template.bin>
 *   env  DEVCRC_NV=8
 *
 * TEETH: tools/engineb/held_teeth.sh plants three defects and requires each to
 * be caught. A gate that has never gone red is an untested detector.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#include "ebdev.h"
#include "eb_devseq.h"
#include "eb_patch.h"
#include "eb_coefs.h"
#include "eb_master_coefs.h"
#include "eb_render.h"
#include "eb_master.h"
#include "eb_recall.h"
#include "eb_alloc.h"
#include "devchord.h"

static eb_render_coefs RC_A, RC_B, RC_WIDE;
static eb_master_coef  MC_A, MC_B, MC_WIDE;
static eb_render_state RS;
static eb_master_state MS;
static eb_recall       REC;
static eb_alloc        AL;
static eb_alloc_ev     EV[EB_ALLOC_MAX_EV];

static unsigned char BANKBUF[EB_DEVSEQ_BANK_BYTES];

static int popcnt(unsigned m)
{
    int n = 0;
    while (m) { n += (int)(m & 1u); m >>= 1; }
    return n;
}

/* one note event batch: apply it, publish it, then prove nothing went stale.
 *
 * `want` is -1 for "report the mask, assert nothing" -- used where the right
 * answer depends on what a patch recall happened to leave in cell 1856, which
 * is not this gate's business to predict. 0 and 1 are assertions. */
static int step(const char *what, int on, int note, int want, int *bad)
{
    unsigned mask;
    int n, wide;

    n = on ? eb_alloc_note_on(&AL, note, 100, EV)
           : eb_alloc_note_off(&AL, note, EV);
    if (n <= 0) { printf("  *** %s: allocator emitted %d events\n", what, n);
                  ++*bad; return 1; }
    if (eb_devseq_events(EV, n) != n) {
        printf("  *** %s: eb_devseq_events refused the batch\n", what);
        ++*bad; return 1;
    }
    mask = EB_DEVSEQ_TOUCHED;
    wide = popcnt(mask & ((1u << EB_NUM_VOICES) - 1u)) == EB_NUM_VOICES;

    /* ---- THE BUILD, AND THE PUBLISH ------------------------------------
     * The publish matters and its absence was this gate's first defect: the
     * firmware makes every note build live, so `cur` always reflects the cells
     * as they were at the last note. A gate that never publishes leaves `cur`
     * at recall-time values, and then EVERY narrow build "differs from a wide
     * one" -- not because the narrowing is wrong but because the reference
     * drifted. Copying the shadow over the live bank models the publish for
     * coefficient purposes, which is all this gate is about. */
    eb_recall_build_voices(&REC, mask);
    RC_A = RC_B; MC_A = MC_B;

    /* ---- THE CHECK THAT MATTERS, and it is not circular -----------------
     * Compare the LIVE bank against a full rebuild from the CURRENT cells. If
     * the narrowing ever leaves a voice stale, the live bank disagrees with
     * ground truth -- and ground truth here is eb_render_coefs_build, the same
     * function the certified gate uses.
     *
     * Asserting "the mask should be wide here" instead would be circular: it
     * would restate the implementation rather than test it. This asks the only
     * question that has a right answer independent of how the mask is chosen. */
    eb_render_coefs_build((const unsigned char *)0, &RC_WIDE);
    eb_master_coefs_build((const unsigned char *)0, &MC_WIDE);
    if (memcmp(&RC_A, &RC_WIDE, sizeof RC_A) != 0) {
        int v;
        printf("  *** %s: the live render coefs DISAGREE with a full rebuild "
               "from the current cells -- the narrowing left a voice stale\n",
               what);
        /* NAME THE CELL, do not leave the next reader to guess. 1856 is
         * scatter index 4, so every voice has its own copy; if they are not
         * all equal then reading voice 0's alone is the wrong test and the
         * narrowing is unsound as written. */
        printf("      cell 1856 per voice:");
        for (v = 0; v < EBDEV_NV; ++v)
            printf(" v%d=%.1f", v, (double)EBDEV_S.scat[v][4]);
        printf("   (scatter index 4)\n");
        {   /* NAME THE BYTE. Guessing which voice went stale cost this gate
             * three rounds; the offset says it in one. */
            const unsigned char *x = (const unsigned char *)&RC_A;
            const unsigned char *y = (const unsigned char *)&RC_WIDE;
            size_t i, first = (size_t)-1, ndiff = 0;
            for (i = 0; i < sizeof RC_A; ++i)
                if (x[i] != y[i]) { if (first == (size_t)-1) first = i; ++ndiff; }
            printf("      first differing byte %u of %u, %u bytes differ\n",
                   (unsigned)first, (unsigned)sizeof RC_A, (unsigned)ndiff);
            /* And whether a WIDE build from the same start would have agreed:
             * if it does, the mask is the cause; if it does not, something
             * outside the mask moved and the narrowing is not to blame. */
            eb_recall_build_voices(&REC, ~0u);
            printf("      a WIDE build from the same start %s the full rebuild\n",
                   memcmp(&RC_B, &RC_WIDE, sizeof RC_B) == 0
                     ? "MATCHES" : "ALSO DIFFERS");
        }
        ++*bad;
    }
    if (memcmp(&MC_A, &MC_WIDE, sizeof MC_A) != 0) {
        printf("  *** %s: the live master coefs disagree with a full rebuild\n",
               what);
        ++*bad;
    }

    /* ---- AND THAT IT ACTUALLY NARROWS ----------------------------------
     * Without this, an implementation that never narrows passes everything
     * above and delivers none of the 7.9x. */
#ifndef EB_DEVSEQ_NARROW_HELD
    /* With the narrowing OFF the mask is always wide BY DESIGN, so the
     * narrowness assertions do not apply. The STALENESS check above still
     * runs and still means something: it proves the unconditional widen is
     * correct, which is the behaviour that ships. */
    want = -1;
#endif
    if (want >= 0 && wide != want) {
        printf("  *** %s: mask %08x is %s, expected %s. %s\n",
               what, mask, wide ? "WIDE" : "narrow",
               want ? "WIDE" : "narrow",
               want ? "This transition MOVES cell 1856, so all eight voices "
                      "really do change."
                    : "Cell 1856 cannot have moved here, so seven voices "
                      "would be rebuilt to identical values.");
        ++*bad;
    } else {
        printf("      %-28s mask %08x  %-6s  %d voice(s)%s\n", what, mask,
               wide ? "WIDE" : "narrow",
               popcnt(mask & ((1u << EB_NUM_VOICES) - 1u)),
               want < 0 ? "   (reported, not asserted)" : "");
    }
    return 0;
}

int main(int argc, char **argv)
{
    FILE *f;
    unsigned char *boot, *bank64, *tpl;
    long bootn, bankn, tpln;
    unsigned nv = 8;
    int bad = 0, p;
    const char *e = getenv("DEVCRC_NV");

    if (argc < 4) {
        fprintf(stderr, "usage: %s <boot.bin> <bank64.bin> <template.bin>\n",
                argv[0]);
        return 2;
    }
    if (e) nv = (unsigned)atoi(e);
    if (nv != (unsigned)EBDEV_NV) {
        fprintf(stderr, "DEVCRC_NV=%u but this build is EBDEV_NV=%d\n",
                nv, EBDEV_NV);
        return 2;
    }
#define SLURP(path, buf, len) do {                                         \
        f = fopen(path, "rb"); if (!f) { perror(path); return 2; }          \
        fseek(f, 0, SEEK_END); len = ftell(f); fseek(f, 0, SEEK_SET);       \
        buf = (unsigned char *)malloc((size_t)len);                        \
        if (!buf || fread(buf, 1, (size_t)len, f) != (size_t)len) return 2; \
        fclose(f);                                                          \
    } while (0)
    SLURP(argv[1], boot, bootn);
    SLURP(argv[2], bank64, bankn);
    SLURP(argv[3], tpl, tpln);
#undef SLURP

    printf("HELD GATE  EBDEV_NV=%d\n", EBDEV_NV);
    eb_recall_init(&REC, &RC_A, &RC_B, &MC_A, &MC_B, &RS, &MS,
                   (const eb_engine *)0);

    /* THREE PATCHES, because the narrowing reads a CELL and a patch recall
     * rewrites that cell. A tracker-based implementation would pass patch 0
     * and fail here, which is exactly the failure this gate must be able to
     * see. Patch 5 is a DELAY TYPE 5; patch 21 another. */
    {   const int pats[3] = { 0, 5, 21 };
        int pi;
        for (pi = 0; pi < 3; ++pi) {
            p = pats[pi];
            printf("  -- patch %d, fresh recall --\n", p);
            ebdev_reset_counters();
            if (eb_devseq_boot_cells(boot, nv)) return 2;
            if (eb_devseq_install(BANKBUF, tpl, (size_t)tpln,
                                  bank64 + (size_t)p * EB_PATCH_BYTES)) return 2;
            eb_devseq_recall(BANKBUF, 128.0f);
            eb_alloc_init(&AL);
            eb_devseq_alloc_config(&AL, BANKBUF);
            eb_render_coefs_build((const unsigned char *)0, &RC_A);
            eb_master_coefs_build((const unsigned char *)0, &MC_A);

            /* THE FIRST NOTE AFTER A RECALL IS REPORTED, NOT ASSERTED, and
             * that correction is worth keeping: this gate first demanded a
             * WIDE mask here and patch 5 refused, because the recall had
             * already left cell 1856 at 1.0. The mask was right and the
             * expectation was wrong. What guards this case is the staleness
             * check above, which holds whatever the recall left behind. */
            if (step("first key after recall", 1, 60, -1, &bad)) return 1;
            /* A SECOND KEY WHILE ONE IS HELD CANNOT MOVE 1856 -- it is already
             * 1.0 -- so this MUST narrow. It is the benefit, in one line. */
            if (step("second key, one held",   1, 64,  0, &bad)) return 1;
            if (step("release one, one held",  0, 64,  0, &bad)) return 1;
            /* THE LAST KEY UP DRIVES 1856 TO 0.0 ON EVERY VOICE. It must widen
             * or seven voices keep a stale k1856 in the LFO. */
            if (step("release last key",       0, 60,  1, &bad)) return 1;
        }
    }

    printf("HELD GATE: %s\n", bad == 0
           ? "PASS -- narrow builds equal wide builds, and narrows when it may"
           : "FAIL");
    return bad == 0 ? 0 : 1;
}

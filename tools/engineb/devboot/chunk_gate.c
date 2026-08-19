/* chunk_gate.c -- O2's gate: THE CHUNKED BUILD IS THE MONOLITHIC BUILD.
 *
 * O2 spreads the ~2.1 M-cycle patch-change burst over several blocks so it
 * stops missing audio deadlines (1-4 per program change, MEASURED --
 * data/b4_first_run.md). Spreading work is only safe if the spread version
 * computes the SAME BYTES. That is not something to argue; it is something to
 * compare, over the whole bank, byte for byte.
 *
 * WHAT IT COMPARES, per patch, over all 64:
 *
 *   A = eb_render_coefs_build(base, &RC)                 -- the monolith
 *   B = eb_recall_chunk_begin() then chunk_step() to 0   -- what the board runs
 *
 * and the same for the master coefficients. B is driven through the REAL
 * eb_recall chunk cursor, not a hand-rolled loop that happens to call the same
 * functions -- otherwise the gate proves a sequence nobody ships. This is the
 * same rule the devrecall gate states about text rewrites: a gate that proves
 * a scratch tree nobody flashes proves the wrong tree.
 *
 * IT ALSO CHECKS THE CURSOR ITSELF, because a chunked build that finishes
 * early is a half-built patch that sounds almost right:
 *   - chunk_step() returns non-zero exactly EB_RECALL_CHUNK_STEPS - 1 times
 *     and then 0, so the number of blocks a patch change costs is bounded and
 *     known rather than "until it stops";
 *   - chunk_busy() is true from begin() until the last step and false after,
 *     so the firmware can refuse to start a note build over a live shadow;
 *   - a step call with no build in progress is a no-op returning 0, so a
 *     stray call cannot half-rebuild a live patch.
 *
 * usage: chunk_gate <boot.bin> <bank64.bin> <template.bin>
 *   env  DEVCRC_NV=8   (must match EBDEV_NV the firmware is built at)
 *
 * TEETH: tools/engineb/chunk_teeth.sh plants five defects and requires each to
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
#include "devchord.h"

/* Two banks for the recall context, plus the reference the monolith fills.
 * The chunk path writes the SHADOW, which with cur=0 is index 1. */
static eb_render_coefs RC_REF, RC_A, RC_B;
static eb_master_coef  MC_REF, MC_A, MC_B;
static eb_render_state RS;
static eb_master_state MS;
static eb_recall       REC;

static unsigned char BANKBUF[EB_DEVSEQ_BANK_BYTES];

static int diff(const void *a, const void *b, size_t n, const char *what,
                int patch)
{
    const unsigned char *x = (const unsigned char *)a;
    const unsigned char *y = (const unsigned char *)b;
    size_t i;
    for (i = 0; i < n; ++i)
        if (x[i] != y[i]) {
            printf("  *** patch %2d %s DIFFERS at byte %u of %u "
                   "(monolith %02x, chunked %02x)\n",
                   patch, what, (unsigned)i, (unsigned)n, x[i], y[i]);
            return 1;
        }
    return 0;
}

int main(int argc, char **argv)
{
    FILE *f;
    unsigned char *boot, *bank64, *tpl;
    long bootn, bankn, tpln;
    unsigned nv = 8;
    int p, bad = 0, steps_seen_bad = 0;
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

    printf("CHUNK GATE  EBDEV_NV=%d  steps/build=%d  "
           "sizeof rc=%u mc=%u\n",
           EBDEV_NV, EB_RECALL_CHUNK_STEPS,
           (unsigned)sizeof(eb_render_coefs), (unsigned)sizeof(eb_master_coef));

    /* cur = 0, so the chunk path writes bank 1. The reference lives outside
     * the context entirely so nothing can alias it. */
    eb_recall_init(&REC, &RC_A, &RC_B, &MC_A, &MC_B, &RS, &MS,
                   (const eb_engine *)0);

    /* A STEP WITH NOTHING IN PROGRESS MUST DO NOTHING. Checked before any
     * build, while the banks are zero: if a stray call built anything, the
     * compare below would pass for the wrong reason. */
    if (eb_recall_chunk_busy(&REC)) {
        printf("  *** chunk_busy() is true before any begin()\n"); ++bad;
    }
    if (eb_recall_chunk_step(&REC) != 0) {
        printf("  *** chunk_step() with no build in progress returned "
               "non-zero -- a stray call can half-rebuild a live patch\n");
        ++bad;
    }

    for (p = 0; p < EB_BANK_COUNT; ++p) {
        int nstep = 0;
        unsigned long miss_ref, miss_chunk;

        /* ---- A: the monolith, from a clean recall of this patch ---------- */
        ebdev_reset_counters();
        if (eb_devseq_boot_cells(boot, nv)) { fprintf(stderr, "boot\n"); return 2; }
        if (eb_devseq_install(BANKBUF, tpl, (size_t)tpln,
                              bank64 + (size_t)p * EB_PATCH_BYTES)) {
            fprintf(stderr, "install %d\n", p); return 2;
        }
        eb_devseq_recall(BANKBUF, 128.0f);
        eb_devseq_notes_on(DEVCHORD_VOICE, DEVCHORD_NOTE, DEVCHORD_VEL,
                           DEVCHORD_N);
        memset(&RC_REF, 0xA5, sizeof RC_REF);   /* poison: a build that skips
                                                 * a field must not inherit a
                                                 * plausible zero */
        memset(&MC_REF, 0xA5, sizeof MC_REF);
        eb_render_coefs_build((const unsigned char *)0, &RC_REF);
        eb_master_coefs_build((const unsigned char *)0, &MC_REF);
        miss_ref = EBDEV_S.miss;

        /* ---- B: the chunked path, through the REAL cursor ---------------- */
        ebdev_reset_counters();
        if (eb_devseq_boot_cells(boot, nv)) return 2;
        if (eb_devseq_install(BANKBUF, tpl, (size_t)tpln,
                              bank64 + (size_t)p * EB_PATCH_BYTES)) return 2;
        eb_devseq_recall(BANKBUF, 128.0f);
        eb_devseq_notes_on(DEVCHORD_VOICE, DEVCHORD_NOTE, DEVCHORD_VEL,
                           DEVCHORD_N);
        memset(&RC_B, 0xA5, sizeof RC_B);
        memset(&MC_B, 0xA5, sizeof MC_B);
        eb_recall_chunk_begin(&REC);
        if (!eb_recall_chunk_busy(&REC)) {
            printf("  *** patch %d: chunk_busy() false right after begin()\n", p);
            ++bad;
        }
        while (eb_recall_chunk_step(&REC)) {
            ++nstep;
            if (nstep > EB_RECALL_CHUNK_STEPS * 4) {
                printf("  *** patch %d: chunk_step() never returned 0 -- the "
                       "cursor does not terminate\n", p);
                return 1;
            }
        }
        if (eb_recall_chunk_busy(&REC)) {
            printf("  *** patch %d: chunk_busy() still true after the last "
                   "step -- the firmware would never start a note build\n", p);
            ++bad;
        }
        miss_chunk = EBDEV_S.miss;

        /* THE COUNT IS PART OF THE CONTRACT. The firmware sizes a program
         * change's latency from it, so "it finished eventually" is not
         * enough -- it must take exactly the advertised number of steps. */
        if (nstep != EB_RECALL_CHUNK_STEPS - 1) {
            printf("  *** patch %d: %d steps returned non-zero, expected %d\n",
                   p, nstep, EB_RECALL_CHUNK_STEPS - 1);
            ++steps_seen_bad;
            ++bad;
        }

        bad += diff(&RC_REF, &RC_B, sizeof RC_REF, "render coefs", p);
        bad += diff(&MC_REF, &MC_B, sizeof MC_REF, "master coefs", p);

        /* A chunked build that touched a cell the monolith did not is a map
         * question, not a coefficient question, and it would be invisible in
         * the byte compare. */
        if (miss_ref != miss_chunk) {
            printf("  *** patch %d: unmapped-cell count differs, monolith %lu "
                   "chunked %lu\n", p, miss_ref, miss_chunk);
            ++bad;
        }
    }

    /* ================= O2: THE NOTE BUILD, EVERY MASK ==================
     * eb_recall_build_voices is what a key press used to call in one lump.
     * The chunked note path must produce the SAME shadow for the SAME mask --
     * over all 256 masks, not the two or three a chord happens to produce,
     * because the allocator's mask is its business and this gate must not
     * assume which bits it sets.
     *
     * It also checks the STEP COUNT: popcount(mask) + 0, because a note owes
     * no shared tail and no master set. A note build that quietly ran the
     * master build would cost 130,000 cycles nobody budgeted. */
    {
        unsigned mask;
        int nmask_bad = 0;
        /* one patch is enough here: the question is whether the chunked note
         * path equals the monolithic one, and that is mask arithmetic, not
         * patch arithmetic. Patch 5 chosen because it is a DELAY TYPE 5 -- the
         * class whose blocks have the least slack. */
        ebdev_reset_counters();
        if (eb_devseq_boot_cells(boot, nv)) return 2;
        if (eb_devseq_install(BANKBUF, tpl, (size_t)tpln,
                              bank64 + (size_t)5 * EB_PATCH_BYTES)) return 2;
        eb_devseq_recall(BANKBUF, 128.0f);
        eb_devseq_notes_on(DEVCHORD_VOICE, DEVCHORD_NOTE, DEVCHORD_VEL,
                           DEVCHORD_N);

        for (mask = 0u; mask < (1u << EB_NUM_VOICES); ++mask) {
            int nstep = 0, want = 0, v;
            for (v = 0; v < EB_NUM_VOICES; ++v)
                if (mask & (1u << v)) ++want;

            /* the live bank must differ from the shadow, or a path that
             * copies and does nothing would pass. Poison the shadow. */
            memset(&RC_B, 0x5A, sizeof RC_B);
            memset(&MC_B, 0x5A, sizeof MC_B);
            memset(&RC_REF, 0x5A, sizeof RC_REF);
            memset(&MC_REF, 0x5A, sizeof MC_REF);

            /* A: the monolith. REC.cur is 0 so the shadow is bank 1 = RC_B. */
            eb_recall_build_voices(&REC, mask);
            RC_REF = RC_B; MC_REF = MC_B;

            /* B: the chunked path, from the same starting shadow. */
            memset(&RC_B, 0x5A, sizeof RC_B);
            memset(&MC_B, 0x5A, sizeof MC_B);
            eb_recall_chunk_begin_voices(&REC, mask);
            if (eb_recall_chunk_steps(&REC) != want) {
                printf("  *** mask %02x: chunk_steps()=%d, expected %d\n",
                       mask, eb_recall_chunk_steps(&REC), want);
                ++bad;
            }
            while (eb_recall_chunk_step(&REC)) {
                if (++nstep > EB_NUM_VOICES * 4) {
                    printf("  *** mask %02x: cursor does not terminate\n", mask);
                    return 1;
                }
            }
            if (eb_recall_chunk_busy(&REC)) {
                printf("  *** mask %02x: still busy after the last step\n", mask);
                ++bad;
            }
            /* steps that RETURNED non-zero is want-1 for a non-empty mask
             * (the last one returns 0), and 0 for an empty mask. */
            if (nstep != (want ? want - 1 : 0)) {
                printf("  *** mask %02x: %d steps ran, expected %d\n",
                       mask, nstep, want ? want - 1 : 0);
                ++nmask_bad; ++bad;
            }
            if (diff(&RC_REF, &RC_B, sizeof RC_REF, "note render coefs",
                     (int)mask)) ++bad;
            if (diff(&MC_REF, &MC_B, sizeof MC_REF, "note master coefs",
                     (int)mask)) ++bad;
        }
        printf("256 masks, chunked note build vs eb_recall_build_voices: %s\n",
               (bad == 0 && nmask_bad == 0) ? "identical" : "DIFFERS");
    }

    /* ============ O2: THE SPLIT PUBLISH -- THE KEY SOUNDS IN TWO BLOCKS =====
     *
     * THE PROBLEM IT SOLVES, measured and stated in b9_held_broadcast.md §4:
     * EB_EV_HELD widens every note's mask to all eight voices, so a chunked
     * note build is 1 + 8 + 1 = TEN BLOCKS = 58 ms between key and sound. The
     * chunking fixed the missed deadlines and created a keyboard nobody can
     * play. Narrowing the mask was tried, gated, and REFUSED (§6-§8).
     *
     * THE FIX, which is option (c) of §6: build the voices the allocator NAMED
     * first, PUBLISH, then build the rest into a SECOND publish. The note
     * sounds after two blocks (~12 ms); the broadcast's effect on the other
     * seven voices arrives up to eight blocks later. THE INVARIANT rule 3
     * exactly -- the change arrives late, the audio never breaks.
     *
     * ⚠ IT ADDS NO NEW PUBLISH PATH, and that is the reason to prefer it. A
     * second chunked build after a publish is the SAME machine on the other
     * bank: begin_voices copies the now-live bank into the new shadow, so the
     * priority voice it just published is carried forward rather than lost.
     *
     * WHAT THIS SECTION PROVES, and neither half is optional:
     *   1. THE END STATE IS UNCHANGED -- the live bank after both publishes is
     *      byte-identical to the live bank after ONE monolithic
     *      eb_recall_build_voices(mask) + publish. If this fails the split has
     *      changed what the instrument computes, not merely when.
     *   2. THE KEY REALLY DOES SOUND EARLY -- the live bank after the FIRST
     *      publish is byte-identical to a monolithic build of the PRIORITY set
     *      alone. Without this the split could pass check 1 while publishing
     *      nothing useful early, which is the whole point defeated silently.
     *
     * OVER EVERY (mask, priority) PAIR, not the few a chord happens to make:
     * for all 256 masks and every SUBSET of each, which is 3^8 = 6,561 pairs.
     * The allocator names one voice usually and two when it steals, but which
     * bits it sets is its business and this gate must not assume.
     *
     * THE PUBLISH RUNS TWICE PER NOTE and that had to be checked rather than
     * assumed, because publish is not a pure function -- step 7b CONSUMES the
     * aux retrigger one-shot out of the cell array. Comparing the RENDER STATE
     * as well as the coefficients is what makes this section see that: a second
     * publish that lost a retrigger, re-latched a delay route differently, or
     * re-seeded a DCO from the wrong bank shows up in RS/MS, not in RC. */
    {
        static ebdev_state    SNAP_CELLS;
        static eb_render_coefs SNAP_A, SNAP_B, LIVE1, LIVEF, REFF;
        static eb_master_coef  SNAP_MA, SNAP_MB, LIVE1M, LIVEFM, REFFM;
        static eb_render_state SNAP_RS, REF_RS, SUB_RS;
        static eb_master_state SNAP_MS, REF_MS, SUB_MS;
        static eb_recall       SNAP_REC;
        unsigned mask, pri;
        long pairs = 0, split_bad = 0, early_bad = 0;

        /* One patch, and patch 5 on purpose: it is the DELAY TYPE 5 whose
         * blocks have the least slack AND the MONO patch whose event set broke
         * the narrowing, so it is the least forgiving input this split has. */
        ebdev_reset_counters();
        if (eb_devseq_boot_cells(boot, nv)) return 2;
        if (eb_devseq_install(BANKBUF, tpl, (size_t)tpln,
                              bank64 + (size_t)5 * EB_PATCH_BYTES)) return 2;
        eb_devseq_recall(BANKBUF, 128.0f);
        /* BOTH BANKS MUST BE POPULATED before any of this means anything: a
         * note build COPIES the live bank, so a trial starting from a zeroed
         * pair would compare two carries of nothing. Build and publish twice. */
        eb_recall_build(&REC); eb_recall_publish(&REC);
        eb_recall_block_boundary(&REC);
        eb_recall_build(&REC); eb_recall_publish(&REC);
        eb_recall_block_boundary(&REC);
        /* ⚠ THE NOTES GO IN AFTER THOSE PUBLISHES, AND THE ORDER IS THE WHOLE
         * POINT. Publish step 7b CONSUMES the aux retrigger one-shot, so a
         * trial that starts with the one-shot already spent cannot tell an
         * idempotent publish from one that destroys what the first publish
         * armed -- which is the single risk the split publish introduces.
         *
         * MEASURED, not reasoned: with the notes applied BEFORE those two
         * publishes, tooth 11 (a publish that clears the retrigger on its
         * second run) WAS NOT CAUGHT. Moving them here is what made it bite.
         * A precondition the gate forgot to set up is a blind gate that reads
         * PASS, and this one read PASS for a whole run. */
        eb_devseq_notes_on(DEVCHORD_VOICE, DEVCHORD_NOTE, DEVCHORD_VEL,
                           DEVCHORD_N);
        /* AND THE RELEASE IS WHAT ACTUALLY ARMS IT. src/juno_note.c:166 says
         * note-ON does NOT arm the DCO retrigger latch, and :255 says each
         * note-OFF arms the released voice's 101504+32v to 1.0. Taking the
         * port at its word rather than assuming a note-on arms everything is
         * the second half of what made tooth 11 bite -- moving the notes after
         * the publishes was not enough on its own. */
        eb_devseq_notes_off(DEVCHORD_VOICE, DEVCHORD_N);

#define SNAPSHOT() do {                                                      \
        SNAP_CELLS = EBDEV_S; SNAP_A = RC_A; SNAP_B = RC_B;                  \
        SNAP_MA = MC_A; SNAP_MB = MC_B;                                      \
        SNAP_RS = RS; SNAP_MS = MS; SNAP_REC = REC;                          \
    } while (0)
#define RESTORE() do {                                                       \
        EBDEV_S = SNAP_CELLS; RC_A = SNAP_A; RC_B = SNAP_B;                   \
        MC_A = SNAP_MA; MC_B = SNAP_MB;                                       \
        RS = SNAP_RS; MS = SNAP_MS; REC = SNAP_REC;                           \
    } while (0)

        SNAPSHOT();

        /* THE SNAPSHOT ITSELF MUST BE HONEST. If restoring did not really put
         * the world back, every comparison below would compare two runs from
         * different starting points and could agree or differ for reasons that
         * have nothing to do with the split. Check it once, out loud -- this is
         * the same defect held_gate.c paid for (b9 §7a). */
        {   static eb_render_coefs T1, T2;
            RESTORE(); eb_recall_build_voices(&REC, 0x0Fu);
            T1 = *REC.rc[1 - REC.cur];
            RESTORE(); eb_recall_build_voices(&REC, 0x0Fu);
            T2 = *REC.rc[1 - REC.cur];
            if (memcmp(&T1, &T2, sizeof T1) != 0) {
                printf("  *** the snapshot does not restore -- two builds from "
                       "the 'same' state differ. Nothing below is evidence.\n");
                ++bad;
            } else {
                printf("split publish: snapshot restores exactly\n");
            }
            RESTORE();
        }

        for (mask = 1u; mask < (1u << EB_NUM_VOICES) && !split_bad
                        && !early_bad; ++mask) {
            /* every non-empty SUBSET of mask, by the standard submask walk */
            for (pri = mask; pri; pri = (pri - 1u) & mask) {
                int nstep;

                /* ---- REFERENCE: one build, one publish ------------------- */
                RESTORE();
                eb_recall_build_voices(&REC, mask);
                if (eb_recall_publish(&REC) != 0) {
                    printf("  *** reference publish refused\n"); ++bad; break;
                }
                eb_recall_block_boundary(&REC);
                REFF = *REC.rc[REC.cur]; REFFM = *REC.mc[REC.cur];
                REF_RS = RS; REF_MS = MS;

                /* ---- REFERENCE 2: the PRIORITY set alone, one publish ----
                 * what the player must be hearing after the first publish. */
                RESTORE();
                eb_recall_build_voices(&REC, pri);
                if (eb_recall_publish(&REC) != 0) { ++bad; break; }
                eb_recall_block_boundary(&REC);
                LIVE1 = *REC.rc[REC.cur]; LIVE1M = *REC.mc[REC.cur];

                /* ---- SUBJECT: the split, through the REAL cursor --------- */
                RESTORE();
                eb_recall_chunk_begin_voices(&REC, pri);
                nstep = 0;
                while (eb_recall_chunk_step(&REC))
                    if (++nstep > EB_NUM_VOICES * 4) {
                        printf("  *** stage 1 cursor does not terminate\n");
                        return 1;
                    }
                if (eb_recall_publish(&REC) != 0) { ++bad; break; }
                eb_recall_block_boundary(&REC);

                /* CHECK 2: the key sounds NOW, with its own voice correct. */
                if (memcmp(&LIVE1, REC.rc[REC.cur], sizeof LIVE1) != 0 ||
                    memcmp(&LIVE1M, REC.mc[REC.cur], sizeof LIVE1M) != 0) {
                    printf("  *** mask %02x pri %02x: after the FIRST publish "
                           "the live bank is NOT the priority build -- the key "
                           "does not sound early, which is the whole point\n",
                           mask, pri);
                    ++early_bad; ++bad; break;
                }

                /* the rest, catching up */
                if (mask & ~pri) {
                    eb_recall_chunk_begin_voices(&REC, mask & ~pri);
                    nstep = 0;
                    while (eb_recall_chunk_step(&REC))
                        if (++nstep > EB_NUM_VOICES * 4) {
                            printf("  *** stage 2 cursor does not terminate\n");
                            return 1;
                        }
                    if (eb_recall_publish(&REC) != 0) { ++bad; break; }
                    eb_recall_block_boundary(&REC);
                }
                LIVEF = *REC.rc[REC.cur]; LIVEFM = *REC.mc[REC.cur];
                SUB_RS = RS; SUB_MS = MS;

                /* CHECK 1: the end state is what the monolith would have. */
                if (memcmp(&REFF, &LIVEF, sizeof REFF) != 0 ||
                    memcmp(&REFFM, &LIVEFM, sizeof REFFM) != 0) {
                    printf("  *** mask %02x pri %02x: the split's FINAL live "
                           "bank differs from the monolithic build -- the "
                           "split changed WHAT is computed, not only when\n",
                           mask, pri);
                    ++split_bad; ++bad; break;
                }
                /* ...INCLUDING the state publish writes. Two publishes instead
                 * of one must not lose a retrigger or re-latch a route. */
                if (memcmp(&REF_RS, &SUB_RS, sizeof REF_RS) != 0) {
                    printf("  *** mask %02x pri %02x: RENDER STATE differs "
                           "after two publishes (gate/aux/dco mirror)\n",
                           mask, pri);
                    ++split_bad; ++bad; break;
                }
                if (memcmp(&REF_MS, &SUB_MS, sizeof REF_MS) != 0) {
                    printf("  *** mask %02x pri %02x: MASTER STATE differs "
                           "after two publishes (delay route / reverb wipe)\n",
                           mask, pri);
                    ++split_bad; ++bad; break;
                }
                ++pairs;
            }
        }
#undef SNAPSHOT
#undef RESTORE
        printf("%ld (mask,priority) pairs, split publish vs monolith: %s\n",
               pairs, (split_bad || early_bad) ? "DIFFERS" : "identical");
    }

    /* ==================== O3: THE SUBSET BUILD (parameter classes) =======
     *
     * eb_recall_chunk_begin_subset(mask, tail, master) is the parameter
     * refresh's engine: re-run only the sub-builders a class needs, carry the
     * rest by the shadow copy. THE CLAIM: for every (mask, tail, master)
     * shape the class table can produce, subset-begin + steps ==
     * copy + the same builders run directly, byte for byte -- AND the step
     * count equals eb_recall_chunk_steps(), because the firmware budgets
     * blocks against that number and a count that lies starves or overruns.
     *
     * All 4 x 256 shapes are cheap, so all are run, not just the 3 shapes the
     * current table happens to contain -- the table is regenerated by a gate
     * and may grow shapes. */
    {
        long shapes = 0;
        int sub_bad = 0, tail, master;
        unsigned mask;

        ebdev_reset_counters();
        if (eb_devseq_boot_cells(boot, nv)) return 2;
        if (eb_devseq_install(BANKBUF, tpl, (size_t)tpln,
                              bank64 + 5u * EB_PATCH_BYTES)) return 2;
        eb_devseq_recall(BANKBUF, 128.0f);
        eb_devseq_notes_on(DEVCHORD_VOICE, DEVCHORD_NOTE, DEVCHORD_VEL,
                           DEVCHORD_N);
        /* a real live bank in cur, poison in the shadow */
        eb_render_coefs_build((const unsigned char *)0, REC.rc[REC.cur]);
        eb_master_coefs_build((const unsigned char *)0, REC.mc[REC.cur]);

        for (tail = 0; tail <= 1 && !sub_bad; ++tail)
        for (master = 0; master <= 1 && !sub_bad; ++master)
        for (mask = 0; mask < 256u && !sub_bad; ++mask) {
            const int shadow = 1 - REC.cur;
            int nstep = 0, v;

            /* the reference: copy, then the same builders, directly */
            RC_REF = *REC.rc[REC.cur];
            MC_REF = *REC.mc[REC.cur];
            for (v = 0; v < EB_NUM_VOICES; ++v)
                if ((mask >> v) & 1u)
                    eb_coefs_voice((const unsigned char *)0, &RC_REF, v);
            if (tail)
                eb_render_coefs_build_shared((const unsigned char *)0, &RC_REF);
            if (master)
                eb_master_coefs_build((const unsigned char *)0, &MC_REF);

            /* the cursor, over poisoned shadow */
            memset(REC.rc[shadow], 0xA5, sizeof *REC.rc[shadow]);
            memset(REC.mc[shadow], 0xA5, sizeof *REC.mc[shadow]);
            eb_recall_chunk_begin_subset(&REC, mask, tail, master);
            while (eb_recall_chunk_step(&REC)) {
                ++nstep;
                if (nstep > EB_RECALL_CHUNK_STEPS * 4) {
                    printf("  *** subset %02x/%d/%d: cursor does not "
                           "terminate\n", mask, tail, master);
                    return 1;
                }
            }
            if (mask == 0u && !tail && !master) {
                /* the empty subset touches nothing, including the copy */
                if (nstep != 0) {
                    printf("  *** empty subset ran %d step(s)\n", nstep);
                    ++sub_bad;
                }
                ++shapes;
                continue;
            }
            ++nstep;   /* the step() call that returned 0 did the last piece */
            if (nstep != eb_recall_chunk_steps(&REC) &&
                eb_recall_chunk_steps(&REC) != 0) {
                /* chunk_steps reads the LIVE fields, which the finished walk
                 * has not cleared -- recompute what it promised at begin */
            }
            {
                int owed = 0;
                for (v = 0; v < EB_NUM_VOICES; ++v)
                    if ((mask >> v) & 1u) ++owed;
                owed += (tail ? 1 : 0) + (master ? 1 : 0);
                if (nstep != owed) {
                    printf("  *** subset %02x/%d/%d: %d steps for %d owed -- "
                           "the count lies to the budget\n",
                           mask, tail, master, nstep, owed);
                    ++sub_bad;
                }
            }
            if (memcmp(REC.rc[shadow], &RC_REF, sizeof RC_REF) != 0 ||
                memcmp(REC.mc[shadow], &MC_REF, sizeof MC_REF) != 0) {
                printf("  *** subset %02x/%d/%d: DIFFERS from the direct "
                       "builders\n", mask, tail, master);
                ++sub_bad;
            }
            ++shapes;
        }
        if (sub_bad) ++bad;
        printf("%ld (mask,tail,master) shapes, subset build vs direct: %s\n",
               shapes, sub_bad ? "DIFFERS" : "identical");
    }

    printf("64 patches, both paths, %u + %u bytes each\n",
           (unsigned)sizeof(eb_render_coefs), (unsigned)sizeof(eb_master_coef));
    printf("CHUNK GATE: %s\n", bad == 0 ? "PASS -- chunked IS monolithic"
                                        : "FAIL");
    return bad == 0 ? 0 : 1;
}

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

    /* ================= O2b: THE NOTE BUILD, EVERY MASK ==================
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

    printf("64 patches, both paths, %u + %u bytes each\n",
           (unsigned)sizeof(eb_render_coefs), (unsigned)sizeof(eb_master_coef));
    printf("CHUNK GATE: %s\n", bad == 0 ? "PASS -- chunked IS monolithic"
                                        : "FAIL");
    return bad == 0 ? 0 : 1;
}

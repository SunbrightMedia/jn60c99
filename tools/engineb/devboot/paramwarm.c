/* paramwarm.c -- O3 STEP 2: IS AN INCREMENTAL PARAMETER EDIT EVEN LEGAL?
 *
 * ⚠ THIS IS THE CORRECTNESS QUESTION, AND IT OUTRANKS THE COST QUESTION.
 * parammap.c asks how much a knob moves. This asks whether the cheap way of
 * moving it produces the RIGHT ANSWER. If it does not, the cost measurement is
 * about a design that cannot ship.
 *
 * WHERE THE DOUBT COMES FROM -- and it is the repo's own warning, not a new
 * worry. engine_b/dev/eb_devseq.h says, of the cold-recall decision:
 *
 *     "THE PRICE, STATED: the port's own order-dependence is then not
 *      reproduced. That is correct for a device whose recall is a program
 *      change and wrong for one that must imitate a DAW's live parameter
 *      edits. When the parameter path (C6) arrives this decision has to be
 *      REVISITED, NOT INHERITED."
 *
 * O3 is that arrival. Today every program change reseeds the cell array from
 * the boot image, so the device's recall is COLD and the host oracle's
 * per-patch CRC is a valid prediction of it. An incremental parameter edit
 * CANNOT reseed -- reseeding is the 2.1 M-cycle burst O3 exists to avoid -- so
 * it necessarily writes on top of live state. That is a WARM path, and
 * docs/engineb/DEVICE_RECALL.md defect (1) measured warm != cold on 24 of 64
 * patches. Whether that gap also opens for a ONE-PARAMETER delta is unmeasured
 * and is exactly what decides O3's shape.
 *
 * THE TEST, which needs no incremental-refresh code to exist yet:
 *
 *   COLD  reseed, install patch P', full recall.            <- the oracle
 *   WARM  reseed, install P, full recall,                   <- the player's
 *         then install P' and recall again WITHOUT reseeding.   real history
 *
 * P' is P with ONE front-panel parameter changed. If COLD == WARM byte for
 * byte for every parameter, then a live edit lands where a cold recall would
 * and the cheap path is legal. Every parameter where they differ is a
 * parameter whose edit CANNOT be done incrementally without reproducing the
 * port's order-dependence -- and that is a finding, not a failure.
 *
 * ⚠ THIS IS A STRICTLY WEAKER TEST THAN THE REAL ONE, AND SAYS SO. It compares
 * two FULL recalls. The shipping path will re-run only a mapped subset, which
 * can only ever differ MORE. So a divergence here is fatal to the cheap
 * design; an agreement here is necessary but not sufficient, and the sufficient
 * gate is the one that drives the actual refresh code once it exists.
 *
 * ⚠ ITEM-7. Nothing here is JUNO. "Does a live edit equal a cold recall of the
 * edited patch" is a question every hoisting port must answer before it offers
 * a knob.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#include "juno_engine.h"
#include "juno_apply.h"
#include "juno_driver.h"
#include "eb_coefs.h"
#include "eb_master_coefs.h"

#define BANK_HEADER  23
#define BANK_STRIDE  20223

static unsigned char *ST;
static eb_render_coefs RC_COLD, RC_WARM;
static eb_master_coef  MC_COLD, MC_WARM;

static void reseed(void)
{
    memset(ST, 0, JUNO_STATE_BYTES);
    juno_chorus_init(ST);
    JF(ST, 16) = 44100.0f;
    juno_engine_init(ST);
    juno_engine_prepare(ST);
}

/* One recall over whatever cell state is already there. Deliberately NOT
 * preceded by a reseed, so the caller decides cold or warm -- which is the
 * entire variable under test. */
static void recall_only(unsigned char *bank, int p)
{
    juno_bank_apply(ST, bank, p);
    juno_driver_seed_voices(ST);
    juno_apply_unison_spread(ST, juno_bank_assign(bank, p));
    juno_apply_condition(ST, juno_bank_condition(bank, p));
    juno_apply_lfo_tempo(ST, juno_bank_lfo_rate_byte(bank, p), 128.0f);
}

/* ⚠ THE FOUR PARAMETERS THAT ARE ORDER-DEPENDENT BY DESIGN.
 *
 * Each was classified by applying the SAME edit twice and finding zero cells
 * still moving: a LATCH, not an accumulation. An accumulation would have made
 * an incremental parameter path impossible; a latch does not.
 *
 *   116  chorus-region latch  (cell 91232)
 *   120  delay-region latch   (cell 102528)
 *   634  EFFECT TYPE -> JUNO_PREV_EFX, read by src/chorus_recall.c:54
 *   650  DELAY  TYPE -> JUNO_PREV_DLY, read by src/delay_recall.c:594
 *
 * ⚠ THE SET IS THE CLAIM, NOT ITS SIZE. This harness first printed a COUNT and
 * called any divergence a failure. Both were wrong. A count cannot see the
 * change that matters: if one parameter became order-dependent while another
 * stopped being so, the count stays 4 and the gate stays green while the
 * instrument has gained a new stale-coefficient path. And a divergence is not
 * a failure -- for a LIVE knob move WARM is the correct answer, because the
 * plugin does not reseed either.
 *
 * So both directions fail, and they are reported apart:
 *   a parameter that JOINS is a new order-dependent path, unclassified;
 *   a parameter that LEAVES means an intended transition stopped firing,
 *   which is a silent loss of behaviour and exactly as serious. */
static const int EXPECT[4] = { 116, 120, 634, 650 };

static int expected(int roff)
{
    int i;
    for (i = 0; i < 4; ++i) if (EXPECT[i] == roff) return 1;
    return 0;
}

int main(int argc, char **argv)
{
    static const unsigned char VAL[4] = { 0x00u, 0x03u, 0x0Cu, 0x7Fu };
    int joined[64], left[64], njoin = 0, nleft = 0;
    unsigned char *bank, *wb;
    unsigned char *base[6];
    long bl;
    FILE *f, *of;
    int b, i, k, ndiff = 0, nparam = 0;
    unsigned s = 7u;

    if (argc < 3) { fprintf(stderr, "usage: paramwarm <bank.bin> <out.tsv>\n");
                    return 2; }
    f = fopen(argv[1], "rb");
    if (!f) { perror(argv[1]); return 2; }
    fseek(f, 0, SEEK_END); bl = ftell(f); fseek(f, 0, SEEK_SET);
    bank = (unsigned char *)malloc((size_t)bl);
    if (fread(bank, 1, (size_t)bl, f) != (size_t)bl) { fclose(f); return 2; }
    fclose(f);

    ST = (unsigned char *)malloc(JUNO_STATE_BYTES);
    wb = (unsigned char *)malloc((size_t)bl);
    memcpy(wb, bank, (size_t)bl);
    for (b = 0; b < 6; ++b) {
        base[b] = wb + BANK_HEADER + (long)(b * 7) * BANK_STRIDE;
        if (b >= 3)
            for (i = 16; i < BANK_STRIDE; ++i) {
                s = s * 1103515245u + 12345u;
                base[b][i] = (unsigned char)((s >> 16) & 0xFF);
            }
    }

    of = fopen(argv[2], "w");
    fprintf(of, "#blob_lo\tblob_hi\tbase\tvalue\trc_diff\tmc_diff\n");

    for (i = 16; i + 1 < 4096; i += 2) {
        int moved_any = 0, diverged = 0;
        for (b = 0; b < 6; ++b) {
            unsigned char o0 = base[b][i], o1 = base[b][i + 1];
            for (k = 0; k < 4; ++k) {
                size_t dr, dm, j;
                const unsigned char *A, *B;
                if (VAL[k] == o0 && VAL[k] == o1) continue;

                /* WARM: the player's real history -- patch P is live, then the
                 * knob moves. No reseed between them. */
                reseed();
                recall_only(wb, b * 7);                  /* patch P */
                base[b][i] = VAL[k]; base[b][i + 1] = VAL[k];
                recall_only(wb, b * 7);                  /* P' over live state */
                eb_render_coefs_build(ST, &RC_WARM);
                eb_master_coefs_build(ST, &MC_WARM);

                /* COLD: what the oracle predicts for P'. */
                reseed();
                recall_only(wb, b * 7);
                eb_render_coefs_build(ST, &RC_COLD);
                eb_master_coefs_build(ST, &MC_COLD);

                base[b][i] = o0; base[b][i + 1] = o1;

                A = (const unsigned char *)&RC_COLD;
                B = (const unsigned char *)&RC_WARM;
                for (dr = 0, j = 0; j < sizeof RC_COLD; ++j)
                    if (A[j] != B[j]) ++dr;
                A = (const unsigned char *)&MC_COLD;
                B = (const unsigned char *)&MC_WARM;
                for (dm = 0, j = 0; j < sizeof MC_COLD; ++j)
                    if (A[j] != B[j]) ++dm;

                moved_any = 1;
                if (dr || dm) {
                    diverged = 1;
                    fprintf(of, "%d\t%d\t%d\t%u\t%lu\t%lu\n", i, i + 1,
                            b, (unsigned)VAL[k],
                            (unsigned long)dr, (unsigned long)dm);
                }
            }
        }
        if (moved_any) ++nparam;
        if (diverged) ++ndiff;
        if (diverged && !expected(i) && njoin < 64) joined[njoin++] = i;
        if (!diverged && expected(i) && nleft < 64) left[nleft++] = i;
    }
    fclose(of);
    printf("WARM-vs-COLD SINGLE-PARAMETER EDIT\n");
    printf("  parameters probed:              %d\n", nparam);
    printf("  order-dependent (WARM != COLD): %d\n", ndiff);
    printf("  expected by name:               4\n");

    for (i = 0; i < njoin; ++i)
        printf("  *** UNEXPECTEDLY order-dependent: record %d ***"
               "  (a new stale-coefficient path; classify it before adding it)\n",
               joined[i]);
    for (i = 0; i < nleft; ++i)
        printf("  *** NO LONGER order-dependent: record %d ***"
               "  (an intended transition stopped firing)\n", left[i]);

    if (!njoin && !nleft) {
        printf("  PASS -- the order-dependent set is exactly the four named,\n");
        printf("          so a live edit is identical to a cold recall for\n");
        printf("          every other parameter. The incremental path is legal.\n");
        return 0;
    }
    printf("  *** FAILED ***\n");
    return 1;
}

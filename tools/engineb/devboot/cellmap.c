/* cellmap.c -- O3 step 2: HOW MANY CELLS DOES ONE KNOB WRITE?
 *
 * ⚠ WHY THIS IS THE QUESTION THAT DECIDES O3'S SECOND HALF.
 *
 * A parameter refresh has two halves. b13 measured the SECOND -- the gather
 * from cells into coefficients -- and found it tiny: a median 32 of 12,276
 * bytes move. The FIRST half is `juno_bank_apply` + the seeds, which turns
 * patch bytes into cells, and the burst split measured it at ~0.24 M cycles on
 * silicon: about 1 ms at 240 MHz, on a block b12 measured already 197 us over
 * period. Narrowing the gather buys nothing while the apply costs that.
 *
 * So: HOW MUCH OF THAT 0.24 M IS WORK THE EDIT ACTUALLY NEEDED? If one knob
 * writes a handful of cells out of the thousands the full apply touches, then
 * the apply is almost entirely redundant recomputation, and a narrowed apply is
 * worth its difficulty. If a knob writes most of them, it is not, and O3's
 * answer must be to SCHEDULE the apply rather than shrink it.
 *
 * ⚠ AND THE DIFFICULTY IS REAL, WHICH IS WHY THIS IS MEASURED BEFORE IT IS
 * ATTEMPTED. `src/` is the FROZEN bit-exact port; juno_bank_apply is
 * transcribed plugin code and `make verify` is its finish line. Decomposing it
 * per parameter means rewriting the one thing in this repo that is proven. This
 * measurement decides whether that is even worth PROPOSING -- it does not
 * license doing it.
 *
 * METHOD. For each parameter the discovery scan names, perturb it over the same
 * 13 bases as parammap.c and diff the whole cell array. The reported count is
 * the UNION over bases and probe values, because under-reporting a dependency
 * is the direction that produces a stale cell and no error.
 *
 * ⚠ THE PROBE IS SAMPLED HERE, AND SAYS SO. parammap.c sweeps all 256 values;
 * this cannot, because each probe costs an 12 MB diff rather than a 12 KB one.
 * The values below include 2, which is not decoration: ASSIGN MODE is live at
 * that value alone and a list without it missed the parameter entirely (b13
 * §3, the third probe defect). A count from this harness is therefore a FLOOR
 * on the cells a parameter can write, and it is labelled as one.
 *
 * ⚠ ITEM-7. Nothing here is JUNO. "How much of the apply does one parameter
 * need" is a question every port that hoists coefficients has to answer before
 * it offers a knob.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#include "juno_engine.h"
#include "juno_apply.h"
#include "juno_driver.h"

#define BANK_HEADER  23
#define BANK_STRIDE  20223
#define NBASE        13

static unsigned char *ST, *S0;

static void full_recall(unsigned char *rec_bank, int p)
{
    memset(ST, 0, JUNO_STATE_BYTES);
    juno_chorus_init(ST);
    JF(ST, 16) = 44100.0f;
    juno_engine_init(ST);
    juno_engine_prepare(ST);

    juno_bank_apply(ST, rec_bank, p);
    juno_driver_seed_voices(ST);
    juno_apply_unison_spread(ST, juno_bank_assign(rec_bank, p));
    juno_apply_condition(ST, juno_bank_condition(rec_bank, p));
    juno_apply_lfo_tempo(ST, juno_bank_lfo_rate_byte(rec_bank, p), 128.0f);
}

int main(int argc, char **argv)
{
    /* 2 is here on purpose -- see the probe note in the header block. */
    static const unsigned char PV[10] = { 0x00u, 0x01u, 0x02u, 0x03u, 0x07u,
                                          0x22u, 0x40u, 0x7Fu, 0xC0u, 0xFFu };
    unsigned char *bank, *wb, *base[NBASE], *moved;
    int bpat[NBASE];
    static unsigned char want[4096];
    long bl;
    FILE *f, *of;
    int b, i, k, nwant = 0, nparam = 0;
    unsigned s = 7u;
    size_t ncell = JUNO_STATE_BYTES / 4u;

    if (argc < 4) {
        fprintf(stderr, "usage: cellmap <bank.bin> <out.tsv> <positions.txt>\n");
        return 2;
    }
    f = fopen(argv[1], "rb");
    if (!f) { perror(argv[1]); return 2; }
    fseek(f, 0, SEEK_END); bl = ftell(f); fseek(f, 0, SEEK_SET);
    bank = (unsigned char *)malloc((size_t)bl);
    if (fread(bank, 1, (size_t)bl, f) != (size_t)bl) { fclose(f); return 2; }
    fclose(f);

    f = fopen(argv[3], "r");
    if (!f) { perror(argv[3]); return 2; }
    while (fscanf(f, "%d", &i) == 1)
        if (i >= 0 && i < 4096) { want[i] = 1u; ++nwant; }
    fclose(f);

    ST = (unsigned char *)malloc(JUNO_STATE_BYTES);
    S0 = (unsigned char *)malloc(JUNO_STATE_BYTES);
    moved = (unsigned char *)malloc(ncell);
    wb = (unsigned char *)malloc((size_t)bl);
    memcpy(wb, bank, (size_t)bl);

    for (b = 0; b < NBASE; ++b) {
        static const int RPAT[3] = { 3, 10, 17 };
        int pat = (b < 10) ? (b * 7) : RPAT[b - 10];
        bpat[b] = pat;
        base[b] = wb + BANK_HEADER + (long)pat * BANK_STRIDE;
        if (b >= 10)
            for (i = 16; i < BANK_STRIDE; ++i) {
                s = s * 1103515245u + 12345u;
                base[b][i] = (unsigned char)((s >> 16) & 0xFF);
            }
    }

    /* The denominator: how many cells a FULL recall writes at all. Without it
     * "a knob writes 40 cells" is a number with nothing to compare it to. */
    {
        size_t nz = 0, c;
        const unsigned char *q;
        memset(ST, 0, JUNO_STATE_BYTES);
        memcpy(S0, ST, JUNO_STATE_BYTES);
        full_recall(wb, 0);
        q = ST;
        for (c = 0; c < ncell; ++c)
            if (memcmp(q + 4 * c, S0 + 4 * c, 4)) ++nz;
        printf("FULL RECALL writes %lu of %lu cells\n",
               (unsigned long)nz, (unsigned long)ncell);
    }

    of = fopen(argv[2], "w");
    fprintf(of, "#rec_lo\trec_hi\tcells_moved\n");
    printf("mapping %d record positions\n", nwant);

    for (i = 16; i + 1 < 4096; i += 2) {
        size_t nmv = 0, c;
        if (!want[i] && !want[i + 1]) continue;
        memset(moved, 0, ncell);
        for (b = 0; b < NBASE; ++b) {
            unsigned char o0 = base[b][i], o1 = base[b][i + 1];
            full_recall(wb, bpat[b]);
            memcpy(S0, ST, JUNO_STATE_BYTES);
            for (k = 0; k < 10; ++k) {
                unsigned char hi = (unsigned char)((PV[k] >> 4) & 0xFu);
                unsigned char lo = (unsigned char)(PV[k] & 0xFu);
                if (hi == (o0 & 0xFu) && lo == (o1 & 0xFu)) continue;
                base[b][i] = hi; base[b][i + 1] = lo;
                full_recall(wb, bpat[b]);
                for (c = 0; c < ncell; ++c)
                    if (!moved[c] && memcmp(ST + 4 * c, S0 + 4 * c, 4))
                        moved[c] = 1u;
            }
            base[b][i] = o0; base[b][i + 1] = o1;
        }
        for (c = 0; c < ncell; ++c) if (moved[c]) ++nmv;
        if (!nmv) continue;
        fprintf(of, "%d\t%d\t%lu\n", i, i + 1, (unsigned long)nmv);
        ++nparam;
    }
    fclose(of);
    printf("PARAMETERS THAT WRITE ANY CELL: %d\n", nparam);
    return 0;
}

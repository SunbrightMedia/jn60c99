/* finefx_port_dump.c — Pillar-3 port-side dumper for the fine-FX exhaustive gate.
 *
 * For a given host rate and fine-FX leaf, sweep the leaf's full record-reachable
 * input domain, apply the PORT's fine-FX law (the SHIPPING appliers in
 * src/finefx_recall.c / src/delay_recall.c), and print the resulting float32 bits
 * at the leaf's coefficient cells. The python driver (finefx_pillar3_gate.py)
 * compares this bit-for-bit against the oracle's own dispatch+snap reference
 * (finefx_cellsweep.pkl), proving APPLIED-PROVEN over the FULL input range.
 *
 * The cell list is supplied on argv by the driver, which reads it from the
 * ORACLE's reference — so the port never curates its own target cells (the
 * Pillar-1/3 anti-circularity rule).
 *
 * usage: finefx_port_dump <rate> <leaf> <cell> [<cell> ...]
 *   prints one line per input value:  <value> <hex(cell0)> <hex(cell1)> ...
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../../src/juno_engine.h"
#include "../../src/finefx_recall.h"
#include "../../src/delay_recall.h"

/* leaf -> (record offset, int1x7? , applier selector) */
typedef struct { int leaf, roff, raw, fam; } LeafSpec;
/* fam: 0=delay_finefx, 1=delay(direct, via juno_apply_delay), 2=chorus_finefx,
 *      3=reverb_finefx */
static const LeafSpec SPECS[] = {
    {1180, 3059, 1, 0}, {1181, 3060, 0, 1}, {1182, 3068, 0, 0}, {1183, 3076, 0, 0},
    {1184, 3084, 0, 0}, {1185, 3092, 0, 0},
    {1210, 3286, 1, 2}, {1211, 3287, 1, 2}, {1212, 3288, 1, 2},
    {1324, 3948, 1, 3}, {1325, 3949, 1, 3}, {1326, 3950, 1, 3}, {1327, 3951, 0, 3},
};

static void set_input(unsigned char *rec, const LeafSpec *s, int val)
{
    if (s->raw) {                 /* int1x7: single raw byte */
        rec[s->roff] = (unsigned char)val;
    } else {                      /* int2x4 / int8x4: nibble pair */
        rec[s->roff]     = (unsigned char)((val >> 4) & 0xF);
        rec[s->roff + 1] = (unsigned char)(val & 0xF);
    }
}

int main(int argc, char **argv)
{
    if (argc < 4) { fprintf(stderr, "usage: %s <rate> <leaf> <cell>...\n", argv[0]); return 2; }
    int rate = atoi(argv[1]);
    int leaf = atoi(argv[2]);
    int ncells = argc - 3;
    int *cells = malloc(sizeof(int) * ncells);
    for (int i = 0; i < ncells; i++) cells[i] = atoi(argv[3 + i]);

    const LeafSpec *s = NULL;
    for (unsigned i = 0; i < sizeof(SPECS)/sizeof(SPECS[0]); i++)
        if (SPECS[i].leaf == leaf) { s = &SPECS[i]; break; }
    if (!s) { fprintf(stderr, "unknown leaf %d\n", leaf); return 2; }

    /* int1x7 record byte spans 0..255 (masked &0x7F by the applier); nibble-pair
     * value spans 0..255. Sweep the full byte space either way. */
    int nval = 256;
    unsigned char *st  = calloc(1, JUNO_STATE_BYTES);
    unsigned char *rec = calloc(1, 8192);

    for (int v = 0; v < nval; v++) {
        /* fresh state each value so no cross-value contamination */
        memset(st, 0, JUNO_STATE_BYTES);
        JF(st, 16) = (float)rate;           /* host rate cell the port reads     */
        memset(rec, 0, 8192);
        /* seed the record's other fine-FX defaults so the applier's non-target
         * cells are well-defined (target cells depend only on the swept input). */
        set_input(rec, s, v);
        switch (s->fam) {
            case 0: juno_apply_delay_finefx(st, rec, rate); break;
            case 1: {
                /* DELAY DIRECT LEVEL (102512 = rec_byte(3060)/255) lives in the
                 * integrated delay recall; drive a minimal DELAY TYPE 0 record. */
                rec[650] = 0; rec[651] = 0;             /* DELAY TYPE 0 (nibble)  */
                juno_apply_delay(st, rec);
                break;
            }
            case 2: juno_apply_chorus_finefx(st, rec, rate); break;
            case 3: juno_apply_reverb_finefx(st, rec, rate); break;
        }
        printf("%d", v);
        for (int i = 0; i < ncells; i++) {
            unsigned int b; float f = JF(st, cells[i]); memcpy(&b, &f, 4);
            printf(" %08x", b);
        }
        printf("\n");
    }
    free(cells); free(st); free(rec);
    return 0;
}

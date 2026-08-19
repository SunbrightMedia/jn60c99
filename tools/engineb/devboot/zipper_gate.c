/* zipper_gate.c -- O3 phase 2: MEASURE THE ZIPPER, DO NOT LISTEN FOR IT.
 *
 * THE QUESTION. O3 ships as "full apply + mapped gather, rate-limited to one
 * refresh every N blocks" (b13 §5). N sets the knob's refresh rate: 172/N Hz.
 * Too coarse and a filter sweep steps audibly -- zipper noise. The usual way to
 * pick N is to listen. END_GOAL FORBIDS THAT: never validate by ear, never ask
 * the user to A/B. So the zipper must be a NUMBER.
 *
 * THE METHOD. Render the same knob sweep twice through the SAME engine:
 *
 *   REFERENCE  the parameter re-applied every block (N=1). This is the finest
 *              update the instrument can realize -- a knob event arrives at
 *              most once per block through the O1 queue, so N=1 is not an
 *              approximation of the plugin, it IS the port's best case.
 *   CANDIDATE  the parameter re-applied every N blocks, value HELD between
 *              refreshes -- exactly what the rate-limited refresh does.
 *
 * The residual between them, in dB relative to the reference, IS the zipper.
 * Reported per N over a full bottom-to-top sweep of the most audible
 * parameter class (a filter-region byte swept over its range), on real factory
 * patches, with a note held so the sweep passes through sounding audio.
 *
 * ⚠ WHAT THIS DOES NOT DECIDE. It gives THE CURVE residual-vs-N; it does not
 * pick the acceptable point on it. That number is the user's (F2 is the only
 * remaining judge). The gate's own PASS is structural, not aesthetic:
 *   - N=1 vs N=1 must be EXACTLY 0 (the harness nulls against itself), and
 *   - the residual must be MONOTONIC in N (a coarser refresh cannot get
 *     closer to the reference; if it does, the harness is broken, not good).
 *
 * ⚠ RENDER PATH. This drives the PORT (src/) through the standalone shim,
 *   which is the trunk's proven render entry: engine B renders the voices and
 *   the port's master stage finishes the sample, nulled EXACTLY 0 against the
 *   port by make engineb. Coefficients rebuild when eb_coef_gen bumps; the
 *   shim does that check per sample, so "apply at block k" is realized by
 *   bumping the generation at that block boundary -- the same contract the
 *   device's publish has.
 *
 * ⚠ ITEM-7. Nothing here is JUNO but the parameter list in the runner script.
 *   "How coarse may a held-and-stepped parameter be before it diverges from
 *   per-block" is a question every rate-limited control path must answer.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "juno_engine.h"
#include "juno_apply.h"
#include "juno_driver.h"
#include "juno_note.h"

#define BANK_HEADER  23
#define BANK_STRIDE  20223
#define SR           44100
#define BLK          256              /* the device's block, samples */
#define NBLK         344              /* ~2.0 s sweep */
#define NSA          (BLK * NBLK)

static unsigned char *ST;

/* The shim's context reset. Without it engine B's static render state carries
 * from one sweep into the next and the N=1 self-null FAILS -- which is exactly
 * what it did on this harness's first run, and why the structural PASS
 * condition exists. */
void ebsh_new_context(void);

/* The coefficient generation counter. Owned by gui/juno_bridge.c in the GUI
 * build; here the harness owns it, and BUMPS IT AFTER EVERY APPLY so the
 * standalone shim rebuilds engine B's coefficients at exactly the block the
 * refresh landed -- the same generation contract the device's publish has. */
unsigned long eb_coef_gen = 1;

static void boot_and_recall(unsigned char *bank, int p)
{
    memset(ST, 0, JUNO_STATE_BYTES);
    juno_chorus_init(ST);
    JF(ST, 16) = (float)SR;
    juno_engine_init(ST);
    juno_engine_prepare(ST);
    juno_bank_apply(ST, bank, p);
    juno_driver_seed_voices(ST);
    juno_apply_unison_spread(ST, juno_bank_assign(bank, p));
    juno_apply_condition(ST, juno_bank_condition(bank, p));
    juno_apply_lfo_tempo(ST, juno_bank_lfo_rate_byte(bank, p), 128.0f);
}

/* One rendered sweep. `n` = refresh period in blocks. The knob moves linearly
 * from 0 to 255 across the sweep; at a refresh block the CURRENT value is
 * applied, between refreshes it is HELD -- the exact behaviour of the
 * rate-limited path. The unused values are not dropped; they are simply
 * superseded, which is what a knob does. */
static void sweep(unsigned char *bank, int p, int roff, int n, float *outL)
{
    unsigned char *blob;
    int b, i;
    float r;

    /* ⚠ THE SWEEP OWNS ITS STARTING VALUE. The first version mutated the bank
     * and never restored it, so the NEXT sweep booted from the PREVIOUS
     * sweep's final knob position -- its cold recall ran at value 255 and the
     * block-0 apply then stepped to 0. The N=1 self-null caught it: two
     * "identical" sweeps differed by -6.8 dB. Write the first value BEFORE the
     * boot recall, so every sweep starts from the same instrument. */
    blob = bank + BANK_HEADER + (long)p * BANK_STRIDE + 16;
    blob[roff - 16] = 0u; blob[roff - 16 + 1] = 0u;
    ebsh_new_context();
    boot_and_recall(bank, p);
    ++eb_coef_gen;
    juno_note_on(ST, 0, 48, 100);
    juno_note_on(ST, 1, 55, 100);
    juno_note_on(ST, 2, 60, 100);

    for (b = 0; b < NBLK; ++b) {
        if (b % n == 0) {
            int val = (int)((255.0 * b) / (NBLK - 1));
            blob[roff - 16]     = (unsigned char)((val >> 4) & 0xF);
            blob[roff - 16 + 1] = (unsigned char)(val & 0xF);
            /* the full apply, as the shipping path does -- the warm path
             * paramwarm.c proved lands where a cold recall would */
            juno_bank_apply(ST, bank, p);
            ++eb_coef_gen;
        }
        for (i = 0; i < BLK; ++i)
            (void)juno_driver_render_sample(ST, &outL[b * BLK + i], &r);
    }
}

int main(int argc, char **argv)
{
    static const int NS[6] = { 1, 2, 4, 8, 11, 22 };
    unsigned char *bank;
    float *ref, *cur;
    long bl;
    FILE *f;
    int p, roff, k, i, bad = 0;
    double prev;

    if (argc < 4) {
        fprintf(stderr, "usage: zipper_gate <bank.bin> <patch> <record_off>\n");
        return 2;
    }
    f = fopen(argv[1], "rb");
    if (!f) { perror(argv[1]); return 2; }
    fseek(f, 0, SEEK_END); bl = ftell(f); fseek(f, 0, SEEK_SET);
    bank = (unsigned char *)malloc((size_t)bl);
    if (fread(bank, 1, (size_t)bl, f) != (size_t)bl) { fclose(f); return 2; }
    fclose(f);
    p = atoi(argv[2]); roff = atoi(argv[3]);

    ST  = (unsigned char *)malloc(JUNO_STATE_BYTES);
    ref = (float *)malloc((size_t)NSA * sizeof(float));
    cur = (float *)malloc((size_t)NSA * sizeof(float));

    sweep(bank, p, roff, 1, ref);
    {
        double q = 0.0;
        for (i = 0; i < NSA; ++i) q += (double)ref[i] * ref[i];
        printf("patch %d record %d: reference sweep rms %.1f dBFS\n",
               p, roff, 10.0 * log10(q / NSA));
        if (q <= 0.0) { printf("*** SILENT REFERENCE -- the sweep drives "
                               "nothing audible, pick another patch ***\n");
                        return 1; }
    }

    printf("%-4s %-9s %s\n", "N", "rate", "residual vs N=1");
    prev = -1e30;
    {
        /* ⚠ THE SWEEP MUST BE SEEN TO ACT. Three of the first four parameters
         * tried produced ZERO differing samples at every N -- the knob moved
         * coefficients that this driving never renders audibly (an envelope
         * rate after the attack has passed, a stage the patch bypasses). A
         * curve of -999 dB is not "no zipper", it is "this measurement cannot
         * see its subject", and it must fail rather than reassure. The check:
         * the CANDIDATE sweeps below must differ from the reference somewhere,
         * or the run is INAUDIBLE and proves nothing about this parameter. */
        int any = 0;
        for (k = 0; k < 6; ++k) if (NS[k] != 1) { any = 1; break; }
        (void)any;
    }
    { int audible = 0;
    for (k = 0; k < 6; ++k) {
        double s = 0.0, q = 0.0, db;
        int nd = 0;
        sweep(bank, p, roff, NS[k], cur);
        for (i = 0; i < NSA; ++i) {
            double d = (double)cur[i] - ref[i];
            s += d * d; q += (double)ref[i] * ref[i];
            if (cur[i] != ref[i]) ++nd;
        }
        if (NS[k] == 1) {
            printf("%-4d %-9s %s\n", 1, "172 Hz",
                   nd ? "*** NOT EXACTLY 0 -- harness broken ***" : "EXACTLY 0");
            if (nd) bad = 1;
            continue;
        }
        db = (s > 0.0 && q > 0.0) ? 10.0 * log10(s / q) : -999.0;
        printf("%-4d %3.0f Hz    %.1f dB rel  (%d/%d samples differ)\n",
               NS[k], 172.4 / NS[k], db, nd, NSA);
        /* monotonic in N: coarser must not be closer */
        if (db < prev - 0.5) {
            printf("*** NON-MONOTONIC at N=%d -- the harness cannot be "
                   "trusted ***\n", NS[k]);
            bad = 1;
        }
        prev = db;
        if (nd) audible = 1;
    }
    if (!audible) {
        printf("*** INAUDIBLE: no N produced a single differing sample. This\n"
               "    driving cannot see this parameter -- the result proves\n"
               "    NOTHING about it. Not a pass. ***\n");
        return 1;
    }
    return bad; }
}

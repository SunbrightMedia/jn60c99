/* parammap.c -- O3 STEP 1: DERIVE THE PARAMETER -> COEFFICIENT MAP.
 *
 * ⚠ THIS IS A MEASUREMENT, NOT A FEATURE. It is deliberately built and run
 * BEFORE any incremental-refresh code exists, because the whole O3 design
 * hangs on a number nobody in this repo has ever measured: WHEN ONE KNOB
 * MOVES, HOW MUCH OF THE COEFFICIENT SET ACTUALLY CHANGES?
 *
 * FINAL_GUIDE's C9 section asserts "a cutoff knob is a few fields, not eight
 * voices and the FX chain". That is an ARGUMENT, not a measurement, and this
 * project has a playbook entry (46) for exactly that: a number quoted N times
 * is not thereby measured. If it is right, O3 is a small map and a cheap
 * refresh. If it is wrong -- if the median knob moves most of the struct --
 * then the map buys nothing and O3 must instead reuse O2's chunked rebuild
 * with no map at all. Those are different projects, and the difference is
 * decided here.
 *
 * THE DECISION RULE, STATED BEFORE THE MEASUREMENT (playbook 11b):
 *
 *   Let F = median over parameters of (coefficient bytes moved) / (struct
 *   bytes total), counting eb_render_coefs and eb_master_coef together.
 *
 *     F <  10%   -> build the map. The incremental refresh is worth its
 *                   complexity and O3 proceeds as C9 describes.
 *     F >  50%   -> DO NOT build the map. Reuse O2: chunk the full rebuild
 *                   and publish late. O3 becomes a scheduling change, not a
 *                   dependency analysis.
 *     10-50%     -> build the map ONLY for the parameters under 10%, and fall
 *                   back to the chunked full rebuild for the rest. Report the
 *                   split; a two-path design must be justified by its own
 *                   numbers, not chosen because both were available.
 *
 * ⚠ WHY PERTURBATION AND NOT READING THE CODE. eb_coefs.c is a pure cell
 * gather -- CF(base, offset) into a struct field -- so one COULD read the
 * offsets out of it. That would map CELLS to FIELDS and stop there, missing
 * the half that matters: juno_bank_apply turns a patch byte into cells through
 * curves, products and clamps, and which cells it touches is not visible in
 * eb_coefs.c at all. Perturbation measures the WHOLE chain, patch byte to
 * coefficient field, which is the only chain the player's knob actually runs.
 *
 * METHOD, borrowed wholesale from gate.c's proven scan_section():
 *   - SIX base patches: three factory, three with every nibble randomised. A
 *     parameter can be gated by another parameter no factory patch moves
 *     (DELAY TYPE 4 is this repo's standing example), so the factory bank
 *     alone under-reports.
 *   - FOUR probe values per parameter, not one. A single probe can land on the
 *     same clamped result as the original -- BEND GAIN's index clamp is that
 *     trap, and it is why the compact format shipped short twice.
 *   - The moved-byte set is the UNION over bases and values. Under-reporting a
 *     dependency is the dangerous direction: it produces a stale coefficient
 *     and no error, which is the single defect shape this project has paid for
 *     most.
 *
 * ⚠ ITEM-7. Nothing here knows what a JUNO parameter means. It is given a
 * record-position list and two structs and reports byte deltas. The parameter
 * NAMES are printed from a table that lives in the analysis script, not here.
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
#include "eb_patch.h"

#define BANK_HEADER  23
#define BANK_STRIDE  20223

static unsigned char *ST;
static eb_render_coefs RC, RC0;
static eb_master_coef  MC_, MC0;

/* One full cold recall, exactly gate.c's scan_build() order. Any divergence
 * here would make the map a map of something other than what the device runs,
 * so it is copied rather than paraphrased. */
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

    eb_render_coefs_build(ST, &RC);
    eb_master_coefs_build(ST, &MC_);
}

/* Mark every byte that differs. `moved` is the running UNION -- see the header
 * note on why under-reporting is the dangerous direction. */
static void mark(unsigned char *moved, const void *a, const void *b,
                 size_t n, size_t off)
{
    const unsigned char *p = (const unsigned char *)a;
    const unsigned char *q = (const unsigned char *)b;
    size_t i;
    for (i = 0; i < n; ++i)
        if (p[i] != q[i]) moved[off + i] = 1u;
}

int main(int argc, char **argv)
{
    /* ⚠ THE PROBE SET, AND THE DEFECT THAT SIZED IT. The first version of this
     * harness wrote ONE value into BOTH nibbles of the pair, reusing gate.c's
     * four single-byte probes. That can only ever produce the parameter values
     * {0x00, 0x33, 0xCC, 0xFF} -- four of 256 -- and it MISSED record 3286-3288
     * (CHORUS PRE DELAY / LOW CUT / HIGH CUT), which the proven single-byte
     * scan in gate.c does find. Caught by comparing this harness's output
     * against EB_RECALL_POS[] rather than by trusting it.
     *
     * That is the exact trap eb_patch.h names -- "a single probe value can land
     * on the same clamped result as the original" -- and coupling the nibbles
     * made it worse, not better. So the sweep is now over PARAMETER VALUES with
     * the nibbles set independently, AND each byte is probed alone as gate.c
     * does. The reported set is the UNION of all of it: under-reporting a
     * dependency yields a stale coefficient and no error, so every doubt is
     * resolved in the direction of reporting more. */
    static const unsigned char PVAL[12] = {
        0x00u, 0x01u, 0x03u, 0x07u, 0x0Fu, 0x10u,
        0x33u, 0x55u, 0x7Fu, 0xA5u, 0xCCu, 0xFFu };
    static const unsigned char VAL[4] = { 0x00u, 0x03u, 0x0Cu, 0x7Fu };
    const size_t NRC = sizeof(eb_render_coefs);
    const size_t NMC = sizeof(eb_master_coef);
    const size_t NTOT = NRC + NMC;
    unsigned char *bank, *wb, *moved;
    unsigned char *base[6];
    unsigned char *OWN[EB_NUM_VOICES];
    long bl;
    FILE *f, *of;
    int b, i, k, v, nparam = 0;
    unsigned s = 7u;

    if (argc < 3) { fprintf(stderr, "usage: parammap <bank.bin> <out.tsv>\n");
                    return 2; }

    f = fopen(argv[1], "rb");
    if (!f) { perror(argv[1]); return 2; }
    fseek(f, 0, SEEK_END); bl = ftell(f); fseek(f, 0, SEEK_SET);
    bank = (unsigned char *)malloc((size_t)bl);
    if (fread(bank, 1, (size_t)bl, f) != (size_t)bl) { fclose(f); return 2; }
    fclose(f);

    ST = (unsigned char *)malloc(JUNO_STATE_BYTES);
    wb = (unsigned char *)malloc((size_t)bl);
    moved = (unsigned char *)malloc(NTOT);
    memcpy(wb, bank, (size_t)bl);

    for (b = 0; b < 6; ++b) {
        base[b] = wb + BANK_HEADER + (long)(b * 7) * BANK_STRIDE;
        if (b >= 3)
            for (i = 16; i < BANK_STRIDE; ++i) {
                s = s * 1103515245u + 12345u;
                base[b][i] = (unsigned char)((s >> 16) & 0xFF);
            }
    }

    /* A real recall first, so ownership is measured over realistic cell
     * values rather than an all-zero state. The two-fill method would survive
     * a zeroed state anyway; this removes the need to argue that it does. */
    full_recall(wb, 0);

    /* ---- OWN[v]: the bytes eb_coefs_voice() writes for voice v -----------
     * Two fills, because a byte the builder writes could happen to equal one
     * fill value and would then look untouched. A byte that survives BOTH
     * fills unchanged is one the builder genuinely does not write. */
    {
        static eb_render_coefs probe;
        int fill;
        for (v = 0; v < EB_NUM_VOICES; ++v) {
            OWN[v] = (unsigned char *)calloc(NRC, 1);
            for (fill = 0; fill < 2; ++fill) {
                unsigned char fv = fill ? 0xFFu : 0x00u;
                const unsigned char *pp = (const unsigned char *)&probe;
                memset(&probe, fv, sizeof probe);
                eb_coefs_voice(ST, &probe, v);
                for (k = 0; (size_t)k < NRC; ++k)
                    if (pp[k] != fv) OWN[v][k] = 1u;
            }
        }
    }

    of = fopen(argv[2], "w");
    fprintf(of, "#blob_lo\tblob_hi\tmoved_bytes\ttotal_bytes\trc_bytes\tmc_bytes\tvoice_mask\n");
    printf("PARAMETER MAP: eb_render_coefs=%lu B  eb_master_coef=%lu B"
           "  total=%lu B\n", (unsigned long)NRC, (unsigned long)NMC,
           (unsigned long)NTOT);

    /* A front-panel parameter is a NIBBLE PAIR (eb_patch.h): parameter p is at
     * record 16+2p, i.e. blob 2p and 2p+1. Both bytes move together because a
     * knob writes a value, not half of one -- perturbing only one nibble would
     * measure a parameter the instrument cannot produce. */
    for (i = 16; i + 1 < 4096; i += 2) {
        size_t nmv = 0, nrc = 0, nmc = 0;
        unsigned vmask = 0u;
        int any = 0;

        memset(moved, 0, NTOT);
        for (b = 0; b < 6; ++b) {
            unsigned char o0 = base[b][i], o1 = base[b][i + 1];
            full_recall(wb, b * 7);
            memcpy(&RC0, &RC, sizeof RC);
            memcpy(&MC0, &MC_, sizeof MC_);
            /* (a) the parameter's own value range, nibbles independent */
            for (k = 0; k < 12; ++k) {
                unsigned char hi = (unsigned char)((PVAL[k] >> 4) & 0xFu);
                unsigned char lo = (unsigned char)(PVAL[k] & 0xFu);
                if (hi == (o0 & 0xFu) && lo == (o1 & 0xFu)) continue;
                base[b][i] = hi; base[b][i + 1] = lo;
                full_recall(wb, b * 7);
                mark(moved, &RC0, &RC, NRC, 0);
                mark(moved, &MC0, &MC_, NMC, NRC);
            }
            base[b][i] = o0; base[b][i + 1] = o1;
            /* (b) each byte alone, exactly gate.c's proven probe. A pair sweep
             * and a single-byte sweep can each see what the other cannot. */
            for (k = 0; k < 4; ++k) {
                if (VAL[k] != o0) {
                    base[b][i] = VAL[k];
                    full_recall(wb, b * 7);
                    mark(moved, &RC0, &RC, NRC, 0);
                    mark(moved, &MC0, &MC_, NMC, NRC);
                    base[b][i] = o0;
                }
                if (VAL[k] != o1) {
                    base[b][i + 1] = VAL[k];
                    full_recall(wb, b * 7);
                    mark(moved, &RC0, &RC, NRC, 0);
                    mark(moved, &MC0, &MC_, NMC, NRC);
                    base[b][i + 1] = o1;
                }
            }
        }

        for (k = 0; (size_t)k < NTOT; ++k)
            if (moved[k]) { ++nmv; if ((size_t)k < NRC) ++nrc; else ++nmc; }
        if (!nmv) continue;
        any = 1; (void)any;

        /* WHICH VOICES -- DERIVED BY CONSTRUCTION, NOT FROM A FIELD LIST.
         *
         * An earlier version scanned only RC.env[v] and called the result a
         * voice mask. It was not one: it reported "no env bytes moved", which
         * is a different statement, and 48 of 56 parameters came back 0 because
         * of it. A column that reports something other than its name is the
         * defect class this project punishes hardest, so it is now measured.
         *
         * OWN[v] is the byte set eb_coefs_voice() itself writes for voice v --
         * obtained by running the real builder over two different fills, since
         * a written byte can coincide with one fill but not both. This needs no
         * list of per-voice fields, so it stays correct when the struct changes
         * and carries to any port (item 7). */
        for (v = 0; v < EB_NUM_VOICES; ++v) {
            for (k = 0; (size_t)k < NRC; ++k)
                if (OWN[v][k] && moved[k]) { vmask |= (1u << v); break; }
        }

        fprintf(of, "%d\t%d\t%lu\t%lu\t%lu\t%lu\t%u\n",
                i, i + 1, (unsigned long)nmv, (unsigned long)NTOT,
                (unsigned long)nrc, (unsigned long)nmc, vmask);
        ++nparam;
    }
    fclose(of);
    printf("PARAMETERS THAT MOVE ANY COEFFICIENT: %d\n", nparam);
    return 0;
}

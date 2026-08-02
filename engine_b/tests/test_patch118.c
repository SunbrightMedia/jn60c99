/* test_patch118.c — the parameter path.
 *
 * Three questions, all answered against the real factory bank:
 *
 *   1. ROUND TRIP. Extract the compact bytes, write them into patch 0's record as
 *      a template, and the reconstructed record must be byte-identical to the
 *      original on every one of them, for 64/64 patches.
 *
 *   2. COVERAGE. Does the byte set actually carry every parameter engine B
 *      READS? This is a different question from 1, and it is the one the format
 *      had never been asked. A byte set derived by hashing audio cells can miss a
 *      parameter whose effect the probe was blind to -- and MEASURED this
 *      session, the documented 118-byte set misses three
 *      (tools/engineb/patch_roundtrip.py is the render-level gate).
 *
 *   3. NON-VACUITY. A decoder that returned zeros would pass 1 and 2. So the
 *      decoded parameters must actually VARY across the bank, and the count of
 *      parameters that are identical in all 64 patches is printed.
 *
 *   cc -std=c99 -O2 -I.. -o t test_patch118.c ../eb_patch.c && ./t <bank.bin>
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "eb_patch.h"

#define REC 20223

int main(int argc, char **argv)
{
    const char *path = argc > 1 ? argv[1] : "truth/presetbankog1.bin";
    FILE *f = fopen(path, "rb");
    unsigned char *bank, *tpl, *rec;
    long len;
    int p, i, fails = 0, rt_bad = 0;
    static eb_patch pk[EB_BANK_COUNT];
    static eb_params pm[EB_BANK_COUNT];

    if (!f) { f = fopen("../truth/presetbankog1.bin", "rb"); }
    if (!f) { f = fopen("../../truth/presetbankog1.bin", "rb"); }
    if (!f) { printf("FAIL: cannot open the bank (%s)\n", path); return 2; }
    fseek(f, 0, SEEK_END); len = ftell(f); fseek(f, 0, SEEK_SET);
    bank = malloc((size_t)len);
    if (fread(bank, 1, (size_t)len, f) != (size_t)len) { printf("FAIL: short read\n"); return 2; }
    fclose(f);

    if (eb_patch_selftest()) { printf("FAIL: eb_patch table self-test\n"); fails++; }

    /* ---- 1. round trip -------------------------------------------------- */
    tpl = bank + 23;                                  /* patch 0's record     */
    rec = malloc(REC);
    for (p = 0; p < EB_BANK_COUNT; ++p) {
        const unsigned char *orig = bank + 23 + (size_t)REC * p;
        if (eb_patch_extract(bank, (size_t)len, p, &pk[p])) {
            printf("FAIL: extract patch %d\n", p); fails++; continue;
        }
        memcpy(rec, tpl, REC);
        eb_patch_install(rec, &pk[p]);
        for (i = 0; i < EB_PATCH_BYTES; ++i) {
            int off = 16 + (int)eb_patch_offsets[i];
            if (rec[off] != orig[off]) {
                rt_bad++;
                printf("FAIL: patch %d blob %d: %02x != %02x\n",
                       p, (int)eb_patch_offsets[i], rec[off], orig[off]);
                fails++;
            }
        }
    }
    printf("round trip: %d/%d patches reproduce all %d live bytes\n",
           EB_BANK_COUNT - rt_bad, EB_BANK_COUNT, EB_PATCH_BYTES);

    /* ---- 2. coverage ---------------------------------------------------- */
    {
        int miss[64], n = eb_patch_coverage(miss, 64);
        const char *un[64]; int u = eb_patch_unresolved(un, 64);
        printf("coverage: %d parameter(s) engine B reads are NOT carried by the "
               "compact format\n", n);
        for (i = 0; i < n && i < 64; ++i)
            printf("    MISSING  record %4d  %s\n", miss[i],
                   eb_patch_name_of(miss[i]));
        printf("unresolved: %d parameter(s) whose blob position engine B has not "
               "derived (never guessed)\n", u);
        for (i = 0; i < u && i < 64; ++i) printf("    UNRESOLVED  %s\n", un[i]);
        /* MISSING is a defect in the format and is FAILED here. UNRESOLVED is
         * work not yet done and is reported, not failed -- failing it would make
         * this test red for the whole of engine B's construction and it would be
         * ignored, which is worse than a number that is printed every run. */
        if (n) fails++;
    }

    /* ---- 3. non-vacuity ------------------------------------------------- */
    {
        int nvar = 0, nconst = 0, nfields = (int)sizeof(eb_params);
        for (p = 0; p < EB_BANK_COUNT; ++p) eb_patch_decode(&pk[p], &pm[p], 0, 0);
        for (i = 0; i < nfields; ++i) {
            int v0 = ((const unsigned char *)&pm[0])[i], varies = 0;
            for (p = 1; p < EB_BANK_COUNT; ++p)
                if (((const unsigned char *)&pm[p])[i] != v0) { varies = 1; break; }
            if (varies) nvar++; else nconst++;
        }
        printf("non-vacuity: %d of %d decoded parameter bytes VARY across the 64 "
               "factory patches (%d constant)\n", nvar, nfields, nconst);
        if (nvar < 10) {
            printf("FAIL: the decoder is not reading the bank\n"); fails++;
        }
        printf("patch 0: cutoff %d res %d hpf %d env1 A/D/S/R %d/%d/%d/%d "
               "vca %d chorus %d cond %d\n",
               pm[0].vcf_freq, pm[0].vcf_res, pm[0].hpf, pm[0].env1_a,
               pm[0].env1_d, pm[0].env1_s, pm[0].env1_r, pm[0].vca_level,
               pm[0].chorus_mode, pm[0].condition);
    }

    printf("%s\n", fails ? "PARAMETER PATH: FAIL" : "PARAMETER PATH: PASS");
    return fails ? 1 : 0;
}

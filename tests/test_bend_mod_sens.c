/* test_bend_mod_sens.c — guard for BEND/MOD SENS recall (juno_apply.c
 * apply_bend_mod_sens), derived bit-exact from the plugin's per-voice recompute
 * thunks (scratchpad/oracle/bendmod_recall_spec.md):
 *   4128 (bend depth DCO) = curve22(BEND SENS DCO) * curve4(BEND RANGE) * mode(BEND GAIN)
 *   7472 (bend depth VCF) = curve22(BEND SENS VCF) * curve4(BEND RANGE) * mode(BEND GAIN)
 *   3984 (mod  depth DCO) = curve22(MOD SENS DCO)
 *   7360 (mod  depth VCF) = curve22(MOD SENS VCF) * 10.0
 *   mode(gain) = {1:2, 2:3, 3:4, else:1}
 * Record bytes: BEND SENS DCO 514, VCF 522, MOD SENS DCO 530, VCF 538, BEND GAIN 506;
 * BEND RANGE is front-panel blob 57. The golden test can't cover these (its 222-byte
 * blob zero-pads the extended region), so this builds a full record.
 */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "../src/juno_engine.h"
#include "../src/juno_apply.h"
#include "../src/juno_curve.h"
#include "../src/juno_driver.h"

#define HDR 23
#define STRIDE 20223
static void put_pair(unsigned char *rec, int off, int v) { rec[off]=(v>>4)&0xF; rec[off+1]=v&0xF; }
static void put_blob(unsigned char *rec, int bp, int v) { put_pair(rec, 16 + 2*bp, v); }
static unsigned u32(unsigned char *st, int off) { float f=JF(st,off); unsigned b; memcpy(&b,&f,4); return b; }
static unsigned fb(float f) { unsigned b; memcpy(&b,&f,4); return b; }

static int fails;
static void expect(unsigned char *st, int off, unsigned want, const char *tag)
{ unsigned g=u32(st,off); if(g!=want){ printf("  %s: off %d %08x != %08x\n",tag,off,g,want); ++fails; } }

int main(void)
{
    unsigned char *bank = calloc(1, HDR + STRIDE);
    unsigned char *st = calloc(1, JUNO_STATE_BYTES);
    bank[0] = 'K';
    unsigned char *rec = bank + HDR;

    int bsd=100, bsv=200, msd=50, msv=30, gain=2, range=20;   /* gain=2 -> mode 3.0 */
    put_pair(rec, 514, bsd);   /* BEND SENS DCO */
    put_pair(rec, 522, bsv);   /* BEND SENS VCF */
    put_pair(rec, 530, msd);   /* MOD  SENS DCO */
    put_pair(rec, 538, msv);   /* MOD  SENS VCF */
    put_pair(rec, 506, gain);  /* BEND GAIN     */
    put_blob(rec, 57, range);  /* BEND RANGE    */

    juno_bank_apply(st, bank, 0);
    juno_driver_seed_voices(st);   /* replicate voice 0 to 1..7, as the bridge does */

    float mode = 3.0f, c4 = juno_curve(4, range);
    expect(st, 4128, fb(juno_curve(22, bsd) * c4 * mode), "4128 bend DCO");
    expect(st, 7472, fb(juno_curve(22, bsv) * c4 * mode), "7472 bend VCF");
    expect(st, 3984, fb(juno_curve(22, msd)),             "3984 mod DCO");
    expect(st, 7360, fb(juno_curve(22, msv) * 10.0f),     "7360 mod VCF");

    /* replicated to all 8 voices (stride 10512) */
    for (int v = 1; v < 8; ++v) {
        unsigned v0 = u32(st, 4128), vv = u32(st, 4128 + v*10512);
        if (v0 != vv) { printf("  voice %d bend depth not replicated (%08x != %08x)\n", v, vv, v0); ++fails; }
    }

    /* BEND GAIN out of range (>3) clamps to mode 1.0 */
    memset(st, 0, JUNO_STATE_BYTES);
    put_pair(rec, 506, 9);
    juno_bank_apply(st, bank, 0);
    expect(st, 4128, fb(juno_curve(22, bsd) * c4 * 1.0f), "4128 gain-clamp");

    free(st); free(bank);
    if (fails) { printf("FAIL: %d bend/mod-sens check(s)\n", fails); return 1; }
    printf("OK: bend/mod SENS recall (product formula + mode + voice replication) verified\n");
    return 0;
}

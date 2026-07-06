/* test_reverb_recall.c — regression guard for the per-patch global REVERB recall.
 *
 * Freezes the value-tree-derived mappings (src/reverb_recall.c):
 *   REVERB LEVEL byte (front-panel blob 51) -> engine 10759408 (send/wet)
 *   REVERB TIME  byte (record 666)          -> engine 10759680 (decay feedback)
 * The bit patterns are the plugin's own value-tree curve outputs, captured from
 * the effect param setter under emulation.
 */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "../src/juno_engine.h"
#include "../src/juno_apply.h"

#define HDR 23
#define STRIDE 20223

static void put_pair(unsigned char *rec, int off, int v)
{ rec[off] = (v >> 4) & 0xF; rec[off + 1] = v & 0xF; }
static void put_blob(unsigned char *rec, int bp, int v) { put_pair(rec, 16 + 2 * bp, v); }
static unsigned u32(unsigned char *st, int off)
{ float f = JF(st, off); unsigned b; memcpy(&b, &f, 4); return b; }

int main(void)
{
    unsigned char *bank = calloc(1, HDR + STRIDE);
    unsigned char *st = calloc(1, JUNO_STATE_BYTES);
    int fails = 0;
    bank[0] = 'K';
    unsigned char *rec = bank + HDR;

    /* REVERB LEVEL 255 -> 1.0 ; TIME 128 -> -0.83656 */
    put_blob(rec, 51, 255);      /* REVERB LEVEL */
    put_pair(rec, 666, 128);     /* REVERB TIME  */
    juno_bank_apply(st, bank, 0);
    if (u32(st, 10759408) != 0x3f800000u) { printf("  RLVL255: 10759408 %08x != 3f800000\n", u32(st,10759408)); ++fails; }
    if (u32(st, 10759680) != 0xbf5628c4u) { printf("  RTIME128: 10759680 %08x != bf5628c4\n", u32(st,10759680)); ++fails; }

    /* REVERB LEVEL 0 -> 0.0 (reverb off), 128 -> 0.16251 */
    put_blob(rec, 51, 0);
    juno_bank_apply(st, bank, 0);
    if (u32(st, 10759408) != 0x00000000u) { printf("  RLVL0: 10759408 %08x != 0\n", u32(st,10759408)); ++fails; }
    put_blob(rec, 51, 128);
    juno_bank_apply(st, bank, 0);
    if (u32(st, 10759408) != 0x3e266800u) { printf("  RLVL128: 10759408 %08x != 3e266800\n", u32(st,10759408)); ++fails; }

    free(st); free(bank);
    if (fails) { printf("FAIL: %d reverb-recall check(s) drifted\n", fails); return 1; }
    printf("OK: per-patch reverb recall (level + time) verified\n");
    return 0;
}

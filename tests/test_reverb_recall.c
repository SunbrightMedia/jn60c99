/* test_reverb_recall.c — regression guard for per-patch global REVERB recall.
 *
 * Reverb LEVEL/TYPE/TIME are recalled from the plugin's OWN value-tree dispatch
 * (setter-hooked under Unicorn — scratchpad/oracle/reverb_validation_findings.md):
 *   LEVEL (blob 51)  -> 10759408                     (REVLVL_LUT, bit-exact 256/256)
 *   TYPE  (rec 658)  -> 4 DPF Fc + type-5 stage 488 + (with TIME) 8 Hp/Lp coeffs
 *   TIME  (rec 666)  -> the 8 Hp/Lp coeffs, JOINT with TYPE
 * The Hp/Lp coeffs are a joint (TYPE,TIME) table; the old single-curve REVTIME_LUT
 * was the TYPE-0 slice of one offset (wrong for every real patch, incl. the default
 * TYPE2/TIME128). This test asserts the corrected joint values.
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

static int fails = 0;
static void chk(unsigned char *st, int off, unsigned want, const char *tag)
{ unsigned g = u32(st, off); if (g != want) { printf("  %s: off %d %08x != %08x\n", tag, off, g, want); ++fails; } }

int main(void)
{
    unsigned char *bank = calloc(1, HDR + STRIDE);
    unsigned char *st = calloc(1, JUNO_STATE_BYTES);
    bank[0] = 'K';
    unsigned char *rec = bank + HDR;

    /* --- LEVEL curve (REVLVL_LUT), unchanged/correct --- */
    put_blob(rec, 51, 255); put_pair(rec, 658, 0); put_pair(rec, 666, 128);
    juno_bank_apply(st, bank, 0);
    chk(st, 10759408, 0x3f800000u, "LVL255");
    put_blob(rec, 51, 0);   juno_bank_apply(st, bank, 0); chk(st, 10759408, 0x00000000u, "LVL0");
    put_blob(rec, 51, 128); juno_bank_apply(st, bank, 0); chk(st, 10759408, 0x3e266800u, "LVL128");

    /* --- TYPE 2 / TIME 128 (plugin default): corrected joint coeffs --- */
    put_blob(rec, 51, 200); put_pair(rec, 658, 2); put_pair(rec, 666, 128);
    juno_bank_apply(st, bank, 0);
    chk(st, 10759648, 0x3e0566f8u, "T2Fc0"); chk(st, 10759792, 0x3e0566f8u, "T2Fc3");
    chk(st, 10759488, 0x00000000u, "T2_488");
    chk(st, 10759664, 0x3ebd52a3u, "T2HP01"); chk(st, 10759712, 0x3ebd52a3u, "T2HP01m");
    chk(st, 10759680, 0xbf16c2f3u, "T2LP01");   /* was wrongly bf5628c4 */
    chk(st, 10759728, 0xbf16c2f3u, "T2LP01m");
    chk(st, 10759760, 0x3e8f487eu, "T2HP23"); chk(st, 10759776, 0xbf044337u, "T2LP23");
    chk(st, 10759824, 0xbf044337u, "T2LP23m");

    /* --- TYPE 5 / TIME 200: enables the type-5-only stage 488 --- */
    put_pair(rec, 658, 5); put_pair(rec, 666, 200);
    juno_bank_apply(st, bank, 0);
    chk(st, 10759488, 0x3e500000u, "T5_488");   /* 0.203125, type-5 only */
    chk(st, 10759744, 0x3e0566f8u, "T5Fc2");
    chk(st, 10759664, 0x3f318c05u, "T5HP01");
    chk(st, 10759680, 0xbf5b0982u, "T5LP01");
    chk(st, 10759808, 0x3f1e5e9du, "T5HP23m");

    free(st); free(bank);
    if (fails) { printf("FAIL: %d reverb-recall check(s) drifted\n", fails); return 1; }
    printf("OK: per-patch reverb recall (level + TYPE + TIME, joint Hp/Lp) verified\n");
    return 0;
}

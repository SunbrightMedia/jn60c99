/* test_delay_recall.c — regression guard for the per-patch DELAY recall.
 *
 * Crafts two synthetic bank records and checks juno_bank_apply -> juno_apply_delay:
 *   (1) DELAY TYPE = 0 (delay mode): the slot-1 delay block (102xxx) is filled
 *       from the leaf values, and the v39 selector cell = 0.
 *   (2) DELAY TYPE = 2 (chorus mode in slot 1): the delay block is NOT touched
 *       (stays zero) and the v39 selector cell = 2.
 * Coefficient formulas are those transcribed from the value-tree oracle
 * (src/delay_recall.c); this freezes them so a drift is caught.
 */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "../src/juno_engine.h"
#include "../src/juno_apply.h"
#include "../src/delay_recall.h"

#define HDR 23
#define STRIDE 20223

/* set the nibble-pair at record byte `off` so record_byte(off) == v (0..255). */
static void put_pair(unsigned char *rec, int off, int v)
{
    rec[off]     = (v >> 4) & 0xF;
    rec[off + 1] = v & 0xF;
}
/* set front-panel blob position bp (blob = record+16) to value v. */
static void put_blob(unsigned char *rec, int bp, int v)
{
    put_pair(rec, 16 + 2 * bp, v);
}

static int u32(unsigned char *st, int off)
{
    float f = JF(st, off); unsigned int b; memcpy(&b, &f, 4); return (int)b;
}

int main(void)
{
    unsigned char *bank = calloc(1, HDR + STRIDE);
    unsigned char *st = calloc(1, JUNO_STATE_BYTES);
    int fails = 0;
    bank[0] = 'K';
    unsigned char *rec = bank + HDR;

    /* --- case 1: DELAY TYPE 0, LEVEL 128, TIME 128, FEEDBACK 255, DIRECT 255 --- */
    put_pair(rec, 650, 0);      /* DELAY TYPE   */
    put_blob(rec,  52, 128);    /* DELAY LEVEL  (blob 52, corrected from 40)  */
    put_blob(rec,  53, 128);    /* DELAY TIME   (blob 53, corrected from 49)  */
    put_pair(rec, 3057, 255);   /* DELAY FEEDBACK   */
    put_pair(rec, 3060, 255);   /* DELAY DIRECT LEV */
    memset(st, 0, JUNO_STATE_BYTES);
    juno_bank_apply(st, bank, 0);

    if (*(int32_t *)(st + JUNO_PROG_DLY) != 0) {
        printf("  case1: v39 cell = %d, expected 0\n", *(int32_t *)(st + JUNO_PROG_DLY)); ++fails; }
    if (u32(st, 102528) != 0x3f008081) {   /* 128/255 = 0.50196 */
        printf("  case1: Wet %08x != 3f008081\n", u32(st, 102528)); ++fails; }
    if (u32(st, 102560) != 0x3f666666) {   /* 255/255*0.9 = 0.9 */
        printf("  case1: Feedback %08x != 3f666666\n", u32(st, 102560)); ++fails; }
    if (JF(st, 102576) != 1.0f) { printf("  case1: On/Off != 1\n"); ++fails; }
    if (JF(st, 102592) != 1.0f) { printf("  case1: Mute != 1\n"); ++fails; }
    if (u32(st, 102352) != 0x3f96bc00) {   /* DELAYTIME_LUT[128] = 1.17761 */
        printf("  case1: Time %08x != 3f96bc00\n", u32(st, 102352)); ++fails; }
    if (u32(st, 102368) != 0x3f03df74) {   /* high-cut filter constant */
        printf("  case1: filter %08x != 3f03df74\n", u32(st, 102368)); ++fails; }

    /* --- case 2: DELAY TYPE 2 (chorus in slot 1): delay block untouched --- */
    put_pair(rec, 650, 2);
    memset(st, 0, JUNO_STATE_BYTES);
    juno_bank_apply(st, bank, 0);
    if (*(int32_t *)(st + JUNO_PROG_DLY) != 2) {
        printf("  case2: v39 cell = %d, expected 2\n", *(int32_t *)(st + JUNO_PROG_DLY)); ++fails; }
    if (JF(st, 102528) != 0.0f || JF(st, 102352) != 0.0f) {
        printf("  case2: delay block written for non-delay mode\n"); ++fails; }

    /* --- case 3: DELAY TYPE 0 but LEVEL 0 (delay off): block muted --- */
    put_pair(rec, 650, 0);
    put_blob(rec, 52, 0);       /* DELAY LEVEL 0 (blob 52, corrected from 40) */
    memset(st, 0, JUNO_STATE_BYTES);
    juno_bank_apply(st, bank, 0);
    if (JF(st, 102576) != 0.0f || JF(st, 102592) != 0.0f) {
        printf("  case3: delay not muted at LEVEL 0 (On=%g Mute=%g)\n",
               JF(st, 102576), JF(st, 102592)); ++fails; }

    free(st); free(bank);
    if (fails) { printf("FAIL: %d delay-recall check(s) drifted\n", fails); return 1; }
    printf("OK: per-patch delay recall (mode + coefficients) verified\n");
    return 0;
}

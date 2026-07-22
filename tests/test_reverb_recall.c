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

    /* --- TYPE-dependent tap-index table (34 ints at 11022208; the plugin's own
     * REVERB TYPE dispatch output under emulation — juno_write_reverb_taps). Types
     * 0/1 run their own stage sets; types >= 2 the default. Entry [3] is the first
     * type-dependent tap; [1] is predelay-only. Rate law: 44100 has its own integer
     * table; other rates = the 96k table + (int)(0.019995*H) - 1919. --- */
    {
        rec[3947] = 20;   /* REVERB PRE DELAY = default 20 (identity: byte-20 taps) */
        static const struct { int Hr; int type; int tap1; int tap3; int tap33; } TT[] = {
            { 96000, 0, 1919, 3128,  8659 },   /* dispatch dumps, verbatim */
            { 96000, 1, 1919, 3620, 20141 },
            { 96000, 2, 1919, 4792, 47511 },
            { 48000, 0,  959, 2168,  7699 },   /* == 96k - 960 (captured p41/p62)  */
            { 48000, 1,  959, 2660, 19181 },   /* == 96k - 960 (captured p8/p34)   */
            { 44100, 0,  881, 1957,  4509 },   /* own 44.1k integer table          */
            { 44100, 1,  881, 2183,  9783 },
            { 44100, 5,  881, 2721, 22358 },   /* type 5 -> default table          */
        };
        int i;
        for (i = 0; i < (int)(sizeof TT / sizeof TT[0]); ++i) {
            memset(st, 0, JUNO_STATE_BYTES);
            JF(st, 16) = (float)TT[i].Hr;
            put_pair(rec, 658, TT[i].type);
            juno_bank_apply(st, bank, 0);
            if (JI(st, 11022208) != 1 ||
                JI(st, 11022208 + 4)      != TT[i].tap1 ||
                JI(st, 11022208 + 4 * 3)  != TT[i].tap3 ||
                JI(st, 11022208 + 4 * 33) != TT[i].tap33) {
                printf("  taps T%d@%d: [0]=%d [1]=%d [3]=%d [33]=%d != 1/%d/%d/%d\n",
                       TT[i].type, TT[i].Hr, JI(st, 11022208), JI(st, 11022208 + 4),
                       JI(st, 11022208 + 12), JI(st, 11022208 + 132),
                       TT[i].tap1, TT[i].tap3, TT[i].tap33);
                ++fails;
            }
        }
    }

    /* --- REVERB PRE DELAY (idx 1323, record byte 3947, int1x7 0..100; W1): shifts the
     * whole tap array uniformly by predelay(byte)-predelay(20), predelay =
     * max((byte*Hr)/1000-2, 0), + writes the master predelay cell 10759360 = (float)
     * predelay. The plugin's own PRE DELAY setter (executed, reverb_predelay_derive.py;
     * exact over every byte x 4 rates x 3 TYPE classes). Values below are dispatch
     * dumps, verbatim. --- */
    {
        static const struct {
            int Hr; int type; int pd; int tap1; int tap3; int tap33; unsigned c360;
        } PD[] = {
            { 44100, 0, 100, 4409, 5485,  8037, 0x4589c000u },  /* predelay 4408    */
            { 96000, 1,   0,    1, 1702, 18223, 0x00000000u },  /* predelay 0 (clamp)*/
            { 48000, 2,  60, 2879, 5752, 48471, 0x4533e000u },  /* predelay 2878    */
        };
        int i;
        for (i = 0; i < (int)(sizeof PD / sizeof PD[0]); ++i) {
            memset(st, 0, JUNO_STATE_BYTES);
            JF(st, 16) = (float)PD[i].Hr;
            put_pair(rec, 658, PD[i].type);
            rec[3947] = (unsigned char)PD[i].pd;
            juno_bank_apply(st, bank, 0);
            if (JI(st, 11022208) != 1 ||
                JI(st, 11022208 + 4)      != PD[i].tap1 ||
                JI(st, 11022208 + 4 * 3)  != PD[i].tap3 ||
                JI(st, 11022208 + 4 * 33) != PD[i].tap33 ||
                u32(st, 10759360)         != PD[i].c360) {
                printf("  PRE DELAY T%d pd%d@%d: [1]=%d [3]=%d [33]=%d 360=%08x "
                       "!= %d/%d/%d/%08x\n", PD[i].type, PD[i].pd, PD[i].Hr,
                       JI(st, 11022208 + 4), JI(st, 11022208 + 12), JI(st, 11022208 + 132),
                       u32(st, 10759360), PD[i].tap1, PD[i].tap3, PD[i].tap33, PD[i].c360);
                ++fails;
            }
        }
        rec[3947] = 20;   /* restore default for subsequent blocks */
    }

    /* --- reverb fine-FX (src/finefx_recall.c): LOW/HIGH CUT / DENSITY / DIRECT
     * LEVEL, the plugin's own smoother-target coeffs (dispatch 1324..1327 + snap).
     * Non-default bytes at 44.1 kHz: LOW CUT=17, HIGH CUT=0, DENSITY=5, DIRECT=128.
     * int1x7 (raw byte) for LOW/HIGH/DENSITY, int2x4 (nibble pair) for DIRECT. --- */
    {
        memset(st, 0, JUNO_STATE_BYTES);
        JF(st, 16) = 44100.0f;
        put_pair(rec, 658, 2); put_pair(rec, 666, 128);   /* reverb TYPE 2 active */
        rec[3948] = 17;                 /* REVERB LOW CUT  = 17 (int1x7 raw)      */
        rec[3949] = 0;                  /* REVERB HIGH CUT = 0                     */
        rec[3950] = 5;                  /* REVERB DENSITY  = 5                     */
        put_pair(rec, 3951, 128);       /* REVERB DIRECT LEVEL = 128 (int2x4)      */
        juno_bank_apply(st, bank, 0);
        chk(st, 10759520, 0x3f639db5u, "revLC17a"); chk(st, 10759536, 0xbf639db5u, "revLC17b");
        chk(st, 10759552, 0x3f473b6au, "revLC17c");
        chk(st, 10759568, 0x3af7c943u, "revHC0a");  chk(st, 10759616, 0x3fefc7b0u, "revHC0d");
        chk(st, 10759632, 0xbf617ef2u, "revHC0e");
        chk(st, 10759392, 0x3e9c0000u, "revDENS5"); chk(st, 10759424, 0x3e266800u, "revDIR128");
        rec[3948] = 2; rec[3949] = 11; rec[3950] = 10; put_pair(rec, 3951, 255);  /* restore defaults */
    }

    free(st); free(bank);
    if (fails) { printf("FAIL: %d reverb-recall check(s) drifted\n", fails); return 1; }
    printf("OK: per-patch reverb recall (level + TYPE + TIME + tap tables, joint Hp/Lp) verified\n");
    return 0;
}

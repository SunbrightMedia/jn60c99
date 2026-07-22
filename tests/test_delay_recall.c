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

    /* The fine-FX filter params (DELAY HIGH CUT / LF+HF DAMP / LF+HF DAMP FREQ) are
     * now live (src/finefx_recall.c). A real patch record always carries them, so
     * seed the synthetic record with their DEFAULT bytes (HIGH CUT=7 raw at 3059;
     * HF DAMP FREQ=13 nibble pair at 3092; LF DAMP / LF DAMP FREQ / HF DAMP default
     * to 0, already zeroed by calloc). At the default byte the applier reproduces
     * delay_recall.c's frozen FILT[]/put_rate constants, so the checks below hold. */
    rec[3059] = 7;              /* DELAY HIGH CUT default (int1x7 raw)       */
    put_pair(rec, 3092, 13);    /* DELAY HF DAMP FREQ default (int8x4 nibble) */

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
    /* Feedback is PER-PATCH: the plugin's own dispatch law f32(byte/255)*f32(0.9),
     * proven bit-exact over all 256 values x 3 rates (tools/verify/delay_fb_sweep.py).
     * FEEDBACK byte 255 -> 0.9f (0x3f666666). The old expectation 0x3ed8d8d9 was a
     * captured constant == the fb=120 special case, proven wrong by the 64-patch
     * render A/B (patches 6/45/46/50/54). DRY (102512) = byte/255 -> 255 -> 1.0. */
    if (u32(st, 102560) != 0x3f666666) {   /* law(255) = 0.9 */
        printf("  case1: Feedback %08x != 3f666666\n", u32(st, 102560)); ++fails; }
    if (u32(st, 102512) != 0x3f800000) {   /* law(255) = 1.0 */
        printf("  case1: Dry %08x != 3f800000\n", u32(st, 102512)); ++fails; }
    if (JF(st, 102576) != 1.0f) { printf("  case1: On/Off != 1\n"); ++fails; }
    if (JF(st, 102592) != 1.0f) { printf("  case1: Enable != 1\n"); ++fails; }
    if (u32(st, 102352) != 0x3f96bc00) {   /* DELAYTIME_LUT[128] = 1.17761 @96k (test default rate) */
        printf("  case1: Time %08x != 3f96bc00\n", u32(st, 102352)); ++fails; }
    if (u32(st, 102368) != 0x3e1b31ce) {   /* high-cut filter constant 0.1515572 */
        printf("  case1: filter %08x != 3e1b31ce\n", u32(st, 102368)); ++fails; }

    /* --- case 2: DELAY TYPE 2 (chorus in slot 1): wet/enables untouched, but the
     * TIME cell 102352 is written for EVERY type (the plugin's recall dispatches the
     * time leaf before the type routing — every captured state carries it). --- */
    put_pair(rec, 650, 2);
    memset(st, 0, JUNO_STATE_BYTES);
    juno_bank_apply(st, bank, 0);
    if (*(int32_t *)(st + JUNO_PROG_DLY) != 2) {
        printf("  case2: v39 cell = %d, expected 2\n", *(int32_t *)(st + JUNO_PROG_DLY)); ++fails; }
    if (JF(st, 102528) != 0.0f) {
        printf("  case2: delay wet written for non-delay mode\n"); ++fails; }
    if (u32(st, 102352) != 0x3f96bc00) {   /* time carried for every type (manual b128 @96k) */
        printf("  case2: Time %08x != 3f96bc00 (universal write)\n", u32(st, 102352)); ++fails; }

    /* --- case 3: DELAY TYPE 0 but LEVEL 0 (delay off): block muted --- */
    put_pair(rec, 650, 0);
    put_blob(rec, 52, 0);       /* DELAY LEVEL 0 (blob 52, corrected from 40) */
    memset(st, 0, JUNO_STATE_BYTES);
    juno_bank_apply(st, bank, 0);
    /* LEVEL 0 -> ON/OFF gate (102576) drops to 0. 102592 is a constant enable (=1.0
     * for every factory patch), so it is NOT the level mute — only 102576 is checked. */
    if (JF(st, 102576) != 0.0f) {
        printf("  case3: delay not muted at LEVEL 0 (On=%g)\n", JF(st, 102576)); ++fails; }

    /* --- case 4: TEMPO SYNC on (blob 59 != 0): TIME byte quantizes to a note
     * division at the baked 128-BPM default. byte 128 -> division 8 (dotted 1/8) ->
     * 351.5625 ms -> 0x4003d400 @96k (the plugin's own dispatch output; bit-exact
     * 48/48 divisions x rates under emulation). --- */
    put_pair(rec, 650, 0);
    put_blob(rec, 52, 128);
    put_blob(rec, 59, 1);       /* TEMPO SYNC on */
    memset(st, 0, JUNO_STATE_BYTES);
    juno_bank_apply(st, bank, 0);
    if (u32(st, 102352) != 0x4003d400) {
        printf("  case4: synced Time %08x != 4003d400 (d8 @96k)\n", u32(st, 102352)); ++fails; }

    /* --- case 5: DELAY TYPE 1 (dual delay): both instances written, same time;
     * second-instance constants + level gate present. --- */
    put_pair(rec, 650, 1);
    memset(st, 0, JUNO_STATE_BYTES);
    juno_bank_apply(st, bank, 0);
    if (*(int32_t *)(st + JUNO_PROG_DLY) != 1) {
        printf("  case5: v39 cell = %d, expected 1\n", *(int32_t *)(st + JUNO_PROG_DLY)); ++fails; }
    if (u32(st, 102352) != 0x4003d400 || u32(st, 4297584) != 0x4003d400) {
        printf("  case5: dual-delay times %08x/%08x != 4003d400\n",
               u32(st, 102352), u32(st, 4297584)); ++fails; }
    if (u32(st, 102528) != 0x3f008081 || u32(st, 4297760) != 0x3f008081) {
        printf("  case5: dual-delay wet %08x/%08x != 3f008081\n",
               u32(st, 102528), u32(st, 4297760)); ++fails; }
    /* type-1 first-instance variant: RATE-ARMED (2sin(pi*10000/H) family; arms
     * measured from the plugin at 44100/48000/88200/96000). Hr unset here -> the
     * 96k arm. The old assertion pinned the 48k capture (0x3f9bd7ca) at 96k, which
     * the plugin's own 96k post-recall state contradicts. */
    if (u32(st, 102544) != 0x3f2493b7) {
        printf("  case5: 102544 %08x != 3f2493b7 (96k arm)\n", u32(st, 102544)); ++fails; }
    if (JF(st, 4297824) != 1.0f || JF(st, 102576) != 1.0f) {
        printf("  case5: dual-delay ON gates not set\n"); ++fails; }

    /* --- case 5b: FX rate arms (44.1 kHz drift fix). The rate-dependent cells of
     * the TYPE-0 delay block must select the measured per-rate bits; the former
     * 48k-only captures seeded the 44.1 kHz (and 96 kHz) cold-render drift. --- */
    {
        struct arm { float rate; unsigned c102608, c102544, c102448, c102656; };
        static const struct arm A[3] = {
            { 44100.0f, 0x3c3abeeau, 0x388b3cdfu, 0x3f800000u, 0x3f800000u },
            { 48000.0f, 0x3c2b929au, 0x387fd974u, 0x00000000u, 0x3f4ba5b0u },
            {     0.0f, 0x3bab929au, 0x37ffd974u, 0x00000000u, 0x3f4ba5b0u },  /* unset -> 96k */
        };
        int a;
        put_pair(rec, 650, 0);                 /* DELAY TYPE 0 -> FILT block */
        for (a = 0; a < 3; ++a) {
            memset(st, 0, JUNO_STATE_BYTES);
            JF(st, 16) = A[a].rate;
            juno_bank_apply(st, bank, 0);
            if ((unsigned)u32(st, 102608) != A[a].c102608 ||
                (unsigned)u32(st, 102544) != A[a].c102544 ||
                (unsigned)u32(st, 102448) != A[a].c102448 ||
                (unsigned)u32(st, 102656) != A[a].c102656) {
                printf("  case5b[arm %d]: 102608=%08x 102544=%08x 102448=%08x 102656=%08x\n",
                       a, u32(st, 102608), u32(st, 102544), u32(st, 102448), u32(st, 102656));
                ++fails;
            }
        }
        put_pair(rec, 650, 1);                 /* restore TYPE 1 for case 6 */
        memset(st, 0, JUNO_STATE_BYTES);
        juno_bank_apply(st, bank, 0);
    }

    /* --- case 6: host-tempo recompute (juno_apply_delay_tempo): 60 BPM, division 8
     * -> ms = 750 exactly -> 0x40866300 @96k ((96000*750)/16384000 - 2/16384). The
     * BPM law is bit-exact vs the plugin's own tempo dispatch at 60/88/176 BPM. --- */
    juno_apply_delay_tempo(st, 128, 1, 1, 60.0f);
    {
        float ms = 750.0f;
        float dt = 96000.0f * ms; dt = dt * (1.0f/16384000.0f); dt = dt - (2.0f/16384.0f);
        unsigned int eb; memcpy(&eb, &dt, 4);
        if ((unsigned)u32(st, 102352) != eb || (unsigned)u32(st, 4297584) != eb) {
            printf("  case6: tempo recompute %08x/%08x != %08x\n",
                   u32(st, 102352), u32(st, 4297584), eb); ++fails; }
    }

    /* --- case 7: NON-DEFAULT fine-FX filter (src/finefx_recall.c). The 18 factory
     * TYPE-0 delay patches (p2/p6/p12/p13/... "Delicate Keys"/"Ouch Bass"/...) carry
     * DELAY HIGH CUT=3, HF DAMP=12, HF DAMP FREQ=3 — NOT the defaults. Before the
     * applier the port froze these at the default coefficients (too bright); it now
     * writes the plugin's own per-byte law. Guard the exact cells at 44.1 kHz (the
     * delivery rate; HF DAMP FREQ is rate-armed). Expected bits are the plugin's own
     * setter output, executed under Unicorn (scratchpad/finefx_delay_rates.py). --- */
    {
        put_pair(rec, 650, 0);        /* DELAY TYPE 0                    */
        rec[3059] = 3;                /* DELAY HIGH CUT = 3  (int1x7 raw) */
        put_pair(rec, 3084, 12);      /* DELAY HF DAMP   = 12 (int8x4)    */
        put_pair(rec, 3092, 3);       /* DELAY HF DAMP FREQ = 3 (int8x4)  */
        memset(st, 0, JUNO_STATE_BYTES);
        JF(st, 16) = 44100.0f;
        juno_bank_apply(st, bank, 0);
        if ((unsigned)u32(st, 102368) != 0x3ce64b15u) {   /* HIGH CUT=3 (rate-indep) */
            printf("  case7: HIGH CUT %08x != 3ce64b15\n", u32(st, 102368)); ++fails; }
        if ((unsigned)u32(st, 102672) != 0x3f004dceu) {   /* HF DAMP=12 (rate-indep) */
            printf("  case7: HF DAMP %08x != 3f004dce\n", u32(st, 102672)); ++fails; }
        if ((unsigned)u32(st, 102656) != 0x3e2e4a3fu) {   /* HF DAMP FREQ=3 @44.1k   */
            printf("  case7: HF DAMP FREQ %08x != 3e2e4a3f\n", u32(st, 102656)); ++fails; }
        /* restore defaults so the record stays a valid default patch */
        rec[3059] = 7; put_pair(rec, 3084, 0); put_pair(rec, 3092, 13);
    }

    /* --- case 8: SLOT-1 CHORUS fine-FX (DELAY TYPE 2/3, finefx_recall.c). CHORUS
     * HIGH CUT (3288) / LOW CUT (3287) / PRE DELAY (3286) apply to the slot-1
     * chorus cells 6396xxx (the slot-2 EFFECT-TYPE chorus has none). Non-default
     * at 44.1 kHz: HIGH CUT=0, LOW CUT=17, PRE DELAY=80 -- vs the plugin's own
     * smoother-target coeffs. int1x7 raw record bytes. --- */
    {
        memset(st, 0, JUNO_STATE_BYTES);
        JF(st, 16) = 44100.0f;
        put_pair(rec, 650, 2);          /* DELAY TYPE 2 -> slot-1 chorus I         */
        rec[3288] = 0;                  /* CHORUS HIGH CUT  = 0                     */
        rec[3287] = 17;                 /* CHORUS LOW CUT   = 17                    */
        rec[3286] = 80;                 /* CHORUS PRE DELAY = 80                    */
        juno_bank_apply(st, bank, 0);
        if ((unsigned)u32(st, 6396192) != 0x3bf819beu) { printf("  case8: choHC0 %08x != 3bf819be\n", u32(st, 6396192)); ++fails; }
        if ((unsigned)u32(st, 6396336) != 0x3de967e3u) { printf("  case8: choLC17 %08x != 3de967e3\n", u32(st, 6396336)); ++fails; }
        if ((unsigned)u32(st, 6396352) != 0x3f800000u) { printf("  case8: choLC17b %08x != 3f800000\n", u32(st, 6396352)); ++fails; }
        if ((unsigned)u32(st, 6396128) != 0x3ddc4001u) { printf("  case8: choPD80 %08x != 3ddc4001\n", u32(st, 6396128)); ++fails; }
        rec[3288] = 13; rec[3287] = 2; rec[3286] = 20;   /* restore defaults        */
    }

    /* --- case 9: DELAY TYPE 1 SECOND-INSTANCE fine-FX (finefx_recall.c
     * juno_apply_delay_finefx_2nd). In dual delay (TYPE 1) the HIGH CUT / DAMP /
     * DIRECT knobs move the SECOND instance (4297xxx) with the SAME law as TYPE 0's
     * first instance -- proven by finefx_multictx_probe.py. Non-default @44.1k:
     * HIGH CUT=3 -> 4297600 (== TYPE-0 102368 @byte3, rate-indep); HF DAMP=12 ->
     * 4297968; DIRECT=128 -> 4297744 (=128/255); HF DAMP FREQ=3 -> 4297952 @44.1k
     * (== case-7's 102656 value, identical rate-armed law). --- */
    {
        memset(st, 0, JUNO_STATE_BYTES);
        JF(st, 16) = 44100.0f;
        put_pair(rec, 650, 1);          /* DELAY TYPE 1 -> dual delay              */
        rec[3059] = 3;                  /* DELAY HIGH CUT = 3 (int1x7 raw)         */
        put_pair(rec, 3060, 128);       /* DELAY DIRECT LEVEL = 128 (int2x4)       */
        put_pair(rec, 3084, 12);        /* DELAY HF DAMP = 12 (int8x4)             */
        put_pair(rec, 3092, 3);         /* DELAY HF DAMP FREQ = 3 (int8x4)         */
        juno_bank_apply(st, bank, 0);
        if ((unsigned)u32(st, 4297600) != 0x3ce64b15u) { printf("  case9: 2nd HIGH CUT %08x != 3ce64b15\n", u32(st, 4297600)); ++fails; }
        if ((unsigned)u32(st, 4297968) != 0x3f004dceu) { printf("  case9: 2nd HF DAMP %08x != 3f004dce\n", u32(st, 4297968)); ++fails; }
        if ((unsigned)u32(st, 4297744) != 0x3f008081u) { printf("  case9: 2nd DIRECT %08x != 3f008081\n", u32(st, 4297744)); ++fails; }
        if ((unsigned)u32(st, 4297952) != 0x3e2e4a3fu) { printf("  case9: 2nd HF DAMP FREQ %08x != 3e2e4a3f\n", u32(st, 4297952)); ++fails; }
        rec[3059] = 7; put_pair(rec, 3060, 255); put_pair(rec, 3084, 0); put_pair(rec, 3092, 13);
    }

    /* --- case 10: DELAY TYPE 5 (slot-1 reverb) fine-FX (finefx_recall.c
     * juno_apply_delay_finefx_slot1rev + juno_apply_chorus_finefx_slot1rev). The DELAY
     * fine-FX knobs move the slot-1-reverb delay-filter block (6497xxx), the CHORUS
     * knobs its chorus-filter block (10693xxx), same laws as TYPE 0 / TYPE 2,3 (proven
     * law-identical, dt5_derive.py). Rate-independent cells @44.1k: delay HIGH CUT=3 ->
     * 6497184; delay DIRECT=128 -> 6497328; chorus HIGH CUT=0 -> 10693072. --- */
    {
        memset(st, 0, JUNO_STATE_BYTES);
        JF(st, 16) = 44100.0f;
        put_pair(rec, 650, 5);          /* DELAY TYPE 5 -> slot-1 reverb           */
        rec[3059] = 3;                  /* DELAY HIGH CUT = 3                       */
        put_pair(rec, 3060, 128);       /* DELAY DIRECT LEVEL = 128                 */
        rec[3288] = 0;                  /* CHORUS HIGH CUT = 0                      */
        juno_bank_apply(st, bank, 0);
        if ((unsigned)u32(st, 6497184) != 0x3ce64b15u) { printf("  case10: s1rev dlyHC %08x != 3ce64b15\n", u32(st, 6497184)); ++fails; }
        if ((unsigned)u32(st, 6497328) != 0x3f008081u) { printf("  case10: s1rev dlyDIR %08x != 3f008081\n", u32(st, 6497328)); ++fails; }
        if ((unsigned)u32(st, 10693072) != 0x3bf819beu) { printf("  case10: s1rev choHC %08x != 3bf819be\n", u32(st, 10693072)); ++fails; }
        put_pair(rec, 650, 0); rec[3059] = 7; put_pair(rec, 3060, 255); rec[3288] = 13;
    }

    free(st); free(bank);
    if (fails) { printf("FAIL: %d delay-recall check(s) drifted\n", fails); return 1; }
    printf("OK: per-patch delay recall (mode + coefficients) verified\n");
    return 0;
}

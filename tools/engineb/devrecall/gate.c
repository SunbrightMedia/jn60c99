/* gate.c -- THE DEVICE-RECALL GATE. ONE source, compiled TWICE.
 *
 *   host half   the port's flat 11 MB cell array, native JF/JI
 *   dev half    -DGATE_DEV, the same sources with JF/JI/CF rebased onto
 *               engine_b/dev/ebdev.h's ~25 KB array
 *
 * ONE source on purpose. The 2026-08-11 gate had two, and a gate whose two
 * halves are separately maintained can drift into agreeing about the wrong
 * scenario. Here the scenario driver is literally the same code; only the
 * boot, the addressing and the output are #ifdef'd.
 *
 * WHAT IT COVERS, and the first two are the holes that hid defects 2 and 3:
 *
 *   NOTES.      Every case issues a note burst across ALL voices and then runs
 *               eb_render_state_seed and eb_render_events_mirror. The old gate
 *               called neither. That is exactly why five per-voice cells looked
 *               like enough when the real set is twelve.
 *   SEQUENCES.  Cases are A->B and A->edit->B, not one cold recall. The device
 *               recalls WARM; a cold-only gate cannot see a stale cell.
 *   the old coverage. 64 patches x 3 rates x {factory, nibble-randomised
 *               synthetic}, at trunk defaults AND at the shipping fork flags.
 *
 * The reference for a warm case is THE SAME SEQUENCE ON THE HOST -- never a
 * cold recall of the same patch. Warm != cold is the plugin's own behaviour
 * (measured: the plugin's state differs in 50 of 64 consecutive pairs while
 * its AUDIO differs in 0 of 64), so a gate that demanded warm == cold would
 * fail on correct behaviour. What the device owes is that its warm state
 * equals the host's warm state, and that is what is compared here.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#include "juno_engine.h"
#include "juno_apply.h"
#include "juno_driver.h"
#include "juno_note.h"
#include "eb_coefs.h"
#include "eb_master_coefs.h"

#ifdef GATE_DEV
#include "ebdev.h"
#include "eb_recall.h"
#else
/* the host half gathers its boot image THROUGH THE GENERATED TABLE, so the
 * two halves cannot disagree about the layout they are exchanging */
#include "ebdev_seg.h"
#endif

#define BANK_HEADER 23
#define BANK_STRIDE 20223
#define NRATE 3
static const int RATES[NRATE] = { 44100, 48000, 96000 };

/* the three sequences */
enum { SEQ_COLD = 0, SEQ_WARM = 1, SEQ_EDIT = 2, NSEQ = 3 };
static const char *SEQNAME[NSEQ] = { "cold", "warm A->B", "warm A->edit->B" };

static uint64_t fnv(const void *p, size_t n)
{
    const unsigned char *q = (const unsigned char *)p;
    uint64_t h = 1469598103934665603ULL;
    size_t i;
    for (i = 0; i < n; ++i) { h ^= q[i]; h *= 1099511628211ULL; }
    return h;
}

static eb_render_coefs RC;
static eb_master_coef  MC;
static eb_render_state RS;

#ifdef GATE_DEV
static unsigned char *const ST = (unsigned char *)0;   /* unused: JF ignores it */
#define BOOTBYTES (EBDEV_VTILE + EBDEV_SEGBYTES + (unsigned)sizeof(((ebdev_state*)0)->scat))
static unsigned char BOOT[NRATE][EBDEV_VTILE + EBDEV_SEGBYTES + EBDEV_NV * EBDEV_NSCAT * 4];
#else
static unsigned char *ST;
#endif

/* ------------------------------------------------------------------ boot */
static void boot(int r)
{
#ifdef GATE_DEV
    memset(&EBDEV_S, 0, sizeof EBDEV_S);
    memcpy(EBDEV_S.v0,   BOOT[r], EBDEV_VTILE);
    memcpy(EBDEV_S.sg,   BOOT[r] + EBDEV_VTILE, EBDEV_SEGBYTES);
    memcpy(EBDEV_S.scat, BOOT[r] + EBDEV_VTILE + EBDEV_SEGBYTES, sizeof EBDEV_S.scat);
#else
    memset(ST, 0, JUNO_STATE_BYTES);
    juno_chorus_init(ST);
    JF(ST, 16) = (float)RATES[r];
    juno_engine_init(ST);
    juno_engine_prepare(ST);
#endif
}

/* --------------------------------------------------------------- recall */
static void recall(const unsigned char *bank, int p, int synth, unsigned *seed)
{
    juno_bank_apply(ST, bank, p);
#ifdef GATE_DEV
    /* THE DEVICE'S juno_driver_seed_voices. On the host, recall writes voice 0
     * and a memcpy replicates the whole block; here the block is not
     * contiguous, so the per-voice scatter must be broadcast explicitly.
     * Omitting this was MEASURED to fail 24 of 192 cases, first at
     * glide[1].k592 -- the portamento gate. */
#ifndef GATE_TOOTH_NOBCAST
    ebdev_broadcast_scatter();
#endif
#else
    juno_driver_seed_voices(ST);
#endif
    if (synth) {
        *seed = *seed * 1103515245u + 12345u;
        juno_apply_unison_spread(ST, (int)((*seed >> 16) & 3));
        *seed = *seed * 1103515245u + 12345u;
        juno_apply_condition(ST, (int)((*seed >> 16) & 0xFF));
    } else {
        juno_apply_unison_spread(ST, juno_bank_assign(bank, p));
        juno_apply_condition(ST, juno_bank_condition(bank, p));
    }
    juno_apply_lfo_tempo(ST, juno_bank_lfo_rate_byte(bank, p), 128.0f);
}

/* ------------------------------------------------------------- the notes
 * A burst that reaches EVERY voice and every note-path entry point. This is
 * the part the 2026-08-11 gate did not have, and the reason defect 2 was
 * invisible: with no note, the seven note-written per-voice cells are never
 * written, so a map that cannot address them looks complete. */
static void notes(void)
{
    int v;
    for (v = 0; v < JUNO_NUM_VOICES; ++v) {
        juno_note_on(ST, v, 36 + v * 5, 40 + v * 11);
        juno_note_broadcast_held(ST, 1);
    }
    juno_note_retrig(ST, 2);
    juno_note_porta_gate(ST, 4, 1, 0.0f);
    juno_note_porta_gate(ST, 5, 0, 1.0f);
    juno_note_velocity(ST, 6, 77);
    juno_note_glide(ST, 7, 61);
    juno_note_off(ST, 3);
}

/* -------------------------------------------------------- a live edit
 * The encoder path, gui/juno_bridge.c:331-341: one leaf expands to every
 * BINDINGS row sharing its blob byte, and a per-voice cell is replicated to
 * voices 1..7 by hand. One of those offsets is 592, the portamento gate --
 * i.e. an ordinary knob move writes a SCATTER cell on every voice. */
static void edit(int idx, int byte)
{
    int blob = juno_param_blob(idx), n = juno_param_count(), i, v;
    int Hr = (int)JF(ST, 16);
    if (blob < 0) return;
    for (i = 0; i < n; ++i) {
        if (juno_param_blob(i) != blob) continue;
        {
            int off = juno_param_offset(i);
            float w = juno_apply_param(ST, i, byte, Hr);
            if (off >= 176 && off < 176 + JUNO_VOICE_MAIN_STRIDE)
                for (v = 1; v < JUNO_NUM_VOICES; ++v)
                    JF(ST, (unsigned)off + (unsigned)v * JUNO_VOICE_MAIN_STRIDE) = w;
        }
    }
}

#ifdef GATE_DEV
/* ================================================== THE PUBLISH CONTRACT
 *
 * Defect 3: eb_render_events_mirror IS on the recall path and it WRITES into
 * the cell array, and nothing was clearing dco_live_seeded. The contract lives
 * in engine_b/dev/eb_recall.c; this is its gate.
 *
 * Every check below is a state assertion after a REAL patch change, and every
 * one has a compile-time tooth in eb_recall.h that must make it fail. A check
 * whose tooth does not fire is printed NOT CAUGHT.
 */
static eb_render_coefs RCB[2];
static eb_master_coef  MCB[2];
static eb_master_state MS;
static eb_engine       ENG;
static eb_recall       REC;
static int PUB_FAIL, PUB_RUN;

static void pcheck(const char *what, int ok)
{
    ++PUB_RUN;
    if (!ok) ++PUB_FAIL;
    printf("  %-58s %s\n", what, ok ? "ok" : "*** FAILED ***");
}

static int refuse(void) { return 0; }
static int allow(void)  { return 1; }

static int publish_section(const unsigned char *bank)
{
    int v, k, ok;
    const eb_render_coefs *before;

    printf("\n=== PUBLISH CONTRACT (engine_b/dev/eb_recall.c) ===\n");
    memset(&ENG, 0, sizeof ENG);
    eb_recall_init(&REC, &RCB[0], &RCB[1], &MCB[0], &MCB[1], &RS, &MS, &ENG);

    /* context start: patch A, cold, the shim's own order */
    boot(0);
    { unsigned s = 1u; recall(bank, 12, 0, &s); }
    notes();
    eb_render_coefs_build(ST, &RCB[0]);
    eb_master_coefs_build(ST, &MCB[0]);
    eb_render_state_seed(ST, &RS);
    eb_master_state_seed(ST, &MS);
    eb_render_events_mirror(ST, &RS);
    REC.route_last = 3;                 /* a DELAY TYPE nobody is about to use */

    /* voices 0..2 sounding, the rest AT REST. The at-rest arm of step 7c
     * exists only because the shims force every voice awake (juno_driver.c
     * :231) and can therefore never reach it. */
    for (v = 0; v < EB_NUM_VOICES; ++v) {
        ENG.v[v].atrest = (uint8_t)(v >= 3);
        RS.dco_live_seeded[v] = 1;
        RS.dco_live[v].inc = 1.25f + (float)v;
        RS.dco_live[v].lvl_saw = -7.0f;      /* a per-recall field, poisoned */
        RS.gate_cell320[v] = -99.0f;
        RS.aux_edge[v] = 0;
    }
    MS.rev_wipe = 0;
    for (k = 0; k < EB_REV_NTAP; ++k) MS.rev_pending[k] = -1;
    MS.route_change = 99; MS.d1.s11022348 = 99; MS.d23.s11022348 = 99;
    MS.d4.s11022348 = 99; MS.d5.s11022348 = 99;

    /* --- THE PATCH CHANGE: patch B, WARM --------------------------------- */
    { unsigned s = 2u; recall(bank, 37, 0, &s); }
    notes();
    before = (const eb_render_coefs *)EB_RC;

    /* 1-2: the burst, into the SHADOW. The live bank must not move. */
    eb_recall_build(&REC);
    pcheck("steps 1-2: the burst leaves the LIVE coefficient bank untouched",
           (const eb_render_coefs *)EB_RC == before &&
           memcmp(before, &RCB[0], sizeof RCB[0]) == 0);

    /* 3: the quiescence precondition, ASSERTED not assumed */
    eb_recall_quiescent = refuse;
    pcheck("step 3: publish REFUSES while the worker is not parked",
           eb_recall_publish(&REC) != 0 &&
           (const eb_render_coefs *)EB_RC == before);
    eb_recall_quiescent = allow;

    if (eb_recall_publish(&REC) != 0) { printf("  publish refused -- aborting\n"); return 1; }

    /* 4: the swap */
    pcheck("step 4: EB_RC now points at the newly built bank",
           (const eb_render_coefs *)EB_RC == &RCB[1] &&
           (const eb_master_coef *)EB_MC == &MCB[1]);
    /* and the bank it points at is what the shim would have built */
    {
        static eb_render_coefs REF;
        eb_render_coefs_build(ST, &REF);
        pcheck("step 4: the published coefficients == the shim's own build",
               memcmp(&REF, &RCB[1], sizeof REF) == 0);
    }

    /* 5: the delay route latch -- five mirrors of one port cell */
    pcheck("step 5: all five route mirrors carry the PREVIOUS arm's id",
           MS.route_change == 3 && MS.d1.s11022348 == 3 &&
           MS.d23.s11022348 == 3 && MS.d4.s11022348 == 3 && MS.d5.s11022348 == 3);

    /* 6: the reverb wipe countdown and the pending taps */
    ok = (MS.rev_wipe == *(const int32_t *)ebdev_at(10759872u));
    for (k = 0; k < EB_REV_NTAP; ++k)
        if (MS.rev_pending[k] != *(const int32_t *)ebdev_at(11022208u + 4u * (unsigned)k))
            ok = 0;
    pcheck("step 6: rev_wipe armed and rev_pending[] refreshed from the cells", ok);

    /* 7a: the ADSR gate, PER VOICE. This is the line where defect 2 bites the
     * publish: with a shared tile every voice takes voice 0's gate. */
    ok = 1;
    for (v = 0; v < EB_NUM_VOICES; ++v)
        if (RS.gate_cell320[v] != *(const float *)ebdev_at_v(v, 320u)) ok = 0;
    pcheck("step 7a: gate_cell320[v] refreshed from VOICE v's own cell 320", ok);
    {   /* non-vacuity: the voices must not all carry the same gate, or the
         * check above would pass with a shared tile too */
        int distinct = 0;
        for (v = 1; v < EB_NUM_VOICES; ++v)
            if (RS.gate_cell320[v] != RS.gate_cell320[0]) distinct = 1;
        pcheck("step 7a: ... and the gates are NOT all equal (non-vacuous)", distinct);
    }

    /* 7b: the retrigger one-shot is CONSUMED, in the array */
    ok = 1;
    for (v = 0; v < EB_NUM_VOICES; ++v)
        if (*(const float *)ebdev_at(101504u + 32u * (unsigned)v) == 1.0f) ok = 0;
    pcheck("step 7b: the aux retrigger one-shot is consumed in the cell array", ok);

    /* 7c: sounding voices re-seed; at-rest voices are refreshed FIELD-WISE and
     * keep their increment */
    ok = 1;
    for (v = 0; v < 3; ++v) if (RS.dco_live_seeded[v]) ok = 0;
    pcheck("step 7c: dco_live_seeded cleared for the SOUNDING voices", ok);
    ok = 1;
    for (v = 3; v < EB_NUM_VOICES; ++v) {
        if (RS.dco_live[v].inc != 1.25f + (float)v) ok = 0;      /* still free-running */
        if (RS.dco_live[v].lvl_saw == -7.0f) ok = 0;             /* but refreshed */
    }
    pcheck("step 7c: at-rest voices keep inc and take the new per-recall fields", ok);

    /* 8: the generation counter moved */
    pcheck("step 8: the publish generation advanced", REC.gen == 1);
    pcheck("no cell was unmapped during the publish",
           EBDEV_S.miss == REC.unmapped_at_publish);

    printf("PUBLISH CONTRACT: %d of %d checks ok\n", PUB_RUN - PUB_FAIL, PUB_RUN);
    return PUB_FAIL ? 1 : 0;
}
#endif

#ifndef GATE_DEV
/* ===================================================== THE RECORD-BYTE SCAN
 *
 * WHICH RECORD POSITIONS CHANGE THE RECALLED COEFFICIENTS?
 *
 * The compact patch format (engine_b/eb_patch.h) carries a fixed list of blob
 * bytes. That list was derived by a scan that hashed AUDIO CELLS on the
 * FACTORY BANK, so a parameter that is constant across the bank was invisible
 * to it -- which is exactly how it shipped five bytes short. The answer is not
 * to add five bytes and hope; it is to MEASURE the set mechanically and let
 * the format's own coverage check assert against it.
 *
 * Method: for each record position, write four different values over SIX base
 * patches (three factory, three with every nibble randomised), rebuild the
 * coefficients and the master coefficients, and record the position if any
 * byte of either moved. Four values, not one, because a single probe value can
 * land on the same clamped result as the original -- BEND GAIN's index clamp
 * is exactly that trap. Randomised bases, because a parameter can be gated by
 * another parameter no factory patch moves (DELAY TYPE 4 is the standing
 * example in this repo).
 */
static eb_render_coefs SC_RC, SC_RC0;
static eb_master_coef  SC_MC, SC_MC0;

static void scan_build(unsigned char *rec_bank, int p)
{
    boot(0);
    juno_bank_apply(ST, rec_bank, p);
    juno_driver_seed_voices(ST);
    juno_apply_unison_spread(ST, juno_bank_assign(rec_bank, p));
    juno_apply_condition(ST, juno_bank_condition(rec_bank, p));
    juno_apply_lfo_tempo(ST, juno_bank_lfo_rate_byte(rec_bank, p), 128.0f);
    eb_render_coefs_build(ST, &SC_RC);
    eb_master_coefs_build(ST, &MC);
    memcpy(&SC_MC, &MC, sizeof MC);
}

static int scan_section(const unsigned char *bank, long bl, const char *outpath)
{
    static const unsigned char VAL[4] = { 0x00u, 0x03u, 0x0Cu, 0x7Fu };
    unsigned char *wb = (unsigned char *)malloc((size_t)bl);
    unsigned char *base[6];
    int nbase = 6, b, i, k, n = 0;
    unsigned s = 7u;
    FILE *of;
    int lo = 16, hi = 4096;          /* juno_bank_apply reads record 30..3952 */

    memcpy(wb, bank, (size_t)bl);
    for (b = 0; b < 6; ++b) {
        base[b] = wb + BANK_HEADER + (long)(b * 7) * BANK_STRIDE;
        if (b >= 3) {
            for (i = 16; i < BANK_STRIDE; ++i) {
                s = s * 1103515245u + 12345u;
                base[b][i] = (unsigned char)((s >> 16) & 0xFF);
            }
        }
    }
    of = fopen(outpath, "w");
    for (i = lo; i < hi; ++i) {
        int moved = 0;
        for (b = 0; b < nbase && !moved; ++b) {
            unsigned char orig = base[b][i];
            scan_build(wb, b * 7);
            memcpy(&SC_RC0, &SC_RC, sizeof SC_RC);
            memcpy(&SC_MC0, &SC_MC, sizeof SC_MC);
            for (k = 0; k < 4 && !moved; ++k) {
                if (VAL[k] == orig) continue;
                base[b][i] = VAL[k];
                scan_build(wb, b * 7);
                if (memcmp(&SC_RC0, &SC_RC, sizeof SC_RC) ||
                    memcmp(&SC_MC0, &SC_MC, sizeof SC_MC)) moved = 1;
            }
            base[b][i] = orig;
        }
        if (moved) { fprintf(of, "%d\n", i); ++n; }
    }
    fclose(of);
    printf("RECORD SCAN: %d of %d positions in [%d,%d) change the recalled "
           "coefficients\n", n, hi - lo, lo, hi);
    return 0;
}
#endif

/* ----------------------------------------------------------- one case */
static void run_case(const unsigned char *bank, int p, int r, int seq,
                     int synth, unsigned seed)
{
    boot(r);
    if (seq != SEQ_COLD) {
        recall(bank, (p + 1) % 64, synth, &seed);
        notes();
        /* the previous patch's coefficient set is BUILT, exactly as the
         * firmware would: a warm case in which nobody ever consumed patch A
         * is not a warm case. */
        eb_render_coefs_build(ST, &RC);
        eb_master_coefs_build(ST, &MC);
        eb_render_state_seed(ST, &RS);
        eb_render_events_mirror(ST, &RS);
    }
    if (seq == SEQ_EDIT) {
        edit(35, 200);      /* VCF CUTOFF FREQ */
        edit(54, 90);       /* PORTAMENTO  -- writes scatter cell 592        */
        edit(38, 111);      /* HPF CUTOFF  -- the 4-cell joint leaf           */
    }
    recall(bank, p, synth, &seed);
    notes();
#if defined(GATE_DEV) && defined(GATE_TOOTH_ULP)
    /* THE 2026-08-11 GATE'S SECOND TOOTH, reproduced. Move ONE per-voice cell
     * on ONE voice by ONE ULP. It is the smallest defect the scatter can carry
     * and it is the shape a wrong stride or a swapped row would make. Voice 3,
     * scatter slot 6 = cell 5520 (CONDITION tune, read at eb_coefs.c:213).
     * If a 1-ULP move on one voice does not reach the compared bytes, the
     * scatter is not being read and every scatter PASS is decoration. */
    if (EBDEV_NV > 3) {
        union { float f; unsigned u; } z;
        z.f = EBDEV_S.scat[3][6];
        z.u ^= 1u;
        EBDEV_S.scat[3][6] = z.f;
    }
#endif
    eb_render_coefs_build(ST, &RC);
    eb_master_coefs_build(ST, &MC);
    eb_render_state_seed(ST, &RS);
    eb_render_events_mirror(ST, &RS);
}

/* ================================================================== main */
int main(int argc, char **argv)
{
    FILE *f, *o;
    long bl;
    unsigned char *bank, *wb;
    int trial, r, p, seq;
    unsigned long ncase = 0;
    long only = -1;                       /* --case N: dump one case in full */

    if (argc < 4) {
        fprintf(stderr, "usage: %s <bank> <out.bin> <boot.bin> [case]\n", argv[0]);
        return 2;
    }
    if (argc > 4) {
        if (strcmp(argv[4], "publish") == 0) only = -2;
        else if (strcmp(argv[4], "scan") == 0) only = -3;
        else only = strtol(argv[4], (char **)0, 10);
    }
    f = fopen(argv[1], "rb");
    if (!f) { perror(argv[1]); return 2; }
    fseek(f, 0, SEEK_END); bl = ftell(f); fseek(f, 0, SEEK_SET);
    bank = (unsigned char *)malloc((size_t)bl);
    if (fread(bank, 1, (size_t)bl, f) != (size_t)bl) return 2;
    fclose(f);
    wb = (unsigned char *)malloc((size_t)bl);

#ifndef GATE_DEV
    ST = (unsigned char *)malloc(JUNO_STATE_BYTES);
#endif

#ifdef GATE_DEV
    f = fopen(argv[3], "rb");
    if (!f) { perror(argv[3]); return 2; }
    if (fread(BOOT, 1, sizeof BOOT, f) != sizeof BOOT) {
        fprintf(stderr, "BOOT: short read (want %u)\n", (unsigned)sizeof BOOT);
        return 2;
    }
    fclose(f);
    {   long bad = ebdev_selftest();
        printf("MAP SELFTEST chain vs table: %s\n",
               bad == 0 ? "0 disagreements" :
               bad < 0  ? "SKIPPED (instrumented build IS the table)" : "FAILED");
        if (bad > 0) { printf("*** MAP CHAIN != MAP TABLE, %ld offsets ***\n", bad); return 1; }
    }
    ebdev_reset_counters();
#else
    {   /* the boot image, one per rate, in the order the dev half reads it */
        FILE *b = fopen(argv[3], "wb");
        static float scat[8][EBDEV_NSCAT];
        static const unsigned *SC = EBDEV_SCATTAB;
        int i, v, k;
        static unsigned char v0[EBDEV_VTILE], sg[EBDEV_SEGBYTES];
        for (r = 0; r < NRATE; ++r) {
            boot(r);
            memcpy(v0, ST, EBDEV_VTILE);
            for (i = 0; i < EBDEV_NSEG; ++i)
                memcpy(sg + EBDEV_SEGTAB[i].at, ST + EBDEV_SEGTAB[i].lo,
                       EBDEV_SEGTAB[i].hi - EBDEV_SEGTAB[i].lo);
            for (v = 0; v < 8; ++v)
                for (k = 0; k < EBDEV_NSCAT; ++k)
                    scat[v][k] = JF(ST, (unsigned)v * JUNO_VOICE_MAIN_STRIDE + SC[k]);
            fwrite(v0, 1, sizeof v0, b);
            fwrite(sg, 1, sizeof sg, b);
            fwrite(scat, 1, sizeof scat, b);
        }
        fclose(b);
    }
#endif

#ifdef GATE_DEV
    if (only == -2) return publish_section(bank);
    if (only == -3) { printf("record scan is host-only\n"); return 0; }
#else
    if (only == -2) { printf("publish section is device-only\n"); return 0; }
    if (only == -3) return scan_section(bank, bl, argv[2]);
#endif

    o = fopen(argv[2], "wb");
    if (!o) { perror(argv[2]); return 2; }

    for (trial = 0; trial < 2; ++trial) {
        unsigned seed = 4242u;
        memcpy(wb, bank, (size_t)bl);
        if (trial == 1) {
            /* the synthetic bank: every record nibble randomised. A parameter
             * that is constant across the factory bank is invisible to a
             * factory-only gate -- which is exactly how the compact patch
             * format shipped five bytes short. */
            unsigned s = 99991u;
            for (p = 0; p < 64; ++p) {
                unsigned char *rr = wb + BANK_HEADER + (long)p * BANK_STRIDE;
                long i;
                for (i = 16; i < BANK_STRIDE; ++i) {
                    s = s * 1103515245u + 12345u;
                    rr[i] = (unsigned char)((s >> 16) & 0xFF);
                }
            }
        }
        for (seq = 0; seq < NSEQ; ++seq)
            for (r = 0; r < NRATE; ++r)
                for (p = 0; p < 64; ++p) {
                    run_case(wb, p, r, seq, trial, seed + (unsigned)(p * 7 + r));
                    if (only >= 0) {
                        /* single-case dump mode: the WHOLE render state, so a
                         * hash mismatch can be localised to a byte */
                        if ((long)ncase == only) {
                            fwrite(&RC, 1, sizeof RC, o);
                            fwrite(&MC, 1, sizeof MC, o);
                            fwrite(&RS, 1, sizeof RS, o);
                            fclose(o);
                            printf("dumped case %ld (RC+MC+RS = %u B)\n", only,
                                   (unsigned)(sizeof RC + sizeof MC + sizeof RS));
                            return 0;
                        }
                        ++ncase;
                        continue;
                    }
                    fwrite(&RC, 1, sizeof RC, o);
                    fwrite(&MC, 1, sizeof MC, o);
                    /* eb_render_state is ~736 KB (the chorus BBD snapshot is
                     * most of it), so 1,152 cases of it is 848 MB per side.
                     * It is hashed instead, and --case N dumps one in full. */
                    {   uint64_t h = fnv(&RS, sizeof RS);
                        fwrite(&h, 1, sizeof h, o); }
                    ++ncase;
                }
    }
    fclose(o);

    printf("%s half done. %lu cases  (%d seq x %d rates x 64 patches x 2 banks)\n",
#ifdef GATE_DEV
           "DEVICE",
#else
           "HOST",
#endif
           ncase, NSEQ, NRATE);
    printf("record: RC %u + MC %u + hash(RS %u) = %u B/case; EB_NUM_VOICES=%d\n",
           (unsigned)sizeof RC, (unsigned)sizeof MC, (unsigned)sizeof RS,
           (unsigned)(sizeof RC + sizeof MC + 8), EB_NUM_VOICES);
    for (seq = 0; seq < NSEQ; ++seq) (void)SEQNAME[seq];

#ifdef GATE_DEV
    printf("cell array = %u B (NV=%d, VTILE %u, SEG %u, SCAT %dx%d)\n",
           (unsigned)sizeof(ebdev_state), EBDEV_NV, EBDEV_VTILE, EBDEV_SEGBYTES,
           EBDEV_NV, EBDEV_NSCAT);
    printf("unmapped accesses = %lu   distinct offsets = %d\n",
           EBDEV_S.miss, EBDEV_NMISS);
    if (EBDEV_NMISS) {
        int j;
        FILE *mf = fopen("devrecall_miss.txt", "w");
        for (j = 0; j < EBDEV_NMISS; ++j) {
            if (j < 12) printf("   UNMAPPED %lu\n", EBDEV_MISSLIST[j]);
            if (mf) fprintf(mf, "%lu\n", EBDEV_MISSLIST[j]);
        }
        if (mf) fclose(mf);
        printf("   (full list in devrecall_miss.txt)\n");
    }
#ifdef EBDEV_INSTRUMENT
    {   int j, hot = 0;
        printf("SEGMENT COVERAGE: ");
        for (j = 0; j < EBDEV_NSEG; ++j) {
            if (EBDEV_SEGHIT[j]) ++hot;
            else printf("[%d:%u cold] ", j, EBDEV_SEGTAB[j].lo);
        }
        printf("\n  %d of %d segments touched; tile hits %lu scatter %lu segment %lu\n",
               hot, EBDEV_NSEG, EBDEV_VHIT, EBDEV_SHIT, EBDEV_GHIT);
    }
#endif
    if (EBDEV_S.miss) { printf("*** UNMAPPED CELLS -- THE MAP IS INCOMPLETE ***\n"); return 1; }
#endif
    return 0;
}

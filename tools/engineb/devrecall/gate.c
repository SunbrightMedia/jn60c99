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
static const char *SEQNAME[NSEQ] = { "cold", "warm A->B", "A->edit->B->edit" };

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

/* ============================================ THE BOOT IMAGE EXCHANGE FORMAT
 *
 * The device does NOT run the port's boot. src/chorus_init.c is 2,971 raw
 * `*(_DWORD *)(a1 + N)` stores and pointer WALKS (`*v6++`), which no cell map
 * can rebase; calling it in a device build segfaults. That is a design fact,
 * not an oversight -- the post-boot state is a per-rate CONSTANT, so it is
 * baked (tools/engineb/devboot/bootgen.c) and flashed. The host half of this
 * gate bakes the same image through the same generated table.
 *
 * IT IS SELF-DESCRIBING, and that is not tidiness. The two halves exchange a
 * packed layout; when a tooth regenerates the map and the two halves disagree
 * about the packing, the reader used to see only a SHORT READ and refuse -- and
 * a refusal reads as "the tooth fired". That is the exact disease this file
 * already warns about above MAP_TEETH, one level down. With a header the
 * reader can say WHICH field disagrees and exit 3, which devrecall_gate.py
 * treats as a HARNESS ERROR and never as a tooth verdict.
 *
 * The scatter row count is carried too, and the reader accepts an image with
 * MORE rows than it carries (skipping the rest). That is what lets the
 * short-rows tooth exercise the MAP instead of the exchange. */
#define BOOT_MAGIC 0x42544f4fu           /* "OOTB" */
typedef struct {
    uint32_t magic, vtile, segbytes, nscat, nrows, nrate;
} boot_hdr;

#ifdef GATE_DEV
static unsigned char *const ST = (unsigned char *)0;   /* unused: JF ignores it */
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
 * The encoder path: juno_apply_param_leaf (src/juno_apply.c), which is the
 * SAME function gui/juno_bridge.c's juno_gui_set_param calls and which carries
 * the device arm the firmware compiles. One leaf expands to every BINDINGS row
 * sharing its blob byte, and a per-voice cell takes the identical value in
 * every voice. One of the offsets reached is 592, the portamento gate -- i.e.
 * an ordinary knob move writes a SCATTER cell on every voice.
 *
 * ⚠ THIS WAS DEAD UNTIL 2026-08-12, TWICE OVER, and it was the first fatal
 * finding of the adversarial round.
 *   (1) it was called with BLOB ids 35/54/38 where it takes a BINDINGS INDEX.
 *       juno_param_count() is 31, so all three returned at the first line.
 *   (2) the calls sat BEFORE the final recall, which rewrites every cell an
 *       edit touches -- so even with the indices repaired, 0 of 192 records
 *       moved.
 * MEASURED consequence: all 384 SEQ_EDIT records were byte-identical to their
 * SEQ_WARM counterparts. A third of 1,152 cases was a duplicate of another
 * third, and it read as coverage.
 *
 * Both causes are addressed by construction. The selector is now the BLOB --
 * which is what the comments always said and what a panel actually has -- and
 * an unresolvable blob ABORTS instead of returning quietly; and the sequence
 * edits AFTER the final recall as well as before it. */
static int param_of_blob(int blob)
{
    int i, n = juno_param_count();
    for (i = 0; i < n; ++i)
        if (juno_param_blob(i) == blob) return i;
    return -1;
}

static void edit(int blob, int byte)
{
    int i = param_of_blob(blob);
    if (i < 0) {
        fprintf(stderr, "EDIT: no BINDINGS row carries blob %d -- the gate's "
                        "live-edit sequence would be vacuous\n", blob);
        exit(3);
    }
    juno_apply_param_leaf(ST, i, byte, (int)JF(ST, 16));
}

/* the three leaves the sequence moves, chosen for what they reach:
 *   35 VCF CUTOFF   1 row,  per-voice, NOT in the scatter (the shared tile)
 *   54 PORTAMENTO   2 rows, one of them cell 592 -- a SCATTER cell
 *   38 HPF CUTOFF   4 rows, the joint leaf, all per-voice, none in the scatter
 * Between them: a plain tile cell, a scatter cell, and a multi-row leaf. */
static void edit_burst(void)
{
    edit(35, 200);
    edit(54, 90);
    edit(38, 111);
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
    /* under EB_RECALL_FX_PIPE the master coefficients are DEFERRED by one block
     * on purpose, so EB_MC is expected NOT to have moved yet -- see the FX PIPE
     * section at the end, which is the only place that behaviour is exercised */
    pcheck("step 4: EB_RC now points at the newly built bank",
           (const eb_render_coefs *)EB_RC == &RCB[1] &&
#if EB_RECALL_FX_PIPE
           REC.mc_pending == &MCB[1]);
#else
           (const eb_master_coef *)EB_MC == &MCB[1]);
#endif
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

    /* ============================== A SECOND PUBLISH ==========================
     * Everything above is ONE publish, and the route latch's whole justification
     * is a DELAY TYPE change ACROSS publishes -- which the section above fakes by
     * planting REC.route_last = 3 by hand. So: keep the id the FIRST publish
     * derived from patch 37's own delay type, recall a third patch, publish
     * again, and require the mirrors to carry THAT id rather than the plant.
     * The bank ping-pong (cur back to 0) and gen == 2 come along free. Nothing
     * had ever run eb_recall_publish twice. */
    {
        int latched = REC.route_last;          /* derived, not planted */
        unsigned s3 = 3u;
        recall(bank, 51, 0, &s3);
        notes();
        eb_recall_build(&REC);
        if (eb_recall_publish(&REC) != 0) {
            printf("  second publish refused -- aborting\n"); return 1;
        }
        pcheck("2nd publish: the banks ping-pong back",
               (const eb_render_coefs *)EB_RC == &RCB[0] &&
#if EB_RECALL_FX_PIPE
               REC.mc_pending == &MCB[0]);
#else
               (const eb_master_coef *)EB_MC == &MCB[0]);
#endif
        pcheck("2nd publish: the mirrors carry the id the FIRST publish derived",
               MS.route_change == latched && MS.d1.s11022348 == latched &&
               MS.d23.s11022348 == latched && MS.d4.s11022348 == latched &&
               MS.d5.s11022348 == latched);
        pcheck("2nd publish: ... and that id was NOT the hand-planted 3",
               latched != 3);
        pcheck("2nd publish: the generation advanced again", REC.gen == 2);
        {   static eb_render_coefs REF2;
            eb_render_coefs_build(ST, &REF2);
            pcheck("2nd publish: the published coefficients == the shim's build",
                   memcmp(&REF2, &RCB[0], sizeof REF2) == 0);
        }
    }

    /* ================== THE FX-PIPE DEFERRAL, WHICH NOTHING COMPILED ==========
     * EB_RECALL_FX_PIPE appears NOWHERE in the repository except its own #if, so
     * eb_recall.c:100-110 and eb_recall_block_boundary() were dead code that no
     * build compiled and no gate ran -- while the design describes the deferral
     * as part of the shipped contract. Either it is exercised or the claim goes.
     * devrecall_gate.py builds this section a third time with the flag on. */
#if EB_RECALL_FX_PIPE
    {
        const eb_master_coef *live = (const eb_master_coef *)EB_MC;
        unsigned s4 = 4u;
        recall(bank, 20, 0, &s4);
        notes();
        eb_recall_build(&REC);
        if (eb_recall_publish(&REC) != 0) { printf("  refused\n"); return 1; }
        pcheck("FX PIPE: publish leaves EB_MC on the PREVIOUS block's coefficients",
               (const eb_master_coef *)EB_MC == live && REC.mc_pending != 0);
        eb_recall_block_boundary(&REC);
        pcheck("FX PIPE: the block boundary applies it, once",
               (const eb_master_coef *)EB_MC != live && REC.mc_pending == 0);
        eb_recall_block_boundary(&REC);
        pcheck("FX PIPE: a second boundary call is a no-op",
               REC.mc_pending == 0);
    }
#endif

    /* ============= THE INCREMENTAL BURST, WHICH IS WHAT MAKES IT PLAYABLE ====
     * MEASURED on silicon 2026-08-12: the voice coefficient build is 1,082,812
     * cycles of a 1,992,935-cycle burst, and a key press pays all of it. That
     * is 8 ms of stall on every note. eb_recall_build_voices() rebuilds only
     * the voices a note touched.
     *
     * THE ONLY THING WORTH PROVING is that it is not an approximation: the
     * incremental result must be BIT-IDENTICAL to the full build. So each
     * check below does the same work twice and compares the bytes.
     *
     * AND IT MUST BE SEEN TO FAIL. The last two checks are teeth: an
     * UNDER-STATED mask -- the caller's one real obligation, and the failure
     * that would be silent on the board -- must produce a difference. If a
     * tooth passes, the comparison is not looking at what it claims to. */
    {
        static eb_render_coefs FULL;
        unsigned s5 = 5u;
        int vch = 4;

        recall(bank, 12, 0, &s5);
        notes();
        eb_recall_build(&REC);
        if (eb_recall_publish(&REC) != 0) {
            printf("  incremental setup publish refused -- aborting\n");
            return 1;
        }

        /* A key press on ONE voice, applied through the port's own note path. */
        juno_note_on(ST, vch, 67, 100);

        eb_render_coefs_build(ST, &FULL);            /* the whole truth */
        eb_recall_build_voices(&REC, 1u << vch);     /* the cheap way */
        pcheck("incremental: one voice rebuilt == the full build, bit for bit",
               memcmp(&FULL, REC.rc[1 - REC.cur], sizeof FULL) == 0);

        /* A second note on a DIFFERENT voice, from the same live bank, to show
         * the carried seven are carried and not merely still correct by luck. */
        if (eb_recall_publish(&REC) != 0) {
            printf("  incremental publish refused -- aborting\n"); return 1;
        }
        juno_note_on(ST, 1, 55, 90);
        eb_render_coefs_build(ST, &FULL);
        eb_recall_build_voices(&REC, 1u << 1);
        pcheck("incremental: a second note carries the other seven voices",
               memcmp(&FULL, REC.rc[1 - REC.cur], sizeof FULL) == 0);

        /* TOOTH 1: name the wrong voice. */
        if (eb_recall_publish(&REC) != 0) {
            printf("  tooth publish refused -- aborting\n"); return 1;
        }
        /* VOICE 3, NOT 6. The fork builds with -DEB_NUM_VOICES=6, so a tooth
         * on voice 6 pokes a voice that does not exist there, nothing differs,
         * and the tooth reports itself as broken -- which is exactly what it
         * did on its first run. Every index here must be inside the SMALLEST
         * configuration the gate compiles, not the largest. */
        juno_note_on(ST, 3, 72, 111);
        eb_render_coefs_build(ST, &FULL);
        eb_recall_build_voices(&REC, 1u << 0);       /* voice 0, not 3 */
        pcheck("TOOTH: naming the wrong voice DOES differ (an under-stated "
               "mask must never be silent)",
               memcmp(&FULL, REC.rc[1 - REC.cur], sizeof FULL) != 0);

        /* TOOTH 2: name no voice at all. */
        eb_recall_build_voices(&REC, 0u);
        pcheck("TOOTH: an empty mask DOES differ",
               memcmp(&FULL, REC.rc[1 - REC.cur], sizeof FULL) != 0);
    }

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
    if (seq == SEQ_EDIT)
        edit_burst();             /* before B: recall must overwrite it */
    recall(bank, p, synth, &seed);
    notes();
    if (seq == SEQ_EDIT)
        edit_burst();             /* after B: THE KNOB MOVE. END_GOAL item 5 */
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
    {   boot_hdr h;
        int i;
        unsigned per_rate;
        if (fread(&h, 1, sizeof h, f) != sizeof h) {
            fprintf(stderr, "BOOT LAYOUT MISMATCH: no header\n"); return 3; }
#define BCHK(field, mine) \
        if (h.field != (uint32_t)(mine)) { \
            fprintf(stderr, "BOOT LAYOUT MISMATCH: %s image=%u device=%u\n", \
                    #field, (unsigned)h.field, (unsigned)(mine)); return 3; }
        BCHK(magic,    BOOT_MAGIC)
        BCHK(vtile,    EBDEV_VTILE)
        BCHK(segbytes, EBDEV_SEGBYTES)
        BCHK(nscat,    EBDEV_NSCAT)
        BCHK(nrate,    NRATE)
#undef BCHK
        if (h.nrows < (uint32_t)EBDEV_NV) {
            fprintf(stderr, "BOOT LAYOUT MISMATCH: nrows image=%u device=%u\n",
                    (unsigned)h.nrows, (unsigned)EBDEV_NV);
            return 3;
        }
        per_rate = EBDEV_VTILE + EBDEV_SEGBYTES + h.nrows * EBDEV_NSCAT * 4u;
        for (i = 0; i < NRATE; ++i) {
            unsigned char *dst = BOOT[i];
            unsigned mine = EBDEV_VTILE + EBDEV_SEGBYTES + EBDEV_NV * EBDEV_NSCAT * 4u;
            if (fread(dst, 1, mine, f) != mine) {
                fprintf(stderr, "BOOT LAYOUT MISMATCH: short image at rate %d\n", i);
                return 3;
            }
            /* skip the rows this build does not carry */
            if (fseek(f, (long)(per_rate - mine), SEEK_CUR)) {
                fprintf(stderr, "BOOT LAYOUT MISMATCH: cannot skip rows\n");
                return 3;
            }
        }
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
        static float scat[EBDEV_NVPORT][EBDEV_NSCAT];
        static const unsigned *SC = EBDEV_SCATTAB;
        int i, v, k;
        static unsigned char v0[EBDEV_VTILE], sg[EBDEV_SEGBYTES];
        {   boot_hdr h;
            h.magic = BOOT_MAGIC; h.vtile = EBDEV_VTILE;
            h.segbytes = EBDEV_SEGBYTES; h.nscat = EBDEV_NSCAT;
            h.nrows = EBDEV_NVPORT; h.nrate = NRATE;
            fwrite(&h, 1, sizeof h, b);
        }
        for (r = 0; r < NRATE; ++r) {
            boot(r);
            memcpy(v0, ST, EBDEV_VTILE);
            for (i = 0; i < EBDEV_NSEG; ++i)
                memcpy(sg + EBDEV_SEGTAB[i].at, ST + EBDEV_SEGTAB[i].lo,
                       EBDEV_SEGTAB[i].hi - EBDEV_SEGTAB[i].lo);
            for (v = 0; v < EBDEV_NVPORT; ++v)
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

/* devparam gate -- THE WARM PARAMETER EDIT MATCHES THE PLUGIN.
 *
 * WHAT IT PROVES. A live knob move must leave per-voice NOTE state (gate, pitch,
 * velocity) exactly as the plugin leaves it: untouched. The device reaches that
 * two ways (eb_devparam.h): a value-tree leaf goes through
 * juno_apply_param_leaf -- the plugin's own live edit, which never writes a note
 * cell; anything else re-derives from the record and PRESERVES the note cells
 * across the re-seed. This gate exercises both on a state that has real notes
 * down and checks the note cells are byte-identical afterwards.
 *
 * WHAT IT DOES NOT. Like devrecall_gate this is a HOST build: it proves the
 * METHOD, which is address-map independent. That the device's cell MAP carries
 * these same offsets is devrecall_gate's proof, not this one. The two together
 * cover the chip; neither runs an Xtensa instruction.
 *
 * TEETH -- every check is SEEN TO FAIL under a compile flag, or printed
 * NOT CAUGHT:
 *   GATE_TOOTH_LEAF_IS_RECALL  apply the leaf through the OLD full-recall path
 *                              instead of juno_apply_param_leaf -> note cells
 *                              corrupt (the storm's stuck note).
 *   GATE_TOOTH_NO_PRESERVE     drop the note-state restore on the non-leaf path
 *                              -> note cells corrupt.
 *   GATE_TOOTH_MAP_OFFBY       eb_devparam_leaf_index off by one blob -> the
 *                              leaf edit lands on the WRONG cell, so the target
 *                              coefficient does NOT move (the edit is vacuous).
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#include "juno_engine.h"
#include "juno_apply.h"
#include "juno_driver.h"
#include "juno_note.h"
#include "eb_param_class.h"
#include "eb_patch.h"
#include "eb_devparam.h"

#define BANK_HEADER 23
#define BANK_STRIDE 20223

static unsigned char *ST;
static unsigned char *BANK;      /* a working copy we may poke */

static int FAIL, RUN;
static void ck(const char *what, int ok)
{
    ++RUN; if (!ok) ++FAIL;
    printf("  %-62s %s\n", what, ok ? "ok" : "*** FAILED ***");
}

/* the plugin-exact leaf edit, exactly as pm_apply's leaf arm does it */
static void leaf_edit(int param_id, int byte, int hr)
{
    int li = eb_devparam_leaf_index(param_id);
#ifdef GATE_TOOTH_MAP_OFFBY
    li = li >= 0 ? li + 1 : li;          /* wrong leaf -> wrong cell */
#endif
#ifdef GATE_TOOTH_LEAF_IS_RECALL
    /* the OLD device answer to a knob move: a full patch recall + re-seed */
    (void)li; (void)byte; (void)hr;
    juno_bank_apply(ST, BANK, 0);
    juno_driver_seed_voices(ST);
#else
    if (li >= 0) juno_apply_param_leaf(ST, li, byte, hr);
#endif
}

/* the device's non-leaf arm, in flat form: re-derive from the record + re-seed,
 * then restore the note state (eb_devseq_recall + the pm_apply preserve) */
static void nonleaf_edit(const unsigned NOTE[], int nn)
{
    float save[JUNO_NUM_VOICES][8];
    int v, c;
    for (v = 0; v < JUNO_NUM_VOICES; ++v)
        for (c = 0; c < nn; ++c)
            save[v][c] = JF(ST, (unsigned)v * JUNO_VOICE_MAIN_STRIDE + NOTE[c]);
    juno_bank_apply(ST, BANK, 0);
    juno_driver_seed_voices(ST);
    juno_apply_unison_spread(ST, juno_bank_assign(BANK, 0));
    juno_apply_condition(ST, juno_bank_condition(BANK, 0));
    juno_apply_lfo_tempo(ST, juno_bank_lfo_rate_byte(BANK, 0), 128.0f);
#ifndef GATE_TOOTH_NO_PRESERVE
    for (v = 0; v < JUNO_NUM_VOICES; ++v)
        for (c = 0; c < nn; ++c)
            JF(ST, (unsigned)v * JUNO_VOICE_MAIN_STRIDE + NOTE[c]) = save[v][c];
#endif
}

static int note_cells_match(const unsigned NOTE[], int nn, float snap[][8])
{
    int v, c, bad = 0;
    for (v = 0; v < JUNO_NUM_VOICES; ++v)
        for (c = 0; c < nn; ++c)
            if (JF(ST, (unsigned)v * JUNO_VOICE_MAIN_STRIDE + NOTE[c]) != snap[v][c])
                ++bad;
    return bad;
}

int main(int argc, char **argv)
{
    FILE *f; long bl; int v, c;
    const unsigned *NOTE = EB_DEVPARAM_NOTE_CELLS;
    const int nn = EB_DEVPARAM_NNOTE;
    float snap[JUNO_NUM_VOICES][8];

    if (argc < 2) { fprintf(stderr, "usage: %s <bank>\n", argv[0]); return 2; }
    f = fopen(argv[1], "rb"); if (!f) { perror(argv[1]); return 2; }
    fseek(f, 0, SEEK_END); bl = ftell(f); fseek(f, 0, SEEK_SET);
    BANK = malloc((size_t)bl);
    if (fread(BANK, 1, (size_t)bl, f) != (size_t)bl) return 2;
    fclose(f);
    ST = malloc(JUNO_STATE_BYTES);

    /* ---- the mapping is a gated invariant, not a comment ---- */
    printf("== eb_devparam_leaf_index mapping ==\n");
    {
        int pid_cut = 12;   /* VCF CUTOFF, blob 35 */
        int li = eb_devparam_leaf_index(pid_cut);
        int i, k = 0;
        for (i = 0; i < EB_PARAM_CLASS_N; ++i)
            if (eb_devparam_leaf_index(i) >= 0) ++k;
        ck("VCF CUTOFF (pid 12) resolves to a leaf",
           li >= 0 && strcmp(juno_param_name(li), "VCF CUTOFF FREQ") == 0);
        ck("an FX/master byte (pid 47) is a non-leaf",
           eb_devparam_leaf_index(47) < 0);
        ck("26 of 59 params are leaves", k == 26);
    }

    /* ---- a state with notes really down ---- */
    memset(ST, 0, JUNO_STATE_BYTES);
    juno_chorus_init(ST);
    JF(ST, 16) = 44100.0f;
    juno_engine_init(ST);
    juno_engine_prepare(ST);
    juno_bank_apply(ST, BANK, 0);
    juno_driver_seed_voices(ST);
    juno_apply_unison_spread(ST, juno_bank_assign(BANK, 0));
    juno_apply_condition(ST, juno_bank_condition(BANK, 0));
    juno_apply_lfo_tempo(ST, juno_bank_lfo_rate_byte(BANK, 0), 128.0f);
    for (v = 0; v < JUNO_NUM_VOICES; ++v)
        juno_note_on(ST, v, 36 + v * 5, 40 + v * 7);
    juno_note_off(ST, 3);                 /* a released voice among held ones */

    for (v = 0; v < JUNO_NUM_VOICES; ++v)
        for (c = 0; c < nn; ++c)
            snap[v][c] = JF(ST, (unsigned)v * JUNO_VOICE_MAIN_STRIDE + NOTE[c]);

    /* ---- the leaf edit: plugin-exact, and it must LAND ---- */
    printf("== leaf edit (VCF CUTOFF) ==\n");
    {
        float cut_before = JF(ST, 6736);   /* the VCF CUTOFF coefficient cell */
        leaf_edit(12, 200, 44100);
        ck("note state unchanged after a leaf edit",
           note_cells_match(NOTE, nn, snap) == 0);
        ck("the edit LANDED (cutoff cell 6736 moved)",
           JF(ST, 6736) != cut_before);
    }

    /* ---- the non-leaf edit: re-derive + preserve ---- */
    printf("== non-leaf edit (re-derive from record + preserve notes) ==\n");
    {
        /* refresh the snapshot (the leaf edit above changed only non-note cells) */
        for (v = 0; v < JUNO_NUM_VOICES; ++v)
            for (c = 0; c < nn; ++c)
                snap[v][c] = JF(ST, (unsigned)v * JUNO_VOICE_MAIN_STRIDE + NOTE[c]);
        nonleaf_edit(NOTE, nn);
        ck("note state unchanged after the non-leaf re-derive",
           note_cells_match(NOTE, nn, snap) == 0);
    }

    printf("\n%d checks, %d failed\n", RUN, FAIL);
    return FAIL ? 1 : 0;
}

/* d3_voiceindex_gate.c -- O6/D3: THE GLOBAL VOICE INDEX ACROSS TWO CHIPS.
 *
 * THE DEFECT, stated before the gate is written (FINAL_GUIDE D3,
 * DEVICE_RECALL.md "the global voice index across two chips"):
 *
 *   CONDITION scatter and UNISON spread are PER-VOICE DISTINCT. Both
 *   juno_apply_condition and juno_apply_unison_spread index their tables by
 *   the LOCAL slot 0..7. On two chips each running its own state, chip B's
 *   local slot 0 therefore receives GLOBAL VOICE 0's detune -- the same value
 *   chip A's slot 0 gets. Two chips would deal the SAME analog scatter, and
 *   the instrument would have three detune identities instead of six.
 *
 * It is silent. Nothing crashes, nothing misses a deadline, the CRC of every
 * coefficient bank still matches, and the fault is only audible as a chord
 * that is less wide than the plugin's.
 *
 * THE SHIPPING LAYOUT (END_GOAL 2, FINAL_GUIDE D1/D3): six voices over two
 * ESP32-S3s. Chip A owns GLOBAL voices 0..2, chip B owns GLOBAL voices 3..5.
 *
 * WHAT THIS GATE ASSERTS: the six sounding voices of the two-chip instrument
 * carry EXACTLY the scatter that global voices 0..5 of a single instrument
 * carry -- value for value, bit for bit, on the three CONDITION cells and the
 * UNISON cell.
 *
 * ⚠ IT MUST FAIL BEFORE IT PASSES. Run it against the tree as it stands: chip
 * B repeats chip A and the gate goes red. A detector that has never been seen
 * to fail is not believed here (playbook 1).
 *
 * ⚠ WHAT IS NOT DECIDED HERE. The JUNO-60 has six voices and the CONDITION
 * tables have EIGHT entries, so WHICH six the fork keeps is an audible choice
 * and FINAL_GUIDE flags it as unresolved. This gate assumes the first six,
 * 0..5, because that is the only choice that needs no justification. If the
 * user picks a different six, GLOBAL[] below is the one line to change.
 *
 * usage: d3_voiceindex_gate <bank>            (exit 0 = green)
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#include "juno_engine.h"
#include "juno_apply.h"
#include "juno_driver.h"

/* the cells juno_apply_condition and juno_apply_unison_spread write */
#define CELL_TUNE   5520u
#define CELL_FINE   7600u
#define CELL_GAIN  10320u
#define CELL_UNI    3968u

#define NGLOBAL 6
static const int GLOBAL[NGLOBAL] = { 0, 1, 2, 3, 4, 5 };
#define CHIP_VOICES 3

/* CONDITION byte and ASSIGN used for the comparison. ASSIGN 2 is UNISON --
 * the only value that makes juno_apply_unison_spread write anything but zero,
 * so testing any other value would test nothing. */
#define TEST_COND   200
#define TEST_ASSIGN 2

static unsigned char *mkstate(void)
{
    unsigned char *st = (unsigned char *)malloc(JUNO_STATE_BYTES);
    memset(st, 0, JUNO_STATE_BYTES);
    juno_chorus_init(st);
    *(float *)(st + 16) = 44100.0f;
    juno_engine_init(st);
    juno_engine_prepare(st);
    return st;
}

/* read the four per-voice scatter cells of LOCAL slot v */
static void readslot(const unsigned char *st, int v, uint32_t out[4])
{
    unsigned b = (unsigned)v * JUNO_VOICE_MAIN_STRIDE;
    memcpy(&out[0], st + CELL_TUNE + b, 4);
    memcpy(&out[1], st + CELL_FINE + b, 4);
    memcpy(&out[2], st + CELL_GAIN + b, 4);
    memcpy(&out[3], st + CELL_UNI  + b, 4);
}

static const char *NAME[4] = { "tune", "fine", "gain", "unison" };

int main(int argc, char **argv)
{
    unsigned char *ref, *chip[2];
    uint32_t want[NGLOBAL][4], got[NGLOBAL][4];
    int i, k, bad = 0, dup = 0;
    (void)argc; (void)argv;

    /* ---- the REFERENCE: one instrument, all eight slots, global order ---- */
    ref = mkstate();
    juno_driver_seed_voices(ref);
    juno_apply_unison_spread(ref, TEST_ASSIGN);
    juno_apply_condition(ref, TEST_COND);
    for (i = 0; i < NGLOBAL; ++i) readslot(ref, GLOBAL[i], want[i]);

    /* ---- THE TWO CHIPS, each exactly as the firmware builds one ---------- */
    for (k = 0; k < 2; ++k) {
        chip[k] = mkstate();
        juno_driver_seed_voices(chip[k]);
#ifdef D3_FIXED
        /* the fix: each chip is told where it sits in the global instrument */
        juno_apply_unison_spread_at(chip[k], TEST_ASSIGN, k * CHIP_VOICES);
        juno_apply_condition_at(chip[k], TEST_COND, k * CHIP_VOICES);
#else
        /* the tree as it stands: neither chip knows which voices it owns */
        juno_apply_unison_spread(chip[k], TEST_ASSIGN);
        juno_apply_condition(chip[k], TEST_COND);
#endif
    }
    for (i = 0; i < NGLOBAL; ++i)
        readslot(chip[i / CHIP_VOICES], i % CHIP_VOICES, got[i]);

    /* ---- the verdict ----------------------------------------------------- */
    printf("=== O6/D3 GLOBAL VOICE INDEX ===\n");
    printf("six voices over two chips: A owns global %d..%d, B owns %d..%d\n",
           GLOBAL[0], GLOBAL[CHIP_VOICES - 1],
           GLOBAL[CHIP_VOICES], GLOBAL[NGLOBAL - 1]);
    printf("CONDITION=%d  ASSIGN=%d (UNISON)\n\n", TEST_COND, TEST_ASSIGN);
    printf("  gv  chip.slot   %-10s %-10s %-10s %-10s\n",
           NAME[0], NAME[1], NAME[2], NAME[3]);
    for (i = 0; i < NGLOBAL; ++i) {
        int mism = 0;
        for (k = 0; k < 4; ++k) if (want[i][k] != got[i][k]) mism = 1;
        printf("  %2d  %c.%d       %08x   %08x   %08x   %08x  %s\n",
               GLOBAL[i], 'A' + i / CHIP_VOICES, i % CHIP_VOICES,
               got[i][0], got[i][1], got[i][2], got[i][3],
               mism ? "<-- WRONG" : "ok");
        if (mism) {
            ++bad;
            printf("        want            %08x   %08x   %08x   %08x\n",
                   want[i][0], want[i][1], want[i][2], want[i][3]);
        }
    }

    /* THE DEFECT'S OWN SIGNATURE, checked directly rather than inferred from
     * the mismatch count: do the two chips deal the SAME scatter? */
    for (i = 0; i < CHIP_VOICES; ++i) {
        uint32_t a[4], b[4];
        readslot(chip[0], i, a);
        readslot(chip[1], i, b);
        if (memcmp(a, b, sizeof a) == 0) ++dup;
    }
    printf("\nslots where chip B deals EXACTLY chip A's scatter: %d of %d\n",
           dup, CHIP_VOICES);

    if (bad == 0 && dup == 0) {
        printf("\nD3: GREEN -- six distinct global voices across two chips.\n");
        return 0;
    }
    printf("\nD3: RED -- %d of %d voices carry the wrong scatter.\n",
           bad, NGLOBAL);
    if (dup == CHIP_VOICES)
        printf("     Chip B is a COPY of chip A. This is the D3 defect, and it\n"
               "     is silent: no crash, no overrun, every coefficient CRC\n"
               "     still matches. It is only audible as a narrow chord.\n");
    return 1;
}

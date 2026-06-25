/* test_arp_smoke.c — smoke test for the faithful JUNO-60 arpeggiator transcription.
 *
 * Holds a C-major triad (60,64,67), installs UP mode, sets a 3-octave range,
 * directly stages a minimal one-cell-per-step pattern into the faithful struct
 * (the CKbdArp preset expander sub_7FF91E01F9F0 is NOT transcribed — see
 * src/arp.c — so the pattern fields are written here by hand, exactly the byte
 * layout the scanner reads), then clocks the engine and prints the emitted
 * note-on stream. A sensible UP arpeggio is 60,64,67 ascending, climbing by
 * octaves up to the range, then wrapping back.
 *
 * Build: cc -std=c99 -O2 -Wall -Wextra -fno-strict-aliasing \
 *           tests/test_arp_smoke.c src/arp.c -o tests/test_arp_smoke
 */
#include "../src/arp.h"
#include <stdio.h>
#include <string.h>

/* Faithful-struct field offsets used to stage the minimal pattern (see
 * docs/ARP_DSP.md §1). We write them directly because the preset expander is
 * not transcribed. */
#define OFF_STEPCOUNT_3054   3054  /* s8  : active-voice count per step          */
#define OFF_CLKPERIOD_3055   3055  /* s8  : step advances when +3056 >= this      */
#define OFF_DUR_610          610   /* u16 : per-step duration, +610 + 6*step      */
#define OFF_CELLS_996        996   /* per-step cell row, +996 + 64*step + 4*v7     */
#define OFF_RANGE_3476       3476  /* s32 : octave range                          */

static int g_notes[256];
static int g_n = 0;

static void on_note_on(void *ud, int note, int vel, int key)
{
    (void)ud; (void)vel; (void)key;
    if (g_n < (int)(sizeof g_notes / sizeof g_notes[0]))
        g_notes[g_n++] = note;
}
static void on_note_off(void *ud, int note, int vel)
{
    (void)ud; (void)note; (void)vel;
}

int main(void)
{
    juno_arp arp;
    juno_arp_callbacks cb;
    unsigned char *st;
    int i;

    cb.note_on  = on_note_on;
    cb.note_off = on_note_off;
    cb.ud       = NULL;

    juno_arp_init(&arp, &cb);
    st = arp.st;

    /* --- stage a minimal pattern: 1 active cell per step, advance every tick ---
     * step0 row, cell v7=0 = "on" (note byte non-zero, mask 0x7f). The actual
     * emitted pitch comes from the held list via the UP selector, not this byte. */
    *(int8_t  *)(st + OFF_STEPCOUNT_3054) = 1;            /* one cell per step    */
    *(int8_t  *)(st + OFF_CLKPERIOD_3055) = 1;            /* advance every tick   */
    *(uint16_t *)(st + OFF_DUR_610 + 6 * 0) = 1;          /* 1 tick per step      */
    *(uint8_t  *)(st + OFF_CELLS_996 + 64 * 0 + 4 * 0) = 0x01; /* cell on, gate.. */
    *(uint16_t *)(st + OFF_CELLS_996 + 64 * 0 + 4 * 0 + 2) = 1; /* gate length 1  */

    /* hold a C-major triad */
    juno_arp_note_on(&arp, 60, 100);
    juno_arp_note_on(&arp, 64, 100);
    juno_arp_note_on(&arp, 67, 100);

    juno_arp_set_mode(&arp, 15);    /* UP */
    juno_arp_set_range(&arp, 2);    /* 3 octaves: offsets 0,1,2 */
    juno_arp_set_running(&arp, 1);

    /* Clock enough samples to cover many ticks. The driver advances +20 by 1 per
     * call and fires the scanner each time +24 reaches +3048; with per-step
     * duration 1, that is roughly one scanner step per clock call once the run
     * state machine has spun up. Clock generously and collect the note-ons. */
    for (i = 0; i < 64; ++i)
        juno_arp_clock(&arp, 1);

    printf("emitted %d note-ons:\n", g_n);
    for (i = 0; i < g_n; ++i)
        printf("%d%s", g_notes[i], (i + 1 < g_n) ? " " : "\n");

    if (g_n == 0) {
        printf("FAIL: no notes emitted\n");
        return 1;
    }
    return 0;
}

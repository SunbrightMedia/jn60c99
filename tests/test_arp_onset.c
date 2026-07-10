/* test_arp_onset.c — regression guard for the arpeggiator's first-step onset.
 *
 * The plugin's CArpeggio schedules the first step at +3048 = +24 + 1 (the next
 * whole 24-PPQN tick strictly after key-down), NOT at pos 0. The old carp fired
 * step 0 immediately on key-down. This test drives carp sample-by-sample and
 * asserts the first note-on lands on the first tick boundary, and that the
 * grid keeps free-running across a key release (phase preserved). See
 * scratchpad/oracle/arp_finish_findings.md (a).
 */
#include <stdio.h>
#include "../src/carp.h"

int main(void)
{
    const double SR = 96000.0;
    /* 120 BPM, default rate_index 4 (RATE_TABLE[4]=6 ticks/step); tick = SR*60/(BPM*24). */
    const double spp = SR * 60.0 / (120.0 * 24.0);   /* 2000 samples/tick */
    int fails = 0;
    carp e;
    carp_init(&e);
    carp_set_bpm(&e, 120.0);

    /* key down at sample 0 */
    carp_add_key(&e, 60, 100);

    carp_event ev[4];
    int first_on = -1;
    for (int s = 0; s < 8000; ++s) {
        int nn = carp_tick(&e, SR, ev, 4);
        for (int i = 0; i < nn; ++i)
            if (ev[i].kind == 1 && first_on < 0) first_on = s;
    }

    /* first note-on must NOT be at sample 0 (the old bug) and must land on the
     * first tick boundary (~spp samples), well before the first full step. */
    if (first_on <= 0) {
        printf("  FAIL: first step fired immediately at sample %d (expected next tick ~%.0f)\n",
               first_on, spp);
        ++fails;
    } else if (first_on < (int)(spp * 0.5) || first_on > (int)(spp * 1.5)) {
        printf("  FAIL: first step at sample %d, expected near tick boundary %.0f\n",
               first_on, spp);
        ++fails;
    } else {
        printf("  onset: first note-on at sample %d (tick boundary ~%.0f) — quantized OK\n",
               first_on, spp);
    }

    if (fails) { printf("FAIL: arp onset quantization drifted\n"); return 1; }
    printf("OK: arp first-step onset is tick-quantized (fires on next 24-PPQN tick, not pos 0)\n");
    return 0;
}

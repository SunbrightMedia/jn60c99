/* test_arp_release.c — guard for the arp last-key-release note-off (§5.1 of
 * scratchpad/oracle/arp_release_fsm_spec.md).
 *
 * The plugin handles the last key-release synchronously (F2A0 -> all-notes-off
 * D3A0), which offs only slots still SOUNDING. So: if the current step's gate has
 * ALREADY closed when the last key lifts, carp must emit NO trailing note-off
 * (emitting one would be a spurious duplicate). If the note is still open, carp
 * must emit exactly one. Arp note-offs carry MIDI velocity 64.
 */
#include <stdio.h>
#include "../src/carp.h"

static const double SR = 96000.0;

/* Run one release scenario: play a note, advance until (on then, if want_gate_closed,
 * its gate note-off) has fired, release the key, then count note-offs emitted after. */
static int scenario(int gate_index, int wait_for_gate_close, int *off_vel_out)
{
    carp e; carp_init(&e); carp_set_bpm(&e, 120.0); carp_set_gate_index(&e, gate_index);
    carp_add_key(&e, 60, 100);
    carp_event ev[4];
    int got_on = 0, gate_closed = 0, offv = -1;
    for (int s = 0; s < 40000; ++s) {
        int n = carp_tick(&e, SR, ev, 4);
        for (int i = 0; i < n; ++i) {
            if (ev[i].kind == 1) got_on = 1;
            if (ev[i].kind == 0 && got_on) { gate_closed = 1; offv = ev[i].velocity; }
        }
        if (got_on && (!wait_for_gate_close || gate_closed)) break;
    }
    /* release the last key now */
    carp_remove_key(&e, 60);
    int trailing_offs = 0;
    for (int t = 0; t < 12; ++t) {
        int n = carp_tick(&e, SR, ev, 4);
        for (int i = 0; i < n; ++i) if (ev[i].kind == 0) { ++trailing_offs; offv = ev[i].velocity; }
    }
    if (off_vel_out) *off_vel_out = offv;
    return trailing_offs;
}

int main(void)
{
    int fails = 0, vel = -1;

    /* (a) release AFTER the gate closed (gate < 100%): expect NO trailing off. */
    int t = scenario(3, 1, &vel);
    if (t != 0) { printf("  FAIL: release-after-gate-close emitted %d trailing off(s), expected 0 (duplicate)\n", t); ++fails; }
    else printf("  release after gate close: 0 trailing offs (no duplicate) OK\n");

    /* (b) release WHILE the note is still open (gate 100%, note-on just fired):
     *     expect exactly one trailing off, velocity 64. */
    t = scenario(7, 0, &vel);
    if (t != 1) { printf("  FAIL: release-while-open emitted %d trailing off(s), expected 1\n", t); ++fails; }
    else if (vel != 64) { printf("  FAIL: trailing off velocity %d, expected 64\n", vel); ++fails; }
    else printf("  release while open: exactly 1 trailing off, velocity 64 OK\n");

    if (fails) { printf("FAIL: %d arp-release check(s)\n", fails); return 1; }
    printf("OK: arp last-key-release matches plugin (no duplicate off, velocity 64)\n");
    return 0;
}

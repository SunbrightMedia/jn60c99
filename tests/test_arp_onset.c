/* test_arp_onset.c -- guard for the arp's tick structure (rva 0x3C6750 ->
 * 0x3C3C50 / 0x3BDEA0), driven one engine tick at a time.
 *
 * The plugin's render driver calls the tick on its own grid (host samples;
 * graded against the plugin by tools/verify/host_process_gate.py). Inside one
 * tick: the keyboard object's counter always advances; the arp's counters
 * (+20/+24) run from the build on (+197 is set by the init, rva 0x3BE2F0); an
 * idle arp with keys starts at the tick (the first step at +24 + 1) and +24
 * walks up to it in the SAME tick -- so the first step fires in the first tick
 * after the key, then every RATE_TABLE[4] = 6 ticks. The arp is switched on as
 * the controller does it (the config twice, rva 0x3C49F0), and the beat
 * re-latch the first config arms is spent (beat 12) before the key.
 */
#include <stdio.h>
#include "../src/carp.h"

int main(void)
{
    int fails = 0, t, i, n, ons[8], no = 0;
    carp e;
    carp_event ev[16];
    carp_init(&e);
    e.ctl_on = 1; carp_ctl_config(&e); carp_ctl_config(&e); carp_enable(&e);
    if (!e.beat_requant_armed || e.rate_index != 4 || e.gate_index != 7 || !e.pat_reload) {
        printf("  FAIL: the first config (re-latch %d, rate %d, gate %d, reload %d)\n",
               e.beat_requant_armed, e.rate_index, e.gate_index, e.pat_reload); ++fails;
    }
    for (t = 0; t < 12; ++t) carp_engine_tick(&e, NULL, ev, 16);   /* no key yet */
    if (e.kb_ctr != 12) { printf("  FAIL: keyboard counter %u after 12 ticks\n", e.kb_ctr); ++fails; }
    if (e.clk20 != 12 || !e.clk_on) { printf("  FAIL: the arp clock from the build (+20 = %lld)\n", e.clk20); ++fails; }
    if (e.beat_requant_armed) { printf("  FAIL: the beat re-latch not spent at beat 12\n"); ++fails; }
    carp_add_key(&e, 60, 100);
    for (t = 1; t <= 40 && no < 8; ++t) {
        n = carp_engine_tick(&e, NULL, ev, 16);
        for (i = 0; i < n; ++i) if (ev[i].kind == 1 && no < 8) ons[no++] = t;
    }
    if (no < 6) { printf("  FAIL: %d note-ons in 40 ticks\n", no); ++fails; }
    else {
        if (ons[0] != 1) { printf("  FAIL: first step at tick %d after the key, expected 1\n", ons[0]); ++fails; }
        for (i = 1; i < no; ++i)
            if (ons[i] - ons[i - 1] != 6) { printf("  FAIL: step %d after %d ticks, expected 6\n", i, ons[i] - ons[i - 1]); ++fails; break; }
    }
    if (fails) { printf("FAIL: arp tick structure\n"); return 1; }
    printf("OK: arp tick structure (counter always, clock from the build, first step in the first tick, 6-tick steps)\n");
    return 0;
}

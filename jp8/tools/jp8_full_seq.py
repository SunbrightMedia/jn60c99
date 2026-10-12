#!/usr/bin/env python3
"""jp8_full_seq.py -- the SHARED drive of the JUPITER-8 full-chain gate (both processes import it; no unicorn, no ctypes).
The full chain = the engine (jp8/src/jp8_engine.c) booting ITSELF from the post-static-init template and its own call
tables, graded against the oracle (jp8_emu.JP8, drive2) booted from static init. Neither side replays the other's calls.
Boot (both sides): FACTORY + BUILD at MXCSR 0x1F80, FTZ, SETSR(rate), host_init (3 x HOSTPARAM); then the event list.
Events: ("recall", p) -- the factory patch through HOSTPARAM, one call per pool; ("on", key, vel) / ("off", key, vel) --
NOTEON / NOTEOFF; ("render", n) -- n host samples, each VOICE_WRAP x8 then MASTER_WRAP (jp8_lift_seq.py's call layout);
every output word is graded (18 per sample: v0 main, v0 sub .. v7 sub, L, R).
Per patch p: recall p, latch + idle, a note, a chord at three velocities, the releases; p % 8 == 0 adds a patch change
under a held note, p % 8 == 4 adds ten keys (two more than the eight voices: stealing)."""
import os
PATCHES = [int(x) for x in os.environ.get("JP8_FULL_PATCHES", "2,63,0,12").split(",")]
RATE = float(os.environ.get("JP8_FULL_RATE", "44100"))
DEEP = (2, 63)                  # patches whose whole end heap the oracle keeps (to locate a first differing dword)
IMG_BASE = 0x180000000; HEAP_BASE = 0x310000000; STACK_BASE = 0x200000000; STACK_SIZE = 0x2000000
TOOTH_RVA = "0x38633e"          # the FINE TUNE setter's "+ 0.0003" (0x386310): reached through every recall
def events(p):
    ev = [("recall", p), ("render", 4096), ("on", 60, 100), ("render", 4000), ("on", 64, 40), ("on", 67, 127),
          ("render", 3000), ("off", 60, 64), ("off", 64, 64), ("off", 67, 64), ("render", 6000)]
    if p % 8 == 0:
        ev += [("on", 72, 90), ("render", 1000), ("recall", (p + 1) % 64), ("render", 2000), ("off", 72, 64), ("render", 2000)]
    if p % 8 == 4:
        keys = list(range(48, 68, 2))
        ev += [("on", k, 30 + 9 * i) for i, k in enumerate(keys)] + [("render", 2000)]
        ev += [("off", k, 64) for k in keys] + [("render", 3000)]
    return ev
def nsamples(p): return sum(e[1] for e in events(p) if e[0] == "render")

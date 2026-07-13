#!/usr/bin/env python3
"""fuzztriage3/triage.py — seed 57 residual divergence: minimize + classify.

Reuses fuzz_diff.gen_script(seed) + run conventions VERBATIM (plugin side:
E2E build/snap/recall/snap/clear_latch/set_ftz, param events dispatched to all
9 units at BLOBS[i]+744 then snap_all; port side: juno_gui_* with the same
event stream). Adds:
  * event-index probes (state peeks + voice census) on BOTH sides
  * event-subset variants with CONSTANT render horizon (all render events kept,
    only non-render events dropped -> horizon fixed at 25528 >= 21528)
  * a hand-written minimal repro (same conventions).

Usage: triage.py repro | drop41 | drop42 | dropboth | minimal | minimal_ctl
"""
import sys, struct, ctypes, os, time
HERE = "/home/user/jn60c99/tools/verify"
sys.path.insert(0, HERE)
import e2e_emu as E
import fuzz_diff as F

REPO = "/home/user/jn60c99"
lib = F.lib          # same CDLL + signatures as fuzz_diff
BLOBS = F.BLOBS
BANK = E.BANK

lib.juno_gui_peek.restype = ctypes.c_uint
lib.juno_gui_peek.argtypes = [ctypes.c_void_p, ctypes.c_int]
lib.juno_gui_debug_voices.restype = ctypes.c_int
lib.juno_gui_debug_voices.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_int),
                                      ctypes.POINTER(ctypes.c_ubyte)]

# state cells of interest (same offset space on both sides: port state block /
# plugin per-unit state).  6497168 = DELAY TYPE-5 (reverb-hosted) instance time
# coeff; 102352 = slot-1 base delay time; 1056 = LFO Tempo Rate Sw (per-voice);
# 1072 = tempo-synced LFO rate cell.
CELLS = [(6497168, "dly5_time"), (102352, "dly_base_time"),
         (1056, "lfo_sync_sw"), (1072, "lfo_sync_rate")]

def plug_peek(e):
    out = {}
    for off, nm in CELLS:
        out[nm + "@u8"] = e.rd_u32(e.state[8] + off)
        out[nm + "@u0"] = e.rd_u32(e.state[0] + off)
    return out

def port_peek(c):
    out = {}
    for off, nm in CELLS:
        out[nm] = lib.juno_gui_peek(c, off)
        if 176 <= off < 176 + 10512:
            out[nm + "@v7"] = lib.juno_gui_peek(c, off + 7 * 10512)
    return out

def plug_census(e, unit=0):
    """per-voice NOTE/GATE/RELPEND bytes (assigner+96+3v) + LRU queue + held mask."""
    a = e.assign[unit]
    tab = bytes(e.uc.mem_read(a + 96, 24))
    lru = struct.unpack("<8i", bytes(e.uc.mem_read(a + 120, 32)))
    held = struct.unpack("<4I", bytes(e.uc.mem_read(a + 80, 16)))
    voices = [(tab[3*v], tab[3*v+1], tab[3*v+2]) for v in range(8)]
    return {"voices(note,gate,relpend)": voices, "lru(front=MRU)": list(lru),
            "held_mask": ["%08x" % h for h in held]}

def port_census(c):
    notes = (ctypes.c_int * 8)(); gated = (ctypes.c_ubyte * 8)()
    ng = lib.juno_gui_debug_voices(c, notes, gated)
    return {"voices(note,gated)": [(notes[v], gated[v]) for v in range(8)],
            "n_gated": ng}

def run_pair(ev, rate, patch, probes=(), label="", census_evs=()):
    """probes: event indices — peek state BEFORE and AFTER that event.
    census_evs: event indices — voice census BEFORE that event."""
    probes = set(probes); census_evs = set(census_evs)
    t0 = time.time()
    # ---------------- plugin (verbatim from fuzz_diff.run_seed) ----------------
    e = E.E2E(); e.build(rate); e.snap_all(); E.recall_patch(e, patch)
    e.snap_all(); e.clear_latch(); e.set_ftz()
    La, Ra = [], []
    for i, x in enumerate(ev):
        if i in census_evs:
            print(f"[plug] census before ev{i} {x}: {plug_census(e)}", flush=True)
        if i in probes:
            print(f"[plug] peek before ev{i} {x}: {plug_peek(e)}", flush=True)
        if x[0] == 'on': e.note_on(x[1], x[2])
        elif x[0] == 'off': e.note_off(x[1])
        elif x[0] == 'param':
            for u in range(9):
                try: e.dispatch(u, BLOBS[x[1]] + 744, x[2])
                except RuntimeError: pass
            e.snap_all()
        else:
            l, r = e.render(x[1]); La += l; Ra += r
        if i in probes:
            print(f"[plug] peek after  ev{i} {x}: {plug_peek(e)}", flush=True)
    print(f"[plug] done {len(La)} frames in {time.time()-t0:.0f}s", flush=True)
    # ---------------- port (verbatim from fuzz_diff.run_seed) ------------------
    bank = open(BANK, 'rb').read()
    c = lib.juno_gui_create(ctypes.c_float(rate), 0)
    lib.juno_gui_apply_bank(c, bank, len(bank), patch)
    if patch in F.ARPS: lib.juno_gui_arp_config(c, 0, 0, 1, 128.0, 0.6)
    Lb, Rb = [], []
    for i, x in enumerate(ev):
        if i in census_evs:
            print(f"[port] census before ev{i} {x}: {port_census(c)}", flush=True)
        if i in probes:
            print(f"[port] peek before ev{i} {x}: {port_peek(c)}", flush=True)
        if x[0] == 'on': lib.juno_gui_note_on(c, x[1], x[2])
        elif x[0] == 'off': lib.juno_gui_note_off(c, x[1])
        elif x[0] == 'param': lib.juno_gui_set_param(c, x[1], x[2])
        else:
            n = x[1]; buf = (ctypes.c_float * (2*n))(); lib.juno_gui_render(c, buf, n)
            inter = struct.unpack("<%dI" % (2*n), bytes(buf))
            Lb += inter[0::2]; Rb += inter[1::2]
        if i in probes:
            print(f"[port] peek after  ev{i} {x}: {port_peek(c)}", flush=True)
    n = min(len(La), len(Lb))
    first = next((i for i in range(n) if La[i] != Lb[i] or Ra[i] != Rb[i]), None)
    if first is None:
        print(f"RESULT {label}: OK frames={n}", flush=True)
    else:
        print(f"RESULT {label}: DIVERGE @frame {first} "
              f"plugL={La[first]:08x} portL={Lb[first]:08x} "
              f"plugR={Ra[first]:08x} portR={Rb[first]:08x}", flush=True)
    return first

def main():
    mode = sys.argv[1]
    rate, patch, ev, total = F.gen_script(57)
    assert (rate, patch, total) == (44100.0, 5, 25528)
    if mode == "repro":
        # full seed with probes at ev41 (param 24) and census before ev42 (off 80)
        run_pair(ev, rate, patch, probes=(41,), census_evs=(41, 42), label="repro-full")
    elif mode == "drop41":
        ev2 = [x for i, x in enumerate(ev) if i != 41]
        run_pair(ev2, rate, patch, label="drop41(no param24; horizon 25528)")
    elif mode == "drop42":
        ev2 = [x for i, x in enumerate(ev) if i != 42]
        run_pair(ev2, rate, patch, label="drop42(no off80; horizon 25528)")
    elif mode == "dropboth":
        ev2 = [x for i, x in enumerate(ev) if i not in (41, 42)]
        run_pair(ev2, rate, patch, label="dropboth(horizon 25528)")
    elif mode == "minimal":
        mv = [('on', 80, 67), ('render', 18000), ('param', 24, 228), ('render', 3600)]
        run_pair(mv, rate, patch, probes=(2,), label="minimal(on80+18000+tempoSync228+3600)")
    elif mode == "minimal_ctl":
        # control: same horizon, no param flip -> must be OK
        mv = [('on', 80, 67), ('render', 18000), ('render', 3600)]
        run_pair(mv, rate, patch, label="minimal-control(no flip, horizon 21600)")
    else:
        raise SystemExit("unknown mode")

if __name__ == "__main__":
    main()

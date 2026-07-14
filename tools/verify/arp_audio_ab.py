#!/usr/bin/env python3
"""arp_audio_ab.py — direct arp-audio A/B (Phase 4).

The port's arp (carp.c) drives its render; this captures the EXACT arp event
schedule the port renders (sample, kind, note, velocity) via the debug trace,
then replays that identical schedule into the plugin oracle (e2e_emu = the
plugin's real per-sample voice+master render) at the same sample offsets, and
compares the audio bit-for-bit.

Since arp and manual notes share the SAME assigner in the plugin (execution-
confirmed, docs/PHASE4_ARP_RVAMAP.md §3) and the per-sample render is proven
bit-exact (203-seed corpus), a bit-exact result here means the port's arp
render == the plugin's render of the same schedule. Combined with carp==CArpeggio
(task #36), the port's arp audio == the plugin's arp audio.

Ground truth = the plugin's machine code under Unicorn.
"""
import sys, struct, ctypes
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E

RATE = 44100.0
CHORD = (60, 64, 67)
MODE, OCT, BPM, GATE = 0, 1, 128.0, 0.6   # UP, 1 octave (defaults; overridden per-run)
N = 40000
# BPM=128 is the recall-default host tempo: at 128 the tempo-synced LFO (cell 1072)
# is value-neutral, so this A/B isolates the arp note dispatch + render from the
# separately-proven LFO tempo-sync (task #55). Other BPMs merely re-time the LFO
# and the arp step spacing; the render of whatever schedule results is still exact.

lib = ctypes.CDLL('/home/user/jn60c99/libjuno.so')
lib.juno_gui_create.restype = ctypes.c_void_p
lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
lib.juno_gui_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
lib.juno_gui_arp_config.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_float, ctypes.c_float]
lib.juno_gui_render.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int]
lib.juno_gui_arp_trace.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_int), ctypes.c_int]
lib.juno_gui_arp_trace_count.restype = ctypes.c_int
lib.juno_gui_arp_trace_count.argtypes = [ctypes.c_void_p]

def port_arp(patch, mode=MODE, oct=OCT):
    bankb = E.bank_bytes()
    c = lib.juno_gui_create(ctypes.c_float(RATE), 0)
    lib.juno_gui_apply_bank(c, bankb, len(bankb), patch)
    lib.juno_gui_arp_config(c, 1, mode, oct, ctypes.c_float(BPM), ctypes.c_float(GATE))
    cap = 4096
    buf = (ctypes.c_int * (4*cap))()
    lib.juno_gui_arp_trace(c, buf, cap)
    for n in CHORD: lib.juno_gui_note_on(c, n, 100)
    out = (ctypes.c_float * (2*N))(); lib.juno_gui_render(c, out, N)
    ne = lib.juno_gui_arp_trace_count(c)
    sched = [(buf[4*i], buf[4*i+1], buf[4*i+2], buf[4*i+3]) for i in range(ne)]
    inter = struct.unpack("<%dI" % (2*N), bytes(out))
    return list(inter[0::2]), list(inter[1::2]), sched

def plugin_replay(patch, sched):
    e = E.E2E(); e.build(RATE); e.snap_all(); E.recall_patch(e, patch)
    e.snap_all(); e.clear_latch(); e.set_ftz()
    L=[]; R=[]; cur=0
    for (smp, kind, note, vel) in sched:
        if smp > cur:
            l,r = e.render(smp-cur); L+=l; R+=r; cur=smp
        if kind == 0: e.note_off(note)
        else:         e.note_on(note, vel)
    if N > cur:
        l,r = e.render(N-cur); L+=l; R+=r
    return L, R

def one(patch, mode, oct):
    pL,pR,sched = port_arp(patch, mode, oct)
    gL,gR = plugin_replay(patch, sched)
    n = min(len(pL), len(gL)); d = None
    for i in range(n):
        if pL[i]!=gL[i] or pR[i]!=gR[i]: d=i; break
    tag = f"patch {patch:2d} mode {mode} oct {oct}"
    if d is None:
        print(f"{tag}: BIT-EXACT {n}f ({len(sched)} ev)", flush=True); return True
    print(f"{tag}: DIVERGE @{d} pL={pL[d]:08x} gL={gL[d]:08x} pR={pR[d]:08x} gR={gR[d]:08x}", flush=True); return False

ARPS = (1, 9, 17, 25, 33, 41, 49)
def main():
    a = sys.argv[1:]
    if a and a[0] == 'sweep':
        modes = (0,1,2); octs = (1,2,3)
        bad = 0; tot = 0
        for p in ARPS:
            for m in modes:
                for o in octs:
                    tot += 1
                    if not one(p, m, o): bad += 1
        print(f"=== {bad} divergent / {tot} arp A/Bs ===", flush=True)
    else:
        patch = int(a[0]) if a else 1
        mode = int(a[1]) if len(a)>1 else MODE
        oct = int(a[2]) if len(a)>2 else OCT
        one(patch, mode, oct)

if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""synth_dco_ab.py — coverage + correctness for the DISCRETE DCO/LFO mode branches.

The corpus (200+ seeds) + factory patches leave ~50 voice_render lines uncovered:
they are gated by DISCRETE mode cells (DCO range/waveform, sub/noise type, LFO
variation/routing, VCA mode, octave shift) whose values no factory patch selects
and which no live front-panel row (0..24) can reach. This test synthesises patches
that DO select those values — by overwriting the base patch's record bytes — and
A/Bs full audio against the running binary. It both drives the uncovered branches
and proves them bit-exact (or finds a real divergence). Reachable on hardware via
the front panel, so in scope for a playable instrument.

Ground truth = the plugin's machine code under Unicorn (e2e_emu.py). Each side
recalls the SAME synthetic blob (oracle: recall_patch(bank=synth); port:
juno_gui_apply_bank(synth)).
"""
import sys, struct, ctypes
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E

HEADER, STRIDE, BLOB_OFF = E.HEADER, E.STRIDE, E.BLOB_OFF
BASE = 5
RATE = 44100.0
N = 3000
NOTES = (24, 36, 60, 84, 96)     # extremes force DCO phase-wrap branches

# discrete-mode record bytes (from load_leaves) to sweep, with a value spread
DISCRETE = [
    ("OSC2 WAVE",        36, (0,1,2,3)),
    ("OSC2 RANGE",       42, (0,1,2,3)),
    ("MIX SUB OSC TYPE", 60, (0,1,2,3)),
    ("MIX NOISE TYPE",   62, (0,1,2,3)),
    ("VCO ENV",          64, (0,1,2)),
    ("OCTAVE SHIFT",    322, (0,1,2,3)),
    ("OSC3 WAVEFORM",   578, (0,1,2,3)),
    ("LFO VARIATION",   530, (0,1,2)),
    ("LFO TRIG ENV",    538, (0,1)),
    ("VCA MODE",        474, (0,1,2)),
    ("LFO PITCH IN",    354, (0,1,2)),
    ("LFO FILTER IN",   362, (0,1,2)),
    ("LFO AMP IN",      370, (0,1,2)),
]

lib = ctypes.CDLL('/home/user/jn60c99/libjuno.so')
lib.juno_gui_create.restype = ctypes.c_void_p
lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
lib.juno_gui_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
lib.juno_gui_render.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int]
has_destroy = hasattr(lib, 'juno_gui_destroy')
if has_destroy: lib.juno_gui_destroy.argtypes = [ctypes.c_void_p]

BANK = bytearray(E.bank_bytes())

def synth(recbyte, val):
    b = bytearray(BANK)
    off = HEADER + BASE * STRIDE + BLOB_OFF + recbyte
    b[off]   = (val >> 4) & 0xF
    b[off+1] = val & 0xF
    return bytes(b)

def plug_stream(bank, note):
    e = E.E2E(); e.build(RATE); e.snap_all()
    E.recall_patch(e, BASE, bank=bank); e.snap_all(); e.clear_latch(); e.set_ftz()
    e.note_on(note, 100); return e.render(N)

def port_stream(bank, note):
    c = lib.juno_gui_create(ctypes.c_float(RATE), 0)
    lib.juno_gui_apply_bank(c, bank, len(bank), BASE)
    lib.juno_gui_note_on(c, note, 100)
    buf = (ctypes.c_float * (2*N))(); lib.juno_gui_render(c, buf, N)
    inter = struct.unpack("<%dI" % (2*N), bytes(buf))
    if has_destroy: lib.juno_gui_destroy(c)
    return list(inter[0::2]), list(inter[1::2])

def first_div(La, Ra, Lb, Rb):
    for i in range(min(len(La), len(Lb))):
        if La[i] != Lb[i] or Ra[i] != Rb[i]: return i
    return None

def main():
    # usage: synth_dco_ab.py [substr] | synth_dco_ab.py --range LO HI
    only = None; lo, hi = 0, len(DISCRETE)
    if len(sys.argv) >= 4 and sys.argv[1] == '--range':
        lo, hi = int(sys.argv[2]), int(sys.argv[3])
    elif len(sys.argv) > 1:
        only = sys.argv[1]
    bad = 0; tot = 0
    for idx, (nm, rb, vals) in enumerate(DISCRETE):
        if not (lo <= idx < hi): continue
        if only and only not in nm: continue
        for v in vals:
            bank = synth(rb, v)
            for note in NOTES:
                tot += 1
                pL, pR = plug_stream(bank, note)
                qL, qR = port_stream(bank, note)
                d = first_div(pL, pR, qL, qR)
                if d is not None:
                    bad += 1
                    print(f"DIVERGE {nm}={v} note={note} @ {d}  "
                          f"pL={pL[d]:08x} qL={qL[d]:08x} pR={pR[d]:08x} qR={qR[d]:08x}", flush=True)
        print(f"  swept {nm} (rec {rb})", flush=True)
    print(f"=== {bad} divergent / {tot} synthetic A/Bs ===", flush=True)

if __name__ == '__main__':
    main()

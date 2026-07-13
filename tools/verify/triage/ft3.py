#!/usr/bin/env python3
"""ft3.py — fuzz-triage round 3 harness (seeds 61 / 51).

Reuses fuzz_diff.py's gen_script + run conventions VERBATIM (imports them);
adds: event-prefix runs with a CONSTANT render horizon, dual-side voice census,
and a per-sample state-diff microscope around the introducing event.

DOES NOT modify the repo. Plugin ground truth = its own machine code under
Unicorn via tools/verify/e2e_emu.py.
"""
import sys, struct, ctypes, os
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E
import fuzz_diff as FD
from fuzz_diff import gen_script, BLOBS, ARPS, BANK

lib = FD.lib
lib.juno_gui_peek.restype = ctypes.c_uint
lib.juno_gui_peek.argtypes = [ctypes.c_void_p, ctypes.c_int]
lib.juno_gui_debug_voices.restype = ctypes.c_int
lib.juno_gui_debug_voices.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_int),
                                      ctypes.POINTER(ctypes.c_ubyte)]
lib.juno_gui_destroy.restype = None
lib.juno_gui_destroy.argtypes = [ctypes.c_void_p]

STRIDE = 10512
ENV_OFFS = (2592, 2720, 3072, 3200)          # ENV1/ENV2 integrator+level slots
AUX0 = 101504                                 # DCO retrigger latch array A

def f32(bits):
    return struct.unpack('<f', struct.pack('<I', bits & 0xFFFFFFFF))[0]

# ---------------------------------------------------------------- plugin side
class PluginRun:
    def __init__(self, rate, patch):
        e = E.E2E(); e.build(rate); e.snap_all(); E.recall_patch(e, patch)
        e.snap_all(); e.clear_latch(); e.set_ftz()
        self.e = e; self.L = []; self.R = []
    def do(self, x, block=600):
        e = self.e
        if x[0] == 'on': e.note_on(x[1], x[2])
        elif x[0] == 'off': e.note_off(x[1])
        elif x[0] == 'param':
            for u in range(9):
                try: e.dispatch(u, BLOBS[x[1]] + 744, x[2])
                except RuntimeError: pass
            e.snap_all()
        else:
            l, r = e.render(x[1], block=block); self.L += l; self.R += r
    def census(self):
        e = self.e; uc = e.uc
        a = e.assign[0]
        mode = struct.unpack('<i', uc.mem_read(a+16, 4))[0]
        nvg = uc.mem_read(a+96, 24)
        lru = struct.unpack('<8I', uc.mem_read(a+120, 32))
        held = struct.unpack('<4I', uc.mem_read(a+80, 16))
        voices = []
        for v in range(8):
            note, gate, rel = nvg[3*v], nvg[3*v+1], nvg[3*v+2]
            st = e.state[v]
            gate_cell = struct.unpack('<f', uc.mem_read(st + v*STRIDE + 320, 4))[0]
            envs = [struct.unpack('<f', uc.mem_read(st + v*STRIDE + o, 4))[0]
                    for o in ENV_OFFS]
            latch = struct.unpack('<f', uc.mem_read(st + AUX0 + 32*v, 4))[0]
            mcv = struct.unpack('<f', uc.mem_read(st + v*STRIDE + 304, 4))[0]
            voices.append(dict(note=note if note != 0xFF else -1, gate=gate, rel=rel,
                               gate_cell=gate_cell, envs=envs, latch=latch, mcv=mcv))
        return dict(side='plugin', mode=mode, lru=lru, held=held, voices=voices)
    def snap_voice(self, v):
        """uint32 view of unit-v's voice-v block + its aux latch row."""
        e = self.e
        blk = bytes(e.uc.mem_read(e.state[v] + v*STRIDE, STRIDE))
        aux = bytes(e.uc.mem_read(e.state[v] + AUX0 + 32*v, 32))
        return blk, aux
    def snap_master(self, lo=84272, hi=0xA83010):
        e = self.e
        return bytes(e.uc.mem_read(e.state[8] + lo, hi - lo))

# ---------------------------------------------------------------- port side
class PortRun:
    def __init__(self, rate, patch):
        bank = open(BANK, 'rb').read()
        c = lib.juno_gui_create(ctypes.c_float(rate), 0)
        lib.juno_gui_apply_bank(c, bank, len(bank), patch)
        if patch in ARPS: lib.juno_gui_arp_config(c, 0, 0, 1, 128.0, 0.6)
        self.c = c; self.L = []; self.R = []
        self.stp = ctypes.cast(c, ctypes.POINTER(ctypes.c_void_p))[0]  # ctx->st
    def do(self, x, block=None):
        c = self.c
        if x[0] == 'on': lib.juno_gui_note_on(c, x[1], x[2])
        elif x[0] == 'off': lib.juno_gui_note_off(c, x[1])
        elif x[0] == 'param': lib.juno_gui_set_param(c, x[1], x[2])
        else:
            n = x[1]; buf = (ctypes.c_float * (2*n))(); lib.juno_gui_render(c, buf, n)
            inter = struct.unpack("<%dI" % (2*n), bytes(buf))
            self.L += inter[0::2]; self.R += inter[1::2]
    def census(self):
        notes = (ctypes.c_int * 8)(); gated = (ctypes.c_ubyte * 8)()
        lib.juno_gui_debug_voices(self.c, notes, gated)
        voices = []
        for v in range(8):
            gate_cell = f32(lib.juno_gui_peek(self.c, v*STRIDE + 320))
            envs = [f32(lib.juno_gui_peek(self.c, v*STRIDE + o)) for o in ENV_OFFS]
            latch = f32(lib.juno_gui_peek(self.c, AUX0 + 32*v))
            mcv = f32(lib.juno_gui_peek(self.c, v*STRIDE + 304))
            voices.append(dict(note=notes[v], gate=int(gated[v]), rel=0,
                               gate_cell=gate_cell, envs=envs, latch=latch, mcv=mcv))
        return dict(side='port', voices=voices)
    def snap_voice(self, v):
        base = self.stp
        blk = ctypes.string_at(base + v*STRIDE, STRIDE)
        aux = ctypes.string_at(base + AUX0 + 32*v, 32)
        return blk, aux
    def snap_master(self, lo=84272, hi=0xA83010):
        return ctypes.string_at(self.stp + lo, hi - lo)
    def close(self):
        lib.juno_gui_destroy(self.c); self.c = None

# ---------------------------------------------------------------- A/B drivers
def first_div(La, Ra, Lb, Rb):
    n = min(len(La), len(Lb))
    for i in range(n):
        if La[i] != Lb[i] or Ra[i] != Rb[i]:
            return i
    return None

def run_prefix(seed, k, horizon, block=600):
    """Run events[:k] + render(horizon) on both sides; return (divframe, nframes,
    bits at div)."""
    rate, patch, ev, total = gen_script(seed)
    evk = list(ev[:k]) + [('render', horizon)]
    P = PluginRun(rate, patch); Q = PortRun(rate, patch)
    for x in evk:
        P.do(x, block=block); Q.do(x)
    d = first_div(P.L, P.R, Q.L, Q.R)
    bits = None
    if d is not None:
        bits = (P.L[d], Q.L[d], P.R[d], Q.R[d])
    n = min(len(P.L), len(Q.L))
    Q.close()
    return d, n, bits

def run_events(seed, events, block=600):
    rate, patch, _, _ = gen_script(seed)
    P = PluginRun(rate, patch); Q = PortRun(rate, patch)
    for x in events:
        P.do(x, block=block); Q.do(x)
    d = first_div(P.L, P.R, Q.L, Q.R)
    bits = None
    if d is not None:
        bits = (P.L[d], Q.L[d], P.R[d], Q.R[d])
    Q.close()
    return d, min(len(P.L), len(Q.L)), bits

if __name__ == '__main__':
    cmd = sys.argv[1]
    if cmd == 'prefix':
        seed, k, hor = int(sys.argv[2]), int(sys.argv[3]), int(sys.argv[4])
        d, n, bits = run_prefix(seed, k, hor)
        if d is None:
            print(f"seed {seed} prefix {k} +render({hor}): OK {n} frames", flush=True)
        else:
            print(f"seed {seed} prefix {k} +render({hor}): DIVERGE @ {d} "
                  f"plugL={bits[0]:08x} portL={bits[1]:08x} "
                  f"plugR={bits[2]:08x} portR={bits[3]:08x}", flush=True)

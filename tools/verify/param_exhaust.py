#!/usr/bin/env python3
"""param_exhaust.py — Phase-2 finite-domain EXHAUSTION: every exposed panel param
x all 256 byte values, plugin's own dispatch vs the port's setter, per rate.

For each BINDINGS row (25 rows over 21 distinct blob positions): dispatch
idx = blob_pos + 744 with raw byte 0..255 into every unit of a live plugin
instance (Unicorn), snap, read the engine cell at the binding's offset from
unit 0; compare bitwise against the port's juno_apply_param(state, i, byte, Hr).
Domain: 256 bytes x 3 rates (44100/48000/96000) x 25 rows = 19200 comparisons.
For finite domains, exhaustive testing IS proof (MASTER_PLAN Phase 2)."""
import sys, struct, ctypes, json
sys.path.insert(0, '/home/user/jn60c99/scratchpad/oracle')
import e2e_emu as E

lib = ctypes.CDLL("/home/user/jn60c99/libjuno.so")
lib.juno_gui_param_count.restype = ctypes.c_int
lib.juno_gui_param_name.restype = ctypes.c_char_p
lib.juno_gui_param_name.argtypes = [ctypes.c_int]
lib.juno_gui_param_offset.restype = ctypes.c_int
lib.juno_gui_param_offset.argtypes = [ctypes.c_int]
lib.juno_gui_create.restype = ctypes.c_void_p
lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
lib.juno_gui_set_param.restype = ctypes.c_float
lib.juno_gui_set_param.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
lib.juno_gui_peek.restype = ctypes.c_uint
lib.juno_gui_peek.argtypes = [ctypes.c_void_p, ctypes.c_int]

# blob position per binding row, parsed from src/juno_apply.c BINDINGS
import re
src = open('/home/user/jn60c99/src/juno_apply.c').read()
m = re.search(r'BINDINGS\[\]\s*=\s*\{(.*?)\n\};', src, re.S)
rows = re.findall(r'\{\s*(\d+)\s*,\s*\d+\s*,\s*[A-Z_]+\s*,\s*(\d+)\s*,\s*"([^"]*)"', m.group(1))
BIND = [(int(bp), int(off), nm) for (bp, off, nm) in rows]
assert len(BIND) == lib.juno_gui_param_count(), (len(BIND), lib.juno_gui_param_count())

def f(u): return struct.unpack('<f', struct.pack('<I', u & 0xffffffff))[0]

total_ok = total_bad = 0
for sr in (44100.0, 48000.0, 96000.0):
    # one plugin instance per rate; canonical cold prep
    e = E.E2E(); e.build(sr); e.snap_all(); e.clear_latch(); e.set_ftz()
    # one port instance per rate
    c = lib.juno_gui_create(ctypes.c_float(sr), 0)
    print(f"--- rate {int(sr)} ---", flush=True)
    for i, (bp, off, nm) in enumerate(BIND):
        disp = bp + 744
        bad = []
        for byte in range(256):
            for u in range(9):
                try: e.dispatch(u, disp, byte)
                except RuntimeError: pass
            e.snap_all()
            gv = e.rd_u32(e.state[0] + off)
            lib.juno_gui_set_param(c, i, byte)
            pv = lib.juno_gui_peek(c, off)
            if gv != pv:
                bad.append((byte, gv, pv))
        total_ok += 256 - len(bad); total_bad += len(bad)
        tag = "OK 256/256" if not bad else f"BAD {len(bad)}/256 first: byte {bad[0][0]} plug {bad[0][1]:08x}({f(bad[0][1]):.6g}) port {bad[0][2]:08x}({f(bad[0][2]):.6g})"
        print(f"  [{i:2d}] blob{bp:3d} off{off:6d} {nm:18s} {tag}", flush=True)
print(f"\nEXHAUSTION TOTAL: {total_ok} identical / {total_bad} mismatched of {total_ok+total_bad}", flush=True)

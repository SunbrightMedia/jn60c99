#!/usr/bin/env python3
"""param_exhaust2.py — Phase-2 exhaustion, WARM and MID-NOTE variants.
Same domain as param_exhaust.py (25 binding rows x 256 bytes x 3 rates), but the
dispatch fires into (a) a WARM engine (12000 samples idle-rendered) and (b) a
MID-NOTE engine (note_on(60,105) + 3000 samples). State-level compare of the
engine cell vs the port setter in the same configuration."""
import sys, struct, ctypes, re
sys.path.insert(0, '/home/user/jn60c99/scratchpad/oracle')
import e2e_emu as E

lib = ctypes.CDLL("/home/user/jn60c99/libjuno.so")
for fn, rt, at in [
    ("juno_gui_create", ctypes.c_void_p, [ctypes.c_float, ctypes.c_int]),
    ("juno_gui_warmup", None, [ctypes.c_void_p, ctypes.c_int]),
    ("juno_gui_note_on", None, [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]),
    ("juno_gui_render", None, [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int]),
    ("juno_gui_set_param", ctypes.c_float, [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]),
    ("juno_gui_peek", ctypes.c_uint, [ctypes.c_void_p, ctypes.c_int]),
    ("juno_gui_param_count", ctypes.c_int, [])]:
    getattr(lib, fn).restype = rt; getattr(lib, fn).argtypes = at

src = open('/home/user/jn60c99/src/juno_apply.c').read()
m = re.search(r'BINDINGS\[\]\s*=\s*\{(.*?)\n\};', src, re.S)
rows = re.findall(r'\{\s*(\d+)\s*,\s*\d+\s*,\s*[A-Z_]+\s*,\s*(\d+)\s*,\s*"([^"]*)"', m.group(1))
BIND = [(int(bp), int(off), nm) for (bp, off, nm) in rows]
assert len(BIND) == lib.juno_gui_param_count()

def f(u): return struct.unpack('<f', struct.pack('<I', u & 0xffffffff))[0]

def run(config):
    total_ok = total_bad = 0
    for sr in (44100.0, 48000.0, 96000.0):
        e = E.E2E(); e.build(sr); e.snap_all(); e.clear_latch(); e.set_ftz()
        c = lib.juno_gui_create(ctypes.c_float(sr), 0)
        if config == 'warm':
            e.render(12000); lib.juno_gui_warmup(c, 12000)
        elif config == 'midnote':
            e.note_on(60, 105); e.render(3000)
            lib.juno_gui_note_on(c, 60, 105)
            buf = (ctypes.c_float * 6000)(); lib.juno_gui_render(c, buf, 3000)
        print(f"--- [{config}] rate {int(sr)} ---", flush=True)
        for i, (bp, off, nm) in enumerate(BIND):
            bad = []
            for byte in range(256):
                for u in range(9):
                    try: e.dispatch(u, bp + 744, byte)
                    except RuntimeError: pass
                e.snap_all()
                gv = e.rd_u32(e.state[0] + off)
                lib.juno_gui_set_param(c, i, byte)
                pv = lib.juno_gui_peek(c, off)
                if gv != pv: bad.append((byte, gv, pv))
            total_ok += 256 - len(bad); total_bad += len(bad)
            tag = "OK 256/256" if not bad else f"BAD {len(bad)}/256 first: byte {bad[0][0]} plug {bad[0][1]:08x} port {bad[0][2]:08x}"
            print(f"  [{i:2d}] blob{bp:3d} off{off:6d} {nm:18s} {tag}", flush=True)
    print(f"[{config}] TOTAL: {total_ok} identical / {total_bad} mismatched of {total_ok+total_bad}", flush=True)

run('warm')
run('midnote')

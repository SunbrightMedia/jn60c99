#!/usr/bin/env python3
"""rate_fullscan.py — FULL-STATE cold differential scan across rates.
For each representative patch (one per DELAY TYPE v39) and each rate in
{44100, 48000, 96000}: diff the port's ENTIRE master region [84272, 12MB) and
all 8 voice regions against the plugin's cold post-recall state. 48 kHz cold
audio is proven bit-exact, so its diff set is the benign baseline; report every
cell whose diff-status exists at 44.1k or 96k but not at 48k, WITH the plugin's
value at all three rates (to derive each cell's rate law)."""
import sys, struct, ctypes
import numpy as np
sys.path.insert(0, '/home/user/jn60c99/scratchpad/oracle')
import e2e_emu as E
BANK = "/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/ae5e8f1d-presetbankog1.bin"
bank = open(BANK, 'rb').read()
STRIDE, STATE = 10512, 12*1024*1024
PATCHES = [(13, 0), (4, 1), (11, 2), (19, 3), (5, 5)]   # (patch, v39 type)
RATES = [44100.0, 48000.0, 96000.0]

lib = ctypes.CDLL("/home/user/jn60c99/libjuno.so")
lib.juno_gui_create.restype = ctypes.c_void_p
lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
def f(u): return struct.unpack('<f', struct.pack('<I', int(u) & 0xffffffff))[0]

def port_state(sr, p):
    c = lib.juno_gui_create(ctypes.c_float(sr), 0)
    lib.juno_gui_apply_bank(c, bank, len(bank), p)
    st_ptr = ctypes.cast(c, ctypes.POINTER(ctypes.c_void_p))[0]
    return np.frombuffer(ctypes.string_at(st_ptr, STATE), dtype=np.uint32).copy()

def plug_state(sr, p):
    e = E.E2E(); e.build(sr); e.snap_all(); E.recall_patch(e, p); e.snap_all(); e.clear_latch()
    # master unit 8 full; voices 0..7 partial
    m = np.frombuffer(b"".join(bytes(e.uc.mem_read(e.state[8] + i, min(1<<20, STATE - i)))
                               for i in range(0, STATE, 1<<20)), dtype=np.uint32).copy()
    vs = [np.frombuffer(bytes(e.uc.mem_read(e.state[v] + 176, 10688-176)), dtype=np.uint32).copy()
          for v in range(8)]
    return m, vs

def diffset(sr, p):
    ps = port_state(sr, p); m, vs = plug_state(sr, p)
    out = {}
    # master region [84272, STATE): port offsets == plugin unit-8 offsets
    a0 = 84272 // 4
    idx = np.nonzero(ps[a0:] != m[a0:])[0]
    for i in idx:
        off = 84272 + 4*int(i)
        out[("m", off)] = (int(m[a0+i]), int(ps[a0+i]))
    # voice regions
    for v in range(8):
        pv = ps[(176 + v*STRIDE)//4 : (10688 + v*STRIDE)//4]
        gv = vs[v]
        idx = np.nonzero(pv != gv)[0]
        for i in idx:
            out[(f"v{v}", 176 + 4*int(i))] = (int(gv[i]), int(pv[i]))
    return out

for (p, typ) in PATCHES:
    ds = {}
    plugvals = {}
    for sr in RATES:
        ds[sr] = diffset(sr, p)
    base = set(ds[48000.0])
    extra = (set(ds[44100.0]) | set(ds[96000.0])) - base
    print(f"\n=== patch {p} (v39={typ}): diffs 44.1k={len(ds[44100.0])} 48k={len(ds[48000.0])} 96k={len(ds[96000.0])}; rate-ONLY={len(extra)} ===", flush=True)
    # for each extra cell, print plugin value at all 3 rates + port value at all 3
    for k in sorted(extra):
        row = []
        for sr in RATES:
            if k in ds[sr]:
                g, q = ds[sr][k]
                row.append(f"{int(sr)}: plug {g:08x}({f(g):.9g}) port {q:08x}({f(q):.9g})")
            else:
                row.append(f"{int(sr)}: EQUAL")
        print(f"  {k[0]:3s} off {k[1]:7d}  " + " | ".join(row), flush=True)

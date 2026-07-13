#!/usr/bin/env python3
"""probe2.py — targeted cell trace at the introducing event.

usage: probe2.py 51   (voice-3 LFO cells, unit strip/header compare)
       probe2.py 61   (voice-6/5 DCO cells, unit strip/header compare)
"""
import sys, struct
import numpy as np
from ft3 import PluginRun, PortRun, gen_script, STRIDE, f32

S = STRIDE

CFG = {
    51: dict(k=11, watch_voices=[3],
             cells=[1056,1072,1088,1136,1424,1440,1456,1472,1488,1504,1520,1536,
                    1552,1568,1584,1856,1904,1920,2064,2256,2272,2448,2464],
             nsamp=5),
    61: dict(k=17, watch_voices=[6,5],
             cells=[4208,4640,4656,4672,4736,4752,4768,4784,4800,4816,4832,4848,
                    4880,4896,4912,4928,4944,5040,5056,5552,5584,5600,5616,5632,
                    5648,5664,5680],
             nsamp=26),
}

def rd_plug(P, v, off):
    return struct.unpack('<I', P.e.uc.mem_read(P.e.state[v] + off, 4))[0]
def rd_port(Q, off):
    import ctypes
    return struct.unpack('<I', ctypes.string_at(Q.stp + off, 4))[0]

def strip_cmp(P, Q, tag):
    """Compare per-unit global strip [84272,84448) + header [0,176) vs port."""
    import ctypes
    port_strip = ctypes.string_at(Q.stp + 84272, 176)
    port_head  = ctypes.string_at(Q.stp, 176)
    ps = np.frombuffer(port_strip, dtype=np.uint32)
    ph = np.frombuffer(port_head, dtype=np.uint32)
    for u in range(9):
        us = np.frombuffer(bytes(P.e.uc.mem_read(P.e.state[u] + 84272, 176)), dtype=np.uint32)
        uh = np.frombuffer(bytes(P.e.uc.mem_read(P.e.state[u], 176)), dtype=np.uint32)
        ds = np.nonzero(us != ps)[0]; dh = np.nonzero(uh != ph)[0]
        for i in ds.tolist():
            print(f"  [{tag}] unit{u} STRIP off {84272+4*i}: plug {us[i]:08x} ({f32(us[i]):.9g}) "
                  f"port {ps[i]:08x} ({f32(ps[i]):.9g})")
        for i in dh.tolist():
            print(f"  [{tag}] unit{u} HEAD off {4*i}: plug {uh[i]:08x} ({f32(uh[i]):.9g}) "
                  f"port {ph[i]:08x} ({f32(ph[i]):.9g})")

def dump_cells(P, Q, v, cells, tag):
    for off in cells:
        a = rd_plug(P, v, v*S + off); b = rd_port(Q, v*S + off)
        mark = '   <-- DIFF' if a != b else ''
        print(f"  [{tag}] v{v} rel {off}: plug {a:08x} ({f32(a):.9g})  port {b:08x} ({f32(b):.9g}){mark}")

def main():
    seed = int(sys.argv[1])
    cfg = CFG[seed]
    rate, patch, ev, _ = gen_script(seed)
    print(f"seed {seed} rate={rate} patch={patch}; event [{cfg['k']}] = {ev[cfg['k']]}", flush=True)
    P = PluginRun(rate, patch); Q = PortRun(rate, patch)
    for x in ev[:cfg['k']]:
        P.do(x); Q.do(x)
    print("== global strip/header compare BEFORE event ==")
    strip_cmp(P, Q, "pre")
    for v in cfg['watch_voices']:
        dump_cells(P, Q, v, cfg['cells'], "pre")
    P.do(ev[cfg['k']]); Q.do(ev[cfg['k']])
    print("== global strip/header compare AFTER event ==")
    strip_cmp(P, Q, "post")
    for v in cfg['watch_voices']:
        dump_cells(P, Q, v, cfg['cells'], "post")
    for s in range(cfg['nsamp']):
        P.do(('render', 1), block=1); Q.do(('render', 1))
        print(f"== after sample rel+{s+1} ==")
        for v in cfg['watch_voices']:
            dump_cells(P, Q, v, cfg['cells'], f"rel+{s+1}")
    Q.close()

if __name__ == '__main__':
    main()

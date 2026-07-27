#!/usr/bin/env python3
"""Map every dropped enumerator index -> unit-0 engine cells it writes, and whether
it's identity at value 0 (default) vs a mid value. Flag ones that move voice-region
cells (offset < 10512)."""
import sys, struct
sys.path.insert(0, 'tools/verify')
import e2e_emu as E
from unicorn import UC_HOOK_MEM_WRITE

dropped = [20,128,129,130,131,132,133,134,135,136,137,138,139,140,141,189,196,254,
 373,375,433,434,435,436,437,438,439,440,450,451,452,453,454,455,456,457,467,468,
 469,470,471,472,473,474,484,493,495,498,553,554,555,614,657,665,668,669,699,707,
 710,711,878,1029,1178]  # excl known: 312-318 mod, 1213-1215 choLFO, 1242-1248 flanger

e = E.E2E(); e.build(48000.0); e.snap_all()
base = e.state[0]; SZ = 0xA83010

def writes_for(idx, val):
    w = {}
    def hk(uc, access, addr, size, value, u):
        off = addr - base
        if 0 <= off < 10512:   # unit-0 voice region only
            w[off] = value
    h = e.uc.hook_add(UC_HOOK_MEM_WRITE, hk)
    try: e.dispatch(0, idx, val)
    except RuntimeError: pass
    e.uc.hook_del(h)
    return w

for idx in dropped:
    w0 = writes_for(idx, 0)
    w100 = writes_for(idx, 100)
    cells = sorted(set(w0)|set(w100))
    # identity test: does value change the cell vs value 0?
    moved = [c for c in cells if w0.get(c) != w100.get(c)]
    if cells:
        print("idx %4d -> cells %s   moved-by-value: %s" % (idx, cells, moved))

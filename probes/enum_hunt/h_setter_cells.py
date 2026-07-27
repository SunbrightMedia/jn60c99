#!/usr/bin/env python3
"""Execute the setter for the dropped PATCH2 'H' indices (878/1029/1178) under
Unicorn, hooking memory writes, to learn WHICH engine cell each writes and
whether it's identity at its controller default. Oracle-only, covenant-clean."""
import sys, struct
sys.path.insert(0, 'tools/verify')
import e2e_emu as E
from unicorn import UC_HOOK_MEM_WRITE

IDX = {878:('LFO RATE H',1058115986), 1029:('VCF CUTOFF FREQ H',1065353216),
       1178:('DELAY TAP TIME',50)}

e = E.E2E(); e.build(48000.0); e.snap_all()
base = e.state[0]
SZ = 0xA83010

def cells_written(idx, val):
    writes = {}
    def hk(uc, access, addr, size, value, u):
        off = addr - base
        if 0 <= off < SZ:
            writes[off] = value
    h = e.uc.hook_add(UC_HOOK_MEM_WRITE, hk)
    try:
        e.dispatch(0, idx, val)
    except RuntimeError:
        pass
    e.uc.hook_del(h)
    return writes

for idx,(name,dflt) in IDX.items():
    # dispatch with a value that's clearly non-default to reveal the target cell,
    # then with the controller default to check identity.
    w_lo = cells_written(idx, 0)
    w_df = cells_written(idx, dflt if dflt < 256 else 0)   # int types take small vals; float 'H' pass raw int
    # 'H' float leaves are int8x4 carrying a float bit pattern; pass a couple of byte codes
    w_255 = cells_written(idx, 255)
    allc = sorted(set(w_lo)|set(w_df)|set(w_255))
    print("=== idx %d %s (dflt=%d) ===" % (idx, name, dflt))
    for off in allc:
        def rd(off):
            return struct.unpack('<f', e.uc.mem_read(base+off,4))[0]
        print("  cell %8d  val@0=%s  val@255=%s" % (off,
              ('%.6g'%struct.unpack('<f',struct.pack('<I',w_lo[off]&0xffffffff))[0]) if off in w_lo else '-',
              ('%.6g'%struct.unpack('<f',struct.pack('<I',w_255[off]&0xffffffff))[0]) if off in w_255 else '-'))
    if not allc:
        print("  (no cell writes)")

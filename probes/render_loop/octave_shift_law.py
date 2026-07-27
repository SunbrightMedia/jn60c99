#!/usr/bin/env python3
"""Derive OCTAVE SHIFT (disp 836, declared range [-3,3]) behaviour from the
PLUGIN'S OWN setter: what does it write for the raw byte 254 (what our unsigned
decode feeds) versus the correct signed value -2, and versus 0?
Oracle-only; plugin's own dispatch 0x3B9A30 with memory-write instrumentation."""
import sys, struct
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E
from unicorn import UC_HOOK_MEM_WRITE

e = E.E2E(); e.build(48000.0); e.snap_all()
base = e.state[0]; SZ = 0xA83010

def writes(idx, val):
    w = {}
    def hk(uc, acc, addr, size, value, u):
        off = addr - base
        if 0 <= off < SZ: w[off] = value
    h = e.uc.hook_add(UC_HOOK_MEM_WRITE, hk)
    try: e.dispatch(0, idx, val & 0xffffffff)
    except RuntimeError: pass
    e.uc.hook_del(h)
    return w

for label, v in [("0 (default)", 0), ("1", 1), ("3 (max)", 3),
                 ("-1", -1), ("-2 (correct for CW53)", -2), ("-3 (min)", -3),
                 ("254 (our unsigned decode)", 254), ("255", 255)]:
    w = writes(836, v)
    cells = sorted(w)
    disp = ", ".join("%d=%s" % (c, struct.unpack('<f', struct.pack('<I', w[c] & 0xffffffff))[0]) for c in cells[:6])
    print("  836 <- %-26s writes %d cells: %s" % (label, len(cells), disp or "(none)"))

print()
print("port handling of OCTAVE SHIFT:")
import subprocess
print(subprocess.run(['grep','-rn','OCTAVE','--include=*.c','--include=*.h','/home/user/jn60c99/src/'],
                     capture_output=True, text=True).stdout or "  (no reference in src/)")

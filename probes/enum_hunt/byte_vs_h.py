#!/usr/bin/env python3
"""Compare what the BYTE VCF cutoff setter (779) writes to cell 6736 vs what the
H setter (1029) writes (= byte/255 linear). If they differ, the plugin's real
recall (which dispatches H LAST) uses a DIFFERENT cutoff than the port (byte)."""
import sys, struct
sys.path.insert(0, 'tools/verify')
import e2e_emu as E
e = E.E2E(); e.build(48000.0); e.snap_all()
base = e.state[0]
def rd(off): return struct.unpack('<f', e.uc.mem_read(base+off,4))[0]

print(" byte |  byte-setter 6736  |  H value (byte/255)  |  H-setter 6736")
for b in [0,15,32,64,100,128,160,200,255]:
    # byte setter
    e.dispatch(0, 779, b); byte6736 = rd(6736)
    # H setter: pass the float bits of byte/255
    hf = struct.unpack('<I', struct.pack('<f', b/255.0))[0]
    e.dispatch(0, 1029, hf); h6736 = rd(6736)
    print("  %3d |  %16.8f  |  %18.8f  |  %14.8f" % (b, byte6736, b/255.0, h6736))

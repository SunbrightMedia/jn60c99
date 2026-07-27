#!/usr/bin/env python3
"""Find Boost Mode / Output Gain in the plugin. (1) scan the name table for the
indices; (2) dispatch each candidate through the plugin's own setter (0x3B9A30)
under BOTH roles (flag 1 = recall, flag 0 = host) and full-state diff all 9
units; (3) if cells move, render BS Solid before/after and compare RMS."""
import sys, struct
sys.path.insert(0, 'tools/verify')
import truth, pefile
pe = pefile.PE(truth.VST3); IB = pe.OPTIONAL_HEADER.ImageBase
img = pe.get_memory_mapped_image()
NAMES, DB = 0x9a0030, 0x98c040
def name(i):
    p = struct.unpack('<Q', img[NAMES+8*i:NAMES+8*i+8])[0]
    if not (IB <= p < IB+len(img)): return None
    r = p - IB
    return img[r:img.index(b'\0', r)].decode('latin1', 'replace')
hits = []
for i in range(1200):
    n = name(i)
    if n and any(k in n.lower() for k in ('boost', 'gain', 'output', 'master v', 'volume', 'level')):
        mn, mx, df, fl = struct.unpack('<iiii', img[DB+16*i:DB+16*i+16])
        print("idx %4d %-34r min=%-4d max=%-4d default=%-4d" % (i, n, mn, mx, df))
        hits.append(i)

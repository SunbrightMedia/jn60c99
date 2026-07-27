#!/usr/bin/env python3
"""Independent corroboration: what do the plugin's own parameter descriptors say
about PORTAMENTO (798) / LEGATO (799) / ASSIGN MODE (800) and the note bus? The
descriptor DB is rva 0x98c040 + 16*idx = {min, max, default, flags} (i32 each),
names at rva 0x9a0030 (stride 8, char*). READ."""
import sys, struct
sys.path.insert(0, 'tools/verify')
import truth, pefile
pe = pefile.PE(truth.VST3); IB = pe.OPTIONAL_HEADER.ImageBase
img = pe.get_memory_mapped_image()
DB, NAMES = 0x98c040, 0x9a0030
def name(i):
    p = struct.unpack('<Q', img[NAMES+8*i:NAMES+8*i+8])[0]
    if not (IB <= p < IB+len(img)): return "<none>"
    r = p - IB; return img[r:img.index(b'\0', r)].decode('latin1')
def desc(i):
    return struct.unpack('<iiii', img[DB+16*i:DB+16*i+16])
for i in (798, 799, 800, 433, 450, 467):
    mn, mx, dflt, fl = desc(i)
    print("  idx %4d %-26r min=%-5d max=%-5d default=%-5d flags=0x%x"
          % (i, name(i), mn, mx, dflt, fl & 0xFFFFFFFF))

#!/usr/bin/env python3
"""LANE A / step 1b: resolve the RTTI names of the vtables around 0x969650 and find
EVERY vtable belonging to the assigner class family."""
import sys, struct
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import truth as _truth
import pefile

pe = pefile.PE(_truth.VST3)
IB = pe.OPTIONAL_HEADER.ImageBase
IMG = pe.get_memory_mapped_image()

def u32(a): return struct.unpack('<I', IMG[a:a+4])[0]
def u64(a): return struct.unpack('<Q', IMG[a:a+8])[0]
def cstr(a):
    e = IMG.find(b'\0', a)
    return IMG[a:e].decode('latin1')

def col_name(col_rva):
    sig, off, cd, ptd = struct.unpack('<IIII', IMG[col_rva:col_rva+16])
    return cstr(ptd + 16), off, cd

for col in (0xAFF8C0, 0xAFF938, 0xAFF9B8):
    try:
        n, off, cd = col_name(col)
        print("COL 0x%X -> %-40s offset=%d cdOffset=%d" % (col, n, off, cd))
    except Exception as ex:
        print("COL 0x%X -> ERR %s" % (col, ex))

# find every TypeDescriptor whose name contains 'Assign'
print("\n--- type descriptors matching 'Assign' ---")
off = 0
tds = []
while True:
    off = IMG.find(b'.?AV', off)
    if off < 0: break
    nm = cstr(off)
    if 'ssign' in nm:
        td = off - 16
        tds.append((td, nm))
        print("  TypeDescriptor rva 0x%X  %s" % (td, nm))
    off += 1

# for each, find COLs pointing at it, then the vtable that follows the COL pointer
print("\n--- vtables for those classes ---")
for td, nm in tds:
    pat = struct.pack('<I', td)
    o = 0
    while True:
        o = IMG.find(pat, o)
        if o < 0: break
        colr = o - 12          # ptd is at COL+12
        if 0 <= colr and u32(colr) == 1 or True:
            # verify it looks like a COL: pSelf (COL+20) == colr
            try:
                if u32(colr + 20) == colr:
                    p = struct.pack('<Q', IB + colr)
                    q = IMG.find(p)
                    if q >= 0:
                        vt = q + 8
                        print("  %s: COL 0x%X  vtable rva 0x%X" % (nm, colr, vt))
            except Exception:
                pass
        o += 1

#!/usr/bin/env python3
"""STEP 1 of docs/HOSTPATH_PARITY_SCOPE.md: read the SYSTEM velocity family's real
DEFAULTS from the plugin's own data. The port's Kbd Vel SW default (OFF -> force
velocity 100) is the last INFERRED item in the whole note path; Fixed Velocity /
Velocity Curve / Velocity Offset have never been derived at all.
SYSTEM name table rva 0x9a0030; SYSTEM param DB rva 0x5EC040 + 16*id. READ (static)."""
import sys, struct, re
sys.path.insert(0, 'tools/verify')
import truth, pefile
pe = pefile.PE(truth.VST3); IB = pe.OPTIONAL_HEADER.ImageBase
img = pe.get_memory_mapped_image()
NAMES, SYSDB, ENGDB = 0x9a0030, 0x5EC040, 0x98c040

def name(i):
    p = struct.unpack('<Q', img[NAMES+8*i:NAMES+8*i+8])[0]
    if not (IB <= p < IB+len(img)): return None
    r = p - IB
    e = img.index(b'\0', r)
    if e - r > 96: return None
    try: return img[r:e].decode('latin1')
    except Exception: return None

pat = re.compile(r'veloc|local sw|master tune|fixed', re.I)
hits = []
for i in range(1400):
    n = name(i)
    if n and pat.search(n):
        hits.append((i, n))
print("=== name-table entries matching velocity/local/tune (name table rva 0x9a0030) ===")
for i, n in hits:
    smn, smx, sdf, sfl = struct.unpack('<iiii', img[SYSDB+16*i:SYSDB+16*i+16])
    emn, emx, edf, efl = struct.unpack('<iiii', img[ENGDB+16*i:ENGDB+16*i+16])
    print("  idx %4d %-30r  SYSTEM_DB{min=%-6d max=%-6d def=%-6d}  ENGINE_DB{min=%-5d max=%-5d def=%-5d}"
          % (i, n, smn, smx, sdf, emn, emx, edf))

# The SYSTEM tree is addressed by its OWN id space; CLAUDE.md records
# "Keyboard Velocity SW = index 12" in the fm.SYSTEM.COM name table.
print("\n=== fm.SYSTEM.COM low ids 0..31, SYSTEM DB at rva 0x5EC040 ===")
for i in range(32):
    mn, mx, df, fl = struct.unpack('<iiii', img[SYSDB+16*i:SYSDB+16*i+16])
    print("  id %3d  min=%-8d max=%-8d default=%-8d flags=0x%08x   %s"
          % (i, mn, mx, df, fl & 0xFFFFFFFF, name(i) or ''))

#!/usr/bin/env python3
"""LANE A / step 1 (static half): locate the CAssignJu60 vtable in the image and
dump every slot, cross-referencing refs/manifest.tsv. No Unicorn, no libjuno."""
import sys, struct, os
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import truth as _truth
import pefile

pe = pefile.PE(_truth.VST3)
IB = pe.OPTIONAL_HEADER.ImageBase
IMG = pe.get_memory_mapped_image()

MAN = {}
for ln in open('/home/user/jn60c99/refs/manifest.tsv'):
    p = ln.rstrip('\n').split('\t')
    if p[0].startswith('0x'):
        MAN[int(p[0], 16)] = (p[1], p[2], p[3])

TARGETS = {0x355820: 'assigner noteOn entry (held-mask + 4-way mode dispatch)',
           0x355780: 'assigner noteOff entry',
           0x3549B0: 'refresh(cat) -> re-read 800 + 799',
           0x354A60: 'refresh LEGATO(799) only',
           0x355940: 'prepare(sr): hold off + allnotesoff + re-read 800/799',
           0x355AB0: 'per-block sample counter += n  (assign+168)'}

# find all image offsets holding a pointer to any target
hits = {}
for t in TARGETS:
    pat = struct.pack('<Q', IB + t)
    off = 0
    while True:
        off = IMG.find(pat, off)
        if off < 0: break
        hits.setdefault(t, []).append(off)
        off += 1
for t in sorted(TARGETS):
    print("rva 0x%06X  %-55s ptr-sites: %s" % (t, TARGETS[t],
          ' '.join('0x%X' % h for h in hits.get(t, []))))

# vtable = contiguous run of image-range pointers containing 0x355820
def is_code_ptr(q):
    return IB <= q < IB + len(IMG)

cands = []
for t in (0x355820, 0x355780):
    for h in hits.get(t, []):
        # walk back while previous qword is a code pointer
        s = h
        while s >= 8:
            q = struct.unpack('<Q', IMG[s - 8:s])[0]
            if not is_code_ptr(q): break
            s -= 8
        e = h
        while e + 8 <= len(IMG):
            q = struct.unpack('<Q', IMG[e:e + 8])[0]
            if not is_code_ptr(q): break
            e += 8
        cands.append((s, e))
cands = sorted(set(cands))
for (s, e) in cands:
    print("\n=== vtable candidate: image rva 0x%X .. 0x%X  (%d slots) ===" % (s, e, (e - s) // 8))
    for i in range((e - s) // 8):
        q = struct.unpack('<Q', IMG[s + 8 * i:s + 8 * i + 8])[0]
        rva = q - IB
        nm, sz, xr = MAN.get(rva, ('?', '?', '?'))
        print("  slot +%3d  [%2d]  rva 0x%06X  %-24s size %-6s xrefs %s" %
              (8 * i, i, rva, nm, sz, xr))

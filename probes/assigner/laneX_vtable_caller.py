#!/usr/bin/env python3
"""Locate the vtable slot of the assigner's onParameterChanged (0x3549B0) and find
every call site in .text that invokes THAT slot. READ (static scan of the image)."""
import sys, struct, re
sys.path.insert(0, 'tools/verify')
import truth, pefile

pe = pefile.PE(truth.VST3)
IB = pe.OPTIONAL_HEADER.ImageBase
img = pe.get_memory_mapped_image()
TARGET = 0x3549B0

# 1) find every qword in the image equal to IB+TARGET (vtable entries)
needle = struct.pack('<Q', IB + TARGET)
hits = [m.start() for m in re.finditer(re.escape(needle), img)]
print("vtable-entry candidates for 0x%X: %s" % (TARGET, [hex(h) for h in hits]))

for h in hits:
    # walk back to the start of the vtable: contiguous run of plausible code ptrs
    start = h
    while start >= 8:
        q = struct.unpack('<Q', img[start-8:start])[0]
        if IB + 0x1000 <= q < IB + len(img):
            start -= 8
        else:
            break
    slot = (h - start) // 8
    print("  vtable base rva 0x%X, entry is SLOT %d (offset +%d)" % (start, slot, slot*8))
    # dump a few neighbours
    for k in range(max(0, slot-2), slot+3):
        q = struct.unpack('<Q', img[start+8*k:start+8*k+8])[0]
        print("     slot %2d (+%3d) -> 0x%X%s" % (k, 8*k, q - IB, "   <== onParam" if k == slot else ""))

#!/usr/bin/env python3
"""The host parameter entry 0x3C7AE0 special-cases a handful of engine indices,
routing them to the object at HOST+136+64u INSTEAD of (or as well as) the
0x3B9A30 dispatch our recall drives. Name them via the plugin's own name table
(rva 0x9a0030, stride 8, char*) and say which our recall can reach. READ."""
import sys, struct
sys.path.insert(0, 'tools/verify')
import truth, pefile

pe = pefile.PE(truth.VST3)
IB = pe.OPTIONAL_HEADER.ImageBase
img = pe.get_memory_mapped_image()
NAMES = 0x9a0030

def name(idx):
    p = struct.unpack('<Q', img[NAMES + 8*idx: NAMES + 8*idx + 8])[0]
    if not (IB <= p < IB + len(img)):
        return "<none>"
    r = p - IB
    e = img.index(b'\0', r)
    return img[r:e].decode('latin1')

# from decomp_3C0000.c:5781+  (v10 = engine index, v11 = HOST+136+64u)
ROUTED = {
    756: ("sub_7FF91E024ED0(obj136, v)", "AND dispatches"),
    831: ("sub_7FF91E0249F0(obj136, v!=0, 0)", "NO dispatch"),
    832: ("sub_7FF91E024E50(obj136, v)", "NO dispatch"),
    833: ("sub_7FF91E0249B0(obj136, v, ...)", "NO dispatch"),
    834: ("sub_7FF91E024F10(obj136, v, 0)", "NO dispatch"),
    835: ("sub_7FF91E024EE0(obj136, v, 0)", "NO dispatch"),
}
XFORM = {707: "v-100", 665: "v-100", 20: "v-100", 22: "v-12", 769: "v-11",
         871: "v!=0"}
print("=== host-entry SPECIAL ROUTING (object at HOST+136+64u) ===")
for i, (fn, disp) in sorted(ROUTED.items()):
    print("  idx %4d  %-40r  %-14s -> %s" % (i, name(i), disp, fn))
print("\n=== host-entry VALUE TRANSFORMS (then normal dispatch) ===")
for i, x in sorted(XFORM.items()):
    print("  idx %4d  %-40r  value := %s" % (i, name(i), x))

# which of these does the port's recall / the plugin's recall enumerator touch?
import re
src = open('src/juno_apply.c').read()
print("\n=== does the PORT bind any of them? ===")
for i in sorted(set(ROUTED) | set(XFORM)):
    hit = re.search(r'\b%d\b' % i, src)
    print("  idx %4d  %-40r  port juno_apply.c mentions: %s"
          % (i, name(i), "yes" if hit else "no"))

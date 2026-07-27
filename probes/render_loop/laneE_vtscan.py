#!/usr/bin/env python3
"""LANE E: find every vtable-like location holding noteOn 0x3C7330 / render
0x3C7400 / 0x34B070, and dump the slot layout around each. Answers: which
vtable does the queue consumer's *(a1+272) object use, and what is its slot 6?"""
import sys, struct
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E

uc = E.E2E().uc
IB = E.IB
TARGETS = {0x3C7330:'noteOn', 0x3C7400:'blockRender', 0x34B070:'baseSlot6',
           0x3C7AE0:'hostParamEntry', 0x3C72D0:'noteOff', 0x3C7230:'slot13'}
# read the whole image in chunks
CH = 1 << 20
hits = {}
for base in range(0, E.IMGSZ, CH):
    n = min(CH, E.IMGSZ - base)
    try: buf = bytes(uc.mem_read(IB + base, n))
    except Exception: continue
    for rva_t, name in TARGETS.items():
        pat = struct.pack('<Q', IB + rva_t)
        off = buf.find(pat)
        while off >= 0:
            if (base + off) % 8 == 0:
                hits.setdefault(name, []).append(base + off)
            off = buf.find(pat, off + 1)
for name in TARGETS.values():
    print(name, [hex(x) for x in hits.get(name, [])])

# For each location holding noteOn, treat it as vtable slot 16 and dump slots 0..33
print()
for loc in hits.get('noteOn', []):
    vt = loc - 128
    print("=== candidate vtable @ rva 0x%x (noteOn at +128) ===" % vt)
    for s in range(0, 34*8, 8):
        try: q = int.from_bytes(uc.mem_read(IB + vt + s, 8), 'little')
        except Exception: break
        if IB <= q < IB + E.IMGSZ:
            print("  +%-4d slot %2d rva 0x%X" % (s, s//8, q - IB))
        else:
            print("  +%-4d slot %2d <0x%x>" % (s, s//8, q))

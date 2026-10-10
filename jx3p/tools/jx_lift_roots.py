#!/usr/bin/env python3
"""jx_lift_roots.py -- the lifted parameter system's ROOTS beyond the host entry (JX-11): the slot-family closure.

The oracle's dynamic reach (jx3p/gen/jx_lift_reach.json) names the targets its indirect calls and jumps met. A
virtual call through a base-class pointer can meet another class's method in another mode -- the master's effect
type 5 (the phaser, CDSPJx3pEfxPh) is never set by the factory bank, and its slot-0 method 0x35A1A0 trapped as
"not lifted" on the variant 0:65=5 (2026-10-10). So: the classes are the ones whose objects LIVE in the plugin's
heap after its boot (the parameter system allocates nothing: their vtables are every qword of the heap that points
at a vtable -- an RTTI object locator before it, code pointers in it); two classes are RELATED when they share a
base class (MSVC RTTI: the class hierarchy descriptor's base class array); and every reached target at slot k of
a class adds slot k of every related live class; the control classes (the parameter object, the assigner, the
keyboard arpeggiator) add every slot (FULL_CLASSES). The three code pointers the heap stores outside any vtable
(a step function of the note store, 0x3F0C20, which jx3p/src/jx_seq.c ports; the render worker's entry 0x3F8C60;
a runtime-library routine 0x6B6B20) are listed, not lifted: no parameter call reaches them. The result is
jx3p/gen/jx_lift_roots.json; jx_lift_gate.py lifts from the host entry and these roots.

    python3 jx3p/tools/jx_lift_roots.py [--check]     (--check: equal to the committed file or exit 1)
"""
import collections
import json
import os
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
OUT = os.path.join(REPO, 'jx3p', 'gen', 'jx_lift_roots.json')
REACH = os.path.join(REPO, 'jx3p', 'gen', 'jx_lift_reach.json')
GUEST = os.path.join(REPO, 'jx3p', 'gen', 'jx_guest_44k.bin')
IB = 0x180000000
FULL_CLASSES = ('.?AVCPrmDSPJx3pPlugin@@', '.?AVCAssignB@@', '.?AVCKbdArp@@')
TEXT = (0x1000, 0x96B000)
RDATA = (0x96B000, 0xC7B000)


def image():
    """the plugin's image as mapped (sections at their rvas), from the checksummed binary (tools/verify/jx_emu)"""
    sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
    import jx_emu as J
    return bytes(J.IMG)


def heap_image():
    b = open(GUEST, 'rb').read()
    hb, hlen = struct.unpack_from('<2Q', b, 8)
    heap = bytearray(hlen)
    o = 8 + 56 + 8
    n, = struct.unpack_from('<I', b, o)
    o += 4
    for _ in range(n):
        off, ln = struct.unpack_from('<II', b, o)
        heap[off:off + ln] = b[o + 8:o + 8 + ln]
        o += 8 + ln
    return bytes(heap)


def main():
    img, heap = image(), heap_image()
    q = lambda r: struct.unpack_from('<Q', img, r)[0]
    u32 = lambda r: struct.unpack_from('<I', img, r)[0]

    def vt_size(r):
        if not (RDATA[0] <= r < RDATA[1]) or r % 8 or not (RDATA[0] <= q(r - 8) - IB < RDATA[1]):
            return 0
        n = 0
        while TEXT[0] <= q(r + 8 * n) - IB < TEXT[1]:
            n += 1
        return n

    def name(td):
        s = img[td + 16:td + 16 + 256]
        return s[:s.index(b'\0')].decode('latin1')

    def bases(r):
        col = q(r - 8) - IB
        chd = u32(col + 16)
        arr = u32(chd + 12)
        return [name(u32(u32(arr + 4 * i))) for i in range(u32(chd + 8))]
    vts, fptrs = set(), set()
    for i in range(0, len(heap) - 7, 8):
        v = struct.unpack_from('<Q', heap, i)[0] - IB
        if RDATA[0] <= v < RDATA[1] and vt_size(v):
            vts.add(v)
        elif TEXT[0] <= v < TEXT[1]:
            fptrs.add(v)
    vts = sorted(vts)
    ent = {v: [q(v + 8 * k) - IB for k in range(vt_size(v))] for v in vts}
    names = {v: bases(v) for v in vts}
    fam = {v: set(names[v][1:]) for v in vts}
    reached = {int(t, 16) for ts in json.load(open(REACH))['indirect'].values() for t in ts}
    add = set()
    for v in vts:
        for k, f in enumerate(ent[v]):
            if f in reached:
                for w in vts:
                    if (w == v or fam[v] & fam[w]) and k < len(ent[w]):
                        add.add(ent[w][k])
    # the CONTROL classes in full: the parameter object (its 329 slots are the parameter paths' own handlers --
    # slot 216, 0x3E0ED0, trapped when ARPEGGIO switched on with a key held, a slot no related class reached),
    # the assigner and the keyboard arpeggiator (the note path the parameter calls drive). The DSP classes keep
    # the slot closure: their unreached slots are their renders (CJx3pSim alone would add 30,000 instructions).
    for v in vts:
        if names[v][0] in FULL_CLASSES:
            add.update(ent[v])
    roots = sorted(add - {0x3F9A30})
    res = dict(note='jx_lift_roots.py: the slot-family closure of the reached virtual targets over the classes '
                    'live in the plugin\'s heap after its boot (the code pointers the heap stores are listed, not roots)',
               classes=[dict(vtable='%x' % v, cls=names[v][0], slots=len(ent[v])) for v in vts],
               code_pointers=['%x' % f for f in sorted(fptrs)],
               roots=['%x' % r for r in roots])
    txt = json.dumps(res, indent=0) + '\n'
    if '--check' in sys.argv:
        same = os.path.exists(OUT) and open(OUT).read() == txt
        print('jx_lift_roots --check: %s' % ('EQUAL to the committed file' if same else 'DIFFERS -- RED'))
        return 0 if same else 1
    open(OUT, 'w').write(txt)
    print('%s: %d live classes, %d roots (%d not reached by the oracle), %d code pointers listed' % (
        OUT, len(vts), len(roots), len(set(roots) - reached), len(fptrs)))
    return 0


if __name__ == '__main__':
    sys.exit(main())

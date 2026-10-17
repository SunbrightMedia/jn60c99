#!/usr/bin/env python3
"""boss_static_roots.py -- the STATIC root set for the first BOSS lift (L2 before a boot, boss/docs/LIFT_PLAN.md 7.3).

READ only: every MSVC x64 RTTI CompleteObjectLocator (sig 1, pSelf == its own rva) whose type name matches --match
(default: the pedal DSP classes C<Model>Dsp and the four CEfx* plugin wrappers), its vtable (the qword after the
COL pointer), and every slot that points into .text. Those methods are the roots; the lifter's recursive descent
closes them over direct calls and jump tables. Indirect calls stay runtime dispatch until L1's dynamic census adds
their targets (--dyn). Harness = plumbing: it reads the image, it reimplements nothing.

usage: python3 boss/tools/boss_static_roots.py [--match REGEX] [--json out.json]   (prints the roots, comma list)
"""
import json, os, re, struct, sys
import pefile
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import boss_truth  # noqa: E402

DEFAULT = r'^\.\?AV(\?\$)?C[A-Za-z0-9]+Dsp@|^\.\?AV\?\$CEfx'


def vtables(match):
    pe = pefile.PE(boss_truth.VST3, fast_load=True)
    IB = pe.OPTIONAL_HEADER.ImageBase; img = pe.get_memory_mapped_image()
    sec = {s.Name.rstrip(b'\0').decode(): (s.VirtualAddress, s.VirtualAddress + s.Misc_VirtualSize) for s in pe.sections}
    tlo, thi = sec['.text']; rlo, rhi = sec['.rdata']
    rx = re.compile(match)
    cols = {}
    for a in range(rlo, rhi - 24, 4):
        sig, off, cdo, ptd, pch, pself = struct.unpack_from('<6I', img, a)
        if sig != 1 or pself != a: continue
        nm = img[ptd + 16: ptd + 16 + 256].split(b'\0')[0].decode('latin1', 'replace')
        if rx.search(nm): cols[IB + a] = (nm, off)
    out = []
    for a in range(rlo, rhi - 8, 8):
        q = struct.unpack_from('<Q', img, a)[0]
        if q not in cols: continue
        nm, off = cols[q]; slots = []; v = a + 8
        while v < rhi:
            t = struct.unpack_from('<Q', img, v)[0] - IB
            if not (tlo <= t < thi): break
            slots.append(t); v += 8
        out.append(dict(name=nm, offset=off, vtable=a + 8, slots=slots))
    return out


def main():
    a = sys.argv[1:]
    match = a[a.index('--match') + 1] if '--match' in a else DEFAULT
    vts = vtables(match)
    roots = sorted({s for v in vts for s in v['slots']})
    if '--json' in a:
        json.dump(dict(match=match, vtables=vts, roots=roots), open(a[a.index('--json') + 1], 'w'), indent=1)
    sys.stderr.write('%d vtables, %d distinct methods\n' % (len(vts), len(roots)))
    print(','.join('%#x' % r for r in roots))


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""jx_host_drive_check.py -- the JX oracle's HOST drive (CLAUDE.md: "INFERRED defect: jx_emu.build() also
hands BUILD a zero HOST (JP8 D7 / playbook 101) -- check it"), checked 2026-10-10.

The plugin's processor builds its engine HOST with the factory 0x3F84E0 (ALLOC 0x880 + ctor: vtable 0xA15B88,
[HOST+8] = 96000.0, [HOST+0x38] = 8 voices; the call at 0x32064B, READ). The old jx_emu.build() handed BUILD a
zero block instead (JX_EMU_LEGACY_HOST=1 still does). This check boots both the same way (static init, BUILD,
FTZ, SETSR, the controller's default push, a recall of patch 0) and compares EVERY allocation, the HOST and the
image word for word, then again after a note sequence (9 note-ons over 8 voices, a note-off, a re-trigger) and
after a render, and compares the rendered output. Heap pointers may differ (the factory's allocation shifts the
heap); a word counts as a pointer only when the aligned qword holding it is a heap address in BOTH boots. Every
other difference is a value. The zero HOST's missing vtable (HOST+0 / +4) is reported, not counted.

READ: SETSR (0x3F9970) returns at once when the new rate equals [HOST+8] (`ucomiss xmm6,[rcx+8]; je`). The
factory HOST is built at 96000, so at 96000 SETSR changes nothing; the zero HOST's BUILD runs at rate 0 and its
SETSR derives every rate cell. MEASURED: see jx3p/docs/S3_STATUS.md (the HOST drive section).

  python3 jx3p/tools/jx_host_drive_check.py [RATE ...]     default 44100 48000 96000
  python3 jx3p/tools/jx_host_drive_check.py --tooth        a planted difference must be reported (exit 0 = bites)
Exit 0 = no value word and no output sample differ at any rate.
"""
import os
import struct
import sys

import numpy as np

sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))),
                                'tools', 'verify'))
import jx_emu as J  # noqa: E402

NOTES = (60, 64, 67, 72, 76, 79, 84, 88, 91)
RENDER = 2400


def boot(factory, sr):
    jx = J.JX()
    jx.run_static_init()
    jx.n0 = len(jx.allocs)
    jx.build(factory=factory)
    jx.set_ftz()
    jx.set_sr(sr)
    ok, fail = jx.host_init()
    assert not fail, 'host_init: %d writes failed' % fail
    jx.recall(0)
    return jx


def allocs(jx, factory):
    al = list(jx.allocs)
    if factory:
        assert al[jx.n0] == (jx.HOST, J.HOST_SZ)
        del al[jx.n0]
    return al


def diff(x, y, lo, hi):
    """the word offsets (in bytes) of the value words that differ between x and y"""
    n = min(len(x), len(y)) & ~7
    xa = np.frombuffer(x[:n], dtype='<u4')
    ya = np.frombuffer(y[:n], dtype='<u4')
    d = np.nonzero(xa != ya)[0]
    if not len(d):
        return []
    xq = np.frombuffer(x[:n], dtype='<u8')[d // 2]
    yq = np.frombuffer(y[:n], dtype='<u8')[d // 2]
    ptr = (xq >= lo) & (xq < hi) & (yq >= lo) & (yq < hi)
    return [4 * int(o) for o in d[~ptr]]


def compare(a, b, tag, show=4):
    lo, hi = J.HEAP_BASE, max(a.heap, b.heap)
    za, fb = allocs(a, False), allocs(b, True)
    if [s for _, s in za] != [s for _, s in fb]:
        raise SystemExit('%s: the allocation lists differ (%d vs %d) -- the drives diverged structurally'
                         % (tag, len(za), len(fb)))
    hw = [o for o in diff(bytes(a.uc.mem_read(a.HOST, J.HOST_SZ)), bytes(b.uc.mem_read(b.HOST, J.HOST_SZ)),
                          lo, hi) if o >= 8]
    total = len(hw)
    lines = ['    HOST: %d value words%s (the vtable at +0 not counted)' % (len(hw), ' ' + str([hex(o) for o in hw[:show]])
                                                                           if hw else '')]
    units = {p: u for u, p in enumerate(a.state)}
    for (pa, s), (pb, _) in zip(za, fb):
        w = diff(bytes(a.uc.mem_read(pa, s)), bytes(b.uc.mem_read(pb, s)), lo, hi)
        if w:
            total += len(w)
            what = 'unit %d state' % units[pa] if pa in units else 'alloc 0x%x bytes' % s
            ex = ', '.join('+0x%x %r -> %r' % (o, struct.unpack('<f', a.uc.mem_read(pa + o, 4))[0],
                                               struct.unpack('<f', b.uc.mem_read(pb + o, 4))[0]) for o in w[:show])
            lines.append('    %s: %d value words (zero -> factory: %s)' % (what, len(w), ex))
    iw = diff(bytes(a.uc.mem_read(J.IB, J.IMGSZ)), bytes(b.uc.mem_read(J.IB, J.IMGSZ)), lo, hi)
    if iw:
        total += len(iw)
        lines.append('    image: %d value words %s' % (len(iw), [hex(o) for o in iw[:show]]))
    print('  %s: %d value words differ' % (tag, total))
    for line in lines[:14]:
        print(line)
    if len(lines) > 14:
        print('    ... %d more differing allocations' % (len(lines) - 14))
    return total


def check(sr, tooth=False):
    a, b = boot(False, sr), boot(True, sr)
    print('sr %g:' % sr)
    bad = compare(a, b, 'after the boot')
    for jx in (a, b):
        for n in NOTES:
            jx.note_on(n, 100)
        jx.note_off(64, 64)
        jx.note_on(62, 90)
    if tooth:                                   # plant: one value word of unit 3 differs
        cell = b.state[3] + 0x1000
        w = struct.unpack('<I', b.uc.mem_read(cell, 4))[0]
        b.uc.mem_write(cell, struct.pack('<I', w ^ 0x00400000))
    bad += compare(a, b, 'after %d note events' % (len(NOTES) + 2))
    la, lb = a.render(RENDER), b.render(RENDER)
    first = next((i for i in range(RENDER) if la[0][i] != lb[0][i] or la[1][i] != lb[1][i]), None)
    bad += compare(a, b, 'after a %d-sample render' % RENDER)
    print('  output: %s' % ('every sample of both channels equal' if first is None else
                            'differs from sample %d' % first))
    return bad + (0 if first is None else 1)


def main():
    if '--tooth' in sys.argv:
        extra = check(44100.0, tooth=True)
        print('jx_host_drive_check --tooth: %s' % ('BITES' if extra else 'DID NOT BITE'))
        return 0 if extra else 1
    rates = [float(r) for r in sys.argv[1:]] or [44100.0, 48000.0, 96000.0]
    bad = sum(check(sr) for sr in rates)
    print('jx_host_drive_check: %s' % ('GREEN -- the zero HOST and the factory HOST give the same engine'
                                       if not bad else 'RED -- the HOST drive changes the engine'))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())

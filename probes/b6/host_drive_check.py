#!/usr/bin/env python3
"""host_drive_check.py -- the JUNO e2e MODEL's HOST drive vs the plugin's own (2026-10-10, playbook 194).

e2e_emu.build() hands BUILD a zero 0x8000 HOST ([HOST+0x38] = 8 written): BUILD runs at rate 0. The plugin's
processor builds the HOST with its factory, rva 0x3C6790 = operator new(0x880) + the CWaveGen ctor 0x3C5A50
(vtable rva 0x9DF1D8, [HOST+8] = 96000.0, [HOST+0x38] = 8; EXECUTED here). This check boots both through
e2e_emu (BUILD, setSampleRate, FTZ), then compares EVERY allocation, the HOST and the image word for word, then
again after 11 note events and after a render, and compares the rendered output. A word counts as a pointer
only when its aligned qword is a heap address in BOTH boots; every other difference is a value.

MEASURED 2026-10-10 (48000 and 96000): every unit's ramp array (a 0x7CD7-byte allocation) holds 244 words
that are +inf on the zero HOST and finite on the factory HOST (0.000822, 0.0148, 0.0260 = 2500/96000 ...);
at 96000 89 more words of each unit state differ (setSampleRate returns when the rate is unchanged); the
outputs differ from sample 960 at both rates (11 note events, then the render). So the e2e model is a MODEL of the engine, not the plugin's
boot: the product claims are graded on the plugin's real boot (tools/verify/host_process_emu.py: the factory,
BUILD at 96000, its ramps in flight -- CLAIMS A25, A29), and juno_gui_plugin_init builds like it. The engine
gates grade juno_gui_create against this model (docs/B6_WRAPPER_BOOT.md, "The zero HOST").

  python3 probes/b6/host_drive_check.py [RATE ...]     default 48000 96000; exit 1 when the drives differ
Unicorn only: never loads libjuno (two-process rule).
"""
import os
import struct
import sys

import numpy as np

sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))),
                                'tools', 'verify'))
import e2e_emu as E  # noqa: E402

FACTORY = E.IB + 0x3C6790


class Fac(E.E2E):
    """e2e_emu's build() on the HOST the plugin's factory builds (instead of its zero block)"""
    def build(self, sr):
        n0 = len(self.allocs)
        h = self.call(FACTORY, count=400_000_000)
        assert h and self.allocs[n0][0] == h, 'factory alloc %r' % (self.allocs[n0:n0 + 2],)
        assert struct.unpack('<f', self.uc.mem_read(h + 8, 4))[0] == 96000.0 and self.rd_i32(h + 0x38) == 8
        self.fac_size = self.allocs[n0][1]
        real, uc = self.bump, self.uc
        orig = uc.mem_write
        once, first = [True], [True]

        def bump(sz):                                # build() takes its HOST from bump(0x8000) ONCE ...
            if once[0]:
                once[0] = False
                return h
            return real(sz)

        def mem_write(a, d):                         # ... and zeroes it: skip that one write
            if first[0] and a == h and len(d) == 0x8000:
                first[0] = False
                return
            orig(a, d)
        self.bump, uc.mem_write = bump, mem_write
        try:
            E.E2E.build(self, sr)
        finally:
            self.bump, uc.mem_write = real, orig


def diff(x, y, lo, hi):
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


def compare(a, b, tag):
    lo, hi = E.HEAP_BASE, max(a.heap, b.heap)
    za, fb = a.allocs, b.allocs[1:]                  # b's first allocation is its HOST
    assert [s for _, s in za] == [s for _, s in fb], 'the allocation lists differ'
    hw = [o for o in diff(bytes(a.uc.mem_read(a.HOST, b.fac_size)), bytes(b.uc.mem_read(b.HOST, b.fac_size)),
                          lo, hi) if o >= 8]
    total, kinds = len(hw), {}
    units = {p: u for u, p in enumerate(a.state)}
    for (pa, s), (pb, _) in zip(za, fb):
        w = diff(bytes(a.uc.mem_read(pa, s)), bytes(b.uc.mem_read(pb, s)), lo, hi)
        if w:
            total += len(w)
            k = 'unit state' if pa in units else 'alloc 0x%x bytes' % s
            n, ex = kinds.get(k, (0, None))
            kinds[k] = (n + 1, ex or (len(w), w[0], struct.unpack('<f', a.uc.mem_read(pa + w[0], 4))[0],
                                      struct.unpack('<f', b.uc.mem_read(pb + w[0], 4))[0]))
    iw = diff(bytes(a.uc.mem_read(E.IB, E.IMGSZ)), bytes(b.uc.mem_read(E.IB, E.IMGSZ)), lo, hi)
    total += len(iw)
    print('  %s: %d value words (HOST %d past its vtable, image %d)' % (tag, total, len(hw), len(iw)))
    for k, (n, (c, o, x, y)) in sorted(kinds.items()):
        print('    %d x %s: e.g. %d words, first +0x%x zero %r -> factory %r' % (n, k, c, o, x, y))
    return total


def run(sr):
    a = E.E2E()
    a.build(sr)
    a.set_ftz()
    b = Fac()
    b.build(sr)
    b.set_ftz()
    print('sr %g:' % sr)
    t = compare(a, b, 'after the build')
    for e in (a, b):
        for n in (60, 64, 67, 72, 76, 79, 84, 88, 91):
            e.note_on(n, 100)
        e.note_off(64, 64)
        e.note_on(62, 90)
    t += compare(a, b, 'after 11 note events')
    la, lb = a.render(1200), b.render(1200)
    first = next((i for i in range(1200) if la[0][i] != lb[0][i] or la[1][i] != lb[1][i]), None)
    t += compare(a, b, 'after a 1200-sample render')
    print('  output: %s' % ('every sample equal' if first is None else 'differs from sample %d' % first))
    return t + (first is not None)


if __name__ == '__main__':
    rates = [float(r) for r in sys.argv[1:]] or [48000.0, 96000.0]
    bad = sum(run(r) for r in rates)
    print('host_drive_check: %s' % ('the zero HOST and the factory HOST give the same engine' if not bad else
                                    'the drives differ -- the e2e model is not the plugin\'s boot'))
    sys.exit(1 if bad else 0)

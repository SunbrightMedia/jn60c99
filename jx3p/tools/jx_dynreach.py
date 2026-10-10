#!/usr/bin/env python3
"""jx_dynreach.py -- the DYNAMIC reach of the JX-3P engine's host entry (HOSTPARAM 0x3F9A30) on a RUNNING engine,
for the lift of the parameter system (jx3p/docs/HOST_LAYER.md 4.3; the method of jp8/tools/jp8_dynreach.py).

The oracle: tools/verify/jx_emu.py boot(44100, product=True, patch=A) -- the plugin's own boot and patch load --,
a note held, samples rendered. Then, with a BLOCK hook installed (the TB cache flushed first: blocks translated
before a hook carry no callbacks), the judged work: every factory patch's 75 records through the host entry in
turn (warm loads, every effect mode the bank holds), then every id of the host entry's id map set to each value
of a sweep (0, 1, 2, 3, 5, 7, 9, 64, 127, 128, 255, 1000, -1), each followed by the base patch's records again.
Recorded: every executed instruction address, and at every indirect call/jmp site every target reached; every
import stub reached (the parameter system calls none: EXECUTED 2026-10-10).

  python3 jx3p/tools/jx_dynreach.py OUT.json [--base A] [--patches 0-63] [--no-sweep]
"""
import collections
import json
import os
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import jx_emu as J                                    # noqa: E402
import capstone                                       # noqa: E402
from capstone import x86                              # noqa: E402
from unicorn import UC_HOOK_BLOCK                     # noqa: E402

SWEEP = (0, 1, 2, 3, 5, 7, 9, 64, 127, 128, 255, 1000, -1)


def main():
    a = sys.argv[1:]
    out = a[0]
    opt = lambda k, d: a[a.index(k) + 1] if k in a else d
    base = int(opt('--base', '0'))
    lo, _, hi = opt('--patches', '0-63').partition('-')
    patches = list(range(int(lo), int(hi or lo) + 1))
    md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_64)
    md.detail = True
    executed, indirect, imports = set(), collections.defaultdict(set), collections.Counter()
    stub_lo, stub_hi = J.STUB_BASE, J.STUB_BASE + 8 * len(J.IMPORTS) + 8
    bcache, prev = {}, [None]
    img = bytes(J.IMG)

    def block(uc, address, size, user):
        rva = address - J.IB
        if prev[0] is not None:
            indirect[prev[0]].add(rva)
            prev[0] = None
        if stub_lo <= address < stub_hi:
            imports[(address - stub_lo) // 8] += 1
            return
        if not (0 <= rva < len(img)):
            return
        k = (address, size)
        e = bcache.get(k)
        if e is None:
            rvas, last = [], None
            for ins in md.disasm(img[rva:rva + size], address):
                rvas.append(ins.address - J.IB)
                last = ins
            ind = last is not None and last.mnemonic in ('call', 'jmp') and last.operands[0].type != x86.X86_OP_IMM
            e = (tuple(rvas), rvas[-1] if ind else None)
            bcache[k] = e
        executed.update(e[0])
        if e[1] is not None:
            prev[0] = e[1]

    t0 = time.time()
    jx = J.JX().boot(44100.0, snap=False, product=True, patch=base)
    jx.note_on(60, 100)
    jx.render(2048, 256)
    uc = jx.uc
    uc.ctl_flush_tb()
    uc.hook_add(UC_HOOK_BLOCK, block)
    recs = J.JX.records()['patches']
    for p in patches:
        jx.host_records(recs[p])
    print('[%6.1fs] %d warm loads: %d addresses, %d indirect sites' % (
        time.time() - t0, len(patches), len(executed), len(indirect)), flush=True)
    if '--no-sweep' not in a:
        ids = sorted(jx.id_map())
        for n, pid in enumerate(ids):
            for v in SWEEP:
                jx.call(J.HOSTPARAM, rcx=jx.HOST, rdx=pid, r8=v & 0xFFFFFFFF, count=400_000_000)
            jx.host_records(recs[base])
            if n % 100 == 99:
                print('[%6.1fs] %d of %d ids swept: %d addresses, %d indirect sites' % (
                    time.time() - t0, n + 1, len(ids), len(executed), len(indirect)), flush=True)
    names = {i: str(x) for i, x in enumerate(J.IMPORTS)}
    json.dump(dict(base=base, patches=patches, sweep=list(SWEEP) if '--no-sweep' not in a else [],
                   executed=sorted('%x' % x for x in executed),
                   indirect={'%x' % s: sorted('%x' % t for t in ts) for s, ts in indirect.items()},
                   imports={str(i): [names.get(i, '?'), c] for i, c in sorted(imports.items())}), open(out, 'w'))
    print('wrote %s: %d addresses, %d indirect sites, imports %s' % (
        out, len(executed), len(indirect), dict(imports) or 'none'))
    return 0


if __name__ == '__main__':
    sys.exit(main())

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

  python3 jx3p/tools/jx_dynreach.py OUT.json [--base A] [--patches 0-63] [--no-sweep] [--ctl]

--ctl: instead of the loads and the sweep, the render driver's KIND-0 targets on the running engine (JX-12):
the engine's CC entry (vt+0x88, 0x34AD50: 1 mod, 10, 11 expression, 64 sustain, 123 all notes off, and CCs it
ignores), its bend entry (vt+0x98, 0x3F91B0), the three empty entries (vt+0x90 / +0xA0 / +0xA8), with keys
pressed and released around the sustain and the all-notes-off (ctl_script: the same calls jx_lift_gate.py
--loads ctl replays).
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
CC_ENTRY, BEND_ENTRY = 0x34AD50, 0x3F91B0            # the engine's vt+0x88 / vt+0x98 (READ)
EMPTY_ENTRIES = (0x34AF20, 0x34AF10, 0x34AD20)        # vt+0x90 / +0xA0 / +0xA8: `ret 0` (READ)


def ctl_script():
    """the --ctl calls in order: ('cc', n, v) / ('bend', v16) / ('on', key, vel) / ('off', key, vel) /
    ('empty', rva, a) -- what the render driver hands the engine for kind-0 records (rva 0x32113C)"""
    out = []
    for v in (0, 1, 64, 127, 255):
        out.append(('cc', 1, v))
    for n in (11, 10, 7, 74, 0, 127):
        for v in (0, 64, 127):
            out.append(('cc', n, v))
    # the bend entry's argument is already centred (the driver: data1 + ((data2 - 64) << 7) as 16 bits) and the
    # entry clamps it as an int16 to -8192..8191 (0x3F6D00): both ends, below and above them, and across the range
    for v in (0, 8191, -8192, 8192, -8193, 4096, -4096, -1, 1, 3276, -3000, 6000, 1000, 0x7F7F, 0):
        out.append(('bend', v & 0xFFFF))
    out += [('cc', 64, 127), ('off', 60, 0), ('on', 64, 90), ('on', 60, 70), ('off', 64, 0), ('cc', 64, 0),
            ('cc', 64, 1), ('on', 67, 100), ('off', 67, 64), ('cc', 64, 127), ('off', 60, 0), ('cc', 64, 0),
            ('on', 72, 80), ('on', 76, 81), ('cc', 123, 0), ('on', 48, 100), ('cc', 64, 127), ('cc', 123, 0),
            ('off', 48, 0), ('cc', 64, 0), ('on', 52, 5), ('cc', 123, 127), ('off', 52, 0), ('off', 72, 0),
            ('off', 76, 0)]
    for r in EMPTY_ENTRIES:
        out.append(('empty', r, 60))
    return out


def ctl_call(jx, c):
    """one ctl_script call through the plugin's own entry"""
    H, k = jx.HOST, c[0]
    if k == 'cc':
        return jx.call(J.IB + CC_ENTRY, rcx=H, rdx=c[1], r8=c[2], count=400_000_000)
    if k == 'bend':
        return jx.call(J.IB + BEND_ENTRY, rcx=H, rdx=c[1] & 0xFFFF, count=400_000_000)
    if k == 'on':
        return jx.call(J.NOTEON, rcx=H, rdx=c[1], r8=c[2], count=400_000_000)
    if k == 'off':
        return jx.call(J.NOTEOFF, rcx=H, rdx=c[1], r8=c[2], count=400_000_000)
    return jx.call(J.IB + c[1], rcx=H, rdx=c[2], r8=0, count=400_000_000)


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
    ctl = '--ctl' in a
    if ctl:
        for c in ctl_script():
            ctl_call(jx, c)
        patches = []
        print('[%6.1fs] %d controller calls: %d addresses, %d indirect sites' % (
            time.time() - t0, len(ctl_script()), len(executed), len(indirect)), flush=True)
    for p in patches:
        jx.host_records(recs[p])
    if not ctl:
        print('[%6.1fs] %d warm loads: %d addresses, %d indirect sites' % (
            time.time() - t0, len(patches), len(executed), len(indirect)), flush=True)
    if '--no-sweep' not in a and not ctl:
        ids = sorted(jx.id_map())
        for n, pid in enumerate(ids):
            for v in SWEEP:
                jx.call(J.HOSTPARAM, rcx=jx.HOST, rdx=pid, r8=v & 0xFFFFFFFF, count=400_000_000)
            jx.host_records(recs[base])
            if n % 100 == 99:
                print('[%6.1fs] %d of %d ids swept: %d addresses, %d indirect sites' % (
                    time.time() - t0, n + 1, len(ids), len(executed), len(indirect)), flush=True)
    names = {i: str(x) for i, x in enumerate(J.IMPORTS)}
    json.dump(dict(base=base, patches=patches, sweep=list(SWEEP) if ('--no-sweep' not in a and not ctl) else [],
                   ctl=len(ctl_script()) if ctl else 0,
                   executed=sorted('%x' % x for x in executed),
                   indirect={'%x' % s: sorted('%x' % t for t in ts) for s, ts in indirect.items()},
                   imports={str(i): [names.get(i, '?'), c] for i, c in sorted(imports.items())}), open(out, 'w'))
    print('wrote %s: %d addresses, %d indirect sites, imports %s' % (
        out, len(executed), len(indirect), dict(imports) or 'none'))
    return 0


if __name__ == '__main__':
    sys.exit(main())

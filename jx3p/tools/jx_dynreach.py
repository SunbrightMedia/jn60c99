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
                                     [--ctl | --notes | --tick | --tempo | --rate]

--notes / --tick (JX-12b): the note entries under every assign mode, legato, portamento and arpeggiator setting,
and the engine's clock tick under every step mode (notes_script / tick_script). --tempo (JX-8): the engine's
tempo entry under every effect mode of the base patch (tempo_script). --rate (JX-15): the engine's setSampleRate
to every rate of the setting table on the running engine (rate_script).
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


ASSIGN_MODE, LEGATO, PORTAMENTO, ARPEGGIO = 0x00600064, 0x00600062, 0x00600060, 0x00600108   # model ids (Script.xml
                                                       # CTRL: PORTAMENTO 0..255, LEGATO 0..1, ASSIGN MODE 0..2; NAME1)
TICK, SETMODE = 0x3F84A0, 0x3F1910                     # the engine's tick (vt+0xB8); the note store's mode setter
TEMPO = 0x3F9DD0                                       # the engine's tempo entry (vt+0xB0, JX-8)
SETSR = 0x3F9970                                       # the engine's setSampleRate (vt+0x18, JX-15: the rate in xmm1)


def notes_script():
    """--notes (JX-12b): the note entries under every assign mode, legato on and off, portamento off and on, the
    arpeggiator off and on (model ids through the host entry), with overlapping keys, re-strikes, the sustain
    and all notes off among them and clock ticks between -- the note paths no factory patch reaches (no patch
    sets LEGATO; three set PORTAMENTO)"""
    out = []
    for arp in (0, 1):
        for mode in (0, 1, 2):
            for leg in (0, 1):
                for porta in (0, 120):
                    out += [('host', ARPEGGIO, arp), ('host', ASSIGN_MODE, mode), ('host', LEGATO, leg),
                            ('host', PORTAMENTO, porta)]
                    out += [('on', 60, 100), ('tick',), ('on', 64, 90), ('tick',), ('off', 60, 0), ('on', 67, 80),
                            ('tick',), ('on', 64, 70), ('off', 64, 64), ('cc', 64, 127), ('off', 67, 0),
                            ('on', 72, 110), ('tick',), ('off', 72, 0), ('cc', 64, 0), ('on', 48, 60),
                            ('on', 52, 61), ('on', 55, 62), ('on', 59, 63), ('on', 62, 64), ('on', 65, 65),
                            ('on', 69, 66), ('tick',), ('cc', 123, 0), ('on', 50, 100), ('off', 50, 0),
                            ('on', 50, 101), ('tick',), ('off', 50, 0), ('off', 48, 0)]
    return out


def tick_script():
    """--tick (JX-12b): every step mode 0..18 put into every unit's store by the plugin's own setter, keys held,
    clock ticks past the 12- and 24-tick boundaries, keys changing between them"""
    out = [('host', ARPEGGIO, 1)]
    for m in range(19):
        out.append(('setmode', m))
        out += [('on', 60, 100), ('on', 64, 90), ('on', 67, 80)]
        out += [('tick',)] * 30
        out += [('off', 64, 0), ('on', 71, 70)] + [('tick',)] * 30 + [('off', 60, 0), ('off', 67, 0), ('off', 71, 0)]
        out += [('tick',)] * 6
    return out


def tempo_script(base=0):
    """--tempo (JX-8): the engine's tempo entry (vt+0xB0, 0x3F9DD0, READ: T = the host tempo x 10; T in 400..3000
    reaches every unit's parameter object, vt+0x58 with id 375; other T nothing) at T inside, at and beyond its
    ends, under every value of the two effect-mode cells (records 65 and 67: 0..5, each a variant of the base
    patch loaded through the host entry)"""
    sys.path.insert(0, HERE)
    import jx_records
    out = []
    for rec in (65, 67):
        for v in range(6):
            out += [('host', pid, val) for kind, pid, val in jx_records.variant_records('%d:%d=%d' % (base, rec, v))
                    if kind == 2]
            out += [('tempo', t) for t in (1200, 400, 3000, 399, 3001, 1201, 777, 2999, 401, 0, -1200, 1280)]
    return out


def rate_script(base=0):
    """--rate (JX-15): the engine's setSampleRate (vt+0x18, 0x3F9970: the rate a float in xmm1; on the running
    engine it allocates nothing and calls no import -- EXECUTED 2026-10-10) to every rate of the setting table and
    back, the same rate again (its early out), keys held across, notes and ticks between"""
    out = [('on', 60, 100)]
    for r in (48000.0, 44100.0, 88200.0, 32000.0, 96000.0, 96000.0, 44100.0, 48000.0, 96000.0):
        out += [('setsr', r), ('tick',), ('on', 64, 90), ('tick',), ('off', 64, 0)]
    return out + [('off', 60, 0)]


def ctl_call(jx, c):
    """one script call through the plugin's own entry; returns the calls it made, [(rva, rcx, rdx, r8, rax, x1)] --
    one, or nine for a 'setmode' (the setter on every unit's note store); x1: xmm1's low 32 bits when the entry
    takes a float there (setSampleRate), else None"""
    H, k = jx.HOST, c[0]
    if k == 'setmode':
        rq = lambda a: int.from_bytes(jx.uc.mem_read(a, 8), 'little')
        out = []
        for u in range(9):
            ns = rq(rq(H + 0x78 + 0x40 * u) + 0x518)
            out.append((SETMODE, ns, c[1], 0, jx.call(J.IB + SETMODE, rcx=ns, rdx=c[1], count=1_000_000), None))
        return out
    if k == 'setsr':
        import struct
        from unicorn.x86_const import UC_X86_REG_XMM1
        x1 = struct.unpack('<I', struct.pack('<f', c[1]))[0]
        jx.uc.reg_write(UC_X86_REG_XMM1, x1)
        return [(SETSR, H, 0, 0, jx.call(J.IB + SETSR, rcx=H, count=2_000_000_000), x1)]
    if k == 'host':
        fn, rdx, r8 = J.HOSTPARAM - J.IB, c[1], c[2] & 0xFFFFFFFF
    elif k == 'tick':
        fn, rdx, r8 = TICK, 0, 0
    elif k == 'tempo':
        fn, rdx, r8 = TEMPO, c[1] & 0xFFFFFFFF, 0
    elif k == 'cc':
        fn, rdx, r8 = CC_ENTRY, c[1], c[2]
    elif k == 'bend':
        fn, rdx, r8 = BEND_ENTRY, c[1] & 0xFFFF, 0
    elif k in ('on', 'off'):
        fn, rdx, r8 = (J.NOTEON if k == 'on' else J.NOTEOFF) - J.IB, c[1], c[2]
    else:                                                  # ('empty', rva, a)
        fn, rdx, r8 = c[1], c[2], 0
    return [(fn, H, rdx, r8, jx.call(J.IB + fn, rcx=H, rdx=rdx, r8=r8, count=400_000_000), None)]


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
    ctl = any(k in a for k in ('--ctl', '--notes', '--tick', '--tempo', '--rate'))
    if ctl:
        script = (ctl_script() if '--ctl' in a else notes_script() if '--notes' in a else tick_script() if '--tick' in a
                  else tempo_script(base) if '--tempo' in a else rate_script(base))
        for c in script:
            ctl_call(jx, c)
        patches = []
        print('[%6.1fs] %d controller / note / tick calls: %d addresses, %d indirect sites' % (
            time.time() - t0, len(script), len(executed), len(indirect)), flush=True)
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
                   ctl=len(script) if ctl else 0,
                   executed=sorted('%x' % x for x in executed),
                   indirect={'%x' % s: sorted('%x' % t for t in ts) for s, ts in indirect.items()},
                   imports={str(i): [names.get(i, '?'), c] for i, c in sorted(imports.items())}), open(out, 'w'))
    print('wrote %s: %d addresses, %d indirect sites, imports %s' % (
        out, len(executed), len(indirect), dict(imports) or 'none'))
    return 0


if __name__ == '__main__':
    sys.exit(main())

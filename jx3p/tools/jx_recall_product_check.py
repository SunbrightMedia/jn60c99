#!/usr/bin/env python3
"""jx_recall_product_check.py -- is the engine-level recall the JX port's data is made with the plugin's
own patch load? (Unicorn only; both sides are emulators, no ctypes.)

PRODUCT (jx3p/tools/jx_host_emu.py): the plugin booted as a DAW boots it (initialize queues its 84
records), its patch browser's load of factory patch k (75 more records), then one process(): the render
driver applies all of them at offset 0 through the engine's host entry (rva 0x3F9A30) and calls the
engine render (rva 0x3F9220) -- where this check stops it and reads the engine: per unit u = 0..8 its
state (0xAAC310 bytes), its parameter object (0x700), its assigner (0xB8), its note manager (0x7A8) and
its note store (0xFF0), from the HOST's unit table.

MODEL (tools/verify/jx_emu.py, the engine alone): static init (it fills the host entry's id map: 744
ids), BUILD on the factory HOST, then the plugin's own host entry called with the same kind-2 records in
the same order (the product's queue, read in the same
run). The kind-0 record initialize queues (MIDI CC 120, all sound off) is not replayed: the comparison
says whether it matters.

Compared word by word, every unit's three objects; a qword both sides hold as a pointer into their own
emulator's memory is skipped (the two heaps differ), every other word must be equal.

    python3 -u jx3p/tools/jx_recall_product_check.py [patch ...]   (default 0 5 20 49)
    python3 -u jx3p/tools/jx_recall_product_check.py --tooth       one record left out on the model
                                                                    side must be seen (exit 0 = bites)
exit 0 = every unit equal for every patch.
"""
import os
import struct
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import jx_bank as B                                    # noqa: E402

RENDER = 0x3F9220                  # the engine render (vtable 0x38)
TICK = 0x3F84A0                    # the engine's clock tick (vtable 0xB8; the render driver calls it, rva 0x320F52)
SIZES = {'state': 0xAAC310, 'proc': 0x700, 'assign': 0xB8, 'mgr': 0x7A8, 'nstore': 0xFF0}


def snapshot(emu, host):
    """per unit its state, parameter object and assigner (the HOST's unit table +80/+96/+104) and, since
    2026-10-10, its note manager (+120) and the note store the manager holds (+0x518): a KEY ASSIGN
    patch (34) played differently through the product while the first three were equal"""
    q = lambda a: struct.unpack('<Q', emu.uc.mem_read(a, 8))[0]
    out = {}
    for u in range(9):
        for k, off in (('state', 80), ('proc', 96), ('assign', 104), ('mgr', 120)):
            out[(k, u)] = bytes(emu.uc.mem_read(q(host + off + 64 * u), SIZES[k]))
        out[('nstore', u)] = bytes(emu.uc.mem_read(q(q(host + 120 + 64 * u) + 0x518), SIZES['nstore']))
    return out


def is_ptr(v, J):
    return (J.HEAP_BASE <= v < J.HEAP_BASE + J.HEAP_SIZE or J.IB <= v < J.IB + J.IMGSZ or
            J.STACK_BASE <= v < J.STACK_BASE + J.STACK_SIZE or J.STUB_BASE <= v < J.STUB_BASE + 0x100000 or
            J.BUF_BASE <= v < J.BUF_BASE + J.BUF_SIZE)


def compare(a, b, J):
    """[(object, unit, word offset, product word, model word)] past the pointer rule"""
    bad = []
    for key in a:
        x = np.frombuffer(a[key], dtype='<u4')
        y = np.frombuffer(b[key], dtype='<u4')
        for i in np.nonzero(x != y)[0]:
            qo = (int(i) * 4) & ~7
            if qo + 8 <= len(a[key]):
                pa = struct.unpack_from('<Q', a[key], qo)[0]
                pb = struct.unpack_from('<Q', b[key], qo)[0]
                if is_ptr(pa, J) and is_ptr(pb, J):
                    continue
            bad.append((key[0], key[1], int(i) * 4, int(x[i]), int(y[i])))
    return bad


def product(k, bank):
    import jx_host_emu as X
    from unicorn import UC_HOOK_CODE
    h = X.JXHost()
    h.start(96000.0, 512)                                 # host = engine rate: the identity render object
    tail = bank[B.BANK_HEADER + k * B.BANK_STRIDE + B.BANK_BLOB_OFF:B.BANK_HEADER + (k + 1) * B.BANK_STRIDE]
    h.load_patch(tail)
    recs = [(kind, struct.unpack_from('<I', r, 12)[0], struct.unpack_from('<i', r, 20)[0]) for kind, off, r in h.queue()]
    snap = {}

    def at_render(uc, addr, size, ud):
        if not snap:
            snap.update(snapshot(h, h.HOST))
            uc.emu_stop()
    h.uc.hook_add(UC_HOOK_CODE, at_render, begin=X.J.IB + RENDER, end=X.J.IB + RENDER)
    h.uc.ctl_remove_cache(X.J.IB, X.J.IB + X.J.IMGSZ)
    try:
        h.process(1)
    except RuntimeError:
        pass                                              # the stop at the render ends the call
    assert snap, 'the engine render was not reached'
    return recs, snap


def model(recs, skip=None):
    import jx_emu as J
    jx = J.JX()
    jx.run_static_init()
    jx.build()
    jx.set_ftz()
    assert len(jx.id_map()) == 744, 'the id map is not the static initializers\' 744 entries'
    for i, (kind, pid, val) in enumerate(recs):
        if kind != 2 or i == skip:
            continue
        jx.call(J.HOSTPARAM, rcx=jx.HOST, rdx=pid, r8=val & 0xFFFFFFFF, count=400_000_000)
    # the render driver's first clock tick: its phase starts at 0, so sample 0 of the first block ticks before
    # the engine renders (EXECUTED, jx3p/docs/HOST_LAYER.md 3c) -- the engine's own tick entry, vtable +0xB8
    jx.call(J.IB + TICK, rcx=jx.HOST, count=50_000_000)
    return snapshot(jx, jx.HOST), J


def main():
    args = sys.argv[1:]
    tooth = '--tooth' in args
    patches = [int(a) for a in args if a.isdigit()] or ([0] if tooth else [0, 5, 20, 49])
    bank = B.bank_bytes()
    worst = 0
    for k in patches:
        recs, ps = product(k, bank)
        kinds = [r[0] for r in recs]
        skip = None
        if tooth:                                         # leave out the patch's VCF record (d752's)
            skip = next(i for i, r in enumerate(recs) if r[1] == 0x00600004 and i > 80)
        ms, J = model(recs, skip)
        bad = compare(ps, ms, J)
        worst = max(worst, len(bad))
        per = {}
        for o, u, off, x, y in bad:
            per.setdefault((o, u), []).append(off)
        print('patch %2d: %d records (%d kind 2, %d kind 0); %d words differ%s' % (
            k, len(recs), kinds.count(2), kinds.count(0), len(bad),
            '' if not bad else ': ' + ', '.join('%s %d: %d (first +0x%x)' % (o, u, len(v), v[0])
                                                for (o, u), v in sorted(per.items())[:8])), flush=True)
        for o, u, off, x, y in bad[:6]:
            print('    %s %d +0x%x product 0x%08x model 0x%08x' % (o, u, off, x, y))
    if tooth:
        print('jx_recall_product_check --tooth: %s' % ('BITES' if worst else 'DID NOT BITE'))
        return 0 if worst else 1
    print('jx_recall_product_check: %s' % ('GREEN -- the model with the plugin\'s own host entry and records IS the '
                                          'patch load' if not worst else 'RED'))
    return 1 if worst else 0


if __name__ == '__main__':
    sys.exit(main())

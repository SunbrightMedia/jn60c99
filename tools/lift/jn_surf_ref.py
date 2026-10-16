#!/usr/bin/env python3
"""jn_surf_ref.py -- L5 (surfaces) ORACLE side: the host oracle booted to the template cut, set up at 48 kHz, then the
shared plan (jn_surf_seq.plan). Each op makes EXACTLY the plugin calls the matching junoh_* entry makes (lift/jn_host.c)
-- e.g. a Learn by id looks its record up with REC_ID over every record, then calls CC_LEARN -- so the two sides run
the same plugin code in the same order. After every op: sha256 of the end-state memory (image + heap + host arena),
the heap / arena tops, and the output words of a block. Also the imports the oracle answered by its default since the
cut (its .unhandled delta). Unicorn only (two-process rule).
usage: python3 tools/lift/jn_surf_ref.py <outdir> [--no-rates]"""
import sys
import os
import json
import struct
import hashlib
import collections

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
sys.path.insert(0, os.path.join(REPO, 'probes', 'b6'))
sys.path.insert(0, HERE)
os.environ.setdefault('JP8_EMU_QUIET', '1')
import host_process_emu as H                                       # noqa: E402
import jn_surf_seq as S                                            # noqa: E402

IB = H.IB
UITICK, CC_LEARN, CC_FORGET, REC_ID = 0x320120, 0x31AA40, 0x3192E0, 0x319C50
TRIO = (0x285320, 0x2853C0, 0x283120)


def main():
    out = sys.argv[1]
    os.makedirs(out, exist_ok=True)
    h = H.HostProcess()
    h.boot_host(log=lambda s: None)
    unh0 = collections.Counter(getattr(h, 'unhandled', {}))        # the template cut: the lift counts from here
    h.setup(48000.0, 512)
    uc = h.uc
    E = H.E
    COM = H.W.COM
    q = lambda a: struct.unpack('<Q', uc.mem_read(a, 8))[0]

    def nrec():
        return (q(h.core + 32) - q(h.core + 24)) // 24

    def rec_id(i):
        return h.call(IB + REC_ID, rcx=h.core + 24, rdx=i) & 0xFFFFFFFF

    def cc_record(pid):                                            # jn_host.c cc_record: REC_ID over all, the last match
        k = -1
        for j in range(nrec()):
            if rec_id(j) == pid:
                k = j
        return k

    def digest():
        m = hashlib.sha256()
        m.update(bytes(uc.mem_read(E.IB, E.IMGSZ)))
        m.update(bytes(uc.mem_read(E.HEAP_BASE, h.heap - E.HEAP_BASE)))
        m.update(bytes(uc.mem_read(COM, h.com_next - COM)))
        return m.hexdigest()

    rows, words = [], bytearray()
    ops = S.plan(rates='--no-rates' not in sys.argv)
    for k, op in enumerate(ops):
        w = b''
        if op[0] == 'proc':
            L, R = h.process(op[1], events=list(op[2]), params=list(op[3]), ctx=S.oracle_ctx())
            w = struct.pack('<%dI' % len(L), *L) + struct.pack('<%dI' % len(R), *R)
        elif op[0] == 'rate':
            h.set_active(0); h.setup_processing(op[1]); h.set_active(1)
        elif op[0] == 'uitick':
            h.call(IB + UITICK, rcx=h.core, count=2_000_000_000)
        elif op[0] in ('learn', 'forget'):
            pid = rec_id(op[1])                                    # junoh_rec_id(i)
            r = cc_record(pid)                                     # inside junoh_cc_learn / junoh_cc_forget
            if op[0] == 'learn':
                h.call(IB + CC_LEARN, rcx=h.core + 24, rdx=r & 0xFFFFFFFF if r >= 0 else 0xFFFFFFFF)
            elif r >= 0:
                h.call(IB + CC_FORGET, rcx=h.core + 24, rdx=r)
        elif op[0] == 'commit':
            model = q(q(h.core + 8))
            for rva in TRIO:
                h.call(IB + rva, rcx=model, count=500_000_000)
        elif op[0] == 'getset':
            s = h.get_state()
            r = h.set_state(s)
            if r & 0xFFFFFFFF:
                raise RuntimeError('setState -> 0x%x' % r)
        else:
            raise SystemExit('op %r' % (op,))
        rows.append(dict(k=k, op=op[0], digest=digest(), heap_top=h.heap, com_next=h.com_next,
                         woff=len(words), wlen=len(w)))
        words += w
        sys.stderr.write('ref op %2d %-7s %s\n' % (k, op[0], rows[-1]['digest'][:16])); sys.stderr.flush()
    unh = {n: c for n, c in (collections.Counter(getattr(h, 'unhandled', {})) - unh0).items() if c}
    open(os.path.join(out, 'words.bin'), 'wb').write(bytes(words))
    open(os.path.join(out, 'image.bin'), 'wb').write(bytes(uc.mem_read(E.IB, E.IMGSZ)))
    open(os.path.join(out, 'heap.bin'), 'wb').write(bytes(uc.mem_read(E.HEAP_BASE, h.heap - E.HEAP_BASE)))
    open(os.path.join(out, 'com.bin'), 'wb').write(bytes(uc.mem_read(COM, h.com_next - COM)))
    json.dump(dict(rows=rows, unhandled=unh, rates='--no-rates' not in sys.argv, heap_top=h.heap, com_next=h.com_next,
                   IB=E.IB, IMGSZ=E.IMGSZ, HEAP_BASE=E.HEAP_BASE, COM=COM), open(os.path.join(out, 'meta.json'), 'w'))
    print('oracle surfaces ref: %d ops, %d output words, unhandled since the cut %s -> %s'
          % (len(rows), len(words) // 4, unh or '{}', out))


if __name__ == '__main__':
    main()

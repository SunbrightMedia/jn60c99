#!/usr/bin/env python3
"""jn_proc_ref.py -- L5 (process) ORACLE side: the JUNO host oracle (host_process_emu) booted, then the shared process
drive (jn_proc_seq.steps). Writes every output word (L then R, per block) the lifted side must reproduce exactly, plus
the performEdit calls and the render count. Unicorn only (two-process rule). usage: jn_proc_ref.py <outdir>"""
import sys
import os
import json
import struct

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
sys.path.insert(0, os.path.join(REPO, 'probes', 'b6'))
sys.path.insert(0, os.path.join(REPO, 'tools', 'lift'))
os.environ.setdefault('JP8_EMU_QUIET', '1')
import host_process_emu as H                                       # noqa: E402
import jn_proc_seq                                                 # noqa: E402


def main():
    out = sys.argv[1]
    os.makedirs(out, exist_ok=True)
    h = H.HostProcess()
    h.start(48000.0, 512)
    words = bytearray()
    for st in jn_proc_seq.steps():
        L, R = h.process(st['n'], events=list(st['events']), params=list(st['params']), ctx=jn_proc_seq.oracle_ctx(st['ctx']))
        if st['n']:
            words += struct.pack('<%dI' % len(L), *L) + struct.pack('<%dI' % len(R), *R)
    open(os.path.join(out, 'words.bin'), 'wb').write(bytes(words))
    edits = [[e[1], struct.unpack('<Q', struct.pack('<d', e[2]))[0]] for e in h.edits if e[0] == 'performEdit']
    # the END-STATE memory after the drive: the plugin's internal state (image globals, heap, host arena) the render
    # wrote -- a stronger proof than the output words alone (it catches an internal divergence that has not yet reached
    # the output). BUF (render scratch) and the stack are not compared.
    E = H.E
    IB = E.IB
    COM = H.W.COM
    open(os.path.join(out, 'image.bin'), 'wb').write(bytes(h.uc.mem_read(IB, E.IMGSZ)))
    open(os.path.join(out, 'heap.bin'), 'wb').write(bytes(h.uc.mem_read(E.HEAP_BASE, h.heap - E.HEAP_BASE)))
    open(os.path.join(out, 'com.bin'), 'wb').write(bytes(h.uc.mem_read(COM, h.com_next - COM)))
    json.dump(dict(nsteps=len(jn_proc_seq.steps()), nwords=len(words) // 4, edits=edits,
                   heap_top=h.heap, com_next=h.com_next, IB=IB, IMGSZ=E.IMGSZ, HEAP_BASE=E.HEAP_BASE, COM=COM),
              open(os.path.join(out, 'meta.json'), 'w'))
    print('oracle process ref: %d output words, %d performEdits, end heap_top 0x%x com_next 0x%x -> %s'
          % (len(words) // 4, len(edits), h.heap, h.com_next, out))


if __name__ == '__main__':
    main()

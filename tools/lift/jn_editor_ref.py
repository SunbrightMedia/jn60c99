#!/usr/bin/env python3
"""jn_editor_ref.py -- L5 (editor) ORACLE side: the editor's SET through the plugin's own model (rva 0x283DB0, flag 1 a
final set). For every parameter record the panel owns, the oracle sets a few values; the plugin's controller answers
each with host calls (beginEdit / performEdit / endEdit) and/or queues an engine record for the next block. Then one
warm block renders. Writes the performEdit sequence (id, value bits), the output words, and the end-state memory the
lifted side (jn_editor_c.py) must reproduce EXACTLY. Unicorn only (two-process rule). A warm block is rendered first
so the final audio is past the 960-sample start mute.
usage: python3 tools/lift/jn_editor_ref.py <outdir>"""
import sys
import os
import json
import struct

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
sys.path.insert(0, os.path.join(REPO, 'probes', 'b6'))
os.environ.setdefault('JP8_EMU_QUIET', '1')
import host_process_emu as H                                       # noqa: E402

MODEL_SET, REC_ID = 0x283DB0, 0x319C50
VALS = (0, 64, 127)                       # a low, a mid and a high value per record (final set, flag 1)
T = dict(state=0x402, ppq=0.0, cs=0.0, ce=0.0, tempo=120.0)


def main():
    out = sys.argv[1]
    os.makedirs(out, exist_ok=True)
    h = H.HostProcess()
    h.start(48000.0, 512)
    uc = h.uc
    q = lambda a: struct.unpack('<Q', uc.mem_read(a, 8))[0]
    # the records the panel owns (index -> id, object), the plugin's own list (core+24 vector of 24-byte records)
    vb, ve = q(h.core + 24), q(h.core + 32)
    nrec = (ve - vb) // 24
    recs = [(h.call(H.IB + REC_ID, rcx=h.core + 24, rdx=i) & 0xFFFFFFFF, q(vb + 24 * i)) for i in range(nrec)]
    model = q(q(h.core + 8))
    # warm past the 960-sample start mute so the final block sounds (two 512 blocks; max block is 512)
    for _ in range(2):
        h.process(512, ctx=dict(state=0x402, ppq=0.0, cycle=(0.0, 0.0), tempo=120.0))
    e0 = len(h.edits)
    for i in range(nrec):
        obj = recs[i][1]
        for v in VALS:
            h.call(H.IB + MODEL_SET, rcx=model, rdx=obj, r8=v & 0xFFFFFFFF, r9=1, count=500_000_000)
    edits = [[e[1], struct.unpack('<Q', struct.pack('<d', e[2]))[0]] for e in h.edits[e0:] if e[0] == 'performEdit']
    L, R = h.process(256, ctx=dict(state=0x402, ppq=0.0, cycle=(0.0, 0.0), tempo=120.0))
    words = struct.pack('<%dI' % len(L), *L) + struct.pack('<%dI' % len(R), *R)
    open(os.path.join(out, 'edits.json'), 'w').write(json.dumps(edits))
    open(os.path.join(out, 'words.bin'), 'wb').write(words)
    E = H.E
    IB = E.IB
    COM = H.W.COM
    open(os.path.join(out, 'image.bin'), 'wb').write(bytes(uc.mem_read(IB, E.IMGSZ)))
    open(os.path.join(out, 'heap.bin'), 'wb').write(bytes(uc.mem_read(E.HEAP_BASE, h.heap - E.HEAP_BASE)))
    open(os.path.join(out, 'com.bin'), 'wb').write(bytes(uc.mem_read(COM, h.com_next - COM)))
    json.dump(dict(nrec=nrec, nedit=len(edits), nwords=len(words) // 4, vals=list(VALS),
                   heap_top=h.heap, com_next=h.com_next, IB=IB, IMGSZ=E.IMGSZ, HEAP_BASE=E.HEAP_BASE, COM=COM),
              open(os.path.join(out, 'meta.json'), 'w'))
    print('oracle editor ref: %d records x %d values -> %d performEdits, %d words -> %s'
          % (nrec, len(VALS), len(edits), len(words) // 4, out))


if __name__ == '__main__':
    main()

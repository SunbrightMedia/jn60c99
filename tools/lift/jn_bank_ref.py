#!/usr/bin/env python3
"""jn_bank_ref.py -- L5 (bank) ORACLE side: the JUNO host oracle (host_process_emu) booted, then for EVERY factory
patch the plugin's own patch browser load (rva 0x335850) and the shared per-patch play (jn_bank_seq.patch_steps).
Writes every output word the lifted side must reproduce, the patch records the C side loads (patches.bin), and the
end-state memory (image + heap + host arena) after the whole run. Unicorn only (the two-process rule).
usage: python3 tools/lift/jn_bank_ref.py <outdir>"""
import sys
import os
import json
import struct

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
sys.path.insert(0, os.path.join(REPO, 'probes', 'b6'))
sys.path.insert(0, HERE)
os.environ.setdefault('JP8_EMU_QUIET', '1')
import host_process_emu as H                                       # noqa: E402
import truth                                                       # noqa: E402
import jn_bank_seq as S                                            # noqa: E402


def main():
    out = sys.argv[1]
    os.makedirs(out, exist_ok=True)
    bank = open(truth.BANK, 'rb').read()
    h = H.HostProcess()
    h.start(48000.0, 512)
    words = bytearray()
    patches = bytearray(struct.pack('<I', S.NPATCH))               # patches.bin: count, then (len, bytes) per patch
    for idx in range(S.NPATCH):
        rec = S.rec_tail(bank, idx)
        patches += struct.pack('<I', len(rec)) + rec
        h.load_patch(rec)
        for st in S.patch_steps():
            L, R = h.process(st['n'], events=list(st['events']), ctx=S.oracle_ctx(st['ctx']))
            if st['n']:
                words += struct.pack('<%dI' % len(L), *L) + struct.pack('<%dI' % len(R), *R)
    open(os.path.join(out, 'words.bin'), 'wb').write(bytes(words))
    open(os.path.join(out, 'patches.bin'), 'wb').write(bytes(patches))
    # the END-STATE memory after the whole bank: the plugin's internal state (image globals, heap, host arena). BUF
    # (render scratch) and the stack are not compared (jn_proc_ref.py).
    E = H.E
    IB = E.IB
    COM = H.W.COM
    open(os.path.join(out, 'image.bin'), 'wb').write(bytes(h.uc.mem_read(IB, E.IMGSZ)))
    open(os.path.join(out, 'heap.bin'), 'wb').write(bytes(h.uc.mem_read(E.HEAP_BASE, h.heap - E.HEAP_BASE)))
    open(os.path.join(out, 'com.bin'), 'wb').write(bytes(h.uc.mem_read(COM, h.com_next - COM)))
    json.dump(dict(npatch=S.NPATCH, nwords=len(words) // 4, heap_top=h.heap, com_next=h.com_next,
                   IB=IB, IMGSZ=E.IMGSZ, HEAP_BASE=E.HEAP_BASE, COM=COM),
              open(os.path.join(out, 'meta.json'), 'w'))
    print('oracle bank ref: %d patches, %d output words, end heap_top 0x%x com_next 0x%x -> %s'
          % (S.NPATCH, len(words) // 4, h.heap, h.com_next, out))


if __name__ == '__main__':
    main()

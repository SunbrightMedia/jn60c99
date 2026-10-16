#!/usr/bin/env python3
"""jn_state_ref.py -- L5 (state) ORACLE side: the JUNO host oracle booted, then the DAW state round trip through the
plugin's OWN getState / setState (IComponent slots 13 / 12). The drive, so setState is LOAD-BEARING (not a no-op from
an already-matching state):
  1. load patch P -> getState -> S_P            (the state bytes the lifted side must reproduce exactly)
  2. load a DIFFERENT patch Q                    (the engine is now Q, not P)
  3. setState(S_P)                               (must put the engine back to P)
  4. getState -> S2                              (must equal S_P again -- the round trip is idempotent)
  5. play the shared drive -> output words       (must reflect P, i.e. the oracle and the lifted host agree)
Writes S_P, S2, the result codes, every output word, and the end-state memory. Unicorn only (two-process rule).
usage: python3 tools/lift/jn_state_ref.py <outdir>"""
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

P_IDX, Q_IDX = 10, 25        # two distinct factory patches (P restored over Q: setState must do real work)


def main():
    out = sys.argv[1]
    os.makedirs(out, exist_ok=True)
    bank = open(truth.BANK, 'rb').read()
    rec_p, rec_q = S.rec_tail(bank, P_IDX), S.rec_tail(bank, Q_IDX)
    open(os.path.join(out, 'patch_p.bin'), 'wb').write(rec_p)      # the C side loads the same two patch records
    open(os.path.join(out, 'patch_q.bin'), 'wb').write(rec_q)
    h = H.HostProcess()
    h.start(48000.0, 512)
    h.load_patch(rec_p)
    s_p = h.get_state()                                            # (1) the state of patch P
    h.load_patch(rec_q)                                           # (2) move the engine to Q
    r_set = h.set_state(s_p)                                       # (3) restore P
    s_2 = h.get_state()                                            # (4) must equal s_p
    words = bytearray()                                            # (5) play, reflecting P
    for st in S.patch_steps():
        L, R = h.process(st['n'], events=list(st['events']), ctx=S.oracle_ctx(st['ctx']))
        if st['n']:
            words += struct.pack('<%dI' % len(L), *L) + struct.pack('<%dI' % len(R), *R)
    open(os.path.join(out, 'state_p.bin'), 'wb').write(s_p)
    open(os.path.join(out, 'state_2.bin'), 'wb').write(s_2)
    open(os.path.join(out, 'words.bin'), 'wb').write(bytes(words))
    E = H.E
    IB = E.IB
    COM = H.W.COM
    open(os.path.join(out, 'image.bin'), 'wb').write(bytes(h.uc.mem_read(IB, E.IMGSZ)))
    open(os.path.join(out, 'heap.bin'), 'wb').write(bytes(h.uc.mem_read(E.HEAP_BASE, h.heap - E.HEAP_BASE)))
    open(os.path.join(out, 'com.bin'), 'wb').write(bytes(h.uc.mem_read(COM, h.com_next - COM)))
    json.dump(dict(p=P_IDX, q=Q_IDX, r_set=int(r_set) & 0xFFFFFFFF, len_p=len(s_p), nwords=len(words) // 4,
                   idempotent=(s_p == s_2), heap_top=h.heap, com_next=h.com_next,
                   IB=IB, IMGSZ=E.IMGSZ, HEAP_BASE=E.HEAP_BASE, COM=COM),
              open(os.path.join(out, 'meta.json'), 'w'))
    print('oracle state ref: patch %d->%d, getState %d bytes, setState->0x%x, idempotent %s, %d words -> %s'
          % (P_IDX, Q_IDX, len(s_p), int(r_set) & 0xFFFFFFFF, s_p == s_2, len(words) // 4, out))


if __name__ == '__main__':
    main()

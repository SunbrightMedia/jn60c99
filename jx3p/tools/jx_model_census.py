#!/usr/bin/env python3
"""jx_model_census.py -- oracle-only census (JX-18): what the JX-3P plugin's EDITOR does with a panel control's value
-- the model's set (rva 0x283C90 = the JUNO-60's 0x283DB0, jx3p/tools/fw_map.py --pair), as the JUNO port's
juno_gui_model_set models it -- on the JX.

The plugin booted as a host boots it (jx_host_emu.JXHost), its first block run; then for every record of the core's
CC map (the 83 parameters of the plugin's id map; record i's id by rva 0x319B30, its model object the record's
first word) the model's set at 14 values (0, 1, 2, 5, 127, 128, 255, 256, 300, 65535, 65536, -1, 2^31 - 1, -2^31),
each recorded: the IComponentHandler calls the plugin makes (beginEdit / performEdit(id, value) / endEdit: the
host's automation round trip), the engine queue records it adds (kind 2: id, value), and getState after it.
Writes scratchpad/jx_model/model_census.pkl.    python3 jx3p/tools/jx_model_census.py   (Unicorn only)
"""
import os
import pickle
import struct
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import jx_host_emu as X                               # noqa: E402

OUT = os.path.join(REPO, 'scratchpad', 'jx_model', 'model_census.pkl')
MODEL_SET, REC_ID = 0x283C90, 0x319B30
VALS = (0, 1, 2, 5, 127, 128, 255, 256, 300, 65535, 65536, -1, 0x7FFFFFFF, -0x80000000)


def main():
    t0 = time.time()
    h = X.JXHost()
    h.start(48000.0, 512)
    h.process(256)
    uc = h.uc
    q = lambda a: struct.unpack('<Q', uc.mem_read(a, 8))[0]
    vb, ve = q(h.core + 24), q(h.core + 32)
    recs = [(h.call(X.IB + REC_ID, rcx=h.core + 24, rdx=i) & 0xFFFFFFFF, q(vb + 24 * i)) for i in range((ve - vb) // 24)]
    model = q(q(h.core + 8))
    sets = []
    for pid, obj in recs:
        for v in VALS:
            e0, n0 = len(h.edits), len(h.queue())
            h.call(X.IB + MODEL_SET, rcx=model, rdx=obj, r8=v & 0xFFFFFFFF, r9=1, count=500_000_000)
            new = [(kind, off, struct.unpack_from('<I', r, 12)[0], struct.unpack_from('<i', r, 20)[0])
                   for kind, off, r in h.queue()[n0:]]
            sets.append(dict(id=pid, v=v, edits=list(h.edits[e0:]), queue=new, save=h.get_state()))
        h.process(256)                                   # the queued records applied: the queue empties
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    pickle.dump(dict(ids=[pid for pid, _ in recs], sets=sets), open(OUT + '.partial', 'wb'))
    os.replace(OUT + '.partial', OUT)
    print('%d records x %d values: %d sets (%d queued records, %d host edits); wrote %s (%.0fs)' % (
        len(recs), len(VALS), len(sets), sum(len(s['queue']) for s in sets), sum(len(s['edits']) for s in sets), OUT,
        time.time() - t0))


if __name__ == '__main__':
    main()

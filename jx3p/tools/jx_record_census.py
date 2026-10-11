#!/usr/bin/env python3
"""jx_record_census.py -- oracle-only census (JX-24): the JX-3P model's RECORD IMAGE -- what the plugin's serializer
(rva 0x335870 = the JUNO-60's 0x335990, fw_map --pair) writes, the bytes the patch window stores when it writes a
patch (docs/PATCH_MANAGER.md: "the view's image").

The plugin booted as a host boots it (jx_host_emu.JXHost); recorded:
  boot      the image after initialize, and after the first block (must be equal: the block changes no model value)
  sets      for every entry of the DAW state (the 82 of jx3p/src/jx_state_tables.h), the model's set (rva 0x283C90)
            at 9 values, each followed by the image: the bytes it changed (offset, old, new)
  loads     the patch browser's load (rva 0x335730) of factory patches and of random bodies, then the image (a
            load keeps the record's bytes as given -- every byte)
  states    setState payloads (single entries, values past the ranges), then the image
No block runs after the boot: the image is the model's, and the engine need not take the extreme values (a block
after the sets crashed the emulated engine). Writes scratchpad/jx_record/record_census.pkl.        python3 jx3p/tools/jx_record_census.py   (Unicorn only)
"""
import os
import pickle
import random
import struct
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import jx_host_emu as X                               # noqa: E402
import jx_bank as B                                   # noqa: E402

OUT = os.path.join(REPO, 'scratchpad', 'jx_record', 'record_census.pkl')
SERIALIZE, MODEL_SET, REC_ID = 0x335870, 0x283C90, 0x319B30
VALS = (0, 1, 5, 127, 255, 256, 65535, -1, 300)


def state_ids():
    """the DAW state's ids, in list order, from the committed table (plain text: the list the gate grades)"""
    import re
    src = open(os.path.join(REPO, 'jx3p', 'src', 'jx_state_tables.h')).read()
    body = src[src.index('JX_STATE_ENT['):]
    body = body[:body.index('};')]
    return [int(m, 16) for m in re.findall(r'\{\s*0x([0-9A-Fa-f]+)u,', body)]


def main():
    t0 = time.time()
    h = X.JXHost()
    h.start(48000.0, 512)
    uc = h.uc
    q = lambda a: struct.unpack('<Q', uc.mem_read(a, 8))[0]
    model_pp = q(h.comp + 280 + 8)
    vec = h.alloc_com(24)

    def image():
        uc.mem_write(vec, bytes(24))
        h.call(X.IB + SERIALIZE, rcx=model_pp, rdx=vec, r8=0, r9=0, count=4_000_000_000)
        b, e = q(vec), q(vec + 8)
        return bytes(uc.mem_read(b, e - b))
    res = {'boot': image()}
    h.process(256)
    res['boot_after_block'] = image()
    # the model objects of the CC map's records (the editor's set takes the record's model object)
    vb, ve = q(h.core + 24), q(h.core + 32)
    obj = {h.call(X.IB + REC_ID, rcx=h.core + 24, rdx=i) & 0xFFFFFFFF: q(vb + 24 * i) for i in range((ve - vb) // 24)}
    model = q(q(h.core + 8))
    ids = state_ids()
    res['ids'] = ids
    sets = []
    prev = image()
    for pid in ids:
        if pid not in obj:
            sets.append((pid, None, None))
            continue
        for v in VALS:
            h.call(X.IB + MODEL_SET, rcx=model, rdx=obj[pid], r8=v & 0xFFFFFFFF, r9=1, count=500_000_000)
            cur = image()
            sets.append((pid, v, [(i, prev[i], cur[i]) for i in range(len(cur)) if cur[i] != prev[i]]))
            prev = cur
    res['sets'] = sets
    res['after_sets'] = prev
    bank = open(os.path.join(REPO, 'jx3p', 'truth', 'preset_bank_1.bin'), 'rb').read()
    loads = []
    r = random.Random(0x5EC0)
    for k in (0, 5, 34, 61, -1, -2, -3):
        if k >= 0:
            body = bank[B.BANK_HEADER + k * B.BANK_STRIDE + B.BANK_BLOB_OFF:B.BANK_HEADER + (k + 1) * B.BANK_STRIDE]
        else:
            body = bytes(r.getrandbits(8) for _ in range(B.BANK_STRIDE - B.BANK_BLOB_OFF))
        h.load_patch(body)
        loads.append((k, body, image()))
    res['loads'] = loads
    states = []
    for pid, v in ((0x0060003A, 300), (0x00600004, -1), (0x00000002, -4000), (0x00600080, 0x7FFF), (0x00A02800, 999)):
        payload = struct.pack('>I', 8) + struct.pack('>Ii', pid, v)
        h.set_state(payload)
        states.append((pid, v, image()))
    res['states'] = states
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    pickle.dump(res, open(OUT + '.partial', 'wb'))
    os.replace(OUT + '.partial', OUT)
    print('record census: boot image %d bytes (%d nonzero), %d sets (%d changed bytes), %d loads, %d states; '
          'wrote %s (%.0fs)' % (len(res['boot']), sum(1 for x in res['boot'] if x), len(sets),
                                sum(len(s[2] or []) for s in sets), len(loads), len(states), OUT, time.time() - t0))


if __name__ == '__main__':
    main()

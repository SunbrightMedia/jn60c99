#!/usr/bin/env python3
"""jx_patch_census.py -- oracle-only census (JX-16): what the JX-3P plugin's own patch load (its patch browser's
"load", rva 0x335730 = the JUNO-60's 0x335850: jx3p/tools/fw_map.py) queues for the engine, per record -- the
JUNO's census (probes/b6/patch_load_census.py --craft) on the JX, whose bank records have the JUNO's geometry
(a 23-byte header, records of 20223 bytes: a 16-byte name, then the bytes the load reads).

The plugin booted as a host boots it (jx_host_emu.JXHost), its first block run (initialize's queue applied); then
per record its load and the queue records the load adds -- kind 2 a parameter record (id, value), kind 0 a MIDI
record (its three bytes) --: the 64 factory records, then CRAFTED records: each byte after the name OR-ed with
0x10, 0x30, 0x70, 0xF0, 0x80 (the bits a nibble field does not carry), and bytes that change with their position
(no two offsets alike), and three of seeded random bytes -- what makes each record's decode (its offset, its
width) unique (jx_gen_patch_tables.py).
Writes scratchpad/jx_patch/patch_census.pkl.     python3 jx3p/tools/jx_patch_census.py   (Unicorn only)
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

OUT = os.path.join(REPO, 'scratchpad', 'jx_patch', 'patch_census.pkl')


def crafted(bank):
    """the crafted records (whole records, name included), in the census order"""
    base = bytearray(bank[B.BANK_HEADER:B.BANK_HEADER + B.BANK_STRIDE])
    out = []
    for pat in (0x10, 0x30, 0x70, 0xF0, 0x80):
        r = bytearray(base)
        for i in range(B.BANK_BLOB_OFF, B.BANK_STRIDE):
            r[i] |= pat
        out.append(('0x%02x' % pat, bytes(r)))
    for mul, add in ((29, 7), (53, 101), (197, 3)):
        r = bytearray(base)
        for i in range(B.BANK_BLOB_OFF, B.BANK_STRIDE):
            r[i] = (i * mul + add + (i >> 8) * 17) & 0xFF
        out.append(('i*%d+%d' % (mul, add), bytes(r)))
    # those three repeat at offsets 8288 apart (96 x mul + 544 = 0 mod 256 for all three multipliers: the JX's LEGATO
    # fitted at 126 and at 8414): seeded random bytes, where no two offsets agree
    for seed in (1, 2, 3):
        g = random.Random(0x5EED0000 + seed)
        out.append(('random %d' % seed, bytes(base[:B.BANK_BLOB_OFF]) +
                    bytes(g.randrange(256) for _ in range(B.BANK_BLOB_OFF, B.BANK_STRIDE))))
    return out


def rec(q):
    kind, off, raw = q
    if kind == 0:
        return (0, off, raw[8], raw[9], raw[10])
    return (kind, off, struct.unpack_from('<I', raw, 12)[0], struct.unpack_from('<i', raw, 20)[0])


def main():
    t0 = time.time()
    bank = B.bank_bytes()
    h = X.JXHost()
    h.start(48000.0, 512)
    h.process(256)
    records = [('factory %d' % p, bank[B.BANK_HEADER + p * B.BANK_STRIDE:B.BANK_HEADER + (p + 1) * B.BANK_STRIDE])
               for p in range(64)] + crafted(bank)
    loads = []
    for name, r in records:
        n0 = len(h.queue())
        h.load_patch(r[B.BANK_BLOB_OFF:])
        loads.append(dict(name=name, record=r, queue=[rec(x) for x in h.queue()[n0:]]))
        h.process(256)                                   # the queue applied and emptied, as between two loads
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    pickle.dump(dict(loads=loads), open(OUT + '.partial', 'wb'))
    os.replace(OUT + '.partial', OUT)
    print('%d loads, %s records each; wrote %s (%.0fs)' % (
        len(loads), sorted(set(len(L['queue']) for L in loads)), OUT, time.time() - t0))


if __name__ == '__main__':
    main()

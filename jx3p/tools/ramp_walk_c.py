#!/usr/bin/env python3
"""ramp_walk_c.py -- PORT side of the RAMP WALKER A/B (process B).

Loads the C walker via ctypes (never in the same process as a Unicorn build --
the two-process rule) and replays every pickled case. Any differing byte in the
record pool, the index list, the live count, or the written target floats is a
failure, reported with the case index so it can be reproduced.

usage: ramp_walk_c.py <cases.pkl> <libjxramp.so>
"""
import sys, pickle, ctypes, struct

REC = 40


def main():
    cases = pickle.load(open(sys.argv[1], "rb"))
    lib = ctypes.CDLL(sys.argv[2])
    lib.jx_walk_case.restype = ctypes.c_int
    lib.jx_walk_case.argtypes = [ctypes.c_int, ctypes.c_char_p,
                                 ctypes.c_char_p, ctypes.c_char_p]

    bad = 0
    for ci, (before, after) in enumerate(cases):
        n = before['n']
        pool = ctypes.create_string_buffer(before['pool'], n * REC)
        idx = ctypes.create_string_buffer(
            b"".join(struct.pack('<i', i) for i in before['idx']), 4 * n)
        tgt = ctypes.create_string_buffer(
            b"".join(struct.pack('<I', v) for v in before['tgt']), 4 * n)

        live = lib.jx_walk_case(n, pool, idx, tgt)

        got_pool = bytes(pool.raw[:n * REC])
        got_idx = list(struct.unpack('<%di' % n, idx.raw[:4 * n]))
        got_tgt = list(struct.unpack('<%dI' % n, tgt.raw[:4 * n]))

        why = []
        if live != after['live']:
            why.append("live %d != %d" % (live, after['live']))
        if got_tgt != after['tgt']:
            why.append("target floats differ")
        # only the LIVE prefix of the index list is defined; the plugin leaves
        # stale bytes past `end` and so does the port, but they are not state.
        if got_idx[:live] != after['idx'][:after['live']]:
            why.append("live index order differs")
        # Mask +0x00..+0x07 of every record: that field is the TARGET POINTER,
        # which is an emulator address on the oracle side and a host address
        # here. Comparing it would fail on every case for a reason that is not
        # a defect. Every other byte of the record IS compared.
        def mask(b):
            m = bytearray(b)
            for i in range(n):
                m[i * REC:i * REC + 8] = b"\0" * 8
            return bytes(m)
        if mask(got_pool) != mask(after['pool']):
            for i in range(n):
                a = mask(got_pool)[i * REC:(i + 1) * REC]
                o = mask(after['pool'])[i * REC:(i + 1) * REC]
                if a != o:
                    why.append("record %d differs: port=%s oracle=%s"
                               % (i, a.hex(), o.hex()))
                    break
        if why:
            bad += 1
            if bad <= 5:
                print("  case %d: %s" % (ci, "; ".join(why)))

    print("WALKER A/B: %d/%d cases EXACTLY 0" % (len(cases) - bad, len(cases)))
    if bad:
        raise SystemExit(1)


if __name__ == "__main__":
    main()

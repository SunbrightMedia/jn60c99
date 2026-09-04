#!/usr/bin/env python3
"""jx_nstore_c.py -- C side of the note-store A/B (process B).
usage: jx_nstore_c.py <refdir> <libjxnstore.so>   exit 0 = EXACTLY 0."""
import sys, os, ctypes
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import jx_nstore_seq

SZ = 0xDB0


def main():
    refdir, so = sys.argv[1], sys.argv[2]
    lib = ctypes.CDLL(so)
    events = []
    CB = ctypes.CFUNCTYPE(None, ctypes.c_void_p, ctypes.c_int, ctypes.c_int,
                          ctypes.c_int)
    keep = CB(lambda u, k, a, b2: events.append(("drain", 0, 0, 0)))

    class Cbs(ctypes.Structure):
        _fields_ = [("cb", CB), ("user", ctypes.c_void_p)]
    cbs = Cbs(keep, None)

    blob = ctypes.create_string_buffer(
        open(os.path.join(refdir, "init.bin"), "rb").read(), SZ)

    for ev in jx_nstore_seq.make():
        if ev[0] == "poke2c":
            import struct as _s
            ctypes.memmove(ctypes.byref(blob, 0x2C), _s.pack("<i", ev[1]), 4)
            events.append(("poke2c", ev[1], 0, 0))
        elif ev[0] == "on":
            r = lib.jx_nstore_on5100(blob, ctypes.byref(cbs), ev[1], ev[2])
            events.append(("ron", ev[1], ev[2], r & 0xFF))
        else:
            r = lib.jx_nstore_off(blob, ctypes.byref(cbs), ev[1], ev[2])
            events.append(("roff", ev[1], ev[2], r & 0xFF))

    ref = [l.split("\t") for l in open(os.path.join(refdir, "events.tsv"))]
    ref = [(k, int(a), int(b2), int(c)) for k, a, b2, c in ref]
    bad = 0
    if len(ref) != len(events):
        print("EVENT COUNT differs: %d vs %d" % (len(ref), len(events)))
        bad += 1
    for i, (r, c) in enumerate(zip(ref, events)):
        if r != c:
            print("event %d differs: oracle %r vs C %r" % (i, r, c))
            bad += 1
            if bad > 10: break

    fin = open(os.path.join(refdir, "final.bin"), "rb").read()
    got = blob.raw[:SZ]
    for o in range(SZ):
        if fin[o] != got[o]:
            print("byte 0x%03X differs: oracle %02x vs C %02x"
                  % (o, fin[o], got[o]))
            bad += 1
            if bad > 40: break
    if bad:
        print("NSTORE A/B: %d+ differences -- NOT bit-exact" % bad)
        sys.exit(1)
    print("NSTORE A/B: EXACTLY 0 -- %d events, 0x%X state bytes"
          % (len(events), SZ))


if __name__ == "__main__":
    main()

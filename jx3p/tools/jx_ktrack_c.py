#!/usr/bin/env python3
"""jx_ktrack_c.py -- C side of the key-tracker A/B (process B).

Replays the shared sequence through libjxktrack.so, feeding get50 answers
from the oracle's tape (events.tsv) and recording set48 posts; compares the
event stream and the final blob. exit 0 = EXACTLY 0.
usage: jx_ktrack_c.py <refdir> <libjxktrack.so>
"""
import sys, os, ctypes
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import jx_ktrack_seq

KT_SZ = 0xB0


def main():
    refdir, so = sys.argv[1], sys.argv[2]
    lib = ctypes.CDLL(so)

    ref = [l.split("\t") for l in open(os.path.join(refdir, "events.tsv"))]
    ref = [(k, int(a), int(b2), int(c)) for k, a, b2, c in ref]
    tape = [e for e in ref if e[0] == "get50"]
    ti = [0]
    events = []

    SET = ctypes.CFUNCTYPE(None, ctypes.c_void_p, ctypes.c_int, ctypes.c_int,
                           ctypes.c_int)
    GET = ctypes.CFUNCTYPE(ctypes.c_int, ctypes.c_void_p, ctypes.c_int,
                           ctypes.c_int, ctypes.POINTER(ctypes.c_int32))
    G70 = ctypes.CFUNCTYPE(ctypes.c_uint32, ctypes.c_void_p)
    tape70 = [e for e in ref if e[0] == "get70"]
    t7 = [0]

    def set48(user, what, pid, val):
        events.append(("set48", pid & 0xFFFFFFFF, val & 0xFFFFFFFF, 0))
    def get50(user, what, pid, out):
        if ti[0] >= len(tape):
            events.append(("get50", -1, pid, -1)); return 0
        _, val, tpid, al = tape[ti[0]]; ti[0] += 1
        events.append(("get50", val, pid & 0xFFFFFFFF, al))
        if al: out[0] = val
        return al
    def get70(user):
        if t7[0] >= len(tape70):
            events.append(("get70", -1, 0, -1)); return 0
        _, val, _z, _z2 = tape70[t7[0]]; t7[0] += 1
        events.append(("get70", val, 0, 0))
        return val & 0xFFFFFFFF
    keep = [SET(set48), GET(get50), G70(get70)]

    class Cbs(ctypes.Structure):
        _fields_ = [("set48", SET), ("get50", GET), ("get70", G70),
                    ("user", ctypes.c_void_p)]
    cbs = Cbs(keep[0], keep[1], keep[2], None)

    blob = ctypes.create_string_buffer(
        open(os.path.join(refdir, "init.bin"), "rb").read(), KT_SZ)

    for ev in jx_ktrack_seq.make():
        if ev[0] == "on":
            lib.jx_ktrack_on(blob, ctypes.byref(cbs), ev[1], ev[2])
        elif ev[0] == "off":
            lib.jx_ktrack_off_full(blob, ctypes.byref(cbs), ev[1])
        elif ev[0] == "mode":
            import struct as _s
            ctypes.memmove(ctypes.byref(blob, 0x10), _s.pack("<i", ev[1]), 4)
            events.append(("mode", ev[1], 0, 0))

    bad = 0
    if len(ref) != len(events):
        print("EVENT COUNT differs: oracle %d vs C %d" %
              (len(ref), len(events))); bad += 1
    for i, (r, c) in enumerate(zip(ref, events)):
        if r != c:
            print("event %d differs: oracle %r vs C %r" % (i, r, c))
            bad += 1
            if bad > 10: break

    fin = open(os.path.join(refdir, "final.bin"), "rb").read()
    got = blob.raw[:KT_SZ]
    for o in range(KT_SZ):
        if o < 8:      # the vtable pointer only: excluded
            continue
        if fin[o] != got[o]:
            print("byte 0x%02X differs: oracle %02x vs C %02x" %
                  (o, fin[o], got[o]))
            bad += 1
            if bad > 40: break

    if bad:
        print("KTRACK A/B: %d+ differences -- NOT bit-exact" % bad)
        sys.exit(1)
    print("KTRACK A/B: EXACTLY 0 -- %d events and 0x%X state bytes match"
          % (len(events), KT_SZ))


if __name__ == "__main__":
    main()

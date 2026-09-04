#!/usr/bin/env python3
"""jx_alloc_c.py -- C side of the note-manager A/B (process B).

Loads libjxalloc.so, seeds the 9 unit blobs from the oracle's init_%d.bin,
replays the SAME shared sequence through the C twin with recording
callbacks, then compares events.tsv and the final blobs against the
oracle's -- EXCLUDING the two pointer fields at +0x518/+0x520 (they are
live oracle addresses; PORT_LESSONS #4).

exit 0 = EXACTLY 0 differences.
usage: jx_alloc_c.py <refdir> <libjxalloc.so>
"""
import sys, os, ctypes
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import jx_alloc_seq

UNIT_SZ = 0x7A8
PTR_LO, PTR_HI = 0x518, 0x528       # excluded pointer window


def main():
    refdir, so = sys.argv[1], sys.argv[2]
    lib = ctypes.CDLL(so)
    assert lib.jx_alloc_unit_size() == UNIT_SZ, "UNIT_SZ drift"

    state = ctypes.create_string_buffer(UNIT_SZ * 9)
    for i in range(9):
        blob = open(os.path.join(refdir, "init_%d.bin" % i), "rb").read()
        assert len(blob) == UNIT_SZ
        ctypes.memmove(ctypes.byref(state, UNIT_SZ * i), blob, UNIT_SZ)

    events = []
    CB = ctypes.CFUNCTYPE(None, ctypes.c_void_p, ctypes.c_int, ctypes.c_int,
                          ctypes.c_int)

    def rec(kind):
        def f(user, unit, note, vel):
            events.append((kind, unit, note & 0xFF, vel & 0xFF))
        return CB(f)

    cbs_keep = [rec("A_on"), rec("A_off"), rec("B_on"), rec("B_off")]

    class Cbs(ctypes.Structure):
        _fields_ = [("s518_on", CB), ("s518_off", CB),
                    ("s520_on", CB), ("s520_off", CB),
                    ("user", ctypes.c_void_p)]
    cbs = Cbs(cbs_keep[0], cbs_keep[1], cbs_keep[2], cbs_keep[3], None)

    a = ctypes.byref(state)
    for ev in jx_alloc_seq.make():
        if ev[0] == "on":
            lib.jx_alloc_note_on(a, ctypes.byref(cbs), ev[1], ev[2])
        elif ev[0] == "off":
            lib.jx_alloc_note_off(a, ctypes.byref(cbs), ev[1], ev[2])
        elif ev[0] == "sus":
            lib.jx_alloc_set_sustain(a, ctypes.byref(cbs), ev[1], ev[2])
        elif ev[0] == "hold":
            lib.jx_alloc_set_hold(a, ctypes.byref(cbs), ev[1], ev[2])
        elif ev[0] == "poly":
            lib.jx_alloc_set_poly(a, ev[1], ev[2])
        elif ev[0] == "pend":
            lib.jx_alloc_set_pending_mode(a, ev[1], ev[2])
        elif ev[0] == "mode8":
            lib.jx_alloc_set_mode8(a, ev[1], ev[2])

    ref = [tuple(l.split("\t")) for l in
           open(os.path.join(refdir, "events.tsv"))]
    ref = [(k, int(u), int(n), int(v)) for k, u, n, v in ref]
    bad = 0
    if len(ref) != len(events):
        print("EVENT COUNT differs: oracle %d vs C %d" %
              (len(ref), len(events))); bad += 1
    for i, (r, c) in enumerate(zip(ref, events)):
        if r != c:
            print("event %d differs: oracle %r vs C %r" % (i, r, c))
            bad += 1
            if bad > 10: break

    for i in range(9):
        fin = open(os.path.join(refdir, "final_%d.bin" % i), "rb").read()
        got = state.raw[UNIT_SZ * i:UNIT_SZ * (i + 1)]
        for o in range(UNIT_SZ):
            if PTR_LO <= o < PTR_HI: continue
            if fin[o] != got[o]:
                print("unit %d byte 0x%03X differs: oracle %02x vs C %02x" %
                      (i, o, fin[o], got[o]))
                bad += 1
                if bad > 30: break
        if bad > 30: break

    if bad:
        print("ALLOC A/B: %d+ differences -- NOT bit-exact" % bad)
        sys.exit(1)
    print("ALLOC A/B: EXACTLY 0 -- %d events and 9x0x%X state bytes match"
          % (len(events), UNIT_SZ))


if __name__ == "__main__":
    main()

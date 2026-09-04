#!/usr/bin/env python3
"""jx_dn_c.py -- C side of the note/gate handler A/B (process B).
Pointer fields inside the blobs are compared EXCLUDED (they are oracle
addresses): proc +0x0..0x8 (vtable) and every 8-byte slot the handlers never
write anyway is caught by the init-copy, so only the vtable window is
skipped. exit 0 = EXACTLY 0.  usage: jx_dn_c.py <refdir> <libjxdn.so>
"""
import sys, os, ctypes, struct
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import jx_dn_seq

PROC_SZ, STATE_SZ = 0x700, 0x60000


def main():
    refdir, so = sys.argv[1], sys.argv[2]
    lib = ctypes.CDLL(so)
    seam = open(os.path.join(refdir, "seam.bin"), "rb").read()
    o58, o5c = struct.unpack("<ii", seam[:8])
    temper = (ctypes.c_float * 23).from_buffer_copy(seam[8:8 + 92])

    class Cbs(ctypes.Structure):
        _fields_ = [("temper23", ctypes.POINTER(ctypes.c_float)),
                    ("o110_58", ctypes.c_int32), ("o110_5c", ctypes.c_int32)]
    cbs = Cbs(ctypes.cast(temper, ctypes.POINTER(ctypes.c_float)), o58, o5c)

    proc = ctypes.create_string_buffer(
        open(os.path.join(refdir, "proc_init.bin"), "rb").read(), PROC_SZ)
    state = ctypes.create_string_buffer(
        open(os.path.join(refdir, "state_init.bin"), "rb").read(), STATE_SZ)

    for ev in jx_dn_seq.make():
        f = lib.jx_dispatch_note_cb if ev[0] == "note" \
            else lib.jx_dispatch_gate_cb
        f(ctypes.byref(cbs), proc, state, ev[1], 2, ev[2])

    bad = 0
    for name, buf, fin_name, sz in (
            ("proc", proc, "proc_final.bin", PROC_SZ),
            ("state", state, "state_final.bin", STATE_SZ)):
        fin = open(os.path.join(refdir, fin_name), "rb").read()
        got = buf.raw[:sz]
        for o in range(sz):
            if name == "proc" and o < 8: continue     # vtable ptr
            if name == "state" and 136 <= o < 144: continue  # link ptr
            if fin[o] != got[o]:
                print("%s byte 0x%X differs: oracle %02x vs C %02x"
                      % (name, o, fin[o], got[o]))
                bad += 1
                if bad > 40: break
        if bad > 40: break
    if bad:
        print("DN A/B: %d+ differences -- NOT bit-exact" % bad)
        sys.exit(1)
    print("DN A/B: EXACTLY 0 -- %d dispatches, proc+state bytes match"
          % len(jx_dn_seq.make()))


if __name__ == "__main__":
    main()

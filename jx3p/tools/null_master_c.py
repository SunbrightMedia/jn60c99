#!/usr/bin/env python3
"""null_master_c.py -- C side of the master-render null gate (process B).
Loads mstate_in, replays the captured per-sample voice inputs through
jx_master_render, compares L/R out + final state to the oracle. EXACTLY 0."""
import sys, os, ctypes, struct

def main():
    refdir = sys.argv[1]; so = sys.argv[2]
    n = int(sys.argv[3]) if len(sys.argv) > 3 else 32
    SNAP = 0xAAD000
    lib = ctypes.CDLL(so)
    if hasattr(lib, "jx_set_ftz"): lib.jx_set_ftz()
    fn = lib.jx_master_render
    fn.restype = ctypes.c_void_p
    fn.argtypes = [ctypes.c_void_p, ctypes.c_void_p, ctypes.c_void_p]

    st = bytearray(open(os.path.join(refdir, "mstate_in.bin"), "rb").read())
    buf = (ctypes.c_ubyte * len(st)).from_buffer(st)
    # relocate the st+136 note-object chain into native memory
    import struct as _st
    link = open(os.path.join(refdir, "mlink.bin"), "rb").read()
    mobj = bytearray(link[:256]); d136 = link[256:260]; d112 = link[260:516]
    mobjbuf = (ctypes.c_ubyte*256).from_buffer(mobj)
    c136 = (ctypes.c_ubyte*4).from_buffer(bytearray(d136))
    c112 = (ctypes.c_ubyte*256).from_buffer(bytearray(d112))
    _keep = [mobjbuf, c136, c112]
    _st.pack_into('<Q', mobj, 136, ctypes.addressof(c136))
    _st.pack_into('<Q', mobj, 112, ctypes.addressof(c112))
    _st.pack_into('<Q', st, 136, ctypes.addressof(mobjbuf))
    vins = open(os.path.join(refdir, "mvins.bin"), "rb").read()
    ref_outs = open(os.path.join(refdir, "mouts.bin"), "rb").read()
    ref_state = open(os.path.join(refdir, "mstate_ref.bin"), "rb").read()

    # a2 = 16 pointers to 16 floats (the captured voice outputs, refreshed/sample)
    vcells = (ctypes.c_uint32 * 16)()
    a2 = (ctypes.c_void_p * 16)(*[ctypes.cast(ctypes.byref(vcells, 4*i), ctypes.c_void_p) for i in range(16)])
    a2b = ctypes.cast(a2, ctypes.c_void_p)   # pass as byte-addressed base
    outL = ctypes.c_uint32(0); outR = ctypes.c_uint32(0)
    a3 = (ctypes.c_void_p * 2)(ctypes.cast(ctypes.byref(outL), ctypes.c_void_p),
                               ctypes.cast(ctypes.byref(outR), ctypes.c_void_p))
    out_mm = 0
    for s in range(n):
        vin = struct.unpack_from('<16I', vins, s*64)
        for i in range(16): vcells[i] = vin[i]
        outL.value = 0; outR.value = 0
        fn(ctypes.addressof(buf), a2b, a3)
        rl, rr = struct.unpack_from('<II', ref_outs, s*8)
        if outL.value != rl or outR.value != rr:
            out_mm += 1
            if out_mm <= 4:
                print("  sample %d: L C=0x%08x ref=0x%08x  R C=0x%08x ref=0x%08x"
                      % (s, outL.value, rl, outR.value, rr))
    # exclude st+136 (the note-object pointer we relocated into native memory)
    state_mm = sum(1 for o in range(0, SNAP, 4)
                   if bytes(st[o:o+4]) != ref_state[o:o+4] and not (136 <= o < 144))
    print("master null: out mismatch %d/%d, state-byte diff %d" %
          (out_mm, n, state_mm*4))
    ok = (out_mm == 0 and state_mm == 0)
    print("MASTER NULL: EXACTLY 0" if ok else "MASTER NULL: NONZERO -- DEFECT")
    return 0 if ok else 1

if __name__ == "__main__":
    sys.exit(main())

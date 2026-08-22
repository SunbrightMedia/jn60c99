#!/usr/bin/env python3
"""null_voice_c.py -- C side of the voice-arm null gate (process B).

Loads jx_voice.so (the transcription), and for each voice replays the SAME N
samples from the emulator's state_in snapshot, then compares outputs and the
final state region to the emulator reference, BIT-EXACT.

Two-process rule: no Unicorn import here. This process only ctypes-loads C.

usage: null_voice_c.py <refdir> <jx_voice.so> [nsamples=32]
"""
import sys, os, ctypes, struct

SNAP = 0x60000
NV = 8

def main():
    refdir = sys.argv[1]; so = sys.argv[2]
    n = int(sys.argv[3]) if len(sys.argv) > 3 else 32
    lib = ctypes.CDLL(so)
    # match the plugin FP environment: FTZ|DAZ (the DSP runs with them set).
    try:
        libm = ctypes.CDLL("libc.so.6")
    except OSError:
        libm = None
    # set MXCSR via a tiny helper compiled into jx_voice.so if present; else use
    # ctypes to call _mm via a fallback. We expose jx_set_ftz() from the .so.
    if hasattr(lib, "jx_set_ftz"):
        lib.jx_set_ftz()
    fn = lib.jx_voice_render
    fn.restype = ctypes.c_uint64
    fn.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_void_p]

    total_mismatch = 0; total_state_mm = 0
    keep = []   # keep relocation buffers alive for the whole voice loop
    for v in range(NV):
        st = bytearray(open(os.path.join(refdir, "state_in_%d.bin" % v), "rb").read())
        buf = (ctypes.c_ubyte * len(st)).from_buffer(st)
        # relocate the st+136 cross-object chain into native memory:
        #   obj(256) | d40(4) | d64(4)  from link_%d.bin
        link = open(os.path.join(refdir, "link_%d.bin" % v), "rb").read()
        obj = bytearray(link[:256]); d40 = ctypes.c_uint32.from_buffer_copy(link[256:260])
        d64 = ctypes.c_uint32.from_buffer_copy(link[260:264])
        objbuf = (ctypes.c_ubyte * 256).from_buffer(obj)
        # patch obj+40 -> &d40, obj+64 -> &d64 (native pointers)
        struct.pack_into('<Q', obj, 40, ctypes.addressof(d40))
        struct.pack_into('<Q', obj, 64, ctypes.addressof(d64))
        # patch st+136 -> &obj
        struct.pack_into('<Q', st, 136, ctypes.addressof(objbuf))
        keep += [obj, objbuf, d40, d64]
        outM = ctypes.c_uint32(0); outS = ctypes.c_uint32(0)
        pair = (ctypes.c_void_p * 2)(ctypes.cast(ctypes.byref(outM), ctypes.c_void_p),
                                     ctypes.cast(ctypes.byref(outS), ctypes.c_void_p))
        ref = open(os.path.join(refdir, "outs_%d.bin" % v), "rb").read()
        refpairs = [struct.unpack_from('<II', ref, 8*i) for i in range(n)]
        mm = 0; first = None
        for s in range(n):
            outM.value = 0; outS.value = 0
            fn(ctypes.addressof(buf), v, pair)
            got = (outM.value, outS.value)
            if got != refpairs[s]:
                mm += 1
                if first is None: first = (s, got, refpairs[s])
        # final state compare
        ref_state = open(os.path.join(refdir, "state_ref_%d.bin" % v), "rb").read()
        got_state = bytes(st[:SNAP])
        # exclude the relocated cross-object pointer cell st+136 (8 bytes): we
        # deliberately repoint it natively; it is not DSP state and the arm never
        # writes it. Every other byte must match.
        def masked(b): return b[:136] + b"\x00"*8 + b[144:SNAP]
        g = masked(got_state); r = masked(ref_state)
        state_diffs = sum(1 for a, b in zip(g, r) if a != b)
        total_mismatch += mm; total_state_mm += state_diffs
        msg = "voice %d: out mismatch %d/%d, state-byte diff %d" % (v, mm, n, state_diffs)
        if first: msg += "  first@%d got=%s ref=%s" % (first[0], [hex(x) for x in first[1]], [hex(x) for x in first[2]])
        print(msg)
    print("\nNULL: %s (out mismatches=%d, state diffs=%d)" %
          ("EXACTLY 0" if total_mismatch == 0 and total_state_mm == 0 else "NONZERO -- DEFECT",
           total_mismatch, total_state_mm))
    return 0 if (total_mismatch == 0 and total_state_mm == 0) else 1

if __name__ == "__main__":
    sys.exit(main())

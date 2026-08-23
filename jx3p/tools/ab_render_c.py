#!/usr/bin/env python3
"""ab_render_c.py -- C side of the INTEGRATION render A/B (process B).

Loads the transcribed engine (voice + master in one .so) and, per patch dir
written by ab_render_emu.py, replays the SAME N samples through the FULL
per-sample chain: 8x jx_voice_render feeding jx_master_render. Compares,
bit-exact: the seam (16 voice-output words vs the oracle's), L/R, and every
final state. EXACTLY 0 or the patch is listed as failing -- and a failure on
a mode-selecting patch is the master's argless-site work list, on schedule.

usage: ab_render_c.py <refdir> <libjxengine.so> [n=32] [patches...]
"""
import sys, os, ctypes, struct

SNAP_V = 0x60000
SNAP_M = 0xAAD000

def run_patch(d, lib, n):
    keep = []
    vfn = lib.jx_voice_render
    vfn.restype = ctypes.c_uint64
    vfn.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_void_p]
    mfn = lib.jx_master_render
    mfn.restype = ctypes.c_void_p
    mfn.argtypes = [ctypes.c_void_p, ctypes.c_void_p, ctypes.c_void_p]

    vstates = []; vbufs = []
    for v in range(8):
        st = bytearray(open(os.path.join(d, "vstate_in_%d.bin" % v), "rb").read())
        buf = (ctypes.c_ubyte * len(st)).from_buffer(st)
        link = open(os.path.join(d, "vlink_%d.bin" % v), "rb").read()
        obj = bytearray(link[:256])
        d40 = ctypes.c_uint32.from_buffer_copy(link[256:260])
        d64 = ctypes.c_uint32.from_buffer_copy(link[260:264])
        objbuf = (ctypes.c_ubyte * 256).from_buffer(obj)
        struct.pack_into('<Q', obj, 40, ctypes.addressof(d40))
        struct.pack_into('<Q', obj, 64, ctypes.addressof(d64))
        struct.pack_into('<Q', st, 136, ctypes.addressof(objbuf))
        keep += [obj, objbuf, d40, d64]
        vstates.append(st); vbufs.append(buf)

    mst = bytearray(open(os.path.join(d, "mstate_in.bin"), "rb").read())
    mbuf = (ctypes.c_ubyte * len(mst)).from_buffer(mst)
    mlink = open(os.path.join(d, "mlink.bin"), "rb").read()
    mobj = bytearray(mlink[:256]); md136 = mlink[256:260]; md112 = mlink[260:516]
    mobjbuf = (ctypes.c_ubyte*256).from_buffer(mobj)
    c136 = (ctypes.c_ubyte*4).from_buffer(bytearray(md136))
    c112 = (ctypes.c_ubyte*256).from_buffer(bytearray(md112))
    keep += [mobj, mobjbuf, c136, c112]
    struct.pack_into('<Q', mobj, 136, ctypes.addressof(c136))
    struct.pack_into('<Q', mobj, 112, ctypes.addressof(c112))
    struct.pack_into('<Q', mst, 136, ctypes.addressof(mobjbuf))

    # the seam: 16 native float cells; voices write pairs, master reads a2
    vcells = (ctypes.c_uint32 * 16)()
    a2 = (ctypes.c_void_p * 16)(*[ctypes.cast(ctypes.byref(vcells, 4*i), ctypes.c_void_p)
                                  for i in range(16)])
    a2b = ctypes.cast(a2, ctypes.c_void_p)
    pairs = []
    for v in range(8):
        pairs.append((ctypes.c_void_p * 2)(
            ctypes.cast(ctypes.byref(vcells, 8*v), ctypes.c_void_p),
            ctypes.cast(ctypes.byref(vcells, 8*v+4), ctypes.c_void_p)))
    outL = ctypes.c_uint32(0); outR = ctypes.c_uint32(0)
    a3 = (ctypes.c_void_p * 2)(ctypes.cast(ctypes.byref(outL), ctypes.c_void_p),
                               ctypes.cast(ctypes.byref(outR), ctypes.c_void_p))

    ref_vins = open(os.path.join(d, "vins.bin"), "rb").read()
    ref_louts = open(os.path.join(d, "louts.bin"), "rb").read()
    seam_mm = out_mm = 0
    for s in range(n):
        for v in range(8):
            vfn(ctypes.addressof(vbufs[v]), v, pairs[v])
        rvin = struct.unpack_from('<16I', ref_vins, 64*s)
        if tuple(vcells) != rvin:
            seam_mm += 1
        outL.value = 0; outR.value = 0
        mfn(ctypes.addressof(mbuf), a2b, a3)
        rl, rr = struct.unpack_from('<II', ref_louts, 8*s)
        if outL.value != rl or outR.value != rr:
            out_mm += 1
            if out_mm <= 2:
                print("    s%d L C=0x%08x ref=0x%08x R C=0x%08x ref=0x%08x"
                      % (s, outL.value, rl, outR.value, rr))
    vstate_mm = 0
    for v in range(8):
        ref = open(os.path.join(d, "vstate_ref_%d.bin" % v), "rb").read()
        vstate_mm += sum(1 for o in range(0, SNAP_V, 4)
                         if bytes(vstates[v][o:o+4]) != ref[o:o+4]
                         and not (136 <= o < 144))
    mref = open(os.path.join(d, "mstate_ref.bin"), "rb").read()
    mstate_mm = sum(1 for o in range(0, SNAP_M, 4)
                    if bytes(mst[o:o+4]) != mref[o:o+4] and not (136 <= o < 144))
    ok = (seam_mm == 0 and out_mm == 0 and vstate_mm == 0 and mstate_mm == 0)
    print("  %s: seam %d/%d, L/R %d/%d, vstate %d words, mstate %d words -> %s"
          % (os.path.basename(d), seam_mm, n, out_mm, n, vstate_mm, mstate_mm,
             "EXACTLY 0" if ok else "FAIL"))
    return ok

def main():
    refdir = sys.argv[1]; so = sys.argv[2]
    n = int(sys.argv[3]) if len(sys.argv) > 3 else 32
    lib = ctypes.CDLL(so)
    if hasattr(lib, "jx_set_ftz"):
        lib.jx_set_ftz()
    dirs = sorted(dd for dd in os.listdir(refdir) if dd.startswith("p"))
    fails = 0
    for dd in dirs:
        if not run_patch(os.path.join(refdir, dd), lib, n):
            fails += 1
    print("AB RENDER: %d/%d patches EXACTLY 0" % (len(dirs) - fails, len(dirs)))
    return 0 if fails == 0 else 1

if __name__ == "__main__":
    sys.exit(main())

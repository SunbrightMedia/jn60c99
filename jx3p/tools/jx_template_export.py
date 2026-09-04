#!/usr/bin/env python3
"""jx_template_export.py -- export the CLEAN-BOOT template (charter 7b).

Builds the plugin under Unicorn through its OWN entry path (BUILD + SETSR),
takes the patch-independent prepared state of all 8 voices + the master, and
writes it SPARSE (nonzero runs only) to jx3p/gen/jx_template.bin:

  header:  'JXT1' u32 nruns_total
  runs:    u8 region (0..7 voice, 8 master), u32 off, u32 len, bytes
  footer:  u32 crc32 of everything before it

Pointer-valued cells (the object pointer at st+136 in each region, and the
link objects' own pointer slots) are ZEROED in the template -- the C engine
re-links them at boot (PORT_LESSONS #4: pointers never survive an address
space). The link objects' VALUE bytes ride along as separate records:
  vlink_%d / mlink after the runs, same format as ab_render_emu writes.

The NaN census of the template is printed and MUST be 0 -- a clean boot with
NaN is refused loudly (the tooth: set JX_TEMPLATE_ALLOW_NAN=1 only to
diagnose).

usage: jx_template_export.py [sr=44100]
"""
import sys, os, struct, zlib
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                "..", "..", "tools", "verify"))
import jx_emu as J

SNAP_V = 0x60000
SNAP_M = 0xAAD000
SETSR = 0x3F9970


def nan_count(buf):
    n = 0
    for o in range(0, len(buf) - 3, 4):
        b = buf[o:o + 4]
        if (b[3] & 0x7F) == 0x7F and (b[2] & 0x80) and \
           (b[0] or b[1] or (b[2] & 0x7F)):
            n += 1
    return n




def main():
    sr = float(sys.argv[1]) if len(sys.argv) > 1 else 44100.0
    jx = J.JX().build()
    jx.set_ftz()
    uc = jx.uc
    jx.call(J.IB + SETSR, rcx=jx.HOST,
            rdx=struct.unpack("<Q", struct.pack("<d", sr))[0])

    regions = []
    links = []
    def rq(a): return int.from_bytes(uc.mem_read(a, 8), "little")
    for v in range(8):
        st = jx.state[v]
        buf = bytearray(uc.mem_read(st, SNAP_V))
        obj = rq(st + 136)
        objb = bytes(uc.mem_read(obj, 256))
        p40 = rq(obj + 40); p64 = rq(obj + 64)
        links.append(objb + bytes(uc.mem_read(p40, 4)) +
                     bytes(uc.mem_read(p64, 4)))
        struct.pack_into("<Q", buf, 136, 0)          # pointer zeroed
        regions.append(buf)
    # control-plane blobs: 9 note managers (+their nstore/ktrack objects)
    # and the 9 proc headers + the dispatch seam constants
    for i in range(9):
        u = rq(jx.HOST + 0x78 + 0x40 * i)
        mgr = bytearray(uc.mem_read(u, 0x7A8))
        struct.pack_into("<QQ", mgr, 0x518, 0, 0)     # sink ptrs zeroed
        ns = bytearray(uc.mem_read(rq(u + 0x518), 0xDB0))
        struct.pack_into("<Q", ns, 0, 0)              # vtable
        kt = bytearray(uc.mem_read(rq(u + 0x520), 0xB0))
        struct.pack_into("<Q", kt, 0, 0)              # vtable
        regions.append(mgr); regions.append(ns); regions.append(kt)
    for i in range(9):
        pr = bytearray(uc.mem_read(jx.proc[i], 0x700))
        struct.pack_into("<Q", pr, 0, 0)              # vtable
        regions.append(pr)
    # WRAPPER + RAMP layer, per unit (charter 7b: a clean boot has 216 LIVE
    # ramps, latch=960, flag=1 -- measured, not assumed):
    #   u32 latch, u8 flag, pad3, u32 nids, ids..., u32 nslots,
    #   slots: {u32 target_off (from the unit state base), 36 bytes rest}
    for u in range(9):
        st = jx.state[u]
        latch = struct.unpack("<i", uc.mem_read(st + 0xAAC308, 4))[0]
        flag = uc.mem_read(st + 0x14, 1)[0]
        arr = rq(st + 0x58)
        b0 = rq(st + 0x70); e0 = rq(st + 0x78)
        ids = list(struct.unpack("<%di" % ((e0 - b0) // 4),
                                 uc.mem_read(b0, e0 - b0))) if e0 > b0 else []
        nslot = (max(ids) + 1) if ids else 0
        rec = struct.pack("<iBxxxI", latch, flag, len(ids))
        rec += struct.pack("<%di" % len(ids), *ids) if ids else b""
        rec += struct.pack("<I", nslot)
        for i in range(nslot):
            sl = bytes(uc.mem_read(arr + 40 * i, 40))
            tgt = struct.unpack("<Q", sl[:8])[0]
            off = tgt - st if tgt else 0xFFFFFFFF
            rec += struct.pack("<I", off & 0xFFFFFFFF) + sl[8:]
        links.append(rec)
    # voice HIGH windows (ramp targets + wrapper cells live above the DSP
    # window): sparse via zlib, one region per voice
    for u in range(8):
        regions.append(bytearray(uc.mem_read(jx.state[u] + 0xA60000,
                                             0x4D000)))
    o110 = rq(jx.proc[0] + 0x110)
    links.append(bytes(uc.mem_read(o110 + 0x58, 8)) +
                 bytes(uc.mem_read(J.IB + 0x9BF2F4, 23 * 4)))
    st8 = jx.state[8]
    buf = bytearray(uc.mem_read(st8, SNAP_M))
    obj = rq(st8 + 136)
    mobjb = bytes(uc.mem_read(obj, 256))
    p136 = rq(obj + 136); p112 = rq(obj + 112)
    links.append(mobjb + bytes(uc.mem_read(p136, 4)) +
                 bytes(uc.mem_read(p112, 256)))
    struct.pack_into("<Q", buf, 136, 0)
    regions.append(buf)

    # the census is a FLOAT-state rule: DSP regions only (8 voices + the
    # master, regions 0..7 and the last). The control blobs hold int lists
    # filled with -1, whose bit pattern is a NaN but is never float data.
    dsp = regions[:8] + [regions[-1]]
    nn = sum(nan_count(r) for r in dsp)
    print("template NaN census: %d (0 REQUIRED)" % nn)
    if nn and os.environ.get("JX_TEMPLATE_ALLOW_NAN") != "1":
        raise SystemExit("CLEAN BOOT CONTAINS NaN -- refused")

    raw = sum(len(r) for r in regions)
    dst = os.path.join(J.REPO, "jx3p", "gen", "jx_template.bin")
    with open(dst, "wb") as f:
        f.write(b"JXT2" + struct.pack("<I", len(regions)))
        crc = zlib.crc32(b"JXT2")
        for r in regions:
            z = zlib.compress(bytes(r), 9)
            hdr = struct.pack("<II", len(r), len(z))
            f.write(hdr + z)
            crc = zlib.crc32(hdr, crc); crc = zlib.crc32(z, crc)
        for lk in links:
            hdr = struct.pack("<I", len(lk))
            f.write(hdr + lk)
            crc = zlib.crc32(hdr, crc); crc = zlib.crc32(lk, crc)
        f.write(struct.pack("<I", crc & 0xFFFFFFFF))
    print("template: %d regions, raw %d B -> %d B compressed, %s"
          % (len(regions), raw, os.path.getsize(dst), dst))


if __name__ == "__main__":
    main()

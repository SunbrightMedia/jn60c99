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
    st8 = jx.state[8]
    buf = bytearray(uc.mem_read(st8, SNAP_M))
    obj = rq(st8 + 136)
    mobjb = bytes(uc.mem_read(obj, 256))
    p136 = rq(obj + 136); p112 = rq(obj + 112)
    links.append(mobjb + bytes(uc.mem_read(p136, 4)) +
                 bytes(uc.mem_read(p112, 256)))
    struct.pack_into("<Q", buf, 136, 0)
    regions.append(buf)

    nn = sum(nan_count(r) for r in regions)
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

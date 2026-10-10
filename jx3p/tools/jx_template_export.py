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




NS_SZ = 0xFF0          # the note store's allocation (4080 bytes, EXECUTED); 0xDB0 before 2026-10-10


def control_blobs(jx):
    """the 36 control objects in template region order (8..43): per unit its note manager (0x7A8, the
    sink pointers at +0x518 zeroed), note store (NS_SZ, its whole allocation since 2026-10-10: the clock
    tick reads it to +0xFD8) and assigner (0xB0), each vtable zeroed; then
    the 9 parameter objects (0x700, vtable zeroed). The recall exporter diffs the same blobs per patch."""
    uc = jx.uc
    def rq(a): return int.from_bytes(uc.mem_read(a, 8), "little")
    out = []
    for i in range(9):
        u = rq(jx.HOST + 0x78 + 0x40 * i)
        mgr = bytearray(uc.mem_read(u, 0x7A8))
        struct.pack_into("<QQ", mgr, 0x518, 0, 0)     # sink ptrs zeroed
        nsa = rq(u + 0x518)
        ns = bytearray(uc.mem_read(nsa, NS_SZ))
        struct.pack_into("<Q", ns, 0, 0)              # vtable
        # +0x20: the step pattern's pointer -- 0 or the store's own +0xDA8 (EXECUTED, KEY ASSIGN patches): kept
        # as its offset in the store, the form the port uses; +0xFD8: the assigner the store plays into (a
        # pointer, the port's link)
        p20 = struct.unpack_from("<Q", ns, 0x20)[0]
        if p20:
            if not nsa <= p20 < nsa + NS_SZ:
                raise SystemExit("unit %d: the note store's +0x20 points outside it (0x%x)" % (i, p20))
            struct.pack_into("<Q", ns, 0x20, p20 - nsa)
        struct.pack_into("<Q", ns, 0xFD8, 0)
        kt = bytearray(uc.mem_read(rq(u + 0x520), 0xB0))
        struct.pack_into("<Q", kt, 0, 0)              # vtable
        out += [bytes(mgr), bytes(ns), bytes(kt)]
    for i in range(9):
        pr = bytearray(uc.mem_read(jx.proc[i], 0x700))
        struct.pack_into("<Q", pr, 0, 0)              # vtable
        out.append(bytes(pr))
    return out


def host_record(jx):
    """HOST+0x38 voices, +0x860 gain, +0x864 step, +0x868 samples left, +0x86C delay, +0x870 fade time,
    +8 the engine rate: 28 bytes, the bridge's host_record() layout"""
    r = lambda off, n: bytes(jx.uc.mem_read(jx.HOST + off, n))
    return r(0x38, 4) + r(0x860, 20) + r(8, 4)


def main():
    a = [x for x in sys.argv[1:]]
    out = a[a.index("--out") + 1] if "--out" in a else None     # another engine rate's template (JX-4)
    if out:
        del a[a.index("--out"):a.index("--out") + 2]
    sr = float(a[0]) if a else 44100.0
    # the plugin's factory HOST -> BUILD -> SETSR (float in xmm1 -- the ABI
    # ledger in jx_emu; the old rdx call never set a rate, playbook 87) ->
    # FTZ. Ramps + latch stay LIVE, as shipped: the template carries them and
    # the C engine replays them. (2026-09-05 to 10-10 this snapped every ramp
    # because the master's boot ramps poisoned the EFX at idle sample 3681 --
    # an artefact of the zero HOST's inf ramp steps, playbook 194: on the
    # factory HOST the unsnapped boot is finite, no pin, idle -61 dBFS.)
    jx = J.JX().boot(sr, snap=False, product=True)   # the plugin's own boot records (jx_patch_records.json)
    uc = jx.uc

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
    # and the 9 proc headers (regions 8..43)
    regions.extend(bytearray(b) for b in control_blobs(jx))
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
    # The master's WRAPPER region [0xAAC000,0xAAD000) holds control cells,
    # not DSP floats: the controller's default push writes the STEP SEQ
    # Assign targets (ids 1493-1499, Script.xml default 0, DB max=-1 flag
    # arrays) as a NaN sentinel at +0xAAC6F4 on every unit -- the plugin's
    # own hosted state, measured benign (master finite over 12000 samples).
    # Excluded from the census BY OFFSET so the tooth still bites on DSP.
    dsp = regions[:8] + [regions[-1][:0xAAC000]]
    nn = sum(nan_count(r) for r in dsp)
    print("template NaN census: %d (0 REQUIRED)" % nn)
    if nn and os.environ.get("JX_TEMPLATE_ALLOW_NAN") != "1":
        raise SystemExit("CLEAN BOOT CONTAINS NaN -- refused")

    # the engine HOST record (link 19, JXT4; 2026-10-10): what the plugin's engine render reads from
    # its HOST after the boot records -- the voice count, the output gain stage armed by writePatch,
    # the engine rate (jx3p/docs/HOST_LAYER.md)
    links.append(host_record(jx))
    # JXT4: regions RAW (the engine parses with no zlib; the WEB fetches the
    # gzip sidecar and inflates with the browser's own DecompressionStream)
    raw = sum(len(r) for r in regions)
    dst = out or os.path.join(J.REPO, "jx3p", "gen", "jx_template.bin")
    body = b"JXT4" + struct.pack("<I", len(regions))
    for r in regions:
        body += struct.pack("<I", len(r)) + bytes(r)
    for lk in links:
        body += struct.pack("<I", len(lk)) + lk
    body += struct.pack("<I", zlib.crc32(body) & 0xFFFFFFFF)
    open(dst, "wb").write(body)
    import gzip
    with open(dst + ".gz", "wb") as fh, gzip.GzipFile(filename="", mode="wb", compresslevel=9,
                                                    fileobj=fh, mtime=0) as gz:   # no name, no time:
        gz.write(body)                                                              # equal bytes every run
    print("template: %d regions, %d B raw file (%d B gz), %s"
          % (len(regions), len(body), os.path.getsize(dst + ".gz"), dst))


if __name__ == "__main__":
    main()

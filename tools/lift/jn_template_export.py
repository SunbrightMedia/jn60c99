#!/usr/bin/env python3
"""jn_template_export.py -- L4 of the JUNO lift (docs/JUNO_LIFT.md): the SHIPPING TEMPLATE for the lifted host.

The cut is the JP8 HOST cut (jp8/docs/HOST_LAYER.md): the JUNO host oracle (tools/verify/host_process_emu.HostProcess)
booted to the point a DAW reaches BEFORE it learns its sample rate -- boot_host() (DllMain, the factory, createInstance,
IComponent + IEditController initialize and connect, setComponentState). Everything after -- setupProcessing,
setActive, process(), patch load, getState / setState, the UI timer, the editor -- runs LIVE in the lifted C
(lift/jn_lift.c on tools/lift/jn_rt via jp8_cpu.h). The template is the oracle's address space right after boot_host,
region by region, plus the runtime scalars (the heap bump pointer, the fake-handle counter, the entry rsp, the RET
sentinel). Format JNT v1 == the proven JP8T v1 (little endian):
  "JNT" u32 version u32 nregions; per region u64 base u64 size u32 nruns, per run u32 off u32 len bytes[len]
  (zero pages skipped); scalars u64 heap_ptr0 u64 heap_limit u64 hc0 u64 rsp u64 ret; u32 crc32 of all bytes before.
Self-check: parse the file back and compare every region byte for byte with oracle memory; TOOTH: one flipped byte
must fail the check (seen to fail, mantra 5).
usage: python3 tools/lift/jn_template_export.py <out.bin>     (Unicorn only; writes <out.bin> and <out.bin>.gz)
"""
import sys
import os
import struct
import zlib
import gzip
import time
import hashlib

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
sys.path.insert(0, os.path.join(REPO, 'probes', 'b6'))
import host_process_emu as H                                       # noqa: E402
E = H.E
PAGE = 0x1000
HEAP_MAP = 0x8000000                                               # the slice of the 8 GB heap region we carry past base
REGIONS = [("page0", 0x0, 0x100000), ("image", E.IB, E.IMGSZ), ("stack", E.STACK_BASE, E.STACK_SIZE),
           ("heap", E.HEAP_BASE, HEAP_MAP), ("stub", E.STUB_BASE, 0x100000)]
RSP = (E.STACK_BASE + E.STACK_SIZE - 0x10000) & ~0xF
RET = E.SCRATCH + 0x5000


def runs_of(blob):
    out, i, n = [], 0, len(blob)
    while i < n:
        if not any(blob[i:i + PAGE]):
            i += PAGE
            continue
        j = i
        while j < n and any(blob[j:j + PAGE]):
            j += PAGE
        out.append((i, bytes(blob[i:j])))
        i = j
    return out


def parse(buf):
    assert buf[:4] == b"JNT ", "magic"
    ver, nreg = struct.unpack_from("<II", buf, 4)
    assert ver == 1, "version"
    crc = struct.unpack_from("<I", buf, len(buf) - 4)[0]
    if zlib.crc32(buf[:-4]) & 0xFFFFFFFF != crc:
        raise ValueError("crc32 mismatch")
    p, regs = 12, []
    for _ in range(nreg):
        base, size, nruns = struct.unpack_from("<QQI", buf, p)
        p += 20
        mem = bytearray(size)
        for _ in range(nruns):
            off, ln = struct.unpack_from("<II", buf, p)
            p += 8
            mem[off:off + ln] = buf[p:p + ln]
            p += ln
        regs.append((base, size, mem))
    sc = struct.unpack_from("<QQQQQ", buf, p)
    p += struct.calcsize("<QQQQQ")
    assert p == len(buf) - 4, "trailing bytes"
    return regs, dict(zip(("heap_ptr0", "heap_limit", "hc0", "rsp", "ret"), sc))


def main():
    t0 = time.time()

    def log(m):
        print("[%6.1fs] %s" % (time.time() - t0, m), flush=True)

    out = sys.argv[1]
    h = H.HostProcess()
    h.boot_host(log=lambda s: None)
    log("boot_host done: heap bump 0x%x, hc 0x%x" % (h.heap, h._hc))
    mem = {}
    for name, base, size in REGIONS:
        if name == "heap":
            mem[name] = bytes(h.uc.mem_read(base, h.heap - base))   # [base, bump pointer)
        elif name == "stub":
            mem[name] = b""                                         # import / COM stubs are call targets only (JP8 "pb")
        elif name == "page0":
            mem[name] = bytes(h.uc.mem_read(0, 0x1000))
        else:
            mem[name] = bytes(h.uc.mem_read(base, size))
    stray = [(b, e + 1) for b, e, _ in h.uc.mem_regions()
             if not any(rb <= b < rb + rs for _, rb, rs in REGIONS) and not (E.STUB_BASE <= b < E.STUB_BASE + 0x100000)]
    log("oracle regions outside the template: %s" % (", ".join("0x%x-0x%x" % be for be in stray) or "none"))
    body = bytearray(b"JNT " + struct.pack("<II", 1, len(REGIONS)))
    for name, base, size in REGIONS:
        rr = runs_of(mem[name]) if mem[name] else []
        body += struct.pack("<QQI", base, size, len(rr))
        for off, b in rr:
            body += struct.pack("<II", off, len(b)) + b
        log("region %-5s guest 0x%09x map 0x%08x: %d runs, %d bytes" % (name, base, size, len(rr), sum(len(b) for _, b in rr)))
    body += struct.pack("<QQQQQ", h.heap, E.HEAP_BASE + HEAP_MAP, h._hc, RSP, RET)
    body += struct.pack("<I", zlib.crc32(bytes(body)) & 0xFFFFFFFF)
    open(out, "wb").write(body)
    open(out + ".gz", "wb").write(gzip.compress(bytes(body), 9))
    log("wrote %s (%d bytes, sha256 %s) and .gz (%d bytes)"
        % (out, len(body), hashlib.sha256(body).hexdigest()[:16], os.path.getsize(out + ".gz")))

    def check(buf):
        regs, sc = parse(buf)
        bad = 0
        for (name, base, size), (b2, s2, m2) in zip(REGIONS, regs):
            assert (b2, s2) == (base, size)
            if name == "heap":
                ref = bytes(h.uc.mem_read(base, h.heap - base)); got = bytes(m2[:len(ref)]); tail = any(m2[len(ref):])
            elif name == "stub":
                ref = b""; got = b""; tail = any(m2)
            elif name == "page0":
                ref = bytes(h.uc.mem_read(0, 0x1000)); got = bytes(m2[:0x1000]); tail = any(m2[0x1000:])
            else:
                ref = bytes(h.uc.mem_read(base, size)); got = bytes(m2); tail = False
            if ref != got or tail:
                bad += 1
                log("SELF-CHECK: region %s differs" % name)
        if (sc["heap_ptr0"], sc["hc0"], sc["rsp"], sc["ret"]) != (h.heap, h._hc, RSP, RET):
            bad += 1
            log("SELF-CHECK: scalars differ")
        return bad
    buf = open(out, "rb").read()
    assert check(buf) == 0, "template self-check FAILED"
    log("SELF-CHECK: every region byte-identical to oracle memory, scalars equal")
    t = bytearray(buf)
    k = len(t) // 2
    t[k] ^= 0x01
    try:
        check(bytes(t)); bit = False
    except ValueError as e:
        bit = "crc: %s" % e
    t[-4:] = struct.pack("<I", zlib.crc32(bytes(t[:-4])) & 0xFFFFFFFF)
    try:
        bit2 = check(bytes(t)) > 0
    except Exception as e:
        bit2 = "parse: %s" % e
    assert bit and bit2, "TEMPLATE TOOTH DID NOT BITE (%r, %r)" % (bit, bit2)
    log("TOOTH bites: flipped byte %d -> %s; crc re-sealed -> region compare fails (%s)" % (k, bit, bit2))


if __name__ == '__main__':
    main()

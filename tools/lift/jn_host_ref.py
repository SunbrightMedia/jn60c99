#!/usr/bin/env python3
"""jn_host_ref.py -- L4 of the JUNO lift (docs/JUNO_LIFT.md): the SHIPPING TEMPLATE for the lifted JUNO host, and (later)
the ORACLE references the L5 gate grades against. The proven twin is jp8/tools/jp8_host_ref.py; this is it pointed at the
JUNO host oracle (tools/verify/host_process_emu.HostProcess on probes/b6/wrapper_emu.py).

It boots the plugin as a DAW does, up to the point a host learns its sample rate -- boot_host() (DllMain, the factory,
the component and the controller initialized and connected, the handler, setComponentState) -- then writes the oracle's
memory at that point, region by region, plus the facts the C side needs (the component, the audio processor, the core,
the controller, process() and patch load, the host-object vtables, the bump pointer, the fake-handle counter, MXCSR, the
registers) and the name of every stub address (imports and host-object methods). It holds NO sample rate: jn_host.c's
junoh_init makes the host's setup calls itself, with the rate it is given, exactly as host_process_emu.setup does.

FORMAT "JNH1" (little endian): "JNH1" u32 version(1) u32 nregions; per region u64 base u64 size u32 nruns, per run u32
off u32 len bytes[len] (zero pages skipped); u32 nfacts, per fact char key[24] u64 value; u32 nstubs, per stub u64 addr
u32 len name[len]; u32 crc32 of every byte before it. Zero pages are skipped (the gz is the shipping form).
Self-check: parse it back, compare every region byte for byte with oracle memory, facts and stubs equal; TOOTH: one
flipped byte must fail the check (seen to fail, mantra 5).
usage: python3 tools/lift/jn_host_ref.py <out.bin>     (Unicorn only; two-process rule: never loads libjuno)
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
os.environ.setdefault('JP8_EMU_QUIET', '1')
import host_process_emu as H                                     # noqa: E402
from unicorn.x86_const import UC_X86_REG_MXCSR                   # noqa: E402
from unicorn import x86_const as XC                              # noqa: E402

E = H.E
IB = E.IB
PAGE = 0x1000
PROCESS_SLOT = H.PROCESS_SLOT                                    # IAudioProcessor::process (rva 0x34A380)


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
    assert buf[:4] == b"JNH1", "magic"
    ver, nreg = struct.unpack_from("<II", buf, 4)
    assert ver == 1, "version"
    if zlib.crc32(buf[:-4]) & 0xFFFFFFFF != struct.unpack_from("<I", buf, len(buf) - 4)[0]:
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
    nf = struct.unpack_from("<I", buf, p)[0]
    p += 4
    facts = {}
    for _ in range(nf):
        key = buf[p:p + 24].split(b"\0")[0].decode()
        facts[key] = struct.unpack_from("<Q", buf, p + 24)[0]
        p += 32
    ns = struct.unpack_from("<I", buf, p)[0]
    p += 4
    stubs = []
    for _ in range(ns):
        addr, ln = struct.unpack_from("<QI", buf, p)
        p += 12
        stubs.append((addr, buf[p:p + ln].decode()))
        p += ln
    assert p == len(buf) - 4, "trailing bytes"
    return regs, facts, stubs


def main():
    t0 = time.time()

    def log(m):
        print("[%6.1fs] %s" % (time.time() - t0, m), flush=True)

    out = sys.argv[1]
    h = H.HostProcess()
    h.boot_host(log=lambda s: None)
    uc = h.uc
    q = lambda a: struct.unpack('<Q', uc.mem_read(a, 8))[0]
    heap_top = h.heap
    hc = getattr(h, '_hc', 0x9000)
    log("boot_host done: heap bump 0x%x, hc 0x%x, com_next 0x%x" % (heap_top, hc, h.com_next))
    HEAP_MAP = ((heap_top - E.HEAP_BASE + 0x10000000 + 0xFFFFF) & ~0xFFFFF)     # the heap so far + 256 MB of room
    COM_MAP = H.W.COM_SIZE                 # map the WHOLE host arena (the oracle's COM_SIZE, 256 MB), not just the boot
    #                                        size: a patch load bumps com_next far past boot, and the lifted host must
    #                                        have the same arena to bump into (a 1 MB COM map faulted at patch 51 of 64)
    REGIONS = [("page0", 0x0, 0x100000), ("image", IB, E.IMGSZ), ("stack", E.STACK_BASE, E.STACK_SIZE),
               ("heap", E.HEAP_BASE, HEAP_MAP), ("stub", E.STUB_BASE, 0x8000), ("com", H.W.COM, COM_MAP),
               ("buf", E.BUF_BASE, E.BUF_SIZE), ("teb", H.W.TEB, 0x10000)]

    def region_bytes(base, size):          # the heap and the COM arena are mapped with room; store only the used prefix
        if base == E.HEAP_BASE:
            return bytes(uc.mem_read(base, heap_top - base))
        if base == H.W.COM:
            return bytes(uc.mem_read(base, h.com_next - base))
        return bytes(uc.mem_read(base, size))

    mapped = [(b, e + 1) for b, e, _ in uc.mem_regions()]
    known = [(b, s) for _, b, s in REGIONS]
    stray = [(b, e) for b, e in mapped if not any(rb <= b < rb + rs for rb, rs in known)
             and not (E.HEAP_BASE <= b < E.HEAP_BASE + E.HEAP_SIZE)]
    log("oracle regions outside the template: %s" % (", ".join("0x%x-0x%x" % be for be in stray[:8]) or "none"))

    facts = dict(audio=h.audio, comp=h.comp, core=h.core, ctrl=h.ctrl, com_next=h.com_next,
                 process_fn=q(q(h.audio) + 8 * PROCESS_SLOT), patch_fn=H.W.PATCH_LOAD,
                 vt_events=h.vt['events'], vt_pchanges=h.vt['pchanges'], vt_pqueue=h.vt['pqueue'], vt_stream=h.vt['stream'],
                 vt_frame=h.vt['frame'],
                 heap_ptr=heap_top, heap_limit=E.HEAP_BASE + HEAP_MAP, hc=hc, mxcsr=uc.reg_read(UC_X86_REG_MXCSR),
                 rsp=(E.STACK_BASE + E.STACK_SIZE - 0x10000) & ~0xF, ret=E.SCRATCH + 0x5000,
                 lasterr=getattr(h, 'lasterr', 0), fake_heap=E.FAKE_HEAP)
    # THE REGISTERS the oracle's next call starts from (they persist between calls: only rsp, rcx, rdx, r8, r9 and the
    # RET slot are written per call) -- the C side starts from the same
    GPR = ['RAX', 'RCX', 'RDX', 'RBX', 'RSP', 'RBP', 'RSI', 'RDI'] + ['R%d' % k for k in range(8, 16)]
    for k, nm in enumerate(GPR):
        facts['r%d' % k] = uc.reg_read(getattr(XC, 'UC_X86_REG_' + nm))
    for k in range(16):
        v = uc.reg_read(getattr(XC, 'UC_X86_REG_XMM%d' % k))
        facts['x%dlo' % k] = v & (2 ** 64 - 1)
        facts['x%dhi' % k] = v >> 64
    facts['eflags'] = uc.reg_read(XC.UC_X86_REG_EFLAGS)
    # the oracle's PYTHON-SIDE state at the cut -- not guest memory, so no region carries it: the TLS / FLS dicts (keyed
    # by the full rcx, as the oracle keys them), their counters, the run-once set, and the SList stacks (bottom first).
    # The lifted glue seeds its tables from these facts (jn_host.c load); tools/lift/jn_import_census.py shows the
    # editor path reads them (2 TLS slots and a 128-node SList pool exist at the cut).
    facts['tls_ctr'] = h.tls_ctr
    facts['fls_ctr'] = h.fls_ctr
    for k, v in sorted(h.tls.items()):
        facts['tls:%d' % k] = v
    for k, v in sorted(h.fls.items()):
        facts['fls:%d' % k] = v
    for i, a in enumerate(sorted(h.once)):
        facts['once:%d' % i] = a
    for head, lst in sorted(h.__dict__.get('slists', {}).items()):
        for i, e in enumerate(lst):
            facts['sl:%d:%d' % (head, i)] = e
    # the editor imports' Python-side state (wrapper_emu._imp / _gdip): the GDI+ images and DIB sections the module init
    # made (26 + 26 at the cut), the skin's blank-image sizes by file name (wrapper_emu.skin_sizes over Script.xml; the
    # name in 8-byte chunks). The screen and the GUI clock are unset at the cut (asserted): the gates set them.
    assert not h.screen and not getattr(h, 'tick_ms', 0), 'the screen or the GUI clock is set at the cut: carry it'
    for i, (hd, im) in enumerate(h.__dict__.get('gdip_imgs', {}).items()):
        facts['gi:%d' % i] = hd
        facts['gs:%d' % i] = (im['w'] & 0xFFFFFFFF) << 32 | (im['h'] & 0xFFFFFFFF)
        facts['gf:%d' % i] = im['fmt'] & 0xFFFFFFFF
    for i, (hb, (w_, h_, bpp, stride, bits)) in enumerate(h.__dict__.get('dibs', {}).items()):
        assert hb == 0xB0000 + 0x10 * i, 'a DIB handle out of the oracle order'
        facts['dh:%d' % i] = hb
        facts['dw:%d' % i] = (w_ & 0xFFFFFFFF) << 32 | (h_ & 0xFFFFFFFF)
        facts['dp:%d' % i] = (bpp & 0xFFFFFFFF) << 32 | (stride & 0xFFFFFFFF)
        facts['db:%d' % i] = bits
    for i, (nm, (w_, h_)) in enumerate(sorted(h.skin.items())):
        nb = nm.encode('ascii')                  # ASCII lower case (the C side's match rule; non-ASCII would need str.lower)
        assert nm == nm.lower() and 0 < len(nb) < 56, 'a skin name the C side cannot hold: %r' % nm
        facts['sk:%d' % i] = (w_ & 0xFFFFFFFF) << 32 | (h_ & 0xFFFFFFFF)
        for k in range(0, len(nb), 8):
            facts['sn:%d:%d' % (i, k // 8)] = int.from_bytes(nb[k:k + 8].ljust(8, b'\0'), 'little')
    assert all(len(k) <= 24 for k in facts), 'a fact key is longer than the 24-byte key field'
    stubs = sorted((a, nm[1]) for a, nm in h.stub2name.items())

    body = bytearray(b"JNH1" + struct.pack("<II", 1, len(REGIONS)))
    for name, base, size in REGIONS:
        rr = runs_of(region_bytes(base, size))
        body += struct.pack("<QQI", base, size, len(rr))
        for off, b in rr:
            body += struct.pack("<II", off, len(b)) + b
        log("region %-5s guest 0x%09x size 0x%08x: %d runs, %d bytes" % (name, base, size, len(rr), sum(len(b) for _, b in rr)))
    body += struct.pack("<I", len(facts))
    for k, v in facts.items():
        body += k.encode().ljust(24, b"\0")[:24] + struct.pack("<Q", v & 0xFFFFFFFFFFFFFFFF)
    body += struct.pack("<I", len(stubs))
    for a, nm in stubs:
        body += struct.pack("<QI", a, len(nm)) + nm.encode()
    body += struct.pack("<I", zlib.crc32(bytes(body)) & 0xFFFFFFFF)
    open(out, "wb").write(body)
    open(out + ".gz", "wb").write(gzip.compress(bytes(body), 9))
    log("wrote %s (%d bytes, sha256 %s) and .gz (%d bytes); %d facts, %d stubs"
        % (out, len(body), hashlib.sha256(body).hexdigest()[:16], os.path.getsize(out + ".gz"), len(facts), len(stubs)))

    def check(buf):
        regs, f2, s2 = parse(buf)
        bad = 0
        for (name, base, size), (b2, s2r, m2) in zip(REGIONS, regs):
            assert (b2, s2r) == (base, size), "region header %s" % name
            ref = region_bytes(base, size)
            prefix = base in (E.HEAP_BASE, H.W.COM)      # mapped with room: only the used prefix is stored, tail zero
            got = bytes(m2[:len(ref)]) if prefix else bytes(m2)
            tail = any(m2[len(ref):]) if prefix else False
            if ref != got or tail:
                bad += 1
                log("SELF-CHECK: region %s differs" % name)
        if f2 != facts:
            bad += 1
            log("SELF-CHECK: facts differ")
        if s2 != stubs:
            bad += 1
            log("SELF-CHECK: stubs differ")
        return bad

    buf = open(out, "rb").read()
    assert check(buf) == 0, "template self-check FAILED"
    log("SELF-CHECK: every region byte-identical to oracle memory, facts and stubs equal")
    t = bytearray(buf)
    k = len(t) // 2
    t[k] ^= 0x01
    try:
        check(bytes(t))
        bit = False
    except ValueError as e:
        bit = "crc: %s" % e
    t[-4:] = struct.pack("<I", zlib.crc32(bytes(t[:-4])) & 0xFFFFFFFF)
    try:
        bit2 = check(bytes(t)) > 0
    except Exception as e:
        bit2 = "parse: %s" % e
    assert bit and bit2, "TEMPLATE TOOTH DID NOT BITE (%r, %r)" % (bit, bit2)
    log("TOOTH bites: flipped byte %d -> %s; crc re-sealed -> compare fails (%s)" % (k, bit, bit2))


if __name__ == '__main__':
    main()

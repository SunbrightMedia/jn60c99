#!/usr/bin/env python3
"""jp8_full_emu.py -- ORACLE side (process A) of the JUPITER-8 full-chain gate (jp8_full_seq.py). For each patch: a fresh
jp8_emu.JP8() (drive2), its own static initializers, then CONTROL 0 -- the shipped template (jp8/gen/jp8_template.bin.gz)
must equal the oracle's post-static-init memory region by region (the template is DERIVED data: a stale one is RED).
Then the boot (FACTORY + BUILD at 0x1F80, FTZ, SETSR, host_init), the INIT HASH (sha256 of the image and of the heap up
to the bump pointer), the event list (recalls through HOSTPARAM, notes, renders = VOICE_WRAP x8 + MASTER_WRAP per sample,
jp8_lift_seq.py's call layout), every output word, the END HASH and the bump pointer. Nothing here computes a sample.
Writes <outdir>/p<NN>/{words.bin, meta.json} and, for the DEEP patches, heap_post.bin.
usage: jp8_full_emu.py <outdir> [template.bin.gz]"""
import sys, os, json, struct, time, hashlib, gzip, zlib
HERE = os.path.dirname(os.path.abspath(__file__)); REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE); sys.path.insert(0, os.path.join(REPO, "tools", "verify"))
import jp8_emu as J, jp8_full_seq as Q, jp8_lift_seq as L
t0 = time.time()
def log(m): print("[%6.1fs] %s" % (time.time() - t0, m), flush=True)
outdir = sys.argv[1]
tpath = sys.argv[2] if len(sys.argv) > 2 else os.path.join(REPO, "jp8", "gen", "jp8_template.bin.gz")
tm = gzip.decompress(open(tpath, "rb").read())

def parse(buf):
    """JP8T v1 -> ([(base, size, bytearray)], scalars) -- jp8_template_export.parse"""
    assert buf[:4] == b"JP8T" and struct.unpack_from("<I", buf, 4)[0] == 1, "template: not JP8T v1"
    assert zlib.crc32(buf[:-4]) & 0xFFFFFFFF == struct.unpack_from("<I", buf, len(buf) - 4)[0], "template: crc32"
    nreg = struct.unpack_from("<I", buf, 8)[0]; p = 12; regs = []
    for _ in range(nreg):
        base, size, nruns = struct.unpack_from("<QQI", buf, p); p += 20; mem = bytearray(size)
        for _ in range(nruns):
            off, ln = struct.unpack_from("<II", buf, p); p += 8; mem[off:off + ln] = buf[p:p + ln]; p += ln
        regs.append((base, size, mem))
    sc = struct.unpack_from("<QQQQQIIII", buf, p)
    return regs, dict(zip(("heap_ptr0", "heap_limit", "hc0", "rsp", "ret", "static_ok", "static_fail", "static_skipped", "faults"), sc))
regs, sc = parse(tm)

def memhash(jp):
    uc = jp.uc; h = hashlib.sha256()
    h.update(bytes(uc.mem_read(J.IB, J.IMGSZ))); h.update(bytes(uc.mem_read(Q.HEAP_BASE, jp.heap - Q.HEAP_BASE)))
    return h.hexdigest()

for patch in Q.PATCHES:
    d = os.path.join(outdir, "p%02d" % patch); os.makedirs(d, exist_ok=True)
    jp = J.JP8(); assert not jp.legacy, "the full-chain gate grades DRIVE2 only (D7)"
    uc = jp.uc
    ok, fail = jp.run_static_init(); assert fail == 0
    # CONTROL 0: the template the engine boots from == this oracle's post-static-init memory
    bad = []
    for base, size, mem in regs:
        if base == Q.HEAP_BASE: ref = bytes(uc.mem_read(base, jp.heap - base)); got = bytes(mem[:len(ref)]); tail = any(mem[len(ref):])
        elif base == 0: ref = bytes(uc.mem_read(0, 0x1000)); got = bytes(mem[:0x1000]); tail = any(mem[0x1000:])
        elif base in (J.BUF_BASE, J.STUB_BASE): ref = got = b""; tail = any(mem)
        else: ref = bytes(uc.mem_read(base, size)); got = bytes(mem); tail = False
        if ref != got or tail: bad.append("0x%x" % base)
    if (sc["heap_ptr0"], sc["hc0"], sc["static_ok"], sc["static_skipped"]) != (jp.heap, getattr(jp, "_hc", 0x9000), ok, jp.static_skipped):
        bad.append("scalars")
    if bad: sys.exit("CONTROL 0 RED: the template differs from the oracle's post-static-init memory in %s (re-export it: "
                     "jp8_template_export.py)" % ", ".join(bad))
    # the boot, the drive2 order
    jp.build(); jp.set_ftz(); jp.set_sr(Q.RATE)
    w, f = jp.host_init(); assert (w, f) == (3, 0), "host_init wrote %d, failed %d" % (w, f)
    init_hash = memhash(jp); heap_init = jp.heap
    uc.mem_write(L.A2, b"".join(struct.pack("<QQ", L.VOUT + 8 * v, L.VOUT + 8 * v + 4) for v in range(8)))
    words = bytearray(); nsamp = 0
    for ev in Q.events(patch):
        if ev[0] == "recall": jp.recall(ev[1])
        elif ev[0] == "on": jp.note_on(ev[1], ev[2])
        elif ev[0] == "off": jp.note_off(ev[1], ev[2])
        elif ev[0] == "render":
            for s in range(ev[1]):
                for v in range(8):
                    uc.mem_write(L.OUT_M, b"\0" * 8); uc.mem_write(L.PAIR_V, struct.pack("<QQ", L.OUT_M, L.OUT_S))
                    jp.call(J.VOICE_WRAP, rcx=jp.state[v], rdx=v, r8=L.PAIR_V)
                    mw = bytes(uc.mem_read(L.OUT_M, 8)); words += mw; uc.mem_write(L.VOUT + 8 * v, mw)
                uc.mem_write(L.OUT_L, b"\0" * 8); uc.mem_write(L.PAIR_M, struct.pack("<QQ", L.OUT_L, L.OUT_R))
                jp.call(J.MASTER_WRAP, rcx=jp.state[8], rdx=L.A2, r8=L.PAIR_M)
                words += bytes(uc.mem_read(L.OUT_L, 8)); nsamp += 1
        else: raise SystemExit("unknown event %r" % (ev,))
    end_hash = memhash(jp)
    stack_hash = hashlib.sha256(bytes(uc.mem_read(Q.STACK_BASE, Q.STACK_SIZE))).hexdigest()
    open(os.path.join(d, "words.bin.partial"), "wb").write(bytes(words)); os.replace(os.path.join(d, "words.bin.partial"), os.path.join(d, "words.bin"))
    if patch in Q.DEEP: open(os.path.join(d, "heap_post.bin"), "wb").write(bytes(uc.mem_read(Q.HEAP_BASE, jp.heap - Q.HEAP_BASE)))
    fl = struct.unpack("<%df" % (len(words) // 4), bytes(words))
    peak = max((abs(x) for i, x in enumerate(fl) if i % 18 >= 16 and x == x), default=0.0)
    nan = sum(1 for x in fl if x != x)
    meta = dict(patch=patch, rate=Q.RATE, drive="drive2", events=Q.events(patch), nsamp=nsamp, init_hash=init_hash,
                heap_init=heap_init, end_hash=end_hash, heap_end=jp.heap, stack_hash=stack_hash, host=jp.HOST, state=jp.state,
                static=[ok, fail, jp.static_skipped], faults=jp.faults, master_peak=peak, nan_words=nan)
    json.dump(meta, open(os.path.join(d, "meta.json"), "w"))
    log("patch %d @ %g: %d samples, %d words, master peak %.4f, NaN words %d, heap %.1f MB, init %s end %s" % (
        patch, Q.RATE, nsamp, len(words) // 4, peak, nan, (jp.heap - Q.HEAP_BASE) / 1e6, init_hash[:12], end_hash[:12]))

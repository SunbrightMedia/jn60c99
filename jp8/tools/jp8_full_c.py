#!/usr/bin/env python3
"""jp8_full_c.py -- C side (process B) of the JUPITER-8 full-chain gate: ctypes-loads an engine library (jp8_engine.c +
jp8_rt.c + a lifted source) and drives ONLY its API (jp8.h): jp8_init from the template, jp8_recall, jp8_note_on/off,
jp8_render_words. No unicorn here (two-process rule), no plugin logic (plumbing only).
  CONTROL 1  after jp8_init: sha256 of the image + the heap up to the bump pointer == the oracle's init hash.
  RUN A      the event list, each render event in one call: every output word, the end hash and the bump pointer EXACT.
  RUN B      a second jp8_init in the same process (the re-init path: CONTROL 1 again), the render events cut into seeded
             random chunks of 1..300 samples: every word and the end hash EXACT.
usage: jp8_full_c.py <refdir> <lib.so> [--template T.bin.gz] [--no-stack] [--runs AB] [--patches 2,63]
  --no-stack  the template's stack runs removed (crc re-sealed): TOOTH T4 (PORT_LESSONS 12), CONTROL 1 must bite.
exit 0 = EXACTLY 0 on every graded item."""
import sys, os, json, struct, ctypes, hashlib, gzip, zlib, random, time
HERE = os.path.dirname(os.path.abspath(__file__)); REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import jp8_full_seq as Q
t0 = time.time()
def log(m): print("[%6.1fs] %s" % (time.time() - t0, m), flush=True)
args = sys.argv[1:]
def opt(name, dflt):
    if name in args: i = args.index(name); v = args[i + 1]; del args[i:i + 2]; return v
    return dflt
tpath = opt("--template", os.path.join(REPO, "jp8", "gen", "jp8_template.bin.gz"))
runs = opt("--runs", "AB"); pl = opt("--patches", None)
nostack = "--no-stack" in args
if nostack: args.remove("--no-stack")
refdir, so = args[0], args[1]
patches = [int(x) for x in pl.split(",")] if pl else Q.PATCHES
tm = gzip.decompress(open(tpath, "rb").read())
if nostack:                      # TOOTH T4: the template without its stack residue
    b = bytearray(tm); nreg = struct.unpack_from("<I", b, 8)[0]; p = 12; out = bytearray(b[:12])
    for _ in range(nreg):
        base, size, nruns = struct.unpack_from("<QQI", b, p); p += 20; rr = []
        for _ in range(nruns):
            off, ln = struct.unpack_from("<II", b, p); rr.append(bytes(b[p:p + 8 + ln])); p += 8 + ln
        if base == Q.STACK_BASE: rr = []
        out += struct.pack("<QQI", base, size, len(rr)) + b"".join(rr)
    out += b[p:len(b) - 4]; out += struct.pack("<I", zlib.crc32(bytes(out)) & 0xFFFFFFFF); tm = bytes(out)
lib = ctypes.CDLL(os.path.abspath(so))
lib.jp8_init.argtypes = [ctypes.c_char_p, ctypes.c_size_t, ctypes.c_float]
lib.jp8_error.restype = ctypes.c_char_p
lib.jp8_guest.argtypes = [ctypes.c_uint64, ctypes.c_size_t]; lib.jp8_guest.restype = ctypes.c_void_p
for f in ("jp8_unit_state", "jp8_host_obj", "jp8_heap_top"): getattr(lib, f).restype = ctypes.c_uint64
lib.jp8_render_words.argtypes = [ctypes.c_void_p, ctypes.c_int]
IMGSZ = 0xDE7000
def region(base, n):
    p = lib.jp8_guest(base, n)
    if not p: raise SystemExit("jp8_guest(0x%x, %d) = NULL" % (base, n))
    return ctypes.string_at(p, n)
def memhash():
    h = hashlib.sha256(); h.update(region(Q.IMG_BASE, IMGSZ)); h.update(region(Q.HEAP_BASE, lib.jp8_heap_top() - Q.HEAP_BASE))
    return h.hexdigest()
def first_heap_diff(d, meta):
    """the first differing heap dword against a DEEP patch's end heap (where to look)"""
    f = os.path.join(d, "heap_post.bin")
    if not os.path.exists(f): return ""
    post = open(f, "rb").read(); mine = region(Q.HEAP_BASE, min(len(post), lib.jp8_heap_top() - Q.HEAP_BASE))
    for off in range(0, min(len(post), len(mine)), 4):
        if post[off:off + 4] != mine[off:off + 4]:
            a = Q.HEAP_BASE + off; where = "heap+0x%x" % off
            for u, st in enumerate(meta["state"]):
                if st <= a < st + 0xA9C0C0: where = "unit %d state+0x%x" % (u, a - st)
            return "; first differing heap dword at %s: oracle %s C %s" % (where, post[off:off + 4].hex(), mine[off:off + 4].hex())
    return ""
def drive(patch, chunks):
    """the event list through the API; chunks(n) -> the call sizes for one render event"""
    got = bytearray()
    for ev in Q.events(patch):
        if ev[0] == "recall": rc = lib.jp8_recall(ev[1])
        elif ev[0] == "on": rc = lib.jp8_note_on(ev[1], ev[2])
        elif ev[0] == "off": rc = lib.jp8_note_off(ev[1], ev[2])
        else:
            rc = 0
            for k in chunks(ev[1]):
                buf = (ctypes.c_uint32 * (18 * k))(); rc = lib.jp8_render_words(buf, k); got += bytes(buf)
                if rc: break
        if rc: return got, "event %r: rc %d %s" % (ev, rc, lib.jp8_error().decode())
    return got, None
bad_total = 0
for patch in patches:
    d = os.path.join(refdir, "p%02d" % patch); meta = json.load(open(os.path.join(d, "meta.json")))
    assert meta["drive"] == "drive2" and meta["rate"] == Q.RATE and meta["events"] == [list(e) for e in Q.events(patch)], \
        "reference %s is not this drive (rate %r)" % (d, meta["rate"])
    ref = open(os.path.join(d, "words.bin"), "rb").read()
    for run in runs:
        bad = 0; ts = time.time()
        rc = lib.jp8_init(tm, len(tm), ctypes.c_float(Q.RATE))
        if rc: log("patch %d run %s: jp8_init rc %d: %s -> FAIL" % (patch, run, rc, lib.jp8_error().decode())); bad_total += 1; continue
        ih = memhash()
        if ih != meta["init_hash"] or lib.jp8_heap_top() != meta["heap_init"]:
            bad += 1; log("patch %d run %s: CONTROL 1 differs: init hash C %s oracle %s, bump pointer C 0x%x oracle 0x%x" % (
                patch, run, ih[:16], meta["init_hash"][:16], lib.jp8_heap_top(), meta["heap_init"]))
        if run == "A": chunks = lambda n: [n]
        else:
            rnd = random.Random(1000 + patch)
            def chunks(n, rnd=rnd):
                out = []
                while n: k = min(n, rnd.randint(1, 300)); out.append(k); n -= k
                return out
        got, trap = drive(patch, chunks)
        if trap: bad += 1; log("patch %d run %s: %s after %d words" % (patch, run, trap, len(got) // 4))
        nw = min(len(ref), len(got)) // 4
        diffs = [i for i in range(nw) if ref[4 * i:4 * i + 4] != got[4 * i:4 * i + 4]]
        if len(ref) != len(got): bad += 1; log("patch %d run %s: %d words, oracle %d" % (patch, run, len(got) // 4, len(ref) // 4))
        if diffs:
            bad += len(diffs)
            for i in diffs[:4]:
                k = i % 18; who = "voice %d %s" % (k // 2, "main" if k % 2 == 0 else "sub") if k < 16 else ("L" if k == 16 else "R")
                log("patch %d run %s: word %d (sample %d, %s) oracle %08x C %08x" % (patch, run, i, i // 18, who,
                    struct.unpack("<I", ref[4 * i:4 * i + 4])[0], struct.unpack("<I", got[4 * i:4 * i + 4])[0]))
        eh = memhash()
        if eh != meta["end_hash"] or lib.jp8_heap_top() != meta["heap_end"]:
            bad += 1; log("patch %d run %s: END differs: hash C %s oracle %s, bump pointer C 0x%x oracle 0x%x%s" % (
                patch, run, eh[:16], meta["end_hash"][:16], lib.jp8_heap_top(), meta["heap_end"], first_heap_diff(d, meta)))
        sh = hashlib.sha256(region(Q.STACK_BASE, Q.STACK_SIZE)).hexdigest()
        log("patch %d run %s: %d words (%d differ), init %s, end %s, stack %s (reported) -> %s  [%.1fs]" % (
            patch, run, nw, len(diffs), "EXACT" if ih == meta["init_hash"] else "DIFFERS", "EXACT" if eh == meta["end_hash"] else "DIFFERS",
            "EXACT" if sh == meta["stack_hash"] else "differs", "PASS" if not bad else "FAIL", time.time() - ts))
        bad_total += bad
        lib.jp8_free()
print("JP8 FULL CHAIN (drive2, %g Hz, runs %s): %s" % (Q.RATE, runs, "EXACTLY 0 -- every word, init and end hash on patches %s" % patches
      if not bad_total else "%d differences -- NOT bit-exact" % bad_total))
sys.exit(0 if not bad_total else 1)

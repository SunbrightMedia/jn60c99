"""ADVERSARIAL probe (scratch, process A only): does the oracle's ZERO-FILLED HOST (no CWaveGen ctor 0x444000,
which writes HOST+8 = 96000.0 via base ctor 0x36c890) cause the NaN/inf boot ramps (report C F1b)?
variants: zero (as jp8_emu), poke (HOST+8 := 96000.0 only), ctor (real ctor 0x444000 on the zeroed HOST)."""
import sys, os, struct, time, math
sys.path.insert(0, "/home/user/jn60c99/jp8/tools"); sys.path.insert(0, "/home/user/jn60c99/tools/verify")
os.environ["JP8_EMU_QUIET"] = "1"
import jp8_emu as J
var = sys.argv[1]; patch = int(sys.argv[2]) if len(sys.argv) > 2 else 2
t0 = time.time()
def log(m): print("[%5.1fs] %s: %s" % (time.time() - t0, var, m), flush=True)
jp = J.JP8(); ok, fail = jp.run_static_init(); uc = jp.uc
log("static init ok %d fail %d faults %d" % (ok, fail, jp.faults))
HOST = jp.bump(0x8000); uc.mem_write(HOST, b"\0" * 0x8000)
if var == "poke": uc.mem_write(HOST + 8, struct.pack("<f", 96000.0))
if var == "ctor":
    na = len(jp.allocs); jp.call(J.IB + 0x444000, rcx=HOST, count=50_000_000)
    log("real ctor ran: allocs %d, HOST+8 = %r, vptr 0x%x, faults %d" % (len(jp.allocs) - na, struct.unpack("<f", uc.mem_read(HOST + 8, 4))[0], int.from_bytes(uc.mem_read(HOST, 8), 'little') - J.IB, jp.faults))
# build() without re-bumping HOST (copy of jp8_emu.JX.build's body)
jp.HOST = HOST; jp.call(J.BUILD, rcx=HOST)
jp.state = [int.from_bytes(uc.mem_read(HOST + 0xA0 + 64 * i, 8), 'little') for i in range(9)]
jp.proc = [int.from_bytes(uc.mem_read(HOST + 0xB0 + 64 * i, 8), 'little') for i in range(9)]
jp.assign = [int.from_bytes(uc.mem_read(HOST + 0xB8 + 64 * i, 8), 'little') for i in range(9)]
def rq(a): return int.from_bytes(uc.mem_read(a, 8), 'little')
def census(tag):
    tot = [0, 0, 0, 0]
    for u in range(9):
        st = jp.state[u]; arr = rq(st + 0x58); b0 = rq(st + 0x70); e0 = rq(st + 0x78)
        ids = struct.unpack("<%di" % ((e0 - b0) // 4), uc.mem_read(b0, e0 - b0)) if e0 > b0 else ()
        for i in ids:
            a = arr + 40 * i; step, acc = struct.unpack("<ff", uc.mem_read(a + 8, 8))
            tot[0] += 1; tot[1] += math.isnan(step); tot[2] += math.isinf(step); tot[3] += math.isnan(acc)
    log("%-12s live ramps %d, step NaN %d, step inf %d, acc NaN %d; state+0x10 rate %r" % (tag, tot[0], tot[1], tot[2], tot[3], struct.unpack("<f", uc.mem_read(jp.state[0] + 0x10, 4))[0]))
census("after BUILD")
jp.set_ftz(); jp.set_sr(44100.0); census("after SETSR")
w, f = jp.host_init(); census("after hinit")
if var == "snapT1": jp.snap_ramps(); census("after snap"); log("host_init %d/%d" % (w, f))
jp.recall(patch); census("after recall")
dry, L, R = jp.render_both(4096)
def fw(x): return struct.unpack("<f", struct.pack("<I", x))[0]
for a, b in ((0, 960), (960, 2048), (2048, 4096)):
    ml = max(abs(fw(x)) for x in L[a:b] + R[a:b]); dm = max(abs(x) for x in dry[a:b])
    log("samples %4d..%4d: master peak %.6g dry peak %.6g" % (a, b, ml, dm))
log("dry NaN %d, faults %d" % (jp.dry_nan, jp.faults)); census("after 4096")
import hashlib
jp.note_on(60, 100); d1, L1, R1 = jp.render_both(3000); jp.note_on(64, 100); d2, L2, R2 = jp.render_both(1000)
jp.note_off(60, 64); jp.note_off(64, 64); d3, L3, R3 = jp.render_both(3000)
W = struct.pack("<%dI" % (2 * (len(L) + len(L1) + len(L2) + len(L3))), *(L + L1 + L2 + L3 + R + R1 + R2 + R3))
D = struct.pack("<%df" % (len(dry) + len(d1) + len(d2) + len(d3)), *(dry + d1 + d2 + d3))
open("words_%s_p%d.bin" % (var, patch), "wb").write(W); open("dry_%s_p%d.bin" % (var, patch), "wb").write(D)
log("note drive: master sha %s dry sha %s, note master peak %.4g dry peak %.4g" % (hashlib.sha256(W).hexdigest()[:16], hashlib.sha256(D).hexdigest()[:16], max(abs(fw(x)) for x in L1), max(abs(x) for x in d1)))
open("heap_%s_p%d.bin" % (var, patch), "wb").write(bytes(uc.mem_read(J.HEAP_BASE, jp.heap - J.HEAP_BASE)))
open("state_%s_p%d.txt" % (var, patch), "w").write(" ".join("%x" % s for s in jp.state) + "\n")

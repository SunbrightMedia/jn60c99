#!/usr/bin/env python3
"""jp8_drive2_probe.py -- D7 evidence for the DRIVE2 oracle boot (jp8_emu default since 2026-09-22).
Process A only (Unicorn). Every subcommand prints labelled lines; logs go to jp8/logs/drive2/.
  boot P [SR]    drive2 boot of patch P: census after every stage (ramps NaN/inf live + all records, latch,
                 host_map size), the host map READ from static init 0xAD320 vs the EXECUTED walk, idle 4096
                 (dry/master peaks, NaN), census + live ramps after the walker settles (no snap)
  tooth          the census detector SEEN TO FAIL: (a) legacy zero HOST, (b) factory HOST with [HOST+8] := 0
                 poked before BUILD (the skeptic's HOST tooth); both must report live NaN/inf > 0
  recall P       HOSTPARAM recall (drive2) vs the old DISPATCH-flag-0 recall on the SAME constructed boot:
                 heap dwords that differ after the recall and after a multi-note drive, output words that
                 differ, LFO KEY TRIG bytes, reads of the LFO KEY TRIG bytes (hook seen to fire on the setter)
  sr P           SETSR 96000 / 44100 / 48000 on drive2: instructions SETSR executed (early return), state
                 rate + ratio cell +0x8B0, key 60 DRY f0 vs the engine pitch cells; order law tooth
  hinit P        host_init HOSTINIT_IDS (drive2) vs every mapped id (old law): writes, heap dwords, words"""
import sys, os, struct, time, math, hashlib, gc
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE); sys.path.insert(0, "/home/user/jn60c99/tools/verify"); sys.path.insert(0, "/home/user/jn60c99/jx3p/tools")
os.environ.setdefault("JP8_EMU_QUIET", "1")
import numpy as np
import jp8_emu as J, audio_metrics as AM
from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_READ
t0 = time.time()
def log(m): print("[%6.1fs] %s" % (time.time() - t0, m), flush=True)
def fw(x): return struct.unpack("<f", struct.pack("<I", x))[0]
def rq(uc, a): return int.from_bytes(uc.mem_read(a, 8), 'little')
def cen_line(tag, c, hm):
    if not c: log("CENSUS %-14s host_map %d" % (tag, hm)); return
    log("CENSUS %-14s live %d (step NaN %d inf %d, acc bad %d) | all %d records (step NaN %d inf %d, acc bad %d) | latch sum %d | state+0x10 %r | host_map %d" % (
        tag, c["live"], c["live_step_nan"], c["live_step_inf"], c["live_acc_bad"], c["records"], c["all_step_nan"], c["all_step_inf"], c["all_acc_bad"], c["latch_sum"], c["rate0"], hm))

def static_map_read():
    """READ: the (host id, engine id) pairs static init 0xAD320 stores at [rbp+0x1670, rbp+0x2db0) before 0x443dd0"""
    import capstone
    md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_64); md.detail = True
    mem = {}
    for ins in md.disasm(bytes(J.IMG[0xAD320:0xB46F2]), 0xAD320):
        if ins.mnemonic == "mov" and "dword ptr [rbp +" in ins.op_str:
            o = ins.operands
            if o[1].type == capstone.x86.X86_OP_IMM: mem[o[0].mem.disp] = o[1].imm & 0xFFFFFFFF
            elif o[1].type == capstone.x86.X86_OP_REG: mem[o[0].mem.disp] = 0   # 0xad358: mov [rbp+0x1670], eax (eax = 0)
    pairs = [(mem.get(d), mem.get(d + 4)) for d in range(0x1670, 0x2DB0, 8)]
    return {k: v for k, v in pairs}

def drive_multi(jp):
    """multi-note drive with LFO time between notes (LFO KEY TRIG matters on the 2nd..4th note-on)"""
    ev = [("r", 2048), ("on", 60), ("r", 3000), ("on", 64), ("r", 3000), ("on", 67), ("r", 3000), ("off", 60), ("r", 1500),
          ("on", 72), ("r", 3000), ("off", 64), ("off", 67), ("off", 72), ("r", 3000)]
    L = []; R = []; D = []; nan = 0
    for k, a in ev:
        if k == "r": d, l, r = jp.render_both(a); L += l; R += r; D += d; nan += jp.dry_nan
        elif k == "on": jp.note_on(a, 100)
        else: jp.note_off(a, 64)
    return L, R, D, nan

def heap(jp): return np.frombuffer(bytes(jp.uc.mem_read(J.HEAP_BASE, jp.heap - J.HEAP_BASE)), dtype=np.uint32)

def cmd_boot(patch, sr):
    jp = J.JP8(); assert not jp.legacy
    jp.boot(sr=sr, patch=patch, census=cen_line); uc = jp.uc
    log("HOST 0x%x via FACTORY 0x444FE0: %d allocations (1 x 0x%X HOST + %d ctor), vptr rva 0x%x, [HOST+8] %r, [HOST+0x38] %d; static init ok %d fail %d; host_init writes %d" % (
        jp.HOST, jp.host_allocs, J.HOST_SZ, jp.host_allocs - 1, rq(uc, jp.HOST) - J.IB, struct.unpack("<f", uc.mem_read(jp.HOST + 8, 4))[0],
        struct.unpack("<i", uc.mem_read(jp.HOST + 0x38, 4))[0], jp.static_ok[0], jp.static_ok[1], jp.hostinit_writes))
    hm = jp.host_map(); sm = static_map_read()
    log("HOST MAP executed %d entries, READ from 0xAD320 %d pairs, identical %s; pools covered %d/64 (host ids 0x%x..0x%x)" % (
        len(hm), len(sm), hm == sm, sum(1 for p in J.ACTIVE_POOLS if (J.POOL_BASE_ID + p) in hm.values()),
        jp.host_id(J.POOL_BASE_ID + J.ACTIVE_POOLS[0]), jp.host_id(J.POOL_BASE_ID + J.ACTIVE_POOLS[-1])))
    dry, Lw, Rw = jp.render_both(4096); L, nanL = AM.words_to_floats(Lw)
    for a, b in ((0, 960), (960, 2048), (2048, 4096)):
        log("idle %4d..%4d: dry peak %.3g master peak %.3g" % (a, b, max(abs(x) for x in dry[a:b]), float(np.abs(L[a:b]).max())))
    log("idle NaN: dry %d master %d; faults in static init %d, after it %d" % (jp.dry_nan, nanL, jp.faults_static, jp.faults - jp.faults_static))
    cen_line("after 4096", jp.ramp_census(), len(hm))
    ok = jp.faults == jp.faults_static and jp.ramp_census()["live_bad"] == 0 and jp.dry_nan == 0 and nanL == 0 and max(abs(x) for x in dry) < 0.01 and float(np.abs(L).max()) < 0.01
    log("DRIVE2 BOOT patch %d sr %g: %s" % (patch, sr, "GREEN" if ok else "FAIL"))
    return 0 if ok else 1

def cmd_tooth():
    bites = 0
    jp = J.JP8(legacy=True); jp.run_static_init(); jp.build()
    c = jp.ramp_census(); cen_line("LEGACY BUILD", c, len(jp.host_map()))
    log("TOOTH (a) legacy zero HOST: live bad %d -> %s" % (c["live_bad"], "BITES" if c["live_bad"] else "DOES NOT BITE"))
    bites += c["live_bad"] > 0
    del jp; gc.collect()
    jp = J.JP8(); jp.run_static_init(); h = jp.make_host(); jp.uc.mem_write(h + 8, struct.pack("<f", 0.0))
    jp.HOST = h; jp.call(J.BUILD, rcx=h)
    jp.state = [rq(jp.uc, h + 0xA0 + 64 * i) for i in range(9)]
    c = jp.ramp_census(); cen_line("POKED BUILD", c, len(jp.host_map()))
    log("TOOTH (b) factory HOST, [HOST+8] := 0 before BUILD: live bad %d -> %s" % (c["live_bad"], "BITES" if c["live_bad"] else "DOES NOT BITE"))
    bites += c["live_bad"] > 0
    log("CENSUS TEETH: %d/2 bite" % bites)
    return 0 if bites == 2 else 1

def lfokt(jp):
    uc = jp.uc; out = []
    for u in range(9):
        o = rq(uc, jp.HOST + 0xD8 + 64 * u); s = rq(uc, o + 0x18)
        out.append((s, uc.mem_read(s + 0xC, 1)[0], uc.mem_read(s + 0xB, 1)[0]))
    return out

def cmd_recall(patch):
    res = {}
    for path in ("hostparam", "dispatch"):
        jp = J.JP8(); jp.boot(sr=44100.0, patch=None); uc = jp.uc
        kt = lfokt(jp); reads = {"recall": 0, "drive": 0}; phase = ["recall"]; pcs = {"recall": {}, "drive": {}}
        def hk(uc_, acc, addr, size, val, user):
            reads[phase[0]] += 1; k = (uc_.reg_read(J.UC_X86_REG_RIP) - J.IB, (addr & 0xF)); pcs[phase[0]][k] = pcs[phase[0]].get(k, 0) + 1
        uc.ctl_flush_tb(); hh = [uc.hook_add(UC_HOOK_MEM_READ, hk, begin=s + 0xB, end=s + 0xC) for s, _, _ in kt]
        jp.recall(patch, path=path)
        kt1 = lfokt(jp); h1 = heap(jp).copy()
        phase[0] = "drive"
        L, R, D, nan = drive_multi(jp)
        for x in hh: uc.hook_del(x)
        uc.ctl_flush_tb()
        h2 = heap(jp).copy()
        log("%-9s patch %d: LFO KEY TRIG (mode,dirty) unit0 %s after recall; reads of those bytes: recall %d, drive %d; drive NaN %d; master sha %s" % (
            path, patch, kt1[0][1:], reads["recall"], reads["drive"], nan, hashlib.sha256(struct.pack("<%dI" % (2 * len(L)), *(L + R))).hexdigest()[:16]))
        log("  reader pcs (rva, byte +0xB/+0xC) -> count: recall %s | drive %s; (mode,dirty) unit0 after drive %s" % (
            {"0x%x/+0x%X" % k: n for k, n in sorted(pcs["recall"].items())}, {"0x%x/+0x%X" % k: n for k, n in sorted(pcs["drive"].items())}, lfokt(jp)[0][1:]))
        res[path] = (h1, h2, np.array(L + R, dtype=np.uint32), np.array(D, dtype=np.float32), kt1)
        del jp, uc; gc.collect()
    a, b = res["hostparam"], res["dispatch"]
    for tag, x, y in (("after recall", a[0], b[0]), ("after drive", a[1], b[1])):
        n = min(len(x), len(y)); d = np.nonzero(x[:n] != y[:n])[0]
        log("HEAP %s: %d dwords differ (of %d)%s" % (tag, len(d), n, "; first at heap+0x%x" % (4 * d[0]) if len(d) else ""))
        if len(d) and tag == "after recall":
            ktaddrs = set()
            for s, _, _ in a[4]: ktaddrs.add((s + 0xB - J.HEAP_BASE) // 4); ktaddrs.add((s + 0xC - J.HEAP_BASE) // 4)
            log("  of which in the LFO KEY TRIG dwords: %d; others: %s" % (sum(1 for i in d if i in ktaddrs), ["heap+0x%x" % (4 * i) for i in d if i not in ktaddrs][:12]))
    dw = np.nonzero(a[2] != b[2])[0]; dd = np.nonzero(a[3] != b[3])[0]
    first = int(dw[0]) % (len(a[2]) // 2) if len(dw) else -1
    mx = max((abs(fw(int(a[2][i])) - fw(int(b[2][i]))) for i in dw), default=0.0)
    log("OUTPUT master words differ %d of %d (first at sample %d, max |diff| %.3g); dry samples differ %d of %d" % (len(dw), len(a[2]), first, mx, len(dd), len(a[3])))
    log("RECALL COMPARE patch %d done" % patch)
    return 0

def cmd_ktflag(patch):
    """who reads the key-trigger FLAG byte [s+8] the note-on (0x44205d) sets from the mode byte, on the stub drive"""
    jp = J.JP8(); jp.boot(sr=44100.0, patch=patch); uc = jp.uc; kt = lfokt(jp); pcs = {}
    def hk(uc_, acc, addr, size, val, user):
        k = uc_.reg_read(J.UC_X86_REG_RIP) - J.IB; pcs[k] = pcs.get(k, 0) + 1
    uc.ctl_flush_tb(); hh = [uc.hook_add(UC_HOOK_MEM_READ, hk, begin=s + 8, end=s + 8) for s, _, _ in kt]
    L, R, D, nan = drive_multi(jp)
    for x in hh: uc.hook_del(x)
    uc.ctl_flush_tb()
    log("KT FLAG patch %d: (mode,dirty) unit0 before drive %s, flag byte [s+8] unit0 after drive %d; readers of [s+8] during the drive (rva -> count): %s" % (
        patch, kt[0][1:], uc.mem_read(kt[0][0] + 8, 1)[0], {"0x%x" % k: n for k, n in sorted(pcs.items())}))
    return 0

def cmd_hwrites(patch):
    """drive2 boot + recall P, then every OTHER mapped id's old-law default pushed through HOSTPARAM one at a time:
    heap bytes each write CHANGES (write hook, old value != new value) -- which non-drive params move the engine"""
    import pe_recon
    from unicorn import UC_HOOK_MEM_WRITE
    jp = J.JP8(); jp.boot(sr=44100.0, patch=patch); uc = jp.uc
    rows = pe_recon.PE(J.BIN).params(list(range(5223)))["rows"]; hm = jp.host_map()
    ch = [0]; lo = J.HEAP_BASE; hi = jp.heap
    def hk(uc_, acc, addr, size, val, user):
        if lo <= addr < hi and int.from_bytes(uc_.mem_read(addr, size), 'little') != (val & ((1 << (8 * size)) - 1)): ch[0] += size
    uc.ctl_flush_tb(); h = uc.hook_add(UC_HOOK_MEM_WRITE, hk)
    out = []
    for hid, eng in sorted(hm.items()):
        if hid in J.HOSTINIT_IDS or 750 <= eng <= 813: continue
        r = rows.get(eng)
        if not r or not r["name"] or r["name"] == "_reserve_" or 433 <= eng < 485 or r["min"] == r["max"] == r["default"] == 0: continue
        ch[0] = 0; jp.call(J.HOSTPARAM, rcx=jp.HOST, rdx=hid, r8=r["default"] - r["min"], count=J.HP_CAP)
        if ch[0]: out.append((eng, r["name"], r["default"], r["min"], ch[0]))
    uc.hook_del(h); uc.ctl_flush_tb()
    log("HWRITES patch %d: %d of the old-law default writes change heap bytes:" % (patch, len(out)))
    for e in out: log("  eng %d %-28s default %d (min %d) -> %d heap bytes changed" % e)
    return 0

def cmd_ab(patch):
    """END-TO-END A/B of the two oracle drives on the multi-note drive: LEGACY (zero HOST, DISPATCH-flag-0 recall, snap +
    latch clear) vs DRIVE2 (factory HOST, HOSTPARAM recall, no snap); master words + dry samples that differ"""
    out = {}
    for lab in ("legacy", "drive2"):
        jp = J.JP8(legacy=(lab == "legacy"))
        if lab == "legacy":
            jp.run_static_init(); jp.build(); jp.set_ftz(); jp.set_sr(44100.0); jp.host_init(); jp.recall(patch); jp.snap_ramps(); jp.clear_latch()
        else:
            jp.boot(sr=44100.0, patch=patch)
        L, R, D, nan = drive_multi(jp)
        out[lab] = (np.array(L + R, dtype=np.uint32), np.array(D, dtype=np.float32))
        log("%-7s patch %d: master sha %s, dry NaN %d, faults %d" % (lab, patch, hashlib.sha256(out[lab][0].tobytes()).hexdigest()[:16], nan, jp.faults))
        del jp; gc.collect()
    a, b = out["legacy"], out["drive2"]; dw = np.nonzero(a[0] != b[0])[0]; dd = np.nonzero(a[1] != b[1])[0]; n = len(a[0]) // 2
    mx = max((abs(fw(int(a[0][i])) - fw(int(b[0][i]))) for i in dw), default=0.0)
    log("AB patch %d: master words differ %d of %d (first at sample %s, max |diff| %.3g); dry samples differ %d of %d (first at %s)" % (
        patch, len(dw), len(a[0]), int(dw[0]) % n if len(dw) else "-", mx, len(dd), len(a[1]), int(dd[0]) if len(dd) else "-"))
    return 0

def cmd_sr(patch):
    rows = []
    for sr in (96000.0, 44100.0, 48000.0):
        jp = J.JP8(); jp.run_static_init(); jp.build(); jp.set_ftz(); uc = jp.uc
        c = [0]
        def h(uc_, a, s, u): c[0] += 1
        uc.ctl_flush_tb(); hh = uc.hook_add(UC_HOOK_CODE, h, begin=J.IB + 0x4464F0, end=J.IB + 0x4467B6)
        jp.set_sr(sr); uc.hook_del(hh); uc.ctl_flush_tb()
        n_setsr = c[0]
        jp.host_init(); jp.recall(patch)
        try: jp.set_sr(44100.0); refused = False
        except RuntimeError: refused = True
        rate = struct.unpack("<f", uc.mem_read(jp.state[0] + 0x10, 4))[0]; ratio = struct.unpack("<f", uc.mem_read(jp.state[0] + 0x8B0, 4))[0]
        jp.render_both(4096); jp.note_on(60, 100); jp.render_both(1024)
        cells = struct.unpack("<ff", uc.mem_read(jp.state[0] + 0x16E0, 4) + uc.mem_read(jp.state[0] + 0x16F0, 4))
        d, Lw, Rw = jp.render_both(16384); d = np.array(d)
        f0 = AM.f0_autocorr(d, sr); hm = AM.harmonicity(d, sr, f0) if f0 > 0 else 0
        exp = [AM.midi_hz(60) * 2 ** (x - 2.0) for x in cells]
        log("SETSR(%g): SETSR ran %d instructions in its own body (%s); state+0x10 %r, ratio +0x8B0 %r; set_sr after recall %s; key 60 DRY f0 %.2f Hz (%+.0f c vs key) harmonic %.3f | engine cells VCO1 %.2f VCO2 %.2f Hz | NaN %d" % (
            sr, n_setsr, "EARLY RETURN" if n_setsr < 30 else "full", rate, ratio, "REFUSED" if refused else "ALLOWED (defect)", f0,
            1200 * math.log2(f0 / AM.midi_hz(60)) if f0 > 0 else float('nan'), hm, exp[0], exp[1], jp.dry_nan))
        rows.append((sr, f0)); del jp, uc; gc.collect()
    log("SR SUMMARY patch %d key 60: %s" % (patch, ", ".join("%g -> %.2f Hz" % r for r in rows)))
    return 0

def cmd_hinit(patch):
    res = {}
    for ids in (None, "all"):
        jp = J.JP8(); jp.run_static_init(); jp.build(); jp.set_ftz(); jp.set_sr(44100.0)
        w, f = jp.host_init(ids=ids); h1 = heap(jp).copy()
        jp.recall(patch); jp.render_both(4096); jp.note_on(60, 100); d, L, R = jp.render_both(4096); jp.note_off(60, 64); d2, L2, R2 = jp.render_both(4096)
        log("host_init ids=%s: writes %d failed %d; census %s" % ("HOSTINIT_IDS" if ids is None else ids, w, f, {k: v for k, v in jp.ramp_census().items() if k in ("live", "live_bad", "all_bad")}))
        res[ids] = (h1, np.array(L + L2 + R + R2, dtype=np.uint32)); del jp; gc.collect()
    a, b = res[None], res["all"]; n = min(len(a[0]), len(b[0]))
    log("HINIT heap dwords differ after host_init: %d; master words differ over note drive: %d of %d" % (int(np.count_nonzero(a[0][:n] != b[0][:n])), int(np.count_nonzero(a[1] != b[1])), len(a[1])))
    return 0

if __name__ == "__main__":
    c = sys.argv[1]
    if c == "boot": sys.exit(cmd_boot(int(sys.argv[2]), float(sys.argv[3]) if len(sys.argv) > 3 else 44100.0))
    if c == "tooth": sys.exit(cmd_tooth())
    if c == "recall": sys.exit(cmd_recall(int(sys.argv[2])))
    if c == "sr": sys.exit(cmd_sr(int(sys.argv[2])))
    if c == "hwrites": sys.exit(cmd_hwrites(int(sys.argv[2])))
    if c == "ab": sys.exit(cmd_ab(int(sys.argv[2])))
    if c == "ktflag": sys.exit(cmd_ktflag(int(sys.argv[2])))
    if c == "hinit": sys.exit(cmd_hinit(int(sys.argv[2])))
    sys.exit(__doc__)

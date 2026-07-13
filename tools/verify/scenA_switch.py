#!/usr/bin/env python3
"""Scenario A — patch->patch switching with tails (cold start, bit-exact A/B).

Sequence (both sides, sr=48000, chorus=0 on port):
  cold-load P1 -> note_on(60,105) -> render 6000 -> note_off(60) -> render 6000
  -> recall/apply P2 -> note_on(64,100) -> render 12000
Plugin recall path (validated): snap_all -> recall_patch -> snap_all -> clear_latch
(done for BOTH recalls); set_ftz once after the first recall (persists in MXCSR).

Usage: scenA_switch.py P1 P2 [outprefix]
"""
import sys, struct, ctypes, math, os
sys.path.insert(0, '/home/user/jn60c99/scratchpad/oracle')
import numpy as np
import e2e_emu as E

P1 = int(sys.argv[1]); P2 = int(sys.argv[2])
PREFIX = sys.argv[3] if len(sys.argv) > 3 else f"/tmp/claude-0/-home-user-jn60c99/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/scratchpad/scenA_{P1}_{P2}"
SR = 48000
SEG = [6000, 6000, 12000]   # after note_on P1 / after note_off / after P2+note_on
NTOT = sum(SEG)

# ---------------- plugin side (Unicorn) ----------------
def run_plugin():
    e = E.E2E(); e.build(SR)
    leaves = E.load_leaves(); bank = E.bank_bytes()
    # cold recall P1 (canonical validated path)
    e.snap_all()
    errs1 = E.recall_patch(e, P1, leaves, bank)
    e.snap_all(); e.clear_latch(); e.set_ftz()
    e.note_on(60, 105)
    L1, R1 = e.render(SEG[0])
    e.note_off(60)                        # vel=64 default, same as validated harness
    L2, R2 = e.render(SEG[1])
    # patch switch: same validated recall path
    e.snap_all()
    errs2 = E.recall_patch(e, P2, leaves, bank)
    e.snap_all(); e.clear_latch()
    e.note_on(64, 100)
    L3, R3 = e.render(SEG[2])
    L = L1 + L2 + L3; R = R1 + R2 + R3
    return L, R, errs1, errs2

# ---------------- port side (native) ----------------
def run_port():
    lib = ctypes.CDLL("/home/user/jn60c99/libjuno.so")
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_note_off.argtypes = [ctypes.c_void_p, ctypes.c_int]
    lib.juno_gui_render.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int]
    lib.juno_gui_render.restype = ctypes.c_int
    bank = open(E.BANK, 'rb').read()
    c = lib.juno_gui_create(ctypes.c_float(float(SR)), 0)
    lib.juno_gui_apply_bank(c, bank, len(bank), P1)
    lib.juno_gui_note_on(c, 60, 105)
    def rend(n):
        buf = (ctypes.c_float * (2 * n))()
        lib.juno_gui_render(c, buf, n)
        u = struct.unpack("<%dI" % (2 * n), bytes(buf))
        return list(u[0::2]), list(u[1::2])
    L1, R1 = rend(SEG[0])
    lib.juno_gui_note_off(c, 60)
    L2, R2 = rend(SEG[1])
    lib.juno_gui_apply_bank(c, bank, len(bank), P2)
    lib.juno_gui_note_on(c, 64, 100)
    L3, R3 = rend(SEG[2])
    return L1 + L2 + L3, R1 + R2 + R3

def f32(u):
    return struct.unpack("<f", struct.pack("<I", u))[0]

def rms(vals):
    s = 0.0; n = 0
    for u in vals:
        v = f32(u)
        if math.isfinite(v): s += v * v; n += 1
    return math.sqrt(s / n) if n else float('nan')

if __name__ == "__main__":
    bank = E.bank_bytes()
    print("== Scenario A: P1=%d (%s) -> P2=%d (%s)  sr=%d ==" % (
        P1, E.patch_name(bank, P1), P2, E.patch_name(bank, P2), SR), flush=True)
    Lb, Rb = run_port()
    print("port done (%d frames)" % len(Lb), flush=True)
    La, Ra, e1, e2 = run_plugin()
    print("plugin done (%d frames) recall_errs=%d/%d" % (len(La), e1, e2), flush=True)

    np.save(PREFIX + "_plugin.npy", np.array([La, Ra], dtype=np.uint32))
    np.save(PREFIX + "_port.npy",   np.array([Lb, Rb], dtype=np.uint32))

    A = np.array([La, Ra], dtype=np.uint32)
    B = np.array([Lb, Rb], dtype=np.uint32)
    d = (A != B)
    total = int(d.sum())
    frames_bad = np.where(d.any(axis=0))[0]
    print("TOTAL frames=%d  channelsamples=%d  mismatched u32=%d" % (NTOT, 2 * NTOT, total))
    # per-segment breakdown
    edges = [0, SEG[0], SEG[0] + SEG[1], NTOT]
    names = ["seg1 noteOn P1", "seg2 release tail", "seg3 P2 switch+note"]
    for k in range(3):
        seg = d[:, edges[k]:edges[k + 1]]
        print("  %-20s frames %5d..%5d  mismatches=%d" % (names[k], edges[k], edges[k + 1] - 1, int(seg.sum())))
    if total == 0:
        print("VERDICT: BIT-IDENTICAL over %d frames (both channels)." % NTOT)
    else:
        i = int(frames_bad[0])
        print("FIRST DIVERGENT frame = %d (segment: %s)" % (
            i, names[0] if i < edges[1] else names[1] if i < edges[2] else names[2]))
        print("  plugin L=%08x (%.9g)  port L=%08x (%.9g)" % (La[i], f32(La[i]), Lb[i], f32(Lb[i])))
        print("  plugin R=%08x (%.9g)  port R=%08x (%.9g)" % (Ra[i], f32(Ra[i]), Rb[i], f32(Rb[i])))
        lo = max(0, i - 64); hi = min(NTOT, i + 64)
        print("  RMS around it [%d..%d): plugin L=%.6g R=%.6g | port L=%.6g R=%.6g" % (
            lo, hi, rms(La[lo:hi]), rms(Ra[lo:hi]), rms(Lb[lo:hi]), rms(Rb[lo:hi])))
        print("  divergent frames: count=%d  first=%d  last=%d" % (
            len(frames_bad), int(frames_bad[0]), int(frames_bad[-1])))

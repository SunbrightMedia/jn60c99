#!/usr/bin/env python3
"""fork_vs_port_ab.py -- FORK (lever OFF) vs PORT vs .vst3, no-regression check.

The port is bit-exact to the .vst3 under emulation (make verify, residual
EXACTLY 0), so comparing the fork to the PORT is the same as comparing it to the
plugin -- and it needs no emulation, so it is immediate.

Renders, per patch, a single held note (note 60, vel 105) at 48 kHz:
  port_pN.wav   src/ via libjuno.so                    == the .vst3
  fork_pN.wav   engine B at the SHIPPING FORK flags, EB_REVERB_HALF OFF
The fork is a deliberate sonic trade (EB_DCO_WT, half-OS VCF, control-rate) --
NOT bit-exact -- so a small dB difference is expected and bounded by
sonic_gate.py. This tool reports that difference and writes both WAVs, so a
regression (a NEW, larger difference) is visible against the accepted trade.
Same gain on both sides. NOT A GATE.
"""
import os, sys, tempfile, wave
import numpy as np
import ctypes

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(REPO, "tools", "trackb"))
sys.path.insert(0, os.path.join(REPO, "tools", "verify"))
import truth
import ab_wavs

SR, NOTE, VEL, N = 48000.0, 60, 105, 16000
PATCHES = [2, 5, 21, 11]


def w24(path, x, g):
    y = np.clip(x * g, -1.0, 1.0)
    q = np.round(y * 8388607.0).astype(np.int32)
    b = bytearray()
    for v in q:
        v = int(v) & 0xFFFFFF
        b += bytes((v & 0xFF, (v >> 8) & 0xFF, (v >> 16) & 0xFF))
    w = wave.open(path, "wb")
    w.setnchannels(1); w.setsampwidth(3); w.setframerate(int(SR))
    w.writeframes(bytes(b)); w.close()


def port_render(idx, bank):
    lib = ctypes.CDLL(os.path.join(REPO, "libjuno.so"))
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_render.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int]
    c = lib.juno_gui_create(ctypes.c_float(SR), 0)
    lib.juno_gui_apply_bank(c, bank, len(bank), idx)
    lib.juno_gui_note_on(c, NOTE, VEL)
    buf = (ctypes.c_float * (2 * N))(); lib.juno_gui_render(c, buf, N)
    a = np.frombuffer(buf, np.float32)
    return a[0::2].astype(np.float64), a[1::2].astype(np.float64)


def main():
    outdir = os.path.join(REPO, "scratchpad", "fork_vs_port")
    os.makedirs(outdir, exist_ok=True)
    bank = open(truth.BANK, "rb").read()

    import null_b
    null_b.SR = SR
    null_b.BASE_SCEN = [(p, [('on', NOTE, VEL), ('render', N)], "p%d" % p)
                        for p in PATCHES]
    tmp = tempfile.mkdtemp(prefix="fvp_")
    print("building shipping fork (EB_REVERB_HALF OFF) ...")
    fork = null_b.render_side(ab_wavs.build(tmp, "fork", ab_wavs.SHIP),
                              False, tmp, "fork")

    print("\n%-8s %10s %10s %8s %10s" % ("patch", "port rms", "fork rms",
                                         "d dB", "max|f-p|"))
    for p in PATCHES:
        pL, pR = port_render(p, bank)
        f = np.asarray(fork["streams"]["p%d" % p], dtype=np.float64)
        n = min(len(pL), len(f)); pL, f = pL[:n], f[:n]
        rp = float(np.sqrt(np.mean(pL * pL)))
        rf = float(np.sqrt(np.mean(f * f)))
        pk = max(float(np.max(np.abs(pL))), 1e-9)
        g = 0.891 / pk
        w24(os.path.join(outdir, "port_p%d.wav" % p), pL, g)
        w24(os.path.join(outdir, "fork_p%d.wav" % p), f, g)
        d = 20.0 * np.log10(max(rf, 1e-30) / max(rp, 1e-30))
        mx = float(np.max(np.abs(f - pL)))
        print("  %-6d %10.5f %10.5f %+8.3f %10.2e" % (p, rp, rf, d, mx))
    print("\n-> %s" % outdir)
    print("port == .vst3 (make verify, residual 0). Fork is a bounded sonic")
    print("trade off the port; the dB column is that trade, not a regression.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

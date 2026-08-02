#!/usr/bin/env python3
"""ENGINE B - REVERB spec, pass 1: isolation, topology reconstruction, buffer extent.

Everything here is EXECUTED against the sealed port (libjuno.so) through
tools/engineb/fx_chorus_probe.c, which drives juno_master_render directly.

The central claim is not read off the decompile: the reverb is re-implemented in
numpy from a hypothesised topology, given only the traced input sample and the
engine's own state at t=0, and required to reproduce the engine's stereo output
BIT FOR BIT. A wrong topology cannot pass that.
"""
import ctypes, json, os, sys
import numpy as np

R = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(R, "tools", "verify"))
import truth

J = ctypes.CDLL(os.path.join(R, "libjuno.so"))
P = ctypes.CDLL(os.path.join(R, "scratchpad", "fx_chorus_probe.so"))
for f, rt, at in (("juno_gui_create", ctypes.c_void_p, [ctypes.c_float, ctypes.c_int]),
                  ("juno_gui_destroy", None, [ctypes.c_void_p]),
                  ("juno_gui_peek", ctypes.c_uint, [ctypes.c_void_p, ctypes.c_int]),
                  ("juno_gui_get", ctypes.c_float, [ctypes.c_void_p, ctypes.c_int]),
                  ("juno_gui_set", None, [ctypes.c_void_p, ctypes.c_int, ctypes.c_float]),
                  ("juno_gui_apply_bank", ctypes.c_int,
                   [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]),
                  ("juno_gui_host_set", None, [ctypes.c_void_p, ctypes.c_int, ctypes.c_int])):
    getattr(J, f).restype = rt; getattr(J, f).argtypes = at
P.pb_state.restype = ctypes.c_void_p
P.pb_state.argtypes = [ctypes.c_void_p]
P.pb_fx.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int,
                    ctypes.POINTER(ctypes.c_float), ctypes.POINTER(ctypes.c_float),
                    ctypes.POINTER(ctypes.c_int), ctypes.c_int, ctypes.POINTER(ctypes.c_float)]
P.pb_copy.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.POINTER(ctypes.c_float)]

BANK = open(truth.BANK, "rb").read()
BUF, NBUF = 10759888, 65536
POS, WIPE, MUTE = 10759856, 10759872, 11022032
TAPW = 11022064
DRY, WET, SEND, GATE, AP = 10759424, 10759440, 10759408, 10759376, 10759392
IN_CELL = 10759120                      # the engine stores the scaled reverb input here
F32 = np.float32


def mk(rate, patch=0):
    c = J.juno_gui_create(F32(rate), 0)
    J.juno_gui_apply_bank(c, BANK, len(BANK), patch)
    return c


def render(ctx, sig, trace_offs=()):
    st = P.pb_state(ctx)
    n = len(sig)
    a = (ctypes.c_float * n)(*np.asarray(sig, F32))
    L = (ctypes.c_float * n)(); Rr = (ctypes.c_float * n)()
    no = len(trace_offs)
    co = (ctypes.c_int * max(no, 1))(*(list(trace_offs) or [0]))
    tr = (ctypes.c_float * (n * max(no, 1)))()
    P.pb_fx(st, a, n, L, Rr, co, no, tr)
    return (np.frombuffer(L, F32).copy(), np.frombuffer(Rr, F32).copy(),
            np.frombuffer(tr, F32).reshape(n, max(no, 1)).copy() if no else None)


def buf_of(ctx):
    d = (ctypes.c_float * NBUF)()
    P.pb_copy(P.pb_state(ctx), BUF, NBUF * 4, d)
    return np.frombuffer(d, F32).copy()


def taps(ctx, base=TAPW):
    return [ctypes.c_int32(J.juno_gui_peek(ctx, base + 4 * k)).value for k in range(34)]


def warm(ctx, n=6000):
    render(ctx, np.zeros(n, F32))


out = {}

# ------------------------------------------------------------------ 1. isolation
iso = {}
for rate in (44100, 48000):
    c = mk(rate); warm(c)
    sig = (0.3 * np.sin(2 * np.pi * 220 * np.arange(4000) / rate)).astype(F32)
    # (a) send = 0 and dry = 0 -> output must be EXACTLY zero
    J.juno_gui_set(c, SEND, F32(0.0)); J.juno_gui_set(c, DRY, F32(0.0))
    l0, r0, _ = render(c, sig)
    # (b) dry = 1, send = 0 -> output must equal the dry path alone
    J.juno_gui_set(c, DRY, F32(1.0))
    l1, r1, _ = render(c, sig)
    # (c) dry = 0, send restored -> pure reverb
    c2 = mk(rate); warm(c2)
    send = float(J.juno_gui_get(c2, SEND))
    J.juno_gui_set(c2, DRY, F32(0.0))
    l2, r2, _ = render(c2, sig)
    iso[str(rate)] = {
        "send0_dry0_max_abs": [float(np.max(np.abs(l0))), float(np.max(np.abs(r0)))],
        "send0_dry0_exactly_zero": bool(np.all(l0 == 0) and np.all(r0 == 0)),
        "dry_only_max_abs": float(np.max(np.abs(l1))),
        "reverb_only_max_abs": float(np.max(np.abs(l2))),
        "reverb_only_rms": float(np.sqrt(np.mean(l2.astype(np.float64) ** 2))),
        "patch0_send": send,
    }
    J.juno_gui_destroy(c); J.juno_gui_destroy(c2)
out["isolation"] = iso

# ------------------------------------------------------------------ 2. topology
# tap indices, by role, as hypothesised from the executed structure
def reconstruct(T, buf0, pos0, st0, x, apc, wet, mute, gate, damp, lfo0, lfo_inc, lfo_depth):
    n = len(x)
    b = buf0.copy()
    pos = pos0
    s120, s136, s152, s168, s184 = st0[:5]
    d200, d216, d232, d248, d264, d280, d296, d312 = st0[5:13]
    ph = lfo0
    c520, c536, c552, c568, c584, c600, c616, c632 = st0[13:21]
    L = np.zeros(n, F32); Rr = np.zeros(n, F32)
    f = F32
    ds = [(d200, d216), (d232, d248), (d264, d280), (d296, d312)]
    for i in range(n):
        pos = (pos - 1) & 0xFFFF
        xn = x[i]
        v477 = f(c536 * s120); v479 = f(c552 * s136); v480 = f(xn * c520)
        s120 = xn
        v481 = f(f(v477 + v480) + v479)
        v482 = f(c616 * s168); v484 = f(c632 * s184)
        v483 = f(f(f(s136 * c584) + f(v481 * c568)) + f(c600 * s152))
        s152 = s136; s136 = v481; s184 = s168
        v485 = f(f(v483 + v482) + v484)
        s168 = v485
        # LFO
        ph = f(lfo_inc + ph)
        if ph > f(1.0):
            ph = f(ph - f(2.0))
        v487 = f(ph * lfo_depth)
        v488 = f(2048.0) if ph < 0 else f(-2048.0)
        mod = int(np.float32(v487 * v488))
        def rd(k, extra=0):
            return b[(pos + T[k] + extra) & 0xFFFF]
        def wr(k, v):
            b[(pos + T[k]) & 0xFFFF] = v
        wr(0, v485)
        a_ = rd(3)
        v491 = f(rd(1, -mod) - f(a_ * apc))
        wr(2, v491)
        v493 = rd(5)
        v494 = f(f(f(apc * v491) + a_) - f(apc * v493))
        wr(4, v494)
        v497 = rd(7)
        v498 = f(f(f(apc * v494) + v493) - f(apc * v497))
        wr(6, v498)
        v501 = rd(9)
        v502 = f(f(f(apc * v498) + v497) - f(apc * v501))
        wr(8, v502)
        v504 = f(f(apc * v502) + v501)
        v506 = f(v504 * f(0.5))
        # four loops
        LOOP = ((11, 10, 18, 21, 0), (13, 12, 22, 25, 1),
                (15, 14, 26, 29, 2), (17, 16, 30, 33, 3))
        for (kr, kw, ko, kd, di) in LOOP:
            dlp, dhp = ds[di]
            vr = rd(kr)
            vo = f(f(v506 - f(vr * apc)) + dhp)
            wr(kw, vo)
            b[(pos + T[ko]) & 0xFFFF] = f(f(vo * apc) + vr)
            e = f(rd(kd) - dlp)
            fc, hpc, lpc = damp[di]
            newlp = f(f(e * fc) + dlp)
            ds[di] = (newlp, f(f(newlp * lpc) + f(hpc * e)))
        g = f(f(f(wet * f(16.0)) * mute) * gate)
        sl = f(f(f(rd(24) + rd(19)) + rd(27)) + rd(32))
        sr = f(f(f(rd(20) + rd(23)) + rd(28)) + rd(31))
        L[i] = f(f(f(f(sl * wet) * f(16.0)) * mute) * gate)
        Rr[i] = f(f(f(f(sr * wet) * f(16.0)) * mute) * gate)
    return L, Rr


topo = {}
for rate in (44100, 48000):
    c = mk(rate); warm(c)
    J.juno_gui_set(c, DRY, F32(0.0))
    T = taps(c)
    buf0 = buf_of(c)
    pos0 = J.juno_gui_peek(c, POS)
    getf = lambda o: F32(J.juno_gui_get(c, o))
    st0 = [getf(o) for o in (10759120, 10759136, 10759152, 10759168, 10759184,
                             10759200, 10759216, 10759232, 10759248,
                             10759264, 10759280, 10759296, 10759312,
                             10759520, 10759536, 10759552, 10759568,
                             10759584, 10759600, 10759616, 10759632)]
    damp = [(getf(10759648 + 48 * k), getf(10759664 + 48 * k), getf(10759680 + 48 * k))
            for k in range(4)]
    lfo0 = getf(10759344)
    n = 60000
    sig = (0.4 * np.sin(2 * np.pi * 330 * np.arange(n) / rate)).astype(F32)
    l, r, tr = render(c, sig, (IN_CELL, 101200, 101216, 101168))
    x = tr[:, 0]
    rl, rr = reconstruct(T, buf0, pos0, st0, x, getf(AP), getf(WET), getf(MUTE),
                         getf(GATE), damp, lfo0, getf(10759504), getf(10759488))
    # the engine's final outL/outR pass through the master output-gain + soft-clip
    # stage; the reverb's own stereo pair is cells 101200/101216 = gain(101168) * it.
    g = tr[:, 3]
    eL = tr[:, 1]; eR = tr[:, 2]
    mL = (g * rl).astype(F32); mR = (g * rr).astype(F32)
    topo[str(rate)] = {
        "bit_exact_L": bool(np.array_equal(eL.view(np.uint32), mL.view(np.uint32))),
        "bit_exact_R": bool(np.array_equal(eR.view(np.uint32), mR.view(np.uint32))),
        "n_samples": int(n),
        "max_abs_err_L": float(np.max(np.abs(eL.astype(np.float64) - mL))),
        "max_abs_err_R": float(np.max(np.abs(eR.astype(np.float64) - mR))),
        "engine_rms": float(np.sqrt(np.mean(eL.astype(np.float64) ** 2))),
        "nonvacuous_output_nonzero": bool(np.any(eL != 0)),
        "taps": T,
    }
    J.juno_gui_destroy(c)
out["topology_reconstruction"] = topo

print(json.dumps(out, indent=1))
os.makedirs(os.path.join(R, "scratchpad", "engineb"), exist_ok=True)
json.dump(out, open(os.path.join(R, "scratchpad", "engineb", "fx_reverb_pass1.json"), "w"), indent=1)

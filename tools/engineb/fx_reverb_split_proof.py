#!/usr/bin/env python3
"""ENGINE B - REVERB, split-buffer equivalence proof.

docs/engineb/FX_REVERB.md proved the topology by reconstructing the plugin's ONE
65,536-float masked line bit for bit. Engine B cannot carry that line (262,144 B
against a 200 KB internal budget), so it uses 13 INDEPENDENT circular buffers,
one per delay element, sized to the measured element lengths.

That substitution is only free if the split indexing reads exactly the same
history the masked line would. This file proves it: it runs the split-buffer
formulation, seeded from the engine's own masked line at t=0, and requires the
stereo pair to be BIT-IDENTICAL to the engine's own cells 101200 / 101216 -- the
same acceptance the masked reconstruction had. It is the arithmetic engine B's
eb_reverb.c implements, in the same order, so a failure here is an addressing
bug and not a rounding one.

Run after `make libjuno.so` and
  cc -O2 -shared -fPIC -o scratchpad/fx_chorus_probe.so \
     tools/engineb/fx_chorus_probe.c -L. -ljuno
with LD_LIBRARY_PATH=.
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
                   [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int])):
    getattr(J, f).restype = rt; getattr(J, f).argtypes = at
P.pb_state.restype = ctypes.c_void_p
P.pb_state.argtypes = [ctypes.c_void_p]
P.pb_fx.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int,
                    ctypes.POINTER(ctypes.c_float), ctypes.POINTER(ctypes.c_float),
                    ctypes.POINTER(ctypes.c_int), ctypes.c_int, ctypes.POINTER(ctypes.c_float)]
P.pb_copy.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.POINTER(ctypes.c_float)]

BANK = open(truth.BANK, "rb").read()
BUF, NBUF = 10759888, 65536
POS, TAPW = 10759856, 11022064
DRY, WET, GATE, AP, MUTE = 10759424, 10759440, 10759376, 10759392, 11022032
IN_CELL = 10759120
F32 = np.float32
f = F32

# (write tap index, read tap indices...) for each of the 13 elements
ELEMS = [("pd", 0, 1), ("ap1", 2, 3), ("ap2", 4, 5), ("ap3", 6, 7), ("ap4", 8, 9),
         ("laA", 10, 11), ("laB", 12, 13), ("laC", 14, 15), ("laD", 16, 17),
         ("dA", 18, 21), ("dB", 22, 25), ("dC", 26, 29), ("dD", 30, 33)]
# extra output taps read out of each long delay (depths measured from its write tap)
OUTTAPS = {"dA": (19, 20), "dB": (24, 23), "dC": (27, 28), "dD": (32, 31)}
MODSLACK = 512          # the TYPE-5 pre-delay modulation reaches 416 samples


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
    return np.frombuffer(tr, F32).reshape(n, max(no, 1)).copy()


def split_run(T, buf0, pos0, st0, x, apc, wet, mute, gate, damp,
              lfo0, lfo_inc, lfo_depth):
    """The engine B formulation: one ring per element, read-then-write, index
    advanced by a compare-and-add. Capacities are the element lengths (plus the
    modulation slack on the pre-delay), i.e. the compile-time budget."""
    n = len(x)
    cap, buf, w = {}, {}, {}
    for name, kw, kr in ELEMS:
        c = T[kr] - T[kw] + (MODSLACK if name == "pd" else 0)
        cap[name] = c
        w[name] = 0
        b = np.zeros(c, F32)
        # seed: the value written d samples ago sits at masked (pos0-1+d+T[kw])
        for d in range(1, c + 1):
            b[(0 - d) % c] = buf0[(pos0 - 1 + d + T[kw]) & 0xFFFF]
        buf[name] = b

    def rd(name, d):
        return buf[name][(w[name] - d) % cap[name]]

    def wr(name, v):
        buf[name][w[name]] = v
        w[name] = w[name] + 1
        if w[name] == cap[name]:
            w[name] = 0

    s120, s136, s152, s168, s184 = st0[:5]
    d200, d216, d232, d248, d264, d280, d296, d312 = st0[5:13]
    c520, c536, c552, c568, c584, c600, c616, c632 = st0[13:21]
    ph = lfo0
    ds = [(d200, d216), (d232, d248), (d264, d280), (d296, d312)]
    L = np.zeros(n, F32); Rr = np.zeros(n, F32)
    PD = T[1] - T[0]
    APL = [T[k + 1] - T[k] for k in (2, 4, 6, 8)]
    LOOP = (("laA", "dA", 0), ("laB", "dB", 1), ("laC", "dC", 2), ("laD", "dD", 3))
    LAL = {nm: T[kr] - T[kw] for nm, kw, kr in ELEMS}
    OT = {nm: (T[a] - T[kw], T[b] - T[kw])
          for nm, kw, kr in ELEMS if nm in OUTTAPS
          for a, b in [OUTTAPS[nm]]}
    for i in range(n):
        xn = x[i]
        v477 = f(c536 * s120); v479 = f(c552 * s136); v480 = f(xn * c520)
        s120 = xn
        v481 = f(f(v477 + v480) + v479)
        v482 = f(c616 * s168); v484 = f(c632 * s184)
        v483 = f(f(f(s136 * c584) + f(v481 * c568)) + f(c600 * s152))
        s152 = s136; s136 = v481; s184 = s168
        v485 = f(f(v483 + v482) + v484)
        s168 = v485
        ph = f(lfo_inc + ph)
        if ph > f(1.0):
            ph = f(ph - f(2.0))
        v487 = f(ph * lfo_depth)
        v488 = f(2048.0) if ph < 0 else f(-2048.0)
        mod = int(np.float32(v487 * v488))
        # pre-delay: read (modulated) BEFORE writing this sample
        pdo = rd("pd", PD - mod)
        wr("pd", v485)
        # four series allpasses
        u = pdo
        for k, nm in enumerate(("ap1", "ap2", "ap3", "ap4")):
            a_ = rd(nm, APL[k])
            v = f(u - f(a_ * apc))
            wr(nm, v)
            u = f(f(apc * v) + a_)
        v506 = f(u * f(0.5))
        sl = []; sr = []
        for (lan, dn, di) in LOOP:
            dlp, dhp = ds[di]
            vr = rd(lan, LAL[lan])
            vo = f(f(v506 - f(vr * apc)) + dhp)
            wr(lan, vo)
            ta, tb = OT[dn]
            e = f(rd(dn, LAL[dn]) - dlp)
            oL = rd(dn, ta); oR = rd(dn, tb)
            wr(dn, f(f(vo * apc) + vr))
            fc, hpc, lpc = damp[di]
            newlp = f(f(e * fc) + dlp)
            ds[di] = (newlp, f(f(newlp * lpc) + f(hpc * e)))
            sl.append(oL); sr.append(oR)
        # summation order is the plugin's: L = B,A,C,D ; R = A,B,C,D
        SL = f(f(f(sl[1] + sl[0]) + sl[2]) + sl[3])
        SR = f(f(f(sr[0] + sr[1]) + sr[2]) + sr[3])
        L[i] = f(f(f(f(SL * wet) * f(16.0)) * mute) * gate)
        Rr[i] = f(f(f(f(SR * wet) * f(16.0)) * mute) * gate)
    return L, Rr


def buf_of(ctx):
    d = (ctypes.c_float * NBUF)()
    P.pb_copy(P.pb_state(ctx), BUF, NBUF * 4, d)
    return np.frombuffer(d, F32).copy()


out = {}
for rate in (44100, 48000):
    for patch in (0,):
        c = mk(rate, patch)
        render(c, np.zeros(6000, F32))
        J.juno_gui_set(c, DRY, F32(0.0))
        T = [ctypes.c_int32(J.juno_gui_peek(c, TAPW + 4 * k)).value for k in range(34)]
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
        n = 60000
        sig = (0.4 * np.sin(2 * np.pi * 330 * np.arange(n) / rate)).astype(F32)
        tr = render(c, sig, (IN_CELL, 101200, 101216, 101168))
        x, eL, eR, g = tr[:, 0], tr[:, 1], tr[:, 2], tr[:, 3]
        rl, rr = split_run(T, buf0, pos0, st0, x, getf(AP), getf(WET), getf(MUTE),
                           getf(GATE), damp, getf(10759344), getf(10759504),
                           getf(10759488))
        mL = (g * rl).astype(F32); mR = (g * rr).astype(F32)
        out["%d_p%d" % (rate, patch)] = {
            "bit_exact_L": bool(np.array_equal(eL.view(np.uint32), mL.view(np.uint32))),
            "bit_exact_R": bool(np.array_equal(eR.view(np.uint32), mR.view(np.uint32))),
            "max_abs_err": float(max(np.max(np.abs(eL.astype(np.float64) - mL)),
                                     np.max(np.abs(eR.astype(np.float64) - mR)))),
            "engine_rms": float(np.sqrt(np.mean(eL.astype(np.float64) ** 2))),
            "nonvacuous": bool(np.any(eL != 0)),
            "n": n,
        }
        J.juno_gui_destroy(c)

print(json.dumps(out, indent=1))
ok = all(v["bit_exact_L"] and v["bit_exact_R"] and v["nonvacuous"] for v in out.values())
print("SPLIT-BUFFER EQUIVALENCE:", "BIT-EXACT" if ok else "FAILED")
sys.exit(0 if ok else 1)

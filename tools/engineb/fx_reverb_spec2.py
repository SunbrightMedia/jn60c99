#!/usr/bin/env python3
"""ENGINE B - REVERB spec, pass 2: parameter laws, memory extent, reference vectors.

Every number is EXECUTED against the sealed port (libjuno.so). Parameters are
driven through juno_gui_host_set, i.e. the port's own host-parameter entry, which
encodes the record byte and re-runs the real recall - not by poking cells.
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
                  ("juno_gui_host_set", None, [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]),
                  ("juno_reverb_predelay", ctypes.c_int, [ctypes.c_int, ctypes.c_int]),
                  ("juno_bank_record", ctypes.c_void_p, [ctypes.c_char_p, ctypes.c_int])):
    getattr(J, f).restype = rt; getattr(J, f).argtypes = at
P.pb_state.restype = ctypes.c_void_p
P.pb_state.argtypes = [ctypes.c_void_p]
P.pb_fx.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int,
                    ctypes.POINTER(ctypes.c_float), ctypes.POINTER(ctypes.c_float),
                    ctypes.POINTER(ctypes.c_int), ctypes.c_int, ctypes.POINTER(ctypes.c_float)]
P.pb_copy.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.POINTER(ctypes.c_float)]

BANK = open(truth.BANK, "rb").read()
F32 = np.float32
BUF, NBUF = 10759888, 65536
POS, TAPW, TAPL = 10759856, 11022064, 11022208
IDX = {"LEVEL": 795, "TYPE": 876, "TIME": 877, "PREDELAY": 1323}
RATES = (44100, 48000)


# --- record-byte driving. juno_gui_host_set is a NO-OP for the reverb TYPE/TIME/
# PRE DELAY indices (MEASURED: sweeping 876/877/1323 through it moved not one cell),
# so those three are driven by editing the patch RECORD in a copy of the bank image
# and re-running the real recall through juno_gui_apply_bank.
_bb = ctypes.create_string_buffer(BANK, len(BANK))
_p0 = ctypes.cast(_bb, ctypes.c_void_p).value
REC_OFF = J.juno_bank_record(_bb, 0) - _p0
REC_STRIDE = J.juno_bank_record(_bb, 1) - J.juno_bank_record(_bb, 0)


def bank_with(patch=0, **kw):
    b = bytearray(BANK)
    o = REC_OFF + REC_STRIDE * patch
    if "type" in kw:
        b[o + 658] = (kw["type"] >> 4) & 0xF; b[o + 659] = kw["type"] & 0xF
    if "time" in kw:
        b[o + 666] = (kw["time"] >> 4) & 0xF; b[o + 667] = kw["time"] & 0xF
    if "predelay" in kw:
        b[o + 3947] = kw["predelay"] & 0x7F
    return bytes(b)


def mk(rate, patch=0, bank=None):
    c = J.juno_gui_create(F32(rate), 0)
    bk = bank if bank is not None else BANK
    J.juno_gui_apply_bank(c, bk, len(bk), patch)
    return c


def render(ctx, sig, offs=()):
    st = P.pb_state(ctx); n = len(sig)
    a = (ctypes.c_float * n)(*np.asarray(sig, F32))
    L = (ctypes.c_float * n)(); Rr = (ctypes.c_float * n)()
    no = len(offs)
    co = (ctypes.c_int * max(no, 1))(*(list(offs) or [0]))
    tr = (ctypes.c_float * (n * max(no, 1)))()
    P.pb_fx(st, a, n, L, Rr, co, no, tr)
    return (np.frombuffer(L, F32).copy(), np.frombuffer(Rr, F32).copy(),
            np.frombuffer(tr, F32).reshape(n, max(no, 1)).copy() if no else None)


def taps(c, base=TAPL):
    return [ctypes.c_int32(J.juno_gui_peek(c, base + 4 * k)).value for k in range(34)]


def u32(c, o):
    return int(J.juno_gui_peek(c, o))


out, npz = {}, {}

# ---------------------------------------------------------- 1. LEVEL law, 0..255
lev = {}
for rate in RATES:
    c = mk(rate)
    v = []
    for b in range(256):
        J.juno_gui_host_set(c, IDX["LEVEL"], b)
        v.append(u32(c, 10759408))
    lev[str(rate)] = v
    J.juno_gui_destroy(c)
out["level_send_10759408_bits"] = lev
out["level_rate_independent"] = lev["44100"] == lev["48000"]
npz["level_send_bits"] = np.array(lev["48000"], np.uint32)

# ------------------------------------------------- 2. TYPE: taps, Fc, mod depth
typ = {}
for rate in RATES:
    per = {}
    for t in range(6):
        c = mk(rate, bank=bank_with(type=t))
        per[str(t)] = {
            "taps": taps(c),
            "fc_bits": ["0x%08x" % u32(c, 10759648 + 48 * k) for k in range(4)],
            "fc": [float(J.juno_gui_get(c, 10759648 + 48 * k)) for k in range(4)],
            "lfo_depth_10759488": float(J.juno_gui_get(c, 10759488)),
            "hp_lp": [float(J.juno_gui_get(c, o)) for o in
                      (10759664, 10759680, 10759712, 10759728,
                       10759760, 10759776, 10759808, 10759824)],
        }
        J.juno_gui_destroy(c)
    typ[str(rate)] = per
out["type"] = typ

# ------------------------------- 3. TIME: 8 hp/lp coeffs, joint with TYPE, 0..255
tm = {}
for rate in RATES:
    arr = np.zeros((6, 256, 8), np.uint32)
    for t in range(6):
        for b in range(256):
            c = mk(rate, bank=bank_with(type=t, time=b))
            for i, o in enumerate((10759664, 10759680, 10759712, 10759728,
                                   10759760, 10759776, 10759808, 10759824)):
                arr[t, b, i] = u32(c, o)
            J.juno_gui_destroy(c)
    npz["time_hplp_bits_%d" % rate] = arr
    tm[str(rate)] = {
        "mirror_pairs_equal": bool(np.all(arr[:, :, 0] == arr[:, :, 2]) and
                                   np.all(arr[:, :, 1] == arr[:, :, 3]) and
                                   np.all(arr[:, :, 4] == arr[:, :, 6]) and
                                   np.all(arr[:, :, 5] == arr[:, :, 7])),
        "distinct_curves": int(len({arr[t, :, i].tobytes() for t in range(6) for i in range(8)})),
        "type_dependent": bool(not np.all(arr[0] == arr[2])),
    }
out["time"] = tm
out["time_rate_independent"] = bool(np.array_equal(npz["time_hplp_bits_44100"],
                                                   npz["time_hplp_bits_48000"]))

# ------------------------------------------- 4. PRE DELAY: uniform tap shift 0..127
pd = {}
for rate in RATES:
    per = {}
    for t in (0, 1, 2):
        c = mk(rate, bank=bank_with(type=t, predelay=20))
        base = taps(c); J.juno_gui_destroy(c)
        rows, uniform, closed = [], True, True
        for b in range(128):
            c = mk(rate, bank=bank_with(type=t, predelay=b))
            tp = taps(c)
            d = [tp[k] - base[k] for k in range(34)]
            if d[0] != 0 or len(set(d[1:])) != 1:
                uniform = False
            pdel = float(J.juno_gui_get(c, 10759360))
            exp = max((min(b, 100) * rate) // 1000 - 2, 0)
            if pdel != float(exp) or d[1] != exp - max((20 * rate) // 1000 - 2, 0):
                closed = False
            rows.append([b, d[1], pdel])
            J.juno_gui_destroy(c)
        per[str(t)] = {"uniform_shift": uniform,
                       "closed_form_max_predelay_2_holds": closed,
                       "shift_at_0": rows[0][1], "shift_at_100": rows[100][1],
                       "shift_at_127": rows[127][1],
                       "predelay_samples_at_100": rows[100][2]}
    pd[str(rate)] = per
out["predelay"] = pd

# ---------------------------------------------------------------- 5. memory extent
mem = {}
for rate in RATES:
    mx = 0
    for t in range(6):
        for b in (0, 20, 100, 127):
            c = mk(rate, bank=bank_with(type=t, predelay=b))
            mx = max(mx, max(taps(c)))
            J.juno_gui_destroy(c)
    mem[str(rate)] = {"max_tap_index": mx,
                      "min_line_floats": mx + 1,
                      "min_line_bytes": (mx + 1) * 4,
                      "engine_line_floats": NBUF,
                      "engine_line_bytes": NBUF * 4,
                      "pow2_line_floats": 1 << (mx).bit_length(),
                      "pow2_line_bytes": (1 << (mx).bit_length()) * 4}
out["memory"] = mem

# ------- 6. wipe coverage: does the lazy wipe clear the whole line the DSP reads?
c = mk(48000)
b0 = np.zeros(NBUF, F32)
d = (ctypes.c_float * NBUF)()
render(c, np.zeros(300, F32))                    # let the 256-sample wipe complete
P.pb_copy(P.pb_state(c), BUF, NBUF * 4, d)
after = np.frombuffer(d, F32).copy()
nz = np.nonzero(after)[0]
out["wipe"] = {"nonzero_cells_after_wipe": int(nz.size),
               "nonzero_index_min": int(nz.min()) if nz.size else -1,
               "nonzero_index_max": int(nz.max()) if nz.size else -1}
J.juno_gui_destroy(c)

# ------------------------------------------------- 7. REFERENCE VECTORS for gating
ref = {}
for rate in RATES:
    for t in (0, 2, 5):
        c = mk(rate, bank=bank_with(type=t))
        render(c, np.zeros(6000, F32))            # complete wipe + mute ramp
        J.juno_gui_set(c, 10759424, F32(0.0))     # dry = 0 -> reverb only
        sig = np.zeros(24000, F32); sig[0] = F32(1.0)
        l, r, tr = render(c, sig, (10759120, 101200, 101216, 101168))
        key = "ir_%d_type%d" % (rate, t)
        npz[key + "_in"] = tr[:, 0]
        npz[key + "_L"] = tr[:, 1]
        npz[key + "_R"] = tr[:, 2]
        npz[key + "_g"] = tr[:, 3]
        ref[key] = {"rms_L": float(np.sqrt(np.mean(tr[:, 1].astype(np.float64) ** 2))),
                    "peak_L": float(np.max(np.abs(tr[:, 1]))),
                    "taps": taps(c),
                    "damp": [[float(J.juno_gui_get(c, 10759648 + 48 * k)),
                              float(J.juno_gui_get(c, 10759664 + 48 * k)),
                              float(J.juno_gui_get(c, 10759680 + 48 * k))] for k in range(4)],
                    "ap": float(J.juno_gui_get(c, 10759392)),
                    "wet": float(J.juno_gui_get(c, 10759440)),
                    "inpfilt": [float(J.juno_gui_get(c, o)) for o in
                                (10759520, 10759536, 10759552, 10759568,
                                 10759584, 10759600, 10759616, 10759632)]}
        J.juno_gui_destroy(c)
out["reference_vectors"] = ref

sd = os.path.join(R, "scratchpad", "engineb"); os.makedirs(sd, exist_ok=True)
dd = os.path.join(R, "docs", "engineb", "data"); os.makedirs(dd, exist_ok=True)
for base in (sd, dd):
    json.dump(out, open(os.path.join(base, "fx_reverb.json"), "w"), indent=1)
    np.savez_compressed(os.path.join(base, "fx_reverb.npz"), **npz)
print(json.dumps({k: v for k, v in out.items() if k != "type"}, indent=1)[:9000])

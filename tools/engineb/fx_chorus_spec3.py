#!/usr/bin/env python3
"""ENGINE B — CHORUS spec, pass 3: rate table, mix law, noise floor, and the
REFERENCE VECTORS engine B's chorus will be gated against offline.

All numbers executed against the sealed port through
tools/engineb/fx_chorus_probe.c (master stage driven directly).
"""
import ctypes, json, os, struct, sys
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

TRACE = [90368, 90656, 90688, 90800, 90816, 91088, 91104, 95824, 95840]
TI = {o: i for i, o in enumerate(TRACE)}
BANK = open(truth.BANK, "rb").read()
WARM = 600000

STRUCT_CELLS = [91120, 91136, 91152, 91168, 91184, 91248, 91264, 91280,
                91296, 91312, 91328, 91344, 91360, 91376, 91392, 91408,
                91424, 91440, 91456, 91472, 91488, 91504, 91520, 91536,
                91552, 91568, 91584, 91600, 91616, 91632, 91648, 91664,
                91680, 91696, 91712, 96336, 96368]


def fx(ctx, sig):
    st = P.pb_state(ctx)
    n = len(sig)
    a = (ctypes.c_float * n)(*sig.astype(np.float32))
    L = (ctypes.c_float * n)(); Rr = (ctypes.c_float * n)()
    co = (ctypes.c_int * len(TRACE))(*TRACE)
    tr = (ctypes.c_float * (n * len(TRACE)))()
    P.pb_fx(st, a, n, L, Rr, co, len(TRACE), tr)
    return np.frombuffer(tr, np.float32).reshape(n, len(TRACE)).copy()


out = {}
npz = {}

# ---------- 1. structural constants at every host rate
tbl = {}
for rate in (44100, 48000, 88200, 96000):
    c = J.juno_gui_create(ctypes.c_float(rate), 0)
    d = {str(o): "0x%08x" % J.juno_gui_peek(c, o) for o in STRUCT_CELLS}
    d["_delay_base_samples"] = float(J.juno_gui_get(c, 91120) * 16384.0)
    d["_delay_base_ms"] = d["_delay_base_samples"] / rate * 1e3
    d["_lfo_rate_hz"] = float(J.juno_gui_get(c, 91152)) * rate / 2.0
    d["_mod_scale_91472"] = float(J.juno_gui_get(c, 91472))
    d["_excursion_samples"] = float(J.juno_gui_get(c, 91184)) * float(J.juno_gui_get(c, 91472)) * 16384.0
    d["_excursion_ms"] = d["_excursion_samples"] / rate * 1e3
    d["_min_delay_samples"] = d["_delay_base_samples"] + float(J.juno_gui_get(c, 91488)) * 16384.0
    d["_min_delay_ms"] = d["_min_delay_samples"] / rate * 1e3
    tbl[str(rate)] = d
    J.juno_gui_destroy(c)
out["structural_by_rate"] = tbl

# chorus II / flanger LFO rates, per rate, driven by EFFECT TYPE
et = {}
for rate in (44100, 48000):
    per_type = {}
    for t in range(6):
        c = J.juno_gui_create(ctypes.c_float(rate), 0)
        J.juno_gui_apply_bank(c, BANK, len(BANK), 0)
        J.juno_gui_host_set(c, 51, t)
        per_type[str(t)] = {
            "routing": int(J.juno_gui_peek(c, 11022052)),
            "lfo_rate_cell": "0x%08x" % J.juno_gui_peek(c, 91152),
            "lfo_rate_hz": float(J.juno_gui_get(c, 91152)) * rate / 2.0,
            "delay_base_samples": float(J.juno_gui_get(c, 91120) * 16384.0),
            "lfo_depth": float(J.juno_gui_get(c, 91184)),
            "lfo_phase_offset": float(J.juno_gui_get(c, 91168)),
            "excursion_samples": float(J.juno_gui_get(c, 91184)) * float(J.juno_gui_get(c, 91472)) * 16384.0,
        }
        J.juno_gui_destroy(c)
    et[str(rate)] = per_type
out["by_effect_type_fresh_context"] = et

# ---------- 2. mix law: linearity in Dry, Wet and Noise (48 kHz)
rate = 48000
sig = np.sin(2 * np.pi * 220.0 / rate * np.arange(3000)).astype(np.float32) * 0.5


def run(dry, wet, noise, warm=WARM, s=None):
    c = J.juno_gui_create(ctypes.c_float(rate), 0)
    J.juno_gui_set(c, 91216, ctypes.c_float(dry))
    J.juno_gui_set(c, 91232, ctypes.c_float(wet))
    J.juno_gui_set(c, 91200, ctypes.c_float(noise))
    fx(c, np.zeros(warm, np.float32))
    tr = fx(c, sig if s is None else s)
    J.juno_gui_destroy(c)
    return tr


t_dry = run(1.3, 0.0, 0.0)
t_wet1 = run(0.0, 1.0, 0.0)
t_wet5 = run(0.0, 0.5, 0.0)
t_both = run(1.3, 1.0, 0.0)
t_noise = run(0.0, 1.0, 0.0025098039768636227, s=np.zeros(3000, np.float32))
t_noise2 = run(0.0, 1.0, 2 * 0.0025098039768636227, s=np.zeros(3000, np.float32))
inL = t_dry[:, TI[90368]].astype(np.float64)
out["mix_law"] = {
    "dry_only_equals_1p3_times_in": bool(np.array_equal(
        t_dry[:, TI[91088]], (t_dry[:, TI[90368]] * np.float32(1.3)).astype(np.float32))),
    "wet_scales_linearly_max_rel_err": float(np.max(np.abs(
        t_wet5[:, TI[91088]].astype(np.float64) * 2 - t_wet1[:, TI[91088]].astype(np.float64))
        ) / (np.max(np.abs(t_wet1[:, TI[91088]])) + 1e-30)),
    "out_equals_dry_plus_wet_max_abs_err": float(np.max(np.abs(
        t_both[:, TI[91088]].astype(np.float64)
        - (t_dry[:, TI[91088]].astype(np.float64) + t_wet1[:, TI[91088]].astype(np.float64))))),
    "wet_rms_at_wet1": float(np.sqrt(np.mean(t_wet1[:, TI[91088]].astype(np.float64) ** 2))),
    "dry_rms": float(np.sqrt(np.mean(t_dry[:, TI[91088]].astype(np.float64) ** 2))),
    "noise_floor_rms_default_tone": float(np.sqrt(np.mean(t_noise[:, TI[91088]].astype(np.float64) ** 2))),
    "noise_doubles_with_level_ratio": float(
        np.sqrt(np.mean(t_noise2[:, TI[91088]].astype(np.float64) ** 2))
        / (np.sqrt(np.mean(t_noise[:, TI[91088]].astype(np.float64) ** 2)) + 1e-30)),
    "note": "in = cell 90368 = 12.0 x (sum of the 8 voice samples)",
}

# ---------- 3. REFERENCE VECTORS for offline gating of engine B's chorus
# Warmed FX, factory-default chorus levels (patch 0 = EFFECT TYPE 2), a
# deterministic test signal, and the chorus block's two outputs per sample.
refs = {}
for rate in (48000, 44100):
    for patch, name in ((0, "type2_chorusI"), (11, "type3_chorusII")):
        c = J.juno_gui_create(ctypes.c_float(rate), 0)
        J.juno_gui_apply_bank(c, BANK, len(BANK), patch)
        fx(c, np.zeros(WARM, np.float32))
        n = 8192
        t = np.arange(n)
        s = (0.3 * np.sin(2 * np.pi * 110.0 / rate * t)
             + 0.2 * np.sin(2 * np.pi * 1237.0 / rate * t)
             + 0.1 * np.sign(np.sin(2 * np.pi * 3.0 / rate * t))).astype(np.float32)
        s[0] = 1.0
        tr = fx(c, s)
        k = "%s_%d" % (name, rate)
        npz["ref_in_%s" % k] = s
        npz["ref_outL_%s" % k] = tr[:, TI[91088]]
        npz["ref_outR_%s" % k] = tr[:, TI[91104]]
        npz["ref_chorusin_%s" % k] = tr[:, TI[90368]]
        npz["ref_delayL_%s" % k] = ((tr[:, TI[90688]].astype(np.float64)
                                     + tr[:, TI[90800]].astype(np.float64)) * 16384).astype(np.float32)
        refs[k] = {
            "levels": {"dry_91216": float(J.juno_gui_get(c, 91216)),
                       "wet_91232": float(J.juno_gui_get(c, 91232)),
                       "noise_91200": float(J.juno_gui_get(c, 91200)),
                       "onoff_91264": float(J.juno_gui_get(c, 91264)),
                       "mute_91280": float(J.juno_gui_get(c, 91280))},
            "warm_samples": WARM,
            "lfo_phase_at_start_90656": float(J.juno_gui_get(c, 90656)),
            "ring_write_index_at_start": int(J.juno_gui_peek(c, 95824)),
            "outL_rms": float(np.sqrt(np.mean(tr[:, TI[91088]].astype(np.float64) ** 2))),
            "outR_rms": float(np.sqrt(np.mean(tr[:, TI[91104]].astype(np.float64) ** 2))),
        }
        J.juno_gui_destroy(c)
out["reference_vectors"] = refs
out["npz_contents"] = sorted(npz.keys())

os.makedirs(os.path.join(R, "scratchpad", "engineb"), exist_ok=True)
with open(os.path.join(R, "scratchpad", "engineb", "fx_chorus3.json"), "w") as f:
    json.dump(out, f, indent=1, sort_keys=True, default=float)
np.savez_compressed(os.path.join(R, "scratchpad", "engineb", "fx_chorus3.npz"), **npz)
print(json.dumps(out, indent=1, sort_keys=True, default=float))

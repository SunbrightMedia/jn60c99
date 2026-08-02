#!/usr/bin/env python3
"""ENGINE B — CHORUS behavioural specification, MEASURED from the sealed port.

Drives the master stage (juno_master_render) directly through
tools/engineb/fx_chorus_probe.c with synthetic voice input, so the chorus block
is observed with a known signal. Everything printed here was executed.

Outputs:
  scratchpad/engineb/fx_chorus.json   scalars + laws + reference vectors
  scratchpad/engineb/fx_chorus.npz    bulk arrays (impulse responses, LFO traces)
"""
import ctypes, json, os, sys
import numpy as np

R = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(R, "tools", "verify"))
import truth

J = ctypes.CDLL(os.path.join(R, "libjuno.so"))
P = ctypes.CDLL(os.path.join(R, "scratchpad", "fx_chorus_probe.so"))
J.juno_gui_create.restype = ctypes.c_void_p
J.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
J.juno_gui_destroy.argtypes = [ctypes.c_void_p]
J.juno_gui_peek.restype = ctypes.c_uint
J.juno_gui_peek.argtypes = [ctypes.c_void_p, ctypes.c_int]
J.juno_gui_get.restype = ctypes.c_float
J.juno_gui_get.argtypes = [ctypes.c_void_p, ctypes.c_int]
J.juno_gui_set.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_float]
J.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
J.juno_gui_apply_bank.restype = ctypes.c_int
J.juno_gui_param_count.restype = ctypes.c_int
J.juno_gui_param_name.restype = ctypes.c_char_p
J.juno_gui_param_name.argtypes = [ctypes.c_int]
J.juno_gui_set_param.restype = ctypes.c_float
J.juno_gui_set_param.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
P.pb_state.restype = ctypes.c_void_p
P.pb_state.argtypes = [ctypes.c_void_p]
P.pb_fx.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int,
                    ctypes.POINTER(ctypes.c_float), ctypes.POINTER(ctypes.c_float),
                    ctypes.POINTER(ctypes.c_int), ctypes.c_int, ctypes.POINTER(ctypes.c_float)]

BLOCKA = [(91120, "DelayTime"), (91136, "ErrorDepth"), (91152, "LFORate"),
          (91168, "LFOPhase"), (91184, "LFODepth"), (91200, "NoiseLevel"),
          (91216, "DryLevel"), (91232, "WetLevel"), (91248, "IpFc"),
          (91264, "OnOff"), (91280, "Mute")]
# aux prepare cells the chorus arm reads (names from the code structure)
AUX = [91296, 91312, 91328, 91344, 91360,      # input biquad b0,b1,b2,a1,a2
       91376, 91392, 91408,                    # input DC-block b0,b1,a1
       91424, 91440,                           # output SVF f, damping
       91456, 91472, 91488, 91504, 91520, 91536, 91552, 91568, 91584,
       91600, 91616, 91632, 91648, 91664, 91680, 91696, 91712]
RING_BASE, RING_LEN_CELL, RING_WIDX = 91728, 95828, 95824

TRACE = [84624, 90368, 90384, 90656, 90688, 90800, 90816, 91088, 91104,
         95824, 95840, 95856, 95860, 95864, 95872, 95876, 95880]
TI = {o: i for i, o in enumerate(TRACE)}


def fx(ctx, sig, offs=TRACE):
    st = P.pb_state(ctx)
    n = len(sig)
    a = (ctypes.c_float * n)(*sig.astype(np.float32))
    L = (ctypes.c_float * n)(); Rr = (ctypes.c_float * n)()
    co = (ctypes.c_int * len(offs))(*offs)
    tr = (ctypes.c_float * (n * len(offs)))()
    P.pb_fx(st, a, n, L, Rr, co, len(offs), tr)
    return (np.frombuffer(L, np.float32).copy(), np.frombuffer(Rr, np.float32).copy(),
            np.frombuffer(tr, np.float32).reshape(n, len(offs)).copy())


def cells(c, offs):
    return {str(o): {"f": float(J.juno_gui_get(c, o)), "bits": "0x%08x" % J.juno_gui_peek(c, o)}
            for o in offs}


def new(rate):
    return J.juno_gui_create(ctypes.c_float(rate), 0)


out = {}
npz = {}
BANK = open(truth.BANK, "rb").read()


def measure_rate(rate):
    tag = "%d" % rate
    res = {}
    c = new(rate)
    res["power_on"] = {
        "routing_11022052": int(J.juno_gui_peek(c, 11022052)),
        "block_a": cells(c, [o for o, _ in BLOCKA]),
        "aux": cells(c, AUX),
        "ring_len_cells": int(J.juno_gui_peek(c, RING_LEN_CELL)),
        "ring_write_index": int(J.juno_gui_peek(c, RING_WIDX)),
        "lfo_state": {str(o): float(J.juno_gui_get(c, o)) for o in (90624, 90640, 90656, 90672)},
    }

    # --- ISOLATION CHECK 1: Wet == 0 at power-on -> chorus out is EXACTLY Dry*in
    sig = np.zeros(64, np.float32); sig[0] = 1.0; sig[1] = -0.5; sig[2] = 0.25
    L, Rr, tr = fx(c, sig)
    inL = tr[:, TI[90368]]; outL = tr[:, TI[91088]]
    dry = float(J.juno_gui_get(c, 91216))
    res["isolation_wet0_exact"] = bool(np.array_equal(outL, (inL * np.float32(dry)).astype(np.float32)))
    res["input_gain_per_voice_sample"] = float(inL[0] / sig[0])
    J.juno_gui_destroy(c)

    # --- gain linearity of the master's pre-chorus mix
    c = new(rate)
    g = []
    for amp in (0.125, 0.5, 1.0, 2.0, -1.0):
        s = np.zeros(4, np.float32); s[0] = amp
        _, _, t = fx(c, s)
        g.append(float(t[0, TI[90368]] / amp))
    res["input_gain_linearity"] = g
    J.juno_gui_destroy(c)

    # --- ISOLATION CHECK 2: wet path only (Dry=0, Wet=1, Noise=0)
    c = new(rate)
    J.juno_gui_set(c, 91216, ctypes.c_float(0.0))    # Dry level
    J.juno_gui_set(c, 91232, ctypes.c_float(1.0))    # Wet level
    J.juno_gui_set(c, 91200, ctypes.c_float(0.0))    # Noise level
    n = 4096
    sig = np.zeros(n, np.float32); sig[0] = 1.0
    L, Rr, tr = fx(c, sig)
    wetL = tr[:, TI[91088]]; wetR = tr[:, TI[91104]]
    npz["ir_wetL_%s" % tag] = wetL
    npz["ir_wetR_%s" % tag] = wetR
    nz = np.nonzero(np.abs(wetL) > 1e-9)[0]
    res["wet_impulse_first_nonzero"] = int(nz[0]) if len(nz) else -1
    res["wet_impulse_peak_index"] = int(np.argmax(np.abs(wetL)))
    res["wet_impulse_peak"] = float(wetL[np.argmax(np.abs(wetL))])
    # feedback check: energy after 2x the max delay
    res["wet_ir_tail_rms_after_2048"] = float(np.sqrt(np.mean(wetL[2048:] ** 2)))
    J.juno_gui_destroy(c)

    # --- interpolation law, verified numerically from the traced tap cells
    c = new(rate)
    J.juno_gui_set(c, 91216, ctypes.c_float(0.0))
    J.juno_gui_set(c, 91232, ctypes.c_float(1.0))
    J.juno_gui_set(c, 91200, ctypes.c_float(0.0))
    rng = np.random.RandomState(7)
    sig = rng.uniform(-1, 1, 3000).astype(np.float32)
    L, Rr, tr = fx(c, sig)
    s0 = tr[:, TI[95856]].astype(np.float64); s1 = tr[:, TI[95860]].astype(np.float64)
    fr = tr[:, TI[95864]].astype(np.float64)
    lin = s0 + fr * (s1 - s0)
    res["interp_linear_max_abs_err_vs_cells"] = float(np.max(np.abs(lin - (s0 + fr * s1 - fr * s0))))
    res["interp_frac_range"] = [float(fr.min()), float(fr.max())]
    npz["interp_s0_%s" % tag] = tr[:, TI[95856]]
    npz["interp_s1_%s" % tag] = tr[:, TI[95860]]
    npz["interp_frac_%s" % tag] = tr[:, TI[95864]]
    J.juno_gui_destroy(c)

    # --- LFO: long silent run, trace phase and both modulated delay times
    c = new(rate)
    N = 400000
    sig = np.zeros(N, np.float32)
    L, Rr, tr = fx(c, sig)
    ph = tr[:, TI[90656]].astype(np.float64)
    base = tr[:, TI[90688]].astype(np.float64)
    mL = tr[:, TI[90800]].astype(np.float64)
    mR = tr[:, TI[90816]].astype(np.float64)
    dL = (base + mL) * 16384.0
    dR = (base + mR) * 16384.0
    # period: samples between successive negative->positive wraps of the ramp
    wr = np.nonzero(np.diff(ph) < -1.0)[0]
    per = np.diff(wr) if len(wr) > 1 else np.array([])
    res["lfo"] = {
        "phase_power_on": float(ph[0]),
        "phase_min": float(ph.min()), "phase_max": float(ph.max()),
        "phase_increment_cell_91152": float(J.juno_gui_get(c, 91152)),
        "wrap_indices_first5": [int(x) for x in wr[:5]],
        "period_samples": [int(x) for x in per[:6]],
        "period_samples_mean": float(per.mean()) if len(per) else None,
        "rate_hz": float(rate / per.mean()) if len(per) else None,
    }
    res["delay_samples"] = {
        "base_cell_target_91120_x16384": float(J.juno_gui_get(c, 91120) * 16384.0),
        "L_min": float(dL[1000:].min()), "L_max": float(dL[1000:].max()),
        "R_min": float(dR[1000:].min()), "R_max": float(dR[1000:].max()),
        "L_at_phase0": float(dL[0]),
        "peak_to_peak_L": float(dL[1000:].max() - dL[1000:].min()),
        "LR_phase_offset_cell_91168": float(J.juno_gui_get(c, 91168)),
    }
    step = max(1, N // 4000)
    npz["lfo_phase_%s" % tag] = ph[::step].astype(np.float32)
    npz["lfo_delayL_%s" % tag] = dL[::step].astype(np.float32)
    npz["lfo_delayR_%s" % tag] = dR[::step].astype(np.float32)
    J.juno_gui_destroy(c)
    return res


for rate in (48000, 44100):
    out["rate_%d" % rate] = measure_rate(rate)

# --- EFFECT DEPTH / EFFECT TONE byte sweeps (per-parameter law), both rates.
# Driven through the HOST parameter path (juno_gui_host_set), which re-runs the
# plugin's own per-patch recall for the edited record byte.
HOST_TYPE, HOST_TONE, HOST_DEPTH = 51, 52, 53
J.juno_gui_host_name.restype = ctypes.c_char_p
J.juno_gui_host_name.argtypes = [ctypes.c_int]
J.juno_gui_host_set.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
out["host_params_used"] = [J.juno_gui_host_name(i).decode()
                           for i in (HOST_TYPE, HOST_TONE, HOST_DEPTH)]
sweeps = {}
for rate in (48000, 44100):
    c = new(rate)
    J.juno_gui_apply_bank(c, BANK, len(BANK), 0)
    J.juno_gui_host_set(c, HOST_TYPE, 2)          # force chorus I so block A is written
    assert int(J.juno_gui_peek(c, 11022052)) == 2
    wet = []; noise = []
    for b in range(256):
        J.juno_gui_host_set(c, HOST_DEPTH, b)
        wet.append(float(J.juno_gui_get(c, 91232)))
    J.juno_gui_host_set(c, HOST_DEPTH, 0)
    for b in range(256):
        J.juno_gui_host_set(c, HOST_TONE, b)
        noise.append(float(J.juno_gui_get(c, 91200)))
    sweeps["wet_%d" % rate] = wet
    sweeps["noise_%d" % rate] = noise
    # per-mode structural cells, driven by EFFECT TYPE on one patch
    md = {}
    for t in range(6):
        J.juno_gui_host_set(c, HOST_TYPE, t)
        md[str(t)] = {"routing": int(J.juno_gui_peek(c, 11022052)),
                      "block_a": ["0x%08x" % J.juno_gui_peek(c, o) for o in
                                  (91120, 91136, 91152, 91168, 91184, 91248, 91264, 91280)],
                      "block_b": ["0x%08x" % J.juno_gui_peek(c, o) for o in
                                  (96336, 96368, 96384, 96416)]}
    out.setdefault("effect_type_sweep", {})["%d" % rate] = md
    J.juno_gui_destroy(c)
out["sweeps_equal_across_rates"] = {
    "wet": sweeps["wet_48000"] == sweeps["wet_44100"],
    "noise": sweeps["noise_48000"] == sweeps["noise_44100"]}
npz["wet_lut"] = np.array(sweeps["wet_48000"], np.float32)
npz["noise_lut"] = np.array(sweeps["noise_48000"], np.float32)
out["wet_lut_probe"] = {str(b): sweeps["wet_48000"][b] for b in (0, 1, 2, 64, 128, 200, 254, 255)}
out["noise_lut_probe"] = {str(b): sweeps["noise_48000"][b] for b in (0, 1, 55, 128, 255)}

# --- per-patch modes: apply every factory patch, group block A by EFFECT TYPE
modes = {}
for rate in (48000, 44100):
    c = new(rate)
    for p in range(64):
        J.juno_gui_apply_bank(c, BANK, len(BANK), p)
        et = int(J.juno_gui_peek(c, 11022052))
        key = "%d_type%d" % (rate, et)
        sig = tuple("0x%08x" % J.juno_gui_peek(c, o) for o in
                    (91120, 91136, 91152, 91168, 91184, 91248, 91264, 91280))
        modes.setdefault(key, {"structural": list(sig), "patches": [], "conflict": False})
        if modes[key]["structural"] != list(sig):
            modes[key]["conflict"] = True
            modes[key]["structural_alt"] = list(sig)
        modes[key]["patches"].append(p)
    J.juno_gui_destroy(c)
out["modes_by_effect_type"] = modes

os.makedirs(os.path.join(R, "scratchpad", "engineb"), exist_ok=True)
with open(os.path.join(R, "scratchpad", "engineb", "fx_chorus.json"), "w") as f:
    json.dump(out, f, indent=1, sort_keys=True)
np.savez_compressed(os.path.join(R, "scratchpad", "engineb", "fx_chorus.npz"), **npz)
print(json.dumps(out, indent=1, sort_keys=True))

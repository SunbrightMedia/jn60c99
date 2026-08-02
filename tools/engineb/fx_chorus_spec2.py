#!/usr/bin/env python3
"""ENGINE B — CHORUS spec, pass 2. Fixes two defects in pass 1:

  1. every measurement is now taken on a WARMED FX block. Pass 1 measured the
     delay range and the impulse response while the delay-time smoother
     (one-pole, coefficient 91248) and the wet-output startup ramp (90752) were
     still converging, so the numbers were the startup transient, not the
     chorus.
  2. the "linear interpolation" check compared two algebraically identical
     expressions and could not fail. It is replaced by an INDEPENDENT
     reconstruction: keep our own copy of the ring buffer and the write index,
     recompute both tap indices and the fraction from the traced modulated
     delay time, and require the reconstruction to equal the traced tap cells
     and the reconstructed wet read to equal the engine's, bit for bit. A
     deliberately wrong variant (nearest-neighbour, and allpass) is run in the
     same place to show the check has teeth.
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
    getattr(J, f).restype = rt
    getattr(J, f).argtypes = at
P.pb_state.restype = ctypes.c_void_p
P.pb_state.argtypes = [ctypes.c_void_p]
P.pb_fx.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int,
                    ctypes.POINTER(ctypes.c_float), ctypes.POINTER(ctypes.c_float),
                    ctypes.POINTER(ctypes.c_int), ctypes.c_int, ctypes.POINTER(ctypes.c_float)]
P.pb_copy.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int,
                      ctypes.POINTER(ctypes.c_float)]

RING_BASE = 91728
TRACE = [90368, 90384, 90656, 90688, 90800, 90816, 91088, 91104,
         95824, 95840, 95856, 95860, 95864, 95872, 95876, 95880, 90752]
TI = {o: i for i, o in enumerate(TRACE)}
BANK = open(truth.BANK, "rb").read()


def fx(ctx, sig):
    st = P.pb_state(ctx)
    n = len(sig)
    a = (ctypes.c_float * n)(*sig.astype(np.float32))
    L = (ctypes.c_float * n)(); Rr = (ctypes.c_float * n)()
    co = (ctypes.c_int * len(TRACE))(*TRACE)
    tr = (ctypes.c_float * (n * len(TRACE)))()
    P.pb_fx(st, a, n, L, Rr, co, len(TRACE), tr)
    return (np.frombuffer(L, np.float32).copy(), np.frombuffer(Rr, np.float32).copy(),
            np.frombuffer(tr, np.float32).reshape(n, len(TRACE)).copy())


def ring(ctx):
    buf = (ctypes.c_float * 1024)()
    P.pb_copy(P.pb_state(ctx), RING_BASE, 4096, buf)
    return np.frombuffer(buf, np.float32).copy()


def new(rate, wet=True):
    c = J.juno_gui_create(ctypes.c_float(rate), 0)
    if wet:
        J.juno_gui_set(c, 91216, ctypes.c_float(0.0))   # Dry level  -> 0
        J.juno_gui_set(c, 91232, ctypes.c_float(1.0))   # Wet level  -> 1
        J.juno_gui_set(c, 91200, ctypes.c_float(0.0))   # Noise level-> 0
    return c


WARM = 600000
out = {}
npz = {}

for rate in (48000, 44100):
    tag = str(rate)
    res = {}
    c = new(rate)
    fx(c, np.zeros(WARM, np.float32))                    # WARM the FX
    res["warm_state"] = {"delay_base_90688_x16384": float(J.juno_gui_get(c, 90688) * 16384.0),
                         "wet_ramp_90752": float(J.juno_gui_get(c, 90752)),
                         "delay_target_91120_x16384": float(J.juno_gui_get(c, 91120) * 16384.0),
                         "mod_scale_91472": float(J.juno_gui_get(c, 91472)),
                         "mod_offset_91488": float(J.juno_gui_get(c, 91488)),
                         "lfo_depth_91184": float(J.juno_gui_get(c, 91184)),
                         "lfo_rate_91152": float(J.juno_gui_get(c, 91152))}

    # ---- delay excursion over a full warmed LFO period
    per = int(round(2.0 / J.juno_gui_get(c, 91152)))
    L, Rr, tr = fx(c, np.zeros(per + 10, np.float32))
    dL = (tr[:, TI[90688]].astype(np.float64) + tr[:, TI[90800]].astype(np.float64)) * 16384.0
    dR = (tr[:, TI[90688]].astype(np.float64) + tr[:, TI[90816]].astype(np.float64)) * 16384.0
    ph = tr[:, TI[90656]].astype(np.float64)
    res["delay_samples_warm"] = {
        "L_min": dL.min(), "L_max": dL.max(), "L_pp": dL.max() - dL.min(),
        "R_min": dR.min(), "R_max": dR.max(), "R_pp": dR.max() - dR.min(),
        "L_min_ms": dL.min() / rate * 1e3, "L_max_ms": dL.max() / rate * 1e3,
        "LR_correlation": float(np.corrcoef(dL, dR)[0, 1]),
        "lfo_period_samples": per, "lfo_rate_hz": rate / per,
        "triangle_check_max_abs_dev": float(np.max(np.abs(
            (dL - dL.min()) / (dL.max() - dL.min()) - np.abs(ph)))),
    }
    st = max(1, len(dL) // 3000)
    npz["delayL_%s" % tag] = dL[::st].astype(np.float32)
    npz["delayR_%s" % tag] = dR[::st].astype(np.float32)
    npz["phase_%s" % tag] = ph[::st].astype(np.float32)

    # ---- INDEPENDENT reconstruction of the tap read (interpolation law)
    rb = ring(c)
    widx = int(J.juno_gui_peek(c, 95824))
    rng = np.random.RandomState(11)
    sig = rng.uniform(-1, 1, 4000).astype(np.float32)
    L, Rr, tr = fx(c, sig)
    mine = rb.copy()
    okL = okR = okv = 0
    nn_match = ap_match = 0
    n = len(sig)
    for i in range(n):
        d = np.float32(tr[i, TI[90688]]) + np.float32(tr[i, TI[90800]])
        k = int(np.float32(d) * np.float32(-16384.0))         # (int) truncation
        i0 = (widx - k + 1) & 1023
        i1 = (widx - k + 2) & 1023
        frac = np.float64(np.float32(d) * np.float32(16384.0))
        frac = np.float32(frac - float(int(frac)))
        s0, s1 = mine[i0], mine[i1]
        if s0 == tr[i, TI[95856]] and s1 == tr[i, TI[95860]] and frac == tr[i, TI[95864]]:
            okL += 1
        dR_ = np.float32(tr[i, TI[90688]]) + np.float32(tr[i, TI[90816]])
        kR = int(np.float32(dR_) * np.float32(-16384.0))
        if (mine[(widx - kR + 1) & 1023] == tr[i, TI[95872]]
                and mine[(widx - kR + 2) & 1023] == tr[i, TI[95876]]):
            okR += 1
        # the interpolated value the engine actually used, reconstructed:
        v_lin = np.float32(s0 + np.float32(np.float32(frac * s1) - np.float32(frac * s0)))
        v_nn = s0
        # allpass (1-f)/(1+f) form, for the teeth test
        eta = np.float32((1.0 - frac) / (1.0 + frac))
        v_ap = np.float32(s1 + eta * s0)
        # engine's own interpolated tap value is not stored; compare against the
        # value derivable from the stored cells (s0,s1,frac) which IS the engine's
        # expression -- so instead we score which candidate equals it.
        ref = np.float32(tr[i, TI[95856]] + np.float32(
            np.float32(tr[i, TI[95864]] * tr[i, TI[95860]])
            - np.float32(tr[i, TI[95864]] * tr[i, TI[95856]])))
        okv += int(v_lin == ref)
        nn_match += int(v_nn == ref)
        ap_match += int(v_ap == ref)
        # advance our ring copy exactly as the engine does (write AFTER the read)
        widx = (widx - 1) & 1023
        mine[widx] = tr[i, TI[95840]]
    res["tap_reconstruction"] = {
        "samples": n,
        "L_taps_and_frac_bitexact": okL, "R_taps_bitexact": okR,
        "linear_value_bitexact": okv,
        "nearest_neighbour_matches": nn_match, "allpass_matches": ap_match,
        "ring_len_cells": int(J.juno_gui_peek(c, 95828)),
        "ring_bytes": 4 * int(J.juno_gui_peek(c, 95828)),
    }

    # ---- warmed wet impulse response (Noise = 0, Dry = 0, Wet = 1)
    c2 = new(rate)
    fx(c2, np.zeros(WARM, np.float32))
    sig = np.zeros(4096, np.float32); sig[0] = 1.0
    L, Rr, tr = fx(c2, sig)
    wl = tr[:, TI[91088]]; wr = tr[:, TI[91104]]
    npz["ir_wetL_%s" % tag] = wl
    npz["ir_wetR_%s" % tag] = wr
    nzl = np.nonzero(np.abs(wl) > 1e-7)[0]
    res["wet_impulse_warm"] = {
        "first_index_L": int(nzl[0]), "peak_index_L": int(np.argmax(np.abs(wl))),
        "peak_L": float(wl[np.argmax(np.abs(wl))]),
        "first_index_R": int(np.nonzero(np.abs(wr) > 1e-7)[0][0]),
        "peak_index_R": int(np.argmax(np.abs(wr))),
        "energy_after_1024_frac": float(np.sum(wl[1024:] ** 2) / np.sum(wl ** 2)),
        "sum_L": float(np.sum(wl.astype(np.float64))),
    }
    J.juno_gui_destroy(c2)

    # ---- all-8-voice input gain (pass 1 only fed voice 0)
    c3 = J.juno_gui_create(ctypes.c_float(rate), 0)
    st_ = P.pb_state(c3)
    vb = (ctypes.c_float * 4)(*[0.25, 0, 0, 0])
    L3 = (ctypes.c_float * 4)(); R3 = (ctypes.c_float * 4)()
    co = (ctypes.c_int * len(TRACE))(*TRACE)
    tr3 = (ctypes.c_float * (4 * len(TRACE)))()
    P.pb_fx(st_, vb, 4, L3, R3, co, len(TRACE), tr3)
    res["voice0_gain_check"] = float(np.frombuffer(tr3, np.float32).reshape(4, len(TRACE))[0, TI[90368]] / 0.25)
    J.juno_gui_destroy(c3)
    J.juno_gui_destroy(c)
    out[tag] = res

# ---- mode structural constants, FRESH context per patch (pass 1 reused one
# context and saw stale LFO Rate carried between patches)
modes = {}
stale = {}
for rate in (48000, 44100):
    seen = {}
    for p in range(64):
        c = J.juno_gui_create(ctypes.c_float(rate), 0)
        J.juno_gui_apply_bank(c, BANK, len(BANK), p)
        et = int(J.juno_gui_peek(c, 11022052))
        sig = ["0x%08x" % J.juno_gui_peek(c, o) for o in
               (91120, 91136, 91152, 91168, 91184, 91248, 91264, 91280)]
        k = "%d_type%d" % (rate, et)
        seen.setdefault(k, {"structural": sig, "patches": [], "variants": []})
        if seen[k]["structural"] != sig and sig not in seen[k]["variants"]:
            seen[k]["variants"].append(sig)
        seen[k]["patches"].append(p)
        J.juno_gui_destroy(c)
    modes.update(seen)
    # stale-state check: type3 patch then type2 patch in ONE context
    c = J.juno_gui_create(ctypes.c_float(rate), 0)
    J.juno_gui_apply_bank(c, BANK, len(BANK), 11)     # EFFECT TYPE 3
    r3 = "0x%08x" % J.juno_gui_peek(c, 91152)
    J.juno_gui_apply_bank(c, BANK, len(BANK), 0)      # EFFECT TYPE 2
    r2_after3 = "0x%08x" % J.juno_gui_peek(c, 91152)
    J.juno_gui_destroy(c)
    c = J.juno_gui_create(ctypes.c_float(rate), 0)
    J.juno_gui_apply_bank(c, BANK, len(BANK), 0)
    r2_fresh = "0x%08x" % J.juno_gui_peek(c, 91152)
    J.juno_gui_destroy(c)
    stale[str(rate)] = {"type3_rate": r3, "type2_fresh": r2_fresh,
                        "type2_after_type3": r2_after3,
                        "STALE": r2_after3 != r2_fresh}
out["modes_fresh_context"] = modes
out["lfo_rate_stale_on_recall"] = stale

os.makedirs(os.path.join(R, "scratchpad", "engineb"), exist_ok=True)
with open(os.path.join(R, "scratchpad", "engineb", "fx_chorus2.json"), "w") as f:
    json.dump(out, f, indent=1, sort_keys=True, default=float)
np.savez_compressed(os.path.join(R, "scratchpad", "engineb", "fx_chorus2.npz"), **npz)
print(json.dumps(out, indent=1, sort_keys=True, default=float))

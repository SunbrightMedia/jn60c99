#!/usr/bin/env python3
"""pyna_oracle.py -- the acoustic oracle for jetsynth.

RUN ONLY UNDER THE ORACLE VENV ($JET_ORACLE/venv/bin/python; see
setup_oracle.sh). It imports MIT pyNA (pinned commit, unmodified) and calls
pyNA's OWN source functions -- jet_mixing_source, jet_shock_source,
core_source, fan_source (Heidmann/ANOPP methods, SAE ARP876, Zorumski) --
with pyNA's OWN default settings, airframe and data tables.

This file is PLUMBING. It never evaluates an acoustic formula itself. The one
place it steps inside pyNA is the fan TONE split (see fan_parts): it wraps
pyNA's calculate_harmonics, records the arguments pyNA passed, and calls the
ORIGINAL function again on a probe band grid to read one harmonic at a time.

  verify   compare this driver's output with NASA's ANOPP source spectra that
           ship with pyNA (cases/nasa_stca_standard/verification). This is the
           check that the DRIVER is right: a wrong input mapping shows up here.
"""
import os, sys, copy
import numpy as np

ORACLE = os.environ.get("JET_ORACLE")
if not ORACLE:
    raise SystemExit("set JET_ORACLE (see jetsynth/tools/setup_oracle.sh)")
PKG_ROOT = os.path.join(ORACLE, "pyNA")
PKG = os.path.join(PKG_ROOT, "pyNA")
sys.path.insert(0, PKG_ROOT)
os.environ["pyna_language"] = "python"

import pandas as pd                                            # noqa: E402
from pyNA.pyna import pyna                                     # noqa: E402
from pyNA.src.noise_src_py import fan_source as _fan           # noqa: E402
from pyNA.src.noise_src_py.jet_source import (                 # noqa: E402
    jet_mixing_source, jet_shock_source)
from pyNA.src.noise_src_py.core_source import core_source      # noqa: E402
from pyNA.src.noise_src_py.spl import spl as _spl              # noqa: E402
from pyNA.src.noise_src_py.normalization_engine_variables import (  # noqa: E402
    NormalizationEngineVariables)

CASE = "nasa_stca_standard"
COMPS = ("jet_mixing", "jet_shock", "core", "fan_inlet", "fan_discharge")
_ORIG_HARM = _fan.calculate_harmonics


class _Opt:
    """Stand-in for an OpenMDAO component: pyNA's source functions read only
    `.options[...]`, and NormalizationEngineVariables.compute reads only
    `.options['settings']`."""
    def __init__(self, **kw):
        self.options = kw


def load(**overrides):
    """pyNA, initialised exactly as pyNA initialises itself. `overrides` are
    pyNA constructor arguments (its own names)."""
    p = pyna(case_name=CASE, pyna_directory=PKG, **overrides)
    p.initialize()
    return p


def _settings(p, **kw):
    s = copy.deepcopy(p.settings)
    for c in ("fan_inlet_source", "fan_discharge_source", "core_source",
              "jet_mixing_source", "jet_shock_source", "airframe_source"):
        s[c] = True               # the normaliser must emit every variable
    s.update(kw)
    return s


def normalise(p, eng, amb, settings):
    """eng: raw engine state (pyNA timeseries column names); amb: c_0, T_0,
    p_0, rho_0, M_0. Runs pyNA's own NormalizationEngineVariables.compute."""
    a = lambda v: np.atleast_1d(np.asarray(v, dtype=float))
    raw = {
        "c_0": a(amb["c_0"]), "T_0": a(amb["T_0"]), "p_0": a(amb["p_0"]),
        "rho_0": a(amb["rho_0"]),
        "V_j": a(eng["Jet V [m/s]"]), "rho_j": a(eng["Jet rho [kg/m3]"]),
        "A_j": a(eng["Jet A [m2]"]), "Tt_j": a(eng["Jet Tt [K]"]),
        "mdoti_c": a(eng["Core mdot [kg/s]"]), "Tti_c": a(eng["Core Tti [K]"]),
        "Ttj_c": a(eng["Core Ttj [K]"]), "Pti_c": a(eng["Core Pt [Pa]"]),
        "DTt_des_c": a(eng["Core DT_t [K]"]),
        "DTt_f": a(eng["Fan delta T [K]"]), "mdot_f": a(eng["Fan mdot in [kg/s]"]),
        "N_f": a(eng["Fan N [rpm]"]), "A_f": a(eng["Fan A [m2]"]),
        "d_f": a(eng["Fan d [m]"]),
    }
    out = {}
    NormalizationEngineVariables.compute(_Opt(settings=settings), raw, out)
    out.update({"M_0": a(amb["M_0"]), "c_0": a(amb["c_0"]), "T_0": a(amb["T_0"]),
                "rho_0": a(amb["rho_0"]), "M_j": a(eng["Jet M [-]"]),
                "TS": a(eng.get("TS [-]", 0.0))})
    return out


def spectra(p, eng, amb, theta, **setkw):
    """msap (re p_ref^2, at r_0, all engines) of each component, 24 bands,
    for ONE operating point and ONE polar angle theta [deg]."""
    s = _settings(p, **setkw)
    inp = normalise(p, eng, amb, s)
    src = _Opt(settings=s, data=p.noise_data, airframe=p.airframe, n_t=1)
    th = np.array([float(theta)])
    shield = np.zeros((1, s["n_frequency_bands"]))
    return {
        "jet_mixing": jet_mixing_source(src, th, inp)[0],
        "jet_shock": jet_shock_source(src, th, inp)[0],
        "core": core_source(src, th, inp)[0],
        "fan_inlet": _fan.fan_source(src, th, shield, inp, "fan_inlet")[0],
        "fan_discharge": _fan.fan_source(src, th, shield, inp, "fan_discharge")[0],
    }


def fan_parts(p, eng, amb, theta, n_harm=10, **setkw):
    """Split pyNA's fan output into what a synthesiser needs:
         bb[comp]      broadband 1/3-octave msap (tones removed)
         ct[comp]      combination-tone (buzz-saw) 1/3-octave msap
         tones[comp]   [(freq_hz, msap)] per BPF harmonic, liner applied
         bpf, rpm_obs  as pyNA computed them (Doppler included)
    Method: pyNA's fan_source is run three times with its own
    calculate_harmonics wrapped. The wrapper records pyNA's arguments; tone
    power of harmonic h is (pyNA calc with n_harmonics=h) - (n_harmonics=h-1)
    on a probe grid whose band h*bpf is the only live band, so every harmonic
    is read in isolation with pyNA's own code. The liner is pyNA's own table
    evaluated at the harmonic frequency."""
    rec = {}

    def spy(settings, freq, th, tI, tX, i_cut, M_tip, bpf, comp):
        rec[comp] = (settings, th, tI, tX, i_cut, M_tip, bpf)
        z = np.zeros(settings["n_frequency_bands"])
        return z, z.copy()

    res = {"bb": {}, "ct": {}, "tones": {}}
    try:
        _fan.calculate_harmonics = spy
        a = spectra(p, eng, amb, theta, fan_combination_tones=False, **setkw)
        b = spectra(p, eng, amb, theta, fan_combination_tones=True, **setkw)
    finally:
        _fan.calculate_harmonics = _ORIG_HARM
    s0 = _settings(p, **setkw)
    for comp in ("fan_inlet", "fan_discharge"):
        res["bb"][comp] = a[comp]
        res["ct"][comp] = b[comp] - a[comp]
        settings, th, tI, tX, i_cut, M_tip, bpf = rec[comp]
        tones = []
        for h in range(1, n_harm + 1):
            probe = np.array([bpf / 100.0, bpf / 99.0, h * bpf])
            def one(nh):
                st = dict(settings); st["n_harmonics"] = nh; st["n_frequency_bands"] = 3
                dp, dpx = _ORIG_HARM(st, probe, th, tI, tX, i_cut, M_tip, bpf, comp)
                return (dp if comp == "fan_inlet" else dpx)[2]
            pw = one(h) - (one(h - 1) if h > 1 else 0.0)
            pw *= p.airframe.n_eng
            if s0["fan_liner_suppression"]:
                f = p.noise_data.supp_fi_f if comp == "fan_inlet" else p.noise_data.supp_fd_f
                pw *= float(np.ravel(f(th, h * bpf))[0])
            # fan_source adds calculate_harmonics' output to its msap with NO
            # p_ref division (fan_source.py: msap_j = ... + dp), so neither do we.
            tones.append((h * bpf, pw))
        res["tones"][comp] = tones
        res["bpf"] = bpf
        res["i_cut"] = i_cut
        res["M_tip"] = M_tip
    return res


def spl_db(msap, amb):
    """pyNA's own SPL conversion (spl.py): the source functions return msap
    normalised by (rho_0 c_0^2)^2 / p_ref^2; this restores dB re 20 uPa."""
    return _spl(_Opt(n_t=1), np.atleast_2d(msap), np.atleast_1d(amb["rho_0"]),
                np.atleast_1d(amb["c_0"]))[0]


# ---------------------------------------------------------------- verification
def _nasa(sheet_file, sheet, ts):
    v = pd.read_excel(os.path.join(PKG, "cases", CASE, "verification", sheet_file),
                      sheet_name=sheet, header=None).values
    blk = v[26 * ts + 1: 26 * ts + 26, :]        # OVERALL + 24 bands
    return blk[1:, 1:18].astype(float)             # 24 bands x theta 10..170


def _timestep(ts):
    eng = pd.read_csv(os.path.join(PKG, "cases", CASE, "engine", "Engine_to.csv")).iloc[ts]
    path = pd.read_csv(os.path.join(PKG, "cases", CASE, "trajectory", "Trajectory_to.csv")).iloc[ts]
    amb = {k: path["%s [%s]" % (k, u)] for k, u in
           (("c_0", "m/s"), ("T_0", "K"), ("p_0", "Pa"), ("rho_0", "kg/m3"), ("M_0", "-"))}
    return eng.to_dict(), amb


def _plant(eng, amb, plant):
    """A deliberate driver defect, so each gate is SEEN TO FAIL."""
    eng = dict(eng); amb = dict(amb)
    if plant == "rpm":
        eng["Fan N [rpm]"] *= 1.02
    elif plant == "vjet":
        eng["Jet V [m/s]"] *= 1.02
    elif plant == "tt":
        eng["Core Ttj [K]"] *= 1.02
    elif plant == "mach":
        amb["M_0"] += 0.02
    return eng, amb


def gate_driver(steps=(0, 152), plant=None):
    """GATE A -- this driver vs pyNA's OWN OpenMDAO pipeline
    (pyna.compute_noise_source_distribution), every component, theta 0..180,
    24 bands. Must be EXACTLY 0.0 dB: the driver adds no arithmetic."""
    ref_p = load()
    ref_p.initialize()
    worst = 0.0
    for comp in COMPS:
        for ts in steps:
            for k in ("fan_inlet_source", "fan_discharge_source", "core_source",
                      "jet_mixing_source", "jet_shock_source", "airframe_source",
                      "all_sources"):
                ref_p.settings[k] = False
            ref_p.settings[comp + "_source"] = True
            ref_p.settings["x_observer_array"] = ([1, 1, 1],)
            pyna.compute_noise_source_distribution(ref_p, timestep=ts)
            ref = ref_p.noise_timeseries.get_val("noise.spl")[0]
            eng, amb = _plant(*_timestep(ts), plant)
            q = load()
            mine = np.array([spl_db(spectra(q, eng, amb, th)[comp], amb)
                             for th in range(0, 181, 10)])
            e = float(np.max(np.abs(mine - ref)))
            worst = max(worst, e)
        print("  A %-14s max|driver - pyNA pipeline| = %.3g dB" % (comp, e))
    return worst


# Measured oracle accuracy vs NASA (see jetsynth/docs/ORACLE.md). A gate that
# passes must stay inside these; a planted defect must break them.
NASA_TOL = {"jet_mixing": 0.20, "core": 0.60, "fan_inlet BB": 0.30,
            "fan_discharge BB": 0.30, "fan_inlet tones": 1.00,
            "fan_discharge tones": 1.00}
MASK_DB = 50.0      # bands more than 50 dB under the loudest source are not graded


def gate_nasa(steps=range(0, 209, 8), plant=None):
    """GATE B -- pyNA (through this driver) vs NASA's ANOPP source spectra for
    the STCA take-off, 27 time steps x 17 angles. Broadband per band; fan
    tones by total tone power (NASA's RS sheets), because a Doppler-shifted
    tone near a 1/3-octave edge is booked one band apart by the two codes at
    the same level (measured: 115.1 vs 115.3 dB, ts 32, theta 100)."""
    p = load()
    fanf = "Fan Module Source.xlsx"
    sheets = {"jet_mixing": ("Jet Module Source.xlsx", "Full"),
              "core": ("Core Module Source.xlsx", "Full"),
              "fan_inlet BB": (fanf, "Suppressed Inlet BB"),
              "fan_discharge BB": (fanf, "Suppressed Discharge BB"),
              "fan_inlet tones": (fanf, "Suppressed Inlet RS"),
              "fan_discharge tones": (fanf, "Suppressed Discharge RS")}
    worst = {k: 0.0 for k in sheets}
    fmax = p.noise_data.f[-1] * 2 ** (1 / 6.0)
    for ts in steps:
        eng, amb = _plant(*_timestep(ts), plant)
        refs = {k: _nasa(fn, sh, ts) for k, (fn, sh) in sheets.items()}
        for j, th in enumerate(range(10, 171, 10)):
            top = max(np.max(r[:, j]) for r in refs.values())
            sp = spectra(p, eng, amb, th)
            fp = fan_parts(p, eng, amb, th)
            mine = {"jet_mixing": spl_db(sp["jet_mixing"], amb),
                    "core": spl_db(sp["core"], amb),
                    "fan_inlet BB": spl_db(fp["bb"]["fan_inlet"], amb),
                    "fan_discharge BB": spl_db(fp["bb"]["fan_discharge"], amb)}
            for k, v in mine.items():
                r = refs[k][:, j]
                m = r >= top - MASK_DB
                if m.any():
                    worst[k] = max(worst[k], float(np.max(np.abs(v - r)[m])))
            for comp in ("fan_inlet", "fan_discharge"):
                r = refs[comp + " tones"][:, j]
                rt = 10 * np.log10(np.sum(10 ** (r / 10)))
                if rt < top - MASK_DB:
                    continue
                pw = sum(w for f, w in fp["tones"][comp] if f <= fmax)
                mt = spl_db(np.array([max(pw, 1e-99)]), amb)[0]
                worst[comp + " tones"] = max(worst[comp + " tones"], abs(mt - rt))
    ok = True
    for k, v in worst.items():
        good = v <= NASA_TOL[k]
        ok &= good
        print("  B %-20s max|pyNA - NASA| = %6.3f dB  (tol %.2f) %s"
              % (k, v, NASA_TOL[k], "ok" if good else "FAIL"))
    return ok


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else "all"
    plant = sys.argv[2] if len(sys.argv) > 2 else None
    ok = True
    if cmd in ("driver", "all"):
        w = gate_driver(plant=plant)
        print("GATE A (driver == pyNA pipeline): %s" % ("PASS" if w == 0.0 else "FAIL"))
        ok &= w == 0.0
    if cmd in ("nasa", "all"):
        b = gate_nasa(plant=plant)
        print("GATE B (pyNA == NASA ANOPP within measured tolerance): %s"
              % ("PASS" if b else "FAIL"))
        ok &= b
    sys.exit(0 if ok else 1)

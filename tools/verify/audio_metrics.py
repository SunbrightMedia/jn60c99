#!/usr/bin/env python3
"""audio_metrics.py -- the LISTEN kit (charter 7b "the port must play").

Never validate by ear, never ask the user to A/B -- but a port that plays
must be SHOWN to play, with numbers. These are the measurements that were
rebuilt five times during the JX-3P robustness arc (2026-09-04); once here,
usable from an oracle render (uint32 words) or a C-twin render (floats).

  f0_autocorr(x, sr)        pitch by autocorrelation (zero-crossing f0 LIES
                            on complex tones -- METHOD_PLAYBOOK 87 notes)
  spectral_peaks(x, sr, k)  top-k spectral lines (Hz, magnitude)
  tone_fraction(x, sr, hz)  share of spectral energy within +-bw of hz --
                            "is THE note there?" (0.28 for a clean saw C4,
                            0.006 for click mush)
  block_profile(x, n)       per-block rms/max/zero-crossings -- distinguishes
                            a sustained tone from a click train at a glance
  sketch(x, i0, n)          ASCII waveform around index i0
  words_to_floats(words)    oracle uint32 -> float, NaN -> 0 and counted
  midi_hz(note)             equal temper reference
  verdict(x, sr, note)      one-line PASS/FAIL against the expected pitch

Requires numpy (pip install numpy).
"""
import struct, math
import numpy as np


def midi_hz(note):
    return 440.0 * 2.0 ** ((note - 69) / 12.0)


def words_to_floats(words):
    f = np.array(struct.unpack("<%df" % len(words),
                               struct.pack("<%dI" % len(words), *words)))
    nan = int(np.isnan(f).sum())
    return np.nan_to_num(f), nan


def f0_autocorr(x, sr=44100.0, fmin=15.0, fmax=3000.0):
    x = np.asarray(x, dtype=np.float64)
    if np.abs(x).max() < 1e-9:
        return 0.0
    x = x - x.mean()
    n = len(x)
    X = np.fft.rfft(x, 2 * n)
    ac = np.fft.irfft(X * np.conj(X))[:n]
    lag0, lag1 = int(sr / fmax), min(int(sr / fmin), n - 1)
    seg = ac[lag0:lag1]
    # octave guard: multiples of the true lag peak almost as high; take the
    # SMALLEST lag within 10% of the maximum (a pure saw ties at 2T)
    top = seg.max()
    cand = np.where(seg >= 0.9 * top)[0]
    i = int(cand[0])
    while i + 1 < len(seg) and seg[i + 1] > seg[i]:      # climb to the local max
        i += 1
    l = float(lag0 + i)
    if 0 < i < len(seg) - 1:                              # parabolic refinement
        a, b, c = seg[i - 1], seg[i], seg[i + 1]
        den = a - 2 * b + c
        if den != 0:
            l += 0.5 * (a - c) / den
    return sr / l


def spectral_peaks(x, sr=44100.0, k=6, guard=4):
    x = np.asarray(x, dtype=np.float64)
    x = x - x.mean()
    n = len(x)
    X = np.abs(np.fft.rfft(x * np.hanning(n)))
    out = []
    for _ in range(k):
        i = int(np.argmax(X))
        if X[i] <= 0:
            break
        out.append((i * sr / n, float(X[i])))
        X[max(0, i - guard):i + guard + 1] = 0
    return out


def tone_fraction(x, sr, hz, bw=12.0):
    x = np.asarray(x, dtype=np.float64)
    x = x - x.mean()
    n = len(x)
    X = np.abs(np.fft.rfft(x * np.hanning(n)))
    fr = np.fft.rfftfreq(n, 1.0 / sr)
    m = (fr > hz - bw) & (fr < hz + bw)
    return float(X[m].sum() / (X.sum() + 1e-12))


def block_profile(x, n=1024):
    x = np.asarray(x, dtype=np.float64)
    rows = []
    for k in range(len(x) // n):
        seg = x[k * n:(k + 1) * n]
        zc = int(((seg[:-1] < 0) & (seg[1:] >= 0)).sum())
        rows.append((k, math.sqrt(float((seg ** 2).mean())),
                     float(np.abs(seg).max()), zc))
    return rows


def sketch(x, i0, n=64, scale=None):
    x = np.asarray(x, dtype=np.float64)
    seg = x[max(0, i0):i0 + n]
    scale = scale or (40.0 / (np.abs(seg).max() + 1e-12))
    lines = []
    for k, v in enumerate(seg):
        bar = ("#" if v > 0 else "-") * int(min(40, abs(v) * scale))
        lines.append("%6d %+9.5f %s" % (i0 + k, v, bar))
    return "\n".join(lines)


def verdict(x, sr, note, cents_tol=25.0, min_fraction=0.10):
    """PASS when the autocorrelation pitch is within cents_tol of the note
    AND the note's line carries at least min_fraction of the spectrum."""
    want = midi_hz(note)
    f0 = f0_autocorr(x, sr)
    frac = tone_fraction(x, sr, want)
    cents = 1200.0 * math.log2(f0 / want) if f0 > 0 else float("inf")
    ok = abs(cents) <= cents_tol and frac >= min_fraction
    return ok, ("%s note %d: f0 %.2f Hz (%+.0f cents), tone fraction %.3f, "
                "peak %.4g" % ("PASS" if ok else "FAIL", note, f0, cents,
                               frac, float(np.abs(x).max())))


if __name__ == "__main__":
    # self-test: a synthetic saw at C4 must PASS, white noise must FAIL
    sr = 44100.0
    t = np.arange(16384) / sr
    saw = 2.0 * ((t * midi_hz(60)) % 1.0) - 1.0
    ok, msg = verdict(saw, sr, 60)
    print(msg); assert ok
    rng = np.random.default_rng(1)
    ok, msg = verdict(rng.standard_normal(16384), sr, 60)
    print(msg); assert not ok
    print("audio_metrics self-test OK")

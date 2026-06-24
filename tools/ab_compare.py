#!/usr/bin/env python3
"""ab_compare.py — Phase 0 audio A/B: quantify how far the port is from a plugin
reference render. Loads two WAVs (reference, port), resamples to a common rate,
time-aligns by cross-correlation, and reports per-sample, level, envelope, and
spectral error so a divergence is a number, not a vibe.

    usage: ab_compare.py <reference.wav> <port.wav> [--plot prefix]

Metrics (all higher-error = worse):
  level diff       : RMS level mismatch, dB
  residual (gain-normalized) : best-scalar-gain residual error, dB below ref RMS
                               (>~ -1 dB = essentially uncorrelated; < -20 dB = close)
  envelope error   : RMS of (ref_env - port_env) over 20 ms windows, dB
  log-spectral dist: mean |log10(|REF|) - log10(|PORT|)| over 1/3-oct bands (0 = identical)
  correlation      : peak normalized cross-correlation (1.0 = perfectly aligned/shaped)
"""
import sys, wave, math
import numpy as np

def load(path):
    w = wave.open(path, 'rb')
    sr, ch, n, sw = w.getframerate(), w.getnchannels(), w.getnframes(), w.getsampwidth()
    raw = w.readframes(n); w.close()
    if sw != 2:
        raise SystemExit(f"{path}: only 16-bit PCM supported (got {sw*8}-bit)")
    a = np.frombuffer(raw, dtype='<i2').astype(np.float64) / 32768.0
    if ch == 2:
        a = a.reshape(-1, 2).mean(axis=1)   # mono mix for comparison
    return sr, a

def resample(x, sr_in, sr_out):
    if sr_in == sr_out:
        return x
    n_out = int(round(len(x) * sr_out / sr_in))
    # FFT resample (band-limited); good enough for comparison
    X = np.fft.rfft(x)
    n_in = len(x)
    # build output spectrum
    if n_out >= n_in:
        Y = np.zeros(n_out // 2 + 1, dtype=complex)
        Y[:len(X)] = X
    else:
        Y = X[:n_out // 2 + 1].copy()
    y = np.fft.irfft(Y, n_out) * (n_out / n_in)
    return y

def align(ref, port):
    """find integer lag maximizing cross-correlation; return aligned, trimmed pair + lag."""
    n = min(len(ref), len(port))
    a, b = ref[:n], port[:n]
    # cross-correlate via FFT, search a +/-0.2s-ish window for speed
    N = 1
    while N < 2 * n: N <<= 1
    fa = np.fft.rfft(a, N); fb = np.fft.rfft(b, N)
    cc = np.fft.irfft(fa * np.conj(fb), N)
    cc = np.concatenate([cc[-n:], cc[:n]])
    lag = np.argmax(cc) - n
    if lag > 0:   port_a, ref_a = port[lag:], ref
    elif lag < 0: port_a, ref_a = port, ref[-lag:]
    else:         port_a, ref_a = port, ref
    m = min(len(ref_a), len(port_a))
    return ref_a[:m], port_a[:m], lag

def envelope(x, sr, win=0.02):
    w = max(1, int(sr * win)); ne = len(x) // w
    e = np.sqrt(np.mean(x[:ne * w].reshape(ne, w) ** 2, axis=1) + 1e-20)
    return e

def avg_spectrum(x, sr, fft=8192):
    if len(x) < fft: x = np.pad(x, (0, fft - len(x)))
    hop = fft // 2; win = np.hanning(fft); acc = None; cnt = 0
    for s in range(0, len(x) - fft, hop):
        X = np.abs(np.fft.rfft(x[s:s+fft] * win))
        acc = X if acc is None else acc + X; cnt += 1
    return (acc / max(cnt, 1)), np.fft.rfftfreq(fft, 1.0 / sr)

def third_octave(mag, freqs):
    bands = []
    f = 31.25
    while f < freqs[-1]:
        lo, hi = f / 2**(1/6), f * 2**(1/6)
        sel = (freqs >= lo) & (freqs < hi)
        bands.append((f, mag[sel].mean() if sel.any() else 1e-9))
        f *= 2**(1/3)
    return bands

def db(x): return 20 * math.log10(max(x, 1e-12))

def main():
    if len(sys.argv) < 3:
        print(__doc__); sys.exit(2)
    refp, portp = sys.argv[1], sys.argv[2]
    sr_r, ref = load(refp); sr_p, port = load(portp)
    sr = min(sr_r, sr_p)                       # compare at the lower rate (no invented HF)
    ref = resample(ref, sr_r, sr); port = resample(port, sr_p, sr)
    ref_a, port_a, lag = align(ref, port)

    rms_ref = np.sqrt(np.mean(ref_a**2) + 1e-20)
    rms_port = np.sqrt(np.mean(port_a**2) + 1e-20)
    g = np.dot(ref_a, port_a) / (np.dot(port_a, port_a) + 1e-20)   # best scalar gain
    resid = ref_a - g * port_a
    resid_db = db(np.sqrt(np.mean(resid**2)) / rms_ref)
    corr = np.dot(ref_a, port_a) / (np.linalg.norm(ref_a) * np.linalg.norm(port_a) + 1e-20)

    er, ep = envelope(ref_a, sr), envelope(port_a, sr)
    m = min(len(er), len(ep)); env_db = db(np.sqrt(np.mean((er[:m]-ep[:m])**2)) / (rms_ref))

    mr, fr = avg_spectrum(ref_a, sr); mp, _ = avg_spectrum(port_a, sr)
    mr = mr / (mr.max()+1e-12); mp = mp / (mp.max()+1e-12)
    br = third_octave(mr, fr); bp = third_octave(mp, fr)
    lsd = np.mean([abs(math.log10(b1[1]+1e-9) - math.log10(b2[1]+1e-9)) for b1,b2 in zip(br,bp)])

    print(f"=== A/B: ref={refp}  port={portp} ===")
    print(f"  compare SR        : {sr} Hz   (align lag {lag} samples = {lag/sr*1000:.1f} ms)")
    print(f"  level (RMS)       : ref {db(rms_ref):6.1f} dBFS | port {db(rms_port):6.1f} dBFS | diff {db(rms_port)-db(rms_ref):+.1f} dB")
    print(f"  residual (gain-norm): {resid_db:6.1f} dB below ref   (lower=better; <-20 close, >-3 ~uncorrelated)")
    print(f"  waveform corr     : {corr:6.3f}              (1.0 = identical shape)")
    print(f"  envelope error    : {env_db:6.1f} dB             (lower=better)")
    print(f"  log-spectral dist : {lsd:6.3f}              (0 = identical timbre; >0.3 audibly off)")
    # biggest per-band timbre gaps
    gaps = sorted(((abs(math.log10(b1[1]+1e-9)-math.log10(b2[1]+1e-9)), b1[0], b1[1], b2[1])
                   for b1,b2 in zip(br,bp)), reverse=True)[:6]
    print("  worst timbre bands (Hz: ref_dB vs port_dB):")
    for d,f,r,p in gaps:
        print(f"     {f:7.0f} Hz : {db(r):6.1f} vs {db(p):6.1f}   (Δ {db(r)-db(p):+.1f} dB)")

    if '--plot' in sys.argv:
        pre = sys.argv[sys.argv.index('--plot')+1]
        with open(pre+'_env.csv','w') as fcsv:
            fcsv.write("t,ref_env_db,port_env_db\n")
            for i in range(m): fcsv.write(f"{i*0.02:.3f},{db(er[i]):.2f},{db(ep[i]):.2f}\n")
        print(f"  wrote {pre}_env.csv")

if __name__ == '__main__':
    main()

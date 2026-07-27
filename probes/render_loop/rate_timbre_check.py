#!/usr/bin/env python3
"""Does the PLUGIN ITSELF sound different at 44100 vs 48000?

Motivation (structural, not capture-derived): the webapp builds the engine at the
browser AudioContext rate (typically 48000); the user's DAW runs 44100. Every
gate proves port==plugin AT THE SAME RATE, so a genuine rate-dependence in the
plugin would be invisible to every gate yet audible to the user.

Renders BS Solid through the PLUGIN'S OWN DSP at both rates and compares the
sustained-portion spectrum in the band under discussion. Oracle-only (Unicorn),
no capture involved anywhere. Purely a plugin-vs-plugin measurement."""
import sys, os, struct, math
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import numpy as np
import e2e_emu as E, real_recall as R, recall_render_ab as RA

BANK = os.environ.get('JUNO_BANK',
    '/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/0e8b9cb5-Chillwave.bin')
PATCH = int(os.environ.get('JUNO_PATCH', '3'))
SECS  = 2.0
NOTE, VEL = 60, 100

bank = open(BANK, 'rb').read()
leaves = R.leaf_table()

def render(sr):
    n = int(sr * SECS)
    e = RA.prepare_recall(PATCH, bank, leaves, E, R, sr)
    e.note_on(NOTE, VEL)
    L, Rr = e.render(n, block=512)
    del e
    f = lambda bits: struct.unpack('<f', struct.pack('<I', bits))[0]
    l = np.array([f(x) for x in L], dtype=np.float64)
    r = np.array([f(x) for x in Rr], dtype=np.float64)
    return (l + r) * 0.5, sr

def spectrum(x, sr, t0, t1):
    seg = x[int(t0*sr):int(t1*sr)]
    seg = seg * np.hanning(len(seg))
    S = np.abs(np.fft.rfft(seg)) / len(seg)
    fr = np.fft.rfftfreq(len(seg), 1.0/sr)
    return fr, S

def band(fr, S, lo, hi):
    m = (fr >= lo) & (fr < hi)
    return float(np.sqrt(np.mean(S[m]**2))) if m.any() else 0.0

out = {}
for sr in (44100.0, 48000.0):
    x, _ = render(sr)
    out[sr] = (x, sr)
    print("rendered sr=%g  peak=%.6f  rms=%.6f" % (sr, np.max(np.abs(x)), np.sqrt(np.mean(x**2))), flush=True)

BANDS = [(50,200),(200,400),(400,780),(780,1400),(1400,2200),(2200,3000),(3000,6000),(6000,12000)]
print("\nSUSTAIN window 0.6-1.8 s, mono sum, band RMS (dB re 1.0), plugin vs plugin:")
print("  band(Hz)        44100 dB      48000 dB     delta(48k-44.1k) dB")
ref = {}
for lo, hi in BANDS:
    vals = {}
    for sr in (44100.0, 48000.0):
        x, _ = out[sr]
        fr, S = spectrum(x, sr, 0.6, 1.8)
        vals[sr] = band(fr, S, lo, hi)
    d = 20*math.log10(vals[48000.0]/vals[44100.0]) if vals[44100.0] > 0 and vals[48000.0] > 0 else float('nan')
    db = lambda v: 20*math.log10(v) if v > 0 else float('-inf')
    print("  %5d-%-5d   %9.2f    %9.2f      %+7.2f" % (lo, hi, db(vals[44100.0]), db(vals[48000.0]), d))

#!/usr/bin/env python3
"""jp8_drive2_triage.py -- confound-removal probe for a sweep FAIL on DRIVE2 (process A only, Unicorn).
Boot patch P on drive2 (jp8_emu default: factory HOST, HOSTPARAM recall, no snap), apply each override ENG=RAW through
HOSTPARAM (the drive's own path -- PORT_LESSONS 2: an override takes the recall's path), let the plugin's walker settle
4096 samples (no snap exists on drive2), then per key the sweep's measurement: EARLY window (1024..17408 after note-on)
DRY f0 by autocorrelation, harmonicity, the engine's own pitch cells [state+0x16e0]/[+0x16f0] at window start and end
(expected f = midi_hz(key)*2^(cell-2)), the LATE window (49152..65536) when EARLY fails; release: 24000 samples, else the
3 s tail rule. Nothing is tuned: an override is a confound REMOVED to see whether the law then holds.
usage: jp8_drive2_triage.py <patch> [ENG=RAW ...] [keys=48,60,72] [tag=name]   -> prints; redirect to jp8/logs/drive2/"""
import sys, os, time, math, struct
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE); sys.path.insert(0, "/home/user/jn60c99/tools/verify"); sys.path.insert(0, "/home/user/jn60c99/jx3p/tools")
os.environ.setdefault("JP8_EMU_QUIET", "1")
import numpy as np
import jp8_emu as J, audio_metrics as AM
from jx_listen import track_verdict
SR = 44100.0
patch = int(sys.argv[1]); ov = []; keys = (48, 60, 72); tag = ""
for a in sys.argv[2:]:
    k, v = a.split("=")
    if k == "keys": keys = tuple(int(x) for x in v.split(","))
    elif k == "tag": tag = v
    else: ov.append((int(k), int(v)))
t0 = time.time()
def log(m): print("[%6.1fs] %s" % (time.time() - t0, m), flush=True)
jp = J.JP8(); assert not jp.legacy
jp.boot(sr=SR, patch=patch); uc = jp.uc
bank = J.bank_bytes(); blob = J.patch_blob(bank, patch)
import pe_recon
rows = pe_recon.PE(J.BIN).params([e for e, _ in ov])["rows"] if ov else {}
for e, v in ov:
    was = J.pool_value(blob, e - J.POOL_BASE_ID) if 0 <= e - J.POOL_BASE_ID < 80 and (e - J.POOL_BASE_ID) in J.ACTIVE_POOLS else None
    jp.param(e, v)
    log("override eng %d %s: bank raw %s -> %d through HOSTPARAM (host id 0x%x)" % (e, rows[e]["name"], was, v, jp.host_id(e)))
dry, Lw, Rw = jp.render_both(4096); L, nanL = AM.words_to_floats(Lw); c = jp.ramp_census()
log("patch %d %r%s: walker settle 4096: dry peak %.3g master peak %.3g NaN %d; live ramps %d (NaN/inf %d)" % (
    patch, J.patch_name(bank, patch).strip(), (" [%s]" % tag) if tag else "", max(abs(x) for x in dry), float(np.abs(L).max()), nanL + jp.dry_nan, c["live"], c["live_bad"]))
def cells(key):
    o = []
    for u in range(8):
        c1, c2 = struct.unpack("<ff", uc.mem_read(jp.state[u] + 0x16e0, 4) + uc.mem_read(jp.state[u] + 0x16f0, 4))
        if c1 != 0 or c2 != 0: o.append((u, AM.midi_hz(key) * 2 ** (c1 - 2.0), AM.midi_hz(key) * 2 ** (c2 - 2.0)))
    return o
def measure(key):
    e0 = cells(key); d, Lw, Rw = jp.render_both(16384); e1 = cells(key); d = np.array(d)
    f0 = AM.f0_autocorr(d, SR); h = AM.harmonicity(d, SR, f0) if f0 > 0 else 0.0
    eng = e0 + e1
    dev = min((abs(1200 * math.log2(f0 / fe)) for u, f1, f2 in eng for fe in (f1, f2)), default=float('inf')) if f0 > 0 else float('inf')
    c = 1200 * math.log2(f0 / AM.midi_hz(key)) if f0 > 0 else float('nan')
    pk = AM.spectral_peaks(d, SR)[:3] if hasattr(AM, "spectral_peaks") else []
    return dict(f0=f0, h=h, c=c, dev=dev, e0=e0, e1=e1, peaks=pk, nan=jp.dry_nan)
res = []; fails = 0
for key in keys:
    jp.note_on(key, 100); jp.render_both(1024)
    m = measure(key); win = "EARLY"
    if not (m["h"] >= 0.80 and m["dev"] <= 25):
        jp.render_both(49152 - 17408); m2 = measure(key)
        if (m2["h"] >= 0.80 and m2["dev"] <= 25) or (m2["h"] > m["h"] and m2["dev"] <= m["dev"]): m, win = m2, "LATE"
    ok = m["h"] >= 0.80 and m["dev"] <= 25; fails += not ok
    log("%s key %d %s: DRY f0 %.2f Hz (%+.0f c vs key) harmonic %.3f | engine start %s end %s | dev %.1f c | spectral peaks %s | NaN %d" % (
        "PASS" if ok else "FAIL", key, win, m["f0"], m["c"], m["h"], " ".join("u%d %.2f/%.2f" % e for e in m["e0"][:2]),
        " ".join("u%d %.2f/%.2f" % e for e in m["e1"][:2]), m["dev"], m["peaks"], m["nan"]))
    res.append((key, m["f0"], m["h"]))
    jp.note_off(key, 64)
    tail, Lw, Rw = jp.render_both(24000); tail = np.array(tail); Lt, nt = AM.words_to_floats(Lw)
    hd_, ld_ = float(np.abs(tail[:4096]).max()), float(np.abs(tail[-4096:]).max()); hm_, lm_ = float(np.abs(Lt[:4096]).max()), float(np.abs(Lt[-4096:]).max())
    okd = ld_ < 0.05 * max(hd_, 1e-9) or ld_ < 1e-4; okm = lm_ < 0.05 * max(hm_, 1e-9) or lm_ < 1e-4; ext = ""
    if not (okd and okm):
        peaks = []
        for k in range((132300 - 24000) // 8192):
            d2, Lw, Rw = jp.render_both(8192); L2, n2 = AM.words_to_floats(Lw); peaks.append((float(np.abs(np.array(d2)).max()), float(np.abs(L2).max())))
        okd = okd or peaks[-1][0] < 0.05 * max(hd_, 1e-9) or peaks[-1][0] < 1e-4
        okm = okm or peaks[-1][1] < 0.05 * max(hm_, 1e-9) or peaks[-1][1] < 1e-4
        ext = " | 3 s tail rule: dry %.3g master %.3g" % peaks[-1]
    fails += (not okd) + (not okm)
    log("%s release %d: dry %.3g -> %.3g, master %.3g -> %.3g%s" % ("PASS" if okd and okm else "FAIL", key, hd_, ld_, hm_, lm_, ext))
okt, msg = track_verdict(res)
log("JX law (dry): %s" % msg)
log("TRIAGE patch %d%s overrides %s: %s" % (patch, (" [%s]" % tag) if tag else "", ",".join("%d=%d" % x for x in ov) or "none", "PASS" if not fails else "%d FAIL" % fails))

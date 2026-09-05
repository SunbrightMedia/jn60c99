#!/usr/bin/env python3
"""jx_listen.py -- PORT_PIPELINE step 4: the LISTEN PROOF on the oracle.

Boots the plugin through jx_emu.boot() (BUILD, SETSR float-in-xmm1, FTZ,
recall + notify, ramps snapped, latch cleared), then for each test note:
idle must be silent, the note's autocorrelation pitch must sit within
25 cents of equal temper, the note's line must carry >= 10% of the
spectrum, the release must decay. Numbers only -- never by ear.

usage: jx_listen.py [patch=0] [notes=48,60,72] [--static-init] [--no-snap]
       JX_LISTEN_WAVE=<n> forces DCO1 WAVEFORM (id 757) before the notes,
       so a waveform-specific defect can be isolated (2026-09-05: waves 0/1
       pass, 2..5 emit only anti-alias spikes on the unhosted boot).
exit 1 on any FAIL. Requires numpy.
"""
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                "..", "..", "tools", "verify"))
import numpy as np
import jx_emu as J
import audio_metrics as M

SR = 44100.0


def track_verdict(results, harm_min=0.80, tol=25.0):
    """results: [(key, f0, harmonic)]. PASS when every note is harmonic and
    the sounding pitch tracks the key by ONE common whole number of
    semitones (the patch's own RANGE/FREQ-MOD transpose): a broken pitch
    law, a stuck oscillator or a click train all fail."""
    import math
    offs = []
    for key, f0, harm in results:
        if f0 <= 0 or harm < harm_min:
            return False, "FAIL harmonic/f0: " + str(results)
        offs.append(1200.0 * math.log2(f0 / M.midi_hz(key)))
    semis = round(offs[0] / 100.0)
    ok = all(abs(o - 100.0 * semis) <= tol for o in offs)
    return ok, "%s pitch tracks keys by %+d semitones (offsets %s cents)" % (
        "PASS" if ok else "FAIL", semis, ", ".join("%+.0f" % o for o in offs))


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    patch = int(args[0]) if args else 0
    notes = [int(x) for x in (args[1] if len(args) > 1 else "48,60,72").split(",")]
    static_init = "--static-init" in sys.argv
    snap = "--no-snap" not in sys.argv
    jx = J.JX().boot(SR, patch=patch, static_init=static_init, snap=snap)
    print("boot: patch %d static_init=%s snap=%s faults=%d"
          % (patch, static_init, snap, jx.faults))
    wave = os.environ.get("JX_LISTEN_WAVE")
    if wave is not None:
        for u in range(J.N_UNITS):
            jx.dispatch(u, 757, int(wave), flag=0)
        print("forced DCO1 WAVEFORM = %s" % wave)
    # the patch's own DCO1 RANGE (pool 20; 3 = 8', each step an octave)
    # sets the expected pitch: patch A11 sits at 16' (RANGE 2) by design
    rng = J.pool_value(J.patch_blob(J.bank_bytes(), patch), 20)
    shift = 12 * (rng - 3)
    print("patch DCO1 RANGE %d -> expected pitch shift %+d semitones" % (rng, shift))
    fails = 0
    idle = np.array(jx.render_dry(4096))
    ok = float(np.abs(idle).max()) < 1e-6
    print("%s idle: peak %.3g" % ("PASS" if ok else "FAIL", float(np.abs(idle).max())))
    fails += not ok
    results = []
    for n in notes:
        jx.note_on(n, 100)
        jx.render_dry(1024)
        x = np.array(jx.render_dry(16384))
        f0 = M.f0_autocorr(x, SR)
        harm = M.harmonicity(x, SR, f0) if f0 > 0 else 0.0
        print("key %d: f0 %.2f Hz, harmonic %.3f, peak %.4g" % (n, f0, harm, float(np.abs(x).max())))
        results.append((n, f0, harm))
        jx.note_off(n)
        tail = np.array(jx.render_dry(44100))
        head, last = float(np.abs(tail[:4096]).max()), float(np.abs(tail[-4096:]).max())
        ok = last < 0.05 * max(head, 1e-9) or last < 1e-4
        print("%s release note %d: %.3g -> %.3g" % ("PASS" if ok else "FAIL", n, head, last))
        fails += not ok
    ok, msg = track_verdict(results)
    print(msg + "  (patch RANGE predicts %+d)" % shift)
    fails += not ok
    print("JX LISTEN: %s" % ("GREEN" if not fails else "%d FAIL" % fails))
    sys.exit(1 if fails else 0)


if __name__ == "__main__":
    main()

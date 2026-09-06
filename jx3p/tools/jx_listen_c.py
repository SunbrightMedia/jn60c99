#!/usr/bin/env python3
"""jx_listen_c.py -- PORT_PIPELINE step 7: the LISTEN PROOF on the SHIPPING
C engine (libjx3p.so built by jx_full_gate.sh), through the same entry path
the web app uses: jx3p_init -> jx3p_recall -> jx3p_note_on -> jx3p_render_dry.
Same verdicts as jx_listen.py (oracle side); two-process rule honoured (no
Unicorn here).

usage: jx_listen_c.py <libjx3p.so> [patches=0,20,49] [notes=48,60,72]
exit 1 on any FAIL. Requires numpy.
"""
import sys, os, ctypes
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                "..", "..", "tools", "verify"))
import numpy as np
import jx_bank as B
import audio_metrics as M

SR = 44100.0
REPO = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..")


MASTER = "--master" in sys.argv


def render(lib, n):
    L = (ctypes.c_float * n)(); R = (ctypes.c_float * n)()
    (lib.jx3p_render if MASTER else lib.jx3p_render_dry)(L, R, n)
    return np.nan_to_num(np.array(L[:], dtype=np.float64))


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
    so = sys.argv[1]
    args = [a for a in sys.argv[2:] if not a.startswith("--")]
    patches = [int(x) for x in (args[0] if len(args) > 0 else "0,20,49").split(",")]
    notes = [int(x) for x in (args[1] if len(args) > 1 else "48,60,72").split(",")]
    lib = ctypes.CDLL(so)
    lib.jx_enable_hw_ftz()
    bank = B.bank_bytes()
    fails = 0
    for patch in patches:
        ok = lib.jx3p_init(os.path.join(REPO, "jx3p", "gen", "jx_template.bin").encode(),
                           os.path.join(REPO, "jx3p", "truth", "preset_bank_1.bin").encode(),
                           os.path.join(REPO, "jx3p", "gen", "jx_master_recall.bin").encode())
        if not ok:
            raise SystemExit("jx3p_init failed")
        lib.jx3p_recall(patch)
        rng = B.pool_value(B.patch_blob(bank, patch), 20)
        shift = 12 * (rng - 3)
        print("== patch %d (DCO1 RANGE %d -> %+d semitones) ==" % (patch, rng, shift))
        idle = render(lib, 4096)
        # THE IDLE LAW (corrected 2026-09-06): silence is not an absolute
        # threshold. Patches with effects idle at a real -60 dBFS floor --
        # PROVEN to be the plugin's own: the full-chain gate compares 1024
        # IDLE samples before note-on and they are EXACTLY 0 vs the oracle.
        # So this check only catches a RUNAWAY (screaming boot); exact idle
        # behaviour is gated by jx_full_gate.sh, not by a number here.
        ok = float(np.abs(idle).max()) < 0.01
        print("%s idle: peak %.3g" % ("PASS" if ok else "FAIL", float(np.abs(idle).max())))
        fails += not ok
        results = []
        for n in notes:
            lib.jx3p_note_on(n, 100)
            render(lib, 1024)
            x = render(lib, 16384)
            f0 = M.f0_autocorr(x, SR)
            harm = M.harmonicity(x, SR, f0) if f0 > 0 else 0.0
            print("key %d: f0 %.2f Hz, harmonic %.3f, peak %.4g" % (n, f0, harm, float(np.abs(x).max())))
            results.append((n, f0, harm))
            lib.jx3p_note_off(n)
            tail = render(lib, 44100)
            head, last = float(np.abs(tail[:4096]).max()), float(np.abs(tail[-4096:]).max())
            ok = last < 0.05 * max(head, 1e-9) or last < 1e-4
            print("%s release note %d: %.3g -> %.3g" % ("PASS" if ok else "FAIL", n, head, last))
            fails += not ok
        ok, msg = track_verdict(results)
        print(msg + "  (patch RANGE predicts %+d)" % shift)
        fails += not ok
    print("JX LISTEN (C twin): %s" % ("GREEN" if not fails else "%d FAIL" % fails))
    sys.exit(1 if fails else 0)


if __name__ == "__main__":
    main()

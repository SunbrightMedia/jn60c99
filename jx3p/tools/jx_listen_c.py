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


def render(lib, n):
    L = (ctypes.c_float * n)(); R = (ctypes.c_float * n)()
    lib.jx3p_render_dry(L, R, n)
    return np.nan_to_num(np.array(L[:], dtype=np.float64))


def main():
    so = sys.argv[1]
    patches = [int(x) for x in (sys.argv[2] if len(sys.argv) > 2 else "0,20,49").split(",")]
    notes = [int(x) for x in (sys.argv[3] if len(sys.argv) > 3 else "48,60,72").split(",")]
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
        ok = float(np.abs(idle).max()) < 1e-6
        print("%s idle: peak %.3g" % ("PASS" if ok else "FAIL", float(np.abs(idle).max())))
        fails += not ok
        for n in notes:
            lib.jx3p_note_on(n, 100)
            render(lib, 1024)
            x = render(lib, 16384)
            ok, msg = M.verdict(x, SR, n + shift)
            print(msg.replace("note %d:" % (n + shift), "key %d (sounding %d):" % (n, n + shift)))
            fails += not ok
            lib.jx3p_note_off(n)
            tail = render(lib, 44100)
            head, last = float(np.abs(tail[:4096]).max()), float(np.abs(tail[-4096:]).max())
            ok = last < 0.05 * max(head, 1e-9) or last < 1e-4
            print("%s release note %d: %.3g -> %.3g" % ("PASS" if ok else "FAIL", n, head, last))
            fails += not ok
    print("JX LISTEN (C twin): %s" % ("GREEN" if not fails else "%d FAIL" % fails))
    sys.exit(1 if fails else 0)


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""fxsweep_gate.py -- PORT side of the FX full-domain sweep. Pairs with
fxsweep_ref.py (read that file for why this gate exists).

The port repeats the ORACLE's exact sequence: the same engine reused across
values, the same bank with one FX byte overwritten, the same patch order --
so both sides carry the same history and only a real law/constant difference
can show. Compares the master/FX region cells the sweep moves.

Two-process rule: ctypes/libjuno only.
usage: fxsweep_gate.py [pkl]
"""
import sys, os, pickle, ctypes

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
HEADER, STRIDE, BLOB_OFF = 23, 20223, 16


def main():
    pkl = sys.argv[1] if len(sys.argv) > 1 else \
        os.path.join(os.path.dirname(os.path.dirname(HERE)), 'scratchpad', 'fxsweep.pkl')
    if not os.path.exists(pkl):
        print("MISSING ref %s -- run fxsweep_ref.py first" % pkl)
        return 1
    ref = pickle.load(open(pkl, 'rb'))
    res, rate = ref['res'], ref['rate']

    import freshlib
    lib = freshlib.load()
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p,
                                        ctypes.c_int, ctypes.c_int]
    lib.juno_gui_peek.restype = ctypes.c_uint
    lib.juno_gui_peek.argtypes = [ctypes.c_void_p, ctypes.c_int]

    import e2e_emu as E
    bank = E.bank_bytes()
    ctx = lib.juno_gui_create(ctypes.c_float(float(rate)), 0)   # ONE engine, as the ref
    total = mism = 0
    bad = {}
    for (P, idx) in sorted(res):
        d = res[(P, idx)]
        bb, cells = d['bb'], d['cells']
        if not cells:
            continue
        rec_off = HEADER + P * STRIDE
        for v in range(256):
            b = bytearray(bank)
            base = rec_off + BLOB_OFF
            b[base + bb] = (v >> 4) & 0xF
            b[base + bb + 1] = v & 0xF
            lib.juno_gui_apply_bank(ctx, bytes(b), len(b), P)
            for o in cells:
                total += 1
                want = d['table'][o][v]
                got = lib.juno_gui_peek(ctx, o + ref['voice_end'])
                if got != want:
                    mism += 1
                    bad.setdefault((P, idx, o), []).append((v, got, want))
    print("comparisons: %d  (patch x FX param x 256 values x moving FX cells)" % total)
    if mism:
        print("mismatches: %d across %d (patch,param,cell)" % (mism, len(bad)))
        for (P, idx, o), rows in sorted(bad.items())[:12]:
            v, g, w = rows[0]
            print("   patch %2d %-13s cell %8d : first v=%3d port=0x%08x plugin=0x%08x (%d values)"
                  % (P, res[(P, idx)]['name'], o + ref['voice_end'], v, g, w, len(rows)))
        print("\nGATE: FAIL")
        return 1
    print("\nGATE: PASS -- every FX parameter reproduces the plugin over its WHOLE")
    print("byte domain 0..255 inside a complete recall, not just the ~58 values the")
    print("factory bank happens to contain.")
    return 0


if __name__ == '__main__':
    sys.exit(main())

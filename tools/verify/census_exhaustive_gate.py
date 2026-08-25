#!/usr/bin/env python3
"""census_exhaustive_gate.py -- PORT side of the FULL-STATE exhaustive recall
sweep. Pairs with census_exhaustive_ref.py; see that file for why it exists.

Short version: recall_exhaustive_gate.py sweeps every byte 0..255 but compares
only the VOICE-0 block, so every master/FX recall law (reverb, delay, effect
depth, VCA level) was swept and then judged on a window that could not contain
its output. Mutation testing proved the cost: perturbing a DELAY filter cell or
REVLVL_LUT[0..1] SURVIVED every gate in `make verify`.

This gate compares the SAME sweep over the FULL meaningful state, so those
cells are in scope. Any (index, value, cell) where port != plugin is a defect.

Two-process rule: ctypes/libjuno only; the oracle pickle came from Unicorn.
usage: census_exhaustive_gate.py [rate ...]   (default 44100)
"""
import sys, os, pickle, ctypes

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
HEADER, STRIDE, BLOB_OFF = 23, 20223, 16
BANK_LEN = HEADER + STRIDE
VOICE_END = 84096
RATES = [44100]


def load_lib():
    import freshlib
    lib = freshlib.load()
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p,
                                        ctypes.c_int, ctypes.c_int]
    lib.juno_gui_peek.restype = ctypes.c_uint
    lib.juno_gui_peek.argtypes = [ctypes.c_void_p, ctypes.c_int]
    lib.juno_gui_destroy.argtypes = [ctypes.c_void_p]
    return lib


def port_cells(lib, rate, bb, v, cells):
    bank = bytearray(BANK_LEN)
    bank[0] = ord('K')
    base = HEADER + BLOB_OFF
    bank[base + bb] = (v >> 4) & 0xF
    bank[base + bb + 1] = v & 0xF
    ctx = lib.juno_gui_create(ctypes.c_float(float(rate)), 0)
    lib.juno_gui_apply_bank(ctx, bytes(bank), BANK_LEN, 0)
    out = {c: lib.juno_gui_peek(ctx, c) for c in cells}
    lib.juno_gui_destroy(ctx)
    return out


def main():
    rates = [int(a) for a in sys.argv[1:]] or RATES
    lib = load_lib()
    total = mism = 0
    bad = {}
    fx_compared = 0
    for rate in rates:
        p = os.path.abspath('%s/../../scratchpad/census_exhaustive_%d.pkl'
                            % (HERE, rate))
        if not os.path.exists(p):
            print("MISSING ref %s -- run census_exhaustive_ref.py %d" % (p, rate))
            return 1
        ref = pickle.load(open(p, 'rb'))
        lut = ref['lut']
        # single-writer cells only, for the same reason recall_exhaustive_gate
        # restricts: a multi-writer cell is a function of several record bytes and
        # per-index isolation does not reproduce the plugin's single dispatch.
        writers = {}
        for i in lut:
            for c in lut[i]['cells']:
                writers.setdefault(c, set()).add(i)
        single = {c for c, ws in writers.items() if len(ws) == 1}
        for idx in sorted(lut):
            bb = lut[idx]['bb']
            cells = [c for c in sorted(lut[idx]['cells']) if c in single]
            if not cells:
                continue
            fx_compared += sum(1 for c in cells if c >= VOICE_END)
            for v in range(256):
                got = port_cells(lib, rate, bb, v, cells)
                for c in cells:
                    total += 1
                    want = lut[idx]['cells'][c][v]
                    if got[c] != want:
                        mism += 1
                        bad.setdefault((idx, c), []).append(
                            (v, got[c], want))
    print("comparisons: %d  (census indices x 256 values x FULL-state cells)" % total)
    print("cells compared in the MASTER/FX region (beyond VOICE_END): %d" % fx_compared)
    if mism:
        print("mismatches: %d across %d (index,cell) pairs" % (mism, len(bad)))
        for (idx, c), rows in sorted(bad.items())[:12]:
            v, g, w = rows[0]
            print("   idx %4d cell %8d : first at v=%3d port=0x%08x plugin=0x%08x (%d values)"
                  % (idx, c, v, g, w, len(rows)))
        print("\nGATE: FAIL -- the port's recall differs from the plugin's own setter.")
        return 1
    print("\nGATE: PASS -- the port's recall reproduces the plugin's setter for every")
    print("census index at every byte 0..255, over the FULL state INCLUDING the")
    print("master/FX region that recall_exhaustive_gate could not see.")
    return 0


if __name__ == '__main__':
    sys.exit(main())

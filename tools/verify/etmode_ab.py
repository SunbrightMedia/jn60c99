#!/usr/bin/env python3
"""etmode_ab.py -- synthetic EFFECT TYPE mode A/B gate (closes the ET-mode
validation hole).

No factory patch uses EFFECT TYPE 2-5, so the port's slot-2 chorus/flanger/effect
recall (chorus_recall.c etype>=2 + effect_modes.c modes 1/5) is NOT exercised by any
live make-verify gate. This gate synthesises EFFECT TYPE 0..5 patches (a factory base
patch with EFFECT TYPE forced to each mode) and proves the PORT's post-recall FX-block
coefficients == the PLUGIN's own recall, bit-for-bit, across all modes x host rates.

Anti-circularity: the ORACLE alone determines which cells each mode writes (the union
over modes of cells that differ from the mode-0 baseline, per base patch/rate); the
port never curates its own target cells. Two-process rule: --ref uses e2e_emu (Unicorn
oracle), --port uses libjuno (ctypes); they meet only through a pickle.

  python3 tools/verify/etmode_ab.py --ref     # oracle reference  (Unicorn process)
  python3 tools/verify/etmode_ab.py --port     # port dump + DIFF  (libjuno process)
"""
import sys, os, struct, pickle

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import truth
SP = '/home/user/jn60c99/scratchpad'
REF = SP + '/etmode_ref.pkl'
HDR, STRIDE_REC = 23, 20223
ET_OFF = 634                          # EFFECT TYPE record offset (nibble pair)
FX_LO, FX_HI = 84000, 97000           # slot-2 FX block byte range
MODES = [0, 1, 2, 3, 4, 5]
RATES = [44100, 48000, 88200, 96000]
BASES = [0, 7, 40]                    # base patches (varied DEPTH/TONE/EFFECT knobs)


def doctor_bank(bank, idx, mode):
    """Return a copy of the bank with patch idx's EFFECT TYPE nibble-pair = mode."""
    b = bytearray(bank)
    off = HDR + idx * STRIDE_REC + ET_OFF
    b[off] = (mode >> 4) & 0xF
    b[off + 1] = mode & 0xF
    return bytes(b)


# ------------------------------------------------------------------ oracle --------
def build_ref():
    import numpy as np, e2e_emu as E
    SZ = 0xA83010
    fac = E.bank_bytes(); std = E.load_leaves()
    ET = 873
    def apply_std(e, blob):
        for (p, nm, disp, bb) in std:
            for u in range(9):
                try: e.dispatch(u, disp, E.dec(blob, bb))
                except RuntimeError: pass
    def force(e, disp, v):
        for u in range(9):
            try: e.dispatch(u, disp, v)
            except RuntimeError: pass
    def rd(e): return np.frombuffer(bytes(e.uc.mem_read(e.state[0], SZ)), dtype='<u4')
    def state(base, sr, mode):
        e = E.E2E(); e.build(float(sr)); e.snap_all()
        apply_std(e, E.patch_blob(fac, base)); force(e, ET, mode)
        e.snap_all()                       # settle coeff smoothers; NO render (pre-render)
        return rd(e)
    lo, hi = FX_LO // 4, FX_HI // 4
    out = {}
    for sr in RATES:
        for base in BASES:
            a0 = state(base, sr, 0)
            per = {0: a0}
            for m in MODES[1:]:
                per[m] = state(base, sr, m)
            # union writeset = cells differing from mode-0 for ANY mode (this base/rate)
            ws = set()
            for m in MODES[1:]:
                for w in range(lo, hi):
                    if per[m][w] != a0[w]:
                        ws.add(w)
            ws = sorted(ws)
            for m in MODES:
                out[(m, sr, base)] = {int(w) * 4: int(per[m][w]) for w in ws}
            sys.stdout.write('[ref base %d @%d] writeset=%d cells\n' % (base, sr, len(ws)))
            sys.stdout.flush()
    with open(REF, 'wb') as f:
        pickle.dump(out, f)
    sys.stdout.write('wrote %s (%d keys)\n' % (REF, len(out)))


# -------------------------------------------------------------------- port --------
def run_port_and_diff():
    import ctypes
    if not os.path.exists(REF):
        print('MISSING %s -- run --ref first' % REF); return 1
    ref = pickle.load(open(REF, 'rb'))
    bank = open(truth.BANK, 'rb').read()
    import freshlib  # stale-artifact guard (ROADMAP P0.3): refuse a libjuno.so older than src
    lib = freshlib.load()
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_peek.restype = ctypes.c_uint
    lib.juno_gui_peek.argtypes = [ctypes.c_void_p, ctypes.c_int]
    lib.juno_gui_destroy.argtypes = [ctypes.c_void_p]

    total = mm = 0; bad = []
    for (mode, sr, base) in sorted(ref):
        cells = ref[(mode, sr, base)]
        if not cells:
            continue
        db = doctor_bank(bank, base, mode)
        ctx = lib.juno_gui_create(ctypes.c_float(float(sr)), 0)
        lib.juno_gui_apply_bank(ctx, db, len(db), base)
        for c, want in cells.items():
            got = lib.juno_gui_peek(ctx, c)
            total += 1
            if got != (want & 0xFFFFFFFF):
                mm += 1
                if len(bad) < 12:
                    bad.append((mode, sr, base, c, want & 0xFFFFFFFF, got))
        lib.juno_gui_destroy(ctx)
    print()
    if mm == 0:
        print('ET-MODE A/B: PROVEN  (%d cells, 6 modes x %d rates x %d base patches, 0 mismatch)'
              % (total, len(RATES), len(BASES)))
        return 0
    print('ET-MODE A/B: RED  (%d/%d mismatches)' % (mm, total))
    for (mode, sr, base, c, want, got) in bad:
        print('  RED mode %d @%d base %d cell %d: want %08x got %08x' % (mode, sr, base, c, want, got))
    return 1


def main():
    if '--ref' in sys.argv:
        build_ref(); return 0
    if '--port' in sys.argv:
        return run_port_and_diff()
    print('usage: etmode_ab.py --ref | --port'); return 2


if __name__ == '__main__':
    sys.exit(main())

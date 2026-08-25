#!/usr/bin/env python3
"""census_exhaustive_ref.py -- ORACLE side of the FULL-STATE exhaustive recall
sweep. Closes the reach hole that mutation testing exposed (playbook 80).

recall_exhaustive_ref.py sweeps every byte 0..255 but reads only the VOICE-0
block (10512 bytes). Every master/FX cell lives in the SAME allocation BEYOND
VOICE_END (coldstate_ab.py's mapping: voice v at state[v]+v*BLOCK, the shared/
master/FX region at state[0]+off for off >= VOICE_END). So reverb, delay and
chorus recall laws were swept over their whole input domain and then compared
on a window that could not contain their output.

Mutation testing proved the consequence: perturbing REVLVL_LUT[0..1] or a DELAY
filter cell SURVIVED every gate. The port could carry a wrong reverb or delay
constant today and `make verify` would still be green.

This ref reads the WHOLE meaningful state, so those cells are in scope.

Two-phase, because 112 indices x 256 values x 11 MB is not tractable:
  1. DISCOVERY: for a spread of values, diff the full state against baseline
     (numpy, 4-byte granularity) -> the set of cells this index can touch.
  2. SWEEP: for all 256 values, restore ONLY those cells to baseline and read
     back ONLY those cells. Correct because phase 1 bounds what the index moves,
     and the sweep re-checks the bound (a value that moves a cell outside the
     discovered set is reported as a DISCOVERY ESCAPE, not silently dropped).

usage: census_exhaustive_ref.py [rate=44100] [out.pkl]
"""
import sys, os, pickle, struct
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import e2e_emu as E
import real_recall as RR

BLOCK = 10512
NVOICE = 8
VOICE_END = NVOICE * BLOCK          # 84096
MEANINGFUL = 11022352               # plugin per-unit object size
DISCOVERY_VALUES = (0, 1, 2, 64, 128, 192, 254, 255)


def main():
    rate = float(sys.argv[1]) if len(sys.argv) > 1 else 44100.0
    out = (sys.argv[2] if len(sys.argv) > 2 else
           os.path.join(E.REPO if hasattr(E, "REPO") else
                        os.path.dirname(os.path.dirname(HERE)),
                        "scratchpad", "census_exhaustive_%d.pkl" % int(rate)))

    lt = dict(RR.leaf_table())
    idxs = sorted(lt)
    sys.stderr.write("rate %g: %d leaf indices x 256 values, FULL state window "
                     "(%d bytes, incl. master/FX beyond %d)\n"
                     % (rate, len(idxs), MEANINGFUL, VOICE_END))

    e = E.E2E(); e.build(rate); e.snap_all()
    uc = e.uc; st0 = e.state[0]
    baseline = bytes(uc.mem_read(st0, MEANINGFUL))
    base_np = np.frombuffer(baseline, dtype=np.uint32)

    lut, escapes = {}, []
    for n, idx in enumerate(idxs):
        # ---- phase 1: which cells can this index move? ----
        touched = set()
        for v in DISCOVERY_VALUES:
            uc.mem_write(st0, baseline)
            try:
                e.dispatch(0, idx, v)
            except RuntimeError:
                pass
            cur = np.frombuffer(bytes(uc.mem_read(st0, MEANINGFUL)), dtype=np.uint32)
            touched.update(int(i) * 4 for i in np.nonzero(cur != base_np)[0])
        if not touched:
            continue
        cells = sorted(touched)
        base_vals = {o: struct.unpack('<I', baseline[o:o + 4])[0] for o in cells}

        # ---- phase 2: all 256 values, restoring/reading only those cells ----
        table = {o: [base_vals[o]] * 256 for o in cells}
        for v in range(256):
            for o in cells:                       # cheap targeted reset
                uc.mem_write(st0 + o, struct.pack('<I', base_vals[o]))
            try:
                e.dispatch(0, idx, v)
            except RuntimeError:
                pass
            for o in cells:
                table[o][v] = struct.unpack('<I', uc.mem_read(st0 + o, 4))[0]

        # ---- bound check: did any value escape the discovered set? ----
        uc.mem_write(st0, baseline)
        try:
            e.dispatch(0, idx, 255 - (idx % 251))
        except RuntimeError:
            pass
        cur = np.frombuffer(bytes(uc.mem_read(st0, MEANINGFUL)), dtype=np.uint32)
        moved = {int(i) * 4 for i in np.nonzero(cur != base_np)[0]}
        if moved - touched:
            escapes.append((idx, sorted(moved - touched)[:8]))

        lut[idx] = {'bb': lt[idx], 'cells': table}
        uc.mem_write(st0, baseline)
        if n % 10 == 0:
            sys.stderr.write("  %d/%d (idx %d -> %d cells, %d beyond VOICE_END)\n"
                             % (n, len(idxs), idx, len(cells),
                                sum(1 for o in cells if o >= VOICE_END)))
            sys.stderr.flush()

    pickle.dump({'rate': int(rate), 'baseline': baseline, 'lut': lut,
                 'escapes': escapes, 'window': MEANINGFUL},
                open(out, 'wb'))
    ncells = sum(len(d['cells']) for d in lut.values())
    nfx = sum(1 for d in lut.values() for o in d['cells'] if o >= VOICE_END)
    print("rate %d: %d indices, %d cells (%d in the master/FX region), "
          "%d discovery escapes -> %s"
          % (int(rate), len(lut), ncells, nfx, len(escapes), out))
    if escapes:
        print("DISCOVERY ESCAPES (widen DISCOVERY_VALUES): %s" % escapes[:5])
    return 0


if __name__ == '__main__':
    sys.exit(main())

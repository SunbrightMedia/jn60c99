#!/usr/bin/env python3
"""recall_ref_diff.py -- the cornerstone recall diff, reconstruction-free.

Compares the PORT's recalled engine state against a REFERENCE engine state,
cell by cell, over the unit-0 voice block, for every patch. Any nonzero diff is a
recall bug -- mechanical, no judgement.

Both sides are pickles of {patch_idx: bytes(BLOCK)} where BLOCK is the unit-0
voice block (10512 bytes, 16-byte cells). The two sides MUST be produced in
separate processes (two-process rule):

  PORT side (this repo): tools/verify/port_state_dump.py  -> scratchpad/port_state.pkl
  REF  side            : the plugin's OWN controller-driven recall, dumped under
                         Unicorn to the SAME {idx: bytes(10512)} format. That side
                         is built once the controller patch-select is executed
                         (see docs/CLAIMS.md section E). Until it exists this tool
                         reports what it needs.

Usage:
  python3 tools/verify/recall_ref_diff.py <ref.pkl> [port.pkl]
"""
import sys, struct, pickle

PORT_DEFAULT = '/home/user/jn60c99/scratchpad/port_state.pkl'
BLOCK  = 10512
STRIDE = 16


def as_f32(u32):
    return struct.unpack('<f', struct.pack('<I', u32))[0]


def cells(blk):
    return [struct.unpack('<I', blk[o:o + 4])[0] for o in range(0, len(blk), STRIDE)]


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        print("MISSING: the reference pickle (the plugin's controller-driven recall).")
        print("It does not exist yet -- it is produced by executing the plugin's own")
        print("controller patch-select under Unicorn (the current work).")
        sys.exit(2)
    ref_path = sys.argv[1]
    port_path = sys.argv[2] if len(sys.argv) > 2 else PORT_DEFAULT
    ref = pickle.load(open(ref_path, 'rb'))
    port = pickle.load(open(port_path, 'rb'))

    common = sorted(set(ref) & set(port))
    print("=== recall diff: PORT vs plugin controller-driven reference (unit-0 block) ===")
    print("patches compared: %d" % len(common))
    percell = {}   # cell offset -> [(patch, ref_f32, port_f32)]
    for idx in common:
        rc, pc = cells(ref[idx]), cells(port[idx])
        for i, (rv, pv) in enumerate(zip(rc, pc)):
            if rv != pv:
                percell.setdefault(i * STRIDE, []).append((idx, as_f32(rv), as_f32(pv)))

    if not percell:
        print("\nNO DIVERGENCES -- port recall == plugin reference for every cell, every patch.")
        return
    print("\nDIVERGING CELLS: %d\n" % len(percell))
    for off in sorted(percell):
        rows = percell[off]
        ex = rows[0]
        print("cell %6d  (%d patches)  e.g. patch %d: ref %.6g vs port %.6g" %
              (off, len(rows), ex[0], ex[1], ex[2]))
        print("    patches:", ", ".join("%d[%.4g/%.4g]" % r for r in rows[:24]),
              ("... +%d more" % (len(rows) - 24)) if len(rows) > 24 else "")


if __name__ == '__main__':
    main()

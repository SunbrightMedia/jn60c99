#!/usr/bin/env python3
"""index_cell_map.py -- the plugin's COMPLETE setter index -> engine-cell map.

Drives the per-param setter 0x3B9A30 DIRECTLY (e.dispatch(unit, index, value))
for every dispatch index under Unicorn and records the unit-0 cell(s) each writes.
This is more complete than param_cell_map.py (which went through the value-tree
apply node 0x3C7AE0 and missed params whose apply-node path skipped/faulted): the
setter is the sole engine writer and BUILD drives it over all indices, so every
recallable cell is reachable here.

Combined with the param_id->index map (0xcb0e18) and the record->param_id map (the
host-mediated half), this gives the full recalled-cell picture with zero
reconstruction on the cell side.

Two-process rule: E2E/Unicorn only.

Usage: python3 tools/verify/index_cell_map.py [--dump] [--maxidx N]
"""
import sys, struct, pickle
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E
from unicorn import UC_HOOK_MEM_WRITE

STATE_SZ = E.STATE_SZ
PKL      = '/home/user/jn60c99/scratchpad/index_cell_map.pkl'
MAXIDX   = 4966   # BUILD drives 0..4965


def main():
    maxidx = MAXIDX
    if '--maxidx' in sys.argv:
        maxidx = int(sys.argv[sys.argv.index('--maxidx') + 1])
    e = E.E2E(); uc = e.uc
    e.build(48000.0)

    lo, hi = e.state[0], e.state[0] + STATE_SZ
    writes = []
    def wh(uc, access, addr, size, value, user):
        writes.append(addr - e.state[0])
    uc.hook_add(UC_HOOK_MEM_WRITE, wh, begin=lo, end=hi - 1)

    idx_cells = {}
    for idx in range(maxidx):
        cells = set()
        for v in (1, 2, 64, 128):
            writes.clear()
            try:
                e.dispatch(0, idx, v)
            except Exception:
                pass
            for off in writes:
                cells.add(off)
            if cells:
                break
        if cells:
            idx_cells[idx] = sorted(cells)

    pickle.dump(idx_cells, open(PKL, 'wb'))
    print("indices driven: %d ; indices that write >=1 cell: %d" % (maxidx, len(idx_cells)))

    # spot-checks vs known port cells
    known = {760: 'DCO RANGE feet 3840', 759: 'LFO cluster', 752: 'LFO rate 1072',
             756: 'LFO key trig 1872'}
    for idx, name in known.items():
        print("  idx %4d (%s): cells %s" % (idx, name, idx_cells.get(idx, 'NONE')))

    # which indices write the port's known recall cells?
    targets = {6736: 'VCF cutoff', 4192: 'DCO saw', 4224: 'DCO sub', 6528: 'DCO noise',
               9584: 'VCA', 10240: 'HPF', 3840: 'feet', 1072: 'LFO rate'}
    print("\n  cell -> index(es) that write it:")
    for cell, name in sorted(targets.items()):
        who = [i for i, cs in idx_cells.items() if cell in cs]
        print("    cell %5d (%-10s) <- indices %s" % (cell, name, who[:6]))

    if '--dump' in sys.argv:
        for idx in sorted(idx_cells):
            print("  idx %4d -> %s" % (idx, idx_cells[idx]))
    print("saved -> %s" % PKL)


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""extract_dropped_luts.py -- capture the plugin's OWN setter output for the 9
dropped front-panel recall indices (751-760), as exact value->cell LUTs.

For each dropped index and each possible record value v (0..255), drive the
plugin's own engine setter 0x3B9A30 via e.dispatch(0, idx, v) and read the
voice-0 engine cells that index writes. The result LUT[idx][cell][v] is the
plugin's exact recall output, byte-for-byte -- no hand formula, no capture, just
the plugin's machine code producing the mapping. Repeated at 44100/48000/96000
to detect per-cell sample-rate dependence.

This is the source data for the port's recall of these params (src/juno_apply.c).
Two-process rule: E2E/Unicorn only.

NEVER reads user_patch5_ableton.json or captured_coeffs.json.
"""
import sys, struct, pickle
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E

OUT = '/home/user/jn60c99/scratchpad/dropped_luts.pkl'

# voice-0 cells each dropped index writes (from index_cell_map, cells < 10512)
IDX_CELLS = {
    751: [1920, 1936],
    752: [1072, 1088, 2064],
    753: [4032],
    754: [7344],
    756: [1872],
    758: [4144],
    759: [3888, 3904, 3920, 3936],
    760: [3840],
}
RATES = [44100.0, 48000.0, 96000.0]


def f32bits(e, off):
    return struct.unpack('<I', e.uc.mem_read(e.state[0] + off, 4))[0]


def capture_rate(sr):
    e = E.E2E(); e.build(sr)
    tbl = {}
    for idx, cells in IDX_CELLS.items():
        tbl[idx] = {c: [0] * 256 for c in cells}
        for v in range(256):
            e.dispatch(0, idx, v)
            for c in cells:
                tbl[idx][c][v] = f32bits(e, c)
    return tbl


def main():
    data = {}
    for sr in RATES:
        sys.stderr.write("building E2E @ %g ...\n" % sr); sys.stderr.flush()
        data[int(sr)] = capture_rate(sr)
    pickle.dump(data, open(OUT, 'wb'))

    # report: which cells are rate-dependent
    print("=== dropped-index setter LUTs captured (0..255) ===")
    a, b, c = data[44100], data[48000], data[96000]
    for idx in sorted(IDX_CELLS):
        for cell in IDX_CELLS[idx]:
            la, lb, lc = a[idx][cell], b[idx][cell], c[idx][cell]
            rate_dep = (la != lb) or (lb != lc)
            distinct = sorted(set(lb))
            tag = "RATE-DEP" if rate_dep else "rate-indep"
            print("  idx %3d cell %5d  %-10s  %d distinct vals (48k) e.g. %s"
                  % (idx, cell, tag, len(distinct),
                     [struct.unpack('<f', struct.pack('<I', x))[0] for x in distinct[:5]]))
    print("saved -> %s" % OUT)


if __name__ == '__main__':
    main()

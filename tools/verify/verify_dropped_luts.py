#!/usr/bin/env python3
"""verify_dropped_luts.py -- prove LUT[idx][cell][dec(blob,bb)] == the self-proven
reference (plugin_recall_ref.pkl) for every patch and every dropped cell.

This is the pre-implementation gate: it proves that reading the bank blob at
blob_pos = bb/2 and indexing the captured plugin-setter LUT reproduces the
plugin's own recalled engine state exactly. If this is clean, baking the LUT into
the port is guaranteed to zero the diff for these cells.

No Unicorn here (pure pickle + raw bank + proven nibble decode). The reference was
built at 48000, so we index the 48000 LUT.

NEVER reads user_patch5_ableton.json or captured_coeffs.json.
"""
import sys, struct, pickle
sys.path.insert(0, '/home/user/jn60c99/tools/verify')

import os as _o, sys as _s; _s.path.insert(0, _o.path.dirname(_o.path.abspath(__file__)))
import truth; BANK = truth.BANK  # single source of ground truth (truth/ folder)
HEADER, STRIDE, BLOB_OFF = 23, 20223, 16
REF = '/home/user/jn60c99/scratchpad/plugin_recall_ref.pkl'
LUTS = '/home/user/jn60c99/scratchpad/dropped_luts.pkl'

# idx -> (blob_pos, [cells]); blob_pos = bb/2 (bb from real_recall.leaf_table SYNTH block)
IDX = {
    751: (7,  [1920, 1936]),
    752: (8,  [1072, 1088, 2064]),
    753: (9,  [4032]),
    754: (10, [7344]),
    756: (12, [1872]),
    758: (14, [4144]),
    759: (15, [3888, 3904, 3920, 3936]),
    760: (16, [3840]),
}


def dec(blob, bb):
    return ((blob[bb] & 0xF) << 4) | (blob[bb + 1] & 0xF)


def cell_bits(blk, off):
    return struct.unpack('<I', blk[off:off + 4])[0]


def main():
    bank = open(BANK, 'rb').read()
    ref = pickle.load(open(REF, 'rb'))
    luts = pickle.load(open(LUTS, 'rb'))[48000]

    total = 0
    bad = []
    for patch in range(64):
        blob = bank[HEADER + patch * STRIDE + BLOB_OFF:
                    HEADER + patch * STRIDE + BLOB_OFF + 700]
        refblk = ref[patch]
        for idx, (p, cells) in IDX.items():
            v = dec(blob, 2 * p)          # == dec(blob, bb): blob[bb]/blob[bb+1]
            for c in cells:
                want = cell_bits(refblk, c)
                got = luts[idx][c][v]
                total += 1
                if want != got:
                    bad.append((patch, idx, c, v, want, got))

    print("=== LUT vs plugin_recall_ref.pkl (64 patches x dropped cells) ===")
    print("comparisons: %d ; mismatches: %d" % (total, len(bad)))
    for m in bad[:30]:
        wf = struct.unpack('<f', struct.pack('<I', m[4]))[0]
        gf = struct.unpack('<f', struct.pack('<I', m[5]))[0]
        print("  patch %d idx %d cell %d v=%d ref=%.6g lut=%.6g" % (m[0], m[1], m[2], m[3], wf, gf))
    print("VERDICT:", "LUT reproduces the plugin recall reference EXACTLY -> safe to bake"
          if not bad else "*** MISMATCH -- do not bake yet ***")
    return 0 if not bad else 1


if __name__ == '__main__':
    sys.exit(main())

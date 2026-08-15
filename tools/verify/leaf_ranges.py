#!/usr/bin/env python3
"""leaf_ranges.py -- ask the PLUGIN for each recall byte's legal range.

WHY. The random gate's first two value-pickers were both wrong, in opposite
directions:

  1. Uniform 0..255 for every byte. A switch with six legal values is
     out of range 250 times in 256, so DELAY TYPE was >= 6 in ALL 60 seeds
     and every reported defect lived in one unreachable corner.
  2. "Values real patches use". Correct for switches, WRONG for knobs: a
     cutoff value no patch happens to use is still legal, and the entire
     point of the seeds is COMPLETE randomness (user, 2026-08-15).

The only correct source of a parameter's range is the PLUGIN. This tool
derives it by experiment, per recall byte:

  Sweep the byte, all else factory-zero, through the plugin under Unicorn.
  Hash the full render-visible state (recall_fullstate_diff.REGIONS).
  If state(v) == state(255) for all v >= N and state(N-1) != state(N),
  the plugin CLAMPS at N: a switch with N+1 classes. Draw 0..N.
  If state(254) != state(255), the byte is continuous. Draw 0..255.
  If the state never moves, the byte is FLAT here; keep 0..255 (wild).

The old exhaustive-sweep pickles CANNOT do this: they record only the 67
voice cells, so every FX-block selector looks flat there (checked: DELAY
TYPE bb 634 shows "1 distinct value" in recall_exhaustive_44100.pkl).

BINARY SEARCH, AND ITS TOOTH. state(v)==state(255) is monotone iff the
plugin clamps; a v%N mapping would break it. So every derived top is
verified: state(top-1) != state(top), and a probe value above top must
equal state(255). A leaf failing either check is reported and left WILD.

⚠ TWO-PROCESS RULE: Unicorn only in --ref. The output pickle is read by
random_state_ab.py (ctypes side) as data, never code.

USAGE
    python3 tools/verify/leaf_ranges.py --ref      # slow: ~1k Unicorn recalls
    python3 tools/verify/leaf_ranges.py --show
"""
import os
import sys
import pickle
import hashlib

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import recall_fullstate_diff as FS                  # noqa: E402

SCRATCH = FS.SCRATCH
SR = FS.SR
OUT = os.path.join(SCRATCH, 'leaf_ranges.pkl')
HEADER = 23
BLOB_OFF = 16
BANK_LEN = 23 + 20223

# Recall bytes the port reads that are NOT front-panel leaves (grep of
# src/ rec_byte calls): DELAY FEEDBACK and DELAY DIRECT LEVEL. The first
# generator missed them entirely -- it only wrote leaf_table() bytes -- so
# the feedback law's fix could never have been found by it.
EXTRA_BYTES = [3057, 3060]


def state_hash(e):
    st = e.state[0]
    h = hashlib.sha256()
    for a, b in FS.REGIONS:
        h.update(bytes(e.uc.mem_read(st + a, b - a)))
    return h.digest()


def probe(bb, v, E, R, RR, leaves):
    b = bytearray(BANK_LEN)
    b[0] = ord('K')
    base = HEADER + BLOB_OFF
    b[base + bb] = (v >> 4) & 0xF
    b[base + bb + 1] = v & 0xF
    e = RR.prepare_recall(0, bytes(b), leaves, E, R, SR)
    return state_hash(e)


def ref():
    import e2e_emu as E
    import real_recall as R
    import recall_render_ab as RR
    leaves = R.leaf_table()
    bbs = sorted({bb for _i, bb in leaves} | set(EXTRA_BYTES))
    ranges = {}
    for n, bb in enumerate(bbs):
        h255 = probe(bb, 255, E, R, RR, leaves)
        h0 = probe(bb, 0, E, R, RR, leaves)
        if h0 == h255:
            # flat OR wraps back; probe a midpoint before calling it flat
            hm = probe(bb, 128, E, R, RR, leaves)
            kind = 'flat' if hm == h255 else 'suspect'
            ranges[bb] = {'top': 255, 'kind': kind}
            print('byte %4d  %s' % (bb, kind), flush=True)
            continue
        h254 = probe(bb, 254, E, R, RR, leaves)
        if h254 != h255:
            ranges[bb] = {'top': 255, 'kind': 'continuous'}
            print('byte %4d  continuous' % bb, flush=True)
            continue
        # clamped: smallest v with state(v)==state(255)
        lo, hi = 0, 255                # state(lo)!=state(255), state(hi)==
        while hi - lo > 1:
            mid = (lo + hi) // 2
            if probe(bb, mid, E, R, RR, leaves) == h255:
                hi = mid
            else:
                lo = mid
        top = hi
        # TOOTH: the boundary must be real and the plateau must hold at a
        # point the search never touched.
        ok = (probe(bb, top - 1, E, R, RR, leaves) != h255 if top > 0 else True)
        pv = top + (255 - top) // 3 + 1
        ok = ok and (pv > 255 or probe(bb, pv, E, R, RR, leaves) == h255)
        if not ok:
            ranges[bb] = {'top': 255, 'kind': 'nonmonotone'}
            print('byte %4d  NON-MONOTONE -- left wild' % bb, flush=True)
        else:
            ranges[bb] = {'top': top, 'kind': 'switch'}
            print('byte %4d  switch, %d classes (0..%d)' % (bb, top + 1, top),
                  flush=True)
    pickle.dump(ranges, open(OUT, 'wb'))
    print('-> %s  (%d bytes)' % (OUT, len(ranges)))
    return 0


def show():
    r = pickle.load(open(OUT, 'rb'))
    for bb in sorted(r):
        print('byte %4d  top %3d  %s' % (bb, r[bb]['top'], r[bb]['kind']))
    return 0


if __name__ == '__main__':
    if '--ref' in sys.argv:
        raise SystemExit(ref())
    if '--show' in sys.argv:
        raise SystemExit(show())
    print(__doc__)
    raise SystemExit(2)

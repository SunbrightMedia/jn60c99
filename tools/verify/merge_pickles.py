#!/usr/bin/env python3
"""merge_pickles.py OUT IN1 IN2 ... -- merge dict pickles (later inputs win on a
key clash, which is reported). Used to join reference pickles that parallel
oracle jobs wrote for disjoint rate subsets (finefx_cellsweep, rate sweeps)."""
import pickle
import sys


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    out = {}
    for p in sys.argv[2:]:
        d = pickle.load(open(p, 'rb'))
        clash = set(out) & set(d)
        if clash:
            print('note: %d keys of %s were already present (overwritten)' % (len(clash), p))
        out.update(d)
    pickle.dump(out, open(sys.argv[1], 'wb'))
    print('wrote %s: %d keys from %d files' % (sys.argv[1], len(out), len(sys.argv) - 2))
    return 0


if __name__ == '__main__':
    sys.exit(main())

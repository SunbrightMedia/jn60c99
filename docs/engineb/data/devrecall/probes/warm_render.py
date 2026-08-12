#!/usr/bin/env python3
"""Does the plugin's warm-vs-cold state difference REACH THE AUDIO?

  cold(B)    = fresh engine -> recall B          -> note on -> render N
  warm(A->B) = fresh engine -> recall A -> recall B -> note on -> render N

Both sides are the PLUGIN's own code under Unicorn.  No ctypes in this process.
"""
import sys, gc, time, argparse
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E
import real_recall as R
import recall_render_ab as RR
from warm_plugin import recall_into, build_engine

NOTE, VEL = 60, 105


def run(seq, bank, leaves, sr, n, variant):
    e = build_engine(sr)
    for p in seq:
        recall_into(e, p, bank, leaves, variant)
    e.clear_latch(); e.set_ftz()
    e.note_on(NOTE, VEL)
    out = e.render(n)
    del e; gc.collect()
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--rate', type=float, default=44100.0)
    ap.add_argument('--variant', default='full')
    ap.add_argument('--n', type=int, default=4000)
    ap.add_argument('--pairs', default='21-22,4-5,8-9,0-1')
    a = ap.parse_args()
    bank = E.bank_bytes(); leaves = R.leaf_table()
    for s in a.pairs.split(','):
        x, y = (int(v) for v in s.split('-'))
        t = time.time()
        cl, cr = run([y], bank, leaves, a.rate, a.n, a.variant)
        wl, wr = run([x, y], bank, leaves, a.rate, a.n, a.variant)
        nd = sum(1 for i in range(a.n) if cl[i] != wl[i] or cr[i] != wr[i])
        first = next((i for i in range(a.n) if cl[i] != wl[i] or cr[i] != wr[i]), None)
        print('RENDER %2d -> %2d : %s  (%d/%d frames differ, first %s)  %.0fs' %
              (x, y, 'BIT-IDENTICAL' if nd == 0 else 'DIFFERS', nd, a.n, first, time.time() - t))
        sys.stdout.flush()


if __name__ == '__main__':
    main()

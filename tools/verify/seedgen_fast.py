#!/usr/bin/env python3
"""seedgen_fast.py -- reference states for random_state_ab.py, ~100x faster.

WHY. Generating one reference state cost 3.92s, of which build_engine was
3.89s (99.2%) and the recall itself 0.03s. Every seed rebuilt the whole plugin
engine under Unicorn to do 30ms of work. At that rate 10,000 seeds is ~7.7
hours on 4 cores; the real work in them is about four minutes.

WHAT IT DOES. Build ONE engine, snapshot every mapped region plus the CPU
context, then per seed: restore, recall, dump. Restoring is a memcpy.

WHY IT IS STILL COLD. prepare_recall is the COLD entry point -- one fresh
engine, one recall -- and the port is stateful, so a warm reference would be a
DIFFERENT measurement (playbook 49). Restoring the post-build snapshot puts the
engine back in exactly the state build_engine left, so recall N never sees
recall N-1. That claim is not taken on trust: --prove regenerates seeds that
already have slow-path pickles and compares them BYTE FOR BYTE.

⚠ TWO-PROCESS RULE: Unicorn only. Never ctypes-load libjuno.so here.

USAGE
    python3 tools/verify/seedgen_fast.py --prove 200 30      # equivalence first
    python3 tools/verify/seedgen_fast.py --gen   500 9500    # start count
"""
import os, sys, pickle, struct, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import random_state_ab as RS                      # noqa: E402
import real_recall as R                           # noqa: E402
import recall_render_ab as RR                     # noqa: E402
import e2e_emu as E                               # noqa: E402
import recall_fullstate_diff as FS                # noqa: E402


class Snap:
    """Snapshot only what the recall can touch.

    The engine maps an 8.6 GB SPARSE arena (0x310000000..0x50fffffff) that
    cannot be read wholesale. The nine state blocks live at its base
    (state[0] = 0x310008000, state[8] ~ +0x4a94000), so a window over the base
    plus the five small regions covers everything the recall writes. The
    window is deliberately generous -- it is memcpy, not emulation.

    The claim "this window is enough" is NOT argued, it is PROVEN: --prove
    regenerates seeds that already have slow-path pickles and compares byte
    for byte. If the window missed live memory, residue from seed N-1 would
    change seed N and the comparison would fail.
    """

    WINDOW = 256 << 20          # 256 MB over the arena base

    def __init__(self, eng):
        self.eng = eng
        self.uc = eng.uc
        regs = [(a, b) for a, b, _p in self.uc.mem_regions()]
        self.regions = []
        for a, b in regs:
            sz = b - a + 1
            if sz > self.WINDOW:                 # the sparse arena
                base = min(eng.state) & ~0xFFFF
                self.regions.append((base, self.WINDOW))
            else:
                self.regions.append((a, sz))
        self.mem = [bytes(self.uc.mem_read(a, n)) for a, n in self.regions]
        self.ctx = self.uc.context_save()
        print('snapshot: %d regions, %.1f MB' %
              (len(self.regions), sum(len(m) for m in self.mem) / 1e6), flush=True)

    def restore(self):
        for (a, _n), m in zip(self.regions, self.mem):
            self.uc.mem_write(a, m)
        self.uc.context_restore(self.ctx)


def run(mode, start, n):
    leaves = R.leaf_table()
    offs = FS.offsets()
    t0 = time.time()
    eng = RR.build_engine(E, RS.SR)
    print('build_engine %.2fs' % (time.time() - t0), flush=True)
    snap = Snap(eng)
    bad = 0
    for i, s in enumerate(range(start, start + n)):
        snap.restore()
        RR.apply_recall(eng, 0, RS.synth_bank(s, leaves), leaves, E, R)
        st = eng.state[0]
        d = {o: struct.unpack('<I', eng.uc.mem_read(st + o, 4))[0] for o in offs}
        if mode == 'prove':
            p = RS.pkl(s)
            if not os.path.exists(p):
                print('  seed %d: no slow pickle, skipped' % s); continue
            old = pickle.load(open(p, 'rb'))
            if old != d:
                bad += 1
                diff = [o for o in offs if old.get(o) != d.get(o)]
                print('  seed %d *** DIFFERS in %d cells: %s' %
                      (s, len(diff), diff[:8]), flush=True)
            else:
                print('  seed %d identical (%d cells)' % (s, len(d)), flush=True)
        else:
            pickle.dump(d, open(RS.pkl(s), 'wb'))
            if i % 200 == 0:
                el = time.time() - t0
                print('  %d/%d  %.1fs  %.3f s/seed' % (i, n, el, el / max(i, 1)),
                      flush=True)
    if mode == 'prove':
        print('PROVE: %s' % ('FAIL -- %d seeds differ' % bad if bad else
                             'PASS -- fast path bit-identical to slow path'),
              flush=True)
        return 1 if bad else 0
    print('GEN DONE %.1fs' % (time.time() - t0), flush=True)
    return 0


if __name__ == '__main__':
    m = 'prove' if '--prove' in sys.argv else 'gen'
    a = [x for x in sys.argv[1:] if not x.startswith('--')]
    sys.exit(run(m, int(a[0]), int(a[1])))

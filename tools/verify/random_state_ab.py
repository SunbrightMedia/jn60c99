#!/usr/bin/env python3
"""random_state_ab.py -- move EVERY parameter to a random value, N times, and
compare the port's whole post-recall state against the plugin's.

USER-BINDING (2026-08-13): "turn every parameter a random value and compare
against the plugin 1000 times".

WHY THIS IS THE GATE THAT WAS MISSING. Everything else samples one axis:

  recall_exhaustive_gate   every parameter x every value 0..255 x 3 rates,
                           but ONE PARAMETER AT A TIME.
  recall_gate / render A/B 64 factory patches -- real music, and therefore a
                           tiny, clustered corner of the space.
  userbank_parity          768 of the user's patches. Bigger, same kind.

So single-parameter LAWS are exhausted, and COMBINATIONS are not tested at all.
That is exactly where the two defects found on 2026-08-13 live:

  ASSIGN MODE 3   never occurs in the factory bank -> never executed
  DELAY on/off    the port decides from DELAY LEVEL alone; the plugin uses
                  something more, and no factory patch separates the two

Neither is findable by moving one knob at a time, and neither was found in
months of green gates. This tool moves ALL of them at once, at values no
musician would choose, which is where the remaining risk is.

WHAT IT DOES, per seed:
  1. Build a one-record bank with EVERY recall leaf byte set to a random value.
  2. Apply it to the PLUGIN (Unicorn) and dump the whole render-visible state.
  3. Apply it to the PORT (libjuno) and compare cell by cell.
  4. Any differing cell is a defect, reported with its seed so it reproduces
     exactly.

⚠ TWO-PROCESS RULE: --ref (Unicorn) writes pickles, --port (ctypes) reads them.

⚠ WHAT IT CANNOT DO. The space is 256^112. This SAMPLES it. It cannot prove
absence of defects; it can only fail fast, reproducibly, and never quietly. Its
value is that it reaches combinations no bank contains -- not that it is
exhaustive.

⚠ TWO MODES, KEPT SEPARATE ON PURPOSE.
  default          every byte drawn from its PLUGIN-DERIVED legal range
                   (scratchpad/leaf_ranges.pkl, tools/verify/leaf_ranges.py).
                   Every seed is a state the plugin itself distinguishes; a
                   failure is a REACHABLE defect.
  JUNO_SEED_WILD=1 uniform 0..255 including out-of-range switch values. The
                   plugin is still the oracle, so a failure is still a port
                   disagreement -- but it must be LABELLED out-of-range, never
                   mixed into the reachable count. The first 60 seeds ran
                   wild-only by accident and every finding was this class.

USAGE
    python3 tools/verify/random_state_ab.py --ref  [N] [--start S]
    python3 tools/verify/random_state_ab.py --port [N] [--start S]
"""
import os
import sys
import pickle
import struct
import random

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import truth                                        # noqa: E402
import recall_fullstate_diff as FS                  # noqa: E402

ROOT = FS.ROOT
SCRATCH = FS.SCRATCH
SR = FS.SR
HEADER = 23
BLOB_OFF = 16           # record-relative blob base -- THE VALUE recall_
                        # exhaustive_gate.py:32 uses. A first draft of this file
                        # said 141; the randomiser then wrote into bytes no leaf
                        # reads, every seed produced the DEFAULT patch, and the
                        # gate would have reported a clean pass while testing
                        # nothing. Caught by comparing against the existing
                        # tool rather than trusting the number.
BANK_LEN = 23 + 20223


def factory_leaves(leaves):
    """Leaf values read OUT of factory patch 0, for the self-control below."""
    b = open(truth.BANK, 'rb').read()
    base = HEADER + BLOB_OFF
    return {bb: ((b[base + bb] & 0xF) << 4) | (b[base + bb + 1] & 0xF)
            for bb in all_bytes(leaves)}


def leaf_ranges():
    """{byte: top} -- each recall byte's legal range 0..top, DERIVED FROM THE
    PLUGIN by tools/verify/leaf_ranges.py (binary-searched clamp point over the
    full render-visible state, with a seen-to-fail boundary check per byte).

    ⚠ TWO PICKERS BEFORE THIS ONE WERE WRONG, one night of results each.
      1. Uniform 0..255: a 6-value switch is out of range 250/256, so DELAY
         TYPE was >= 6 in ALL 60 seeds -- one unreachable corner, 60 times.
      2. "Values real patches use": right for switches, WRONG for knobs -- a
         cutoff value no patch uses is still legal, and the entire reason for
         the seeds is COMPLETE randomness (user, 2026-08-15).
    The range must come from the plugin, nowhere else. A knob whose 256 values
    all move the plugin stays 0..255; a clamped switch draws only its classes.
    """
    import leaf_ranges as LR
    r = pickle.load(open(LR.OUT, 'rb'))
    return {bb: d['top'] for bb, d in r.items()}


_RANGES = None


def all_bytes(leaves):
    """EVERY recall byte, not just the 112 front-panel leaves: src/ also reads
    blob 3057 (DELAY FEEDBACK) and 3060 (DELAY DIRECT). The first generator
    missed them, so the feedback law could never fail under it."""
    import leaf_ranges as LR
    return sorted({bb for _i, bb in leaves} | set(LR.EXTRA_BYTES))


def synth_bank(seed, leaves, fixed=None):
    """One record, every recall byte randomised within its PLUGIN-DERIVED
    range. The nibble-pair encoding is the port's own (juno_bank_apply reads
    blob[2*pos] / [2*pos+1])."""
    rnd = random.Random(seed)
    b = bytearray(BANK_LEN)
    b[0] = ord('K')
    base = HEADER + BLOB_OFF
    wild = bool(os.environ.get('JUNO_SEED_WILD'))
    global _RANGES
    if _RANGES is None and fixed is None and not wild:
        _RANGES = leaf_ranges()
    for bb in all_bytes(leaves):
        if fixed is not None:
            v = fixed.get(bb, 0)
        elif wild:
            v = rnd.randrange(256)      # out-of-range too; NOT user-reachable
        else:
            v = rnd.randrange(_RANGES.get(bb, 255) + 1)
        b[base + bb] = (v >> 4) & 0xF
        b[base + bb + 1] = v & 0xF
    return bytes(b)


def pkl(seed):
    return os.path.join(SCRATCH, 'randstate_%d.pkl' % seed)


def ref(n, start):
    import e2e_emu as E
    import real_recall as R
    import recall_render_ab as RR
    leaves = R.leaf_table()
    offs = FS.offsets()
    for s in range(start, start + n):
        fixed = factory_leaves(leaves) if s < 0 else None
        bank = synth_bank(s, leaves, fixed)
        e = RR.prepare_recall(0, bank, leaves, E, R, SR)
        st = e.state[0]
        d = {o: struct.unpack('<I', e.uc.mem_read(st + o, 4))[0] for o in offs}
        pickle.dump(d, open(pkl(s), 'wb'))
        print('  seed %d ref done' % s, flush=True)
    return 0


def port(n, start):
    import ctypes
    import real_recall as R
    lib = ctypes.CDLL(os.path.join(ROOT, 'libjuno.so'))
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p,
                                        ctypes.c_int, ctypes.c_int]
    lib.juno_gui_peek.restype = ctypes.c_uint
    lib.juno_gui_peek.argtypes = [ctypes.c_void_p, ctypes.c_int]
    lib.juno_gui_destroy.argtypes = [ctypes.c_void_p]
    leaves = R.leaf_table()

    # Cells that differ on EVERY patch, including passing ones: the C++ object
    # header (< 176, vtable/allocator pointers the port has no equivalent for)
    # and the FX-default cells audited inert. Proven inert by control on
    # 2026-08-13: a PASSING patch differs in exactly these.
    def inert(off):
        return off < 176 or off in (10759472, 11022352, 11022356)

    seeds = [s for s in range(start, start + n) if os.path.exists(pkl(s))]
    bad = {}
    for s in seeds:
        r = pickle.load(open(pkl(s), 'rb'))
        ctx = lib.juno_gui_create(ctypes.c_float(SR), 0)
        fixed = factory_leaves(leaves) if s < 0 else None
        lib.juno_gui_apply_bank(ctx, synth_bank(s, leaves, fixed), BANK_LEN, 0)
        for off in sorted(r):
            if inert(off):
                continue
            pv = lib.juno_gui_peek(ctx, off)
            if pv != r[off]:
                bad.setdefault(off, []).append(s)
        lib.juno_gui_destroy(ctx)

    print('=== RANDOM FULL-STATE A/B (port vs plugin) ===')
    print('seeds %d   cells per seed %d   SR %g' % (len(seeds), len(r), SR))
    if not bad:
        print('\n0 differing cells. Every parameter random, every seed, '
              'bit-identical.')
        return 0
    print('\n*** %d CELLS DIFFER ***  (seed makes each reproduce exactly)' %
          len(bad))
    print('%10s %7s  %s' % ('cell', 'seeds', 'first seed'))
    for off in sorted(bad, key=lambda o: -len(bad[o]))[:40]:
        print('%10d %7d  %d' % (off, len(bad[off]), bad[off][0]))
    print('\nby region:')
    for a, b in FS.REGIONS:
        n_ = sum(1 for o in bad if a <= o < b)
        if n_:
            print('  %8d..%-8d  %d cells' % (a, b, n_))
    return 1


def main():
    n = 20
    start = 0
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    if args:
        n = int(args[0])
    if '--start' in sys.argv:
        start = int(sys.argv[sys.argv.index('--start') + 1])
    if '--ref' in sys.argv:
        return ref(n, start)
    if '--port' in sys.argv:
        return port(n, start)
    print(__doc__)
    return 2


if __name__ == '__main__':
    raise SystemExit(main())

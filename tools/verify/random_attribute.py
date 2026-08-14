#!/usr/bin/env python3
"""random_attribute.py -- WHICH parameter causes a random-gate cell to differ.

`random_state_ab.py` proves 44 cells disagree between the port and the plugin
when every parameter is random. It does not say WHY. This finds the parameter,
by experiment rather than by reading code and guessing.

THE METHOD: HOLD-OUT. Take a failing seed. Keep every leaf random EXCEPT one
GROUP, which is pinned to factory patch 0's values. Re-run. If a cell stops
differing, the cause is inside that group. Then split the group and repeat.

Why hold-out and not "vary one parameter alone": varying one alone is exactly
what `recall_exhaustive_gate` already does, over every value and every rate, and
it finds NOTHING here. These defects need two or more parameters set together,
so the cause is only visible when the others stay random.

⚠ TWO-PROCESS RULE: --ref (Unicorn) writes the pickles, --port (ctypes) reads.

⚠ THIS DOES NOT DERIVE THE LAW. It names the parameters. The law itself must
then be derived by driving the plugin's own dispatch -- never fitted to these
seeds, which would be a capture-derived constant by another name.

USAGE
    python3 tools/verify/random_attribute.py --ref  <seed> [--groups N]
    python3 tools/verify/random_attribute.py --port <seed> [--groups N]
"""
import os
import sys
import pickle
import struct

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import random_state_ab as RS                          # noqa: E402
import recall_fullstate_diff as FS                    # noqa: E402

SCRATCH = RS.SCRATCH
SR = RS.SR


def groups_of(leaves, ngroups):
    # --leaves a,b,c  -> each named leaf is its OWN group, for the refine pass
    # after a coarse run has narrowed the cause to one group.
    only = os.environ.get('JUNO_ATTR_LEAVES')
    if only:
        return [[int(x)] for x in only.split(',')]
    bbs = sorted(bb for _i, bb in leaves)
    per = (len(bbs) + ngroups - 1) // ngroups
    return [bbs[i:i + per] for i in range(0, len(bbs), per)]


def bank_holding(seed, leaves, hold, fac):
    """Every leaf random for `seed`, except those in `hold`, pinned to factory."""
    fixed = None
    b = bytearray(RS.synth_bank(seed, leaves, fixed))
    base = RS.HEADER + RS.BLOB_OFF
    for bb in hold:
        v = fac[bb]
        b[base + bb] = (v >> 4) & 0xF
        b[base + bb + 1] = v & 0xF
    return bytes(b)


def pkl(seed, g):
    return os.path.join(SCRATCH, 'attr_%d_%d.pkl' % (seed, g))


def ref(seed, ng):
    import e2e_emu as E
    import real_recall as R
    import recall_render_ab as RR
    leaves = R.leaf_table()
    fac = RS.factory_leaves(leaves)
    offs = FS.offsets()
    for g, hold in enumerate(groups_of(leaves, ng)):
        bank = bank_holding(seed, leaves, hold, fac)
        e = RR.prepare_recall(0, bank, leaves, E, R, SR)
        st = e.state[0]
        d = {o: struct.unpack('<I', e.uc.mem_read(st + o, 4))[0] for o in offs}
        pickle.dump({'hold': hold, 'state': d}, open(pkl(seed, g), 'wb'))
        print('  group %d (%d leaves) ref done' % (g, len(hold)), flush=True)
    return 0


def port(seed, ng):
    import ctypes
    import real_recall as R
    lib = ctypes.CDLL(os.path.join(RS.ROOT, 'libjuno.so'))
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p,
                                        ctypes.c_int, ctypes.c_int]
    lib.juno_gui_peek.restype = ctypes.c_uint
    lib.juno_gui_peek.argtypes = [ctypes.c_void_p, ctypes.c_int]
    lib.juno_gui_destroy.argtypes = [ctypes.c_void_p]
    leaves = R.leaf_table()
    fac = RS.factory_leaves(leaves)

    def inert(o):
        return o < 176 or o in (10759472, 11022352, 11022356)

    print('=== HOLD-OUT ATTRIBUTION, seed %d ===' % seed)
    print('A group whose removal FIXES cells contains the cause.\n')
    base_bad = None
    for g, hold in enumerate(groups_of(leaves, ng)):
        p = pkl(seed, g)
        if not os.path.exists(p):
            continue
        d = pickle.load(open(p, 'rb'))
        ctx = lib.juno_gui_create(ctypes.c_float(SR), 0)
        lib.juno_gui_apply_bank(ctx, bank_holding(seed, leaves, hold, fac),
                                RS.BANK_LEN, 0)
        bad = {o for o in d['state']
               if not inert(o) and lib.juno_gui_peek(ctx, o) != d['state'][o]}
        lib.juno_gui_destroy(ctx)
        if base_bad is None:
            base_bad = bad
        print('group %2d  leaves %-4d  differing cells %3d' %
              (g, len(hold), len(bad)))
    return 0


def main():
    seed = 0
    ng = 16
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    if args:
        seed = int(args[0])
    if '--groups' in sys.argv:
        ng = int(sys.argv[sys.argv.index('--groups') + 1])
    if '--ref' in sys.argv:
        return ref(seed, ng)
    if '--port' in sys.argv:
        return port(seed, ng)
    print(__doc__)
    return 2


if __name__ == '__main__':
    raise SystemExit(main())

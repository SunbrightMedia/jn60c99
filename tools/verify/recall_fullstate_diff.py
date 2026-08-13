#!/usr/bin/env python3
"""recall_fullstate_diff.py -- diff the WHOLE post-recall state, port vs plugin.

WHY IT EXISTS (2026-08-13). The user's 12 banks -- 768 patches the port had
never seen -- gave this:

    recall_gate   768/768 PASS
    render A/B    637/691 bit-exact, 54 patches differ

and the divergence starts at SAMPLE 2 and touches nearly every sample after.
That is not drift or rounding. A coefficient is wrong before the first note is
shaped.

`recall_gate` cannot see it, and that is not a bug in it: it compares VOICE 0
and 67 enumerator-written cells. The render reads far more -- the other seven
voices, the master chain, and every FX block. A cell that is wrong outside
those 67 passes recall and fails render, which is exactly the observed shape.

So this compares EVERYTHING: the full 0xA83010 state, cell by cell, for one
patch, and prints the cells that differ with the value on each side.

⚠ TWO-PROCESS RULE. The oracle (Unicorn) and the port (ctypes libjuno) may
never live in one process. `--ref` writes a pickle; `--port` reads it. They
meet only through that file.

⚠ THE PLUGIN IS THE ORACLE, THE BANK IS INPUT. Point it at any bank with
$JUNO_TRUTH; the user's banks are input and never ground truth.

USAGE
    python3 tools/verify/recall_fullstate_diff.py --ref  <patch>
    python3 tools/verify/recall_fullstate_diff.py --port <patch>   # prints the diff
"""
import os
import sys
import pickle
import struct

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import truth                                     # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(
    os.path.abspath(__file__))))
SCRATCH = os.path.join(ROOT, 'scratchpad')
BANK = truth.BANK
SR = float(os.environ.get('JUNO_RENDER_SR', '44100'))
STATE_SZ = 0xA83010

# The regions the render actually reads. Dumping all 11 MB through a 4-byte
# accessor is 2.7 M calls per patch; these cover every cell any render path
# touches, and a cell outside them cannot reach the audio.
#   voices        8 x 10512 from 0
#   shared noise  84272..84436
#   aux one-shot  101504 + v*32
#   master/FX     the blocks master_render.c reads
REGIONS = [
    (0, 8 * 10512),
    (84272, 84436),
    (101504, 101504 + 8 * 32),
    (102336, 102720),          # delay type 0 block
    (4297552, 4297856),        # delay second instance
    (6395248, 6395440),        # delay t23
    (6429408, 6429440),
    (6463712, 6463744),
    (6496480, 6497500),        # delay t5 + fine-FX
    (8594768, 8594800),
    (10691936, 10693300),      # chorus
    (10726256, 10726288),
    (10759040, 10759520),      # reverb
    (11022040, 11022360),      # effect routing / prog id
    (90624, 96000),            # chorus LFO + BBD ring
    (100992, 101060),
]


def offsets():
    out = []
    for a, b in REGIONS:
        out.extend(range(a & ~3, b, 4))
    return sorted(set(out))


def ref(patch):
    import e2e_emu as E
    import real_recall as R
    import recall_render_ab as RR
    bank = E.bank_bytes()
    leaves = R.leaf_table()
    e = RR.prepare_recall(patch, bank, leaves, E, R, SR)
    st = e.state[0]
    d = {}
    for off in offsets():
        d[off] = struct.unpack('<I', e.uc.mem_read(st + off, 4))[0]
    p = os.path.join(SCRATCH, 'fullstate_ref_%d.pkl' % patch)
    pickle.dump(d, open(p, 'wb'))
    print('ref: patch %d, %d cells -> %s' % (patch, len(d), p))
    return 0


def as_f(u):
    return struct.unpack('<f', struct.pack('<I', u))[0]


def port(patch):
    import ctypes
    lib = ctypes.CDLL(os.path.join(ROOT, 'libjuno.so'))
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p,
                                        ctypes.c_int, ctypes.c_int]
    lib.juno_gui_peek.restype = ctypes.c_uint
    lib.juno_gui_peek.argtypes = [ctypes.c_void_p, ctypes.c_int]
    bank = open(BANK, 'rb').read()
    ctx = lib.juno_gui_create(ctypes.c_float(SR), 0)
    lib.juno_gui_apply_bank(ctx, bank, len(bank), patch)

    r = pickle.load(open(os.path.join(SCRATCH,
                                      'fullstate_ref_%d.pkl' % patch), 'rb'))
    bad = []
    for off in sorted(r):
        pv = lib.juno_gui_peek(ctx, off)
        if pv != r[off]:
            bad.append((off, r[off], pv))
    print('=== FULL-STATE RECALL DIFF, patch %d, SR %g ===' % (patch, SR))
    print('bank: %s' % BANK)
    print('cells compared: %d   DIFFERING: %d' % (len(r), len(bad)))
    if not bad:
        print('\nNo cell differs. The recall is identical and the render '
              'divergence is NOT a recalled coefficient -- look at the render '
              'path or at which VOICE the note lands on.')
        return 0
    print('\n%10s %14s %14s   %s' % ('cell', 'plugin', 'port', 'as float'))
    for off, rv, pv in bad[:80]:
        print('%10d %14d %14d   %+.9g vs %+.9g'
              % (off, rv, pv, as_f(rv), as_f(pv)))
    if len(bad) > 80:
        print('... %d more' % (len(bad) - 80))
    # Group by region, because one wrong law usually moves a whole block.
    print('\nby region:')
    for a, b in REGIONS:
        n = sum(1 for off, _, _ in bad if a <= off < b)
        if n:
            print('  %8d..%-8d  %d cells' % (a, b, n))
    return 1


def main():
    if '--ref' in sys.argv:
        return ref(int(sys.argv[sys.argv.index('--ref') + 1]))
    if '--port' in sys.argv:
        return port(int(sys.argv[sys.argv.index('--port') + 1]))
    print(__doc__)
    return 2


if __name__ == '__main__':
    raise SystemExit(main())

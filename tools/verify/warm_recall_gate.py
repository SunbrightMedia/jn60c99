#!/usr/bin/env python3
"""warm_recall_gate.py -- the WARM two-recall harness: N patch recalls through ONE
engine on each side, then a whole-state A/B.

WHY IT EXISTS (2026-08-15). Every gate in tools/verify/ recalls COLD. They all go
through recall_render_ab.prepare_recall, which was `e = E.E2E(); e.build(sr)` per
comparison -- a FRESH plugin engine per patch. The port is NOT fresh per patch:
src/juno_apply.c:647 juno_bank_apply writes into an EXISTING state (chorus at :799)
and never re-prepares. So the two sides were only ever compared in the one condition
where the port's statefulness cannot show: the first patch after power-on.

Consequence, and it is the whole reason for this file: NOT ONE GATE IN THIS TREE
COULD FAIL ON A WARM DEFECT, and a warm defect is live in the SHIPPING FACTORY BANK
(chorus WET cell 91232, factory p39 -> p40). Playbook 38 recurring: a defect class
that is catalogued but not gated is still shipping.

WHAT IT DOES
  --ref  (Unicorn ONLY)  build ONE plugin engine, then apply patch A's own recall,
                         then patch B's, then C's... WITHOUT rebuilding. Dump the
                         compared cells AFTER EVERY STEP to a pickle.
  --port (ctypes ONLY)   ONE juno_gui_create, then juno_gui_apply_bank per patch in
                         the same order. Compare every step against the pickle.

Comparing EVERY step, not just the last, is what separates "the port is wrong about
this patch" (step 0 red too) from "the port is wrong about this TRANSITION" (step 0
green, step 1 red). Only the second is a warm defect.

⚠ TWO-PROCESS RULE (CLAUDE.md): a Unicorn E2E instance and a ctypes libjuno.so may
never live in one process. They meet only through the pickle.

⚠ THE PLUGIN IS THE ORACLE. Nothing here is fitted to an observation; the port side
never runs before the plugin side has written the pickle.

GENERAL BY DESIGN -- G2 (warm DELAY LEVEL) and G3 (warm delay tear-down) are this
tool with a different --seq, --bank and --cells. Nothing about chorus is hardcoded.

USAGE
    python3 tools/verify/warm_recall_gate.py --ref  --seq 39,40 --cells 91232
    python3 tools/verify/warm_recall_gate.py --port --seq 39,40 --cells 91232

    --seq A,B[,C...]   patch indices, applied in order through ONE engine
                       (env JUNO_WARM_SEQ)
    --cells N[,N...]   extra cells to report BY NAME on every run, pass or fail,
                       in hex, whether or not they are inside the compared regions
                       (env JUNO_WARM_CELLS)
    --cells-only       verdict on the named cells alone (the whole-state diff is
                       still printed -- it is just not the verdict)
    --bank PATH        a bank OTHER than the ground-truth one. Ground truth resolves
                       through truth.py and is NEVER hardcoded here; a --bank/
                       $JUNO_WARM_BANK file is INPUT (a synthetic G2/G3 bank), never
                       ground truth. Both processes must be given the same one -- the
                       pickle carries the bank's sha256 and the port side refuses a
                       mismatch, so this cannot silently compare two different banks.
    $JUNO_RENDER_SR    host rate, default 44100 (recall_fullstate_diff's default).

EXIT 0 = GREEN, 1 = RED, 2 = usage.
"""
import os
import sys
import pickle
import struct
import hashlib

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import truth                                    # noqa: E402  ground-truth paths
import recall_fullstate_diff as FS              # noqa: E402  REGIONS/offsets()
import random_state_ab as RS                    # noqa: E402  the inert-cell rule

ROOT = FS.ROOT
SCRATCH = FS.SCRATCH
SR = float(os.environ.get('JUNO_RENDER_SR', '44100'))


def bank_path():
    """The bank to recall from. Ground truth resolves through truth.py ($JUNO_TRUTH
    or <repo>/truth), never a path written into this file."""
    return os.environ.get('JUNO_WARM_BANK') or truth.BANK


def parse_seq(argv):
    v = None
    if '--seq' in argv:
        v = argv[argv.index('--seq') + 1]
    else:
        v = os.environ.get('JUNO_WARM_SEQ')
    if not v:
        return None
    return [int(x) for x in v.replace(',', ' ').split()]


def parse_cells(argv):
    v = None
    if '--cells' in argv:
        v = argv[argv.index('--cells') + 1]
    else:
        v = os.environ.get('JUNO_WARM_CELLS')
    if not v:
        return []
    return [int(x, 0) for x in v.replace(',', ' ').split()]


def compare_offsets(cells):
    """The whole render-visible state (recall_fullstate_diff.offsets(), widened
    2026-08-15 to cover four FX cell pairs that sat outside it) PLUS any cell the
    caller named -- a named cell outside REGIONS is still dumped and still judged."""
    return sorted(set(FS.offsets()) | {c & ~3 for c in cells})


def pkl_path(seq):
    return os.path.join(SCRATCH, 'warm_recall_%s_%g.pkl'
                        % ('-'.join(str(p) for p in seq), SR))


def sha(path):
    h = hashlib.sha256()
    with open(path, 'rb') as f:
        for chunk in iter(lambda: f.read(1 << 20), b''):
            h.update(chunk)
    return h.hexdigest()


def banner(seq, offs, bp, bsha):
    print('=== WARM RECALL GATE -- %s ===' % ' -> '.join('p%d' % p for p in seq))
    print('ONE engine per side. The engine is NOT rebuilt between patches.')
    print('bank:   %s' % bp)
    print('sha256: %s' % bsha)
    print('SR %g   steps %d   cells compared %d' % (SR, len(seq), len(offs)))


# --------------------------------------------------------------- plugin (Unicorn)
def ref(seq, cells):
    import e2e_emu as E
    import real_recall as R
    import recall_render_ab as RR

    bp = bank_path()
    bank = open(bp, 'rb').read()
    leaves = R.leaf_table()
    offs = compare_offsets(cells)
    banner(seq, offs, bp, sha(bp))

    # THE WHOLE POINT: build_engine ONCE, apply_recall per patch. The cold gates call
    # prepare_recall, which is build_engine+apply_recall fused -- one engine per patch.
    e = RR.build_engine(E, SR)
    steps = []
    for i, idx in enumerate(seq):
        RR.apply_recall(e, idx, bank, leaves, E, R)
        steps.append(dump_ref(e, offs))
        print('  step %d: patch %2d (%s) recalled into the SAME engine'
              % (i, idx, E.patch_name(bank, idx)), flush=True)

    out = {'seq': seq, 'cells': cells, 'offs': offs, 'sr': SR,
           'bank': bp, 'bank_sha256': sha(bp), 'steps': steps}
    p = pkl_path(seq)
    pickle.dump(out, open(p, 'wb'))
    print('ref: %d steps x %d cells -> %s' % (len(steps), len(offs), p))
    return 0


def dump_ref(e, offs):
    """Read the compared cells out of the plugin's unit-0 state. Region-at-a-time
    (one mem_read per REGION, not one per cell): 23,627 cells x N steps through a
    4-byte accessor is the difference between seconds and minutes."""
    st = e.state[0]
    d = {}
    runs = contiguous(offs)
    for a, n in runs:
        raw = e.uc.mem_read(st + a, 4 * n)
        vals = struct.unpack('<%dI' % n, raw)
        for k in range(n):
            d[a + 4 * k] = vals[k]
    return d


def contiguous(offs):
    """[(start, ncells)] runs of 4-byte-adjacent offsets, so both sides can read in
    bulk instead of cell by cell."""
    runs = []
    start = prev = None
    for o in offs:
        if start is None:
            start = prev = o
            continue
        if o == prev + 4:
            prev = o
            continue
        runs.append((start, (prev - start) // 4 + 1))
        start = prev = o
    if start is not None:
        runs.append((start, (prev - start) // 4 + 1))
    return runs


# ------------------------------------------------------------------ port (ctypes)
def dump_port(lib, ctx, offs, runs):
    d = {}
    for a, n in runs:
        buf = (__import__('ctypes').c_ubyte * (4 * n))()
        got = lib.juno_gui_dump(ctx, a, buf, 4 * n)
        if got != 4 * n:
            raise SystemExit('juno_gui_dump short read at %d: %d of %d'
                             % (a, got, 4 * n))
        vals = struct.unpack('<%dI' % n, bytes(buf))
        for k in range(n):
            d[a + 4 * k] = vals[k]
    return d


def as_f(u):
    return struct.unpack('<f', struct.pack('<I', u))[0]


def port(seq, cells, cells_only):
    import ctypes
    import freshlib                       # refuse a libjuno.so older than src/
    p = pkl_path(seq)
    if not os.path.exists(p):
        raise SystemExit('no reference pickle %s -- run --ref first (SAME --seq, '
                         'SAME $JUNO_RENDER_SR)' % p)
    ref = pickle.load(open(p, 'rb'))
    bp = bank_path()
    bsha = sha(bp)
    if bsha != ref['bank_sha256']:
        raise SystemExit('BANK MISMATCH -- the reference was taken from\n  %s\n  %s\n'
                         'and this process holds\n  %s\n  %s\nRefusing: comparing two '
                         'different banks would report the DATA as a port defect.'
                         % (ref['bank'], ref['bank_sha256'], bp, bsha))
    if ref['sr'] != SR:
        raise SystemExit('SR MISMATCH: reference %g, this process %g'
                         % (ref['sr'], SR))
    offs = ref['offs']
    banner(seq, offs, bp, bsha)
    print('inert cells skipped (random_state_ab.inert): off < 176, '
          '10759472, 11022352, 11022356')

    lib = freshlib.load()
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p,
                                        ctypes.c_int, ctypes.c_int]
    lib.juno_gui_dump.restype = ctypes.c_int
    lib.juno_gui_dump.argtypes = [ctypes.c_void_p, ctypes.c_int,
                                  ctypes.POINTER(ctypes.c_ubyte), ctypes.c_int]
    lib.juno_gui_destroy.argtypes = [ctypes.c_void_p]

    bank = open(bp, 'rb').read()
    runs = contiguous(offs)
    ctx = lib.juno_gui_create(ctypes.c_float(SR), 0)   # ONE ctx for the whole run
    got = []
    for idx in seq:
        lib.juno_gui_apply_bank(ctx, bank, len(bank), idx)
        got.append(dump_port(lib, ctx, offs, runs))
    lib.juno_gui_destroy(ctx)

    red = False
    named_red = False
    for i, idx in enumerate(seq):
        r, g = ref['steps'][i], got[i]
        bad = [(o, r[o], g[o]) for o in offs
               if not RS.inert(o) and r[o] != g[o]]
        print('\n--- step %d: patch %d %s---'
              % (i, idx, '(WARM: engine already holds p%d) ' % seq[i - 1]
                 if i else '(cold: first recall after prepare) '))
        if cells:
            print('  NAMED CELLS')
            for c in cells:
                o = c & ~3
                mark = '  *** DIFFER ***' if r[o] != g[o] else '  same'
                print('    %-10d plugin 0x%08x  port 0x%08x   %+.9g vs %+.9g%s'
                      % (c, r[o], g[o], as_f(r[o]), as_f(g[o]), mark))
                if r[o] != g[o]:
                    named_red = True
        print('  whole-state: %d of %d cells differ' % (len(bad), len(offs)))
        for o, rv, gv in bad[:40]:
            print('    %-10d plugin 0x%08x  port 0x%08x   %+.9g vs %+.9g'
                  % (o, rv, gv, as_f(rv), as_f(gv)))
        if len(bad) > 40:
            print('    ... %d more' % (len(bad) - 40))
        if bad:
            red = True

    verdict = named_red if cells_only else (red or named_red)
    print('\nVERDICT: %s' % ('RED' if verdict else 'GREEN'))
    return 1 if verdict else 0


def main():
    seq = parse_seq(sys.argv)
    cells = parse_cells(sys.argv)
    if not seq or len(seq) < 2:
        print(__doc__)
        print('ERROR: --seq needs at least two patches; a one-patch sequence is a '
              'COLD recall and recall_fullstate_diff.py already does that.',
              file=sys.stderr)
        return 2
    if '--ref' in sys.argv:
        return ref(seq, cells)
    if '--port' in sys.argv:
        return port(seq, cells, '--cells-only' in sys.argv)
    print(__doc__)
    return 2


if __name__ == '__main__':
    raise SystemExit(main())

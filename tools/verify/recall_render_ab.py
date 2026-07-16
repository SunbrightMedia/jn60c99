#!/usr/bin/env python3
"""recall_render_ab.py -- Phase-1 AUDIBLE gate: port recall+render vs the PLUGIN's
own recall+render, BIT-EXACT on the output audio.

This is the authoritative Phase-1 judge (NOT the recall-state diff): a cell only
needs fixing if fixing it makes THIS A/B more bit-exact; a cell that diverges in
the recall-state diff but is render-overwritten shows up here as already-matching.

REFERENCE (process 1, --ref) = the plugin's OWN recall + render, executed under
Unicorn, with ZERO port code in the path:
  build (0x3C68D0, applies defaults to all 9 units) -> snap_all
  -> write each COMPLETE value-tree leaf's decoded patch byte into the plugin's
     descriptor table, then dispatch that leaf through the plugin's REAL setter
     (sub_7FF91E019A30) to all 9 units  [ = real_recall's dispatch-loop recall ]
  -> snap_all -> clear_latch -> set_ftz -> note_on(60,105) -> render(N)
  This is the plugin's changed-leaf recall (its true replaceState behaviour): each
  leaf setter is a direct idempotent store, so dispatching every leaf == dispatching
  only the changed ones. It is NOT the full 0..4965 loop: re-dispatching the ~4850
  NON-leaf indices (recall_fullstate_diff.py --ref) clobbers real leaf cells the
  plugin never re-touches on recall -- e.g. VCF cutoff 6736 -> 1.0 (the golden/oracle-
  proven per-patch value is 0.6) and LFO-rate 1088/2064 -> a constant. The full loop
  is thus contaminated for those cells; the complete-leaf recall matches the plugin's
  captured post-recall engine state (juno_apply.c: 6736 == coarse value, 0/64 mism).

PORT (process 2, --port) = juno_gui_create(SR) + juno_gui_apply_bank(patch)
  + juno_gui_note_on(60,105) + juno_gui_render(N), via ctypes on libjuno.so.

TWO-PROCESS (mandatory): never build E2E + load libjuno in one process.
  python3 recall_render_ab.py --ref  [patches...]   # plugin -> pickle
  python3 recall_render_ab.py --port [patches...]   # port, compare, verdict
"""
import sys, struct, pickle

HERE = '/home/user/jn60c99/tools/verify'
sys.path.insert(0, HERE)
PKL  = '/home/user/jn60c99/scratchpad/recall_render_ref.pkl'
import os as _o, sys as _s; _s.path.insert(0, _o.path.dirname(_o.path.abspath(__file__)))
import truth; BANK = truth.BANK  # single source of ground truth (truth/ folder)
SR   = 48000.0
NOTE, VEL, N = 60, 105, 16000

# diff set (RANGE/PWM/LFO variation) + delay-active + no-divergence controls.
DEFAULT_PATCHES = [62, 5, 18, 39, 6, 14, 31, 0, 21, 53, 50, 12, 45, 13, 22]


def parse_patches(argv):
    ps = [int(a) for a in argv if a.lstrip('-').isdigit()]
    return ps or DEFAULT_PATCHES


# Master/FX value-tree leaves whose dispatch index is beyond real_recall.leaf_table's
# voice range (disp <= 877) but which the plugin's replaceState still fires on recall.
# (dispatch idx, RECORD byte): DELAY FEEDBACK -> 102560, DELAY DIRECT LEVEL -> 102512.
# Executed law (scratchpad/sweep_delay_fx.py): 102560 = byte/255*0.9, 102512 = byte/255.
FX_LEAVES = [(1179, 3057), (1181, 3060)]


def ref_render(idx, bank, leaves, E, R):
    e = E.E2E(); e.build(SR); e.snap_all()
    blob = E.patch_blob(bank, idx)
    for (disp, bb) in leaves:
        R.wr_desc(e, disp, R.dec(blob, bb))
    for (disp, recoff) in FX_LEAVES:                  # record byte -> blob-relative
        R.wr_desc(e, disp, R.dec(blob, recoff - 16))
    for u in range(9):
        for (disp, bb) in leaves:
            try: e.dispatch(u, disp, R.rd_desc(e, disp))
            except RuntimeError: pass
        for (disp, recoff) in FX_LEAVES:
            try: e.dispatch(u, disp, R.rd_desc(e, disp))
            except RuntimeError: pass
    e.snap_all(); e.clear_latch(); e.set_ftz()
    e.note_on(NOTE, VEL)
    return e.render(N)


def cmp_stream(la, ra, lb, rb):
    n = min(len(la), len(lb)); first = None; nd = 0
    for i in range(n):
        if la[i] != lb[i] or ra[i] != rb[i]:
            nd += 1
            if first is None: first = i
    return n, nd, first


if len(sys.argv) > 1 and sys.argv[1] == '--ref':
    import e2e_emu as E
    import real_recall as R
    patches = parse_patches(sys.argv[2:])
    bank = E.bank_bytes(); leaves = R.leaf_table()
    out = {}
    for idx in patches:
        L, Rr = ref_render(idx, bank, leaves, E, R)
        out[idx] = (L, Rr)
        sys.stderr.write("ref patch %2d (%s): %d frames\n" % (idx, E.patch_name(bank, idx), len(L)))
        sys.stderr.flush()
    pickle.dump(out, open(PKL, 'wb'))
    print("REF: saved %d patch render streams (N=%d, note %d vel %d, SR %g)" %
          (len(out), N, NOTE, VEL, SR))

elif len(sys.argv) > 1 and sys.argv[1] == '--port':
    import ctypes
    ref = pickle.load(open(PKL, 'rb'))
    bankbytes = open(BANK, 'rb').read()
    lib = ctypes.CDLL('/home/user/jn60c99/libjuno.so')
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_render.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int]
    import e2e_emu as E
    bank = E.bank_bytes()
    print("=== recall RENDER A/B: port vs plugin's own recall+render ===")
    print("N=%d note %d vel %d SR %g\n" % (N, NOTE, VEL, SR))
    npass = nfail = 0
    fails = []
    for idx in sorted(ref):
        c = lib.juno_gui_create(ctypes.c_float(SR), 0)
        lib.juno_gui_apply_bank(c, bankbytes, len(bankbytes), idx)
        lib.juno_gui_note_on(c, NOTE, VEL)
        buf = (ctypes.c_float * (2 * N))(); lib.juno_gui_render(c, buf, N)
        inter = struct.unpack("<%dI" % (2 * N), bytes(buf))
        L = list(inter[0::2]); R = list(inter[1::2])
        la, ra = ref[idx]
        n, nd, first = cmp_stream(la, ra, L, R)
        tag = 'BIT-EXACT' if nd == 0 else ('FIRST@%d diffs=%d' % (first, nd))
        print("  patch %2d %-18s %s" % (idx, E.patch_name(bank, idx), tag))
        if nd == 0: npass += 1
        else: nfail += 1; fails.append(idx)
    print("\n%d/%d BIT-EXACT%s" % (npass, npass + nfail,
          "" if not fails else "  FAIL: " + str(fails)))
    sys.exit(1 if nfail else 0)   # gate semantics: RED until every patch is bit-exact
else:
    print("usage: recall_render_ab.py --ref | --port  [patches...]", file=sys.stderr)
    sys.exit(2)

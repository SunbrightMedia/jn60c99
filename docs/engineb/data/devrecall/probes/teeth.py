#!/usr/bin/env python3
"""Teeth + controls for the warm-vs-cold plugin harness.

T1 (control, must be ZERO)  : warm(B->B) vs cold(B).  Recalling the SAME patch
    twice must be the identity.  If this is non-zero the harness's second recall
    is itself perturbing state and EVERY positive result is worthless.
T2 (control, must be LARGE) : cold(B) vs cold(C), B != C.  Proves the differ can
    see a difference at all.
T3 (tooth, must be CAUGHT)  : warm(A->B) with ONE leaf of B's recall deliberately
    skipped (VCF CUTOFF, dispatch 779).  A recall-completeness defect of exactly
    the shape being hunted.  If T3 is not caught the diff is blind to it.
T4 (tooth, must be CAUGHT)  : warm(A->B) with ONE leaf of B given a wrong value.
"""
import sys, gc, struct
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E, real_recall as R, recall_render_ab as RR
from warm_plugin import build_engine, snapshot, diff_units, recall_into

SR = 44100.0
bank = E.bank_bytes(); leaves = R.leaf_table()


def recall_mut(e, idx, skip=None, force=None):
    blob = E.patch_blob(bank, idx)
    for (disp, bb) in leaves:
        v = R.dec(blob, bb)
        if force and disp == force[0]: v = force[1]
        R.wr_desc(e, disp, v)
    for (disp, recoff) in RR.FX_LEAVES: R.wr_desc(e, disp, R.dec(blob, recoff - 16))
    for (disp, bb) in RR.EXTRA_LEAVES:  R.wr_desc(e, disp, R.dec(blob, bb))
    finefx = RR._finefx_leaves(blob, R)
    for (disp, recoff, raw) in finefx:
        R.wr_desc(e, disp, (blob[recoff - 16] & 0x7F) if raw else R.dec(blob, recoff - 16))
    for u in range(9):
        for (disp, bb) in leaves:
            if skip is not None and disp == skip: continue
            try: e.dispatch(u, disp, R.rd_desc(e, disp))
            except RuntimeError: pass
        for (disp, recoff) in RR.FX_LEAVES:
            try: e.dispatch(u, disp, R.rd_desc(e, disp))
            except RuntimeError: pass
        for (disp, bb) in RR.EXTRA_LEAVES:
            try: e.dispatch(u, disp, R.rd_desc(e, disp))
            except RuntimeError: pass
        for (disp, recoff, raw) in finefx:
            try: e.dispatch(u, disp, R.rd_desc(e, disp))
            except RuntimeError: pass
    e.assigner_notify(); e.snap_all()


def cold(p, **kw):
    e = build_engine(SR); recall_mut(e, p, **kw); s = snapshot(e); del e; gc.collect(); return s


def warm(a, b, **kw):
    e = build_engine(SR); recall_mut(e, a); recall_mut(e, b, **kw)
    s = snapshot(e); del e; gc.collect(); return s


for b in (13, 22, 5):
    t, _ = diff_units(cold(b), warm(b, b))
    print('T1 control  warm(%d->%d) vs cold(%d) : %d differing bytes   %s'
          % (b, b, b, t, 'PASS (0)' if t == 0 else '*** HARNESS BROKEN ***'))
t, _ = diff_units(cold(13), cold(22))
print('T2 control  cold(13) vs cold(22)      : %d differing bytes   %s'
      % (t, 'PASS (non-zero)' if t else '*** DIFFER IS BLIND ***'))
t, per = diff_units(cold(13), warm(12, 13, skip=779))
print('T3 tooth    warm(12->13) with VCF CUTOFF (779) NOT dispatched : %d bytes  %s'
      % (t, 'CAUGHT' if t else '*** NOT CAUGHT ***'))
if per:
    u = min(per); print('     first runs:', [(s, (s // 16) * 16) for (s, _, _, _) in per[u][:6]])
t, per = diff_units(cold(13), warm(12, 13, force=(779, 200)))
print('T4 tooth    warm(12->13) with VCF CUTOFF forced to 200        : %d bytes  %s'
      % (t, 'CAUGHT' if t else '*** NOT CAUGHT ***'))

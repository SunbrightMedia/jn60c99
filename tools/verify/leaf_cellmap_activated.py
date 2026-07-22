#!/usr/bin/env python3
"""PILLAR 1 completion — the ACTIVATED cell-map sweep. Resolves both soft spots
of the isolated sweep at once:
  - UNRESOLVED extended-FX leaves (MFX/flanger/rev/cho) whose blocks were never
    set up, and
  - conditional setters wrongly bucketed INERT (e.g. F ENV VARIATION) that write
    nothing until their precondition state exists.
Method: in each EFFECT-TYPE context, first PRE-ACTIVATE by dispatching ALL 269
dispatchable leaves to a nonzero value (every block + every smoother target set
up live), snap, THEN sweep each leaf min<->max with memory-write instrumentation
— the other 268 leaves stay fixed, so the diff still isolates the swept leaf's
cells, but now against a fully-live engine. Union over contexts merges into
leaf_cellmap.pkl. Oracle-only (Unicorn)."""
import sys, pickle
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E
from unicorn import UC_HOOK_MEM_WRITE

SP  = '/tmp/claude-0/-home-user-jn60c99/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/scratchpad'
PKL = SP + '/leaf_cellmap.pkl'
CW  = SP + '/chillwave.bin'
SZ  = 0xA83010
EFFECT_TYPE, DELAY_TYPE, REVERB_TYPE = 873, 875, 876

cm = pickle.load(open(PKL, 'rb'))
leaves = [(d, cm[d]['rmax']) for d in sorted(cm)]

facbank = E.bank_bytes(); cwbank = open(CW, 'rb').read()
std = E.load_leaves()

def recall_full(e, bank, idx):
    blob = E.patch_blob(bank, idx)
    for (p, nm, disp, bb) in std:
        for u in range(9):
            try: e.dispatch(u, disp, E.dec(blob, bb))
            except RuntimeError: pass

# (label, which, patch, effect_type, reverb_type)
CTXS = [('chorusI','fac',0,2,None), ('chorusII','fac',11,3,None),
        ('mfx','fac',7,5,None), ('flanger','cw',32,4,None),
        ('reverb','fac',20,2,2), ('delay','fac',13,None,None), ('pan','fac',9,1,None)]

for (label, which, idx, et, rt) in CTXS:
    bank = facbank if which == 'fac' else cwbank
    e = E.E2E(); e.build(48000.0); e.snap_all()
    recall_full(e, bank, idx); e.snap_all()
    # PRE-ACTIVATE: every dispatchable leaf to its max, so every block is live.
    for (d, rm) in leaves:
        for u in range(9):
            try: e.dispatch(u, d, rm)
            except RuntimeError: pass
    if et is not None or rt is not None:
        for u in range(9):
            if et is not None:
                try: e.dispatch(u, EFFECT_TYPE, et)
                except RuntimeError: pass
            if rt is not None:
                try: e.dispatch(u, REVERB_TYPE, rt)
                except RuntimeError: pass
    e.snap_all()
    base = e.state[0]; lo, hi = base, base + SZ
    written = set()
    def hook(uc, acc, addr, sz, val, u):
        if lo <= addr < hi: written.add((addr - base) & ~3)
    h = e.uc.hook_add(UC_HOOK_MEM_WRITE, hook)
    for (d, rm) in leaves:
        for val in (0, rm):
            written.clear()
            for u in range(9):
                try: e.dispatch(u, d, val)
                except RuntimeError: pass
            cm[d]['cells'] = sorted(set(cm[d]['cells']) | written)
    e.uc.hook_del(h)
    sys.stderr.write("activated ctx %s done\n" % label); sys.stderr.flush()

pickle.dump(cm, open(PKL, 'wb'))
nz = sum(1 for d in cm if cm[d]['cells'])
print("activated sweep done; %d/%d leaves now write cells" % (nz, len(cm)))

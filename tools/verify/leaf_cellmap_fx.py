#!/usr/bin/env python3
"""PILLAR 1 / Stage A completion — re-sweep the extended-FX leaves in CORRECT
FX-active patch contexts (the first pass used a non-chorus patch for 'chorus',
so the chorus block was never live and its setters wrote nothing). Recalling a
real patch of each EFFECT TYPE via load_leaves activates that block (as
ext_sweeps did with patch 5), so each fine-FX setter writes to a live block.

Contexts (patch, EFFECT TYPE): chorusI=factory0(2), chorusII=factory11(3),
mfx=factory7(5), pan=factory9(1), delay=factory13, flanger=chillwave32(4),
reverb=factory20(reverb-active). Merges cells into leaf_cellmap.pkl for the
PAT2_*/EFX/CTRL leaves; the rest keep their first-pass result.
Oracle-only (Unicorn). Output: updates scratchpad/leaf_cellmap.pkl in place.
"""
import sys, pickle
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E
from unicorn import UC_HOOK_MEM_WRITE

SP  = '/tmp/claude-0/-home-user-jn60c99/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/scratchpad'
PKL = SP + '/leaf_cellmap.pkl'
CW  = SP + '/chillwave.bin'
SZ  = 0xA83010
EFFECT_TYPE, REVERB_TYPE = 873, 876

cellmap = pickle.load(open(PKL, 'rb'))
# target: every PATCH2-family FX leaf + EFX/CTRL that is currently silent-or-gap
TARGET = [d for d, i in cellmap.items()
          if i['struct'] in ('PAT2_CHO','PAT2_FL','PAT2_MFX','PAT2_REV','PAT2_DLY',
                             'PAT2_FLT','PAT2_AMP','PAT2_LFO','PAT2_CTRL','EFX','CTRL')]

# (label, bankfile, patch idx, force EFFECT TYPE, force REVERB TYPE)
FACT = None  # loaded via E.bank_bytes()
CTXS = [('chorusI', 'fac', 0, 2, None), ('chorusII', 'fac', 11, 3, None),
        ('mfx', 'fac', 7, 5, None), ('pan', 'fac', 9, 1, None),
        ('delay', 'fac', 13, None, None), ('flanger', 'cw', 32, 4, None),
        ('reverb', 'fac', 20, 2, 2)]

facbank = E.bank_bytes(); cwbank = open(CW, 'rb').read()
leaves_std = E.load_leaves()

def recall_full(e, bank, idx):
    blob = E.patch_blob(bank, idx)
    for (p, nm, disp, bb) in leaves_std:
        val = E.dec(blob, bb)
        for u in range(9):
            try: e.dispatch(u, disp, val)
            except RuntimeError: pass

for (label, which, idx, et, rt) in CTXS:
    bank = facbank if which == 'fac' else cwbank
    e = E.E2E(); e.build(48000.0); e.snap_all()
    recall_full(e, bank, idx); e.snap_all()
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
    for d in TARGET:
        rm = cellmap[d]['rmax']
        for val in (0, rm):
            written.clear()
            for u in range(9):
                try: e.dispatch(u, d, val)
                except RuntimeError: pass
            cellmap[d]['cells'] = sorted(set(cellmap[d]['cells']) | written)
    e.uc.hook_del(h)
    sys.stderr.write("ctx %s (patch %s:%d) done\n" % (label, which, idx)); sys.stderr.flush()

pickle.dump(cellmap, open(PKL, 'wb'))
nz = sum(1 for d in TARGET if cellmap[d]['cells'])
print("re-swept %d FX leaves in 7 real-FX contexts; %d now write cells" % (len(TARGET), nz))

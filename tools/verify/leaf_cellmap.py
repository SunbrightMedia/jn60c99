#!/usr/bin/env python3
"""PILLAR 1 / Stage A — execute every real value-tree leaf under Unicorn and
record which unit-0 engine cells it writes (memory-write instrumentation, not
state-diff — exact and cheap). Swept across several FX-mode contexts so
subsystem-gated setters (reverb cuts need reverb active, flanger needs EFFECT
TYPE 4, mfx needs TYPE 5) are all reached; the per-leaf cell set is the UNION
over contexts. Output: scratchpad/leaf_cellmap.pkl { disp -> {'name','struct',
'cells':sorted[int], 'ctxhits':{ctx:ncells}} }.

This is the plugin's OWN setters executed on the plugin's OWN state — PROVEN
provenance. Covenant-clean. Oracle-only (Unicorn); no ctypes in this process.
"""
import sys, struct, pickle
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E
from unicorn import UC_HOOK_MEM_WRITE

SP  = '/tmp/claude-0/-home-user-jn60c99/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/scratchpad'
OUT = SP + '/leaf_cellmap.pkl'
SZ  = 0xA83010

# real dispatchable leaves from the enumeration (skip _reserve_ / NAME)
def real_leaves():
    rows = []
    for ln in open('/home/user/jn60c99/tools/verify/coverage_leaves.tsv').read().splitlines()[1:]:
        pos, disp, fam, struct_, name, ty, rng, dflt = ln.split('\t')
        if name == '_reserve_' or fam == 'NAME':
            continue
        try:
            rmax = int(rng.split(',')[1])
        except Exception:
            rmax = 255
        rows.append((int(disp), name, struct_, ty, rmax))
    return rows

# EFFECT/DELAY/REVERB TYPE selector dispatch indices (from coverage_leaves.tsv)
EFFECT_TYPE, DELAY_TYPE, REVERB_TYPE = 873, 875, 876

def force_type(e, et=None, dt=None, rt=None):
    for u in range(9):
        if et is not None:
            try: e.dispatch(u, EFFECT_TYPE, et)
            except RuntimeError: pass
        if dt is not None:
            try: e.dispatch(u, DELAY_TYPE, dt)
            except RuntimeError: pass
        if rt is not None:
            try: e.dispatch(u, REVERB_TYPE, rt)
            except RuntimeError: pass

def build_ctx(tag):
    """Return a fresh E2E in a given FX context (all snapped), plus its state base.
    Each context activates a different slot-2/slot-1 algorithm so subsystem-gated
    setters (chorus cuts, flanger, mfx, reverb) are all reached by the union."""
    e = E.E2E(); e.build(48000.0); e.snap_all()
    leaves = E.load_leaves(); bank = E.bank_bytes()
    # full recalls set up the FX blocks realistically; patch 13 = delay-active,
    # patch 7 = EFFECT TYPE 5 (mfx). Then force the routing for the tag.
    base_patch = {'cold': None, 'chorus': 13, 'flanger': 13, 'mfx': 7, 'reverb': 13}[tag]
    if base_patch is not None:
        E.recall_patch(e, base_patch, leaves, bank); e.snap_all()
    et = {'cold': None, 'chorus': 2, 'flanger': 4, 'mfx': 5, 'reverb': 2}[tag]
    rt = 2 if tag == 'reverb' else None
    if et is not None or rt is not None:
        force_type(e, et=et, rt=rt); e.snap_all()
    return e

CONTEXTS = ['cold', 'chorus', 'flanger', 'mfx', 'reverb']
leaves = real_leaves()
cellmap = {d: {'name': n, 'struct': s, 'type': t, 'rmax': rm, 'cells': set(),
               'ctxhits': {}} for (d, n, s, t, rm) in leaves}

for ctx in CONTEXTS:
    e = build_ctx(ctx)
    base = e.state[0]
    lo, hi = base, base + SZ
    written = set()
    def hook(uc, access, address, size, value, user):
        if lo <= address < hi:
            written.add((address - base) & ~3)
    h = e.uc.hook_add(UC_HOOK_MEM_WRITE, hook)
    for (d, n, s, t, rm) in leaves:
        for val in (0, rm):
            written.clear()
            for u in range(9):
                try: e.dispatch(u, d, val)
                except RuntimeError: pass
            cellmap[d]['cells'] |= set(written)
        # record how many this ctx contributed (last val's set is representative)
        cellmap[d]['ctxhits'][ctx] = len([c for c in cellmap[d]['cells']])
    e.uc.hook_del(h)
    sys.stderr.write("ctx %s done\n" % ctx); sys.stderr.flush()

for d in cellmap:
    cellmap[d]['cells'] = sorted(cellmap[d]['cells'])
pickle.dump(cellmap, open(OUT, 'wb'))
nz = sum(1 for d in cellmap if cellmap[d]['cells'])
print("leaves swept: %d   write-audio-cells: %d   silent: %d" %
      (len(cellmap), nz, len(cellmap) - nz))
print("wrote", OUT)

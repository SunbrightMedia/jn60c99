"""Oracle-only probe (CLAIMS B1): during a recall (no render, so no ramp steps),
does ANY code other than the ramp machinery write the 73 recall-ramped cells?
A memory-write hook on every such cell of unit 0 logs the writing instruction;
the warm_chain_gate pool family (96 recalls) at 44100.
    python3 probes/warm/ramp_cells_writers.py     (Unicorn only)"""
import os, sys, pickle, gc
from collections import Counter
REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import e2e_emu as E
import real_recall as R
import recall_render_ab as RR
import warm_chain_gate as W
from unicorn import UC_HOOK_MEM_WRITE
from unicorn.x86_const import UC_X86_REG_RIP

d = pickle.load(open(os.path.join(REPO, 'scratchpad', 'ramp_census_dyn.pkl'), 'rb'))
CELLS = sorted(set(x[5] for x in d['log'] if x[2] == 'R' and x[10] == 1))
bank = E.bank_bytes()
lt = R.leaf_table()
writers = Counter()
on = {'v': False}
for ci, (fam, rate, steps) in enumerate(W.chains(bank)):
    if fam != 'pool':
        continue
    e = E.E2E()
    e.build(44100.0)
    e.snap_all()
    st = e.state[0]

    def hook(uc_, access, addr, size, value, ud, st=st):
        if on['v']:
            writers[(uc_.reg_read(UC_X86_REG_RIP) - E.IB, addr - st)] += 1
    for c in CELLS:
        e.uc.hook_add(UC_HOOK_MEM_WRITE, hook, begin=st + c, end=st + c + 3)
    for si, (name, rb) in enumerate(steps):
        on['v'] = True
        blob = E.patch_blob(rb, 0)
        late = RR.late_leaves(blob, R)
        for (dd, bb) in lt: R.wr_desc(e, dd, R.dec(blob, bb))
        for (dd, v) in late: R.wr_desc(e, dd, v)
        for u in range(9):
            for (dd, _) in lt:
                try: e.dispatch(u, dd, R.rd_desc(e, dd))
                except RuntimeError: pass
            for (dd, _) in late:
                try: e.dispatch(u, dd, R.rd_desc(e, dd))
                except RuntimeError: pass
        e.assigner_notify()
        on['v'] = False
        e.snap_all()          # the harness settle, outside the window
    del e
    gc.collect()
print('cells watched: %d' % len(CELLS))
print('writes during the recall dispatch (rip, cell): %d distinct' % len(writers))
for (rip, cell), n in sorted(writers.items()):
    print('  rip %06X cell %-9d x%d' % (rip, cell, n))

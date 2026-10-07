"""Oracle-only probe (CLAIMS B1): which code WRITES the ramp records a warm
recall arms. Watches unit 0's records for the given cells (memory-write hook)
during the dispatch of a warm recall and prints each writing instruction (rva),
the field written (+offset in the 40-byte record) and the value.
    python3 probes/warm/ramp_writers.py [from to rate]   (Unicorn only)"""
import os, sys, struct
from collections import defaultdict
REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import e2e_emu as E
import real_recall as R
import recall_render_ab as RR
from unicorn import UC_HOOK_MEM_WRITE
from unicorn.x86_const import UC_X86_REG_RIP, UC_X86_REG_RSP

a = sys.argv[1:]
P_FROM, P_TO = (int(a[0]), int(a[1])) if len(a) >= 2 else (0, 7)
SR = float(a[2]) if len(a) >= 3 else 44100.0
CELLS = (102544, 102592, 4297776, 4297840, 96384, 96416, 10759408, 10759648, 2848, 101744)
bank = E.bank_bytes()
lt = R.leaf_table()


def dispatch_only(e, idx):
    blob = E.patch_blob(bank, idx)
    late = RR.late_leaves(blob, R)
    for (d, bb) in lt: R.wr_desc(e, d, R.dec(blob, bb))
    for (d, v) in late: R.wr_desc(e, d, v)
    for u in range(9):
        for (d, _) in lt:
            try: e.dispatch(u, d, R.rd_desc(e, d))
            except RuntimeError: pass
        for (d, _) in late:
            try: e.dispatch(u, d, R.rd_desc(e, d))
            except RuntimeError: pass
    e.assigner_notify()


e = RR.prepare_recall(P_FROM, bank, lt, E, R, SR)
e.note_on(60, 100); e.render(1024); e.note_off(60); e.render(512)
uc = e.uc
st = e.state[0]
base = int.from_bytes(uc.mem_read(st + 88, 8), 'little')
nrec = 4096
recs = {}
for ix in range(nrec):
    outp = int.from_bytes(uc.mem_read(base + 40 * ix, 8), 'little')
    if outp and (outp - st) in CELLS:
        recs[ix] = outp - st
print('records of the watched cells in unit 0:', {c: ix for ix, c in recs.items()})
writes = defaultdict(list)
cellw = defaultdict(list)


def hook(uc_, access, addr, size, value, ud):
    rip = uc_.reg_read(UC_X86_REG_RIP) - E.IB
    ix, off = divmod(addr - base, 40)
    if ix in recs:
        writes[(recs[ix], rip)].append((off, value & 0xFFFFFFFF))
    elif addr - st in recs.values():
        cellw[(addr - st, rip)].append(value & 0xFFFFFFFF)


lo = base + 40 * min(recs)
hi = base + 40 * (max(recs) + 1)
uc.hook_add(UC_HOOK_MEM_WRITE, hook, begin=lo, end=hi)
for c in recs.values():
    uc.hook_add(UC_HOOK_MEM_WRITE, hook, begin=st + c, end=st + c + 3)
dispatch_only(e, P_TO)
print('== record writes during p%d -> p%d dispatch @%g' % (P_FROM, P_TO, SR))
for (cell, rip), ws in sorted(writes.items()):
    fields = sorted(set(o for o, _ in ws))
    print('  cell %-9d rip %06X  %3d writes  fields %s  last %s'
          % (cell, rip, len(ws), fields, ['+%d=%08x' % (o, v) for o, v in ws[-4:]]))
print('== direct cell writes')
for (cell, rip), ws in sorted(cellw.items()):
    print('  cell %-9d rip %06X  %3d writes  last %08x' % (cell, rip, len(ws), ws[-1]))

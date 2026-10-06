"""Oracle-only dynamic census (CLAIMS B1): every RAMPED set (wrapper rva
0x3C2920, reached from rva 0x3C10D0) and every IMMEDIATE set (rva 0x3C2750,
from rva 0x3C10F0) that unit 0 receives during the 234 recalls of
warm_chain_gate.py's chains (same records, same order, 44100 only), with the
calling site, descriptor, cell, value, time index, the record's stored target
before the call, and whether the arm took effect. Hooks are installed BEFORE
the engine is built (a hook added later never fired on the cached start).
Writes scratchpad/ramp_census_dyn.pkl; prints a per-cell summary.
    python3 probes/warm/ramp_census_dyn.py      (Unicorn only)"""
import os, sys, struct, pickle, gc
from collections import defaultdict, Counter
REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import e2e_emu as E
import real_recall as R
import recall_render_ab as RR
import warm_chain_gate as W
from unicorn import UC_HOOK_CODE
from unicorn.x86_const import (UC_X86_REG_RCX, UC_X86_REG_RDX, UC_X86_REG_R8, UC_X86_REG_RSP,
                               UC_X86_REG_XMM2, UC_X86_REG_XMM3)

WRAP, IMM = 0x3C2920, 0x3C2750
OUT = os.path.join(REPO, 'scratchpad', 'ramp_census_dyn.pkl')
SR = 44100.0


def f32(x):
    return struct.unpack('<f', struct.pack('<I', x & 0xFFFFFFFF))[0]


bank = E.bank_bytes()
lt = R.leaf_table()
chains = W.chains(bank)
log = []          # (chain, step, kind, site, desc, cell, value, tidx, stored_target, effective, type, leaf)
cur = {'tag': None, 'leaf': None}


def make_engine():
    e = E.E2E()
    uc = e.uc

    def hook(uc_, addr, size, ud):
        if cur['tag'] is None:
            return
        rcx = uc_.reg_read(UC_X86_REG_RCX)
        if rcx != e.state[0]:
            return
        rva = addr - E.IB
        rsp = uc_.reg_read(UC_X86_REG_RSP)
        site = int.from_bytes(uc_.mem_read(rsp, 8), 'little') - E.IB
        desc_i = uc_.reg_read(UC_X86_REG_RDX) & 0xFFFFFFFF
        desc = int.from_bytes(uc_.mem_read(rcx + 0x38, 8), 'little') + 40 * desc_i
        cellp = int.from_bytes(uc_.mem_read(desc + 0x20, 8), 'little')
        cell = cellp - rcx
        if rva == WRAP:
            typ = int.from_bytes(uc_.mem_read(desc + 0xC, 4), 'little')
            val = f32(uc_.reg_read(UC_X86_REG_XMM3))
            tidx = uc_.reg_read(UC_X86_REG_R8) & 0xFFFFFFFF
            if typ == 1:
                rix = int.from_bytes(uc_.mem_read(desc + 0x14, 4), 'little')
                rec = int.from_bytes(uc_.mem_read(rcx + 0x58, 8), 'little') + 40 * rix
                st = f32(int.from_bytes(uc_.mem_read(rec + 20, 4), 'little'))
                eff = (val < st or val > st)
            else:
                st, eff = None, None
            log.append(cur['tag'] + ('R', site, desc_i, cell, val, tidx, st, eff, typ, cur['leaf']))
        else:
            val = f32(uc_.reg_read(UC_X86_REG_XMM2))
            log.append(cur['tag'] + ('I', site, desc_i, cell, val, None, None, None, None, cur['leaf']))

    disp0 = e.dispatch

    def dispatch_tagged(u, d_, v):          # which recall leaf is being dispatched
        cur['leaf'] = (u, d_)
        try:
            return disp0(u, d_, v)
        finally:
            cur['leaf'] = None
    e.dispatch = dispatch_tagged
    uc.hook_add(UC_HOOK_CODE, hook, begin=E.IB + WRAP, end=E.IB + WRAP)
    uc.hook_add(UC_HOOK_CODE, hook, begin=E.IB + IMM, end=E.IB + IMM)
    e.build(SR)
    e.snap_all()
    return e


for ci, (fam, rate, steps) in enumerate(chains):
    e = make_engine()
    for si, (name, rb) in enumerate(steps):
        cur['tag'] = (ci, si)
        RR.apply_recall(e, 0, rb, lt, E, R)
        cur['tag'] = None
    del e
    gc.collect()
    sys.stderr.write('chain %d %s done (%d sets so far)\n' % (ci, fam, len(log)))
    sys.stderr.flush()
pickle.dump({'log': log, 'names': [[n for n, _ in s] for _, _, s in chains]}, open(OUT, 'wb'))

# per-cell summary of the RAMPED sets on type-1 descriptors
per = defaultdict(lambda: {'sites': Counter(), 'tidx': Counter(), 'imm_sites': Counter(), 'patterns': Counter()})
by_step = defaultdict(lambda: defaultdict(list))
for (ci, si, kind, site, di, cell, val, tidx, st, eff, typ, leaf) in log:
    if kind == 'R' and typ == 1:
        per[cell]['sites'][site] += 1
        per[cell]['tidx'][tidx] += 1
        by_step[(ci, si)][cell].append(val)
    elif kind == 'I':
        per[cell]['imm_sites'][site] += 1
for step, cells in by_step.items():
    for cell, vals in cells.items():
        per[cell]['patterns'][len(set(vals))] += 1
print('recalls %d, sets logged %d (ramped %d, immediate %d)'
      % (sum(len(s) for _, _, s in chains), len(log),
         sum(1 for x in log if x[2] == 'R'), sum(1 for x in log if x[2] == 'I')))
print('cells set through the RAMPED path on a type-1 descriptor: %d'
      % sum(1 for c, p in per.items() if p['sites']))
for cell, p in sorted(per.items()):
    if not p['sites']:
        continue
    print('  cell %-9d ramped sites %s  tidx %s  distinct-targets-per-recall %s  immediate sites %s'
          % (cell, ' '.join('%06X' % s for s in sorted(p['sites'])), dict(p['tidx']),
             dict(sorted(p['patterns'].items())), ' '.join('%06X' % s for s in sorted(p['imm_sites']))))
imm_only = sorted(c for c, p in per.items() if not p['sites'] and p['imm_sites'])
print('cells set ONLY through the immediate path: %d %s' % (len(imm_only), imm_only[:40]))

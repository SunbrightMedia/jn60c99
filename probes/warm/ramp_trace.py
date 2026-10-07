"""Oracle-only probe (CLAIMS B1): WHO arms the recall ramps, and WHERE they are
stepped. A memory-write hook over every unit's ramp records catches each arm at
the ramp start's first store (rva 0x3C2EAD, `movss [rcx+0x14], xmm3`), where
[rsp] is still the return address (the function has no frame): caller, unit,
record, target cell, current value, old target, new target (xmm3), time ms
(xmm5), subdiv (r9d). A code hook on the ramp step (rva 0x3C2E00) then counts
its callers per rendered sample. (A code hook on the start's entry 0x3C2E80
never fired: its translation block was cached before the hook was added.)
    python3 probes/warm/ramp_trace.py [from to rate]   (Unicorn only)"""
import os, sys, struct
from collections import defaultdict, Counter
REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import e2e_emu as E
import real_recall as R
import recall_render_ab as RR
from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_WRITE
from unicorn.x86_const import (UC_X86_REG_RCX, UC_X86_REG_RSP, UC_X86_REG_R9,
                               UC_X86_REG_RIP, UC_X86_REG_XMM3, UC_X86_REG_XMM5)

RAMP_STEP, ARM_STORE = 0x3C2E00, 0x3C2EAD
a = [x for x in sys.argv[1:] if x not in ('-v', '--flag0')]
FLAG = 0 if '--flag0' in sys.argv else 1
P_FROM, P_TO = (int(a[0]), int(a[1])) if len(a) >= 2 else (0, 7)
SR = float(a[2]) if len(a) >= 3 else 44100.0
NREC = 1024
VERBOSE = '-v' in sys.argv
bank = E.bank_bytes()
lt = R.leaf_table()


def f32(x):
    return struct.unpack('<f', struct.pack('<I', x & 0xFFFFFFFF))[0]


def dispatch_only(e, idx):
    blob = E.patch_blob(bank, idx)
    late = RR.late_leaves(blob, R)
    for (d, bb) in lt: R.wr_desc(e, d, R.dec(blob, bb))
    for (d, v) in late: R.wr_desc(e, d, v)
    for u in range(9):
        for (d, _) in lt:
            try: e.dispatch(u, d, R.rd_desc(e, d), FLAG)
            except RuntimeError: pass
        for (d, _) in late:
            try: e.dispatch(u, d, R.rd_desc(e, d), FLAG)
            except RuntimeError: pass
    e.assigner_notify()


e = RR.prepare_recall(P_FROM, bank, lt, E, R, SR)
e.note_on(60, 100); e.render(1024); e.note_off(60); e.render(512)
uc = e.uc
bases = [int.from_bytes(uc.mem_read(e.state[u] + 88, 8), 'little') for u in range(9)]
arms = []
steps = Counter()
mode = {'on': 'arm'}


def on_write(uc_, access, addr, size, value, ud):
    if mode['on'] != 'arm':
        return
    if uc_.reg_read(UC_X86_REG_RIP) - E.IB != ARM_STORE:
        return
    rcx = uc_.reg_read(UC_X86_REG_RCX)
    for u in range(9):
        ix, r = divmod(rcx - bases[u], 40)
        if r == 0 and 0 <= ix < NREC:
            break
    else:
        u = ix = None
    rsp = uc_.reg_read(UC_X86_REG_RSP)
    ret = int.from_bytes(uc_.mem_read(rsp, 8), 'little') - E.IB
    if ret == 0x3C2971:      # inside the wrapper rva 0x3C2920 (push rdi; sub rsp,0x20)
        ret = (ret, int.from_bytes(uc_.mem_read(rsp + 0x30, 8), 'little') - E.IB)
    outp = int.from_bytes(uc_.mem_read(rcx, 8), 'little')
    cell = outp - e.state[u] if (u is not None and outp) else None
    cur = f32(int.from_bytes(uc_.mem_read(outp, 4), 'little')) if outp else float('nan')
    old_t = f32(int.from_bytes(uc_.mem_read(rcx + 20, 4), 'little'))
    arms.append((ret, u, ix, cell, cur, old_t, f32(uc_.reg_read(UC_X86_REG_XMM3)),
                 f32(uc_.reg_read(UC_X86_REG_XMM5)), uc_.reg_read(UC_X86_REG_R9) & 0xFFFFFFFF))


def on_step(uc_, addr, size, ud):
    if mode['on'] == 'step':
        rsp = uc_.reg_read(UC_X86_REG_RSP)
        r0 = int.from_bytes(uc_.mem_read(rsp, 8), 'little') - E.IB
        r1 = int.from_bytes(uc_.mem_read(rsp + 0x30, 8), 'little') - E.IB   # the pump's caller
        steps[(r0, r1)] += 1


for u in range(9):
    uc.hook_add(UC_HOOK_MEM_WRITE, on_write, begin=bases[u], end=bases[u] + 40 * NREC)
uc.hook_add(UC_HOOK_CODE, on_step, begin=E.IB + RAMP_STEP, end=E.IB + RAMP_STEP)
dispatch_only(e, P_TO)
print('== p%d -> p%d @%g, dispatch flag %d: %d arms (units 0..8)' % (P_FROM, P_TO, SR, FLAG, len(arms)))
by_site = defaultdict(list)
for x in arms:
    by_site[x[0]].append(x)
for ret, xs in sorted(by_site.items(), key=lambda kv: str(kv[0])):
    print('  caller %s: %d arms, units %s, cells %s'
          % (ret if isinstance(ret, int) else '%06X <- %06X' % ret, len(xs),
             sorted(set(x[1] for x in xs)), sorted(set(x[3] for x in xs if x[1] == 0))))
    if VERBOSE:
      for (_, u, ix, cell, cur, old_t, tgt, tms, sub) in [x for x in xs if x[1] == 0]:
        print('     u0 rec %4s cell %-10s cur %-13.7g old target %-13.7g -> %-13.7g %g ms /%d%s'
              % (ix, cell, cur, old_t, tgt, tms, sub,
                 '' if (old_t < tgt or old_t > tgt) else '  (same target: early-out)'))
mode['on'] = 'step'
N = 40
e.render(N, block=N)
print('== ramp step callers over %d samples:' % N)
for (r0, r1), n in sorted(steps.items()):
    print('  step ret %06X, pump called from %06X: %d calls (%.2f per sample)' % (r0, r1, n, n / N))

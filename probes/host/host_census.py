"""Oracle-only census (CLAIMS B7): what the plugin's HOST entry (rva 0x3C7AE0,
the path a DAW's parameter change takes: dispatch flag 0 on all 9 units +
assigner refresh) does for each of the port's 79 host parameters, on a
RUNNING engine after a settled recall (P112 trap 4). For unit 0: every ramped
set (cell, value, time index, effective?), every immediate set, and every
other direct write to the object. Writes scratchpad/host_census.pkl.
    python3 probes/host/host_census.py [base_patch rate]     (Unicorn only)"""
import os, sys, struct, pickle, re
from collections import defaultdict
REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import e2e_emu as E
import real_recall as R
import recall_render_ab as RR
import seed_recall_gate as S
from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_WRITE
from unicorn.x86_const import (UC_X86_REG_RCX, UC_X86_REG_RDX, UC_X86_REG_R8, UC_X86_REG_RSP,
                               UC_X86_REG_RIP, UC_X86_REG_XMM2, UC_X86_REG_XMM3)

APPLY, POPULATE, MAP_G = E.IB + 0x3C7AE0, E.IB + 0xAD5A0, E.IB + 0xCB0E18
WRAP, IMM = 0x3C2920, 0x3C2750
DB_LO = 0x98c040 + 0      # paramDB {lo, hi} at +0 (hostpath_roles.DB_LO convention checked below)
a = sys.argv[1:]
BASE = int(a[0]) if a else 0
SR = float(a[1]) if len(a) > 1 else 44100.0
OUT = os.path.join(REPO, 'scratchpad', 'host_census_p%d_%d.pkl' % (BASE, int(SR)))

f32 = lambda x: struct.unpack('<f', struct.pack('<I', x & 0xFFFFFFFF))[0]
src = open(os.path.join(REPO, 'src', 'juno_hostparams.c')).read()
HOST = [(m.group(1).strip(), int(m.group(2)), int(m.group(3)), int(m.group(4)), int(m.group(5)))
        for m in re.finditer(r'\{"([^"]+)"\s*,"[^"]*"\s*,\s*(\d+),\s*(\d+),\s*(-?\d+),\s*(\d+),', src)]
roff_to_d = {off: d for d, off, kind in S.leaf_slots()}

e = E.E2E()
log = []
cur = {'p': None}


def hook(uc_, addr, size, ud):
    if cur['p'] is None or uc_.reg_read(UC_X86_REG_RCX) != e.state[0]:
        return
    rva = addr - E.IB
    site = int.from_bytes(uc_.mem_read(uc_.reg_read(UC_X86_REG_RSP), 8), 'little') - E.IB
    di = uc_.reg_read(UC_X86_REG_RDX) & 0xFFFFFFFF
    desc = int.from_bytes(uc_.mem_read(e.state[0] + 0x38, 8), 'little') + 40 * di
    cell = int.from_bytes(uc_.mem_read(desc + 0x20, 8), 'little') - e.state[0]
    if rva == WRAP:
        typ = int.from_bytes(uc_.mem_read(desc + 0xC, 4), 'little')
        val = f32(uc_.reg_read(UC_X86_REG_XMM3)); t = uc_.reg_read(UC_X86_REG_R8) & 0xFFFFFFFF
        st = None
        if typ == 1:
            rix = int.from_bytes(uc_.mem_read(desc + 0x14, 4), 'little')
            rec = int.from_bytes(uc_.mem_read(e.state[0] + 0x58, 8), 'little') + 40 * rix
            st = f32(int.from_bytes(uc_.mem_read(rec + 20, 4), 'little'))
        log.append((cur['p'], 'R', site, cell, val, t, typ, st))
    else:
        log.append((cur['p'], 'I', site, cell, f32(uc_.reg_read(UC_X86_REG_XMM2)), None, None, None))


def whook(uc_, access, addr, size, value, ud):
    if cur['p'] is None:
        return
    rip = uc_.reg_read(UC_X86_REG_RIP) - E.IB
    if rip in (0x3C2763,):          # the immediate set's own store (logged above)
        return
    log.append((cur['p'], 'W', rip, addr - e.state[0], value & 0xFFFFFFFF, size, None, None))


e.uc.hook_add(UC_HOOK_CODE, hook, begin=E.IB + WRAP, end=E.IB + WRAP)
e.uc.hook_add(UC_HOOK_CODE, hook, begin=E.IB + IMM, end=E.IB + IMM)
e.build(SR); e.snap_all()
e.call(POPULATE, count=200_000_000)
uc = e.uc
q = lambda x: int.from_bytes(uc.mem_read(x, 8), 'little')
head = q(MAP_G); root = q(head + 8); pid_of = {}
def walk(n, seen=set()):
    if not n or n in seen or uc.mem_read(n + 25, 1)[0]: return
    seen.add(n); walk(q(n))
    pid, idx = struct.unpack('<II', uc.mem_read(n + 28, 8)); pid_of[idx] = pid
    walk(q(n + 16))
walk(root)
bank = E.bank_bytes(); lt = R.leaf_table()
RR.apply_recall(e, BASE, bank, lt, E, R)
e.uc.hook_add(UC_HOOK_MEM_WRITE, whook, begin=e.state[0] + 176, end=e.state[0] + E.STATE_SZ - 1)
e.note_on(60, 100); e.render(256)
rec = E.patch_blob(bank, BASE)
info = {}
for i, (name, roff, typ, lo, hi) in enumerate(HOST):
    d = roff_to_d.get(roff)
    pid = pid_of.get(d) if d is not None else None
    dlo, dhi = struct.unpack('<ii', uc.mem_read(E.IB + 0x98c040 + 16 * d, 8)) if d is not None else (None, None)
    curv = R.rd_desc(e, d) if d is not None else None
    if pid is None:
        info[i] = (name, d, None, (dlo, dhi), curv, None); continue
    span = (dhi - dlo) if (dhi is not None and dhi > dlo) else 1
    v = dlo + ((curv - dlo + max(1, span // 3)) % (span + 1)) if curv is not None else dlo
    cur['p'] = i
    try:
        e.call(APPLY, rcx=e.HOST, rdx=pid, r8=v & 0xFFFFFFFF, count=30_000_000)
        ok = True
    except Exception as ex:
        ok = repr(ex)[:80]
    cur['p'] = None
    info[i] = (name, d, pid, (dlo, dhi), curv, v, ok, R.rd_desc(e, d))
    e.render(64)
pickle.dump({'host': HOST, 'info': info, 'log': log, 'base': BASE, 'sr': SR}, open(OUT, 'wb'))
by = defaultdict(lambda: {'R': [], 'I': [], 'W': []})
for (p, k, site, cell, val, t, typ, st) in log:
    by[p][k].append((cell, val, t, typ, st))
for i, row in info.items():
    name = row[0]
    rs = by[i]['R']; ims = by[i]['I']; ws = by[i]['W']
    rcells = sorted(set(c for c, v, t, ty, st in rs if ty == 1)); times = sorted(set(t for c, v, t, ty, st in rs if ty == 1))
    print('%-20s d=%-5s pid=%-10s db=%-12s cur->new %s->%s ramped %d cells t%s | immediate %d | other writes %d %s'
          % (name, row[1], row[2], row[3], row[4], row[5] if len(row) > 5 else None, len(rcells), times, len(set(c for c, *_ in ims)),
             len(set(c for c, *_ in ws)), sorted(set(c for c, *_ in ws))[:6]))

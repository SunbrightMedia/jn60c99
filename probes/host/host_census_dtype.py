"""Oracle-only census DT (CLAIMS A20): the DELAY TYPE switch through the host
entry under BOTH states of the DELAY LEVEL on-flag.

The DELAY TYPE setter (rva 0x3B93E0) re-sends DELAY LEVEL (rva 0x3B8E50),
which recomputes the on-flag (processor +6776, hysteresis) and, for delay types
0/1/4/5, sets the feedback cell to (flag ? FEEDBACK : 0) before the FEEDBACK
re-send (rva 0x3B8D00) sets it to FEEDBACK (READ). With the flag off, the first
set differs from the recall's value, and the record's stored target decides
whether the second one arms. The v2/v3 censuses ran DELAY TYPE on records whose
DELAY LEVEL was on (patch 0: 20), so their programs carry the "on" list only
(host_edit_gate each chain 7: patch 38, DELAY LEVEL 0, 5 -> 0, paid 2026-10-06).

Per job (base record, ET, FROM -> TO, DELAY LEVEL context): settled recall of
the base at DELAY LEVEL `pre` (prepares the flag), then at `dl` -> HOST APPLY
DELAY TYPE = TO (flag 0), logging every ramped set (cell, time index, value),
immediate set and direct write on unit 0, the flag before and after -> snap ->
settled recall of the base with DELAY TYPE = TO -> the touched cells ("rec").
Contexts (pre, dl): (0,0) off, (0,1) off by hysteresis, (2,1) on by hysteresis,
(2,2) on, (0,255) on; every ET 0..5 x FROM 0..5 x TO 0..5, bases varied.
Writes scratchpad/host_census_dtype.pkl.
    python3 probes/host/host_census_dtype.py      (Unicorn only)"""
import os, sys, struct, pickle, re
REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import e2e_emu as E
import real_recall as R
import recall_render_ab as RR
from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_WRITE
from unicorn.x86_const import (UC_X86_REG_RCX, UC_X86_REG_RDX, UC_X86_REG_R8,
                               UC_X86_REG_RIP, UC_X86_REG_XMM2, UC_X86_REG_XMM3)

APPLY, POPULATE, MAP_G = E.IB + 0x3C7AE0, E.IB + 0xAD5A0, E.IB + 0xCB0E18
WRAP, IMM = 0x3C2920, 0x3C2750
SR = 44100.0
OUT = os.path.join(REPO, 'scratchpad', 'host_census_dtype.pkl')
HEADER, STRIDE = 23, 20223
R_ET, R_DT, R_DL = 634, 650, 120
D_ET, D_DT = 873, 875
src = open(os.path.join(REPO, 'src', 'juno_hostparams.c')).read()
HOST = [(m.group(1).strip(), int(m.group(2)), int(m.group(3)))
        for m in re.finditer(r'\{"([^"]+)"\s*,"[^"]*"\s*,\s*(\d+),\s*(\d+),', src)]
bank = E.bank_bytes(); lt = R.leaf_table()


def rec_with(base, sets):
    rec = bytearray(bank[HEADER + base * STRIDE: HEADER + (base + 1) * STRIDE])
    for off, v in sets:
        rec[off] = (v >> 4) & 0xF; rec[off + 1] = v & 0xF
    return rec


def mk(rec):
    return bytes(bank[:HEADER]) + bytes(rec)


e = E.E2E()
cur = {'k': None}
ev = []


def hook(uc_, addr, size, ud):
    if cur['k'] is None or uc_.reg_read(UC_X86_REG_RCX) != e.state[0]:
        return
    rva = addr - E.IB
    di = uc_.reg_read(UC_X86_REG_RDX) & 0xFFFFFFFF
    desc = int.from_bytes(uc_.mem_read(e.state[0] + 0x38, 8), 'little') + 40 * di
    cell = int.from_bytes(uc_.mem_read(desc + 0x20, 8), 'little') - e.state[0]
    if rva == WRAP:
        typ = int.from_bytes(uc_.mem_read(desc + 0xC, 4), 'little')
        ev.append(('R' if typ == 1 else 'N', cell, uc_.reg_read(UC_X86_REG_R8) & 0xFFFFFFFF,
                   uc_.reg_read(UC_X86_REG_XMM3) & 0xFFFFFFFF))
    else:
        ev.append(('I', cell, None, uc_.reg_read(UC_X86_REG_XMM2) & 0xFFFFFFFF))


def whook(uc_, access, addr, size, value, ud):
    if cur['k'] is None or uc_.reg_read(UC_X86_REG_RIP) - E.IB == 0x3C2763:
        return
    ev.append(('W', addr - e.state[0], size, value))


e.uc.hook_add(UC_HOOK_CODE, hook, begin=E.IB + WRAP, end=E.IB + WRAP)
e.uc.hook_add(UC_HOOK_CODE, hook, begin=E.IB + IMM, end=E.IB + IMM)
e.build(SR); e.snap_all()
e.call(POPULATE, count=200_000_000)
uc = e.uc
q = lambda x: int.from_bytes(uc.mem_read(x, 8), 'little')
pid_of = {}


def walk(n, seen=set()):
    if not n or n in seen or uc.mem_read(n + 25, 1)[0]: return
    seen.add(n); walk(q(n))
    pid, idx = struct.unpack('<II', uc.mem_read(n + 28, 8)); pid_of[idx] = pid
    walk(q(n + 16))


walk(q(q(MAP_G) + 8))
e.uc.hook_add(UC_HOOK_MEM_WRITE, whook, begin=e.state[0] + 176, end=e.state[0] + E.STATE_SZ - 1)
flag = lambda: e.uc.mem_read(e.proc[0] + 6776, 1)[0]

i = [k for k, h in enumerate(HOST) if h[0] == 'DELAY TYPE'][0]
assert HOST[i][1] == R_DT
pid = pid_of[D_DT]
lo, hi = struct.unpack('<ii', uc.mem_read(E.IB + 0x98c040 + 16 * D_DT, 8))
plist = [(i, 'DELAY TYPE', D_DT, pid, lo, hi, R_DT, 'n')]
CTX = ((0, 0), (0, 1), (2, 1), (2, 2), (0, 255))
jobs = []
for et in range(6):
    for frm in range(6):
        for to in range(6):
            for c, (pre, dl) in enumerate(CTX):
                jobs.append(((et * 11 + frm * 5 + to * 3 + c * 13) % 64, et, frm, to, pre, dl))
res = {}
sys.stderr.write('DELAY TYPE: %d jobs\n' % len(jobs))
for j, (base, et, frm, to, pre, dl) in enumerate(jobs):
    RR.apply_recall(e, 0, mk(rec_with(base, ((R_ET, et), (R_DT, frm), (R_DL, pre)))), lt, E, R)
    rec = rec_with(base, ((R_ET, et), (R_DT, frm), (R_DL, dl)))
    RR.apply_recall(e, 0, mk(rec), lt, E, R)
    ctx = (R.rd_desc(e, D_ET), R.rd_desc(e, D_DT))
    f0 = flag()
    del ev[:]
    cur['k'] = j
    try:
        e.call(APPLY, rcx=e.HOST, rdx=pid, r8=to, count=60_000_000)
        ok = True
    except Exception as ex:
        ok = repr(ex)[:80]
    cur['k'] = None
    f1 = flag()
    cells = sorted(set(c for _, c, _, _ in ev))
    e.snap_all()
    fin = {c: int.from_bytes(uc.mem_read(e.state[0] + c, 4), 'little') for c in cells}
    RR.apply_recall(e, 0, mk(rec_with(base, ((R_ET, et), (R_DT, to), (R_DL, dl)))), lt, E, R)
    rcv = {c: int.from_bytes(uc.mem_read(e.state[0] + c, 4), 'little') for c in cells}
    res[j] = dict(fam='DT', i=i, frm=frm, to=to, ctx=ctx, ok=ok, ev=list(ev), fin=fin, rec=rcv,
                  base=bytes(rec), f0=f0, f1=f1, pre=pre, dl=dl)
    if j % 100 == 99:
        sys.stderr.write('job %d/%d\n' % (j + 1, len(jobs))); sys.stderr.flush()
pickle.dump({'host': HOST, 'plist': plist, 'res': res, 'njobs': len(jobs)}, open(OUT, 'wb'))
print('wrote', OUT, len(res), 'jobs; flag after: on %d, off %d'
      % (sum(1 for r in res.values() if r['f1']), sum(1 for r in res.values() if not r['f1'])))

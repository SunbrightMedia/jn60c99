"""Oracle-only census (CLAIMS B7): the HOST entry's set list for DELAY LEVEL and
REVERB LEVEL with the processor state their setters keep: the DELAY LEVEL
on-flag (processor +6776, rva 0x3B8E50, hysteresis) before and after, under
every DELAY TYPE and both flag states, and REVERB LEVEL across its on/off
threshold. Each job: settled recall of the base record (level forced to
`frm`, the flag prepared by a recall at level `pre` first), then HOST APPLY.
Writes scratchpad/host_census_flags.pkl.
    python3 probes/host/host_census_flags.py      (Unicorn only)"""
import os, sys, struct, pickle, re
REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import e2e_emu as E
import real_recall as R
import recall_render_ab as RR
import seed_recall_gate as S
import host_edit_gate as HG
from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_WRITE
from unicorn.x86_const import (UC_X86_REG_RCX, UC_X86_REG_RDX, UC_X86_REG_R8,
                               UC_X86_REG_RIP, UC_X86_REG_XMM2, UC_X86_REG_XMM3)

APPLY, POPULATE = E.IB + 0x3C7AE0, E.IB + 0xAD5A0
WRAP, IMM = 0x3C2920, 0x3C2750
OUT = os.path.join(REPO, 'scratchpad', 'host_census_flags.pkl')
HEADER, STRIDE = 23, 20223
bank = E.bank_bytes(); lt = R.leaf_table()
e = RR.build_engine(E, 44100.0)
e.call(POPULATE, count=200_000_000)
params = HG.oracle_params(e, E, S)
name_to = {v[0]: k for k, v in params.items()}
slots = {d: (off, kind) for d, off, kind in S.leaf_slots()}
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
e.uc.hook_add(UC_HOOK_MEM_WRITE, whook, begin=e.state[0] + 176, end=e.state[0] + E.STATE_SZ - 1)


def flag():
    return e.uc.mem_read(e.proc[0] + 6776, 1)[0]


def rec_with(base, sets):
    rec = bytearray(bank[HEADER + base * STRIDE: HEADER + (base + 1) * STRIDE])
    for off, kind, v in sets:
        if kind == 'r':
            rec[off] = v & 0x7F
        else:
            rec[off] = (v >> 4) & 0xF; rec[off + 1] = v & 0xF
    return bytes(bank[:HEADER]) + bytes(rec)


res = []
for nm in ('DELAY LEVEL', 'REVERB LEVEL'):
    k = name_to[nm]
    _, d, pid, lo, hi = params[k]
    off, kind = slots[d]
    for dt in range(6):
        for et in (0, 2, 5):
            for pre in (0, 2):
                for frm in (0, 1, 2, 3, 255):
                    for to in (0, 1, 2, 3, 255):
                        base = (dt * 7 + et) % 64
                        sets = [(650, 'n', dt), (634, 'n', et)]
                        RR.apply_recall(e, 0, rec_with(base, sets + [(off, kind, pre)]), lt, E, R)
                        RR.apply_recall(e, 0, rec_with(base, sets + [(off, kind, frm)]), lt, E, R)
                        f0 = flag()
                        lvl0 = bytes(e.uc.mem_read(e.state[0] + 10759408, 4))
                        del ev[:]
                        cur['k'] = 1
                        e.call(APPLY, rcx=e.HOST, rdx=pid, r8=to, count=60_000_000)
                        cur['k'] = None
                        f1 = flag()
                        res.append(dict(name=nm, k=k, dt=dt, et=et, pre=pre, frm=frm, to=to,
                                        f0=f0, f1=f1, ev=list(ev)))
                        e.snap_all()
    sys.stderr.write('%s done (%d)\n' % (nm, len(res))); sys.stderr.flush()
pickle.dump(res, open(OUT, 'wb'))
print('wrote', OUT, len(res))

"""Oracle-only census (CLAIMS B7): the HOST entry's set list for every host
parameter in every EFFECT TYPE x DELAY TYPE context (36) at two values each.
Per APPLY: every ramped set (cell, time index, value), immediate set (cell,
value) and other direct write (cell) on unit 0, plus each touched cell's value
after a snap (to classify an arm's value as the settled one or a constant).
Base: factory patch BASE with the context's types forced, settled recall
before every APPLY (P112 trap 4). Writes scratchpad/host_census_ctx.pkl.
    python3 probes/host/host_census_ctx.py [BASE]     (Unicorn only, ~1 h)"""
import os, sys, struct, pickle, re, gc
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
BASE = int(sys.argv[1]) if len(sys.argv) > 1 else 0
SR = 44100.0
OUT = os.path.join(REPO, 'scratchpad', 'host_census_ctx.pkl')
HEADER, STRIDE = 23, 20223
f32 = lambda x: struct.unpack('<f', struct.pack('<I', x & 0xFFFFFFFF))[0]
src = open(os.path.join(REPO, 'src', 'juno_hostparams.c')).read()
HOST = [(m.group(1).strip(), int(m.group(2))) for m in re.finditer(r'\{"([^"]+)"\s*,"[^"]*"\s*,\s*(\d+),', src)]
roff_to_d = {off: d for d, off, kind in S.leaf_slots()}
bank = E.bank_bytes(); lt = R.leaf_table()


def ctx_bank(et, dt):
    rec = bytearray(bank[HEADER + BASE * STRIDE: HEADER + (BASE + 1) * STRIDE])
    for off, v in ((634, et), (650, dt)):
        rec[off] = (v >> 4) & 0xF; rec[off + 1] = v & 0xF
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
        if typ != 1:
            return                     # a ramped set on a non-ramp descriptor does nothing
        ev.append(('R', cell, uc_.reg_read(UC_X86_REG_R8) & 0xFFFFFFFF,
                   uc_.reg_read(UC_X86_REG_XMM3) & 0xFFFFFFFF))
    else:
        ev.append(('I', cell, None, uc_.reg_read(UC_X86_REG_XMM2) & 0xFFFFFFFF))


def whook(uc_, access, addr, size, value, ud):
    if cur['k'] is None:
        return
    if uc_.reg_read(UC_X86_REG_RIP) - E.IB == 0x3C2763:
        return
    ev.append(('W', addr - e.state[0], None, value & 0xFFFFFFFF))


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
res = {}
plist = []
for i, (name, roff) in enumerate(HOST):
    d = roff_to_d.get(roff)
    if d is None or d not in pid_of:
        continue
    lo, hi = struct.unpack('<ii', uc.mem_read(E.IB + 0x98c040 + 16 * d, 8))
    plist.append((i, name, d, pid_of[d], lo, hi))
for et in range(6):
    for dt in range(6):
        cb = ctx_bank(et, dt)
        for (i, name, d, pid, lo, hi) in plist:
            for vi in range(2):
                RR.apply_recall(e, 0, cb, lt, E, R)
                curv = R.rd_desc(e, d)
                span = max(hi - lo, 1)
                v = lo + ((curv - lo) + (vi + 1) * max(1, span // 3)) % (span + 1)
                del ev[:]
                cur['k'] = (i, et, dt, vi)
                try:
                    e.call(APPLY, rcx=e.HOST, rdx=pid, r8=v & 0xFFFFFFFF, count=30_000_000)
                    ok = True
                except Exception as ex:
                    ok = repr(ex)[:60]
                cur['k'] = None
                cells = sorted(set(c for _, c, _, _ in ev))
                e.snap_all()
                fin = {c: int.from_bytes(uc.mem_read(e.state[0] + c, 4), 'little') for c in cells}
                res[(i, et, dt, vi)] = (curv, v, ok, list(ev), fin)
        sys.stderr.write('context ET %d DT %d done (%d entries)\n' % (et, dt, len(res))); sys.stderr.flush()
    pickle.dump({'host': HOST, 'plist': plist, 'res': res, 'base': BASE}, open(OUT, 'wb'))
pickle.dump({'host': HOST, 'plist': plist, 'res': res, 'base': BASE}, open(OUT, 'wb'))
print('wrote', OUT, len(res))

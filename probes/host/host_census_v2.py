"""Oracle-only census v2 (CLAIMS B7): the HOST entry's set list for every host
parameter over a broad set of contexts, with the value each set would have
under a settled RECALL of the edited record, so every set can be classified as
"the recall's value" or a constant.

Per job (base record, host param, value):
  settled recall of the base (recall_render_ab.apply_recall) -> from value ->
  HOST APPLY (rva 0x3C7AE0, flag 0, the DAW-automation path) logging every
  ramped set (cell, time index, value), immediate set (cell, value) and other
  direct write (cell, value) on unit 0 -> snap -> the touched cells ("fin") ->
  settled recall of the base with the leaf edited -> the touched cells ("rec").
Families:
  A  every param, 6 contexts (EFFECT TYPE = DELAY TYPE = k), values lo/lo+1/lo+2/mid/hi
  B  FX params, all 36 EFFECT x DELAY TYPE contexts, values lo/mid/hi
  C  EFFECT / DELAY / REVERB TYPE: every from -> to in every other-type context
  D  REVERB LEVEL, DELAY LEVEL, EFFECT DEPTH, VCA LEVEL: from {0,1,2,3,255} to
     {0,1,2,3,255} under every DELAY TYPE
  E  24 seeded legal records (seed_recall_gate.seed_bank), every param, values
     random/lo/hi
Writes scratchpad/host_census_v2.pkl (resumable by job index).
    python3 probes/host/host_census_v2.py      (Unicorn only)"""
import os, sys, struct, pickle, re, gc, random
REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import e2e_emu as E
import real_recall as R
import recall_render_ab as RR
import seed_recall_gate as S
from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_WRITE
from unicorn.x86_const import (UC_X86_REG_RCX, UC_X86_REG_RDX, UC_X86_REG_R8,
                               UC_X86_REG_RIP, UC_X86_REG_XMM2, UC_X86_REG_XMM3)

APPLY, POPULATE, MAP_G = E.IB + 0x3C7AE0, E.IB + 0xAD5A0, E.IB + 0xCB0E18
WRAP, IMM = 0x3C2920, 0x3C2750
SR = 44100.0
OUT = os.path.join(REPO, 'scratchpad', 'host_census_v2.pkl')
HEADER, STRIDE = 23, 20223
src = open(os.path.join(REPO, 'src', 'juno_hostparams.c')).read()
HOST = [(m.group(1).strip(), int(m.group(2)), int(m.group(3)))
        for m in re.finditer(r'\{"([^"]+)"\s*,"[^"]*"\s*,\s*(\d+),\s*(\d+),', src)]
slots = S.leaf_slots()
roff_to = {off: (d, kind) for d, off, kind in slots}
bank = E.bank_bytes(); lt = R.leaf_table()


def rec_of(b):
    return bytearray(bank[HEADER + b * STRIDE: HEADER + (b + 1) * STRIDE])


def put(rec, off, kind, v):
    if kind == 'r':
        rec[off] = v & 0x7F
    else:
        rec[off] = (v >> 4) & 0xF; rec[off + 1] = v & 0xF


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
        if typ != 1:
            ev.append(('N', cell, uc_.reg_read(UC_X86_REG_R8) & 0xFFFFFFFF,
                       uc_.reg_read(UC_X86_REG_XMM3) & 0xFFFFFFFF))
            return
        ev.append(('R', cell, uc_.reg_read(UC_X86_REG_R8) & 0xFFFFFFFF,
                   uc_.reg_read(UC_X86_REG_XMM3) & 0xFFFFFFFF))
    else:
        ev.append(('I', cell, None, uc_.reg_read(UC_X86_REG_XMM2) & 0xFFFFFFFF))


def whook(uc_, access, addr, size, value, ud):
    if cur['k'] is None:
        return
    if uc_.reg_read(UC_X86_REG_RIP) - E.IB == 0x3C2763:
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

plist = []
for i, (name, roff, typ) in enumerate(HOST):
    if roff not in roff_to:
        continue
    d, kind = roff_to[roff]
    if d not in pid_of:
        continue
    lo, hi = struct.unpack('<ii', uc.mem_read(E.IB + 0x98c040 + 16 * d, 8))
    if lo < 0:
        continue
    plist.append((i, name, d, pid_of[d], lo, hi, roff, kind))
P = {p[0]: p for p in plist}
FX = [i for i in P if i >= 51]
NAME = {p[1]: p[0] for p in plist}


def base_ctx(b, sets):
    rec = rec_of(b)
    for off, v in sets:
        rec[off] = (v >> 4) & 0xF; rec[off + 1] = v & 0xF
    return rec


def vals(i, n):
    _, _, _, _, lo, hi, _, _ = P[i]
    mid = (lo + hi) // 2
    out = [lo, lo + 1, lo + 2, mid, hi] if n == 5 else [lo, mid, hi]
    return sorted(set(min(max(v, lo), hi) for v in out))


jobs = []
for k in range(6):
    rec = base_ctx(0, ((634, k), (650, k)))
    for i in P:
        for v in vals(i, 5):
            jobs.append(('A', bytes(rec), i, v))
for et in range(6):
    for dt in range(6):
        rec = base_ctx(0, ((634, et), (650, dt)))
        for i in FX:
            for v in vals(i, 3):
                jobs.append(('B', bytes(rec), i, v))
for i, off_self, off_other in ((NAME['EFFECT TYPE'], 634, 650), (NAME['DELAY TYPE'], 650, 634)):
    for frm in range(6):
        for oth in range(6):
            rec = base_ctx(0, ((off_self, frm), (off_other, oth)))
            for to in range(6):
                jobs.append(('C', bytes(rec), i, to))
for frm in range(6):
    for b in (0, 5):
        rec = base_ctx(b, ((658, frm),))
        for to in range(6):
            jobs.append(('C', bytes(rec), NAME['REVERB TYPE'], to))
for nm in ('REVERB LEVEL', 'DELAY LEVEL', 'EFFECT DEPTH', 'VCA LEVEL'):
    i = NAME[nm]
    roff, kind = P[i][6], P[i][7]
    for dt in range(6):
        for frm in (0, 1, 2, 3, 255):
            rec = base_ctx(0, ((650, dt), (634, dt)))
            put(rec, roff, kind, frm)
            for to in (0, 1, 2, 3, 255):
                jobs.append(('D', bytes(rec), i, to))
rnd = random.Random(4242)
ranges = S.declared_ranges()
for s in range(24):
    rb, _, _ = S.seed_bank(bank, 9000 + s, slots, ranges, wild=False)
    rec = bytearray(rb[HEADER:])
    for i in P:
        _, _, _, _, lo, hi, _, _ = P[i]
        for v in sorted(set((rnd.randint(lo, hi), lo, hi))):
            jobs.append(('E', bytes(rec), i, v))

state = {'host': HOST, 'plist': plist, 'res': {}}
if os.path.exists(OUT):
    old = pickle.load(open(OUT, 'rb'))
    if old.get('njobs') == len(jobs):
        state = old
state['njobs'] = len(jobs)
res = state['res']
sys.stderr.write('%d jobs, %d done\n' % (len(jobs), len(res)))
for j, (fam, rec, i, v) in enumerate(jobs):
    if j in res:
        continue
    _, name, d, pid, lo, hi, roff, kind = P[i]
    cb = mk(rec)
    RR.apply_recall(e, 0, cb, lt, E, R)
    frm = R.rd_desc(e, d)
    ctx = (R.rd_desc(e, 873), R.rd_desc(e, 875))
    del ev[:]
    cur['k'] = j
    try:
        e.call(APPLY, rcx=e.HOST, rdx=pid, r8=v & 0xFFFFFFFF, count=60_000_000)
        ok = True
    except Exception as ex:
        ok = repr(ex)[:80]
    cur['k'] = None
    cells = sorted(set(c for _, c, _, _ in ev))
    e.snap_all()
    fin = {c: int.from_bytes(uc.mem_read(e.state[0] + c, 4), 'little') for c in cells}
    ed = bytearray(rec)
    put(ed, roff, kind, v)
    RR.apply_recall(e, 0, mk(ed), lt, E, R)
    rcv = {c: int.from_bytes(uc.mem_read(e.state[0] + c, 4), 'little') for c in cells}
    res[j] = dict(fam=fam, i=i, frm=frm, to=v, ctx=ctx, ok=ok, ev=list(ev), fin=fin, rec=rcv,
                  base=rec if fam in ('E',) else None)
    if j % 500 == 499:
        pickle.dump(state, open(OUT, 'wb'))
        sys.stderr.write('job %d/%d\n' % (j + 1, len(jobs))); sys.stderr.flush()
pickle.dump(state, open(OUT, 'wb'))
print('wrote', OUT, len(res))

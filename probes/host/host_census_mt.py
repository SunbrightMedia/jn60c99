"""Oracle-only census MT (CLAIMS A20): MASTER TUNE through the host entry.

MASTER TUNE (host id 2) has no slot in a bank record the recall reads, so the
v2/v3/H censuses (which join host parameters to record slots) never ran it, and
A20 called it "not in the engine's parameter map" without a measurement. READ:
the host entry (rva 0x3C7AE0) maps id 2 to dispatch 20 and passes value - 100
(rva 0x3C7C6C) when it lies in the database range; dispatch 20 (rva 0x3B9A30)
calls, for every voice of the unit, the voice's tune setter (rva 0x35CEF0),
which looks the value + 100 up in the curve table (rva 0x356380, curve 55) and
sets the voice's tune cell through the ramped setter (rva 0x3C10D0).

Per job (base record, value): settled recall of the base -> HOST APPLY (flag 0)
logging every ramped set (cell, time index, value), immediate set and direct
write on unit 0, and every curve lookup (curve, input) -> snap. The recall does
not touch the leaf, so no recall value is recorded (rec = None): the value
source must come from the curve. Jobs run in order on ONE engine, so each job's
"from" is the previous job's value (kept across the recalls: the recall never
sets dispatch 20).
Families:
  T  6 contexts (patch 7k, EFFECT TYPE = DELAY TYPE = k), values lo/lo+1/37/
     99/100/101/150/hi-1/hi and two random
  S  every value lo..hi on patch 0
  X  values outside the database range (no setter may run)
Writes scratchpad/host_census_mt.pkl.
    python3 probes/host/host_census_mt.py      (Unicorn only)"""
import os, sys, struct, pickle, re, random
REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import e2e_emu as E
import real_recall as R
import recall_render_ab as RR
from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_WRITE
from unicorn.x86_const import (UC_X86_REG_RCX, UC_X86_REG_RDX, UC_X86_REG_R8,
                               UC_X86_REG_RIP, UC_X86_REG_XMM2, UC_X86_REG_XMM3)

APPLY, POPULATE, MAP_G = E.IB + 0x3C7AE0, E.IB + 0xAD5A0, E.IB + 0xCB0E18
WRAP, IMM, CURVE = 0x3C2920, 0x3C2750, 0x356380
OFFSET = 100            # the host entry passes value - 100 for dispatch 20 (rva 0x3C7C6C, READ)
SR = 44100.0
OUT = os.path.join(REPO, 'scratchpad', 'host_census_mt.pkl')
HEADER, STRIDE = 23, 20223
src = open(os.path.join(REPO, 'src', 'juno_hostparams.c')).read()
HOST = [(m.group(1).strip(), int(m.group(2)), int(m.group(3)))
        for m in re.finditer(r'\{"([^"]+)"\s*,"[^"]*"\s*,\s*(\d+),\s*(\d+),', src)]
bank = E.bank_bytes(); lt = R.leaf_table()


def rec_of(b):
    return bytearray(bank[HEADER + b * STRIDE: HEADER + (b + 1) * STRIDE])


def mk(rec):
    return bytes(bank[:HEADER]) + bytes(rec)


e = E.E2E()
cur = {'k': None}
ev, cv = [], []


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


def chook(uc_, addr, size, ud):
    if cur['k'] is not None:
        cv.append((uc_.reg_read(UC_X86_REG_RDX) & 0xFFFFFFFF, uc_.reg_read(UC_X86_REG_R8) & 0xFFFFFFFF))


def whook(uc_, access, addr, size, value, ud):
    if cur['k'] is None:
        return
    if uc_.reg_read(UC_X86_REG_RIP) - E.IB == 0x3C2763:
        return
    ev.append(('W', addr - e.state[0], size, value))


e.uc.hook_add(UC_HOOK_CODE, hook, begin=E.IB + WRAP, end=E.IB + WRAP)
e.uc.hook_add(UC_HOOK_CODE, hook, begin=E.IB + IMM, end=E.IB + IMM)
e.uc.hook_add(UC_HOOK_CODE, chook, begin=E.IB + CURVE, end=E.IB + CURVE)
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

D = 20
i = [k for k, h in enumerate(HOST) if h[0] == 'MASTER TUNE'][0]
assert pid_of.get(D) == 2, pid_of.get(D)
dlo, dhi = struct.unpack('<ii', uc.mem_read(E.IB + 0x98c040 + 16 * D, 8))
lo, hi = dlo + OFFSET, dhi + OFFSET
plist = [(i, 'MASTER TUNE', D, 2, lo, hi, HOST[i][1], 'M')]

rnd = random.Random(2020)
jobs = []
for k in range(6):
    base = rec_of((7 * k) % 64)
    base[634] = (k >> 4) & 0xF; base[635] = k & 0xF
    base[650] = (k >> 4) & 0xF; base[651] = k & 0xF
    for v in (lo, lo + 1, 37, 99, 100, 101, 150, hi - 1, hi, rnd.randint(lo, hi), rnd.randint(lo, hi)):
        jobs.append(('T', bytes(base), v))
for v in range(lo, hi + 1):
    jobs.append(('S', bytes(rec_of(0)), v))
for v in (hi + 1, 255, 300, lo - 1, 0x80000000, 0x7FFFFFFF):
    jobs.append(('X', bytes(rec_of(0)), v))

res = {}
sys.stderr.write('MASTER TUNE: host id 2 -> dispatch %d, database [%d,%d] -> host [%d,%d]; %d jobs\n'
                 % (D, dlo, dhi, lo, hi, len(jobs)))
prev = 100                                   # the build's value (POPULATE: the default)
for j, (fam, rec, v) in enumerate(jobs):
    RR.apply_recall(e, 0, mk(rec), lt, E, R)
    ctx = (R.rd_desc(e, 873), R.rd_desc(e, 875))
    del ev[:]; del cv[:]
    cur['k'] = j
    try:
        e.call(APPLY, rcx=e.HOST, rdx=2, r8=v & 0xFFFFFFFF, count=60_000_000)
        ok = True
    except Exception as ex:
        ok = repr(ex)[:80]
    cur['k'] = None
    cells = sorted(set(c for _, c, _, _ in ev))
    e.snap_all()
    fin = {c: int.from_bytes(uc.mem_read(e.state[0] + c, 4), 'little') for c in cells}
    res[j] = dict(fam=fam, i=i, frm=prev, to=v, ctx=ctx, ok=ok, ev=list(ev), fin=fin, rec=None,
                  base=rec, curve=sorted(set(cv)))
    if lo <= v <= hi:
        prev = v
    if j % 50 == 49:
        sys.stderr.write('job %d/%d\n' % (j + 1, len(jobs))); sys.stderr.flush()
pickle.dump({'host': HOST, 'plist': plist, 'res': res, 'njobs': len(jobs)}, open(OUT, 'wb'))
inr = [r for r in res.values() if lo <= r['to'] <= hi]
print('wrote', OUT, len(res), 'jobs;', 'in range: %d, sets per job %s, curves %s'
      % (len(inr), sorted(set(len(r['ev']) for r in inr)), sorted(set(c for r in inr for c, _ in r['curve']))))
print('out of range: sets per job', sorted(set(len(r['ev']) for r in res.values() if not lo <= r['to'] <= hi)))

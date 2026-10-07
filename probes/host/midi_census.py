"""Oracle-only census (CLAIMS B16): what the engine's MIDI controller entries write.

READ (rva 0x320B20 -> CWaveGen vtable): pitch bend (0xE0) -> vt+152 (rva 0x3C7390): the 14-bit
value - 8192 clamped to -8192..8191, dispatch 493 to all 9 units; CC 1 (mod wheel) -> vt+256
(rva 0x3C7E70): value <= 127, dispatch 495; CC 11 (expression) -> vt+280 (rva 0x3C7DD0): value
<= 127, dispatch 498. The processor's dispatch (rva 0x3B9A30) calls its methods vt+1920 / +1928 /
+1936 and keeps the value (processor +1160 / +1164 / +1168).

Per job (context record, controller, value): the dispatch on every unit, logging on EVERY unit each
ramped set (cell, time index, value), immediate set and direct write, then a snap. Jobs run in
order on one engine per context (each controller's previous value carries over).
Contexts: factory patches 0, 9, 21, 40 and two synthetic records (BEND SENS DCO / VCF, BEND
GAIN, MOD SENS DCO / VCF at their minimum, and at their maximum).
DEFECT (playbook 146): the census dispatches with e2e_emu's default flag 1 -- the setters'
IMMEDIATE branch -- while the engine's MIDI entries pass 0, the RAMPED branch. Its value laws
hold; its set kind does not. The real path: probes/host_midi/ctl_path_probe.py (process()).
Writes scratchpad/midi_census.pkl.
    python3 probes/host/midi_census.py      (Unicorn only)"""
import os
import pickle
import random
import re
import sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import e2e_emu as E                      # noqa: E402
import real_recall as R                  # noqa: E402
import recall_render_ab as RR            # noqa: E402
from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_WRITE           # noqa: E402
from unicorn.x86_const import (UC_X86_REG_RCX, UC_X86_REG_RDX, UC_X86_REG_R8,   # noqa: E402
                               UC_X86_REG_RIP, UC_X86_REG_XMM2, UC_X86_REG_XMM3)

POPULATE = E.IB + 0xAD5A0
WRAP, IMM = 0x3C2920, 0x3C2750
SR = 44100.0
OUT = os.path.join(REPO, 'scratchpad', 'midi_census.pkl')
HEADER, STRIDE = 23, 20223
src = open(os.path.join(REPO, 'src', 'juno_hostparams.c')).read()
HOST = {m.group(1).strip(): (int(m.group(2)), int(m.group(3)))
        for m in re.finditer(r'\{"([^"]+)"\s*,"[^"]*"\s*,\s*(\d+),\s*(\d+),', src)}
bank = E.bank_bytes()
lt = R.leaf_table()


def rec_of(b):
    return bytearray(bank[HEADER + b * STRIDE: HEADER + (b + 1) * STRIDE])


def put(rec, name, v):
    """a host parameter's record bytes: types 1 and 2 keep the value's low byte as the nibble
    pair at roff / roff + 1 (src/juno_hostparams.c)"""
    roff, typ = HOST[name]
    assert typ in (1, 2), name
    rec[roff], rec[roff + 1] = (v >> 4) & 0xF, v & 0xF


e = E.E2E()
cur = {'on': False}
ev = []


def unit_of(addr):
    for u in range(9):
        if e.state[u] <= addr < e.state[u] + E.STATE_SZ:
            return u
    return -1


def hook(uc_, addr, size, ud):
    if not cur['on']:
        return
    rcx = uc_.reg_read(UC_X86_REG_RCX)
    u = unit_of(rcx)
    if u < 0 or rcx != e.state[u]:
        return
    rva = addr - E.IB
    di = uc_.reg_read(UC_X86_REG_RDX) & 0xFFFFFFFF
    desc = int.from_bytes(uc_.mem_read(e.state[u] + 0x38, 8), 'little') + 40 * di
    cell = int.from_bytes(uc_.mem_read(desc + 0x20, 8), 'little') - e.state[u]
    if rva == WRAP:
        typ = int.from_bytes(uc_.mem_read(desc + 0xC, 4), 'little')
        ev.append((u, 'R' if typ == 1 else 'N', cell, uc_.reg_read(UC_X86_REG_R8) & 0xFFFFFFFF,
                   uc_.reg_read(UC_X86_REG_XMM3) & 0xFFFFFFFF))
    else:
        ev.append((u, 'I', cell, None, uc_.reg_read(UC_X86_REG_XMM2) & 0xFFFFFFFF))


def whook(uc_, access, addr, size, value, ud):
    if not cur['on'] or uc_.reg_read(UC_X86_REG_RIP) - E.IB == 0x3C2763:
        return
    u = unit_of(addr)
    if u >= 0:
        ev.append((u, 'W', addr - e.state[u], size, value & 0xFFFFFFFF))


e.uc.hook_add(UC_HOOK_CODE, hook, begin=E.IB + WRAP, end=E.IB + WRAP)
e.uc.hook_add(UC_HOOK_CODE, hook, begin=E.IB + IMM, end=E.IB + IMM)
e.build(SR)
e.snap_all()
e.call(POPULATE, count=200_000_000)
for u in range(9):
    e.uc.hook_add(UC_HOOK_MEM_WRITE, whook, begin=e.state[u] + 176, end=e.state[u] + E.STATE_SZ - 1)

ctxs = []
for p in (0, 9, 21, 40):
    ctxs.append(('patch%d' % p, bytes(rec_of(p))))
for name, v in (('min', 0), ('max', 1)):
    r = rec_of(5)
    put(r, 'BEND SENS DCO', 255 * v)
    put(r, 'BEND SENS VCF', 255 * v)
    put(r, 'BEND GAIN', 3 * v)
    put(r, 'MOD SENS DCO', 255 * v)
    put(r, 'MOD SENS VCF', 255 * v)
    ctxs.append((name, bytes(r)))

rnd = random.Random(493)
BEND = [-8192, -8191, -4096, -2048, -1, 0, 1, 2048, 4095, 8191] + [rnd.randint(-8192, 8191) for _ in range(6)] + [0]
FULL = list(range(128)) + [0]
SOME = [0, 1, 63, 64, 126, 127] + [rnd.randint(0, 127) for _ in range(4)] + [0]
jobs = []
for ci, (cname, rec) in enumerate(ctxs):
    jobs.append((ci, 'recall', None))
    for v in BEND:
        jobs.append((ci, 493, v))
    for v in (FULL if ci == 0 else SOME):
        jobs.append((ci, 495, v))
    for v in (FULL if ci == 0 else SOME):
        jobs.append((ci, 498, v))

res = []
sys.stderr.write('%d contexts, %d jobs\n' % (len(ctxs), len(jobs)))
for j, (ci, d, v) in enumerate(jobs):
    if d == 'recall':
        RR.apply_recall(e, 0, bytes(bank[:HEADER]) + ctxs[ci][1], lt, E, R)
        e.snap_all()
        res.append(dict(ctx=ci, d=d))
        continue
    del ev[:]
    cur['on'] = True
    ok = True
    try:
        for u in range(9):
            e.dispatch(u, d, v & 0xFFFFFFFF)
    except Exception as ex:
        ok = repr(ex)[:80]
    cur['on'] = False
    e.snap_all()
    cells = sorted(set((x[0], x[2]) for x in ev))
    fin = {(u, c): int.from_bytes(e.uc.mem_read(e.state[u] + c, 4), 'little') for u, c in cells}
    res.append(dict(ctx=ci, d=d, v=v, ok=ok, ev=list(ev), fin=fin))
    if j % 50 == 49:
        sys.stderr.write('job %d/%d\n' % (j + 1, len(jobs)))
        sys.stderr.flush()
pickle.dump({'ctxs': ctxs, 'res': res}, open(OUT + '.partial', 'wb'))
os.replace(OUT + '.partial', OUT)
for d in (493, 495, 498):
    rr = [r for r in res if r['d'] == d]
    print('dispatch %d: %d jobs, sets per job %s, units %s, kinds %s' % (
        d, len(rr), sorted(set(len(r['ev']) for r in rr)), sorted(set(x[0] for r in rr for x in r['ev'])),
        sorted(set(x[1] for r in rr for x in r['ev']))))
print('wrote', OUT)

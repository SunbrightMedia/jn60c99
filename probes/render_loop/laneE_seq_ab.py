#!/usr/bin/env python3
"""LANE E — stronger terminus equivalence: a polyphonic SEQUENCE through the
plugin's own engine noteOn/noteOff vs. replaying the exact per-voice
Note/Gate/Mute bus tuples it published. If the bus IS the terminus, replay must
reproduce the engine state cell-for-cell."""
import sys, os, struct, json
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E
import real_recall as R
import recall_render_ab as RRA
from unicorn import UC_HOOK_CODE
from unicorn.x86_const import (UC_X86_REG_RCX, UC_X86_REG_RDX,
                               UC_X86_REG_R8, UC_X86_REG_R9)

PATCH = int(os.environ.get('JUNO_PATCH', '3')); SR = 48000.0; SPAN = 110000
bank = E.bank_bytes(); leaves = R.leaf_table()
SEQ = [('on', 60, 100), ('on', 64, 110), ('on', 67, 90), ('off', 64, 64),
       ('on', 72, 127), ('on', 55, 40), ('off', 60, 64), ('on', 48, 64),
       ('on', 50, 64), ('on', 52, 64), ('on', 53, 64), ('on', 57, 64),
       ('on', 59, 64), ('on', 61, 64), ('off', 67, 64), ('off', 72, 64)]

def recall(hooks=None):
    e = E.E2E()
    if hooks:
        for rva, cb in hooks: e.uc.hook_add(UC_HOOK_CODE, cb, begin=E.IB+rva, end=E.IB+rva)
    e.build(SR); e.snap_all()
    blob = E.patch_blob(bank, PATCH)
    for (d, bb) in leaves: R.wr_desc(e, d, R.dec(blob, bb))
    for (d, ro) in RRA.FX_LEAVES: R.wr_desc(e, d, R.dec(blob, ro-16))
    for (d, bb) in RRA.EXTRA_LEAVES: R.wr_desc(e, d, R.dec(blob, bb))
    ff = RRA._finefx_leaves(blob, R)
    for (d, ro, raw) in ff: R.wr_desc(e, d, (blob[ro-16] & 0x7F) if raw else R.dec(blob, ro-16))
    allv = ([d for d, _ in leaves] + [d for d, _ in RRA.FX_LEAVES]
            + [d for d, _ in RRA.EXTRA_LEAVES] + [d for d, _, _ in ff])
    for u in range(9):
        for d in allv:
            try: e.dispatch(u, d, R.rd_desc(e, d))
            except RuntimeError: pass
    e.snap_all(); e.clear_latch(); e.set_ftz()
    return e

log = []; armed = {'v': False}
def hk(u_, a, s, x):
    if armed['v']:
        log.append((u_.reg_read(UC_X86_REG_RCX), u_.reg_read(UC_X86_REG_RDX),
                    u_.reg_read(UC_X86_REG_R8), u_.reg_read(UC_X86_REG_R9) & 0xffffffff))
eA = recall(hooks=[(0x3B9A30, hk)])
p2u = {p: u for u, p in enumerate(eA.proc)}
armed['v'] = True; log.clear()
for kind, n, v in SEQ:
    (eA.note_on(n, v) if kind == 'on' else eA.note_off(n, v))
armed['v'] = False
tuples = [(p2u.get(p, -1), i, f, val) for p, i, f, val in log]
A = [bytes(eA.uc.mem_read(eA.state[u], SPAN)) for u in (0, 6, 7, 8)]

byidx = {}
for u, i, f, v in tuples: byidx.setdefault(i, []).append(v)
print("patch %d  %d events -> %d dispatch calls" % (PATCH, len(SEQ), len(tuples)))
print("indices touched: %s" % sorted(byidx))
for i in sorted(byidx):
    print("   idx %4d flag0  n=%d values(unit0 only)=%s" % (i, len(byidx[i]),
          [v for uu, ii, ff, v in tuples if ii == i and uu == 0]))

eB = recall()
for u, i, f, v in tuples:
    R.wr_desc(eB, i, v); eB.dispatch(u, i, v, flag=f)
B = [bytes(eB.uc.mem_read(eB.state[u], SPAN)) for u in (0, 6, 7, 8)]

tot = 0
for k, u in enumerate((0, 6, 7, 8)):
    d = [o for o in range(0, SPAN, 4) if A[k][o:o+4] != B[k][o:o+4]]
    tot += len(d)
    if d:
        print(" unit%d: %d differing" % (u, len(d)))
        for o in d[:20]:
            print("   off %-7d  A=%-14g B=%-14g" % (o, struct.unpack('<f', A[k][o:o+4])[0],
                                                    struct.unpack('<f', B[k][o:o+4])[0]))
print("SEQ A-vs-B TOTAL differing cells: %d" % tot)

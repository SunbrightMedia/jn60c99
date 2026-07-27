#!/usr/bin/env python3
"""LANE E (spillover, high value for the render-loop hunt): the queue consumer
0x320B20 subdivides EVERY host block at 24-PPQN transport ticks and calls engine
vtable slot 23 (+184) = rva 0x3C6750 between sub-blocks. Neither e2e_emu.render()
nor juno_driver.c ever calls it. Is it audio-inert?

PROVEN: on a RECALLED engine, call 0x3C6750 N times and record every guest write
that lands inside any of the 9 unit state blocks."""
import sys, os, struct, collections
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E
import real_recall as R
import recall_render_ab as RRA
from unicorn import UC_HOOK_MEM_WRITE

PATCH = int(os.environ.get('JUNO_PATCH', '3')); SR = 48000.0
TICK = E.IB + 0x3C6750
bank = E.bank_bytes(); leaves = R.leaf_table()
e = RRA.prepare_recall(PATCH, bank, leaves, E, R, SR); uc = e.uc
spans = [(e.state[u], e.state[u] + E.STATE_SZ, u) for u in range(9)]
cap = {'on': False}
writes = collections.Counter()
def onw(u_, acc, addr, size, val, x):
    if not cap['on']: return
    for lo, hi, u in spans:
        if lo <= addr < hi:
            writes[(u, addr - lo, size)] += 1
            return
uc.hook_add(UC_HOOK_MEM_WRITE, onw)

for label, notes in (('noteless', []), ('with note 60', [(60, 100)])):
    for n, v in notes: e.note_on(n, v)
    writes.clear(); cap['on'] = True
    for _ in range(24): e.call(TICK, rcx=e.HOST)
    cap['on'] = False
    print("\n=== slot23 (0x3C6750) x24, %s ===" % label)
    print("distinct state cells written: %d" % len(writes))
    byu = collections.Counter(k[0] for k in writes)
    print("per-unit: %s" % dict(sorted(byu.items())))
    offs = sorted({k[1] for k in writes})
    print("offsets (first 40): %s" % offs[:40])
    for o in offs[:12]:
        cur = struct.unpack('<f', uc.mem_read(e.state[0] + o, 4))[0]
        cui = struct.unpack('<i', uc.mem_read(e.state[0] + o, 4))[0]
        print("   off %-8d  f32=%-14g i32=%d" % (o, cur, cui))

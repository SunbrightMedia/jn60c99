#!/usr/bin/env python3
"""LANE A part 4 — exercise slot13's OTHER arm with a LIVE (non-zero, changing)
metered value, and identify the metered source cell.

The first write-trace ran on a settled note-on state where the metered float was
0.0, so 0x324A30's `xmm1 != *(this) && xmm1 >= 0` branch (which writes +8/+0xC)
was never taken. Here we render first so the source cell is live, then trace
again, interleaving slot13 with per-sample renders exactly as the pool does.
"""
import sys, os, struct, collections
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E
import real_recall as R
import recall_render_ab as AB
from unicorn import *

IB = E.IB
SR = float(os.environ.get('JUNO_SR', '48000'))
PATCH = int(sys.argv[1]) if len(sys.argv) > 1 else 3
SLOT13 = IB + 0x3C7230

bank = E.bank_bytes(); leaves = R.leaf_table()
e = AB.prepare_recall(PATCH, bank, leaves, E, R, SR)
e.note_on(60, 100)
uc = e.uc; HOST = e.HOST
def rq(a): return int.from_bytes(uc.mem_read(a, 8), 'little')
def rf(a): return struct.unpack('<f', uc.mem_read(a, 4))[0]

st0 = e.state[0]
base = rq(st0 + 0x38)
rec = base + 40 * 29
valp = rq(rec + 0x20)
print("metered source: unit0 state + %d   (record 29 of the array at *(state+0x38))"
      % (valp - st0))
print("value before render: %r" % rf(valp))

writes = []
def mk(lab, lo):
    def cb(u, acc, addr, sz, val, usr): writes.append((lab, addr - lo, sz, val))
    return cb
hooks = [uc.hook_add(UC_HOOK_MEM_WRITE, mk("state[%d]" % u, e.state[u]),
                     begin=e.state[u], end=e.state[u] + E.STATE_SZ - 1) for u in range(9)]
hooks.append(uc.hook_add(UC_HOOK_MEM_WRITE, mk("ENGINE", HOST), begin=HOST, end=HOST + 0x7FFF))

vals = []
engoff = collections.Counter()
statew = 0
for i in range(256):
    writes.clear()
    e.render(1, block=1)                      # advance the DSP one sample
    rw = [w for w in writes if w[0] != "ENGINE"]
    writes.clear()
    v = rf(valp)
    e.call(SLOT13, rcx=HOST, count=2_000_000)  # the plugin's voice-0 cadence
    vals.append(v)
    for lab, off, sz, val in writes:
        if lab == "ENGINE": engoff[(off, sz)] += 1
        else: statew += 1
for h in hooks: uc.hook_del(h)

print("metered value over 256 samples: min=%r max=%r  n_distinct=%d  n_nonzero=%d"
      % (min(vals), max(vals), len(set(vals)), sum(1 for x in vals if x != 0.0)))
print("first 8 values: %s" % [round(x, 6) for x in vals[:8]])
print()
print("UNIT-STATE writes attributable to slot13 over 256 calls: %d" % statew)
print("ENGINE offsets written by slot13 over 256 calls:")
for (off, sz), n in sorted(engoff.items()):
    print("   ENGINE+%-5d size=%d  count=%d" % (off, sz, n))
print()
print("accumulator ENGINE+1040..1068 now:")
for k in range(1040, 1072, 4):
    b = struct.unpack('<I', uc.mem_read(HOST + k, 4))[0]
    print("   +%d = %08x  (f32 %r  i32 %d)" % (k, b, struct.unpack('<f', struct.pack('<I', b))[0],
                                               struct.unpack('<i', struct.pack('<I', b))[0]))
print("\n== VERDICT: %s ==" % ("NO-EQUIVALENT (audio-inert): 0 unit-state writes"
                               if statew == 0 else "YES-DIVERGENCE"))

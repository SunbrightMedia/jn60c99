#!/usr/bin/env python3
"""LANE A — prove/refute that ENGINE vtable slot13 (rva 0x3C7230), the
voice-0-only per-sample call inside the pool work item (0x3C6F00), is AUDIO-INERT.

Protocol (obeys docs/P112_FINDINGS.md §8):
  * baseline is a RECALLED patch, not a pristine engine (trap 4)
  * full state restore is irrelevant here because we only OBSERVE writes
  * we do not dispatch anything, so traps 2/3 do not apply
Single process, Unicorn only (two-process rule: no libjuno here).

Run:  PYTHONUNBUFFERED=1 python3 probes/render_loop/laneA_slot13_inert.py [patch]
"""
import sys, os, struct, collections

HERE = '/home/user/jn60c99/tools/verify'
sys.path.insert(0, HERE)
import e2e_emu as E
import real_recall as R
import recall_render_ab as AB
from unicorn import *
from unicorn.x86_const import *

IB = E.IB
SR = float(os.environ.get('JUNO_SR', '48000'))
PATCH = int(sys.argv[1]) if len(sys.argv) > 1 else 0

SLOT13 = IB + 0x3C7230
SLOT10 = IB + 0x3C7180
F_3C10B0 = IB + 0x3C10B0
F_3C2520 = IB + 0x3C2520
F_324A30 = IB + 0x324A30

print(f"== LANE A: slot13 (rva 0x3C7230) inertness, patch {PATCH}, sr {SR}")

bank = E.bank_bytes()
leaves = R.leaf_table()
e = AB.prepare_recall(PATCH, bank, leaves, E, R, SR)
print("recall done; patch name =", E.patch_name(bank, PATCH))
e.note_on(60, 100)
print("note_on(60,100) done")

uc = e.uc
HOST = e.HOST

def rq(a):  return int.from_bytes(uc.mem_read(a, 8), 'little')
def rd(a):  return struct.unpack('<I', uc.mem_read(a, 4))[0]
def rf(a):  return struct.unpack('<f', uc.mem_read(a, 4))[0]

# ---------------------------------------------------------------- STEP 2: identity of ENGINE+88+64i
print("\n-- per-unit 64-byte struct (ENGINE+80+64i), slot map --")
for i in range(9):
    row = [rq(HOST + 80 + 64 * i + 8 * k) for k in range(8)]
    if i < 2 or i == 8:
        print(f"  unit{i}: " + " ".join("+%3d=%016x" % (80 + 64 * i + 8 * k, row[k]) for k in range(8)))
lam = [rq(HOST + 88 + 64 * i) for i in range(9)]
print("\n  ENGINE+88+64i (the object slot13 reads):")
for i in range(9):
    inner = rq(lam[i])
    tag = ""
    if inner == e.state[i]: tag = "== state[%d]" % i
    elif inner in e.state: tag = "== state[%d]" % e.state.index(inner)
    sz = [s for (a, s) in e.allocs if a == lam[i]]
    print("    unit%d obj=%016x size=%s  *(obj+0)=%016x  %s"
          % (i, lam[i], sz[0] if sz else '?', inner, tag))

# the record array 0x3C2520 walks:  base = *(inner + 0x38); rec = base + 40*29
inner0 = rq(lam[0])
base = rq(inner0 + 0x38)
smoo = rq(inner0 + 0x58)      # e2e_emu.snap_all's smoother array base (state+88)
print("\n  *(state0+0x38) = %016x   (0x3C2520 record array base)" % base)
print("  *(state0+0x58) = %016x   (e2e snap_all smoother base)  same=%s" % (smoo, base == smoo))
rec = base + 40 * 29
print("  record 29 @ %016x:" % rec)
print("    " + " ".join("+%02x=%08x" % (k, rd(rec + k)) for k in range(0, 40, 4)))
valp = rq(rec + 0x20)
print("    [rec+0x0c] (validity, must be <=1 to return a value) = %d" % rd(rec + 0x0c))
print("    [rec+0x20] value ptr = %016x  -> f32 %r" % (valp, rf(valp) if valp else None))
if valp:
    for u in range(9):
        if e.state[u] <= valp < e.state[u] + E.STATE_SZ:
            print("    value ptr is INSIDE unit%d state at offset %d" % (u, valp - e.state[u]))
    if HOST <= valp < HOST + 0x8000:
        print("    value ptr is INSIDE the ENGINE object at +%d" % (valp - HOST))

# ---------------------------------------------------------------- STEP 3: write trace
UNIT_RANGES = [(e.state[u], e.state[u] + E.STATE_SZ, "state[%d]" % u) for u in range(9)]
ENG_RANGE = (HOST, HOST + 0x8000, "ENGINE")

writes = []          # (label, offset, size, value)
blocks = collections.OrderedDict()

def mk_cb(label, lo):
    def cb(uc_, access, address, size, value, user):
        writes.append((label, address - lo, size, value))
    return cb

hooks = []
for lo, hi, lab in UNIT_RANGES:
    hooks.append(uc.hook_add(UC_HOOK_MEM_WRITE, mk_cb(lab, lo), begin=lo, end=hi - 1))
hooks.append(uc.hook_add(UC_HOOK_MEM_WRITE, mk_cb("ENGINE", HOST), begin=ENG_RANGE[0], end=ENG_RANGE[1] - 1))

def blkcb(uc_, address, size, user):
    blocks[address - IB] = blocks.get(address - IB, 0) + 1
hb = uc.hook_add(UC_HOOK_BLOCK, blkcb, begin=IB, end=IB + E.IMGSZ - 1)

# snapshot the accumulator region before
acc_before = bytes(uc.mem_read(HOST + 1024, 64))

print("\n-- calling slot13 (rva 0x3C7230, rcx=ENGINE) x1, bounded --")
try:
    ret = e.call(SLOT13, rcx=HOST, count=2_000_000)
    print("   returned rax=0x%x  (no stall, no stub of any sync primitive)" % ret)
except Exception as ex:
    print("   CALL FAILED:", ex)
    raise

acc_after = bytes(uc.mem_read(HOST + 1024, 64))

print("\n-- basic blocks executed (rva : count) --")
print("   " + ", ".join("0x%X" % r for r in list(blocks)[:40]))
print("   n_blocks=%d" % len(blocks))

state_w = [w for w in writes if w[0].startswith("state[")]
eng_w = [w for w in writes if w[0] == "ENGINE"]
print("\n-- WRITES INSIDE ANY OF THE 9 UNIT STATE REGIONS: %d --" % len(state_w))
for w in state_w[:50]:
    print("   %s +%d size=%d val=0x%x" % w)
print("\n-- WRITES INSIDE THE ENGINE OBJECT (HOST..+0x8000): %d --" % len(eng_w))
agg = collections.OrderedDict()
for lab, off, sz, val in eng_w:
    agg.setdefault((off, sz), []).append(val)
for (off, sz), vals in agg.items():
    print("   ENGINE+%d (0x%x) size=%d  values=%s" % (off, off, sz, [hex(v) for v in vals]))

print("\n-- accumulator region ENGINE+1024..1088 before/after --")
for k in range(0, 64, 4):
    b = struct.unpack('<I', acc_before[k:k + 4])[0]
    a = struct.unpack('<I', acc_after[k:k + 4])[0]
    if b != a:
        fb = struct.unpack('<f', acc_before[k:k + 4])[0]
        fa = struct.unpack('<f', acc_after[k:k + 4])[0]
        print("   ENGINE+%4d  %08x -> %08x   (f32 %r -> %r)" % (1024 + k, b, a, fb, fa))

# repeat 4095 more times to see the steady-state footprint
writes.clear()
for _ in range(4095):
    e.call(SLOT13, rcx=HOST, count=2_000_000)
state_w2 = [w for w in writes if w[0].startswith("state[")]
eng_off2 = sorted({(w[1], w[2]) for w in writes if w[0] == "ENGINE"})
print("\n-- after 4096 total calls --")
print("   unit-state writes across 4095 further calls: %d" % len(state_w2))
print("   ENGINE offsets touched: %s" % [("+%d/%dB" % o) for o in eng_off2])
acc_4096 = bytes(uc.mem_read(HOST + 1024, 64))
for k in range(0, 64, 4):
    b = struct.unpack('<I', acc_before[k:k + 4])[0]
    a = struct.unpack('<I', acc_4096[k:k + 4])[0]
    if b != a:
        print("   ENGINE+%4d  %08x -> %08x   (f32 %r -> %r)"
              % (1024 + k, b, a, struct.unpack('<f', acc_before[k:k+4])[0],
                 struct.unpack('<f', acc_4096[k:k+4])[0]))

for h in hooks: uc.hook_del(h)
uc.hook_del(hb)

verdict = "NO-EQUIVALENT (audio-inert)" if not state_w and not state_w2 else "YES-DIVERGENCE"
print("\n== STEP3 VERDICT: %s ==" % verdict)

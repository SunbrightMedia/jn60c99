#!/usr/bin/env python3
"""LANE E — the note-path terminus, PROVEN, with hooks installed BEFORE any
guest execution (Unicorn caches translated blocks; a hook added after a block
first runs silently misses it -- that artefact produced a false "0 dispatch
calls" in the first cut of this probe).

STATE A: recalled engine + the plugin's OWN engine noteOn (vtable slot16,
         rva 0x3C7330) -- the entry both the port and e2e_emu drive.
STATE B: recalled engine + the per-voice NOTE/GATE bus fired directly through
         the value-tree dispatch 0x3B9A30 with exactly the (idx, flag, value)
         tuples state A was observed to publish.
Diff = whether the two entries drive the same lifecycle.

Traps guarded (docs/P112_FINDINGS.md sec 8): fresh engine per state (no partial
restore); descriptor DB written before every dispatch; values inside each
index's own paramDB {min,max}; baseline is a RECALLED patch, not a pristine
engine.  Oracle-only (Unicorn); no ctypes/libjuno in this process.
"""
import sys, os, struct, json
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E
import real_recall as R
import recall_render_ab as RRA
from unicorn import UC_HOOK_CODE
from unicorn.x86_const import (UC_X86_REG_RCX, UC_X86_REG_RDX,
                               UC_X86_REG_R8, UC_X86_REG_R9)

PATCH = int(os.environ.get('JUNO_PATCH', '3'))
SR = 48000.0
NOTE, VEL = 60, 100
SPAN = 110000             # 8 voice regions (8*10512=84096) + noise block + aux arrays (101504+)
bank = E.bank_bytes()
leaves = R.leaf_table()
DISPATCH = E.IB + 0x3B9A30


def recall(hooks=None):
    """recall_render_ab.prepare_recall inlined so hooks can be installed on a
    virgin uc before ANY emu_start (TB-cache safety)."""
    e = E.E2E()
    if hooks:
        for rva, cb in hooks: e.uc.hook_add(UC_HOOK_CODE, cb, begin=E.IB+rva, end=E.IB+rva)
    e.build(SR); e.snap_all()
    blob = E.patch_blob(bank, PATCH)
    for (disp, bb) in leaves: R.wr_desc(e, disp, R.dec(blob, bb))
    for (disp, ro) in RRA.FX_LEAVES: R.wr_desc(e, disp, R.dec(blob, ro-16))
    for (disp, bb) in RRA.EXTRA_LEAVES: R.wr_desc(e, disp, R.dec(blob, bb))
    finefx = RRA._finefx_leaves(blob, R)
    for (disp, ro, raw) in finefx:
        R.wr_desc(e, disp, (blob[ro-16] & 0x7F) if raw else R.dec(blob, ro-16))
    allleaves = ([d for d, _ in leaves] + [d for d, _ in RRA.FX_LEAVES]
                 + [d for d, _ in RRA.EXTRA_LEAVES] + [d for d, _, _ in finefx])
    for u in range(9):
        for disp in allleaves:
            try: e.dispatch(u, disp, R.rd_desc(e, disp))
            except RuntimeError: pass
    e.snap_all(); e.clear_latch(); e.set_ftz()
    return e


def snap(e):
    return [bytes(e.uc.mem_read(e.state[u], SPAN)) for u in range(9)]


def diff(A, B, tag):
    tot = 0
    for u in (0, 7, 8):
        d = [o for o in range(0, SPAN, 4) if A[u][o:o+4] != B[u][o:o+4]]
        tot += len(d)
        if d:
            print("  %s unit%d: %d differing cells" % (tag, u, len(d)))
            for o in d[:24]:
                a = struct.unpack('<f', A[u][o:o+4])[0]
                b = struct.unpack('<f', B[u][o:o+4])[0]
                print("      off %-7d voice%d+%-6d  A=%-14g B=%-14g" %
                      (o, o // 10512, o % 10512, a, b))
            if len(d) > 24: print("      ... %d more" % (len(d)-24))
    print("  %s TOTAL differing cells: %d" % (tag, tot))
    return tot


# ---------------------------------------------------------------- STATE A ---
log = []
armed = {'v': False}
def hk(u_, a, s, x):
    if armed['v']:
        log.append((u_.reg_read(UC_X86_REG_RCX), u_.reg_read(UC_X86_REG_RDX),
                    u_.reg_read(UC_X86_REG_R8), u_.reg_read(UC_X86_REG_R9) & 0xffffffff))
eA = recall(hooks=[(0x3B9A30, hk)])
base = snap(eA)
proc2u = {p: u for u, p in enumerate(eA.proc)}
armed['v'] = True
log.clear(); eA.note_on(NOTE, VEL); on_disp = [(proc2u.get(p, -1), i, f, v) for p, i, f, v in log]
A_on = snap(eA)
log.clear(); eA.note_off(NOTE, 64); off_disp = [(proc2u.get(p, -1), i, f, v) for p, i, f, v in log]
A_off = snap(eA)
armed['v'] = False

print("patch %d '%s' @ %g Hz" % (PATCH, E.patch_name(bank, PATCH), SR))
print("\nengine noteOn(%d,%d) -> value-tree dispatch 0x3B9A30 calls: %d" % (NOTE, VEL, len(on_disp)))
for r in on_disp: print("   unit%-2d idx %4d flag %d val %d" % r)
print("engine noteOff(%d,64) -> dispatch calls: %d" % (NOTE, len(off_disp)))
for r in off_disp: print("   unit%-2d idx %4d flag %d val %d" % r)

print("\n[baseline -> after noteOn]  (A=baseline, B=after)"); diff(base, A_on, 'noteOn')
print("\n[after noteOn -> after noteOff]  (A=afterOn, B=afterOff)"); diff(A_on, A_off, 'noteOff')

# ---------------------------------------------------------------- STATE B ---
eB = recall()
b_base = snap(eB)
assert b_base == base, "recall not reproducible between engines"
for u, idx, flag, val in on_disp:
    R.wr_desc(eB, idx, val)
    eB.dispatch(u, idx, val, flag=flag)
B_on = snap(eB)
print("\n[A(noteOn) vs B(Note/Gate bus, flag as observed)]"); nAB = diff(A_on, B_on, 'A-vs-B')

for u, idx, flag, val in off_disp:
    R.wr_desc(eB, idx, val)
    eB.dispatch(u, idx, val, flag=flag)
B_off = snap(eB)
print("\n[A(noteOff) vs B(Gate=0 bus)]"); nABoff = diff(A_off, B_off, 'A-vs-B-off')

# ---------------------------------------------------------------- STATE C ---
# same bus, but flag=1 (the RECALL role) instead of the observed flag=0
eC = recall()
for u, idx, flag, val in on_disp:
    R.wr_desc(eC, idx, val)
    eC.dispatch(u, idx, val, flag=1)
C_on = snap(eC)
print("\n[A(noteOn) vs C(same bus, flag=1 recall role)]"); nAC = diff(A_on, C_on, 'A-vs-C')

print("\nSUMMARY patch %d: A-vs-B(on)=%d  A-vs-B(off)=%d  A-vs-C(on)=%d" %
      (PATCH, nAB, nABoff, nAC))
json.dump({'patch': PATCH, 'on_disp': on_disp, 'off_disp': off_disp,
           'AB_on': nAB, 'AB_off': nABoff, 'AC_on': nAC},
          open('/home/user/jn60c99/probes/render_loop/laneE_terminus_ab_p%d.json' % PATCH, 'w'))

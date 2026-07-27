#!/usr/bin/env python3
"""LANE factory-statediff: fullstate_diff2 + WRITE ATTRIBUTION.
Same A/B construction as fullstate_diff2.py (A = plugin's own enumerator index
set in enumerator order; B = port applied set in port order; identical
descriptor population both sides), but with a UC_HOOK_MEM_WRITE hook over the
unit-0 voice region attributing every write to the (unit, dispatch-index)
active at the time. For each differing cell, prints the LAST writer on each
side. Oracle-only (Unicorn); covenant-clean (plugin's own setters + proven
blob decode). Usage: factory_statediff_attrib.py <patch> [patch...]"""
import sys, os, struct
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E
import real_recall as R
from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_WRITE
from unicorn.x86_const import UC_X86_REG_RCX, UC_X86_REG_RDX

PATCHES = [int(a) for a in sys.argv[1:]] or [0]
SETTER = E.IB + 0x3B9A30
ENUM   = E.IB + 0x3B48A0


def enum_order():
    e = E.E2E(); uc = e.uc; order, rcx0 = [], []
    def hk(u, a, s, x):
        if not rcx0: rcx0.append(u.reg_read(UC_X86_REG_RCX))
        order.append(u.reg_read(UC_X86_REG_RDX))
    uc.hook_add(UC_HOOK_CODE, hk, begin=SETTER, end=SETTER)
    e.build(48000.0); proc = rcx0[0]; order.clear()
    e.call(ENUM, rcx=proc, rdx=1, count=200_000_000)
    s = set(); seen = []
    for i in order:
        if i not in s: s.add(i); seen.append(i)
    return seen


ENUM_ORDER = enum_order()
print("enum order length:", len(ENUM_ORDER), flush=True)

leaves = R.leaf_table()
FX_REC = [(1179, 3057), (1181, 3060)]
EXTRA  = [(1028, 1852), (1058, 2086)]
H_MAP  = {878: 752, 1029: 779}


def bank_bytes():
    p = os.environ.get('JUNO_BANK')
    if p: return open(p, 'rb').read()
    return E.bank_bytes()


def populate(e, blob):
    for (disp, bb) in leaves: R.wr_desc(e, disp, R.dec(blob, bb))
    for (disp, rec) in FX_REC: R.wr_desc(e, disp, R.dec(blob, rec - 16))
    for (disp, bb) in EXTRA: R.wr_desc(e, disp, R.dec(blob, bb))
    for h, bi in H_MAP.items():
        b = R.rd_desc(e, bi) & 0xff
        R.wr_desc(e, h, struct.unpack('<I', struct.pack('<f', b / 255.0))[0])


APPLIED = [d for (d, _) in leaves] + [1179, 1181, 1028, 1058]


def run_side(blob, order, label):
    """Build, populate, dispatch order for all 9 units with write attribution.
    Returns (state_bytes, last_writer{off: (unit, idx, value_u32)})."""
    e = E.E2E(); e.build(48000.0); e.snap_all(); populate(e, blob)
    base = e.state[0]
    cur = [None, None]           # (unit, idx) active during dispatch
    last = {}
    def hk(uc, access, addr, size, value, u):
        off = addr - base
        if 0 <= off < 10512:
            last[off] = (cur[0], cur[1], value & 0xffffffff, size)
    h = e.uc.hook_add(UC_HOOK_MEM_WRITE, hk)
    for u in range(9):
        for idx in order:
            cur[0], cur[1] = u, idx
            try: e.dispatch(u, idx, R.rd_desc(e, idx))
            except RuntimeError: pass
    e.uc.hook_del(h)
    e.snap_all()                  # snap AFTER unhook: attribute only dispatch writes
    S = bytes(e.uc.mem_read(e.state[0], 10512))
    del e
    return S, last


bank = bank_bytes()
for P in PATCHES:
    blob = E.patch_blob(bank, P)
    A, lastA = run_side(blob, ENUM_ORDER, 'A')
    B, lastB = run_side(blob, APPLIED, 'B')
    diffs = [o for o in range(0, 10512, 4) if A[o:o+4] != B[o:o+4]]
    print("patch %2d (%s): %d diffs" % (P, E.patch_name(bank, P), len(diffs)), flush=True)
    for o in diffs:
        fa = struct.unpack('<f', A[o:o+4])[0]
        fb = struct.unpack('<f', B[o:o+4])[0]
        wa = lastA.get(o); wb = lastB.get(o)
        def wfmt(w):
            if w is None: return "no-dispatch-write(snap/pre)"
            return "unit=%s idx=%s val=0x%08x sz=%d" % (w[0], w[1], w[2], w[3])
        print("  cell %6d  A=%.9g  B=%.9g  lastA[%s]  lastB[%s]" %
              (o, fa, fb, wfmt(wa), wfmt(wb)), flush=True)

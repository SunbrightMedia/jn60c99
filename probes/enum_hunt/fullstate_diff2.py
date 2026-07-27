#!/usr/bin/env python3
"""Clean full-state diff: identical per-patch descriptor population on BOTH sides.
State A = the plugin's OWN recall enumerator index set (165 indices, captured in
the enumerator's own dispatch ORDER). State B = the port's applied leaf set in
port order. Any remaining unit-0 cell diff = a genuine completeness/order effect
that every render A/B is structurally blind to (both its sides use the applied
set). Oracle-only (Unicorn), covenant-clean: plugin's own setters + proven blob
decode. Env JUNO_BANK overrides the bank file (e.g. the Chillwave bank)."""
import sys, os, struct
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E
import real_recall as R
from unicorn import UC_HOOK_CODE
from unicorn.x86_const import UC_X86_REG_RCX, UC_X86_REG_RDX

PATCHES = [int(a) for a in sys.argv[1:]] or [0, 1, 2, 3, 4, 5, 6, 7]
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
H_MAP  = {878: 752, 1029: 779}          # H float twin <- byte param (same cell)


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

bank = bank_bytes()
total_bad = 0
for P in PATCHES:
    blob = E.patch_blob(bank, P)
    eA = E.E2E(); eA.build(48000.0); eA.snap_all(); populate(eA, blob)
    for u in range(9):
        for idx in ENUM_ORDER:
            try: eA.dispatch(u, idx, R.rd_desc(eA, idx))
            except RuntimeError: pass
    eA.snap_all(); A = bytes(eA.uc.mem_read(eA.state[0], 10512))
    del eA
    eB = E.E2E(); eB.build(48000.0); eB.snap_all(); populate(eB, blob)
    for u in range(9):
        for idx in APPLIED:
            try: eB.dispatch(u, idx, R.rd_desc(eB, idx))
            except RuntimeError: pass
    eB.snap_all(); B = bytes(eB.uc.mem_read(eB.state[0], 10512))
    del eB
    diffs = [(o, struct.unpack('<f', A[o:o+4])[0], struct.unpack('<f', B[o:o+4])[0])
             for o in range(0, 10512, 4) if A[o:o+4] != B[o:o+4]]
    total_bad += len(diffs)
    print("patch %2d: %d diffs %s" % (P, len(diffs),
          "" if not diffs else str([(o, round(a, 6), round(b, 6)) for o, a, b in diffs])),
          flush=True)
print("TOTAL differing cells:", total_bad)

#!/usr/bin/env python3
"""CLOSE THE HOLE: the earlier enum-vs-port recall state diff compared ONLY
unit-0's first 10512 bytes (the voice region). The FX/MASTER region — chorus
6396xxx / 10693xxx, delay 102xxx / 6497xxx, reverb 10759xxx, routing 11022xxx —
was NEVER compared, and BS Solid is an EFFECT TYPE 2 (chorus) + REVERB patch.

This diffs the FULL unit state (0xA83010 bytes) for EVERY unit 0..8 between:
  A = the plugin's OWN recall enumerator index set (165), in enumerator order
  B = the port's applied leaf set, in port order
with IDENTICAL per-patch descriptor population on both sides.
Any differing cell is a recall gap the render A/B could be blind to.

Oracle-only (Unicorn). Env JUNO_BANK selects the bank.
Usage: fullstate_diff_ALL.py [patch ...]
"""
import sys, os, struct
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E
import real_recall as R
from unicorn import UC_HOOK_CODE
from unicorn.x86_const import UC_X86_REG_RCX, UC_X86_REG_RDX

SETTER = E.IB + 0x3B9A30
ENUM   = E.IB + 0x3B48A0
SZ     = 0xA83010
PATCHES = [int(a) for a in sys.argv[1:] if a.lstrip('-').isdigit()] or [3]


def enum_order():
    e = E.E2E(); uc = e.uc; order, rcx0 = [], []
    def hk(u, a, s, x):
        if not rcx0: rcx0.append(u.reg_read(UC_X86_REG_RCX))
        order.append(u.reg_read(UC_X86_REG_RDX))
    uc.hook_add(UC_HOOK_CODE, hk, begin=SETTER, end=SETTER)
    e.build(48000.0); proc = rcx0[0]; order.clear()
    e.call(ENUM, rcx=proc, rdx=1, count=200_000_000)
    seen, s = [], set()
    for i in order:
        if i not in s: s.add(i); seen.append(i)
    return seen


ENUM_ORDER = enum_order()
leaves = R.leaf_table()
FX_REC = [(1179, 3057), (1181, 3060)]
EXTRA  = [(1028, 1852), (1058, 2086)]
H_MAP  = {878: 752, 1029: 779}
# the fine-FX leaves the port applies (recall_render_ab), so both sides match
DLY  = [(1180, 3059, True), (1182, 3068, False), (1183, 3076, False),
        (1184, 3084, False), (1185, 3092, False)]
REV  = [(1323, 3947, True), (1324, 3948, True), (1325, 3949, True),
        (1326, 3950, True), (1327, 3951, False)]
CHO  = [(1210, 3286, True), (1211, 3287, True), (1212, 3288, True)]


def bank_bytes():
    p = os.environ.get('JUNO_BANK')
    return open(p, 'rb').read() if p else E.bank_bytes()


def finefx(blob):
    dt = R.dec(blob, 634)
    return (DLY if dt in (0, 1, 5) else []) + (CHO if dt in (2, 3, 5) else []) + REV


def populate(e, blob):
    for (d, bb) in leaves: R.wr_desc(e, d, R.dec(blob, bb))
    for (d, rec) in FX_REC: R.wr_desc(e, d, R.dec(blob, rec - 16))
    for (d, bb) in EXTRA:   R.wr_desc(e, d, R.dec(blob, bb))
    for (d, rec, raw) in finefx(blob):
        R.wr_desc(e, d, (blob[rec-16] & 0x7F) if raw else R.dec(blob, rec-16))
    for h, bi in H_MAP.items():
        b = R.rd_desc(e, bi) & 0xff
        R.wr_desc(e, h, struct.unpack('<I', struct.pack('<f', b/255.0))[0])


bank = bank_bytes()
for P in PATCHES:
    blob = E.patch_blob(bank, P)
    APPLIED = ([d for (d, _) in leaves] + [1179, 1181, 1028, 1058]
               + [d for (d, _, _) in finefx(blob)])
    snaps = {}
    for tag, order in (('A-enum', ENUM_ORDER), ('B-port', APPLIED)):
        e = E.E2E(); e.build(48000.0); e.snap_all(); populate(e, blob)
        for u in range(9):
            for idx in order:
                try: e.dispatch(u, idx, R.rd_desc(e, idx))
                except RuntimeError: pass
        e.snap_all()
        snaps[tag] = [bytes(e.uc.mem_read(e.state[u], SZ)) for u in range(9)]
        del e
        print("  built %s" % tag, flush=True)
    tot = 0
    for u in range(9):
        A, B = snaps['A-enum'][u], snaps['B-port'][u]
        if A == B:
            print("patch %d unit %d: FULL STATE (0x%X bytes) IDENTICAL" % (P, u, SZ), flush=True)
            continue
        diffs = [o for o in range(0, SZ, 4) if A[o:o+4] != B[o:o+4]]
        tot += len(diffs)
        print("patch %d unit %d: %d differing 4-byte cells" % (P, u, len(diffs)), flush=True)
        for o in diffs[:40]:
            fa = struct.unpack('<f', A[o:o+4])[0]; fb = struct.unpack('<f', B[o:o+4])[0]
            print("    cell %9d  enum=%-14.7g port=%-14.7g" % (o, fa, fb))
        if len(diffs) > 40: print("    ... %d more" % (len(diffs)-40))
    print("patch %d TOTAL differing cells across all 9 units: %d" % (P, tot), flush=True)

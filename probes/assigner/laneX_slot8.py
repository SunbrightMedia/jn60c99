#!/usr/bin/env python3
"""Confirm by EXECUTION that the assigner's vtable slot at +8 -- the one the
host param entry 0x3C7AE0 calls with argument 4 after every parameter write --
is the onParameterChanged that caches ASSIGN MODE (800) / LEGATO (799)."""
import sys, struct
sys.path.insert(0, 'tools/verify')
import truth, e2e_emu as E, real_recall as R, recall_render_ab as RA

CW = ('/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/'
      '0e8b9cb5-Chillwave.bin')
bank = open(CW, 'rb').read()
leaves = R.leaf_table()
e = RA.prepare_recall(3, bank, leaves, E, R, 44100.0)

a = e.assign[0]
vptr = int.from_bytes(e.uc.mem_read(a, 8), 'little')
print("assigner[0] = 0x%X   vptr rva = 0x%X" % (a, vptr - E.IB))
for s in range(0, 4):
    fn = int.from_bytes(e.uc.mem_read(vptr + 8*s, 8), 'little')
    print("   slot %d (+%2d) -> rva 0x%X%s"
          % (s, 8*s, fn - E.IB, "   <== host calls THIS with arg 4" if s == 1 else ""))

slot1 = int.from_bytes(e.uc.mem_read(vptr + 8, 8), 'little')
print("\nbefore: mode=%d legato=%d" % (e.rd_i32(a+16), e.rd_i32(a+20)))
e.call(slot1, rcx=a, rdx=4)
print("after slot1(asg,4): mode=%d legato=%d" % (e.rd_i32(a+16), e.rd_i32(a+20)))
print("VERDICT: slot+8 %s the assigner refresh (0x3549B0 = %s)"
      % ("IS" if e.rd_i32(a+16) == 2 else "IS NOT", hex(slot1 - E.IB)))

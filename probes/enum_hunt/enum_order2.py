#!/usr/bin/env python3
import sys, struct
sys.path.insert(0, 'tools/verify')
import e2e_emu as E
from unicorn import UC_HOOK_CODE
from unicorn.x86_const import UC_X86_REG_RCX, UC_X86_REG_RDX

SETTER = E.IB + 0x3B9A30
ENUM   = E.IB + 0x3B48A0

e = E.E2E(); uc = e.uc
order, rcx0 = [], []
def hook(uc,a,s,u):
    if not rcx0: rcx0.append(uc.reg_read(UC_X86_REG_RCX))
    order.append(uc.reg_read(UC_X86_REG_RDX))
uc.hook_add(UC_HOOK_CODE, hook, begin=SETTER, end=SETTER)   # before build
e.build(48000.0)
proc = rcx0[0]
order.clear()
e.call(ENUM, rcx=proc, rdx=1, count=200_000_000)
print("enumerator dispatched %d setters" % len(order))
def firstpos(idx):
    try: return order.index(idx)
    except ValueError: return -1
for idx,name in [(779,'byte VCF cutoff'),(1029,'VCF CUTOFF FREQ H'),
                 (752,'byte LFO rate'),(878,'LFO RATE H'),
                 (1178,'DELAY TAP TIME'),(1058,'VCA vel sens')]:
    print("  idx %4d %-20s first-dispatch-pos=%d" % (idx,name,firstpos(idx)))
p779,p1029 = firstpos(779), firstpos(1029)
print("\n779 pos=%d  1029 pos=%d  => %s wins (dispatched last)" % (
    p779, p1029, ('1029/H' if p1029>p779 else '779/byte')))

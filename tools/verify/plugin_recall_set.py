#!/usr/bin/env python3
"""plugin_recall_set.py -- the plugin's OWN recall parameter set, self-proven.

The plugin's proc vtable slot 8 (rva 0x3B48A0) is its "apply patch params to the
engine" method: it reads each of a fixed list of internal indices via the value
getter (vtable +0x68) and dispatches them to the engine setter (vtable +0x58 =
0x3B9A30). Called with a2!=0 it uses the setter branch. Executing it under Unicorn
and hooking the setter reveals the EXACT recall index set -- the plugin's own
enumeration of which parameters a JUNO-60 patch recalls. No ear, no capture, no
Script.xml guessing: read straight off the setter it fires.

(On the DSP-only harness the value getter +0x68 is a stub -> value 0, so this is
the clear/init phase; its INDEX LIST is nonetheless the plugin's recall param set.
Per-patch VALUES come from the bank blob at the Script.xml positions.)

Result: 165 indices, incl front-panel 751-754,756-760 (DCO RANGE 760, PWM 758/759,
LFO 751-756) and extended 878,1028,1029,1058. The port's load_leaves (contiguous
761-813 + 830-877) DROPS 751-760 and over-includes the boundary indices -> both
wrong. Two-process rule: E2E/Unicorn only.
"""
import sys
sys.path.insert(0, 'tools/verify')
import e2e_emu as E
from unicorn import UC_HOOK_CODE
from unicorn.x86_const import UC_X86_REG_RCX, UC_X86_REG_RDX, UC_X86_REG_R9

SETTER = E.IB + 0x3B9A30
ENUM   = E.IB + 0x3B48A0     # proc vtable slot 8: apply-patch-params


def recall_indices():
    e = E.E2E(); uc = e.uc
    hits, rcx0 = [], []
    def hook(uc, a, s, u):
        if a != SETTER: return
        if not rcx0: rcx0.append(uc.reg_read(UC_X86_REG_RCX))
        hits.append((uc.reg_read(UC_X86_REG_RDX), uc.reg_read(UC_X86_REG_R9)))
    uc.hook_add(UC_HOOK_CODE, hook, begin=SETTER, end=SETTER)   # BEFORE build (JIT cache)
    e.build(48000.0)
    proc = rcx0[0]
    hits.clear()
    e.call(ENUM, rcx=proc, rdx=1, count=200_000_000)           # a2=1 -> setter branch
    return sorted({i for (i, v) in hits})


def main():
    idx = recall_indices()
    print("plugin recall param set (0x3B48A0): %d indices" % len(idx))
    fp = [i for i in idx if 750 <= i <= 760]
    print("front-panel 750-760 recalled:", fp, "(port DROPS 751-760 -> BUG)")
    print("extended recalled:", [i for i in idx if i in (878, 1028, 1029, 1058)])
    print("full set:", idx)


if __name__ == '__main__':
    main()

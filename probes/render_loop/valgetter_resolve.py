#!/usr/bin/env python3
"""Resolve the plugin's VALUE GETTER (proc vtable +104) that its own recall
enumerator (0x3B48A0) uses:  value = getter(proc, 0, idx);  setter(proc, idx, 1, value).
This getter is the ONLY step in the whole chain still reconstructed on our side
(the record-byte <-> dispatch-index POSITION MAP). Resolving + executing it turns
that map from cross-validated into PROVEN. Oracle-only."""
import sys, struct
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E

e = E.E2E(); e.build(48000.0)
uc = e.uc
rdq = lambda a: int.from_bytes(uc.mem_read(a, 8), 'little')
proc = e.proc[0]
vt = rdq(proc)
print("proc[0] = 0x%x   vtable = 0x%x (rva 0x%x)" % (proc, vt, vt - E.IB))
KNOWN = {0x3B9A30: 'ENGINE SETTER (used with flag)', 0x3B48A0: 'RECALL ENUMERATOR'}
for s in range(0, 160, 8):
    f = rdq(vt + s)
    if not (E.IB <= f < E.IB + E.IMGSZ):
        print("  +%-4d <non-code 0x%x>" % (s, f)); continue
    rva = f - E.IB
    tag = KNOWN.get(rva, '')
    mark = ''
    if s == 104: mark = '   <=== VALUE GETTER (enumerator reads values here)'
    if s == 88:  mark = '   <=== setter(idx, flag, value)'
    if s == 80:  mark = '   <=== setter(idx, value)'
    if s == 64:  mark = '   <=== slot8'
    print("  +%-4d rva 0x%-8X %s%s" % (s, rva, tag, mark))

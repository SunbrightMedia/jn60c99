#!/usr/bin/env python3
"""LANE E: raw disassembly of chosen rvas (IDA's decompile of the vtable slot-6
thunk is register-lossy)."""
import sys
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E
import capstone
uc = E.E2E().uc
md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_64)
for arg in sys.argv[1:]:
    rva, n = (arg.split(':') + ['96'])[:2]
    rva = int(rva, 16); n = int(n)
    code = bytes(uc.mem_read(E.IB + rva, n))
    print("=== rva 0x%X ===" % rva)
    for i in md.disasm(code, E.IB + rva):
        tgt = ''
        op = i.op_str
        if op.startswith('0x'):
            try:
                t = int(op, 16)
                if E.IB <= t < E.IB + E.IMGSZ: tgt = '   ; rva 0x%X' % (t - E.IB)
            except ValueError: pass
        print("  0x%-8X %-8s %s%s" % (i.address - E.IB, i.mnemonic, op, tgt))

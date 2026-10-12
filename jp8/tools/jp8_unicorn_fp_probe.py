#!/usr/bin/env python3
"""jp8_unicorn_fp_probe.py -- what the ORACLE's CPU does with the MXCSR's float modes (Unicorn, executed): DAZ (bit 6:
denormal inputs read as zero), FTZ (bit 15: denormal results stored as zero), the starting MXCSR, and whether an inexact
operation sets a sticky flag stmxcsr can read. The C runtime's models (jp8_cpu.h: the hardware build, JP8_SOFTFP 1 and 2)
are written against this; run it again on any other Unicorn.
    python3 jp8/tools/jp8_unicorn_fp_probe.py [--tooth]  (exit 0 = Unicorn 2.1.4's known answers; --tooth expects FTZ,
    as a CPU would: it must exit 1)"""
import struct, sys
import unicorn
from unicorn import Uc, UC_ARCH_X86, UC_MODE_64
from unicorn.x86_const import UC_X86_REG_RSP, UC_X86_REG_XMM0, UC_X86_REG_XMM1

OPS = {'mulss': 'f30f59c1', 'addss': 'f30f58c1'}
def run(mx, a, b, op):
    """ldmxcsr [rsp+8]; OP xmm0, xmm1; movss [rsp], xmm0; stmxcsr [rsp+16]: the stored result and the MXCSR after"""
    uc = Uc(UC_ARCH_X86, UC_MODE_64)
    uc.mem_map(0x1000, 0x1000); uc.mem_map(0x10000, 0x10000)
    code = bytes.fromhex('0fae542408' + OPS[op] + 'f30f110424' + '0fae5c2410')
    uc.mem_write(0x1000, code); uc.reg_write(UC_X86_REG_RSP, 0x18000)
    uc.mem_write(0x18008, struct.pack('<I', mx))
    uc.reg_write(UC_X86_REG_XMM0, a); uc.reg_write(UC_X86_REG_XMM1, b)
    uc.emu_start(0x1000, 0x1000 + len(code))
    m = uc.mem_read(0x18000, 20)
    return struct.unpack_from('<I', m, 0)[0], struct.unpack_from('<I', m, 16)[0]
def start_mxcsr():
    uc = Uc(UC_ARCH_X86, UC_MODE_64)
    uc.mem_map(0x1000, 0x1000); uc.mem_map(0x10000, 0x10000)
    uc.mem_write(0x1000, bytes.fromhex('0fae1c24')); uc.reg_write(UC_X86_REG_RSP, 0x18000)
    uc.emu_start(0x1000, 0x1004)
    return struct.unpack('<I', uc.mem_read(0x18000, 4))[0]
f = lambda x: struct.unpack('<I', struct.pack('<f', x))[0]
got = dict(start=start_mxcsr(),
           ftz=run(0x9FC0, f(1e-20), f(1e-20), 'mulss')[0],      # a denormal RESULT at FTZ | DAZ
           daz=run(0x9FC0, 0x00000100, f(1.0), 'mulss')[0],       # a denormal INPUT at FTZ | DAZ
           daz_off=run(0x9F80, 0x00000100, f(1.0), 'mulss')[0],   # the same input, DAZ off
           flags=run(0x9FC0, f(0.1), f(0.1), 'mulss')[1])        # MXCSR after an inexact product
want = dict(start=0x0, ftz=0x000116C2, daz=0x0, daz_off=0x00000100, flags=0x9FC0)
if '--tooth' in sys.argv[1:]:
    want['ftz'] = 0x0                                      # the answer an x86 CPU gives: must not hold here
print('unicorn %s' % unicorn.__version__)
print('  a thread starts at MXCSR 0x%x (Windows: 0x1F80 -- the emulators set it, playbooks 228 / 241)' % got['start'])
print('  FTZ: 1e-20f * 1e-20f at 0x9FC0 stores 0x%08x (%s)' % (got['ftz'], 'NOT flushed: no FTZ' if got['ftz'] else 'flushed'))
print('  DAZ: denormal 0x100 * 1.0 at 0x9FC0 -> 0x%08x, at 0x9F80 (DAZ off) -> 0x%08x' % (got['daz'], got['daz_off']))
print('  flags: MXCSR after an inexact mulss 0x%x (%s)' % (got['flags'], 'no sticky flag' if got['flags'] == 0x9FC0 else 'a flag set'))
bad = [k for k in want if got[k] != want[k]]
print('the known answers of Unicorn 2.1.4: %s' % ('ALL HOLD' if not bad else 'DIFFER in %s' % ', '.join(bad)))
sys.exit(1 if bad else 0)

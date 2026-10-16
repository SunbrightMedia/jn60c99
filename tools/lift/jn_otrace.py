#!/usr/bin/env python3
"""jn_otrace.py -- ORACLE instruction trace of ONE process() block, for the L5 render-path trace-diff. It boots the
JUNO host oracle (host_process_emu), then records (rva, rax, rcx, rdx, rbx, xmm0_lo32) for every image instruction of
process(64, note-on 60). Format == the lifted side's jp8_tr: '<IQQQQI' per instruction. The oracle stops at the
engine render (host_process_emu._on_render emu_stops at 0x3C7400), so the trace ends there -- the common prefix with
the lifted trace (which stops at its first unlifted target) diffs to the first divergent instruction. Unicorn only.
usage: python3 tools/lift/jn_otrace.py <out.bin> [ncap]"""
import sys
import os
import struct

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
sys.path.insert(0, os.path.join(REPO, 'probes', 'b6'))
os.environ.setdefault('JP8_EMU_QUIET', '1')
import host_process_emu as H                                       # noqa: E402
from unicorn import UC_HOOK_CODE                                   # noqa: E402
from unicorn.x86_const import (UC_X86_REG_RAX, UC_X86_REG_RCX, UC_X86_REG_RDX,   # noqa: E402
                               UC_X86_REG_RBX, UC_X86_REG_XMM0)
E = H.E
IB = E.IB
LO, HI = IB, IB + E.IMGSZ
ER = IB + 0x3C7400          # the engine render dispatch: stop the trace here (the prefix is the process() path we diff)


def main():
    out = open(sys.argv[1], 'wb')
    cap = int(sys.argv[2]) if len(sys.argv) > 2 else 4_000_000
    h = H.HostProcess()
    h.start(48000.0, 512)
    uc = h.uc
    n = [0]
    buf = bytearray()

    def rec(uc_, addr, size, ud):
        if not (LO <= addr < HI):
            return
        if addr == ER:                     # the render dispatch: record it, then stop (do not enter the composition)
            buf.extend(struct.pack('<IQQQQI', addr - IB, 0, 0, 0, 0, 0))
            uc_.emu_stop(); return
        rax = uc_.reg_read(UC_X86_REG_RAX); rcx = uc_.reg_read(UC_X86_REG_RCX)
        rdx = uc_.reg_read(UC_X86_REG_RDX); rbx = uc_.reg_read(UC_X86_REG_RBX)
        x = uc_.reg_read(UC_X86_REG_XMM0) & 0xFFFFFFFF
        buf.extend(struct.pack('<IQQQQI', addr - IB, rax & (2**64 - 1), rcx & (2**64 - 1), rdx & (2**64 - 1), rbx & (2**64 - 1), x))
        n[0] += 1
        if n[0] >= cap:
            uc_.emu_stop()
    uc.hook_add(UC_HOOK_CODE, rec, begin=LO, end=HI)
    try:
        h.process(64, events=[('on', 0, 0, 60, 0.8)], ctx=None)   # the render is served after the stop; ignore it
    except Exception as e:
        sys.stderr.write('process stopped (prefix kept): %s\n' % e)
    out.write(bytes(buf)); out.close()
    print('oracle trace: %d image instructions -> %s' % (n[0], sys.argv[1]))


if __name__ == '__main__':
    main()

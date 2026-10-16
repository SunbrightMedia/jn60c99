#!/usr/bin/env python3
"""thunk_roots.py -- extra lift roots for the JUNO host path: the ADJUSTOR / ILT THUNKS the plugin reaches by indirect
call. These tiny fragments ("add rcx, imm; jmp method" for a multiple-inheritance this-adjust, or a plain "jmp method")
live in the GAPS between .pdata functions, so they are not pdata function starts and the dynamic census does not always
record the indirect edge to them (a vtable slot holds the thunk's address). Without them the lifted host traps
("indirect target 0x... not lifted"). This scans every pdata gap for a thunk whose terminating jmp lands on an EXECUTED
instruction (a reached method), and prints those thunk entry rvas, comma-joined, for gen_juno_lift.sh to append to the
roots. Plumbing: it adds the plugin's own thunks to the lift; the oracle still grades every byte (L5).
usage: python3 tools/lift/thunk_roots.py <reach.json>      (prints 0xrva,0xrva,... to stdout)
"""
import sys
import os
import json
import bisect

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import truth                                                      # noqa: E402
import pefile                                                     # noqa: E402
import capstone                                                   # noqa: E402

IB = 0x180000000
MAXINS = 4                   # a thunk is 1-3 instructions; longer runs are not thunks


def main():
    reach = json.load(open(sys.argv[1]))
    executed = set(reach['executed']) if isinstance(reach.get('executed'), list) else None
    # the executed-instruction set lives in juno_executed.json next to the reach file
    exe_path = os.path.join(os.path.dirname(os.path.abspath(sys.argv[1])), 'juno_executed.json')
    executed = set(json.load(open(exe_path)))
    pe = pefile.PE(truth.VST3, fast_load=True)
    pe.parse_data_directories(directories=[pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_EXCEPTION']])
    starts = sorted(e.struct.BeginAddress for e in pe.DIRECTORY_ENTRY_EXCEPTION)
    ends = {e.struct.BeginAddress: e.struct.EndAddress for e in pe.DIRECTORY_ENTRY_EXCEPTION}
    text = [s for s in pe.sections if s.Name.startswith(b'.text')][0]
    CLO, CHI = text.VirtualAddress, text.VirtualAddress + text.Misc_VirtualSize
    IMG = pe.get_memory_mapped_image()
    md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_64)
    md.detail = True

    def dis(rva):
        return next(md.disasm(bytes(IMG[rva:rva + 16]), IB + rva), None)

    # the gaps between consecutive pdata functions (where thunks sit), plus a tail gap to the end of .text
    gaps = []
    for i in range(len(starts)):
        g0 = ends[starts[i]]
        g1 = starts[i + 1] if i + 1 < len(starts) else CHI
        if CLO <= g0 < g1 <= CHI and g1 - g0 >= 5:
            gaps.append((g0, g1))

    roots = []
    for g0, g1 in gaps:
        a = g0
        tstart = g0
        n = 0
        while a < g1:
            ins = dis(a)
            if ins is None:
                a += 1
                tstart = a
                n = 0
                continue
            m = ins.mnemonic
            if m == 'jmp' and ins.operands and ins.operands[0].type == capstone.x86.X86_OP_IMM:
                t = ins.operands[0].imm - IB
                if t in executed and CLO <= t < CHI:          # the jmp lands on a reached method
                    roots.append(tstart)
                a += ins.size
                tstart = a
                n = 0
                continue
            if m in ('ret', 'int3', 'nop') or m.startswith('j') or n + 1 >= MAXINS:
                a += ins.size
                tstart = a
                n = 0
                continue
            # an adjust (add/sub/lea/mov on the this pointer) before the jmp: keep the run going
            a += ins.size
            n += 1
    roots = sorted(set(roots))
    sys.stderr.write('thunk_roots: %d gaps, %d thunk entries rooted\n' % (len(gaps), len(roots)))
    print(','.join('%#x' % r for r in roots))


if __name__ == '__main__':
    main()

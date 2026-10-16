#!/usr/bin/env python3
"""jn_extra_roots.py -- the extra lift roots the host path needs beyond the pdata function starts, printed comma-joined
for gen_juno_lift.sh. Two kinds, both the plugin's own code reached by an indirect transfer that has no pdata entry of
its own, so they are not discovered as functions otherwise:
  1. ADJUSTOR / ILT THUNKS in the gaps between pdata functions (add rcx,imm; jmp method), whose jmp lands on an
     executed method -- the old thunk_roots scan.
  2. INTERIOR indirect-transfer targets: every target recorded in the census's indirect edges (call AND jmp sites,
     juno_lift_reach.py) that lies in .text but is NOT a pdata function start. These are functions with no pdata
     (shared unwind), reached only by an indirect call / tail jmp (e.g. 0x3c7c6f on the no-context process path,
     0x3b929f on the context path). Rooting each makes jp8_icall resolve it; it executes the same instructions.
Both are the plugin's own code; the oracle still grades every output word (L5).
usage: python3 tools/lift/jn_extra_roots.py <reach.json>      (prints 0xrva,... to stdout)"""
import sys
import os
import re
import json

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import truth                                                      # noqa: E402
import pefile                                                     # noqa: E402
import capstone                                                   # noqa: E402

IB = 0x180000000
MAXINS = 4


def main():
    reach = json.load(open(sys.argv[1]))
    exe_path = os.path.join(os.path.dirname(os.path.abspath(sys.argv[1])), 'juno_executed.json')
    executed = set(json.load(open(exe_path)))
    pe = pefile.PE(truth.VST3, fast_load=True)
    pe.parse_data_directories(directories=[pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_EXCEPTION']])
    starts = sorted(e.struct.BeginAddress for e in pe.DIRECTORY_ENTRY_EXCEPTION)
    pstarts = set(starts)
    ends = {e.struct.BeginAddress: e.struct.EndAddress for e in pe.DIRECTORY_ENTRY_EXCEPTION}
    text = [s for s in pe.sections if s.Name.startswith(b'.text')][0]
    CLO, CHI = text.VirtualAddress, text.VirtualAddress + text.Misc_VirtualSize
    IMG = pe.get_memory_mapped_image()
    md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_64)
    md.detail = True

    def dis(rva):
        return next(md.disasm(bytes(IMG[rva:rva + 16]), IB + rva), None)

    roots = set()

    # 1. adjustor / ILT thunks in the pdata gaps, jmp-to-executed
    gaps = []
    for i in range(len(starts)):
        g0 = ends[starts[i]]
        g1 = starts[i + 1] if i + 1 < len(starts) else CHI
        if CLO <= g0 < g1 <= CHI and g1 - g0 >= 5:
            gaps.append((g0, g1))
    for g0, g1 in gaps:
        a = g0
        tstart = g0
        n = 0
        while a < g1:
            ins = dis(a)
            if ins is None:
                a += 1; tstart = a; n = 0; continue
            m = ins.mnemonic
            if m == 'jmp' and ins.operands and ins.operands[0].type == capstone.x86.X86_OP_IMM:
                t = ins.operands[0].imm - IB
                if t in executed and CLO <= t < CHI:
                    roots.add(tstart)
                a += ins.size; tstart = a; n = 0; continue
            if m in ('ret', 'int3', 'nop') or m.startswith('j') or n + 1 >= MAXINS:
                a += ins.size; tstart = a; n = 0; continue
            a += ins.size; n += 1
    nthunk = len(roots)

    # 2. interior indirect-transfer targets (call AND jmp edges) that are in .text but not pdata starts
    for v in reach.get('indirect', {}).values():
        for x in v:
            t = int(x, 16)
            if CLO <= t < CHI and t not in pstarts:
                roots.add(t)

    # 3. every rva the host glue CALLS DIRECTLY (lift/jn_entries.h, one source of truth): only the glue calls some of
    #    them, and some are leaves with no pdata (CC_LEARN 0x31AA40, the commit's 0x2853C0), so rules 1-2 miss them
    ent = open(os.path.join(REPO, 'lift', 'jn_entries.h')).read()
    nent = 0
    for m in re.finditer(r'#define\s+JN_RVA_\w+\s+0x([0-9A-Fa-f]+)ULL', ent):
        t = int(m.group(1), 16)
        if not CLO <= t < CHI:
            sys.exit('jn_extra_roots: lift/jn_entries.h entry 0x%x is outside .text' % t)
        roots.add(t); nent += 1
    if not nent:
        sys.exit('jn_extra_roots: no JN_RVA_* entry in lift/jn_entries.h')

    roots = sorted(roots)
    sys.stderr.write('jn_extra_roots: %d gaps, %d thunks, %d host entries, %d total extra roots (incl. interior '
                     'indirect targets)\n' % (len(gaps), nthunk, nent, len(roots)))
    print(','.join('%#x' % r for r in roots))


if __name__ == '__main__':
    main()

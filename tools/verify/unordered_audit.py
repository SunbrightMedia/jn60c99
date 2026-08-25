#!/usr/bin/env python3
"""unordered_audit.py -- find every float compare whose NaN behaviour the
decompiler may have transcribed wrongly (playbook 81).

x86 comiss/ucomiss set CF=ZF=PF=1 when either operand is NaN. So:
    ja / jae  are NOT taken on unordered  -> the fall-through path runs on NaN
    jb / jbe  ARE  taken on unordered
Hex-Rays renders `comiss; ja skip` as `if (x <= y) ...`, but C's `<=` is FALSE
on NaN while the asm's fall-through RUNS. The two agree on every ordered input
and differ only on NaN -- invisible to any gate whose states are NaN-free.

This tool lists every (compare, jump) pair in a function so each one can be
checked against its C transcription. Sites marked RISK are those where the
decompiler's natural operator has the WRONG NaN behaviour and the C must be
written in negated form, e.g. !(x > y) instead of x <= y.

usage: unordered_audit.py <vst3> <rva_hex> [length_hex]
"""
import sys
import pefile, capstone

RISK = {'ja': '!(x > y)', 'jae': '!(x >= y)', 'jnbe': '!(x > y)', 'jnb': '!(x >= y)'}
SAFE = {'jb', 'jbe', 'jnae', 'jna', 'jp', 'jnp'}


def main():
    path = sys.argv[1]
    rva = int(sys.argv[2], 16)
    ln = int(sys.argv[3], 16) if len(sys.argv) > 3 else 0xC000
    img = pefile.PE(path).get_memory_mapped_image()
    md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_64)
    insns = list(md.disasm(bytes(img[rva:rva + ln]), rva))
    risk = safe = other = 0
    rows = []
    for i, ins in enumerate(insns):
        if ins.mnemonic not in ('comiss', 'ucomiss', 'comisd', 'ucomisd'):
            continue
        # the next conditional jump within a short window is this compare's user
        for j in range(i + 1, min(i + 12, len(insns))):
            m = insns[j].mnemonic
            if m.startswith('j') and m != 'jmp':
                if m in RISK:
                    risk += 1
                    rows.append((ins.address, insns[j].address, m, RISK[m]))
                elif m in SAFE:
                    safe += 1
                else:
                    other += 1
                    rows.append((ins.address, insns[j].address, m, '(check)'))
                break
    print("function 0x%X: %d compares -> RISK %d, safe-on-unordered %d, other %d"
          % (rva, risk + safe + other, risk, safe, other))
    print("RISK = the fall-through RUNS on NaN; C must be written negated.\n")
    for c, j, m, form in rows:
        print("   compare @0x%X  jump @0x%X  %-5s  C must be %s" % (c, j, m, form))
    return 0


if __name__ == '__main__':
    sys.exit(main())

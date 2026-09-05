#!/usr/bin/env python3
"""abi_check.py -- PROVE the calling convention of an oracle entry point
before the harness calls it (METHOD_PLAYBOOK 87: the JX harness passed the
sample rate in RDX; the callee read a FLOAT from XMM1; every gate stayed
green while the engine had no sample rate).

For each (name, rva) the tool disassembles the function head and reports
every argument location that is READ BEFORE IT IS WRITTEN:
  rcx rdx r8 r9         integer/pointer args 1-4 (Win64)
  xmm0 xmm1 xmm2 xmm3   float/double args 1-4 (and whether ss or sd)
  [rsp+0x28..]          stack args 5+
plus the width of the first xmm use (movss/ucomiss = float, movsd/comisd =
double). A harness call that fills a different register than the one read
here is WRONG, whatever the gate says.

usage: abi_check.py <pe-file> NAME=rva [NAME=rva ...]
       abi_check.py --json <pe-file> ...     (machine-readable ledger)
Exit 1 if any entry reads an arg the harness convention does not name.
"""
import sys, json, re
import pefile, capstone
from capstone import x86

INT_ARGS = {"rcx": "arg1", "rdx": "arg2", "r8": "arg3", "r9": "arg4"}
SUBREG = {
    "ecx": "rcx", "cx": "rcx", "cl": "rcx",
    "edx": "rdx", "dx": "rdx", "dl": "rdx",
    "r8d": "r8", "r8w": "r8", "r8b": "r8",
    "r9d": "r9", "r9w": "r9", "r9b": "r9",
}
XMM_ARGS = {"xmm0": "farg1", "xmm1": "farg2", "xmm2": "farg3", "xmm3": "farg4"}
FLOAT_OPS = ("ss", "ps")
DOUBLE_OPS = ("sd", "pd")


def analyze(img, ib, rva, max_ins=60):
    md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_64)
    md.detail = True
    read, written = {}, set()
    stack_args = set()
    frame = 0                      # bytes pushed/subtracted below the return address
    n = 0
    for ins in md.disasm(bytes(img[rva:rva + 0x400]), ib + rva):
        n += 1
        if n > max_ins or ins.mnemonic in ("ret", "jmp"):
            break
        if ins.mnemonic == "push":
            frame += 8
        elif ins.mnemonic == "sub" and ins.op_str.startswith("rsp,"):
            frame += ins.operands[1].imm
        regs_r, regs_w = ins.regs_access()
        names_r = [ins.reg_name(r) for r in regs_r]
        names_w = [ins.reg_name(r) for r in regs_w]
        # xorps/pxor/xor reg,reg is a zeroing WRITE, not a read of the arg
        if ins.mnemonic in ("xorps", "pxor", "xor", "xorpd") and \
           len(ins.operands) == 2 and ins.op_str.split(", ")[0] == ins.op_str.split(", ")[1]:
            names_r = []
        for nm in names_r:
            base = SUBREG.get(nm, nm)
            if base in INT_ARGS and base not in written and base not in read:
                read[base] = ("0x%x" % (ins.address - ib), ins.mnemonic)
            if base in XMM_ARGS and base not in written and base not in read:
                width = ("float" if ins.mnemonic.endswith(FLOAT_OPS)
                         else "double" if ins.mnemonic.endswith(DOUBLE_OPS)
                         else "?")
                read[base] = ("0x%x" % (ins.address - ib), ins.mnemonic, width)
        # stack args: [rsp + 0x28 + 8k] read before the prologue moves rsp
        for op in ins.operands:
            if op.type == x86.X86_OP_MEM and ins.reg_name(op.mem.base) == "rsp" \
               and op.mem.disp >= frame + 0x28 and (op.access & capstone.CS_AC_READ):
                stack_args.add("[rsp+0x%x] = stack arg %d"
                               % (op.mem.disp, 5 + (op.mem.disp - frame - 0x28) // 8))
        for nm in names_w:
            base = SUBREG.get(nm, nm)
            if base in INT_ARGS or base in XMM_ARGS:
                if base not in read:
                    written.add(base)
    return read, sorted(stack_args)


def main():
    argv = sys.argv[1:]
    as_json = False
    if argv and argv[0] == "--json":
        as_json = True; argv = argv[1:]
    if len(argv) < 2:
        raise SystemExit(__doc__)
    pe = pefile.PE(argv[0])
    ib = pe.OPTIONAL_HEADER.ImageBase
    img = pe.get_memory_mapped_image()
    ledger = {}
    for spec in argv[1:]:
        name, rva = spec.split("=")
        rva = int(rva, 16)
        read, stack = analyze(img, ib, rva)
        ledger[name] = {"rva": "0x%x" % rva,
                        "reads": {k: list(v) for k, v in read.items()},
                        "stack_args": stack}
        if not as_json:
            print("%-10s rva 0x%06x" % (name, rva))
            for k in ("rcx", "rdx", "r8", "r9", "xmm0", "xmm1", "xmm2", "xmm3"):
                if k in read:
                    v = read[k]
                    extra = ("  (%s)" % v[2]) if len(v) > 2 else ""
                    print("   %-5s %-6s read at %s by %s%s"
                          % (k, INT_ARGS.get(k, XMM_ARGS.get(k)), v[0], v[1], extra))
            for s in stack:
                print("   %s (stack arg)" % s)
    if as_json:
        print(json.dumps(ledger, indent=1))


if __name__ == "__main__":
    main()

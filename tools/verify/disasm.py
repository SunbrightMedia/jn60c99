#!/usr/bin/env python3
"""disasm.py -- print the JUNO plugin's own machine code for an rva range.

The binary is resolved ONLY through the checksummed truth path used by
e2e_emu, so what this prints is ground truth, not a stale dump.

usage: disasm.py <rva_hex> [n_bytes=256]
       disasm.py --cmp <rva_hex> [n_bytes=256]     only compare/jump pairs

--cmp is the playbook-81 view: every (u)comiss/(u)comisd immediately followed
by a conditional jump, with the UNORDERED behaviour of that jump spelled out.
  ja / jae   NOT taken when unordered  -> C must be !(x > y) / !(x >= y)
  jb / jbe   IS taken when unordered   -> C's x < y / x <= y is correct
  jne        NOT taken when unordered  -> C needs ORDERED-AND-UNEQUAL
  je         IS taken when unordered   -> C's x == y is NOT equivalent
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import e2e_emu as E
import capstone

UNORDERED = {
    "ja":  ("NOT taken", "C must be !(x > y)"),
    "jae": ("NOT taken", "C must be !(x >= y)"),
    "jnbe": ("NOT taken", "C must be !(x > y)"),
    "jnb": ("NOT taken", "C must be !(x >= y)"),
    "jb":  ("IS taken", "C's x < y is correct"),
    "jbe": ("IS taken", "C's x <= y is correct"),
    "jne": ("NOT taken", "C needs ORDERED-AND-UNEQUAL: (x<y||x>y)"),
    "je":  ("IS taken", "C's x == y is NOT equivalent"),
    "jp":  ("IS taken", "parity: an explicit NaN test"),
    "jnp": ("NOT taken", "parity: an explicit NaN test"),
}


def main():
    args = [a for a in sys.argv[1:] if a != "--cmp"]
    only_cmp = "--cmp" in sys.argv
    rva = int(args[0], 16)
    n = int(args[1], 0) if len(args) > 1 else 256

    e = E.E2E()
    code = bytes(e.uc.mem_read(E.IB + rva, n))
    md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_64)
    ins = list(md.disasm(code, E.IB + rva))

    if not only_cmp:
        for i in ins:
            print("%06X  %-20s %s %s" % (i.address - E.IB, i.bytes.hex(),
                                         i.mnemonic, i.op_str))
        return

    # The jump is NOT always the next instruction: the compiler schedules
    # flag-preserving work between the compare and its branch. In juno_ramp a
    # `movss` sat in that gap, and a next-instruction-only scan missed the
    # site entirely -- one of the four real defects lived there. Skip forward
    # over instructions that cannot touch EFLAGS.
    FLAG_SAFE = ("mov", "movss", "movsd", "movaps", "movapd", "movd", "movq",
                 "lea", "nop", "movzx", "movsx", "movsxd", "xorps", "xorpd",
                 "cvtdq2ps", "cvtsi2ss", "push", "pop")

    def find_jump(idx):
        for k in range(idx + 1, min(idx + 6, len(ins))):
            m = ins[k].mnemonic
            if m.startswith("j"):
                return ins[k]
            if m.startswith("set"):
                return ins[k]
            if not m.startswith(FLAG_SAFE):
                return None       # flags clobbered before any branch
        return None

    n_risk = 0
    n_cmp = 0
    for idx, a in enumerate(ins):
        if not a.mnemonic.startswith(("comis", "ucomis")):
            continue
        n_cmp += 1
        b = find_jump(idx)
        if b is None:
            print("%06X  %s %s   -> no branch within 5 insns (flags consumed "
                  "elsewhere or dead compare)" % (a.address - E.IB,
                                                  a.mnemonic, a.op_str))
            continue
        beh = UNORDERED.get(b.mnemonic)
        if beh is None:
            print("%06X  %s %s  -> %s %s   [jump not classified]"
                  % (a.address - E.IB, a.mnemonic, a.op_str,
                     b.mnemonic, b.op_str))
            continue
        risk = beh[0] == "NOT taken"
        n_risk += risk
        print("%06X  %s %s ; %s   unordered: %-9s  %s%s"
              % (a.address - E.IB, a.mnemonic, a.op_str, b.mnemonic,
                 beh[0], beh[1], "   <== RISK" if risk else ""))
    print("-- %d compares, %d at RISK of a naive C transcription" % (n_cmp, n_risk))


if __name__ == "__main__":
    main()

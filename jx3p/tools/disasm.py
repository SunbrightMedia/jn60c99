#!/usr/bin/env python3
"""disasm.py -- print the JX plugin's own machine code for an rva range.

Transcription tool. The binary is resolved ONLY through tools/verify/truth.py
(checksummed), so what this prints is ground truth, not a stale dump.

usage: disasm.py <rva_hex> [n_bytes=512]
"""
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                "..", "..", "tools", "verify"))
import jx_emu as J
import capstone


def main():
    rva = int(sys.argv[1], 16)
    n = int(sys.argv[2], 0) if len(sys.argv) > 2 else 512
    jx = J.JX().build()
    code = bytes(jx.uc.mem_read(J.IB + rva, n))
    md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_64)
    md.detail = False
    for i in md.disasm(code, J.IB + rva):
        print("%06X  %-22s %s %s" % (i.address - J.IB,
                                     i.bytes.hex(), i.mnemonic, i.op_str))


if __name__ == "__main__":
    main()

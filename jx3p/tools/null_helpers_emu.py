#!/usr/bin/env python3
"""null_helpers_emu.py -- Unicorn reference for the 5 voice helpers over an input
sweep. Writes <outdir>/helper_<rva>.bin: rows of (input_bits..., output_bits).
Two-process rule: no ctypes here."""
import sys, os, struct
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "tools", "verify"))
import jx_emu as J
from unicorn.x86_const import *

IB = J.IB
# sweep of representative inputs (floats seen in the render + edge cases)
FS = [(-4.0 + 0.013*k) for k in range(700)] + [0.0,-0.0,1.0,-1.0,0.5,-0.5]
IS = list(range(-34, 35))

def call_ff(jx, fn, xmm0_f, xmm1_or_int=None, is_int=False):
    uc = jx.uc
    rsp = (J.STACK_BASE+J.STACK_SIZE-0x10000) & ~0xF; rsp -= 8
    uc.reg_write(UC_X86_REG_RSP, rsp)
    uc.reg_write(UC_X86_REG_XMM0, struct.unpack('<Q', struct.pack('<f', xmm0_f)+b'\0\0\0\0')[0])
    if xmm1_or_int is not None:
        if is_int: uc.reg_write(UC_X86_REG_EDX, xmm1_or_int & 0xFFFFFFFF)
        else: uc.reg_write(UC_X86_REG_XMM1, struct.unpack('<Q', struct.pack('<f', xmm1_or_int)+b'\0\0\0\0')[0])
    RET = J.BUF_BASE + 0x8000; uc.mem_write(rsp, struct.pack('<Q', RET))
    uc.emu_start(fn, RET, count=2_000_000)
    assert uc.reg_read(UC_X86_REG_RIP) == RET
    return uc.reg_read(UC_X86_REG_XMM0) & 0xFFFFFFFF

def call_dd(jx, fn, xmm0_d):
    uc = jx.uc
    rsp = (J.STACK_BASE+J.STACK_SIZE-0x10000) & ~0xF; rsp -= 8
    uc.reg_write(UC_X86_REG_RSP, rsp)
    uc.reg_write(UC_X86_REG_XMM0, struct.unpack('<Q', struct.pack('<d', xmm0_d))[0])
    RET = J.BUF_BASE + 0x8000; uc.mem_write(rsp, struct.pack('<Q', RET))
    uc.emu_start(fn, RET, count=2_000_000)
    assert uc.reg_read(UC_X86_REG_RIP) == RET
    return uc.reg_read(UC_X86_REG_XMM0)  # low 64 = double bits

def main():
    outdir = sys.argv[1]; os.makedirs(outdir, exist_ok=True)
    jx = J.JX()
    jx.uc.reg_write(UC_X86_REG_MXCSR, 0x9FC0)   # FTZ|DAZ, mask all -- match render env
    # 39A250(float result, int a2) -> float
    rows = []
    for f in FS:
        for i in IS:
            o = call_ff(jx, IB+0x39A250, f, i, is_int=True)
            rows.append(struct.pack('<fiI', f, i, o))
    open(os.path.join(outdir, "helper_39A250.bin"), "wb").write(b"".join(rows))
    # 3A2180(float)->float, 3A2210(float)->float, 3A9950(float)->float
    for rva in (0x3A2180, 0x3A2210, 0x3A9950, 0x3A21E0):
        rows = []
        for f in FS:
            o = call_ff(jx, IB+rva, f)
            rows.append(struct.pack('<fI', f, o))
        open(os.path.join(outdir, "helper_%X.bin" % rva), "wb").write(b"".join(rows))
    # 3A2010(double)->double
    DS = [(-21.0 + 0.01*k) for k in range(3100)]   # dense over all 29 rows [-20,8.9] + clamp edges
    rows = []
    for d in DS:
        o = call_dd(jx, IB+0x3A2010, d)
        rows.append(struct.pack('<dQ', d, o))
    open(os.path.join(outdir, "helper_3A2010.bin"), "wb").write(b"".join(rows))
    print("emu helper refs written:", os.listdir(outdir))

if __name__ == "__main__":
    main()

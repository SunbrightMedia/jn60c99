#!/usr/bin/env python3
"""null_voice_emu.py -- ORACLE side of the voice-arm null gate (process A).

Two-process rule (CLAUDE.md): Unicorn and the ctypes-loaded C engine never share
a process; they meet only through files. This side:
  1. builds the JX instance, SETSR 44100, note-on, renders WARM blocks so the
     state is musically active;
  2. snapshots each voice's state region (SNAP bytes);
  3. calls the ORIGINAL per-voice arm clone directly, N single samples,
     recording every output pair and the final state region;
  4. writes state_in / outs / state_ref per voice under the scratch dir.

usage: null_voice_emu.py <outdir> [nsamples=32] [warmblocks=6]
"""
import sys, os, struct
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "tools", "verify"))
import jx_emu as J

ARMS = [0x3A22C0,0x3A99B0,0x3B1040,0x3B86D0,0x3BFD60,0x3C73F0,0x3CEA80,0x3D6110]
SNAP = 0x60000
NOTEON = 0x3F9150; SETSR = 0x3F9970

def main():
    outdir = sys.argv[1]
    n = int(sys.argv[2]) if len(sys.argv) > 2 else 32
    warm = int(sys.argv[3]) if len(sys.argv) > 3 else 6
    os.makedirs(outdir, exist_ok=True)
    jx = J.JX().build()
    jx.set_ftz()          # match the plugin's FTZ|DAZ FP env (0x9FC0) -- the
                          # reference must be computed in the same env the C uses.
    uc = jx.uc
    # SETSR(HOST, 44100.0f)
    rsp = (J.STACK_BASE+J.STACK_SIZE-0x10000) & ~0xF; rsp -= 8
    uc.reg_write(J.UC_X86_REG_RSP, rsp); uc.reg_write(J.UC_X86_REG_RCX, jx.HOST)
    uc.reg_write(J.UC_X86_REG_XMM1, struct.unpack('<Q', struct.pack('<f',44100.0)+b'\0\0\0\0')[0])
    RET = J.SCRATCH+0x5000; uc.mem_write(rsp, struct.pack('<Q', RET))
    uc.emu_start(J.IB+SETSR, RET)
    jx.call(J.IB+NOTEON, rcx=jx.HOST, rdx=60, r8=100)
    for _ in range(warm):
        jx.render(256)
    # out pair cells in the mapped BUF region: pairptr -> {outM, outS}
    PAIR = J.BUF_BASE + 0x100; OUTM = J.BUF_BASE + 0x200; OUTS = J.BUF_BASE + 0x204
    uc.mem_write(PAIR, struct.pack('<QQ', OUTM, OUTS))
    def rq(a): return int.from_bytes(uc.mem_read(a, 8), 'little')
    def rd(a): return uc.mem_read(a, 4)
    for v, arm in enumerate(ARMS):
        st = jx.state[v]
        open(os.path.join(outdir, "state_in_%d.bin" % v), "wb").write(bytes(uc.mem_read(st, SNAP)))
        # cross-object linkage the arm reads through st+136 (the shared "common"
        # object): v290 = *(*(obj+40)), v725 = *(*(obj+64)). Capture obj bytes +
        # the two indirect DWORDs so the C side can relocate the chain natively.
        obj = rq(st + 136)
        objbytes = bytes(uc.mem_read(obj, 256))
        p40 = rq(obj + 40); p64 = rq(obj + 64)
        d40 = bytes(rd(p40)); d64 = bytes(rd(p64))
        open(os.path.join(outdir, "link_%d.bin" % v), "wb").write(objbytes + d40 + d64)
        outs = []
        for s in range(n):
            uc.mem_write(OUTM, b"\x00"*8)
            jx.call(J.IB+arm, rcx=st, rdx=PAIR)
            m = struct.unpack('<I', uc.mem_read(OUTM,4))[0]
            sb = struct.unpack('<I', uc.mem_read(OUTS,4))[0]
            outs.append((m, sb))
        open(os.path.join(outdir, "outs_%d.bin" % v), "wb").write(
            b"".join(struct.pack('<II', m, s) for m, s in outs))
        open(os.path.join(outdir, "state_ref_%d.bin" % v), "wb").write(bytes(uc.mem_read(st, SNAP)))
        nz = sum(1 for m, s in outs if m or s)
        print("voice %d: %d samples, %d nonzero-out, faults=%d" % (v, n, nz, jx.faults))
    print("EMU REFERENCE WRITTEN to %s" % outdir)

if __name__ == "__main__":
    main()

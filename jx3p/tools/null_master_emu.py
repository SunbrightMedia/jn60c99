#!/usr/bin/env python3
"""null_master_emu.py -- ORACLE side of the master-render null gate.

Master render sub_18039A2B0(a1=state8, a2=16 voice-output ptrs, a3=L/R out) is a
single unit. It reads the 8 voice MAIN outputs (a2 offsets 0,16,..,112) and
writes L/R. Two-process rule: writes files only.

Flow: build, SETSR, note-on, warm (render voices+master via cleared latch),
snapshot master state_in, then for N samples capture the 16 voice-output floats
fed to the master AND run the master directly, recording L/R out + final state.
"""
import sys, os, struct
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "tools", "verify"))
import jx_emu as J

SNAP = 0xAAD000
NOTEON = 0x3F9150; SETSR = 0x3F9970; MASTER = 0x39A2B0

def main():
    outdir = sys.argv[1]; n = int(sys.argv[2]) if len(sys.argv) > 2 else 32
    warm = int(sys.argv[3]) if len(sys.argv) > 3 else 6
    os.makedirs(outdir, exist_ok=True)
    jx = J.JX().build(); jx.set_ftz(); uc = jx.uc
    rsp = (J.STACK_BASE+J.STACK_SIZE-0x10000) & ~0xF; rsp -= 8
    uc.reg_write(J.UC_X86_REG_RSP, rsp); uc.reg_write(J.UC_X86_REG_RCX, jx.HOST)
    uc.reg_write(J.UC_X86_REG_XMM1, struct.unpack('<Q', struct.pack('<f',44100.0)+b'\0\0\0\0')[0])
    RET = J.SCRATCH+0x5000; uc.mem_write(rsp, struct.pack('<Q',RET)); uc.emu_start(J.IB+SETSR, RET)
    jx.call(J.IB+NOTEON, rcx=jx.HOST, rdx=60, r8=100)
    st8 = jx.state[8]
    # clear master warmup latch + enable, so the master DSP runs
    uc.mem_write(st8+11191048, b'\x00\x00\x00\x00'); uc.mem_write(st8+20, b'\x01')

    # buffers: 8 voice main/sub, a2 (16 ptrs), L/R out
    BUF = J.BUF_BASE; p = BUF; off = {}
    for v in range(8):
        off[('m',v)] = p; p += 16
        off[('s',v)] = p; p += 16
    A2 = p; p += 16*8
    OUTL = p; p += 8; OUTR = p; p += 8; A3 = p; p += 16
    a2blob = b"".join(struct.pack('<Q',x) for pair in
                      ((off[('m',v)],off[('s',v)]) for v in range(8)) for x in pair)
    uc.mem_write(A2, a2blob); uc.mem_write(A3, struct.pack('<QQ', OUTL, OUTR))

    def render_voices_one():
        for v in range(8):
            uc.mem_write(J.PB_VOICE, struct.pack("<QQQQQ", jx.state[v], v, off[('m',v)], off[('s',v)], 1))
            jx._run(jx.SVOICE)
    def run_master():
        jx.call(J.IB+MASTER, rcx=st8, rdx=A2, r8=A3)

    # warm
    for _ in range(warm*64):
        render_voices_one(); run_master()

    open(os.path.join(outdir, "mstate_in.bin"), "wb").write(bytes(uc.mem_read(st8, SNAP)))
    # cross-object link the master reads through st+136 (note object): v31 =
    # *(*(obj+136)), v490 = *(obj+112). Capture obj + the two indirect targets so
    # the C side can relocate them natively (same pattern as the voice link).
    def rq(a): return int.from_bytes(uc.mem_read(a,8),'little')
    mobj = rq(st8+136)
    mobjbytes = bytes(uc.mem_read(mobj,256))
    p136 = rq(mobj+136); p112 = rq(mobj+112)
    d136 = bytes(uc.mem_read(p136,4))
    # obj+112 target: v490 is a _DWORD*; capture a page of what it points at
    d112 = bytes(uc.mem_read(p112,256))
    open(os.path.join(outdir, "mlink.bin"), "wb").write(mobjbytes + d136 + d112)
    outs = []; vins = []
    for s in range(n):
        render_voices_one()
        # capture the 16 voice-output floats a2 points at (main+sub per voice)
        vin = []
        for v in range(8):
            vin.append(struct.unpack('<I', uc.mem_read(off[('m',v)],4))[0])
            vin.append(struct.unpack('<I', uc.mem_read(off[('s',v)],4))[0])
        vins.append(vin)
        run_master()
        outs.append((struct.unpack('<I',uc.mem_read(OUTL,4))[0],
                     struct.unpack('<I',uc.mem_read(OUTR,4))[0]))
    open(os.path.join(outdir, "mouts.bin"), "wb").write(
        b"".join(struct.pack('<II', l, r) for l, r in outs))
    open(os.path.join(outdir, "mvins.bin"), "wb").write(
        b"".join(struct.pack('<16I', *vin) for vin in vins))
    open(os.path.join(outdir, "mstate_ref.bin"), "wb").write(bytes(uc.mem_read(st8, SNAP)))
    nz = sum(1 for l, r in outs if l or r)
    print("master: %d samples, %d nonzero-out, faults=%d" % (n, nz, jx.faults))
    print("MASTER EMU REFERENCE WRITTEN to %s" % outdir)

if __name__ == "__main__":
    main()

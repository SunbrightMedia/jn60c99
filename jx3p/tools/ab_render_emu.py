#!/usr/bin/env python3
"""ab_render_emu.py -- ORACLE side of the INTEGRATION render A/B (process A).

The seam gate: recall (proven) + note-on (oracle, untranscribed) + the FULL
per-sample chain (8 voice arms + master) over REAL recalled patches. For each
patch in the set:
  1. fresh build, SETSR 44100, recall via the proven active-pool dispatch,
     note-on(60,100), warm W blocks (state musically active);
  2. snapshot all 8 voice states (SNAP_V) + master state (SNAP_M) + the
     cross-object links each renderer follows;
  3. render N single samples through the plugin's OWN arms + master,
     capturing per-sample: 16 voice-output words fed to the master and L/R;
  4. write everything under <outdir>/p<patch>/ for the ctypes side.

This is the gate that finally EXERCISES the master's 11 argless placeholder
sites: mode-selecting patches route into them, and the C side must then null
or fail loudly per patch -- the failure list IS the remaining work list.

usage: ab_render_emu.py <outdir> [patches=0,5,20,49] [n=32] [warm=6]
"""
import sys, os, struct
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "tools", "verify"))
import jx_emu as J

BANK = os.path.join(J.REPO, "jx3p", "truth", "preset_bank_1.bin")
HEADER = 23; STRIDE = 20223; BLOB_OFF = 16
SNAP_V = 0x60000
SNAP_M = 0xAAD000
NOTEON = 0x3F9150; SETSR = 0x3F9970; MASTER = 0x39A2B0
ARMS = [0x3A22C0,0x3A99B0,0x3B1040,0x3B86D0,0x3BFD60,0x3C73F0,0x3CEA80,0x3D6110]
ACTIVE = [10, 11, 12, 13, 14, 16, 17, 19, 20, 22, 24, 25, 26, 28, 29, 30, 31,
          36, 39, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55,
          56, 57, 58, 59, 60, 61, 63, 70, 90, 115, 116, 117, 118, 119, 120,
          121, 123, 133, 134, 135, 136, 137, 138]

def decode(blob, pool):
    p = 2 * pool + 8
    return ((blob[p] & 0xF) << 4) | (blob[p + 1] & 0xF)

def run_patch(outdir, patch, n, warm, bank, sr=44100.0):
    jx = J.JX().build(); jx.set_ftz(); uc = jx.uc
    rsp = (J.STACK_BASE+J.STACK_SIZE-0x10000) & ~0xF; rsp -= 8
    uc.reg_write(J.UC_X86_REG_RSP, rsp); uc.reg_write(J.UC_X86_REG_RCX, jx.HOST)
    uc.reg_write(J.UC_X86_REG_XMM1, struct.unpack('<Q', struct.pack('<f',float(sr))+b'\0\0\0\0')[0])
    RET = J.SCRATCH+0x5000; uc.mem_write(rsp, struct.pack('<Q',RET)); uc.emu_start(J.IB+SETSR, RET)
    # RECALL: the proven sequence -- active pools in order, dispatched per UNIT
    # (all 9 procs; the plugin's own recall touches every unit's proc).
    rec = bank[HEADER + patch * STRIDE:]; blob = rec[BLOB_OFF:]
    for u in range(J.N_UNITS):
        for pool in ACTIVE:
            jx.dispatch(u, pool + 740, decode(blob, pool))
    jx.call(J.IB+NOTEON, rcx=jx.HOST, rdx=60, r8=100)
    st8 = jx.state[8]
    uc.mem_write(st8+11191048, b'\x00\x00\x00\x00'); uc.mem_write(st8+20, b'\x01')
    for _ in range(warm):
        jx.render(256)

    # ---- SEED NaN REPORT (2026-08-25, downgraded from a hard tooth) ----
    # This started as a tooth that FAILED on any NaN in the snapshot, because a
    # NaN-bearing seed looked like an invalid start state. Investigation proved
    # otherwise, and the tooth was wrong to fail:
    #   * the NaN is produced by the PLUGIN's own render, not by the harness
    #     (state is clean through BUILD/SETSR/RECALL/NOTE-ON; NaN appears in the
    #     first rendered block and grows ~3 cells per sample);
    #   * the plugin never computes with those cells -- hooking every read
    #     showed one site, an INTEGER `mov` shuffling a word along a ring;
    #   * the plugin CLAMPS them at the output, and the port failed to only
    #     because of an unordered-compare mistranscription, now fixed
    #     (docs/NAN_SEMANTICS_SCOPE.md, playbook 81).
    # So a NaN-bearing seed is a REAL state the plugin produces, and refusing to
    # gate it would hide the very defect it helped find. The count is reported
    # for visibility; set JX_FAIL_ON_NAN_SEED=1 to make it fatal again.
    def _nan_count(buf):
        n = 0
        for _o in range(0, len(buf) - 3, 4):
            _b = buf[_o:_o + 4]
            if (_b[3] & 0x7F) == 0x7F and (_b[2] & 0x80) and \
               (_b[0] or _b[1] or (_b[2] & 0x7F)):
                n += 1
        return n
    _nm = _nan_count(bytes(uc.mem_read(st8, SNAP_M)))
    _nv = sum(_nan_count(bytes(uc.mem_read(jx.state[_v], SNAP_V))) for _v in range(8))
    if (_nm or _nv) and os.environ.get("JX_FAIL_ON_NAN_SEED") == "1":
        raise SystemExit("SEED NaN (master=%d voices=%d) and JX_FAIL_ON_NAN_SEED=1"
                         % (_nm, _nv))

    d = os.path.join(outdir, "p%d" % patch); os.makedirs(d, exist_ok=True)
    def rq(a): return int.from_bytes(uc.mem_read(a,8),'little')
    # voice snapshots + links
    for v in range(8):
        st = jx.state[v]
        open(os.path.join(d, "vstate_in_%d.bin" % v), "wb").write(bytes(uc.mem_read(st, SNAP_V)))
        obj = rq(st + 136)
        objb = bytes(uc.mem_read(obj, 256))
        p40 = rq(obj + 40); p64 = rq(obj + 64)
        open(os.path.join(d, "vlink_%d.bin" % v), "wb").write(
            objb + bytes(uc.mem_read(p40,4)) + bytes(uc.mem_read(p64,4)))
    # master snapshot + link
    open(os.path.join(d, "mstate_in.bin"), "wb").write(bytes(uc.mem_read(st8, SNAP_M)))
    mobj = rq(st8+136)
    mobjb = bytes(uc.mem_read(mobj,256))
    p136 = rq(mobj+136); p112 = rq(mobj+112)
    open(os.path.join(d, "mlink.bin"), "wb").write(
        mobjb + bytes(uc.mem_read(p136,4)) + bytes(uc.mem_read(p112,256)))

    # per-sample oracle chain: voices then master, capturing the seam + L/R
    BUF = J.BUF_BASE; p = BUF; off = {}
    for v in range(8):
        off[('m',v)] = p; p += 16
        off[('s',v)] = p; p += 16
    A2 = p; p += 16*8; OUTL = p; p += 8; OUTR = p; p += 8; A3 = p; p += 16
    a2blob = b"".join(struct.pack('<Q',x) for pair in
                      ((off[('m',v)],off[('s',v)]) for v in range(8)) for x in pair)
    uc.mem_write(A2, a2blob); uc.mem_write(A3, struct.pack('<QQ', OUTL, OUTR))
    vins = []; louts = []
    for s in range(n):
        for v in range(8):
            uc.mem_write(J.PB_VOICE, struct.pack("<QQQQQ", jx.state[v], v,
                                                 off[('m',v)], off[('s',v)], 1))
            jx._run(jx.SVOICE)
        vin = []
        for v in range(8):
            vin.append(struct.unpack('<I', uc.mem_read(off[('m',v)],4))[0])
            vin.append(struct.unpack('<I', uc.mem_read(off[('s',v)],4))[0])
        vins.append(vin)
        jx.call(J.IB+MASTER, rcx=st8, rdx=A2, r8=A3)
        louts.append((struct.unpack('<I',uc.mem_read(OUTL,4))[0],
                      struct.unpack('<I',uc.mem_read(OUTR,4))[0]))
    open(os.path.join(d, "vins.bin"), "wb").write(
        b"".join(struct.pack('<16I', *x) for x in vins))
    open(os.path.join(d, "louts.bin"), "wb").write(
        b"".join(struct.pack('<II', l, r) for l, r in louts))
    # final states (the deep half of the null)
    for v in range(8):
        open(os.path.join(d, "vstate_ref_%d.bin" % v), "wb").write(
            bytes(uc.mem_read(jx.state[v], SNAP_V)))
    open(os.path.join(d, "mstate_ref.bin"), "wb").write(bytes(uc.mem_read(st8, SNAP_M)))
    nz = sum(1 for l, r in louts if l or r)
    print("p%d: %d samples, %d nonzero L/R, faults=%d" % (patch, n, nz, jx.faults))

def main():
    outdir = sys.argv[1]
    patches = [int(x) for x in (sys.argv[2] if len(sys.argv) > 2 else "0,5,20,49").split(",")]
    n = int(sys.argv[3]) if len(sys.argv) > 3 else 32
    warm = int(sys.argv[4]) if len(sys.argv) > 4 else 6
    sr = float(sys.argv[5]) if len(sys.argv) > 5 else 44100.0
    # arg 6 or $JX_BANK: any bank file with the same HEADER/STRIDE/BLOB layout
    # as the factory bank. Other banks are INPUT (never ground truth): the
    # oracle still recalls them via the plugin's own dispatch, so the A/B stays
    # a plugin-vs-port comparison, not a bank-derived assertion.
    bank_path = sys.argv[6] if len(sys.argv) > 6 else os.environ.get("JX_BANK", BANK)
    bank = open(bank_path, "rb").read()
    os.makedirs(outdir, exist_ok=True)
    for patch in patches:
        run_patch(outdir, patch, n, warm, bank, sr)
    print("AB EMU REFERENCE WRITTEN to %s" % outdir)

if __name__ == "__main__":
    main()

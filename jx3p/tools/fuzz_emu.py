#!/usr/bin/env python3
"""fuzz_emu.py -- ORACLE side of the JX SEEDED FUZZ A/B (process A).

The gate the JX should have had from the start. docs/GATE_PARITY.tsv row
`seeded_random_diff`. The JUNO has had tools/verify/fuzz_diff.py for months;
the JX was proven against 64 factory patches, which is ONE correlated sample
of the input space. The FTZ/DAZ defect (2026-08-26) lived in the gap.

The seed IS the regression script: a DIVERGE at seed N is replayable forever.

Grammar per seed (every dimension the factory-bank A/B holds constant):
  rate     44100 | 48000 | 96000 | 88200   (88200 is deliberately non-standard:
           it catches rate-dependent constants -- charter rule 5)
  patch    uniform over all 64 factory patches
  warm     1..12 blocks of 256 (the bank A/B always used exactly 6)
  notes    1..6 simultaneous note_on, random pitch 24..96, random velocity
           1..127 (the bank A/B always used exactly one note, 60 @ 100)
  n        32..256 samples (the bank A/B always used 64)

STILL OWED, stated so the coverage is not read wider than it is:
  * note-OFF and release. The plugin's note-off entry is not yet located;
    0x3F91B0 is a 9-unit dispatch of param 0x1ED (bend-shaped), not note-off.
    Tracked in docs/GATE_PARITY.tsv row note_velocity_exhaust.
  * block-size invariance: this renders single samples, like the bank A/B.

Writes the SAME directory layout as ab_render_emu.py, so the proven port-side
comparator ab_render_c.py is reused unchanged (working style: reuse proven
gates before building new machinery).

usage: fuzz_emu.py <outdir> <seed_lo> <seed_hi>
"""
import sys, os, struct, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                "..", "..", "tools", "verify"))
import jx_emu as J
from ab_render_emu import (BANK, HEADER, STRIDE, BLOB_OFF, SNAP_V, SNAP_M,
                           NOTEON, SETSR, MASTER, ACTIVE, decode)

RATES = [44100.0, 48000.0, 96000.0, 88200.0]


def script_for(seed):
    """Deterministic event script. The seed reproduces it exactly, forever."""
    rng = random.Random(seed)
    sr = RATES[seed % len(RATES)]
    patch = rng.randrange(64)
    warm = rng.randint(1, 12)
    nvoice = rng.randint(1, 6)
    notes = []
    used = set()
    while len(notes) < nvoice:
        p = rng.randint(24, 96)
        if p in used:
            continue
        used.add(p)
        notes.append((p, rng.randint(1, 127)))
    n = rng.randint(32, 256)
    return dict(sr=sr, patch=patch, warm=warm, notes=notes, n=n)


def run_seed(outdir, seed, bank):
    s = script_for(seed)
    jx = J.JX().build(); jx.set_ftz(); uc = jx.uc
    rsp = (J.STACK_BASE + J.STACK_SIZE - 0x10000) & ~0xF; rsp -= 8
    uc.reg_write(J.UC_X86_REG_RSP, rsp)
    uc.reg_write(J.UC_X86_REG_RCX, jx.HOST)
    uc.reg_write(J.UC_X86_REG_XMM1, struct.unpack(
        '<Q', struct.pack('<f', float(s['sr'])) + b'\0\0\0\0')[0])
    RET = J.SCRATCH + 0x5000
    uc.mem_write(rsp, struct.pack('<Q', RET))
    uc.emu_start(J.IB + SETSR, RET)

    rec = bank[HEADER + s['patch'] * STRIDE:]; blob = rec[BLOB_OFF:]
    for u in range(J.N_UNITS):
        for pool in ACTIVE:
            jx.dispatch(u, pool + 740, decode(blob, pool))

    for pitch, vel in s['notes']:
        jx.call(J.IB + NOTEON, rcx=jx.HOST, rdx=pitch, r8=vel)

    st8 = jx.state[8]
    uc.mem_write(st8 + 11191048, b'\x00\x00\x00\x00')
    uc.mem_write(st8 + 20, b'\x01')
    for _ in range(s['warm']):
        jx.render(256)

    # One seed per PARENT directory: each seed has its own render length, and
    # the proven comparator (ab_render_c.py) takes one length for the whole
    # directory it is given. s<seed>/p0/ keeps that comparator unchanged.
    d = os.path.join(outdir, "s%d" % seed, "p0"); os.makedirs(d, exist_ok=True)

    def rq(a): return int.from_bytes(uc.mem_read(a, 8), 'little')

    for v in range(8):
        st = jx.state[v]
        open(os.path.join(d, "vstate_in_%d.bin" % v), "wb").write(
            bytes(uc.mem_read(st, SNAP_V)))
        obj = rq(st + 136)
        objb = bytes(uc.mem_read(obj, 256))
        p40 = rq(obj + 40); p64 = rq(obj + 64)
        open(os.path.join(d, "vlink_%d.bin" % v), "wb").write(
            objb + bytes(uc.mem_read(p40, 4)) + bytes(uc.mem_read(p64, 4)))
    open(os.path.join(d, "mstate_in.bin"), "wb").write(
        bytes(uc.mem_read(st8, SNAP_M)))
    mobj = rq(st8 + 136)
    mobjb = bytes(uc.mem_read(mobj, 256))
    p136 = rq(mobj + 136); p112 = rq(mobj + 112)
    open(os.path.join(d, "mlink.bin"), "wb").write(
        mobjb + bytes(uc.mem_read(p136, 4)) + bytes(uc.mem_read(p112, 256)))

    BUF = J.BUF_BASE; p = BUF; off = {}
    for v in range(8):
        off[('m', v)] = p; p += 16
        off[('s', v)] = p; p += 16
    A2 = p; p += 16 * 8; OUTL = p; p += 8; OUTR = p; p += 8; A3 = p; p += 16
    a2blob = b"".join(struct.pack('<Q', x) for pair in
                      ((off[('m', v)], off[('s', v)]) for v in range(8))
                      for x in pair)
    uc.mem_write(A2, a2blob)
    uc.mem_write(A3, struct.pack('<QQ', OUTL, OUTR))
    vins = []; louts = []
    for _ in range(s['n']):
        for v in range(8):
            uc.mem_write(J.PB_VOICE, struct.pack("<QQQQQ", jx.state[v], v,
                                                 off[('m', v)], off[('s', v)], 1))
            jx._run(jx.SVOICE)
        vin = []
        for v in range(8):
            vin.append(struct.unpack('<I', uc.mem_read(off[('m', v)], 4))[0])
            vin.append(struct.unpack('<I', uc.mem_read(off[('s', v)], 4))[0])
        vins.append(vin)
        jx.call(J.IB + MASTER, rcx=st8, rdx=A2, r8=A3)
        louts.append((struct.unpack('<I', uc.mem_read(OUTL, 4))[0],
                      struct.unpack('<I', uc.mem_read(OUTR, 4))[0]))
    open(os.path.join(d, "vins.bin"), "wb").write(
        b"".join(struct.pack('<16I', *x) for x in vins))
    open(os.path.join(d, "louts.bin"), "wb").write(
        b"".join(struct.pack('<II', l, r) for l, r in louts))
    for v in range(8):
        open(os.path.join(d, "vstate_ref_%d.bin" % v), "wb").write(
            bytes(uc.mem_read(jx.state[v], SNAP_V)))
    open(os.path.join(d, "mstate_ref.bin"), "wb").write(
        bytes(uc.mem_read(st8, SNAP_M)))
    open(os.path.join(d, "script.txt"), "w").write(repr(s) + "\n")
    nz = sum(1 for l, r in louts if l or r)
    print("seed %d: sr=%g patch=%d warm=%d notes=%s n=%d -> %d nonzero, faults=%d"
          % (seed, s['sr'], s['patch'], s['warm'], s['notes'], s['n'], nz,
             jx.faults))
    return s['n'], nz


def main():
    outdir = sys.argv[1]
    lo = int(sys.argv[2]); hi = int(sys.argv[3])
    bank = open(BANK, "rb").read()
    os.makedirs(outdir, exist_ok=True)
    tot_nz = 0
    for seed in range(lo, hi):
        _, nz = run_seed(outdir, seed, bank)
        tot_nz += nz
    print("FUZZ ORACLE: seeds %d..%d written to %s" % (lo, hi - 1, outdir))
    if tot_nz == 0:
        raise SystemExit("REFUSE: every seed rendered silence -- the gate would "
                         "be comparing zeros, which any port passes")


if __name__ == "__main__":
    main()

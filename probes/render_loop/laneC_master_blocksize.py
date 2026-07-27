#!/usr/bin/env python3
"""LANE C addendum — is the MASTER half of 0x3C7400 block-size independent?

READ: between samples the master loop does nothing; all per-block work (vector
resize, work-item fill, assigner+=b, barrier) happens before it and touches no
master state. PROVEN here: drive the plugin's own 0x3C7400 master loop with the
SAME 64-sample input stream once as a single block of 64 and once as 4 chained
blocks of 16, from the same master state, and compare the output bit-for-bit.
Also does the same for the e2e_emu master stub (block=600 vs chained blocks).
"""
import os, struct, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', 'tools', 'verify'))
import e2e_emu as E
import real_recall as R
import recall_render_ab as RA
from unicorn import UC_PROT_ALL
from unicorn.x86_const import *
from laneC_master_abi import call6, q, d, SCRATCH_BASE, SCRATCH_SIZE

RENDER_BLOCK = E.IB + 0x3C7400
SR = 48000.0
N = 64
PATCH = int(os.environ.get('LANEC_PATCH', '2'))
AMP = 0.001


def main():
    bank = E.bank_bytes(); leaves = R.leaf_table()
    e = RA.prepare_recall(PATCH, bank, leaves, E, R, SR)
    uc = e.uc; H = e.HOST
    uc.mem_map(SCRATCH_BASE, SCRATCH_SIZE, UC_PROT_ALL)
    uc.mem_write(SCRATCH_BASE, b"\0" * SCRATCH_SIZE)
    outL, outR, a4 = SCRATCH_BASE + 0x1000, SCRATCH_BASE + 0x4000, SCRATCH_BASE
    uc.mem_write(a4, struct.pack("<QQ", outL, outR))
    uc.mem_write(H + 56, struct.pack("<i", 8))

    uc.mem_write(H + 1072, struct.pack("<i", 8))
    call6(e, RENDER_BLOCK, H, 0, 0, a4, 0, N)          # allocate the vectors at N
    bufs = [(q(uc, H + 656 + 48*i), q(uc, H + 680 + 48*i)) for i in range(8)]
    MS = e.state[8]
    S0 = bytes(uc.mem_read(MS, E.STATE_SZ))

    def val(slot, s):
        return AMP * ((slot + 1) * 0.0117 + s * 0.00031)

    def load(off, cnt):
        for i in range(8):
            uc.mem_write(bufs[i][0], struct.pack("<%df" % cnt,
                         *[val(2*i, off + s) for s in range(cnt)]))
            uc.mem_write(bufs[i][1], struct.pack("<%df" % cnt,
                         *[val(2*i+1, off + s) for s in range(cnt)]))

    def plugin_chain(sizes):
        """Each block is run TWICE: a throwaway 'sizing' call (whose master-state
        mutation is rolled back) so the vector resize -- including the GROW path's
        memset of the newly grown tail, sub_7FF91DFA3830 -> sub_7FF91E30F460 --
        happens BEFORE we inject the block's input, exactly as the real pool writes
        the samples after the resize. Without this, a size increase wipes the
        sentinels inside the call and manufactures a fake divergence."""
        uc.mem_write(MS, S0)
        L = []; Rr = []; off = 0
        for b in sizes:
            Sk = bytes(uc.mem_read(MS, E.STATE_SZ))
            uc.mem_write(H + 1072, struct.pack("<i", 8))
            call6(e, RENDER_BLOCK, H, 0, 0, a4, 0, b)     # sizing only
            uc.mem_write(MS, Sk)
            load(off, b)
            uc.mem_write(outL, b"\0" * (4*b)); uc.mem_write(outR, b"\0" * (4*b))
            uc.mem_write(H + 1072, struct.pack("<i", 8))
            call6(e, RENDER_BLOCK, H, 0, 0, a4, 0, b)     # real
            L += list(struct.unpack("<%dI" % b, uc.mem_read(outL, 4*b)))
            Rr += list(struct.unpack("<%dI" % b, uc.mem_read(outR, 4*b)))
            off += b
        return L, Rr

    def oracle_chain(sizes):
        uc.mem_write(MS, S0)
        L = []; Rr = []; off = 0
        for b in sizes:
            load(off, b)
            uc.mem_write(outL, b"\0" * (4*b)); uc.mem_write(outR, b"\0" * (4*b))
            a2 = b"".join(struct.pack("<Q", x) for pair in bufs for x in pair)
            uc.mem_write(E.PB_MASTER,
                         struct.pack("<QQQQ", MS, outL, outR, b) + b"\0"*16 + a2)
            e._run(e.SMASTER)
            L += list(struct.unpack("<%dI" % b, uc.mem_read(outL, 4*b)))
            Rr += list(struct.unpack("<%dI" % b, uc.mem_read(outR, 4*b)))
            off += b
        return L, Rr

    p1L, p1R = plugin_chain([N])
    p4L, p4R = plugin_chain([16, 16, 16, 16])
    # Ragged chains. Without plugin_chain's sizing pre-pass these showed fake
    # divergences ([7,1,40,16] -> L diff 39/64) purely because sub_7FF91DFA3830's
    # GROW path memsets each voice vector's newly grown tail to 0 inside 0x3C7400,
    # after this probe had already written the block's samples.
    p7L, p7R = plugin_chain([7, 1, 40, 16])
    p9L, p9R = plugin_chain([32, 16, 8, 4, 2, 1, 1])
    o1L, o1R = oracle_chain([N])
    o4L, o4R = oracle_chain([16, 16, 16, 16])

    def cmp(a, b):
        return sum(1 for x, y in zip(a, b) if x != y)

    print("patch %d (%s) @ %g Hz, N=%d, AMP=%g" % (PATCH, E.patch_name(bank, PATCH), SR, N, AMP))
    print("plugin  1x64  vs  4x16   : L diff %d/%d  R diff %d/%d"
          % (cmp(p1L, p4L), N, cmp(p1R, p4R), N))
    print("plugin  1x64  vs 7,1,40,16 : L diff %d/%d  R diff %d/%d"
          % (cmp(p1L, p7L), N, cmp(p1R, p7R), N))
    print("oracle  1x64  vs  4x16   : L diff %d/%d  R diff %d/%d"
          % (cmp(o1L, o4L), N, cmp(o1R, o4R), N))
    print("plugin 1x64 vs oracle 1x64: L diff %d/%d  R diff %d/%d"
          % (cmp(p1L, o1L), N, cmp(p1R, o1R), N))
    print("plugin 4x16 vs oracle 4x16: L diff %d/%d  R diff %d/%d"
          % (cmp(p4L, o4L), N, cmp(p4R, o4R), N))
    print("plugin  1x64  vs 32,16,8,4,2,1,1: L diff %d/%d  R diff %d/%d"
          % (cmp(p1L, p9L), N, cmp(p1R, p9R), N))
    print("output varies over s: %s" % (len(set(p1L)) > 1))


if __name__ == "__main__":
    main()

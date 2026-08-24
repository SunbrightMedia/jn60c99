#!/usr/bin/env python3
"""probe_pools.py -- HONEST re-derivation of the JX recall ACTIVE pool set.

Supersedes the discovery loop inside recall_ref_emu.py, which had TWO flaws
that silently narrowed the port's proven scope (found 2026-08-24 when the
user counted 63 panel parameters in a host against the tool's 32):

  1. It watched a 16128-byte VOICE-0 window only. Every master/FX parameter
     (HPF CUTOFF, EFFECT LEVEL/TYPE/TONE, DELAY LEVEL/TIME, REVERB *, VCA
     LEVEL) writes the MASTER unit and was therefore invisible.
  2. It probed each pool only with the values that pool happens to take in
     the FACTORY bank. A parameter that is constant across all 64 factory
     patches never moved off the clean base, so it looked inactive.

This probe fixes both: FULL state windows, on the voice unit AND the master
unit, with a spread of in-range values. A pool is ACTIVE if any probe moves
any byte of either window.

Output: JSON {pool: {"voice": bool, "master": bool}} + a printed summary.
usage: probe_pools.py <out.json> [pool_lo=2] [pool_hi=140]
"""
import sys, os, json, hashlib

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                "..", "..", "tools", "verify"))
import jx_emu as J

SNAP_V = 0x60000      # voice unit window (as used by the render A/B)
SNAP_M = 0xAAD000     # master unit window: FULL, so reverb/delay tails count
VALUES = (0, 255, 1, 64, 128, 192)


def main():
    out = sys.argv[1]
    lo = int(sys.argv[2]) if len(sys.argv) > 2 else 2
    hi = int(sys.argv[3]) if len(sys.argv) > 3 else 140

    jx = J.JX().build(); jx.set_ftz(); uc = jx.uc
    st0, st8 = jx.state[0], jx.state[8]
    base0 = bytes(uc.mem_read(st0, SNAP_V))
    base8 = bytes(uc.mem_read(st8, SNAP_M))
    h0 = hashlib.blake2b(base0, digest_size=16).digest()
    h8 = hashlib.blake2b(base8, digest_size=16).digest()

    res = {}
    for pool in range(lo, hi):
        idx = pool + 740
        mv = mm = False
        for v in VALUES:
            if not mv:
                jx.dispatch(0, idx, v)
                if hashlib.blake2b(bytes(uc.mem_read(st0, SNAP_V)),
                                   digest_size=16).digest() != h0:
                    mv = True
                uc.mem_write(st0, base0)
            if not mm:
                jx.dispatch(8, idx, v)
                if hashlib.blake2b(bytes(uc.mem_read(st8, SNAP_M)),
                                   digest_size=16).digest() != h8:
                    mm = True
                uc.mem_write(st8, base8)
            if mv and mm:
                break
        if mv or mm:
            res[pool] = {"voice": mv, "master": mm}
        sys.stderr.write("pool %3d: voice=%d master=%d\n" % (pool, mv, mm))

    json.dump(res, open(out, "w"), indent=0, sort_keys=True)
    act = sorted(int(k) for k in res)
    print("ACTIVE pools: %d" % len(act))
    print("  voice-writing : %s" % [p for p in act if res[str(p)]["voice"]])
    print("  master-writing: %s" % [p for p in act if res[str(p)]["master"]])
    print("faults=%d" % jx.faults)


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""jx_bank_census.py -- the DECODE TOOTH for the factory bank.

Decodes every pool of every patch with jx_emu.pool_value and checks each
value against the ENGINE DB row {min,max} the binary itself declares for
that pool's dispatch id (pe_recon params). A byte->pool formula that is
off by even one field puts switch values (0..5) on continuous fields and
continuous values on switches; this census counts those violations and
FAILS on any. It also refuses a silent bank: a level pool that is 0 on
every patch is a defect, not a design.

usage: jx_bank_census.py [--offset N]   (N overrides the formula's byte
                                          offset, to SEE THE TOOTH BITE:
                                          --offset 8 reproduces the old +8
                                          decode and must FAIL)
"""
import sys, os, struct
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                "..", "..", "tools", "verify"))
import jx_emu as J
import pe_recon

LEVEL_POOLS = {30: "DCO1 LEVEL", 39: "VCF CUTOFF FREQ", 46: "ENV1 SUSTAIN",
               51: "ENV2 SUSTAIN"}


def main():
    off = None
    if "--offset" in sys.argv:
        off = int(sys.argv[sys.argv.index("--offset") + 1])
    pe = pe_recon.PE(os.path.join(J.REPO, "jx3p", "truth", "JX3P.vst3"))
    rows = pe.params([J.POOL_BASE_ID + p for p in J.ACTIVE_POOLS])["rows"]
    bank = J.bank_bytes()
    bad = 0
    per_pool = {}
    for idx in range(64):
        blob = J.patch_blob(bank, idx)
        for pool in J.ACTIVE_POOLS:
            if off is None:
                v = J.pool_value(blob, pool)
            else:
                p = 2 * pool + off
                v = ((blob[p] & 0xF) << 4) | (blob[p + 1] & 0xF)
            r = rows[J.POOL_BASE_ID + pool]
            lo, hi = r["min"], r["max"]
            if lo < 0:                       # signed engine frame stored raw
                lo, hi = 0, hi - lo
            per_pool.setdefault(pool, []).append(v)
            if not (lo <= v <= hi):
                bad += 1
                if bad <= 12:
                    print("  patch %2d pool %2d %-22s = %3d  out of [%d,%d]"
                          % (idx, pool, r["name"], v, lo, hi))
    silent = [(p, n) for p, n in LEVEL_POOLS.items() if max(per_pool[p]) == 0]
    for p, n in silent:
        print("  pool %d %s is 0 on ALL 64 patches" % (p, n))
    print("bank census (%s): %d out-of-range values, %d silent level pools"
          % ("offset %+d" % off if off is not None else "jx_emu.pool_value",
             bad, len(silent)))
    ok = bad == 0 and not silent
    print("JX BANK CENSUS: %s" % ("GREEN" if ok else "FAIL"))
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()

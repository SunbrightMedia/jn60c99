#!/usr/bin/env python3
"""jp8_bank_census.py -- the DECODE TOOTH for the JP8 factory bank (twin of
jx3p/tools/jx_bank_census.py). Decodes every pool of every patch and checks
each value against the ENGINE DB {min,max} the binary declares for that
pool's dispatch id. --offset N overrides the byte offset to SEE THE TOOTH
BITE (the formula is -8; -6 and -10 must FAIL)."""
import sys, os
sys.path.insert(0, "/home/user/jn60c99/tools/verify")
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pe_recon, jp8_bank as B

BIN = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "truth",
                   "JUPITER-8VST3_64bit.vst3")
LEVEL_POOLS = {30: "MIXER VCO1", 39: "VCF CUTOFF", 46: "ENV1 SUSTAIN", 51: "ENV2 SUSTAIN", 70: "VCA LEVEL"}


def main():
    off = int(sys.argv[sys.argv.index("--offset") + 1]) if "--offset" in sys.argv else -8
    pe = pe_recon.PE(BIN)
    rows = pe.params([B.POOL_BASE_ID + p for p in B.ACTIVE_POOLS])["rows"]
    bank = B.bank_bytes()
    bad = 0; per_pool = {}; names = []
    for idx in range(B.NPATCH):
        blob = B.patch_blob(bank, idx); names.append(B.patch_name(bank, idx))
        for pool in B.ACTIVE_POOLS:
            v = B.pool_value(blob, pool, off)
            r = rows[B.POOL_BASE_ID + pool]; lo, hi = r["min"], r["max"]
            if lo < 0: lo, hi = 0, hi - lo
            per_pool.setdefault(pool, []).append(v)
            if not (lo <= v <= hi):
                bad += 1
                if bad <= 8: print("  patch %2d pool %2d %-20s = %3d out of [%d,%d]" % (idx, pool, r["name"], v, lo, hi))
    silent = [(p, n) for p, n in LEVEL_POOLS.items() if max(per_pool[p]) == 0]
    for p, n in silent: print("  pool %d %s is 0 on ALL 64 patches" % (p, n))
    nonascii = sum(1 for n in names if not all(32 <= ord(c) < 127 for c in n))
    print("names: %s ... %s (non-ASCII names: %d)" % (names[:3], names[-2:], nonascii))
    print("bank census (offset %+d): %d out-of-range values, %d silent level pools" % (off, bad, len(silent)))
    ok = bad == 0 and not silent and nonascii == 0
    print("JP8 BANK CENSUS: %s" % ("GREEN" if ok else "FAIL"))
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()

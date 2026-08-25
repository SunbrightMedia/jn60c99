#!/usr/bin/env python3
"""recall_model_check.py -- test the port recall MODEL against the sequential
reference, all 64 patches, bit-exact. Model = clean base + isolated per-pool LUT
writes, with the 7 interacting cells resolved by the value-pool-wins rule:
  1072<-pool12, 3056<-pool49, 3072<-pool50, 3104<-pool52, and 3088/4000/13440
  stay clean. (The mode pools 115/117/135 write these only as a from-clean
  default that the real ordered sequence discards.) Prints per-cell/per-patch
  mismatches so any residual is visible."""
import sys, os, struct, pickle, json
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "tools", "verify"))
import jx_emu as J

BANK = os.path.join(J.REPO, "jx3p", "truth", "preset_bank_1.bin")
BLOCK = 16128; HEADER = 23; STRIDE = 20223; BLOB_OFF = 16; NPATCH = 64
# interacting cell -> value pool to trust (None = keep clean)
# 1088 added 2026-08-25, when the corrected 57-pool census widened the active
# set. Cell 1088 is written by pool 12 (LFO RATE) and pool 138 (LFO RATE H) --
# a high/low resolution pair. DERIVED, not guessed:
#   * pool 12 at its patch value writes 1088 (e.g. v=2 -> 0x3C008081);
#   * pool 138 at v=0 writes NOTHING in isolation, because the clean base is
#     already 0 so the per-pool diff records no change;
#   * the ORACLE's sequential recall ends with 1088 == 0 on all 64 patches,
#     i.e. pool 138 runs LAST and RESETS the cell.
# So the composed value must stay CLEAN, not keep pool 12's write. 'pool 12
# wins' was tried first and failed on all 64 patches -- the opposite rule to
# cell 1072, which really is pool-12-wins.
# BOUND: pool 138 is CONSTANT 0 across the whole factory bank, so this is
# proven only for LFO RATE H == 0. A bank that varies it needs the true JOINT
# law derived; the fxsweep/census tooling is the way to get it.
OVERRIDE = {1072: 12, 1088: None, 3056: 49, 3072: 50, 3088: None, 3104: 52, 4000: None, 13440: None}

def decode(blob, pool):
    p = 2 * pool + 8
    return ((blob[p] & 0xF) << 4) | (blob[p + 1] & 0xF)

def main():
    refdir = sys.argv[1]
    ref = pickle.load(open(os.path.join(refdir, "recall_ref.pkl"), "rb"))
    D = pickle.load(open(os.path.join(refdir, "recall_lut.pkl"), "rb"))
    lut = D["lut"]; active = D["active"]; clean = D["clean"]
    bank = open(BANK, "rb").read()
    fails = 0
    for patch in range(NPATCH):
        rec = bank[HEADER + patch * STRIDE:]; blob = rec[BLOB_OFF:]
        comp = bytearray(clean)
        for pool in active:
            for o, val in lut[pool][decode(blob, pool)].items():
                if o in OVERRIDE:
                    continue                     # handled below, never by raw compose
                comp[o:o+4] = val
        for o, vp in OVERRIDE.items():
            if vp is None:
                comp[o:o+4] = clean[o:o+4]
            else:
                w = lut[vp][decode(blob, vp)].get(o)
                comp[o:o+4] = w if w else clean[o:o+4]
        r = ref[patch]
        diffs = [o for o in range(0, BLOCK, 4) if bytes(comp[o:o+4]) != r[o:o+4]]
        if diffs:
            fails += 1
            print("patch %d: %d diffs %s" % (patch, len(diffs), diffs[:12]))
    print("MODEL vs reference: %d/%d patches EXACT" % (NPATCH - fails, NPATCH))
    print("RECALL MODEL: EXACTLY 0" if fails == 0 else "RECALL MODEL: NONZERO")
    return 0 if fails == 0 else 1

if __name__ == "__main__":
    sys.exit(main())

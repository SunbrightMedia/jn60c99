#!/usr/bin/env python3
"""recall_joint.py -- reverse the 7 interacting-cell laws. For each interacting
cell, print per-patch: the two (or more) writer-pool input bytes, the isolated
LUT value from each writer, and the true sequential reference value (as float and
hex). Enough to read off the joint law (product / lerp / mode-select), the way
JUNO's apply_bend_mod_sens was found."""
import sys, os, struct, pickle, json
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "tools", "verify"))
import jx_emu as J

BANK = os.path.join(J.REPO, "jx3p", "truth", "preset_bank_1.bin")
BLOCK = 16128; HEADER = 23; STRIDE = 20223; BLOB_OFF = 16; NPATCH = 64
CELLS = [1072, 3056, 3072, 3088, 3104, 4000, 13440]

def decode(blob, pool):
    p = 2 * pool - 8   # CORRECTED 2026-09-05 (playbook 88, jx_bank_census.py)
    return ((blob[p] & 0xF) << 4) | (blob[p + 1] & 0xF)

def f(b):  # 4 bytes -> float
    return struct.unpack('<f', b)[0]

def main():
    refdir = sys.argv[1]
    ref = pickle.load(open(os.path.join(refdir, "recall_ref.pkl"), "rb"))
    D = pickle.load(open(os.path.join(refdir, "recall_lut.pkl"), "rb"))
    lut = D["lut"]; writers = D["writers"]; clean = D["clean"]
    bank = open(BANK, "rb").read()
    for cell in CELLS:
        w = writers[cell]
        print("\n=== cell %d  writers=%s ===" % (cell, w))
        cf = f(clean[cell:cell+4])
        for patch in range(0, NPATCH, 8):
            rec = bank[HEADER + patch * STRIDE:]; blob = rec[BLOB_OFF:]
            bytes_in = [(p, decode(blob, p)) for p in w]
            iso = []
            for p in w:
                wr = lut[p][decode(blob, p)].get(cell)
                iso.append(f(wr) if wr else None)
            trueval = f(ref[patch][cell:cell+4])
            print("  p%02d in=%s iso=%s true=%.6g (0x%08x) clean=%.6g"
                  % (patch, bytes_in,
                     ["%.6g" % x if x is not None else "None" for x in iso],
                     trueval, struct.unpack('<I', ref[patch][cell:cell+4])[0], cf))

if __name__ == "__main__":
    main()

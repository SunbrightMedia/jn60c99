#!/usr/bin/env python3
"""jx_recall_gate.py -- prove the C recall (jx_bank_apply) reproduces the oracle
recall reference bit-for-bit, all 64 patches. Process B (ctypes only; the oracle
pickle was written by recall_ref_emu.py under Unicorn). EXACTLY 0."""
import sys, os, ctypes, pickle

BANK = None
def main():
    refdir = sys.argv[1]; so = sys.argv[2]
    ref = pickle.load(open(os.path.join(refdir, "recall_ref.pkl"), "rb"))
    clean = pickle.load(open(os.path.join(refdir, "recall_lut.pkl"), "rb"))["clean"]
    bankp = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "truth", "preset_bank_1.bin")
    bank = open(bankp, "rb").read()
    BLOCK = len(clean)
    lib = ctypes.CDLL(so)
    fn = lib.jx_bank_apply
    fn.restype = ctypes.c_int
    fn.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int]
    cbank = ctypes.c_char_p(bank)
    fails = 0
    for patch in range(64):
        blk = bytearray(clean)
        buf = (ctypes.c_ubyte * BLOCK).from_buffer(blk)
        fn(ctypes.addressof(buf), cbank, patch)
        r = ref[patch]
        diffs = [o for o in range(0, BLOCK, 4) if bytes(blk[o:o+4]) != r[o:o+4]]
        if diffs:
            fails += 1
            print("patch %d: %d diffs %s" % (patch, len(diffs), diffs[:12]))
    print("JX RECALL: %d/64 patches EXACT" % (64 - fails))
    print("JX RECALL NULL: EXACTLY 0" if fails == 0 else "JX RECALL NULL: NONZERO -- DEFECT")
    return 0 if fails == 0 else 1

if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
import sys, pickle, struct
ref = pickle.load(open(sys.argv[1], "rb")); cand = pickle.load(open(sys.argv[2], "rb"))
VS = 10512
for stage in ("after_recall", "after_idle", "after_noteon", "after_post"):
    print("== %s ==" % stage)
    for v in range(8):
        r = ref[stage][v]; c = cand[stage]
        lo, hi = v * VS, (v + 1) * VS
        d = [i for i in range(lo, hi, 4) if r[i:i+4] != c[i:i+4]]
        if d:
            print("  voice %d: %d differing dwords, first %s" % (v, len(d), [(x, x - lo) for x in d[:8]]))
    # noise block + aux, compare vs unit v as well
    for name, lo, hi in (("noise", 84272, 84436), ("aux", 101504, 101504 + 8 * 32)):
        for v in range(8):
            r = ref[stage][v]; c = cand[stage]
            d = [i for i in range(lo, hi, 4) if r[i:i+4] != c[i:i+4]]
            if d: print("  %s vs unit%d: %d diff, first %s" % (name, v, len(d), d[:6]))
            if name == "noise": break
if "post" in ref:
    L, R = ref["post"]; c = cand["post"]
    ref_i = []
    for lb, rb in zip(L, R):
        ref_i.append(struct.unpack("<f", struct.pack("<I", lb))[0])
        ref_i.append(struct.unpack("<f", struct.pack("<I", rb))[0])
    n = sum(1 for a, b in zip(ref_i, c) if a != b)
    print("post-note audio: %d/%d samples differ" % (n, len(ref_i)))

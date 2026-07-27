import sys
sys.path.insert(0, 'tools/verify')
# dropped indices from enum_vs_applied
dropped = [20, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 189, 196, 254, 312, 313, 314, 315, 316, 317, 318, 373, 375, 433, 434, 435, 436, 437, 438, 439, 440, 450, 451, 452, 453, 454, 455, 456, 457, 467, 468, 469, 470, 471, 472, 473, 474, 484, 493, 495, 498, 553, 554, 555, 614, 657, 665, 668, 669, 699, 707, 710, 711, 878, 1029, 1178, 1213, 1214, 1215, 1242, 1243, 1244, 1245, 1246, 1247, 1248]
by_disp = {}
for ln in open('tools/verify/coverage_leaves.tsv').read().splitlines()[1:]:
    f = ln.split('\t')
    pos, disp, fam, struct_, name, ty, rng, dflt, dok = f
    by_disp[int(disp)] = (fam, struct_, name, ty, rng, dflt, dok)
for d in dropped:
    if d in by_disp:
        fam, struct_, name, ty, rng, dflt, dok = by_disp[d]
        print("%5d  disp_ok=%s  %-14s %-16s %-28s ty=%s rng=%s dflt=%s" % (d, dok, fam, struct_, name, ty, rng, dflt))
    else:
        print("%5d  <not in coverage_leaves.tsv>" % d)

#!/usr/bin/env python3
"""idle probe of the census drive: per-64-sample-window dry-sum peak / master-L peak / NaN, variant = nosnap | snap"""
import sys, os, struct, time
sys.dont_write_bytecode = True
sys.path.insert(0, "/home/user/jn60c99/jp8/tools"); sys.path.insert(0, "/home/user/jn60c99/tools/verify")
import numpy as np, jp8_emu as J
var = sys.argv[1]; N = int(sys.argv[2]) if len(sys.argv) > 2 else 4096
jp = J.JP8(); jp.run_static_init(); jp.build(); jp.set_ftz(); jp.set_sr(44100.0); print("hostinit", jp.host_init())
jp.recall(2)
if var == "snap": jp.snap_ramps(); jp.clear_latch()
lat = struct.unpack("<i", jp.uc.mem_read(jp.state[0] + J.LATCH_OFF, 4))[0]; print("latch unit0", lat)
first = None
for w in range(N // 64):
    dry, L, R = jp.render_both(64)
    Lf = np.frombuffer(struct.pack("<64I", *L), np.float32); Rf = np.frombuffer(struct.pack("<64I", *R), np.float32)
    d = np.abs(np.array(dry)); m = max(float(np.nanmax(np.abs(Lf))), float(np.nanmax(np.abs(Rf))))
    if w < 20 or w % 8 == 0 or (first is None and (d.max() > 1e-3 or m > 1e-3)):
        print("win %3d s%5d dry_peak %.6g master_peak %.6g nanL %d dry_nan %d" % (w, w * 64, d.max(), m, int(np.isnan(Lf).sum()), jp.dry_nan))
    if first is None and (d.max() > 1e-3 or m > 1e-3): first = w * 64 + int(np.argmax((d > 1e-3) | (np.abs(Lf) > 1e-3)))
print("first sample |x|>1e-3:", first)

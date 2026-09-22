#!/usr/bin/env python3
"""t1_emu.py -- SCRATCH probe, process A (Unicorn only): the ORACLE driving itself through the proposed shipping
order (T1): static init -> BUILD -> FTZ -> SETSR(44100 float) -> host_init -> SNAP (latch LIVE) -> recall(patch,
flag 0 + notify) -> render in render_both's own 256-blocks (the jp8_emu stubs) with the 16 voice words kept ->
note-on 60 -> render -> note-off 60 -> render. Writes words (18 per sample) + the final heap for the C probe.
usage: t1_emu.py <outdir> <patch> [idle] [on] [off]"""
import sys, os, struct, time, hashlib
sys.path.insert(0, "/home/user/jn60c99/jp8/tools"); sys.path.insert(0, "/home/user/jn60c99/tools/verify")
import jp8_emu as J
out, patch = sys.argv[1], int(sys.argv[2])
IDLE, ON, OFF = (int(sys.argv[3]) if len(sys.argv) > 3 else 4096), (int(sys.argv[4]) if len(sys.argv) > 4 else 4096), (int(sys.argv[5]) if len(sys.argv) > 5 else 4096)
os.makedirs(out, exist_ok=True); t0 = time.time()
def log(m): print("[%6.1fs] %s" % (time.time() - t0, m), flush=True)
jp = J.JP8(); ok, fail = jp.run_static_init(); uc = jp.uc
jp.build(); jp.set_ftz(); jp.set_sr(44100.0); w, f = jp.host_init(); assert f == 0
jp.snap_ramps()                                  # latch NOT cleared: the plugin's own warm-up mute runs
h_init = hashlib.sha256(bytes(uc.mem_read(J.HEAP_BASE, jp.heap - J.HEAP_BASE))).hexdigest()[:16]
jp.recall(patch)
log("booted T1: static ok %d, host writes %d, heap ptr 0x%x, init heap sha %s" % (ok, w, jp.heap, h_init))
BLOCK = 256
offs = {}; p = J.BUF_BASE
for v in range(8):
    offs[('m', v)] = p; p += 4 * BLOCK; offs[('s', v)] = p; p += 4 * BLOCK
offL = p; p += 4 * BLOCK; offR = p; p += 4 * BLOCK
words = bytearray()
def render(n):
    done = 0
    while done < n:
        b = min(BLOCK, n - done)
        vw = []
        for v in range(8):
            uc.mem_write(J.PB_VOICE, struct.pack("<QQQQQ", jp.state[v], v, offs[('m', v)], offs[('s', v)], b))
            jp._run(jp.SVOICE)
            vw.append((uc.mem_read(offs[('m', v)], 4 * b), uc.mem_read(offs[('s', v)], 4 * b)))
        a2 = b"".join(struct.pack("<Q", x) for pair in ((offs[('m', v)], offs[('s', v)]) for v in range(8)) for x in pair)
        uc.mem_write(J.PB_MASTER, struct.pack("<QQQQ", jp.state[8], offL, offR, b) + b"\x00" * 16 + a2)
        jp._run(jp.SMASTER)
        Lb = uc.mem_read(offL, 4 * b); Rb = uc.mem_read(offR, 4 * b)
        for s in range(b):
            for v in range(8):
                words.extend(vw[v][0][4 * s:4 * s + 4]); words.extend(vw[v][1][4 * s:4 * s + 4])
            words.extend(Lb[4 * s:4 * s + 4]); words.extend(Rb[4 * s:4 * s + 4])
        done += b
render(IDLE); jp.note_on(60, 100); render(ON); jp.note_off(60, 64); render(OFF)
open(os.path.join(out, "words.bin"), "wb").write(bytes(words))
open(os.path.join(out, "heap_end.bin"), "wb").write(bytes(uc.mem_read(J.HEAP_BASE, jp.heap - J.HEAP_BASE)))
open(os.path.join(out, "meta.txt"), "w").write("%d %d %d %d %s\n" % (IDLE, ON, OFF, jp.heap, h_init))
import numpy as np
wf = np.frombuffer(bytes(words), dtype=np.float32).reshape(-1, 18)
for a, b, lab in ((0, 960, "latch"), (960, IDLE, "idle"), (IDLE, IDLE + ON, "note 60"), (IDLE + ON, IDLE + ON + OFF, "release")):
    seg = wf[a:b]
    log("%-8s %5d..%5d: master peak %.4g  dry(main sum) peak %.4g  NaN %d" % (lab, a, b, np.nanmax(np.abs(seg[:, 16:18])), np.nanmax(np.abs(seg[:, 0:16:2].sum(1))), int(np.isnan(seg).sum())))
log("T1 oracle probe done: %d samples, faults after static init %d" % (len(wf), jp.faults))
